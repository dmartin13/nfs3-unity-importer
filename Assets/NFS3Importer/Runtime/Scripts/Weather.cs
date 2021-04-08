using System.Collections.Generic;
using UnityEngine;

namespace NFS3Importer.Runtime {
    [CreateAssetMenu(fileName = "Weather", menuName = "NFS3Importer/Weather")]
    public class Weather : ScriptableObject {
        public WeatherType type;
        public WeatherEffect weatherEffect;
        public GameObject effect;
        public GameObject lightning;
        public float lightningHeight;
        public int effectStartPoint;
        public int effectStopPoint;
        // in seconds
        public int effectStayTimeOn;
        // in seconds
        public int effectFadeTimeOff;
        // in seconds
        public int effectStayTimeOff;
        // in seconds
        public int effectFadeTimeOn;
        // in seconds
        [Header("Lightning Settings")]
        [Range(0.0f, 100.0f)]
        public float lightningChance;
        public float perSeconds;
        // in num points
        [Header("Weather Fade Settings")]
        public int fadeVRoadPoints;
        public Material skybox;
        public Color32 sunColor;
        public Vector2 cloudsDir;
        public float cloudsKPH;
        // fog region at index 0 is the global fog
        public FogRegion[] fogRegions;

        [System.NonSerialized] private float timerWeatherEffect;
        [System.NonSerialized] private float timerLightning;
        [System.NonSerialized] private bool effectOn;
        [System.NonSerialized] private bool fadingOn;
        [System.NonSerialized] private bool fadingOff;
        [System.NonSerialized] private int rndIndex;
        [System.NonSerialized] private List<DynamicWeatherEffect> subscribers = new List<DynamicWeatherEffect>();

        public float EffectIntensity {get; private set;}

        [System.NonSerialized] private const float CLOUDSPEEDFACTOR = (1.0f / 3.6f) * 0.003f;

        /// <summary>
        /// This should be called from a MonoBehaviours Start()
        /// </summary>
        public void Start() {
            timerWeatherEffect = 0;
            timerLightning = 0;
            effectOn = true;
            fadingOff = false;
            fadingOn = false;
        }
        
        /// <summary>
        /// This should be called from a MonoBehaviours Update()
        /// </summary>
        public void Update() {
            // update cloud movement
            float movement = cloudsKPH * CLOUDSPEEDFACTOR * Time.deltaTime;
            skybox.SetVector("_CloudsOffset", skybox.GetVector("_CloudsOffset") + new Vector4(cloudsDir.x, cloudsDir.y, 0.0f, 0.0f) * movement);
            // update weather effect
            if(effectStayTimeOn == 0 && effectFadeTimeOff == 0 && effectStayTimeOff == 0 && effectFadeTimeOn == 0) {
                // if everything is zero we have no time based weather fading... weather is always on
                EffectIntensity = 1;
            } else {
                if(effectOn) {
                    if(fadingOff) {
                        EffectIntensity = Mathf.InverseLerp(effectFadeTimeOff, 0, timerWeatherEffect);
                        if(timerWeatherEffect >= effectFadeTimeOff) {
                            fadingOff = false;
                            effectOn = false;
                            timerWeatherEffect = 0;
                        }
                    } else if (timerWeatherEffect >= effectStayTimeOn) {
                        fadingOff = true;
                        timerWeatherEffect = 0;
                    } else {
                        EffectIntensity = 1;
                    }
                } else {
                    if(fadingOn) {
                        EffectIntensity = Mathf.InverseLerp(0, effectFadeTimeOn, timerWeatherEffect);
                        if(timerWeatherEffect >= effectFadeTimeOn) {
                            fadingOn = false;
                            effectOn = true;
                            timerWeatherEffect = 0;
                        }
                    } else if (timerWeatherEffect >= effectStayTimeOff) {
                        fadingOn = true;
                        timerWeatherEffect = 0;
                    } else {
                        EffectIntensity = 0;
                    }
                }
            }

            if(timerLightning >= perSeconds) {
                if(Random.Range(0, 100) < lightningChance * EffectIntensity) {
                    if(subscribers.Count > 0) {
                        rndIndex = Random.Range(0, subscribers.Count - 1);
                        subscribers[rndIndex].Lightning();
                    }
                }
                timerLightning = 0;
            }

            timerLightning += Time.deltaTime;
            timerWeatherEffect += Time.deltaTime;
        }

        public void Subscribe(DynamicWeatherEffect subscriber) {
            subscribers.Add (subscriber);
        }

        public FogRegion GetFogRegionAt(int id) {
            if (fogRegions == null || fogRegions.Length == 0) return null;

            // try to find a specific fog region
            for (int i = 1; i < fogRegions.Length; i++) {
                if (fogRegions[i].startPoint <= id && fogRegions[i].endPoint >= id) {
                    return fogRegions[i];
                }
            }
            // otherwise return the global fog region at [0]
            return fogRegions[0];
        }

        public FogParameter GetFogParameterAt(int id) {
            if (fogRegions == null || fogRegions.Length == 0) return null;

            return GetFogRegionAt(id).GetFogParameterAt(id);
        }

        public void Load(GameObject lightObj, VRoadPoint[] virtualRoadPoints) {
            setLight(lightObj);
            setFogParameters(virtualRoadPoints);
            setGlobalFog();
            RenderSettings.skybox = skybox;
        }

        private void setFogParameters(VRoadPoint[] virtualRoadPoints) {
            if(virtualRoadPoints != null) {
				for (int i = 0; i < virtualRoadPoints.Length; i++) {
					virtualRoadPoints[i].fogParameter = GetFogParameterAt(virtualRoadPoints[i].id);
				}
			} else {
				Debug.LogWarning("There are no virtual road points! Can't assign fog regions.");
			}
        }

        private void setLight(GameObject lightObj) {
            if(lightObj) {
                Light light = lightObj.GetComponent<Light>();
                if(!light) {
                    light = lightObj.AddComponent<Light>();
                }
                light.type = LightType.Directional;
                light.transform.rotation = Quaternion.Euler(50.0f, -30.0f, 0.0f);
                light.color = sunColor;
                light.lightmapBakeType = LightmapBakeType.Mixed;
                light.shadows = LightShadows.Soft;
            }
        }

        private void setGlobalFog() {
            RenderSettings.fog = true;
            RenderSettings.fogMode = FogMode.Exponential;
            RenderSettings.fogDensity = fogRegions[0].startDensity;
            RenderSettings.fogColor = fogRegions[0].startColor;
        }

        [System.Serializable]
        public class FogRegion {
            public bool isGlobal;
            public int startPoint;
            public int midPoint;
            public int endPoint;
            public Color startColor;
            public Color midColor;
            public Color endColor;
            public float startDensity;
            public float midDensity;
            public float endDensity;

            public FogRegion(bool isGlobal, int start, int midpoint, int end, Color startColor, Color midColor, Color endColor, float startDensity, float midDensity, float endDensity) {
                this.isGlobal = isGlobal;
                this.startPoint = start;
                this.midPoint = midpoint;
                this.endPoint = end;
                this.startColor = startColor;
                this.midColor = midColor;
                this.endColor = endColor;
                this.startDensity = startDensity;
                this.midDensity = midDensity;
                this.endDensity = endDensity;
            }

            public FogParameter GetFogParameterAt(int id) {
                if(isGlobal) {
                    return new FogParameter(startColor, startDensity);
                }
                return new FogParameter(getColorAt(id), getDensityAt(id));
            }

            private float getDensityAt(int id) {
                if (id >= startPoint && id <= midPoint) {
                    return Mathf.Lerp(startDensity, midDensity, Mathf.InverseLerp(startPoint, midPoint, id));
                } else if (id >= midPoint && id <= endPoint) {
                    return Mathf.Lerp(midDensity, endDensity, Mathf.InverseLerp(midPoint, endPoint, id));
                }
                return 0.0f;
            }

            private Color getColorAt(int id) {
                if (id >= startPoint && id <= midPoint) {
                    return Color.Lerp(startColor, midColor, Mathf.InverseLerp(startPoint, midPoint, id));
                } else if (id >= midPoint && id <= endPoint) {
                    return Color.Lerp(midColor, endColor, Mathf.InverseLerp(startPoint, midPoint, id));
                }
                // this should not happen. So return a "warning-color" for debugging
                return Color.magenta;
            }
        }

        [System.Serializable]
        public class FogParameter {

            public Color color;
            public float density;

            public FogParameter (Color color, float density) {
                this.color = color;
                this.density = density;
            }
        }
    }
}