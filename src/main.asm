

;;= Structure includes
;%include "src/macros/oc_sdl2.asm"
extern ExitProcess
extern SDL_Init
extern SDL_CreateWindow
extern SDL_GetWindowSurface
extern SDL_MapRGB
extern SDL_FillRect
extern SDL_UpdateWindowSurface
extern SDL_PollEvent
extern SDL_DestroyWindow
extern SDL_Quit

SDL_INIT_VIDEO			equ 0x00000020
SDL_WINDOWPOS_UNDEFINED equ 0x1FFF0000
SDL_WINDOW_SHOWN		equ 0x00000004
SDL_QUIT_CODE			equ 0x100


;;= Header
global main
section .text


;;= Main
main:
	sub rsp,8

	call init_sdl

	mov byte[running],1
.loop:
	;* SDL_PollEvent
	sub rsp,32
	mov rcx,event
	call SDL_PollEvent
	add rsp,32

	mov rdx,0
	mov ecx,[event]
	cmp ecx,SDL_QUIT_CODE
	mov rcx,1
	cmove ecx,edx
	mov [running],cl

	;;= Update

	;;= Draw


	mov cl,[running]
	cmp cl,1
	je .loop

.exit:

	;* ExitProcess
	mov ecx,0
	call ExitProcess



;;= Function Includes
%include "src/engine/sdl2/init_sdl.asm"


;;= Data Includes


;;= Variables
WindowName : db "Hecate",0

section .bss
%include "src/variables.asm"