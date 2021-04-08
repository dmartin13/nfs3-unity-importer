

namespace NFS3Importer.NFSData.COL {
	public class COLTextureInfo {
		// position in .QFS file
		public short Texture { get; set; }
		// zero ?
		public short Unknown1{ get; set; }
		// texture offset ?
		public short Unknown2{ get; set; }

		public short Unknown3{ get; set; }

		public COLTextureInfo () {
		}

		public COLTextureInfo (short texture, short unknown1, short unknown2, short unknown3) {
			this.Texture = texture;
			this.Unknown1 = unknown1;
			this.Unknown2 = unknown2;
			this.Unknown3 = unknown3;
		}
	}
}
