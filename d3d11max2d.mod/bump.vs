cbuffer CMax2DBuffer
{
	matrix ProjMatrix;
};

struct VertexInputType
{
	float2 position : POSITION;
	float2 tex : TEXCOORD0;
};

struct PixelInputType
{
	float4 position : SV_POSITION;
	float2 tex : TEXCOORD0;
};

PixelInputType BumpVertexShader( VertexInputType input)
{
	PixelInputType output;
	output.position = mul(float4(input.position,0,1),ProjMatrix);
	output.tex = input.tex;
	return output;
}
