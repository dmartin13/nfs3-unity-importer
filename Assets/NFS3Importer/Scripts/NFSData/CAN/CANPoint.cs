
namespace NFS3Importer.NFSData.CAN {
	public class CANPoint {
		// 3*4 Byte long
		public int X {get; private set;}
		public int Y {get; private set;}
		public int Z {get; private set;}
		// 4*2 Byte short
		public int Od1 {get; private set;}
		public int Od2 {get; private set;}
		public int Od3 {get; private set;}
		public int Od4 {get; private set;}

		public CANPoint (int x, int y, int z, int od1, int od2, int od3, int od4) {
			this.X = x;
			this.Y = y;
			this.Z = z;
			this.Od1 = od1;
			this.Od2 = od2;
			this.Od3 = od3;
			this.Od4 = od4;
		}

		public override string ToString () {
			return "CAN: {" + X + ", " + Y + ", " + Z + ", " + Od1 + ", " + Od2 + ", " + Od3 + ", " + Od4 + "}";
		}
	}
}
