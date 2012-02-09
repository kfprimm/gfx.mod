Private

Type TShadowImageGlobals
	Field _shadowvs:ID3D11VertexShader
	Field _casterps:ID3D11PixelShader
	Field _distanceps:ID3D11PixelShader
	Field _distortps:ID3D11PixelShader
	
	Field _shadowhps:ID3D11PixelShader
	Field _shadowvps:ID3D11PixelShader
	Field _shadowps:ID3D11PixelShader
		
	Field _layout:ID3D11InputLayout
	Field _vbuffer:ID3D11Buffer

	Field _depthstate:ID3D11DepthStencilState
	
	Field _shaderready

	Field _vs$ = LoadText("incbin::shadow.vs")
	Field _ps$ = LoadText("incbin::shadow.ps")
	
	Field _verts#[16]
	
	Method Create:TShadowImageGlobals()
		CreateBuffer(_vbuffer,SizeOf(_verts),D3D11_USAGE_DYNAMIC,D3D11_BIND_VERTEX_BUFFER,D3D11_CPU_ACCESS_WRITE,_verts,"Shadow Caster Data")

		Local dsdesc:D3D11_DEPTH_STENCIL_DESC = New D3D11_DEPTH_STENCIL_DESC
		dsdesc.DepthEnable = True
		dsdesc.DepthWriteMask = D3D11_DEPTH_WRITE_MASK_ALL
		dsdesc.DepthFunc = D3D11_COMPARISON_LESS
		dsdesc.StencilEnable = False
		
		If _d3d11dev.CreateDepthStencilState(dsdesc,_depthstate)<0
			WriteStdout "Cannot create shadow depth state~n"
			End
		EndIf

		Local hr
		Local vscode:ID3DBlob
		Local pscode:ID3DBlob
		Local pErrorMsg:ID3DBlob
		
		hr = D3DCompile(_vs,_vs.length,Null,Null,Null,"ImageToCasterVS","vs_4_0",..
							_ShaderFlag,0,vscode,pErrorMsg)
		If pErrorMsg
			Local _ptr:Byte Ptr = pErrorMsg.GetBufferPointer()
			WriteStdout String.fromCString(_ptr)
			SAFE_RELEASE(pErrorMsg)
		EndIf
		
		If hr<0
			WriteStdout "Cannot compile shadow caster vs source code~n"
			End
		EndIf
	
		If _d3d11dev.CreateVertexShader(vscode.GetBufferPointer(),vscode.GetBufferSize(),Null,_shadowvs)<0
			WriteStdout "Cannot create shadow caster vertex shader - compiled ok~n"
			End
		EndIf
		
		'CasterPS
		hr = D3DCompile(_ps,_ps.length,Null,Null,Null,"ImageToCasterPS","ps_4_0",..
							_ShaderFlag,0,pscode,pErrorMsg)
		If pErrorMsg
			Local _ptr:Byte Ptr = pErrorMsg.GetBufferPointer()
			WriteStdout String.fromCString(_ptr)
			SAFE_RELEASE(pErrorMsg)
		EndIf
		
		If hr<0
			WriteStdout "Cannot compile shadow caster ps source code~n"
			End
		EndIf

		If _d3d11dev.CreatePixelShader(pscode.GetBufferPointer(),pscode.GetBufferSize(),Null,_casterps)<0
			WriteStdout "Cannot create shadow caster pixel shader - compiled ok~n"
			End
		EndIf

		'DistancePS
		hr = D3DCompile(_ps,_ps.length,Null,Null,Null,"CasterToDistancePS","ps_4_0",..
							_ShaderFlag,0,pscode,pErrorMsg)
		If pErrorMsg
			Local _ptr:Byte Ptr = pErrorMsg.GetBufferPointer()
			WriteStdout String.fromCString(_ptr)
			SAFE_RELEASE(pErrorMsg)
		EndIf
		
		If hr<0
			WriteStdout "Cannot compile shadow distance ps source code~n"
			End
		EndIf

		If _d3d11dev.CreatePixelShader(pscode.GetBufferPointer(),pscode.GetBufferSize(),Null,_distanceps)<0
			WriteStdout "Cannot create shadow distance pixel shader - compiled ok~n"
			End
		EndIf
	
		'DistortPS
		hr = D3DCompile(_ps,_ps.length,Null,Null,Null,"DistanceToDistortPS","ps_4_0",..
							_ShaderFlag,0,pscode,pErrorMsg)
		If pErrorMsg
			Local _ptr:Byte Ptr = pErrorMsg.GetBufferPointer()
			WriteStdout String.fromCString(_ptr)
			SAFE_RELEASE(pErrorMsg)
		EndIf
		
		If hr<0
			WriteStdout "Cannot compile shadow distort ps source code~n"
			End
		EndIf

		If _d3d11dev.CreatePixelShader(pscode.GetBufferPointer(),pscode.GetBufferSize(),Null,_distortps)<0
			WriteStdout "Cannot create shadow distort pixel shader - compiled ok~n"
			End
		EndIf
	
		'create input layout for the vertex shader
		Local polyLayout[] = [	0,0,DXGI_FORMAT_R32G32_FLOAT,0,D3D11_APPEND_ALIGNED_ELEMENT,D3D11_INPUT_PER_VERTEX_DATA,0,..
								0,0,DXGI_FORMAT_R32G32_FLOAT,0,D3D11_APPEND_ALIGNED_ELEMENT,D3D11_INPUT_PER_VERTEX_DATA,0]
		polyLayout[0] = Int("POSITION".ToCString())
		polyLayout[7] = Int("TEXCOORD".ToCString())
	
		hr = _d3d11dev.CreateInputLayout(polyLayout,2,vscode.GetBufferPointer(),vscode.GetBuffersize(),_layout)
	
		MemFree Byte Ptr(Int(polyLayout[0]))
		MemFree Byte Ptr(Int(polyLayout[7]))
		
		If hr<0
			WriteStdout "Cannot create shadow input layout~n"
			Return
		EndIf

		'ShadowHorizontalPS
		hr = D3DCompile(_ps,_ps.length,Null,Null,Null,"DistortHToDepthPS","ps_4_0",..
							_ShaderFlag,0,pscode,pErrorMsg)
		If pErrorMsg
			Local _ptr:Byte Ptr = pErrorMsg.GetBufferPointer()
			WriteStdout String.fromCString(_ptr)
			SAFE_RELEASE(pErrorMsg)
		EndIf
		
		If hr<0
			WriteStdout "Cannot compile DistortHToDepthPS source code~n"
			End
		EndIf

		If _d3d11dev.CreatePixelShader(pscode.GetBufferPointer(),pscode.GetBufferSize(),Null,_shadowhps)<0
			WriteStdout "Cannot create DistortToShadowPS shader - compiled ok~n"
			End
		EndIf
		
		'ShadowVerticalPS
		hr = D3DCompile(_ps,_ps.length,Null,Null,Null,"DistortVToDepthPS","ps_4_0",..
							_ShaderFlag,0,pscode,pErrorMsg)
		If pErrorMsg
			Local _ptr:Byte Ptr = pErrorMsg.GetBufferPointer()
			WriteStdout String.fromCString(_ptr)
			SAFE_RELEASE(pErrorMsg)
		EndIf
		
		If hr<0
			WriteStdout "Cannot compile DistortVToDepthPS source code~n"
			End
		EndIf

		If _d3d11dev.CreatePixelShader(pscode.GetBufferPointer(),pscode.GetBufferSize(),Null,_shadowvps)<0
			WriteStdout "Cannot create DistortToShadowPS shader - compiled ok~n"
			End
		EndIf
		
		'ShadowMapPS
		hr = D3DCompile(_ps,_ps.length,Null,Null,Null,"ShadowMapPS","ps_4_0",..
							_ShaderFlag,0,pscode,pErrorMsg)
		If pErrorMsg
			Local _ptr:Byte Ptr = pErrorMsg.GetBufferPointer()
			WriteStdout String.fromCString(_ptr)
			SAFE_RELEASE(pErrorMsg)
		EndIf
		
		If hr<0
			WriteStdout "Cannot compile DistortToShadowPS source code~n"
			End
		EndIf

		If _d3d11dev.CreatePixelShader(pscode.GetBufferPointer(),pscode.GetBufferSize(),Null,_shadowps)<0
			WriteStdout "Cannot create ShadowMapPS shader - compiled ok~n"
			End
		EndIf

		SAFE_RELEASE(vscode)
		SAFE_RELEASE(pscode)
		SAFE_RELEASE(pErrorMsg)

		Return Self
	EndMethod
	
	Method FreeResources()
		'SAFE_RELEASE(_shadowvs)
		SAFE_RELEASE(_casterps)
		SAFE_RELEASE(_distanceps)
		SAFE_RELEASE(_distortps)
		SAFE_RELEASE(_shadowhps)
		SAFE_RELEASE(_shadowvps)
		SAFE_RELEASE(_shadowps)
		SAFE_RELEASE(_layout)
		SAFE_RELEASE(_vbuffer)
		SAFE_RELEASE(_depthstate)
	EndMethod
EndType

Incbin "shadow.vs"
Incbin "shadow.ps"

Global _SIG:TShadowImageGlobals
Global _DebugShader = D3D11_SHADER_DEBUG|D3D11_SHADER_SKIP_OPTIMIZATION
Global _OptimizeShader = D3D11_SHADER_OPTIMIZATION_LEVEL3
Global _ShaderFlag = _OptimizeShader
'Global _ShaderFlag = _DebugShader

Public

Type TShadowImage	
	Field _casterTEX:ID3D11Texture2D	
	Field _casterSRV:ID3D11ShaderResourceView
	Field _casterRTV:ID3D11RenderTargetView

	Field _distanceTEX:ID3D11Texture2D
	Field _distanceSRV:ID3D11ShaderResourceView
	Field _distanceRTV:ID3D11RenderTargetView
	
	Field _distortTEX:ID3D11Texture2D
	Field _distortSRV:ID3D11ShaderResourceView
	Field _distortRTV:ID3D11RenderTargetView
	
	Field _depthTEX:ID3D11Texture1D
	Field _depthSRV:ID3D11ShaderResourceView
	Field _depthDSV:ID3D11DepthStencilView[4]
	Field _depthDEBUGSRV:ID3D11ShaderResourceView[4]
	
	Field _shadowTEX:ID3D11Texture2D
	Field _shadowSRV:ID3D11ShaderResourceView
	Field _shadowRTV:ID3D11RenderTargetView
	
	Field _vbuffer:ID3D11buffer
	Field _verts#[]
	
	Field _scrx#
	Field _scry#
	Field _width#
	Field _height#
	
	Method Create:TShadowImage(width#,height#)
		If Not _SIG _SIG = New TShadowImageGlobals.Create()
		
		_verts = _verts[..height*8]

		Local index
		For Local y# = 0 Until height
			Local texh#
			texh = y/(height-1)

			_verts[index]=0.0 'left
			_verts[index+1]=0.5
			_verts[index+2]=0.0 'u
			_verts[index+3]=texh'v
			
			_verts[index+4]=width 'right
			_verts[index+5]=0.5
			_verts[index+6]=1.0 'u
			_verts[index+7]=texh 'v
			
			index:+8
		Next
		
		CreateBuffer(_vbuffer,SizeOf(_verts),D3D11_USAGE_DYNAMIC,D3D11_BIND_VERTEX_BUFFER,D3D11_CPU_ACCESS_WRITE,_verts,"Shadow Distance Map Data")
		
		_width = width
		_height = height

		Local image:TImage = CreateImage(width,height,1,RENDERIMAGE)
		Local iframe:TD3D11ImageFrame = TD3D11ImageFrame(image.frame(0))

		_casterTEX = iframe._tex2D
		_casterSRV = iframe._srv
		_casterRTV = iframe._rtv		

		Local texDesc2D:D3D11_TEXTURE2D_DESC = New D3D11_TEXTURE2D_DESC
		_casterTEX.GetDesc(texDesc2D)
		
		'Distance
		If _d3d11dev.CreateTexture2D(texDesc2D,Null,_distanceTEX)<0
			WriteStdout "Cannot create shadow distance texture"
			End
		EndIf
		
		If _d3d11dev.CreateShaderResourceView(_distanceTEX,Null,_distanceSRV)<0
			WriteStdout "Cannot create shadow distance srv"
			End
		EndIf

		If _d3d11dev.CreateRenderTargetView(_distanceTEX,Null,_distanceRTV)<0
			WriteStdout "Cannot create shadow distance rtv"
			End
		EndIf
		
		'Distort
		If _d3d11dev.CreateTexture2D(texDesc2D,Null,_distortTEX)<0
			WriteStdout "Cannot create shadow distortion texture"
			End
		EndIf
		
		If _d3d11dev.CreateShaderResourceView(_distortTEX,Null,_distortSRV)<0
			WriteStdout "Cannot create shadow distortion srv"
			End
		EndIf

		If _d3d11dev.CreateRenderTargetView(_distortTEX,Null,_distortRTV)<0
			WriteStdout "Cannot create shadow distortion rtv"
			End
		EndIf

		'Shadow
		If _d3d11dev.CreateTexture2D(texDesc2D,Null,_shadowTEX)<0
			WriteStdout "Cannot create shadow texture"
			End
		EndIf
		
		If _d3d11dev.CreateShaderResourceView(_shadowTEX,Null,_shadowSRV)<0
			WriteStdout "Cannot create shadow srv"
			End
		EndIf

		If _d3d11dev.CreateRenderTargetView(_shadowTEX,Null,_shadowRTV)<0
			WriteStdout "Cannot create shadow rtv"
			End
		EndIf
		
		'create depth buffers
		Local texDesc:D3D11_TEXTURE1D_DESC = New D3D11_TEXTURE1D_DESC
		texDesc.Width = width
		texDesc.MipLevels = 1
		texDesc.ArraySize = 4
		texDesc.Format = DXGI_FORMAT_R32_TYPELESS
		texDesc.Usage = D3D11_USAGE_DEFAULT
		texDesc.BindFlags = D3D11_BIND_DEPTH_STENCIL|D3D11_BIND_SHADER_RESOURCE
		texDesc.CPUAccessFlags = 0
		texDesc.MiscFlags = 0
		
		If _d3d11dev.CreateTexture1D(texDesc,Null,_depthTEX)<0
			WriteStdout "Cannot create shadow depth texture"
			End
		EndIf
		
		Local dsvView:D3D11_DEPTH_STENCIL_VIEW_DESC = New D3D11_DEPTH_STENCIL_VIEW_DESC
		dsvView.Format = DXGI_FORMAT_D32_FLOAT
		dsvView.ViewDimension = D3D11_DSV_DIMENSION_TEXTURE1DARRAY
		dsvView.Flags = 0
		dsvView.Texture_ArraySize = 1
		dsvView.Texture_MipSlice = 0
		
		For Local i = 0 Until 4
			dsvView.Texture_FirstArraySlice  = i
			
			If _d3d11dev.CreateDepthStencilView(_depthTEX,dsvView,_depthDSV[i])<0
				WriteStdout "Cannot create shadow depth targets"
				End
			EndIf		
		Next
		
		Local srvView:D3D11_SHADER_RESOURCE_VIEW_DESC = New D3D11_SHADER_RESOURCE_VIEW_DESC
		srvView.Format = DXGI_FORMAT_R32_FLOAT
		srvView.ViewDimension =  D3D11_SRV_DIMENSION_TEXTURE1DARRAY
		srvView.Texture_MostDetailedMip = 0
		srvView.Texture_MipLevels = 1
		srvView.Texture_FirstArraySlice = 0
		srvView.Texture_ArraySize = 4

		If _d3d11dev.CreateShaderResourceView(_depthTEX,srvView,_depthSRV)<0
			WriteStdout "Cannot create shadow depth resource view"
			End
		EndIf
		
		For Local i = 0 Until 4
			srvView.Texture_FirstArraySlice = i
			srvView.Texture_ArraySize = 1
			
			If _d3d11dev.CreateShaderResourceView(_depthTEX,srvView,_depthDEBUGSRV[i])<0
				WriteStdout "Cannot create depth debug SRVs"
				End
			EndIf
		Next

		Return Self
	EndMethod
	
	Method Set(x#,y#)
		_d3d11devcon.OMSetRenderTargets(1,Varptr _casterRTV,Null)
		_scrx = x
		_scry = y
	EndMethod
	
	Method Clear()
		_d3d11devcon.ClearRenderTargetView(_casterRTV,[0,0,0,0])
	EndMethod
	
	Method UnSet()
		_d3d11devcon.OMSetRenderTargets(1,Varptr _currentRTV,Null)
	EndMethod
	
	Method DrawShadowCaster(Image:TImage,x#,y#)
		Local iframe:TD3D11ImageFrame = TD3D11ImageFrame(Image.frame(0))

		x:-image.handle_x + _max2DGraphics.origin_x
		y:-image.handle_y + _max2DGraphics.origin_y
		
		Local x1# = x + image.width
		Local y1# = y + image.height
		
		_SIG._verts[0] = x - _scrx
		_SIG._verts[1] = y - _scry
		_SIG._verts[2] = 0.0
		_SIG._verts[3] = 0.0
		
		_SIG._verts[4] = x1 - _scrx
		_SIG._verts[5] = y - _scry
		_SIG._verts[6] = 1.0
		_SIG._verts[7] = 0.0
		
		_SIG._verts[8] = x - _scrx
		_SIG._verts[9] = y1 - _scry
		_SIG._verts[10] = 0.0
		_SIG._verts[11] = 1.0
		
		_SIG._verts[12] = x1 - _scrx
		_SIG._verts[13] = y1 - _scry
		_SIG._verts[14] = 1.0
		_SIG._verts[15] = 1.0
		
		MapBuffer(_SIG._vbuffer,0,D3D11_MAP_WRITE_DISCARD,0,_SIG._verts,SizeOf(_SIG._verts),"Shadow Caster Data")
		
		_d3d11devcon.VSSetShader(_SIG._shadowvs,Null,0)
		_d3d11devcon.PSSetShader(_SIG._casterps,Null,0)
		
		_d3d11devcon.PSSetShaderResources(0,1,Varptr iframe._srv)
		_d3d11devcon.IASetInputLayout(_SIG._layout)
		_d3d11devcon.IASetVertexBuffers(0,1,[_SIG._vbuffer],[16],[0])
		_d3d11devcon.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP)
		
		_d3d11devcon.Draw(4,0)
	EndMethod
	
	Method BuildShadowImage()		
		_SIG._verts[0] = 0.0
		_SIG._verts[1] = 0.0
		_SIG._verts[2] = 0.0
		_SIG._verts[3] = 0.0
		
		_SIG._verts[4] = _width
		_SIG._verts[5] = 0.0
		_SIG._verts[6] = 1.0
		_SIG._verts[7] = 0.0
		
		_SIG._verts[8] = 0.0
		_SIG._verts[9] = _height
		_SIG._verts[10] = 0.0 
		_SIG._verts[11] = 1.0
		
		_SIG._verts[12] = _width
		_SIG._verts[13] = _height
		_SIG._verts[14] = 1.0
		_SIG._verts[15] = 1.0
		
		MapBuffer(_SIG._vbuffer,0,D3D11_MAP_WRITE_DISCARD,0,_SIG._verts,SizeOf(_SIG._verts),"Shadow Caster Data")
		
		_d3d11devcon.OMSetRenderTargets(1,Varptr _distanceRTV,Null)
		_d3d11devcon.ClearRenderTargetView(_distanceRTV,[0.0,0.0,0.0,0.0])

		_d3d11devcon.VSSetShader(_SIG._shadowvs,Null,0)
		_d3d11devcon.PSSetShader(_SIG._distanceps,Null,0)
		
		_d3d11devcon.PSSetShaderResources(0,1,Varptr _casterSRV)
		_d3d11devcon.IASetInputLayout(_SIG._layout)
		_d3d11devcon.IASetVertexBuffers(0,1,[_SIG._vbuffer],[16],[0])
		_d3d11devcon.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP)
		
		_d3d11devcon.Draw(4,0)
		
		'Distort the caster texture
		_d3d11devcon.OMSetRenderTargets(1,Varptr _distortRTV,Null)
		_d3d11devcon.ClearRenderTargetView(_distortRTV,[0.0,0.0,0.0,0.0])

		_d3d11devcon.PSSetShader(_SIG._distortps,Null,0)

		_d3d11devcon.PSSetShaderResources(0,1,Varptr _distanceSRV)
		_d3d11devcon.Draw(4,0)

		'Build 1D Depth Buffers
		Local currentDepthState:ID3D11DepthStencilState
		Local stencilRef
		Local _size = SizeOf(_verts)/2'_height * 16

		_d3d11devcon.OMGetDepthStencilState(currentDepthState,StencilRef)
		_d3d11devcon.OMSetDepthStencilState(_SIG._depthstate,0)
		_d3d11devcon.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_LINELIST)
		_d3d11devcon.PSSetShader(_SIG._shadowhps,Null,0)

		'1st depth -Top
		_d3d11devcon.OMSetRenderTargets(0,Null,_depthDSV[0])
		_d3d11devcon.PSSetShaderResources(0,1,Varptr _distortSRV)
		_d3d11devcon.ClearDepthStencilView(_depthDSV[0],D3D11_CLEAR_DEPTH,1.0,0)
		_d3d11devcon.IASetVertexBuffers(0,1,Varptr _vbuffer,[16],[0])
		_d3d11devcon.Draw(_height,0) 'half texture height
		
		'2nd depth - Bottom
		_d3d11devcon.OMSetRenderTargets(0,Null,_depthDSV[1])
		_d3d11devcon.ClearDepthStencilView(_depthDSV[1],D3D11_CLEAR_DEPTH,1.0,0)
		_d3d11devcon.IASetVertexBuffers(0,1,Varptr _vbuffer,[16],[_size])
		_d3d11devcon.Draw(_height,0) 'half texture height

		'3rd depth - Left
		_d3d11devcon.OMSetRenderTargets(0,Null,_depthDSV[2])
		_d3d11devcon.ClearDepthStencilView(_depthDSV[2],D3D11_CLEAR_DEPTH,1.0,0)
		_d3d11devcon.PSSetShader(_SIG._shadowvps,Null,0)
		_d3d11devcon.IASetVertexBuffers(0,1,[_vbuffer],[16],[0])
		_d3d11devcon.Draw(_height,0) 'half texture height

		'4th depth - Right
		_d3d11devcon.OMSetRenderTargets(0,Null,_depthDSV[3])
		_d3d11devcon.ClearDepthStencilView(_depthDSV[3],D3D11_CLEAR_DEPTH,1.0,0)
		_d3d11devcon.IASetVertexBuffers(0,1,[_vbuffer],[16],[_size])
		_d3d11devcon.Draw(_height,0) 'half texture height

		'final shadow
		_d3d11devcon.OMSetRenderTargets(1,Varptr _shadowRTV,Null)
		_d3d11devcon.ClearRenderTargetView(_shadowRTV,[0.0,0.0,0.0,0.0])
		_d3d11devcon.IASetVertexBuffers(0,1,[_SIG._vbuffer],[16],[0])
		_d3d11devcon.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP)
		_d3d11devcon.PSSetShader(_SIG._shadowps,Null,0)
		_d3d11devcon.PSSetShaderResources(0,1,Varptr _depthSRV)
		
		_d3d11devcon.Draw(4,0)
		
		'resolve
		_d3d11devcon.OMSetDepthStencilState(currentDepthState,stencilRef)
		currentDepthState.Release_
	EndMethod
	
	Method Draw()
		_SIG._verts[0] = _scrx
		_SIG._verts[1] = _scry
		_SIG._verts[2] = 0.0
		_SIG._verts[3] = 0.0
		
		_SIG._verts[4] = _scrx+_width
		_SIG._verts[5] = _scry
		_SIG._verts[6] = 1.0
		_SIG._verts[7] = 0.0
		
		_SIG._verts[8] = _scrx
		_SIG._verts[9] = _scry+_height
		_SIG._verts[10] = 0.0
		_SIG._verts[11] = 1.0
		
		_SIG._verts[12] = _scrx+_width
		_SIG._verts[13] = _scry+_height
		_SIG._verts[14] = 1.0
		_SIG._verts[15] = 1.0

		MapBuffer(_SIG._vbuffer,0,D3D11_MAP_WRITE_DISCARD,0,_SIG._verts,64,"Shadow Caster Data")

		_d3d11devcon.VSSetShader(_vertexshader,Null,0)
		_d3d11devcon.PSSetShader(_texturepixelshader,Null,0)
		_d3d11devcon.IASetInputLayout(_max2Dlayout)
		_d3d11devcon.IASetVertexBuffers(0,1,[_SIG._vbuffer],[16],[0])
		_d3d11devcon.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP)
		_d3d11devcon.PSSetShaderResources(0,1,Varptr _shadowSRV)

		_d3d11devcon.Draw(4,0)
	EndMethod
	
	Method Destroy()
		SAFE_RELEASE(_casterTEX)
		SAFE_RELEASE(_casterSRV)
		SAFE_RELEASE(_casterRTV)
		
		SAFE_RELEASE(_distanceTEX)
		SAFE_RELEASE(_distanceSRV)
		SAFE_RELEASE(_distanceRTV)
		
		SAFE_RELEASE(_distortTEX)
		SAFE_RELEASE(_distortSRV)
		SAFE_RELEASE(_distortRTV)
		
		SAFE_RELEASE(_depthTEX)
		SAFE_RELEASE(_depthSRV)
		
		For Local i = 0 Until 4
			SAFE_RELEASE(_depthDSV[i])
			SAFE_RELEASE(_depthDEBUGSRV[i])
		Next
		
		SAFE_RELEASE(_shadowTEX)
		SAFE_RELEASE(_shadowSRV)
		SAFE_RELEASE(_shadowRTV)
		
		SAFE_RELEASE(_vbuffer)
	EndMethod
	
	Method DebugShadowImage(x#,y#,map)
		_SIG._verts[0] = x
		_SIG._verts[1] = y
		_SIG._verts[2] = 0.0
		_SIG._verts[3] = 0.0
		
		_SIG._verts[4] = x+_width
		_SIG._verts[5] = y
		_SIG._verts[6] = 1.0
		_SIG._verts[7] = 0.0
		
		_SIG._verts[8] = x
		_SIG._verts[9] = y+_height
		_SIG._verts[10] = 0.0
		_SIG._verts[11] = 1.0
		
		_SIG._verts[12] = x+_width
		_SIG._verts[13] = y+_height
		_SIG._verts[14] = 1.0
		_SIG._verts[15] = 1.0
		
		MapBuffer(_SIG._vbuffer,0,D3D11_MAP_WRITE_DISCARD,0,_SIG._verts,SizeOf(_SIG._verts),"Shadow Caster Data")
		
		_d3d11devcon.VSSetShader(_vertexshader,Null,0)
		_d3d11devcon.PSSetShader(_texturepixelshader,Null,0)
		_d3d11devcon.IASetInputLayout(_max2Dlayout)
		_d3d11devcon.IASetVertexBuffers(0,1,[_SIG._vbuffer],[16],[0])
		_d3d11devcon.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP)
	
		Select map
			Case 0
				_d3d11devcon.PSSetShaderResources(0,1,Varptr _casterSRV)
			Case 1
				_d3d11devcon.PSSetShaderResources(0,1,Varptr _distanceSRV)
			Case 2
				_d3d11devcon.PSSetShaderResources(0,1,Varptr _distortSRV)
			Case 3,4,5,6
				_d3d11devcon.PSSetShaderResources(0,1,Varptr _depthDEBUGSRV[map-3])
			Case 7
				_d3d11devcon.PSSetShaderResources(0,1,Varptr _shadowSRV)
		EndSelect

		_d3d11devcon.Draw(4,0)
	EndMethod
EndType

Function CreateShadowImage:TShadowImage(width#,height#)
	Return New TShadowImage.Create(width,height)
EndFunction

Function ClearShadowImage(SImage:TShadowImage)
	If Not SImage Return
	
	SImage.Clear()
EndFunction

Function SetShadowImage(SImage:TShadowImage,x#,y#)
	If Not SImage Return
	
	SImage.Set(x,y)
EndFunction

Function UnSetShadowImage(SImage:TShadowImage)
	If Not SImage Return
	
	SImage.UnSet()
EndFunction

Function DrawShadowCaster(SImage:TShadowImage,Image:TImage,x#,y#)
	If Not SImage Return
	
	SImage.DrawShadowCaster(Image,x,y)
EndFunction

Function BuildShadowImage(SImage:TShadowImage)
	If Not SImage Return
	
	SImage.BuildShadowImage()
EndFunction

Function DrawShadowImage(SImage:TShadowImage)
	If Not SImage Return
	
	SImage.Draw()
EndFunction

Function DestroyShadowImage(SImage:TShadowImage Var)
	If Not SImage Return
	
	SImage.Destroy
	SImage = Null
EndFunction

Function FreeShadowResources()
	If _SIG _SIG.FreeResources()
	_SIG = Null
EndFunction
