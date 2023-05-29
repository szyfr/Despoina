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
	sram = make([]u8, 4890624)
	defer delete(sram)
	wram = make([]u8, 4890624)
	defer delete(wram)
	vram = make([]u8, 4890624)
	defer delete(vram)

	//* Init CPU
	cpu = new(CPU)
	cpu.pc = 0x0100
	cpu.curCyc = 1
	cpu.curOp = Instruction(memoryMap[cpu.pc])
	memoryMap[0xFE00] = 1
	
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
				if event.key.keysym.sym == .RETURN {//&& event.key.repeat == 0 && !keyStopper {
					keyStopper = true
					cycle()
				}
				if event.key.keysym.sym == .O && event.key.repeat == 0 && !keyStopper {
					keyStopper = true
					fmt.printf("A: %2X\nBC: %4X\nXY: %4X\n\n",cpu.a,cpu.bc,cpu.xy)
					for i in 0..<20 {
						fmt.printf("%2X-",vram[i])
					}
					fmt.printf("\n")
				}
			case .KEYUP:
				if (event.key.keysym.sym == .RETURN || event.key.keysym.sym == .O) && event.key.repeat == 0 && keyStopper {
					keyStopper = false
				}
		}

		//* Calculate FPS
		fps := frames / (f64(timer_getticks(fpsTimer)) / 1000)

		//* Update
		update()
		//thread.run(update)

		//* Draw
		//thread.run(draw)
		draw()
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
	for i in 0..<(144*160)/4 {
		//graphics.draw_pixel(
		//	i32(i%160), i32(i/160),
		//	[4]u8{
		//		engine.vram[(i * 3)],
		//		engine.vram[(i * 3)+1],
		//		engine.vram[(i * 3)+2],
		//		255},
		//)
		for o in 0..<4 {
			color : engine.Color = get_color( engine.vram[i], u8(o) )
			graphics.draw_pixel(
				i32(i%160), i32(i/160),
				color,
			)
		}
	}
	off += 1

	sdl2.UpdateWindowSurface( engine.window )
}

get_color :: proc( input : u8, pos : u8 ) -> engine.Color {
	value : u8 = input << pos * 2
	color : engine.Color

	switch {
		case (value | 0b00000000) != 0: color = engine.COL_0
		case (value | 0b01000000) != 0: color = engine.COL_1
		case (value | 0b10000000) != 0: color = engine.COL_2
		case (value | 0b11000000) != 0: color = engine.COL_3
	}
	return color
}