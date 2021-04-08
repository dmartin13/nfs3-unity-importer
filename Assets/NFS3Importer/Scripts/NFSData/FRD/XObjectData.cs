using NFS3Importer.NFSData.GLOBAL;
using UnityEngine;

namespace NFS3Importer.NFSData.FRD {
	public class XObjectData {

		public int CrossType { get; set; }

		public int CrossNo { get; set; }

		public int Unknown { get; set; }

		public Vector3 RefPoint { get; set; }

		public int AnimMemory { get; set; }

		public short[] Unknown3 { get; set; }

		public byte Type3 { get; set; }

		public byte ObjNo { get; set; }

		public short NAnimLength { get; set; }

		public short AnimDelay { get; set; }

		public AnimationData[] AnimaData { get; set; }

		public int NumVertices { get; set; }

		public Vector3[] Vertices { get; set; }

		public int[] UnknVertices { get; set; }

		public int NumPolygons { get; set; }

		public PolygonData[] PolygonData { get; set; }
	}
}
