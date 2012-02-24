
Strict

Rem
	bbdoc: Direct3D 9 driver for Max2DEx
End Rem
Module GFX.D3D9Max2DEx
ModuleInfo "Author: Kevin Primm"
ModuleInfo "Version: 0.01"
ModuleInfo "License: MIT"

Import GFX.Max2DEx
Import BRL.D3D9Max2D

?Win32

Type TD3D9Buffer Extends TBuffer

End Type

Type TD3D9Max2DExDriver Extends TMax2DExDriver
	Method MakeBuffer:TBuffer(src:Object,width,height,flags)
		Return MakeD3D9Buffer(width,height)
	End Method
	
	Method MakeD3D9Buffer:TD3D9Buffer(width,height)
		Local buffer:TD3D9Buffer=New TD3D9Buffer
		buffer._width=width
		buffer._height=height
		Return buffer
	End Method
	
	Method SetBuffer(buffer:TBuffer)
		_currentbuffer=buffer
	End Method
	
	Method CreateBatchImage:TBatchImage(image:TImage,color=False,rotation=False,scale=False,uv=False,frames=False)
    Throw "Batching support needs implementation!"
	End Method
	
	Method PlotPoints(points#[])
		Throw "PlotPoints support needs implementation!"
	End Method
  
  Method DrawLines(lines#[],linked)
		Throw "DrawLines support needs implementation!"
	End Method 
  
  Method DrawImageTiled(image:TImage,x#=0,y#=0,frame=0)
		Throw "DrawImageTiled support needs implementation!"
	End Method
End Type

Rem
	bbdoc: Needs documentation. #TODO
End Rem
Function D3D9Max2DExDriver:TD3D9Max2DExDriver ()
	If D3D9Max2DDriver()
		Global driver:TD3D9Max2DExDriver = New TD3D9Max2DExDriver 
		driver._parent=D3D9Max2DDriver()
		Return driver
	End If
End Function

Local driver:TD3D9Max2DExDriver = D3D9Max2DExDriver()
If driver SetGraphicsDriver driver

?
