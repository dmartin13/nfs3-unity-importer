using System.Collections.Generic;
using System.IO;
using NFS3Importer.NFSData.FSHQFS;
using NFS3Importer.Runtime;
using NFS3Importer.UnityData;
using NFS3Importer.Utility;
using UnityEditor.SceneManagement;
using UnityEngine;

namespace NFS3Importer {
	public class Importer {

		public string trackName;
		public ImporterSettings settings;

		public string texturesFolder;
		public string materialsFolder;
		public string modelsFolder;
		public string collidersFolder;
		public string soundsFolder;
		public string scenesFolder;
		public string prefabsFolder;
		public string animationsFolder;
		public RenderPipeline renderPipeline;

		private List<GeneratedObject> generatedObjects = new List<GeneratedObject>();

		public void Import (TrackInfo track, string sfxFshPath, bool saveToAssets) {
			
			NFSData.FRD.FRDFile frdFile;
			NFSData.COL.COLFile colFile;
			NFSData.CAN.CANFile[] canFiles;

			List<FSHQFSItem> textures;
			MaterialHandler materialHandler;

			// read bytewise
			byte[] frdBytes;
			byte[] colBytes;
			List<byte[]> canBytes = new List<byte[]> ();

			// read linewise
			// 0 = Normal Day, 1 = Weather On, 2 = Night On, 3 = Night & Weather
			string[][] hrzLines = new string[4][];

			//Create scene
			UnityEngine.SceneManagement.Scene scene = default;
			#if UNITY_EDITOR
			if(saveToAssets) {
				scene = EditorSceneManager.NewScene (NewSceneSetup.EmptyScene, NewSceneMode.Single);
				scene.name = trackName;
			}
			#endif

			// first decompress the textures
			string textureTmpPath = Path.Combine (Application.temporaryCachePath, track.Name + "_Textures");
			Directory.CreateDirectory (textureTmpPath);
			Debug.Log ("Decompressing textures to: " + textureTmpPath);
			FSHTool.Decompress (track.QFSPath, textureTmpPath);

			// decompress the SFX-textures
			string sfxTextureTmpPath = Path.Combine (Application.temporaryCachePath, track.Name + "_SFXTextures");
			Directory.CreateDirectory (sfxTextureTmpPath);
			Debug.Log ("Decompressing SFX-textures to: " + sfxTextureTmpPath);
			FSHTool.Decompress (sfxFshPath, sfxTextureTmpPath);

			// decompress the sky textures
			string skyTextureTmpPath = Path.Combine (Application.temporaryCachePath, track.Name + "_SKYTextures");
			Directory.CreateDirectory (skyTextureTmpPath);
			Debug.Log ("Decompressing SKY-textures to: " + skyTextureTmpPath);
			FSHTool.Decompress (track.SkyFSHPath, skyTextureTmpPath);

			//texture folder is scanned seperately by TextureLoader
			textures = new List<FSHQFSItem> ();
			// create items for "normal" track textures
			FSHQFSItem[] textureItems = TextureLoader.GetTextures (textureTmpPath, true);
			// create items for SKY track textures
			FSHQFSItem[] skyTextureItems = TextureLoader.GetTextures (skyTextureTmpPath, false);
			// add sfx-textures for every track
			FSHQFSItem[] sfxTextureItems = TextureLoader.GetTextures (sfxTextureTmpPath, false);

			#if UNITY_EDITOR
			if(saveToAssets) {
				// create an asset for each texture of this track
				for (int i = 0; i < textureItems.Length; i++) {
					generatedObjects.Add(new GeneratedObject(textureItems[i].Texture, ObjectType.Texture, i + "_D.texture2d"));
				}
				// create an asset for each sky-texture of this track
				for (int i = 0; i < skyTextureItems.Length; i++) {
					generatedObjects.Add(new GeneratedObject(skyTextureItems[i].Texture, ObjectType.Texture, i + "_SKY_D.texture2d"));
				}
				// create an asset for each texture of this track
				for (int i = 0; i < sfxTextureItems.Length; i++) {
					generatedObjects.Add(new GeneratedObject(sfxTextureItems[i].Texture, ObjectType.Texture, i + "_SFX_D.texture2d"));
				}
			}
			#endif

			// add textures to our own datastructure
			textures.AddRange (textureItems);
			textures.AddRange (skyTextureItems);
			textures.AddRange (sfxTextureItems);

			FSHQFSItem[] texturesArray = textures.ToArray();

			frdBytes = File.ReadAllBytes (track.FRDPath);
			colBytes = File.ReadAllBytes (track.COLPath);

			foreach (string canFile in track.CANPaths) {
				canBytes.Add (File.ReadAllBytes (canFile));
			}

			// day
			hrzLines[0] = File.ReadAllLines (track.HRZPaths[0]);
			// weather
			hrzLines[1] = File.ReadAllLines (track.HRZPaths[1]);
			// night
			hrzLines[2] = File.ReadAllLines (track.HRZPaths[2]);
			// night and weather
			hrzLines[3] = File.ReadAllLines (track.HRZPaths[3]);

			materialHandler = new MaterialHandler (texturesArray, renderPipeline, settings, ref generatedObjects);

			// main track file
			frdFile = new NFS3Importer.NFSData.FRD.FRDFile (frdBytes);
			// additional track file
			colFile = new NFS3Importer.NFSData.COL.COLFile (colBytes);

			// camera animation files
			canFiles = new NFS3Importer.NFSData.CAN.CANFile[canBytes.Count];
			for (int i = 0; i < canBytes.Count; i++) {
				canFiles[i] = new NFS3Importer.NFSData.CAN.CANFile (canBytes[i]);
			}

			// create the pixmap-texture
			Texture2D pixmap =  TrackUtils.CreatePixmap(textureItems);
			// create an asset for the pixmap
			#if UNITY_EDITOR
			if(saveToAssets) {
				generatedObjects.Add(new GeneratedObject(pixmap, ObjectType.Texture, "pixmap_combined.texture2d"));
				//UnityEditor.AssetDatabase.CreateAsset (pixmap, Path.Combine (texturesFolder, "pixmap_combined.texture2d"));
			}
			#endif

			// get cloud textures
			Texture2D cloudsDay = Utility.Utils.GetTexture(FSHQFSGroup.CloudsDay, 0, texturesArray).Texture;
			Texture2D cloudsWeather = Utility.Utils.GetTexture(FSHQFSGroup.CloudsWeather, 0, texturesArray).Texture;
			Texture2D cloudsNight = Utility.Utils.GetTexture(FSHQFSGroup.CloudsNight, 0, texturesArray).Texture;
			Texture2D cloudsNightWeather = Utility.Utils.GetTexture(FSHQFSGroup.CloudsNightWeather, 0, texturesArray).Texture;

			// horizon files
			// [0] = Normal Weather, [1] = Weather On, [2] = Night On, [3] = Weather and Night On
			Weather wDay = HRZParser.CreateWeather(renderPipeline, new NFS3Importer.NFSData.HRZ.HRZFile (hrzLines[0]), WeatherType.Day, pixmap, cloudsDay, settings);
			Weather wWeather = HRZParser.CreateWeather(renderPipeline, new NFS3Importer.NFSData.HRZ.HRZFile (hrzLines[1]), WeatherType.Weather, pixmap, cloudsWeather, settings);
			Weather wNight = HRZParser.CreateWeather(renderPipeline, new NFS3Importer.NFSData.HRZ.HRZFile (hrzLines[2]), WeatherType.Night, pixmap, cloudsNight, settings);
			Weather wNightWeather = HRZParser.CreateWeather(renderPipeline, new NFS3Importer.NFSData.HRZ.HRZFile (hrzLines[3]), WeatherType.NightWeather, pixmap, cloudsNightWeather, settings);
			#if UNITY_EDITOR
			if(saveToAssets) {
				// save the skyboxmaterials
				generatedObjects.Add(new GeneratedObject(wDay.skybox, ObjectType.Material, "skybox_day.mat"));
				generatedObjects.Add(new GeneratedObject(wWeather.skybox, ObjectType.Material, "skybox_weather.mat"));
				generatedObjects.Add(new GeneratedObject(wNight.skybox, ObjectType.Material, "skybox_night.mat"));
				generatedObjects.Add(new GeneratedObject(wNightWeather.skybox, ObjectType.Material, "skybox_night_weather.mat"));
				// create an asset for each weather of this track
				generatedObjects.Add(new GeneratedObject(wDay, ObjectType.WeatherAsset, "weather_day.asset"));
				generatedObjects.Add(new GeneratedObject(wWeather, ObjectType.WeatherAsset, "weather_weather.asset"));
				generatedObjects.Add(new GeneratedObject(wNight, ObjectType.WeatherAsset, "weather_night.asset"));
				generatedObjects.Add(new GeneratedObject(wNightWeather, ObjectType.WeatherAsset, "weather_night_weather.asset"));
			}
			#endif

			NFS2UnityParser parser = new NFS2UnityParser (frdFile, colFile, canFiles, materialHandler, true, ref generatedObjects, settings);
			parser.GetTrack ();

			// load the default weather (day)
			NFSTrackSettings.Instance.Weather = wDay;

			// save scene and all created assets
			#if UNITY_EDITOR
			if(saveToAssets) {
				if(scene != default) {
					string scenePath = Path.Combine(scenesFolder, trackName + ".unity");
					Debug.Log("Saving Scene to " + scenePath);
					EditorSceneManager.SaveScene(scene, scenePath);
				}
				// save all created assets
				saveAssets();
			}
			#endif
		}

		private void saveAssets() {
			string path;
			foreach (GeneratedObject generatedObject in generatedObjects) {
				path = null;
				switch (generatedObject.type) {
					case ObjectType.Animation:
						path = animationsFolder;
						break;
					case ObjectType.Collider:
						path = collidersFolder;
						break;
					case ObjectType.Material:
						path = materialsFolder;
						break;
					case ObjectType.Model:
						path = modelsFolder;
						break;
					case ObjectType.Texture:
						path = texturesFolder;
						break;
					case ObjectType.Prefab:
						path = prefabsFolder;
						break;
					case ObjectType.Scene:
						path = scenesFolder;
						break;
					case ObjectType.Sound:
						path = soundsFolder;
						break;
					case ObjectType.WeatherAsset:
						path = scenesFolder;
						break;
					default:
						break;
				}
				if (path != null) {
					UnityEditor.AssetDatabase.CreateAsset (generatedObject.o, Path.Combine (path, generatedObject.name));
				}
			}
		}
	}
}