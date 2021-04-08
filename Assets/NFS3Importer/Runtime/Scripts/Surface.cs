using System.Collections.Generic;
using UnityEngine;

namespace NFS3Importer.Runtime {
    public class Surface : MonoBehaviour {
        public Dictionary<int, SurfaceFlag> Surfaces {get; set;}
        [SerializeField] private PolygonFlag[] polygonFlags;

        void Start() {
            Surfaces = new Dictionary<int, SurfaceFlag>();
            foreach (PolygonFlag pf in polygonFlags) {
                Surfaces.Add(pf.triangleIndex, pf.surfaceFlag);
            }
        }

        public void SetSurfaces (PolygonFlag[] polygonFlags) {
            this.polygonFlags = polygonFlags;
        }
    }
}
