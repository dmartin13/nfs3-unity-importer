using System;
using NFS3Importer.Utility;

namespace NFS3Importer.NFSData.CAN {
	public class CANFile {

		private FileReader fileContent;

		// 2 Byte short
		public int Size {get; private set;}
		// 1 Byte
		public int Type {get; private set;}
		// 1 Byte
		public int Struct3D {get; private set;}
		// 2 Byte short
		public int AnimLength {get; private set;}
		// 2 Byte short
		public int Unknown {get; private set;}
		public CANPoint[] Animation {get; private set;}

		public CANFile (byte[] fileContent) {
			this.fileContent = new FileReader (fileContent);
			generate ();
		}

		private void generate () {
			Size = fileContent.readShort ();
			Type = fileContent.readByte ();
			Struct3D = fileContent.readByte ();
			AnimLength = fileContent.readShort ();
			Unknown = fileContent.readShort ();

			Animation = new CANPoint[AnimLength];
			for (int i = 0; i < AnimLength; i++) {

				byte[] x = fileContent.readBytes (4);
				System.Array.Reverse (x);

				Animation [i] = new CANPoint (BitConverter.ToInt32 (x, 0), fileContent.readInt (), fileContent.readInt (), 
					fileContent.readShort (), fileContent.readShort (), fileContent.readShort (), fileContent.readShort ());
			}
		}
	}
}
