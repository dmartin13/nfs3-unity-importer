using NFS3Importer.NFSData.GLOBAL;
using UnityEngine;

namespace NFS3Importer.NFSData.COL {
	public class COLObject {
		public short Size{ get; set; }
		// 1 = basic object, 3 = animated ...
		public byte Type{ get; set; }
		// reference in previous block
		public byte Struct3D{ get; set; }
		// type 1
		public Vector3Int RefPoint{ get; set; }
		// type 3
		public short AnimLength{ get; set; }

		public short Unknown{ get; set; }
		// same structure as in xobjs
		public AnimationData[] AnimData{ get; set; }
	}
}
