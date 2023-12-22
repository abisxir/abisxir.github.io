import alasgar
import alasgar/misc/astar
import tile
import noisy

type
    StageComponent* = ref object of Component
        size*: int
        radius*: int
        grid*: tile.Grid
        board: seq[int]
        goal: (int, int)

proc newStageComponent*(size, radius: int): StageComponent =
    new(result)
    result.size = size
    result.radius = radius
    result.grid = newGrid(size, size)
    result.board = newSeq[int](size * size)
    result.goal = (int(size / 2), int(size / 2))
    for i in 0..<size * size:
        result.board[i] = 0

template `goal`*(stage: StageComponent): (int, int) = stage.goal

template pow2(x: int): int = x * x
template pow2(x: float32): float32 = x * x

proc createTileEntity(scene: Scene, model: Resource, x, y: int): Entity =
    result = toEntity(model, scene)
    result.transform.position = vec3(x.float32, 0.0, y.float32)
    result.transform.scale = vec3(0.5, 1.0, 0.5)

proc createTileEntity(scene: Scene, tile: Tile): Entity =
    let noise = tile.noise * 0.5 + 0.5
    result = newEntity(scene, &"Tile-{tile.x}x{tile.y}")
    add(result, newPlaneMesh())
    if tile.kind == tkTile:
        result.transform.position = vec3(tile.x.float32, 0.0, tile.y.float32)
        result.material.diffuseColor = color(noise, 0.0, 0.0, 1.0)
    else:
        result.transform.position = vec3(tile.x.float32, 0.0, tile.y.float32)
    #if tile.kind == tkTile:
    #    result.material.diffuseColor = color(tile.noise, 0.0, 0.0, 1.0)
    #    result.transform.position = vec3(tile.x.float32, 5.0, tile.y.float32)
    #elif tile.kind == tkDirt:
    #    result.transform.position = vec3(tile.x.float32, 0.0, tile.y.float32)
    #    result.material.diffuseColor = color(0.0, 1.0, 0.0, 1.0)
    #else:
    #    result.transform.position = vec3(tile.x.float32, 0.0, tile.y.float32)
    #    result.material.diffuseColor = color(0.0, 0.0, 1.0, 1.0)
    


proc sample(value: float32, models: openArray[Resource]): Resource =
    let n = map(clamp(value, 0, 1), 0, 1, 0, models.len.float32 - EPSILON)
    result = models[n.int]

proc refineLevel1(g: var tile.Grid) =
    for t in mitems(g.tiles):
        if t.kind == tkEmpty and naibours(g, t) > 2:
            t.kind = tkDirt

proc refineLevel2(g: var tile.Grid) =
    for t in mitems(g.tiles):
        if t.kind == tkDirt and naibours(g, t, tkTile) > 2:
            t.kind = tkTile

proc refineLevel3(g: var tile.Grid) =
    for t in mitems(g.tiles):
        if t.kind == tkTile and naibours(g, t, tkDirt) > 2:
            t.kind = tkDirt

proc createStage*(scene: Scene, size, radius: int): Entity =
    var 
        tiles = [
            load("res://gltf/floor_tile_small_broken_A.gltf.glb"),
            load("res://gltf/floor_tile_small_broken_B.gltf.glb"),
            load("res://gltf/floor_tile_small_broken_B.gltf.glb"),
            load("res://gltf/floor_tile_small_weeds_A.gltf.glb"),
            load("res://gltf/floor_tile_small_weeds_B.gltf.glb"),
        ]
        dirts = [
            load("res://gltf/floor_dirt_small_A.gltf.glb"),
            load("res://gltf/floor_dirt_small_B.gltf.glb"),
            load("res://gltf/floor_dirt_small_weeds.gltf.glb"),
            load("res://gltf/floor_dirt_small_C.gltf.glb"),
        ]
        simplex = initSimplex(1988)
        stage = newStageComponent(size, radius)

    simplex.frequency = 0.1
    let 
        values = simplex.grid((0, 0), (size, size))
    

    result = newEntity(scene, "Stage")
    add(result, stage)
    result.transform.position = vec3(-size / 2, 0, -size / 2)

    let 
        centerX: int = size div 2
        centerY: int = size div 2
        surroundingRadius = radius div 2
        noiseFactor = 1

    for y in 0..<size:
        for x in 0..<size:
            let 
                distanceSquared = pow2(x - centerX) + pow2(y - centerY)
                noise = rand(-noiseFactor.float32, noiseFactor.float32)
            if distanceSquared.float32 <= pow2(surroundingRadius.float32 + noise):
                stage.grid[x, y] = newTile(x, y, tkTile, noise)
            elif distanceSquared.float32 <= pow2(radius.float32 + noise):
                stage.grid[x, y] = newTile(x, y, tkDirt, noise)
            else:
                stage.grid[x, y] = newTile(x, y, tkEmpty, noise)

    refineLevel1(stage.grid)
    refineLevel2(stage.grid)
    refineLevel3(stage.grid)

    for y in 0..<size:
        for x in 0..<size:
            if stage.grid[x, y].kind == tkDirt:
                if isNaibourWith(stage.grid, x, y, tkTile):
                    add(result, createTileEntity(scene, stage.grid[x, y]))
                else:
                    add(result, createTileEntity(scene, stage.grid[x, y]))
            elif stage.grid[x, y].kind == tkTile:
                add(result, createTileEntity(scene, stage.grid[x, y]))
            #else:
            #    addChild(result, createTile(scene, load("res://gltf/floor_wood_small.gltf.glb"), x, y))


proc getPath*(stage: StageComponent, t1, t2: (int, int), path: var seq[(int, int)]): bool = findPath(stage.board, stage.size, stage.size, t1, t2, path)
proc getPath*(stage: StageComponent, t1, t2: Tile, path: var seq[(int, int)]): bool = getPath(stage, (t1.x, t1.y), (t2.x, t2.y), path)
