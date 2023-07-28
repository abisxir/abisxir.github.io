# Model Information:
# * title:	Pokemon RSE - Pokemon Center
# * source:	https://sketchfab.com/3d-models/pokemon-rse-pokemon-center-ae2858d8d212406ebe95927d4f17d328
# * author:	Wesai (https://sketchfab.com/Wesai)
# Model License:
# * license type:	CC-BY-4.0 (http://creativecommons.org/licenses/by/4.0/)
# * requirements:	Author must be credited. Commercial use is allowed.

# Model Information:
# * title:	Robot RoCKet
# * source:	https://sketchfab.com/3d-models/robot-rocket-f04d70f5a38943098da45f76e7ebb238
# * author:	TeKen_art30 (https://sketchfab.com/ken_art30)
# Model License:
# * license type:	CC-BY-4.0 (http://creativecommons.org/licenses/by/4.0/)
# * requirements:	Author must be credited. Commercial use is allowed.

import alasgar

# Creates a window named Hello
window("Demo", 830, 415)
   
let 
    # Creates a new scene
    scene = newScene()
    # Creates an environment component
    env = newEnvironmentComponent()
    # Creates camera entity
    cameraEntity = newEntity(scene, "Camera")

# Sets background color
setBackground(env, parseHex("d7d1bf"))
setAmbient(env, parseHex("ffffff"), 1.0)
# Adds environment component to scene
addComponent(scene, env)

# Sets camera position
cameraEntity.transform.position = vec3(7, 6, 10)
# Adds a perspective camera component to entity
addComponent(
    cameraEntity, 
    newPerspectiveCamera(
        75, 
        runtime.ratio, 
        0.1, 
        100.0, 
        vec3(0) - cameraEntity.transform.position
    )
)
#addCameraController(cameraEntity)
# Makes the camera entity child of the scene
addChild(scene, cameraEntity)

# Loads model from file
let 
    room = newEntity(scene, "Room")
    pokemon = toEntity(load("res://pokemon/scene.gltf"), scene, castShadow=false, rootName="Pokemon")

pokemon.transform.scale = vec3(20)
addChild(room, pokemon)

addChild(scene, room)

# Renders the scene
render(scene)
# Runs game main loop
loop()

