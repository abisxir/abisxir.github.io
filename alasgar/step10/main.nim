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
addComponent(cubeEntity, newMaterialComponent(
    diffuseColor=parseHtmlName("white"),
    specularColor=parseHtmlName("grey"),
    albedoMap=newTexture("res://stone-texture.png")
))
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

# Creats spot point light entity
let spotLightEntity = newEntity(scene, "SpotLight")
# Sets position to (-6, 6, 6)
spotLightEntity.transform.position = vec3(-6, 6, 6)
# Adds a spot point light component
addComponent(spotLightEntity, newSpotPointLightComponent(
    vec3(0) - spotLightEntity.transform.position, # Light direction
    color=parseHtmlName("Tomato"),                # Light color
    luminance=200.0,                              # Light intensity
    shadow=false,                                 # Casts shadow or not
    innerCutoff=30,                               # Inner circle of light
    outerCutoff=90                                # Outer circle of light
))
# Makes the new light child of the scene
addChild(scene, spotLightEntity)

# Creats direct light entity
let directLightEntity = newEntity(scene, "DirectLight")
# Adds a direct light component, and select camera direction for lighting
addComponent(directLightEntity, newDirectLightComponent(
    vec3(0) - cameraEntity.transform.position,    # Light direction
    color=parseHtmlName("Aqua"),                  # Light color
    luminance=150.0,                              # Light intensity
    shadow=false,                                 # Casts shadow or not
))
# Adds a script component to direct light entity
program(directLightEntity, proc(script: ScriptComponent) =
    # Access to direct light component.
    let light = script[DirectLightComponent]
    # Or you can access it by calling getComponent function:
    # let light = getComponent[DirectLightComponent](script)
    # Changes light color
    light.color = color(
        abs(sin(runtime.age)), 
        abs(cos(runtime.age)), 
        abs(sin(runtime.age) * cos(runtime.age))
    )
    # Change luminance, will be between 250 and 750
    light.luminance = 500.0 + 250.0 * sin(runtime.age)
)
# Makes the new light child of the scene
addChild(scene, directLightEntity)

# Renders the scene
render(scene)
# Runs game main loop
loop()

