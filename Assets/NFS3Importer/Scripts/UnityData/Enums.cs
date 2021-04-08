namespace NFS3Importer.UnityData {

	public enum EntityType {
		BLOCK,
		LANE,
		POLYOBJ,
		XOBJ,
		COLLIDER,
		BLOCKEXTRAS
	}

	public enum RenderFlag {
		//// the corresponding char values of the FRD in hexadecimals
		//// 0x00 the same as 0x40?
		//Normal = 0x00,
		//// Corresponding Animdata has to be used for flow-speed values etc.
		//AnimatedOneSided = 0x04,
		//AnimatedBothSided = 0x14,
		//BothSidedOpaque = 0x10,
		//OneSidedCutOff = 0x20,
		//BothSidedCutOff = 0x30,
		//OneSidedOpaque = 0x40

		// the corresponding char values of the FRD in hexadecimals
		// 0x00 the same as 0x40?
		// Corresponding Animdata has to be used for flow-speed values etc.
		AnimatedOneSided, //0x04
		AnimatedBothSided, //0x14
		BothSided, // 0x10, 0x30
		OneSided // 0x00, 0x40
	}

	public enum FSHQFSExtraData {
		//<additive> in FSH/QFS Index file
		AdditiveTransparency,
		//additive  in FSH/QFS Index file
		AdditiveOpaque,
		Unknown,
		None
	}

	public enum FSHQFSGroup {
		GLOBAL,
		Lanes,
		SHAD,
		SPKB,
		FNTC,
		MOUS,
		GLW,
		SKD,
		SP,
		SL,
		C,
		SPK,
		SN,
		CloudsDay,
		CloudsNight,
		CloudsWeather,
		CloudsNightWeather,
		SunDay,
		SunWeather,
		ReflectionNightWeather,
		ReflectionDay,
		ReflectionNight,
		ReflectionWeather,
		SunNight,
		SunNightWeather,
		OTHER
	}

	// CollideEffect
	public enum XObjectCollideEffect {
		Nothing = 0,
		Solid = 1,
		HitAndFall = 2,
		DriveThroughWithSound = 3
	}

	// Crosstype
	public enum XObjectType {
		Global,
		Simple,
		Animated,
		Collision
	}

	public enum RenderPipeline {
		Legacy,
		URP,
		HDRP
	}

	public enum ObjectType {
		Model,
		Collider,
		Texture,
		Material,
		Animation,
		Sound,
		Scene,
		Prefab,
		WeatherAsset
	}

	public enum LOD {
		LowRes,
		MidRes,
		HighRes
	}
}
