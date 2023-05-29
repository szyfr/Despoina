package graphics


//= Imports
import "../../engine"


//= Procedures
draw_pixel :: proc( x, y : i32, color : engine.Color ) {
	using engine

	newX := x * SCREEN_SIZE_MOD
	newY := y * SCREEN_SIZE_MOD

	for y:i32=0;y<SCREEN_SIZE_MOD;y+=1 {
		for x:i32=0;x<SCREEN_SIZE_MOD;x+=1 {
			position := (((newY + y) * engine.surface.w) + (newX + x)) * 4

			([^]byte)(engine.surface.pixels)[position + 0] = color.r
			([^]byte)(engine.surface.pixels)[position + 1] = color.g
			([^]byte)(engine.surface.pixels)[position + 2] = color.b
			([^]byte)(engine.surface.pixels)[position + 3] = color.a
		}
	}
}