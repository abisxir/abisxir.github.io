import alasgar

# Creates a window named Step1
window("Step1", 830, 415)
   
let 
    # Creates a new scene
    scene = newScene()
    # Creates camera entity
    cameraEntity = newEntity(scene, "Camera")

# Sets camera position
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

# Renders an empty scene
render(scene)
# Runs game main loop
loop()

