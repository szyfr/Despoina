package engine


//= Imports
import "vendor:sdl2"


//= Structures
Timer :: struct {
	started, paused : bool,

	startTicks, pausedTicks : u32,
}


//= Procedures
timer_start :: proc( timer : ^Timer ) {
	timer.started = true
	timer.paused = false
	timer.startTicks = sdl2.GetTicks()
	timer.pausedTicks = 0
}
timer_stop :: proc( timer : ^Timer ) {
	timer.started = false
	timer.paused = false
	timer.startTicks = 0
	timer.pausedTicks = 0
}
timer_pause :: proc( timer : ^Timer ) {
	if timer.started && !timer.paused {
		timer.paused = true
		timer.pausedTicks = sdl2.GetTicks() - timer.startTicks
		timer.startTicks = 0
	}
}
timer_unpause :: proc( timer : ^Timer ) {
	if timer.started && timer.paused {
		timer.paused = false
		timer.startTicks = sdl2.GetTicks() - timer.pausedTicks
		timer.pausedTicks = 0
	}
}
timer_getticks :: proc( timer : ^Timer ) -> u32 {
	time : u32 = 0

	if timer.started {
		if timer.paused do time = timer.pausedTicks
		else do time = sdl2.GetTicks() - timer.startTicks
	}

	return time
}