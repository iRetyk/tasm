IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
array db ?,?,?,?
var1 db ?
var2 db ?
sum dw ?


array1 db 9,8,7,6
array2 db 7,2,4,4
array3 db ?,?,?,?
CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------
mov [array] ,15
mov [array + 1], 13
mov [array + 2], 28
mov [array + 3], 4

add al, [array]
add al, [array + 1]
add al, [array + 2]
add al, [array + 3]

add ax, [var1]
add ax, [var2]
mov [sum], ax



exit:
	mov ax, 4c00h
	int 21h
END start


