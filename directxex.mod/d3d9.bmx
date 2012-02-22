
Strict

Rem
Copyright (C) 2011 by Kevin Primm

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
End Rem

' D3DFILLMODE
Const D3DFILL_POINT			= 1
Const D3DFILL_WIREFRAME	= 2
Const D3DFILL_SOLID			= 3

' D3DTEXTURETRANSFORMFLAGS 
Const D3DTTFF_DISABLE   = 0
Const D3DTTFF_COUNT1    = 1
Const D3DTTFF_COUNT2    = 2
Const D3DTTFF_COUNT3    = 3
Const D3DTTFF_COUNT4    = 4
Const D3DTTFF_PROJECTED = 256

Const D3DWRAPCOORD_0 = 1
Const D3DWRAPCOORD_1 = 2
Const D3DWRAPCOORD_2 = 4
Const D3DWRAPCOORD_3 = 8

Const D3DWRAP_U = D3DWRAPCOORD_0
Const D3DWRAP_V = D3DWRAPCOORD_1
Const D3DWRAP_W = D3DWRAPCOORD_2

Const D3DRENDERSTATE_WRAPBIAS = 128

' D3DTSS_TCI
Const D3DTSS_TCI_PASSTHRU                    = 0
Const D3DTSS_TCI_CAMERASPACENORMAL           = $00010000
Const D3DTSS_TCI_CAMERASPACEPOSITION         = $00020000
Const D3DTSS_TCI_CAMERASPACEREFLECTIONVECTOR = $00030000
Const D3DTSS_TCI_SPHEREMAP                   = $00040000

Function D3DCOLOR_ARGB(alpha,red,green,blue)
	Return ((alpha&$ff) Shl 24)|((red&$ff) Shl 16)|((green&$ff) Shl 8)|(blue&$ff)
End Function
Function D3DCOLOR_RGBA(red,green,blue,alpha)
	Return D3DCOLOR_ARGB(alpha,red,green,blue)
End Function
Function D3DCOLOR_XRGB(red,green,blue)
	Return D3DCOLOR_ARGB(255,red,green,blue)
End Function
Function D3DCOLOR_RGB(red,green,blue)
	Return D3DCOLOR_ARGB(255,red,green,blue)
End Function


