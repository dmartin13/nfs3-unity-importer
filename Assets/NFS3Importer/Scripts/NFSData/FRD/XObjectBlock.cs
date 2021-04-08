
namespace NFS3Importer.NFSData.FRD {
	public class XObjectBlock {

		public XObjectBlock () {
		}

		public XObjectBlock (int numObj, XObjectData[] objects) {
			this.NumObj = numObj;
			this.Objects = objects;
		}

		public int NumObj { get; set; }

		public XObjectData[] Objects { get; set; }
	}
}
