
namespace NFS3Importer.NFSData.FRD {
	public class PolygonData {

		public PolygonData () {
		}

		public PolygonData (short[] vertices, short texture, short textureFlagsHS, byte textureAnimData, byte unknown2) {
			this.Vertex = vertices;
			this.Texture = texture;
			this.TextureFlagsHS = textureFlagsHS;
			this.TextureAnimData = textureAnimData;
			this.AnimInfo = unknown2;
		}


		public short[] Vertex { get; set; }

		public short Texture { get; set; }

		public short TextureFlagsHS { get; set; }

		public byte TextureAnimData { get; set; }

		public byte AnimInfo { get; set; }
	}
}
