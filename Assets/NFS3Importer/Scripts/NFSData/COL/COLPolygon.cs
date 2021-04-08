namespace NFS3Importer.NFSData.COL {
	public class COLPolygon {
		public short Texture { get; set; }
		// [4] vertices
		public byte[] Vertices { get; set; }

		public COLPolygon () {
		}

		public COLPolygon (short texture, byte[] vertices) {
			this.Texture = texture;
			this.Vertices = vertices;
		}


	}
}
