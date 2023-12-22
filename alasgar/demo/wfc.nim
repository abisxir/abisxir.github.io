import tables
import random

type
    CanPlaceFunc*[T] = proc (wfc: Wfc[T], x, y: int, value: T): bool
    FailedFunc*[T] = proc (wfc: Wfc[T], x, y: int): seq[T]
    Cell[T] = object
        value: T
        collapsed: bool
    Wfc*[T] = object
        width, height: int
        grid: seq[Cell[T]]
        initial: T
        canPlace*: CanPlaceFunc[T]
        failed*: FailedFunc[T]
        patterns: Table[T, array[0..3, set[T]]]

proc newWfc*[T](width, height: int, initial: T, patterns: Table[T, array[0..3, set[T]]]): Wfc[T] =
    result.width = width
    result.height = height
    result.grid = newSeq[Cell[T]](width * height)
    result.initial = initial
    result.patterns = patterns

func valid*[T](wfc: Wfc[T], x, y: int): bool = x >= 0 and x < wfc.width and y >= 0 and y < wfc.height
func get*[T](wfc: Wfc[T], x, y: int): T = 
    if valid(wfc, x, y):
        wfc.grid[x + y * wfc.width].value
    else:
        wfc.initial

proc debug*[T](wfc: Wfc[T]) =
    for j in 0 ..< wfc.height:
        for i in 0 ..< wfc.width:
            stdout.write get(wfc, i, j)
        echo ""

func set[T](cell: var Cell[T], v: T) = 
    cell.value = v
    cell.collapsed = true
func put[T](wfc: var Wfc[T], x, y: int, value: T) = set(wfc.grid[x + y * wfc.width], value)
func left[T](wfc: Wfc[T], x, y: int): T = get(wfc, x - 1, y) 
func right[T](wfc: Wfc[T], x, y: int): T = get(wfc, x + 1, y) 
func up[T](wfc: Wfc[T], x, y: int): T = get(wfc, x, y - 1) 
func down[T](wfc: Wfc[T], x, y: int): T = get(wfc, x, y + 1) 
iterator iterate*[T](wfc: Wfc[T]): (int, int, T) =
    for y in 0 ..< wfc.height:
        for x in 0 ..< wfc.width:
            yield (x, y, wfc.grid[x + y * wfc.width].value)

func count*[T](wfc: Wfc[T], value: T): int =
    for e in wfc.grid:
        if e.value == value:
            inc result

func nearby*[T](wfc: Wfc[T], x, y, r: int, v: T): bool =
    for i in -r..r:
        for j in -r..r:
            if get(wfc, x + i, y + j) == v:
                return true
    false

func isNaiborWith*[T](wfc: Wfc[T], x, y: int, v: set[T]): bool = 
    left(wfc, x, y) in v or right(wfc, x, y) in v or up(wfc, x, y) in v or down(wfc, x, y) in v

proc allowed[T](wfc: Wfc[T], x, y: int): seq[T] = 
    let
        l = wfc.patterns[left(wfc, x, y)][1]
        r = wfc.patterns[right(wfc, x, y)][0]
        u = wfc.patterns[up(wfc, x, y)][3]
        d = wfc.patterns[down(wfc, x, y)][2]
        possible = l * r * u * d
    for e in possible:
        if isNil(wfc.canPlace) or wfc.canPlace(wfc, x, y, e):
            add(result, e)
    if len(result) == 0 and not isNil(wfc.failed):
        result = wfc.failed(wfc, x, y)

proc entropy[T](wfc: Wfc[T], x, y: int): int = len(allowed[T](wfc, x, y))
proc getCandidate[T](wfc: Wfc[T], solved, failed: var bool): (int, int) =
    var
        maxEntropy = wfc.patterns.len + 1
        minEntropy = maxEntropy
        minX, minY: int
    solved = true
    for x in 0 ..< wfc.width:
        for y in 0 ..< wfc.height:
            if not wfc.grid[x + y * wfc.width].collapsed:
                solved = false
                let e = entropy[T](wfc, x, y)
                if e < minEntropy:
                    minEntropy = e
                    minX = x
                    minY = y
    failed = minEntropy == 0
    solved = minEntropy == maxEntropy
    (minX, minY)

proc solve*[T](wfc: var Wfc[T]): bool =
    var
        solved, failed: bool
    for i in 0 ..< wfc.width * wfc.height:
        wfc.grid[i].collapsed = false
        wfc.grid[i].value = wfc.initial
    while not solved and not failed:
        let (x, y) = getCandidate(wfc, solved, failed)
        if not failed:
            let 
                a = allowed(wfc, x, y)
                s = sample(a)
            put(wfc, x, y, s)
   
when isMainModule:
    const 
        patterns = {
            '+' : [
                {'-'},
                {'-'},
                {'|'},
                {'|'},
            ],
            '-' : [
                {'-', '+'},
                {'-', '+'},
                {' '},
                {' '},
            ],
            '|' : [
                {' '},
                {' '},
                {'|', '+'},
                {'|', '+'},
            ],
            ' ' : [
                {' ', '|', '+'},
                {' ', '|', '+'},
                {' ', '+', '-'},
                {' ', '+', '-'},
            ],
            '*' : [
                {' ', '|', '+', '-'},
                {' ', '|', '+', '-'},
                {' ', '|', '+', '-'},
                {' ', '|', '+', '-'},
            ]
        }.toTable()
    proc canPlace[char](wfc: Wfc[char], x, y: int, value: char): bool = value != '+' or not nearby(wfc, x, y, 3, '+')
    proc failed[char](wfc: Wfc[char], x, y: int): seq[char] = @['+']

    var test = newWfc(32, 16, '*', patterns)
    test.canPlace = canPlace
    test.failed = failed
    echo test.solve()
    test.debug()
