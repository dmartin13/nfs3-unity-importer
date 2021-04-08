using System.Collections.Generic;
using UnityEngine;
using System;
using NFS3Importer.UnityData;

namespace NFS3Importer.Utility {
	public static class Utils {

		public class Vector3Comparer : IEqualityComparer<Vector3> {
			public bool Equals(Vector3 a, Vector3 b) {
				if (Mathf.Abs(a.x - b.x) > 0.001) return false;
				if (Mathf.Abs(a.y - b.y) > 0.001) return false;
				if (Mathf.Abs(a.z - b.z) > 0.001) return false;
				return true; //indeed, very close
			}
 
			public int GetHashCode(Vector3 obj) {
				//a cruder than default comparison, allows to compare very close-vector3's into same hash-code.
				return Math.Round(obj.x, 3).GetHashCode() ^ Math.Round(obj.y, 3).GetHashCode() << 2 ^ Math.Round(obj.z, 3).GetHashCode() >> 2;
			}
		}

		public static Vector3 CalculateQuadNormal (Vector3 p1, Vector3 p2, Vector3 p3, Vector3 p4) {
			Vector3 triANormal = CalculateNormal (p1, p2, p3);
			Vector3 triBNormal = CalculateNormal (p1, p3, p4);
			return Vector3.Normalize (triANormal + triBNormal);
		}

		public static Vector3 CalculateNormal (Vector3 p1, Vector3 p2, Vector3 p3) {
			//Vector3 vertexNormal = new Vector3 (0, 0, 0);

			//Vector3 U = p2 - p1;
			//Vector3 V = p3 - p1;

			// this is the cross product
			return Vector3.Cross((p2 - p1), (p3 - p1));
			//vertexNormal.x = (U.y * V.z) - (U.z * V.y);
			//vertexNormal.y = (U.z * V.x) - (U.x * V.z);
			//vertexNormal.z = (U.x * V.y) - (U.y * V.x);

			//return vertexNormal;
		}

		/// <summary>
		/// Rotates vertices from a 3D quad (x, y, z) to a 2D quad (x, y)
		/// </summary>
		/// <returns>The inverse rotation that has been applied to the quad3d. 
		/// out quad2d gives the 3D->2D transformed quad</returns>
		/// <param name="quad3d">3D quad</param>
		public static Quaternion Quad3dToQuad2d (Quad3D quad3d, out Quad2D quad2d) {

			// the normal vector of the quad
			Vector3 normal = Vector3.Cross (quad3d.v1 - quad3d.v0, quad3d.v2 - quad3d.v0).normalized;

			// the angle between the normal and the z-axis vector
			float angle = Vector3.Angle (Vector3.forward, -normal);

			// rotation axis
			Vector3 axis = Vector3.Cross (Vector3.forward, normal);

			// the rotation
			Quaternion q = Quaternion.AngleAxis (angle, axis);

			Vector2 project (Vector3 point) {
				point = q * point;
				return new Vector2 (point.x, point.y);
			}

			Quad2D result = new Quad2D {
				v0 = project (quad3d.v0),
				v1 = project (quad3d.v1),
				v2 = project (quad3d.v2),
				v3 = project (quad3d.v3)
			};

			quad2d = result;

			return Quaternion.Inverse (q);
		}

		/// <summary>
		/// Calculates the minimum bounding box of a 3D quad
		/// </summary>
		/// <param name="quad">Quad.</param>
		/// <param name="thickness">Thickness.</param>
		public static BoundingBoxQuad MinimumBoundingBoxQuad3D (Quad3D quad, float thickness) {
			Quad2D q2d;
			// convert quad3d to quad2d
			Quaternion rot = Quad3dToQuad2d (quad, out q2d);
			// calculate optimal bounding box 2d
			BoundingBoxQuad result = MinimumBoundingBoxQuad2D (q2d, thickness);
			// rotate back into 3d space
			result.localRotation = rot * result.localRotation;
			result.localPosition = rot * result.localPosition;
			return result;
		}

		/// <summary>
		/// Calculates the minimum bounding box of a 2D quad
		/// </summary>
		public static BoundingBoxQuad MinimumBoundingBoxQuad2D (Quad2D quad, float thickness) {

			// calculates the bounding box of a quad2d by rotating the specified edge to the x-axis
			BoundingBoxQuad getBoundingBoxOfEdge (Quad2D q, int edgeIndex) {

				//current edge
				Vector2 ev0 = Vector2.zero, ev1 = Vector2.zero;
				switch (edgeIndex % 4) {
					case 0:
						ev0 = q.v0;
						ev1 = q.v1;
						break;
					case 1:
						ev0 = q.v1;
						ev1 = q.v2;
						break;
					case 2:
						ev0 = q.v2;
						ev1 = q.v3;
						break;
					case 3:
						ev0 = q.v3;
						ev1 = q.v0;
						break;
				}

				// shift quad v0 to origin
				//q.Shift (-ev0);
				// rotate the quad so that the current edge is parallel to the x-axis
				float angle = Vector2.Angle (Vector2.right, ev1 - ev0);
				q.Rotate (angle);
				// calculate min/max x and min/max y
				float[] xArray = new float[] { q.v0.x, q.v1.x, q.v2.x, q.v3.x };
				float[] yArray = new float[] { q.v0.y, q.v1.y, q.v2.y, q.v3.y };
				float minX = Mathf.Min (xArray);
				float maxX = Mathf.Max (xArray);
				float minY = Mathf.Min (yArray);
				float maxY = Mathf.Max (yArray);

				float sizeX = Mathf.Abs (maxX - minX);
				float sizeY = Mathf.Abs (maxY - minY);
				float sizeZ = thickness;

				float centerX = minX + sizeX / 2.0f;
				float centerY = minY + sizeY / 2.0f;
				Vector2 localPosition = new Vector2 (centerX, centerY);
				localPosition.Rotate (-angle);

				BoundingBoxQuad b = new BoundingBoxQuad {
					sizeX = sizeX,
					sizeY = sizeY,
					sizeZ = sizeZ,
					localRotation = Quaternion.Euler (new Vector3 (0, 0, angle)),
					localPosition = localPosition
				};

				return b;
			}

			// check all 4 possible boxes (each edge is tested as "basis-edge")
			// The bounding box with minimum of free space between collider box 
			// and quad is choosen
			BoundingBoxQuad minBBox = new BoundingBoxQuad ();
			float minFreeArea = float.PositiveInfinity;
			for (int i = 0; i < 4; i++) {
				BoundingBoxQuad bBoxEdge;
				bBoxEdge = getBoundingBoxOfEdge (quad, i);
				float freeArea = bBoxEdge.area - quad.area;
				if (minBBox.area.Equals (0.0f) || freeArea < minFreeArea) {
					minBBox = bBoxEdge;
					minFreeArea = freeArea;
				}
			}

			return minBBox;
		}

		/// <summary>
		/// calculates the modulo of x divided by n
		/// </summary>
		/// <param name="x"></param>
		/// <param name="n"></param>
		/// <returns></returns>
		public static int Modulo(int x,int n){
    		return (x % n + n) % n;
		}
		public static NFSData.FSHQFS.FSHQFSItem GetTexture(FSHQFSGroup group, int id, NFSData.FSHQFS.FSHQFSItem[] textures) {
			for (int i = 0; i < textures.Length; i++) {
				if(textures[i].Group == group && textures[i].ID == id) {
					return textures[i];
				}
			}
			return null;
		}
	}
}
