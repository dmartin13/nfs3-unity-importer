using System.Collections.Generic;
using NFS3Importer.NFSData.FRD;
using NFS3Importer.UnityData;
using UnityEditor;
using UnityEngine;
using NFS3Importer.Utility;
using System.Linq;
using NFS3Importer.HullDelaunayVoronoi.Voronoi;
using NFS3Importer.HullDelaunayVoronoi.Primitives;
using NFS3Importer.Runtime;
using NFS3Importer.NFSData.GLOBAL;

namespace NFS3Importer {
	public class NFS2UnityParser {

		private FRDFile frd;
		private NFSData.COL.COLFile col;
		private NFSData.CAN.CANFile[] canFiles;
		private ImporterSettings settings;
		private MaterialHandler materialHandler;

		// this is a temporary hashmap which stores all processed vertices of trackblocks and polygonobjects
		// and all their normals (cause a vertice can be used by multiple faces/trackblocks/objects with
		// different normals). This list is later used to calculate the optimal normal for each vertice
		public static NFS3Importer.Utility.Utils.Vector3Comparer customComparer = new NFS3Importer.Utility.Utils.Vector3Comparer ();
		private Dictionary<Vector3, HashSet<Vector3>> tmpVerticesToNormals = new Dictionary<Vector3, HashSet<Vector3>> (customComparer);
		private List<Mesh> generatedMeshes = new List<Mesh> ();
		// this List stores all edges that are walls in the block colliders and their indices inside the collidermeshes vertices array (v1, v1Top, v2Top, v2)
		private List<(Edge, int, int, int, int)> tmpWallEdges = new List<(Edge, int, int, int, int)>();

		private List<GameObject> xObjects = new List<GameObject>();
		private (Mesh, PolygonFlag[])[] blockColliderMeshes;
		private GameObject[] blocks;
		private List<MeshCollider> blockColliders = new List<MeshCollider>();

		private bool saveToAssets;

		private int meshNameCounter = 0;
		private int animationNameCounter = 0;

		// This value is used for determining the possible Neighbors of a Virtual Road Point 
		// if teh distance between two Virtual Road Points is less or eqaul to this value they are treated as neighbors. This is mainly used for detecting abbreviations
		private const float VROADNEIGHBORTHRESHOLD = 20.0f; // 20 meters

		private const float BOXCOLLIDERTHICKNESS = 0.15f; // 15 cm

		private List<GeneratedObject> generatedObjects;

		private (Vector3, Vector3, Vector3)[] lightProbePositions;

		private int lod2intBlock {
			get {
				switch (settings.levelOfDetail) {
					case UnityData.LOD.HighRes:
						return 4;
					case UnityData.LOD.MidRes:
						return 2;
					case UnityData.LOD.LowRes:
						return 0;
					default:
						return 4;
				}
			}
		}

		private int lod2intBlockExtras {
			get {
				switch (settings.levelOfDetail) {
					case UnityData.LOD.HighRes:
						return 5;
					case UnityData.LOD.MidRes:
						return 3;
					case UnityData.LOD.LowRes:
						return 1;
					default:
						return 5;
				}
			}
		}

		public NFS2UnityParser (FRDFile frd, NFSData.COL.COLFile col, NFSData.CAN.CANFile[] canFiles, MaterialHandler materialHandler, bool saveToAssets, ref List<GeneratedObject> generatedObjects, ImporterSettings settings) {
			this.frd = frd;
			this.col = col;
			this.canFiles = canFiles;
			this.materialHandler = materialHandler;
			this.saveToAssets = saveToAssets;
			this.settings = settings;
			this.generatedObjects = generatedObjects;
		}

		public GameObject GetTrack () {
			GameObject track = new GameObject ("Need For Speed Track");
			track.isStatic = true;

			this.blocks = new GameObject[this.frd.NumBlocks];

			blockColliderMeshes = generateBlockColliderMeshes();

			//FRD
			for (int i = 0; i < frd.NumBlocks; i++) {
				GameObject block = getBlock (i);
				if (block != null) {
					block.transform.SetParent (track.transform);
					block.isStatic = true;
					blocks[i] = block;
				}

				GameObject blockLanes = getLanes (i);
				if (blockLanes != null) {
					blockLanes.transform.SetParent (block.transform);
					blockLanes.isStatic = true;
				}

				GameObject blockExtras = getBlockExtras (i);
				if (blockExtras != null) {
					blockExtras.transform.SetParent (block.transform);
					blockExtras.isStatic = true;
				}

				GameObject[] polyObjects;
				polyObjects = getPolyObjects (i);
				foreach (GameObject polyObject in polyObjects) {
					polyObject.transform.SetParent (block.transform);
					polyObject.isStatic = true;
				}

				GameObject[] blockXObjects;
				blockXObjects = getXObjects (i);
				foreach (GameObject xObject in blockXObjects) {
					xObject.transform.SetParent (block.transform);
				}
				xObjects.AddRange(blockXObjects);

				GameObject[] lights;
				lights = getLights (i);
				foreach (GameObject light in lights) {
					light.transform.SetParent (block.transform);
					light.isStatic = true;
				}

				GameObject[] sounds;
				sounds = getSounds (i);
				foreach (GameObject sound in sounds) {
					sound.transform.SetParent (block.transform);
					sound.isStatic = true;
				}
			}

			// optimize block colliders (solve intersecting colliders)
			optimizeBlockColliders(blocks);

			// add Fixed Joints to all HitAndFall-XObjects from all blocks
			addFixedJoints(xObjects.ToArray());

			// fetching global xObjects (last virtual block)
			GameObject[] xObjectsGlobal;
			xObjectsGlobal = getXObjects (frd.NumBlocks);
			foreach (GameObject xObject in xObjectsGlobal) {
				xObject.transform.SetParent (track.transform);
			}

			GameObject[] vRoadPointsGameObjects;
			vRoadPointsGameObjects = getVRoadPoints ();
			GameObject vRoadHolder = new GameObject ("Virtual Road Points");
			vRoadHolder.transform.SetParent (track.transform);
			foreach (GameObject vRoadPoint in vRoadPointsGameObjects) {
				vRoadPoint.transform.SetParent (vRoadHolder.transform);
			}

			// make our Virtual Roadpoints accessable for users
			VRoadPoint[] virtualRoadPoints = vRoadPointsGameObjects.Select(p => p.GetComponent<VRoadPoint>()).ToArray();

			// create neighbordata for vroadpoint with voronoi-diagram
			createVRoadPointNeighbors(virtualRoadPoints);

			NFSTrackSettings.Instance.virtualRoadPoints =  virtualRoadPoints;


			// the vRoadPoints have to be calculated before this can be called
			GameObject lightProbeGroup = createLightProbes();
			lightProbeGroup.transform.SetParent (track.transform);

			//COL
			//	it seems that COL Objects are duplicated and not necessary to be imported

			//	GameObject[] colObjects = getCOLObjects ();
			//	if (colObjects != null) {
			//		foreach (GameObject s in colObjects) {
			//			s.transform.SetParent (track.transform);
			//		}
			//	}

			//optimize normals
			optimizeNormals ();

			return track;
		}

		private GameObject getBlock (int block) {
			// LOD: 0 for lowres, 2 for medres, 4 for hires
			return generateGameObject (EntityType.BLOCK, frd.TrackBlocks[block].Vertices,
				frd.PolygonBlocks[block].Polygons[lod2intBlock], "Block_" + block, block);
		}

		private GameObject getLanes (int block) {
			const int levelOfDetail = 6; // 6 = Lanes
			return generateGameObject (EntityType.LANE, frd.TrackBlocks[block].Vertices,
				frd.PolygonBlocks[block].Polygons[levelOfDetail], "Lane_" + block);
		}

		private GameObject getBlockExtras (int block) {
			// LOD: 1 for lowres, 3 for medres, 5 for hires
			return generateGameObject (EntityType.BLOCKEXTRAS, frd.TrackBlocks[block].Vertices,
				frd.PolygonBlocks[block].Polygons[lod2intBlockExtras], "BlockExtra_" + block);
		}

		private GameObject[] getPolyObjects (int block) {
			List<GameObject> objects = new List<GameObject> ();

			for (int i = 0; i < frd.PolygonBlocks[block].Obj.Length; i++) {
				if (frd.PolygonBlocks[block].Obj[i].Polygons != null) {
					for (int j = 0; j < frd.PolygonBlocks[block].Obj[i].Polygons.Length; j++) {
						if (frd.PolygonBlocks[block].Obj[i].Polygons[j] != null) {
							objects.Add (generateGameObject (EntityType.POLYOBJ, frd.TrackBlocks[block].Vertices,
								frd.PolygonBlocks[block].Obj[i].Polygons[j],
								"Object_" + block + "_" + i + "_" + j));
						}
					}
				}
			}

			return objects.ToArray ();
		}

		private GameObject[] getXObjects (int block) {
			List<GameObject> objects = new List<GameObject> ();

			// 4 XObjectBlocks per TrackBlock
			for (int i = 0; i < 4; i++) {
				if (frd.XObjects[block * 4 + i] == null) {
					continue;
				}
				for (int j = 0; j < frd.XObjects[block * 4 + i].NumObj; j++) {
					XObjectData xObject = frd.XObjects[block * 4 + i].Objects[j];

					GameObject generatedXObject = generateGameObject (EntityType.XOBJ, xObject.Vertices, xObject.PolygonData, "XObject_" + block + "_" + i + "_" + j);
					// update Position
					generatedXObject.transform.position = xObject.RefPoint;

					XObjectCollideEffect collideEffect;
					XObjectType type = getXObjectType (xObject.CrossType);
					if (type == XObjectType.Collision) {
						// fetch collideeffect-byte from trackblocks REFXOBJ
						byte originalCollideEffect = frd.TrackBlocks[block].Xobj[xObject.CrossNo].CollideEffect;
						collideEffect = getXObjectCollideEffect (originalCollideEffect);

						switch (collideEffect) {
							case XObjectCollideEffect.Solid:
								// create solid collider
								MeshCollider mc = generatedXObject.AddComponent<MeshCollider> ();
								mc.sharedMesh = generatedXObject.GetComponent<MeshFilter> ().sharedMesh;
								generatedXObject.isStatic = true;
								break;
							case XObjectCollideEffect.HitAndFall:
								// create collider and fixed joint
								addBoxColliders (generatedXObject, xObject.PolygonData, xObject.Vertices);
								hitAndFallObjectHelper(generatedXObject);
								break;
							case XObjectCollideEffect.DriveThroughWithSound:
								// TODO: decode soundeffect
								DriveThroughWithSoundObject dt = generatedXObject.AddComponent<DriveThroughWithSoundObject> ();
								dt.Init (null, 0);
								generatedXObject.isStatic = true;
								break;
						}

					} else if (type == XObjectType.Animated) {
						//Animated
						//swap z y coords
						generatedXObject.transform.position = new Vector3 (
							generatedXObject.transform.position.x,
							generatedXObject.transform.position.z,
							generatedXObject.transform.position.y
						);

						AnimationClip clip = createAnimationData (xObject.AnimaData);

						#if UNITY_EDITOR
						if(saveToAssets)
							this.generatedObjects.Add(new GeneratedObject(clip, ObjectType.Animation, (animationNameCounter++) + ".anim"));
						#endif

						Animation anim = generatedXObject.AddComponent<Animation> ();
						AnimationHandler animHandler = generatedXObject.AddComponent<AnimationHandler>();
						anim.AddClip (clip, clip.name);

						// AnimDelay is saved as short but with a range between 1 and 400
						// whereas 1 is a fast movement and 400 is a very slow movement
						// Examples: 
						// AnimDelay: 1 -> 64 FPS = 2⁶
						// AnimDelay: 2 -> 32 FPS = 2⁵
						// AnimDelay: 4 -> 16 FPS = 2⁴
						// AnimDelay: 8 -> 8 FPS = 2³
						// AnimDelay: 16 -> 4 FPS = 2²
						// AnimDelay: 32 -> 2 FPS = 2¹
						// AnimDelay: 64 -> 1 FPS = 2⁰
						// AnimDelay: 128 -> 0.5 FPS = 2⁻¹
						// AnimDelay: 256 -> 0.25 FPS = 2⁻²
						// General Formula: 64/x

						float animSpeed = 64.0f / ((float) Mathf.Clamp (xObject.AnimDelay, 1, 400));
						animHandler.animationSpeed = animSpeed;
					}

					objects.Add (generatedXObject);
				}
			}

			return objects.ToArray ();
		}

		private GameObject[] getLights (int block) {
			List<GameObject> result = new List<GameObject> ();
			LightSource[] lightSources = frd.TrackBlocks[block].LightSource;

			foreach (LightSource lightSource in lightSources) {
				result.Add (TrackUtils.MakeLight (lightSource.RefPoint.Vector3Int2Float (), lightSource.Type, settings));
			}

			return result.ToArray ();
		}

		private GameObject[] getSounds (int block) {
			List<GameObject> result = new List<GameObject> ();
			SoundSource[] soundSources = frd.TrackBlocks[block].SoundSrc;

			for (int i = 0; i < soundSources.Length; i++) {
				SoundSource soundSource = soundSources[i];
				// for now: just create dummy SoundSources as we have no sounds so far (compression not decrypted)
				GameObject go = new GameObject ("Sound_" + block + "_" + i, typeof (AudioSource));
				go.transform.position = soundSource.RefPoint.Vector3Int2Float ();
				result.Add (go);
			}

			return result.ToArray ();
		}

		private void hitAndFallObjectHelper(GameObject go) {
			Rigidbody rb = go.AddComponent<Rigidbody>();
			rb.mass = settings.hitAndFallMass;
			HitAndFallObject hf = go.AddComponent<HitAndFallObject>();
			hf.Init(settings.hitAndFallRealMass);
		}

		private void addFixedJoints(GameObject[] xObjects) {

			// Vars
			GameObject currentObject;
			FixedJoint WorldJoint;
			Rigidbody myBody;
			BoxCollider[] myColliders;
			BoxCollider c;
			Collider[] intersectingColliders;
			bool skip;
			Collider otherCollider;
			Rigidbody otherBody;
			HitAndFallObject otherHitAndFall;
			FixedJoint[] otherJoints;
			FixedJoint currentJoint;
			FixedJoint fj;

			for (int i = 0; i < xObjects.Length; i++) {
				currentObject = xObjects[i];
				// we iterate over all X-Objects and search for HitAndFallObjects
				if(currentObject.GetComponent<HitAndFallObject>() == null) continue;

				// every HitAndFallObject has a "global" Fixed Joint which has no connected RigidBody
				WorldJoint = currentObject.AddComponent<FixedJoint>();
				WorldJoint.breakForce = settings.hitAndFallBreakForce;
				WorldJoint.breakTorque = settings.hitAndFallBreakForce;

				// fetch our Rigidbody
				myBody = currentObject.GetComponent<Rigidbody>();
				// and colliders
				myColliders = currentObject.GetComponentsInChildren<BoxCollider>(true);

				// no we iterate over all colliders of currentObject and search for intersecting colliders, so we can connect them with a Joint
				for (int j = 0; j < myColliders.Length; j++) {
					c = myColliders[j];

					// get intersecting colliders
					intersectingColliders = Physics.OverlapBox(c.transform.position, c.size * 0.5f, c.transform.rotation);

					for (int k = 0; k < intersectingColliders.Length; k++) {
						skip = false;
						otherCollider = intersectingColliders[k];

						// if the intersecting collider belongs to our self, then skip
						if(myColliders.Contains(otherCollider)) continue;

						otherBody = otherCollider.gameObject.GetComponentInParent<Rigidbody>();

						// if the other X-Object has no Rigidbody then skip
						if(otherBody == null) continue;

						// if the other object is also a HitAndFallObject then check if we have already connected the two objects with a Joint
						otherHitAndFall = otherCollider.GetComponentInParent<HitAndFallObject>();
						if(otherHitAndFall != null) {
							otherJoints = otherHitAndFall.transform.GetComponents<FixedJoint>();
							for (int l = 0; l < otherJoints.Length; l++) {
								currentJoint = otherJoints[l];
								if (currentJoint.connectedBody == myBody) {
									skip = true;
								}
							}
						}

						// if there is no connection so far add one
						if(!skip) {
							fj = currentObject.AddComponent<FixedJoint>();
							fj.breakForce = settings.hitAndFallBreakForce;
							fj.breakTorque = settings.hitAndFallBreakForce;
							fj.connectedBody = otherBody;
						}
					}
				}
			}
		}

		private static void addBoxColliders (GameObject obj, PolygonData[] polygonData, Vector3[] vertices) {

			// remove similar quads
			HashSet<Quad3D> quads = new HashSet<Quad3D> ();
			for (int i = 0; i < polygonData.Length; i++) {
				Quad3D quad = new Quad3D {
					v0 = vertices[polygonData[i].Vertex[0]],
					v1 = vertices[polygonData[i].Vertex[1]],
					v2 = vertices[polygonData[i].Vertex[2]],
					v3 = vertices[polygonData[i].Vertex[3]]
				};
				quads.Add (quad);
			}

			// create colliders
			int index = 0;
			foreach (Quad3D quad in quads) {
				BoundingBoxQuad bb = NFS3Importer.Utility.Utils.MinimumBoundingBoxQuad3D (quad, BOXCOLLIDERTHICKNESS);

				GameObject collider = new GameObject ("Collider_" + (index++));

				BoxCollider bc = collider.AddComponent<BoxCollider> ();
				bc.size = new Vector3 (bb.sizeX, bb.sizeY, bb.sizeZ);

				// it's very important to set the parent before position and rotation.
				// Otherwise the localPosition and localRotation won't work as these 
				// values are calculated in local space.
				collider.transform.SetParent (obj.transform);

				collider.transform.localPosition = bb.localPosition;
				collider.transform.localRotation = bb.localRotation;
			}
		}

		private static AnimationClip createAnimationData (AnimationData[] animData) {
			AnimationCurve curvePosX;
			AnimationCurve curvePosY;
			AnimationCurve curvePosZ;
			AnimationCurve curveRotX;
			AnimationCurve curveRotY;
			AnimationCurve curveRotZ;
			AnimationCurve curveRotW;
			AnimationClip clip = new AnimationClip ();
			clip.legacy = true;
			clip.name = animData.GetHashCode ().ToString ();

			Keyframe[] keysPosX = new Keyframe[animData.Length];
			Keyframe[] keysPosY = new Keyframe[animData.Length];
			Keyframe[] keysPosZ = new Keyframe[animData.Length];
			Keyframe[] keysRotX = new Keyframe[animData.Length];
			Keyframe[] keysRotY = new Keyframe[animData.Length];
			Keyframe[] keysRotZ = new Keyframe[animData.Length];
			Keyframe[] keysRotW = new Keyframe[animData.Length];
			for (int i = 0; i < animData.Length; i++) {
				keysPosX[i] = new Keyframe ((float)i, animData[i].Point.Vector3Int2Float ().x);
				keysPosY[i] = new Keyframe ((float)i, animData[i].Point.Vector3Int2Float ().y);
				keysPosZ[i] = new Keyframe ((float)i, animData[i].Point.Vector3Int2Float ().z);

				Quaternion q = new Quaternion (animData[i].Od1, animData[i].Od2, animData[i].Od3, animData[i].Od4);
				q.Normalize ();

				keysRotX[i] = new Keyframe ((float)i, q.x);
				keysRotY[i] = new Keyframe ((float)i, q.y);
				keysRotZ[i] = new Keyframe ((float)i, q.z);
				keysRotW[i] = new Keyframe ((float)i, q.w);
			}

			curvePosX = new AnimationCurve (keysPosX);
			curvePosY = new AnimationCurve (keysPosY);
			curvePosZ = new AnimationCurve (keysPosZ);
			curveRotX = new AnimationCurve (keysRotX);
			curveRotY = new AnimationCurve (keysRotY);
			curveRotZ = new AnimationCurve (keysRotZ);
			curveRotW = new AnimationCurve (keysRotW);

			curvePosX.SetLinear ();
			curvePosY.SetLinear ();
			curvePosZ.SetLinear ();
			curveRotX.SetLinear ();
			curveRotY.SetLinear ();
			curveRotZ.SetLinear ();
			curveRotW.SetLinear ();

			clip.SetCurve ("", typeof (Transform), "localPosition.x", curvePosX);
			clip.SetCurve ("", typeof (Transform), "localPosition.y", curvePosY);
			clip.SetCurve ("", typeof (Transform), "localPosition.z", curvePosZ);
			clip.SetCurve ("", typeof (Transform), "localRotation.x", curveRotX);
			clip.SetCurve ("", typeof (Transform), "localRotation.y", curveRotY);
			clip.SetCurve ("", typeof (Transform), "localRotation.z", curveRotZ);
			clip.SetCurve ("", typeof (Transform), "localRotation.w", curveRotW);

			clip.wrapMode = WrapMode.Loop;

			return clip;
		}

		private GameObject[] getVRoadPoints () {

			List<(Vector3, Vector3, Vector3)> tmpPoints = new List<(Vector3, Vector3, Vector3)>();

			if (col.VroadHead == null)
				return null;

			int numPoints = col.VroadHead.NumRec;

			GameObject[] result = new GameObject[numPoints];

			for (int i = 0; i < numPoints; i++) {
				NFSData.COL.COLVRoad colVRoadElement = col.Vroad[i];

				GameObject vRoadPoint = new GameObject ("VRoad_" + i);
				VRoadPoint p = vRoadPoint.AddComponent<VRoadPoint> ();
				Vector3 position = colVRoadElement.RefPoint.Vector3Int2Float ();
				Vector3 leftPoint = colVRoadElement.RefPoint.Vector3Int2Float () - colVRoadElement.Right.ToVector3Float () * (colVRoadElement.LeftWall / 65536.0f);
				Vector3 rightPoint = colVRoadElement.RefPoint.Vector3Int2Float () + colVRoadElement.Right.ToVector3Float () * (colVRoadElement.RightWall / 65536.0f);
				Vector3 up = colVRoadElement.Normal.ToVector3Float ().normalized;
				Vector3 forward = colVRoadElement.Forward.ToVector3Float ().normalized;
				Vector3 right = colVRoadElement.Right.ToVector3Float ().normalized;
				vRoadPoint.transform.position = position;
				vRoadPoint.transform.rotation = Quaternion.LookRotation(forward, up);
				p.Init (i, leftPoint, rightPoint);
				
				float f = settings.lightProbeMargin;
				tmpPoints.Add((position + up * f, leftPoint + up * f + right * f, rightPoint + up * f - right * f));

				result[i] = vRoadPoint;
			}

			// this is for creating our lightprobes later on
			this.lightProbePositions = tmpPoints.ToArray();

			return result;
		}

		private void createVRoadPointNeighbors(VRoadPoint[] points) {
			// Voronoi Classes from: https://github.com/Scrawk/Hull-Delaunay-Voronoi
			// transform our v road points to 2d
			Vertex2[] tmp = points.Select(p => new Vertex2(p.position.x, p.position.z)).ToArray();
			
			// create a voronoi diagram containing all v road points
			VoronoiMesh2<Vertex2> voronoi = new VoronoiMesh2<Vertex2>();
			// changed line 118 in VoronoiMesh.cs that region id's are equal with the VRoadPoint Id
			voronoi.Generate(tmp);

			// create a temporary hashmap
			Dictionary<int, HashSet<int>> tmpDictionary = new Dictionary<int, HashSet<int>>();
			HashSet<VoronoiRegion<Vertex2>> tmpRegions = new HashSet<VoronoiRegion<Vertex2>>();

			foreach (VoronoiRegion<Vertex2> r in voronoi.Regions) {
				tmpDictionary.Add(r.Id, new HashSet<int>());
			}

			// now we iterate over the voronoid diagram and find for each voronoi-cell the neighbor-cells
			foreach (VoronoiRegion<Vertex2> r1 in voronoi.Regions) {
				// we found already the neighbors for r1 and have also set r1 as a neighbor there.
				// add to temp Map so we can skip this region in the inner loop
				tmpRegions.Add(r1);
				foreach (VoronoiRegion<Vertex2> r2 in voronoi.Regions) {
					if (tmpRegions.Contains(r2)) continue;
					foreach (VoronoiEdge<Vertex2> e1 in r1.Edges) {
						foreach (VoronoiEdge<Vertex2> e2 in r2.Edges) {
							if (e1.Equals(e2)) {
								// r1 has r2 as a neighbor AND r2 has r1 as a neighbor
								tmpDictionary[r1.Id].Add(r2.Id);
								tmpDictionary[r2.Id].Add(r1.Id);
								// as we found neighbors for 2 regions we can skip all other edges
								// a region can not be multiple times a neighbor for one region
								goto label1;
							}
						}
					}
					// jump to the next region
					label1:;
				}
			}

			// now we set the neighbor points
			foreach (KeyValuePair<int, HashSet<int>> entry in tmpDictionary) {
				HashSet<VRoadPoint> neighbors = new HashSet<VRoadPoint>();
				// we can always add the prvious and the next point
				neighbors.Add(points[NFS3Importer.Utility.Utils.Modulo((entry.Key - 1), points.Length)]);
				neighbors.Add(points[(entry.Key + 1) % points.Length]);
				foreach(int id in entry.Value) {
					if ((Vector3.Distance(points[entry.Key].leftPoint, points[id].leftPoint) <= VROADNEIGHBORTHRESHOLD)
					 || (Vector3.Distance(points[entry.Key].leftPoint, points[id].rightPoint) <= VROADNEIGHBORTHRESHOLD)
					 || (Vector3.Distance(points[entry.Key].rightPoint, points[id].leftPoint) <= VROADNEIGHBORTHRESHOLD)
					 || (Vector3.Distance(points[entry.Key].rightPoint, points[id].rightPoint) <= VROADNEIGHBORTHRESHOLD)) {
						 neighbors.Add(points[id]);
					}
				}
				points[entry.Key].neighbors = neighbors.ToArray();
			}
		}

		/*
		private GameObject[] getCOLObjects () {

			if (col.ObjectHead == null)
				return null;

			List<NFS3Importer.COL.COLObject> objects = new List<NFS3Importer.COL.COLObject> ();

			for (int i = 0; i < col.ObjectHead.NumRec; i++) {
				objects.Add (col.ColObject[i]);
			}
			if (col.Object2Head != null) {
				for (int i = 0; i < col.Object2Head.NumRec; i++) {
					objects.Add (col.ColObject2[i]);
				}
			}

			GameObject[] gameObjects = new GameObject[objects.Count];

			for (int i = 0; i < objects.Count; i++) {
				NFS3Importer.COL.COLObject o = objects[i];
				Mesh mesh = getCOLStruct3D (o.Struct3D);

				gameObjects[i] = new GameObject ("COLObject_" + i, typeof (MeshRenderer), typeof (MeshFilter));
				gameObjects[i].GetComponent<MeshFilter> ().mesh = mesh;
				gameObjects[i].transform.position = new Vector3 (o.RefPoint.x / 65535.0f, o.RefPoint.y / 65535.0f, o.RefPoint.z / 65535.0f);
			}

			return gameObjects;

		}

		private Mesh getCOLStruct3D (int rec) {

			NFS3Importer.COL.COLStruct3D s = col.Struct3D[rec];

			Mesh mesh = new Mesh ();
			List<Vector3> vertices = new List<Vector3> ();

			for (int i = 0; i < s.NumVertices; i++) {
				vertices.Add (s.Vertices[i].Point);
			}

			List<int> triangles = new List<int> ();

			for (int i = 0; i < s.NumPolygons; i++) {
				triangles.Add (s.Polygons[i].Vertices[0]);
				triangles.Add (s.Polygons[i].Vertices[1]);
				triangles.Add (s.Polygons[i].Vertices[2]);
				triangles.Add (s.Polygons[i].Vertices[0]);
				triangles.Add (s.Polygons[i].Vertices[2]);
				triangles.Add (s.Polygons[i].Vertices[3]);
			}

			// setting the actual vertices
			mesh.vertices = vertices.ToArray ();

			// set triangles
			mesh.triangles = triangles.ToArray ();

			// setting the uv coords
			//mesh.uv = uvs.ToArray ();
			mesh.RecalculateBounds ();
			mesh.RecalculateNormals ();

			return mesh;
		}
		*/

		private GameObject generateGameObject (EntityType type, Vector3[] vertices, PolygonData[] polygonData, string name, int block = default (int)) {

			if (polygonData == null || vertices == null) {
				return null;
			}

			GameObject result = new GameObject (name, typeof (MeshRenderer), typeof (MeshFilter));

			FSHQFSGroup group = FSHQFSGroup.GLOBAL;
			if (type == EntityType.LANE) {
				group = FSHQFSGroup.Lanes;
			}

			//sortinge the polygons by texture so we can create submeshes.
			PolygonData[][] submeshes = sortPolygonData (polygonData);

			Mesh mesh = generateMesh (vertices, submeshes, type);
			Material[] materials = collectMaterials (submeshes, group);

			// finalize Block-Gameobject
			result.GetComponent<MeshFilter> ().mesh = mesh;
			result.GetComponent<MeshRenderer> ().materials = materials;
			
			UnityEngine.Rendering.ShadowCastingMode mode;
			
			if(materials[0] != null && materials[0].shader.name.Contains("Additive")) {
				// lightbeams should have nor shadows
				mode = UnityEngine.Rendering.ShadowCastingMode.Off;
			} else {
				// for all other objects set shadow casting mode to two-sided. Otherwise the shadows won't work properly
				mode = UnityEngine.Rendering.ShadowCastingMode.TwoSided;
			}
			
			result.GetComponent<MeshRenderer> ().shadowCastingMode = mode;

			// add Texture Animator if neccessary
			for (int i = 0; i < submeshes.Length; i++) {
				RenderFlag rf = getRenderFlag (submeshes[i][0].TextureAnimData);
				if (rf == RenderFlag.AnimatedBothSided || rf == RenderFlag.AnimatedOneSided) {
					TextureAnimator ta = result.AddComponent<TextureAnimator> ();
					ta.Init (getAnimInfo (submeshes[i][0].AnimInfo).Item1, i);
				}
			}

			if (type == EntityType.BLOCK) {
				MeshCollider c = result.AddComponent<MeshCollider> ();
				c.sharedMesh = blockColliderMeshes[block].Item1;
				blockColliders.Add(c);
				Rigidbody r = result.AddComponent<Rigidbody>();
				r.isKinematic = true;
				Surface s = result.AddComponent<Surface>();
				s.SetSurfaces(blockColliderMeshes[block].Item2);
			}
			if (type == EntityType.XOBJ) {

			}

			return result;
		}

		private (PolygonData, PolyVRoadData)[] getPolygonsWithVRoadData (int block) {
			(PolygonData, PolyVRoadData)[] result = new (PolygonData, PolyVRoadData)[frd.PolygonBlocks[block].Size[lod2intBlock]];
			for (int i = 0; i < result.Length; i++) {
				// it seems that vroad entries are stored sequentially. No need to compare VroadEntry-Index with Polygon-Index
				PolyVRoadData polyVRoadData = frd.TrackBlocks[block].PolygonVRoadData[i];
				result[i] = (frd.PolygonBlocks[block].Polygons[lod2intBlock][i], polyVRoadData);
			}
			return result;
		}

		private static bool isPassable ((PolygonData, PolyVRoadData) pair) {
			SurfaceFlag sf = getSurfaceFlag (pair.Item2.Flags);
			if (sf != SurfaceFlag.NoDriveSurface && sf != SurfaceFlag.SimNullSurface) {
				return true;
			}
			return false;
		}

		private PolygonData[] getPassablePolygons (int block) {
			List<PolygonData> result = new List<PolygonData> ();
			(PolygonData, PolyVRoadData)[] polygonsWithVRoadData = getPolygonsWithVRoadData (block);

			for (int i = 0; i < polygonsWithVRoadData.Length; i++) {
				if (isPassable (polygonsWithVRoadData[i])) {
					result.Add (polygonsWithVRoadData[i].Item1);
				}
			}

			return result.ToArray ();
		}

		private (Mesh, PolygonFlag[])[] generateBlockColliderMeshes () {
			/*
			Basic Idea:
			The problem is that NFS doesn't use colliders like Unity does. 
			Instead, it is determined for each polygon whether it is passable or not. 
			However, this can be difficult if you want to translate this information into Collider. 
			You cannot create a wall at every transition between passable and non-passable polygons. 
			Example: In the Atlantica track there is a jump ramp that has perfectly vertical walls. 
			You can drive on top of it and of course on the bottom too. 
			But of course you shouldn't fall through the vertical wall if you drive against it. 
			Because of this, the polygons of the vertical wall that connects the top of the ramp to 
			the road below are marked as non-drivable in NFS. If you were to see this transition between 
			drivable polygons and non-drivable polygons as a wall with a fixed height in Unity, then you could 
			no longer jump down from the ramp because a vertical wall would be created. For this reason, 
			the algorithm creates a 2D topdown view, so to speak, which determines whether the upper 
			edges of the ramp coincide with the lower edges of the ramp. The vertical wall of the ramp 
			virtually disappears in the 2D view. If that is the case, then we know that we are not allowed 
			to create walls at this point, but must treat the entire polygon as a mesh collider.

			To create collider walls, we first create a list of all passable polygons along the entire route. 
			The edges that form the outline of all these polygons will later become our walls. 
			In the next step we filter out all edges of these polygons that occur more than once. 
			So these are edges between two passable polygons. Now comes the interesting part: 
			There can be transitions between drivable and non-drivable polygons that should still 
			not become a wall. Namely whenever the non-drivable polygons are perfectly vertical and 
			a connection between two drivable levels are at different heights. To filter these edges, 
			we ignore the y-coordinates of the edges and create a 2D view, so to speak. When the non-drivable 
			vertical walls disappear in the 2D view and the edges match at the two different heights, 
			we know that we have such a special case and filter the corresponding edges.
			Now we have all the information we need. The passable polygons become mesh colliders. 
			The filtered out edges in wallEdges become walls. and the pairs of edges in meshColliderEdges 
			become Mesh Colliders that connect two drivable levels.

			Executing this algorithm globally for the entire route and not individually for each block offers 
			the advantage that we can also determine transitions between different blocks where there should 
			not be a wall. This occurs e.g. with abbreviations
			
			*/

			// vars
			HashSet<Edge> wallEdges = new HashSet<Edge>();
			List<(Edge, Edge)> meshColliderEdges = new List<(Edge, Edge)>();
			List<PolygonFlag>[] polygonFlags = new List<PolygonFlag>[this.frd.NumBlocks];
			for (int i = 0; i < polygonFlags.Length; i++) {
				polygonFlags[i] = new List<PolygonFlag>();
			}


			// first we create a List of passable Polygons with our struct
			List<Polygon> passablePolygons = new List<Polygon>();
			for (int i = 0; i < this.frd.NumBlocks; i++) {
				(PolygonData, PolyVRoadData)[] polygonsWithVRoadData = getPolygonsWithVRoadData (i);
				for (int j = 0; j < polygonsWithVRoadData.Length; j++) {
					(PolygonData, PolyVRoadData) p = polygonsWithVRoadData[j];
					if(isPassable(p)) {
						SurfaceFlag sf = getSurfaceFlag(p.Item2.Flags);
						passablePolygons.Add(new Polygon {
							v1 = frd.TrackBlocks[i].Vertices[p.Item1.Vertex[0]],
							v2 = frd.TrackBlocks[i].Vertices[p.Item1.Vertex[1]],
							v3 = frd.TrackBlocks[i].Vertices[p.Item1.Vertex[2]],
							v4 = frd.TrackBlocks[i].Vertices[p.Item1.Vertex[3]],
							isPassable = true,
							block = i,
							surfaceFlag = sf
						});
					}
				}
			}

			// now we create an outline around all passable polygons
			// for this we check whether edges occur more than once. If so, we know that this is not a marginal edge
			HashSet<Edge> edgesToRemove = new HashSet<Edge>();
			foreach (Polygon p in passablePolygons) {
				for (int i = 0; i < 4; i++) {
					if(wallEdges.Contains(p.Edges3D[i])) {
						edgesToRemove.Add(p.Edges3D[i]);
					}	else {
						wallEdges.Add(p.Edges3D[i]);
					}
				}
			}

			// now we delete from all possible edges those edges that should not later become a wall.
			wallEdges.ExceptWith(edgesToRemove);

			// Now we check from a top-down view whether there are still edges that are the same
			edgesToRemove.Clear();
			Edge[] tmp = wallEdges.ToArray();
			for (int i = 0; i < tmp.Length; i++) {
				Edge e1 = tmp[i];
				for (int j = 0; j < tmp.Length; j++) {
					if (i == j) continue;
					Edge e2 = tmp[j];
					if(e1.To2D().Equals(e2.To2D())) {
						edgesToRemove.Add(e1);
						if(!meshColliderEdges.Contains((e1, e2)) && !meshColliderEdges.Contains((e2, e1))) {
							meshColliderEdges.Add((e1, e2));
						}
					}
				}
			}

			// again we delete all edges that we found in this way
			wallEdges.ExceptWith(edgesToRemove);

			//At this point we have determined an outline for the entire track, which then becomes walls.
			//All edges for this are now saved in wallEdges

			// generate Mesh
			(Mesh, PolygonFlag[])[] result = new (Mesh, PolygonFlag[])[this.frd.NumBlocks];
			List<Vector3>[] vertices = new List<Vector3>[this.frd.NumBlocks];
			List<int>[] triangles = new List<int>[this.frd.NumBlocks];

			for (int i = 0; i < this.frd.NumBlocks; i++) {
				result[i].Item1 = new Mesh();
				vertices[i] = new List<Vector3>();
				triangles[i] = new List<int>();
			}

			// add walls for trackboundaries
			int[] counters = new int[this.frd.NumBlocks];
			int counter;
			foreach (Edge e in wallEdges) {
				int block = e.block;
				counter = counters[block];
				Vector3 v1Top = new Vector3 (e.v1.x, e.v1.y + settings.colliderHeight, e.v1.z);
				Vector3 v2Top = new Vector3 (e.v2.x, e.v2.y + settings.colliderHeight, e.v2.z);
				vertices[block].Add (e.v1);
				vertices[block].Add (v1Top);
				vertices[block].Add (v2Top);
				vertices[block].Add (e.v2);

				triangles[block].Add (counter + 0);
				triangles[block].Add (counter + 1);
				triangles[block].Add (counter + 2);
				triangles[block].Add (counter + 0);
				triangles[block].Add (counter + 2);
				triangles[block].Add (counter + 3);

				// this for collider optimization later
				tmpWallEdges.Add((e, counter + 0, counter + 1, counter + 2, counter + 3));
				counters[block] += 4;
			}

			// add colliders for walls inside the track (steps)
			foreach ((Edge, Edge) edgePair in meshColliderEdges) {
				int block = edgePair.Item1.block;
				counter = counters[block];
				Vector3 v1, v2, v3, v4;
				if(edgePair.Item1.v1.y > edgePair.Item2.v1.y) {
					v1 = new Vector3 (edgePair.Item2.v1.x, edgePair.Item2.v1.y, edgePair.Item2.v1.z);
					v2 = new Vector3 (edgePair.Item1.v1.x, edgePair.Item1.v1.y, edgePair.Item1.v1.z);
					v3 = new Vector3 (edgePair.Item1.v2.x, edgePair.Item1.v2.y, edgePair.Item1.v2.z);
					v4 = new Vector3 (edgePair.Item2.v2.x, edgePair.Item2.v2.y, edgePair.Item2.v2.z);
				} else {
					v1 = new Vector3 (edgePair.Item1.v1.x, edgePair.Item1.v1.y, edgePair.Item1.v1.z);
					v2 = new Vector3 (edgePair.Item2.v1.x, edgePair.Item2.v1.y, edgePair.Item2.v1.z);
					v3 = new Vector3 (edgePair.Item2.v2.x, edgePair.Item2.v2.y, edgePair.Item2.v2.z);
					v4 = new Vector3 (edgePair.Item1.v2.x, edgePair.Item1.v2.y, edgePair.Item1.v2.z);
				}

				// this for determining the order of vertices so we can create proper triangles
				Vector3 v1Flat = new Vector3(v1.x, 0, v1.z);
				Vector3 v2Flat = new Vector3(v2.x, 0, v2.z);
				Vector3 v3Flat = new Vector3(v3.x, 0, v3.z);
				Vector3 v4Flat = new Vector3(v4.x, 0, v4.z);

				vertices[block].Add (v1);
				if(v1Flat == v2Flat) {
					vertices[block].Add (v2);
					vertices[block].Add (v3);
					vertices[block].Add (v4);
				} else {
					vertices[block].Add (v3);
					vertices[block].Add (v2);
					vertices[block].Add (v4);
				}
				

				triangles[block].Add (counter + 2);
				triangles[block].Add (counter + 1);
				triangles[block].Add (counter + 0);
				triangles[block].Add (counter + 3);
				triangles[block].Add (counter + 2);
				triangles[block].Add (counter + 0);
				// we simply add two collidermeshes facing in oppposite direction 
				//as we can not determine the facing direction of our mesh from the two edges
				triangles[block].Add (counter + 0);
				triangles[block].Add (counter + 1);
				triangles[block].Add (counter + 2);
				triangles[block].Add (counter + 0);
				triangles[block].Add (counter + 2);
				triangles[block].Add (counter + 3);
				counters[block] += 4;
			}

			// add mesh colliders for drivable polygons
			foreach(Polygon p in passablePolygons) {
				int block = p.block;
				int currentTriangleIndex = triangles[block].Count() / 3;

				counter = counters[block];
				vertices[block].Add (p.v1);
				vertices[block].Add (p.v2);
				vertices[block].Add (p.v3);
				vertices[block].Add (p.v4);

				triangles[block].Add (counter + 0);
				triangles[block].Add (counter + 1);
				triangles[block].Add (counter + 2);
				triangles[block].Add (counter + 0);
				triangles[block].Add (counter + 2);
				triangles[block].Add (counter + 3);

				PolygonFlag pf1 = new PolygonFlag() {
					triangleIndex = currentTriangleIndex,
					surfaceFlag = p.surfaceFlag
				};
				PolygonFlag pf2 = new PolygonFlag() {
					triangleIndex = currentTriangleIndex + 1,
					surfaceFlag = p.surfaceFlag
				};
				polygonFlags[block].Add(pf1);
				polygonFlags[block].Add(pf2);

				counters[block] += 4;
			}

			for (int i = 0; i < this.frd.NumBlocks; i++) {
				result[i].Item1.vertices = vertices[i].ToArray();
				result[i].Item1.triangles = triangles[i].ToArray();
				result[i].Item2 = polygonFlags[i].ToArray();
				//result[i].RecalculateBounds();
				//result[i].RecalculateNormals();
				//result[i].RecalculateTangents();
				//result[i].Optimize();
			}

			#if UNITY_EDITOR
			if(saveToAssets)
			for (int i = 0; i < result.Length; i++) {
				this.generatedObjects.Add(new GeneratedObject(result[i].Item1, ObjectType.Collider, i + "_block.mesh"));
			}
			#endif

			return result;
		}

		/// <summary>
		/// solves intersecting block colliders
		/// </summary>
		/// <param name="blocks"></param>
		private void optimizeBlockColliders(GameObject[] blocks) {
			// vars
			MeshCollider myCollider;
			RaycastHit[] hit;
			float magnitude;
			float minHeight, minHeightTotal;
			Vector3 vTop;
			bool scaleDown = false;

			foreach ((Edge, int, int, int, int) e in this.tmpWallEdges) {
				scaleDown = false; //<-- that cost me an hour xD
				myCollider = blocks[e.Item1.block].GetComponent<MeshCollider>();
				minHeightTotal = settings.colliderHeight;
				minHeight = settings.colliderHeight;
				foreach (Vector3 v in new []{e.Item1.v1, e.Item1.v2}) {
					vTop = v + Vector3.up * settings.colliderHeight;
					hit = Physics.RaycastAll(vTop, Vector3.down, settings.colliderHeight);
					minHeight = settings.colliderHeight;
					foreach (RaycastHit h in hit) {
						// skip if its our own collider
						if (h.collider == myCollider) continue;
						// skip if its not a mesh-collider
						if (!h.collider.GetType().Equals(typeof(MeshCollider))) continue;
						// skip if its not a block collider
						if (!blockColliders.Contains(h.collider)) continue;
						// skip if we hit a wall. We only want detect intersections with drivable surfaces
						if (isPerpendicular((MeshCollider)h.collider, h.triangleIndex)) continue;
						magnitude = (v - h.point).magnitude;
						if(!Mathf.Approximately(magnitude, minHeight) && magnitude < minHeight) {
							minHeight = magnitude;
						}
					}
					if(!Mathf.Approximately(minHeight, minHeightTotal) && minHeight < minHeightTotal) {
						minHeightTotal = minHeight;
						scaleDown = true;
					}
				}

				// we define a minimum of 2 meters height for walls. If calculated height is below 2 meters its
				// likely that we have hit a drivable surface of a neighbor-block. We want to exclude this cases
				if(scaleDown && minHeightTotal >= 2.0f) {
					Vector3[] colliderVerts = myCollider.sharedMesh.vertices;
					// subtract 1.0 to make sure colliders do not intersect
					// v1Top
					colliderVerts[e.Item3] = colliderVerts[e.Item2] + Vector3.up * (minHeightTotal - 1.0f);
					// v2Top
					colliderVerts[e.Item4] = colliderVerts[e.Item5] + Vector3.up * (minHeightTotal - 1.0f);
					myCollider.sharedMesh.SetVertices(colliderVerts);
				}
			}

			/// <summary>
			/// Helper Method to calculate if a triangle is world-perpendicular (walls are perpendicular)
			/// </summary>
			/// <param name="collider"></param>
			/// <param name="triangleIndex"></param>
			/// <returns></returns>
			bool isPerpendicular(MeshCollider collider, int triangleIndex) {
				int[] tris = collider.sharedMesh.triangles;
				Vector3[] verts = collider.sharedMesh.vertices;
				(Vector3,Vector3,Vector3) triangle = (verts[tris[triangleIndex * 3 + 0]], verts[tris[triangleIndex * 3 + 1]],verts[tris[triangleIndex * 3 + 2]]);
				Vector3 facingDir = Vector3.Cross((triangle.Item2 - triangle.Item1).normalized, (triangle.Item3 - triangle.Item1).normalized).normalized;
				if(Mathf.Approximately(facingDir.y, 0)) {
					return true;
				}
				return false;
			}
		}

		private Mesh generateMesh (Vector3[] vertices, PolygonData[][] submeshes, EntityType type) {

			if (submeshes == null || vertices == null) {
				return null;
			}

			Mesh result = new Mesh ();

			//Vertices
			List<Vector3> verts = new List<Vector3> ();

			List<Vector2> uvs = new List<Vector2> ();

			List<Vector3> normals = new List<Vector3> ();

			List<List<int>> triangles = new List<List<int>>();

			// temp Vars
			Vector3 n0, n1, n2, n3;

			// Note: some vertices in the frd are out of bound and can not be represented by Unity.
			// This vertices are not used by NFS. They are skipped automatically by the Dictionary loop


			result.subMeshCount = submeshes.Length;

			int submeshCounter = 0;
			int vertexCounter = 0;
			foreach (PolygonData[] polyList in submeshes) {
				List<int> tris = new List<int> ();
				// generate Polygons. Convert from NFSs 4 Vertex Polys to Triangles
				for (int j = 0; j < polyList.Length; j++) {

					verts.Add (vertices[polyList[j].Vertex[0]]);
					verts.Add (vertices[polyList[j].Vertex[1]]);
					verts.Add (vertices[polyList[j].Vertex[2]]);
					verts.Add (vertices[polyList[j].Vertex[3]]);

					// adding the vertice to the tmpVerticesToNormals Dictionary
					for (int i = 0; i < 4; i++) {
						if (!tmpVerticesToNormals.ContainsKey (vertices[polyList[j].Vertex[i]])) {
							tmpVerticesToNormals.Add (vertices[polyList[j].Vertex[i]], new HashSet<Vector3> ());
						}
						tmpVerticesToNormals[vertices[polyList[j].Vertex[i]]].Add (Utility.Utils.CalculateQuadNormal (vertices[polyList[j].Vertex[0]], vertices[polyList[j].Vertex[1]], vertices[polyList[j].Vertex[2]], vertices[polyList[j].Vertex[3]]));
					}


					n0 = n1 = n2 = n3 =  Utility.Utils.CalculateQuadNormal (vertices[polyList[j].Vertex[0]], vertices[polyList[j].Vertex[1]], vertices[polyList[j].Vertex[2]], vertices[polyList[j].Vertex[3]]);

					//TODO: fix flipped textures on some objects

					if (type != EntityType.XOBJ) {
						tris.Add (vertexCounter + 0);
						tris.Add (vertexCounter + 1);
						tris.Add (vertexCounter + 2);
						tris.Add (vertexCounter + 0);
						tris.Add (vertexCounter + 2);
						tris.Add (vertexCounter + 3);
						normals.Add(n0);
						normals.Add(n1);
						normals.Add(n2);
						normals.Add(n3);
					} else {
						// if XOBJ: flip facing direction
						tris.Add (vertexCounter + 0);
						tris.Add (vertexCounter + 2);
						tris.Add (vertexCounter + 1);
						tris.Add (vertexCounter + 0);
						tris.Add (vertexCounter + 3);
						tris.Add (vertexCounter + 2);
						// and also flip normals
						normals.Add(-n0);
						normals.Add(-n1);
						normals.Add(-n2);
						normals.Add(-n3);
					}
					

					// duplicate triangles if neccessary (both sided culled)
					RenderFlag rf = getRenderFlag (polyList[j].TextureAnimData);
					if (rf == RenderFlag.BothSided) {

						// add the vertices again so we can create new normals for the opposite face
						// first we increment our vertexcounter as we want to use the additionally added vertices for the opposite face
						// then add the vertices again and create new normals for them in opposite direction
						vertexCounter += 4;
						verts.Add (vertices[polyList[j].Vertex[0]]);
						verts.Add (vertices[polyList[j].Vertex[1]]);
						verts.Add (vertices[polyList[j].Vertex[2]]);
						verts.Add (vertices[polyList[j].Vertex[3]]);
						// invert the normals as this triangle is facing to the opposite direction
						n0 = n1 = n2 = n3 = -Utility.Utils.CalculateQuadNormal (vertices[polyList[j].Vertex[0]], vertices[polyList[j].Vertex[1]], vertices[polyList[j].Vertex[2]], vertices[polyList[j].Vertex[3]]);

						if (type != EntityType.XOBJ) {
							tris.Add (vertexCounter + 2);
							tris.Add (vertexCounter + 1);
							tris.Add (vertexCounter + 0);
							tris.Add (vertexCounter + 3);
							tris.Add (vertexCounter + 2);
							tris.Add (vertexCounter + 0);
							normals.Add(n0);
							normals.Add(n1);
							normals.Add(n2);
							normals.Add(n3);
						} else {
							// if XOBJ: flip facing direction
							tris.Add (vertexCounter + 2);
							tris.Add (vertexCounter + 0);
							tris.Add (vertexCounter + 1);
							tris.Add (vertexCounter + 3);
							tris.Add (vertexCounter + 0);
							tris.Add (vertexCounter + 2);
							normals.Add(-n0);
							normals.Add(-n1);
							normals.Add(-n2);
							normals.Add(-n3);
						}
					}

					Vector2[] originalUVs = new Vector2[4];
					originalUVs[0] = new Vector2 (frd.Textures[polyList[j].Texture].UVCoords[0],
						frd.Textures[polyList[j].Texture].UVCoords[1]);
					originalUVs[1] = new Vector2 (frd.Textures[polyList[j].Texture].UVCoords[2],
						frd.Textures[polyList[j].Texture].UVCoords[3]);
					originalUVs[2] = new Vector2 (frd.Textures[polyList[j].Texture].UVCoords[4],
						frd.Textures[polyList[j].Texture].UVCoords[5]);
					originalUVs[3] = new Vector2 (frd.Textures[polyList[j].Texture].UVCoords[6],
						frd.Textures[polyList[j].Texture].UVCoords[7]);

					uvs.AddRange (generateUVs (type, originalUVs));
					// if we have a double sided object we have to add the uvs again for the additional vertices
					if (rf == RenderFlag.BothSided) {
						uvs.AddRange (generateUVs (type, originalUVs));
					}

					vertexCounter += 4;
				}
				
				triangles.Add(tris);
				submeshCounter++;
			}

			// setting the actual vertices
			result.vertices = verts.ToArray ();

			// if type = collider we don't have submeshes
			if (type == EntityType.COLLIDER) {
				result.triangles = triangles[0].ToArray ();
			} else {
				for (int i = 0; i < submeshes.Length; i++) {
					result.SetTriangles (triangles[i].ToArray (), i, true, 0);
				}
			}

			// setting the uv coords
			result.uv = uvs.ToArray ();

			result.normals = normals.ToArray ();

			result.RecalculateBounds ();

			// adding all generated meshes to our meshes list so we can optimize the normals
			if (type != EntityType.COLLIDER) {
				this.generatedMeshes.Add (result);

				#if UNITY_EDITOR
				if(saveToAssets)
					this.generatedObjects.Add(new GeneratedObject(result, ObjectType.Model, (meshNameCounter++) + "_" + type.ToString() + ".mesh"));
				#endif
			}

			genLightmapUVs(result);

			return result;
		}

		private void genLightmapUVs (Mesh m) {
			// this should create the uvs for the lightmap
			#if UNITY_EDITOR
			// this settings should avoid overlapping uvs. packMargin is the padding between uv-island 
			// (maybe play with this value(s))
			UnwrapParam unwrapParam = new UnwrapParam();
			UnwrapParam.SetDefaults(out unwrapParam);
			//settings.hardAngle = 60.0f;
			//settings.angleError = 1.0f;
			//settings.areaError = 1.0f;
			unwrapParam.packMargin = settings.UVMargin;
			Unwrapping.GenerateSecondaryUVSet (m, unwrapParam);
			#endif
		}

		private Material[] collectMaterials (PolygonData[][] submeshes, FSHQFSGroup group) {

			List<Material> tmp = new List<Material> ();

			// the polygondata is already sorted by textures so it's enough to check the item at index 0
			foreach (PolygonData[] polygonData in submeshes) {
				if (polygonData != null && polygonData.Length > 0) {
					int textureID = frd.Textures[polygonData[0].Texture].Texture;
					RenderFlag rf = getRenderFlag (polygonData[0].TextureAnimData);
					// if animated texture: create an array with all texture IDs of the frames
					int[] frameIDs = null;
					if (rf == RenderFlag.AnimatedOneSided || rf == RenderFlag.AnimatedBothSided) {
						(float, int) animInfo = getAnimInfo (polygonData[0].AnimInfo);
						frameIDs = new int[animInfo.Item2];
						for (int i = 0; i < frameIDs.Length; i++) {
							frameIDs[i] = frd.Textures[polygonData[0].Texture + i].Texture;
						}
					}

					tmp.Add (materialHandler.GetMaterial (group, textureID, rf, saveToAssets, polygonData[0].AnimInfo, frameIDs));
				}
			}

			return tmp.ToArray ();
		}

		/// <summary>
		/// Sorts the polygon data by texture ID and Render Flag (TextureAnimData).
		/// </summary>
		/// <returns>The polygon data.</returns>
		/// <param name="polygonData">Polygon data.</param>
		private static PolygonData[][] sortPolygonData (PolygonData[] polygonData) {
			Dictionary<(int, RenderFlag), List<PolygonData>> tempDic = new Dictionary<(int, RenderFlag), List<PolygonData>> ();

			for (int i = 0; i < polygonData.Length; i++) {
				PolygonData p = polygonData[i];
				(int, RenderFlag) pair = (p.Texture, getRenderFlag (p.TextureAnimData));
				if (!tempDic.ContainsKey (pair)) {
					tempDic.Add (pair, new List<PolygonData> ());
				}
				tempDic[pair].Add (p);
			}
			PolygonData[][] result = new PolygonData[tempDic.Count][];
			int j = 0;
			foreach (List<PolygonData> l in tempDic.Values) {
				result[j++] = l.ToArray ();
			}
			return result;
		}

		private static Vector2[] generateUVs (EntityType type, Vector2[] inputUVs) {
			Vector2[] result = new Vector2[4];
			switch (type) {
				case EntityType.XOBJ:
					//TODO: fix flipped textures on some objects
					result[0] = (new Vector2 (1.0f - inputUVs[0].x, 1.0f - inputUVs[0].y));
					result[1] = (new Vector2 (1.0f - inputUVs[1].x, 1.0f - inputUVs[1].y));
					result[2] = (new Vector2 (1.0f - inputUVs[2].x, 1.0f - inputUVs[2].y));
					result[3] = (new Vector2 (1.0f - inputUVs[3].x, 1.0f - inputUVs[3].y));
					break;
				case EntityType.POLYOBJ:
				case EntityType.LANE:
				case EntityType.BLOCK:
				case EntityType.BLOCKEXTRAS:
					result[0] = (new Vector2 (inputUVs[0].x, 1.0f - inputUVs[0].y));
					result[1] = (new Vector2 (inputUVs[1].x, 1.0f - inputUVs[1].y));
					result[2] = (new Vector2 (inputUVs[2].x, 1.0f - inputUVs[2].y));
					result[3] = (new Vector2 (inputUVs[3].x, 1.0f - inputUVs[3].y));
					break;
			}

			return result;
		}

		private void optimizeNormals () {

			for (int i = 0; i < this.generatedMeshes.Count; i++) {
				Mesh currentMesh = this.generatedMeshes[i];
				List<Vector3> normals = new List<Vector3> ();
				for (int j = 0; j < currentMesh.vertices.Length; j++) {

					Vector3 optimizedNormal = currentMesh.normals[j];
					foreach (Vector3 oldNormal in this.tmpVerticesToNormals[currentMesh.vertices[j]]) {
						// checking GouraudAngle angle
						if (Vector3.Angle (currentMesh.normals[j], oldNormal) <= settings.GouraudAngle) {
							optimizedNormal += oldNormal;
						}
					}
					optimizedNormal.Normalize ();

					normals.Add (optimizedNormal);
				}
				currentMesh.normals = normals.ToArray ();
			}
		}

		private GameObject createLightProbes() {
			List<Vector3> probePositions = new List<Vector3>();
			GameObject go = new GameObject ("LightProbes");
			LightProbeGroup group = go.AddComponent<LightProbeGroup>();
			int groupCounter = 0;
			for (int i = 0; (i + settings.lightProbeSpacing) < this.lightProbePositions.Length; i += settings.lightProbeSpacing) {
				probePositions.Add(this.lightProbePositions[i].Item1);
				probePositions.Add(this.lightProbePositions[i].Item2);
				probePositions.Add(this.lightProbePositions[i].Item3);
				probePositions.Add(this.lightProbePositions[i].Item1 + Vector3.up * settings.lightProbeHeight);
				probePositions.Add(this.lightProbePositions[i].Item2 + Vector3.up * settings.lightProbeHeight);
				probePositions.Add(this.lightProbePositions[i].Item3 + Vector3.up * settings.lightProbeHeight);
				group.probePositions = probePositions.ToArray();
				groupCounter ++;
			}
			
			return go;
		}

		private static RenderFlag getRenderFlag (byte renderFlag) {
			switch (renderFlag) {
				case 0x00:
				case 0x20:
				case 0x40:
					return RenderFlag.OneSided;
				case 0x10:
				case 0x30:
					return RenderFlag.BothSided;
				case 0x04:
				case 0x24:
				case 0x44:
					// not sure if 0x24, 0x44 exists
					return RenderFlag.AnimatedOneSided;
				case 0x14:
				case 0x34:
					return RenderFlag.AnimatedBothSided;

			}
			return RenderFlag.OneSided;
		}

		private static SurfaceFlag getSurfaceFlag (byte polyVRoadFlag) {
			byte flag = (byte)(polyVRoadFlag & (byte)0x1F);
			switch (flag) {
				case 0:
					return SurfaceFlag.NoDriveSurface;
				case 1:
					return SurfaceFlag.PavedSurface;
				case 2:
					return SurfaceFlag.GravelSurface;
				case 3:
					return SurfaceFlag.GrassSurface;
				case 4:
					return SurfaceFlag.LeavesSurface;
				case 5:
					return SurfaceFlag.DirtSurface;
				case 6:
					return SurfaceFlag.WaterSurface;
				case 7:
					return SurfaceFlag.WoodSurface;
				case 8:
					return SurfaceFlag.IceSurface;
				case 9:
					return SurfaceFlag.SnowSurface;
				case 10:
					return SurfaceFlag.PavedShoulder;
				case 11:
					return SurfaceFlag.LeavesShoulder;
				case 12:
					return SurfaceFlag.WoodShoulder;
				case 13:
					return SurfaceFlag.DirtShoulder;
				case 14:
					return SurfaceFlag.SimNullSurface;
				case 15:
					return SurfaceFlag.SnowShoulder;
				default:
					return SurfaceFlag.SimNullSurface;
			}
		}

		private static bool detectsCollision (byte polyVRoadFlag) {
			return (byte)(polyVRoadFlag & (byte)0x80) != 0;
		}

		private static (float, int) getAnimInfo (byte animInfo) {
			//extract animInfo. Bits LSB 2 - LSB 0: Number of Texture-Frames (numFrames) (this textures are stored sequentially in the TextureBlock-Array from FRD)
			// Bits LSB 7 - LSB 3 is the animationspeed (animSpeed)
			int animSpeed = (animInfo & 0x000000F8) >> 3;
			int numFrames = (animInfo & 0x00000007);

			float fps = 64 * Mathf.Pow (2, -Mathf.Log (Mathf.Clamp (animSpeed, 1, 32), 2));
			// fps, numFrames
			return (fps, numFrames);
		}

		private static XObjectType getXObjectType (int crossType) {
			switch (crossType) {
				case 1:
					return XObjectType.Global;
				case 2:
					return XObjectType.Simple;
				case 3:
					return XObjectType.Animated;
				case 4:
					return XObjectType.Collision;
				default:
					return XObjectType.Simple;
			}
		}

		private static XObjectCollideEffect getXObjectCollideEffect (byte collideEffect) {
			switch (collideEffect) {
				case 0:
					return XObjectCollideEffect.Nothing;
				case 1:
					return XObjectCollideEffect.Solid;
				case 2:
					return XObjectCollideEffect.HitAndFall;
				case 3:
					return XObjectCollideEffect.DriveThroughWithSound;
				default:
					return XObjectCollideEffect.Nothing;
			}
		}
	}
}