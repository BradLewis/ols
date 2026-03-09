package main

import "core:math/rand"
import rl "vendor:raylib"

WIDTH :: 1920
HEIGHT :: 1200


Rect :: struct {
	x, y, vx, vy, width, height: i32,
	colour_index:                int,
}

update_rect :: proc(r: ^Rect) {
	if r.x < 0 || r.x + r.width > WIDTH {
		r.vx *= -1
		r.colour_index += 1
	}
	if r.y < 0 || r.y + r.height > HEIGHT {
		r.vy *= -1
		r.colour_index += 1
	}
	r.x += r.vx

	r.y += r.vy
}

main :: proc() {
	colours := [?]rl.Color{rl.RED, rl.WHITE, rl.PURPLE, rl.BLUE, rl.PINK, rl.GREEN, rl.GRAY, rl.YELLOW, rl.ORANGE, rl.VIOLET}
	rl.InitWindow(WIDTH, HEIGHT, "Hello, Marcel and Ella!")
	rl.SetTargetFPS(60)

	rects := []Rect {
		{0, 0, 4, 4, 1200, 1000, 0},
		{500, 199, -4, 4, 1200, 1000, 8},
		{100, 100, -14, 14, 100, 100, 4},
		{100, 100, 32, 32, 100, 100, 4},
		{100, 100, -16, -16, 100, 100, 4},
		{100, 100, 64, -64, 100, 100, 4},
	}
	rand_rects := make([dynamic]Rect, 10000)
	MAX_SPEED :: 20
	SIZE :: 5
	for &r in rand_rects {
		r.height = SIZE
		r.width = SIZE
		r.x = rand.int32_range(SIZE, WIDTH - SIZE)
		r.y = rand.int32_range(SIZE, HEIGHT - SIZE)
		r.vx = rand.int32_range(-1 * MAX_SPEED, MAX_SPEED)
		r.vy = rand.int32_range(-1 * MAX_SPEED, MAX_SPEED)
		r.colour_index = rand.int_range(0, 100)
	}
	for !rl.WindowShouldClose() {
		rl.ClearBackground(rl.BLACK)
		rl.BeginDrawing()
		for &r in rects {
			update_rect(&r)
			rl.DrawRectangle(r.x, r.y, r.width, r.height, colours[r.colour_index % len(colours)])
		}
		for &r in rand_rects {
			update_rect(&r)
			rl.DrawRectangle(r.x, r.y, r.width, r.height, colours[r.colour_index % len(colours)])
		}
		rl.EndDrawing()
	}
}

Foo :: struct {
	a, b: int,
}
