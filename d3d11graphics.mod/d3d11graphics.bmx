Strict

Module GFX.D3D11Graphics

ModuleInfo "Version: V1.0"
ModuleInfo "Author: Dave Camp"
ModuleInfo "License: SRS Shared Source Code License"
ModuleInfo "Copyright: SRS Software"
ModuleInfo ""
ModuleInfo "BUGFIXES:"
ModuleInfo "Fixed render lag for window and fullscreen"
ModuleInfo "Fixed crash when exiting from fullscreen then using another DX driver"
 
Import BRL.Graphics
Import BRL.LinkedList
Import BRL.Retro
Import GFX.DirectXEx

?Win32
Private
'Lag fix
Global _DwmapiDLL = LoadLibraryA("dwmapi.dll")

Global _FlushGPU()
If _DwmapiDLL _FlushGPU = GetProcAddress(_DwmapiDLL,"DwmFlush")
'end of lagfix

Global _graphics:TD3D11Graphics
Global _driver:TD3D11GraphicsDriver
Global _wndclass$ = "BBDX11Device Window Class"

Global _displaymodes:DXGI_MODE_DESC[]
Global _modes:TGraphicsMode[]
Global _d3d11dev:ID3D11Device
Global _d3d11devcon:ID3D11DeviceContext
Global _fullscreentarget:DXGI_MODE_DESC
Global _query:ID3D11Query
Global _release:TList
Global _windowed
Global _fps
Global _d3d11Refs

Type TD3D11Release
	Field unk:IUnknown
EndType

Function D3D11WndProc( hwnd,MSG,wp,lp )"win32"

	bbSystemEmitOSEvent hwnd,MSG,wp,lp,Null
	
	Select MSG
		Case WM_CLOSE
			Return
		Case WM_SYSKEYDOWN
			If wp<>KEY_F4 Return
		Case WM_SIZE	
			'Local w = lp & $ffff
			'Local h = lp Shr 16
			'WriteStdout w+","+h+"~n"
			'If _swapchain
			'EndIf
	EndSelect
	Return DefWindowProcW( hwnd,MSG,wp,lp )
End Function

Function CreateD3D11Device()
	If _d3d11Refs
		_d3d11Refs:+1
		Return True
	EndIf
		
	Local FeatureLevels[1]' = [D3D_FEATURE_LEVEL_11_0] 
	
	Local CreationFlag = D3D11_CREATE_DEVICE_SINGLETHREADED
	'?DEBUG
	'	CreationFlag :| D3D11_CREATE_DEVICE_DEBUG
	'?
	If D3D11CreateDevice(Null,D3D_DRIVER_TYPE_HARDWARE,Null,CreationFlag,Null,0,D3D11_SDK_VERSION,_d3d11dev,FeatureLevels,_d3d11devcon)<0
		Notify "Critical Error!~nCannot create D3D11Device~nExiting.",True
		End
	EndIf
	
	If FeatureLevels[0] < D3D_FEATURE_LEVEL_10_0
		Notify 	"Critical Error!~n"+..
					"Make sure your GPU is Dx10/Dx11 compatible or~n"+..
					"Make sure you have the latest drivers for your GPU.",True
		End
	EndIf
	
	'QUERY
	Local _querydesc:D3D11_QUERY_DESC = New D3D11_QUERY_DESC
	_querydesc.Query = D3D11_QUERY_EVENT
	
	If _d3d11dev.CreateQuery(_querydesc,_query)<0
		Notify "Critical Error!~nCannot create device query!~nExiting.",True
		End
	EndIf
	_d3d11devcon.Begin _query
	
	If Not _release _release = New TList
	
	_d3d11Refs:+1
	Return True
EndFunction

Function CloseD3D11Device()
	_d3d11Refs:-1
	
	If _d3d11Refs Return
	
	For Local ar:TD3D11Release = EachIn _release
		If ar.unk ar.unk.Release_
	Next
	_release.Clear
	_release = Null

	If _query _query.Release_
	
	If _d3d11devcon _d3d11devcon.ClearState
	
	If _d3d11devcon _d3d11devcon.Release_
	If _d3d11dev _d3d11dev.Release_
	
	_query = Null
	_d3d11devcon = Null
	_d3d11dev = Null
EndFunction

Public

Type TD3D11Graphics Extends TGraphics
	Field _width
	Field _height
	Field _depth
	Field _hertz
	Field _flags
	Field _hwnd
	Field _attached
	Field _swapchain:IDXGISwapChain
	Field _sd:DXGI_SWAP_CHAIN_DESC
	Field _target:DXGI_MODE_DESC
	Field _rendertargetview:ID3D11RenderTargetView

	Method GetDirect3DDevice:ID3D11Device()
		Return _d3d11dev
	EndMethod
	
	Method GetDirect3DDeviceContext:ID3D11DeviceContext()
		Return _d3d11devcon
	EndMethod
	
	'TGraphics
	Method Driver:TD3D11GraphicsDriver()
		Return _driver
	EndMethod
	
	'TGraphics
	Method GetSettings( width Var,height Var,depth Var,hertz Var,flags Var)
		width = _width
		height = _height
		depth = _depth
		hertz = _hertz
		flags = _flags
	EndMethod
	
	'TGraphics
	Method Close()
		If Not _hwnd Return
	
		If _swapchain _swapchain.SetFullScreenState False,Null
		
		If _rendertargetview _rendertargetview.Release_
		If _swapchain _swapchain.Release_

		CloseD3D11Device
		
		If Not _attached DestroyWindow(_hwnd)
		_hwnd = Null
		
		_windowed = False
	EndMethod
	
	Method Attach:TD3D11Graphics( hwnd ,flags )
		Local rect[4]
		GetClientRect hwnd,rect
		Local width=rect[2]-rect[0]
		Local height=rect[3]-rect[1]
		
		CreateD3D11Device()
		CreateSwapChain(hwnd,width,height,0,0,flags)

		_hwnd=hwnd
		_width=width
		_height=height
		_flags=flags
		_attached=True
		
		Return Self
	EndMethod
	
	Method Create:TD3D11Graphics(width,height,depth,hertz,flags)
		
		If _windowed Return Null 'Already have a window thats full screen
		
		'register wndclass
		Local WNDCLASS:WNDCLASSW=New WNDCLASSW
		WNDCLASS.hInstance=GetModuleHandleW( Null )
		WNDCLASS.lpfnWndProc=D3D11WndProc
		WNDCLASS.hCursor=LoadCursorW( Null,Short Ptr IDC_ARROW )
		WNDCLASS.lpszClassName=_wndClass.ToWString()
		RegisterClassW WNDCLASS
		MemFree WNDCLASS.lpszClassName

		'Create the window
		Local wstyle = WS_VISIBLE|WS_POPUP
				
		'centre window on screen
		Local rect[4]
		If Not depth
			wstyle = WS_VISIBLE|WS_CAPTION|WS_SYSMENU|WS_MINIMIZEBOX

			Local desktoprect[4]
			
			GetWindowRect( GetDesktopWindow() , desktoprect )
			
			rect[0]=desktopRect[2]/2-width/2		
			rect[1]=desktopRect[3]/2-height/2
			rect[2]=rect[0]+width
			rect[3]=rect[1]+height
			
			AdjustWindowRect rect,wstyle,0
			
			_windowed = True
		Else
			rect[2] = width
			rect[3] = height
			
			_windowed = False
		EndIf
		
		Local hwnd=CreateWindowExW( 0,_wndClass,AppTitle,wstyle,rect[0],rect[1],rect[2]-rect[0],rect[3]-rect[1],0,0,GetModuleHandleW(Null),Null )
		If Not hwnd Return Null

		If Not CreateD3D11Device()
			DestroyWindow hwnd
			Return Null
		EndIf

		If Not depth
			GetClientRect hwnd,rect
			width=rect[2]-rect[0]
			height=rect[3]-rect[1]
		EndIf
		
		If Not _depth
			CreateSwapChain(hwnd,width,height,depth,hertz,flags)
		EndIf
		
		_hwnd=hwnd
		_width=width
		_height=height
		_depth=depth
		_hertz=hertz
		_flags=flags

		Return Self
	EndMethod
	
	Method CreateSwapChain(hwnd,width,height,depth,hertz,flags)
		Local modes:DXGI_MODE_DESC[] = _Displaymodes
	
		Local numerator = 0
		Local denominator = 1

		If depth
			For Local i = 0 Until modes.length
				If width = modes[i].Width
					If height = modes[i].Height
						numerator = modes[i].RefreshRate_Numerator
						denominator = modes[i].RefreshRate_Denominator
						_fullscreentarget = modes[i]
					EndIf
				EndIf
			Next
		EndIf

		_sd = New DXGI_SWAP_CHAIN_DESC
		_sd.BufferCount = 1+(depth>0)	'MSDN conflicting information on this parameter
		_sd.BufferDesc_Width = width
		_sd.BufferDesc_Height = height
		_sd.BufferDesc_Format = DXGI_FORMAT_R8G8B8A8_UNORM
		_sd.BufferDesc_RefreshRate_Numerator = numerator
		_sd.BufferDesc_RefreshRate_Denominator = denominator
		_sd.BufferDesc_Scaling = 0
		_sd.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT
		_sd.OutputWindow = hwnd
		_sd.SwapEffect = DXGI_SWAP_EFFECT_DISCARD
		_sd.Flags = DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH
		_sd.SampleDesc_Count = 1
		_sd.SampleDesc_Quality = 0

		If Not depth _sd.Windowed = True
	
		Local Factory:IDXGIFactory
		Local Adapter:IDXGIAdapter
		Local Device:IDXGIDevice
	
		_d3d11dev.QueryInterface(IID_IDXGIDevice,Byte Ptr Ptr(Varptr Device))
		Device.GetParent(IID_IDXGIAdapter,Adapter)
		Adapter.GetParent(IID_IDXGIFactory,Factory)
	
		If Factory.CreateSwapChain(_d3d11dev,_sd,_swapchain)<0
			Notify "Critical Error!~nCannot create swap chain~nExiting",True
			End
		EndIf

		Factory.MakeWindowAssociation(hwnd,DXGI_MWA_NO_WINDOW_CHANGES)
		Device.Release_
		Adapter.Release_
		Factory.Release_

		'Create a rendertarget
		Local pBackBuffer:ID3D11Texture2D
		If _swapchain.GetBuffer(0,IID_ID3D11Texture2D,pBackBuffer)<0
			Notify "Critical Error!~nCannot create backbuffer~nExiting."
			End
		EndIf
	
		If _d3d11dev.CreateRenderTargetView(pBackBuffer,Null,_rendertargetview)<0
			Notify "Critical Error!~nCannot create RenderTargetView for rendering~n",True
			End
		EndIf

		If pBackBuffer pBackBuffer.Release_()
		pBackBuffer = Null

		_d3d11devcon.OMSetRenderTargets(1,Varptr _rendertargetview,Null)

		'Create a viewport
		Local vp:D3D11_VIEWPORT = New D3D11_VIEWPORT
		vp.Width = width
		vp.Height = height
		vp.MinDepth = 0.0
		vp.MaxDepth = 1.0
		vp.TopLeftX = 0.0
		vp.TopLeftY = 0.0
		_d3d11devcon.RSSetViewports(1,vp)
	EndMethod
	
	Method Flip( sync )
		_swapchain.Present(sync = True,0)
	EndMethod
	
	Method GetRenderTarget:ID3D11RenderTargetView()
		Return _renderTargetView
	EndMethod

	Method AddRelease(unk:IUnknown)
		Local ar:TD3D11Release = New TD3D11Release
		ar.unk = unk
		_release.AddLast ar
	EndMethod
EndType

Type TD3D11GraphicsDriver Extends TGraphicsDriver
	Method Create:TD3D11GraphicsDriver()
		Local _Factory:IDXGIFactory
		Local _Adapter:IDXGIAdapter
		Local _Output:IDXGIOutput

		If Not _d3d11 Return Null
	
		If CreateDXGIFactory(IID_IDXGIFactory,_Factory)<0 Throw "Error creating IDXGIFactory!~nExiting."

		'TODO: Multiple GPUs?
		If _Factory.EnumAdapters(0,_Adapter)<0 Throw "Error enumerating GPUs!~nExiting."

		'TODO: Each GPU may have multiple outputs?
		If _Adapter.EnumOutputs(0,_Output)<0 Throw "Error enumeration graphics modes!~nExiting"
		
		Local nummodes
		If _Output.GetDisplaymodeList(DXGI_FORMAT_R8G8B8A8_UNORM,DXGI_ENUM_MODES_INTERLACED,nummodes,Null)<0
			Throw "Error getting number of graphics modes!~nExiting."
		EndIf
		_Displaymodes = _Displaymodes[..nummodes]

		Local modesptr:Byte Ptr=MemAlloc(SizeOf(DXGI_MODE_DESC)*nummodes)
		
		If _Output.GetDisplaymodeList(DXGI_FORMAT_R8G8B8A8_UNORM,DXGI_ENUM_MODES_INTERLACED,nummodes,modesptr)<0
			Throw "Error filling display modes data!~nExiting."
		EndIf
		
		_modes=New TGraphicsMode[nummodes]
		For Local i = 0 Until nummodes
			_Displaymodes[i] = New DXGI_MODE_DESC
			MemCopy _Displaymodes[i],modesptr+(SizeOf( DXGI_MODE_DESC) * i),SizeOf(DXGI_MODE_DESC)
			
			_modes[i] = New TGraphicsMode
			Local dm:TGraphicsMode[] = _modes

			_modes[i].width = _Displaymodes[i].Width
			_modes[i].Height = _Displaymodes[i].Height
			_modes[i].Hertz = _Displaymodes[i].RefreshRate_Numerator/_Displaymodes[i].RefreshRate_Denominator
			_modes[i].depth = 32
		Next
		
		MemFree modesptr

		If _Output _Output.Release_
		If _Adapter _Adapter.Release_
		If _Factory _Factory.Release_

		Return Self
	EndMethod
	
	'TGraphicsDriver
	Method GraphicsModes:TGraphicsMode[]()
		Return _modes
	EndMethod
	
	Method AttachGraphics:TD3D11Graphics( hwnd , flags )
		Return New TD3D11Graphics.Attach( hwnd , flags )
	EndMethod
	
	Method CreateGraphics:TD3D11Graphics( width,height,depth,hertz,flags )
		Return New TD3D11Graphics.Create(width,height,depth,hertz,flags)
	EndMethod
	
	Method SetGraphics( g:TGraphics )
		_graphics = TD3D11Graphics( g )
		
		If _graphics
			Local vp:D3D11_VIEWPORT = New D3D11_VIEWPORT
			vp.Width = _graphics._width
			vp.Height = _graphics._height
			vp.MinDepth = 0.0
			vp.MaxDepth = 1.0
			vp.TopLeftX = 0.0
			vp.TopLeftY = 0.0
			_d3d11devcon.RSSetViewports(1,vp)

			_d3d11devcon.OMSetRenderTargets(1,Varptr _graphics._rendertargetview,Null)
		EndIf
	EndMethod
	
	Method Flip( sync )
		_graphics.Flip( sync )
		
		'Render lag fix
		If _windowed
			If _DwmapiDLL _FlushGPU
		Else
			_d3d11devcon.End_(_query)
			Local queryData:Int
			While _d3d11devcon.GetData(_query,Varptr queryData,SizeOf(queryData),0)<>0
			Wend
		EndIf
	EndMethod
EndType

Function D3D11GraphicsDriver:TD3D11GraphicsDriver()
	Global _doneD3D11
	If Not _doneD3D11
		_driver = New TD3D11GraphicsDriver.Create()
		_doneD3D11 = True
	EndIf
	Return _driver
EndFunction


'EXPERIMENTAL...............
Function D3D11ShowAllSupportedFeatures(InFormat=0)
	Function YesNo$(value)
		If value Return "Yes"
		Return "No"
	EndFunction
	
	Function CheckThreading()
		Local pThreading:D3D11_FEATURE_DATA_THREADING = New D3D11_FEATURE_DATA_THREADING
		
		If _d3d11dev.CheckFeatureSupport(D3D11_FEATURE_THREADING,pThreading,8)<0
			Notify "WARNING:-~n_d3d11dev.CheckFeatureSupport - D3D11_FEATURE_THREADING : FAILED~nExiting",True
			End
		EndIf
		
		WriteStdout "~nMultiThreading:-~n"
		WriteStdout "   DriverConcurrentCreates - "+YesNo(pThreading.DriverConcurrentCreates)+"~n"
		WriteStdout "   DriverCommandLists - "+YesNo(pThreading.DriverCommandLists)+"~n~n"
	EndFunction

	Function CheckDataDoubles()
		Local pDoubles:D3D11_FEATURE_DATA_DOUBLES = New D3D11_FEATURE_DATA_DOUBLES
		
		If _d3d11dev.CheckFeatureSupport(D3D11_FEATURE_DOUBLES,pDoubles,4)<0
			Notify "WARNING:-~n_d3d11dev.CheckFeatureSupport - D3D11_FEATURE_DOUBLES : FAILED~nExiting",True
			End
		EndIf

		WriteStdout "DataDoubles:-~n"
		WriteStdout "   DoublePrecisionFloatShaderOps - "+YesNo(pDoubles.DoublePrecisionFloatShaderOps)+"~n~n"
	EndFunction
	
	Function CheckD3D10XHardwareOptions()
		Local pD3D10XOptions:D3D11_FEATURE_DATA_D3D10_X_HARDWARE_OPTIONS = New D3D11_FEATURE_DATA_D3D10_X_HARDWARE_OPTIONS
		
		If _d3d11dev.CheckFeatureSupport(D3D11_FEATURE_D3D10_X_HARDWARE_OPTIONS,pD3D10XOptions,4)<0
			Notify "WARNING:-~n_d3d11dev.CheckFeatureSupport - D3D10_HARDWARE_OPTIONS : FAILED~nExiting",True
			End
		EndIf
		
		WriteStdout "D3D10XHardwareOptions:-~n"
		WriteStdout "   ComputeShaders_Plus_RawAndStructuredBuffers_Via_Shader_4_x - "+YesNo(pD3D10XOptions.ComputeShaders_Plus_RawAndStructuredBuffers_Via_Shader_4_x)+"~n~n"
	EndFunction
	
	Function CheckDataFormat(InFormat)
		Local pFormatSupport:D3D11_FEATURE_DATA_FORMAT_SUPPORT = New D3D11_FEATURE_DATA_FORMAT_SUPPORT

		pFormatSupport.InFormat = InFormat
		_d3d11dev.CheckFeatureSupport(D3D11_FEATURE_FORMAT_SUPPORT,pFormatSupport,8)
		
		WriteStdout "DataFormat:-~n"
		WriteStdout EnumSupportFormat(pFormatSupport.OutFormatSupport)

		_d3d11dev.CheckFeatureSupport(D3D11_FEATURE_FORMAT_SUPPORT2,pFormatSupport,8)
		
		WriteStdout "DataFormat2:-~n"
		WriteStdout EnumSupportFormat(pFormatSupport.OutFormatSupport)
	EndFunction
	
	Function EnumSupportFormat$(Value)
		Local Result$
		
		If Value & $1 Result =  "   D3D11_FORMAT_SUPPORT_BUFFER~n"
		If Value & $2 Result :+ "   D3D11_FORMAT_SUPPORT_IA_VERTEX_BUFFER~n"
		If Value & $4 Result :+ "   D3D11_FORMAT_SUPPORT_IA_INDEX_BUFFER~n"
		If Value & $8 Result :+ "   D3D11_FORMAT_SUPPORT_SO_BUFFER~n"
		If Value & $10 Result :+ "   D3D11_FORMAT_SUPPORT_TEXTURE1D~n"
		If Value & $20 Result :+ "   D3D11_FORMAT_SUPPORT_TEXTURE2D~n"
		If Value & $40 Result :+ "   D3D11_FORMAT_SUPPORT_TEXTURE3D~n"
		If Value & $80 Result :+ "   D3D11_FORMAT_SUPPORT_TEXTURECUBE~n"
		If Value & $100 Result :+ "   D3D11_FORMAT_SUPPORT_SHADER_LOAD~n"
		If Value & $200 Result :+ "   D3D11_FORMAT_SUPPORT_SHADER_SAMPLE~n"
		If Value & $400 Result :+ "   D3D11_FORMAT_SUPPORT_SHADER_SAMPLE_COMPARISON~n"
		If Value & $800 Result :+ "   D3D11_FORMAT_SUPPORT_SHADER_SAMPLE_MONO_EXIT~n"
		If Value & $1000 Result :+ "   D3D11_FORMAT_SUPPORT_MIP~n"
		If Value & $2000 Result :+ "   D3D11_FORMAT_SUPPORT_MIP_AUTOGEN~n"
		If Value & $4000 Result :+ "   D3D11_FORMAT_SUPPORT_RENDER_TARGET~n"
		If Value & $8000 Result :+ "   D3D11_FORMAT_SUPPORT_BLENDABLE~n"
		If Value & $10000 Result :+ "   D3D11_FORMAT_SUPPORT_DEPTH_STENCIL~n"
		If Value & $20000 Result :+ "   D3D11_FORMAT_SUPPORT_CPU_LOCKABLE~n"
		If Value & $40000 Result :+ "   D3D11_FORMAT_SUPPORT_MULITSAMPLE_RESOLVE~n"
		If Value & $80000 Result :+ "   D3D11_FORMAT_SUPPORT_DISPLAY~n"
		If Value & $100000 Result :+ "   D3D11_FORMAT_SUPPORT_CAST_WITHIN_BIT_LAYOUT~n"
		If Value & $200000 Result :+ "   D3D11_FORMAT_SUPPORT_MULTISAMPLE_RENDERTARGET~n"
		If Value & $400000 Result :+ "   D3D11_FORMAT_SUPPORT_MULTISAMPLE_LOAD~n"
		If Value & $800000 Result :+ "   D3D11_FORMAT_SUPPORT_SHADER_GATHER~n"
		If Value & $1000000 Result :+ "   D3D11_FORMAT_SUPPORT_BACK_BUFFER_CAST~n"
		If Value & $2000000 Result :+ "   D3D11_FORMAT_SUPPORT_TYPED_UNORDERED_ACCESS_VIEW~n"
		If Value & $4000000 Result :+ "   D3D11_FORMAT_SUPPORT_SHADER_GATHER_COMPARISON~n"
		
		If Result = "" Result = "   None"
		
		Return Result
	EndFunction
	
	If Not _d3d11dev
		Notify "D3D11Device isnt ready!~nExiting"
		End
	EndIf

	CheckThreading
	CheckDataDoubles
	CheckD3D10XHardwareOptions
	If InFormat CheckDataFormat(InFormat)
EndFunction
?
