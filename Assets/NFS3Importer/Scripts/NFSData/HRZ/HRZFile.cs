using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEngine;

namespace NFS3Importer.NFSData.HRZ {

	public class HRZFile {

		private string[] lines;
		private int[] values;

		/// <summary>
		/// The global fog color
		/// This values are overwritten by fog regions
		/// </summary>
		/// <value></value>
		public Color32 GlobalFogColor {
			get {
				return new Color32((byte)values[0], (byte)values[1], (byte)values[2], 0);
			}
		}

		/// <summary>
		/// Global fog density in percent.
		/// This values are overwritten by fog regions
		/// </summary>
		/// <value></value>
		public int GlobalFogDensity {
			get {
				return values[3];
			}
		}

		/// <summary>
		/// Effect of fog on the Pixmap (Backgroundimage) in percent
		/// </summary>
		/// <value></value>
		public int GlobalFogEffectOnPixmap {
			get {
				return values[4];
			}
		}

		/// <summary>
		/// Number of Fogregions
		/// </summary>
		/// <value></value>
		public int NumFogRegions {
			get {
				return values[5];
			}
		}

		/// <summary>
		/// Returns the fog region with a specified id
		/// </summary>
		/// <param name="id"></param>
		/// <returns></returns>
		public HRZFogRegion GetFogRegion(int id) {
			if (id < 0 || id > (NumFogRegions - 1)) return null;
			int i = 6 + (id * 15);
			return new HRZFogRegion() {
				StartColor = new Color32((byte)values[i], (byte)values[i + 1], (byte)values[i + 2], 0),
				StartDensity = values[i + 3],
				ApexColor = new Color32((byte)values[i + 4], (byte)values[i + 5], (byte)values[i + 6], 0),
				ApexDensity = values[i + 7],
				EndColor = new Color32((byte)values[i + 8], (byte)values[i + 9], (byte)values[i + 10], 0),
				EndDensity = values[i + 11],
				BeforeSlice = values[i + 12],
				CenterSlice = values[i + 13],
				AfterSlice = values[i + 14]
			};
		}

		/// <summary>
		/// Cloud Type 0 (no clouds), 1 (additive), 2 (blend)
		/// </summary>
		/// <value></value>
		public int CloudType {
			get {
				return values[6 + (NumFogRegions * 15)];
			}
		}

		/// <summary>
		/// Should the fog have effect on the clounds?
		/// </summary>
		/// <value></value>
		public int FogClouds {
			get {
				return values[6 + (NumFogRegions * 15) + 1];
			}
		}

		/// <summary>
		/// Has Lightning?, (%chance per # ticks): (chance, ticks)
		/// </summary>
		/// <value></value>
		public (int, int) LightningChancePerTicks {
			get {
				return (values[6 + (NumFogRegions * 15) + 2], values[6 + (NumFogRegions * 15) + 3]);
			}
		}

		/// <summary>
		/// Visual Height 100-1000.
		/// </summary>
		/// <value></value>
		public int VisualHeight {
			get {
				return values[6 + (NumFogRegions * 15) + 4];
			}
		}

		/// <summary>
		/// First integer is height offset. Second integer is the cloud height
		/// </summary>
		/// <value></value>
		public (int, int) CloudDomeOffset {
			get {
				return (values[6 + (NumFogRegions * 15) + 5], values[6 + (NumFogRegions * 15) + 6]);
			}
		}

		/// <summary>
		/// Cloud brightness (0-255)
		/// </summary>
		/// <value></value>
		public int CloudBrightness {
			get {
				return values[6 + (NumFogRegions * 15) + 7];
			}
		}

		/// <summary>
		/// Cloud Variance (< CloudBrightness)
		/// The contrast of the clouds
		/// </summary>
		/// <value></value>
		public int CloudVariance {
			get {
				return values[6 + (NumFogRegions * 15) + 8];
			}
		}

		/// <summary>
		/// how strongly the clouds shine at the position of a lightning bolt
		/// </summary>
		/// <value></value>
		public int CloudNimbusEffect {
			get {
				return values[6 + (NumFogRegions * 15) + 9];
			}
		}

		/// <summary>
		/// WindSpeed (clouds) mph
		/// </summary>
		/// <value></value>
		public int WindSpeed {
			get {
				return values[6 + (NumFogRegions * 15) + 10];
			}
		}

		/// <summary>
		/// Movement of the clouds (direction)
		/// </summary>
		/// <value></value>
		public int WindDirection {
			get {
				return values[6 + (NumFogRegions * 15) + 11];
			}
		}

		/// <summary>
		/// If true: the whole sky is black
		/// </summary>
		/// <value></value>
		public bool BlackHorizon {
			get {
				return values[6 + (NumFogRegions * 15) + 12] == 1;
			}
		}

		/// <summary>
		/// If true: the pixmap is mirrored horizontally
		/// </summary>
		/// <value></value>
		public int MirrorFlag {
			get {
				return values[6 + (NumFogRegions * 15) + 13];
			}
		}

		/// <summary>
		/// Radius of Pixmap (Backgroundimage) in meters
		/// </summary>
		/// <value></value>
		public int HorizonRadius {
			get {
				return values[6 + (NumFogRegions * 15) + 14];
			}
		}

		/// <summary>
		/// The angle of rotation for the horizon in degrees.
		/// </summary>
		/// <value></value>
		public int HorizonRotation {
			get {
				return values[6 + (NumFogRegions * 15) + 15];
			}
		}

		/// <summary>
		/// If a pixmap shuold be rendered or not
		/// </summary>
		/// <value></value>
		public bool HasPixmap {
			get {
				return values[6 + (NumFogRegions * 15) + 16] == 1;
			}
		}

		/// <summary>
		/// How high in the air the base of the Gourad shaded area is (world offset).
		/// </summary>
		/// <value></value>
		public int Base {
			get {
				return values[6 + (NumFogRegions * 15) + 17];
			}
		}

		/// <summary>
		/// Height of the Gourad shaded area (offset from base)
		/// </summary>
		/// <value></value>
		public int SkyTopOffsetFromBase {
			get {
				return values[6 + (NumFogRegions * 15) + 18];
			}
		}

		/// <summary>
		/// Midpoint of Gourad shaded area (offset from base)
		/// </summary>
		/// <value></value>
		public int HorizonOffsetFromBase {
			get {
				return values[6 + (NumFogRegions * 15) + 19];
			}
		}

		/// <summary>
		/// Top of horizon pixmap (offset from base)
		/// </summary>
		/// <value></value>
		public int TopOfPixmapOffsetFromBase {
			get {
				return values[6 + (NumFogRegions * 15) + 20];
			}
		}

		/// <summary>
		/// Bottom of horizon pixmap (offset from base)
		/// </summary>
		/// <value></value>
		public int BottomOfPixmapOffsetFromBase {
			get {
				return values[6 + (NumFogRegions * 15) + 21];
			}
		}

		/// <summary>
		/// r,g,b value at top of Gourad shaded EARTH area
		/// </summary>
		/// <value></value>
		public Color32 HorizonColor {
			get {
				int i = 6 + (NumFogRegions * 15);
				return new Color32((byte)values[i + 22], (byte)values[i + 23], (byte)values[i + 24], 0);
			}
		}

		/// <summary>
		/// r,g,b value at base of Gourad shaded EARTH area
		/// </summary>
		/// <value></value>
		public Color32 BottomColor {
			get {
				int i = 6 + (NumFogRegions * 15);
				return new Color32((byte)values[i + 25], (byte)values[i + 26], (byte)values[i + 27], 0);
			}
		}

		/// <summary>
		/// r,g,b value at top of Gourad shaded SKY area. First Element: SunSide, Second element: SunOpposite
		/// </summary>
		/// <value></value>
		public Color32 SkyColor {
			get {
				int i = 6 + (NumFogRegions * 15);
				return new Color32((byte)values[i + 28], (byte)values[i + 29], (byte)values[i + 30], 0);
			}
		}

		/// <summary>
		/// r,g,b values for base of Gourad shaded SKY area
		/// (at position of sun, at position opposite to sun)
		/// </summary>
		/// <value></value>
		public (Color32, Color32) SkyBaseColors {
			get {
				int i = 6 + (NumFogRegions * 15);
				return (new Color32((byte)values[i + 31], (byte)values[i + 32], (byte)values[i + 33], 0),
					new Color32((byte)values[i + 34], (byte)values[i + 35], (byte)values[i + 36], 0));
			}
		}

		/// <summary>
		/// Weathertype.
		/// 0: no weather effect
		/// 1: Rain
		/// 2: Snow
		/// </summary>
		/// <value></value>
		public int WeatherType {
			get {
				return values[6 + (NumFogRegions * 15) + 37];
			}
		}

		/// <summary>
		/// Which Virtual-Road-Point is the start-point of the weather-effect
		/// </summary>
		/// <value></value>
		public int StartSlice {
			get {
				return values[6 + (NumFogRegions * 15) + 38];
			}
		}

		/// <summary>
		/// Which Virtual-Road-Point is the end-point of the weather-effect
		/// </summary>
		/// <value></value>
		public int EndSlice {
			get {
				return values[6 + (NumFogRegions * 15) + 39];
			}
		}

		/// <summary>
		/// Linear fade in of weather before/after StartSlice/EndSlice
		/// </summary>
		/// <value></value>
		public int Fade {
			get {
				return values[6 + (NumFogRegions * 15) + 40];
			}
		}

		/// <summary>
		/// stayTimeOn  Ticks.
		/// How long (seconds*64) the weather effect should last
		/// This value has the be divided by 64 or (>>6)
		/// </summary>
		/// <value></value>
		public int StayTimeOnTicks {
			get {
				return values[6 + (NumFogRegions * 15) + 41];
			}
		}

		/// <summary>
		/// How long (seconds*64) the weather effect should fade out
		/// This value has the be divided by 64 or (>>6)
		/// </summary>
		/// <value></value>
		public int FadeTimeOffTicks {
			get {
				return values[6 + (NumFogRegions * 15) + 42];
			}
		}

		/// <summary>
		/// How long (seconds*64) the weather effect should stay off
		/// This value has the be divided by 64 or (>>6)
		/// </summary>
		/// <value></value>
		public int StayTimeOffTicks {
			get {
				return values[6 + (NumFogRegions * 15) + 43];
			}
		}

		/// <summary>
		/// How long (seconds*64) the weather effect should fade in
		/// This value has the be divided by 64 or (>>6)
		/// </summary>
		/// <value></value>
		public int FadeTimeOnTicks {
			get {
				return values[6 + (NumFogRegions * 15) + 44];
			}
		}

		/// <summary>
		/// Ambient Light Percentages (R,G,B) 0-100
		/// </summary>
		/// <value></value>
		public (int, int, int) AmbientLightPercentagesRGB {
			get {
				return (values[6 + (NumFogRegions * 15) + 45], 
					values[6 + (NumFogRegions * 15) + 46], 
					values[6 + (NumFogRegions * 15) + 47]);
			}
		}

		public HRZFile (string[] lines) {
			this.lines = lines;
			generate ();
		}

		private void generate() {
			List<string> tmp = new List<string>();
			// read HRZ-File linewise
			for (int i = 0; i < lines.Length; i++) {
				string withoutComments = Regex.Replace(lines[i], @"/\*.*\*/", string.Empty);
				foreach (Match match in Regex.Matches(withoutComments, @"-?\d+")) {
					tmp.Add(match.Value);
				}
			}
			this.values = new int[tmp.Count];
			for (int i = 0; i < tmp.Count; i++) {
				this.values[i] = int.Parse(tmp[i]);
			}
		}
	}
}