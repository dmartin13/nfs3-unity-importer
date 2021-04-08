using UnityEngine;

namespace NFS3Importer.Utility {
	/// <summary>
	/// Edge.
	/// </summary>
	public class Edge {

		public readonly Vector3 v1;
		public readonly Vector3 v2;
		public readonly int block;

		public Edge (Vector3 v1, Vector3 v2) {
			this.v1 = v1;
			this.v2 = v2;
		}

		public Edge (Vector3 v1, Vector3 v2, int block) {
			this.v1 = v1;
			this.v2 = v2;
			this.block = block;
		}

		public Edge To2D() {
			return new Edge(new Vector3(v1.x, 0, v1.z), new Vector3(v2.x, 0, v2.z), block);
		}

		public override bool Equals (object obj) {
			if (obj.GetType () == typeof(Edge)) {
				if (((Edge)obj).v1 == (v1) && ((Edge)obj).v2 == (v2)) {
					return true;
				}
				if (((Edge)obj).v1 == (v2) && ((Edge)obj).v2 == (v1)) {
					return true;
				}
			}
			return false;
		}

		public override int GetHashCode () {
			return v1.GetHashCode () + v2.GetHashCode ();
		}
	}
}
