Strict

Import BRL.System
Import "d3dcommon.bmx"

Const D3DCOMPILE_DEBUG                          = ( 1 Shl 0)
Const D3DCOMPILE_SKIP_VALIDATION                = ( 1 Shl 1)
Const D3DCOMPILE_SKIP_OPTIMIZATION              = ( 1 Shl 2)
Const D3DCOMPILE_PACK_MATRIX_ROW_MAJOR          = ( 1 Shl 3)
Const D3DCOMPILE_PACK_MATRIX_COLUMN_MAJOR       = ( 1 Shl 4)
Const D3DCOMPILE_PARTIAL_PRECISION              = ( 1 Shl 5)
Const D3DCOMPILE_FORCE_VS_SOFTWARE_NO_OPT       = ( 1 Shl 6)
Const D3DCOMPILE_FORCE_PS_SOFTWARE_NO_OPT       = ( 1 Shl 7)
Const D3DCOMPILE_NO_PRESHADER                   = ( 1 Shl 8)
Const D3DCOMPILE_AVOID_FLOW_CONTROL             = ( 1 Shl 9)
Const D3DCOMPILE_PREFER_FLOW_CONTROL            = ( 1 Shl 10)
Const D3DCOMPILE_ENABLE_STRICTNESS              = ( 1 Shl 11)
Const D3DCOMPILE_ENABLE_BACKWARDS_COMPATIBILITY = ( 1 Shl 12)
Const D3DCOMPILE_IEEE_STRICTNESS                = ( 1 Shl 13)
Const D3DCOMPILE_OPTIMIZATION_LEVEL0            = ( 1 Shl 14)
Const D3DCOMPILE_OPTIMIZATION_LEVEL1            = 0
Const D3DCOMPILE_OPTIMIZATION_LEVEL2            = ( 1 Shl 14) | ( 1 Shl 15)
Const D3DCOMPILE_OPTIMIZATION_LEVEL3            = ( 1 Shl 15)
Const D3DCOMPILE_RESERVED16                     = ( 1 Shl 16)
Const D3DCOMPILE_RESERVED17                     = ( 1 Shl 17)
Const D3DCOMPILE_WARNINGS_ARE_ERRORS            = ( 1 Shl 18)

Const D3DCOMPILE_EFFECT_CHILD_EFFECT              = ( 1 Shl 0)
Const D3DCOMPILE_EFFECT_ALLOW_SLOW_OPS            = ( 1 Shl 1)

Global _d3dcompiler = LoadLibraryA("d3dcompiler_43.dll")
If Not _d3dcompiler
	Notify "ERROR!~nCannot find 'd3dcompiler_43.dll'~nPlease install the latest version of DirectX11~nExiting.",True
	End
EndIf

Global D3DCreateBlob(Size,ppBlob:ID3DBlob Var)"win32" = GetProcAddress(_d3dcompiler,"D3DCreateBlob")
Global D3DCompile(pSrcData:Byte Ptr,SrcDataSize,pSourceName:Byte Ptr,pDefines:Byte Ptr,pInclude:Byte Ptr,pEntryPoint:Byte Ptr,pTarget:Byte Ptr,Flags1,Flags2,ppCode:ID3DBlob Var,ppErrorMsgs:ID3DBlob Var)"win32" = GetProcAddress(_d3dcompiler,"D3DCompile")
'Global D3DPreprocess()
'Global D3DGetDebugInfo()
'Global D3DReflect()
'Global D3DDisassemble()
'Global D3DDisassemble10Effect()
'Global D3DGetInputSignatureBlob()
'Global D3DGetInputAndOutputSignatureBlob()
'Global D3DStripShader()
'Global D3DGetBlobPart()
'Global D3DCompressShaders()
'Global D3DDecompressShaders()