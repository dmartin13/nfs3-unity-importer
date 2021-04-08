using UnityEngine;

namespace NFS3Importer.Runtime {
    public class ProgressTracker : MonoBehaviour {

        public VRoadPoint CurrentPoint {get; private set;}
        private VRoadPoint[] virtualRoadPoints;

        private float tmpDist;
        private VRoadPoint tmpPoint;
        private float sqrtDist;

        void Start() {
            virtualRoadPoints = NFSTrackSettings.Instance.virtualRoadPoints;
            tmpDist = float.PositiveInfinity;
            tmpPoint = virtualRoadPoints[0];
            foreach (VRoadPoint p in virtualRoadPoints) {
                sqrtDist = (p.position - transform.position).sqrMagnitude;
                if(sqrtDist < tmpDist) {
                    tmpDist = sqrtDist;
                    tmpPoint = p;
                }
            }
            CurrentPoint = tmpPoint;
        }

        void Update() {
            if(virtualRoadPoints != null) {
                tmpDist = (CurrentPoint.position - transform.position).sqrMagnitude;
                tmpPoint = CurrentPoint;
                foreach (VRoadPoint p in CurrentPoint.neighbors) {
                    sqrtDist = (p.position - transform.position).sqrMagnitude;
                    if(sqrtDist < tmpDist) {
                        tmpDist = sqrtDist;
                        tmpPoint = p;
                    }
                }
                CurrentPoint = tmpPoint;
            }
        }
    }   
}
