using UnityEngine;
using System.Collections.Generic;
using System;

namespace NFS3Importer.Utility {
	public static class ExtensionMethods {

		public static Vector3 Vector3Int2Float (this Vector3Int v) {
			return new Vector3 (v.x / 65536.0f, v.y / 65536.0f, v.z / 65536.0f);
		}

		public static void Rotate (ref this Vector2 v, float angle) {
			v = Quaternion.Euler (0, 0, angle) * v;
		}

		public static void Rotate (ref this Vector3 v, float angle, Vector3 axis) {
			v = Quaternion.AngleAxis (angle, axis) * v;
		}

		public static void SetLinear (this AnimationCurve curve) {
			for (int i = 0; i < curve.keys.Length; ++i) {
				float intangent = 0;
				float outtangent = 0;
				bool intangent_set = false;
				bool outtangent_set = false;
				Vector2 point1;
				Vector2 point2;
				Vector2 deltapoint;
				Keyframe key = curve[i];

				if (i == 0) {
					intangent = 0;
					intangent_set = true;
				}

				if (i == curve.keys.Length - 1) {
					outtangent = 0;
					outtangent_set = true;
				}

				if (!intangent_set) {
					point1.x = curve.keys[i - 1].time;
					point1.y = curve.keys[i - 1].value;
					point2.x = curve.keys[i].time;
					point2.y = curve.keys[i].value;

					deltapoint = point2 - point1;

					intangent = deltapoint.y / deltapoint.x;
				}
				if (!outtangent_set) {
					point1.x = curve.keys[i].time;
					point1.y = curve.keys[i].value;
					point2.x = curve.keys[i + 1].time;
					point2.y = curve.keys[i + 1].value;

					deltapoint = point2 - point1;

					outtangent = deltapoint.y / deltapoint.x;
				}

				key.inTangent = intangent;
				key.outTangent = outtangent;
				curve.MoveKey (i, key);
			}
		}

		public static bool ContainsCaseInsensitive (this string s, string needle) {
			return s.IndexOf (needle, System.StringComparison.OrdinalIgnoreCase) >= 0;
		}

		public static float Remap (this float value, float from1, float to1, float from2, float to2) {
    		return (value - from1) / (to1 - from1) * (to2 - from2) + from2;
		}

		public static byte[] GetUTF8Bytes(this string str)
        {
            return System.Text.UTF8Encoding.UTF8.GetBytes(str);
        }

		public static string GetUTF8String(this byte[] array)
        {
            return System.Text.Encoding.UTF8.GetString(array);
        }

		public static byte[] ToByteArray(this int[] input)
        {
            List<byte> result = new List<byte>();
			for (int i = 0; i < input.Length; i++) {
				result.AddRange(BitConverter.GetBytes(input[i]));
			}
			return result.ToArray();
        }
	}
}