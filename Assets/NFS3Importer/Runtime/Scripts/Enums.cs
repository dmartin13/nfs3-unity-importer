namespace NFS3Importer.Runtime {
    
    	public enum SurfaceFlag {
		//Not passable inner
		NoDriveSurface,
		PavedSurface,
		GravelSurface,
		GrassSurface,
		LeavesSurface,
		DirtSurface,
		WaterSurface,
		WoodSurface,
		IceSurface,
		SnowSurface,
		PavedShoulder,
		LeavesShoulder,
		WoodShoulder,
		DirtShoulder,
		//Not passable outer
		SimNullSurface,
		SnowShoulder
	}

    public enum WeatherType {
		Day,
		Weather,
		Night,
		NightWeather
	}

	public enum WeatherEffect {
		None,
		Rain,
		Snow
	}
}