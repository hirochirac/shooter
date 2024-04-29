package main

import "core:fmt"
import ry "vendor:raylib"
import mth "core:math"
import rnd "core:math/rand"

TITLE :: "Shooter"
HEIGHT :: 800
WIDTH :: 1024
TAU :: mth.PI * 2


triangle :: struct {
    position: ry.Vector2,
    vertex1: ry.Vector2,
    vertex2: ry.Vector2,
    vertex3: ry.Vector2,
    dx: f32,
    dy: f32,
    r: f32,
}

shoot :: struct {
    position : ry.Vector2,
    angle: f32,
}



main :: proc () {

    lasers: [dynamic]shoot
    defer delete(lasers)

    timeElapsed  : f32 = -1.0
    shootElapsed : f32 = 20.0
    tir          : shoot = {}

    angle : f32 = 0
    t := init_triangle()

    ry.SetTraceLogLevel(ry.TraceLogLevel.NONE);
    ry.SetTargetFPS(60)

    ry.InitWindow(WIDTH,HEIGHT,TITLE)
    defer ry.CloseWindow()

    for !ry.WindowShouldClose() {
       
        if (timeElapsed > 0) {
        
            if ry.IsKeyDown(ry.KeyboardKey.UP) {
                t.dx = t.dx - mth.cos_f32(t.r)
                t.dy = t.dy - mth.sin_f32(t.r)
            } else if ry.IsKeyDown(ry.KeyboardKey.LEFT) {
                t.r = t.r + 0.01
            } else if ry.IsKeyDown(ry.KeyboardKey.RIGHT) {
                t.r = t.r - 0.01
            } else if ry.IsKeyDown(ry.KeyboardKey.DOWN) {
                t.dx = 0
                t.dy = 0
            }

            timeElapsed = timeElapsed - ry.GetFrameTime()    
            t.position.x = t.position.x + t.dx * ry.GetFrameTime()
            t.position.y = t.position.y + t.dy * ry.GetFrameTime()
        
        } else {
            timeElapsed = 10
        }

        if ry.IsKeyDown(ry.KeyboardKey.SPACE) && shootElapsed >= 1 {
                tir.angle = t.r
                tir.position.x = t.position.x - mth.cos_f32(tir.angle) * 20.0
                tir.position.y = t.position.y - mth.sin_f32(tir.angle) * 20.0
                append(&lasers,tir)
                shootElapsed = 0.0
        }

        shootElapsed = shootElapsed + ry.GetFrameTime()

        fmt.printf("%f\n",shootElapsed)

        if ( t.position.x >= WIDTH ) {
            t.position.x = 0
        }

        if ( t.position.x < 0) {
            t.position.x = WIDTH
        }

        if ( t.position.y >= HEIGHT ) {
            t.position.y = 0
        }

        if ( t.position.y < 0) {
            t.position.y = HEIGHT
        }


        ry.BeginDrawing()

        ry.ClearBackground(ry.BLACK)


        if timeElapsed > 0.0 {
            draw_triangle(t,3.5)
        }

        for j in 0 ..< len(lasers) {
            if lasers[j].position.x <= 0 || lasers[j].position.x >= f32(ry.GetScreenWidth()) || lasers[j].position.y <= 0 || lasers[j].position.y >= f32(ry.GetScreenHeight()) {
                ordered_remove(&lasers,j)
            }
        }

        for l in 0..< len(lasers) {
            ry.DrawRectangleRec({lasers[l].position.x, lasers[l].position.y,10,3},ry.RED)
            lasers[l].position.x = lasers[l].position.x - mth.cos_f32(lasers[l].angle) * ry.GetFrameTime() * 100
            lasers[l].position.y = lasers[l].position.y - mth.sin_f32(lasers[l].angle) * ry.GetFrameTime() * 100
        }

        ry.EndDrawing()

    }

    
}

m :: proc ( a: f32, b: f32 ) -> f32 {
    if ( a > b) {
        return b
    } else {
        return a
    }
}


init_modelAsteroid :: proc () -> [dynamic]ry.Vector2 {
    modelAsteroids : [dynamic]ry.Vector2 
    e: ry.Vector2
    noise: f32
    rand : rnd.Rand

    modelAsteroids = make([dynamic]ry.Vector2,0,20)


    for i, idx in modelAsteroids {
        rand = rnd.create(100.0)
        noise = rnd.float32_range(-1,1,&rand)
        e = {
            noise * mth.sin_f32(f32(idx/20) * mth.PI), 
            noise * mth.cos_f32(f32(idx/20) * mth.PI), 
        }
        append(&modelAsteroids,e)
    }


    return modelAsteroids
}

init_triangle :: proc (position := ry.Vector2{WIDTH/2,HEIGHT/2}) -> triangle {

    t : triangle = {
        position = position,
        r = 0,
        vertex1 = {0.0,-5.0},
        vertex2 = {-2.5,2.5},
        vertex3 = {2.5,2.5},
    }

    return t

}

draw_triangle :: proc ( t: triangle, s: f32 ) {

    temp : triangle = {}
    temp.vertex1.x = t.vertex1.x * (-1.0 * mth.sin_f32(t.r)) + t.vertex1.y * mth.cos_f32(t.r)
    temp.vertex1.y = t.vertex1.x * mth.cos_f32(t.r) + t.vertex1.y * mth.sin_f32(t.r)

    temp.vertex2.x = t.vertex2.x * (-1.0 * mth.sin_f32(t.r)) + t.vertex2.y * mth.cos_f32(t.r)
    temp.vertex2.y = t.vertex2.x * mth.cos_f32(t.r) + t.vertex2.y * mth.sin_f32(t.r)

    temp.vertex3.x = t.vertex3.x * (-1.0 * mth.sin_f32(t.r)) + t.vertex3.y * mth.cos_f32(t.r)
    temp.vertex3.y = t.vertex3.x * mth.cos_f32(t.r) + t.vertex3.y * mth.sin_f32(t.r)
    
    temp.vertex1.x = temp.vertex1.x * s
    temp.vertex1.y = temp.vertex1.y * s 

    temp.vertex2.x = temp.vertex2.x * s
    temp.vertex2.y = temp.vertex2.y * s
    
    temp.vertex3.x = temp.vertex3.x * s
    temp.vertex3.y = temp.vertex3.y * s


    temp.vertex1.x = temp.vertex1.x + t.position.x
    temp.vertex1.y = temp.vertex1.y + t.position.y

    temp.vertex2.x = temp.vertex2.x + t.position.x
    temp.vertex2.y = temp.vertex2.y + t.position.y

    temp.vertex3.x = temp.vertex3.x + t.position.x
    temp.vertex3.y = temp.vertex3.y + t.position.y

    ry.DrawTriangleLines(temp.vertex1,temp.vertex2,temp.vertex3,ry.WHITE)
    

}