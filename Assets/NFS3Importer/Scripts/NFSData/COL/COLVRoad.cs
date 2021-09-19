using NFS3Importer.Utility;
using UnityEngine;

namespace NFS3Importer.NFSData.COL {
	public class COLVRoad {
		public Vector3Int RefPoint { get; set; }
		// flags ?
		public int Unknown{ get; set; }

		public COLVector Normal{ get; set; }

		public COLVector Forward{ get; set; }

		public COLVector Right{ get; set; }

		public int LeftWall{ get; set; }

		public int RightWall{ get; set; }

		public COLVRoad () {
		}

		public COLVRoad (Vector3Int refPoint, int unknown, COLVector normal, COLVector forward, COLVector right,
		                 int leftWall, int rightWall) {
			this.RefPoint = refPoint;
			this.Unknown = unknown;
			this.Normal = normal;
			this.Forward = forward;
			this.Right = right;
			this.LeftWall = leftWall;
			this.RightWall = rightWall;
		}

        public override string ToString()
        {
            return "{ " + "RefPoint: " + RefPoint.Vector3Int2Float().ToString() + ", VRoad: " + Unknown.ToString("X8") + " }";
        }
    
	}
}
