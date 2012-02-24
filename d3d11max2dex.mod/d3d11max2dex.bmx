
Strict

Module GFX.D3D11Max2DEx
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"
ModuleInfo "Credit: Code derived from SRS.D3D11Max2D"

Import GFX.Max2DEx
Import GFX.D3D11Max2D

Incbin "batch.vs"
Incbin "batch.ps"

?Win32

Private

Function SAFE_RELEASE(interface:IUnknown Var)
	If interface interface.Release_
	interface = Null
EndFunction

Global _d3d11dev:ID3D11Device
Global _d3d11devcon:ID3D11DeviceContext

Public

Rem
Type TD3D11BatchImage Extends TBatchImage
	Global _gvshader:ID3D11VertexShader[32]
	Global _gpshader:ID3D11PixelShader
	Global _glayout:ID3D11InputLayout

	Global _vs$ = LoadText("incbin::batch.vs")
	Global _ps$ = LoadText("incbin::batch.ps")
	
	Global _shaderready
	
	Function FreeResources()
		For Local i = 0 Until 32
			SAFE_RELEASE(_gvshader[i])
		Next
		SAFE_RELEASE(_gpshader)
		SAFE_RELEASE(_glayout)
	End Function

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
				
		Local iframe:TD3D11ImageFrame = TD3D11ImageFrame(image.Frame(0))
		If iframe = Null Return
		
		_image = image
		_numframes = image.frames.length
		_sampler = iframe._sampler
		
		Local texDesc:D3D11_TEXTURE2D_DESC = New D3D11_TEXTURE2D_DESC
		iframe._tex2D.GetDesc(texDesc)
		texDesc.ArraySize = _numframes
		texDesc.Usage = D3D11_USAGE_DEFAULT

		If _d3d11dev.CreateTexture2D(texDesc,Null,_tex)<0 Throw "Cannot create instancing texture array."

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
		
		If Not _gvshader[_shaderindex]
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

			hr = D3DCompile(_vs,_vs.length,Null,Defines,Null,"InstanceVertexShader","vs_4_0",..
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

			If _d3d11dev.CreateVertexShader(vscode.GetBufferPointer(),vscode.GetBufferSize(),Null,_gvshader[_shaderindex])<0
				WriteStdout "Cannot create instance vertex shader id:"+_shaderindex+" - compiled ok~n"
				End
			EndIf
			
			For Local i=0 Until index - 2
				MemFree Byte Ptr(Defines[i])
			Next

			If Not _glayout
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

				If _d3d11dev.CreateInputLayout(bLayout,8,vscode.GetBufferPointer(),vscode.GetBufferSize(),_glayout)<0
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
		
		If Not _gpshader
			'create batching pixel shader
			Local hr
			Local pscode:ID3DBlob
			Local pErrorMsg:ID3DBlob

			hr = D3DCompile(_gps,_gps.length,Null,Null,Null,"InstancePixelShader","ps_4_0",..
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

			If _d3d11dev.CreatePixelShader(pscode.GetBufferPointer(),pscode.GetBufferSize(),Null,_gpshader)<0
				Notify "Cannot create pixel shader for coloring - compiled ok~n",True
				End
			EndIf
		EndIf
	
		_vshader = _gvshader[_shaderindex]
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
		_d3d11devcon.IASetInputLayout(_glayout)
		_d3d11devcon.VSSetShader(_vshader,Null,0)
		_d3d11devcon.PSSetShader(_gpshader,Null,0)
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
End Type
End Rem

Type TD3D11Buffer Extends TBuffer
	Field _rtv:ID3D11RenderTargetView
End Type

Type THLSL11Driver Extends TShaderDriver
	Method Compile:TShaderCode(code:TShaderCode)
	End Method
	Method Apply(res:Object, data:Object)
	End Method
	Method Name$()
	End Method
End Type

Type TD3D11Max2DExDriver Extends TMax2DExDriver
	Field _t:TMax2DGraphics
	
	Method SetGraphics(g:TGraphics)
		_t = TMax2DGraphics(g)
		If _t
			Local dg:TD3D11Graphics = TD3D11Graphics(_t._graphics)
			If dg
				_d3d11dev = dg.GetDirect3DDevice()
				_d3d11devcon = dg.GetDirect3DDeviceContext()
			EndIf
		EndIf

		Return Super.SetGraphics(g)
	End Method
	
	Method CreateBatchImage:TBatchImage(image:TImage,color=False,rotation=False,scale=False,uv=False,frames=False)
    'Return New TD3D11BatchImage.Create(image,color,rotation,scale,uv,frames)
	End Method

	Method PlotPoints(points#[])
		If points.length<2 Or (points.length&1) Return
	
		Local buildbuffer = False
		Local ox#=_t.origin_x
		Local oy#=_t.origin_y
	
		If TD3D11Max2DDriver._pointarray.length <> points.length*2
			'BUG FIX - Causes intermittent EAV if removed!
			'Only when array size is changed every frame
			TD3D11Max2DDriver._pointarray = Null
			GCCollect()
		
			TD3D11Max2DDriver._pointarray = TD3D11Max2DDriver._pointarray[..points.length*2]
			buildbuffer = True
		EndIf

		Local i
		Repeat
			TD3D11Max2DDriver._pointarray[i*4+0] = points[i*2+0] + ox
			TD3D11Max2DDriver._pointarray[i*4+1] = points[i*2+1] + oy

			i:+1
		Until i = points.length*0.5

		If Not buildbuffer
			TD3D11Max2DDriver.MapBuffer(TD3D11Max2DDriver._pointBuffer,0,D3D11_MAP_WRITE_DISCARD,0,TD3D11Max2DDriver._pointarray,SizeOf(TD3D11Max2DDriver._pointarray))
		Else
			SAFE_RELEASE(TD3D11Max2DDriver._pointBuffer)
			TD3D11Max2DDriver.CreateBuffer(TD3D11Max2DDriver._pointbuffer,SizeOf(TD3D11Max2DDriver._pointarray),D3D11_USAGE_DYNAMIC,D3D11_BIND_VERTEX_BUFFER,D3D11_CPU_ACCESS_WRITE,TD3D11Max2DDriver._pointarray,"Point Array")
		EndIf		

		Local stride=16
		Local offset=0
	
		_d3d11devcon.VSSetShader(TD3D11Max2DDriver._vertexshader,Null,0)
		_d3d11devcon.PSSetShader(TD3D11Max2DDriver._colorpixelshader,Null,0)
		_d3d11devcon.PSSetConstantBuffers(0,1,Varptr TD3D11Max2DDriver._psfbuffer)
		_d3d11devcon.IASetInputLayout(TD3D11Max2DDriver._max2dlayout)
		_d3d11devcon.IASetVertexBuffers(0,1,Varptr TD3D11Max2DDriver._pointBuffer,Varptr stride,Varptr offset)
		_d3d11devcon.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_POINTLIST)
		_d3d11devcon.Draw(points.length*0.5,0)
	End Method

	Method DrawLines(lines#[], linked)
		If lines.length<4 Or (lines.length&1) Return
	  If linked And (lines.length Mod 4) Return
	
	  Local buildbuffer = False
	
	  Local handlex#=_t.handle_x
	  Local handley#=_t.handle_y
	  Local ox#=_t.origin_x
	  Local oy#=_t.origin_y

	  If TD3D11Max2DDriver._linearray.length <> lines.length*2
		  'BUG FIX - Causes intermittent EAV if removed!
		  'Only when array size is changed every frame
		  TD3D11Max2DDriver._linearray = Null
		  GCCollect()

		  TD3D11Max2DDriver._linearray = TD3D11Max2DDriver._linearray[..lines.length*2]
		  buildbuffer = True
	  EndIf
	
	  Local index = 0	
	  For Local i = 0 Until lines.length Step 2
		  TD3D11Max2DDriver._linearray[index] = (handlex+lines[i])*TD3D11Max2DDriver._ix + (handley+lines[i+1])*TD3D11Max2DDriver._iy + ox
		  TD3D11Max2DDriver._linearray[index+1] = (handlex+lines[i])*TD3D11Max2DDriver._jx + (handley+lines[i+1])*TD3D11Max2DDriver._jy + oy
		  index:+4
	  Next

	  Local stride = 16
	  Local offset = 0
	
	  If Not buildbuffer
		  TD3D11Max2DDriver.MapBuffer(TD3D11Max2DDriver._linebuffer,0,D3D11_MAP_WRITE_DISCARD,0,TD3D11Max2DDriver._linearray,SizeOf(TD3D11Max2DDriver._linearray))
	  Else
		  SAFE_RELEASE(TD3D11Max2DDriver._linebuffer)
		  TD3D11Max2DDriver.CreateBuffer(TD3D11Max2DDriver._linebuffer,SizeOf(TD3D11Max2DDriver._linearray),D3D11_USAGE_DYNAMIC,D3D11_BIND_VERTEX_BUFFER,D3D11_CPU_ACCESS_WRITE,TD3D11Max2DDriver._linearray,"Line Array")
	  EndIf
	
	  _d3d11devcon.VSSetShader(TD3D11Max2DDriver._vertexshader,Null,0)
	  _d3d11devcon.PSSetShader(TD3D11Max2DDriver._colorpixelshader,Null,0)
	  _d3d11devcon.PSSetConstantBuffers(0,1,Varptr TD3D11Max2DDriver._psfbuffer)
	  _d3d11devcon.IASetInputLayout(TD3D11Max2DDriver._max2dlayout)
	  'LINESTRIP(=3) or LINELIST(=2)
	  _d3d11devcon.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_LINESTRIP-(linked=True))
	  _d3d11devcon.IASetVertexBuffers(0,1,Varptr TD3D11Max2DDriver._linebuffer,Varptr stride,Varptr offset)
	  _d3d11devcon.Draw(lines.length*0.5,0)
	End Method
	
	Method DrawImageTiled(image:TImage,x#=0,y#=0,frame=0)
		Local iframe:TD3D11ImageFrame=TD3D11ImageFrame(image.Frame(frame))

		Local iw=image.width
		Local ih=image.height
		Local ox=_t.viewport_x-iw+1
		Local oy=_t.viewport_y-ih+1
		Local tx#=Floor(x+_t.origin_x-image.handle_x)-ox
		Local ty#=Floor(y+_t.origin_y-image.handle_y)-oy

		If tx>=0 tx=tx Mod iw + ox Else tx=iw - -tx Mod iw + ox
		If ty>=0 ty=ty Mod ih + oy Else ty=ih - -ty Mod ih + oy

		Local vw=_t.viewport_x+_t.viewport_w
		Local vh=_t.viewport_y+_t.viewport_h

		Local width# = vw - tx
		Local height# = vh - ty

		Local nx = Ceil((vw - tx) / iw)
		Local ny = Ceil((vh - ty) / ih)

		Local numtiles = nx*ny

		Local buildbuffer = False
	
		If TD3D11Max2DDriver._tilearray.length <> 24*numtiles
			'BUG FIX - Causes intermittent EAV if removed!
			'Only when array size is changed every frame
			TD3D11Max2DDriver._tilearray = Null
			GCCollect()
		
			TD3D11Max2DDriver._tilearray = TD3D11Max2DDriver._tilearray[..24*numtiles]
			buildbuffer = True
		EndIf
	
		Local ii,jj
		Local index
		Local ar#[]=TD3D11Max2DDriver._tilearray
		Local u#=iframe._uscale * iw
		Local v#=iframe._vscale * ih
	
		For Local ay = 0 Until ny
			For Local ax = 0 Until nx
				TD3D11Max2DDriver._tilearray[index + 0] = tx + ii
				TD3D11Max2DDriver._tilearray[index + 1] = ty + jj
				TD3D11Max2DDriver._tilearray[index + 2] = 0.0
				TD3D11Max2DDriver._tilearray[index + 3] = 0.0

				TD3D11Max2DDriver._tilearray[index + 4] = tx + iw + ii
				TD3D11Max2DDriver._tilearray[index + 5] = ty + jj
				TD3D11Max2DDriver._tilearray[index + 6] = u
				TD3D11Max2DDriver._tilearray[index + 7] = 0.0

				TD3D11Max2DDriver._tilearray[index + 8] = tx + ii
				TD3D11Max2DDriver._tilearray[index + 9] = ty + ih + jj
				TD3D11Max2DDriver._tilearray[index + 10] = 0.0
				TD3D11Max2DDriver._tilearray[index + 11] = v
			
				TD3D11Max2DDriver._tilearray[index + 12] = tx + ii
				TD3D11Max2DDriver._tilearray[index + 13] = ty + ih + jj
				TD3D11Max2DDriver._tilearray[index + 14] = 0.0
				TD3D11Max2DDriver._tilearray[index + 15] = v
			
				TD3D11Max2DDriver._tilearray[index + 16] = tx + iw + ii
				TD3D11Max2DDriver._tilearray[index + 17] = ty + jj
				TD3D11Max2DDriver._tilearray[index + 18] = u
				TD3D11Max2DDriver._tilearray[index + 19] = 0.0

				TD3D11Max2DDriver._tilearray[index + 20] = tx + iw + ii
				TD3D11Max2DDriver._tilearray[index + 21] = ty + ih + jj
				TD3D11Max2DDriver._tilearray[index + 22] = u
				TD3D11Max2DDriver._tilearray[index + 23] = v

				ii:+image.width

				index :+ 24
			Next
			ii = 0
			jj:+image.height
		Next

		If Not buildbuffer
			TD3D11Max2DDriver.MapBuffer(TD3D11Max2DDriver._tilebuffer,0,D3D11_MAP_WRITE_DISCARD,0,TD3D11Max2DDriver._tilearray,SizeOf(TD3D11Max2DDriver._tilearray))
		Else
			SAFE_RELEASE(TD3D11Max2DDriver._tilebuffer)
			TD3D11Max2DDriver.CreateBuffer(TD3D11Max2DDriver._tilebuffer,SizeOf(TD3D11Max2DDriver._tilearray),D3D11_USAGE_DYNAMIC,D3D11_BIND_VERTEX_BUFFER,D3D11_CPU_ACCESS_WRITE,TD3D11Max2DDriver._tilearray,"Tile Array")
		EndIf

		Local stride = 16
		Local offset = 0
		TD3D11Max2DDriver._currentsrv = iframe._srv
	
		_d3d11devcon.VSSetShader(TD3D11Max2DDriver._vertexshader,Null,0)
		_d3d11devcon.PSSetShader(TD3D11Max2DDriver._texturepixelshader,Null,0)
		_d3d11devcon.PSSetConstantBuffers(0,1,Varptr TD3D11Max2DDriver._psfbuffer)
		_d3d11devcon.IASetInputLayout(TD3D11Max2DDriver._max2dlayout)
		_d3d11devcon.PSSetShaderResources(0,1,Varptr iframe._srv)
		_d3d11devcon.IASetVertexBuffers(0,1,Varptr TD3D11Max2DDriver._tilebuffer,Varptr stride,Varptr offset)
		_d3d11devcon.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST)

		_d3d11devcon.Draw(6*numtiles,0)
	End Method
	
	Method MakeBuffer:TBuffer(src:Object,width,height,flags)
		Local frame:TBufferedImageFrame=TBufferedImageFrame(src)
		If Not frame Return Null
		If frame._buffer Return frame._buffer
		
		Local buffer:TD3D11Buffer=New TD3D11Buffer
		buffer._rtv = TD3D11ImageFrame(frame._parent)._rtv
		frame._buffer = buffer
		Return frame._buffer		
	End Method
	
	Method SetBuffer(buffer:TBuffer)
		_currentbuffer=buffer		
		Local rtv:ID3D11RenderTargetView
		If _currentbuffer <> _backbuffer
		  rtv = TD3D11Buffer(_currentbuffer)._rtv
		Else
		  rtv = TD3D11Graphics(_t._graphics).GetRenderTarget()
		EndIf
		_d3d11devcon.OMSetRenderTargets(1,Varptr rtv,Null)
	End Method	
End Type

Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function D3D11Max2DExDriver:TD3D11Max2DExDriver()
	If D3D11Max2DDriver()
		Global driver:TD3D11Max2DExDriver=New TD3D11Max2DExDriver
		driver._parent = D3D11Max2DDriver()
		Return driver
	End If
End Function

Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function HLSL11ShaderDriver:THLSL11Driver()
	Global _driver:THLSL11Driver=New THLSL11Driver
	Return _driver
End Function

Local driver:TD3D11Max2DExDriver=D3D11Max2DExDriver()
If driver 
	SetGraphicsDriver driver
	SetShaderDriver HLSL11ShaderDriver()
EndIf
