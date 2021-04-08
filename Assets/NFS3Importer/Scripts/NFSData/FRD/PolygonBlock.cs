
namespace NFS3Importer.NFSData.FRD {
	public class PolygonBlock {

		public PolygonBlock () {
		}

		public PolygonBlock (int[] size, int[] sizeDup, PolygonData[][] polygons, ObjectPolygonBlock[] obj) {
			this.Size = size;
			this.SizeDup = sizeDup;
			this.Polygons = polygons;
			this.Obj = obj;
		}


		public int[] Size { get; set; }

		public int[] SizeDup { get; set; }

		public PolygonData[][] Polygons { get; set; }

		public ObjectPolygonBlock[] Obj { get; set; }
	}
}
