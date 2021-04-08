using UnityEngine;

namespace NFS3Importer.NFSData.COL {
	public class COLVector {
		public sbyte X { get; set; }

		public sbyte Z { get; set; }

		public sbyte Y { get; set; }

		public byte Unknown { get; set; }

		public COLVector () {
		}

		public COLVector (sbyte x, sbyte z, sbyte y, byte unknown) {
			this.X = x;
			this.Z = z;
			this.Y = y;
			this.Unknown = unknown;
		}

		public Vector3 ToVector3Float () {
			return new Vector3 (X / 128.0f, Z / 128.0f, Y / 128.0f).normalized;
		}

		public override string ToString () {
			return "(X: " + X + ", Z: " + Z + ", Y: " + Y + ")";
		}
	}
}
