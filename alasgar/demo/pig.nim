import alasgar
import stage

type
    Enemy = ref object of Component
        stage: StageComponent
        health: float32
        running: bool
        speed: float32
        direction: Vec3
    PigSoldier = ref object of Component
        discard
        #frame: int
        #frameCount: int

let chunks = [
    ("res://Sprites/03-Pig/Run (34x28).png", 6),
    ("res://Sprites/03-Pig/Idle (34x28).png", 11),
]

proc collidesOtherEnemy(enemy: Enemy): bool =
    let
        point =enemy.transform.position + normalize(enemy.direction) * 0.5
    for e in iterate[Enemy](enemy.entity.scene):
        if enemy != e:
            if isPointInsideSphere(point, e.transform.position, 0.2):
                return true
        
proc runToTarget(enemy: Enemy) =
    var 
        goal = enemy.stage.goal
        pos = enemy.transform.position
        current = (int(pos.x + 0.05), int(pos.z + 0.05))
        path: seq[(int, int)]
    enemy.running = current != goal and not collidesOtherEnemy(enemy)
    if enemy.running:
        if getPath(enemy.stage, current, goal, path) and len(path) > 1:
            let 
                (x, y) = path[1]
                dir = vec2(x.float32, y.float32) - pos.xz
            enemy.direction = vec3(dir.x, 0.0, dir.y)
            enemy.transform.position = enemy.transform.position + normalize(enemy.direction) * runtime.delta * enemy.speed

proc updateEnemy(script: ScriptComponent) =   
    let 
        cameraPos = runtime.camera.transform.position
        enemy = script[Enemy]
    runToTarget(enemy) 
    script.transform.lookAt(vec3(cameraPos.x, 0, cameraPos.z))

proc tickPig(timer: TimerComponent) =
    let
        enemy = timer[Enemy]
        material = timer[MaterialComponent]
        (texture, maxFrames) = if enemy.running: chunks[0] else: chunks[1]
    timer.material.albedoMap = newTexture(texture)
    material.vframes = 1
    material.hframes = maxFrames
    material.frame = material.frame + 1
    if material.frame >= maxFrames - 1:
        material.frame = 0

proc createPig*(scene: Scene, stage: StageComponent, pos: (int, int)): Entity =
    result = newEntity(scene, "PigSoldier")
    add(result, Enemy(stage: stage, health: 1, speed: 2.0))
    add(result, PigSoldier())
    add(result, newLambertMaterialComponent())
    add(result, newSpriteComponent())
    program(result, updateEnemy)
    timer(result, 1.0 / 12.0, tickPig)
    result.transform.position = vec3(pos[0].float32, 0.5, pos[1].float32)
    result.transform.scale = vec3(0.5)
