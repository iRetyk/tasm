IDEAL
MODEL small

BMP_WIDTH = 10
BMP_HEIGHT = 10

STACK 100h

FILE_NAME_IN equ "Donkey.bmp"


DATASEG

; --------------------------
; Your variables here
; --------------------------
	New_Line db 10, 13, '$'
	RndCurrentPos dw start
	xSquare dw 50
	ySquare dw 50
	direction dw 3 ;(0-3) right, down, left , up
	speed dw 3
	cont db 1
	GameOver db "Game-Over$"
	rndx dw ?
	rndy dw ?
	points dw 0
	rndcolor db ?
	
	OneBmpLine 	db BMP_WIDTH dup (0)  ; One Color line read buffer
   
    ScrLine 	db BMP_WIDTH dup (0)  ; One Color line read buffer
	
	;BMP File data
	FileName 	db FILE_NAME_IN ,0
	FileHandle	dw ?
	Header 	    db 54 dup(0)
	Palette 	db 400h dup (0)
	
	BmpFileErrorMsg    	db 'Error At Opening Bmp File ',FILE_NAME_IN, 0dh, 0ah,'$'
	ErrorFile           db 0
	
	BmpLeft dw ?
	BmpTop dw ?
	BmpColSize dw ?
	BmpRowSize dw ?

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------



	call Game





exit:
	mov ax, 4c00h
	int 21h

proc Game 
	xor si, si
	xor di, di
	call GraphicMode
@@Main:
	;check if cont is true
	cmp [cont], 1
	jne @@HalfWayToExit
	
	call PrintPoints
	
	cmp si, 0
	jne @@SkipTheSeconds
	sub si, 10
	cmp di, 0
	jne @@DontResetClock
	;timer reached zero:
	mov di, 11
	call DeleteRandomSquare
	call DrawRandomSquare
@@DontResetClock:
	dec di
	push ax
	push bx
	push dx
	mov ah, 2 ; move curosr position
	mov bh, 0
	mov dh, 1
	mov dl, 34
	int 10h
	pop dx
	pop bx
	pop ax
	
	push ax
	mov ax, di
	call ShowAxDecimal
	pop ax
@@SkipTheSeconds:
	mov ah, 1
	int 16h
	jz @@NotPressed
	mov ah, 0
	int 16h
	cmp ah, 48h
	je @@Up
	cmp ah, 4bh
	je @@Left
	cmp ah, 50h
	je @@Down
	cmp ah, 4dh
	je @@Right
	cmp ah, 39h
	je @@Space
	cmp ah, 1
	jne @@NotPressed
	mov [Cont], 0
@@HalfWayToExit:
	jmp @@Exit

	@@Space:
			cmp [speed], 1
			je @@SpeedIs1
			mov [speed], 1
			jmp @@NotPressed
		@@SpeedIs1:
			mov [speed], 3
			jmp @@NotPressed
	@@Right:
		mov [direction], 0
		jmp @@NotPressed
	@@Down:
		mov [direction], 1
		jmp @@NotPressed
	@@Left:
		mov [direction], 2
		jmp @@NotPressed
	@@Up:
		mov [direction], 3

@@NotPressed:
	call MoveDonkey
	call AreSquaresTouching
	cmp dx, 1
	jne @@NotTouching
	inc [points]
	mov si, -1
	xor di, di
	@@NotTouching:
	call Delay100ms
	inc si

	@@Check1: ;check when moving right
		mov bx, [speed]
		mov ax, [xSquare]
		add ax, bx
		cmp ax, 312
		jl @@Check2
		mov [direction], 2
	;----------------
	@@HalfWayToMain:
		jmp @@Main
	;----------------
	@@Check2:	;check when moving left
		mov bx, [speed]
		mov ax, [xSquare]
		sub ax, bx
		cmp ax, 0
		jg @@Check3
		mov [direction], 0
		jmp @@HalfWayToMain
	@@Check3:	;check when moving up
		mov bx, [speed]
		mov ax, [ySquare]
		sub ax, bx
		cmp ax, 0
		jg @@Check4
		mov [direction], 1
		jmp @@Main
	@@Check4:	;check when moving down
		mov bx, [speed]
		mov ax, [ySquare]
		add ax, bx
		cmp ax, 192
			jl @@jmpMain
			mov [direction], 3
		@@jmpMain:
		jmp @@HalfWayToMain

@@Exit:
	call DeleteDonkey
	mov ah, 2
	mov bh, 0
	mov dh, 12
	mov dl, 12
	int 10h
	mov dx, offset GameOver
	call PrintString
	call InputChar
	call TextMode
	
	ret
endp Game




;--------------------
;      bmp proc
;---------------------

proc MainBmp ;push x and y
	
	push bp
	mov bp, sp
	
	mov ah, 2 ; move curosr position
	mov bh, 0
	mov dh, [bp + 6]
	mov dl, [bp + 4]
	int 10h
	
	mov dx, offset FileName
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpColSize], BMP_WIDTH
	mov [BmpRowSize] ,BMP_HEIGHT
	
	
	mov dx, offset FileName
	call OpenShowBmp
	cmp [ErrorFile],1
	jne @@cont 
	jmp exitError
@@cont:

	
    jmp @@exit
	
exitError:
	mov ax,2
	int 10h
	
    mov dx, offset BmpFileErrorMsg
	mov ah,9
	int 21h
	
@@exit:
	
	mov ah,7
	int 21h
	
	mov ax,2
	int 10h

	
	mov ax, 4c00h
	int 21h
	
	pop bp
	
	ret 4 
endp








proc OpenShowBmp near
	
	 
	call OpenBmpFile
	cmp [ErrorFile],1
	je @@ExitProc
	
	call ReadBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	
	call  ShowBmp
	
	 
	call CloseBmpFile

@@ExitProc:
	ret
endp OpenShowBmp

 

; input dx filename to open
proc OpenBmpFile	near						 
	mov ah, 3Dh
	xor al, al
	int 21h
	jc @@ErrorAtOpen
	mov [FileHandle], ax
	jmp @@ExitProc
	
@@ErrorAtOpen:
	mov [ErrorFile],1
@@ExitProc:	
	ret
endp OpenBmpFile


proc CloseBmpFile near
	mov ah,3Eh
	mov bx, [FileHandle]
	int 21h
	ret
endp CloseBmpFile




; Read 54 bytes the Header
proc ReadBmpHeader	near					
	push cx
	push dx
	
	mov ah,3fh
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	
	pop dx
	pop cx
	ret
endp ReadBmpHeader



proc ReadBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)
						 ; 4 bytes for each color BGR + null)			
	push cx
	push dx
	
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	
	pop dx
	pop cx
	
	ret
endp ReadBmpPalette


; Will move out to screen memory the colors
; video ports are 3C8h for number of first color
; and 3C9h for all rest
proc CopyBmpPalette		near					
										
	push cx
	push dx
	
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0  ; black first							
	out dx,al ;3C8h
	inc dx	  ;3C9h
CopyNextColor:
	mov al,[si+2] 		; Red				
	shr al,2 			; divide by 4 Max (cos max is 63 and we have here max 255 ) (loosing color resolution).				
	out dx,al 						
	mov al,[si+1] 		; Green.				
	shr al,2            
	out dx,al 							
	mov al,[si] 		; Blue.				
	shr al,2            
	out dx,al 							
	add si,4 			; Point to next color.  (4 bytes for each color BGR + null)				
								
	loop CopyNextColor
	
	pop dx
	pop cx
	
	ret
endp CopyBmpPalette


proc  SetGraphic
	mov ax,13h   ; 320 X 200 
				 ;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode 
	int 10h
	ret
endp 	SetGraphic



proc ShowBMP 
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; displaying the lines from bottom to top.
	push cx
	
	mov ax, 0A000h
	mov es, ax
	
	mov cx,[BmpRowSize]
	
 
	mov ax,[BmpColSize] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
	xor dx,dx
	mov si,4
	div si
	cmp dx,0
	mov bp,0
	jz @@row_ok
	mov bp,4
	sub bp,dx

@@row_ok:	
	mov dx,[BmpLeft]
	
@@NextLine:
	push cx
	push dx
	
	mov di,cx  ; Current Row at the small bmp (each time -1)
	add di,[BmpTop] ; add the Y on entire screen
	
 
	; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
	mov cx,di
	shl cx,6
	shl di,8
	add di,cx
	add di,dx
	 
	; small Read one line
	mov ah,3fh
	mov cx,[BmpColSize]  
	add cx,bp  ; extra  bytes to each row must be divided by 4
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,[BmpColSize]  
	mov si,offset ScrLine
	rep movsb ; Copy line to the screen
	
	pop dx
	pop cx
	 
	loop @@NextLine
	
	pop cx
	ret
endp ShowBMP 


;--------------------
;--------------------
;--------------------
;--------------------
;--------------------
;--------------------
;--------------------
;--------------------
;--------------------
;   helpful proc
;--------------------
;--------------------
;--------------------
;--------------------
;--------------------
;--------------------
;--------------------
;--------------------
;--------------------




proc AreSquaresTouching ;sets dx = 1 if the squares are touching
	push bp
	mov bp,sp
	push ax
	
	mov ax,[rndx]
	cmp ax,[xSquare]
	ja @@Skip
	add ax,5
	cmp ax,[xSquare]
	jb @@Skip

	mov ax,[rndy]
	cmp ax,[ySquare]
	ja @@Skip
	add ax,5
	cmp ax,[ySquare]
	jb @@Skip
	
	mov dx,1
	jmp @@End
@@Skip:
	mov dx,0
@@End: 
	pop ax
	pop bp
	ret 
endp



proc DeleteRandomSquare
	push [rndx]
	push [rndy]
	push 5
	push 5
	push 0
	call DrawFullRect
	ret
endp DeleteRandomSquare



proc PrintPoints
	push ax
	
	mov ah, 2 ; move curosr position
	mov bh, 0
	mov dh, 3
	mov dl, 34
	int 10h
	mov ax, [Points]
	call ShowAxDecimal
	
	pop ax
	ret
endp PrintPoints



proc DrawRandomSquare
	push ax
	push bx
	push dx
	
	mov bx, 0
	mov dx, 314
	call RandomByCsWord
	mov [rndx], ax
	push ax ;x
	
	mov bl, 0
	mov bh, 194
	call RandomByCs
	xor ah, ah
	mov [rndy], ax
	push ax ;y
	
	call MainBmp
	
	pop dx
	pop bx
	pop ax
	ret
endp




proc MoveDonkey 
	
	push ax
	call DeleteDonkey
	
	cmp [direction], 0
	je @@Right
	cmp [direction], 1
	je @@Down
	cmp [direction], 2
	je @@Left
	cmp [direction], 3
	je @@Up
	
@@Right:
	mov ax, [speed]
	add [xSquare], ax
	jmp @@Cont
@@Down:
	mov ax, [speed]
	add [ySquare], ax
	jmp @@Cont
@@Left:
	mov ax, [speed]
	sub [xSquare], ax
	jmp @@Cont
@@Up:
	mov ax, [speed]
	sub [ySquare], ax
	
@@Cont:
	call DrawDonkey
	pop ax
	ret 
endp MoveDonkey





proc DeleteDonkey ;specifly for ex4
	push [xSquare]
	push [ySquare]
	push 10
	push 10
	push 0
	call DrawFullRect
	ret
endp DeleteDonkey



proc DrawDonkey ;specifly for ex4
	push [xSquare]
	push [ySquare] 
	call MainBmp
	
	ret
endp DrawDonkey


proc Delay100ms
	push cx
	mov cx, 100
@@Self1:
	push cx
	mov cx, 3000
@@Self2:
	loop @@Self2
	pop cx
	loop @@Self1
	
	pop cx
	ret
endp Delay100ms


color equ [bp+4]
len equ [bp+6]
y equ [bp+8]
x equ [bp+10]

proc DrawHorizontalLine; push in that order: x,y,len,color

	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	

	
	mov bh, 0
	mov cx, len
DrawLine:
	push cx
	mov cx, x
	mov dx, y
	mov al, color
	mov ah, 0ch
	int 10h
	pop cx
	inc x
	loop DrawLine
	
	;mov ax, 2
	;int 10h

	pop cx
	pop bx
	pop ax
	pop bp
	
	ret 8
endp DrawHorizontalLine



proc GraphicMode
	push ax
	mov ax, 13h
	int 10h
	pop ax
	ret
endp
proc TextMode
	push ax
	mov ax, 2
	int 10h
	pop ax
	ret
endp




color equ [bp+4]
len equ [bp+6]
y equ [bp+8]
x equ [bp+10]

proc DrawVerticalLine ; push in that order: x,y,len,color

	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	
	
	mov bh, 0
	mov cx, len
DrawVertLine:
	push cx
	mov cx, x
	mov dx, y
	mov al, color
	mov ah, 0ch
	int 10h
	pop cx
	inc y
	loop DrawVertLine
	
	;mov ax, 2
	;int 10h

	pop cx
	pop bx
	pop ax
	pop bp

	ret 8
endp DrawVerticalLine


color equ [bp+4]
wid equ [bp+6]
len equ [bp+8]
y equ [bp+10]
x equ [bp+12]

proc DrawFullRect;push in that order: x,y,len,wid,color

	push bp
	mov bp, sp
	push cx
	
	mov cx, wid
DrawR:
	push x
	push y
	push len
	push color
	call DrawVerticalLine
	add x, 1
	loop DrawR

	pop cx
	pop bp
	
	ret 10
endp DrawFullRect


proc InputTwoDigit ;output in ax
	push bx
	call InputChar
	sub al, '0'
	mov bh, al
	call InputChar
	sub al, '0'
	mov bl, al
	mov al, 10
	mul bh
	add al, bl
	
	call NewLine
	pop bx
	ret
endp

; Description  : get RND between any bl and bh includs (max 0 -255)
; Input        : 1. Bl = min (from 0) , BH , Max (till 255)
; 			     2. RndCurrentPos a  word variable,   help to get good rnd number
; 				 	Declre it at DATASEG :  RndCurrentPos dw ,0
;				 3. EndOfCsLbl: is label at the end of the program one line above END start		
; Output:        Al - rnd num from bl to bh  (example 50 - 150)
; More Info:
; 	Bl must be less than Bh 
; 	in order to get good random value again and agin the Code segment size should be 
; 	at least the number of times the procedure called at the same second ... 
; 	for example - if you call to this proc 50 times at the same second  - 
; 	Make sure the cs size is 50 bytes or more 
; 	(if not, make it to be more) 
proc RandomByCs
    push es
	push si
	push di
	
	mov ax, 40h
	mov	es, ax
	
	sub bh,bl  ; we will make rnd number between 0 to the delta between bl and bh
			   ; Now bh holds only the delta
	cmp bh,0
	jz @@ExitP
 
	mov di, [word RndCurrentPos]
	call MakeMask ; will put in si the right mask according the delta (bh) (example for 28 will put 31)
	
RandLoop: ;  generate random number 
	mov ax, [es:06ch] ; read timer counter
	mov ah, [byte cs:di] ; read one byte from memory (from semi random byte at cs)
	xor al, ah ; xor memory and counter
	
	; Now inc di in order to get a different number next time
	inc di
	cmp di,(EndOfCsLbl - start - 1)
	jb @@Continue
	mov di, offset start
@@Continue:
	mov [word RndCurrentPos], di
	
	and ax, si ; filter result between 0 and si (the nask)
	cmp al,bh    ;do again if  above the delta
	ja RandLoop
	
	add al,bl  ; add the lower limit to the rnd num
		 
@@ExitP:	
	pop di
	pop si
	pop es
	ret
endp RandomByCs


; Description  : get RND between any bl and bh includs (max 0 - 65535)
; Input        : 1. BX = min (from 0) , DX, Max (till 64k -1)
; 			     2. RndCurrentPos a  word variable,   help to get good rnd number
; 				 	Declre it at DATASEG :  RndCurrentPos dw ,0
;				 3. EndOfCsLbl: is label at the end of the program one line above END start		
; Output:        AX - rnd num from bx to dx  (example 50 - 1550)
; More Info:
; 	BX  must be less than DX 
; 	in order to get good random value again and again the Code segment size should be 
; 	at least the number of times the procedure called at the same second ... 
; 	for example - if you call to this proc 50 times at the same second  - 
; 	Make sure the cs size is 50 bytes or more 
; 	(if not, make it to be more) 
proc RandomByCsWord
    push es
	push si
	push di
 
	
	mov ax, 40h
	mov	es, ax
	
	sub dx,bx  ; we will make rnd number between 0 to the delta between bx and dx
			   ; Now dx holds only the delta
	cmp dx,0
	jz @@ExitP
	
	push bx
	
	mov di, [word RndCurrentPos]
	call MakeMaskWord ; will put in si the right mask according the delta (bh) (example for 28 will put 31)
	
@@RandLoop: ;  generate random number 
	mov bx, [es:06ch] ; read timer counter
	
	mov ax, [word cs:di] ; read one word from memory (from semi random bytes at cs)
	xor ax, bx ; xor memory and counter
	
	; Now inc di in order to get a different number next time
	inc di
	inc di
	cmp di,(EndOfCsLbl - start - 2)
	jb @@Continue
	mov di, offset start
@@Continue:
	mov [word RndCurrentPos], di
	
	and ax, si ; filter result between 0 and si (the nask)
	
	cmp ax,dx    ;do again if  above the delta
	ja @@RandLoop
	pop bx
	add ax,bx  ; add the lower limit to the rnd num
		 
@@ExitP:
	
	pop di
	pop si
	pop es
	ret
endp RandomByCsWord

; make mask acording to bh size 
; output Si = mask put 1 in all bh range
; example  if bh 4 or 5 or 6 or 7 si will be 7
; 		   if Bh 64 till 127 si will be 127
Proc MakeMask    
    push bx

	mov si,1
    
@@again:
	shr bh,1
	cmp bh,0
	jz @@EndProc
	
	shl si,1 ; add 1 to si at right
	inc si
	
	jmp @@again
	
@@EndProc:
    pop bx
	ret
endp  MakeMask


Proc MakeMaskWord    
    push dx
	
	mov si,1
    
@@again:
	shr dx,1
	cmp dx,0
	jz @@EndProc
	
	shl si,1 ; add 1 to si at right
	inc si
	
	jmp @@again
	
@@EndProc:
    pop dx
	ret
endp  MakeMaskWord

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

proc InputChar ;output: al
	
	mov ah, 1
	int 21h
	
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
		
	   ; mov dl, ','
       ; mov ah, 2h
	   ; int 21h
	   
	   mov dl, 20h
       mov ah, 2h
	   int 21h
   
	   pop dx
	   pop cx
	   pop bx
	   pop ax
	   
	   ret
endp ShowAxDecimal
EndOfCsLbl:
END start