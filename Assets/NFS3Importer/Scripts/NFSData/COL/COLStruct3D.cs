
namespace NFS3Importer.NFSData.COL {
	public class COLStruct3D {
		public int Size { get; set; }

		public short NumVertices{ get; set; }

		public short NumPolygons{ get; set; }

		public COLVertex[] Vertices{ get; set; }

		public COLPolygon[] Polygons{ get; set; }

		public COLStruct3D () {
		}

		public COLStruct3D (int size, short numVertices, short numPolygons, COLVertex[] vertices, COLPolygon[] polygons) {
			this.Size = size;
			this.NumVertices = numVertices;
			this.NumPolygons = numPolygons;
			this.Vertices = vertices;
			this.Polygons = polygons;
		}
	}
}
