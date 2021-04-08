using UnityEngine;

namespace NFS3Importer.Runtime {
    public class DynamicWeatherEffect : MonoBehaviour {

        private Weather weather;
        private ParticleSystem.EmissionModule emissionModule;
        private float emissionRate;
        private ProgressTracker progressTracker;
        private VRoadPoint currentVRoadPoint;
        private bool active;
        private ParticleSystem pSys;
        private GameObject weatherEffect;
        public GameObject lightning;
        private int fade;
        private float positionBasedIntensity;
        private int numVRoadPoints;
        private Camera cam;
        private float lightningRadius;
        private (int, int) interval;
        private int offset;
        
        void Start() {
            progressTracker = GetComponentInParent<ProgressTracker>();
            weather = NFSTrackSettings.Instance.Weather;
            weather.Subscribe(this);
            numVRoadPoints = NFSTrackSettings.Instance.virtualRoadPoints.Length;
            cam = GetComponent<Camera>();
            active = progressTracker && weather && weather.effect;
            if(active) {
                weatherEffect = Instantiate(weather.effect, this.transform);
                pSys = weatherEffect.GetComponent<ParticleSystem>();
                emissionModule = pSys.emission;
                emissionRate = emissionModule.rateOverTime.constant;
                fade = weather.fadeVRoadPoints;
                lightning = weather.lightning;
                if(cam) {
                    if(cam.farClipPlane - weather.lightningHeight >= 0) {
                        lightningRadius = Mathf.Sqrt((cam.farClipPlane * cam.farClipPlane) - (weather.lightningHeight * weather.lightningHeight));
                    }
                }
            }
        }

        void Update() {
            if(active) {
                if(weather.effectStartPoint != weather.effectStopPoint) {
                    if(Utils.PointInClosedInterval(progressTracker.CurrentPoint.id, Utils.ModN(weather.effectStartPoint - fade, numVRoadPoints), Utils.ModN(weather.effectStopPoint + fade, numVRoadPoints), numVRoadPoints)) {
                        if(Utils.PointInClosedInterval(progressTracker.CurrentPoint.id, Utils.ModN(weather.effectStartPoint - fade, numVRoadPoints), weather.effectStartPoint, numVRoadPoints)) {
                            offset = Utils.ModN(weather.effectStartPoint - fade, numVRoadPoints);
                            interval = Utils.RemapCircularInterval((offset, weather.effectStartPoint), -offset, numVRoadPoints);
                            positionBasedIntensity = Mathf.InverseLerp(interval.Item1, interval.Item2, Utils.ModN(progressTracker.CurrentPoint.id - offset, numVRoadPoints));
                        } else if (Utils.PointInClosedInterval(progressTracker.CurrentPoint.id, weather.effectStopPoint, Utils.ModN(weather.effectStopPoint + fade, numVRoadPoints), numVRoadPoints)) {
                            offset = weather.effectStopPoint;
                            interval = Utils.RemapCircularInterval((offset, Utils.ModN(weather.effectStopPoint + fade, numVRoadPoints)), -offset, numVRoadPoints);
                            positionBasedIntensity = 1 - Mathf.InverseLerp(interval.Item1, interval.Item2, Utils.ModN(progressTracker.CurrentPoint.id - offset, numVRoadPoints));
                        } else {
                            positionBasedIntensity = 1;
                        }
                    } else {
                        positionBasedIntensity = 0;
                    }
                } else {
                    positionBasedIntensity = 1;
                }
                
                emissionModule.rateOverTime = emissionRate * weather.EffectIntensity * positionBasedIntensity;
            }
        }

        public void Lightning() {

            if(lightningRadius > 0) {
                if(Random.Range(0, 100) < positionBasedIntensity * 100) {
                    // Instantiate lightningbolts inside the cameras far-clip plane (lightningRadius) and at least lightningRadius * 0.5f away from the camera so its more likely to see the bolt.
                    // The position is relative to the current camera position
                    float a = Random.Range(0, 2 * Mathf.PI);
                    float b = Random.Range(lightningRadius * 0.5f, lightningRadius);
                    Instantiate(lightning, new Vector3(Mathf.Cos(a) * b, weather.lightningHeight, Mathf.Sin(a) * b) + transform.position, Quaternion.identity);
                }
            }
            
        }
        
    }
}
