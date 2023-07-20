import alasgar

# Creates a window named Hello
window("Hello", 960, 540)
   
let 
    # Creates a new scene
    scene = newScene()
    # Creates an environment component
    env = newEnvironmentComponent()
    # Creates camera entity
    cameraEntity = newEntity(scene, "Camera")

# Sets background color
setBackground(env, parseHex("d7d1bf"))
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
# Makes the camera entity child of the scene
addChild(scene, cameraEntity)

# Creates cube entity, by default position is 0, 0, 0
let cubeEntity = newEntity(scene, "Cube")
# Add a cube mesh component to entity
addComponent(cubeEntity, newCubeMesh())
# Adds a script component to cube entity, we use this helpful function:
program(cubeEntity, proc(script: ScriptComponent) =
    # We can rotate an object using euler also it is possible to directly set rotation property which is a quaternion.
    script.transform.euler = vec3(
        sin(runtime.age) * cos(runtime.age), 
        cos(runtime.age), 
        sin(runtime.age)
    )
)
# Adds a material to cube
addComponent(cubeEntity, newMaterialComponent(diffuseColor=parseHtmlName("Tomato")))
# Makes the cube enity child of the scene
addChild(scene, cubeEntity)
# Scale it up
cubeEntity.transform.scale = vec3(2)

# Creates light entity
let lightEntity = newEntity(scene, "Light")
# Adds a point light component to entity
addComponent(
    lightEntity, 
    newPointLightComponent()
)
# Adds a script component to light entity
program(lightEntity, proc(script: ScriptComponent) =
    let 
        r = 7.0
        angle = runtime.age * 1.0
    # Change position on transform
    script.transform.position = r * vec3(
        sin(angle),
        cos(angle),
        sin(angle) * cos(angle),
    )
)
# Also you can add using a suger function called "program", will explain it later
# Makes the light entity child of the scene
addChild(scene, lightEntity)

# Adds a material to cube
addComponent(cubeEntity, newMaterialComponent(
    diffuseColor=parseHtmlName("white"),
    specularColor=parseHtmlName("grey"),
    albedoMap=newTexture("res://stone-texture.png")
))

# Renders the scene
render(scene)
# Runs game main loop
loop()
