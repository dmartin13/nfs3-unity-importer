using UnityEngine;

namespace NFS3Importer.Runtime {
	public class VRoadPoint : MonoBehaviour {

		[SerializeField] public int id;
		[SerializeField] public VRoadPoint[] neighbors;
		[SerializeField] public Vector3 rightPoint;
		[SerializeField] public Vector3 leftPoint;
		[HideInInspector] [SerializeField] public Vector3 position;

		public Weather.FogParameter fogParameter;
		public Vector3 Right {get {return transform.right;}}
		public Vector3 Up {get {return transform.up;}}
		public Vector3 Forward {get {return transform.forward;}}

		public void Init (int id, Vector3 leftPoint, Vector3 rightPoint, VRoadPoint[] neighbors = null) {
			this.id = id;
			this.position = transform.position;
			this.leftPoint = leftPoint;
			this.rightPoint = rightPoint;
			this.neighbors = neighbors;
		}

		void OnDrawGizmosSelected () {

			Gizmos.color = Color.magenta;
			Gizmos.DrawSphere (transform.position, 0.5f);

			Gizmos.color = Color.white;
			Gizmos.DrawLine (transform.position, transform.position + transform.forward);

			Gizmos.color = Color.green;
			Gizmos.DrawSphere (leftPoint, 0.5f);
			Gizmos.DrawSphere (rightPoint, 0.5f);
			Gizmos.color = Color.white;
			Gizmos.DrawLine (transform.position, leftPoint);
			Gizmos.DrawLine (transform.position, rightPoint);

			Gizmos.color = Color.white;
			Gizmos.DrawLine (transform.position, transform.position + transform.up);
		}
	}
}
