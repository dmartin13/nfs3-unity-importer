
namespace NFS3Importer.NFSData.FRD {
	public class TextureBlock {
		public short Width { get; set; }

		public short Height { get; set; }

		public int Unknown1 { get; set; }

		// 4 x Vector2 (v1,v2,v3,v4)
		public float[] UVCoords { get; set; }

		public int Unknown2 { get; set; }

		public byte IsLane { get; set; }

		public short Texture { get; set; }
	}
}
