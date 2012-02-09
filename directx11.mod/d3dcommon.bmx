Strict

Import Pub.Win32

Const D3D_DRIVER_TYPE_UNKNOWN = 0
Const D3D_DRIVER_TYPE_HARDWARE = 1
Const D3D_DRIVER_TYPE_REFERENCE = 2
Const D3D_DRIVER_TYPE_NULL = 3
Const D3D_DRIVER_TYPE_SOFTWARE = 4
Const D3D_DRIVER_TYPE_WARP = 5

Const D3D_FEATURE_LEVEL_9_1	= $9100
Const D3D_FEATURE_LEVEL_9_2	= $9200
Const D3D_FEATURE_LEVEL_9_3	= $9300
Const D3D_FEATURE_LEVEL_10_0	= $a000
Const D3D_FEATURE_LEVEL_10_1	= $a100
Const D3D_FEATURE_LEVEL_11_0	= $b000

Const D3D_PRIMITIVE_TOPOLOGY_UNDEFINED           = 0
Const D3D_PRIMITIVE_TOPOLOGY_POINTLIST           = 1
Const D3D_PRIMITIVE_TOPOLOGY_LINELIST            = 2
Const D3D_PRIMITIVE_TOPOLOGY_LINESTRIP           = 3
Const D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST        = 4
Const D3D_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP       = 5
Const D3D_PRIMITIVE_TOPOLOGY_LINELIST_ADJ        = 10
Const D3D_PRIMITIVE_TOPOLOGY_LINESTRIP_ADJ       = 11
Const D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST_ADJ    = 12
Const D3D_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP_ADJ   = 13 
Const D3D_PRIMITIVE_TOPOLOGY_1_CONTROL_POINT_PATCHLIST	= 33
Const D3D_PRIMITIVE_TOPOLOGY_2_CONTROL_POINT_PATCHLIST	= 34
Const D3D_PRIMITIVE_TOPOLOGY_3_CONTROL_POINT_PATCHLIST	= 35
Const D3D_PRIMITIVE_TOPOLOGY_4_CONTROL_POINT_PATCHLIST	= 36
Const D3D_PRIMITIVE_TOPOLOGY_5_CONTROL_POINT_PATCHLIST	= 37
Const D3D_PRIMITIVE_TOPOLOGY_6_CONTROL_POINT_PATCHLIST	= 38
Const D3D_PRIMITIVE_TOPOLOGY_7_CONTROL_POINT_PATCHLIST	= 39
Const D3D_PRIMITIVE_TOPOLOGY_8_CONTROL_POINT_PATCHLIST	= 40
Const D3D_PRIMITIVE_TOPOLOGY_9_CONTROL_POINT_PATCHLIST	= 41
Const D3D_PRIMITIVE_TOPOLOGY_10_CONTROL_POINT_PATCHLIST	= 42
Const D3D_PRIMITIVE_TOPOLOGY_11_CONTROL_POINT_PATCHLIST	= 43
Const D3D_PRIMITIVE_TOPOLOGY_12_CONTROL_POINT_PATCHLIST	= 44
Const D3D_PRIMITIVE_TOPOLOGY_13_CONTROL_POINT_PATCHLIST	= 45
Const D3D_PRIMITIVE_TOPOLOGY_14_CONTROL_POINT_PATCHLIST	= 46
Const D3D_PRIMITIVE_TOPOLOGY_15_CONTROL_POINT_PATCHLIST	= 47
Const D3D_PRIMITIVE_TOPOLOGY_16_CONTROL_POINT_PATCHLIST	= 48
Const D3D_PRIMITIVE_TOPOLOGY_17_CONTROL_POINT_PATCHLIST	= 49
Const D3D_PRIMITIVE_TOPOLOGY_18_CONTROL_POINT_PATCHLIST	= 50
Const D3D_PRIMITIVE_TOPOLOGY_19_CONTROL_POINT_PATCHLIST	= 51
Const D3D_PRIMITIVE_TOPOLOGY_20_CONTROL_POINT_PATCHLIST	= 52
Const D3D_PRIMITIVE_TOPOLOGY_21_CONTROL_POINT_PATCHLIST	= 53
Const D3D_PRIMITIVE_TOPOLOGY_22_CONTROL_POINT_PATCHLIST	= 54
Const D3D_PRIMITIVE_TOPOLOGY_23_CONTROL_POINT_PATCHLIST	= 55
Const D3D_PRIMITIVE_TOPOLOGY_24_CONTROL_POINT_PATCHLIST	= 56
Const D3D_PRIMITIVE_TOPOLOGY_25_CONTROL_POINT_PATCHLIST	= 57
Const D3D_PRIMITIVE_TOPOLOGY_26_CONTROL_POINT_PATCHLIST	= 58
Const D3D_PRIMITIVE_TOPOLOGY_27_CONTROL_POINT_PATCHLIST	= 59
Const D3D_PRIMITIVE_TOPOLOGY_28_CONTROL_POINT_PATCHLIST	= 60
Const D3D_PRIMITIVE_TOPOLOGY_29_CONTROL_POINT_PATCHLIST	= 61
Const D3D_PRIMITIVE_TOPOLOGY_30_CONTROL_POINT_PATCHLIST	= 62
Const D3D_PRIMITIVE_TOPOLOGY_31_CONTROL_POINT_PATCHLIST	= 63
Const D3D_PRIMITIVE_TOPOLOGY_32_CONTROL_POINT_PATCHLIST	= 64
Const D3D11_PRIMITIVE_TOPOLOGY_UNDEFINED	= D3D_PRIMITIVE_TOPOLOGY_UNDEFINED
Const D3D11_PRIMITIVE_TOPOLOGY_POINTLIST	= D3D_PRIMITIVE_TOPOLOGY_POINTLIST
Const D3D11_PRIMITIVE_TOPOLOGY_LINELIST	= D3D_PRIMITIVE_TOPOLOGY_LINELIST
Const D3D11_PRIMITIVE_TOPOLOGY_LINESTRIP	= D3D_PRIMITIVE_TOPOLOGY_LINESTRIP
Const D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST	= D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST
Const D3D11_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP	= D3D_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP
Const D3D11_PRIMITIVE_TOPOLOGY_LINELIST_ADJ	= D3D_PRIMITIVE_TOPOLOGY_LINELIST_ADJ
Const D3D11_PRIMITIVE_TOPOLOGY_LINESTRIP_ADJ	= D3D_PRIMITIVE_TOPOLOGY_LINESTRIP_ADJ
Const D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST_ADJ	= D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST_ADJ
Const D3D11_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP_ADJ	= D3D_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP_ADJ
Const D3D11_PRIMITIVE_TOPOLOGY_1_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_1_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_2_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_2_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_3_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_3_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_4_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_4_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_5_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_5_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_6_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_6_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_7_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_7_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_8_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_8_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_9_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_9_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_10_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_10_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_11_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_11_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_12_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_12_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_13_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_13_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_14_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_14_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_15_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_15_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_16_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_16_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_17_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_17_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_18_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_18_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_19_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_19_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_20_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_20_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_21_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_21_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_22_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_22_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_23_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_23_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_24_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_24_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_25_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_25_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_26_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_26_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_27_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_27_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_28_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_28_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_29_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_29_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_30_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_30_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_31_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_31_CONTROL_POINT_PATCHLIST
Const D3D11_PRIMITIVE_TOPOLOGY_32_CONTROL_POINT_PATCHLIST	= D3D_PRIMITIVE_TOPOLOGY_32_CONTROL_POINT_PATCHLIST

Const D3D_PRIMITIVE_UNDEFINED	= 0
Const D3D_PRIMITIVE_POINT	= 1
Const D3D_PRIMITIVE_LINE	= 2
Const D3D_PRIMITIVE_TRIANGLE	= 3
Const D3D_PRIMITIVE_LINE_ADJ	= 6
Const D3D_PRIMITIVE_TRIANGLE_ADJ	= 7
Const D3D_PRIMITIVE_1_CONTROL_POINT_PATCH	= 8
Const D3D_PRIMITIVE_2_CONTROL_POINT_PATCH	= 9
Const D3D_PRIMITIVE_3_CONTROL_POINT_PATCH	= 10
Const D3D_PRIMITIVE_4_CONTROL_POINT_PATCH	= 11
Const D3D_PRIMITIVE_5_CONTROL_POINT_PATCH	= 12
Const D3D_PRIMITIVE_6_CONTROL_POINT_PATCH	= 13
Const D3D_PRIMITIVE_7_CONTROL_POINT_PATCH	= 14
Const D3D_PRIMITIVE_8_CONTROL_POINT_PATCH	= 15
Const D3D_PRIMITIVE_9_CONTROL_POINT_PATCH	= 16
Const D3D_PRIMITIVE_10_CONTROL_POINT_PATCH	= 17
Const D3D_PRIMITIVE_11_CONTROL_POINT_PATCH	= 18
Const D3D_PRIMITIVE_12_CONTROL_POINT_PATCH	= 19
Const D3D_PRIMITIVE_13_CONTROL_POINT_PATCH	= 20
Const D3D_PRIMITIVE_14_CONTROL_POINT_PATCH	= 21
Const D3D_PRIMITIVE_15_CONTROL_POINT_PATCH	= 22
Const D3D_PRIMITIVE_16_CONTROL_POINT_PATCH	= 23
Const D3D_PRIMITIVE_17_CONTROL_POINT_PATCH	= 24
Const D3D_PRIMITIVE_18_CONTROL_POINT_PATCH	= 25
Const D3D_PRIMITIVE_19_CONTROL_POINT_PATCH	= 26
Const D3D_PRIMITIVE_20_CONTROL_POINT_PATCH	= 28
Const D3D_PRIMITIVE_21_CONTROL_POINT_PATCH	= 29
Const D3D_PRIMITIVE_22_CONTROL_POINT_PATCH	= 30
Const D3D_PRIMITIVE_23_CONTROL_POINT_PATCH	= 31
Const D3D_PRIMITIVE_24_CONTROL_POINT_PATCH	= 32
Const D3D_PRIMITIVE_25_CONTROL_POINT_PATCH	= 33
Const D3D_PRIMITIVE_26_CONTROL_POINT_PATCH	= 34
Const D3D_PRIMITIVE_27_CONTROL_POINT_PATCH	= 35
Const D3D_PRIMITIVE_28_CONTROL_POINT_PATCH	= 36
Const D3D_PRIMITIVE_29_CONTROL_POINT_PATCH	= 37
Const D3D_PRIMITIVE_30_CONTROL_POINT_PATCH	= 38
Const D3D_PRIMITIVE_31_CONTROL_POINT_PATCH	= 39
Const D3D_PRIMITIVE_32_CONTROL_POINT_PATCH	= 40
Const D3D11_PRIMITIVE_UNDEFINED	= D3D_PRIMITIVE_UNDEFINED
Const D3D11_PRIMITIVE_POINT	= D3D_PRIMITIVE_POINT
Const D3D11_PRIMITIVE_LINE	= D3D_PRIMITIVE_LINE
Const D3D11_PRIMITIVE_TRIANGLE	= D3D_PRIMITIVE_TRIANGLE
Const D3D11_PRIMITIVE_LINE_ADJ	= D3D_PRIMITIVE_LINE_ADJ
Const D3D11_PRIMITIVE_TRIANGLE_ADJ	= D3D_PRIMITIVE_TRIANGLE_ADJ
Const D3D11_PRIMITIVE_1_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_1_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_2_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_2_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_3_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_3_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_4_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_4_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_5_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_5_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_6_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_6_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_7_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_7_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_8_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_8_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_9_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_9_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_10_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_10_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_11_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_11_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_12_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_12_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_13_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_13_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_14_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_14_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_15_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_15_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_16_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_16_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_17_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_17_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_18_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_18_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_19_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_19_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_20_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_20_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_21_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_21_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_22_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_22_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_23_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_23_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_24_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_24_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_25_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_25_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_26_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_26_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_27_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_27_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_28_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_28_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_29_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_29_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_30_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_30_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_31_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_31_CONTROL_POINT_PATCH
Const D3D11_PRIMITIVE_32_CONTROL_POINT_PATCH	= D3D_PRIMITIVE_32_CONTROL_POINT_PATCH

Const D3D_SRV_DIMENSION_UNKNOWN            = 0
Const D3D_SRV_DIMENSION_BUFFER             = 1
Const D3D_SRV_DIMENSION_TEXTURE1D          = 2
Const D3D_SRV_DIMENSION_TEXTURE1DARRAY     = 3
Const D3D_SRV_DIMENSION_TEXTURE2D          = 4
Const D3D_SRV_DIMENSION_TEXTURE2DARRAY     = 5
Const D3D_SRV_DIMENSION_TEXTURE2DMS        = 6
Const D3D_SRV_DIMENSION_TEXTURE2DMSARRAY   = 7
Const D3D_SRV_DIMENSION_TEXTURE3D          = 8
Const D3D_SRV_DIMENSION_TEXTURECUBE        = 9
Const D3D_SRV_DIMENSION_TEXTURECUBEARRAY	= 10
Const D3D_SRV_DIMENSION_BUFFEREX	= 11
Const D3D11_SRV_DIMENSION_UNKNOWN	= D3D_SRV_DIMENSION_UNKNOWN
Const D3D11_SRV_DIMENSION_BUFFER	= D3D_SRV_DIMENSION_BUFFER
Const D3D11_SRV_DIMENSION_TEXTURE1D	= D3D_SRV_DIMENSION_TEXTURE1D
Const D3D11_SRV_DIMENSION_TEXTURE1DARRAY	= D3D_SRV_DIMENSION_TEXTURE1DARRAY
Const D3D11_SRV_DIMENSION_TEXTURE2D	= D3D_SRV_DIMENSION_TEXTURE2D
Const D3D11_SRV_DIMENSION_TEXTURE2DARRAY	= D3D_SRV_DIMENSION_TEXTURE2DARRAY
Const D3D11_SRV_DIMENSION_TEXTURE2DMS	= D3D_SRV_DIMENSION_TEXTURE2DMS
Const D3D11_SRV_DIMENSION_TEXTURE2DMSARRAY	= D3D_SRV_DIMENSION_TEXTURE2DMSARRAY
Const D3D11_SRV_DIMENSION_TEXTURE3D	= D3D_SRV_DIMENSION_TEXTURE3D
Const D3D11_SRV_DIMENSION_TEXTURECUBE	= D3D_SRV_DIMENSION_TEXTURECUBE
Const D3D11_SRV_DIMENSION_TEXTURECUBEARRAY	= D3D_SRV_DIMENSION_TEXTURECUBEARRAY
Const D3D11_SRV_DIMENSION_BUFFEREX	= D3D_SRV_DIMENSION_BUFFEREX

Const D3D_INCLUDE_LOCAL	= 0
Const D3D_INCLUDE_SYSTEM	= ( D3D_INCLUDE_LOCAL + 1 )
Const D3D_INCLUDE_FORCE_DWORD	= $7fffffff

Type D3D_SHADER_MACRO
	Field Name:Byte Ptr
	Field Definition:Byte Ptr
EndType

Extern "win32"
Type ID3DBlob Extends IUnknown
	Method GetBufferPointer:Byte Ptr()
	Method GetBufferSize()
EndType
EndExtern

