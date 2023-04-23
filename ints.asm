IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
num1 db ?
num2 db ?
result db ?
niceResult db "xXx=x$"
newLine db 10,13,'$'
input db "5x1234x"
BigStr db "5x1234x"
SmallStr db "1234$"


CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------

;ex1
mov ah, 1h
int 21h
mov [num1], al
mov ah, 1h
int 21h
mov [num2], al

sub [num1], '0'
sub [num2], '0'

mov al, [num1]
mov bl, [num2]
mul bl

add al, '0'
mov [result], al
mov dl,[result]
mov ah, 2
int 21h

;ex2
mov dx, offset newLine
mov ah, 9
int 21h

mov ah, 1h
int 21h
mov [num1], al
mov ah, 1h
int 21h
mov [num2], al

sub [num1], '0'
sub [num2], '0'

mov al, [num1]
mov bl, [num2]
mul bl
mov [result], al

add [num1], '0'
add [num2], '0'
add [result], '0'



mov bl, [num1]
mov [niceResult], bl
mov bl, [num2]
mov [niceResult + 2], bl
mov bl, [result]
mov [niceResult + 4], bl

mov dx, offset newLine
mov ah, 9
int 21h

mov dx, offset niceResult
mov ah, 9h
int 21h

;ex3
mov dx, offset newLine
mov ah, 9
int 21h

mov dx, offset input
mov ah, 0ah
int 21h

mov dx, offset newLine
mov ah, 9
int 21h

mov ah, 2h
mov dl, [input + 5]
int 21h
mov dl, [input + 4]
int 21h
mov dl, [input + 3]
int 21h
mov dl, [input + 2]
int 21h

;ex4
mov dx, offset newLine
mov ah, 0ah
int 21h

mov dx, offset BigStr
mov ah ,0ah
int 21h

or [BigStr +2], 20h
or [BigStr +3], 20h
or [BigStr +4], 20h
or [BigStr +5], 20h

mov al, [BigStr +2]
mov[SmallStr], al
mov al, [BigStr +3]
mov[SmallStr +1], al
mov al, [BigStr +4]
mov[SmallStr +2], al
mov al, [BigStr +5]
mov[SmallStr +3], al

mov ah, 9h
mov dx, offset newLine
int 21h
mov ah, 9h
mov dx, offset SmallStr
int 21h



exit:
	mov ax, 4c00h
	int 21h
END start


