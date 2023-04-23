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

	mov cx, 50
	mov dx, 50
	push 2
	mov al, 10
	
	call DrawHorizontalLine
	mov al, 0
	push 8
	call DrawHorizontalLine ;Delete the line
	
	mov cx, 50
	mov dx, 50
	push 8
	mov al, 10
	
	call DrawVerticalLine
	mov al, 0
	push 8
	call DrawVerticalLine;Delete the line
	
exit:
	mov ax, 4c00h
	int 21h
proc DrawHorizontalLine ;put x in cx, y in dx before calling the proc and the color in al

	call GraphicMode
	mov bp, sp
	push bp
	
	mov bx, cx ;save x
	
	mov cx, [bp + 4]
@@Loop:
	push cx
	mov cx, bx
	
	mov bh, 0
	mov ah, 0ch
	int 10h
	
	mov bx, cx
	inc bx
	pop cx
	loop @@Loop
	
	
	call InputChar ;wait for user input before continueing
	
	call TextMode
	pop bp
	ret 2
endp

proc DrawVerticalLine ;put x in cx, y in dx before calling the proc and the color in al

	call GraphicMode
	mov bp, sp
	push bp
	
	mov bx, cx ;save x
	
	mov cx, [bp + 4]
@@Loop:
	push cx
	mov cx, bx
	
	mov bh, 0
	mov ah, 0ch
	int 10h
	
	mov bx, cx
	inc dx
	pop cx
	loop @@Loop
	
	
	call InputChar ;wait for user input before continueing
	
	call TextMode
	pop bp
	ret 2
endp


proc GraphicMode
	mov ax, 13h
	int 10h
	ret
endp
proc TextMode
	mov ax, 2
	int 10h
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
		
	   mov dl, 20h
       mov ah, 2h
	   int 21h
	   
	   mov dl, ','
       mov ah, 2h
	   int 21h
   
	   pop dx
	   pop cx
	   pop bx
	   pop ax
	   
	   ret
endp ShowAxDecimal
END start