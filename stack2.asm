IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
	New_Line db 10, 13, '$'
	Yes db "Yes$"
	No db "No$"
	Num1 db (?)
	Num2 db (?)
	Num3 db (?)

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
	call Rectangle1
	
	call Kefel
	
	call InputChar
	mov bl, al
	call InputChar
	mov ah, bl
	sub al, '0'
	sub ah, '0'
	call NewLine
	call Rectangle2
	
	mov [num1], 3
	mov [num2], 4
	mov [num3], 5
	call Pitagoras
; --------------------------

exit:
	mov ax, 4c00h
	int 21h


proc Rectangle1
	mov dl, '*'
	mov cx, 6
@@Loop1:
	push cx
	mov cx, 8
@@Loop2:
	call PrintChar
	loop @@Loop2
	pop cx
	call NewLine
	loop @@Loop1
	
	ret
endp

proc Kefel

	mov si,1
	mov bh,1;
	
	mov cx,10
	
@@Loop1:
	push cx
	mov cx,10
@@Loop2:
	
	mov ax,si
	mov bl,bh
	mul bl
	
	push ax
	cmp al,10
	jae @@OneSpace
	

	mov dl,20h
	call PrintChar
@@OneSpace:
	mov dl,20h
	call PrintChar
	
	pop ax
	mov ah,0
	call ShowAxDecimal
	
	inc bh
	
	loop @@Loop2
	
	call NewLine
	
	inc si
	mov bh,1
	
	pop cx
	loop @@Loop1

	ret
endp Kefel

proc Rectangle2
	mov dl, '*'
	xor ch, ch
	mov cl, al
@@Loop1:
	push cx
	mov cl, ah
@@Loop2:
	call PrintChar
	loop @@Loop2
	pop cx
	call NewLine
	loop @@Loop1
	
	ret
endp

proc Pitagoras
	mov al, [Num1]
	mul al
	mov bx, ax
	mov al, [Num2]
	mul al
	mov cx, ax
	mov al, [Num3]
	mul al
	mov dx, ax
	add bx, cx
	cmp bx, dx
	je @@Equal
	jne @@NotEqual
@@Equal:
	mov dl, offset Yes
	call PrintString
	jmp @@Cont
@@NotEqual:
	mov dl, offset No
	call PrintString
@@Cont:
	ret
endp

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
		
	   mov dl, 20h
       mov ah, 2h
	   int 21h
   
	   pop dx
	   pop cx
	   pop bx
	   pop ax
	   
	   ret
endp ShowAxDecimal

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
	mov ah, 1
	int 21h
	ret
endp

proc InputString
	push ax
	
	mov ah, 1
	int 21h
	
	pop ax
	ret
endp

END start