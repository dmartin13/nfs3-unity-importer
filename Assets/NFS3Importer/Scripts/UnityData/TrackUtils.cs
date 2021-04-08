using System.Collections.Generic;
using NFS3Importer.Utility;
using NFS3Importer.Runtime;
using UnityEngine;

namespace NFS3Importer.UnityData {
	public static class TrackUtils {
		public static GameObject MakeLight (Vector3 lightPosition, int lightType, ImporterSettings settings) {
			// Use Data from NFSHS Tracks TR.INI
			switch (lightType) {
			case 0:
				return CreateLightObject (lightPosition, new Color32 (222, 234, 235, 255), false, 0, settings.lightMultiplier * 5.00f, settings);
			case 1:
				return CreateLightObject (lightPosition, new Color32 (255, 255, 255, 185), false, 0, settings.lightMultiplier * 4.50f, settings);
			case 2:
				return CreateLightObject (lightPosition, new Color32 (255, 255, 210, 255), false, 0, settings.lightMultiplier * 5.00f, settings);
			case 3:
				return CreateLightObject (lightPosition, new Color32 (128, 229, 240, 255), false, 0, settings.lightMultiplier * 4.50f, settings);
			case 4:
				return CreateLightObject (lightPosition, new Color32 (217, 196, 94, 255), false, 0, settings.lightMultiplier * 5.00f, settings);
			case 5:
				return CreateLightObject (lightPosition, new Color32 (223, 22, 22, 255), true, 6, settings.lightMultiplier * 5.00f, settings);
			case 6:
				return CreateLightObject (lightPosition, new Color32 (223, 22, 22, 255), true, 5, settings.lightMultiplier * 5.00f, settings);
			case 7:
				return CreateLightObject (lightPosition, new Color32 (255, 0, 0, 255), true, 6, settings.lightMultiplier * 3.13f, settings);
			case 8:
				return CreateLightObject (lightPosition, new Color32 (163, 177, 190, 255), false, 0, settings.lightMultiplier * 3.75f, settings);
			case 9:
				return CreateLightObject (lightPosition, new Color32 (223, 22, 22, 255), false, 0, settings.lightMultiplier * 3.13f, settings);
			case 10:
				return CreateLightObject (lightPosition, new Color32 (223, 22, 22, 186), false, 0, settings.lightMultiplier * 2.50f, settings);
			case 11:
				return CreateLightObject (lightPosition, new Color32 (30, 149, 227, 255), false, 0, settings.lightMultiplier * 2.50f, settings);
			case 12:
				return CreateLightObject (lightPosition, new Color32 (30, 149, 227, 255), true, 6, settings.lightMultiplier * 3.13f, settings);
			case 13:
				return CreateLightObject (lightPosition, new Color32 (224, 224, 39, 255), false, 0, settings.lightMultiplier * 3.75f, settings);
			case 14:
				return CreateLightObject (lightPosition, new Color32 (222, 234, 235, 255), false, 0, settings.lightMultiplier * 5.00f, settings);
			case 15:
				return CreateLightObject (lightPosition, new Color32 (222, 234, 235, 255), false, 0, settings.lightMultiplier * 5.00f, settings);
			case 16:
				return CreateLightObject (lightPosition, new Color32 (222, 234, 235, 255), false, 0, settings.lightMultiplier * 5.00f, settings);
			case 17:
				return CreateLightObject (lightPosition, new Color32 (255, 255, 255, 185), false, 0, settings.lightMultiplier * 4.50f, settings);
			case 18:
				return CreateLightObject (lightPosition, new Color32 (255, 255, 210, 255), false, 0, settings.lightMultiplier * 5.00f, settings);
			case 19:
				return CreateLightObject (lightPosition, new Color32 (128, 229, 240, 255), false, 0, settings.lightMultiplier * 4.50f, settings);
			case 20:
				return CreateLightObject (lightPosition, new Color32 (217, 196, 94, 255), false, 0, settings.lightMultiplier * 5.00f, settings);
			case 21:
				return CreateLightObject (lightPosition, new Color32 (223, 22, 22, 255), true, 6, settings.lightMultiplier * 5.00f, settings);
			case 22:
				return CreateLightObject (lightPosition, new Color32 (223, 22, 22, 255), true, 5, settings.lightMultiplier * 5.00f, settings);
			case 23:
				return CreateLightObject (lightPosition, new Color32 (255, 0, 0, 255), true, 6, settings.lightMultiplier * 3.13f, settings);
			case 24:
				return CreateLightObject (lightPosition, new Color32 (163, 177, 190, 255), false, 0, settings.lightMultiplier * 3.75f, settings);
			case 25:
				return CreateLightObject (lightPosition, new Color32 (223, 22, 22, 255), false, 0, settings.lightMultiplier * 3.13f, settings);
			case 26:
				return CreateLightObject (lightPosition, new Color32 (223, 22, 22, 186), false, 0, settings.lightMultiplier * 2.50f, settings);
			case 27:
				return CreateLightObject (lightPosition, new Color32 (30, 149, 227, 255), false, 0, settings.lightMultiplier * 2.50f, settings);
			case 28:
				return CreateLightObject (lightPosition, new Color32 (30, 149, 227, 255), true, 6, settings.lightMultiplier * 3.13f, settings);
			case 29:
				return CreateLightObject (lightPosition, new Color32 (224, 224, 39, 255), false, 0, settings.lightMultiplier * 3.75f, settings);
			case 30:
				return CreateLightObject (lightPosition, new Color32 (222, 234, 235, 255), false, 0, settings.lightMultiplier * 5.00f, settings);
			case 31:
				return CreateLightObject (lightPosition, new Color32 (222, 234, 235, 255), false, 0, settings.lightMultiplier * 5.00f, settings);
			default:
				return CreateLightObject (lightPosition, new Color32 (255, 255, 255, 255), false, 0, settings.lightMultiplier * 5.00f, settings);
			}
		}

		private static GameObject CreateLightObject (Vector3 lightPosition, Color32 color, bool isBlinking, int blinkInterval, float range, ImporterSettings settings) {
			GameObject obj = new GameObject ("Light");
			obj.transform.position = lightPosition;

			TrackLight trackLight = obj.AddComponent<TrackLight> ();

			trackLight.Init (lightPosition, color, isBlinking, blinkInterval, range);

			if(settings.lightsHaveFlare) {
				// TODO: Add Flare
			}
			
			return obj;
		}

		public static Texture2D CreatePixmap(NFSData.FSHQFS.FSHQFSItem[] textures) {
            // first we collect our pixmap-textures. As this textures are always the first 8, we search for IDs 0 - 8
            // actually we could simply use texture[0] - texture[7] as the textures are loaded sequentially. 
            // But as germans like to say: doppelt hält besser.. we search directly for the IDs
            List<NFSData.FSHQFS.FSHQFSItem> pixmapTextures = new List<NFSData.FSHQFS.FSHQFSItem>();
            for (int i = 0; i <= 7; i++) {
                pixmapTextures.Add(Utility.Utils.GetTexture(FSHQFSGroup.GLOBAL, i, textures));
            }

            if(pixmapTextures.Count == 0) return null;

            int width = pixmapTextures[0].Texture.width;
            int height = pixmapTextures[0].Texture.height;

            // the combined texture consists of 8 textures 
            int newWidth = width * 8;
            int newHeight = height;

			// important: we want no mipmaps!
			Texture2D pixmap = new Texture2D(newWidth, newHeight, TextureFormat.RGBA32, false, false);

			// make complete texture black
			Color[] pixels = pixmap.GetPixels();
			for (int i = 0; i < pixels.Length; i++) {
				pixels[i] = Color.clear;
			}
			pixmap.SetPixels(pixels);


            for (int i = 0; i <= 7; i++) {
				Texture2D slice = pixmapTextures[i].Texture;
				// our skybox-shader has problems to display clamped textures when there is not enough transparent margin 
            	// on the clamped edges. So we simply scale the height down and add some transparent pixels at the top and bottom where the texture 
            	// should be clamped later
				if(height > 4) {
					if (slice.width != width || slice.height != (height - 4)) {
						TextureScale.Bilinear (slice, width, (height - 4));
					}
					pixmap.SetPixels (i * width, 2, width, (height - 4), slice.GetPixels ());
				} else {
					if (slice.width != width || slice.height != height) {
						TextureScale.Bilinear (slice, width, height);
					}
					pixmap.SetPixels (i * width, 0, width, height, slice.GetPixels ());
				}
				
			}

			pixmap.Apply ();

			// we want to mirror the texture horizontally and clamp vertically
			pixmap.wrapModeU = TextureWrapMode.Mirror;
			pixmap.wrapModeV = TextureWrapMode.Clamp;

            return pixmap;
        }
	}
}
