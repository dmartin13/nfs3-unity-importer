using UnityEngine;
using NFS3Importer.NFSData.FSHQFS;
using System.Collections.Generic;
using NFS3Importer.Utility;
using System.IO;
using UnityEngine.Rendering;

namespace NFS3Importer.UnityData {
	public class MaterialHandler {

		// Shaders
		private readonly Shader CULLONCUTOUT;
		private readonly Shader CULLONOPAQUE;
		private readonly Shader CULLOFFCUTOUT;
		private readonly Shader CULLOFFOPAQUE;
		private readonly Shader ADDITIVE;

		private Dictionary<FSHQFSGroup, Dictionary<int, FSHQFSItem>> textures;
		private Dictionary<FSHQFSGroup, Dictionary<int, Dictionary<RenderFlag, Material>>> materials;
		private RenderPipeline renderPipeline;
		private List<GeneratedObject> generatedObjects;
		private ImporterSettings settings;

		public MaterialHandler (FSHQFSItem[] textures, RenderPipeline renderPipeline, ImporterSettings settings, ref List<GeneratedObject> generatedObjects) {

			this.renderPipeline = renderPipeline;
			this.settings = settings;

			// fetching shaders depending on renderpipeline
			if (renderPipeline == RenderPipeline.Legacy) {
				CULLONCUTOUT = Shader.Find ("Standard");
				CULLONOPAQUE = Shader.Find ("Standard");
				CULLOFFCUTOUT = Shader.Find ("Standard");
				CULLOFFOPAQUE = Shader.Find ("Standard");
				ADDITIVE = Shader.Find ("NFS3Importer/Legacy/Additive");
			} else if (renderPipeline == RenderPipeline.URP) {
				CULLONCUTOUT = Shader.Find ("Universal Render Pipeline/Lit");
				CULLONOPAQUE = Shader.Find ("Universal Render Pipeline/Lit");
				CULLOFFCUTOUT = Shader.Find ("Universal Render Pipeline/Lit");
				CULLOFFOPAQUE = Shader.Find ("Universal Render Pipeline/Lit");
				ADDITIVE = Shader.Find ("NFS3Importer/URP/Additive");
   			} else {
				// Render pipeline not supported
				CULLONCUTOUT = Shader.Find ("Standard");
				CULLONOPAQUE = Shader.Find ("Standard");
				CULLOFFCUTOUT = Shader.Find ("Standard");
				CULLOFFOPAQUE = Shader.Find ("Standard");
				ADDITIVE = Shader.Find ("NFS3Importer/Legacy/Additive");
			}
			

			this.materials = new Dictionary<FSHQFSGroup, Dictionary<int, Dictionary<RenderFlag, Material>>> ();
			this.textures = new Dictionary<FSHQFSGroup, Dictionary<int, FSHQFSItem>> ();
			this.generatedObjects = generatedObjects;

			foreach (FSHQFSItem item in textures) {
				if (!this.textures.ContainsKey (item.Group)) {
					this.textures.Add (item.Group, new Dictionary<int, FSHQFSItem> ());
				}
				if(this.textures[item.Group].ContainsKey(item.ID)) {
					Debug.LogWarning("There is already a Texture in group " + item.Group.ToString() + " with ID " + item.ID + ". This is a known issue and is caused by invalid entries in index.fsh files from the NFS-developers. But it has no negative effect on the import");
					continue;
				}
				this.textures[item.Group].Add (item.ID, item);
			}
		}

		public Material GetMaterial (FSHQFSGroup group, int textureID, RenderFlag renderFlag, bool saveToAssets, byte animInfo = 0xF9, int[] animFrameIDs = null) {

			FSHQFSItem textureItem = textures[group][textureID];

			if (!materials.ContainsKey (group)) {
				materials.Add (group, new Dictionary<int, Dictionary<RenderFlag, Material>> ());
			}

			if (!materials[group].ContainsKey (textureID)) {
				materials[group].Add (textureID, new Dictionary<RenderFlag, Material> ());
			}

			if (!materials[group][textureID].ContainsKey (renderFlag)) {
				Material m;
				//TODO: process all Texture information from FSHQFS Index file
				switch (renderPipeline) {
					case RenderPipeline.URP:
						if (textureItem.AdditionalData == FSHQFSExtraData.AdditiveTransparency) {
							m = new Material(ADDITIVE);
							m.SetFloat("_Intensity", 0.5f);
						} else {
							switch (textureItem.HasAlpha) {
								case true:
									if (renderFlag == RenderFlag.BothSided || renderFlag == RenderFlag.AnimatedBothSided) {
										m = new Material(CULLOFFCUTOUT);
									} else {
										m = new Material (CULLONCUTOUT);
									}
									// URP
									// according to BaseShaderGUI.cs and LitShader.cs
									m.SetOverrideTag("RenderType", "TransparentCutout");
									m.SetInt ("_SrcBlend",  (int) UnityEngine.Rendering.BlendMode.One);
									m.SetInt ("_DstBlend", (int) UnityEngine.Rendering.BlendMode.Zero);
									m.SetInt("_ZWrite", 1);
									m.EnableKeyword("_ALPHATEST_ON");
									m.DisableKeyword("_ALPHAPREMULTIPLY_ON");
									m.renderQueue = (int) RenderQueue.AlphaTest;
									m.SetShaderPassEnabled("ShadowCaster", true);
									m.SetFloat("_AlphaClip", 1.0f);
									m.SetFloat("_Surface", 0);
									m.SetFloat("_Blend", 0);
									m.SetFloat("_WorkflowMode", 1.0f);
									break;
								default:
									if (renderFlag == RenderFlag.BothSided || renderFlag == RenderFlag.AnimatedBothSided) {
										m = new Material(CULLOFFOPAQUE);
									} else {
										m = new Material (CULLONOPAQUE);
									}
									break;
							}
							m.SetFloat("_Smoothness", settings.materialGlossiness);
						}
						break;
					case RenderPipeline.HDRP:
						if (textureItem.AdditionalData == FSHQFSExtraData.AdditiveTransparency) {
							m = new Material(ADDITIVE);
							m.SetFloat("_Intensity", 0.5f);
						} else {
							switch (textureItem.HasAlpha) {
								case true:
									if (renderFlag == RenderFlag.BothSided || renderFlag == RenderFlag.AnimatedBothSided) {
										m = new Material(CULLOFFCUTOUT);
									} else {
										m = new Material (CULLONCUTOUT);
									}
									break;
								default:
									if (renderFlag == RenderFlag.BothSided || renderFlag == RenderFlag.AnimatedBothSided) {
										m = new Material(CULLOFFOPAQUE);
									} else {
										m = new Material (CULLONOPAQUE);
									}
									break;
							}
						}
						break;
					default:
						if (textureItem.AdditionalData == FSHQFSExtraData.AdditiveTransparency) {
							m = new Material(ADDITIVE);
							m.SetFloat("_Intensity", 0.5f);
						} else {
							switch (textureItem.HasAlpha) {
								case true:
									if (renderFlag == RenderFlag.BothSided || renderFlag == RenderFlag.AnimatedBothSided) {
										m = new Material(CULLOFFCUTOUT);
									} else {
										m = new Material (CULLONCUTOUT);
									}
									// setting rendering mode to Cut Out
									// according to https://github.com/jamesjlinden/unity-decompiled/blob/master/UnityEditor/UnityEditor/StandardShaderGUI.cs
									m.SetOverrideTag ("RenderType", "TransparentCutout");
									m.SetInt ("_SrcBlend", 1);
									m.SetInt ("_DstBlend", 0);
									m.SetInt ("_ZWrite", 1);
									m.EnableKeyword ("_ALPHATEST_ON");
									m.DisableKeyword ("_ALPHABLEND_ON");
									m.DisableKeyword ("_ALPHAPREMULTIPLY_ON");
									m.renderQueue = 2450;
									// to set the Render Mode to Cutout in the Inspector
									m.SetFloat ("_Mode", 1.0f);
									break;
								default:
									if (renderFlag == RenderFlag.BothSided || renderFlag == RenderFlag.AnimatedBothSided) {
										m = new Material(CULLOFFOPAQUE);
									} else {
										m = new Material (CULLONOPAQUE);
									}
									break;
							}
							m.SetFloat("_Glossiness", settings.materialGlossiness);
						}
						break;
				}

				// we want GI from both sides otherwise some strange artefacts occur in the lightmap
				m.doubleSidedGI = true;

				if (renderFlag == RenderFlag.AnimatedOneSided || renderFlag == RenderFlag.AnimatedBothSided) {
					// create tiled texture

					//extract animInfo. Bits LSB 2 - LSB 0: Number of Texture-Frames (numFrames) (this textures are stored sequentially in the TextureBlock-Array from FRD)
					// Bits LSB 7 - LSB 3 is the animationspeed (animSpeed) (display duration of one frame: 60/(animSpeed*numFrames))
					int animSpeed = (animInfo & 0x000000F8) >> 3;
					int numFrames = (animInfo & 0x00000007);

					// We use only the first frame as (size)-reference
					int height = textureItem.Height;
					int width = textureItem.Width;
					int tiledWidth = textureItem.Width * numFrames;

					Texture2D tiledTexture = new Texture2D (tiledWidth, height);

					for (int i = 0; i < numFrames; i++) {
						Texture2D frame = textures[group][animFrameIDs[i]].Texture;
						// all textures need to have the same size
						// all textures are scaled to the size of the first texture
						if (frame.width != width || frame.height != height) {
							TextureScale.Bilinear (frame, width, height);
						}
						tiledTexture.SetPixels (i * width, 0, width, height, frame.GetPixels ());
					}

					tiledTexture.Apply ();

					m.mainTexture = tiledTexture;
					
					#if UNITY_EDITOR
					if(saveToAssets)
						this.generatedObjects.Add(new GeneratedObject(tiledTexture, ObjectType.Texture, textureID + "_tiled.texture2d"));
					#endif

				} else {
					m.mainTexture = textureItem.Texture;
				}
				materials[group][textureID].Add (renderFlag, m);
			}

			#if UNITY_EDITOR
			GeneratedObject o = new GeneratedObject(materials[group][textureID][renderFlag], ObjectType.Material, group + "_" + textureID + "_" + renderFlag.ToString () + ".mat");
			if (!this.generatedObjects.Contains(o))
				this.generatedObjects.Add(o);
			#endif

			return materials[group][textureID][renderFlag];
		}
	}
}