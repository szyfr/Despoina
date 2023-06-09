package engine


//= Imports
import "vendor:sdl2"


//= Constants
SCREEN_SIZE_MOD :: 6
SCREEN_TICKS_PER_FRAME :: 1000 / 60

COL_0 :: Color{ 0, 0, 0, 255 }
COL_1 :: Color{ 155, 188,  12, 255 }
COL_2 :: Color{ 139, 172,  12, 255 }
COL_3 :: Color{  12,  54,  12, 255 }


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

play	: bool = false


cpu		: ^CPU

rom		: []u8
sram	: []u8
wram	: []u8
vram	: []u8

//sram	: [4890624]u8
//wram	: [4890624]u8
//vram	: [4890624]u8

memoryMap	: [0x10000]u8