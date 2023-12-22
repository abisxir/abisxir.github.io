import alasgar

# Creates a window named Step10
window("Step10", 830, 415)
   
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
cameraEntity.transform.position = 7.5 * vec3(1)
# Adds a perspective camera component to entity
add(
    cameraEntity, 
    newPerspectiveCamera(
        75, 
        runtime.ratio, 
        0.1, 
        100.0, 
        vec3(0) - cameraEntity.transform.position
    )
)
# Makes the camera entity child of the scene
add(scene, cameraEntity)

# Creates the cube entity, by default position is 0, 0, 0
let cubeEntity = newEntity(scene, "Cube")
# Add a cube mesh component to entity
add(cubeEntity, newCubeMesh())
# Adds a script component to the cube entity
program(cubeEntity, proc(script: ScriptComponent) =
    let t = 2 * runtime.age
    # Rotates the cube using euler angles
    script.transform.euler = vec3(
        sin(t),
        cos(t),
        sin(t) * cos(t),
    )
)
# Makes the cube enity child of the scene
add(scene, cubeEntity)
# Scale it up
cubeEntity.transform.scale = vec3(2)
# Enables shadows for the cube
cubeEntity.material.castShadow = true

# Creates the plane entity
let planeEntity = newEntity(scene, "Ground")
# Adds a plane mesh component to entity
add(planeEntity, newPlaneMesh(1, 1))
# Makes the plane entity child of the scene
add(scene, planeEntity)
# Sets the plane position and scale
planeEntity.transform.position = vec3(0, -3, 0)
planeEntity.transform.scale = vec3(200, 1, 200)
# Marks the plane to not cast shadows
planeEntity.material.castShadow = false

# Creates the light entity
let lightEntity = newEntity(scene, "Light")
# Adds a point light component to entity
add(
    lightEntity, 
    newDirectLightComponent(
        direction=vec3(0) - vec3(-4, 5, 4),
        shadow=true,
    )
)
# Makes the light entity child of the scene
add(scene, lightEntity)

# Renders an empty scene
render(scene)
# Runs game main loop
loop()

