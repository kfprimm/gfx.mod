//D3D11Max2D Vertex Shader
//Written by Dave Camp - SRS Software 2011

cbuffer CMax2DMatrixBuffer
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

PixelInputType StandardVertexShader(VertexInputType input)
{
	PixelInputType output;
	output.position = mul(float4(input.position+0.5, 0, 1),ProjMatrix);
	output.tex = input.tex;
	return output;
}