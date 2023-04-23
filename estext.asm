IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
mov di,0b800h	
mov es,di
mov al,'E'
mov ah,00000001b
mov [es:3000],ax
mov al,'y'
mov ah,00000010
mov [es:3002],ax
mov al,'a'
mov ah,00000101b
mov [es:3004],ax
mov al,'l'
mov ah,00001000b
mov [es:3006],ax;;משימה 1

mov al,'I'
mov ah,00010000b
mov [es:3970],ax

mov al,"'"
mov ah,00010000b
mov [es:3972],ax

mov al,'m'
mov ah,00010000b
mov [es:3974],ax

mov al,' '
mov ah,00010000b
mov [es:3976],ax

mov al,'u'
mov ah,00010000b
mov [es:3978],ax

mov al,'s'
mov ah,00010000b
mov [es:3980],ax

mov al,'i'
mov ah,00010000b
mov [es:3982],ax

mov al,'n'
mov ah,00010000b
mov [es:3984],ax

mov al,'g'
mov ah,00010000b
mov [es:3986],ax

mov al,' '
mov ah,00010000b
mov [es:3988],ax

mov al,'B'
mov ah,00010000b
mov [es:3990],ax

mov al,'8'
mov ah,00010000b
mov [es:3992],ax

mov al,'0'
mov ah,00010000b
mov [es:3994],ax

mov al,'0'
mov ah,00010000b
mov [es:3996],ax


;;משימה 2



mov al,'A'
mov ah,00100100b
mov [es:3840],ax

mov al,'t'
mov ah,00100100b
mov [es:3842],ax

mov al,'t'
mov ah,00100100b
mov [es:3844],ax

mov al,'A'
mov ah,00100100b
mov [es:3846],ax

mov al,'c'
mov ah,00100100b
mov [es:3848],ax

mov al,'k'
mov ah,00100100b
mov [es:3850],ax
 
exit:
	mov ax, 4c00h
	int 21h
END start