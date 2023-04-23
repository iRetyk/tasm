IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
New_LineString db 10, 13, '$'

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------

	;ex2
	push 3
	push 4
	push 5 
	call PitagorianTriplet
	pop ax
	call ShowAxDecimal
	call NewLine
	push 5
	push 6
	push 8
	call PitagorianTriplet
	pop ax
	call ShowAxDecimal
	
	call NewLine
	
	;ex3
	push 37
	call IsPrime
	push 20
	call IsPrime
	push 2
	call IsPrime
	
	
	
exit:
	mov ax, 4c00h
	int 21h


proc PrintArr
	push bp
	mov bp, sp
	push si
	push ax
	
	call NewLine
	
	mov cx, [bp + 4]
	mov si, [bp + 6]
	xor ah, ah
@@Loop:
	mov al, [si]
	call ShowAxDecimal
	inc si
	loop @@Loop
	pop ax
	pop si
	pop bp
	
	call NewLine
	
	ret 4
endp


proc PitagorianTriplet
	push bp
	mov bp, sp
	sub sp, 4
	push ax
	xor ax, ax
	
	mov al, [bp + 8]
	mul al
	mov [bp - 2], ax
	mov al, [bp + 6]
	mul al
	mov [bp - 4], ax
	mov al ,[bp + 4]
	mul al
	sub ax, [bp - 4]
	sub ax, [bp - 2]
	cmp ax, 0
	jne @@NotEqual
	mov ax, 1
	jmp @@Cont
@@NotEqual:
	mov ax, 0
@@Cont:
	mov [bp + 8], ax
	pop ax
	add sp, 4
	pop bp
	ret 4
endp

proc IsPrime
	push bp
	mov bp, sp
	push bx
	xor bx, bx
	push ax
	
	mov ax, [bp + 4] ;ax holds the number
	call ShowAxDecimal
	cmp ax, 2
	je @@TheNumberIs2
	mov bx, 2
	
	
@@Loop:
	call ShowAxDecimal
	cmp bx, ax
	je @@Prime
	call ShowAxDecimal
	push ax
	xor dx, dx
	div bx 
	pop ax
	inc bx
	cmp dx, 0
	call ShowAxDecimal
	je @@Cont ;not prime
	call ShowAxDecimal
	jmp @@Loop
	
@@Prime:
	call ShowAxDecimal
	jmp @@Cont

@@TheNumberIs2:
	mov dl , '2'
	call PrintChar


@@Cont:
	call ShowAxDecimal
	pop ax
	pop bx
	pop bp
	ret 2
endp





proc NewLine
	push dx
	mov dx, offset New_LineString
	call PrintString
	pop dx
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
	push bx
	mov bh, ah
	
	mov ah, 1
	int 21h
	
	mov ah, bh
	pop bx
	ret
endp

proc InputString
	push ax
	
	mov ah, 0ah
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
	   call PrintChar
	   
	   
	   pop dx
	   pop cx
	   pop bx
	   pop ax
	   
	   ret
endp ShowAxDecimal
END start