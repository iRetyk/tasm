IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
num1 db ?
num2 db ?


CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------

	mov ah, 1
	int 21h
	mov [num1], al
	int 21h
	mov [num2], al
	xor cx,cx
	mov cl, [num1]
Loop1:
	mov ax, cx
	xor cx, cx
	mov cl, [num2]
Loop2:
	mov dl, 'X'
	mov ah, 2
	int 21h
	loop Loop2
	
	mov cx, ax
	loop Loop1


exit:
	mov ax, 4c00h
	int 21h
END start


