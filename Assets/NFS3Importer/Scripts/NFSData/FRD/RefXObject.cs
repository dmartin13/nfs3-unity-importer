using UnityEngine;

namespace NFS3Importer.NFSData.FRD {
	public class RefXObject {

		public RefXObject () {
		}

		public RefXObject (Vector3 point, short unknown1, short globalNo, short unknown2, byte crossIndex, byte collideEffect) {
			this.Point = point;
			this.Unknown1 = unknown1;
			this.GlobalNo = globalNo;
			this.Unknown2 = unknown2;
			this.CrossIndex = crossIndex;
			this.CollideEffect = collideEffect;
		}

		public Vector3 Point { get; set; }

		public short Unknown1 { get; set; }

		public short GlobalNo { get; set; }

		public short Unknown2 { get; set; }

		public byte CrossIndex { get; set; }

		public byte CollideEffect { get; set; }
	}
}
