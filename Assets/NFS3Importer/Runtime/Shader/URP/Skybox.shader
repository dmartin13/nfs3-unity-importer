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
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "Queue"="Geometry+0"
        }
        
        Pass
        {
            Name "Pass"
            Tags 
            { 
                // LightMode: <None>
            }
           
            // Render State
            Blend One Zero, One Zero
            Cull Back
            ZTest LEqual
            ZWrite On
            // ColorMask: <None>
            
        
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            // Pragmas
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
        
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
            #pragma multi_compile_instancing
            #define SHADERPASS_UNLIT
            
        
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"
        
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
            float4 _PixMapColor;
            float _PixMapOffset;
            float _PixMapTilingV;
            float _PixMapTilingU;
            float _FogIntensityOnSkybox;
            CBUFFER_END
            TEXTURE2D(_CloudsTexture); SAMPLER(sampler_CloudsTexture); float4 _CloudsTexture_TexelSize;
            TEXTURE2D(_PixMap); SAMPLER(sampler_PixMap); float4 _PixMap_TexelSize;
            SAMPLER(_SampleTexture2D_9B5156DF_Sampler_3_Linear_Repeat);
            SAMPLER(_SampleTexture2D_32034BE8_Sampler_3_Linear_Repeat);
        
            // Graph Functions
            
            // f5d3b80e26e1167ba05f9c82df3db153
            #include "Assets/NFS3Importer/Runtime/Shader/URP/CustomLighting.hlsl"
            
            struct Bindings_MainLight_ea19639cbd5b57dae9d81a5e33b525f4
            {
                float3 WorldSpacePosition;
            };
            
            void SG_MainLight_ea19639cbd5b57dae9d81a5e33b525f4(Bindings_MainLight_ea19639cbd5b57dae9d81a5e33b525f4 IN, out float3 Direction_1, out float3 Color_2, out float DistanceAtten_3, out float ShadowAtten_4)
            {
                float3 _CustomFunction_88EECB2A_Direction_1;
                float3 _CustomFunction_88EECB2A_Color_2;
                float _CustomFunction_88EECB2A_DistanceAtten_3;
                float _CustomFunction_88EECB2A_ShadowAtten_4;
                MainLight_float(IN.WorldSpacePosition, _CustomFunction_88EECB2A_Direction_1, _CustomFunction_88EECB2A_Color_2, _CustomFunction_88EECB2A_DistanceAtten_3, _CustomFunction_88EECB2A_ShadowAtten_4);
                Direction_1 = _CustomFunction_88EECB2A_Direction_1;
                Color_2 = _CustomFunction_88EECB2A_Color_2;
                DistanceAtten_3 = _CustomFunction_88EECB2A_DistanceAtten_3;
                ShadowAtten_4 = _CustomFunction_88EECB2A_ShadowAtten_4;
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
            // GraphVertex: <None>
            
            // Graph Pixel
            struct SurfaceDescriptionInputs
            {
                float3 WorldSpaceViewDirection;
                float3 ObjectSpacePosition;
                float3 WorldSpacePosition;
            };
            
            struct SurfaceDescription
            {
                float3 Color;
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float _Property_6A0724A7_Out_0 = _CloudsHaveFog;
                float _Property_B21251FB_Out_0 = _AdditiveOrBlend;
                Bindings_MainLight_ea19639cbd5b57dae9d81a5e33b525f4 _MainLight_F58A1DCE;
                _MainLight_F58A1DCE.WorldSpacePosition = IN.WorldSpacePosition;
                float3 _MainLight_F58A1DCE_Direction_1;
                float3 _MainLight_F58A1DCE_Color_2;
                float _MainLight_F58A1DCE_DistanceAtten_3;
                float _MainLight_F58A1DCE_ShadowAtten_4;
                SG_MainLight_ea19639cbd5b57dae9d81a5e33b525f4(_MainLight_F58A1DCE, _MainLight_F58A1DCE_Direction_1, _MainLight_F58A1DCE_Color_2, _MainLight_F58A1DCE_DistanceAtten_3, _MainLight_F58A1DCE_ShadowAtten_4);
                float3 _Normalize_8C76FE1D_Out_1;
                Unity_Normalize_float3(IN.WorldSpaceViewDirection, _Normalize_8C76FE1D_Out_1);
                float3 _Negate_87909F62_Out_1;
                Unity_Negate_float3(_MainLight_F58A1DCE_Direction_1, _Negate_87909F62_Out_1);
                float _DotProduct_1A136E3E_Out_2;
                Unity_DotProduct_float3(_Normalize_8C76FE1D_Out_1, _Negate_87909F62_Out_1, _DotProduct_1A136E3E_Out_2);
                float _Clamp_12B71237_Out_3;
                Unity_Clamp_float(_DotProduct_1A136E3E_Out_2, 0, 1, _Clamp_12B71237_Out_3);
                float _Property_2BF2E839_Out_0 = _SunRadius;
                float _Multiply_4FD00505_Out_2;
                Unity_Multiply_float(_Property_2BF2E839_Out_0, _Property_2BF2E839_Out_0, _Multiply_4FD00505_Out_2);
                float _OneMinus_849AB3DD_Out_1;
                Unity_OneMinus_float(_Multiply_4FD00505_Out_2, _OneMinus_849AB3DD_Out_1);
                float _Property_3A2394DE_Out_0 = _SunFalloff;
                float _Add_77702BCF_Out_2;
                Unity_Add_float(_Property_2BF2E839_Out_0, _Property_3A2394DE_Out_0, _Add_77702BCF_Out_2);
                float _Multiply_74FF364E_Out_2;
                Unity_Multiply_float(_Add_77702BCF_Out_2, _Add_77702BCF_Out_2, _Multiply_74FF364E_Out_2);
                float _OneMinus_D45CD048_Out_1;
                Unity_OneMinus_float(_Multiply_74FF364E_Out_2, _OneMinus_D45CD048_Out_1);
                float2 _Vector2_3AFE014F_Out_0 = float2(_OneMinus_849AB3DD_Out_1, _OneMinus_D45CD048_Out_1);
                float2 _Vector2_38998FEB_Out_0 = float2(1, 0);
                float _Remap_96F53453_Out_3;
                Unity_Remap_float(_Clamp_12B71237_Out_3, _Vector2_3AFE014F_Out_0, _Vector2_38998FEB_Out_0, _Remap_96F53453_Out_3);
                float _Clamp_B9DF65E8_Out_3;
                Unity_Clamp_float(_Remap_96F53453_Out_3, 0, 1, _Clamp_B9DF65E8_Out_3);
                float _Property_A9DB424_Out_0 = _HorizonOffset;
                float _Negate_DC85C2FE_Out_1;
                Unity_Negate_float(_Property_A9DB424_Out_0, _Negate_DC85C2FE_Out_1);
                float3 _Normalize_6790B2_Out_1;
                Unity_Normalize_float3(IN.WorldSpacePosition, _Normalize_6790B2_Out_1);
                float _Split_B7765605_R_1 = _Normalize_6790B2_Out_1[0];
                float _Split_B7765605_G_2 = _Normalize_6790B2_Out_1[1];
                float _Split_B7765605_B_3 = _Normalize_6790B2_Out_1[2];
                float _Split_B7765605_A_4 = 0;
                float _Add_D41D6984_Out_2;
                Unity_Add_float(_Negate_DC85C2FE_Out_1, _Split_B7765605_G_2, _Add_D41D6984_Out_2);
                float _Subtract_CFB1C2B8_Out_2;
                Unity_Subtract_float(1, _Add_D41D6984_Out_2, _Subtract_CFB1C2B8_Out_2);
                float _Minimum_D1375739_Out_2;
                Unity_Minimum_float(1, _Subtract_CFB1C2B8_Out_2, _Minimum_D1375739_Out_2);
                float _Clamp_63EA1E4D_Out_3;
                Unity_Clamp_float(_Minimum_D1375739_Out_2, 0, 1, _Clamp_63EA1E4D_Out_3);
                float _Property_1C7FF596_Out_0 = _HorizonSharpnessSky;
                float _Absolute_1419907D_Out_1;
                Unity_Absolute_float(_Property_1C7FF596_Out_0, _Absolute_1419907D_Out_1);
                float _Power_C5FFF73B_Out_2;
                Unity_Power_float(_Clamp_63EA1E4D_Out_3, _Absolute_1419907D_Out_1, _Power_C5FFF73B_Out_2);
                float _OneMinus_F6F7C5D7_Out_1;
                Unity_OneMinus_float(_Power_C5FFF73B_Out_2, _OneMinus_F6F7C5D7_Out_1);
                float _Multiply_30DBE56B_Out_2;
                Unity_Multiply_float(_Clamp_B9DF65E8_Out_3, _OneMinus_F6F7C5D7_Out_1, _Multiply_30DBE56B_Out_2);
                float3 _Multiply_135D9EA_Out_2;
                Unity_Multiply_float(_MainLight_F58A1DCE_Color_2, (_Multiply_30DBE56B_Out_2.xxx), _Multiply_135D9EA_Out_2);
                float _Property_6FF3D547_Out_0 = _SunIntensity;
                float3 _Multiply_BAFE60AA_Out_2;
                Unity_Multiply_float(_Multiply_135D9EA_Out_2, (_Property_6FF3D547_Out_0.xxx), _Multiply_BAFE60AA_Out_2);
                float _Split_D677C553_R_1 = IN.WorldSpaceViewDirection[0];
                float _Split_D677C553_G_2 = IN.WorldSpaceViewDirection[1];
                float _Split_D677C553_B_3 = IN.WorldSpaceViewDirection[2];
                float _Split_D677C553_A_4 = 0;
                float2 _Vector2_D12D154B_Out_0 = float2(_Split_D677C553_R_1, _Split_D677C553_B_3);
                float2 _Normalize_AF032049_Out_1;
                Unity_Normalize_float2(_Vector2_D12D154B_Out_0, _Normalize_AF032049_Out_1);
                Bindings_MainLight_ea19639cbd5b57dae9d81a5e33b525f4 _MainLight_DFC1539E;
                _MainLight_DFC1539E.WorldSpacePosition = IN.WorldSpacePosition;
                float3 _MainLight_DFC1539E_Direction_1;
                float3 _MainLight_DFC1539E_Color_2;
                float _MainLight_DFC1539E_DistanceAtten_3;
                float _MainLight_DFC1539E_ShadowAtten_4;
                SG_MainLight_ea19639cbd5b57dae9d81a5e33b525f4(_MainLight_DFC1539E, _MainLight_DFC1539E_Direction_1, _MainLight_DFC1539E_Color_2, _MainLight_DFC1539E_DistanceAtten_3, _MainLight_DFC1539E_ShadowAtten_4);
                float _Split_2FBC88B6_R_1 = _MainLight_DFC1539E_Direction_1[0];
                float _Split_2FBC88B6_G_2 = _MainLight_DFC1539E_Direction_1[1];
                float _Split_2FBC88B6_B_3 = _MainLight_DFC1539E_Direction_1[2];
                float _Split_2FBC88B6_A_4 = 0;
                float2 _Vector2_D46D07DC_Out_0 = float2(_Split_2FBC88B6_R_1, _Split_2FBC88B6_B_3);
                float2 _Normalize_72396725_Out_1;
                Unity_Normalize_float2(_Vector2_D46D07DC_Out_0, _Normalize_72396725_Out_1);
                float2 _Negate_5CD5D1C2_Out_1;
                Unity_Negate_float2(_Normalize_72396725_Out_1, _Negate_5CD5D1C2_Out_1);
                float _DotProduct_9CC43A2_Out_2;
                Unity_DotProduct_float2(_Normalize_AF032049_Out_1, _Negate_5CD5D1C2_Out_1, _DotProduct_9CC43A2_Out_2);
                float _Clamp_4B96EA47_Out_3;
                Unity_Clamp_float(_DotProduct_9CC43A2_Out_2, 0, 1, _Clamp_4B96EA47_Out_3);
                float _OneMinus_CB717DF7_Out_1;
                Unity_OneMinus_float(_Clamp_4B96EA47_Out_3, _OneMinus_CB717DF7_Out_1);
                float _Property_3E6A27F2_Out_0 = _AmbientColorSharpness;
                float _Absolute_2F087987_Out_1;
                Unity_Absolute_float(_Property_3E6A27F2_Out_0, _Absolute_2F087987_Out_1);
                float _Power_AD989DB_Out_2;
                Unity_Power_float(_Clamp_63EA1E4D_Out_3, _Absolute_2F087987_Out_1, _Power_AD989DB_Out_2);
                float _Multiply_728988ED_Out_2;
                Unity_Multiply_float(_OneMinus_CB717DF7_Out_1, _Power_AD989DB_Out_2, _Multiply_728988ED_Out_2);
                float _Multiply_8D21997E_Out_2;
                Unity_Multiply_float(_Multiply_728988ED_Out_2, _OneMinus_F6F7C5D7_Out_1, _Multiply_8D21997E_Out_2);
                float4 _Property_60E941DC_Out_0 = _AmbientColorSunOpposite;
                float4 _Multiply_51515C65_Out_2;
                Unity_Multiply_float((_Multiply_8D21997E_Out_2.xxxx), _Property_60E941DC_Out_0, _Multiply_51515C65_Out_2);
                float _DotProduct_D58E27D8_Out_2;
                Unity_DotProduct_float2(_Normalize_AF032049_Out_1, _Normalize_72396725_Out_1, _DotProduct_D58E27D8_Out_2);
                float _Clamp_30E67F73_Out_3;
                Unity_Clamp_float(_DotProduct_D58E27D8_Out_2, 0, 1, _Clamp_30E67F73_Out_3);
                float _OneMinus_5513F55C_Out_1;
                Unity_OneMinus_float(_Clamp_30E67F73_Out_3, _OneMinus_5513F55C_Out_1);
                float _Multiply_DD7D3DAD_Out_2;
                Unity_Multiply_float(_OneMinus_5513F55C_Out_1, _Power_AD989DB_Out_2, _Multiply_DD7D3DAD_Out_2);
                float _Multiply_A916BBA4_Out_2;
                Unity_Multiply_float(_Multiply_DD7D3DAD_Out_2, _OneMinus_F6F7C5D7_Out_1, _Multiply_A916BBA4_Out_2);
                float4 _Property_FC3C37F_Out_0 = _AmbientColorSunSide;
                float4 _Multiply_F726EC60_Out_2;
                Unity_Multiply_float((_Multiply_A916BBA4_Out_2.xxxx), _Property_FC3C37F_Out_0, _Multiply_F726EC60_Out_2);
                float _OneMinus_9051FF3F_Out_1;
                Unity_OneMinus_float(_Multiply_8D21997E_Out_2, _OneMinus_9051FF3F_Out_1);
                float _OneMinus_8946DBE5_Out_1;
                Unity_OneMinus_float(_Multiply_A916BBA4_Out_2, _OneMinus_8946DBE5_Out_1);
                float4 _Property_CB0B10D2_Out_0 = _SkyColor;
                float4 _Multiply_E2C125B4_Out_2;
                Unity_Multiply_float(_Property_CB0B10D2_Out_0, (_OneMinus_F6F7C5D7_Out_1.xxxx), _Multiply_E2C125B4_Out_2);
                float4 _Multiply_ED3E9617_Out_2;
                Unity_Multiply_float((_OneMinus_8946DBE5_Out_1.xxxx), _Multiply_E2C125B4_Out_2, _Multiply_ED3E9617_Out_2);
                float4 _Multiply_A21ACFCE_Out_2;
                Unity_Multiply_float((_OneMinus_9051FF3F_Out_1.xxxx), _Multiply_ED3E9617_Out_2, _Multiply_A21ACFCE_Out_2);
                float4 _Property_43FCC87_Out_0 = _HorizonColor;
                float _OneMinus_2FCF02E5_Out_1;
                Unity_OneMinus_float(_OneMinus_F6F7C5D7_Out_1, _OneMinus_2FCF02E5_Out_1);
                float _Add_EA65E386_Out_2;
                Unity_Add_float(1, _Split_B7765605_G_2, _Add_EA65E386_Out_2);
                float _Minimum_834B8440_Out_2;
                Unity_Minimum_float(1, _Add_EA65E386_Out_2, _Minimum_834B8440_Out_2);
                float _Property_9749D37B_Out_0 = _HorizonSharpnessGround;
                float _Absolute_B3170871_Out_1;
                Unity_Absolute_float(_Property_9749D37B_Out_0, _Absolute_B3170871_Out_1);
                float _Power_141EDB10_Out_2;
                Unity_Power_float(_Minimum_834B8440_Out_2, _Absolute_B3170871_Out_1, _Power_141EDB10_Out_2);
                float _OneMinus_59CFDF55_Out_1;
                Unity_OneMinus_float(_Power_141EDB10_Out_2, _OneMinus_59CFDF55_Out_1);
                float _Subtract_7962C2B7_Out_2;
                Unity_Subtract_float(_OneMinus_2FCF02E5_Out_1, _OneMinus_59CFDF55_Out_1, _Subtract_7962C2B7_Out_2);
                float4 _Multiply_1ADDF353_Out_2;
                Unity_Multiply_float(_Property_43FCC87_Out_0, (_Subtract_7962C2B7_Out_2.xxxx), _Multiply_1ADDF353_Out_2);
                float4 _Add_1C60BD4B_Out_2;
                Unity_Add_float4(_Multiply_A21ACFCE_Out_2, _Multiply_1ADDF353_Out_2, _Add_1C60BD4B_Out_2);
                float4 _Property_9D8058FD_Out_0 = _GroundColor;
                float4 _Multiply_B53F9997_Out_2;
                Unity_Multiply_float(_Property_9D8058FD_Out_0, (_OneMinus_59CFDF55_Out_1.xxxx), _Multiply_B53F9997_Out_2);
                float4 _Add_9F3E05C0_Out_2;
                Unity_Add_float4(_Add_1C60BD4B_Out_2, _Multiply_B53F9997_Out_2, _Add_9F3E05C0_Out_2);
                float4 _Add_69D43022_Out_2;
                Unity_Add_float4(_Multiply_F726EC60_Out_2, _Add_9F3E05C0_Out_2, _Add_69D43022_Out_2);
                float4 _Add_EB731D71_Out_2;
                Unity_Add_float4(_Multiply_51515C65_Out_2, _Add_69D43022_Out_2, _Add_EB731D71_Out_2);
                float _Property_7368AB68_Out_0 = _SkyIntensity;
                float4 _Multiply_3D8D4DB0_Out_2;
                Unity_Multiply_float(_Add_EB731D71_Out_2, (_Property_7368AB68_Out_0.xxxx), _Multiply_3D8D4DB0_Out_2);
                float3 _Add_7172614D_Out_2;
                Unity_Add_float3(_Multiply_BAFE60AA_Out_2, (_Multiply_3D8D4DB0_Out_2.xyz), _Add_7172614D_Out_2);
                float2 _Property_BD55DF8A_Out_0 = _CloudsOffset;
                float _Split_EDA32DE9_R_1 = _Normalize_6790B2_Out_1[0];
                float _Split_EDA32DE9_G_2 = _Normalize_6790B2_Out_1[1];
                float _Split_EDA32DE9_B_3 = _Normalize_6790B2_Out_1[2];
                float _Split_EDA32DE9_A_4 = 0;
                float2 _Vector2_DD83481C_Out_0 = float2(_Split_EDA32DE9_R_1, _Split_EDA32DE9_B_3);
                float _Absolute_7E70E9B1_Out_1;
                Unity_Absolute_float(_Split_EDA32DE9_G_2, _Absolute_7E70E9B1_Out_1);
                float _Property_F400C11F_Out_0 = _CloudsFarTiling;
                float _Absolute_997B1D0C_Out_1;
                Unity_Absolute_float(_Property_F400C11F_Out_0, _Absolute_997B1D0C_Out_1);
                float2 _Vector2_5146FD4B_Out_0 = float2(_Absolute_997B1D0C_Out_1, 1);
                float _Remap_A42AC745_Out_3;
                Unity_Remap_float(_Absolute_7E70E9B1_Out_1, float2 (0, 1), _Vector2_5146FD4B_Out_0, _Remap_A42AC745_Out_3);
                float2 _Divide_2BB33621_Out_2;
                Unity_Divide_float2(_Vector2_DD83481C_Out_0, (_Remap_A42AC745_Out_3.xx), _Divide_2BB33621_Out_2);
                float _Property_CF93F304_Out_0 = _CloudsTiling;
                float2 _Multiply_6D2E4B0_Out_2;
                Unity_Multiply_float(_Divide_2BB33621_Out_2, (_Property_CF93F304_Out_0.xx), _Multiply_6D2E4B0_Out_2);
                float2 _Add_9C0A2472_Out_2;
                Unity_Add_float2(_Property_BD55DF8A_Out_0, _Multiply_6D2E4B0_Out_2, _Add_9C0A2472_Out_2);
                float4 _SampleTexture2D_9B5156DF_RGBA_0 = SAMPLE_TEXTURE2D(_CloudsTexture, sampler_CloudsTexture, _Add_9C0A2472_Out_2);
                float _SampleTexture2D_9B5156DF_R_4 = _SampleTexture2D_9B5156DF_RGBA_0.r;
                float _SampleTexture2D_9B5156DF_G_5 = _SampleTexture2D_9B5156DF_RGBA_0.g;
                float _SampleTexture2D_9B5156DF_B_6 = _SampleTexture2D_9B5156DF_RGBA_0.b;
                float _SampleTexture2D_9B5156DF_A_7 = _SampleTexture2D_9B5156DF_RGBA_0.a;
                float _Property_14FE2C08_Out_0 = _CloudsContrast;
                float3 _Contrast_6D4250BB_Out_2;
                Unity_Contrast_float((_SampleTexture2D_9B5156DF_RGBA_0.xyz), _Property_14FE2C08_Out_0, _Contrast_6D4250BB_Out_2);
                float _Property_9D27A937_Out_0 = _CloudsBrightness;
                float _Subtract_2765777D_Out_2;
                Unity_Subtract_float(_Property_9D27A937_Out_0, 1, _Subtract_2765777D_Out_2);
                float3 _Add_EE40FF0E_Out_2;
                Unity_Add_float3(_Contrast_6D4250BB_Out_2, (_Subtract_2765777D_Out_2.xxx), _Add_EE40FF0E_Out_2);
                Bindings_MainLight_ea19639cbd5b57dae9d81a5e33b525f4 _MainLight_79E14BC4;
                _MainLight_79E14BC4.WorldSpacePosition = IN.WorldSpacePosition;
                float3 _MainLight_79E14BC4_Direction_1;
                float3 _MainLight_79E14BC4_Color_2;
                float _MainLight_79E14BC4_DistanceAtten_3;
                float _MainLight_79E14BC4_ShadowAtten_4;
                SG_MainLight_ea19639cbd5b57dae9d81a5e33b525f4(_MainLight_79E14BC4, _MainLight_79E14BC4_Direction_1, _MainLight_79E14BC4_Color_2, _MainLight_79E14BC4_DistanceAtten_3, _MainLight_79E14BC4_ShadowAtten_4);
                float4 _Property_9775F6F0_Out_0 = _CloudsColor;
                float3 _Blend_A4CA2F10_Out_2;
                Unity_Blend_Overlay_float3(_MainLight_79E14BC4_Color_2, (_Property_9775F6F0_Out_0.xyz), _Blend_A4CA2F10_Out_2, 1);
                float3 _Clamp_63D0FFEC_Out_3;
                Unity_Clamp_float3(_Blend_A4CA2F10_Out_2, float3(0, 0, 0), float3(1, 1, 1), _Clamp_63D0FFEC_Out_3);
                float3 _Multiply_49C0E4E4_Out_2;
                Unity_Multiply_float(_Add_EE40FF0E_Out_2, _Clamp_63D0FFEC_Out_3, _Multiply_49C0E4E4_Out_2);
                float _Property_35E536A9_Out_0 = _CloudsCutoff;
                float _Negate_31AB0141_Out_1;
                Unity_Negate_float(_Property_35E536A9_Out_0, _Negate_31AB0141_Out_1);
                float _Add_70B710F4_Out_2;
                Unity_Add_float(_Split_EDA32DE9_G_2, _Negate_31AB0141_Out_1, _Add_70B710F4_Out_2);
                float _Clamp_2695D8C8_Out_3;
                Unity_Clamp_float(_Add_70B710F4_Out_2, 0, 1, _Clamp_2695D8C8_Out_3);
                float _Property_87030A69_Out_0 = _CloudsFalloff;
                float _Power_6A757EED_Out_2;
                Unity_Power_float(_Clamp_2695D8C8_Out_3, _Property_87030A69_Out_0, _Power_6A757EED_Out_2);
                float _Multiply_31FDC376_Out_2;
                Unity_Multiply_float(_SampleTexture2D_9B5156DF_A_7, _Power_6A757EED_Out_2, _Multiply_31FDC376_Out_2);
                float _Property_6664377B_Out_0 = _CloudsOpacity;
                float _Multiply_8E92E3A8_Out_2;
                Unity_Multiply_float(_Multiply_31FDC376_Out_2, _Property_6664377B_Out_0, _Multiply_8E92E3A8_Out_2);
                float3 _Multiply_EB31B978_Out_2;
                Unity_Multiply_float(_Multiply_49C0E4E4_Out_2, (_Multiply_8E92E3A8_Out_2.xxx), _Multiply_EB31B978_Out_2);
                float3 _Add_F81E148E_Out_2;
                Unity_Add_float3(_Add_7172614D_Out_2, _Multiply_EB31B978_Out_2, _Add_F81E148E_Out_2);
                float3 _Blend_CC117BDF_Out_2;
                Unity_Blend_Overlay_float3(_Add_7172614D_Out_2, _Multiply_49C0E4E4_Out_2, _Blend_CC117BDF_Out_2, _Multiply_8E92E3A8_Out_2);
                float3 _Branch_C8FF873C_Out_3;
                Unity_Branch_float3(_Property_B21251FB_Out_0, _Add_F81E148E_Out_2, _Blend_CC117BDF_Out_2, _Branch_C8FF873C_Out_3);
                float4 _Fog_A11A9702_Color_0;
                float _Fog_A11A9702_Density_1;
                Unity_Fog_float(_Fog_A11A9702_Color_0, _Fog_A11A9702_Density_1, IN.ObjectSpacePosition);
                float _Property_D72A3084_Out_0 = _FogIntensityOnSkybox;
                float3 _Lerp_ED18A34E_Out_3;
                Unity_Lerp_float3(_Branch_C8FF873C_Out_3, (_Fog_A11A9702_Color_0.xyz), (_Property_D72A3084_Out_0.xxx), _Lerp_ED18A34E_Out_3);
                float3 _Branch_ED9FF4_Out_3;
                Unity_Branch_float3(_Property_6A0724A7_Out_0, _Lerp_ED18A34E_Out_3, _Branch_C8FF873C_Out_3, _Branch_ED9FF4_Out_3);
                float3 _Clamp_E0A91893_Out_3;
                Unity_Clamp_float3(_Branch_ED9FF4_Out_3, float3(0, 0, 0), float3(1, 1, 1), _Clamp_E0A91893_Out_3);
                float _Split_214F8B91_R_1 = _Normalize_6790B2_Out_1[0];
                float _Split_214F8B91_G_2 = _Normalize_6790B2_Out_1[1];
                float _Split_214F8B91_B_3 = _Normalize_6790B2_Out_1[2];
                float _Split_214F8B91_A_4 = 0;
                float _Arctangent2_AD8E3AE7_Out_2;
                Unity_Arctangent2_float(_Split_214F8B91_R_1, _Split_214F8B91_B_3, _Arctangent2_AD8E3AE7_Out_2);
                float Constant_1B13EACD = 6.283185;
                float _Divide_7ECA169_Out_2;
                Unity_Divide_float(_Arctangent2_AD8E3AE7_Out_2, Constant_1B13EACD, _Divide_7ECA169_Out_2);
                float _Property_6F8159F0_Out_0 = _PixMapTilingU;
                float _Multiply_EE498C5E_Out_2;
                Unity_Multiply_float(_Divide_7ECA169_Out_2, _Property_6F8159F0_Out_0, _Multiply_EE498C5E_Out_2);
                float _Arcsine_4391350B_Out_1;
                Unity_Arcsine_float(_Split_214F8B91_G_2, _Arcsine_4391350B_Out_1);
                float Constant_249DD24D = 3.141593;
                float _Divide_74A9A869_Out_2;
                Unity_Divide_float(Constant_249DD24D, 2, _Divide_74A9A869_Out_2);
                float _Divide_CDBAD6DA_Out_2;
                Unity_Divide_float(_Arcsine_4391350B_Out_1, _Divide_74A9A869_Out_2, _Divide_CDBAD6DA_Out_2);
                float _Property_9CD588A1_Out_0 = _PixMapOffset;
                float _Negate_42923710_Out_1;
                Unity_Negate_float(_Property_9CD588A1_Out_0, _Negate_42923710_Out_1);
                float _Add_75B7ACF6_Out_2;
                Unity_Add_float(_Divide_CDBAD6DA_Out_2, _Negate_42923710_Out_1, _Add_75B7ACF6_Out_2);
                float _Property_CABF052A_Out_0 = _PixMapTilingV;
                float _Multiply_D9911AD0_Out_2;
                Unity_Multiply_float(_Add_75B7ACF6_Out_2, _Property_CABF052A_Out_0, _Multiply_D9911AD0_Out_2);
                float4 _Combine_9DE12C7A_RGBA_4;
                float3 _Combine_9DE12C7A_RGB_5;
                float2 _Combine_9DE12C7A_RG_6;
                Unity_Combine_float(_Multiply_EE498C5E_Out_2, _Multiply_D9911AD0_Out_2, 0, 0, _Combine_9DE12C7A_RGBA_4, _Combine_9DE12C7A_RGB_5, _Combine_9DE12C7A_RG_6);
                float4 _SampleTexture2D_32034BE8_RGBA_0 = SAMPLE_TEXTURE2D(_PixMap, sampler_PixMap, _Combine_9DE12C7A_RG_6);
                float _SampleTexture2D_32034BE8_R_4 = _SampleTexture2D_32034BE8_RGBA_0.r;
                float _SampleTexture2D_32034BE8_G_5 = _SampleTexture2D_32034BE8_RGBA_0.g;
                float _SampleTexture2D_32034BE8_B_6 = _SampleTexture2D_32034BE8_RGBA_0.b;
                float _SampleTexture2D_32034BE8_A_7 = _SampleTexture2D_32034BE8_RGBA_0.a;
                float _Vector1_D30C0ECC_Out_0 = _SampleTexture2D_32034BE8_A_7;
                float _OneMinus_1B7DD504_Out_1;
                Unity_OneMinus_float(_Vector1_D30C0ECC_Out_0, _OneMinus_1B7DD504_Out_1);
                float3 _Multiply_ADCFDBA6_Out_2;
                Unity_Multiply_float(_Clamp_E0A91893_Out_3, (_OneMinus_1B7DD504_Out_1.xxx), _Multiply_ADCFDBA6_Out_2);
                float4 _Property_DB1976B5_Out_0 = _PixMapColor;
                float4 _Multiply_448B57D4_Out_2;
                Unity_Multiply_float(_Property_DB1976B5_Out_0, _SampleTexture2D_32034BE8_RGBA_0, _Multiply_448B57D4_Out_2);
                float4 _Lerp_2BEEAE0E_Out_3;
                Unity_Lerp_float4(_Multiply_448B57D4_Out_2, _Fog_A11A9702_Color_0, (_Property_D72A3084_Out_0.xxxx), _Lerp_2BEEAE0E_Out_3);
                float4 _Saturate_6C9F0B4C_Out_1;
                Unity_Saturate_float4(_Lerp_2BEEAE0E_Out_3, _Saturate_6C9F0B4C_Out_1);
                float4 _Multiply_CD3DD5D5_Out_2;
                Unity_Multiply_float((_Vector1_D30C0ECC_Out_0.xxxx), _Saturate_6C9F0B4C_Out_1, _Multiply_CD3DD5D5_Out_2);
                float3 _Add_D8799266_Out_2;
                Unity_Add_float3(_Multiply_ADCFDBA6_Out_2, (_Multiply_CD3DD5D5_Out_2.xyz), _Add_D8799266_Out_2);
                surface.Color = _Add_D8799266_Out_2;
                surface.Alpha = 1;
                surface.AlphaClipThreshold = 0;
                return surface;
            }
        
            // --------------------------------------------------
            // Structs and Packing
        
            // Generated Type: Attributes
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
        
            // Generated Type: Varyings
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS;
                float3 viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Generated Type: PackedVaryings
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                float3 interp00 : TEXCOORD0;
                float3 interp01 : TEXCOORD1;
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Packed Type: Varyings
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output = (PackedVaryings)0;
                output.positionCS = input.positionCS;
                output.interp00.xyz = input.positionWS;
                output.interp01.xyz = input.viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            // Unpacked Type: Varyings
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output = (Varyings)0;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp00.xyz;
                output.viewDirectionWS = input.interp01.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
        
            // --------------------------------------------------
            // Build Graph Inputs
        
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            
            
            
            
                output.WorldSpaceViewDirection =     input.viewDirectionWS;
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
            Blend One Zero, One Zero
            Cull Back
            ZTest LEqual
            ZWrite On
            // ColorMask: <None>
            
        
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            // Pragmas
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_instancing
        
            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>
            
            // Defines
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #pragma multi_compile_instancing
            #define SHADERPASS_SHADOWCASTER
            
        
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"
        
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
            float4 _PixMapColor;
            float _PixMapOffset;
            float _PixMapTilingV;
            float _PixMapTilingU;
            float _FogIntensityOnSkybox;
            CBUFFER_END
            TEXTURE2D(_CloudsTexture); SAMPLER(sampler_CloudsTexture); float4 _CloudsTexture_TexelSize;
            TEXTURE2D(_PixMap); SAMPLER(sampler_PixMap); float4 _PixMap_TexelSize;
        
            // Graph Functions
            // GraphFunctions: <None>
        
            // Graph Vertex
            // GraphVertex: <None>
            
            // Graph Pixel
            struct SurfaceDescriptionInputs
            {
            };
            
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                surface.Alpha = 1;
                surface.AlphaClipThreshold = 0;
                return surface;
            }
        
            // --------------------------------------------------
            // Structs and Packing
        
            // Generated Type: Attributes
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
        
            // Generated Type: Varyings
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Generated Type: PackedVaryings
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Packed Type: Varyings
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output = (PackedVaryings)0;
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            // Unpacked Type: Varyings
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output = (Varyings)0;
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
        
            // --------------------------------------------------
            // Build Graph Inputs
        
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
            Blend One Zero, One Zero
            Cull Back
            ZTest LEqual
            ZWrite On
            ColorMask 0
            
        
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            // Pragmas
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_instancing
        
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #pragma multi_compile_instancing
            #define SHADERPASS_DEPTHONLY
            
        
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"
        
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
            float4 _PixMapColor;
            float _PixMapOffset;
            float _PixMapTilingV;
            float _PixMapTilingU;
            float _FogIntensityOnSkybox;
            CBUFFER_END
            TEXTURE2D(_CloudsTexture); SAMPLER(sampler_CloudsTexture); float4 _CloudsTexture_TexelSize;
            TEXTURE2D(_PixMap); SAMPLER(sampler_PixMap); float4 _PixMap_TexelSize;
        
            // Graph Functions
            // GraphFunctions: <None>
        
            // Graph Vertex
            // GraphVertex: <None>
            
            // Graph Pixel
            struct SurfaceDescriptionInputs
            {
            };
            
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                surface.Alpha = 1;
                surface.AlphaClipThreshold = 0;
                return surface;
            }
        
            // --------------------------------------------------
            // Structs and Packing
        
            // Generated Type: Attributes
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
        
            // Generated Type: Varyings
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Generated Type: PackedVaryings
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Packed Type: Varyings
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output = (PackedVaryings)0;
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            // Unpacked Type: Varyings
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output = (Varyings)0;
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
        
            // --------------------------------------------------
            // Build Graph Inputs
        
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
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
            ENDHLSL
        }
        
    }
    FallBack "Hidden/Shader Graph/FallbackError"
}
