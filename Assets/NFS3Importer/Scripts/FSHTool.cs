using System.IO;
using UnityEngine;
using NFS3Importer.Utility;

namespace NFS3Importer {
	public static class FSHTool {

		#if UNITY_EDITOR_LINUX
		public static string fshtoolPath = "Assets/NFS3Importer/Plugins/fshtool_linux_86_64";
		#endif

		#if UNITY_EDITOR_WIN
		public static string fshtoolPath = "Assets/NFS3Importer/Plugins/fshtool_win_86_64.exe";
		#endif

		#if UNITY_EDITOR_OSX
		public static string fshtoolPath = "Assets/NFS3Importer/Plugins/fshtool_macos_86_64";
		#endif

		/*
		[DllImport ("fshtool")]
		private static extern int uncompress ([MarshalAs (UnmanagedType.LPStr)] string filename, [MarshalAs (UnmanagedType.LPStr)] string outputpath, out IntPtr log);
		[DllImport ("fshtool")]
		private static extern int compress ([MarshalAs (UnmanagedType.LPStr)] string indexfile, [MarshalAs (UnmanagedType.LPStr)] string outputfile, out IntPtr log);
		*/

		/*
		[DllImport ("fshtool")]
		private static extern int uncompress ([MarshalAs (UnmanagedType.LPStr)] string filename, [MarshalAs (UnmanagedType.LPStr)] string outputpath);
		*/

		/*
		/// <summary>
		/// Uncompress the specified filename and outputpath.
		/// </summary>
		/// <returns>The decompress.</returns>
		/// <param name="filename">Filename.</param>
		/// <param name="outputpath">Outputpath.</param>
		public static bool Decompress (string inputFile, string outputDir) {
			string wd = Environment.CurrentDirectory;
			int result;
			//IntPtr log;
			//result = uncompress (inputFile, outputDir, out log);
			result = uncompress (inputFile, outputDir);
			Environment.CurrentDirectory = wd;
			return result == 0;
		}

		*/

		/*

		/// <summary>
		/// Compress the specified indexfile and outputfile.
		/// </summary>
		/// <returns>The compress.</returns>
		/// <param name="indexfile">Indexfile.</param>
		/// <param name="outputfile">Outputfile.</param>
		public static bool Compress (string indexFile, string outputFile) {
			string wd = Environment.CurrentDirectory;
			int result;
			IntPtr log;
			result = compress (indexFile, outputFile, out log);
			Environment.CurrentDirectory = wd;
			return result == 1;
		}

		*/


		/// <summary>
		/// Uncompress the specified inputFile and outputDir.
		/// </summary>
		/// <returns>The uncompress.</returns>
		/// <param name="inputFile">Input file.</param>
		/// <param name="outputDir">Output dir.</param>
		public static bool Decompress (string inputFile, string outputDir) {
			if (!inputFile.ContainsCaseInsensitive ("QFS") && !inputFile.ContainsCaseInsensitive ("FSH")) {
				Debug.LogError ("Only .QFS and .FSH files can be decompressed");
				return false;
			}
			return runFSHTool (new string[] { inputFile, outputDir });
		}


		/// <summary>
		/// Compress the specified indexFile and outputFile.
		/// </summary>
		/// <returns>The compress.</returns>
		/// <param name="indexFile">Index file.</param>
		/// <param name="outputFile">Output file.</param>
		public static bool Compress (string indexFile, string outputFile) {
			if (!indexFile.ContainsCaseInsensitive ("INDEX.FSH")) {
				Debug.LogError ("Make sure to specify a valid \"INDEX.FSH\"");
				return false;
			}
			if (!outputFile.ContainsCaseInsensitive ("QFS") && !outputFile.ContainsCaseInsensitive ("FSH")) {
				Debug.LogError ("Please specify a .QFS or .FSH file as output");
				return false;
			}
			return runFSHTool (new string[] { indexFile, outputFile });
		}

		private static bool runFSHTool (string[] args) {
			using (System.Diagnostics.Process process = new System.Diagnostics.Process ()) {
				process.StartInfo.FileName = fshtoolPath;
				process.StartInfo.WindowStyle = System.Diagnostics.ProcessWindowStyle.Hidden;
				process.StartInfo.UseShellExecute = false;
				process.StartInfo.RedirectStandardOutput = true;
				process.StartInfo.Arguments = string.Join (" ", args);
				process.Start ();

				// Synchronously read the standard output of the spawned process. 
				StreamReader reader = process.StandardOutput;
				string output = reader.ReadToEnd ();

				// Write the redirected output to this application's window.
				Debug.Log (output);

				process.WaitForExit ();
				return process.ExitCode == 0;
			}
		}
	}
}