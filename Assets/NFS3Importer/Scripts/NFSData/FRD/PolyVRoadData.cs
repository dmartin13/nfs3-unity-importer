
namespace NFS3Importer.NFSData.FRD {
	
	public class PolyVRoadData {

		public PolyVRoadData () {
		}

		public PolyVRoadData (byte vroadEntry, byte flags, byte[] unknown, byte[] minMaxHS, byte[] orphanHS, byte unknownHS, bool virtualRoadEdge) {
			this.VroadEntry = vroadEntry;
			this.Flags = flags;
			this.Unknown = unknown;
			this.MinMaxHS = minMaxHS;
			this.OrphanHS = orphanHS;
			this.UnknownHS = unknownHS;
			this.VirtualRoadEdge = virtualRoadEdge;
		}

		public byte VroadEntry { get; set; }

		public byte Flags { get; set; }

		public byte[] Unknown { get; set; }

		public byte[] MinMaxHS { get; set; }

		public byte[] OrphanHS { get; set; }

		public byte UnknownHS { get; set; }

		public bool VirtualRoadEdge { get; set; }
	}
}
