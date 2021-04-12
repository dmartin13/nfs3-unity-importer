using NFS3Importer.Runtime;
using NFS3Importer.UnityData;
using NFS3Importer.Utility;
using UnityEngine;

namespace NFS3Importer {
    public static class HRZParser {

        private const float FOGSCALINGFACTOR = 1.0f/128.0f;
        private static Material createSkybox(RenderPipeline rp, NFSData.HRZ.HRZFile hrz, Texture2D pixmap, Texture2D clouds) {
            Shader shader;
            if (rp == RenderPipeline.Legacy) {
                shader = Shader.Find("NFS3Importer/Legacy/Skybox");
            } else if(rp == RenderPipeline.URP) {
                shader = Shader.Find("NFS3Importer/URP/Skybox");
            } else {
                // renderpipeline not supported
                shader = Shader.Find("NFS3Importer/Legacy/Skybox");
            }

            Material skybox = new Material(shader);

            Color skyColor = hrz.SkyColor;
            Color horizonColor = hrz.HorizonColor;
            Color bottomColor = hrz.BottomColor;
            Color ambientColorSunSide = hrz.SkyBaseColors.Item1;
            Color ambientColorSunOpposite = hrz.SkyBaseColors.Item2;
            float sunIntensity = 1.0f;
            float cloudsOpacity = 1.0f;
            float cloudsBrightness = ((float)hrz.CloudBrightness).Remap(0, 255.0f, 0, 1.0f);
            float cloudsContrast = ((float)hrz.CloudVariance).Remap(0, 255.0f, 0, 1.0f);

            // this scaling is just a very basic translation from NFS HRZ information. But for now its ok.
            // TODO: Mabe find a better solution
            float fogIntensity = hrz.GlobalFogEffectOnPixmap * 0.01f ;

            if(hrz.BlackHorizon) {
                skyColor = Color.black;
                horizonColor = Color.black;
                bottomColor = Color.black;
                ambientColorSunSide = Color.black;
                ambientColorSunOpposite = Color.black;
                sunIntensity = 0;
                cloudsOpacity = 0;
                clouds = null;
                pixmap = null;
            }

            if(!hrz.HasPixmap) {
                pixmap = null;
            }

            float horizonOffset = toV(hrz.Base, hrz.HorizonRadius, hrz.HorizonOffsetFromBase);
            float pixmapOffset = toV(hrz.Base, hrz.HorizonRadius, hrz.BottomOfPixmapOffsetFromBase);
            float pixmapTilingV = scale(hrz.Base, hrz.HorizonRadius, hrz.BottomOfPixmapOffsetFromBase, hrz.TopOfPixmapOffsetFromBase);

            //set values
            skybox.SetColor("_SkyColor", skyColor);
            skybox.SetColor("_HorizonColor", horizonColor);
            skybox.SetColor("_GroundColor", bottomColor);
            skybox.SetFloat("_HorizonSharpnessSky", 30.0f);
            skybox.SetFloat("_HorizonSharpnessGround", 1.0f);
            skybox.SetColor("_AmbientColorSunSide", ambientColorSunSide);
            skybox.SetColor("_AmbientColorSunOpposite", ambientColorSunOpposite);
            skybox.SetFloat("_AmbientColorSharpness", 7.0f);
            skybox.SetFloat("_HorizonOffset", horizonOffset);
            skybox.SetFloat("_SkyIntensity", 1.0f);
            skybox.SetFloat("_SunRadius", 0.07f);
            skybox.SetFloat("_SunFalloff", 0.02f);
            skybox.SetFloat("_SunIntensity", sunIntensity);
            skybox.SetTexture("_CloudsTexture", clouds);
            skybox.SetFloat("_AdditiveOrBlend", hrz.CloudType == 1 ? 1.0f : 0.0f);
            skybox.SetFloat("_CloudsTiling", 1.0f);
            skybox.SetFloat("_CloudsFarTiling", 0.2f);
            skybox.SetVector("_CloudsOffset", new Vector4(0.0f, 0.0f, 0.0f, 0.0f));
            skybox.SetFloat("_CloudsBrightness", cloudsBrightness);
            skybox.SetFloat("_CloudsContrast", cloudsContrast);
            skybox.SetColor("_CloudsColor", Color.white);
            skybox.SetFloat("_CloudsCutoff", 0.0f);
            skybox.SetFloat("_CloudsFalloff", 1.0f);
            skybox.SetFloat("_CloudsOpacity", cloudsOpacity);
            skybox.SetFloat("_CloudsHaveFog", hrz.FogClouds == 1 ? 1.0f : 0.0f);
            skybox.SetTexture("_PixMap", pixmap);
            skybox.SetColor("_PixMapColor", Color.white);
            skybox.SetFloat("_PixMapOffset", pixmapOffset);
            skybox.SetFloat("_PixMapTilingV", pixmapTilingV);
            skybox.SetFloat("_PixMapTilingU", 2.0f);
            skybox.SetFloat("_FogIntensityOnSkybox", fogIntensity);

            return skybox;
        }

        /// <summary>
        /// Transforms world-coordinates from HRZ-files into uv-coordinates for our shader 
        /// </summary>
        /// <param name="baseOffsetFromZero">This is the value "How high in the air the base of the Gourad shaded area is (world offset)." from HRZ-file</param>
        /// <param name="radius">This is the value "The radius of the horizon" from HRZ-file</param>
        /// <param name="valueOffset">This is a offset from baseOffsetFromZero. e.g. "Bottom of horizon pixmap (offset from base)"</param>
        /// <returns></returns>
        private static float toV(float baseOffsetFromZero, float radius, float valueOffset) {
            /*
              First we calculate the actual position (y-coordinate) of value by adding valueOffset to base.
              Then we scale everything down, so we can interpret the value as tangens
              the arctan of value gives us the angle between horizontal axis and the y-coordinate of value in radians
              to project this onto the unit circle we transform the radians into degree and divide by 90 to
              get the procentual amount of our angle between 0 and 90 degree. This is our v-coordinate
            */
            float value = baseOffsetFromZero + valueOffset;
            float scaledValue = value / radius;
            float arctan = Mathf.Atan(scaledValue);
            float result = arctan * Mathf.Rad2Deg / 90.0f;
            return result;
        }

        /// <summary>
        /// Transforms a distance between two world-coordinates from HRZ-files into uv-amount for our shader 
        /// </summary>
        /// <param name="baseOffsetFromZero">This is the value "How high in the air the base of the Gourad shaded area is (world offset)." from HRZ-file</param>
        /// <param name="radius">This is the value "The radius of the horizon" from HRZ-file</param>
        /// <param name="fromOffset">This is a offset from baseOffsetFromZero. e.g. "Bottom of horizon pixmap (offset from base)"</param>
        /// <param name="toOffset">This is a offset from baseOffsetFromZero. e.g. "Top of horizon pixmap (offset from base)"</param>
        /// <returns></returns>
        private static float scale (float baseOffsetFromZero, float radius, float fromOffset, float toOffset) {
            float vFrom = toV(baseOffsetFromZero, radius, fromOffset);
            float vTo = toV(baseOffsetFromZero, radius, toOffset);
            // invert the value as the texture-tiling increases if the distance between from and to is getting smaller
            return 1.0f / (vTo - vFrom);
        }

        public static Weather CreateWeather(RenderPipeline rp, NFSData.HRZ.HRZFile hrz, WeatherType type, Texture2D pixmap, Texture2D clouds, ImporterSettings settings) {
            Weather weather = ScriptableObject.CreateInstance<Weather>();

            weather.type = type;

            switch (hrz.WeatherType) {
                case 1:
                    weather.weatherEffect = WeatherEffect.Rain;
                    weather.effect = settings.rainEffect;
                    break;
                case 2:
                    weather.weatherEffect = WeatherEffect.Snow;
                    weather.effect = settings.snowEffect;
                    break;
                default:
                    weather.weatherEffect = WeatherEffect.None;
                    break;
            }

            if (hrz.LightningChancePerTicks.Item1 > 0) {
                weather.lightning = settings.lightningEffect;
                weather.lightningChance = hrz.LightningChancePerTicks.Item1;
                weather.perSeconds = hrz.LightningChancePerTicks.Item2 >> 6;
                weather.lightningHeight = settings.lightningHeight;
            }

            // skybox
            weather.skybox = createSkybox(rp, hrz, pixmap, clouds);

            // sunlight
            weather.sunColor = new Color32((byte) (hrz.AmbientLightPercentagesRGB.Item1 * 2.55f),(byte) (hrz.AmbientLightPercentagesRGB.Item2 * 2.55f),(byte) (hrz.AmbientLightPercentagesRGB.Item3 * 2.55f), 0);

            // clouds movement
            weather.cloudsKPH = hrz.WindSpeed * 1.60934f; // MPH to KPH
            weather.cloudsDir = (Vector2)(Quaternion.Euler(0,0,hrz.WindDirection) * Vector2.right);

            // fog regions
            /*
              The density in NFS fog regions is given in percent, so we divide by 100 (= *0.01f).
              But this values are much to intense for the Unity fog. So we scale the fog again to make it look realistic.
            */
            int numFogRegions = hrz.NumFogRegions;

            // we have one global fog region and maybe more
            weather.fogRegions = new Weather.FogRegion[numFogRegions + 1];
            // assign the global fog
            weather.fogRegions[0] = new Weather.FogRegion (
                true,
                0,
                0,
                0,
                hrz.GlobalFogColor,
                hrz.GlobalFogColor,
                hrz.GlobalFogColor,
                (float) hrz.GlobalFogDensity * 0.01f * FOGSCALINGFACTOR,
                (float) hrz.GlobalFogDensity * 0.01f * FOGSCALINGFACTOR,
                (float) hrz.GlobalFogDensity * 0.01f * FOGSCALINGFACTOR
            );
            // create the other regions
            for (int i = 0; i < hrz.NumFogRegions; i++) {
                weather.fogRegions[i + 1] = new Weather.FogRegion(
                    false,
                    hrz.GetFogRegion(i).BeforeSlice,
                    hrz.GetFogRegion(i).CenterSlice,
                    hrz.GetFogRegion(i).AfterSlice,
                    hrz.GetFogRegion(i).StartColor,
                    hrz.GetFogRegion(i).ApexColor,
                    hrz.GetFogRegion(i).EndColor,
                    (float) hrz.GetFogRegion(i).StartDensity * 0.01f * FOGSCALINGFACTOR,
                    (float) hrz.GetFogRegion(i).ApexDensity * 0.01f * FOGSCALINGFACTOR,
                    (float) hrz.GetFogRegion(i).EndDensity * 0.01f * FOGSCALINGFACTOR
                );
            }

            // divide all values by 64
            weather.effectStayTimeOn = hrz.StayTimeOnTicks >> 6;
            weather.effectFadeTimeOff = hrz.FadeTimeOffTicks >> 6;
            weather.effectStayTimeOff = hrz.StayTimeOffTicks >> 6;
            weather.effectFadeTimeOn = hrz.FadeTimeOnTicks >> 6;
            weather.fadeVRoadPoints = hrz.Fade;


            return weather;
        }
    }
}
