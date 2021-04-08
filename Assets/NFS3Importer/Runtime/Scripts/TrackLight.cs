using System.Collections;
using UnityEngine;

namespace NFS3Importer.Runtime {
	public class TrackLight : MonoBehaviour {

		[SerializeField] [HideInInspector] private Light trackLight;
		[SerializeField] private bool isBlinking;
		[SerializeField] private int blinkInterval;

		public void Init (Vector3 position, Color32 color, bool isBlinking, int blinkInterval, float range) {
			this.isBlinking = isBlinking;
			this.blinkInterval = blinkInterval;

			trackLight = gameObject.AddComponent<Light> ();
			trackLight.color = (Color)color;
			trackLight.range = range;
			trackLight.type = LightType.Point;

			if(!isBlinking) {
				trackLight.lightmapBakeType = LightmapBakeType.Mixed;
			} else {
				trackLight.lightmapBakeType = LightmapBakeType.Realtime;
			}
			
			trackLight.shadows = LightShadows.Soft;
		}

		void Start () {
			if (isBlinking) {
				StartCoroutine (blinkLight ());
			}
		}

		private IEnumerator blinkLight () {
			while (true) {
				trackLight.enabled = !trackLight.enabled;
				yield return new WaitForSeconds (1f / blinkInterval);
			}

		}
	}
}
