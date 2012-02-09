Const RENDERIMAGE = $10

Function ImageBuffer:ID3D11RenderTargetView(image:TImage,frame=0)
	Local iframe:TD3D11ImageFrame = TD3D11ImageFrame(image.frame(frame))
	
	Return iframe._rtv
EndFunction

Function BackBuffer:ID3D11RenderTargetView()
	Return _d3d11Graphics.GetRenderTarget()
EndFunction

Function SetBuffer(rtv:ID3D11RenderTargetView)
	If rtv
		_currentrtv = rtv
		_d3d11devcon.OMSetRenderTargets(1,Varptr rtv,Null)
	EndIf
EndFunction


