
Strict

Rem
	bbdoc: NVIDIA Cg shader support for Max2DEx.
End Rem
Module GFX.CgShaderDriver
ModuleInfo "Author: Kevin Primm"
ModuleInfo "License: MIT"

Import "driver.bmx"
Import "gl.bmx"
'Import "d3d9.bmx"

Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function CgShaderDriver:TCgShaderDriver()
	Local driver:TCgShaderDriver=TCgShaderDriver._first_cg
	While driver
		If driver.Compatible(GetGraphicsDriver())
			driver.Initialize(GetGraphicsDriver())
			Return driver
		EndIf
		driver=driver._next_cg
	Wend
End Function
