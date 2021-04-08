using NFS3Importer.UnityData;
using UnityEngine;

namespace NFS3Importer.NFSData.FSHQFS {
	public class FSHQFSItem {
		public int ID { get; set; }

		public FSHQFSGroup Group { get; set; }

		public string AlphaFilename { get; set; }

		public bool HasAlpha { get; set; }

		public string Header { get; set; }

		public byte EntryFormat { get; set; }

		public int NumAttachedDataChunks { get; set; }

		public int Width { get; set; }

		public int Height { get; set; }

		public Vector4 DisplayPosData { get; set; }

		public FSHQFSExtraData AdditionalData { get; set; }

		//--------- From here on Unity specific properties -----------//
		public Texture2D Texture { get; set; }
		// public Texture2D NormalMap { get; set; }
		// public Texture2D SpecularMap { get; set; }
	}
}
