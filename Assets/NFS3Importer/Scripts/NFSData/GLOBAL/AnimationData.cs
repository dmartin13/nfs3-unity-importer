using UnityEngine;

namespace NFS3Importer.NFSData.GLOBAL {
	public class AnimationData {

		public AnimationData () {
		}

		public AnimationData (Vector3Int point, short od1, short od2, short od3, short od4) {
			this.Point = point;
			this.Od1 = od1;
			this.Od2 = od2;
			this.Od3 = od3;
			this.Od4 = od4;
		}


		public Vector3Int Point { get; set; }

		public short Od1 { get; set; }

		public short Od2 { get; set; }

		public short Od3 { get; set; }

		public short Od4 { get; set; }
	}
}
