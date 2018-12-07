// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/TransparentColoredWithEdge (SoftClip)"
{
	Properties
	{
		_MainTex("Base (RGB), Alpha (A)", 2D) = "white" {}
		_GatherRange("Gather Range", float) = 0.008
		_HighlightColor("Highlight Color", Color) = (0, 1, 1)
		_Select("Highlight On", float) = 0

		_EdgeX("Edge X", float) = 0.05
		_EdgeY("Edge Y", float) = 0.05

		_AnimTex_1("First Anim (RGB), Alpha (A)", 2D) = "white" {}
		_AnimX_1("First Anim Pic X Num",int) = 6
		_AnimY_1("First Anim Pic Y Num",int) = 6
		_AnimScale_1("First Anim Scale",float) = 0.6
		_Frame_1("First Anim Frame", int) = 0

		_AnimTex_2("Second Anim (RGB), Alpha (A)", 2D) = "white" {}
		_AnimX_2("Second Anim Pic X Num",int) = 8
		_AnimY_2("Second Anim Pic Y Num",int) = 8
		_AnimScale_2("Second Anim Scale",float) = 0.3
		_Frame_2("Second Anim Frame", int) = 0
	}

		SubShader
	{
		LOD 200

		Tags
	{
		"Queue" = "Transparent"
		"IgnoreProjector" = "True"
		"RenderType" = "Transparent"
	}

			Cull Off
			Lighting Off
			ZWrite Off
			Offset -1, -1
			Fog{ Mode Off }
			ColorMask RGB
			AlphaTest Greater .01

			Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"

			sampler2D _MainTex;
		float4 _MainTex_ST;
		float2 _ClipSharpness = float2(20.0, 20.0);

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

		v2f vert(appdata_t v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex * 1.1f);
			o.texcoord = v.texcoord;
			o.color = v.color;
			o.worldPos = TRANSFORM_TEX(v.vertex, _MainTex);
			return o;
		}

		half4 frag(v2f IN) : COLOR
		{
			// Softness factor
			float2 factor = (float2(1.0, 1.0) - abs(IN.worldPos)) * _ClipSharpness;

			// Sample the texture
			half4 col = tex2D(_MainTex, IN.texcoord) * IN.color;
			col.a *= clamp(min(factor.x, factor.y), 0.0, 1.0);
			return col;
		}
			ENDCG
		}

		Pass
	{
		Blend One One

		CGPROGRAM
#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"

		sampler2D _MainTex;
	float4 _MainTex_ST;
	float2 _ClipSharpness = float2(20.0, 20.0);

	half _Select;
	half3 _HighlightColor;
	half _GatherRange;

	half _EdgeX;
	half _EdgeY;

	sampler2D _AnimTex_1;
	int _Frame_1;
	int _AnimX_1;
	int _AnimY_1;
	half _AnimScale_1;

	sampler2D _AnimTex_2;
	int _Frame_2;
	int _AnimX_2;
	int _AnimY_2;
	half _AnimScale_2;

	struct appdata_t
	{
		float4 vertex : POSITION;
		half4 color : COLOR;
		float2 texcoord : TEXCOORD0;
	};

	struct v2f
	{
		float4 vertex : SV_POSITION;
		half4 color : COLOR;
		float2 texcoord : TEXCOORD0;
		float2 worldPos : TEXCOORD4;
		//half2 texcoord1 : TEXCOORD1;
	};

	v2f vert(appdata_t v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex * 1.1f);
		o.texcoord = v.texcoord;
		o.color = v.color;
		o.worldPos = TRANSFORM_TEX(v.vertex, _MainTex);
		return o;
	}

	half GetColor(half c, half a)
	{
		return c < 0.99f ? pow(c + (1 - c) * a, 2) * a: a;
	}

	half4 frag(v2f i) : COLOR
	{
		// Softness factor
		float2 factor = (float2(1.0, 1.0) - abs(i.worldPos)) * _ClipSharpness;

		// Sample the texture
		half4 col = tex2D(_MainTex, i.texcoord) * i.color;
		//fixed4 col1 = tex2D(_MainTex, i.texcoord1);

		if (_Select > 5 && col.a < 0.87f)
		{
			//检查周围像素
			half A = 0;
			for (half y = 0; y < 7; ++y)
			{
				for (half x = 0; x < 7; ++x)
				{
					float2 offset = float2(_GatherRange * (x - 3), _GatherRange * (y - 3));
					half tmpA = tex2D(_MainTex, i.texcoord + offset).a;
					A += tmpA;
				}
			}
			if (A > 1.0f)
			{
				half2 center = half2(0.5f, 0.5f);

				int _curFrame = _Frame_1 % (_AnimX_1 * _AnimY_1);
				half2 uv = (i.texcoord - center) * _AnimScale_1 + center;
				uv.x = (uv.x + _curFrame % _AnimX_1) / _AnimX_1;
				uv.y = (uv.y + _AnimY_1 - _curFrame / _AnimY_1 - 1) / _AnimY_1;
				half animAlpha = tex2D(_AnimTex_1, uv).a;

				_curFrame = _Frame_2 % (_AnimX_2 * _AnimY_2);
				uv = (i.texcoord - center) * _AnimScale_2 + center;
				uv.x = (uv.x + _curFrame % _AnimX_2) / _AnimX_2;
				uv.y = (uv.y + _AnimY_2 - _curFrame / _AnimY_2 - 1) / _AnimY_2;
				animAlpha = clamp((animAlpha + tex2D(_AnimTex_2, uv).a) * 1.2f, 0, 1);

				half alpha = clamp(A / 20, 0, 1) * animAlpha;
				col = fixed4(GetColor(_HighlightColor.r, alpha), GetColor(_HighlightColor.g, alpha), GetColor(_HighlightColor.b, alpha), alpha);
			}
			else
				col = fixed4(0, 0, 0, 0);
		}
		else
			col = fixed4(0, 0, 0, 0);
		col *= clamp(min(factor.x, factor.y), 0.0, 1.0);
		return col;
	}
		ENDCG
	}
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

		Pass
	{
		Cull Off
		Lighting Off
		ZWrite Off
		Fog{ Mode Off }
		ColorMask RGB
		AlphaTest Greater .01
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMaterial AmbientAndDiffuse

		SetTexture[_MainTex]
	{
		Combine Texture * Primary
	}
	}
	}
}