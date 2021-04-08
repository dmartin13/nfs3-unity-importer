using UnityEngine;

namespace NFS3Importer.Runtime {
    public class ThunderBolt : MonoBehaviour {

        [SerializeField] private float length = 128.0f;
        [SerializeField] private float width = 32.0f;
        [SerializeField] private float duration = 0.3f;
        [SerializeField] private Material material;
        [SerializeField] private Vector2Int slices; 
        [SerializeField] private bool loop = false;
        [SerializeField] private AnimationCurve fadeOut = AnimationCurve.Linear(0, 1, 1, 0);
        [SerializeField] private float fadeOutDuration = 0.1f;
        
        private const string SHADER = "Particles/Priority Additive";
        private const string TEXTUREPROPERTYNAME = "_MainTex";
        private const string COLORPROPERTYNAME = "_TintColor";
        private LineRenderer rend;
        private Vector3[] positions;
        private int currentSliceX = 0;
        private int currentSliceY = 0;
        private int numSlices;
        private float sliceDuration;
        private float timeAccumulator;
        private float sliceWidthStep;
        private float sliceHeightStep;
        private Vector2 offset;
        private bool fadingOut;
        private Color initialColor;
        float time;

        void Start() {
            numSlices = slices.x * slices.y;
            sliceDuration = duration / numSlices;
            sliceWidthStep = 1.0f / slices.x;
            sliceHeightStep = 1.0f / slices.y;
            offset = new Vector2(0, 0);
            positions = new Vector3[] {new Vector3(0, 0, 0), new Vector3(0, -1 * length, 0)};

            rend = gameObject.AddComponent<LineRenderer>();
            for (int i = 0; i < positions.Length; i++) {
                positions[i] = positions[i] + transform.position;
            }
            rend.SetPositions(positions);
            rend.startWidth = width;
            rend.endWidth = width;
            rend.material = material;
            rend.material.SetTextureScale(TEXTUREPROPERTYNAME, new Vector2(1.0f / slices.x, 1.0f / slices.y));
            initialColor = rend.material.GetColor(COLORPROPERTYNAME);
        }

        void Update() {
            timeAccumulator += Time.deltaTime;
            if(fadingOut) {
                if(timeAccumulator >= fadeOutDuration) {
                    Destroy(gameObject);
                }
                time = Mathf.InverseLerp(0, fadeOutDuration, timeAccumulator);
                rend.material.SetColor(COLORPROPERTYNAME, initialColor * new Color (1,1,1, fadeOut.Evaluate(time)));
                return;
            }
            if(timeAccumulator >= sliceDuration) {
                currentSliceX++;
                if(currentSliceX >= slices.x) {
                    currentSliceX = 0;
                    currentSliceY += 1;
                }
                if(currentSliceY >= slices.y) {
                    if(!loop) {
                        fadingOut = true;
                        timeAccumulator = 0;
                        return;
                    }
                    currentSliceX = 0;
                    currentSliceY = 0;
                }
                offset.x = currentSliceX * sliceWidthStep;
                offset.y = currentSliceY * sliceHeightStep;
                rend.material.SetTextureOffset(TEXTUREPROPERTYNAME, offset);
                timeAccumulator = 0;
            }
        }
    }
}