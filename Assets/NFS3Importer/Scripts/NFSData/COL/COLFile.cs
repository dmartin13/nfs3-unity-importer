using UnityEngine;
using NFS3Importer.Utility;
using NFS3Importer.NFSData.GLOBAL;

namespace NFS3Importer.NFSData.COL {
	public class COLFile {
		private readonly FileReader fileContent;

		// [4] (4 Byte char) 'COLL'
		public char[] CollID { get; set; }
		//  11
		public int Version { get; set; }

		public int FileLength { get; set; }

		public int NumBlocks { get; set; }
		// [5]
		public int[] XbTable { get; set; }

		public XBHead TextureHead { get; set; }

		public COLTextureInfo[] Textures { get; set; }

		public XBHead Struct3DHead { get; set; }

		public COLStruct3D[] Struct3D { get; set; }

		public XBHead ObjectHead { get; set; }

		public COLObject[] ColObject { get; set; }

		public XBHead Object2Head { get; set; }

		public COLObject[] ColObject2 { get; set; }

		public XBHead VroadHead { get; set; }

		public COLVRoad[] Vroad { get; set; }
		//for the extra HS data in COLVROAD
		public int ExtraHS { get; set; }


		public COLFile (byte[] fileContent) {
			this.fileContent = new FileReader (fileContent);
			generate ();
		}

		private void generate () {

			this.ExtraHS = 0;

			// read collID
			this.CollID = new char[] { (char)fileContent.readByte (), (char)fileContent.readByte (),
				(char)fileContent.readByte (), (char)fileContent.readByte ()
			};
			// read version
			this.Version = fileContent.readInt ();
			// read file length
			this.FileLength = fileContent.readInt ();
			// read number of blocks
			this.NumBlocks = fileContent.readInt ();

			// skip validity checks
			// version has to be 11, numBlocks has to be 2 or 4 or 5, CollID has to be
			// 'COLL'

			// read xbTable
			this.XbTable = new int[this.NumBlocks];
			for (int i = 0; i < this.NumBlocks; i++) {
				this.XbTable [i] = fileContent.readInt ();
			}

			// texture XB
			this.TextureHead = new XBHead (fileContent.readInt (), fileContent.readShort (), fileContent.readShort ());
			this.Textures = new COLTextureInfo[this.TextureHead.NumRec];
			for (int i = 0; i < this.TextureHead.NumRec; i++) {
				this.Textures [i] = new COLTextureInfo (fileContent.readShort (), fileContent.readShort (),
					fileContent.readShort (), fileContent.readShort ());
			}

			// struct3D XB
			if (this.NumBlocks >= 4) {
				this.Struct3DHead = new XBHead (fileContent.readInt (), fileContent.readShort (), fileContent.readShort ());
				this.Struct3D = new COLStruct3D[this.Struct3DHead.NumRec];
				for (int i = 0; i < this.Struct3DHead.NumRec; i++) {
					this.Struct3D [i] = new COLStruct3D ();
					this.Struct3D [i].Size = fileContent.readInt ();
					this.Struct3D [i].NumVertices = fileContent.readShort ();
					this.Struct3D [i].NumPolygons = fileContent.readShort ();

					int delta = (8 + 16 * this.Struct3D [i].NumVertices + 6 * this.Struct3D [i].NumPolygons) % 4;
					delta = (4 - delta) % 4;

					this.Struct3D [i].Vertices = new COLVertex[this.Struct3D [i].NumVertices];
					for (int j = 0; j < this.Struct3D [i].NumVertices; j++) {
						this.Struct3D [i].Vertices [j] = new COLVertex (fileContent.readVector3 (), fileContent.readInt ());
					}
					this.Struct3D [i].Polygons = new COLPolygon[this.Struct3D [i].NumPolygons];
					for (int j = 0; j < this.Struct3D [i].NumPolygons; j++) {
						this.Struct3D [i].Polygons [j] = new COLPolygon ();
						this.Struct3D [i].Polygons [j].Texture = fileContent.readShort ();
						byte[] vertices = new byte[4];
						vertices [0] = fileContent.readByte ();
						vertices [1] = fileContent.readByte ();
						vertices [2] = fileContent.readByte ();
						vertices [3] = fileContent.readByte ();
						this.Struct3D [i].Polygons [j].Vertices = vertices;
					}
					if (delta > 0) {
						fileContent.readBytes (delta);
					}
				}

				// Object XB
				this.ObjectHead = new XBHead (fileContent.readInt (), fileContent.readShort (), fileContent.readShort ());
				this.ColObject = new COLObject[this.ObjectHead.NumRec];
				for (int i = 0; i < this.ObjectHead.NumRec; i++) {
					this.ColObject [i] = new COLObject ();
					this.ColObject [i].Size = fileContent.readShort ();
					this.ColObject [i].Type = fileContent.readByte ();
					this.ColObject [i].Struct3D = fileContent.readByte ();
					if (this.ColObject [i].Type == 1) {
						this.ColObject [i].RefPoint = fileContent.readVector3Int ();
					} else if (this.ColObject [i].Type == 3) {
						this.ColObject [i].AnimLength = fileContent.readShort ();
						this.ColObject [i].Unknown = fileContent.readShort ();
						this.ColObject [i].AnimData = new AnimationData[this.ColObject [i].AnimLength];
						for (int j = 0; j < this.ColObject [i].AnimLength; j++) {
							this.ColObject [i].AnimData [j] = new AnimationData ();
							this.ColObject [i].AnimData [j].Point = fileContent.readVector3Int ();
							this.ColObject [i].AnimData [j].Od1 = fileContent.readShort ();
							this.ColObject [i].AnimData [j].Od2 = fileContent.readShort ();
							this.ColObject [i].AnimData [j].Od3 = fileContent.readShort ();
							this.ColObject [i].AnimData [j].Od4 = fileContent.readShort ();
						}
						this.ColObject [i].RefPoint = this.ColObject [i].AnimData [0].Point;
					} else {
						// unknown object
					}
				}
			}

			// Object2 XB
			if (this.NumBlocks == 5) {
				this.Object2Head = new XBHead (fileContent.readInt (), fileContent.readShort (), fileContent.readShort ());
				this.ColObject2 = new COLObject[this.Object2Head.NumRec];
				for (int i = 0; i < this.Object2Head.NumRec; i++) {
					this.ColObject2 [i] = new COLObject ();
					this.ColObject2 [i].Size = fileContent.readShort ();
					this.ColObject2 [i].Type = fileContent.readByte ();
					this.ColObject2 [i].Struct3D = fileContent.readByte ();
					if (this.ColObject2 [i].Type == 1) {
						this.ColObject2 [i].RefPoint = fileContent.readVector3Int ();
					} else if (this.ColObject2 [i].Type == 3) {
						this.ColObject2 [i].AnimLength = fileContent.readShort ();
						this.ColObject2 [i].Unknown = fileContent.readShort ();
						this.ColObject2 [i].AnimData = new AnimationData[this.ColObject2 [i].AnimLength];
						for (int j = 0; j < this.ColObject2 [i].AnimLength; j++) {
							this.ColObject2 [i].AnimData [j] = new AnimationData ();
							this.ColObject2 [i].AnimData [j].Point = fileContent.readVector3Int ();
							this.ColObject2 [i].AnimData [j].Od1 = fileContent.readShort ();
							this.ColObject2 [i].AnimData [j].Od2 = fileContent.readShort ();
							this.ColObject2 [i].AnimData [j].Od3 = fileContent.readShort ();
							this.ColObject2 [i].AnimData [j].Od4 = fileContent.readShort ();
						}
						this.ColObject2 [i].RefPoint = this.ColObject2 [i].AnimData [0].Point;
					} else {
						// unknown object
					}
				}
			}

			// VRoad XB
			this.VroadHead = new XBHead (fileContent.readInt (), fileContent.readShort (), fileContent.readShort ());
			this.Vroad = new COLVRoad[this.VroadHead.NumRec];
			for (int i = 0; i < this.VroadHead.NumRec; i++) {
				this.Vroad [i] = new COLVRoad ();
				this.Vroad [i].RefPoint = fileContent.readVector3Int ();
				this.Vroad [i].Unknown = fileContent.readInt ();
				COLVector normal, forward, right;
				normal = new COLVector (fileContent.readSignedByte (), fileContent.readSignedByte (), fileContent.readSignedByte (),
					fileContent.readByte ());
				forward = new COLVector (fileContent.readSignedByte (), fileContent.readSignedByte (), fileContent.readSignedByte (),
					fileContent.readByte ());
				right = new COLVector (fileContent.readSignedByte (), fileContent.readSignedByte (), fileContent.readSignedByte (),
					fileContent.readByte ());
				this.Vroad [i].Normal = normal;
				this.Vroad [i].Forward = forward;
				this.Vroad [i].Right = right;
				this.Vroad [i].LeftWall = fileContent.readInt ();
				this.Vroad [i].RightWall = fileContent.readInt ();
			}

			// finally check if we reached the end of file
			if (fileContent.getContentLength () - fileContent.getCurrPos () == 0) {
				Debug.Log ("End of 'COL' file reached :)");
			} else {
				Debug.Log ("Something went wrong! The file-end was not reached. " + (fileContent.getContentLength () - fileContent.getCurrPos ()) + " Bytes left!");
			}
		}
	}
}
