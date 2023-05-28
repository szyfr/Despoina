package main


//= Imports
import "core:fmt"
import "core:os"
import "core:thread"

import "vendor:sdl2"

import "engine"
import "engine/graphics"
import "debug"


//= Main
off : u8 = 0
keyStopper : bool = false

main :: proc() {
	using engine

	init_sdl2()

	//* Initialize timers
	fpsTimer := new(Timer)
	capTimer := new(Timer)
	timer_start(fpsTimer)
	frames : f64 = 0

	//* Init ROM
	result := false
	rom, result = os.read_entire_file_from_filename("data/boot.bin")
	// TODO Create file loading function
	if !result {
		debug.log("[ERROR] - Failed to load boot ROM")
		return
	}
	if len(rom) < 0x8000 {
		debug.log("[ERROR] - Boot ROM not correct size")
		return
	}
	for i in 0..<0x8000 {
		memoryMap[i] = rom[i]
	}

	//* Init CPU
	cpu = new(CPU)
	cpu.pc = 0x0100
	cpu.curCyc = 1
	cpu.curOp = Instruction(memoryMap[cpu.pc])
	
	for running {
		timer_start(capTimer)

		//* Poll Events
		sdl2.PollEvent( &event )
		#partial switch event.type {
			case .QUIT:
				running = false
			case .DROPFILE:
				fmt.printf("%v\n",event.drop.file)
			case .KEYDOWN:
				if event.key.keysym.sym == .RETURN && event.key.repeat == 0 && !keyStopper {
					keyStopper = true
					cycle()
				}
			case .KEYUP:
				if event.key.keysym.sym == .RETURN && event.key.repeat == 0 && keyStopper {
					keyStopper = false
				}
		}

		//* Calculate FPS
		fps := frames / (f64(timer_getticks(fpsTimer)) / 1000)

		//* Update
		//update()
		//thread.run(update)

		//* Draw
		thread.run(draw)
		//for i in 0..<144*160 {
		//	graphics.draw_pixel(i32(i%160), i32(i/160), [4]u8{u8(off),u8(off),u8(off),255})
		//}
		//off += 1
		//sdl2.UpdateWindowSurface( window )


		//* Cap framerate
		frames += 1
		frameTicks := timer_getticks(capTimer)
		if frameTicks < SCREEN_TICKS_PER_FRAME do sdl2.Delay( SCREEN_TICKS_PER_FRAME - frameTicks )
		//fmt.printf("%v\n",fps)
	}

}

draw :: proc() {
	for i in 0..<144*160 {
		graphics.draw_pixel(i32(i%160), i32(i/160), [4]u8{u8(off),u8(off),u8(off),255})
	}
	off += 1

	sdl2.UpdateWindowSurface( engine.window )
}