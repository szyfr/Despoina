package main


//= Imports
import "core:fmt"

import "vendor:sdl2"

import "engine"
import "engine/graphics"
import "debug"


//= Main
off : i32 = 0

main :: proc() {
	using engine

	init_sdl2()

	fpsTimer := new(Timer)
	capTimer := new(Timer)
	timer_start(fpsTimer)
	frames : f64 = 0
	
	for running {
		timer_start(capTimer)

		sdl2.PollEvent( &event )
		#partial switch event.type {
			case .QUIT:
				running = false
		}

		//* Calculate FPS
		fps := frames / (f64(timer_getticks(fpsTimer)) / 1000)


		//* Update
		

		//* Draw
		for i in 0..<144*160 {
			graphics.draw_pixel(i32(i%160), i32(i/160), [4]u8{u8(off),u8(off),u8(off),255})
		}
		off += 1

		sdl2.UpdateWindowSurface( window )
		frames += 1

		frameTicks := timer_getticks(capTimer)
		if frameTicks < SCREEN_TICKS_PER_FRAME do sdl2.Delay( SCREEN_TICKS_PER_FRAME - frameTicks )
	}

}