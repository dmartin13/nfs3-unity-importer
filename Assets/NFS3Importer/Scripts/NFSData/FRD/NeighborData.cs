
namespace NFS3Importer.NFSData.FRD {
	public class NeighborData {

		public NeighborData () {
		}

		public NeighborData (short block, short unknown) {
			Block = block;
			Unknown = unknown;
		}

		public short Block { get; set; }

		public short Unknown { get; set; }
	}
}
