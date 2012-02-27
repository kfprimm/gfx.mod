
Strict

Module GFX.D3D11Max2D

ModuleInfo "Version: V1.0"
ModuleInfo "Author: Dave Camp"
ModuleInfo "License: SRS Shared Source Code License"
ModuleInfo "Copyright: SRS Software"

?Win32

Import BRL.Max2D 
Import BRL.TextStream
Import GFX.DXGraphicsEx

'Include "TLighting.bmx"
'Include "TBumpImage.bmx"
'Include "TShadowImage.bmx"

Private
'Max2D
Const OneOver255# = 1.0 / 255.0


'D3D11
Global _d3d11dev:ID3D11Device
Global _d3d11devcon:ID3D11DeviceContext

Global _TD3D11ImageFrameList:TList

Type TD3D11Max2DShaders
	Field _max2dvs$ = LoadText("incbin::max2D.vs")
	Field _max2dps$ = LoadText("incbin::max2D.ps")
EndType

Incbin "max2D.vs"
Incbin "max2D.ps"

Function SAFE_RELEASE(interface:IUnknown Var)
	If interface interface.Release_
	interface = Null
EndFunction

Type TD3D11RingBuffer
	Const RING_SIZE = 1048576 '1MB
	
	Field _buffer:ID3D11Buffer
	Field _ringPos:Int
	
	Method Create:TD3D11RingBuffer()
		Local Desc:D3D11_BUFFER_DESC = New D3D11_BUFFER_DESC
		Desc.ByteWidth = RING_SIZE
		Desc.Usage = D3D11_USAGE_DYNAMIC
		Desc.BindFlags = D3D11_BIND_VERTEX_BUFFER
		Desc.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE

		If _d3d11dev.CreateBuffer(Desc,Null,_buffer)<0 Throw "Cannot create vertex ring buffer~nExiting."
		
		Return Self
	EndMethod
	
	Method Allocate:Int(Data#[])
		Local mRes:D3D11_MAPPED_SUBRESOURCE = New D3D11_MAPPED_SUBRESOURCE

		Local MapPermission = D3D11_MAP_WRITE_NO_OVERWRITE
		If _ringpos + SizeOf(Data) > RING_SIZE
			MapPermission = D3D11_MAP_WRITE_DISCARD
			_ringPos = 0
		EndIf
		
		If _d3d11devcon.Map(_buffer,0,MapPermission,0,mRes)<0 Throw "Cannot map RingBuffer!"
		
		MemCopy mRes.pData+_ringPos,Data,SizeOf(Data)
		_d3d11devcon.UnMap(_buffer,0)
		
		_ringPos :+ SizeOf(Data)
		
		Return _ringPos - SizeOf(Data)
	EndMethod
	
	Method Destroy()
		If _buffer _buffer.Release_
	EndMethod
EndType


Public

Type TD3D11ImageFrame Extends TImageFrame 
	Field _tex2D:ID3D11Texture2D
	Field _srv:ID3D11ShaderResourceView
	Field _rtv:ID3D11RenderTargetView
	Field _sampler:ID3D11SamplerState
	Field _uscale#,_vscale#
	Field _seq

	Method Create:TImageFrame(pixmap:TPixmap,flags)
		If Not _TD3D11ImageFrameList _TD3D11ImageFrameList = New TList
	
		Local width#=pixmap.width
		Local height#=pixmap.height
		Local mipmapped = (flags&MIPMAPPEDIMAGE=MIPMAPPEDIMAGE)
		Local resData[3]
		Local mipindex

		If pixmap.format<>PF_RGBA8888
			pixmap = pixmap.Convert( PF_RGBA8888 )
		EndIf
		
		While pixmap.width > 0 And pixmap.height > 0
			resData[mipindex] = Int(pixmap.pixels)
			resData[mipindex+1] = pixmap.pitch
			resData[mipindex+2] = pixmap.capacity
			
			If Not mipmapped Exit
			
			If pixmap.width>1 And pixmap.height>1
				pixmap=ResizePixmap(pixmap,pixmap.width/2,pixmap.height/2)
			Else
				If pixmap.width>1 And pixmap.height = 1
					pixmap=ResizePixmap(pixmap,pixmap.width/2,pixmap.height)
				Else
					pixmap=ResizePixmap(pixmap,pixmap.width,pixmap.height/2)
				EndIf
			EndIf
			resData = resData[..resData.length+3]
			mipindex :+ 3
		Wend
		
		_uscale=1.0 / width
		_vscale=1.0 / height
		
		'create texture
		Local desc:D3D11_TEXTURE2D_DESC = New D3D11_TEXTURE2D_DESC
		desc.Width = width
		desc.Height = height
		desc.MipLevels = flags&MIPMAPPEDIMAGE=0
		desc.ArraySize = 1
		desc.Format = DXGI_FORMAT_R8G8B8A8_UNORM
		desc.SampleDesc_Count = 1
		desc.SampleDesc_Quality = 0
		desc.Usage = D3D11_USAGE_DEFAULT
		
		Local bind = D3D11_BIND_SHADER_RESOURCE
		If Not mipmapped
		'	If flags&RENDERIMAGE bind = bind|D3D11_BIND_RENDER_TARGET
		EndIf

		desc.BindFlags = bind
		desc.CPUAccessFlags = 0

		If _d3d11dev.CreateTexture2D(desc,resData,_tex2D) < 0
			WriteStdout("Cannot create texture~n")
			Return
		EndIf
		
		'Setup for shader
		Local srdesc:D3D11_SHADER_RESOURCE_VIEW_DESC = New D3D11_SHADER_RESOURCE_VIEW_DESC

		srdesc.Format = desc.Format
		srdesc.ViewDimension = D3D11_SRV_DIMENSION_TEXTURE2D
		srdesc.Texture_MostDetailedMip = 0
		srdesc.Texture_MipLevels = -1*(mipmapped+(flags&MIPMAPPEDIMAGE=0))
				
		If _d3d11dev.CreateShaderResourceView(_tex2D,srdesc,_srv)<0
			WriteStdout "Cannot create ShaderResourceView for TImage texture~n"
			Return
		EndIf
		
		If Not mipmapped
			'If (flags&RENDERIMAGE)
			'	If _d3d11dev.CreateRenderTargetView(_tex2D,Null,_rtv)<0
			'		WriteStdout "Cannot use texture as a Render Texture~n"
			'		Return
			'	Else
					'Created OK so clear the allocated memory
			'		_d3d11devcon.ClearRenderTargetView(_rtv,[0.0,0.0,0.0,0.0])
			'	EndIf
			'EndIf
		EndIf
		
		_seq=GraphicsSeq
		
		If flags&FILTEREDIMAGE
			_sampler = TD3D11Max2DDriver._linearsamplerstate
		Else
			_sampler = TD3D11Max2DDriver._pointsamplerstate
		EndIf
		
		_TD3D11ImageFrameList.AddLast Self
		Return Self
	EndMethod
	
	Method Destroy()
		SAFE_RELEASE(_tex2D)
		SAFE_RELEASE(_srv)
		SAFE_RELEASE(_rtv)
	EndMethod

	Method Draw( x0#,y0#,x1#,y1#,tx#,ty#,sx#,sy#,sw#,sh# )
		Local u0#=sx*_uscale
		Local v0#=sy*_vscale
		Local u1#=(sx+sw)*_uscale
		Local v1#=(sy+sh)*_vscale
		Local _verts#[16]
		
		_verts[0]=x0*TD3D11Max2DDriver._ix+y0*TD3D11Max2DDriver._iy+tx
		_verts[1]=x0*TD3D11Max2DDriver._jx+y0*TD3D11Max2DDriver._jy+ty
		_verts[2]=u0
		_verts[3]=v0

		_verts[4]=x1*TD3D11Max2DDriver._ix+y0*TD3D11Max2DDriver._iy+tx
		_verts[5]=x1*TD3D11Max2DDriver._jx+y0*TD3D11Max2DDriver._jy+ty
		_verts[6]=u1
		_verts[7]=v0

		_verts[8]=x0*TD3D11Max2DDriver._ix+y1*TD3D11Max2DDriver._iy+tx
		_verts[9]=x0*TD3D11Max2DDriver._jx+y1*TD3D11Max2DDriver._jy+ty
		_verts[10]=u0
		_verts[11]=v1
		
		_verts[12]=x1*TD3D11Max2DDriver._ix+y1*TD3D11Max2DDriver._iy+tx
		_verts[13]=x1*TD3D11Max2DDriver._jx+y1*TD3D11Max2DDriver._jy+ty
		_verts[14]=u1
		_verts[15]=v1

		Local stride = 16
		Local offset = 0
		
		'Use a ring buffer - MS recommend this approach, but tiny tiny bit inefficient due to 'low through-put' of Max2D
		'Local offset = _ringBuffer.Allocate(_verts)
		'_d3d11devcon.IASetVertexBuffers(0,1,Varptr _ringbuffer._buffer,Varptr stride,Varptr offset)
		
		TD3D11Max2DDriver.MapBuffer(TD3D11Max2DDriver._vertexbuffer,0,D3D11_MAP_WRITE_DISCARD,0,_verts,SizeOf(_verts))

		_d3d11devcon.VSSetShader(TD3D11Max2DDriver._vertexshader,Null,0)
		_d3d11devcon.PSSetShader(TD3D11Max2DDriver._texturepixelshader,Null,0)

		_d3d11devcon.PSSetSamplers(0,1,Varptr _sampler)
		_d3d11devcon.PSSetShaderResources(0,1,Varptr _srv)
		_d3d11devcon.PSSetConstantBuffers(0,1,Varptr TD3D11Max2DDriver._psfbuffer)
		
		_d3d11devcon.IASetInputLayout(TD3D11Max2DDriver._max2dlayout)
		_d3d11devcon.IASetVertexBuffers(0,1,Varptr TD3D11Max2DDriver._vertexbuffer,Varptr stride,Varptr offset)
		_d3d11devcon.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP)
		_d3d11devcon.Draw(4,0)
	EndMethod
EndType

Type TD3D11Max2DDriver Extends TMax2DDriver	
	Global _pointbuffer:ID3D11Buffer, _linebuffer:ID3D11Buffer, _projbuffer:ID3D11Buffer, _tilebuffer:ID3D11Buffer
	Global _pointarray#[], _polyarray#[], _ovalarray#[], _linearray#[], _tilearray#[]
	
	Global _vertexshader:ID3D11VertexShader
	Global _texturepixelshader:ID3D11PixelShader
	Global _colorpixelshader:ID3D11PixelShader
	Global _max2dlayout:ID3D11InputLayout
	Global _currentbuffer:ID3D11Buffer, _vertexbuffer:ID3D11Buffer, _psfbuffer:ID3D11Buffer, _polybuffer:ID3D11Buffer, _ovalbuffer:ID3D11Buffer
	
	Global _clscolor#[] = [0.0,0.0,0.0,1.0]
	Global _ix#,_iy#,_jx#,_jy#, _linewidth#
	
	Global _max2dshaders:TD3D11Max2DShaders
	Global _currentrtv:ID3D11RenderTargetView
	Global _driver:TD3D11Max2DDriver
	Global _d3d11graphics:TD3D11Graphics
	Global _max2DGraphics:TMax2DGraphics
	Global _width#,_height#
	Global _currblend
	
	Global _shaderready
	Global _currentshader:ID3D11PixelShader
	Global _currentsrv:ID3D11ShaderResourceView
	Global _currentsampler:ID3D11SamplerState
	Global _pointsamplerstate:ID3D11SamplerState
	Global _linearsamplerstate:ID3D11SamplerState
	Global _rs:ID3D11RasterizerState
	Global _psflags#[8]
	Global _matrixproj#[16]
	Global _ringbuffer:TD3D11RingBuffer
	

	Global _solidblend:ID3D11BlendState, _maskblend:ID3D11BlendState, _alphablend:ID3D11BlendState
	Global _lightblend:ID3D11BlendState, _shadeblend:ID3D11BlendState

	Method ToString$()
		Local Feature$
		Local FeatureLevel = _d3d11dev.GetFeatureLevel()
		
		Select FeatureLevel
			Case D3D_FEATURE_LEVEL_10_0
				Feature = "10.0"
			Case D3D_FEATURE_LEVEL_10_1
				Feature = "10.1"
			Case D3D_FEATURE_LEVEL_11_0
				Feature = "11.0"
			'Case D3D_FEATURE_LEVEL_11_1	'Waiting for Win8
			'	Feature = "11.1"
		EndSelect
		
		Return "DirectX11 - Using DirectX"+Feature
	EndMethod
	
	'TMaxGraphicsDriver
	Method GraphicsModes:TGraphicsMode[]()
		Return D3D11GraphicsDriver().GraphicsModes()
	EndMethod
	
	Method AttachGraphics:TGraphics( hwnd,flags )
		Local g:TD3D11Graphics = D3D11GraphicsDriver().AttachGraphics( hwnd,flags )
		If g Return TMax2DGraphics.Create( g ,Self )
	EndMethod
	
	Method CreateGraphics:TGraphics( width,height,depth,hertz,flags )
		Local g:TD3D11Graphics = D3D11GraphicsDriver().CreateGraphics(width,height,depth,hertz,flags)
		If Not g Return Null
		Return TMax2DGraphics.Create(g,Self)
	EndMethod
	
	Method SetGraphics( g:TGraphics )
		If Not g
			Free
			
			If _TD3D11ImageFrameList
				For Local frame:TD3D11ImageFrame = EachIn _TD3D11ImageFrameList
					frame.Destroy
				Next
			EndIf
			_TD3D11ImageFrameList = Null
			
			If _d3d11dev
				If _d3d11devcon
					_d3d11devcon.ClearState
					_d3d11devcon = Null
				EndIf
				_d3d11dev = Null
			EndIf
					
			_d3d11graphics = Null
			TMax2DGraphics.ClearCurrent
			D3D11GraphicsDriver().SetGraphics Null
			
			Return
		EndIf
		
		_max2DGraphics = TMax2DGraphics( g )
		_d3d11graphics = TD3D11Graphics( _max2DGraphics._graphics )
		
		Assert _max2DGraphics And _d3d11graphics
		
		_d3d11dev = _d3d11Graphics.GetDirect3DDevice()
		_d3d11devcon = _d3d11Graphics.GetDirect3DDeviceContext()
		
		D3D11GraphicsDriver().SetGraphics _d3d11Graphics
		_currentrtv = _d3d11graphics.GetRenderTarget()

		Init
		
		_max2DGraphics.MakeCurrent

		_width = GraphicsWidth()
		_height = GraphicsHeight()
	EndMethod
	
	Method Flip( sync )
		D3D11GraphicsDriver().Flip( sync )
	EndMethod

	'TMax2DDriver
	Method CreateFrameFromPixmap:TImageFrame( pixmap:TPixmap,flags )
		Return New TD3D11ImageFrame.Create(pixmap,flags)
	EndMethod
		
	Method SetBlend( blend )
		If _currblend = blend Return

		Local BF#[] = [0.0,0.0,0.0,0.0] 'Not utilised
		Select blend
			Case SOLIDBLEND
				_d3d11devcon.OMSetBlendState(_solidblend,BF,$ffffffff)
				DisableAlphaTest
			Case ALPHABLEND
				_d3d11devcon.OMSetBlendState(_alphablend,BF,$ffffffff)
				DisableAlphaTest
			Case SHADEBLEND
				_d3d11devcon.OMSetBlendState(_shadeblend,BF,$ffffffff)
				DisableAlphaTest
			Case LIGHTBLEND
				_d3d11devcon.OMSetBlendState(_lightblend,BF,$ffffffff)
				DisableAlphaTest
			Case MASKBLEND
				_d3d11devcon.OMSetBlendState(_maskblend,BF,$ffffffff)
				EnableAlphaTest
		EndSelect

		_currblend = blend
	EndMethod
	
	Method SetAlpha( alpha# )
		If alpha = _psflags[3] Return

		alpha=Max(Min(alpha,1),0) 'clamp 0.0 - 1.0
		_psflags[3] = alpha
			
		MapBuffer(_psfbuffer,0,D3D11_MAP_WRITE_DISCARD,0,_psflags,SizeOf(_psflags))
	EndMethod

	Method SetColor( red,green,blue )
		Local r = Max(Min(red,255),0)
		Local g = Max(Min(green,255),0)
		Local b = Max(Min(blue,255),0)
		
		_psflags[0] = OneOver255 *  red
		_psflags[1] = OneOver255 *  green
		_psflags[2] = OneOver255 *  blue
		
		MapBuffer(_psfbuffer,0,D3D11_MAP_WRITE_DISCARD,0,_psflags,SizeOf(_psflags))
	EndMethod

	Method SetClsColor( red,green,blue )
		_clscolor[0] = OneOver255 * red
		_clscolor[1] = OneOver255 * green
		_clscolor[2] = OneOver255 * blue
	EndMethod

	Method SetViewport( x,y,width,height )
		_d3d11devcon.RSSetScissorRects(1,[x,y,x+width,y+height])
	EndMethod

	Method SetTransform( xx#,xy#,yx#,yy# )
		_ix = xx
		_iy = xy
		_jx = yx
		_jy = yy
	EndMethod

	Method SetLineWidth( width# )
		_linewidth=width
	EndMethod

	Method Cls()
		_d3d11devcon.ClearRenderTargetView( _currentrtv , _clscolor )
	EndMethod

	Method Plot( x#,y# )
		Local _vert#[4]
		_vert[0]=x
		_vert[1]=y
			
		Local stride = 16
		Local offset = 0
			
		MapBuffer(_vertexbuffer,0,D3D11_MAP_WRITE_DISCARD,0,_vert,SizeOf(_vert))

		_d3d11devcon.IASetInputLayout(_max2dlayout)
		_d3d11devcon.VSSetShader(_vertexshader,Null,0)
		_d3d11devcon.PSSetShader(_colorpixelshader,Null,0)
		_d3d11devcon.PSSetConstantBuffers(0,1,Varptr _psfbuffer)
		_d3d11devcon.IASetVertexBuffers(0,1,Varptr _vertexbuffer,Varptr stride,Varptr offset)
		_d3d11devcon.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_POINTLIST)
		_d3d11devcon.Draw(1,0)
	EndMethod

	Method DrawLine( x0#,y0#,x1#,y1#,tx#,ty# )
		Local _verts#[16]
		
		Local lx0# = x0*_ix + y0*_iy + tx
		Local ly0# = x0*_jx + y0*_jy + ty
		Local lx1# = x1*_ix + y1*_iy + tx
		Local ly1# = x1*_jx + y1*_jy + ty
		
		_d3d11devcon.VSSetShader(_vertexshader,Null,0)
		_d3d11devcon.PSSetShader(_colorpixelshader,Null,0)
		_d3d11devcon.PSSetConstantBuffers(0,1,Varptr _psfbuffer)
		_d3d11devcon.IASetInputLayout(_max2dlayout)

		If _lineWidth<=1
			_verts[0]=lx0
			_verts[1]=ly0
			_verts[4]=lx1
			_verts[5]=ly1
			
			Local stride = 16
			Local offset = 0
			
			MapBuffer(_vertexbuffer,0,D3D11_MAP_WRITE_DISCARD,0,_verts,SizeOf(_verts))

			_d3d11devcon.IASetVertexBuffers(0,1,Varptr _vertexbuffer,Varptr stride,Varptr offset)
			_d3d11devcon.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_LINELIST)
			_d3d11devcon.Draw(2,0)
			Return
		EndIf
		
		Local lw#=_lineWidth
		If Abs(ly1-ly0)>Abs(lx1-lx0)
			_verts[0]=lx0-lw
			_verts[1]=ly0
			_verts[4]=lx0+lw
			_verts[5]=ly0
			_verts[8]=lx1-lw
			_verts[9]=ly1
			_verts[12]=lx1+lw
			_verts[13]=ly1
		Else
			_verts[0]=lx0
			_verts[1]=ly0-lw
			_verts[4]=lx0
			_verts[5]=ly0+lw
			_verts[8]=lx1
			_verts[9]=ly1-lw
			_verts[12]=lx1
			_verts[13]=ly1+lw
		EndIf

		MapBuffer(_vertexbuffer,0,D3D11_MAP_WRITE_DISCARD,0,_verts,SizeOf(_verts))

		Local stride = 16
		Local offset = 0

		_d3d11devcon.IASetVertexBuffers(0,1,Varptr _vertexbuffer,Varptr stride,Varptr offset)
		_d3d11devcon.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP)
		_d3d11devcon.Draw(4,0)
	EndMethod

	Method DrawRect( x0#,y0#,x1#,y1#,tx#,ty# )
		Local _verts#[16]
		
		_verts[0]  = x0*_ix + y0*_iy + tx
		_verts[1]  = x0*_jx + y0*_jy + ty
		_verts[4]  = x1*_ix + y0*_iy + tx
		_verts[5]  = x1*_jx + y0*_jy + ty
		_verts[8] = x0*_ix + y1*_iy + tx
		_verts[9] = x0*_jx + y1*_jy + ty
		_verts[12] = x1*_ix + y1*_iy + tx
		_verts[13] = x1*_jx + y1*_jy + ty
		
		MapBuffer(_vertexbuffer,0,D3D11_MAP_WRITE_DISCARD,0,_verts,SizeOf(_verts))
		
		Local stride = 16
		Local offset = 0
		
		_d3d11devcon.VSSetShader(_vertexshader,Null,0)
		_d3d11devcon.PSSetShader(_colorpixelshader,Null,0)
		_d3d11devcon.PSSetConstantBuffers(0,1,Varptr _psfbuffer)
		_d3d11devcon.IASetInputLayout(_max2dlayout)
		_d3d11devcon.IASetVertexBuffers(0,1,Varptr _vertexbuffer,Varptr stride,Varptr offset)
		_d3d11devcon.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP)
		_d3d11devcon.Draw(4,0)
	EndMethod

	Method DrawOval(x0#,y0#,x1#,y1#,tx#,ty#)
		Local BuildBuffer=False

		Local xr#=(x1-x0)*0.5
		Local yr#=(y1-y0)*0.5
		Local segs=Abs(xr)+Abs(yr)
		segs=(Max(segs,12)&~3)

		If _ovalarray.length <> segs*12
			'BUG FIX - Causes intermittant EAV if removed!!!
			'Only when array size is changed every frame
			_ovalarray = Null
			GCCollect()

			_ovalarray = _ovalarray[..segs*12]
			BuildBuffer = True
		EndIf

		x0:+xr
		y0:+yr
		
		Local cx#=x0 + tx
		Local cy#=y0 + ty
		
		Local i#
		Local index
		Repeat
			_ovalarray[index] = cx
			_ovalarray[index+1] = cy

			Local th#=-i*360.0/segs
			Local x#=x0+Cos(th)*xr
			Local y#=y0-Sin(th)*yr
			
			Local xx#=x*_ix+y*_iy+tx
			Local yy#=x*_jx+y*_jy+ty
		
			_ovalarray[index+4] = xx
			_ovalarray[index+5] = yy
					
			i:+1
			th#=-i*360.0/segs
			x#=x0+Cos(th)*xr
			y#=y0-Sin(th)*yr
			
			xx#=x*_ix+y*_iy+tx
			yy#=x*_jx+y*_jy+ty

			_ovalarray[index+8] = xx
			_ovalarray[index+9] = yy
			
			index :+ 12
		Until i = segs
		
		If Not BuildBuffer
			MapBuffer(_ovalbuffer,0,D3D11_MAP_WRITE_DISCARD,0,_ovalarray,SizeOf(_ovalarray))
		Else
			SAFE_RELEASE(_ovalbuffer)
			CreateBuffer(_ovalbuffer,SizeOf(_ovalarray),D3D11_USAGE_DYNAMIC,D3D11_BIND_VERTEX_BUFFER,D3D11_CPU_ACCESS_WRITE,_ovalarray,"Oval Array")
		EndIf
		
		Local stride = 16
		Local offset = 0
		
		_d3d11devcon.VSSetShader(_vertexshader,Null,0)
		_d3d11devcon.PSSetShader(_colorpixelshader,Null,0)
		_d3d11devcon.PSSetConstantBuffers(0,1,Varptr _psfbuffer)
		_d3d11devcon.IASetInputLayout(_max2dlayout)
		_d3d11devcon.IASetVertexBuffers(0,1,Varptr _ovalbuffer,Varptr stride,Varptr offset)
		_d3d11devcon.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST)
		_d3d11devcon.Draw(segs*3,0)
	EndMethod

	Method DrawPoly( inverts#[],handlex#,handley#,tx#,ty# )
		If inverts.length<6 Or (inverts.length&1) Return
		Local nv=inverts.length/2
		Local numpolys = nv-2
		
		Local buildbuffer = False
		If _polyarray.length <> numpolys*12
			'BUG FIX - Causes intermittant EAV if removed!!!
			'Only when array size is changed every frame
			_polyarray = Null
			GCCollect()
			
			_polyarray = _polyarray[..numpolys*12]
			BuildBuffer = True
		EndIf
				
		Local v0x#=inverts[0]+handlex
		Local v0y#=inverts[1]+handley

		Local i=1
		Local j
		Repeat			
			Local v1x#=inverts[i*2]+handlex
			Local v1y#=inverts[i*2+1]+handley
			Local v2x#=inverts[i*2+2]+handlex
			Local v2y#=inverts[i*2+3]+handley
			
			_polyarray[j*12]=v0x*_ix+v0y*_iy+tx
			_polyarray[j*12+1]=v0x*_jx+v0y*_jy+ty
			
			_polyarray[j*12+4]=v1x*_ix+v1y*_iy+tx
			_polyarray[j*12+5]=v1x*_jx+v1y*_jy+ty
			
			_polyarray[j*12+8]=v2x*_ix+v2y*_iy+tx
			_polyarray[j*12+9]=v2x*_jx+v2y*_jy+ty

			i:+1
			j:+1
		Until j = numpolys

		If Not buildbuffer
			MapBuffer(_polybuffer,0,D3D11_MAP_WRITE_DISCARD,0,_polyarray,SizeOf(_polyarray))
		Else
			SAFE_RELEASE(_polybuffer)
			CreateBuffer(_polybuffer,SizeOf(_polyarray),D3D11_USAGE_DYNAMIC,D3D11_BIND_VERTEX_BUFFER,D3D11_CPU_ACCESS_WRITE,_polyarray,"Poly Array")
		EndIf

		Local stride = 16
		Local offset = 0
		
		_d3d11devcon.VSSetShader(_vertexshader,Null,0)
		_d3d11devcon.PSSetShader(_colorpixelshader,Null,0)
		_d3d11devcon.PSSetConstantBuffers(0,1,Varptr _psfbuffer)
		_d3d11devcon.IASetInputLayout(_max2dlayout)
		_d3d11devcon.IASetVertexBuffers(0,1,Varptr _polybuffer,Varptr stride,Varptr offset)
		_d3d11devcon.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST)
		_d3d11devcon.Draw(numpolys*3,0)
	EndMethod

	Method DrawPixmap( pixmap:TPixmap,x0,y0 )		
		Local pTex:ID3D11Texture2D
		Local pTexDesc:D3D11_TEXTURE2D_DESC = New D3D11_TEXTURE2D_DESC
		
		If pixmap.format <> PF_RGBA8888 pixmap=ConvertPixmap(pixmap,PF_RGBA8888)
		
		pTexDesc.Width = pixmap.width
		pTexDesc.Height = pixmap.height
		pTexDesc.MipLevels = 1
		pTexDesc.ArraySize = 1
		pTexDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM
		pTexDesc.SampleDesc_Count = 1
		pTexDesc.SampleDesc_Quality = 0
		pTexDesc.Usage = D3D11_USAGE_DEFAULT
		pTexDesc.BindFlags = D3D11_BIND_SHADER_RESOURCE
		pTexDesc.CPUAccessFlags = 0
		pTexDesc.MiscFlags = 0
		
		Local desc[3]
		desc[0]=Int(pixmap.pixels)
		desc[1]=pixmap.pitch
		desc[2]=pixmap.pitch*pixmap.height
		
		If _d3d11dev.CreateTexture2D(pTexDesc,desc,pTex)<0
			WriteStdout "DrawPixmap Error - Cannot create texture!~n"
			Return
		EndIf
		
		Local pmverts#[] = [Float(x0),Float(y0),0.0,0.0,..
							Float(x0+pixmap.width),Float(y0),1.0,0.0,..
							Float(x0),Float(y0+pixmap.height),0.0,1.0,..
							Float(x0+pixmap.width),Float(y0+pixmap.height),1.0,1.0]
	
		MapBuffer(_vertexbuffer,0,D3D11_MAP_WRITE_DISCARD,0,pmverts,SizeOf(pmverts))
		
		Local srdesc:D3D11_SHADER_RESOURCE_VIEW_DESC = New D3D11_SHADER_RESOURCE_VIEW_DESC
		Local pmsrv:ID3D11ShaderResourceView
		
		srdesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM
		srdesc.ViewDimension = D3D11_SRV_DIMENSION_TEXTURE2D
		srdesc.Texture_MostDetailedMip = 0
		srdesc.Texture_MipLevels = 1
		
		If _d3d11dev.CreateShaderResourceView(pTex,srdesc,pmsrv)<0
			WriteStdout "Cannot create ShaderResourceView for pixamp texture~n"
			Return
		EndIf
		
		Local stride = 16
		Local offset = 0

		_d3d11devcon.PSSetShaderResources(0,1,Varptr pmsrv)		
		_d3d11devcon.VSSetShader(_vertexshader,Null,0)
		_d3d11devcon.PSSetShader(_texturepixelshader,Null,0)
		_d3d11devcon.PSSetConstantBuffers(0,1,Varptr _psfbuffer)
		_d3d11devcon.IASetInputLayout(_max2dlayout)
		_d3d11devcon.IASetVertexBuffers(0,1,Varptr _vertexbuffer,Varptr stride,Varptr offset)
		_d3d11devcon.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP)
		_d3d11devcon.Draw(4,0)

		SAFE_RELEASE(pTex)
		SAFE_RELEASE(pmsrv)
	EndMethod

	Method GrabPixmap:TPixmap(x,y,width,height)
		Local pixmap:TPixmap=CreatePixmap(width,height,PF_RGBA8888)

		Local pRTV:ID3D11RenderTargetView
		Local pBackBuffer:ID3D11Texture2D
		Local pTex:ID3D11Texture2D
		
		'Get back buffer
		_d3d11devcon.OMGetRenderTargets(1,Varptr pRTV,Null)
		pRTV.GetResource(pBackBuffer)
		
		Local pBufferDesc:D3D11_TEXTURE2D_DESC = New D3D11_TEXTURE2D_DESC
		pBackBuffer.GetDesc(pBufferDesc)
		
		pBufferDesc.Usage = D3D11_USAGE_STAGING
		pBufferDesc.BindFlags = 0
		pBufferDesc.CPUAccessFlags = D3D11_CPU_ACCESS_READ
		pBufferDesc.MiscFlags = 0
		
		'copy backbuffer
		_d3d11dev.CreateTexture2D(pBufferDesc,Null,pTex)
		_d3d11devcon.CopyResource(pTex,pBackBuffer)
		
		'now copy into pixmap
		Local _map:D3D11_MAPPED_SUBRESOURCE = New D3D11_MAPPED_SUBRESOURCE
		_d3d11devcon.Map(pTex,0,D3D11_MAP_READ,0,_map)

			For Local h = 0 Until pixmap.height
				Local dst:Byte Ptr = pixmap.pixels + h*pixmap.pitch
				Local src:Byte Ptr = _map.pData+(x Shl 2 + (y*_map.RowPitch))+h*_map.RowPitch
				MemCopy dst,src,pixmap.pitch
			Next
		_d3d11devcon.UnMap(pTex,0)
		
		SAFE_RELEASE(pTeX)
		SAFE_RELEASE(pBackBuffer)
		SAFE_RELEASE(pRTV)
		
		Return pixmap
	EndMethod

	Method SetResolution( w#,h# )
		_matrixproj = [2.0/w,0.0,0.0,-1-(1.0/w)+(1.0/w),..
						0.0,-2.0/h,0.0,1+(1.0/h)-(1.0/h),..
						0.0,0.0,1.0,0.0,..
						0.0,0.0,0.0,1.0]
		MapBuffer(_projbuffer,0,D3D11_MAP_WRITE_DISCARD,0,_matrixproj,SizeOf(_matrixproj))
	EndMethod
	
	Method Create:TD3D11Max2DDriver()
		If Not D3D11GraphicsDriver() Return Null
		Return Self
	EndMethod
	
	Function Init()
		If _shaderready Return
		
		If Not _max2dshaders _max2dshaders = New TD3D11Max2DShaders
	
	_ringbuffer:TD3D11RingBuffer = New TD3D11RingBuffer.Create()
		
 	Local dsdesc:D3D11_DEPTH_STENCIL_DESC =  New D3D11_DEPTH_STENCIL_DESC
	dsdesc.DepthEnable=False
	dsdesc.StencilEnable=False
	Local dsstate:ID3D11DepthStencilState

	If _d3d11dev.CreateDepthStencilState(dsdesc,dsstate)<0
		WriteStdout "Cannot create depth stencil state~n"
		Return
	EndIf
	
	_d3d11devcon.OMSetDepthStencilState(dsstate,0)
	_d3d11graphics.AddRelease dsstate

	'rasterizer state
	Local rsdesc:D3D11_RASTERIZER_DESC = New D3D11_RASTERIZER_DESC
	rsdesc.Fillmode = D3D11_FILL_SOLID
	rsdesc.CullMode = D3D11_CULL_NONE
	rsdesc.ScissorEnable = True

	If _d3d11dev.CreateRasterizerState(rsdesc,_rs)<0
		WriteStdout "Cannot create rasterizer state~n"
		Return
	EndIf
	
	_d3d11devcon.RSSetScissorRects(1,[0,0,GraphicsWidth(),GraphicsHeight()])

	_d3d11devcon.RSSetState(_rs)
	_d3d11graphics.AddRelease _rs
	
	'create shaders
	Local hr
	Local vscode:ID3DBlob
	Local pscode:ID3DBlob
	Local pErrorMsg:ID3DBlob
	
	'create vertex shader
	hr = D3DCompile(_max2dshaders._max2Dvs,_max2dshaders._max2Dvs.length,Null,Null,Null,"StandardVertexShader","vs_4_0",..
							D3D11_SHADER_OPTIMIZATION_LEVEL3,0,vscode,pErrorMsg)
	If pErrorMsg
		Local _ptr:Byte Ptr = pErrorMsg.GetBufferPointer()
		WriteStdout String.fromCString(_ptr)
		
		SAFE_RELEASE(pErrorMsg)
	EndIf
		
	If hr<0
			WriteStdout "Cannot compile vertex shader source code~n"
			Return
	EndIf

	If _d3d11dev.CreateVertexShader(vscode.GetBufferPointer(),vscode.GetBufferSize(),Null,_vertexshader)<0
		WriteStdout "Cannot create vertex shader - compiled ok~n"
		Return
	EndIf
	
	'create input layout for the vertex shader
	Local polyLayout[] = [	0,0,DXGI_FORMAT_R32G32_FLOAT,0,D3D11_APPEND_ALIGNED_ELEMENT,D3D11_INPUT_PER_VERTEX_DATA,0,..
							0,0,DXGI_FORMAT_R32G32_FLOAT,0,D3D11_APPEND_ALIGNED_ELEMENT,D3D11_INPUT_PER_VERTEX_DATA,0]
	
	polyLayout[0] = Int("POSITION".ToCString())
	polyLayout[7] = Int("TEXCOORD".ToCString())
	
	hr = _d3d11dev.CreateInputLayout(polyLayout,2,vscode.GetBufferPointer(),vscode.GetBuffersize(),_max2dlayout)
	
	MemFree Byte Ptr(Int(polyLayout[0]))
	MemFree Byte Ptr(Int(polyLayout[7]))
	
	If hr<0
		WriteStdout "Cannot create shader input layout~n"
		Return
	EndIf

	'create texture pixel shader
	hr = D3DCompile(_max2dshaders._max2Dps,_max2dshaders._max2Dps.length,Null,Null,Null,"TexturePixelShader","ps_4_0",..
								D3D11_SHADER_OPTIMIZATION_LEVEL3,0,pscode,pErrorMsg)
									
	If pErrorMsg
		Local _ptr:Byte Ptr = pErrorMsg.GetBufferPointer()
		WriteStdout String.fromCString(_ptr)
			
		SAFE_RELEASE(pErrorMsg)
	EndIf
	If hr<0
		Throw "Cannot compile pixel shader source code for texturing!~nShutting down."
	EndIf

	If _d3d11dev.CreatePixelShader(pscode.GetBufferPointer(),pscode.GetBufferSize(),Null,_texturepixelshader)<0
		Throw "Cannot create pixel shader for texturing - compiled ok~n"
	EndIf
	
	'create color pixel shader
	hr = D3DCompile(_max2dshaders._max2Dps,_max2dshaders._max2Dps.length,Null,Null,Null,"ColorPixelShader","ps_4_0",..
								D3D11_SHADER_OPTIMIZATION_LEVEL3,0,pscode,pErrorMsg)
									
	If pErrorMsg
		Local _ptr:Byte Ptr = pErrorMsg.GetBufferPointer()
		WriteStdout String.fromCString(_ptr)
			
		SAFE_RELEASE(pErrorMsg)
	EndIf
	If hr<0 Throw "Cannot compile pixel shader source code for coloring!~nShutting down."
	
	If _d3d11dev.CreatePixelShader(pscode.GetBufferPointer(),pscode.GetBufferSize(),Null,_colorpixelshader)<0 Throw "Cannot create pixel shader for coloring - compiled ok~n"

	'release blobs
	SAFE_RELEASE(vscode)
	SAFE_RELEASE(pscode)
	SAFE_RELEASE(pErrorMsg)			'Should NEVER need this if we actually get here
	
	'create vertex buffer
	CreateBuffer(_vertexbuffer,64,D3D11_USAGE_DYNAMIC,D3D11_BIND_VERTEX_BUFFER,D3D11_CPU_ACCESS_WRITE,Null,"Vertex Buffer")	

	'matrix buffer for orthogonal matrix
	_matrixproj = New Float[16]
	CreateBuffer(_projbuffer,64,D3D11_USAGE_DYNAMIC,D3D11_BIND_CONSTANT_BUFFER,D3D11_CPU_ACCESS_WRITE,_matrixproj,"Matrix Buffer")
	
	'create buffer for pixel shader flags
	_psflags = [1.0,1.0,1.0,1.0,1.0,0.0,0.0,0.0]
	CreateBuffer(_psfbuffer,32,D3D11_USAGE_DYNAMIC,D3D11_BIND_CONSTANT_BUFFER,D3D11_CPU_ACCESS_WRITE,_psflags,"Pixel Shader Flags Buffer")
	
	'create texture sampler states
	Local sd:D3D11_SAMPLER_DESC = New D3D11_SAMPLER_DESC
	sd.Filter = D3D11_FILTER_MIN_MAG_MIP_POINT
	sd.AddressU = D3D11_TEXTURE_ADDRESS_CLAMP
	sd.AddressV = D3D11_TEXTURE_ADDRESS_CLAMP
	sd.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP
	sd.MipLODBias = 0.0
	sd.MaxAnisotropy = 1
	sd.ComparisonFunc = D3D11_COMPARISON_GREATER_EQUAL
	sd.BorderColor0 = 0.0
	sd.BorderColor1 = 0.0
	sd.BorderColor2 = 0.0
	sd.BorderColor3 = 0.0
	sd.MinLOD = 0.0
	sd.MaxLOD = D3D11_FLOAT32_MAX

	If _d3d11dev.CreateSamplerState(sd,_pointsamplerstate)<0 Throw "Cannot create point sampler state~nExiting."
	
	sd.Filter = D3D11_FILTER_MIN_MAG_MIP_LINEAR
	
	If _d3d11dev.CreateSamplerState(sd,_linearsamplerstate)<0 Throw "Cannot create linear sampler state~nExiting." 
	
	_d3d11devcon.IASetInputLayout(_max2dlayout)
	_d3d11devcon.VSSetShader(_vertexshader,Null,0)
	_d3d11devcon.VSSetConstantBuffers(0,1,Varptr _projbuffer)
	_d3d11devcon.PSSetShader(_texturepixelshader,Null,0)
	_d3d11devcon.PSSetSamplers(0,1,Varptr _pointsamplerstate)
	_d3d11devcon.PSSetConstantBuffers(0,1,Varptr _psfbuffer)
		
		'pre-defined blend states
		Local _bd:D3D11_BLEND_DESC = New D3D11_BLEND_DESC
		
		'Solid blend
		_bd.IndependentBlendEnable = True
		_bd.RenderTarget0_BlendEnable = False
		_bd.RenderTarget0_SrcBlend = D3D11_BLEND_ONE
		_bd.RenderTarget0_DestBlend = D3D11_BLEND_ZERO
		_bd.RenderTarget0_BlendOp = D3D11_BLEND_OP_ADD
		_bd.RenderTarget0_SrcBlendAlpha = D3D11_BLEND_ONE
		_bd.RenderTarget0_DestBlendAlpha = D3D11_BLEND_ZERO
		_bd.RenderTarget0_BlendOpAlpha = D3D11_BLEND_OP_ADD
		_bd.RenderTarget0_RenderTargetWriteMask = D3D11_COLOR_WRITE_ENABLE_ALL
		_d3d11dev.CreateBlendState(_bd,_solidblend)
		
		'Mask blend
		_bd.RenderTarget0_BlendEnable = False
		_d3d11dev.CreateBlendState(_bd,_maskblend)
		
		'Alpha blend
		_bd.RenderTarget0_BlendEnable = True
		_bd.RenderTarget0_SrcBlend = D3D11_BLEND_SRC_ALPHA
		_bd.RenderTarget0_DestBlend = D3D11_BLEND_INV_SRC_ALPHA
		_d3d11dev.CreateBlendState(_bd,_alphablend)
		
		'Light blend
		_bd.RenderTarget0_BlendEnable = True
		_bd.RenderTarget0_SrcBlend = D3D11_BLEND_SRC_ALPHA
		_bd.RenderTarget0_DestBlend = D3D11_BLEND_ONE
		_d3d11dev.CreateBlendState(_bd,_lightblend)
		
		'Shade blend
		_bd.RenderTarget0_BlendEnable = True
		_bd.RenderTarget0_SrcBlend = D3D11_BLEND_ZERO
		_bd.RenderTarget0_DestBlend = D3D11_BLEND_SRC_COLOR
		_d3d11dev.CreateBlendState(_bd,_shadeblend)
		
		_currblend = SOLIDBLEND
		_currentrtv = _d3d11Graphics.GetRenderTarget()
		
		_shaderready = True
	End Function
	
	Function Free()
		If Not _shaderready Return
		SAFE_RELEASE(_psfbuffer)
		SAFE_RELEASE(_polyBuffer)
		SAFE_RELEASE(_pointbuffer)
		SAFE_RELEASE(_ovalbuffer)
		SAFE_RELEASE(_projbuffer)
		SAFE_RELEASE(_solidblend)
		SAFE_RELEASE(_maskblend)
		SAFE_RELEASE(_alphablend)
		SAFE_RELEASE(_lightblend)
		SAFE_RELEASE(_shadeblend)
		
		SAFE_RELEASE(_vertexshader) '
		SAFE_RELEASE(_texturepixelshader)
		SAFE_RELEASE(_colorpixelshader)
		SAFE_RELEASE(_max2dlayout) '
		SAFE_RELEASE(_vertexbuffer)
		SAFE_RELEASE(_pointsamplerstate)
		SAFE_RELEASE(_linearsamplerstate)
		
		If _ringbuffer _ringbuffer.Destroy
		_currentsrv = Null
		
		_shaderready = False
	End Function
		
	Function CreateBuffer(Buffer:ID3D11Buffer Var,ByteWidth,Usage,BindFlags,CPUAccessFlags,Data:Byte Ptr=Null,Name$="")
		Local SubResourceData:D3D11_SUBRESOURCE_DATA
		Local hr
	
		Local Desc:D3D11_BUFFER_DESC = New D3D11_BUFFER_DESC	
		Desc.ByteWidth = ByteWidth
		Desc.Usage = Usage
		Desc.BindFlags = BindFlags
		Desc.CPUAccessFlags = CPUAccessFlags
	
		If Data
			SubResourceData = New D3D11_SUBRESOURCE_DATA
			SubResourceData.pSysMem = Data
			
			hr =  _d3d11dev.CreateBuffer(Desc,SubResourceData,Buffer)
		Else
			hr = _d3d11dev.CreateBuffer(Desc,Null,Buffer)
		EndIf
		
		If hr<0
			WriteStdout "Cannot create buffer for : "+Name+"~n"
			Return -1
		Else
			Return True
		EndIf
	EndFunction
	
	Function MapBuffer(Buffer:ID3D11Buffer Var,SubresourceIndex,MapType,MapFlags,Data:Byte Ptr,Size,Name$="")
		If Not Buffer Return
	
		Local Map:D3D11_MAPPED_SUBRESOURCE = New D3D11_MAPPED_SUBRESOURCE
	
		If _d3d11devcon.Map(Buffer,SubresourceIndex,MapType,MapFlags,Map)<0
			Throw "Error! "+Name+"~nCannot map data for resources!~n"
		Else
			'For Local i = 0 Until Size
			'	Map.pData[i] = Data[i]
			'Next
			MemCopy Map.pData,Data,Size
			_d3d11devcon.UnMap(Buffer,SubresourceIndex)
		EndIf
		Return True
	EndFunction
	
	Function EnableAlphaTest()
		If _psflags[4] = 1.0 Return
		_psflags[4] = 1.0
		MapBuffer(_psfbuffer,0,D3D11_MAP_WRITE_DISCARD,0,_psflags,SizeOf(_psflags))
	EndFunction
	
	Function DisableAlphaTest()
		If _psflags[4] = 0.0 Return
		_psflags[4] = 0.0
		MapBuffer(_psfbuffer,0,D3D11_MAP_WRITE_DISCARD,0,_psflags,SizeOf(_psflags))
	EndFunction
EndType

Function D3D11Max2DDriver:TD3D11Max2DDriver()
	If D3D11GraphicsDriver()
		Global _driver:TD3D11Max2DDriver = New TD3D11Max2DDriver
		Return _driver
	EndIf
End Function

Local driver:TD3D11Max2DDriver = D3D11Max2DDriver()
If driver SetGraphicsDriver driver, GRAPHICS_BACKBUFFER

