using UnityEngine;

namespace NFS3Importer.NFSData.FRD {
	public class SoundSource {

		public SoundSource () {
		}

		public SoundSource (Vector3Int refPoint, int type) {
			this.RefPoint = refPoint;
			this.Type = type;
		}


		public Vector3Int RefPoint { get; set; }

		public int Type { get; set; }
	}
}
