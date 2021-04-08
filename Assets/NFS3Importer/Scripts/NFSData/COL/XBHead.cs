
namespace NFS3Importer.NFSData.COL {
	public class XBHead {
		public int Size { get; set; }

		public short XBid { get; set; }

		public short NumRec { get; set; }

		public XBHead () {
		}

		public XBHead (int size, short xBid, short numRec) {
			this.Size = size;
			this.XBid = xBid;
			this.NumRec = numRec;
		}
	}
}
