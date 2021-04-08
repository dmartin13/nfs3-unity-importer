using UnityEngine;

namespace NFS3Importer.Runtime {
	public class HitAndFallObject : MonoBehaviour {

		private Rigidbody rb;
		public bool Broken {get; private set;}

		[SerializeField] private float mass;

		public void Init (float mass) {
			this.mass = mass;
		}

		void Start () {
			rb = gameObject.GetComponent<Rigidbody> ();
		}
		private void OnJointBreak () {
			rb.mass = mass;
			Broken = true;
		}
	}
}
