using UnityEngine;

namespace NFS3Importer.NFSData.COL {
	public class COLVertex {
		// relative coord
		public Vector3 Point  { get; set; }
		//like the unknVertices structures in FRD
		private int Unknown { get; set; }

		public COLVertex () {
		}

		public COLVertex (Vector3 point, int unknown) {
			this.Point = point;
			this.Unknown = unknown;
		}
	}
}
