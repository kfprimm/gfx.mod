Private 

Type TBatchImageGlobals
	Field _vshader:ID3D11VertexShader[32]
	Field _pshader:ID3D11PixelShader
	Field _layout:ID3D11InputLayout

	Field _vs$ = LoadText("incbin::batch.vs")
	Field _ps$ = LoadText("incbin::batch.ps")
	
	Field _shaderready
	
	Method FreeResources()
		For Local i = 0 Until 32
			SAFE_RELEASE(_vshader[i])
		Next
		SAFE_RELEASE(_pshader)
		SAFE_RELEASE(_layout)
	EndMethod
EndType

Incbin "batch.vs"
Incbin "batch.ps"

Global _BIG:TBatchImageGlobals

Public

Type TBatchImage
	Field _readytodraw
	Field _isvalid
	
	Field _numframes
	Field _image:TImage
	Field _tex:ID3D11Texture2D
	Field _sampler:ID3D11SamplerState
	Field _srv:ID3D11ShaderResourceView
	
	Field _ilength
	Field _shaderindex
	Field _vbuffer:ID3D11Buffer
	Field _dbuffer:ID3D11Buffer
	Field _cbuffer:ID3D11Buffer
	Field _rbuffer:ID3D11Buffer
	Field _sbuffer:ID3D11Buffer
	Field _fbuffer:ID3D11Buffer
	Field _uvbuffer:ID3D11Buffer
	Field _vshader:ID3D11VertexShader

	Field _strides[]
	Field _offsets[]
	Field _buffers:ID3D11Buffer[]
	
	Method Create:TBatchImage(image:TImage,color,rotation,scale,uv,frames)
		If Not _shaderready Return
		
		If Not _BIG _BIG = New TBatchImageGlobals
		
		Local iframe:TD3D11ImageFrame = TD3D11ImageFrame(image.Frame(0))
		If iframe = Null Return
		
		_image = image
		_numframes = image.frames.length
		_sampler = iframe._sampler
		
		Local texDesc:D3D11_TEXTURE2D_DESC = New D3D11_TEXTURE2D_DESC
		iframe._tex2D.GetDesc(texDesc)
		texDesc.ArraySize = _numframes
		texDesc.Usage = D3D11_USAGE_DEFAULT

		If _d3d11dev.CreateTexture2D(texDesc,Null,_tex)<0
			Notify "Error!~nCannot create instancing texture array.~nExiting.",True
			End
		EndIf

		For Local i = 0 Until _numframes
			Local iframe:TD3D11ImageFrame = TD3D11ImageFrame(image.Frame(i))
		
			If Not iframe
				Continue
			Else
				For Local mip = 0 Until texDesc.MipLevels
					Local res=D3D11CalcSubresource(mip,i,texDesc.MipLevels)
					_d3d11devcon.CopySubresourceRegion(_tex,res,0,0,0,iframe._tex2D,mip,Null)
				Next
			EndIf
		Next
		
		If _d3d11dev.CreateShaderResourceView(_tex,Null,_srv)<0
			Notify "Error!~nCannot create instancing shader resource.~nExiting.",True
			End
		EndIf
				
		Local u#=iframe._uscale * image.width
		Local v#=iframe._vscale * image.height
		Local verts#[16]
	
		Local x# = -image.handle_x + _max2DGraphics.origin_x
		Local y# = -image.handle_y + _max2DGraphics.origin_y
		Local x1# = x + image.width
		Local y1# = y + image.height
	
		verts[0] = x
		verts[1] = y
		verts[2] = 0.0
		verts[3] = 0.0
	
		verts[4] = x1
		verts[5] = y
		verts[6] = u
		verts[7] = 0.0
	
		verts[8] = x
		verts[9] = y1
		verts[10] = 0.0
		verts[11] = v
	
		verts[12] = x1
		verts[13] = y1
		verts[14] = u
		verts[15] = v

		CreateBuffer(_vbuffer,SizeOf(verts),D3D11_USAGE_IMMUTABLE,D3D11_BIND_VERTEX_BUFFER,0,verts,"Instance Vertex Data")

		_ilength = -1
		_shaderindex = color Shl 4 + rotation Shl 3 + scale Shl 2 + uv Shl 1 + frames
		
		If Not _BIG._vshader[_shaderindex]
			Local hr
			Local vscode:ID3DBlob
			Local pErrorMsg:ID3DBlob
			Local Defines[10]
			
			Local index
			If color
				Defines[index] = Int("COLOR".ToCString())
				Defines[index+1] = Int("1".ToCstring())
				index:+2
			EndIf
			If rotation
				Defines[index] = Int("ROTATION".ToCString())
				Defines[index+1] = Int("1".ToCstring())
				index:+2
			EndIf
			If scale
				Defines[index] = Int("SCALE".ToCString())
				Defines[index+1] = Int("1".ToCstring())
				index:+2
			EndIf
			If uv
				Defines[index] = Int("UV".ToCString())
				Defines[index+1] = Int("1".ToCString())
				index:+2
			EndIf
			Defines[index] = 0
			Defines[index+1] = 0

			hr = D3DCompile(_BIG._vs,_BIG._vs.length,Null,Defines,Null,"InstanceVertexShader","vs_4_0",..
							D3D11_SHADER_OPTIMIZATION_LEVEL3,0,vscode,pErrorMsg)
			If pErrorMsg
				Local _ptr:Byte Ptr = pErrorMsg.GetBufferPointer()
				WriteStdout String.fromCString(_ptr)
				SAFE_RELEASE(pErrorMsg)
			EndIf
		
			If hr<0
				WriteStdout "Cannot compile instance vertex shader source code~n"
				End
			EndIf

			If _d3d11dev.CreateVertexShader(vscode.GetBufferPointer(),vscode.GetBufferSize(),Null,_BIG._vshader[_shaderindex])<0
				WriteStdout "Cannot create instance vertex shader id:"+_shaderindex+" - compiled ok~n"
				End
			EndIf
			
			For Local i=0 Until index - 2
				MemFree Byte Ptr(Defines[i])
			Next

			If Not _BIG._layout
				Local bLayout[] = [0,0,DXGI_FORMAT_R32G32B32A32_FLOAT,0,D3D11_APPEND_ALIGNED_ELEMENT,D3D11_INPUT_PER_VERTEX_DATA,0,..
						0,0,DXGI_FORMAT_R32G32B32A32_FLOAT,1,D3D11_APPEND_ALIGNED_ELEMENT,D3D11_INPUT_PER_INSTANCE_DATA,1,..
						0,1,DXGI_FORMAT_R32G32B32A32_FLOAT,2,D3D11_APPEND_ALIGNED_ELEMENT,D3D11_INPUT_PER_INSTANCE_DATA,1,..
						0,2,DXGI_FORMAT_R32G32B32A32_FLOAT,2,D3D11_APPEND_ALIGNED_ELEMENT,D3D11_INPUT_PER_INSTANCE_DATA,1,..
						0,3,DXGI_FORMAT_R32G32_FLOAT,3,D3D11_APPEND_ALIGNED_ELEMENT,D3D11_INPUT_PER_INSTANCE_DATA,1,..
						0,4,DXGI_FORMAT_R32G32_FLOAT,4,D3D11_APPEND_ALIGNED_ELEMENT,D3D11_INPUT_PER_INSTANCE_DATA,1,..
						0,5,DXGI_FORMAT_R32_FLOAT,5,D3D11_APPEND_ALIGNED_ELEMENT,D3D11_INPUT_PER_INSTANCE_DATA,1,..
						0,6,DXGI_FORMAT_R32_UINT,6,D3D11_APPEND_ALIGNED_ELEMENT,D3D11_INPUT_PER_INSTANCE_DATA,1]

				bLayout[0] = Int("POSITION".ToCString())
				bLayout[7] = Int("TEXCOORD".ToCString())
				bLayout[14] = Int("TEXCOORD".ToCString())
				bLayout[21] = Int("TEXCOORD".ToCString())
				bLayout[28] = Int("TEXCOORD".ToCString())
				bLayout[35] = Int("TEXCOORD".ToCString())
				bLayout[42] = Int("TEXCOORD".ToCString())
				bLayout[49] = Int("TEXCOORD".ToCString())

				If _d3d11dev.CreateInputLayout(bLayout,8,vscode.GetBufferPointer(),vscode.GetBufferSize(),_BIG._layout)<0
					Notify "Error!~nCannot create InputLayout for TBatchImage~nExiting."
					End
				EndIf
				
				MemFree Byte Ptr(Int(bLayout[0]))
				MemFree Byte Ptr(Int(bLayout[7]))
				MemFree Byte Ptr(Int(bLayout[14]))
				MemFree Byte Ptr(Int(bLayout[21]))
				MemFree Byte Ptr(Int(bLayout[28]))
				MemFree Byte Ptr(Int(bLayout[35]))
				MemFree Byte Ptr(Int(bLayout[42]))
				MemFree Byte Ptr(Int(bLayout[49]))
			EndIf
		EndIf
		
		If Not _BIG._pshader
			'create batching pixel shader
			Local hr
			Local pscode:ID3DBlob
			Local pErrorMsg:ID3DBlob

			hr = D3DCompile(_BIG._ps,_BIG._ps.length,Null,Null,Null,"InstancePixelShader","ps_4_0",..
								D3D11_SHADER_OPTIMIZATION_LEVEL3,0,pscode,pErrorMsg)
									
			If pErrorMsg
				Local _ptr:Byte Ptr = pErrorMsg.GetBufferPointer()
				WriteStdout String.fromCString(_ptr)
			
				SAFE_RELEASE(pErrorMsg)
			EndIf
			If hr<0
				Notify "Cannot compile pixel shader source code for coloring!~nShutting down."
				End
			EndIf

			If _d3d11dev.CreatePixelShader(pscode.GetBufferPointer(),pscode.GetBufferSize(),Null,_BIG._pshader)<0
				Notify "Cannot create pixel shader for coloring - compiled ok~n",True
				End
			EndIf
		EndIf
	
		_vshader = _BIG._vshader[_shaderindex]
		_isvalid = True
		Return Self
	EndMethod
	
	Method Update(position#[] Var,color#[] Var,rotation#[] Var,scale#[] Var,uv#[] Var,frames[] Var)
		Local shaderindex = (color <> Null) Shl 4 + (rotation <> Null) Shl 3 + (scale<>Null) Shl 2 + (uv<>Null) Shl 1 + (frames<>Null)
		If shaderindex <> _shaderindex Return

		If Not position Return
		If position.length<2 Or (position.length&1) Return
		
		If _ilength<1
			_ilength = position.length
		EndIf
		If _ilength <> position.length Return
		
		If _dbuffer
			MapBuffer(_dbuffer,0,D3D11_MAP_WRITE_DISCARD,0,position,SizeOf(position),"Instance Position Data")
		Else
			CreateBuffer(_dbuffer,SizeOf(position),D3D11_USAGE_DYNAMIC,D3D11_BIND_VERTEX_BUFFER,D3D11_CPU_ACCESS_WRITE,position,"Instance Position Array")
		EndIf

		If color
			If color.length <> _ilength*2 Return
			If _cbuffer
				MapBuffer(_cbuffer,0,D3D11_MAP_WRITE_DISCARD,0,color,SizeOf(color),"Instance Color Data")
			Else
				CreateBuffer(_cbuffer,SizeOf(color),D3D11_USAGE_DYNAMIC,D3D11_BIND_VERTEX_BUFFER,D3D11_CPU_ACCESS_WRITE,color,"Instance Colour Array")
			EndIf
		Else
			If Not _cbuffer CreateBuffer(_cbuffer,_ilength*2,D3D11_USAGE_DEFAULT,D3D11_BIND_VERTEX_BUFFER,0,Null,"Empty Instance Color")
		EndIf
		
		If rotation
			If rotation.length <> _ilength*0.5 Return
			If _rbuffer
				MapBuffer(_rbuffer,0,D3D11_MAP_WRITE_DISCARD,0,rotation,SizeOf(rotation),"Instance Rotation Data")
			Else
				CreateBuffer(_rbuffer,SizeOf(rotation),D3D11_USAGE_DYNAMIC,D3D11_BIND_VERTEX_BUFFER,D3D11_CPU_ACCESS_WRITE,rotation,"Instance Rotation Array")
			EndIf
		Else
			If Not _rbuffer CreateBuffer(_rbuffer,_ilength*0.5,D3D11_USAGE_DEFAULT,D3D11_BIND_VERTEX_BUFFER,0,Null,"Empty Instance Rotation")
		EndIf

		If scale
			If scale.length <> _ilength Return
			If _sbuffer
				MapBuffer(_sbuffer,0,D3D11_MAP_WRITE_DISCARD,0,scale,SizeOf(scale),"Instance Scale Data")
			Else
				CreateBuffer(_sbuffer,SizeOf(scale),D3D11_USAGE_DYNAMIC,D3D11_BIND_VERTEX_BUFFER,D3D11_CPU_ACCESS_WRITE,scale,"Instance Scaling Array")
			EndIf
		Else
			If Not _sbuffer CreateBuffer(_sbuffer,_ilength,D3D11_USAGE_DEFAULT,D3D11_BIND_VERTEX_BUFFER,0,Null,"Empty Instance Scale")
		EndIf
		
		If uv
			If uv.length <> _ilength*4 Return
			If _uvbuffer
				MapBuffer(_uvbuffer,0,D3D11_MAP_WRITE_DISCARD,0,uv,SizeOf(uv),"Instance UV Data")
			Else
				CreateBuffer(_uvbuffer,SizeOf(uv),D3D11_USAGE_DYNAMIC,D3D11_BIND_VERTEX_BUFFER,D3D11_CPU_ACCESS_WRITE,uv,"Instance UV Array")
			EndIf
		Else
			If Not _uvbuffer CreateBuffer(_uvbuffer,_ilength*4,D3D11_USAGE_DEFAULT,D3D11_BIND_VERTEX_BUFFER,0,Null,"Empty Instance UV")
		EndIf

		If frames
			If frames.length <> _ilength*0.5 Return
			If _fbuffer
				MapBuffer(_fbuffer,0,D3D11_MAP_WRITE_DISCARD,0,frames,SizeOf(frames),"Instance Frame Data")
			Else
				CreateBuffer(_fbuffer,SizeOf(frames),D3D11_USAGE_DYNAMIC,D3D11_BIND_VERTEX_BUFFER,D3D11_CPU_ACCESS_WRITE,frames,"Instance Frames Array")
			EndIf
		Else
			If Not _fbuffer CreateBuffer(_fbuffer,_ilength*0.5,D3D11_USAGE_DEFAULT,D3D11_BIND_VERTEX_BUFFER,0,Null,"Empty Instance Frames")
		EndIf
				
		_strides = [16,16,32,8,8,4,4]
		_offsets = [0,0,0,0,0,0,0]
		_buffers = [_vbuffer,_cbuffer,_uvbuffer,_dbuffer,_sbuffer,_rbuffer,_fbuffer]
		
		_readytodraw = True
	EndMethod

	Method Draw(frame)
		If Not _readytodraw Return
		If Not _shaderready Return
		
		If frame > _numframes-1 Return
		
		If frame >= 0
			Local iframe:TD3D11ImageFrame = TD3D11ImageFrame(_image.Frame(frame))
			_d3d11devcon.PSSetShaderResources(0,1,Varptr iframe._srv)
		Else
			_d3d11devcon.PSSetShaderResources(0,1,Varptr _srv)
		EndIf

		If _currentsampler <> _sampler
			_d3d11devcon.PSSetSamplers(0,1,Varptr _sampler)
			_currentsampler = _sampler
		EndIf
		
		_d3d11devcon.IASetVertexBuffers(0,7,_buffers,_strides,_offsets)
		_d3d11devcon.IASetInputLayout(_BIG._layout)
		_d3d11devcon.VSSetShader(_vshader,Null,0)
		_d3d11devcon.PSSetShader(_BIG._pshader,Null,0)
		_d3d11devcon.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP)
		_d3d11devcon.DrawInstanced(4,_ilength*0.5,0,0)
	EndMethod
	
	Method Destroy()
		SAFE_RELEASE(_tex)
		SAFE_RELEASE(_srv)
		SAFE_RELEASE(_vbuffer)
		SAFE_RELEASE(_dbuffer)
		SAFE_RELEASE(_cbuffer)
		SAFE_RELEASE(_rbuffer)
		SAFE_RELEASE(_sbuffer)
		SAFE_RELEASE(_fbuffer)
		SAFE_RELEASE(_uvbuffer)
	EndMethod
EndType

Function CreateBatchImage:TBatchImage(image:TImage Var,color=False,rotation=False,scale=False,uv=False,frames=False)
	If Not VerifyD3D11Max2DDriver() Return

	If Not image Return
	
	Return New TBatchImage.Create(image,color,rotation,scale,uv,frames)
EndFunction

Function UpdateBatchImage(bimage:TBatchImage,position#[]=Null,color#[]=Null,rotation#[]=Null,scale#[]=Null,uv#[]=Null,frames[]=Null)
	If Not bimage Return
	If Not bimage._isvalid Return

	bimage.Update(position,color,rotation,scale,uv,frames)
EndFunction

Function DrawBatchImage(bimage:TBatchImage Var,frame=-1)
	If Not bimage Return
	If Not bimage._isvalid Return
	
	bimage.Draw(frame)
EndFunction

Function DestroyBatchImage(bimage:TBatchImage Var)
	If Not bimage Return
	If Not bimage._isvalid Return
	
	bimage.Destroy
	bimage = Null
EndFunction

Function FreeBatchResources()
	If _BIG	_BIG.FreeResources()
	_BIG = Null
EndFunction