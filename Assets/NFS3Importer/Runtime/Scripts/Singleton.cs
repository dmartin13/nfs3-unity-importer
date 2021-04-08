using UnityEngine;

/// <summary>
/// Inherit from this base class to create a singleton.
/// e.g. public class MyClassName : Singleton<MyClassName> {}
/// </summary>

namespace NFS3Importer.Runtime {
	public class Singleton<T> : MonoBehaviour where T : MonoBehaviour {
		// Check to see if we're about to be destroyed.
		private static bool shuttingDown = false;
		private static object lockObject = new object ();
		private static T instance;

		/// <summary>
		/// Access singleton instance through this propriety.
		/// </summary>
		public static T Instance {
			get {
				if (shuttingDown) {
					Debug.LogWarning ("[Singleton] Instance '" + typeof (T) +
						"' already destroyed. Returning null.");
					return null;
				}

				lock (lockObject) {
					if (instance == null) {
						// Search for existing instance.
						instance = (T)FindObjectOfType (typeof (T));

						// Create new instance if one doesn't already exist.
						if (instance == null) {
							// Need to create a new GameObject to attach the singleton to.
							var singletonObject = new GameObject ();
							instance = singletonObject.AddComponent<T> ();
							singletonObject.name = typeof (T).ToString () + " (Singleton)";

							// Make instance persistent.
							//DontDestroyOnLoad (singletonObject);
						}
					}

					return instance;
				}
			}
		}


		private void OnApplicationQuit () {
			shuttingDown = true;
		}


		private void OnDestroy () {
			shuttingDown = true;
		}
	}
}