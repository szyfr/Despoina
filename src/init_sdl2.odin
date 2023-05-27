package main


//= Imports
import "vendor:sdl2"

import "engine"
import "debug"


//= Procedures
init_sdl2 :: proc() {
	if sdl2.Init( {.VIDEO} ) != 0 {
		debug.log("[ERROR] - Failed to initialize SDL2.")
		return
	}

	engine.window = sdl2.CreateWindow(
		"Despoina",
		sdl2.WINDOWPOS_UNDEFINED,
		sdl2.WINDOWPOS_UNDEFINED,
		160 * engine.SCREEN_SIZE_MOD,
		144 * engine.SCREEN_SIZE_MOD,
		sdl2.WINDOW_SHOWN,
	)
	if engine.window == nil {
		debug.log("[ERROR] - Failed to create window.")
		return
	}

	engine.surface = sdl2.GetWindowSurface( engine.window )
	if engine.surface == nil {
		debug.log("[ERROR] - Failed to create surface.")
		return
	}

	sdl2.FillRect(
		engine.surface,
		nil,
		sdl2.MapRGB( engine.surface.format, 0, 0, 0 ),
	)
	sdl2.UpdateWindowSurface( engine.window )
}