# Need For Speed III - Unity Importer

![Overview](http://files.fotomartin.eu/nfsimporter/images/overview.png "Overview")

**Important notes**:

* if you are not a developer and just want to use the tool, then you do not need to clone this repository. All you have to do is download the following package and import it into Unity

| NFS3Importer |
| ------ |
| [Download NFS3Importer Package](https://drive.google.com/file/d/1iN68UD8v4eq7ZVNcQsg2BDY9Hvg2vg2q/view) |

* It is important that the importer is located in the project under Assets/NFS3Importer, as there are dependencies in the code. However, this path is set by default when importing
* If you do not use the Universal Render Pipeline, but the Legacy Render Pipeline, errors will appear when importing the package because the URP shaders cannot be compiled. However, these errors can simply be ignored, since in this case they are not used by the importer.
* The latest release was created and tested with Unity 2020.3.3f1 LTS. All original tracks from NFS3 can be imported. However, since the importer makes some assumptions that the original tracks adhere to, but do not necessarily have to be, modified tracks can cause errors during the import.

## What is Need For Speed III - Unity Importer

The Need For Speed III Unity Importer is an editor plug-in for the Unity Engine to import race tracks from the computer game Need For Speed III Hot Pursuite. All files are converted into "Unity-understandable" files so that the track can be edited inside the Unity Editor. For each imported track, a scene is created with all track contents. The tool works on Linux, Windows, MacOS. It supports the legacy render pipeline (built-in) and the universal render pipeline (URP).

**Special Thanks:**

* Denis Auroux (T3D, fshtool) (<http://www.math.polytechnique.fr/cmat/auroux/nfs/>)
* Amrik Sadhra ([OpenNFS](https://github.com/OpenNFS/OpenNFS))
* Justin Hawkins, David Sehnal, Matthew Campbell ([Hull-Delaunay-Voronoi for Unity3D](https://github.com/Scrawk/Hull-Delaunay-Voronoi))

Without the work of others, this project would not have been possible for me. I got the main information from the source code of the T3D tool from Denis Auroux. I got some information about the street lights and animated textures from the OpenNFS project, which by the way is a very interesting project :)

**[Video Collection Of Imported Tracks](https://youtu.be/M0tAuKIhzHw)**

## What is Need For Speed 3 - Unity Importer NOT

This tool is only a track importer... no music, no cars (maybe i will add this in the future but i have no plans for that)

## Features

* Supports Legacy Renderpipeline (Built-In), Universal Render-Pipeline (URP)
* Import of complete track-geometry with all textures
* Import of all objects along the track
* supports animated objects (train, aircraft, zeppelin, ...)
* supports animated textures (e.g. rivers)
* supports destroyable objects (roadsigns, fences, ...)
* Accurate creation of track colliders
* Import of all lights (static lights, blinking lights)
* Import of "Virtual Road Points" (for position detection along the track)
* Own shaders for skybox and for additive textures (e.g. lightbeams)
* almost complete parsing of HRZ-files
* creation of easily configurable weather-objects that can be assigned to the track
* ready for light-baking after import
* mesh optimization (recalculation of normals to make a smoother look)
* automated lightprobe creation
* Runtime-Scripts:
  * Accurate positiondetection (also support for abbreviations) along track based on a Voronoi-Diagram
  * Dynamic Fog script per camera to support fog-regions from HRZ-files
  * Dynamic Weather effects (rain, snow, lightning) with parsed information from HRZ-Files
  * Script for playing sounds on objects that have a sound attached (bushes, church, farm, ...) [Note: Import of sound-effects is not yet supported, but you can assign your own sounds]

## Quick Start (for users)

### Import Tracks

**[Quick Start Video](https://youtu.be/UEzAoHOXvJY)**

* Import **[NFS3Importer.unitypackage](https://drive.google.com/file/d/1iN68UD8v4eq7ZVNcQsg2BDY9Hvg2vg2q/view)** into your project.
  * It is important that the importer is located in the project under Assets/NFS3Importer, as there are dependencies in the code. However, this path is set by default when importing
  * If you do not use the Universal Render Pipeline, but the Legacy Render Pipeline, errors will appear when importing the package because the URP shaders cannot be compiled. Example: ```Shader error in 'NFS3Importer/URP/Additive': failed to open source file: 'Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl' at line 71 (on glcore)``` However, these errors can simply be ignored, since in this case they are not used by the importer.
* Go to **Window** -> **NFS3 Track Importer** and drag the new window wherever you want.
* Click **Select Path** and choose the root directory of your NFS3 CD or NFS3 directory on your hard drive.
* Click **Scan Directory**
* Choose the tracks you want to import
* Click on **Import Tracks**
* **CAUTION**: One Track needs up to 10 or 15 Minutes to import and there is no progress bar or something else... stay patient

### After Import

The last imported track is directly loaded as new scene in the Editor Hierachy. Each track consists of several blocks that correspond to those of the NFS files. Each block in turn has its own sub-objects.

![Hierarchy](http://files.fotomartin.eu/nfsimporter/images/hierarchy0.png "Hierarchy")

**Object types:**

* **Block**: The blocks store the main geometry of a track section. So this is the road itself and the surrounding landscape. Each block has a mesh collider so that cars can drive on it and collide with the walls. Furthermore, every block has a surface script, which is later used by the runtime script **SurfaceDetector** to determine the current subsurface under the car
* **Lane**: Lanes are the road markings
* **BlockExtra**: Additional objects such as fences are saved here
* **Object**: These are normal objects that have no collider or any other special function. E.g. trees
* **XObject**: This object has some special function. There are e.g. objects that you can destroy (street signs, fences, ...) or objects that play a sound when you drive through (bushes). The colliders for XObjects are specially calculated by the importer. These are BoxColliders, which, compared to MeshColliders, are significantly more efficient in terms of performance. And the accuracy of MeshCollider is not absolutely necessary here.\
  ![Roadsign](http://files.fotomartin.eu/nfsimporter/images/roadsign.png "Roadsign")
  * **Destroyable objects**: So-called joints are added to every destructible object, which break if you hit them with a certain force. In addition, a rigidbody component and the HitAndFallObject script are added to the script. The HitAndFallObject script saves the weight of the object
  * **Objects playing a sound**: The script DriveThroughWithSound is attached to this object, which plays a sound when a threshold is exceeded when you drive through. Since I was unfortunately not yet able to decode the sounds, the field for the audio clip in this script is empty. But of course you can add your own sound files.
* **Sound**: Sound objects have no geometry, but you can save a sound that is played under certain conditions. Since I was unfortunately not yet able to decode the sounds, the field for the audio clip in this script is empty. But of course you can add your own sound files. All you have to do is write a script that plays the sound in the way you want

For each track, the VirtualRoadPoints from Need For Speed are also imported, which are used, for example, for position detection. The importer places them as independent objects in the hierarchy so that they can easily be used in other objects later.

![Hierarchy](http://files.fotomartin.eu/nfsimporter/images/hierarchy1.png "Hierarchy")

The importer automatically creates lightprobes (described in more detail below), which are also created in the hierarchy

![Hierarchy](http://files.fotomartin.eu/nfsimporter/images/hierarchy2.png "Hierarchy")

A global NFSTrackSettings object is also created for each track, which is used by many runtime scripts. This object stores e.g. a reference to all virtual road points. It also includes the weather object. If you program your own logic and need access to the virtual road points, you should take them from this object. Since this object is a singleton, there can only be one object of this type in the scene and all other scripts can rely on only this one unique instance.

![Hierarchy](http://files.fotomartin.eu/nfsimporter/images/hierarchy3.png "Hierarchy")

The tracks are saved under Assets/NFS3Tracks/[NAME_OF_THE_TRACK]

Each track has folders for 3D models, Colliders, Textures, Materials, Scenes, Animations, Sounds

The Scenes folder contains also 4 configurable weather objects

![Project Hierarchy](http://files.fotomartin.eu/nfsimporter/images/projecthierarchy0.png "Project Hierarchy")

After import there are several possibilities:

1. use the imported tracks inside this project (see below)
2. export imported tracks for use in other projects (see below)

#### Export & Import

##### Export Tracks for use in other Projects

Export of tracks for use in other projects can be done in seconds. The only thing to watch out for is that the render pipeline has to match. You cannot use a track that was imported with the Legacy RP in a project with the URP or vice versa

* If you want to export tracks so they can be used in other projects you have to go to the project hierarchy.
* Right Click on the track folder ( e.g. Assets/NFS3Tracks/Hometown) -> Export Package
* **IMPORTANT**: Do not include any dependencies (include dependencies is the default... so deselect that)
* Choose name and location and save

##### Import Tracks in other Projects

* Open your Project
* Import the **[NFS3ImporterRE.unitypackage](https://drive.google.com/file/d/1E6wCnp6UDTbruaDD5BnaGUu4CJj-2QAe/view)**
* Import your track package
* That's it

#### Use in Project

##### Remove Importer if you are done

If you are done with importing you can remove all files and directories inside Assets/NFS3Importer except the folder "**Runtime**"

#### Change the weather

* Drag&Drop your desired weather from Assets/NFS3Tracks/[NAMEOFTHETRACK]/Scenes/[WEATHER] to the "Weather" Slot of "NFS3Importer.Runtime.NFSTrackSettings (Singleton)" object in your scene\
  ![Track Settings](http://files.fotomartin.eu/nfsimporter/images/projecthierarchy0.png "Track Settings")
* The weather will be loaded and updated automatically
* If you want to edit the weatherobjects themself simply select them and edit them in the inspector
* You can also create new weatherobjects: Right click in the projects browser -> Create -> NFS3Importer -> Weather

#### Bake Lightmap

The scene is optimized for baking a lightmap with Mixed Mode (Shadowmask in Legacy RP, Subtractive in URP) (<https://docs.unity3d.com/Manual/LightMode-Mixed.html>)

* Go to Lighting-Tab or open it from Window -> Rendering -> Lighting
* Create a new Lighting Settings Object
* Change Lighting Mode to Shadowmask (Legacy RP) or Subtractive (URP)
* Adjust Parameters: CAUTION: Baking can take a very long time and consume a lot of RAM (up to 60 GB or more) if you use "wrong" parameters. Here are some values that i use:
  * I prefer the GPU Lightmapper (much faster than CPU even with a NVIDIA 1050TI)
  * Direct Samples: 8
  * Indirect Samples: 128
  * Environment Samples: 64
  * Lightprobe Samples: 2
  * Lightmap Resolution: 16
  * Max Lightmap Size: 256
  * Ambient Occlusion with default settings
* Click Generate Lighting
* Depending on your hardware this can take a bit (GTX 1050TI \~ 40 mins per track, CPU \~ multiple hours :D)

#### Runtime scripts

I have created some scripts that can be used to easily create some game logic

* **Progress Tracker**: Assign this script to your car and it will automatically detect the current Position (index of Virtual Road Point) along the track.
  * This script is very efficient at runtime as it doesn't check every waypoint to see which is the nearest. The basic concept behind the whole is the calculation of all possible neighboring points of one point with the help of a voronoi diagram while the track is being imported. At runtime, starting from the current waypoint, only the possible neighbors are checked. (Constant runtime, even with thousands of points)
  * **this script is a prerequisite for the scripts "dynamic weather effect" and "dynamic fog" as they need the current position along the track**
  * The script has a public variable: `public VRoadPoint CurrentPoint` with which you have access to the waypoint that is currently closest
* **Dynamic Fog**: Add this script to a camera. This script changes the fog along the route based on the values ​​in the weather objects (requires **Progress Tracker** in a parent's object)
* **Dynamic Weather Effect**: Add this script to a camera. This script changes the weather along the route based on the values ​​in the weather objects (rain effect, snow effect, lightning). (requires **Progress Tracker** in a parent's object)
* **Surface Detector**: This script recognizes the current surface under the car (wood, grass, asphalt, ...). Add this script to your car object.

## FAQ

TBD

## Troubleshooting

* Collider issues (very rare)
  * **Solution**: manually edit the collider meshes
* Darkness in tunnels
  * **Solution**: simply add some lights or adjust the settings for lightbaking
* NullReferenceException because TrackSettings-Instance is destroyed during Import
  * **Solution**: Remove the partly imported Scene, delete the folder containing the track. Quit Unity and start it again. Try again. Now it should work.

## More Details (for users)

### Importer Settings

The importer settings allow you to adjust certain parameters that are used during import. The values ​​of the standard settings are preselected by me and produce good results in most cases. However, you may want to adjust certain values ​​to your requirements

![Importer Settings](http://files.fotomartin.eu/nfsimporter/images/importersettings.png "Importer Settings")

* **Level Of Detail**: Just use High Res and avoid Mid Res and Low Res. Background: Need for Speed ​​saves the track geometry in 3 different quality levels. Higher quality levels are loaded dynamically in Need for Speed ​​the closer you are to a certain object. This concept is called LOD (Level Of Detail) in game development and enables performance improvements, since objects that are further away do not have to be displayed in great detail. Since Need For Speed ​​is a very old game, the highest quality level is no longer a problem for modern hardware and you can always choose high quality without hesitation. Attention: With Low Res and Mid Res there are problems with the UV coordinates of the textures
* **Gouraud Angle**: To make the geometry smoother, the importer recalculates the normal vectors. A very simple process is used here, which is called Gouraud Shading (<https://en.wikipedia.org/wiki/Gouraud_shading>). Here the arithmetic mean of all normal vectors of faces that have a common point is calculated. In some cases, however, you want to make a hard edge visible. This is usually the case when the angle between two surfaces is very large. With this parameter you can set the threshold, as it were, from which edges should be hard to see. A common value for this is 60 °
* **UV Margin**: This value is only of interest to lightmap baking. The lightmapper in Unity uses extra UV coordinates, which are saved in the second UV channel of an object. Fortunately, there is a function of the Unity Engine that automatically calculates these UV coordinates, so that I could save myself this work :). If the UV coordinates are too close to each other, depending on the resolution used for the lightmap, problems can arise in the form of strange appearances on the surfaces of objects. To counteract this problem, you can specify here how much space should be between the UV coordinates of faces. 0.07 is a good value for this, but if too many warnings about overlapping UV coordinates should appear in the console after the import, you can try increasing this value. But be careful: a value that is too high has an impact on the quality of the lightmap
* **Light Multiplier**: The light intensities that Need for Speed ​​uses are a bit too weak for the Unity Engine. This value is a simple linear factor that scales the value of Need for Speed
* **Lights Have Flare**: This function is currently not supported and has no effect. It will later be determined here whether or not lights cause lens flare
* **Flare Size**: Is also not yet implemented. But I think this value is self-explanatory
* **Light Probe Height**: The importer automatically creates light probes (<https://docs.unity3d.com/Manual/LightProbes.html>) along the route. At the level of the route for the defined virtual roadpoints, 3 lightprobes are created and, in parallel, 3 lightprobes a little higher up. This value defines this height.\
  ![Lightptobes](http://files.fotomartin.eu/nfsimporter/images/lightprobes.png "Lightptobes")
* **Lightprobe Spacing**: This value determines after how many virtual road points a light probe should be created again.
* **Light Probe Margin**: This value determines a small distance between the route geometry and the light probe in order to avoid incorrect results. If the light probe were directly on the street, it could also use the light below the street as a value, which we don't want
* **Rain Effect**: Here you can add your own rain effect (prefab). It's best to have a look at how the standard effects are set up by me
* **Snow Effect**: Just like with the rain effect
* **Lightning Effect**: Just like with the rain effect
* **Lightning Height**: This value determines in which height the lightning has to be generated later during runtime
* **Hit And Fall Mass**: This value is a fake value for the mass of objects that can fall over. The problem with Unity is that objects that are too light compared to the weight of the car create strange behavior. The objects then behave like a rubber ball or something like that: D. Therefore this value should have about the same weight as the cars
* **Hit And Fall Break Force**: The force which is necessary to break an object.
* **Hit And Fall Real Mass**: As soon as an object falls over, the fake weight is replaced by this value. So that, for example, street signs do not weigh 1000 kg, but only 50
* **Collider Height**: This value determines the height of the collider walls created by the importer\
  ![Collider Walls](http://files.fotomartin.eu/nfsimporter/images/colliderwalls0.png "Collider Walls")
* **Material Glossiness**: The standard shader of the respective render pipeline is used for all objects in the route. This value determines the glossiness of the material. Usually you want a matte look

### Skybox Shaders

All values for the Shader are automatically calculated by the importer and have their origin in the weather files (HRZ files) of Need For Speed. However, you can of course adjust the values a little and also create a skybox. Therefore, here is a brief explanation of the values

![Shader Settings](http://files.fotomartin.eu/nfsimporter/images/shadersettings.png "Shader Settings")

In general, it should be said that it is probably best if you just try something around with the values.

* **SkyColor, HorizonColor, GroundColor**: I think these values are self-explanatory
* **HorizonSharpnessSky**: With this value you can specify how soft or hard the transition between the SkyColor and the HorizonColor should be
* **HorizonSharpnessGround**: With this value you can specify how soft or hard the transition between the GroundColor and the HorizonColor should be
* **AmbientColorSunSide**: This color is drawn on the horizon of the sunny side. This allows you to make the skybox look a little more natural, as the sun often shines a little on the dunst.
* **AmbientColorSunOpposite:** Just like with AmbientColorSunSide, only on the other side
* **AmbientColorSharpness**: This value again indicates how hard or soft the transitions between the colors should be
* **HorizonOffset**: With this value you can shift the horizon up or down a little
* **SkyIntensity**: This value indicates the contrast of the sky
* **SunRadius**, **SunFalloff:** These values can be used to set the size of the sun and the sunshine
* **SunIntensity**: I think this value is self-explanatory
* **CloudsTexture**: I think this value is self-explanatory
* **AdditiveOrBlendClouds**: With this value you can set how the shader should render the clouds. Additive means that the shader adds the texture to the sky, so to speak. In the blend mode, the cloud texture is mixed with the sky using the alpha values. *No tick: additives, tick: blend*
* **CloudsTiling**: With this value you can set how often the texture should be repeated in the sky. So you can adjust the size of the clouds
* **CloudsFarTiling**: This value determines the tiling of the clouds in the distance. You can use this value especially to simulate a kind of dome
* **CloudsOffset**: This value can be used to define an offset in the x and y directions. The z component is not used. This vector is actually only used at runtime by a script that simulates cloud movement
* **CloudsBrightness**: I think this value is self-explanatory
* **CloudsContranst**: I think this value is self-explanatory
* **CloudsColor:** I think this value is self-explanatory
* **CloudsCutoff**: With this value you can set the height from which the clouds should appear
* **CloudsFalloff**: With this value you can set how soft or hard the transition should be where the clouds begin
* **CloudsOpacity**: I think this value is self-explanatory
* **CloudsHaveFog**: With this option you can choose whether the clouds should be influenced by the fog
* **PixMap**: Here you can choose a texture for the horizon. \
  **Attention: The texture should have a transparent border at least 2 pixels wide at the top and bottom, otherwise weird artifacts will occur**. \
  Need for Speed's pixmaps are automatically created with such a border by the importer.
* **PixMapColor**: think this value is self-explanatory
* **PixMapOffset**: With this value you can set a vertical offset
* **PixMapTilingV**: With this value you can set how high the texture should be
* **PixMapTilingU**: With this value you can set how often the texture should be repeated around the horizon (horizontal)
* **FogIntensityOnSkybox**: With this value you can set how the pixmap should be influenced by the fog

**Side note**: The shaders for the legacy render pipeline were created with ShaderForge (1.40) (<https://acegikmo.com/shaderforge/>) and can therefore also be edited. I left the necessary meta data for this in the shader. I created the shaders for the universal render pipeline with Shadergraph. They can also be edited with Shadergraph.

### Lightprobes

As already mentioned above, the importer automatically creates light probes along the route. These are useful to store light information from light rays in the air and are later used for non-static objects (e.g. cars) to improve performance. However, the algorithm for creating the light probes is very simple and sometimes creates light probes where they shouldn't be. Let's take a tunnel as an example: 3 Lightprobes are created directly above the street (**Light Probe Margin**) and then 3 are created a few meters higher (**Light Probe Height**) in parallel. Now it is possible that the higher light probes are above the tunnel ceiling and thus store incorrect light information. In a nutshell, you can say that the automatic creation saves a lot of work, but you have to manually adjust the lightprobes again at certain points so that they really are where they should be.

### Colliders

The colliders for the route are created automatically by the importer. However, it has to be said that it is a bit difficult to get the collider information from Need For Speed into the Unity Engine. This is because, unlike Unity, Need For Speed does not use colliders, but saves for each polygon whether it is passable or not. Nevertheless, I have developed an algorithm that covers almost all cases. It can of course still be the case that the collider does not quite fit in some places. You then have to readjust manually here. Here are a few examples of what the importer can do and where problems can arise:

Automatic height adjustment if e.g. a bridge is over the road.

![Collider Walls](http://files.fotomartin.eu/nfsimporter/images/colliderwalls1.png "Collider Walls")

Automatic detection of such constructs, so that no collider walls are created where none should be.

![Collider Walls](http://files.fotomartin.eu/nfsimporter/images/colliderwalls2.png "Collider Walls")

Abbreviations can sometimes cause problems

![Collider Walls](http://files.fotomartin.eu/nfsimporter/images/colliderwalls3.png "Collider Walls")

## Documentation for Developers

TBD

## Known Issues

* Some interactive objects (roadsigns, fences, ...) have flipped textures
* Light is bleeding through edges in tunnels

## Planed for Future

* Light flares
* Support of CAN files (camera animations)
* (maybe Support of HDRP)
