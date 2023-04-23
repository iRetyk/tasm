IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
	New_Line db 10, 13, '$'
	RndCurrentPos dw start
	num db ?
	SmallString db "Try a bigger number" ,10, 13, '$'
	BiggerString db "Try a smaller number" ,10, 13, '$'
	UpString db "Up   $"
	DownString db "Down $"
	LeftString db "Left $"
	RightString db "Right$"
	;vars for moving square
	xSquare dw 50
	ySquare dw 50
	direction dw 3 ;(0-3) right, down, left , up
	speed dw 3
	cont db 1
	GameOver db "Game-Over$"
	
	;vars for ex5
	rndx dw ?
	rndy dw ?
	points dw 0
	rndcolor db ?
	
CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------
	
	
	call ex5

exit:
	mov ax, 4c00h
	int 21h

;|||||||||||||||||||||||
;||||||exersices||||||||
;|||||||||||||||||||||||
	
proc ex1 ;שקופית 13 במצגת מספרים אקראיים
	mov bl, 1
	mov bh, 100
	call RandomByCs
	mov [num], al
	xor si, si
@@Loop:
	inc si
	call InputTwoDigit	
	
	cmp al, [num]
	je @@End
	jg @@Bigger
@@Smaller:
	mov dx, offset SmallString
	call PrintString
	call NewLine
	jmp @@Loop
@@Bigger:
	mov dx, offset BiggerString
	call PrintString
	call NewLine
	jmp @@Loop
@@End:
	mov ax, si
	call ShowAxDecimal
	ret
endp ex1



proc ex2 ;שקופית 13 במצגת מספרים אקראיים
	
	call GraphicMode
@@Loop:
	mov bx, 0
	mov dx, 314
	call RandomByCsWord
	push ax ;x
	
	mov bl, 0
	mov bh, 194
	call RandomByCs
	xor ah, ah
	push ax ;y
	
	push 5
	push 5
	
	mov bl, 0
	mov bh, 255
	call RandomByCs
	xor ah, ah
	push ax ;color
	
	call DrawFullRect
	mov ah, 1
	int 16h
	jz @@Loop
	mov ah, 0
	int 16h
	cmp ah, 1
	jne @@Loop
	
	call TextMode
	ret
endp ex2



proc ex3 ;page 7 of מקלדת והשהייה

	xor si, si ;si goes up every .1 seconds
	mov ax, -1 ;ax holds number of seconds
	call GraphicMode
	jmp @@AddSecond
@@Main:
	push ax
	
	mov ah, 1
	int 16h
	jz @@Delay
	
	mov ah, 2
	mov bh, 0
	mov dh, 12
	mov dl, 20
	int 10h
	
	
	
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
	
	cmp ah, 1
	jne @@Delay
	jmp @@Exit
	
@@Up:
	mov dx, offset UpString
	call PrintString
	jmp @@Delay
@@Down:
	mov dx, offset DownString
	call PrintString
	jmp @@Delay
@@Left:	
	mov dx, offset LeftString
	call PrintString
	jmp @@Delay
@@Right:
	mov dx, offset RightString
	call PrintString
	jmp @@Delay

@@Delay:
	pop ax
	call Delay100ms
	inc si
	test si, si ;checks if si == 0
	jz @@AddSecond
	jmp @@Main
@@AddSecond:
	sub si, 10
	inc ax
	push ax
	
	mov ah, 2
	mov bh, 0
	mov dh, 1
	mov dl, 34
	int 10h
	
	pop ax
	call ShowAxDecimal
	
	jmp @@Main
@@Exit:
	pop ax
	call TextMode
	ret
endp ex3


proc ex4 ;ריבוע זז על מסך
	
	call GraphicMode
@@Main:
	;check if cont is true
	cmp [cont], 1
	jne @@HalfWayToExit
	
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
			cmp [speed], 2
			je @@SpeedIs2
			mov [speed], 2
			jmp @@NotPressed
		@@SpeedIs2:
			mov [speed], 6
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
	call MoveSquare
	call Delay100ms
	
	
		;check when moving right
		mov bx, [speed]
		mov ax, [xSquare]
		add ax, bx
		cmp ax, 312
		jl @@Check2
		mov [direction], 2
	@@HalfWayToMain:
		jmp @@Main
	@@Check2:	;check when moving left
		mov bx, [speed]
		mov ax, [xSquare]
		sub ax, bx
		cmp ax, 0
		jg @@Check3
		mov [direction], 0
		jmp @@Main
	@@Check3:	;check when moving up
		push ax
		push bx
		mov bx, [speed]
		mov ax, [ySquare]
		sub ax, bx
		cmp ax, 0
		pop bx
		pop ax
		jg @@Check4
		mov [direction], 1
		jmp @@Main
	@@Check4:	;check when moving down
		mov bx, [speed]
		mov ax, [ySquare]
		add ax, bx
		cmp ax, 192
		jl @@HalfWayToMain
		mov [direction], 3
		jmp @@HalfWayToMain

@@Exit:
	call DeleteSquare
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
endp ex4




proc ex5 ;תפוס תריבוע
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
	call MoveSquare
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
	call DeleteSquare
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
endp ex5

;||||||||||||||||||||||||||||||||
;||||||||helpul proc here||||||||
;||||||||||||||||||||||||||||||||


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
	
	push 5 ;length
	push 5 ;width
	
	mov bl, 0
	mov bh, 255
	call RandomByCs
	xor ah, ah
	push ax ;color
	
	call DrawFullRect
	
	pop dx
	pop bx
	pop ax
	ret
endp




proc MoveSquare 
	
	push ax
	call DeleteSquare
	
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
	call DrawSquare
	pop ax
	ret 
endp MoveSquare





proc DeleteSquare ;specifly for ex4
	push [xSquare]
	push [ySquare]
	push 10
	push 10
	push 0
	call DrawFullRect
	ret
endp DeleteSquare




proc DrawSquare ;specifly for ex4
	push [xSquare]
	push [ySquare]
	push 10
	push 10
	push 7 ;color
	call DrawFullRect
	
	inc [xSquare]
	push [xSquare]
	dec [xSquare]
	inc [ySquare]
	push [ySquare]
	dec [ySquare]
	push 8
	push 8
	push 10; color
	call DrawFullRect
	
	ret
endp DrawSquare


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