Shader "Custom/CartoonLightCustom"
{
		Properties
		{
			_Color("_Color", Color) = (0,0,0,0)
			_Emission("_Emission", Color) = (0,0,0,0)
			_Brightness("_Brightness", Range(0,1)) = 0
			_shadow("_shadow", Range(0,1)) = 0
			_MainTex("MainTex", 2D) = "white" {}
			[HideInInspector] _texcoord("", 2D) = "white" {}
			[HideInInspector] __dirty("", Int) = 1
		}

			SubShader
			{
				Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry" }
				CGINCLUDE
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#pragma target 3.0
				struct Input
				{
					float2 uv_texcoord;
					float3 worldNormal;
					float3 worldPos;
				};

				struct SurfaceOutputCustomLightingCustom
				{
					half3 Albedo;
					half3 Normal;
					half3 Emission;
					half Metallic;
					half Smoothness;
					half Occlusion;
					half Alpha;
					Input SurfInput;
					UnityGIInput GIData;
				};

				uniform sampler2D _MainTex;
				uniform float4 _MainTex_ST;
				uniform float4 _Color;
				uniform float4 _Emission;
				uniform float _shadow;
				uniform float _Brightness;

				inline half4 LightingStandardCustomLighting(inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi)
				{
					UnityGIInput data = s.GIData;
					Input i = s.SurfInput;
					half4 c = 0;
	
					float ase_lightAtten = data.atten;

					float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
					float lerpResult7 = lerp(1.5 , 0.0 , _shadow);
					float3 ase_worldNormal = i.worldNormal;
					float3 ase_worldPos = i.worldPos;


					float3 ase_worldlightDir = normalize(UnityWorldSpaceLightDir(ase_worldPos));

					float dotResult4 = dot(ase_worldNormal , ase_worldlightDir);
					c.rgb = _Emission + ((((tex2D(_MainTex, uv_MainTex) * _Color) * max(lerpResult7 , dotResult4)) + (dotResult4 * _Brightness)) * saturate(ase_lightAtten)).rgb;
					c.a = 1;
					return c;
				}

				inline void LightingStandardCustomLighting_GI(inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi)
				{
					s.GIData = data;
				}

				void surf(Input i , inout SurfaceOutputCustomLightingCustom o)
				{
					o.SurfInput = i;
				}

				ENDCG
				CGPROGRAM
				#pragma surface surf StandardCustomLighting fullforwardshadows 

				ENDCG
				Pass
				{
					Name "ShadowCaster"
					Tags{ "LightMode" = "ShadowCaster" }
					CGPROGRAM
					#pragma vertex vert
					#pragma fragment frag
					#pragma target 3.0
					#pragma multi_compile_shadowcaster
					#pragma multi_compile UNITY_PASS_SHADOWCASTER
					#include "UnityCG.cginc"
					#include "Lighting.cginc"
					struct v2f
					{
						V2F_SHADOW_CASTER;
						float2 customPack1 : TEXCOORD1;
						float3 worldPos : TEXCOORD2;
						float3 worldNormal : TEXCOORD3;
						UNITY_VERTEX_INPUT_INSTANCE_ID

					};
					v2f vert(appdata_full v)
					{
						v2f o;
						UNITY_SETUP_INSTANCE_ID(v);
						UNITY_INITIALIZE_OUTPUT(v2f, o);
						UNITY_TRANSFER_INSTANCE_ID(v, o);
						Input customInputData;
						float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
						half3 worldNormal = UnityObjectToWorldNormal(v.normal);
						o.worldNormal = worldNormal;
						o.customPack1.xy = customInputData.uv_texcoord;
						o.customPack1.xy = v.texcoord;
						o.worldPos = worldPos;
						TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
						return o;
					}
					half4 frag(v2f IN) : SV_Target
					{
						UNITY_SETUP_INSTANCE_ID(IN);
						Input surfIN;
						UNITY_INITIALIZE_OUTPUT(Input, surfIN);
						surfIN.uv_texcoord = IN.customPack1.xy;
						float3 worldPos = IN.worldPos;
						half3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
						surfIN.worldPos = worldPos;
						surfIN.worldNormal = IN.worldNormal;
						SurfaceOutputCustomLightingCustom o;
						UNITY_INITIALIZE_OUTPUT(SurfaceOutputCustomLightingCustom, o)
						surf(surfIN, o);

						SHADOW_CASTER_FRAGMENT(IN)
					}
					ENDCG
				}
			}
	}
