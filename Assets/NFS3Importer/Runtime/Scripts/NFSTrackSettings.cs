using UnityEngine;
using UnityEditor;

namespace NFS3Importer.Runtime {

	public class NFSTrackSettings : Singleton<NFSTrackSettings> {

		// (Optional) Prevent non-singleton constructor use.
		protected NFSTrackSettings () { }

		[SerializeField] public VRoadPoint[] virtualRoadPoints;

		[SerializeField] private Weather weather;

		public Weather Weather {
			get {
				return weather;
			}
			set {
				weather = value;
				setWeather();
			}
		}

		private Weather oldWeather;
		[HideInInspector] [SerializeField] private GameObject sunlight;

		void Start() {
			oldWeather = weather;
			weather.Start();
		}

		void Update() {
			// update our weather every frame
			weather.Update();
		}

		private void setWeather() {
			if (weather) {
				if(!sunlight) {
					sunlight = new GameObject("Sunlight");
				}
				weather.Load(sunlight, virtualRoadPoints);
				oldWeather = weather;
			}
		}

		private void update() {
			setWeather();
		}

		#if UNITY_EDITOR
		[CustomEditor(typeof(NFSTrackSettings))]
		public class GlobalManagerEditor : Editor {
			public override void OnInspectorGUI() {
				DrawDefaultInspector();

				NFSTrackSettings gm = (NFSTrackSettings)target;
				if (gm.oldWeather != gm.weather && gm.oldWeather != null) {
					gm.update();
				} else if(gm.oldWeather == null) {
					gm.oldWeather = gm.weather;
					if(gm.weather != null) {
						gm.update();
					}
				}
			}
		}
		#endif
	}
}