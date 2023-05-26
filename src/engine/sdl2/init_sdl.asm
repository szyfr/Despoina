

;;== init_sdl
;;=  Initializes sdl
;;= Size-b


init_sdl:
	push rbp
	mov rbp,rsp


	;* SDL_Init(SDL_INIT_VIDEO)
	sub rsp,32
	mov ecx,SDL_INIT_VIDEO
	call SDL_Init
	add rsp,32

	test eax,eax
	js main.exit

	;* SDL_CreateWindow
	sub rsp,96
	mov rcx,WindowName
	mov edx,SDL_WINDOWPOS_UNDEFINED		; Window position X
	mov r8d,SDL_WINDOWPOS_UNDEFINED		; Window position Y
	mov r9d,1280						; Window width
	mov dword[rsp+32],720				; Window height
	mov dword[rsp+40],SDL_WINDOW_SHOWN	; Tags
	call SDL_CreateWindow
	add rsp,96

	test rax,rax
	js main.exit
	mov [window],rax

	;* SDL_GetWindowSurface
	sub rsp,32
	mov rcx,rax
	call SDL_GetWindowSurface
	add rsp,32
	mov [surface],rax

	;* SDL_MapRGB
	sub rsp,32
	mov rcx,[rax+8]
	mov rdx,0
	mov r8,0
	mov r9,0
	call SDL_MapRGB
	add rsp,32

	;* SDL_FillRect
	sub rsp,64
	mov rcx,[surface]
	mov rdx,0
	mov r8,rax
	call SDL_FillRect
	add rsp,64

	;* SDL_UpdateWindowSurface
	sub rsp,64
	mov rcx,[window]
	call SDL_UpdateWindowSurface
	add rsp,64


	mov rsp,rbp
	pop rbp
	ret