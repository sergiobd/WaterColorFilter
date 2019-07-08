
Shader "Hidden/WaterColorFilter_v2" {
	
	HLSLINCLUDE

	#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

	TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);

	TEXTURE2D_SAMPLER2D(_WobbTex, sampler_WobbTex);

	TEXTURE2D_SAMPLER2D(_PaperTex, sampler_PaperTex);

	float _WobbScale;
	float _WobbPower;
	float _EdgeSize;
	float _EdgePower;

	float4 _MainTex_TexelSize;

	float _PaperScale;
	float _PaperPower;


	struct appdata {
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};
	struct v2f {
		float2 uv_Main : TEXCOORD0;
		float4 vertex : SV_POSITION;
	};


	float4 ColorMod(float4 c, float d) {
		return c - (c - c * c) * (d - 1);
	}

	ENDHLSL

		SubShader{
			Cull Off ZWrite Off ZTest Always

			// Wobbing
			Pass {
				HLSLPROGRAM

				#pragma vertex VertDefault
				#pragma fragment frag

				float4 frag(VaryingsDefault k) :SV_Target{

					float aspect = _ScreenParams.x / _ScreenParams.y;
					float2 wobbUV = k.texcoord * float2(aspect, 1) * _WobbScale;

					float2 wobb = SAMPLE_TEXTURE2D(_WobbTex, sampler_WobbTex, wobbUV).wy * 2 - 1;

					float4 src = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, k.texcoord + wobb * _WobbPower);

					return src;


					}

				ENDHLSL

			}

		// Edge Darkening
			Pass {
				HLSLPROGRAM
				#pragma vertex VertDefault
				#pragma fragment frag

				float4 frag(VaryingsDefault i) : SV_Target {
					float2 uv_offset = _MainTex_TexelSize.xy * _EdgeSize;
				
					float4 src_l = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord + float2(-uv_offset.x, 0));
					float4 src_r = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord + float2(+uv_offset.x, 0));
					float4 src_b = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord + float2(0, -uv_offset.y));
					float4 src_t = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord + float2(0, +uv_offset.y));

					float4 src = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);


					float4 grad = abs(src_r - src_l) + abs(src_b - src_t);
					float intens = saturate(0.333 * (grad.x + grad.y + grad.z));
					float d = _EdgePower * intens + 1;
					return ColorMod(src, d);
				}
				ENDHLSL
			}

			// Paper Layer
			Pass {
				HLSLPROGRAM

				#pragma vertex VertDefault
				#pragma fragment frag

				float4 frag(VaryingsDefault i) : SV_Target {

					float aspect = _ScreenParams.x / _ScreenParams.y;

					float2 paper_uv = i.texcoord * float2(aspect, 1) * _PaperScale;

					float4 src = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);

					float paper = SAMPLE_TEXTURE2D(_PaperTex, sampler_PaperTex, paper_uv).x;

					float d = _PaperPower * (paper - 0.5) + 1;

					return ColorMod(src, d);
				}

				ENDHLSL
			}

	}
}
