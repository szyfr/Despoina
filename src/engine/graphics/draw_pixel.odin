package graphics


//= Imports
import "../../engine"


//= Procedures
draw_pixel :: proc( x, y : i32, color : [4]u8 ) {
	using engine

	newX := x * SCREEN_SIZE_MOD
	newY := y * SCREEN_SIZE_MOD

	for y:i32=0;y<SCREEN_SIZE_MOD;y+=1 {
		for x:i32=0;x<SCREEN_SIZE_MOD;x+=1 {
			position := (((newY + y) * engine.surface.w) + (newX + x)) * 4

			([^]byte)(engine.surface.pixels)[position + 0] = color[0]
			([^]byte)(engine.surface.pixels)[position + 1] = color[1]
			([^]byte)(engine.surface.pixels)[position + 2] = color[2]
			([^]byte)(engine.surface.pixels)[position + 3] = color[3]
		}
	}
}

draw_minor_pixel :: proc( x, y : i32, color : [4]u8 ) {
	
}