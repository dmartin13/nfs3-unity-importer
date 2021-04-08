using UnityEngine;
using System;
using System.IO;
using NFS3Importer.Utility.B83.Image.BMP;
using NFS3Importer.Utility;
using NFS3Importer.UnityData;

namespace NFS3Importer.NFSData.FSHQFS {
	public static class TextureLoader {

		// this are the group identifiers in the FSH/QFS Index files
		private static readonly (string, FSHQFSGroup)[] GROUPNAMES = new (string, FSHQFSGroup)[] {
			("shad", FSHQFSGroup.SHAD),
			("spkb", FSHQFSGroup.SPKB),
			("fntc", FSHQFSGroup.FNTC),
			("mous", FSHQFSGroup.MOUS),
			("glw", FSHQFSGroup.GLW),
			("lin", FSHQFSGroup.Lanes),
			("skd", FSHQFSGroup.SKD),
			("SP", FSHQFSGroup.SP),
			("SL", FSHQFSGroup.SL),
			("c", FSHQFSGroup.C),
			("spk", FSHQFSGroup.SPK),
			("SN", FSHQFSGroup.SN),
			("CLDD", FSHQFSGroup.CloudsDay),
			("CLDN", FSHQFSGroup.CloudsNight),
			("CLWD", FSHQFSGroup.CloudsWeather),
			("CLWN", FSHQFSGroup.CloudsNightWeather),
			("SUND", FSHQFSGroup.SunDay),
			("SUNW", FSHQFSGroup.SunWeather),
			("CHNW", FSHQFSGroup.ReflectionNightWeather),
			("CHRD", FSHQFSGroup.ReflectionDay),
			("CHRN", FSHQFSGroup.ReflectionNight),
			("CHRW", FSHQFSGroup.ReflectionWeather),
			("SUNN", FSHQFSGroup.SunNight),
			("SNNW", FSHQFSGroup.SunNightWeather)
		};

		public static FSHQFSItem[] GetTextures (string path, bool ignoreGroups = false) {
			FSHQFSItem[] items;
			DirectoryInfo dir = new DirectoryInfo (path);
			FileInfo[] files = dir.GetFiles ("*.fsh");

			string[] lines = File.ReadAllLines (files[0].FullName);
			items = parseIndexFile (lines, path, ignoreGroups);

			return items;
		}

		private static FSHQFSItem[] parseIndexFile (string[] lines, string path, bool ignoreGroups) {

			// the first 3 lines are not relevant for us
			int currentLine = 3;
			// check for padding bytes
			currentLine = lines[currentLine].Contains ("!PAD") ? currentLine + 1 : currentLine;
			// Number of FSH Items
			int numItems = int.Parse (lines[currentLine++].Split (new char[] { ' ' })[1]);
			FSHQFSItem[] items = new FSHQFSItem[numItems];
			// the next 2 lines are not relevant for us
			currentLine += 2;
			// reading items
			for (int i = 0; i < numItems; i++) {
				items[i] = new FSHQFSItem ();

				// check for padding bytes
				currentLine = lines[currentLine].Contains ("!PAD") ? currentLine + 1 : currentLine;
				// ID and Filename
				string[] idAndMasterFilename = lines[currentLine++].Split (new char[] { ' ' });



				// If group = GLOBAL then sometimes the TextureIDs are displaced in the index.fsh file. 
				// 22.12.2020: But it seems that even NFS3 does not use the IDs inside the index.fsh.
				// It looks like NFS3 is using also sequential IDs as we do. So keep it as it is?
				if (ignoreGroups) {
					items[i].Group = FSHQFSGroup.GLOBAL;
					items[i].ID = i;
				} else {
					// try to identify group
					items[i].Group = getGroup (idAndMasterFilename[0]);
					items[i].ID = getID (idAndMasterFilename[0]);
				}

				// check for padding bytes
				currentLine = lines[currentLine].Contains ("!PAD") ? currentLine + 1 : currentLine;
				// Header
				string[] header = lines[currentLine++].Split (new string[] { " {" }, StringSplitOptions.None);
				string[] firstHeaderPart = header[0].Split (new char[] { ' ' });
				string secondHeaderPart = header[1];
				string headerType = firstHeaderPart[0];
				items[i].Header = firstHeaderPart[0];
				//EntryFormat
				items[i].EntryFormat = byte.Parse (firstHeaderPart[1], System.Globalization.NumberStyles.HexNumber);
				//NumAttachedDataChunks
				items[i].NumAttachedDataChunks = int.Parse (firstHeaderPart[2].Substring (1));
				//Width
				items[i].Width = int.Parse (firstHeaderPart[3]);
				//Height
				items[i].Height = int.Parse (firstHeaderPart[4]);

				//DisplayPosData
				string[] displayPosCords = secondHeaderPart.Trim (new char[] { '}' }).Split (new char[] { ' ' });
				items[i].DisplayPosData = new Vector4 (
					float.Parse (displayPosCords[0]),
					float.Parse (displayPosCords[1]),
					float.Parse (displayPosCords[2]),
					float.Parse (displayPosCords[3])
				);

				// check for padding bytes
				currentLine = lines[currentLine].Contains ("!PAD") ? currentLine + 1 : currentLine;

				if (items[i].EntryFormat == 0x60) {
					// DXT1 compressed

				} else if (items[i].EntryFormat == 0x61) {
					// DXT3 compressed (with alpha channel)
					items[i].AlphaFilename = Path.Combine (path, lines[currentLine++].Split (new char[] { ' ' })[1]);
					items[i].HasAlpha = true;

				} else if (items[i].EntryFormat == 0x6D) {
					// 16-bit 4:4:4:4 (with alpha channel)
					items[i].AlphaFilename = Path.Combine (path, lines[currentLine++].Split (new char[] { ' ' })[1]);
					items[i].HasAlpha = true;

				} else if (items[i].EntryFormat == 0x78) {
					// 16-bit 0:5:6:5


				} else if (items[i].EntryFormat == 0x7B) {
					// 8-bit (with palette)


				} else if (items[i].EntryFormat == 0x7D) {
					// 32-bit 8:8:8:8 (with alpha channel)
					items[i].AlphaFilename = Path.Combine (path, lines[currentLine++].Split (new char[] { ' ' })[1]);
					items[i].HasAlpha = true;

				} else if (items[i].EntryFormat == 0x7E) {
					// 16-bit 1:5:5:5 (with alpha channel)
					items[i].AlphaFilename = Path.Combine (path, lines[currentLine++].Split (new char[] { ' ' })[1]);
					items[i].HasAlpha = true;
				} else if (items[i].EntryFormat == 0x7F) {
					// 24-bit 0:8:8:8
					currentLine++;
				}

				// check for padding bytes
				currentLine = lines[currentLine].Contains ("!PAD") ? currentLine + 1 : currentLine;

				if (items[i].NumAttachedDataChunks <= 0) {
					items[i].AdditionalData = FSHQFSExtraData.None;
				} else {
					for (int j = 0; j < items[i].NumAttachedDataChunks; j++) {
						string[] additionalHeader = lines[currentLine++].Split (new char[] { ' ' });
						if (additionalHeader[0].Equals ("TXT")) {
							items[i].AdditionalData = parseAdditionalText (lines[currentLine++]);
						} else if (additionalHeader[0].Equals ("ETXT") && additionalHeader[1].Equals ("69")) {
							items[i].AdditionalData = parseAdditionalText (lines[currentLine++]);
						} else if (additionalHeader[0].Equals ("ETXT") && additionalHeader[1].Equals ("70")) {
							items[i].AdditionalData = parseAdditionalText (lines[currentLine++]);
						} else if (additionalHeader[0].Equals ("PAL")) {

						} else {
							items[i].AdditionalData = FSHQFSExtraData.Unknown;
						}
					}
				}

				// create Textures
				byte[] bmpFileData;
				bmpFileData = File.ReadAllBytes (Path.Combine (path, idAndMasterFilename[1]));
				BMPLoader bmpLoader = new BMPLoader ();
				//Load the BMP data
				BMPImage bmpImg = bmpLoader.LoadBMP (bmpFileData);

				//Convert the Color32 array into a Texture2D
				Texture2D tex = bmpImg.ToTexture2D ();

				// for clouds we want repeat-mode
				if(items[i].Group == FSHQFSGroup.CloudsDay ||
					items[i].Group == FSHQFSGroup.CloudsNight ||
					items[i].Group == FSHQFSGroup.CloudsWeather ||
					items[i].Group == FSHQFSGroup.CloudsNightWeather) {
						tex.wrapMode = TextureWrapMode.Repeat;
				} else {
					// setting Texture wrap mode to clamp in order to make transparency working correctly
					tex.wrapMode = TextureWrapMode.Clamp;
				}

				if (items[i].HasAlpha) {
					byte[] alphaFileData;
					alphaFileData = File.ReadAllBytes (items[i].AlphaFilename);
					//Load the ALPHA data
					BMPImage alphaImg = bmpLoader.LoadBMP (alphaFileData);

					transferAlpha (tex, alphaImg.ToTexture2D ());
				}

				items[i].Texture = tex;

				// create a normal-map and specular map from given texture
				// Texture2D filteredTex = NormalMapTools.FilterMedian(tex,5);
				// Texture2D normalTex = NormalMapTools.CreateNormalmap(filteredTex,6);
				// Texture2D specularTex = NormalMapTools.CreateSpecular(filteredTex,1.2f,0.5f);
				// items[i].NormalMap = normalTex;
				// items[i].SpecularMap = specularTex;

				//Testing
				//if (ignoreGroups)
				//	UnityEditor.AssetDatabase.CreateAsset (tex, Path.Combine (Importer.texturesFolder, i + ".texture2d"));
			}
			return items;
		}

		private static FSHQFSExtraData parseAdditionalText (string input) {
			string result = "";

			int i = 0;
			while (input[i] != '%' && i < input.Length) {
				result += input[i];
				i++;
			}
			if(result.Equals("<additive>")) {
				return FSHQFSExtraData.AdditiveTransparency;
			} else if (result.Equals("additive")){
				return FSHQFSExtraData.AdditiveOpaque;
			} else {
				return FSHQFSExtraData.Unknown;
			}
		}

		private static void transferAlpha (Texture2D a, Texture2D b) {
			Color pixA, pixB;
			for (int i = 0; i < a.width; i++) {
				for (int j = 0; j < a.height; j++) {
					// Read out pixel value at that location in both textures
					pixA = a.GetPixel (i, j);
					pixB = b.GetPixel (i, j);
					// Copy the alpha channel from B's pixel and assign it to A's pixel
					pixA.a = pixB.r;
					// Set the changed pixel back to A in that location
					a.SetPixel (i, j, pixA);
				}
			}
			// Apply the results
			a.Apply ();
		}

		private static FSHQFSGroup getGroup (string entryName) {
			foreach ((string, FSHQFSGroup) groupName in GROUPNAMES) {
				if (entryName.Contains (groupName.Item1)) {
					return groupName.Item2;
				}
			}
			return FSHQFSGroup.GLOBAL;
		}

		private static int getID (string entryName) {
			int index = 0;
			for (int i = 0; i < entryName.Length; i++) {
				// if the character is not a number between 0 and 9 go ahead
				if (entryName[i] < 0x30 || entryName[i] > 0x39) {
					index++;
				}
			}
			string subString = entryName.Substring (index);
			if (subString.Length == 0) {
				// there is no id
				return 0;
			}
			return int.Parse (entryName.Substring (index));
		}
	}
}
