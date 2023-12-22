import tables

import alasgar
import random
import wfc


# Exists when ESC is pressed
settings.exitOnEsc = true

# Creates a window named Hello
window("Demo", 1920, 1080)

const
    WIDTH = 16
    HEIGHT = 16

type 
    Grid[T] = object
        data: seq[T]
        width, height: int
    SectionKind = enum
        skEmpty
        skWater
        skGround
        skFloor1
        skFloor2
        skFloor3
    Section = object
        kind: SectionKind
        x, y: int
        tiles: Grid[Tile]
    TileKind = enum
        tkGrass
        tkWater
        tkSand
    Tile = object
        kind: TileKind
        x, y: int

const 
    sectionsPattern = {
        skWater: [
            {skWater, skGround, skFloor1, skFloor2, skFloor3},
            {skWater, skGround, skFloor1, skFloor2, skFloor3},
            {skWater, skGround, skFloor1, skFloor2, skFloor3},
            {skWater, skGround, skFloor1, skFloor2, skFloor3},
        ],
        skGround: [
            {skWater, skGround, skFloor1, skFloor2, skFloor3},
            {skWater, skGround, skFloor1, skFloor2, skFloor3},
            {skWater, skGround, skFloor1, skFloor2, skFloor3},
            {skWater, skGround, skFloor1, skFloor2, skFloor3},
        ],
        skFloor1: [
            {skWater, skGround, skFloor1, skFloor2, skFloor3},
            {skWater, skGround, skFloor1, skFloor2, skFloor3},
            {skWater, skGround, skFloor1, skFloor2, skFloor3},
            {skWater, skGround, skFloor1, skFloor2, skFloor3},
        ],
        skFloor2: [
            {skFloor1, skFloor2, skFloor3},
            {skFloor1, skFloor2, skFloor3},
            {skFloor1, skFloor2, skFloor3},
            {skFloor1, skFloor2, skFloor3},
        ],
        skFloor3: [
            {skFloor1, skFloor2, skFloor3},
            {skFloor1, skFloor2, skFloor3},
            {skFloor1, skFloor2, skFloor3},
            {skFloor1, skFloor2, skFloor3},
        ],
    }.toTable()
   
var
    sectionsWfc = newWFC[SectionKind](WIDTH, HEIGHT, skWater, {
        skWater: [
            {skWater, skGround},
            {skWater, skGround},
            {skWater, skGround},
            {skWater, skGround},
        ],
        skGround: [
            {skWater, skGround},
            {skWater, skGround},
            {skWater, skGround},
            {skWater, skGround},
        ],
    }.toTable())
    #grid = newSeq[Tile](WIDTH * HEIGHT)
    #simplex = initSimplex(1988)
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

#simplex.frequency = 0.1
#let values = simplex.grid((0, 0), (WIDTH, HEIGHT))

sectionsWfc.canPlace = proc(wfc: Wfc[SectionKind], x, y: int, value: SectionKind): bool = 
    case value:
        of skWater:
            isNaiborWith(wfc, x, y, {skWater}) and count(wfc, skWater) < 40
        of skGround:
            true
        else:
            true
    #if value == skFloor2:
    #    return isNaiborWith(wfc, x, y, {skFloor1, skFloor2})
    #elif value == skFloor3:
    #    return isNaiborWith(wfc, x, y, {skFloor2})
    #elif value == skWater:
    #    return isNaiborWith(wfc, x, y, {skWater}) and count(wfc, skWater) < 6
    #else:
    #    return true

randomize()
discard sectionsWfc.solve()

proc addWalls(p: Entity, x, y, h: int) =
    for (ox, oy) in [(-0.5, 0.0), (0.5, 0.0), (0.0, -0.5), (0.0, 0.5)]:
        var 
            wall = newEntity(scene, &"Wall{x}x{y}")
        wall.transform.position = vec3(x.float32 + ox.float32, h.float32 / 2.0, y.float32 + oy.float32)
        if ox == 0:
            wall.transform.euler = vec3(0, 0, PI / 2)
            wall.transform.scale = vec3(1, 1, h.float32)
        else:
            wall.transform.euler = vec3(PI / 2, 0, 0)
            wall.transform.scale = vec3(h.float32, 1, 1)
        add(wall, newPlaneMesh())
        add(p, wall)

let island = newEntity(scene, "Island")
island.transform.position = vec3(-WIDTH.float32 / 2.0, 0, -HEIGHT.float32 / 2.0)
#island.transform.scale = vec3(3)
add(scene, island)


for (x, y, kind) in iterate(sectionsWfc):
    var 
        section = newEntity(scene, &"Section{x}x{y}")   
    section.transform.position = 1 * vec3(x.float32, 0, y.float32)
    section.transform.scale = vec3(1)
    add(section, newPlaneMesh())
    if kind == skWater:
        section.material.diffuseColor = color(0, 0, 1)
    elif kind == skGround:
        section.material.diffuseColor = color(0, 1, 0)
    elif kind == skFloor1:
        section.transform.positionY = 1
        section.material.diffuseColor = color(1, 1, 0)
        addWalls(island, x, y, 1)
    elif kind == skFloor2:
        section.transform.positionY = 2
        section.material.diffuseColor = color(1, 0, 1)
        addWalls(island, x, y, 2)
    elif kind == skFloor3:
        section.transform.positionY = 3
        section.material.diffuseColor = color(1, 0, 0)
        addWalls(island, x, y, 3)
    #section.transform.positionY = 0
    add(island, section)


# Renders the scene
render(scene)
# Runs game main loop
loop()

