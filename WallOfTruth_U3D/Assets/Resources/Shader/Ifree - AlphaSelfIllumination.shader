Shader "Custom/Ifree - AlphaSelfIllumination" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Illumination ( "Self Illumination", Color) = (0, 0, 0, 1)
	}
	SubShader {
		Tags { "RenderType"="Transparent" }
		LOD 200
		//ZTest LEqual
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#pragma surface surf myLambert

		sampler2D _MainTex;
		float4 _Illumination;

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		
      half4 LightingmyLambert (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
          half3 h = normalize (lightDir + viewDir);

          half diff = max (0, dot (s.Normal, lightDir));

          float nh = max (0, dot (s.Normal, h));
          float spec = pow (nh, 48.0);

          half4 c;
          c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * (atten * 2) + _Illumination;
          c.a = s.Alpha;
          return c;
      }
		ENDCG
	} 
	FallBack "Diffuse"
}
