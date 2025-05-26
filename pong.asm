	bits 64

	section .bss
	section .data

message:	dw 'Hello, world!', 0

	section .text

	global main

	extern InitWindow, CloseWindow, WindowShouldClose, SetTargetFPS
	extern BeginDrawing, EndDrawing, ClearBackground

;
; Calling convention (Windows ?)
;
; rax | return address.
; rcx | 1st argument
; rdx | 2nd argument
; r8  | 3rd argument
; r9  | 4th argument
;
; 
; Calling convention (C calling convention)
;
; rax | return address.
; rdi | 1th
; rsi | 2nd
; rdx | 3rd
; rcx | 4th
; r8  | 5th
; r9  | 6th
;

main:
	push rbp
	mov rbp, rsp
	sub rsp, 64

	mov rcx, 800 * 2
	mov rdx, 450 * 2
	mov r8, message
	call InitWindow

	mov rcx, 60
	call SetTargetFPS      	; bool SetTargetFPW(int fps);

.main__loop_begin:
	call WindowShouldClose  ; bool WindowShouldClose(void)
	cmp rax, 0
	jne .main__loop_end

	call BeginDrawing

	mov rcx, 0x00AFAFAF
	call ClearBackground

	call EndDrawing

	jmp .main__loop_begin

.main__loop_end:
	call CloseWindow

.main__exit:
	xor rax, rax

	mov rsp, rbp
	pop rbp
	ret
