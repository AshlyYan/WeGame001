// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Unlit - CircleClip (AlphaClip)" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Radius_A("RadiusA", float) = 0.5
		_Radius_B("RadiusB", float) = 0.5
		_Origin ("Origin", vector) = (0.5, 0.5, 0, 0)
		_Fade ("Fade Rate", float) = 0.97
	}
	SubShader 
	{
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
			//AlphaTest Greater .01
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMaterial AmbientAndDiffuse

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
						
			#include "UnityCG.cginc"			

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Radius_A;
			float _Radius_B;
			float2 _Origin;
			float _Fade;

			struct appdata_t
			{
				float4 vertex : POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex : POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float2 worldPos : TEXCOORD1;
			};
			
			v2f vert (appdata_t v)
			{
			    v2f o;
			    o.vertex = UnityObjectToClipPos (v.vertex);
			    o.texcoord = v.texcoord;
				o.color = v.color;
				o.worldPos = TRANSFORM_TEX(v.vertex.xy, _MainTex);
			    return o;
			}
			
			half4 frag (v2f i) : COLOR
			{				
			    half4 texcol = tex2D (_MainTex, i.texcoord) * i.color;

				float2 xy = i.texcoord - _Origin.xy;
				float d = pow(xy.x, 2) / pow(_Radius_A, 2) + pow(xy.y, 2) / pow(_Radius_B, 2);
				if (d >= _Fade)
					texcol.a *= clamp((1 - d) / (1 - _Fade), 0, 1);

				float2 factor = abs(i.worldPos);
				float val = 1.0 - max(factor.x, factor.y);

				// Option 1: 'if' statement
				if (val < 0.0) texcol.a = 0.0;
				// Option 2: no 'if' statement -- may be faster on some devices
				// texcol.a *= ceil(clamp(val, 0.0, 1.0));


			    return texcol;
			}
			ENDCG

		}		

	} 
	FallBack "Diffuse"
}
