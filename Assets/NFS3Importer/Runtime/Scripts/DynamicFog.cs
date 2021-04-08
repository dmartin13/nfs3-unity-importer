using UnityEngine;
using UnityEngine.Rendering;

namespace NFS3Importer.Runtime {
    public class DynamicFog : MonoBehaviour {

        [Range(0.0f, 2.0f)] public float intensity = 1.0f;

        private Weather weather;
        private ProgressTracker progressTracker;
        private VRoadPoint currentVRoadPoint;
        private bool fog;
        private FogMode fogMode;
        private float fogDensity;
        private Color fogColor;
        private float fogStartDistance;
        private float fogEndDistance;
        private bool active;
        
        void Start() {
            progressTracker = GetComponentInParent<ProgressTracker>();
            weather = NFSTrackSettings.Instance.Weather;
            RenderPipelineManager.beginCameraRendering += OnBeginCameraRendering;
            active = progressTracker && weather;
        }

        // for Built-In (Legacy) RP
        void OnPreRender() {
            preRender();
        }

        // for Built-In (Legacy) RP
        void OnPostRender() {
            postRender();
        }

        // for URP and HDRP
        void OnBeginCameraRendering(ScriptableRenderContext context, Camera camera) {
            preRender();
        }

        // for URP and HDRP
        void OnEndCameraRendering() {
            postRender();
        }

        void OnDestroy() {
            RenderPipelineManager.beginCameraRendering -= OnBeginCameraRendering;
        }

        private void preRender() {
            if(active) {
                // get current position on track
                currentVRoadPoint = progressTracker.CurrentPoint;

                if(currentVRoadPoint.fogParameter == null) return;

                // save old values
                fog = RenderSettings.fog;
                fogMode = RenderSettings.fogMode;
                fogDensity = RenderSettings.fogDensity;
                fogColor = RenderSettings.fogColor;
                fogStartDistance = RenderSettings.fogStartDistance;
                fogEndDistance = RenderSettings.fogEndDistance;

                // load new values
                RenderSettings.fog = true;
                RenderSettings.fogMode = FogMode.Exponential;
                RenderSettings.fogDensity = currentVRoadPoint.fogParameter.density * intensity;
                RenderSettings.fogColor = currentVRoadPoint.fogParameter.color;
            }
        }

        private void postRender() {
            if(active) {
                // restore old values
                RenderSettings.fog = fog;
                RenderSettings.fogMode = fogMode;
                RenderSettings.fogDensity = fogDensity;
                RenderSettings.fogColor = fogColor;
                RenderSettings.fogStartDistance = fogStartDistance;
                RenderSettings.fogEndDistance = fogEndDistance;
            }
        }
    }
}
