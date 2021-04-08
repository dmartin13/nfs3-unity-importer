using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace NFS3Importer.UnityData {
    [CreateAssetMenu(fileName = "ImporterSettings", menuName = "NFS3Importer/ImporterSettings")]
	public class ImporterSettings : ScriptableObject {
		public LOD levelOfDetail = LOD.HighRes;
        public float GouraudAngle = 60.0f;
		public float UVMargin = 0.07f;
		public float lightMultiplier = 10.0f;
		public bool lightsHaveFlare = true;
		public float flareSize = 5.0f;
		public float lightProbeHeight = 5.0f;
		public int lightProbeSpacing = 8;
		public float lightProbeMargin = 0.1f;
		public GameObject rainEffect;
		public GameObject snowEffect;
		public GameObject lightningEffect;
		public float lightningHeight = 200.0f;
        public float hitAndFallMass = 1000.0f;
		public float hitAndFallBreakForce = 50000.0f;
		public float hitAndFallRealMass = 50.0f;
		public float colliderHeight = 10.0f;
		public float materialGlossiness = 0;
    }
}
