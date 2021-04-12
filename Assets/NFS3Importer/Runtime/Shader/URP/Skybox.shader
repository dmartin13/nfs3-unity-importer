Shader "NFS3Importer/URP/Skybox"
    {
        Properties
        {
            _SkyColor("SkyColor", Color) = (0.3529412, 0.6470588, 1, 1)
            _HorizonColor("HorizonColor", Color) = (0.8666667, 0.8666667, 0.8666667, 0)
            _GroundColor("GroundColor", Color) = (0.282353, 0.282353, 0.282353, 0)
            _HorizonSharpnessSky("HorizonSharpnessSky", Float) = 5
            _HorizonSharpnessGround("HorizonSharpnessGround", Float) = 2
            _AmbientColorSunSide("AmbientColorSunSide", Color) = (1, 1, 1, 1)
            _AmbientColorSunOpposite("AmbientColorSunOpposite", Color) = (1, 1, 1, 1)
            _AmbientColorSharpness("AmbientColorSharpness", Float) = 10
            _HorizonOffset("HorizonOffset", Range(-1, 1)) = 0
            _SkyIntensity("SkyIntensity", Range(0, 1)) = 1
            _SunRadius("SunRadius", Range(0, 1)) = 0.05
            _SunFalloff("SunFalloff", Range(0.001, 1)) = 0.02
            _SunIntensity("SunIntensity", Range(0, 1)) = 1
            [NoScaleOffset]_CloudsTexture("CloudsTexture", 2D) = "black" {}
            [ToggleUI]_AdditiveOrBlend("AdditiveOrBlendClouds", Float) = 1
            _CloudsTiling("CloudsTiling", Float) = 1
            _CloudsFarTiling("CloudsFarTiling", Float) = 0
            _CloudsOffset("CloudsOffset", Vector) = (0, 0, 0, 0)
            _CloudsBrightness("CloudsBrightness", Range(0, 1)) = 1
            _CloudsContrast("CloudsContrast", Range(0, 1)) = 1
            _CloudsColor("CloudsColor", Color) = (1, 1, 1, 0)
            _CloudsCutoff("CloudsCutoff", Range(0, 1)) = 0
            _CloudsFalloff("CloudsFalloff", Range(0.001, 10)) = 0.001
            _CloudsOpacity("CloudsOpacity", Range(0, 1)) = 1
            [ToggleUI]_CloudsHaveFog("CloudsHaveFog", Float) = 0
            [NoScaleOffset]_PixMap("PixMap", 2D) = "black" {}
            _PixMapColor("PixMapColor", Color) = (1, 1, 1, 0)
            _PixMapOffset("PixMapOffset", Float) = 0
            _PixMapTilingV("PixMapTilingV", Float) = 1
            _PixMapTilingU("PixMapTilingU", Float) = 1
            _FogIntensityOnSkybox("FogIntensityOnSkybox", Range(0, 1)) = 0.1
            [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
        }
        SubShader
        {
            Tags
            {
                "RenderPipeline"="UniversalPipeline"
                "RenderType"="Opaque"
                "UniversalMaterialType" = "Unlit"
                "Queue"="Geometry"
            }
            Pass
            {
                Name "Pass"
                Tags
                {
                    // LightMode: <None>
                }
    
                // Render State
                Cull Back
                Blend One Zero
                ZTest LEqual
                ZWrite On
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 2.0
                #pragma only_renderers gles gles3 glcore d3d11
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma shader_feature _ _SAMPLE_GI
                // GraphKeywords: <None>
    
                // Defines
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_UNLIT
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float3 viewDirectionWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 WorldSpaceViewDirection;
                    float3 ObjectSpacePosition;
                    float3 WorldSpacePosition;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.viewDirectionWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.viewDirectionWS = input.interp1.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 _SkyColor;
                float4 _HorizonColor;
                float4 _GroundColor;
                float _HorizonSharpnessSky;
                float _HorizonSharpnessGround;
                float4 _AmbientColorSunSide;
                float4 _AmbientColorSunOpposite;
                float _AmbientColorSharpness;
                float _HorizonOffset;
                float _SkyIntensity;
                float _SunRadius;
                float _SunFalloff;
                float _SunIntensity;
                float4 _CloudsTexture_TexelSize;
                float _AdditiveOrBlend;
                float _CloudsTiling;
                float _CloudsFarTiling;
                float2 _CloudsOffset;
                float _CloudsBrightness;
                float _CloudsContrast;
                float4 _CloudsColor;
                float _CloudsCutoff;
                float _CloudsFalloff;
                float _CloudsOpacity;
                float _CloudsHaveFog;
                float4 _PixMap_TexelSize;
                float4 _PixMapColor;
                float _PixMapOffset;
                float _PixMapTilingV;
                float _PixMapTilingU;
                float _FogIntensityOnSkybox;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_CloudsTexture);
                SAMPLER(sampler_CloudsTexture);
                TEXTURE2D(_PixMap);
                SAMPLER(sampler_PixMap);
    
                // Graph Functions
                
                // 92f5cc04867e6bc979da043d7187c089
                #include "Assets/NFS3Importer/Runtime/Shader/URP/Graphs/CustomLighting.hlsl"
                
                struct Bindings_MainLight_ea19639cbd5b57dae9d81a5e33b525f4
                {
                    float3 WorldSpacePosition;
                };
                
                void SG_MainLight_ea19639cbd5b57dae9d81a5e33b525f4(Bindings_MainLight_ea19639cbd5b57dae9d81a5e33b525f4 IN, out float3 Direction_1, out float3 Color_2, out float DistanceAtten_3, out float ShadowAtten_4)
                {
                    float3 _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_Direction_1;
                    float3 _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_Color_2;
                    float _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_DistanceAtten_3;
                    float _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_ShadowAtten_4;
                    MainLight_float(IN.WorldSpacePosition, _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_Direction_1, _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_Color_2, _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_DistanceAtten_3, _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_ShadowAtten_4);
                    Direction_1 = _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_Direction_1;
                    Color_2 = _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_Color_2;
                    DistanceAtten_3 = _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_DistanceAtten_3;
                    ShadowAtten_4 = _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_ShadowAtten_4;
                }
                
                void Unity_Normalize_float3(float3 In, out float3 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_Negate_float3(float3 In, out float3 Out)
                {
                    Out = -1 * In;
                }
                
                void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
                {
                    Out = dot(A, B);
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_OneMinus_float(float In, out float Out)
                {
                    Out = 1 - In;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Negate_float(float In, out float Out)
                {
                    Out = -1 * In;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Minimum_float(float A, float B, out float Out)
                {
                    Out = min(A, B);
                };
                
                void Unity_Absolute_float(float In, out float Out)
                {
                    Out = abs(In);
                }
                
                void Unity_Power_float(float A, float B, out float Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Normalize_float2(float2 In, out float2 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_Negate_float2(float2 In, out float2 Out)
                {
                    Out = -1 * In;
                }
                
                void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
                {
                    Out = dot(A, B);
                }
                
                void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A / B;
                }
                
                void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Contrast_float(float3 In, float Contrast, out float3 Out)
                {
                    float midpoint = pow(0.5, 2.2);
                    Out =  (In - midpoint) * Contrast + midpoint;
                }
                
                void Unity_Blend_Overlay_float3(float3 Base, float3 Blend, out float3 Out, float Opacity)
                {
                    float3 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
                    float3 result2 = 2.0 * Base * Blend;
                    float3 zeroOrOne = step(Base, 0.5);
                    Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                    Out = lerp(Base, Out, Opacity);
                }
                
                void Unity_Clamp_float3(float3 In, float3 Min, float3 Max, out float3 Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
                {
                    Out = Predicate ? True : False;
                }
                
                void Unity_Fog_float(out float4 Color, out float Density, float3 Position)
                {
                    SHADERGRAPH_FOG(Position, Color, Density);
                }
                
                void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Arctangent2_float(float A, float B, out float Out)
                {
                    Out = atan2(A, B);
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_Arcsine_float(float In, out float Out)
                {
                    Out = asin(In);
                }
                
                void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                {
                    RGBA = float4(R, G, B, A);
                    RGB = float3(R, G, B);
                    RG = float2(R, G);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Saturate_float4(float4 In, out float4 Out)
                {
                    Out = saturate(In);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _Property_6cdd730bc476ae8c8e4f818600a51ba6_Out_0 = _CloudsHaveFog;
                    float _Property_4afa1727096745889652fd3a646ad060_Out_0 = _AdditiveOrBlend;
                    Bindings_MainLight_ea19639cbd5b57dae9d81a5e33b525f4 _MainLight_1674c078010fc38eb0e4e6b600613923;
                    _MainLight_1674c078010fc38eb0e4e6b600613923.WorldSpacePosition = IN.WorldSpacePosition;
                    float3 _MainLight_1674c078010fc38eb0e4e6b600613923_Direction_1;
                    float3 _MainLight_1674c078010fc38eb0e4e6b600613923_Color_2;
                    float _MainLight_1674c078010fc38eb0e4e6b600613923_DistanceAtten_3;
                    float _MainLight_1674c078010fc38eb0e4e6b600613923_ShadowAtten_4;
                    SG_MainLight_ea19639cbd5b57dae9d81a5e33b525f4(_MainLight_1674c078010fc38eb0e4e6b600613923, _MainLight_1674c078010fc38eb0e4e6b600613923_Direction_1, _MainLight_1674c078010fc38eb0e4e6b600613923_Color_2, _MainLight_1674c078010fc38eb0e4e6b600613923_DistanceAtten_3, _MainLight_1674c078010fc38eb0e4e6b600613923_ShadowAtten_4);
                    float3 _Normalize_106e87729f6366829f35a5c170a1f11a_Out_1;
                    Unity_Normalize_float3(IN.WorldSpaceViewDirection, _Normalize_106e87729f6366829f35a5c170a1f11a_Out_1);
                    float3 _Negate_11eeda9518d5ea8e90846c81f528969f_Out_1;
                    Unity_Negate_float3(_MainLight_1674c078010fc38eb0e4e6b600613923_Direction_1, _Negate_11eeda9518d5ea8e90846c81f528969f_Out_1);
                    float _DotProduct_492e6bfb3ee8e38087a8ff45df49cf81_Out_2;
                    Unity_DotProduct_float3(_Normalize_106e87729f6366829f35a5c170a1f11a_Out_1, _Negate_11eeda9518d5ea8e90846c81f528969f_Out_1, _DotProduct_492e6bfb3ee8e38087a8ff45df49cf81_Out_2);
                    float _Clamp_5831f9f011d49083b2b3c29fd831d4a2_Out_3;
                    Unity_Clamp_float(_DotProduct_492e6bfb3ee8e38087a8ff45df49cf81_Out_2, 0, 1, _Clamp_5831f9f011d49083b2b3c29fd831d4a2_Out_3);
                    float _Property_c3f4aa5b4dd52f80a624333e31609de3_Out_0 = _SunRadius;
                    float _Multiply_ebacd8f65361c78cb9bdb871cc66febe_Out_2;
                    Unity_Multiply_float(_Property_c3f4aa5b4dd52f80a624333e31609de3_Out_0, _Property_c3f4aa5b4dd52f80a624333e31609de3_Out_0, _Multiply_ebacd8f65361c78cb9bdb871cc66febe_Out_2);
                    float _OneMinus_cd063fdd4aed4d8da70079de794f1511_Out_1;
                    Unity_OneMinus_float(_Multiply_ebacd8f65361c78cb9bdb871cc66febe_Out_2, _OneMinus_cd063fdd4aed4d8da70079de794f1511_Out_1);
                    float _Property_280cb7edb9c2f38180121e0b498afc69_Out_0 = _SunFalloff;
                    float _Add_178efb861531cd808f449dfefedfa373_Out_2;
                    Unity_Add_float(_Property_c3f4aa5b4dd52f80a624333e31609de3_Out_0, _Property_280cb7edb9c2f38180121e0b498afc69_Out_0, _Add_178efb861531cd808f449dfefedfa373_Out_2);
                    float _Multiply_2fdc206eef817c8793be810572d3a7b0_Out_2;
                    Unity_Multiply_float(_Add_178efb861531cd808f449dfefedfa373_Out_2, _Add_178efb861531cd808f449dfefedfa373_Out_2, _Multiply_2fdc206eef817c8793be810572d3a7b0_Out_2);
                    float _OneMinus_5f1074e9364e118bbceea2a7c58ad337_Out_1;
                    Unity_OneMinus_float(_Multiply_2fdc206eef817c8793be810572d3a7b0_Out_2, _OneMinus_5f1074e9364e118bbceea2a7c58ad337_Out_1);
                    float2 _Vector2_d3804964aa7b46888a6b0e9fca96055c_Out_0 = float2(_OneMinus_cd063fdd4aed4d8da70079de794f1511_Out_1, _OneMinus_5f1074e9364e118bbceea2a7c58ad337_Out_1);
                    float2 _Vector2_dff7ec1d7693c582a10887285323f38f_Out_0 = float2(1, 0);
                    float _Remap_866007041a15ad89865e03c773ab51c9_Out_3;
                    Unity_Remap_float(_Clamp_5831f9f011d49083b2b3c29fd831d4a2_Out_3, _Vector2_d3804964aa7b46888a6b0e9fca96055c_Out_0, _Vector2_dff7ec1d7693c582a10887285323f38f_Out_0, _Remap_866007041a15ad89865e03c773ab51c9_Out_3);
                    float _Clamp_6a9dbe57fd779b808af81994f453ae14_Out_3;
                    Unity_Clamp_float(_Remap_866007041a15ad89865e03c773ab51c9_Out_3, 0, 1, _Clamp_6a9dbe57fd779b808af81994f453ae14_Out_3);
                    float _Property_1f735ec07548808fbe303e2c31f7ecfd_Out_0 = _HorizonOffset;
                    float _Negate_d8852e67199228869d36f955ede5cfb9_Out_1;
                    Unity_Negate_float(_Property_1f735ec07548808fbe303e2c31f7ecfd_Out_0, _Negate_d8852e67199228869d36f955ede5cfb9_Out_1);
                    float3 _Normalize_80f304b664466483adad5af4772611f7_Out_1;
                    Unity_Normalize_float3(IN.WorldSpacePosition, _Normalize_80f304b664466483adad5af4772611f7_Out_1);
                    float _Split_d0be98147c88b087adcced8f9ad450f4_R_1 = _Normalize_80f304b664466483adad5af4772611f7_Out_1[0];
                    float _Split_d0be98147c88b087adcced8f9ad450f4_G_2 = _Normalize_80f304b664466483adad5af4772611f7_Out_1[1];
                    float _Split_d0be98147c88b087adcced8f9ad450f4_B_3 = _Normalize_80f304b664466483adad5af4772611f7_Out_1[2];
                    float _Split_d0be98147c88b087adcced8f9ad450f4_A_4 = 0;
                    float _Add_06ba8778e7827383a4c301d74fabfdd3_Out_2;
                    Unity_Add_float(_Negate_d8852e67199228869d36f955ede5cfb9_Out_1, _Split_d0be98147c88b087adcced8f9ad450f4_G_2, _Add_06ba8778e7827383a4c301d74fabfdd3_Out_2);
                    float _Subtract_fcaff62ff3f25f859c0807b3bb8ee927_Out_2;
                    Unity_Subtract_float(1, _Add_06ba8778e7827383a4c301d74fabfdd3_Out_2, _Subtract_fcaff62ff3f25f859c0807b3bb8ee927_Out_2);
                    float _Minimum_4cbee6c9819a5289beb43e21acdae1a4_Out_2;
                    Unity_Minimum_float(1, _Subtract_fcaff62ff3f25f859c0807b3bb8ee927_Out_2, _Minimum_4cbee6c9819a5289beb43e21acdae1a4_Out_2);
                    float _Clamp_2bbda44fd91d838ba903958d3e96d52c_Out_3;
                    Unity_Clamp_float(_Minimum_4cbee6c9819a5289beb43e21acdae1a4_Out_2, 0, 1, _Clamp_2bbda44fd91d838ba903958d3e96d52c_Out_3);
                    float _Absolute_2dc0eba1e4554879b14fb45b59394ae7_Out_1;
                    Unity_Absolute_float(_Clamp_2bbda44fd91d838ba903958d3e96d52c_Out_3, _Absolute_2dc0eba1e4554879b14fb45b59394ae7_Out_1);
                    float _Property_cf22e7639b4eca83a6c46752170b4043_Out_0 = _HorizonSharpnessSky;
                    float _Absolute_4c948f406cefa98eb8adc076e66e62fa_Out_1;
                    Unity_Absolute_float(_Property_cf22e7639b4eca83a6c46752170b4043_Out_0, _Absolute_4c948f406cefa98eb8adc076e66e62fa_Out_1);
                    float _Power_43bed1fc90c5f884848d42465dd1f147_Out_2;
                    Unity_Power_float(_Absolute_2dc0eba1e4554879b14fb45b59394ae7_Out_1, _Absolute_4c948f406cefa98eb8adc076e66e62fa_Out_1, _Power_43bed1fc90c5f884848d42465dd1f147_Out_2);
                    float _OneMinus_a084c53942f57b8fb62bdd3319b55d09_Out_1;
                    Unity_OneMinus_float(_Power_43bed1fc90c5f884848d42465dd1f147_Out_2, _OneMinus_a084c53942f57b8fb62bdd3319b55d09_Out_1);
                    float _Multiply_083ecdd0ff51ba85b716ccc42969817c_Out_2;
                    Unity_Multiply_float(_Clamp_6a9dbe57fd779b808af81994f453ae14_Out_3, _OneMinus_a084c53942f57b8fb62bdd3319b55d09_Out_1, _Multiply_083ecdd0ff51ba85b716ccc42969817c_Out_2);
                    float3 _Multiply_01f013a34f547e8496578005485d6c5f_Out_2;
                    Unity_Multiply_float(_MainLight_1674c078010fc38eb0e4e6b600613923_Color_2, (_Multiply_083ecdd0ff51ba85b716ccc42969817c_Out_2.xxx), _Multiply_01f013a34f547e8496578005485d6c5f_Out_2);
                    float _Property_5328bf2c8ea71f8da8989f5271e4128d_Out_0 = _SunIntensity;
                    float3 _Multiply_0f259cb699d33383a15b24326509ac27_Out_2;
                    Unity_Multiply_float(_Multiply_01f013a34f547e8496578005485d6c5f_Out_2, (_Property_5328bf2c8ea71f8da8989f5271e4128d_Out_0.xxx), _Multiply_0f259cb699d33383a15b24326509ac27_Out_2);
                    float _Split_1eb0246e5767ae8188e695b866e6c9f6_R_1 = IN.WorldSpaceViewDirection[0];
                    float _Split_1eb0246e5767ae8188e695b866e6c9f6_G_2 = IN.WorldSpaceViewDirection[1];
                    float _Split_1eb0246e5767ae8188e695b866e6c9f6_B_3 = IN.WorldSpaceViewDirection[2];
                    float _Split_1eb0246e5767ae8188e695b866e6c9f6_A_4 = 0;
                    float2 _Vector2_fd5a61ec84ab2387a0c28b4ef8c80bfc_Out_0 = float2(_Split_1eb0246e5767ae8188e695b866e6c9f6_R_1, _Split_1eb0246e5767ae8188e695b866e6c9f6_B_3);
                    float2 _Normalize_f0ba3247cb3081849d0bf9d01b138dba_Out_1;
                    Unity_Normalize_float2(_Vector2_fd5a61ec84ab2387a0c28b4ef8c80bfc_Out_0, _Normalize_f0ba3247cb3081849d0bf9d01b138dba_Out_1);
                    Bindings_MainLight_ea19639cbd5b57dae9d81a5e33b525f4 _MainLight_2b7b6c47811b548baca4c01a8d13d9c9;
                    _MainLight_2b7b6c47811b548baca4c01a8d13d9c9.WorldSpacePosition = IN.WorldSpacePosition;
                    float3 _MainLight_2b7b6c47811b548baca4c01a8d13d9c9_Direction_1;
                    float3 _MainLight_2b7b6c47811b548baca4c01a8d13d9c9_Color_2;
                    float _MainLight_2b7b6c47811b548baca4c01a8d13d9c9_DistanceAtten_3;
                    float _MainLight_2b7b6c47811b548baca4c01a8d13d9c9_ShadowAtten_4;
                    SG_MainLight_ea19639cbd5b57dae9d81a5e33b525f4(_MainLight_2b7b6c47811b548baca4c01a8d13d9c9, _MainLight_2b7b6c47811b548baca4c01a8d13d9c9_Direction_1, _MainLight_2b7b6c47811b548baca4c01a8d13d9c9_Color_2, _MainLight_2b7b6c47811b548baca4c01a8d13d9c9_DistanceAtten_3, _MainLight_2b7b6c47811b548baca4c01a8d13d9c9_ShadowAtten_4);
                    float _Split_ca60176887667286976f2a81e7dd99f3_R_1 = _MainLight_2b7b6c47811b548baca4c01a8d13d9c9_Direction_1[0];
                    float _Split_ca60176887667286976f2a81e7dd99f3_G_2 = _MainLight_2b7b6c47811b548baca4c01a8d13d9c9_Direction_1[1];
                    float _Split_ca60176887667286976f2a81e7dd99f3_B_3 = _MainLight_2b7b6c47811b548baca4c01a8d13d9c9_Direction_1[2];
                    float _Split_ca60176887667286976f2a81e7dd99f3_A_4 = 0;
                    float2 _Vector2_dd21fbd4f18ca68f85a7f979ae6a7c72_Out_0 = float2(_Split_ca60176887667286976f2a81e7dd99f3_R_1, _Split_ca60176887667286976f2a81e7dd99f3_B_3);
                    float2 _Normalize_d6615702f3500383ab0feb1fee8b51aa_Out_1;
                    Unity_Normalize_float2(_Vector2_dd21fbd4f18ca68f85a7f979ae6a7c72_Out_0, _Normalize_d6615702f3500383ab0feb1fee8b51aa_Out_1);
                    float2 _Negate_9d04d7617d1aa68aab4dc0be4a6db24d_Out_1;
                    Unity_Negate_float2(_Normalize_d6615702f3500383ab0feb1fee8b51aa_Out_1, _Negate_9d04d7617d1aa68aab4dc0be4a6db24d_Out_1);
                    float _DotProduct_2f922bcbda3b6f84aa1396f6e4216b45_Out_2;
                    Unity_DotProduct_float2(_Normalize_f0ba3247cb3081849d0bf9d01b138dba_Out_1, _Negate_9d04d7617d1aa68aab4dc0be4a6db24d_Out_1, _DotProduct_2f922bcbda3b6f84aa1396f6e4216b45_Out_2);
                    float _Clamp_e6482ced6ecc1986a735822b672f3f73_Out_3;
                    Unity_Clamp_float(_DotProduct_2f922bcbda3b6f84aa1396f6e4216b45_Out_2, 0, 1, _Clamp_e6482ced6ecc1986a735822b672f3f73_Out_3);
                    float _OneMinus_15e4629e989b258db02eaeaafccdef8b_Out_1;
                    Unity_OneMinus_float(_Clamp_e6482ced6ecc1986a735822b672f3f73_Out_3, _OneMinus_15e4629e989b258db02eaeaafccdef8b_Out_1);
                    float _Property_0334b5dcf965d1898c78a73597c91fac_Out_0 = _AmbientColorSharpness;
                    float _Absolute_072c15c14401da808aa395e70874f4aa_Out_1;
                    Unity_Absolute_float(_Property_0334b5dcf965d1898c78a73597c91fac_Out_0, _Absolute_072c15c14401da808aa395e70874f4aa_Out_1);
                    float _Power_65de6ec7eee12d8180ce05d3ce74e164_Out_2;
                    Unity_Power_float(_Absolute_2dc0eba1e4554879b14fb45b59394ae7_Out_1, _Absolute_072c15c14401da808aa395e70874f4aa_Out_1, _Power_65de6ec7eee12d8180ce05d3ce74e164_Out_2);
                    float _Multiply_3eaa2b045d20c98bb21225169054bdbb_Out_2;
                    Unity_Multiply_float(_OneMinus_15e4629e989b258db02eaeaafccdef8b_Out_1, _Power_65de6ec7eee12d8180ce05d3ce74e164_Out_2, _Multiply_3eaa2b045d20c98bb21225169054bdbb_Out_2);
                    float _Multiply_5e35640adfb2f482b7862be668da2443_Out_2;
                    Unity_Multiply_float(_Multiply_3eaa2b045d20c98bb21225169054bdbb_Out_2, _OneMinus_a084c53942f57b8fb62bdd3319b55d09_Out_1, _Multiply_5e35640adfb2f482b7862be668da2443_Out_2);
                    float4 _Property_381d46d6fc718d8a835aa71237c620fa_Out_0 = _AmbientColorSunOpposite;
                    float4 _Multiply_882769eb04ad5681a7176eb1bee6ee52_Out_2;
                    Unity_Multiply_float((_Multiply_5e35640adfb2f482b7862be668da2443_Out_2.xxxx), _Property_381d46d6fc718d8a835aa71237c620fa_Out_0, _Multiply_882769eb04ad5681a7176eb1bee6ee52_Out_2);
                    float _DotProduct_94b3bc1f37741480a1d015aa57a05c8e_Out_2;
                    Unity_DotProduct_float2(_Normalize_f0ba3247cb3081849d0bf9d01b138dba_Out_1, _Normalize_d6615702f3500383ab0feb1fee8b51aa_Out_1, _DotProduct_94b3bc1f37741480a1d015aa57a05c8e_Out_2);
                    float _Clamp_6f0cad73644d7a869058b28e1604c258_Out_3;
                    Unity_Clamp_float(_DotProduct_94b3bc1f37741480a1d015aa57a05c8e_Out_2, 0, 1, _Clamp_6f0cad73644d7a869058b28e1604c258_Out_3);
                    float _OneMinus_0d257b87b757848eb4218c1224a90622_Out_1;
                    Unity_OneMinus_float(_Clamp_6f0cad73644d7a869058b28e1604c258_Out_3, _OneMinus_0d257b87b757848eb4218c1224a90622_Out_1);
                    float _Multiply_1bb9aa77d07fab818812acb90237009b_Out_2;
                    Unity_Multiply_float(_OneMinus_0d257b87b757848eb4218c1224a90622_Out_1, _Power_65de6ec7eee12d8180ce05d3ce74e164_Out_2, _Multiply_1bb9aa77d07fab818812acb90237009b_Out_2);
                    float _Multiply_a93626ab254697849551e2bc0d7c442b_Out_2;
                    Unity_Multiply_float(_Multiply_1bb9aa77d07fab818812acb90237009b_Out_2, _OneMinus_a084c53942f57b8fb62bdd3319b55d09_Out_1, _Multiply_a93626ab254697849551e2bc0d7c442b_Out_2);
                    float4 _Property_a8ef3b402ae848898ffbf507ccb6ccb2_Out_0 = _AmbientColorSunSide;
                    float4 _Multiply_a8aae2a9bb708a8bb77efb7a710cddd6_Out_2;
                    Unity_Multiply_float((_Multiply_a93626ab254697849551e2bc0d7c442b_Out_2.xxxx), _Property_a8ef3b402ae848898ffbf507ccb6ccb2_Out_0, _Multiply_a8aae2a9bb708a8bb77efb7a710cddd6_Out_2);
                    float _OneMinus_ecdd902e759b5c8abf32511b088e0225_Out_1;
                    Unity_OneMinus_float(_Multiply_5e35640adfb2f482b7862be668da2443_Out_2, _OneMinus_ecdd902e759b5c8abf32511b088e0225_Out_1);
                    float _OneMinus_4b9ef46dceef7c84a46dfee669824a2d_Out_1;
                    Unity_OneMinus_float(_Multiply_a93626ab254697849551e2bc0d7c442b_Out_2, _OneMinus_4b9ef46dceef7c84a46dfee669824a2d_Out_1);
                    float4 _Property_7ec399d3c7a9d98a892918d33e69b68c_Out_0 = _SkyColor;
                    float4 _Multiply_03a132a2dad0f388b8c38f587226a860_Out_2;
                    Unity_Multiply_float(_Property_7ec399d3c7a9d98a892918d33e69b68c_Out_0, (_OneMinus_a084c53942f57b8fb62bdd3319b55d09_Out_1.xxxx), _Multiply_03a132a2dad0f388b8c38f587226a860_Out_2);
                    float4 _Multiply_8ba5bb3d383b028aa7007a3ff464ae56_Out_2;
                    Unity_Multiply_float((_OneMinus_4b9ef46dceef7c84a46dfee669824a2d_Out_1.xxxx), _Multiply_03a132a2dad0f388b8c38f587226a860_Out_2, _Multiply_8ba5bb3d383b028aa7007a3ff464ae56_Out_2);
                    float4 _Multiply_ce8739399081e780a804939196c008e6_Out_2;
                    Unity_Multiply_float((_OneMinus_ecdd902e759b5c8abf32511b088e0225_Out_1.xxxx), _Multiply_8ba5bb3d383b028aa7007a3ff464ae56_Out_2, _Multiply_ce8739399081e780a804939196c008e6_Out_2);
                    float4 _Property_e053ad5f9234cc808a3d192278de9c1c_Out_0 = _HorizonColor;
                    float _OneMinus_2d93b658b622bd83b153a3233a4364d7_Out_1;
                    Unity_OneMinus_float(_OneMinus_a084c53942f57b8fb62bdd3319b55d09_Out_1, _OneMinus_2d93b658b622bd83b153a3233a4364d7_Out_1);
                    float _Add_8b01b78b03c53d81b31d0b748cc1473f_Out_2;
                    Unity_Add_float(1, _Split_d0be98147c88b087adcced8f9ad450f4_G_2, _Add_8b01b78b03c53d81b31d0b748cc1473f_Out_2);
                    float _Minimum_3d487fc14f28338a8659ec2d0692f637_Out_2;
                    Unity_Minimum_float(1, _Add_8b01b78b03c53d81b31d0b748cc1473f_Out_2, _Minimum_3d487fc14f28338a8659ec2d0692f637_Out_2);
                    float _Absolute_a004beb86a244dbf95f0a391a23d7845_Out_1;
                    Unity_Absolute_float(_Minimum_3d487fc14f28338a8659ec2d0692f637_Out_2, _Absolute_a004beb86a244dbf95f0a391a23d7845_Out_1);
                    float _Property_c3d4a02a62710189948668e9a4f81b87_Out_0 = _HorizonSharpnessGround;
                    float _Absolute_a36039bf2edb6a8f8fb4795ff8607259_Out_1;
                    Unity_Absolute_float(_Property_c3d4a02a62710189948668e9a4f81b87_Out_0, _Absolute_a36039bf2edb6a8f8fb4795ff8607259_Out_1);
                    float _Power_68118c95baeccc8d990055cff53e9e78_Out_2;
                    Unity_Power_float(_Absolute_a004beb86a244dbf95f0a391a23d7845_Out_1, _Absolute_a36039bf2edb6a8f8fb4795ff8607259_Out_1, _Power_68118c95baeccc8d990055cff53e9e78_Out_2);
                    float _OneMinus_3fe77a3bc79a4f869cd2e21803770d6a_Out_1;
                    Unity_OneMinus_float(_Power_68118c95baeccc8d990055cff53e9e78_Out_2, _OneMinus_3fe77a3bc79a4f869cd2e21803770d6a_Out_1);
                    float _Subtract_abce996cb5c17889bd3e98a2a4414506_Out_2;
                    Unity_Subtract_float(_OneMinus_2d93b658b622bd83b153a3233a4364d7_Out_1, _OneMinus_3fe77a3bc79a4f869cd2e21803770d6a_Out_1, _Subtract_abce996cb5c17889bd3e98a2a4414506_Out_2);
                    float4 _Multiply_4503a3a42cc1a4839958c8e81a3ab51b_Out_2;
                    Unity_Multiply_float(_Property_e053ad5f9234cc808a3d192278de9c1c_Out_0, (_Subtract_abce996cb5c17889bd3e98a2a4414506_Out_2.xxxx), _Multiply_4503a3a42cc1a4839958c8e81a3ab51b_Out_2);
                    float4 _Add_94097b34603a358eb944c3ab7a3ac543_Out_2;
                    Unity_Add_float4(_Multiply_ce8739399081e780a804939196c008e6_Out_2, _Multiply_4503a3a42cc1a4839958c8e81a3ab51b_Out_2, _Add_94097b34603a358eb944c3ab7a3ac543_Out_2);
                    float4 _Property_cfc737b236664f878b16b97ab2330b87_Out_0 = _GroundColor;
                    float4 _Multiply_d7208a9e842c1784a6b46067bd1c068e_Out_2;
                    Unity_Multiply_float(_Property_cfc737b236664f878b16b97ab2330b87_Out_0, (_OneMinus_3fe77a3bc79a4f869cd2e21803770d6a_Out_1.xxxx), _Multiply_d7208a9e842c1784a6b46067bd1c068e_Out_2);
                    float4 _Add_95a95753e771598ca3848ff72b98a3d2_Out_2;
                    Unity_Add_float4(_Add_94097b34603a358eb944c3ab7a3ac543_Out_2, _Multiply_d7208a9e842c1784a6b46067bd1c068e_Out_2, _Add_95a95753e771598ca3848ff72b98a3d2_Out_2);
                    float4 _Add_56971d882ceaef80b0c7d338a7a5b2f0_Out_2;
                    Unity_Add_float4(_Multiply_a8aae2a9bb708a8bb77efb7a710cddd6_Out_2, _Add_95a95753e771598ca3848ff72b98a3d2_Out_2, _Add_56971d882ceaef80b0c7d338a7a5b2f0_Out_2);
                    float4 _Add_59674a922eacf98b8bae3c928b3b1b18_Out_2;
                    Unity_Add_float4(_Multiply_882769eb04ad5681a7176eb1bee6ee52_Out_2, _Add_56971d882ceaef80b0c7d338a7a5b2f0_Out_2, _Add_59674a922eacf98b8bae3c928b3b1b18_Out_2);
                    float _Property_6be6cbde3fc7f98f866e6f5214bae6ec_Out_0 = _SkyIntensity;
                    float4 _Multiply_e2fd473a8e5f5489a228a6295b85cb69_Out_2;
                    Unity_Multiply_float(_Add_59674a922eacf98b8bae3c928b3b1b18_Out_2, (_Property_6be6cbde3fc7f98f866e6f5214bae6ec_Out_0.xxxx), _Multiply_e2fd473a8e5f5489a228a6295b85cb69_Out_2);
                    float3 _Add_c2d7373c2314958f8d80191577f4a53c_Out_2;
                    Unity_Add_float3(_Multiply_0f259cb699d33383a15b24326509ac27_Out_2, (_Multiply_e2fd473a8e5f5489a228a6295b85cb69_Out_2.xyz), _Add_c2d7373c2314958f8d80191577f4a53c_Out_2);
                    UnityTexture2D _Property_4ff079c907cb178c828f2b80966c220a_Out_0 = UnityBuildTexture2DStructNoScale(_CloudsTexture);
                    float2 _Property_438209e9fe7d05828eb444867877bc96_Out_0 = _CloudsOffset;
                    float _Split_fa20d4eb619805889c1b3e576300949b_R_1 = _Normalize_80f304b664466483adad5af4772611f7_Out_1[0];
                    float _Split_fa20d4eb619805889c1b3e576300949b_G_2 = _Normalize_80f304b664466483adad5af4772611f7_Out_1[1];
                    float _Split_fa20d4eb619805889c1b3e576300949b_B_3 = _Normalize_80f304b664466483adad5af4772611f7_Out_1[2];
                    float _Split_fa20d4eb619805889c1b3e576300949b_A_4 = 0;
                    float2 _Vector2_b8a403750721b58c94534d3ee2911177_Out_0 = float2(_Split_fa20d4eb619805889c1b3e576300949b_R_1, _Split_fa20d4eb619805889c1b3e576300949b_B_3);
                    float _Absolute_2b379ef09b845781954ca341ad6a825e_Out_1;
                    Unity_Absolute_float(_Split_fa20d4eb619805889c1b3e576300949b_G_2, _Absolute_2b379ef09b845781954ca341ad6a825e_Out_1);
                    float _Property_3034a6b7cc2e8b8992a3220ba06bc456_Out_0 = _CloudsFarTiling;
                    float _Absolute_9eba2df4adc4038c98b69e2b671c545c_Out_1;
                    Unity_Absolute_float(_Property_3034a6b7cc2e8b8992a3220ba06bc456_Out_0, _Absolute_9eba2df4adc4038c98b69e2b671c545c_Out_1);
                    float2 _Vector2_8cdf206f906faf8f9faabbbec88cff4f_Out_0 = float2(_Absolute_9eba2df4adc4038c98b69e2b671c545c_Out_1, 1);
                    float _Remap_0142a7fd6f223883b420472af5090016_Out_3;
                    Unity_Remap_float(_Absolute_2b379ef09b845781954ca341ad6a825e_Out_1, float2 (0, 1), _Vector2_8cdf206f906faf8f9faabbbec88cff4f_Out_0, _Remap_0142a7fd6f223883b420472af5090016_Out_3);
                    float2 _Divide_c584b47c95086d89987bf10771d94e31_Out_2;
                    Unity_Divide_float2(_Vector2_b8a403750721b58c94534d3ee2911177_Out_0, (_Remap_0142a7fd6f223883b420472af5090016_Out_3.xx), _Divide_c584b47c95086d89987bf10771d94e31_Out_2);
                    float _Property_2fa3b2f4cfa53284be286bcc050618c4_Out_0 = _CloudsTiling;
                    float2 _Multiply_3175d45900525586a42f936675a7ac03_Out_2;
                    Unity_Multiply_float(_Divide_c584b47c95086d89987bf10771d94e31_Out_2, (_Property_2fa3b2f4cfa53284be286bcc050618c4_Out_0.xx), _Multiply_3175d45900525586a42f936675a7ac03_Out_2);
                    float2 _Add_4074d87d47336f8096db1e1ce1c17c98_Out_2;
                    Unity_Add_float2(_Property_438209e9fe7d05828eb444867877bc96_Out_0, _Multiply_3175d45900525586a42f936675a7ac03_Out_2, _Add_4074d87d47336f8096db1e1ce1c17c98_Out_2);
                    float4 _SampleTexture2D_1d43da7e29a2c88da498e46113287a5c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4ff079c907cb178c828f2b80966c220a_Out_0.tex, _Property_4ff079c907cb178c828f2b80966c220a_Out_0.samplerstate, _Add_4074d87d47336f8096db1e1ce1c17c98_Out_2);
                    float _SampleTexture2D_1d43da7e29a2c88da498e46113287a5c_R_4 = _SampleTexture2D_1d43da7e29a2c88da498e46113287a5c_RGBA_0.r;
                    float _SampleTexture2D_1d43da7e29a2c88da498e46113287a5c_G_5 = _SampleTexture2D_1d43da7e29a2c88da498e46113287a5c_RGBA_0.g;
                    float _SampleTexture2D_1d43da7e29a2c88da498e46113287a5c_B_6 = _SampleTexture2D_1d43da7e29a2c88da498e46113287a5c_RGBA_0.b;
                    float _SampleTexture2D_1d43da7e29a2c88da498e46113287a5c_A_7 = _SampleTexture2D_1d43da7e29a2c88da498e46113287a5c_RGBA_0.a;
                    float _Property_cde5d97592a7f888ae932105d647e427_Out_0 = _CloudsContrast;
                    float3 _Contrast_ab70fdf9bb3a1d8388826540eee1df07_Out_2;
                    Unity_Contrast_float((_SampleTexture2D_1d43da7e29a2c88da498e46113287a5c_RGBA_0.xyz), _Property_cde5d97592a7f888ae932105d647e427_Out_0, _Contrast_ab70fdf9bb3a1d8388826540eee1df07_Out_2);
                    float _Property_6daa3e2a940d7888bf5985fe40db1f3f_Out_0 = _CloudsBrightness;
                    float _Subtract_3c1eb6d1da42f589964fde1cc5eb9994_Out_2;
                    Unity_Subtract_float(_Property_6daa3e2a940d7888bf5985fe40db1f3f_Out_0, 1, _Subtract_3c1eb6d1da42f589964fde1cc5eb9994_Out_2);
                    float3 _Add_95f1ee00bc779f82882b700d0f00d590_Out_2;
                    Unity_Add_float3(_Contrast_ab70fdf9bb3a1d8388826540eee1df07_Out_2, (_Subtract_3c1eb6d1da42f589964fde1cc5eb9994_Out_2.xxx), _Add_95f1ee00bc779f82882b700d0f00d590_Out_2);
                    Bindings_MainLight_ea19639cbd5b57dae9d81a5e33b525f4 _MainLight_bea2094acb577d8db6b573d3360afc53;
                    _MainLight_bea2094acb577d8db6b573d3360afc53.WorldSpacePosition = IN.WorldSpacePosition;
                    float3 _MainLight_bea2094acb577d8db6b573d3360afc53_Direction_1;
                    float3 _MainLight_bea2094acb577d8db6b573d3360afc53_Color_2;
                    float _MainLight_bea2094acb577d8db6b573d3360afc53_DistanceAtten_3;
                    float _MainLight_bea2094acb577d8db6b573d3360afc53_ShadowAtten_4;
                    SG_MainLight_ea19639cbd5b57dae9d81a5e33b525f4(_MainLight_bea2094acb577d8db6b573d3360afc53, _MainLight_bea2094acb577d8db6b573d3360afc53_Direction_1, _MainLight_bea2094acb577d8db6b573d3360afc53_Color_2, _MainLight_bea2094acb577d8db6b573d3360afc53_DistanceAtten_3, _MainLight_bea2094acb577d8db6b573d3360afc53_ShadowAtten_4);
                    float4 _Property_e006ff8afcdf0d86af668641f0620f74_Out_0 = _CloudsColor;
                    float3 _Blend_8cf28ed0fe92c7808e63c20e89b0d780_Out_2;
                    Unity_Blend_Overlay_float3(_MainLight_bea2094acb577d8db6b573d3360afc53_Color_2, (_Property_e006ff8afcdf0d86af668641f0620f74_Out_0.xyz), _Blend_8cf28ed0fe92c7808e63c20e89b0d780_Out_2, 1);
                    float3 _Clamp_c5b42de80314ed898b143044a9ef5078_Out_3;
                    Unity_Clamp_float3(_Blend_8cf28ed0fe92c7808e63c20e89b0d780_Out_2, float3(0, 0, 0), float3(1, 1, 1), _Clamp_c5b42de80314ed898b143044a9ef5078_Out_3);
                    float3 _Multiply_05042963f32bec87b8aa78c8dfae33fe_Out_2;
                    Unity_Multiply_float(_Add_95f1ee00bc779f82882b700d0f00d590_Out_2, _Clamp_c5b42de80314ed898b143044a9ef5078_Out_3, _Multiply_05042963f32bec87b8aa78c8dfae33fe_Out_2);
                    float _Property_d63079f286e9808c9ea4dd3ea1127114_Out_0 = _CloudsCutoff;
                    float _Negate_ee57934645f94984a9ba20af3f00804b_Out_1;
                    Unity_Negate_float(_Property_d63079f286e9808c9ea4dd3ea1127114_Out_0, _Negate_ee57934645f94984a9ba20af3f00804b_Out_1);
                    float _Add_432a8922a41aec8789f765bd80fd1581_Out_2;
                    Unity_Add_float(_Split_fa20d4eb619805889c1b3e576300949b_G_2, _Negate_ee57934645f94984a9ba20af3f00804b_Out_1, _Add_432a8922a41aec8789f765bd80fd1581_Out_2);
                    float _Clamp_5f690c94990c788a8de44102d5b610af_Out_3;
                    Unity_Clamp_float(_Add_432a8922a41aec8789f765bd80fd1581_Out_2, 0, 1, _Clamp_5f690c94990c788a8de44102d5b610af_Out_3);
                    float _Property_84117e0f689d0c828573e6473418648a_Out_0 = _CloudsFalloff;
                    float _Power_3834f4663a90e58eb0bdec5430595fea_Out_2;
                    Unity_Power_float(_Clamp_5f690c94990c788a8de44102d5b610af_Out_3, _Property_84117e0f689d0c828573e6473418648a_Out_0, _Power_3834f4663a90e58eb0bdec5430595fea_Out_2);
                    float _Multiply_62bd64691833778e92c972525b44a49d_Out_2;
                    Unity_Multiply_float(_SampleTexture2D_1d43da7e29a2c88da498e46113287a5c_A_7, _Power_3834f4663a90e58eb0bdec5430595fea_Out_2, _Multiply_62bd64691833778e92c972525b44a49d_Out_2);
                    float _Property_6474db2d2b5c13849b68ce850a798968_Out_0 = _CloudsOpacity;
                    float _Multiply_2d54d9e4e47a4e80bb79a9ad04aeadd3_Out_2;
                    Unity_Multiply_float(_Multiply_62bd64691833778e92c972525b44a49d_Out_2, _Property_6474db2d2b5c13849b68ce850a798968_Out_0, _Multiply_2d54d9e4e47a4e80bb79a9ad04aeadd3_Out_2);
                    float3 _Multiply_4d2f78be50c04c8eacdde788802c8676_Out_2;
                    Unity_Multiply_float(_Multiply_05042963f32bec87b8aa78c8dfae33fe_Out_2, (_Multiply_2d54d9e4e47a4e80bb79a9ad04aeadd3_Out_2.xxx), _Multiply_4d2f78be50c04c8eacdde788802c8676_Out_2);
                    float3 _Add_4fe80f84a0c98a879ef74a9e3494e87c_Out_2;
                    Unity_Add_float3(_Add_c2d7373c2314958f8d80191577f4a53c_Out_2, _Multiply_4d2f78be50c04c8eacdde788802c8676_Out_2, _Add_4fe80f84a0c98a879ef74a9e3494e87c_Out_2);
                    float3 _Blend_11cebb7c6cdfd78790d667e4f435d468_Out_2;
                    Unity_Blend_Overlay_float3(_Add_c2d7373c2314958f8d80191577f4a53c_Out_2, _Multiply_05042963f32bec87b8aa78c8dfae33fe_Out_2, _Blend_11cebb7c6cdfd78790d667e4f435d468_Out_2, _Multiply_2d54d9e4e47a4e80bb79a9ad04aeadd3_Out_2);
                    float3 _Branch_c73a3a8a4ea2bd8c9c1b51bac18188a9_Out_3;
                    Unity_Branch_float3(_Property_4afa1727096745889652fd3a646ad060_Out_0, _Add_4fe80f84a0c98a879ef74a9e3494e87c_Out_2, _Blend_11cebb7c6cdfd78790d667e4f435d468_Out_2, _Branch_c73a3a8a4ea2bd8c9c1b51bac18188a9_Out_3);
                    float4 _Fog_2b53bbb40c980187808f83f2dca8c87c_Color_0;
                    float _Fog_2b53bbb40c980187808f83f2dca8c87c_Density_1;
                    Unity_Fog_float(_Fog_2b53bbb40c980187808f83f2dca8c87c_Color_0, _Fog_2b53bbb40c980187808f83f2dca8c87c_Density_1, IN.ObjectSpacePosition);
                    float _Property_b845b6e513290f81947460352e38a02b_Out_0 = _FogIntensityOnSkybox;
                    float3 _Lerp_ba0cedbfecb8ed8d91aa4446fdfc5f7f_Out_3;
                    Unity_Lerp_float3(_Branch_c73a3a8a4ea2bd8c9c1b51bac18188a9_Out_3, (_Fog_2b53bbb40c980187808f83f2dca8c87c_Color_0.xyz), (_Property_b845b6e513290f81947460352e38a02b_Out_0.xxx), _Lerp_ba0cedbfecb8ed8d91aa4446fdfc5f7f_Out_3);
                    float3 _Branch_ee37586f10d9e683ae933dceb6acb2f8_Out_3;
                    Unity_Branch_float3(_Property_6cdd730bc476ae8c8e4f818600a51ba6_Out_0, _Lerp_ba0cedbfecb8ed8d91aa4446fdfc5f7f_Out_3, _Branch_c73a3a8a4ea2bd8c9c1b51bac18188a9_Out_3, _Branch_ee37586f10d9e683ae933dceb6acb2f8_Out_3);
                    float3 _Clamp_25bb679ace5050889f831b11eae18634_Out_3;
                    Unity_Clamp_float3(_Branch_ee37586f10d9e683ae933dceb6acb2f8_Out_3, float3(0, 0, 0), float3(1, 1, 1), _Clamp_25bb679ace5050889f831b11eae18634_Out_3);
                    UnityTexture2D _Property_8a4bb4717b58918ebc0e11867070fd07_Out_0 = UnityBuildTexture2DStructNoScale(_PixMap);
                    float _Split_d8cf36b85c736082b11ae447fa003154_R_1 = _Normalize_80f304b664466483adad5af4772611f7_Out_1[0];
                    float _Split_d8cf36b85c736082b11ae447fa003154_G_2 = _Normalize_80f304b664466483adad5af4772611f7_Out_1[1];
                    float _Split_d8cf36b85c736082b11ae447fa003154_B_3 = _Normalize_80f304b664466483adad5af4772611f7_Out_1[2];
                    float _Split_d8cf36b85c736082b11ae447fa003154_A_4 = 0;
                    float _Arctangent2_dd7d560e5a9e738982965e88e7411314_Out_2;
                    Unity_Arctangent2_float(_Split_d8cf36b85c736082b11ae447fa003154_R_1, _Split_d8cf36b85c736082b11ae447fa003154_B_3, _Arctangent2_dd7d560e5a9e738982965e88e7411314_Out_2);
                    float Constant_6e4f17e0960bda8ea5050dbb7eeab61a = 6.283185;
                    float _Divide_c2c3603e004fa282ae12f4d0863a5ed7_Out_2;
                    Unity_Divide_float(_Arctangent2_dd7d560e5a9e738982965e88e7411314_Out_2, Constant_6e4f17e0960bda8ea5050dbb7eeab61a, _Divide_c2c3603e004fa282ae12f4d0863a5ed7_Out_2);
                    float _Property_2a560148b0b5ae82b596ce19f5c0b930_Out_0 = _PixMapTilingU;
                    float _Multiply_d4373a4c5185688984b6cec0ced0fe11_Out_2;
                    Unity_Multiply_float(_Divide_c2c3603e004fa282ae12f4d0863a5ed7_Out_2, _Property_2a560148b0b5ae82b596ce19f5c0b930_Out_0, _Multiply_d4373a4c5185688984b6cec0ced0fe11_Out_2);
                    float _Arcsine_031c4549ce6ecb8cbfa3cf30798b2615_Out_1;
                    Unity_Arcsine_float(_Split_d8cf36b85c736082b11ae447fa003154_G_2, _Arcsine_031c4549ce6ecb8cbfa3cf30798b2615_Out_1);
                    float Constant_ae78797e4c684e8da9c3aebe502831cb = 3.141593;
                    float _Divide_d51129e052abf68bbb7f80b93d53f8ef_Out_2;
                    Unity_Divide_float(Constant_ae78797e4c684e8da9c3aebe502831cb, 2, _Divide_d51129e052abf68bbb7f80b93d53f8ef_Out_2);
                    float _Divide_9ea6a6006a15d28280d88fb2c41a8143_Out_2;
                    Unity_Divide_float(_Arcsine_031c4549ce6ecb8cbfa3cf30798b2615_Out_1, _Divide_d51129e052abf68bbb7f80b93d53f8ef_Out_2, _Divide_9ea6a6006a15d28280d88fb2c41a8143_Out_2);
                    float _Property_41088d012c1ed983b4907cb84a1554ac_Out_0 = _PixMapOffset;
                    float _Negate_65bf95124c3ba68ca257109d393d8a77_Out_1;
                    Unity_Negate_float(_Property_41088d012c1ed983b4907cb84a1554ac_Out_0, _Negate_65bf95124c3ba68ca257109d393d8a77_Out_1);
                    float _Add_7534ac02b0908b8a9ea1e18c493650f2_Out_2;
                    Unity_Add_float(_Divide_9ea6a6006a15d28280d88fb2c41a8143_Out_2, _Negate_65bf95124c3ba68ca257109d393d8a77_Out_1, _Add_7534ac02b0908b8a9ea1e18c493650f2_Out_2);
                    float _Property_3474a95210bff988a84fca0d824e182b_Out_0 = _PixMapTilingV;
                    float _Multiply_4202f70be2925782a183a21c093bfe8c_Out_2;
                    Unity_Multiply_float(_Add_7534ac02b0908b8a9ea1e18c493650f2_Out_2, _Property_3474a95210bff988a84fca0d824e182b_Out_0, _Multiply_4202f70be2925782a183a21c093bfe8c_Out_2);
                    float4 _Combine_ec74633c191b3b869b64b8b4986681a5_RGBA_4;
                    float3 _Combine_ec74633c191b3b869b64b8b4986681a5_RGB_5;
                    float2 _Combine_ec74633c191b3b869b64b8b4986681a5_RG_6;
                    Unity_Combine_float(_Multiply_d4373a4c5185688984b6cec0ced0fe11_Out_2, _Multiply_4202f70be2925782a183a21c093bfe8c_Out_2, 0, 0, _Combine_ec74633c191b3b869b64b8b4986681a5_RGBA_4, _Combine_ec74633c191b3b869b64b8b4986681a5_RGB_5, _Combine_ec74633c191b3b869b64b8b4986681a5_RG_6);
                    float4 _SampleTexture2D_29ceb406e933a78688f670c1b3b5661e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_8a4bb4717b58918ebc0e11867070fd07_Out_0.tex, _Property_8a4bb4717b58918ebc0e11867070fd07_Out_0.samplerstate, _Combine_ec74633c191b3b869b64b8b4986681a5_RG_6);
                    float _SampleTexture2D_29ceb406e933a78688f670c1b3b5661e_R_4 = _SampleTexture2D_29ceb406e933a78688f670c1b3b5661e_RGBA_0.r;
                    float _SampleTexture2D_29ceb406e933a78688f670c1b3b5661e_G_5 = _SampleTexture2D_29ceb406e933a78688f670c1b3b5661e_RGBA_0.g;
                    float _SampleTexture2D_29ceb406e933a78688f670c1b3b5661e_B_6 = _SampleTexture2D_29ceb406e933a78688f670c1b3b5661e_RGBA_0.b;
                    float _SampleTexture2D_29ceb406e933a78688f670c1b3b5661e_A_7 = _SampleTexture2D_29ceb406e933a78688f670c1b3b5661e_RGBA_0.a;
                    float _Float_e1c62dd18545388a99b1dceb5912e75d_Out_0 = _SampleTexture2D_29ceb406e933a78688f670c1b3b5661e_A_7;
                    float _OneMinus_cfdcfdadcb46c485a3fde33f9b1bb9ef_Out_1;
                    Unity_OneMinus_float(_Float_e1c62dd18545388a99b1dceb5912e75d_Out_0, _OneMinus_cfdcfdadcb46c485a3fde33f9b1bb9ef_Out_1);
                    float3 _Multiply_0840d5ffd7a0a483afbba997e9142b96_Out_2;
                    Unity_Multiply_float(_Clamp_25bb679ace5050889f831b11eae18634_Out_3, (_OneMinus_cfdcfdadcb46c485a3fde33f9b1bb9ef_Out_1.xxx), _Multiply_0840d5ffd7a0a483afbba997e9142b96_Out_2);
                    float4 _Property_ae581dbb4ef69e8eb9786c4505009838_Out_0 = _PixMapColor;
                    float4 _Multiply_70697d37a370b98d8fdb551d653a4ace_Out_2;
                    Unity_Multiply_float(_Property_ae581dbb4ef69e8eb9786c4505009838_Out_0, _SampleTexture2D_29ceb406e933a78688f670c1b3b5661e_RGBA_0, _Multiply_70697d37a370b98d8fdb551d653a4ace_Out_2);
                    float4 _Lerp_8ae7b3c34725af89921b0685d2404fe4_Out_3;
                    Unity_Lerp_float4(_Multiply_70697d37a370b98d8fdb551d653a4ace_Out_2, _Fog_2b53bbb40c980187808f83f2dca8c87c_Color_0, (_Property_b845b6e513290f81947460352e38a02b_Out_0.xxxx), _Lerp_8ae7b3c34725af89921b0685d2404fe4_Out_3);
                    float4 _Saturate_e57d05317b94548d999a85c2b4bbe632_Out_1;
                    Unity_Saturate_float4(_Lerp_8ae7b3c34725af89921b0685d2404fe4_Out_3, _Saturate_e57d05317b94548d999a85c2b4bbe632_Out_1);
                    float4 _Multiply_7ea33ddc36101f87a11f5347318e99e6_Out_2;
                    Unity_Multiply_float((_Float_e1c62dd18545388a99b1dceb5912e75d_Out_0.xxxx), _Saturate_e57d05317b94548d999a85c2b4bbe632_Out_1, _Multiply_7ea33ddc36101f87a11f5347318e99e6_Out_2);
                    float3 _Add_72f48bf2ead0c6888884fc97acfb9504_Out_2;
                    Unity_Add_float3(_Multiply_0840d5ffd7a0a483afbba997e9142b96_Out_2, (_Multiply_7ea33ddc36101f87a11f5347318e99e6_Out_2.xyz), _Add_72f48bf2ead0c6888884fc97acfb9504_Out_2);
                    surface.BaseColor = _Add_72f48bf2ead0c6888884fc97acfb9504_Out_2;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                
                
                    output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
                    output.WorldSpacePosition =          input.positionWS;
                    output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "ShadowCaster"
                Tags
                {
                    "LightMode" = "ShadowCaster"
                }
    
                // Render State
                Cull Back
                Blend One Zero
                ZTest LEqual
                ZWrite On
                ColorMask 0
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 2.0
                #pragma only_renderers gles gles3 glcore d3d11
                #pragma multi_compile_instancing
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_SHADOWCASTER
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 _SkyColor;
                float4 _HorizonColor;
                float4 _GroundColor;
                float _HorizonSharpnessSky;
                float _HorizonSharpnessGround;
                float4 _AmbientColorSunSide;
                float4 _AmbientColorSunOpposite;
                float _AmbientColorSharpness;
                float _HorizonOffset;
                float _SkyIntensity;
                float _SunRadius;
                float _SunFalloff;
                float _SunIntensity;
                float4 _CloudsTexture_TexelSize;
                float _AdditiveOrBlend;
                float _CloudsTiling;
                float _CloudsFarTiling;
                float2 _CloudsOffset;
                float _CloudsBrightness;
                float _CloudsContrast;
                float4 _CloudsColor;
                float _CloudsCutoff;
                float _CloudsFalloff;
                float _CloudsOpacity;
                float _CloudsHaveFog;
                float4 _PixMap_TexelSize;
                float4 _PixMapColor;
                float _PixMapOffset;
                float _PixMapTilingV;
                float _PixMapTilingU;
                float _FogIntensityOnSkybox;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_CloudsTexture);
                SAMPLER(sampler_CloudsTexture);
                TEXTURE2D(_PixMap);
                SAMPLER(sampler_PixMap);
    
                // Graph Functions
                // GraphFunctions: <None>
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                
                
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "DepthOnly"
                Tags
                {
                    "LightMode" = "DepthOnly"
                }
    
                // Render State
                Cull Back
                Blend One Zero
                ZTest LEqual
                ZWrite On
                ColorMask 0
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 2.0
                #pragma only_renderers gles gles3 glcore d3d11
                #pragma multi_compile_instancing
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_DEPTHONLY
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 _SkyColor;
                float4 _HorizonColor;
                float4 _GroundColor;
                float _HorizonSharpnessSky;
                float _HorizonSharpnessGround;
                float4 _AmbientColorSunSide;
                float4 _AmbientColorSunOpposite;
                float _AmbientColorSharpness;
                float _HorizonOffset;
                float _SkyIntensity;
                float _SunRadius;
                float _SunFalloff;
                float _SunIntensity;
                float4 _CloudsTexture_TexelSize;
                float _AdditiveOrBlend;
                float _CloudsTiling;
                float _CloudsFarTiling;
                float2 _CloudsOffset;
                float _CloudsBrightness;
                float _CloudsContrast;
                float4 _CloudsColor;
                float _CloudsCutoff;
                float _CloudsFalloff;
                float _CloudsOpacity;
                float _CloudsHaveFog;
                float4 _PixMap_TexelSize;
                float4 _PixMapColor;
                float _PixMapOffset;
                float _PixMapTilingV;
                float _PixMapTilingU;
                float _FogIntensityOnSkybox;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_CloudsTexture);
                SAMPLER(sampler_CloudsTexture);
                TEXTURE2D(_PixMap);
                SAMPLER(sampler_PixMap);
    
                // Graph Functions
                // GraphFunctions: <None>
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                
                
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
    
                ENDHLSL
            }
        }
        SubShader
        {
            Tags
            {
                "RenderPipeline"="UniversalPipeline"
                "RenderType"="Opaque"
                "UniversalMaterialType" = "Unlit"
                "Queue"="Geometry"
            }
            Pass
            {
                Name "Pass"
                Tags
                {
                    // LightMode: <None>
                }
    
                // Render State
                Cull Back
                Blend One Zero
                ZTest LEqual
                ZWrite On
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma shader_feature _ _SAMPLE_GI
                // GraphKeywords: <None>
    
                // Defines
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_UNLIT
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float3 viewDirectionWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 WorldSpaceViewDirection;
                    float3 ObjectSpacePosition;
                    float3 WorldSpacePosition;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.viewDirectionWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.viewDirectionWS = input.interp1.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 _SkyColor;
                float4 _HorizonColor;
                float4 _GroundColor;
                float _HorizonSharpnessSky;
                float _HorizonSharpnessGround;
                float4 _AmbientColorSunSide;
                float4 _AmbientColorSunOpposite;
                float _AmbientColorSharpness;
                float _HorizonOffset;
                float _SkyIntensity;
                float _SunRadius;
                float _SunFalloff;
                float _SunIntensity;
                float4 _CloudsTexture_TexelSize;
                float _AdditiveOrBlend;
                float _CloudsTiling;
                float _CloudsFarTiling;
                float2 _CloudsOffset;
                float _CloudsBrightness;
                float _CloudsContrast;
                float4 _CloudsColor;
                float _CloudsCutoff;
                float _CloudsFalloff;
                float _CloudsOpacity;
                float _CloudsHaveFog;
                float4 _PixMap_TexelSize;
                float4 _PixMapColor;
                float _PixMapOffset;
                float _PixMapTilingV;
                float _PixMapTilingU;
                float _FogIntensityOnSkybox;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_CloudsTexture);
                SAMPLER(sampler_CloudsTexture);
                TEXTURE2D(_PixMap);
                SAMPLER(sampler_PixMap);
    
                // Graph Functions
                
                // 92f5cc04867e6bc979da043d7187c089
                #include "Assets/NFS3Importer/Runtime/Shader/URP/Graphs/CustomLighting.hlsl"
                
                struct Bindings_MainLight_ea19639cbd5b57dae9d81a5e33b525f4
                {
                    float3 WorldSpacePosition;
                };
                
                void SG_MainLight_ea19639cbd5b57dae9d81a5e33b525f4(Bindings_MainLight_ea19639cbd5b57dae9d81a5e33b525f4 IN, out float3 Direction_1, out float3 Color_2, out float DistanceAtten_3, out float ShadowAtten_4)
                {
                    float3 _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_Direction_1;
                    float3 _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_Color_2;
                    float _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_DistanceAtten_3;
                    float _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_ShadowAtten_4;
                    MainLight_float(IN.WorldSpacePosition, _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_Direction_1, _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_Color_2, _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_DistanceAtten_3, _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_ShadowAtten_4);
                    Direction_1 = _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_Direction_1;
                    Color_2 = _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_Color_2;
                    DistanceAtten_3 = _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_DistanceAtten_3;
                    ShadowAtten_4 = _MainLightCustomFunction_7b1485d7bdc8368aa5437c2164e097e0_ShadowAtten_4;
                }
                
                void Unity_Normalize_float3(float3 In, out float3 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_Negate_float3(float3 In, out float3 Out)
                {
                    Out = -1 * In;
                }
                
                void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
                {
                    Out = dot(A, B);
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_OneMinus_float(float In, out float Out)
                {
                    Out = 1 - In;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Negate_float(float In, out float Out)
                {
                    Out = -1 * In;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Minimum_float(float A, float B, out float Out)
                {
                    Out = min(A, B);
                };
                
                void Unity_Absolute_float(float In, out float Out)
                {
                    Out = abs(In);
                }
                
                void Unity_Power_float(float A, float B, out float Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Normalize_float2(float2 In, out float2 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_Negate_float2(float2 In, out float2 Out)
                {
                    Out = -1 * In;
                }
                
                void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
                {
                    Out = dot(A, B);
                }
                
                void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A / B;
                }
                
                void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Contrast_float(float3 In, float Contrast, out float3 Out)
                {
                    float midpoint = pow(0.5, 2.2);
                    Out =  (In - midpoint) * Contrast + midpoint;
                }
                
                void Unity_Blend_Overlay_float3(float3 Base, float3 Blend, out float3 Out, float Opacity)
                {
                    float3 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
                    float3 result2 = 2.0 * Base * Blend;
                    float3 zeroOrOne = step(Base, 0.5);
                    Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                    Out = lerp(Base, Out, Opacity);
                }
                
                void Unity_Clamp_float3(float3 In, float3 Min, float3 Max, out float3 Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
                {
                    Out = Predicate ? True : False;
                }
                
                void Unity_Fog_float(out float4 Color, out float Density, float3 Position)
                {
                    SHADERGRAPH_FOG(Position, Color, Density);
                }
                
                void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Arctangent2_float(float A, float B, out float Out)
                {
                    Out = atan2(A, B);
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_Arcsine_float(float In, out float Out)
                {
                    Out = asin(In);
                }
                
                void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                {
                    RGBA = float4(R, G, B, A);
                    RGB = float3(R, G, B);
                    RG = float2(R, G);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Saturate_float4(float4 In, out float4 Out)
                {
                    Out = saturate(In);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _Property_6cdd730bc476ae8c8e4f818600a51ba6_Out_0 = _CloudsHaveFog;
                    float _Property_4afa1727096745889652fd3a646ad060_Out_0 = _AdditiveOrBlend;
                    Bindings_MainLight_ea19639cbd5b57dae9d81a5e33b525f4 _MainLight_1674c078010fc38eb0e4e6b600613923;
                    _MainLight_1674c078010fc38eb0e4e6b600613923.WorldSpacePosition = IN.WorldSpacePosition;
                    float3 _MainLight_1674c078010fc38eb0e4e6b600613923_Direction_1;
                    float3 _MainLight_1674c078010fc38eb0e4e6b600613923_Color_2;
                    float _MainLight_1674c078010fc38eb0e4e6b600613923_DistanceAtten_3;
                    float _MainLight_1674c078010fc38eb0e4e6b600613923_ShadowAtten_4;
                    SG_MainLight_ea19639cbd5b57dae9d81a5e33b525f4(_MainLight_1674c078010fc38eb0e4e6b600613923, _MainLight_1674c078010fc38eb0e4e6b600613923_Direction_1, _MainLight_1674c078010fc38eb0e4e6b600613923_Color_2, _MainLight_1674c078010fc38eb0e4e6b600613923_DistanceAtten_3, _MainLight_1674c078010fc38eb0e4e6b600613923_ShadowAtten_4);
                    float3 _Normalize_106e87729f6366829f35a5c170a1f11a_Out_1;
                    Unity_Normalize_float3(IN.WorldSpaceViewDirection, _Normalize_106e87729f6366829f35a5c170a1f11a_Out_1);
                    float3 _Negate_11eeda9518d5ea8e90846c81f528969f_Out_1;
                    Unity_Negate_float3(_MainLight_1674c078010fc38eb0e4e6b600613923_Direction_1, _Negate_11eeda9518d5ea8e90846c81f528969f_Out_1);
                    float _DotProduct_492e6bfb3ee8e38087a8ff45df49cf81_Out_2;
                    Unity_DotProduct_float3(_Normalize_106e87729f6366829f35a5c170a1f11a_Out_1, _Negate_11eeda9518d5ea8e90846c81f528969f_Out_1, _DotProduct_492e6bfb3ee8e38087a8ff45df49cf81_Out_2);
                    float _Clamp_5831f9f011d49083b2b3c29fd831d4a2_Out_3;
                    Unity_Clamp_float(_DotProduct_492e6bfb3ee8e38087a8ff45df49cf81_Out_2, 0, 1, _Clamp_5831f9f011d49083b2b3c29fd831d4a2_Out_3);
                    float _Property_c3f4aa5b4dd52f80a624333e31609de3_Out_0 = _SunRadius;
                    float _Multiply_ebacd8f65361c78cb9bdb871cc66febe_Out_2;
                    Unity_Multiply_float(_Property_c3f4aa5b4dd52f80a624333e31609de3_Out_0, _Property_c3f4aa5b4dd52f80a624333e31609de3_Out_0, _Multiply_ebacd8f65361c78cb9bdb871cc66febe_Out_2);
                    float _OneMinus_cd063fdd4aed4d8da70079de794f1511_Out_1;
                    Unity_OneMinus_float(_Multiply_ebacd8f65361c78cb9bdb871cc66febe_Out_2, _OneMinus_cd063fdd4aed4d8da70079de794f1511_Out_1);
                    float _Property_280cb7edb9c2f38180121e0b498afc69_Out_0 = _SunFalloff;
                    float _Add_178efb861531cd808f449dfefedfa373_Out_2;
                    Unity_Add_float(_Property_c3f4aa5b4dd52f80a624333e31609de3_Out_0, _Property_280cb7edb9c2f38180121e0b498afc69_Out_0, _Add_178efb861531cd808f449dfefedfa373_Out_2);
                    float _Multiply_2fdc206eef817c8793be810572d3a7b0_Out_2;
                    Unity_Multiply_float(_Add_178efb861531cd808f449dfefedfa373_Out_2, _Add_178efb861531cd808f449dfefedfa373_Out_2, _Multiply_2fdc206eef817c8793be810572d3a7b0_Out_2);
                    float _OneMinus_5f1074e9364e118bbceea2a7c58ad337_Out_1;
                    Unity_OneMinus_float(_Multiply_2fdc206eef817c8793be810572d3a7b0_Out_2, _OneMinus_5f1074e9364e118bbceea2a7c58ad337_Out_1);
                    float2 _Vector2_d3804964aa7b46888a6b0e9fca96055c_Out_0 = float2(_OneMinus_cd063fdd4aed4d8da70079de794f1511_Out_1, _OneMinus_5f1074e9364e118bbceea2a7c58ad337_Out_1);
                    float2 _Vector2_dff7ec1d7693c582a10887285323f38f_Out_0 = float2(1, 0);
                    float _Remap_866007041a15ad89865e03c773ab51c9_Out_3;
                    Unity_Remap_float(_Clamp_5831f9f011d49083b2b3c29fd831d4a2_Out_3, _Vector2_d3804964aa7b46888a6b0e9fca96055c_Out_0, _Vector2_dff7ec1d7693c582a10887285323f38f_Out_0, _Remap_866007041a15ad89865e03c773ab51c9_Out_3);
                    float _Clamp_6a9dbe57fd779b808af81994f453ae14_Out_3;
                    Unity_Clamp_float(_Remap_866007041a15ad89865e03c773ab51c9_Out_3, 0, 1, _Clamp_6a9dbe57fd779b808af81994f453ae14_Out_3);
                    float _Property_1f735ec07548808fbe303e2c31f7ecfd_Out_0 = _HorizonOffset;
                    float _Negate_d8852e67199228869d36f955ede5cfb9_Out_1;
                    Unity_Negate_float(_Property_1f735ec07548808fbe303e2c31f7ecfd_Out_0, _Negate_d8852e67199228869d36f955ede5cfb9_Out_1);
                    float3 _Normalize_80f304b664466483adad5af4772611f7_Out_1;
                    Unity_Normalize_float3(IN.WorldSpacePosition, _Normalize_80f304b664466483adad5af4772611f7_Out_1);
                    float _Split_d0be98147c88b087adcced8f9ad450f4_R_1 = _Normalize_80f304b664466483adad5af4772611f7_Out_1[0];
                    float _Split_d0be98147c88b087adcced8f9ad450f4_G_2 = _Normalize_80f304b664466483adad5af4772611f7_Out_1[1];
                    float _Split_d0be98147c88b087adcced8f9ad450f4_B_3 = _Normalize_80f304b664466483adad5af4772611f7_Out_1[2];
                    float _Split_d0be98147c88b087adcced8f9ad450f4_A_4 = 0;
                    float _Add_06ba8778e7827383a4c301d74fabfdd3_Out_2;
                    Unity_Add_float(_Negate_d8852e67199228869d36f955ede5cfb9_Out_1, _Split_d0be98147c88b087adcced8f9ad450f4_G_2, _Add_06ba8778e7827383a4c301d74fabfdd3_Out_2);
                    float _Subtract_fcaff62ff3f25f859c0807b3bb8ee927_Out_2;
                    Unity_Subtract_float(1, _Add_06ba8778e7827383a4c301d74fabfdd3_Out_2, _Subtract_fcaff62ff3f25f859c0807b3bb8ee927_Out_2);
                    float _Minimum_4cbee6c9819a5289beb43e21acdae1a4_Out_2;
                    Unity_Minimum_float(1, _Subtract_fcaff62ff3f25f859c0807b3bb8ee927_Out_2, _Minimum_4cbee6c9819a5289beb43e21acdae1a4_Out_2);
                    float _Clamp_2bbda44fd91d838ba903958d3e96d52c_Out_3;
                    Unity_Clamp_float(_Minimum_4cbee6c9819a5289beb43e21acdae1a4_Out_2, 0, 1, _Clamp_2bbda44fd91d838ba903958d3e96d52c_Out_3);
                    float _Absolute_2dc0eba1e4554879b14fb45b59394ae7_Out_1;
                    Unity_Absolute_float(_Clamp_2bbda44fd91d838ba903958d3e96d52c_Out_3, _Absolute_2dc0eba1e4554879b14fb45b59394ae7_Out_1);
                    float _Property_cf22e7639b4eca83a6c46752170b4043_Out_0 = _HorizonSharpnessSky;
                    float _Absolute_4c948f406cefa98eb8adc076e66e62fa_Out_1;
                    Unity_Absolute_float(_Property_cf22e7639b4eca83a6c46752170b4043_Out_0, _Absolute_4c948f406cefa98eb8adc076e66e62fa_Out_1);
                    float _Power_43bed1fc90c5f884848d42465dd1f147_Out_2;
                    Unity_Power_float(_Absolute_2dc0eba1e4554879b14fb45b59394ae7_Out_1, _Absolute_4c948f406cefa98eb8adc076e66e62fa_Out_1, _Power_43bed1fc90c5f884848d42465dd1f147_Out_2);
                    float _OneMinus_a084c53942f57b8fb62bdd3319b55d09_Out_1;
                    Unity_OneMinus_float(_Power_43bed1fc90c5f884848d42465dd1f147_Out_2, _OneMinus_a084c53942f57b8fb62bdd3319b55d09_Out_1);
                    float _Multiply_083ecdd0ff51ba85b716ccc42969817c_Out_2;
                    Unity_Multiply_float(_Clamp_6a9dbe57fd779b808af81994f453ae14_Out_3, _OneMinus_a084c53942f57b8fb62bdd3319b55d09_Out_1, _Multiply_083ecdd0ff51ba85b716ccc42969817c_Out_2);
                    float3 _Multiply_01f013a34f547e8496578005485d6c5f_Out_2;
                    Unity_Multiply_float(_MainLight_1674c078010fc38eb0e4e6b600613923_Color_2, (_Multiply_083ecdd0ff51ba85b716ccc42969817c_Out_2.xxx), _Multiply_01f013a34f547e8496578005485d6c5f_Out_2);
                    float _Property_5328bf2c8ea71f8da8989f5271e4128d_Out_0 = _SunIntensity;
                    float3 _Multiply_0f259cb699d33383a15b24326509ac27_Out_2;
                    Unity_Multiply_float(_Multiply_01f013a34f547e8496578005485d6c5f_Out_2, (_Property_5328bf2c8ea71f8da8989f5271e4128d_Out_0.xxx), _Multiply_0f259cb699d33383a15b24326509ac27_Out_2);
                    float _Split_1eb0246e5767ae8188e695b866e6c9f6_R_1 = IN.WorldSpaceViewDirection[0];
                    float _Split_1eb0246e5767ae8188e695b866e6c9f6_G_2 = IN.WorldSpaceViewDirection[1];
                    float _Split_1eb0246e5767ae8188e695b866e6c9f6_B_3 = IN.WorldSpaceViewDirection[2];
                    float _Split_1eb0246e5767ae8188e695b866e6c9f6_A_4 = 0;
                    float2 _Vector2_fd5a61ec84ab2387a0c28b4ef8c80bfc_Out_0 = float2(_Split_1eb0246e5767ae8188e695b866e6c9f6_R_1, _Split_1eb0246e5767ae8188e695b866e6c9f6_B_3);
                    float2 _Normalize_f0ba3247cb3081849d0bf9d01b138dba_Out_1;
                    Unity_Normalize_float2(_Vector2_fd5a61ec84ab2387a0c28b4ef8c80bfc_Out_0, _Normalize_f0ba3247cb3081849d0bf9d01b138dba_Out_1);
                    Bindings_MainLight_ea19639cbd5b57dae9d81a5e33b525f4 _MainLight_2b7b6c47811b548baca4c01a8d13d9c9;
                    _MainLight_2b7b6c47811b548baca4c01a8d13d9c9.WorldSpacePosition = IN.WorldSpacePosition;
                    float3 _MainLight_2b7b6c47811b548baca4c01a8d13d9c9_Direction_1;
                    float3 _MainLight_2b7b6c47811b548baca4c01a8d13d9c9_Color_2;
                    float _MainLight_2b7b6c47811b548baca4c01a8d13d9c9_DistanceAtten_3;
                    float _MainLight_2b7b6c47811b548baca4c01a8d13d9c9_ShadowAtten_4;
                    SG_MainLight_ea19639cbd5b57dae9d81a5e33b525f4(_MainLight_2b7b6c47811b548baca4c01a8d13d9c9, _MainLight_2b7b6c47811b548baca4c01a8d13d9c9_Direction_1, _MainLight_2b7b6c47811b548baca4c01a8d13d9c9_Color_2, _MainLight_2b7b6c47811b548baca4c01a8d13d9c9_DistanceAtten_3, _MainLight_2b7b6c47811b548baca4c01a8d13d9c9_ShadowAtten_4);
                    float _Split_ca60176887667286976f2a81e7dd99f3_R_1 = _MainLight_2b7b6c47811b548baca4c01a8d13d9c9_Direction_1[0];
                    float _Split_ca60176887667286976f2a81e7dd99f3_G_2 = _MainLight_2b7b6c47811b548baca4c01a8d13d9c9_Direction_1[1];
                    float _Split_ca60176887667286976f2a81e7dd99f3_B_3 = _MainLight_2b7b6c47811b548baca4c01a8d13d9c9_Direction_1[2];
                    float _Split_ca60176887667286976f2a81e7dd99f3_A_4 = 0;
                    float2 _Vector2_dd21fbd4f18ca68f85a7f979ae6a7c72_Out_0 = float2(_Split_ca60176887667286976f2a81e7dd99f3_R_1, _Split_ca60176887667286976f2a81e7dd99f3_B_3);
                    float2 _Normalize_d6615702f3500383ab0feb1fee8b51aa_Out_1;
                    Unity_Normalize_float2(_Vector2_dd21fbd4f18ca68f85a7f979ae6a7c72_Out_0, _Normalize_d6615702f3500383ab0feb1fee8b51aa_Out_1);
                    float2 _Negate_9d04d7617d1aa68aab4dc0be4a6db24d_Out_1;
                    Unity_Negate_float2(_Normalize_d6615702f3500383ab0feb1fee8b51aa_Out_1, _Negate_9d04d7617d1aa68aab4dc0be4a6db24d_Out_1);
                    float _DotProduct_2f922bcbda3b6f84aa1396f6e4216b45_Out_2;
                    Unity_DotProduct_float2(_Normalize_f0ba3247cb3081849d0bf9d01b138dba_Out_1, _Negate_9d04d7617d1aa68aab4dc0be4a6db24d_Out_1, _DotProduct_2f922bcbda3b6f84aa1396f6e4216b45_Out_2);
                    float _Clamp_e6482ced6ecc1986a735822b672f3f73_Out_3;
                    Unity_Clamp_float(_DotProduct_2f922bcbda3b6f84aa1396f6e4216b45_Out_2, 0, 1, _Clamp_e6482ced6ecc1986a735822b672f3f73_Out_3);
                    float _OneMinus_15e4629e989b258db02eaeaafccdef8b_Out_1;
                    Unity_OneMinus_float(_Clamp_e6482ced6ecc1986a735822b672f3f73_Out_3, _OneMinus_15e4629e989b258db02eaeaafccdef8b_Out_1);
                    float _Property_0334b5dcf965d1898c78a73597c91fac_Out_0 = _AmbientColorSharpness;
                    float _Absolute_072c15c14401da808aa395e70874f4aa_Out_1;
                    Unity_Absolute_float(_Property_0334b5dcf965d1898c78a73597c91fac_Out_0, _Absolute_072c15c14401da808aa395e70874f4aa_Out_1);
                    float _Power_65de6ec7eee12d8180ce05d3ce74e164_Out_2;
                    Unity_Power_float(_Absolute_2dc0eba1e4554879b14fb45b59394ae7_Out_1, _Absolute_072c15c14401da808aa395e70874f4aa_Out_1, _Power_65de6ec7eee12d8180ce05d3ce74e164_Out_2);
                    float _Multiply_3eaa2b045d20c98bb21225169054bdbb_Out_2;
                    Unity_Multiply_float(_OneMinus_15e4629e989b258db02eaeaafccdef8b_Out_1, _Power_65de6ec7eee12d8180ce05d3ce74e164_Out_2, _Multiply_3eaa2b045d20c98bb21225169054bdbb_Out_2);
                    float _Multiply_5e35640adfb2f482b7862be668da2443_Out_2;
                    Unity_Multiply_float(_Multiply_3eaa2b045d20c98bb21225169054bdbb_Out_2, _OneMinus_a084c53942f57b8fb62bdd3319b55d09_Out_1, _Multiply_5e35640adfb2f482b7862be668da2443_Out_2);
                    float4 _Property_381d46d6fc718d8a835aa71237c620fa_Out_0 = _AmbientColorSunOpposite;
                    float4 _Multiply_882769eb04ad5681a7176eb1bee6ee52_Out_2;
                    Unity_Multiply_float((_Multiply_5e35640adfb2f482b7862be668da2443_Out_2.xxxx), _Property_381d46d6fc718d8a835aa71237c620fa_Out_0, _Multiply_882769eb04ad5681a7176eb1bee6ee52_Out_2);
                    float _DotProduct_94b3bc1f37741480a1d015aa57a05c8e_Out_2;
                    Unity_DotProduct_float2(_Normalize_f0ba3247cb3081849d0bf9d01b138dba_Out_1, _Normalize_d6615702f3500383ab0feb1fee8b51aa_Out_1, _DotProduct_94b3bc1f37741480a1d015aa57a05c8e_Out_2);
                    float _Clamp_6f0cad73644d7a869058b28e1604c258_Out_3;
                    Unity_Clamp_float(_DotProduct_94b3bc1f37741480a1d015aa57a05c8e_Out_2, 0, 1, _Clamp_6f0cad73644d7a869058b28e1604c258_Out_3);
                    float _OneMinus_0d257b87b757848eb4218c1224a90622_Out_1;
                    Unity_OneMinus_float(_Clamp_6f0cad73644d7a869058b28e1604c258_Out_3, _OneMinus_0d257b87b757848eb4218c1224a90622_Out_1);
                    float _Multiply_1bb9aa77d07fab818812acb90237009b_Out_2;
                    Unity_Multiply_float(_OneMinus_0d257b87b757848eb4218c1224a90622_Out_1, _Power_65de6ec7eee12d8180ce05d3ce74e164_Out_2, _Multiply_1bb9aa77d07fab818812acb90237009b_Out_2);
                    float _Multiply_a93626ab254697849551e2bc0d7c442b_Out_2;
                    Unity_Multiply_float(_Multiply_1bb9aa77d07fab818812acb90237009b_Out_2, _OneMinus_a084c53942f57b8fb62bdd3319b55d09_Out_1, _Multiply_a93626ab254697849551e2bc0d7c442b_Out_2);
                    float4 _Property_a8ef3b402ae848898ffbf507ccb6ccb2_Out_0 = _AmbientColorSunSide;
                    float4 _Multiply_a8aae2a9bb708a8bb77efb7a710cddd6_Out_2;
                    Unity_Multiply_float((_Multiply_a93626ab254697849551e2bc0d7c442b_Out_2.xxxx), _Property_a8ef3b402ae848898ffbf507ccb6ccb2_Out_0, _Multiply_a8aae2a9bb708a8bb77efb7a710cddd6_Out_2);
                    float _OneMinus_ecdd902e759b5c8abf32511b088e0225_Out_1;
                    Unity_OneMinus_float(_Multiply_5e35640adfb2f482b7862be668da2443_Out_2, _OneMinus_ecdd902e759b5c8abf32511b088e0225_Out_1);
                    float _OneMinus_4b9ef46dceef7c84a46dfee669824a2d_Out_1;
                    Unity_OneMinus_float(_Multiply_a93626ab254697849551e2bc0d7c442b_Out_2, _OneMinus_4b9ef46dceef7c84a46dfee669824a2d_Out_1);
                    float4 _Property_7ec399d3c7a9d98a892918d33e69b68c_Out_0 = _SkyColor;
                    float4 _Multiply_03a132a2dad0f388b8c38f587226a860_Out_2;
                    Unity_Multiply_float(_Property_7ec399d3c7a9d98a892918d33e69b68c_Out_0, (_OneMinus_a084c53942f57b8fb62bdd3319b55d09_Out_1.xxxx), _Multiply_03a132a2dad0f388b8c38f587226a860_Out_2);
                    float4 _Multiply_8ba5bb3d383b028aa7007a3ff464ae56_Out_2;
                    Unity_Multiply_float((_OneMinus_4b9ef46dceef7c84a46dfee669824a2d_Out_1.xxxx), _Multiply_03a132a2dad0f388b8c38f587226a860_Out_2, _Multiply_8ba5bb3d383b028aa7007a3ff464ae56_Out_2);
                    float4 _Multiply_ce8739399081e780a804939196c008e6_Out_2;
                    Unity_Multiply_float((_OneMinus_ecdd902e759b5c8abf32511b088e0225_Out_1.xxxx), _Multiply_8ba5bb3d383b028aa7007a3ff464ae56_Out_2, _Multiply_ce8739399081e780a804939196c008e6_Out_2);
                    float4 _Property_e053ad5f9234cc808a3d192278de9c1c_Out_0 = _HorizonColor;
                    float _OneMinus_2d93b658b622bd83b153a3233a4364d7_Out_1;
                    Unity_OneMinus_float(_OneMinus_a084c53942f57b8fb62bdd3319b55d09_Out_1, _OneMinus_2d93b658b622bd83b153a3233a4364d7_Out_1);
                    float _Add_8b01b78b03c53d81b31d0b748cc1473f_Out_2;
                    Unity_Add_float(1, _Split_d0be98147c88b087adcced8f9ad450f4_G_2, _Add_8b01b78b03c53d81b31d0b748cc1473f_Out_2);
                    float _Minimum_3d487fc14f28338a8659ec2d0692f637_Out_2;
                    Unity_Minimum_float(1, _Add_8b01b78b03c53d81b31d0b748cc1473f_Out_2, _Minimum_3d487fc14f28338a8659ec2d0692f637_Out_2);
                    float _Absolute_a004beb86a244dbf95f0a391a23d7845_Out_1;
                    Unity_Absolute_float(_Minimum_3d487fc14f28338a8659ec2d0692f637_Out_2, _Absolute_a004beb86a244dbf95f0a391a23d7845_Out_1);
                    float _Property_c3d4a02a62710189948668e9a4f81b87_Out_0 = _HorizonSharpnessGround;
                    float _Absolute_a36039bf2edb6a8f8fb4795ff8607259_Out_1;
                    Unity_Absolute_float(_Property_c3d4a02a62710189948668e9a4f81b87_Out_0, _Absolute_a36039bf2edb6a8f8fb4795ff8607259_Out_1);
                    float _Power_68118c95baeccc8d990055cff53e9e78_Out_2;
                    Unity_Power_float(_Absolute_a004beb86a244dbf95f0a391a23d7845_Out_1, _Absolute_a36039bf2edb6a8f8fb4795ff8607259_Out_1, _Power_68118c95baeccc8d990055cff53e9e78_Out_2);
                    float _OneMinus_3fe77a3bc79a4f869cd2e21803770d6a_Out_1;
                    Unity_OneMinus_float(_Power_68118c95baeccc8d990055cff53e9e78_Out_2, _OneMinus_3fe77a3bc79a4f869cd2e21803770d6a_Out_1);
                    float _Subtract_abce996cb5c17889bd3e98a2a4414506_Out_2;
                    Unity_Subtract_float(_OneMinus_2d93b658b622bd83b153a3233a4364d7_Out_1, _OneMinus_3fe77a3bc79a4f869cd2e21803770d6a_Out_1, _Subtract_abce996cb5c17889bd3e98a2a4414506_Out_2);
                    float4 _Multiply_4503a3a42cc1a4839958c8e81a3ab51b_Out_2;
                    Unity_Multiply_float(_Property_e053ad5f9234cc808a3d192278de9c1c_Out_0, (_Subtract_abce996cb5c17889bd3e98a2a4414506_Out_2.xxxx), _Multiply_4503a3a42cc1a4839958c8e81a3ab51b_Out_2);
                    float4 _Add_94097b34603a358eb944c3ab7a3ac543_Out_2;
                    Unity_Add_float4(_Multiply_ce8739399081e780a804939196c008e6_Out_2, _Multiply_4503a3a42cc1a4839958c8e81a3ab51b_Out_2, _Add_94097b34603a358eb944c3ab7a3ac543_Out_2);
                    float4 _Property_cfc737b236664f878b16b97ab2330b87_Out_0 = _GroundColor;
                    float4 _Multiply_d7208a9e842c1784a6b46067bd1c068e_Out_2;
                    Unity_Multiply_float(_Property_cfc737b236664f878b16b97ab2330b87_Out_0, (_OneMinus_3fe77a3bc79a4f869cd2e21803770d6a_Out_1.xxxx), _Multiply_d7208a9e842c1784a6b46067bd1c068e_Out_2);
                    float4 _Add_95a95753e771598ca3848ff72b98a3d2_Out_2;
                    Unity_Add_float4(_Add_94097b34603a358eb944c3ab7a3ac543_Out_2, _Multiply_d7208a9e842c1784a6b46067bd1c068e_Out_2, _Add_95a95753e771598ca3848ff72b98a3d2_Out_2);
                    float4 _Add_56971d882ceaef80b0c7d338a7a5b2f0_Out_2;
                    Unity_Add_float4(_Multiply_a8aae2a9bb708a8bb77efb7a710cddd6_Out_2, _Add_95a95753e771598ca3848ff72b98a3d2_Out_2, _Add_56971d882ceaef80b0c7d338a7a5b2f0_Out_2);
                    float4 _Add_59674a922eacf98b8bae3c928b3b1b18_Out_2;
                    Unity_Add_float4(_Multiply_882769eb04ad5681a7176eb1bee6ee52_Out_2, _Add_56971d882ceaef80b0c7d338a7a5b2f0_Out_2, _Add_59674a922eacf98b8bae3c928b3b1b18_Out_2);
                    float _Property_6be6cbde3fc7f98f866e6f5214bae6ec_Out_0 = _SkyIntensity;
                    float4 _Multiply_e2fd473a8e5f5489a228a6295b85cb69_Out_2;
                    Unity_Multiply_float(_Add_59674a922eacf98b8bae3c928b3b1b18_Out_2, (_Property_6be6cbde3fc7f98f866e6f5214bae6ec_Out_0.xxxx), _Multiply_e2fd473a8e5f5489a228a6295b85cb69_Out_2);
                    float3 _Add_c2d7373c2314958f8d80191577f4a53c_Out_2;
                    Unity_Add_float3(_Multiply_0f259cb699d33383a15b24326509ac27_Out_2, (_Multiply_e2fd473a8e5f5489a228a6295b85cb69_Out_2.xyz), _Add_c2d7373c2314958f8d80191577f4a53c_Out_2);
                    UnityTexture2D _Property_4ff079c907cb178c828f2b80966c220a_Out_0 = UnityBuildTexture2DStructNoScale(_CloudsTexture);
                    float2 _Property_438209e9fe7d05828eb444867877bc96_Out_0 = _CloudsOffset;
                    float _Split_fa20d4eb619805889c1b3e576300949b_R_1 = _Normalize_80f304b664466483adad5af4772611f7_Out_1[0];
                    float _Split_fa20d4eb619805889c1b3e576300949b_G_2 = _Normalize_80f304b664466483adad5af4772611f7_Out_1[1];
                    float _Split_fa20d4eb619805889c1b3e576300949b_B_3 = _Normalize_80f304b664466483adad5af4772611f7_Out_1[2];
                    float _Split_fa20d4eb619805889c1b3e576300949b_A_4 = 0;
                    float2 _Vector2_b8a403750721b58c94534d3ee2911177_Out_0 = float2(_Split_fa20d4eb619805889c1b3e576300949b_R_1, _Split_fa20d4eb619805889c1b3e576300949b_B_3);
                    float _Absolute_2b379ef09b845781954ca341ad6a825e_Out_1;
                    Unity_Absolute_float(_Split_fa20d4eb619805889c1b3e576300949b_G_2, _Absolute_2b379ef09b845781954ca341ad6a825e_Out_1);
                    float _Property_3034a6b7cc2e8b8992a3220ba06bc456_Out_0 = _CloudsFarTiling;
                    float _Absolute_9eba2df4adc4038c98b69e2b671c545c_Out_1;
                    Unity_Absolute_float(_Property_3034a6b7cc2e8b8992a3220ba06bc456_Out_0, _Absolute_9eba2df4adc4038c98b69e2b671c545c_Out_1);
                    float2 _Vector2_8cdf206f906faf8f9faabbbec88cff4f_Out_0 = float2(_Absolute_9eba2df4adc4038c98b69e2b671c545c_Out_1, 1);
                    float _Remap_0142a7fd6f223883b420472af5090016_Out_3;
                    Unity_Remap_float(_Absolute_2b379ef09b845781954ca341ad6a825e_Out_1, float2 (0, 1), _Vector2_8cdf206f906faf8f9faabbbec88cff4f_Out_0, _Remap_0142a7fd6f223883b420472af5090016_Out_3);
                    float2 _Divide_c584b47c95086d89987bf10771d94e31_Out_2;
                    Unity_Divide_float2(_Vector2_b8a403750721b58c94534d3ee2911177_Out_0, (_Remap_0142a7fd6f223883b420472af5090016_Out_3.xx), _Divide_c584b47c95086d89987bf10771d94e31_Out_2);
                    float _Property_2fa3b2f4cfa53284be286bcc050618c4_Out_0 = _CloudsTiling;
                    float2 _Multiply_3175d45900525586a42f936675a7ac03_Out_2;
                    Unity_Multiply_float(_Divide_c584b47c95086d89987bf10771d94e31_Out_2, (_Property_2fa3b2f4cfa53284be286bcc050618c4_Out_0.xx), _Multiply_3175d45900525586a42f936675a7ac03_Out_2);
                    float2 _Add_4074d87d47336f8096db1e1ce1c17c98_Out_2;
                    Unity_Add_float2(_Property_438209e9fe7d05828eb444867877bc96_Out_0, _Multiply_3175d45900525586a42f936675a7ac03_Out_2, _Add_4074d87d47336f8096db1e1ce1c17c98_Out_2);
                    float4 _SampleTexture2D_1d43da7e29a2c88da498e46113287a5c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4ff079c907cb178c828f2b80966c220a_Out_0.tex, _Property_4ff079c907cb178c828f2b80966c220a_Out_0.samplerstate, _Add_4074d87d47336f8096db1e1ce1c17c98_Out_2);
                    float _SampleTexture2D_1d43da7e29a2c88da498e46113287a5c_R_4 = _SampleTexture2D_1d43da7e29a2c88da498e46113287a5c_RGBA_0.r;
                    float _SampleTexture2D_1d43da7e29a2c88da498e46113287a5c_G_5 = _SampleTexture2D_1d43da7e29a2c88da498e46113287a5c_RGBA_0.g;
                    float _SampleTexture2D_1d43da7e29a2c88da498e46113287a5c_B_6 = _SampleTexture2D_1d43da7e29a2c88da498e46113287a5c_RGBA_0.b;
                    float _SampleTexture2D_1d43da7e29a2c88da498e46113287a5c_A_7 = _SampleTexture2D_1d43da7e29a2c88da498e46113287a5c_RGBA_0.a;
                    float _Property_cde5d97592a7f888ae932105d647e427_Out_0 = _CloudsContrast;
                    float3 _Contrast_ab70fdf9bb3a1d8388826540eee1df07_Out_2;
                    Unity_Contrast_float((_SampleTexture2D_1d43da7e29a2c88da498e46113287a5c_RGBA_0.xyz), _Property_cde5d97592a7f888ae932105d647e427_Out_0, _Contrast_ab70fdf9bb3a1d8388826540eee1df07_Out_2);
                    float _Property_6daa3e2a940d7888bf5985fe40db1f3f_Out_0 = _CloudsBrightness;
                    float _Subtract_3c1eb6d1da42f589964fde1cc5eb9994_Out_2;
                    Unity_Subtract_float(_Property_6daa3e2a940d7888bf5985fe40db1f3f_Out_0, 1, _Subtract_3c1eb6d1da42f589964fde1cc5eb9994_Out_2);
                    float3 _Add_95f1ee00bc779f82882b700d0f00d590_Out_2;
                    Unity_Add_float3(_Contrast_ab70fdf9bb3a1d8388826540eee1df07_Out_2, (_Subtract_3c1eb6d1da42f589964fde1cc5eb9994_Out_2.xxx), _Add_95f1ee00bc779f82882b700d0f00d590_Out_2);
                    Bindings_MainLight_ea19639cbd5b57dae9d81a5e33b525f4 _MainLight_bea2094acb577d8db6b573d3360afc53;
                    _MainLight_bea2094acb577d8db6b573d3360afc53.WorldSpacePosition = IN.WorldSpacePosition;
                    float3 _MainLight_bea2094acb577d8db6b573d3360afc53_Direction_1;
                    float3 _MainLight_bea2094acb577d8db6b573d3360afc53_Color_2;
                    float _MainLight_bea2094acb577d8db6b573d3360afc53_DistanceAtten_3;
                    float _MainLight_bea2094acb577d8db6b573d3360afc53_ShadowAtten_4;
                    SG_MainLight_ea19639cbd5b57dae9d81a5e33b525f4(_MainLight_bea2094acb577d8db6b573d3360afc53, _MainLight_bea2094acb577d8db6b573d3360afc53_Direction_1, _MainLight_bea2094acb577d8db6b573d3360afc53_Color_2, _MainLight_bea2094acb577d8db6b573d3360afc53_DistanceAtten_3, _MainLight_bea2094acb577d8db6b573d3360afc53_ShadowAtten_4);
                    float4 _Property_e006ff8afcdf0d86af668641f0620f74_Out_0 = _CloudsColor;
                    float3 _Blend_8cf28ed0fe92c7808e63c20e89b0d780_Out_2;
                    Unity_Blend_Overlay_float3(_MainLight_bea2094acb577d8db6b573d3360afc53_Color_2, (_Property_e006ff8afcdf0d86af668641f0620f74_Out_0.xyz), _Blend_8cf28ed0fe92c7808e63c20e89b0d780_Out_2, 1);
                    float3 _Clamp_c5b42de80314ed898b143044a9ef5078_Out_3;
                    Unity_Clamp_float3(_Blend_8cf28ed0fe92c7808e63c20e89b0d780_Out_2, float3(0, 0, 0), float3(1, 1, 1), _Clamp_c5b42de80314ed898b143044a9ef5078_Out_3);
                    float3 _Multiply_05042963f32bec87b8aa78c8dfae33fe_Out_2;
                    Unity_Multiply_float(_Add_95f1ee00bc779f82882b700d0f00d590_Out_2, _Clamp_c5b42de80314ed898b143044a9ef5078_Out_3, _Multiply_05042963f32bec87b8aa78c8dfae33fe_Out_2);
                    float _Property_d63079f286e9808c9ea4dd3ea1127114_Out_0 = _CloudsCutoff;
                    float _Negate_ee57934645f94984a9ba20af3f00804b_Out_1;
                    Unity_Negate_float(_Property_d63079f286e9808c9ea4dd3ea1127114_Out_0, _Negate_ee57934645f94984a9ba20af3f00804b_Out_1);
                    float _Add_432a8922a41aec8789f765bd80fd1581_Out_2;
                    Unity_Add_float(_Split_fa20d4eb619805889c1b3e576300949b_G_2, _Negate_ee57934645f94984a9ba20af3f00804b_Out_1, _Add_432a8922a41aec8789f765bd80fd1581_Out_2);
                    float _Clamp_5f690c94990c788a8de44102d5b610af_Out_3;
                    Unity_Clamp_float(_Add_432a8922a41aec8789f765bd80fd1581_Out_2, 0, 1, _Clamp_5f690c94990c788a8de44102d5b610af_Out_3);
                    float _Property_84117e0f689d0c828573e6473418648a_Out_0 = _CloudsFalloff;
                    float _Power_3834f4663a90e58eb0bdec5430595fea_Out_2;
                    Unity_Power_float(_Clamp_5f690c94990c788a8de44102d5b610af_Out_3, _Property_84117e0f689d0c828573e6473418648a_Out_0, _Power_3834f4663a90e58eb0bdec5430595fea_Out_2);
                    float _Multiply_62bd64691833778e92c972525b44a49d_Out_2;
                    Unity_Multiply_float(_SampleTexture2D_1d43da7e29a2c88da498e46113287a5c_A_7, _Power_3834f4663a90e58eb0bdec5430595fea_Out_2, _Multiply_62bd64691833778e92c972525b44a49d_Out_2);
                    float _Property_6474db2d2b5c13849b68ce850a798968_Out_0 = _CloudsOpacity;
                    float _Multiply_2d54d9e4e47a4e80bb79a9ad04aeadd3_Out_2;
                    Unity_Multiply_float(_Multiply_62bd64691833778e92c972525b44a49d_Out_2, _Property_6474db2d2b5c13849b68ce850a798968_Out_0, _Multiply_2d54d9e4e47a4e80bb79a9ad04aeadd3_Out_2);
                    float3 _Multiply_4d2f78be50c04c8eacdde788802c8676_Out_2;
                    Unity_Multiply_float(_Multiply_05042963f32bec87b8aa78c8dfae33fe_Out_2, (_Multiply_2d54d9e4e47a4e80bb79a9ad04aeadd3_Out_2.xxx), _Multiply_4d2f78be50c04c8eacdde788802c8676_Out_2);
                    float3 _Add_4fe80f84a0c98a879ef74a9e3494e87c_Out_2;
                    Unity_Add_float3(_Add_c2d7373c2314958f8d80191577f4a53c_Out_2, _Multiply_4d2f78be50c04c8eacdde788802c8676_Out_2, _Add_4fe80f84a0c98a879ef74a9e3494e87c_Out_2);
                    float3 _Blend_11cebb7c6cdfd78790d667e4f435d468_Out_2;
                    Unity_Blend_Overlay_float3(_Add_c2d7373c2314958f8d80191577f4a53c_Out_2, _Multiply_05042963f32bec87b8aa78c8dfae33fe_Out_2, _Blend_11cebb7c6cdfd78790d667e4f435d468_Out_2, _Multiply_2d54d9e4e47a4e80bb79a9ad04aeadd3_Out_2);
                    float3 _Branch_c73a3a8a4ea2bd8c9c1b51bac18188a9_Out_3;
                    Unity_Branch_float3(_Property_4afa1727096745889652fd3a646ad060_Out_0, _Add_4fe80f84a0c98a879ef74a9e3494e87c_Out_2, _Blend_11cebb7c6cdfd78790d667e4f435d468_Out_2, _Branch_c73a3a8a4ea2bd8c9c1b51bac18188a9_Out_3);
                    float4 _Fog_2b53bbb40c980187808f83f2dca8c87c_Color_0;
                    float _Fog_2b53bbb40c980187808f83f2dca8c87c_Density_1;
                    Unity_Fog_float(_Fog_2b53bbb40c980187808f83f2dca8c87c_Color_0, _Fog_2b53bbb40c980187808f83f2dca8c87c_Density_1, IN.ObjectSpacePosition);
                    float _Property_b845b6e513290f81947460352e38a02b_Out_0 = _FogIntensityOnSkybox;
                    float3 _Lerp_ba0cedbfecb8ed8d91aa4446fdfc5f7f_Out_3;
                    Unity_Lerp_float3(_Branch_c73a3a8a4ea2bd8c9c1b51bac18188a9_Out_3, (_Fog_2b53bbb40c980187808f83f2dca8c87c_Color_0.xyz), (_Property_b845b6e513290f81947460352e38a02b_Out_0.xxx), _Lerp_ba0cedbfecb8ed8d91aa4446fdfc5f7f_Out_3);
                    float3 _Branch_ee37586f10d9e683ae933dceb6acb2f8_Out_3;
                    Unity_Branch_float3(_Property_6cdd730bc476ae8c8e4f818600a51ba6_Out_0, _Lerp_ba0cedbfecb8ed8d91aa4446fdfc5f7f_Out_3, _Branch_c73a3a8a4ea2bd8c9c1b51bac18188a9_Out_3, _Branch_ee37586f10d9e683ae933dceb6acb2f8_Out_3);
                    float3 _Clamp_25bb679ace5050889f831b11eae18634_Out_3;
                    Unity_Clamp_float3(_Branch_ee37586f10d9e683ae933dceb6acb2f8_Out_3, float3(0, 0, 0), float3(1, 1, 1), _Clamp_25bb679ace5050889f831b11eae18634_Out_3);
                    UnityTexture2D _Property_8a4bb4717b58918ebc0e11867070fd07_Out_0 = UnityBuildTexture2DStructNoScale(_PixMap);
                    float _Split_d8cf36b85c736082b11ae447fa003154_R_1 = _Normalize_80f304b664466483adad5af4772611f7_Out_1[0];
                    float _Split_d8cf36b85c736082b11ae447fa003154_G_2 = _Normalize_80f304b664466483adad5af4772611f7_Out_1[1];
                    float _Split_d8cf36b85c736082b11ae447fa003154_B_3 = _Normalize_80f304b664466483adad5af4772611f7_Out_1[2];
                    float _Split_d8cf36b85c736082b11ae447fa003154_A_4 = 0;
                    float _Arctangent2_dd7d560e5a9e738982965e88e7411314_Out_2;
                    Unity_Arctangent2_float(_Split_d8cf36b85c736082b11ae447fa003154_R_1, _Split_d8cf36b85c736082b11ae447fa003154_B_3, _Arctangent2_dd7d560e5a9e738982965e88e7411314_Out_2);
                    float Constant_6e4f17e0960bda8ea5050dbb7eeab61a = 6.283185;
                    float _Divide_c2c3603e004fa282ae12f4d0863a5ed7_Out_2;
                    Unity_Divide_float(_Arctangent2_dd7d560e5a9e738982965e88e7411314_Out_2, Constant_6e4f17e0960bda8ea5050dbb7eeab61a, _Divide_c2c3603e004fa282ae12f4d0863a5ed7_Out_2);
                    float _Property_2a560148b0b5ae82b596ce19f5c0b930_Out_0 = _PixMapTilingU;
                    float _Multiply_d4373a4c5185688984b6cec0ced0fe11_Out_2;
                    Unity_Multiply_float(_Divide_c2c3603e004fa282ae12f4d0863a5ed7_Out_2, _Property_2a560148b0b5ae82b596ce19f5c0b930_Out_0, _Multiply_d4373a4c5185688984b6cec0ced0fe11_Out_2);
                    float _Arcsine_031c4549ce6ecb8cbfa3cf30798b2615_Out_1;
                    Unity_Arcsine_float(_Split_d8cf36b85c736082b11ae447fa003154_G_2, _Arcsine_031c4549ce6ecb8cbfa3cf30798b2615_Out_1);
                    float Constant_ae78797e4c684e8da9c3aebe502831cb = 3.141593;
                    float _Divide_d51129e052abf68bbb7f80b93d53f8ef_Out_2;
                    Unity_Divide_float(Constant_ae78797e4c684e8da9c3aebe502831cb, 2, _Divide_d51129e052abf68bbb7f80b93d53f8ef_Out_2);
                    float _Divide_9ea6a6006a15d28280d88fb2c41a8143_Out_2;
                    Unity_Divide_float(_Arcsine_031c4549ce6ecb8cbfa3cf30798b2615_Out_1, _Divide_d51129e052abf68bbb7f80b93d53f8ef_Out_2, _Divide_9ea6a6006a15d28280d88fb2c41a8143_Out_2);
                    float _Property_41088d012c1ed983b4907cb84a1554ac_Out_0 = _PixMapOffset;
                    float _Negate_65bf95124c3ba68ca257109d393d8a77_Out_1;
                    Unity_Negate_float(_Property_41088d012c1ed983b4907cb84a1554ac_Out_0, _Negate_65bf95124c3ba68ca257109d393d8a77_Out_1);
                    float _Add_7534ac02b0908b8a9ea1e18c493650f2_Out_2;
                    Unity_Add_float(_Divide_9ea6a6006a15d28280d88fb2c41a8143_Out_2, _Negate_65bf95124c3ba68ca257109d393d8a77_Out_1, _Add_7534ac02b0908b8a9ea1e18c493650f2_Out_2);
                    float _Property_3474a95210bff988a84fca0d824e182b_Out_0 = _PixMapTilingV;
                    float _Multiply_4202f70be2925782a183a21c093bfe8c_Out_2;
                    Unity_Multiply_float(_Add_7534ac02b0908b8a9ea1e18c493650f2_Out_2, _Property_3474a95210bff988a84fca0d824e182b_Out_0, _Multiply_4202f70be2925782a183a21c093bfe8c_Out_2);
                    float4 _Combine_ec74633c191b3b869b64b8b4986681a5_RGBA_4;
                    float3 _Combine_ec74633c191b3b869b64b8b4986681a5_RGB_5;
                    float2 _Combine_ec74633c191b3b869b64b8b4986681a5_RG_6;
                    Unity_Combine_float(_Multiply_d4373a4c5185688984b6cec0ced0fe11_Out_2, _Multiply_4202f70be2925782a183a21c093bfe8c_Out_2, 0, 0, _Combine_ec74633c191b3b869b64b8b4986681a5_RGBA_4, _Combine_ec74633c191b3b869b64b8b4986681a5_RGB_5, _Combine_ec74633c191b3b869b64b8b4986681a5_RG_6);
                    float4 _SampleTexture2D_29ceb406e933a78688f670c1b3b5661e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_8a4bb4717b58918ebc0e11867070fd07_Out_0.tex, _Property_8a4bb4717b58918ebc0e11867070fd07_Out_0.samplerstate, _Combine_ec74633c191b3b869b64b8b4986681a5_RG_6);
                    float _SampleTexture2D_29ceb406e933a78688f670c1b3b5661e_R_4 = _SampleTexture2D_29ceb406e933a78688f670c1b3b5661e_RGBA_0.r;
                    float _SampleTexture2D_29ceb406e933a78688f670c1b3b5661e_G_5 = _SampleTexture2D_29ceb406e933a78688f670c1b3b5661e_RGBA_0.g;
                    float _SampleTexture2D_29ceb406e933a78688f670c1b3b5661e_B_6 = _SampleTexture2D_29ceb406e933a78688f670c1b3b5661e_RGBA_0.b;
                    float _SampleTexture2D_29ceb406e933a78688f670c1b3b5661e_A_7 = _SampleTexture2D_29ceb406e933a78688f670c1b3b5661e_RGBA_0.a;
                    float _Float_e1c62dd18545388a99b1dceb5912e75d_Out_0 = _SampleTexture2D_29ceb406e933a78688f670c1b3b5661e_A_7;
                    float _OneMinus_cfdcfdadcb46c485a3fde33f9b1bb9ef_Out_1;
                    Unity_OneMinus_float(_Float_e1c62dd18545388a99b1dceb5912e75d_Out_0, _OneMinus_cfdcfdadcb46c485a3fde33f9b1bb9ef_Out_1);
                    float3 _Multiply_0840d5ffd7a0a483afbba997e9142b96_Out_2;
                    Unity_Multiply_float(_Clamp_25bb679ace5050889f831b11eae18634_Out_3, (_OneMinus_cfdcfdadcb46c485a3fde33f9b1bb9ef_Out_1.xxx), _Multiply_0840d5ffd7a0a483afbba997e9142b96_Out_2);
                    float4 _Property_ae581dbb4ef69e8eb9786c4505009838_Out_0 = _PixMapColor;
                    float4 _Multiply_70697d37a370b98d8fdb551d653a4ace_Out_2;
                    Unity_Multiply_float(_Property_ae581dbb4ef69e8eb9786c4505009838_Out_0, _SampleTexture2D_29ceb406e933a78688f670c1b3b5661e_RGBA_0, _Multiply_70697d37a370b98d8fdb551d653a4ace_Out_2);
                    float4 _Lerp_8ae7b3c34725af89921b0685d2404fe4_Out_3;
                    Unity_Lerp_float4(_Multiply_70697d37a370b98d8fdb551d653a4ace_Out_2, _Fog_2b53bbb40c980187808f83f2dca8c87c_Color_0, (_Property_b845b6e513290f81947460352e38a02b_Out_0.xxxx), _Lerp_8ae7b3c34725af89921b0685d2404fe4_Out_3);
                    float4 _Saturate_e57d05317b94548d999a85c2b4bbe632_Out_1;
                    Unity_Saturate_float4(_Lerp_8ae7b3c34725af89921b0685d2404fe4_Out_3, _Saturate_e57d05317b94548d999a85c2b4bbe632_Out_1);
                    float4 _Multiply_7ea33ddc36101f87a11f5347318e99e6_Out_2;
                    Unity_Multiply_float((_Float_e1c62dd18545388a99b1dceb5912e75d_Out_0.xxxx), _Saturate_e57d05317b94548d999a85c2b4bbe632_Out_1, _Multiply_7ea33ddc36101f87a11f5347318e99e6_Out_2);
                    float3 _Add_72f48bf2ead0c6888884fc97acfb9504_Out_2;
                    Unity_Add_float3(_Multiply_0840d5ffd7a0a483afbba997e9142b96_Out_2, (_Multiply_7ea33ddc36101f87a11f5347318e99e6_Out_2.xyz), _Add_72f48bf2ead0c6888884fc97acfb9504_Out_2);
                    surface.BaseColor = _Add_72f48bf2ead0c6888884fc97acfb9504_Out_2;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                
                
                    output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
                    output.WorldSpacePosition =          input.positionWS;
                    output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "ShadowCaster"
                Tags
                {
                    "LightMode" = "ShadowCaster"
                }
    
                // Render State
                Cull Back
                Blend One Zero
                ZTest LEqual
                ZWrite On
                ColorMask 0
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_SHADOWCASTER
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 _SkyColor;
                float4 _HorizonColor;
                float4 _GroundColor;
                float _HorizonSharpnessSky;
                float _HorizonSharpnessGround;
                float4 _AmbientColorSunSide;
                float4 _AmbientColorSunOpposite;
                float _AmbientColorSharpness;
                float _HorizonOffset;
                float _SkyIntensity;
                float _SunRadius;
                float _SunFalloff;
                float _SunIntensity;
                float4 _CloudsTexture_TexelSize;
                float _AdditiveOrBlend;
                float _CloudsTiling;
                float _CloudsFarTiling;
                float2 _CloudsOffset;
                float _CloudsBrightness;
                float _CloudsContrast;
                float4 _CloudsColor;
                float _CloudsCutoff;
                float _CloudsFalloff;
                float _CloudsOpacity;
                float _CloudsHaveFog;
                float4 _PixMap_TexelSize;
                float4 _PixMapColor;
                float _PixMapOffset;
                float _PixMapTilingV;
                float _PixMapTilingU;
                float _FogIntensityOnSkybox;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_CloudsTexture);
                SAMPLER(sampler_CloudsTexture);
                TEXTURE2D(_PixMap);
                SAMPLER(sampler_PixMap);
    
                // Graph Functions
                // GraphFunctions: <None>
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                
                
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "DepthOnly"
                Tags
                {
                    "LightMode" = "DepthOnly"
                }
    
                // Render State
                Cull Back
                Blend One Zero
                ZTest LEqual
                ZWrite On
                ColorMask 0
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_DEPTHONLY
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 _SkyColor;
                float4 _HorizonColor;
                float4 _GroundColor;
                float _HorizonSharpnessSky;
                float _HorizonSharpnessGround;
                float4 _AmbientColorSunSide;
                float4 _AmbientColorSunOpposite;
                float _AmbientColorSharpness;
                float _HorizonOffset;
                float _SkyIntensity;
                float _SunRadius;
                float _SunFalloff;
                float _SunIntensity;
                float4 _CloudsTexture_TexelSize;
                float _AdditiveOrBlend;
                float _CloudsTiling;
                float _CloudsFarTiling;
                float2 _CloudsOffset;
                float _CloudsBrightness;
                float _CloudsContrast;
                float4 _CloudsColor;
                float _CloudsCutoff;
                float _CloudsFalloff;
                float _CloudsOpacity;
                float _CloudsHaveFog;
                float4 _PixMap_TexelSize;
                float4 _PixMapColor;
                float _PixMapOffset;
                float _PixMapTilingV;
                float _PixMapTilingU;
                float _FogIntensityOnSkybox;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_CloudsTexture);
                SAMPLER(sampler_CloudsTexture);
                TEXTURE2D(_PixMap);
                SAMPLER(sampler_PixMap);
    
                // Graph Functions
                // GraphFunctions: <None>
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                
                
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
    
                ENDHLSL
            }
        }
        FallBack "Hidden/Shader Graph/FallbackError"
    }