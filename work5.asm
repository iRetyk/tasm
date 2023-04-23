IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
firstName db "Idan"
age db 15
age2 dw 15
lastName db "Retyk"




CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------
mov [5h], al

mov bx ,0bfddh


mov ax ,bl
mov bl, bh
mov bh, ax

mov bh,[16h]
mov [6h], bh

mov ah, [5h]
mov al, [03h]
mov [3h], ah


mov [1], 41h


mov [byte 16], 1110000b
mov [byte 0ah], 240d
mov [byte 0bh], -16d


exit:
	mov ax, 4c00h
	int 21h
END start



