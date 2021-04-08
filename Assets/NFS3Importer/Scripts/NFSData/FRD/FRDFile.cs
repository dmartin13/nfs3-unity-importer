using UnityEngine;
using NFS3Importer.Utility;
using NFS3Importer.NFSData.GLOBAL;

namespace NFS3Importer.NFSData.FRD {
	public class FRDFile {
		
		private byte[] header;
		private FileReader fileContent;

		public FRDFile (byte[] fileContent) {
			this.fileContent = new FileReader (fileContent);
			generate ();
		}

		public int NumBlocks { get; set; }

		public int NumTextures { get; set; }

		public TrackBlock[] TrackBlocks { get; set; }

		public PolygonBlock[] PolygonBlocks { get; set; }

		public XObjectBlock[] XObjects{ get; set; }

		public TextureBlock[] Textures { get; set; }

		public void generate () {
			TrackBlock b;
			PolygonBlock p;
			XObjectData x;
			ObjectPolygonBlock o;

			// Read 28 Byte to header
			header = fileContent.readBytes (28);

			// read number of Blocks (4 Bytes)
			NumBlocks = fileContent.readInt () + 1;

			// throw exception if there are 0 Blocks or more than 500 blocks
			if (NumBlocks < 1 || NumBlocks > 500) {
				//throw new RuntimeException ("Invalid number of blocks!");
			}

			// +1 = Dummy trackblock for global objects
			TrackBlocks = new TrackBlock[NumBlocks + 1];

			// +4 because global objects are added at the end
			XObjects = new XObjectBlock[4 * NumBlocks + 4];

			// TrackBlocks
			for (int i = 0; i < NumBlocks; i++) {
				b = new TrackBlock ();
				
				b.CenterPoint = fileContent.readVector3 ();

				Vector3[] boundings = new Vector3[4];
				boundings [0] = fileContent.readVector3 ();
				boundings [1] = fileContent.readVector3 ();
				boundings [2] = fileContent.readVector3 ();
				boundings [3] = fileContent.readVector3 ();
				b.BoundingPoints = boundings;

				b.NumVertices = fileContent.readInt ();

				b.NumHighResVerts = (fileContent.readInt ());
				b.NumLowResVerts = (fileContent.readInt ());
				b.NumMedResVerts = (fileContent.readInt ());

				b.NumVerticesDup = (fileContent.readInt ());

				b.NumObjectVert = (fileContent.readInt ());

				// b.verts
				Vector3[] bVerts = new Vector3[b.NumVertices];
				for (int m = 0; m < b.NumVertices; m++) {
					bVerts [m] = fileContent.readVector3 ();
				}
				b.Vertices = (bVerts);

				// b.unknownVerts
				int[] unknVerts = new int[b.NumVertices];
				for (int m = 0; m < b.NumVertices; m++) {
					unknVerts [m] = fileContent.readInt ();
				}
				b.UnknVertices = (unknVerts);

				NeighborData[] nbData = new NeighborData[0x12C]; // 0x12C = 300
				for (int m = 0; m < 0x12C; m++) {
					nbData [m] = new NeighborData (fileContent.readShort (), fileContent.readShort ());
				}
				b.NbData = (nbData);

				b.NumStartPos = (fileContent.readInt ());

				b.NumPositions = (fileContent.readInt ());
				b.NumPolygons = (fileContent.readInt ());
				b.NumVRoad = (fileContent.readInt ());
				b.NumXObj = (fileContent.readInt ());
				b.NumPolyObj = (fileContent.readInt ());
				b.NumSoundSrc = (fileContent.readInt ());
				b.NumLightSrc = (fileContent.readInt ());

				PositionData[] posData = new PositionData[b.NumPositions];
				for (int m = 0; m < b.NumPositions; m++) {
					posData [m] = new PositionData (fileContent.readShort (), fileContent.readByte (),
						fileContent.readByte (), fileContent.readShort (), fileContent.readShort ());
				}
				b.PosData = (posData);

				// POLYVROADDATA
				PolyVRoadData[] polyData = new PolyVRoadData[b.NumPolygons];
				for (int m = 0; m < b.NumPolygons; m++) {
					polyData [m] = new PolyVRoadData (fileContent.readByte (), fileContent.readByte (),
						new byte[] { fileContent.readByte (), fileContent.readByte (), fileContent.readByte (),
							fileContent.readByte (), fileContent.readByte (), fileContent.readByte ()
						},
						null, null, 0, false);
				}
				b.PolygonVRoadData = (polyData);

				// VROADDATA
				VRoadData[] vroadData = new VRoadData[b.NumVRoad];
				for (int m = 0; m < b.NumVRoad; m++) {
					vroadData [m] = new VRoadData (fileContent.readShort (), fileContent.readShort (), fileContent.readShort (),
						fileContent.readShort (), fileContent.readShort (), fileContent.readShort ());
				}
				b.VRData = (vroadData);

				// Xobj
				if (b.NumXObj > 0) {
					RefXObject[] xobj = new RefXObject[b.NumXObj];
					for (int m = 0; m < b.NumXObj; m++) {
						xobj [m] = new RefXObject (fileContent.readVector3 (), fileContent.readShort (),
							fileContent.readShort (), fileContent.readShort (), fileContent.readByte (),
							fileContent.readByte ());
					}
					b.Xobj = (xobj);
				}

				// alignment?
				if (b.NumPolyObj > 0) {
					// into the void??
					fileContent.readBytes (20 * b.NumPolyObj);
				}
				//b.setnPolyobj(0);

				// SOUNDSRC
				SoundSource[] soundsrc = new SoundSource[b.NumSoundSrc];
				for (int m = 0; m < b.NumSoundSrc; m++) {
					soundsrc [m] = new SoundSource (fileContent.readVector3Int (), fileContent.readInt ());
				}
				b.SoundSrc = (soundsrc);

				// LIGHTSRC
				LightSource[] lightsrc = new LightSource[b.NumLightSrc];
				for (int m = 0; m < b.NumLightSrc; m++) {
					lightsrc [m] = new LightSource (fileContent.readVector3Int (), fileContent.readInt ());
				}
				b.LightSource = (lightsrc);

				TrackBlocks [i] = b;
			}

			/// POLYGONBLOCKs
			PolygonBlocks = new PolygonBlock[NumBlocks];
			for (int i = 0; i < NumBlocks; i++) {
				p = new PolygonBlock ();
				PolygonData[][] poly = new PolygonData[7][];
				int[] sz = new int[7];
				int[] szdup = new int[7];
				for (int j = 0; j < 7; j++) {
					sz [j] = fileContent.readInt ();
					if (sz [j] != 0) {
						szdup [j] = fileContent.readInt ();
						poly [j] = new PolygonData[sz [j]];
						for (int k = 0; k < sz [j]; k++) {
							poly [j] [k] = new PolygonData (
								new short[] { fileContent.readShort (), fileContent.readShort (), fileContent.readShort (),
									fileContent.readShort ()
								},
								fileContent.readShort (), fileContent.readShort (), fileContent.readByte (),
								fileContent.readByte ());
						}
						p.Polygons = (poly);
					}
				}
				p.Size = (szdup);
				p.SizeDup = (szdup);

				if (p.Size [4] != TrackBlocks [i].NumPolygons)
					return;

				ObjectPolygonBlock[] obj = new ObjectPolygonBlock[4];
				for (int j = 0; j < 4; j++) {
					o = new ObjectPolygonBlock ();
					o.N1 = (fileContent.readInt ());
					if (o.N1 > 0) {
						o.N2 = (fileContent.readInt ());
						int[] types = new int[o.N2];
						int[] numpoly = new int[o.N2];
						poly = new PolygonData[o.N2][];
						o.NumObjects = (0);
						int l = 0;

						for (int k = 0; k < o.N2; k++) {
							types [k] = fileContent.readInt ();

							if (types [k] == 1) {
								numpoly [o.NumObjects] = fileContent.readInt ();
								o.NumPoly = (numpoly);
								poly [o.NumObjects] = new PolygonData[o.NumPoly [o.NumObjects]];

								for (int m = 0; m < o.NumPoly [o.NumObjects]; m++) {
									poly [o.NumObjects] [m] = new PolygonData (
										new short[] { fileContent.readShort (), fileContent.readShort (),
											fileContent.readShort (), fileContent.readShort ()
										},
										fileContent.readShort (), fileContent.readShort (), fileContent.readByte (),
										fileContent.readByte ());
								}
								l += o.NumPoly [o.NumObjects];
								o.NumObjects = (o.NumObjects + 1);
							}
						}
						if (l != o.N1)
							return; // n1 == total nb polygons
						o.Polygons = (poly);
						o.Types = (types);
					}
					obj [j] = o;
				}

				p.Obj = (obj);

				PolygonBlocks [i] = p;
			}

			// XOBJBLOCKs
			for (int i = 0; i <= 4 * NumBlocks; i++) {

				XObjects [i] = new XObjectBlock ();
				int nObj = fileContent.readInt ();
				XObjects [i].NumObj = (nObj);

				if (nObj > 0) {
					XObjectData[] obj = new XObjectData[XObjects [i].NumObj];

					for (int j = 0; j < XObjects [i].NumObj; j++) {
						x = new XObjectData ();
						// 3 headers = 12 bytes
						x.CrossType = (fileContent.readInt ());
						x.CrossNo = (fileContent.readInt ());
						x.Unknown = (fileContent.readInt ());

						if (x.CrossType == 4) { // basic objects
							x.RefPoint = (fileContent.readVector3 ());
							x.AnimMemory = (fileContent.readInt ());
						} else if (x.CrossType == 3) { // animated objects
							// unkn3, type3, objno, nAnimLength, AnimDelay == 24 bytes
							x.Unknown3 = (
							    new short[] { fileContent.readShort (), fileContent.readShort (), fileContent.readShort (),
								fileContent.readShort (), fileContent.readShort (), fileContent.readShort (),
								fileContent.readShort (), fileContent.readShort (), fileContent.readShort ()
							});
							x.Type3 = (fileContent.readByte ());
							x.ObjNo = (fileContent.readByte ());
							x.NAnimLength = (fileContent.readShort ());
							x.AnimDelay = (fileContent.readShort ());

							if (x.Type3 != 3)
								return;

							AnimationData[] animData = new AnimationData[x.NAnimLength];
							for (int k = 0; k < x.NAnimLength; k++) {
								animData [k] = new AnimationData (fileContent.readVector3Int (), fileContent.readShort (),
									fileContent.readShort (), fileContent.readShort (), fileContent.readShort ());
							}
							x.AnimaData = (animData);
							// make a ref point from first anim position
							x.RefPoint = (new Vector3 (x.AnimaData [0].Point.x / 65536.0f,
								x.AnimaData [0].Point.z / 65536.0f,
								x.AnimaData [0].Point.y / 65536.0f));
						} else {
							return; // unknown object type
						}
						// common part : vertices & polygons
						x.NumVertices = (fileContent.readInt ());
						Vector3[] vert = new Vector3[x.NumVertices];
						for (int k = 0; k < x.NumVertices; k++) {
							vert [k] = fileContent.readVector3 ();
						}
						x.Vertices = (vert);

						int[] unknVertices = new int[x.NumVertices];
						for (int k = 0; k < x.NumVertices; k++) {
							unknVertices [k] = fileContent.readInt ();
						}
						x.UnknVertices = (unknVertices);

						x.NumPolygons = (fileContent.readInt ());
						PolygonData[] polyData = new PolygonData[x.NumPolygons];
						for (int k = 0; k < x.NumPolygons; k++) {
							polyData [k] = new PolygonData (
								new short[] { fileContent.readShort (), fileContent.readShort (), fileContent.readShort (),
									fileContent.readShort ()
								},
								fileContent.readShort (), fileContent.readShort (), fileContent.readByte (),
								fileContent.readByte ());
						}
						x.PolygonData = (polyData);
						obj [j] = x;
					}

					XObjects [i].Objects = (obj);
				}
			}

			// TEXTUREBLOCKs
			NumTextures = fileContent.readInt ();
			Textures = new TextureBlock[NumTextures];
			for (int i = 0; i < NumTextures; i++) {
				TextureBlock tex = new TextureBlock ();
				tex.Width = (fileContent.readShort ());
				tex.Height = (fileContent.readShort ());
				tex.Unknown1 = (fileContent.readInt ());
				tex.UVCoords = (new float[] { fileContent.readFloat (), fileContent.readFloat (), fileContent.readFloat (),
					fileContent.readFloat (), fileContent.readFloat (), fileContent.readFloat (), fileContent.readFloat (),
					fileContent.readFloat ()
				});
				tex.Unknown2 = (fileContent.readInt ());
				tex.IsLane = (fileContent.readByte ());
				tex.Texture = (fileContent.readShort ());
				Textures [i] = tex;
			}

			// finally check if we reached the end of file
			if (fileContent.getContentLength () - fileContent.getCurrPos () == 0) {
				Debug.Log ("End of 'FRD' file reached :)");
			} else {
				Debug.Log ("Something went wrong! The file-end was not reached. " + (fileContent.getContentLength () - fileContent.getCurrPos ()) + " Bytes left!");
			}
		}
	}
}
