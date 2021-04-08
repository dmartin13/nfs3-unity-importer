using UnityEngine;

namespace NFS3Importer.NFSData.FRD {
	public class TrackBlock {
		public Vector3 CenterPoint { get; set; }

		public Vector3[] BoundingPoints { get; set; }

		public int NumVertices { get; set; }

		public int NumHighResVerts { get; set; }

		public int NumMedResVerts { get; set; }

		public int NumLowResVerts { get; set; }

		public int NumVerticesDup { get; set; }

		public int NumObjectVert { get; set; }

		public Vector3[] Vertices { get; set; }

		public int[] UnknVertices { get; set; }

		public NeighborData[] NbData { get; set; }

		public int NumStartPos { get; set; }

		public int NumPositions { get; set; }

		public int NumPolygons { get; set; }

		public int NumVRoad { get; set; }

		public int NumXObj { get; set; }

		public int NumPolyObj { get; set; }

		public int NumSoundSrc { get; set; }

		public int NumLightSrc { get; set; }

		public PositionData[] PosData { get; set; }

		public PolyVRoadData[] PolygonVRoadData { get; set; }

		public VRoadData[] VRData { get; set; }

		public RefXObject[] Xobj { get; set; }

		public SoundSource[] SoundSrc { get; set; }

		public LightSource[] LightSource { get; set; }

		public Vector3 HSPtMin { get; set; }

		public Vector3 HSPtMax { get; set; }

		public int[] HSNeighbors { get; set; }
	}
}
