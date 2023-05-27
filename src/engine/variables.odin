package engine


//= Imports
import "vendor:sdl2"


//= Constants
SCREEN_SIZE_MOD :: 6
SCREEN_TICKS_PER_FRAME :: 1000 / 60


//= Structs
Vector2 :: struct {
	x, y : i32,
}
Color :: struct {
	r, g, b, a : u8,
}


//= Global Variables
window	: ^sdl2.Window
surface : ^sdl2.Surface
event	:  sdl2.Event

running := true