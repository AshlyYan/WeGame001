// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Unlit - OutLine" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_OffValue ("Off Value", float) = 0.2
		_LineColor ("OutLine Color", Color) = (1, 0, 0, 0)
	}
	
	SubShader {
		LOD 100

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Fog { Mode Off }
			Offset -1, -1
			ColorMask RGB
			AlphaTest Greater .01
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMaterial AmbientAndDiffuse

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
						
			#include "UnityCG.cginc"			

			sampler2D _MainTex;
			float _OffValue;
			float4 _LineColor;
			
			struct v2f 
			{
			    float4  pos : SV_POSITION;
			    float2  uv : TEXCOORD0;
			};
			
			v2f vert (appdata_base v)
			{
			    v2f o;
			    
			    float3 vworldPos = v.vertex.xyz;
			    float3 verPos = vworldPos * _OffValue;
			    float3 offPos = vworldPos + verPos;
			    float4 resPos = float4(offPos, 1);
			    o.pos = UnityObjectToClipPos (resPos);
			    o.uv = v.texcoord;
			    return o;
			}
			
			half4 frag (v2f i) : COLOR
			{
			    half4 texcol = tex2D (_MainTex, i.uv);
			    texcol.rgb = texcol.a * _LineColor.rgb;			    
			    return texcol;
			}
			ENDCG
		}		
		
		
		pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Fog { Mode Off }
			Offset -1, -1
			ColorMask RGB
			AlphaTest Greater .01
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMaterial AmbientAndDiffuse
			
			SetTexture [_MainTex]
			{
				Combine Texture * Primary
			}
		}		

	} 
	
	FallBack "Diffuse"
}
