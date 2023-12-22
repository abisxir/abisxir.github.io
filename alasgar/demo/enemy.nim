import alasgar
import stage

type
    EnemySoldier = ref object of Component
        stage: StageComponent
        health: float32
        running: bool
        frame: int
        frameCount: int

let chunks = [
    ("res://Warrior/SpriteSheet/Warrior_Sheet-Effect.png", 6, 17, 6, vec3(1.0, 1.0, 1.0)),
    ("res://16x32.png", 4, 64, 8, vec3(0.5, 1.0, 1.0)),
    ("res://32x32.png", 4, 12, 8, vec3(1.0)), 
    ("res://32x48.png", 4, 2, 8, vec3(0.5, 1.0, 1.0)),
]
        
proc runToTarget(enemy: EnemySoldier) =
    var 
        goal = enemy.stage.goal
        pos = enemy.transform.position
        current = (int(pos.x + 0.05), int(pos.z + 0.05))
        path: seq[(int, int)]
    enemy.running = current != goal
    if enemy.running:
        if getPath(enemy.stage, current, goal, path) and len(path) > 1:
            let 
                (x, y) = path[1]
                dir = vec2(x.float32, y.float32) - pos.xz
                newPos = pos.xz + normalize(dir) * runtime.delta * 2.0
            enemy.transform.position = vec3(newPos.x, pos.y, newPos.y)

proc updateEnemySoldier(script: ScriptComponent) =   
    runToTarget(script[EnemySoldier]) 
    let cpos = runtime.camera.transform.position

    script.transform.lookAt(vec3(cpos.x, 0, cpos.z))

proc tickEnemySoldier(timer: TimerComponent) =
    let
        enemy = timer[EnemySoldier]
    timer[MaterialComponent].frame = timer[MaterialComponent].frame + 1
    if timer[MaterialComponent].frame >= enemy.frame + enemy.frameCount:
        timer[MaterialComponent].frame = enemy.frame

proc createEnemySoldier*(scene: Scene, stage: StageComponent, pos: (int, int), chunk, index: int): Entity =
    let 
        (path, frameCount, vframes, hframes, scale) = chunks[chunk]
    result = newEntity(scene, "EnemySoldier")
    add(result, EnemySoldier(stage: stage, health: 1, frame: index * hframes, frameCount: frameCount))
    add(result, newLambertMaterialComponent(
        albedoMap=newTexture(path),
        vframes=vframes.int32, hframes=hframes.int32, frame=(index * hframes).int32
    ))
    add(result, newSpriteComponent())
    program(result, updateEnemySoldier)
    timer(result, 1.0 / 6.0, tickEnemySoldier)
    result.transform.position = vec3(pos[0].float32, 0.5, pos[1].float32)
    result.transform.scale = 0.5 * scale
