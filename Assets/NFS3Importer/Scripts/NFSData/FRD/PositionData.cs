
namespace NFS3Importer.NFSData.FRD {
	public class PositionData {

		public PositionData () {
		}

		public PositionData (short polygon, byte numPolygons, byte unknown, short extraNeighbor1, short extraNeighbor2) {
			this.polygon = polygon;
			this.numPolygons = numPolygons;
			this.unknown = unknown;
			this.extraNeighbor1 = extraNeighbor1;
			this.extraNeighbor2 = extraNeighbor2;
		}


		public short polygon { get; set; }

		public byte numPolygons { get; set; }

		public byte unknown { get; set; }

		public short extraNeighbor1 { get; set; }

		public short extraNeighbor2 { get; set; }
	}
}
