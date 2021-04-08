using UnityEngine;
using System;

namespace NFS3Importer.Utility {
	public class FileReader {

		private byte[] bytes;
		private int currPos;

		public FileReader (byte[] bytes) {
			this.bytes = bytes;
			this.currPos = 0;
		}

		public byte readByte () {
			Debug.Assert (currPos < bytes.Length);
			return bytes[currPos++];
		}

		public sbyte readSignedByte () {
			return (sbyte)readByte ();
		}

		public byte[] readBytes (int length) {
			Debug.Assert ((currPos + length - 1) < bytes.Length);
			byte[] result = new byte[length];
			for (int i = 0; i < length; i++) {
				result[i] = bytes[currPos++];
			}
			return result;
		}

		public int readInt () {
			Debug.Assert ((currPos + 3) <= bytes.Length);
			int result = BitConverter.ToInt32 (bytes, currPos);
			currPos += 4;
			return result;
		}

		public uint readUInt () {
			Debug.Assert ((currPos + 3) <= bytes.Length);
			uint result = BitConverter.ToUInt32 (bytes, currPos);
			currPos += 4;
			return result;
		}

		public int readByteAsInt () {
			return (int)readByte ();
		}

		public short readShort () {
			Debug.Assert ((currPos + 1) <= bytes.Length);
			short result = BitConverter.ToInt16 (bytes, currPos);
			currPos += 2;
			return result;
		}

		public char readChar8Bit () {
			return (char)readByte ();
		}

		public float readFloat () {
			Debug.Assert ((currPos + 3) <= bytes.Length);
			float result = BitConverter.ToSingle (bytes, currPos);
			currPos += 4;
			return result;
		}

		public Vector3 readVector3 () {
			return new Vector3 (readFloat (), readFloat (), readFloat ());
		}

		public Vector3Int readVector3Int () {
			return new Vector3Int (readInt (), readInt (), readInt ());
		}

		public Vector3 readVector3IntToFloat () {
			return new Vector3 (readInt () / 65536.0f, readInt () / 65536.0f, readInt () / 65536.0f);
		}

		public int getCurrPos () {
			return this.currPos;
		}

		public int getContentLength () {
			return this.bytes.Length;
		}
	}
}