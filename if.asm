IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
num1 db 8d
num2 db 6d
string db "Enter a two digit number$"
InputArea db "2x12x"
smll db "SMALL$"
mid db "MEDIUM$"
big db "BIG$"
equal db "EQUAL$"

num db ?
char db ?


CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------

;ex1
cmp ax,50d
jne Cont1
	add ax, ax
Cont1:

;ex2
mov bx, ax
or bl, 80h;this action will yield 10000000 if negative and 0 if positve
cmp bl, 0
je Cont2
	add ax, 1
Cont2:

;ex3
mov al, [num1]
cmp al, [num2]
jns Positve
	mov dx,0 ;if its negative if will go here
	js Negative
Positve:
	mov dx, 1
Negative:

mov bx, dx
add [num1], '0'
add [num2], '0'
mov dl,[num1]
mov ah, 2
int 21h
mov dl, [num2]
int 21h
mov dl, bl
int 21h

;ex4
mov ah, 9h
mov dl, offset string
int 21h
mov ah, 0ah
mov dl ,offset InputArea
int 21h

sub [InputArea + 2], '0'
sub [InputArea + 3], '0'

mov bl, [InputArea + 2]
mov al, 10d
mul bl
add al, [InputArea + 3]
;ax now contains the input

mov bx, 50d
cmp bx, ax
jns BiggerThan50
	mov dl, offset smll
	mov ah, 09h
	int 21h
	jmp Done
BiggerThan50:
	mov bx, 75d
	cmp bx, ax
	jne Not75
		mov dl , offset equal
		mov ah, 09h
		int 21h
		jmp Done
Not75:
	jg MoreThan75
		mov dl, offset mid
		mov ah, 9h
		int 21h
		jmp Done
MoreThan75:
	mov dl ,offset big
	mov ah, 9h
	int 21h
Done:


;ex5
mov ah, 1
int 21h
mov [num], al
int 21h
mov [char], al

mov dl, [char]
mov ah, 2
mov al, [num]
NotZero:
	int 21h
	sub al, 1
	cmp al, 0
	je Zero
	jne NotZero
Zero:
	
exit:
	mov ax, 4c00h
	int 21h
END start


