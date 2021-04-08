using UnityEngine;

namespace NFS3Importer.NFSData.HRZ {
    public class HRZFogRegion {
        public Color32 StartColor { get; set; }
        public int StartDensity { get; set; }
        public Color32 ApexColor { get; set; }
        public int ApexDensity { get; set; }
        public Color32 EndColor { get; set; }
        public int EndDensity { get; set; }
        public int BeforeSlice { get; set; }
        public int CenterSlice { get; set; }
        public int AfterSlice { get; set; }

        public override string ToString () {
		    	return "CAN: {" + StartColor + ", " + StartDensity + ", " + ApexColor + ", " + ApexDensity + ", " + EndColor + ", " + EndDensity + ", " + BeforeSlice + ", " + CenterSlice + ", " + AfterSlice + "}";
	    }
    }
}