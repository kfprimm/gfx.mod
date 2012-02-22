//D3D11Max2D TBatchImage Vertex Shader
//Written by Dave Camp - SRS Software 2011

cbuffer CMax2DMatrixBuffer
{
	matrix ProjMatrix;
};

struct VertexInstanceType
{
	float4 vpostex : POSITION0;
	float4 color : TEXCOORD0;
	float4 uv0 : TEXCOORD1;
	float4 uv1 : TEXCOORD2;
	float2 iposition : TEXCOORD3;
	float2 scale : TEXCOORD4;
	float rot : TEXCOORD5;
	uint srv : TEXCOORD6;
};

struct PixelInstanceType
{
	float4 position : SV_POSITION;
	float4 color : COLOR0;
	float3 srv : TEXTURE;
};

const static float oneover255 = 1.0 / 255.0;
float4 MapColour( float4 incol )
{
	float4 outcol;
	outcol.rgb = oneover255 * incol.rgb;
	outcol.a = incol.a;
	return outcol;
}

float2 CalcUV(uint VID, float4 uv0, float4 uv1)
{
    [branch]
	switch(VID)
    {
        case 0:
			return uv0.xy;
        case 1:
			return uv0.zw;
        case 2:
			return uv1.xy;
        default:
			return uv1.zw;
    }
}

PixelInstanceType InstanceVertexShader(VertexInstanceType input, uint vid : SV_VERTEXID)
{
	PixelInstanceType output;
	
	float4 pos;
	#if defined(SCALE)
		pos = float4(input.vpostex.x*input.scale.x,input.vpostex.y*input.scale.y,0,1);
	#else
		pos = float4(input.vpostex.xy,0,1);
	#endif

	float4x4 rmatrix;
	#if defined(ROTATION)
		input.rot = radians(input.rot);
		
		rmatrix[0] = float4(cos(input.rot),sin(input.rot),0,0);
		rmatrix[1] = float4(-sin(input.rot),cos(input.rot),0,0);
		rmatrix[2] = float4(0,0,1,0);
		rmatrix[3] = float4(0,0,0,1);
		
		pos = mul(pos,rmatrix);
	#endif
	
	float4 color;	
	#if defined(COLOR)
		output.color = MapColour(input.color);
	#else
		output.color = 1;
	#endif
	
	float2 uv;
	#if defined(UV)
		uv = CalcUV(vid, input.uv0, input.uv1);
	#else
		uv = input.vpostex.zw;
	#endif
	
	output.position = mul(pos + float4(input.iposition,0,0),ProjMatrix);
	output.srv = float3(uv,input.srv);
	return output;
}