cbuffer CMax2DMatrixBuffer
{
	matrix ProjMatrix;
};

struct VS_IN
{
	float2 pos : POSITION;
	float2 tex : TEXCOORD0;
};

struct VS_OUT
{
	float4 pos : SV_POSITION;
	float2 tex : TEXCOORD0;
};

VS_OUT ImageToCasterVS( VS_IN input )
{
	VS_OUT output;
	
	output.pos = mul(float4(input.pos+0.5,0,1),ProjMatrix);
	output.tex = input.tex;
	
	return output;
}