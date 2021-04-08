using UnityEngine;
using NFS3Importer.Utility;
using System.Collections.Generic;
using System;
using NFS3Importer.Runtime;

namespace NFS3Importer.UnityData {

	public struct Quad2D {
		public Vector2 v0, v1, v2, v3;

		public void Shift (Vector2 value) {
			v0 += value;
			v1 += value;
			v2 += value;
			v3 += value;
		}

		public void Rotate (float eulerAngle) {
			v0.Rotate (eulerAngle);
			v1.Rotate (eulerAngle);
			v2.Rotate (eulerAngle);
			v3.Rotate (eulerAngle);
		}

		public Quad3D toQuad3D () {
			return new Quad3D {
				v0 = new Vector3 (v0.x, v0.y, 0),
				v1 = new Vector3 (v1.x, v1.y, 0),
				v2 = new Vector3 (v2.x, v2.y, 0),
				v3 = new Vector3 (v3.x, v3.y, 0),
			};
		}

		public float area {
			get {
				Vector2 a = v3 - v0;
				Vector2 b = v2 - v3;
				Vector2 c = v1 - v2;
				Vector2 d = v0 - v1;
				return 0.5f * (c.magnitude * d.magnitude * Mathf.Sin (Vector2.Angle (c, d) * Mathf.Deg2Rad) +
				a.magnitude * b.magnitude * Mathf.Sin (Vector2.Angle (a, b) * Mathf.Deg2Rad));
			}
		}

		public override string ToString () {
			return "{" + v0 + ", " + v1 + ", " + v2 + ", " + v3 + "}";
		}
	}

	public struct Quad3D {
		public Vector3 v0, v1, v2, v3;

		public void Shift (Vector3 value) {
			v0 += value;
			v1 += value;
			v2 += value;
			v3 += value;
		}

		public void Rotate (float eulerAngle, Vector3 axis) {
			v0.Rotate (eulerAngle, axis);
			v1.Rotate (eulerAngle, axis);
			v2.Rotate (eulerAngle, axis);
			v3.Rotate (eulerAngle, axis);
		}

		public override string ToString () {
			return "{" + v0 + ", " + v1 + ", " + v2 + ", " + v3 + "}";
		}

		public override bool Equals (object obj) {

			if (!(obj is Quad3D)) {
				return false;
			}

			Vector3[] ownVerts = { v0, v1, v2, v3 };
			Vector3[] otherVerts = { ((Quad3D)obj).v0, ((Quad3D)obj).v1, ((Quad3D)obj).v2, ((Quad3D)obj).v3 };

			int comparer (Vector3 v1, Vector3 v2) {
				int i = v1.x.CompareTo (v2.x);
				if (i == 0) {
					i = v1.z.CompareTo (v2.z);
				}
				if (i == 0) {
					return v1.y.CompareTo (v2.y);
				}
				return i;
			}

			// sort the Vectors first by x and then by z coordinates. So we can create a 2d array
			// with x and z as indices for the dimension
			Array.Sort (ownVerts, comparer);
			Array.Sort (otherVerts, comparer);

			for (int i = 0; i < 4; i++) {
				if (ownVerts[i] != otherVerts[i]) {
					return false;
				}
			}
			return true;
		}

        // Our GetHashCode() does not need to be efficient. We just have to make sure that
		// the set in addBoxColliders() (NFS2UnityParser.CS) uses the Equals-Method for 
		// every element instead of GetHashCode()
		public override int GetHashCode() {
            return 1;
        }
    }

	public struct BoundingBoxQuad {
		public Vector3 localPosition;
		public Quaternion localRotation;
		public float sizeX, sizeY, sizeZ;

		public float area {
			get {
				return Mathf.Abs (sizeX * sizeY);
			}
		}

		public override string ToString () {
			return "{" + sizeX + ", " + sizeY + ", " + sizeZ + "}";
		}
	}

	public struct TrackInfo {
		public string Name { get; set; }
		public string FRDPath { get; set; }
		public string COLPath { get; set; }
		public string[] HRZPaths { get; set; }
		public string QFSPath { get; set; }
		public string SkyFSHPath { get; set; }
		public string[] CANPaths { get; set; }
	}

	public struct Polygon {
		public Vector3 v1, v2, v3, v4;

		public Edge[] Edges3D {
			get {
				return new Edge[] {new Edge(v1,v2, block), new Edge(v2,v3, block), new Edge(v3,v4, block), new Edge(v4,v1, block)};
			}
		}
		public bool isPassable;

		public int block;

		public SurfaceFlag surfaceFlag;

	}

	public struct GeneratedObject {
		public UnityEngine.Object o;
		public ObjectType type;
		public string name;

		public GeneratedObject(UnityEngine.Object o, ObjectType type, string name) {
			this.o = o;
			this.type = type;
			this.name = name;
		}
	}
}
