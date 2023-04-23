;
; here write your ID. DOnt forget the name of the file should be your id . asm
; ID  = 216239939

; For tester:
; Tester name = 
; Tester Total Grade = 

 
;---------------------------------------------
; 
; Skelatone Solution for Chapter 8 Work
;  
;----------------------------------------------- 


IDEAL

MODEL small

	stack 256
DATASEG
		 
		 ; Ex1 Variables 
		  aTom db 13 dup(?)  ; example to varible for exercise 1
		
		  
		 ; Ex2 Variables 
		 digits db 10 dup (?)
		 
		 
		 ; Ex3 Variables 
		 ex3array db 10 dup (?)
			
		; ex4 variables
		array4 db 101 dup (?)
		; ex5 variables
		BufferFrom5 db 10 dup (?)
		BufferTo5 db 10 dup (?)

		 ; ex6 variables
		 BufferFrom6 db 50 dup (?)
		 BufferTo6 db 50 dup (?)
		 BufferTo6Len db 0
		 
		 ;ex7 variables
		 MyLine7 db 10,16,13,65,7,0ffh, 4d, 0dh
		 Line7Length db 0
		MyWords7 dw 1016,1365,7,0ffh, 4d, 0ddddh
		 MyWords7Length db 0
		 
		 ;ex8 variable
		 MyQ8 db 101, 130,30,201, 120, -3,100,255,0
		 
		 ;ex9 variables
		 MySet9 dw (?), (?), (?), 0FFFFh
		 count1 db 0
		 count2 db 0
		 count3 db 0
		 
		 
		 
		 ; Ex11 Variables 
		 EndGates11 db 65
		 stringFalse db "Both 7 and 8 bits are false$"
		 stringTrue db "At least one of 7 and 8 bits are true$"
		 
		 ;ex3 variables
		 WordNum13 dw 0
		 NumString db "18!"
		 
CODESEG

start:
		mov ax, @data
		mov ds,ax

		; next 5 lines: example how to use ShowAxDecimal (you can delete them)
		

		

		; call ex1
	 
		; call ex2
	 
		; call ex3
	 
		; call ex4
	 
		; call ex5
	 
		; call ex6
	 
		; call ex7a
		
		; call ex7b
	 
		;call ex8
	 
		;call ex9
		; mov al, 1001011b
		; call ex10
	 
		;call ex11
	 
		;call ex12
	 
		;call ex13
	 
	 
		 mov ax ,0f70ch  
 		call ex14c     ; this will call to ex14b and ex14a
	 
	 
	 
	 

exit:
		mov ax, 04C00h
		int 21h

		
		
;------------------------------------------------
;------------------------------------------------
;-- End of Main Program ... Start of Procedures 
;------------------------------------------------
;------------------------------------------------





;================================================
; Description -  Move 'a' -> 'm'  to variable at DSEG 
; INPUT: None
; OUTPUT: array on Dataseg name : aTom
; Register Usage: 
;================================================
proc ex1

    ; < HERE YOUR ANSWER>
	xor si, si
	mov al , 'a'
	mov cx, 13
@@Loop:
	mov [aTom + si], al
	inc al
	inc si
	loop @@Loop
	
    ret
endp ex1









;================================================
; Description -  puts the ascii values of the digits in digits
; INPUT:  
; OUTPUT:  ds:digits
; Register Usage:  ???????????????????
;================================================
proc ex2
    xor si, si
	mov al , '0'
	mov cx, 10
@@Loop:
	mov [aTom + si], al
	inc al
	inc si
	loop @@Loop
    ret
endp ex2




;================================================
; Description: puts in an array the number 0 - 9
; INPUT:  
; OUTPUT:  ds:ex3array
; Register Usage: 
;================================================
proc ex3
      xor si, si
	xor ax, ax
	mov cx, 10
@@Loop:
	mov [aTom + si], al
	inc al
	inc si
	loop @@Loop
    ret
endp ex3




;================================================
; Description:puts the value 0cch in all the even and divisable by seven cells
; INPUT:  
; OUTPUT:  array4
; Register Usage: 
;================================================
proc ex4
      
	  mov cx, 101
	  mov bx, offset array4
	xor si, si
@@StartLoop:
	mov ax, bx
	mov dl, 2
	div dl
	cmp ah, 1
	je @@Movecch
	mov ax, bx
	mov dl, 7
	div dl
	cmp ah, 0
	je @@Movecch
	jmp @@Skip
@@Movecch:
	mov [bx], 0cch
@@Skip:
	
	inc bx
	loop @@StartLoop
	  
    ret
endp ex4




;================================================
; Description:Copy 10 numbers
; INPUT:  BufferFrom5
; OUTPUT:  BufferTo5
; Register Usage: 
;================================================
proc ex5
      xor si, si
	  mov cx, 10
@@Loop:
	mov al, [BufferFrom5 + si]
	mov [BufferTo5 + si], al
	inc si
	loop @@Loop  
    ret
endp ex5




;================================================
; Description: copy all the number that are greater than 12
; INPUT:  BufferFrom6
; OUTPUT:  BufferTo6, BufferTo6Len
; Register Usage: 
;================================================
proc ex6
      xor si, si
	  mov cx, 50
@@Loop:
	cmp [BufferFrom6 + si], 12
	jng @@Skip
	mov al, [BufferFrom6 + si]
	mov [BufferTo6 + si], al
	inc [BufferTo6Len]
@@Skip:
	inc si
	loop @@Loop
    ret
endp ex6




;================================================
; Description:calcultes the length of an array ending with 0dh
; INPUT:  MyLine7
; OUTPUT:  Line7Length
; Register Usage: 
;================================================
proc ex7a
      
	  xor si, si
	  
@@Loop:
	  cmp [MyLine7 + si], 0dh
	  je @@EndLoop
	  inc [MyLine7]
	  inc si
	  inc cx
	  jmp @@Loop
@@EndLoop:
	
	  
    ret
endp ex7a




;================================================
; Description: same like 7a but with words
; INPUT:  MyWords7
; OUTPUT:  MyWords7Length
; Register Usage: 
;================================================
proc ex7b
      xor si, si
	  
@@Loop:
	  cmp [MyLine7 + si], 0ddh
	  jne @@ContLoop
	  cmp [MyLine7 + si + 1], 0ddh
	  je @@EndLoop
@@ContLoop:
	  inc [MyLine7]
	  add si, 2
	  inc cx
	  jmp @@Loop
@@EndLoop:
	  
	  
    ret
endp ex7b




;================================================
; Description: sums all the numbers that are greater than 100
; INPUT:  MyQ8
; OUTPUT:  screen
; Register Usage: 
;================================================
proc ex8
    xor si, si
	xor bh, bh
	xor ax, ax
@@Loop:
	cmp [MyQ8 + si], 0
	je @@EndLoop
	cmp [MyQ8 + si], 100
	jng @@NotGreater
	mov bl, [MyQ8 + si]
	add ax, bx
@@NotGreater:
	inc si
	inc cx
	loop @@Loop
@@EndLoop:
	call ShowAxDecimal

    ret
endp ex8




;================================================
; Description: Counts the amount of positve, negatives and 0's
; INPUT:  MySet9
; OUTPUT:  count1, count2, count3
; Register Usage: 
;================================================
proc ex9
    xor si, si
	mov cx, 4
@@Loop:
	cmp [MySet9 + si], 0
	jne @@Not0
	inc [count3]
	jmp @@ContLoop
@@Not0:
	cmp [MySet9 + si] , 0
	jng @@negative
	inc [count1]
	jmp @@ContLoop
@@Negative:
	inc [count2]
@@ContLoop:
	inc si
	loop @@Loop
    ret
endp ex9




;================================================
; Description: Prints al in binary
; INPUT:  al
; OUTPUT:  screen
; Register Usage: 
;================================================
proc ex10
    mov cx, 8
	mov ah, 2
	mov bl, al
@@Loop:
	shl bl, 1
	jc @@Carry
	jnc @@NotCarry
@@Carry:
	mov dl, '1'
	int 21h
	jmp @@ContLoop
@@NotCarry:
	mov dl, '0'
	int 21h
@@ContLoop:
	loop @@Loop
	mov dl, 'B'
	int 21h
    ret
endp ex10




;================================================
; Description: checks if both the 7 and 8 bits of EndGates11 are on
; INPUT:  EndGates11
; OUTPUT:  screen
; Register Usage: 
;================================================
proc ex11
    
	mov al, [EndGates11]
	mov bl, al
	and al, 01000000b
	and bl, 10000000b
	or al, bl
	cmp al, 0
	jne @@NotZero
	mov dx, offset stringFalse
	mov ah, 09h
	int 21h
	jmp @@Cont
@@NotZero:
	mov dx, offset stringTrue
	mov ah, 09h
	int 21h
@@Cont:
    ret
endp ex11




;================================================
; Description: checks if the value in ds:a000h is between 10 and 70. if it is it transfers it to ds:b000h
; INPUT:  none
; OUTPUT:  none
; Register Usage: 
;================================================
proc ex12
    mov al, [ds:0a000h]
	cmp al, 10
	jb @@Cont
	cmp al, 70
	ja @@cont
	mov [ds:0b000h], al
@@Cont:

    ret
endp ex12




;================================================
; Description:int.Parse
; INPUT:  NumString
; OUTPUT:  WordNum13
; Register Usage: 
;================================================
proc ex13
    xor si, si
	mov cx, 5
	xor ah, ah
	xor bh, bh
@@Loop:
	mov cl, [NumString + si]
	cmp al, '!'
	je @@EndLoop
	sub al, '0'
	push cx
	mov cx, 4
	sub cx, si
	cmp cx, 0
	je @@SkipPower
	mov bx, ax
@@Power:
	mul bx
	Loop @@Power
@@SkipPower:
	add [WordNum13], ax
	pop cx
	inc si
	loop @@Loop
@@EndLoop:
	mov ax, [WordNum13]
	call ShowAxDecimal
    ret
endp ex13




;================================================
; Description:prints one hex digit in al
; INPUT:  al
; OUTPUT:  screen
; Register Usage: 
;================================================
proc ex14a
	
	push bx
	
	mov bl ,al
    mov ah, 2h
	and al , 0Fh
	cmp al, 10 
	jb @@PrintDecimal 
	add al, 57h 
	jmp @@PrintCharacter 
	
	
@@PrintDecimal:
	add al, '0' 
	mov dl, al
	int 21h
	jmp @@Cont
@@PrintCharacter:
	mov dl, al
	int 21h 

@@Cont:
	mov al ,bl
	
	
	pop bx
    ret
endp ex14a




;================================================
; Description:prints al in hex
; INPUT:  al
; OUTPUT:  screen
; Register Usage: 
;================================================
proc ex14b
     push ax
	 push bx
	 mov bl, al
	 shr al, 4
	 call ex14a
	 mov al, bl
	 call ex14a
	 pop bx
	 pop ax
    ret
endp ex14b




;================================================
; Description:prints ax in hex
; INPUT:  ax
; OUTPUT:  screen
; Register Usage: 
;================================================
proc ex14c
     mov bl, al
	 mov al, ah
	 call ex14b
	 mov al, bl
	 call ex14b
	 mov dl, 'h'
	 mov ah, 2
	 int 21h
    ret
endp ex14c












;================================================
; Description - Write on screen the value of ax (decimal)
;               the practice :  
;				Divide AX by 10 and put the Mod on stack 
;               Repeat Until AX smaller than 10 then print AX (MSB) 
;           	then pop from the stack all what we kept there and show it. 
; INPUT: AX
; OUTPUT: Screen 
; Register Usage: AX  
;================================================
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
   
	   pop dx
	   pop cx
	   pop bx
	   pop ax
	   
	   ret
endp ShowAxDecimal



END start
