
namespace NFS3Importer.NFSData.FRD {
	public class VRoadData {

		public VRoadData () {
		}

		public VRoadData (short xNorm, short zNorm, short yNorm, short xForw, short zForw, short yForw) {
			this.XNorm = xNorm;
			this.ZNorm = zNorm;
			this.YNorm = yNorm;
			this.XForw = xForw;
			this.ZForw = zForw;
			this.YForw = yForw;
		}


		public short XNorm { get; set; }

		public short ZNorm { get; set; }

		public short YNorm { get; set; }

		public short XForw { get; set; }

		public short ZForw { get; set; }

		public short YForw { get; set; }
	}
}
