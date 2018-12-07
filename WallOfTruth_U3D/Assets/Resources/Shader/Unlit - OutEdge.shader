// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Unlit - OutEdge" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_OffValue ("Off Value", float) = 0.02
		_LineColor ("OutLine Color", Color) = (1, 0, 0, 0)
	}
	
	CGINCLUDE
	
	#include "UnityCG.cginc"			

	sampler2D _MainTex;
	float _OffValue;
	float4 _LineColor;
	
	struct v2f 
	{
	    float4  pos : SV_POSITION;
	    float2  uv : TEXCOORD0;
	};
	
	float4 GetPos(float4 v, float x, float y)
	{
		float4 r = v;
		r.x += x;
		r.y += y;
		return r;
	}
	
	v2f vert1 (appdata_base v)
	{
	    v2f o;
	 	float4 tmpVertex = UnityObjectToClipPos (v.vertex);
	    o.pos = GetPos(tmpVertex, -_OffValue, -_OffValue);
	    o.uv = v.texcoord;
	    return o;
	}
	
	v2f vert2 (appdata_base v)
	{
	    v2f o;
	 	float4 tmpVertex = UnityObjectToClipPos (v.vertex);
	    o.pos = GetPos(tmpVertex, -_OffValue, _OffValue);
	    o.uv = v.texcoord;
	    return o;
	}
	
	v2f vert3 (appdata_base v)
	{
	    v2f o;
	 	float4 tmpVertex = UnityObjectToClipPos (v.vertex);
	    o.pos = GetPos(tmpVertex, _OffValue, -_OffValue);
	    o.uv = v.texcoord;
	    return o;
	}
	
	v2f vert4 (appdata_base v)
	{
	    v2f o;
	 	float4 tmpVertex = UnityObjectToClipPos (v.vertex);
	    o.pos = GetPos(tmpVertex, _OffValue, _OffValue);
	    o.uv = v.texcoord;
	    return o;
	}
	
	half4 frag (v2f i) : COLOR
	{
	    half4 texcol = tex2D (_MainTex, i.uv);
	    float ca = 0;
	    if(texcol.a > 0.05)
	    	ca = 1;
	    //else if(ca > 0)
	    //	ca = (0.5-texcol.a) * 2;
	    texcol.rgb = ca * _LineColor.rgb;
	    texcol.a = ca;		    
	    return texcol;
	}
	
	v2f vertend (appdata_base v)
	{
	    v2f o;
	 	float4 tmpVertex = GetPos(v.vertex, 0, 0);
	    o.pos = UnityObjectToClipPos (tmpVertex);
	    o.uv = v.texcoord;
	    return o;
	}
	
	half4 fragend (v2f i) : COLOR
	{
	    half4 texcol = tex2D (_MainTex, i.uv);
	    float ca = 0;
	    //if(texcol.a > 0.5)
	   // 	texcol.a = 1;
	   // else
	    	texcol.a = texcol.a * 5;		    
	    return texcol;
	}
			
	ENDCG
	
	SubShader {
		//LOD 100

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
			//Offset 1, 1
			ColorMask RGB
			AlphaTest Greater .01
			Blend SrcAlpha OneMinusSrcAlpha
			//ColorMaterial AmbientAndDiffuse

			CGPROGRAM

			#pragma vertex vert1
			#pragma fragment frag
						
			
			ENDCG
		}	
		pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Fog { Mode Off }
			//Offset 1, 1
			ColorMask RGB
			AlphaTest Greater .01
			Blend SrcAlpha OneMinusSrcAlpha
			//ColorMaterial AmbientAndDiffuse

			CGPROGRAM

			#pragma vertex vert2
			#pragma fragment frag
						
			
			ENDCG
		}	
		pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Fog { Mode Off }
			//Offset 1, 1
			ColorMask RGB
			AlphaTest Greater .01
			Blend SrcAlpha OneMinusSrcAlpha
			//ColorMaterial AmbientAndDiffuse

			CGPROGRAM

			#pragma vertex vert3
			#pragma fragment frag
						
			
			ENDCG
		}	
		pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Fog { Mode Off }
			//Offset 1, 1
			ColorMask RGB
			AlphaTest Greater .01
			Blend SrcAlpha OneMinusSrcAlpha
			//ColorMaterial AmbientAndDiffuse

			CGPROGRAM

			#pragma vertex vert4
			#pragma fragment frag
						
			
			ENDCG
		}	
		
//		
//		pass
//		{
//			Cull Off
//			Lighting Off
//			ZWrite on
//			Fog { Mode Off }
//			Offset 0, -1
//			ColorMask RGB
//			AlphaTest Greater 0.5
//			Blend SrcAlpha OneMinusSrcAlpha
//			ColorMaterial AmbientAndDiffuse
//			
//			CGPROGRAM
//
//			#pragma vertex vertend
//			#pragma fragment fragend
//						
//			
//			ENDCG
//		}		

	} 
	
	
	
	FallBack "Diffuse"
}
