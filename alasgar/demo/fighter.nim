import alasgar


proc createPlatform(scene: Scene, position, scale: Vec3): Entity =
    let platform = newEntity(scene, "Platform")
    add(platform, newCubeMesh())
    add(scene, platform)
    platform.transform.scale = scale
    platform.transform.position = position


# Creates a window named Step10
window("Fighter", 830, 830)
settings.exitOnEsc = true
   
let 
    # Creates a new scene
    scene = newScene()
    # Creates the camera entity
    cameraEntity = newEntity(scene, "Camera")

# Sets the background color
scene.background = parseHex("d7d1bf")
# Sets fog desnity to enable fog, fancy effect :)
scene.fogDensity = 0.05

# Sets the camera position
cameraEntity.transform.position = vec3(0.0, 5.0, 0.1)
# Adds a perspective camera component to entity
add(
    cameraEntity, 
    newPerspectiveCamera(
        75, 
        runtime.ratio, 
        0.1, 
        100.0, 
        vec3(0) - cameraEntity.transform.position,
    )
)
program(cameraEntity, proc (script: ScriptComponent) =
    var 
        camera = script[CameraComponent]
        position = script.transform.position
        target = vec3(position.x, 0.0, position.z - EPSILON)
        direction = target - position
    camera.direction = direction#lerp(camera.direction, direction, runtime.delta)
)
# Makes the camera entity child of the scene
add(scene, cameraEntity)

discard createPlatform(scene, vec3(-4.0, 0.0, 2.0), vec3(2.0))
discard createPlatform(scene, vec3(-4.0, 0.0, -2.5), vec3(2.0))

# Creates the light entity
let lightEntity = newEntity(scene, "Light")
# Adds a point light component to entity
add(
    lightEntity, 
    newDirectLightComponent(
        direction=vec3(0) - cameraEntity.transform.position,
        shadow=true,
    )
)
# Makes the light entity child of the scene
add(scene, lightEntity)

# Renders an empty scene
render(scene)
# Runs game main loop
loop()

