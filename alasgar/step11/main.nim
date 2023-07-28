import alasgar

# Creates a window named Hello
window("Step10", 830, 415)
   
let 
    # Creates a new scene
    scene = newScene()
    # Creates an environment component
    env = newEnvironmentComponent()
    # Creates camera entity
    cameraEntity = newEntity(scene, "Camera")

# Sets skybox, uses a panaorama image here
setSkybox(env, "res://skybox.jpeg", 512)
# Sets ambient light color and intensity
setAmbient(env, parseHtmlName("White"), 1.0)
# Adds environment component to scene
addComponent(scene, env)

# Sets camera position
cameraEntity.transform.position = vec3(5, 5, 5)
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
# Adds orbital camera controller to camera entity
addCameraController(cameraEntity)
# Makes the camera entity child of the scene
addChild(scene, cameraEntity)

let 
    # Loads external model
    model = load("res://DamagedHelmet.gltf")
    # Creates an entity out of loaded model, it will take care of textures, animations, and so on.
    helmetEntity = toEntity(model, scene)
helmetEntity.transform.scale = vec3(4)
# Adds helmet as scene child
addChild(scene, helmetEntity)

# Renders the scene
render(scene)
# Runs game main loop
loop()

