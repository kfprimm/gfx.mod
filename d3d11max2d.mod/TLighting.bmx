Private

Type TLightingGlobals
	Field _vbuffer:ID3D11Buffer
	Field _lbuffer:ID3D11Buffer
	Field _sbuffer:ID3D11Buffer
	
	Field _blendmode:ID3D11BlendState
	
	Field _colorTEX:ID3D11Texture2D
	Field _colorRTV:ID3D11RenderTargetView
	Field _colorSRV:ID3D11ShaderResourceView

	Field _depthTEX:ID3D11Texture2D
	Field _depthRTV:ID3D11RenderTargetView
	Field _depthSRV:ID3D11ShaderResourceView
	
	Field _normalTEX:ID3D11Texture2D
	Field _normalRTV:ID3D11RenderTargetView
	Field _normalSRV:ID3D11ShaderResourceView
	
	Field _shadowTEX:ID3D11Texture2D
	Field _shadowRTV:ID3D11RenderTargetView
	Field _shadowSRV:ID3D11ShaderResourceView
	
	Field _layout:ID3D11InputLayout
	Field _vshader:ID3D11VertexShader
	Field _pshader:ID3D11PixelShader
	Field _cpshader:ID3D11PixelShader
	Field _spshader:ID3D11PixelShader

	Field _vs$ = LoadText("incbin::lighting.vs")
	Field _ps$ = LoadText("incbin::lighting.ps")
		
	Field _width#,_height#
	Field _lightdata#[2048]
	Field _verts#[16]
	Field _ambient#[6]
	
	Field _shaderready
EndType

Incbin "lighting.vs"
Incbin "lighting.ps"

Global _LG:TLightingGlobals
Global _Lighting:TLighting
Global _LightIndex
Public

Type TLight
	'Data in the _LG.lightdata is xyz,radius, rgb,intensity
	Field _index
	Field _SwitchedOn

	Field _x#,_y#,_z#,_radius#
	Field _r#,_g#,_b#,_intensity#
	Field _att0#,_att1#,_att2#

	Method Create:TLight()
		_index = _LightIndex

		Self.SetPosition(GraphicsWidth()/2,GraphicsHeight()/2,0.0)
		Self.SetRadius(GraphicsWidth()/4)
		Self.SetColor(255.0,255.0,255.0)
		Self.SetIntensity(100.0)
		Self.SetAttenuation(1.0,0.0,0.0)
				
		_LightIndex :+ 1
		
		Return Self
	EndMethod
	
	Method SetPosition(x#,y#,z#)
		_x = x
		_y = y
		_z = z
		
		If _SwitchedOn
			_LG._lightdata[_index*12 + 0] = x
			_LG._lightdata[_index*12 + 1] = y
			_LG._lightdata[_index*12 + 2] = z
		EndIf
	EndMethod
	
	Method SetRadius(radius#)
		_radius = radius
		
		If _SwitchedOn
			_LG._lightdata[_index*12 + 3] = radius
		EndIf
	EndMethod
		
	Method SetColor(r#,g#,b#)
		Local red = Max(Min(r,255),0)
		Local green = Max(Min(g,255),0)
		Local blue = Max(Min(b,255),0)
		
		_r = red
		_g = green
		_b = blue

		If _SwitchedOn
			_LG._lightdata[_index*12 + 4] = OneOver255 * red
			_LG._lightdata[_index*12 + 5] = OneOver255 * green
			_LG._lightdata[_index*12 + 6] = OneOver255 * blue
		EndIf
	EndMethod
	
	Method SetAttenuation(att0#,att1#,att2#)
		_att0 = att0
		_att1 = att1
		_att2 = att2
		
		If _SwitchedOn
			_LG._lightdata[_index*12 + 8] = att0
			_LG._lightdata[_index*12 + 9] = att1
			_LG._lightdata[_index*12 + 10] = att2
		EndIf
	EndMethod
	
	Method SetIntensity(intensity#)
		_intensity = intensity
		
		If _SwitchedOn
			_LG._lightdata[_index*12 + 7] = intensity
		EndIf
	EndMethod
	
	Method TurnOn()
		_SwitchedOn = True
		
		_LG._lightdata[_index*12 + 0] = _x
		_LG._lightdata[_index*12 + 1] = _y
		_LG._lightdata[_index*12 + 2] = _z
		_LG._lightdata[_index*12 + 3] = _radius
		_LG._lightdata[_index*12 + 4] = OneOver255 * _r
		_LG._lightdata[_index*12 + 5] = OneOver255 * _g
		_LG._lightdata[_index*12 + 6] = OneOver255 * _b
		_LG._lightdata[_index*12 + 7] = _intensity
		_LG._lightdata[_index*12 + 8] = _att0
		_LG._lightdata[_index*12 + 9] = _att1
		_LG._lightdata[_index*12 + 10] = _att2
	EndMethod
	
	Method TurnOff()
		_SwitchedOn = False
		
		_LG._lightdata[_index*12 + 0] = 0
		_LG._lightdata[_index*12 + 1] = 0
		_LG._lightdata[_index*12 + 2] = 0
		_LG._lightdata[_index*12 + 3] = 0
		_LG._lightdata[_index*12 + 4] = 0
		_LG._lightdata[_index*12 + 5] = 0
		_LG._lightdata[_index*12 + 6] = 0
		_LG._lightdata[_index*12 + 7] = 0
	EndMethod
EndType

Type TLitSprite
	Field _colorMap:TImage
	Field _depthMap:TImage
	Field _normalMap:TImage
	
	Field _width#
	Field _height#
	Field _numframes

	Field _sampler:ID3D11SamplerState
	
	Method Create:TLitSprite(colorImage:TImage,depthImage:TImage,normalImage:TImage)		
		Local cframe:TD3D11ImageFrame = TD3D11ImageFrame(colorImage.frame(0))
		Local dframe:TD3D11ImageFrame = TD3D11ImageFrame(depthImage.frame(0))
		Local nframe:TD3D11ImageFrame = TD3D11ImageFrame(normalImage.frame(0))
		
		If Not cframe Return
		If Not dframe Return
		If Not nframe Return
		
		If colorImage.frames.length <> depthImage.frames.length Return
		If colorImage.frames.length <> normalImage.frames.length Return
		
		If colorImage.Width <> depthImage.Width Return
		If colorImage.Height <> depthImage.Height Return
		If colorImage.Width <> normalImage.Width Return
		If colorImage.Height <> normalImage.Height Return
		
		If cframe._sampler <> dframe._sampler Return
		If cframe._sampler <> nframe._sampler Return

		_colorMap = colorImage
		_depthMap = depthImage
		_normalMap = normalImage
		
		_numframes = colorImage.frames.length
		_sampler = cframe._sampler
		
		_width = colorImage.Width
		_height = colorImage.Height
		'TODO MipMaps
		Return Self
	EndMethod
	
	Method Update(x#,y#,frame)
		Local x0#=-_colorMap.handle_x,x1#=x0+_width
		Local y0#=-_colorMap.handle_y,y1#=y0+_height
		Local iframe:TD3D11ImageFrame=TD3D11ImageFrame(_colorMap.Frame(frame))

		Local tx# = x+_max2DGraphics.origin_x
		Local ty# = y+_max2dGraphics.origin_y
		Local sx# = 0
		Local sy# = 0
		Local sw# = _width
		Local sh# = _height
		
		If Not _shaderready Return
		
		Local _uscale# = iframe._uscale
		Local _vscale# = iframe._vscale
	
		Local u0#=sx*_uscale
		Local v0#=sy*_vscale
		Local u1#=(sx+sw)*_uscale
		Local v1#=(sy+sh)*_vscale
		
		Local _verts#[16]
		_verts[0]=x0*_ix+y0*_iy+tx
		_verts[1]=x0*_jx+y0*_jy+ty
		_verts[2]=u0
		_verts[3]=v0

		_verts[4]=x1*_ix+y0*_iy+tx
		_verts[5]=x1*_jx+y0*_jy+ty
		_verts[6]=u1
		_verts[7]=v0

		_verts[8]=x0*_ix+y1*_iy+tx
		_verts[9]=x0*_jx+y1*_jy+ty
		_verts[10]=u0
		_verts[11]=v1
		
		_verts[12]=x1*_ix+y1*_iy+tx
		_verts[13]=x1*_jx+y1*_jy+ty
		_verts[14]=u1
		_verts[15]=v1

		MapBuffer(_vertexbuffer,0,D3D11_MAP_WRITE_DISCARD,0,_verts,SizeOf(_verts))
	EndMethod
EndType

Type TLighting
	Method Create:TLighting()
		If Not _LG _LG = New TLightingGlobals
		
		_LG._width = GraphicsWidth()
		_LG._height = GraphicsHeight()
		
		Local texDesc:D3D11_TEXTURE2D_DESC = New D3D11_TEXTURE2D_DESC
		texDesc.Width = _LG._width
		texDesc.Height = _LG._height
		texDesc.MipLevels = 1
		texDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM
		texDesc.ArraySize = 1
		texDesc.SampleDesc_Count = 1
		texDesc.SampleDesc_Quality = 0
		texDesc.Usage = D3D11_USAGE_DEFAULT
		texDesc.BindFlags = D3D11_BIND_SHADER_RESOURCE | D3D11_BIND_RENDER_TARGET
		texDesc.CPUAccessFlags = 0
		texDesc.MiscFlags = 0
		
		_d3d11dev.CreateTexture2D(texDesc,Null,_LG._colorTEX)
		_d3d11dev.CreateTexture2D(texDesc,Null,_LG._depthTEX)
		_d3d11dev.CreateTexture2D(texDesc,Null,_LG._normalTEX)
		_d3d11dev.CreateTexture2D(texDesc,Null,_LG._shadowTEX)
		
		_d3d11dev.CreateRenderTargetView(_LG._colorTEX,Null,_LG._colorRTV)
		_d3d11dev.CreateRenderTargetView(_LG._depthTEX,Null,_LG._depthRTV)
		_d3d11dev.CreateRenderTargetView(_LG._normalTEX,Null,_LG._normalRTV)
		_d3d11dev.CreateRenderTargetView(_LG._shadowTEX,Null,_LG._shadowRTV)
		
		_d3d11dev.CreateShaderResourceView(_LG._colorTex,Null,_LG._colorSRV)
		_d3d11dev.CreateShaderResourceView(_LG._depthTex,Null,_LG._depthSRV)
		_d3d11dev.CreateShaderResourceView(_LG._normalTex,Null,_LG._normalSRV)
		_d3d11dev.CreateShaderResourceView(_LG._shadowTex,Null,_LG._shadowSRV)
		
		_LG._verts = [	-1.0, 1.0, 0.0,0.0,..
						 1.0, 1.0, 1.0,0.0,..
						-1.0,-1.0, 0.0,1.0,..
						 1.0,-1.0, 1.0,1.0]
						
		_LG._ambient = [0.0,0.0,0.0,0.0,_width,_height,10.0,0.0]
		
		CreateBuffer(_LG._vbuffer,SizeOf(_LG._verts),D3D11_USAGE_IMMUTABLE,D3D11_BIND_VERTEX_BUFFER,0,_LG._verts,"Lighting Vertex Data")
		CreateBuffer(_LG._sbuffer,SizeOf(_LG._ambient),D3D11_USAGE_DYNAMIC,D3D11_BIND_CONSTANT_BUFFER,D3D11_CPU_ACCESS_WRITE,_LG._ambient,"Lighting Screen Data")
		CreateBuffer(_LG._lbuffer,8192,D3D11_USAGE_DYNAMIC,D3D11_BIND_VERTEX_BUFFER,D3D11_CPU_ACCESS_WRITE,Null,"Lighting Light Data")
		'4096 = 128 light x 8 data x 4 bytes

		Local hr
		Local vscode:ID3DBlob
		Local pscode:ID3DBlob
		Local pErrorMsg:ID3DBlob

		hr = D3DCompile(_LG._vs,_LG._vs.length,Null,Null,Null,"LightingVertexShader","vs_4_0",..
							D3D11_SHADER_OPTIMIZATION_LEVEL3,0,vscode,pErrorMsg)
		If pErrorMsg
			Local _ptr:Byte Ptr = pErrorMsg.GetBufferPointer()
			WriteStdout String.fromCString(_ptr)
			SAFE_RELEASE(pErrorMsg)
		EndIf
	
		If hr<0
			WriteStdout "Cannot compile lighting vertex shader source code~n"
			End
		EndIf

		If _d3d11dev.CreateVertexShader(vscode.GetBufferPointer(),vscode.GetBufferSize(),Null,_LG._vshader)<0
			WriteStdout "Cannot create lighting vertex shader - compiled ok~n"
			End
		EndIf
	
		Local shaderbuild = D3D11_SHADER_OPTIMIZATION_LEVEL3
		'Local shaderbuild = D3D11_SHADER_DEBUG|D3D11_SHADER_SKIP_OPTIMIZATION
		hr = D3DCompile(_LG._ps,_LG._ps.length,Null,Null,Null,"LightingPixelShader","ps_4_0",..
							shaderbuild,0,pscode,pErrorMsg)

		If pErrorMsg
			Local _ptr:Byte Ptr = pErrorMsg.GetBufferPointer()
			WriteStdout String.fromCString(_ptr)
			SAFE_RELEASE(pErrorMsg)
		EndIf
		
		If hr<0
			WriteStdout "Cannot compile lighting pixel shader source code~n"
			End
		EndIf

		If _d3d11dev.CreatePixelShader(pscode.GetBufferPointer(),pscode.GetBufferSize(),Null,_LG._pshader)<0
			WriteStdout "Cannot create lighting pixel shader - compiled ok~n"
			End
		EndIf
		
		hr = D3DCompile(_LG._ps,_LG._ps.length,Null,Null,Null,"LightingCombineShader","ps_4_0",..
							D3D11_SHADER_OPTIMIZATION_LEVEL3,0,pscode,pErrorMsg)
		If pErrorMsg
			Local _ptr:Byte Ptr = pErrorMsg.GetBufferPointer()
			WriteStdout String.fromCString(_ptr)
			SAFE_RELEASE(pErrorMsg)
		EndIf
		
		If hr<0
			WriteStdout "Cannot compile lighting combine pixel shader source code~n"
			End
		EndIf

		If _d3d11dev.CreatePixelShader(pscode.GetBufferPointer(),pscode.GetBufferSize(),Null,_LG._cpshader)<0
			WriteStdout "Cannot create lighting combine pixel shader - compiled ok~n"
			End
		EndIf

		'create input layout for the vertex shader
		Local polyLayout[] = [	0,0,DXGI_FORMAT_R32G32B32A32_FLOAT,0,D3D11_APPEND_ALIGNED_ELEMENT,D3D11_INPUT_PER_VERTEX_DATA,0,..
								0,0,DXGI_FORMAT_R32G32B32A32_FLOAT,1,D3D11_APPEND_ALIGNED_ELEMENT,D3D11_INPUT_PER_INSTANCE_DATA,1,..
								0,1,DXGI_FORMAT_R32G32B32A32_FLOAT,1,D3D11_APPEND_ALIGNED_ELEMENT,D3D11_INPUT_PER_INSTANCE_DATA,1,..
								0,2,DXGI_FORMAT_R32G32B32A32_FLOAT,1,D3D11_APPEND_ALIGNED_ELEMENT,D3D11_INPUT_PER_INSTANCE_DATA,1]

		polyLayout[0] = Int("POSITION".ToCString())
		polyLayout[7] = Int("TEXCOORD".ToCString())
		polyLayout[14] = Int("TEXCOORD".ToCString())
		polyLayout[21] = Int("TEXCOORD".ToCString())

		hr = _d3d11dev.CreateInputLayout(polyLayout,Len(polyLayout)/7,vscode.GetBufferPointer(),vscode.GetBuffersize(),_LG._layout)
	
		MemFree Byte Ptr(Int(polyLayout[0]))
		MemFree Byte Ptr(Int(polyLayout[7]))
		MemFree Byte Ptr(Int(polyLayout[14]))
		MemFree Byte Ptr(Int(polyLayout[21]))
		
		If hr<0
			WriteStdout "Cannot create lighting input layout~n"
			Return
		EndIf

		SAFE_RELEASE(vscode)
		SAFE_RELEASE(pscode)
		SAFE_RELEASE(pErrorMsg)
		
		Local bd:D3D11_BLEND_DESC = New D3D11_BLEND_DESC
		bd.IndependentBlendEnable = True
		bd.RenderTarget0_BlendEnable = True
		bd.RenderTarget0_SrcBlend = D3D11_BLEND_ONE
		bd.RenderTarget0_DestBlend = D3D11_BLEND_ONE
		bd.RenderTarget0_BlendOp = D3D11_BLEND_OP_ADD
		bd.RenderTarget0_SrcBlendAlpha = D3D11_BLEND_ONE
		bd.RenderTarget0_DestBlendAlpha = D3D11_BLEND_ZERO
		bd.RenderTarget0_BlendOpAlpha = D3D11_BLEND_OP_ADD
		bd.RenderTarget0_RenderTargetWriteMask = D3D11_COLOR_WRITE_ENABLE_ALL
		_d3d11dev.CreateBlendState(bd,_LG._blendmode)
		
		_LG._shaderready = True
		Return Self
	EndMethod
	
	Method Destroy()		
		SAFE_RELEASE(_LG._colorTEX)
		SAFE_RELEASE(_LG._colorSRV)
		SAFE_RELEASE(_LG._colorRTV)
	
		SAFE_RELEASE(_LG._depthTEX)
		SAFE_RELEASE(_LG._depthRTV)
		SAFE_RELEASE(_LG._depthSRV)
	
		SAFE_RELEASE(_LG._normalTEX)
		SAFE_RELEASE(_LG._normalRTV)
		SAFE_RELEASE(_LG._normalSRV)
	
		SAFE_RELEASE(_LG._shadowTEX)
		SAFE_RELEASE(_LG._shadowRTV)
		SAFE_RELEASE(_LG._shadowSRV)
	
		SAFE_RELEASE(_LG._layout)
		SAFE_RELEASE(_LG._vshader)
		SAFE_RELEASE(_LG._pshader)
		SAFE_RELEASE(_LG._cpshader)
		SAFE_RELEASE(_LG._spshader)
	
		SAFE_RELEASE(_LG._vbuffer)
		SAFE_RELEASE(_LG._lbuffer)
		SAFE_RELEASE(_LG._sbuffer)
	
		SAFE_RELEASE(_LG._blendmode)
	EndMethod
	
	Method SetAmbientColor(r,g,b)
		_LG._ambient[0] = OneOver255 * r
		_LG._ambient[1] = OneOver255 * g
		_LG._ambient[2] = OneOver255 * b
		
		MapBuffer(_LG._sbuffer,0,D3D11_MAP_WRITE_DISCARD,0,_LG._ambient,SizeOf(_LG._ambient))
	EndMethod
	
	Method SetAmbientIntensity(in#)
		_LG._ambient[3] = in

		MapBuffer(_LG._sbuffer,0,D3D11_MAP_WRITE_DISCARD,0,_LG._ambient,SizeOf(_LG._ambient))
	EndMethod
	
	Method DrawScene()
		If Not _LG._shaderready Return

		_d3d11devcon.OMSetBlendState(_LG._blendmode,[0.0,0.0,0.0,0.0],$ffffffff)		
		_d3d11devcon.OMSetRenderTargets(1,Varptr _LG._shadowRTV,Null)		
		_d3d11devcon.ClearRenderTargetView(_LG._shadowRTV,[0.0,0.0,0.0,0.0])

		_d3d11devcon.VSSetShader(_LG._vshader,Null,0)
		_d3d11devcon.PSSetShader(_LG._pshader,Null,0)

		_d3d11devcon.PSSetShaderResources(0,2,[_LG._depthSRV,_LG._normalSRV])

		MapBuffer(_LG._lbuffer,0,D3D11_MAP_WRITE_DISCARD,0,_LG._lightdata,48*_LightIndex)
		_d3d11devcon.IASetVertexBuffers(0,2,[_LG._vbuffer,_LG._lbuffer],[16,48],[0,0])
		_d3d11devcon.IASetInputLayout(_LG._layout)

		_d3d11devcon.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP)

		_d3d11devcon.PSSetConstantBuffers(0,1,Varptr _LG._sbuffer)
		_d3d11devcon.DrawInstanced(4,_LightIndex,0,0)

		SetBlend(-1)
		SetBlend(_currblend)
		
		_d3d11devcon.PSSetShader(_LG._cpshader,Null,0)
		_d3d11devcon.PSSetSamplers(0,1,Varptr _pointsamplerstate)

		Local backbuffer:ID3D11RenderTargetView
		backbuffer = _d3d11Graphics.GetRenderTarget()
		_d3d11devcon.OMSetRenderTargets(1,Varptr backbuffer,Null)
		
		_d3d11devcon.PSSetShaderResources(0,2,[_LG._colorSRV,_LG._shadowSRV])
		_d3d11devcon.Draw(4,0)
		
		_d3d11devcon.ClearRenderTargetView(_LG._colorRTV,[0.0,0.0,0.0,0.0])
		_d3d11devcon.ClearRenderTargetView(_LG._depthRTV,[0.0,0.0,0.0,0.0])
		_d3d11devcon.ClearRenderTargetView(_LG._normalRTV,[0.0,0.0,0.0,0.0])

		ResolveTarget
	EndMethod
	
	Method DrawSprite(Sprite:TLitSprite,x#,y#,frame=0)
		If Not _LG._shaderready Return
			
		_d3d11devcon.OMSetRenderTargets(1,Varptr _LG._colorRTV,Null)
		DrawImage Sprite._ColorMap,x,y,frame
		
		_d3d11devcon.OMSetRenderTargets(1,Varptr _LG._depthRTV,Null)
		DrawImage Sprite._DepthMap,x,y,frame
		
		_d3d11devcon.OMSetRenderTargets(1,Varptr _LG._normalRTV,Null)
		DrawImage Sprite._NormalMap,x,y,frame
		
	EndMethod
	
	Method ResolveTarget()
		Local backbuffer:ID3D11RenderTargetView
		backbuffer = _d3d11Graphics.GetRenderTarget()
		_d3d11devcon.OMSetRenderTargets(1,Varptr backbuffer,Null)
	EndMethod
EndType

Function UseLighting()
	If Not _Lighting _Lighting = New TLighting.Create()
EndFunction

Function FlipLighting()
	If _Lighting _Lighting.DrawScene
EndFunction

Function CreateLitSprite:TLitSprite(colorImage:TImage,depthImage:TImage,normalImage:TImage)
	If Not colorImage Return
	If Not depthImage Return
	If Not normalImage Return
	
	Return New TLitSprite.Create(colorImage,depthImage,normalImage)
EndFunction

Function DrawLitSprite(Sprite:TLitSprite,x#,y#,frame=0)
	If _Lighting _Lighting.DrawSprite(Sprite,x,y,frame)
EndFunction

Function CreateLight:TLight()
	Return New TLight.Create()
EndFunction

Function SetLightPosition(Light:TLight,x#,y#,z#)
	If Not Light Return
	
	Light.SetPosition x,y,z
EndFunction

Function SetLightRadius(Light:TLight,radius#)
	If Not Light Return

	Light.SetRadius radius
EndFunction

Function SetLightColor(Light:TLight,r,g,b)
	If Not Light Return

	Light.SetColor r,g,b
EndFunction

Function SetLightAttenuation(Light:TLight,att0#,att1#,att2#)
	If Not Light Return
	
	Light.SetAttenuation(att0,att1,att2)
EndFunction

Function SetLightIntensity(Light:TLight,intensity#)
	If Not Light Return

	Light.SetIntensity intensity
EndFunction

Function SetAmbientLightColor(r,g,b)
	_Lighting.SetAmbientColor(r,g,b)
EndFunction

Function SetAmbientLightIntensity(in#)
	_Lighting.SetAmbientIntensity(in)
EndFunction

Function TurnLightOn(Light:TLight)
	If Not Light Return
	
	Light.TurnOn
EndFunction

Function TurnLightOff(Light:TLight)
	If Not Light Return
	
	Light.TurnOff
EndFunction

Function FreeLightingResources()
	If _Lighting _Lighting.Destroy()
EndFunction