	bits 64

	section .bss

	section .data

player_x:	dd 0
player_y:	dd 0
player_w:	dd 90
player_h:	dd 90

message:	dw 'Hello, world!', 0

	section .text

	global main

	%define PLAYER_SPEED 300

	;; 
	;; Raylib
	;; 

	;; Window managing and initialization
	extern InitWindow, CloseWindow, WindowShouldClose, SetTargetFPS

	;; Drawing
	extern BeginDrawing, EndDrawing, ClearBackground, DrawRectangle

	;; Input
	extern IsKeyPressed, IsKeyDown
	%include "pong_input.inc"

	;; Time
	extern GetFrameTime


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
	jne .main__exit

	;; Update

	call GetFrameTime

	movss dword 4[rsp], xmm0 	; store delta time from GetFrameTime
	mov dword 8[rsp], PLAYER_SPEED	; store player_speed

	cvtsi2ss xmm0, dword 8[rsp]	; convert player_speed to floating-point
	mulss xmm0, dword 4[rsp]	; actual floating-point multiplication

	cvttss2si r10D, xmm0 	; convert floating-point result to integer

	mov rcx, KEY_A
	call IsKeyDown  ; bool IsKeyDown(int key) 
	cmp rax, 0
	je .main__L0
	sub dword [player_x], r10D

.main__L0:

	mov rcx, KEY_D
	call IsKeyDown  ; bool IsKeyDown(int key) 
	cmp rax, 0
	je .main__L1
	add dword [player_x], r10D

.main__L1:

	;; Render

	call BeginDrawing

	mov rcx, 0x00AFAFAF
	call ClearBackground

	mov ecx, dword [player_x]     ; posX
	mov edx, dword [player_y]     ; posY
	mov r8D, dword [player_w]     ; width
	mov r9D, dword [player_h]     ; height
	mov dword 32[rsp], 0xFFFFFFFF ; color
	call DrawRectangle ; void DrawRectangle(int posX, int posY, int width, int height, Color color);

	call EndDrawing

	jmp .main__loop_begin

.main__exit:
	call CloseWindow
	xor rax, rax

	add rsp, 64
	pop rbp
	ret
