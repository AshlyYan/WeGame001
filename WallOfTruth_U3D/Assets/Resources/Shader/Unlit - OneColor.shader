// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Unlit - OneColor" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Color ("One Color", Color) = (1, 0, 0, 0)
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
			float4 _Color;
			
			struct v2f 
			{
			    float4  pos : SV_POSITION;
			    float2  uv : TEXCOORD0;
			};
			
			v2f vert (appdata_base v)
			{
			    v2f o;
			    o.pos = UnityObjectToClipPos (v.vertex);
			    o.uv = v.texcoord;
			    return o;
			}
			
			half4 frag (v2f i) : COLOR
			{
			    half4 texcol = tex2D (_MainTex, i.uv);
			    texcol.rgb = _Color.rgb;
			    if(texcol.a > 0.1)
			    	texcol.a = 1;
			    else
			    	texcol.a = 0;		    
			    return texcol;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
