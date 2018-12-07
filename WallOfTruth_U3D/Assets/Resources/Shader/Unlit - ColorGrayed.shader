// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Unlit - ColorGrayed" 
{
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Color_Rate ("Color Rate", float) = 0
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
//			
//			lighting off			
//			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
						
			#include "UnityCG.cginc"			

			sampler2D _MainTex;
			half _Color_Rate;
			
			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct v2f 
			{
			    float4  pos : SV_POSITION;
			    float2  uv : TEXCOORD0;
				fixed4 color : COLOR;
			};
			
			v2f vert (appdata_t v)
			{
			    v2f o;
			    o.pos = UnityObjectToClipPos (v.vertex);
			    o.uv = v.texcoord;
				o.color = v.color;
			    return o;
			}
			
			half4 frag (v2f i) : COLOR
			{
			    half4 texcol = tex2D (_MainTex, i.uv) * i.color;
				//half a = texcol.a;
			    half4 gray = (texcol.r + texcol.g + texcol.b) / 3;		
				
				texcol.rgb = lerp(gray, texcol, _Color_Rate);
				//texcol.a = a;
			    return texcol;
			}
			ENDCG

		}		

	} 
	FallBack "Diffuse"
}
