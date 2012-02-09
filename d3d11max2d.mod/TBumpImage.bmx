Private

Type TBumpImageGlobals
	Field _vshader:ID3D11VertexShader
	Field _pshader:ID3D11PixelShader
	Field _layout:ID3D11InputLayout
	Field _shaderready

	Field _vs$ = LoadText("incbin::bump.vs")
	Field _ps$ = LoadText("incbin::bump.ps")

EndType
	
Incbin "bump.vs"
Incbin "bump.ps"

Global _BumpIG:TBumpImageGlobals

Public

Type TBumpImage
	Field DImage:TImage
	Field NImage:TImage
	Field DFrame:TD3D11ImageFrame
	Field NFrame:TD3D11ImageFrame
	Field DResView:ID3D11ShaderResourceView
	Field NResView:ID3D11ShaderResourceView
	
	Field bumparray#[8]
	Field bumpbuffer:ID3D11Buffer
	Field vbuffer:ID3D11Buffer

	Method Create:TBumpImage(DiffuseImage:TImage,NormalImage:TImage)
		If Not _shaderready Return Null

		If Not _BumpIG _BumpIG = New TBumpImageGlobals
		
		DFrame = TD3D11ImageFrame(DiffuseImage.Frame(0))
		NFrame = TD3D11ImageFrame(NormalImage.Frame(0))
		
		If (Not dframe) Or (Not nframe) Return Null
		
		DImage = DiffuseImage
		NImage = NormalImage
		
		DResView = DFrame._srv
		NResView = NFrame._srv
		
		If Not _BumpIG._shaderready
			Local hr
			Local vscode:ID3DBlob
			Local pscode:ID3DBlob
			Local errorMsg:ID3DBlob
		
			hr = D3DCompile(_BumpIG._vs,_BumpIG._vs.length,Null,Null,Null,"BumpVertexShader","vs_4_0",..
							D3D11_SHADER_OPTIMIZATION_LEVEL3,0,vscode,errorMsg)
			If errorMsg
				Local _ptr:Byte Ptr = errorMsg.GetBufferPointer()
				WriteStdout String.fromCString(_ptr)
				SAFE_RELEASE(errorMsg)
			EndIf
	
			If hr<0
				Notify "Cannot compile bump vertex shader source code~nExiting.",True
				End
			EndIf

			If _d3d11dev.CreateVertexShader(vscode.GetBufferPointer(),vscode.GetBufferSize(),Null,_BumpIG._vshader)<0
				Notify "Cannot create bump vertex shader - compiled ok~nExiting.",True
				End
			EndIf
	
			hr = D3DCompile(_BumpIG._ps,_BumpIG._ps.length,Null,Null,Null,"BumpPixelShader","ps_4_0",..
							D3D11_SHADER_OPTIMIZATION_LEVEL3,0,pscode,errorMsg)
			If errorMsg
				Local _ptr:Byte Ptr = errorMsg.GetBufferPointer()
				WriteStdout String.fromCString(_ptr)
				SAFE_RELEASE(errorMsg)
			EndIf

			If hr<0
				Notify "Cannot compile bump pixel shader source code~nExiting.",True
				End
			EndIf

			If _d3d11dev.CreatePixelShader(pscode.GetBufferPointer(),pscode.GetBufferSize(),Null,_BumpIG._pshader)<0
				Notify "Cannot create bump pixel shader - compiled ok~nExiting.",True
				End
			EndIf
		
			Local bumpLayout[] = [0,0,DXGI_FORMAT_R32G32_FLOAT,0,D3D11_APPEND_ALIGNED_ELEMENT,D3D11_INPUT_PER_VERTEX_DATA,0,..
								0,0,DXGI_FORMAT_R32G32_FLOAT,0,D3D11_APPEND_ALIGNED_ELEMENT,D3D11_INPUT_PER_VERTEX_DATA,0]
									
			bumpLayout[0] = Int("POSITION".ToCString())
			bumpLayout[7] = Int("TEXCOORD".ToCString())
			
			If _d3d11dev.CreateInputLayout(bumpLayout,2,vscode.GetBufferPointer(),vscode.GetBufferSize(),_BumpIG._layout)<0
				Notify "Error!~nCannot create InputLayout for TBatchImage~nExiting."
				End
			EndIf
				
			MemFree Byte Ptr(Int(bumpLayout[0]))
			MemFree Byte Ptr(Int(bumpLayout[7]))
		
			SAFE_RELEASE(vscode)
			SAFE_RELEASE(pscode)
			SAFE_RELEASE(errorMsg)
		EndIf
		
		Local u#=dframe._uscale * dimage.width
		Local v#=dframe._vscale * dimage.height
		Local verts#[16]
	
		Local x# = -dimage.handle_x + _max2DGraphics.origin_x
		Local y# = -dimage.handle_y + _max2DGraphics.origin_y
		Local x1# = x + dimage.width
		Local y1# = y + dimage.height
	
		verts[0] = x
		verts[1] = y
		verts[2] = 0.0
		verts[3] = 0.0
	
		verts[4] = x1
		verts[5] = y
		verts[6] = 1.0
		verts[7] = 0.0
	
		verts[8] = x
		verts[9] = y1
		verts[10] = 0.0
		verts[11] = 1.0
	
		verts[12] = x1
		verts[13] = y1
		verts[14] = 1.0
		verts[15] = 1.0

		CreateBuffer(vbuffer,SizeOf(verts),D3D11_USAGE_IMMUTABLE,D3D11_BIND_VERTEX_BUFFER,0,verts,"Bumpmap Vertex Data")
		CreateBuffer(bumpbuffer,SizeOf(bumpArray),D3D11_USAGE_DYNAMIC,D3D11_BIND_CONSTANT_BUFFER,D3D11_CPU_ACCESS_WRITE,Null,"Bumpmap Array")

		_BumpIG._shaderready = True
		Return Self
	EndMethod

	Method Draw(x#,y#,z#)
		If Not _BumpIG._shaderready Return
		
		bumparray[0] = 1.0
		bumparray[1] = 1.0
		bumparray[2] = 1.0
		bumparray[3] = 1.0
		bumparray[4] = x
		bumparray[5] = y
		bumparray[6] = z

		MapBuffer(bumpbuffer,0,D3D11_MAP_WRITE_DISCARD,0,bumparray,SizeOf(bumparray),"Bumpmap Data")
		
		Local stride = 16
		Local offset = 0
		
		_d3d11devcon.VSSetShader(_BumpIG._vshader,Null,0)
		_d3d11devcon.PSSetShader(_BumpIG._pshader,Null,0)
		_d3d11devcon.PSSetConstantBuffers(0,2,[_psfbuffer,bumpbuffer])
		_d3d11devcon.PSSetShaderResources(0,2,[DResView,NResview])
		
		_d3d11devcon.IASetInputLayout(_BumpIG._layout)
		_d3d11devcon.IASetVertexBuffers(0,1,Varptr vbuffer,Varptr stride,Varptr offset)
		_d3d11devcon.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP)
		_d3d11devcon.Draw(4,0)
	EndMethod
	
	Method Destroy()
	EndMethod 
EndType

Function CreateBumpImage:TBumpImage(DiffuseImage:TImage,NormalImage:TImage)
	If GetGraphicsDriver().ToSTring() <> "DirectX11" Return

	If (Not DiffuseImage) Or (Not NormalImage) Return
	Return New TBumpImage.Create(DiffuseImage,NormalImage)
EndFunction

Function DrawBumpImage(Image:TBumpImage,x#,y#,z#)
	If Not Image Return
	
	Image.Draw(x,y,z)
EndFunction

Function FreeBumpResources()
	SAFE_RELEASE(_BumpIG._vshader)
	SAFE_RELEASE(_BumpIG._pshader)
	SAFE_RELEASE(_BumpIG._layout)
	_BumpIG._shaderready = False
EndFunction