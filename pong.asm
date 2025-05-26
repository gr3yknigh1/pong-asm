
	%define PLAYER_SPEED 	300
	%define PLAYER_W   	20
	%define PLAYER_H	120

	%define WINDOW_W	1600
	%define WINDOW_H	900

	%define BALL_W		30
	%define BALL_H		30
	%define BALL_SPEED 	330

	bits 64

	section .bss

	section .data

window_w:	dd WINDOW_W
window_h:	dd WINDOW_H

;;; TODO: make second player!
player_x:	dd                PLAYER_W / 2
player_y:	dd WINDOW_H / 2 - PLAYER_H / 2
player_w:	dd PLAYER_W
player_h:	dd PLAYER_H

ball_x:		dd WINDOW_W / 2 - BALL_W / 2
ball_y:		dd WINDOW_H / 2 - BALL_H / 2
ball_w:		dd BALL_W
ball_h:		dd BALL_H

ball_dir_x:	dd -1
ball_dir_y:	dd 0

message:	dw 'Hello, world!', 0

	section .text

	global main

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

	mov rcx, [window_w]
	mov rdx, [window_h]
	mov r8, message
	call InitWindow

	mov rcx, 60
	call SetTargetFPS      	; bool SetTargetFPW(int fps);

.main__loop_begin:
	call WindowShouldClose  ; bool WindowShouldClose(void)
	cmp rax, 0
	jne .main__exit

	;; --------------------------------------------------------------------
	;; Update
	;; --------------------------------------------------------------------

	call GetFrameTime

	movss dword 4[rsp], xmm0 	; store delta time from GetFrameTime

	;; 
	;; Calculating velocity for player.
	;; 
	mov dword 8[rsp], PLAYER_SPEED	; store player_speed
	cvtsi2ss xmm1, dword 8[rsp]	; convert player_speed to floating-point
	mulss xmm1, dword 4[rsp]	; actual floating-point multiplication
	cvttss2si r10D, xmm1 	; convert floating-point result to integer

	;; 
	;; Calculating velocity for ball.
	;; 
	mov dword 8[rsp], BALL_SPEED
	cvtsi2ss xmm1, dword 8[rsp]
	mulss xmm1, dword 4[rsp]
	cvttss2si r11D, xmm1

	mov dword 8[rsp], r11D 	; storing ball velocity
	imul r11D, [ball_dir_x]
	add [ball_x], r11D

	mov r11D, dword 8[rsp]
	imul r11D, [ball_dir_y]
	add [ball_x], r11D

	;; 
	;; Handle input for player movement
	;; 

	mov rcx, KEY_W
	call IsKeyDown  ; bool IsKeyDown(int key) 
	cmp rax, 0
	je .main__L0
	sub dword [player_y], r10D

.main__L0:

	mov rcx, KEY_S
	call IsKeyDown  ; bool IsKeyDown(int key) 
	cmp rax, 0
	je .main__L1
	add dword [player_y], r10D

.main__L1:

	mov rcx, KEY_Q
	call IsKeyDown
	cmp rax, 0
	je .main__L3
	jmp .main__exit

.main__L3:

	;; --------------------------------------------------------------------
	;; Render
	;; --------------------------------------------------------------------

	call BeginDrawing

	mov rcx, 0x00AFAFAF
	call ClearBackground

	mov ecx, dword [player_x]     ; posX
	mov edx, dword [player_y]     ; posY
	mov r8D, dword [player_w]     ; width
	mov r9D, dword [player_h]     ; height
	mov dword 32[rsp], 0xFFFFFFFF ; color
	call DrawRectangle ; void DrawRectangle(int posX, int posY, int width, int height, Color color);

	mov ecx, dword [ball_x]     ; posX
	mov edx, dword [ball_y]     ; posY
	mov r8D, dword [ball_w]     ; width
	mov r9D, dword [ball_h]     ; height
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
