import alasgar

# Direct translation of https://www.shadertoy.com/view/4sX3z2 to nim
proc snowEffect*(FRAME: Uniform[Frame],
                 COLOR_CHANNEL: Layout[0, Uniform[Sampler2D]],
                 SPEED: Uniform[float],
                 UV: Vec2,
                 COLOR: var Vec4) =
    var 
        fragCoord = UV * FRAME.RESOLUTION.xy
        snow = 0.0
        gradient = (1.0 - float(fragCoord.y / FRAME.RESOLUTION.x)) * 0.4
        random = fract(sin(dot(fragCoord.xy, vec2(12.9898,78.233))) * 43758.5453)
    for k in 0..5:
        for i in 0..11:
            var 
                cellSize = 2.0 + (float(i) * 3.0)
                downSpeed = SPEED + (sin(FRAME.TIME * 0.4 + float(k + i * 20)) + 1.0) * 0.00008
                uv = (fragCoord.xy / FRAME.RESOLUTION.x) + vec2(0.01 * sin((FRAME.TIME + float(k * 6185)) * 0.6 + float(i)) * (5.0 / float(i)), downSpeed * (FRAME.TIME + float(k*1352)) * (1.0 / float(i)))
                uvStep = (ceil((uv) * cellSize - vec2(0.5,0.5)) / cellSize)
                x = fract(sin(dot(uvStep, vec2(12.9898 + float(k) * 12.0, 78.233 + float(k) * 315.156))) * 43758.5453 + float(k) * 12.0) - 0.5
                y = fract(sin(dot(uvStep, vec2(62.2364 + float(k) * 23.0, 94.674 + float(k) * 95.0))) * 62159.8432 + float(k) * 12.0) - 0.5
                randomMagnitude1 = sin(FRAME.TIME * 2.5) * 0.7 / cellSize
                randomMagnitude2 = cos(FRAME.TIME * 2.5) * 0.7 / cellSize
                d = 5.0 * distance((uvStep.xy + vec2(x * sin(y), y) * randomMagnitude1 + vec2(y,x) * randomMagnitude2), uv.xy)
                omiVal = fract(sin(dot(uvStep.xy, vec2(32.4691,94.615))) * 31572.1684)
            
            if omiVal < 0.08:
                let newd = (x+1.0)*0.4*clamp(1.9-d*(15.0+(x*6.3))*(cellSize/1.4),0.0,1.0)
                snow += newd

    COLOR = texture(COLOR_CHANNEL, UV) + vec4(snow) + gradient * vec4(0.4, 0.8, 1.0, 0.0) + random * 0.01


proc snowEffect1*(CAMERA: Uniform[Camera],
                 FRAME: Uniform[Frame],
                 COLOR_CHANNEL: Layout[0, Uniform[Sampler2D]],
                 NORMAL_CHANNEL: Layout[1, Uniform[Sampler2D]],
                 DEPTH_CHANNEL: Layout[2, Uniform[Sampler2D]],
                 UV: Vec2,
                 COLOR: var Vec4) =
    var 
        fragCoord = UV * FRAME.RESOLUTION.xy
        snow = 0.0
        gradient = (1.0 - float(fragCoord.y / FRAME.RESOLUTION.x)) * 0.4
        random = fract(sin(dot(fragCoord.xy, vec2(12.9898,78.233))) * 43758.5453)
    for k in 0..5:
        for i in 0..11:
            var 
                cellSize = 2.0 + (float(i) * 3.0)
                downSpeed = 0.3 + (sin(FRAME.TIME * 0.4 + float(k + i * 20)) + 1.0) * 0.00008
                uv = (fragCoord.xy / FRAME.RESOLUTION.x) + vec2(0.01 * sin((FRAME.TIME + float(k * 6185)) * 0.6 + float(i)) * (5.0 / float(i)), downSpeed * (FRAME.TIME + float(k*1352)) * (1.0 / float(i)))
                uvStep = (ceil((uv) * cellSize - vec2(0.5,0.5)) / cellSize)
                x = fract(sin(dot(uvStep, vec2(12.9898 + float(k) * 12.0, 78.233 + float(k) * 315.156))) * 43758.5453 + float(k) * 12.0) - 0.5
                y = fract(sin(dot(uvStep, vec2(62.2364 + float(k) * 23.0, 94.674 + float(k) * 95.0))) * 62159.8432 + float(k) * 12.0) - 0.5
                randomMagnitude1 = sin(FRAME.TIME * 2.5) * 0.7 / cellSize
                randomMagnitude2 = cos(FRAME.TIME * 2.5) * 0.7 / cellSize
                d = 5.0 * distance((uvStep.xy + vec2(x * sin(y), y) * randomMagnitude1 + vec2(y,x) * randomMagnitude2), uv.xy)
                omiVal = fract(sin(dot(uvStep.xy, vec2(32.4691,94.615))) * 31572.1684)
            
            if omiVal < 0.08:
                let newd = (x+1.0)*0.4*clamp(1.9-d*(15.0+(x*6.3))*(cellSize/1.4),0.0,1.0)
                snow += newd

    COLOR = texture(COLOR_CHANNEL, UV) + vec4(snow) + gradient * vec4(0.4, 0.8, 1.0, 0.0) + random * 0.01

# Direct translation of https://www.shadertoy.com/view/4sX3z2 to nim
proc snowEffect2*(CAMERA: Uniform[Camera],
                 FRAME: Uniform[Frame],
                 COLOR_CHANNEL: Layout[0, Uniform[Sampler2D]],
                 NORMAL_CHANNEL: Layout[1, Uniform[Sampler2D]],
                 DEPTH_CHANNEL: Layout[2, Uniform[Sampler2D]],
                 UV: Vec2,
                 COLOR: var Vec4) =
    var 
        LAYERS = 20
        DEPTH = 0.5
        WIDTH = 0.3
        SPEED = 0.6
        p = mat3(13.323122,23.5112,21.71123,21.1212,28.7312,11.9312,21.8112,14.7212,61.3934)
        acc = vec3(0.0)
        dof = 5.0 * sin(FRAME.TIME * 0.1)
        uv = UV * FRAME.RESOLUTION.x / FRAME.RESOLUTION.y
    for i in 0..<LAYERS:
        var fi = i.float
        var q = uv * (1.0 + fi * DEPTH)
        q = q + vec2(q.y * (WIDTH * fi*7.238917 mod 1.0 - WIDTH * 0.5), SPEED * FRAME.TIME / (1.0 + fi * DEPTH * 0.03))
        var 
            n = vec3(floor(q), 31.189 + fi)
            m = floor(n) * 0.00001 + fract(n)
            mp = (m + 31415.9) / fract(p * m)
            r = fract(mp)
            s = abs(q mod 1.0 - 0.5 + 0.9 * r.xy - 0.45)
        s += 0.01 * abs(2.0 * fract(10.0 * q.yx) - 1.0);
        var 
            d = 0.6 * max(s.x - s.y, s.x + s.y) + max(s.x, s.y) - 0.01
            edge = 0.005 + 0.05 * min(0.5 * abs(fi - 5.0 - dof), 1.0)
        acc = acc + vec3(smoothstep(edge, -edge, d) * (r.x / (1.0 + 0.02 * fi * DEPTH)))
    COLOR = texture(COLOR_CHANNEL, UV)
    COLOR.rgb = COLOR.rgb + acc

