using System.IO;
using UnityEditor;
using UnityEngine;
using NFS3Importer.Utility;
using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine.Rendering;
using NFS3Importer.UnityData;

namespace NFS3Importer.Editor {
	public class NFS3TrackImporterEditor : EditorWindow {
		private Texture2D logo = null;
		private string nfsBaseDirectory = null;
		private bool scanned = false;
		private bool[] selectedTracks;
		private bool unknownRP;
		private int selectedRP = -1;
		private readonly string[] optionsRP = new string[] {"Built-In Render Pipeline (Legacy)", "Universal Render Pipeline", "High Definition Render Pipeline"};
		private UnityData.RenderPipeline renderPipeline;
		private string sfxFshPath;
		private TrackInfo[] foundTracks;
		private ImporterSettings settings;

		[MenuItem ("Window/NFS3 Track Importer")]
		public static void ShowWindow () {
			EditorWindow.GetWindow (typeof (NFS3TrackImporterEditor));
		}

		void OnEnable () {
			logo = (Texture2D)AssetDatabase.LoadAssetAtPath ("Assets/NFS3Importer/Images/EditorLogo.png", typeof (Texture2D));
			settings = (ImporterSettings)AssetDatabase.LoadAssetAtPath("Assets/NFS3Importer/Settings/ImporterSettingsDefault.asset", typeof(ImporterSettings));
			if (GraphicsSettings.renderPipelineAsset == null) {
				// legacy renderer
				renderPipeline = UnityData.RenderPipeline.Legacy;
			} else {
				// URP or HDRP
				if (GraphicsSettings.currentRenderPipeline.GetType().ToString().Contains("HighDefinition")) {
					renderPipeline = UnityData.RenderPipeline.HDRP;
   				}
				else if (GraphicsSettings.currentRenderPipeline.GetType().ToString().Contains("Universal")) {
					renderPipeline = UnityData.RenderPipeline.URP;
				} else {
					renderPipeline = UnityData.RenderPipeline.Unknown;
					unknownRP = true;
				}
				
			}
		}

		void OnGUI () {

			if (unknownRP && selectedRP >= 0) {
				switch (selectedRP) {
					case 0: renderPipeline = UnityData.RenderPipeline.Legacy; break;
					case 1: renderPipeline = UnityData.RenderPipeline.URP; break;
					case 2: renderPipeline = UnityData.RenderPipeline.HDRP; break;
					default: renderPipeline = UnityData.RenderPipeline.Legacy; break;
				}
				unknownRP = false;
			}

			if(foundTracks == null && scanned) {
				scanned = false;
				nfsBaseDirectory = null;
			}

			GUILayout.BeginHorizontal ();
			GUILayout.FlexibleSpace ();
			GUILayout.Label (logo);
			GUILayout.FlexibleSpace ();
			GUILayout.EndHorizontal ();

			if(renderPipeline == UnityData.RenderPipeline.HDRP) {
				EditorGUILayout.HelpBox("The HDRP is currently not supported!", MessageType.Warning);
				return;
			} else if (renderPipeline == UnityData.RenderPipeline.URP) {
				EditorGUILayout.HelpBox("Universal Render Pipeline is active!", MessageType.Info);
			} else if (renderPipeline == UnityData.RenderPipeline.Legacy) {
				EditorGUILayout.HelpBox("Built-In Render Pipeline is active!", MessageType.Info);
			} else {
				EditorGUILayout.HelpBox("The render pipeline could not be recognized! Please select the render pipeline you are using from the list below", MessageType.Warning);
				selectedRP = EditorGUILayout.Popup("Render Pipeline", selectedRP, optionsRP);
				unknownRP = true;
				return;
			}

			if (GUILayout.Button ("Select Path")) {
				nfsBaseDirectory = EditorUtility.OpenFolderPanel ("Select Path", Application.streamingAssetsPath, "");
				if (nfsBaseDirectory.Length != 0) {
					Debug.Log ("Need For Speed 3 Base Directory: " + nfsBaseDirectory);
					scanned = false;
				}
			}
			if (nfsBaseDirectory != null && !nfsBaseDirectory.Equals ("")) {
				if (GUILayout.Button ("Scan Directory")) {
					if (scanDirectory ()) {
						scanned = true;
					}
				}
				if (scanned) {

					for (int i = 0; i < foundTracks.Length; i++) {
						TrackInfo info = foundTracks[i];
						GUILayout.BeginHorizontal ();
						GUILayout.FlexibleSpace ();
						GUILayout.Label (info.Name.Replace('_', ' '));
						selectedTracks[i] = GUILayout.Toggle (selectedTracks[i], "Import");
						GUILayout.FlexibleSpace ();
						GUILayout.EndHorizontal ();
					}

					GUILayout.BeginVertical ();
					settings = (ImporterSettings) EditorGUILayout.ObjectField("Importer Settings", settings, typeof(ImporterSettings), false);
					GUILayout.EndVertical ();

					if (GUILayout.Button ("Import Tracks")) {
						if(settings != null) {
							importTracks();
						} else {
							Debug.LogWarning("You need to assign a ImporterSettings-Object first!");
						}
					}
				}
			}
		}

		private bool scanDirectory () {

			FileInfo[] frdFiles = null;
			FileInfo[] sfxFiles = null;
			List<TrackInfo> tracks = new List<TrackInfo> ();

			try {

				DirectoryInfo folder = new DirectoryInfo (nfsBaseDirectory);

				sfxFiles = folder.GetFiles ("SFX.FSH", SearchOption.AllDirectories);
				if (sfxFiles == null || sfxFiles.Length == 0) {
					Debug.LogError ("No SFX.FSH found");
					return false;
				} else if (sfxFiles.Length > 1) {
					Debug.LogWarning ("More than one SFX-texture-file found. Using the first one");
				}
				sfxFshPath = sfxFiles[0].FullName;

				frdFiles = folder.GetFiles ("*.FRD", SearchOption.AllDirectories);

				foreach (FileInfo frd in frdFiles) {
					FileInfo[] colFiles = null;
					FileInfo[] hrzFiles = null;
					FileInfo[] qfsFiles = null;
					FileInfo[] canFiles = null;
					FileInfo[] skyFSHFiles = null;

					DirectoryInfo parent = frd.Directory;

					colFiles = parent.GetFiles ("*.COL");
					if (colFiles == null || colFiles.Length == 0) {
						Debug.LogError ("No COL-file found");
						return false;
					} else if (colFiles.Length > 1) {
						Debug.LogWarning ("More than one COL-file found. Using the first one");
					}

					hrzFiles = parent.GetFiles ("*.HRZ");
					if (hrzFiles == null || hrzFiles.Length == 0) {
						Debug.LogError ("No HRZ-files found");
						return false;
					} else if (hrzFiles.Length < 4) {
						Debug.LogWarning ("Less than 4 HRZ-files found");
					} else if (hrzFiles.Length > 4) {
						Debug.LogWarning ("More than 4 HRZ-files found. Using the first 4");
					}
					string[] hrzPaths = (from hrz in categorizeHRZ (hrzFiles) select hrz.FullName).ToArray ();

					qfsFiles = parent.GetFiles ("*0.QFS");
					if (qfsFiles == null || qfsFiles.Length == 0) {
						Debug.LogError ("No QFS-file found");
						return false;
					} else if (qfsFiles.Length > 1) {
						Debug.LogWarning ("More than one QFS-file found. Using the first");
					}

					canFiles = parent.GetFiles ("*.CAN");
					if (canFiles == null || canFiles.Length == 0) {
						Debug.LogWarning ("No CAN-files found");
					}
					string[] canPaths = (from can in canFiles select can.FullName).ToArray ();

					skyFSHFiles = parent.GetFiles ("SKY.FSH");
					if (skyFSHFiles == null || skyFSHFiles.Length == 0) {
						Debug.LogError ("No SKY.FSH found");
						return false;
					} else if (qfsFiles.Length > 1) {
						Debug.LogWarning ("More than one SKY.FSH found. Using the first");
					}

					TrackInfo info = new TrackInfo {
						Name = getTrackname (frd.DirectoryName),
						FRDPath = frd.FullName,
						COLPath = colFiles[0].FullName,
						HRZPaths = hrzPaths,
						QFSPath = qfsFiles[0].FullName,
						SkyFSHPath = skyFSHFiles[0].FullName,
						CANPaths = canPaths
					};
					tracks.Add (info);
				}
			} catch (UnauthorizedAccessException UAEx) {
				Debug.LogError (UAEx.Message);
				return false;
			} catch (PathTooLongException PathEx) {
				Debug.LogError (PathEx.Message);
				return false;
			}
			foundTracks = tracks.ToArray ();
			selectedTracks = new bool[foundTracks.Length];
			return true;
		}

		private string getTrackname (string path) {
			if (path.ContainsCaseInsensitive ("TRK000")) {
				return "Hometown";
			} else if (path.ContainsCaseInsensitive ("TRK001")) {
				return "Red_Rock_Ridge";
			} else if (path.ContainsCaseInsensitive ("TRK002")) {
				return "Atlantica";
			} else if (path.ContainsCaseInsensitive ("TRK003")) {
				return "Rocky_Pass";
			} else if (path.ContainsCaseInsensitive ("TRK004")) {
				return "Country_Woods";
			} else if (path.ContainsCaseInsensitive ("TRK005")) {
				return "Lost_Canyons";
			} else if (path.ContainsCaseInsensitive ("TRK006")) {
				return "Aquatica";
			} else if (path.ContainsCaseInsensitive ("TRK007")) {
				return "The_Summit";
			} else if (path.ContainsCaseInsensitive ("TRK008")) {
				return "Empire_City";
			}
			return "Unknown_Track";
		}

		private void importTracks () {

			// create a folder for our tracks if no folder exists already (asset-database allways use forward-slashes)
			string NFSTracksDirGUID;
			//string SFXTexturesDirGUID;
			if (!AssetDatabase.IsValidFolder("Assets/NFS3Tracks")) {
				NFSTracksDirGUID = AssetDatabase.CreateFolder ("Assets", "NFS3Tracks");
			} else {
				NFSTracksDirGUID = AssetDatabase.AssetPathToGUID ("Assets/NFS3Tracks");
			}

			for (int i = 0; i < foundTracks.Length; i++) {
				if (selectedTracks[i]) {

					Importer importer = new Importer();

					if(Directory.Exists(Path.Combine(AssetDatabase.GUIDToAssetPath (NFSTracksDirGUID), foundTracks[i].Name))) {
						Debug.LogWarning ("A folder with the name '" + foundTracks[i].Name + "' exists already. Delete this folder to re-import the track. Skipping track...");
						continue;
					}

					importer.trackName = foundTracks[i].Name;

					//create Assets Folders
					string guid = AssetDatabase.CreateFolder (AssetDatabase.GUIDToAssetPath (NFSTracksDirGUID), foundTracks[i].Name);
					string trackFolder = AssetDatabase.GUIDToAssetPath (guid);
					Debug.Log ("Saving Track to: " + trackFolder);
					string guidTextures = AssetDatabase.CreateFolder (trackFolder, "Textures");
					importer.texturesFolder = AssetDatabase.GUIDToAssetPath (guidTextures);
					string guidMaterials = AssetDatabase.CreateFolder (trackFolder, "Materials");
					importer.materialsFolder = AssetDatabase.GUIDToAssetPath (guidMaterials);
					string guidModels = AssetDatabase.CreateFolder (trackFolder, "Models");
					importer.modelsFolder = AssetDatabase.GUIDToAssetPath (guidModels);
					string guidColliders = AssetDatabase.CreateFolder (trackFolder, "Colliders");
					importer.collidersFolder = AssetDatabase.GUIDToAssetPath (guidColliders);
					string guidSounds = AssetDatabase.CreateFolder (trackFolder, "Sounds");
					importer.soundsFolder = AssetDatabase.GUIDToAssetPath (guidSounds);
					string guidScenes = AssetDatabase.CreateFolder (trackFolder, "Scenes");
					importer.scenesFolder = AssetDatabase.GUIDToAssetPath (guidScenes);
					string guidPrefabs = AssetDatabase.CreateFolder (trackFolder, "Prefabs");
					importer.prefabsFolder = AssetDatabase.GUIDToAssetPath (guidPrefabs);
					string guidAnimations = AssetDatabase.CreateFolder (trackFolder, "Animations");
					importer.animationsFolder = AssetDatabase.GUIDToAssetPath (guidAnimations);

					importer.settings = settings;

					importer.renderPipeline = renderPipeline;

					// Load Track
					importer.Import (foundTracks[i], sfxFshPath, true);
				}
			}

			// remove temporary textures
			Directory.Delete (Application.temporaryCachePath, true);
		}

		/// <summary>
		/// Categorizes the hrz-files. [0] = Normal, [1] = Weather ON, [2] = Night ON, [3] = WeatherNight ON 
		/// </summary>
		/// <returns>The hrz.</returns>
		/// <param name="hrzFiles">Hrz files.</param>
		private FileInfo[] categorizeHRZ (FileInfo[] hrzFiles) {

			FileInfo[] hrzPathsCategorized = new FileInfo[4];

			foreach (FileInfo hrzFile in hrzFiles) {

				if (hrzFile.Name.ContainsCaseInsensitive ("NW")) {
					// Night and Weather on
					hrzPathsCategorized[3] = hrzFile;
				} else if (hrzFile.Name.ContainsCaseInsensitive ("N")) {
					// Night on
					hrzPathsCategorized[2] = hrzFile;
				} else if (hrzFile.Name.ContainsCaseInsensitive ("W")) {
					// Weather on
					hrzPathsCategorized[1] = hrzFile;
				} else {
					// Normal day
					hrzPathsCategorized[0] = hrzFile;
				}
			}

			return hrzPathsCategorized;
		}
	}
}