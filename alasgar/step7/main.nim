import alasgar

# Creates a window named Step7
window("Step7", 830, 415)
   
let 
    # Creates a new scene
    scene = newScene()
    # Creates the camera entity
    cameraEntity = newEntity(scene, "Camera")

# Sets the background color
scene.background = parseHex("d7d1bf")

# Sets the camera position
cameraEntity.transform.position = vec3(5, 5, 5)
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
# Sets the diffuse color
cubeEntity.material.diffuseColor = parseHtmlName("White") 
# Sets albedo map
cubeEntity.material.albedoMap = newTexture("res://tiles08-diffuse.jpg")

# Creates the light entity
let lightEntity = newEntity(scene, "Light")
# Sets light position
lightEntity.transform.position = vec3(3, 5, 4)
# Adds a point light component to entity
add(
    lightEntity, 
    newPointLightComponent()
)
# Adds a script component to the point light entity
program(lightEntity, proc(script: ScriptComponent) =
    let 
        t = runtime.age
        # Access to the point light component.
        light = script[PointLightComponent]
    # Or you can access it by calling getComponent function:
    # let light = get[PointLightComponent](script)
    # Changes light color
    light.color = color(
        abs(sin(t)), 
        1, 
        abs(cos(t))
    )
)
# Makes the light entity child of the scene
add(scene, lightEntity)

# Renders an empty scene
render(scene)
# Runs game main loop
loop()

