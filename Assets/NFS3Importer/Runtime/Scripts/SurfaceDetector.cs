using UnityEngine;

namespace NFS3Importer.Runtime {
    public class SurfaceDetector : MonoBehaviour {

        private RaycastHit hit;
        private Surface surface;
        private int triangleIndex;
        public SurfaceFlag currentSurface;
        private float raycastDistanceMax = 10.0f;

        void Update() {
            Physics.Raycast(transform.position, Vector3.down, out hit, raycastDistanceMax);
            if(hit.collider != null) {
                hit.collider.transform.TryGetComponent<Surface>(out surface);
                triangleIndex = hit.triangleIndex;
                if(surface) {
                    surface.Surfaces.TryGetValue(triangleIndex, out currentSurface);
                }
            }
            
        }
    }
}
