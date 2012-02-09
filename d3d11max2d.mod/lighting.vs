struct VertexLightingType	
{
	float4 postex : POSITION;
	float4 lightPR : TEXCOORD0; //xyz = position , a = radius
	float4 lightCI : TEXCOORD1; //xyz = rgb , a = intensity
	float4 lightAtt : TEXCOORD2; //attenuation xyz,padding

};

struct PixelLightingType
{
	float4 position : SV_POSITION;
	float2 tex : TEXCOORD0;
	float4 lightPR : TEXCOORD1; //xyz = position , a = radius
	float4 lightCI : TEXCOORD2; //xyz = rgb , a = intensity
	float4 lightAtt : TEXCOORD3; //attenuation xyz,padding
};

PixelLightingType LightingVertexShader(VertexLightingType input, uint vid:SV_VERTEXID)
{
	PixelLightingType output;

	output.position = float4(input.postex.xy,0,1);
	output.tex = input.postex.zw;
	
	output.lightPR = input.lightPR;
	output.lightCI = input.lightCI;
	output.lightAtt = input.lightAtt;
	
	return output;
}