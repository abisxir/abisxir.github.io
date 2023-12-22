type
    TileKind* = enum
        tkEmpty,
        tkDirt,
        tkTile
    Tile* = object
        x*, y*: int
        noise*: float
        kind*: TileKind
    Grid* = object
        tiles*: seq[Tile]
        width, height: int

func newTile*(x, y: int, kind: TileKind=tkEmpty, noise: float=0.0): Tile = Tile(x: x, y: y, kind: kind, noise: noise)
func hash*(t: Tile): int = t.x * t.y
func `==`*(t1, t2: Tile): bool = t1.x == t2.x and t1.y == t2.y
func `!=`*(t1, t2: Tile): bool = t1.x != t2.x or t1.y != t2.y

func newGrid*(width, height: int): Grid =
    result.tiles = newSeq[Tile](width * height)
    result.width = width
    result.height = height
template `width`*(g: Grid): int = g.width
template `height`*(g: Grid): int = g.height
func `[]`*(g: Grid, x, y: int): Tile = 
    let i = x + y * g.width
    if i < 0 or i >= g.tiles.len: 
        result = newTile(x, y, tkEmpty)
    else:
        result = g.tiles[x + y * g.width]
func `[]=`*(g: var Grid, x, y: int, t: Tile) = g.tiles[x + y * g.width] = t 
func left*(g: Grid, t: Tile): Tile = g[t.x - 1, t.y]
func right*(g: Grid, t: Tile): Tile = g[t.x + 1, t.y]
func top*(g: Grid, t: Tile): Tile = g[t.x, t.y - 1]
func bottom*(g: Grid, t: Tile): Tile = g[t.x, t.y + 1]

func naibours*(g: Grid, t: Tile): int =
    if left(g, t).kind != t.kind: result += 1
    if right(g, t).kind != t.kind: result += 1
    if top(g, t).kind != t.kind: result += 1
    if bottom(g, t).kind != t.kind: result += 1

func naibours*(g: Grid, t: Tile, kind: TileKind): int =
    if left(g, t).kind == kind: result += 1
    if right(g, t).kind == kind: result += 1
    if top(g, t).kind == kind: result += 1
    if bottom(g, t).kind == kind: result += 1

func isNaibourWith*(g: Grid, x, y: int, kind: TileKind): bool =
    let tile = g[x, y]
    result = left(g, tile).kind == kind or right(g, tile).kind == kind or top(g, tile).kind == kind or bottom(g, tile).kind == kind

