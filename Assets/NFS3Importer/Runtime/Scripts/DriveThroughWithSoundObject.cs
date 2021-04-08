using UnityEngine;

namespace NFS3Importer.Runtime {
	public class DriveThroughWithSoundObject : MonoBehaviour {

		[SerializeField] [HideInInspector] private BoxCollider trigger;
		[SerializeField] [HideInInspector] private AudioSource audioSource;
		[SerializeField] private float speedThreshold;
		[SerializeField] private AudioClip sound;

		public void Init (AudioClip sound, float speedThreshold) {
			this.sound = sound;
			this.speedThreshold = speedThreshold;
			trigger = gameObject.AddComponent<BoxCollider> ();
			trigger.isTrigger = true;
			audioSource = gameObject.AddComponent<AudioSource> ();
			audioSource.clip = sound;
		}

		void OnTriggerEnter (Collider other) {
			if(other.GetComponent<Rigidbody>() != null 
			&& !other.attachedRigidbody.isKinematic 
			&& other.attachedRigidbody.velocity.magnitude >= speedThreshold) {
				audioSource.Play ();
			}
		}
	}
}