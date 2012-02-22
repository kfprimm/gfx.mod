
Strict

Import BRL.Max2D

Type TBatchImage
	Method Create:TBatchImage(image:TImage,color,rotation,scale,uv,frames) Abstract
	Method Update(position#[] Var,color#[] Var,rotation#[] Var,scale#[] Var,uv#[] Var,frames[] Var) Abstract
	Method Draw(frame) Abstract
	Method Destroy() Abstract
EndType



