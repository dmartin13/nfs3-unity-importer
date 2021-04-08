using System.Collections;
using UnityEngine;

namespace NFS3Importer.Runtime {

	[RequireComponent (typeof(MeshRenderer))]
	public class TextureAnimator : MonoBehaviour {

		private MeshRenderer rend;
		private bool isShaderGraph;
		//private Material material;
		[HideInInspector] [SerializeField] private int numFrames;
		[SerializeField] private float framesPerSecond;

		//the current frame to display
		private int index = 0;

		public void Start () {
			rend = transform.GetComponent<MeshRenderer> ();
			StartCoroutine (updateTiling ());

			if(rend.sharedMaterial.shader.name.Contains("URP/Additive")) {
				isShaderGraph = true;
			}
		}

		/// <summary>
		/// This has to be called after the materials have been assigned to the object
		/// </summary>
		/// <param name="framesPerSecond"></param>
		/// <param name="materialIndex"></param>
		public void Init (float framesPerSecond, int materialIndex) {
			this.framesPerSecond = framesPerSecond;

			rend = transform.GetComponent<MeshRenderer> ();
			Material material = rend.sharedMaterials [materialIndex];
			// assume that every tile is a square with the same size
			numFrames = material.mainTexture.width / material.mainTexture.height;

			//set the tile size of the texture (in UV units), based on the rows and columns
			Vector2 size = new Vector2 (1f / numFrames, 1f);

			if(rend.sharedMaterial.shader.name.Contains("URP/Additive")) {
				rend.sharedMaterial.SetVector("_Tiling", (Vector4) size);
			} else {
				rend.sharedMaterial.mainTextureScale = size;
			}
			
		}

		private IEnumerator updateTiling () {
			while (true) {
				//move to the next index
				index++;
				if (index >= numFrames)
					index = 0;

				//split into x and y indexes
				Vector2 offset = new Vector2 ((float)index / numFrames - (index / numFrames), //x index
									(index / numFrames));                                     //y index

				if(isShaderGraph) {
					rend.material.SetVector("_Offset", (Vector4) offset);
				} else {
					rend.material.mainTextureOffset = offset;
				}

				yield return new WaitForSeconds (1f / framesPerSecond);
			}

		}
	}
}