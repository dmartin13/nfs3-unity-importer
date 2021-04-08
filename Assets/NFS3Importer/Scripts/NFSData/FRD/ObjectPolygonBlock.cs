
namespace NFS3Importer.NFSData.FRD {
	public class ObjectPolygonBlock {
		public int N1 { get; set; }

		public int N2 { get; set; }

		public int NumObjects { get; set; }

		public int[] Types { get; set; }

		public int[] NumPoly { get; set; }

		public PolygonData[][] Polygons { get; set; }
	}
}
