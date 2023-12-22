import alasgar
import room

# Creates a window named Hello
window("Step8", 1920, 1080)
settings.exitOnEsc = true
   
let 
    # Creates a new scene
    scene = newScene()
    # Creates an environment component
    env = newEnvironmentComponent()
    # Creates camera entity
    cameraEntity = newEntity(scene, "Camera")

# Sets background color
setAmbient(env, parseHex("ffffff"), 1.0)
# Adds environment component to scene
addComponent(scene, env)

# Sets camera position
cameraEntity.transform.position = 10 * vec3(5, 5, 5)
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
addCameraController(cameraEntity)
# Makes the camera entity child of the scene
addChild(scene, cameraEntity)

let hallEntity = newEntity(scene, "Hall")
addChild(scene, hallEntity)

let 
    floor = load("res://gltf/floor_tile_small.gltf.glb")
    tiles = [
        load("res://gltf/floor_tile_small_broken_A.gltf.glb"),
        load("res://gltf/floor_tile_small_broken_B.gltf.glb"),
        #load("res://gltf/floor_tile_small_decorated.gltf.glb"),
        load("res://gltf/floor_tile_small_weeds_A.gltf.glb"),
        load("res://gltf/floor_tile_small_weeds_B.gltf.glb"),
    ]
    dirts = [
        load("res://gltf/floor_dirt_small_A.gltf.glb"),
        load("res://gltf/floor_dirt_small_B.gltf.glb"),
        load("res://gltf/floor_dirt_small_C.gltf.glb"),
        load("res://gltf/floor_dirt_small_D.gltf.glb"),
        load("res://gltf/floor_dirt_small_weeds.gltf.glb"),
        #load("res://gltf/floor_dirt_small_corner.gltf.glb"),
    ]
    corner = load("res://gltf/floor_tile_small_weeds_A.gltf.glb")
    smallWall = load("res://gltf/wall_half.gltf.glb")
    endcap = load("res://gltf/wall_endcap.gltf.glb")
    doorways = [
        load("res://gltf/wall_doorway.gltf.glb"),
        load("res://gltf/wall_doorway_scaffold.gltf.glb"),
    ]
    windows = [
        load("res://gltf/wall_archedwindow_gated.gltf.glb"),
        load("res://gltf/wall_archedwindow_open.gltf.glb"),
        load("res://gltf/wall_archedwindow_gated_scaffold.gltf.glb"),
        load("res://gltf/wall_window_open.gltf.glb"),
        load("res://gltf/wall_window_closed.gltf.glb"),
        load("res://gltf/wall_window_open_scaffold.gltf.glb"),
    ]
    corners = [
        #load("res://gltf/wall_corner.gltf.glb"),
        load("res://gltf/wall_corner_scaffold.gltf.glb"),
        load("res://gltf/wall_corner_gated.gltf.glb"),
    ]
    walls = [
        #load("res://gltf/wall_gated.gltf.glb"),
        #load("res://gltf/wall_broken.gltf.glb"),
        #load("res://gltf/wall.gltf.glb"),
        #load("res://gltf/wall_arched.gltf.glb"),
        #load("res://gltf/wall_cracked.gltf.glb"),
        #load("res://gltf/wall_pillar.gltf.glb"),
        #load("res://gltf/wall_shelves.gltf.glb"),
        #load("res://gltf/wall_doorway_Tsplit.gltf.glb"),
        #load("res://gltf/wall.gltf.glb"),
        load("res://gltf/wall_doorway.gltf.glb"),
    ]


proc createPassway(): Entity = 
    let 
        model = load("res://gltf/wall_doorway.gltf.glb")
        e = toEntity(model, scene)
    e["wall_doorway/wall_doorway_door"].visible = false
    e.transform.scale = vec3(0.25)
    result = e


proc findComponent*[T: Component](e: Entity): T =
    for c in e.components:
        if c of T:
            result = cast[T](c)
            break
    if result == nil:
        for c in e.children:
            result = findComponent[T](c)
            if result != nil:
                break

proc createCorner(position: Vec3, rotation: Vec3) =
    let 
        e = toEntity(sample(corners), scene)
        l = toEntity(smallWall, scene)
        r = toEntity(smallWall, scene)
    
    e.transform.position = position
    e.transform.scale = vec3(0.25)
    e.transform.euler = rotation

    l.transform.position = vec3(-4.0, 0.0, 0.0)
    r.transform.position = vec3(0.0, 0.0, 4.0)
    r.transform.euler = vec3(0, PI / 2, 0)

    addChild(e, l)
    addChild(e, r)
    addChild(hallEntity, e)

proc createWall(position: Vec3, rotation: Vec3) =
    let w = toEntity(sample(walls), scene)
    w.transform.position = position
    w.transform.scale = vec3(0.25)
    w.transform.euler = rotation
    addChild(hallEntity, w)

proc createWall(p: Tile, color: Color) =
    if isTopLeftCorner(p):
        createCorner(vec3(p.x.float32 - 0.5, 0, p.y.float32 - 0.5), vec3(0, PI / 2, 0))
    elif isTopRightCorner(p):
        createCorner(vec3(p.x.float32 + 0.5, 0, p.y.float32 - 0.5), vec3(0, 0, 0))
    elif isBottomLeftCorner(p):
        createCorner(vec3(p.x.float32 - 0.5, 0, p.y.float32 + 0.5), vec3(0, PI, 0))
    elif isBottomRightCorner(p):
        createCorner(vec3(p.x.float32 + 0.5, 0, p.y.float32 + 0.5), vec3(0, -PI / 2, 0))
    else:
        if p.leftWall:
            createWall(vec3(p.x.float32 - 0.5, 0.0, p.y.float32), vec3(0, PI / 2, 0))
        if p.rightWall:
            createWall(vec3(p.x.float32 + 0.5, 0.0, p.y.float32), vec3(0, -PI / 2, 0))
        if p.topWall:
            createWall(vec3(p.x.float32, 0.0, p.y.float32 - 0.5), vec3(0, 0, 0))
        if p.bottomWall:
            createWall(vec3(p.x.float32, 0.0, p.y.float32 + 0.5), vec3(0, -PI, 0))

proc createTile(p: Tile, color: Color) =
    let 
        e = if p.naibouring: toEntity(sample(tiles), scene) else: toEntity(sample(dirts), scene)
        m = findComponent[MaterialComponent](e)
    e.transform.position = vec3(p.x.float32, 0, p.y.float32)
    e.transform.scale = vec3(0.5)
    m.diffuseColor = color
    addChild(hallEntity, e)    

proc createRoom(room: Room) =
    let color = randomColor()
    for p in room.tiles:
        createTile(p, color)
        if p.naibouring:
            createWall(p, color)

for room in createMap(2, 5, 10):
    createRoom(room)

hallEntity.transform.position = vec3(-10, 0, 0)

# Renders the scene
render(scene)
# Runs game main loop
loop()
