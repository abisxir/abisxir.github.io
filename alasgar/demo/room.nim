import alasgar
import sequtils

type
    Tile* = object
        x*: int
        y*: int
        leftWall*, topWall*, rightWall*, bottomWall*: bool
        naibouring*: bool
    Room* = object
        id*: int
        tiles*: seq[Tile]

proc newTile(x: int, y: int): Tile =
    result.x = x
    result.y = y

proc left(tile: Tile): Tile = newTile(tile.x - 1, tile.y)
proc right(tile: Tile): Tile = newTile(tile.x + 1, tile.y)
proc top(tile: Tile): Tile = newTile(tile.x, tile.y - 1)
proc bottom(tile: Tile): Tile = newTile(tile.x, tile.y + 1)
proc `$`*(p: Tile): string = &"({p.x}, {p.y})"
proc `==`*(a, b: Tile): bool = a.x == b.x and a.y == b.y
proc `!=`*(a, b: Tile): bool = a.x != b.x or a.y != b.y
proc `$`*(r: Room): string = 
    result = ""
    for r in r.tiles:
        result &= $r & " "

proc hasWall*(tile: Tile): bool = tile.leftWall or tile.topWall or tile.rightWall or tile.bottomWall
proc isTopLeftCorner*(tile: Tile): bool = tile.leftWall and tile.topWall
proc isTopRightCorner*(tile: Tile): bool = tile.rightWall and tile.topWall
proc isBottomLeftCorner*(tile: Tile): bool = tile.leftWall and tile.bottomWall
proc isBottomRightCorner*(tile: Tile): bool = tile.rightWall and tile.bottomWall

proc createRoom(position: Tile, size: Tile): Room =
    result.tiles = newSeq[Tile](size.x * size.y)
    for y in 0 ..< size.y:
        for x in 0 ..< size.x:
            let 
                px = x + position.x
                py = y + position.y
            result.tiles[y * size.x + x] = newTile(px, py)

proc removeTileFromRoom(room: var Room, tile: Tile) =
    keepItIf(room.tiles, it.x != tile.x or it.y != tile.y)

proc isTileOverlapping(room: Room, tile: Tile): bool =
    result = false
    for roomTile in room.tiles:
        if roomTile.x == tile.x and roomTile.y == tile.y:
            result = true
            break

proc getTileAt(room: Room, x, y: int, tile: var Tile): bool =
    result = false
    for roomTile in room.tiles:
        if roomTile.x == x and roomTile.y == y:
            result = true
            tile = roomTile
            break

proc getNaibouringTiles(a, b: Room): seq[Tile] =
    for tile1 in a.tiles:
        if tile1.naibouring:
            for tile2 in b.tiles:
                if tile2.naibouring:
                    if tile1 in [left(tile2), right(tile2), top(tile2), bottom(tile2)]:
                        result.add(tile1)
                        break

proc createRoomOutOfOverlapping(room1: var Room, room2: var Room): Room =
    var 
        toRemove = newSeq[Tile](0)
    for tile1 in room1.tiles:
        if isTileOverlapping(room2, tile1):
            result.tiles.add(tile1)
            toRemove.add(tile1)
    for tile in toRemove:
        removeTileFromRoom(room1, tile)
        removeTileFromRoom(room2, tile)

proc canPlaceWall(root: var Tile, refRoomId: int, tile: Tile, rooms: seq[Room], cnd: proc(t:Tile): bool): bool =
    var 
        id = -1
        naibour: Tile
    for room in rooms:
        if getTileAt(room, tile.x, tile.y, naibour):
            id = room.id
            break
    root.naibouring = root.naibouring or id == -1 or id != refRoomId
    result = id == -1 or (id != refRoomId and cnd(naibour))

proc connectRooms(initial: var seq[Room], final: var seq[Room]) =
    var 
        id: int = 0

    initial[0].id = id
    final.add(initial[0])
    for i in 1 ..< initial.len:
        var 
            intersection = createRoomOutOfOverlapping(final[final.len - 1], initial[i])
        if intersection.tiles.len > 0:
            inc(id)
            intersection.id = id
            final.add(intersection)
        inc(id)
        initial[i].id = id
        final.add(initial[i])


proc divideWalls(rooms: var seq[Room]) =
    for room in mitems(rooms):
        for tile in mitems(room.tiles):
            tile.leftWall = canPlaceWall(tile, room.id, left(tile), rooms, proc(tile: Tile): bool = not tile.rightWall)
            tile.rightWall = canPlaceWall(tile, room.id, right(tile), rooms, proc(tile: Tile): bool = not tile.leftWall)
            tile.topWall = canPlaceWall(tile, room.id, top(tile), rooms, proc(tile: Tile): bool = not tile.bottomWall)
            tile.bottomWall = canPlaceWall(tile, room.id, bottom(tile), rooms, proc(tile: Tile): bool = not tile.topWall)

proc createMap*(maxRooms: int, roomMinSize: int, roomMaxSize: int): seq[Room] =
    var initial = newSeq[Room]()
    template randomSize(): Tile = newTile(rand(roomMinSize, roomMaxSize), rand(roomMinSize, roomMaxSize))
    var 
        start = newTile(0, 0)
        size = randomSize()
        endPosition = newTile(start.x + size.x, start.y + size.y)
    initial.add(createRoom(start, size))
    for i in 1 ..< maxRooms:
        let 
            right = rand(roomMinSize)
            top = rand(roomMinSize)
        start = newTile(endPosition.x - right, endPosition.y - top)
        size = randomSize()
        endPosition = newTile(start.x + size.x, start.y + size.y)
        initial.add(createRoom(start, size))

    connectRooms(initial, result)
    divideWalls(result)

        
