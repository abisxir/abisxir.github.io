import alasgar

import stage
import pig

# Exists when ESC is pressed
settings.exitOnEsc = true

# Creates a window named Hello
window("Demo", 1920, 1080)
   
let 
    # Creates a new scene
    scene = newScene()
    # Creates camera entity
    cameraEntity = newEntity(scene, "Camera")

# Sets background color
scene.background = parseHex("827972")
scene.fogDensity = 0.0
#scene.fogMinDistance = 10.0
scene.ambient = parseHex("ffffff") * 1.0

# Sets camera position
cameraEntity.transform.position = vec3(7, 6, 10)
# Adds a perspective camera component to entity
add(
    cameraEntity, 
    #newOrthoCamera(
    #    -10, 
    #    10, 
    #    -10, 
    #    10, 
    #    0.1, 
    #    100.0, 
    #    vec3(0) - cameraEntity.transform.position
    #)
    newPerspectiveCamera(
        45, 
        runtime.ratio, 
        0.1, 
        100.0, 
        vec3(0) - cameraEntity.transform.position
    )
)
addCameraController(cameraEntity, phi=0.5, distance=20.0)
# Makes the camera entity child of the scene
add(scene, cameraEntity)

# Loads model from file
let 
    stage1 = createStage(scene, 32, 12)
    #model = load("res://gltf/Knight.glb")
    #knight = toEntity(model, scene)

for i in 1..10:
    add(
        stage1, 
        createPig(
            scene, 
            stage1[StageComponent], 
            (rand(32), rand(32))
        )
    )

add(scene, stage1)
#addChild(stage1, knight)


# Renders the scene
render(scene)
# Runs game main loop
loop()

