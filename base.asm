IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
New_Line db 10, 13, '$'

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------

exit:
	mov ax, 4c00h
	int 21h

proc NewLine
	push ax
	push dx
	
	mov ah, 9h
	mov dx, offset New_Line
	int 21h
	
	pop dx
	pop ax
	ret
endp

proc PrintString
	push ax
	
	
	mov ah, 9h
	int 21h
	
	pop ax
	ret
endp

proc PrintChar
	push ax
	
	mov ah, 2
	int 21h
	
	pop ax
	ret
endp

proc InputChar
	push ax
	
	mov ah, 1
	int 21h
	
	pop ax
	ret
endp

proc InputString
	push ax
	
	mov ah, 1
	int 21h
	
	pop ax
	ret
endp

proc ShowAxDecimal
       push ax
	   push bx
	   push cx
	   push dx
	   
	   ; check if negative
	   test ax,08000h
	   jz PositiveAx
			
	   ;  put '-' on the screen
	   push ax
	   mov dl,'-'
	   mov ah,2
	   int 21h
	   pop ax

	   neg ax ; make it positive
PositiveAx:
       mov cx,0   ; will count how many time we did push 
       mov bx,10  ; the divider
   
put_mode_to_stack:
       xor dx,dx
       div bx
       add dl,30h
	   ; dl is the current LSB digit 
	   ; we cant push only dl so we push all dx
       push dx    
       inc cx
       cmp ax,9   ; check if it is the last time to div
       jg put_mode_to_stack

	   cmp ax,0
	   jz pop_next  ; jump if ax was totally 0
       add al,30h  
	   mov dl, al    
  	   mov ah, 2h
	   int 21h        ; show first digit MSB
	       
pop_next: 
       pop ax    ; remove all rest LIFO (reverse) (MSB to LSB)
	   mov dl, al
       mov ah, 2h
	   int 21h        ; show all rest digits
       loop pop_next
		
	   mov dl, ','
       mov ah, 2h
	   int 21h
	   
	   mov dl, 20h
       mov ah, 2h
	   int 21h
   
	   pop dx
	   pop cx
	   pop bx
	   pop ax
	   
	   ret
endp ShowAxDecimal
END start