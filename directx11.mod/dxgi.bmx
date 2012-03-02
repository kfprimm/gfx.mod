Strict

Import Pub.Win32
Import BRL.System

Const DXGI_CPU_ACCESS_NONE     = 0
Const DXGI_CPU_ACCESS_DYNAMIC     = 1
Const DXGI_CPU_ACCESS_READ_WRITE     = 2
Const DXGI_CPU_ACCESS_SCRATCH     = 3
Const DXGI_CPU_ACCESS_FIELD       = 15
Const DXGI_USAGE_SHADER_INPUT             :Long =  1 Shl ( 0 + 4 )
Const DXGI_USAGE_RENDER_TARGET_OUTPUT     :Long =  1 Shl ( 1 + 4 )
Const DXGI_USAGE_BACK_BUFFER              :Long =  1 Shl ( 2 + 4 )
Const DXGI_USAGE_SHARED                   :Long =  1 Shl ( 3 + 4 )
Const DXGI_USAGE_READ_ONLY                :Long =  1 Shl ( 4 + 4 )
Const DXGI_USAGE_DISCARD_ON_PRESENT       :Long =  1 Shl ( 5 + 4 )
Const DXGI_USAGE_UNORDERED_ACCESS         :Long =  1 Shl ( 6 + 4 )

Const DXGI_MWA_NO_WINDOW_CHANGES      = ( 1 Shl 0 )
Const DXGI_MWA_NO_ALT_ENTER           = ( 1 Shl 1 )
Const DXGI_MWA_NO_PRINT_SCREEN        = ( 1 Shl 2 )
Const DXGI_MWA_VALID                  = ( $7 )

Const DXGI_SWAP_EFFECT_DISCARD	= 0
Const DXGI_SWAP_EFFECT_SEQUENTIAL	= 1

Const DXGI_MODE_SCALING_UNSPECIFIED   = 0
Const DXGI_MODE_SCALING_CENTERED      = 1
Const DXGI_MODE_SCALING_STRETCHED     = 2

Const DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED         = 0
Const DXGI_MODE_SCANLINE_ORDER_PROGRESSIVE         = 1
Const DXGI_MODE_SCANLINE_ORDER_UPPER_FIELD_FIRST   = 2
Const DXGI_MODE_SCANLINE_ORDER_LOWER_FIELD_FIRST   = 3

'DXGI_FORMAT
Const DXGI_FORMAT_UNKNOWN	                    = 0
Const DXGI_FORMAT_R32G32B32A32_TYPELESS       = 1
Const DXGI_FORMAT_R32G32B32A32_FLOAT          = 2
Const DXGI_FORMAT_R32G32B32A32_UINT           = 3
Const DXGI_FORMAT_R32G32B32A32_SINT           = 4
Const DXGI_FORMAT_R32G32B32_TYPELESS          = 5
Const DXGI_FORMAT_R32G32B32_FLOAT             = 6
Const DXGI_FORMAT_R32G32B32_UINT              = 7
Const DXGI_FORMAT_R32G32B32_SINT              = 8
Const DXGI_FORMAT_R16G16B16A16_TYPELESS       = 9
Const DXGI_FORMAT_R16G16B16A16_FLOAT          = 10
Const DXGI_FORMAT_R16G16B16A16_UNORM          = 11
Const DXGI_FORMAT_R16G16B16A16_UINT           = 12
Const DXGI_FORMAT_R16G16B16A16_SNORM          = 13
Const DXGI_FORMAT_R16G16B16A16_SINT           = 14
Const DXGI_FORMAT_R32G32_TYPELESS             = 15
Const DXGI_FORMAT_R32G32_FLOAT                = 16
Const DXGI_FORMAT_R32G32_UINT                 = 17
Const DXGI_FORMAT_R32G32_SINT                 = 18
Const DXGI_FORMAT_R32G8X24_TYPELESS           = 19
Const DXGI_FORMAT_D32_FLOAT_S8X24_UINT        = 20
Const DXGI_FORMAT_R32_FLOAT_X8X24_TYPELESS    = 21
Const DXGI_FORMAT_X32_TYPELESS_G8X24_UINT     = 22
Const DXGI_FORMAT_R10G10B10A2_TYPELESS        = 23
Const DXGI_FORMAT_R10G10B10A2_UNORM           = 24
Const DXGI_FORMAT_R10G10B10A2_UINT            = 25
Const DXGI_FORMAT_R11G11B10_FLOAT             = 26
Const DXGI_FORMAT_R8G8B8A8_TYPELESS           = 27
Const DXGI_FORMAT_R8G8B8A8_UNORM              = 28
Const DXGI_FORMAT_R8G8B8A8_UNORM_SRGB         = 29
Const DXGI_FORMAT_R8G8B8A8_UINT               = 30
Const DXGI_FORMAT_R8G8B8A8_SNORM              = 31
Const DXGI_FORMAT_R8G8B8A8_SINT               = 32
Const DXGI_FORMAT_R16G16_TYPELESS             = 33
Const DXGI_FORMAT_R16G16_FLOAT                = 34
Const DXGI_FORMAT_R16G16_UNORM                = 35
Const DXGI_FORMAT_R16G16_UINT                 = 36
Const DXGI_FORMAT_R16G16_SNORM                = 37
Const DXGI_FORMAT_R16G16_SINT                 = 38
Const DXGI_FORMAT_R32_TYPELESS                = 39
Const DXGI_FORMAT_D32_FLOAT                   = 40
Const DXGI_FORMAT_R32_FLOAT                   = 41
Const DXGI_FORMAT_R32_UINT                    = 42
Const DXGI_FORMAT_R32_SINT                    = 43
Const DXGI_FORMAT_R24G8_TYPELESS              = 44
Const DXGI_FORMAT_D24_UNORM_S8_UINT           = 45
Const DXGI_FORMAT_R24_UNORM_X8_TYPELESS       = 46
Const DXGI_FORMAT_X24_TYPELESS_G8_UINT        = 47
Const DXGI_FORMAT_R8G8_TYPELESS               = 48
Const DXGI_FORMAT_R8G8_UNORM                  = 49
Const DXGI_FORMAT_R8G8_UINT                   = 50
Const DXGI_FORMAT_R8G8_SNORM                  = 51
Const DXGI_FORMAT_R8G8_SINT                   = 52
Const DXGI_FORMAT_R16_TYPELESS                = 53
Const DXGI_FORMAT_R16_FLOAT                   = 54
Const DXGI_FORMAT_D16_UNORM                   = 55
Const DXGI_FORMAT_R16_UNORM                   = 56
Const DXGI_FORMAT_R16_UINT                    = 57
Const DXGI_FORMAT_R16_SNORM                   = 58
Const DXGI_FORMAT_R16_SINT                    = 59
Const DXGI_FORMAT_R8_TYPELESS                 = 60
Const DXGI_FORMAT_R8_UNORM                    = 61
Const DXGI_FORMAT_R8_UINT                     = 62
Const DXGI_FORMAT_R8_SNORM                    = 63
Const DXGI_FORMAT_R8_SINT                     = 64
Const DXGI_FORMAT_A8_UNORM                    = 65
Const DXGI_FORMAT_R1_UNORM                    = 66
Const DXGI_FORMAT_R9G9B9E5_SHAREDEXP          = 67
Const DXGI_FORMAT_R8G8_B8G8_UNORM             = 68
Const DXGI_FORMAT_G8R8_G8B8_UNORM             = 69
Const DXGI_FORMAT_BC1_TYPELESS                = 70
Const DXGI_FORMAT_BC1_UNORM                   = 71
Const DXGI_FORMAT_BC1_UNORM_SRGB              = 72
Const DXGI_FORMAT_BC2_TYPELESS                = 73
Const DXGI_FORMAT_BC2_UNORM                   = 74
Const DXGI_FORMAT_BC2_UNORM_SRGB              = 75
Const DXGI_FORMAT_BC3_TYPELESS                = 76
Const DXGI_FORMAT_BC3_UNORM                   = 77
Const DXGI_FORMAT_BC3_UNORM_SRGB              = 78
Const DXGI_FORMAT_BC4_TYPELESS                = 79
Const DXGI_FORMAT_BC4_UNORM                   = 80
Const DXGI_FORMAT_BC4_SNORM                   = 81
Const DXGI_FORMAT_BC5_TYPELESS                = 82
Const DXGI_FORMAT_BC5_UNORM                   = 83
Const DXGI_FORMAT_BC5_SNORM                   = 84
Const DXGI_FORMAT_B5G6R5_UNORM                = 85
Const DXGI_FORMAT_B5G5R5A1_UNORM              = 86
Const DXGI_FORMAT_B8G8R8A8_UNORM              = 87
Const DXGI_FORMAT_B8G8R8X8_UNORM              = 88
Const DXGI_FORMAT_R10G10B10_XR_BIAS_A2_UNORM  = 89
Const DXGI_FORMAT_B8G8R8A8_TYPELESS           = 90
Const DXGI_FORMAT_B8G8R8A8_UNORM_SRGB         = 91
Const DXGI_FORMAT_B8G8R8X8_TYPELESS           = 92
Const DXGI_FORMAT_B8G8R8X8_UNORM_SRGB         = 93
Const DXGI_FORMAT_BC6H_TYPELESS               = 94
Const DXGI_FORMAT_BC6H_UF16                   = 95
Const DXGI_FORMAT_BC6H_SF16                   = 96
Const DXGI_FORMAT_BC7_TYPELESS                = 97
Const DXGI_FORMAT_BC7_UNORM                   = 98
Const DXGI_FORMAT_BC7_UNORM_SRGB              = 99
Const DXGI_FORMAT_FORCE_UINT                  = $ffffffff

Const DXGI_SWAP_CHAIN_FLAG_NONPREROTATED       = 1
Const DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH   = 2
Const DXGI_SWAP_CHAIN_FLAG_GDI_COMPATIBLE      = 4

Const DXGI_MAX_SWAP_CHAIN_BUFFERS     = 16
Const DXGI_PRESENT_TEST               = $00000001
Const DXGI_PRESENT_DO_NOT_SEQUENCE    = $00000002
Const DXGI_PRESENT_RESTART            = $00000004

Const DXGI_ENUM_MODES_INTERLACED = 1
Const DXGI_ENUM_MODES_SCALING = 2

Type DXGI_MODE_DESC
	Field Width
	Field Height
  	Field RefreshRate_Numerator
	Field RefreshRate_Denominator
	Field Format
	Field ScanlineOrdering
	Field Scaling
EndType

Type DXGI_FRAME_STATISTICS
	Field PresentCount
	Field PresentRefreshCount
	Field SyncRefreshCount
	Field SyncQPCTime:Long
	Field SyncGPUTime:Long
EndType

Type DXGI_ADAPTER_DESC
	Field Desc0:Short,Desc1,Desc2,Desc3,Desc4,Desc5,Desc6,Desc7,Desc8,Desc9
	Field Desc10,Desc11,Desc12,Desc13,Desc14,Desc15,Desc16,Desc17,Desc18,Desc19
	Field Desc20,Desc21,Desc22,Desc23,Desc24,Desc25,Desc26,Desc27,Desc28,Desc29
	Field Desc30,Desc31,Desc32,Desc33,Desc34,Desc35,Desc36,Desc37,Desc38,Desc39
	Field Desc40,Desc41,Desc42,Desc43,Desc44,Desc45,Desc46,Desc47,Desc48,Desc49
	Field Desc50,Desc51,Desc52,Desc53,Desc54,Desc55,Desc56,Desc57,Desc58,Desc59
	Field Desc60,Desc61,Desc62,Desc63

	Field VendorID
	Field DeviceID
	Field SubSysID
	Field Revision
	Field DedicatedVideoMemory
	Field DedicatedSystemMemory
	Field SharedSystemMemory
	Field AdapterLuidLow
	Field AdapterLuidHigh:Long
	
	Method Description$()
		Return String.FromWString(Varptr Desc0)
	EndMethod
EndType

Type DXGI_OUTPUT_DESC
EndType

Type DXGI_SHARED_RESOURCE
EndType

Type DXGI_RESIDENCY
EndType

Type DXGI_SURFACE_DESC
EndType

Type DXGI_SWAP_EFFECT
EndType

Type DXGI_SWAP_CHAIN_FLAG
EndType

Type DXGI_SWAP_CHAIN_DESC
	Field BufferDesc_Width
	Field BufferDesc_Height
	Field BufferDesc_RefreshRate_Numerator
	Field BufferDesc_RefreshRate_Denominator
	Field BufferDesc_Format
	Field BufferDesc_ScanlineOrdering
	Field BufferDesc_Scaling
	Field SampleDesc_Count
	Field SampleDesc_Quality
	Field BufferUsage
	Field BufferCount
	Field OutputWindow
	Field Windowed
	Field SwapEffect
	Field Flags
EndType

Extern"win32"

Type IDXGIObject Extends IUnknown
	Method SetPrivateData(Name:Byte Ptr,DataSize,pData:Byte Ptr)
	Method SetPrivateDataInterface(Name:Byte Ptr,pUnknown:Byte Ptr)
	Method GetPrivateData(Name:Byte Ptr,pDataSize:Int Var,pData:Byte Ptr)
	Method GetParent(riid:Byte Ptr,ppParent:IUnknown var)
EndType

Type IDXGIDeviceSubObject Extends IDXGIObject
	Method GetDevice()
EndType

Type IDXGIResource Extends IDXGIDeviceSubObject
	Method GetSharedHandle()
	Method GetUsage()
	Method SetEvictionPriority()
	Method GetEvictionPriority()
EndType

Type IDXGIKeyedMutex Extends IDXGIDeviceSubObject
	Method AcquireSync()
	Method ReleaseSync()
EndType

Type IDXGISurface Extends IDXGIDeviceSubObject
	Method GetDesc()
	Method Map()
	Method UnMap()
EndType

Type IDXGISurface1 Extends IDXGISurface
	Method GetDC()
	Method ReleaseDC()
EndType

Type IDXGIAdapter Extends IDXGIObject
	Method EnumOutputs(Output,ppOutput:IDXGIOutput Var)
	Method GetDesc(pDesc:Byte Ptr)
	Method CheckInterfaceSupport(InterfaceName:Byte Ptr,pUMDVersion:Byte Ptr)
EndType

Type IDXGIOutput Extends IDXGIObject
	Method GetDesc(pDesc:Byte Ptr)
	Method GetDisplayModeList(EnumFormat,Flags,pNumModes:Int Var,pDesc:Byte Ptr)
	Method FindClosestMatchMode(pModeToMatch:Byte Ptr,pClosestMatch:Byte Ptr,pConcernedDevice:Byte Ptr)
	Method WaitForVBlank()
	Method TakeOwnership(pDevice:Byte Ptr,Exclusive)
	Method ReleaseOwnership()
	Method GetGammaControlCapabilities(pGammaCaps:Byte Ptr)
	Method SetGammaControl(pArray:Byte Ptr)
	Method GetGammaControl(pArray:Byte Ptr)
	Method SetDisplaySurface(pScanoutSurface:Byte Ptr)
	Method GetDisplaySurfaceData(pDestination:Byte Ptr)
	Method GetFrameStatistics(pStats:Byte Ptr)
EndType

Type IDXGISwapChain Extends IDXGIDeviceSubObject
	Method Present(SyncInterval,Flags)
	Method GetBuffer(Buffer,riid:Byte Ptr,ppSurface:IUnknown Var)
	Method SetFullscreenState(FullScreen,pTarget:Byte Ptr)
	Method GetFullscreenState(pFullScreen Var,ppTarget:IDXGIOutput Var)
	Method GetDesc(pDesc:Byte Ptr)
	Method ResizeBuffers(BufferCount,Width,Hieght,NewFormat,SwapChainFlags)
	Method ResizeTarget(pNewTargetParameters:Byte Ptr)
	Method GetContainingOutput(ppOutput:IDXGIOutput Var)
	Method GetFrameStatistics(pStats:Byte Ptr)
	Method GetLastPresentCount(pLastPresentCount:Int Var)
EndType

Type IDXGIFactory Extends IDXGIObject
	Method EnumAdapters(Adapter,ppAdapter:IDXGIAdapter Var)
	Method MakeWindowAssociation(WindowHandle,Flags)
	Method GetWindowAssociation(pWindowHandle:Int Var)
	Method CreateSwapChain(pDevice:Byte Ptr,pDesc:Byte Ptr,ppSwapChain:IDXGISwapChain Var)
	Method CreateSoftwareAdapter(Module_,ppAdapter:IDXGIAdapter Var)
EndType

Type IDXGIDevice Extends IDXGIObject
	Method GetAdapter()
	Method CreateSurface()
	Method QueryResourceResidency()
	Method SetGPUThreadPriority()
	Method GetGPUThreadPriority()
EndType

Type IDXGIFactory1 Extends IDXGIFactory
	Method EnumAdapters1()
	Method IsCurrent()
EndType

Type IDXGIAdapter1 Extends IDXGIAdapter
	Method GetDesc1()
EndType

Type IDXGIDevice1 Extends IDXGIDevice
	Method SetMaximumFrameLatency()
	Method GetMaximumFrameLatency()
EndType

EndExtern

Global _DXGI = LoadLibraryA("dxgi.dll")

If Not _DXGI Return

'DEFINE_GUID(IID_IDXGIFactory,0x7b7166ec,0x21c7,0x44ae,0xb2,0x1a,0xc9,0xae,0x32,0x1a,0xe3,0x69);
'DEFINE_GUID(IID_IDXGIAdapter,0x2411e7e1,0x12ac,0x4ccf,0xbd,0x14,0x97,0x98,0xe8,0x53,0x4d,0xc0);
'DEFINE_GUID(IID_IDXGIDevice,0x54ec77fa,0x1377,0x44e6,0x8c,0x32,0x88,0xfd,0x5f,0x44,0xc8,0x4c);

Global IID_IDXGIFactory[]=[$7b7166ec,$44ae21c7,$aec91ab2,$69e31a32]
Global IID_IDXGIAdapter[]=[$2411e7e1,$4ccf12ac,$989714bd,$c04d53e8]
Global IID_IDXGIDevice[]= [$54ec77fa,$44e61377,$fd88328c,$4cc8445f]

Global CreateDXGIFactory(riid:Byte Ptr,ppFactory:IDXGIFactory Var)"win32" = GetProcAddress(_DXGI,"CreateDXGIFactory")
