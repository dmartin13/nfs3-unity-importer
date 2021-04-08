using UnityEngine;

namespace NFS3Importer.Runtime {

    [RequireComponent (typeof(Animation))]
    public class AnimationHandler : MonoBehaviour {

        private Animation anim;
        [SerializeField] public float animationSpeed = 1.0f; 
        void Start() {
            anim = GetComponent<Animation>();
            if(anim != null ) {
                foreach (AnimationState state in anim) {
                    state.speed = animationSpeed;
                    anim.Play(state.clip.name);
                    // just play the first animation if there is one as we have always only one animation clip.
                    break;
                }
            }
        }
    }
}
