IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
	ScrLine 	db 320 dup (0)  ; One Color line read buffer
	
	;<BMP File data>
	FileName 	db 11 dup (0) ,0
	FileHandle	dw ?
	Header 	    db 54 dup(0)
	Palette 	db 400h dup (0)
	
	BmpFileErrorMsg    	db 'Error At Opening Bmp File '
    BmpName  db 'NoName', 0dh, 0ah,'$'
	ErrorFile           db 0
	
	BmpLeft dw ? ;inputed before calling bmp proc
	BmpTop dw ?
	BmpColSize dw ?
	BmpRowSize dw ?
	;</Bmp File data>
	
	
	
	;<strings>
	New_Line db 10, 13, '$' ;used in proc - NewLine
	BestString db "Best:$"
	BestScoreString db "Best "
	ScoreString db "Score:$"
	NewBestScoreString db "New Best Score!!!! $"
	PlayAgain db "Press enter to play again$"
	PlayAgainPart2 db "Press esc to exit$"
	;</strings>
	
	FruitColor db ? ;holds the color of the fruit according to the Palette
	PeachColor db ? ; "-"
	RedMatrix db 64 dup (0)
	PurpleMatrix db 64 dup (0)
	matrixOffset dw offset RedMatrix, offset PurpleMatrix
	RndCurrentPos dw start
	
	;<packman data>
	x dw 8 ;head x
	y dw 10 ;head y
	direction dw 0 ;(0-3) right, down, left , up
	turned db 0 ;bool. will be true if its just after you turned
	score dw 0
	bestScore dw 0
	dollar db '$'
	cont db 1
	freezeCounter db 0
	;</packman data>
	
	;<ghosts data>
	;because there is more than one ghost the stats that are ghost specific are arrays of word for simplisty
	xGhost dw 120, 130 ;head x
	yGhost dw 80, 80 ;head y
	dirGhost dw '2', '2' ; '1' - right, '2' - left
	ghostCounter db 1 ;when hits 2 ghost will move
	stuck dw 0, 0;bool var represesnts if the ghost is stuck in a wall
	freeze db 0 ;bool var represesnting if the ghost need to freeze
	eaten dw 0, 0;bool
	;purple ghost movemnet 
	purpleGhostCounter db 0
	purpleGhostDireciton db 3;(0-3) right, down, left , up
	;</ghosts data>
	
CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------
	;main
	call SetGraphic
	xor ax, ax
	call Background
MainLoop:
	call AreTouching
	
	call MovePacman
	call ShowScore
	call Delay100ms
	call Delay100ms
	
	cmp [freeze], 1
	je DontMoveGhost
	inc [freezeCounter]
	
	inc [ghostCounter]
	
	
	cmp [ghostCounter], 2
	jne DontMoveGhost
	call MoveGhosts
	mov [ghostCounter], 0
	
DontMoveGhost:
	cmp [freeze], 1
	jne AfterFreezePart
	call MoveGhosts
	inc [freezeCounter]
	cmp [freezeCounter], 200
	jne AfterFreezePart
	;freeze counter = 200
	mov [freeze], 0
	mov [freezeCounter], 0
AfterFreezePart:
	cmp [cont], 1
	jne Ending
	mov ah, 1
	int 16h
	jz MainLoop
	mov ah, 0
	int 16h
	cmp ah, 48h
	je Up
	cmp ah, 4bh
	je Left
	cmp ah, 50h
	je Down
	cmp ah, 4dh
	je Right
	cmp ah, 1
	mov [cont], 0
	jmp MainLoop
Up:
	mov [direction], 3
	jmp MainLoop
Down:
	mov [direction], 1
	jmp MainLoop
Right:
	mov [direction], 0
	jmp MainLoop
Left:
	mov [direction], 2
	jmp MainLoop

Ending:
	call EndScreen
	cmp al, 0
	je ExitLoop
	call Restart
	jmp MainLoop

ExitLoop:
	call SetText
	
exit:
	mov ax, 4c00h
	int 21h




;---------------------
;---------------------
;---------------------
;---------------------
;game proc section 
;---------------------
;---------------------
;---------------------
;---------------------

;===========================
;description - restarts all variables
;input - none
;output - none
;variables - none
;===========================
proc Restart
	push bx
	
	mov [cont], 1
	mov [x], 8
	mov [y], 10
	mov [direction], 0
	mov [score], 0
	mov [xGhost], 120
	mov [yGhost], 80
	mov [xGhost + 2], 130
	mov [yGhost + 2], 80
	mov [ghostCounter], 1
	mov [eaten], 0
	mov [eaten + 2], 0
	mov [freeze], 0
	mov [freezeCounter], 0
	call Background
	mov bx, 0
	call DeleteMatrix
	mov bx, 2
	call DeleteMatrix
	
	pop bx
	ret
endp Restart


;===========================
;description - displays ending screen and ask if you want to restart
;input - none
;output - if restart al = 1
;variables - none
;===========================
proc EndScreen
	mov [FileName], 'g'
    mov [FileName + 1], 'o'
    mov [FileName + 2], '.'
    mov [FileName + 3], 'b'
    mov [FileName + 4], 'm'
    mov [FileName + 5], 'p'
    
    mov [BmpLeft], 0
    mov [BmpTop], 0
    mov [BmpColSize], 320
    mov [BmpRowSize], 200
    call Bmp
	
	mov ax, [score]
	cmp ax, [bestScore]
	jge @@NewBS
	mov bh, 0
	mov dh, 3
	mov dl, 15
	mov ah, 2
	int 10h
	mov dx, offset ScoreString
	call PrintString
	mov ax, [score]
	call ShowAxDecimal
	
	mov bh, 0
	mov dh, 5
	mov dl, 12
	mov ah, 2
	int 10h
	mov dx, offset BestScoreString
	call PrintString
	mov ax, [bestScore]
	call ShowAxDecimal
	jmp @@Cont
@@NewBS:
	mov ax, [score]
	mov [bestScore], ax
	mov bh, 0
	mov dh, 3
	mov dl, 15
	mov ah, 2
	int 10h
	mov dx, offset ScoreString
	call PrintString
	mov ax, [score]
	call ShowAxDecimal
	
	mov bh, 0
	mov dh, 5
	mov dl, 12
	mov ah, 2
	int 10h
	mov dx, offset NewBestScoreString
	call PrintString

@@Cont:
	mov bh, 0
	mov dh, 19
	mov dl, 8
	mov ah, 2
	int 10h
	mov dx, offset PlayAgain
	call PrintString
	mov bh, 0
	mov dh, 21
	mov dl, 12
	mov ah, 2
	int 10h
	mov dx, offset PlayAgainPart2
	call PrintString
	
	mov ah, 0
	int 16h
	cmp ah, 1
	jne @@PlayAgain
	mov al, 0 
	jmp @@ExitLoop
@@PlayAgain:
	mov al, 1
@@ExitLoop:
	ret
endp EndScreen


;===========================
;description - checks if the pacman and the ghosts are touching 
;input - none
;output - if touching ->cont = 0
;variables - none
;===========================
proc AreTouching
	push ax
	push bx
	mov bx, -2
@@NextGhost:
	add bx, 2 ;next ghost
	cmp bx, 4
	je @@ExitProc ;if bx = 4 we finished checking both ghosts
	
	cmp [eaten + bx], 1
	je @@NextGhost

	mov ax, [x]
	sub ax, [xGhost + bx]
	cmp ax, 9
	jnl @@NextGhost
	cmp ax, -9
	jng @@NextGhost
	
	mov ax, [y]
	sub ax, [yGhost + bx]
	cmp ax, 9
	jnl @@NextGhost
	cmp ax, -9
	jng @@NextGhost
	
	;if we got until here they are touching
	cmp [freeze], 1
	je @@EatGhost
	mov [cont], 0
	jmp @@NextGhost
@@EatGhost:
	add [score], 250
	mov [eaten + bx], 1
	call DeleteMatrix
	call DeleteGhost
	jmp @@NextGhost
	
@@ExitProc:
	pop bx
	pop ax
	ret
endp AreTouching




;===========================
;description - deletes all the cells of an 8*8 matrix
;input - bx = ghost number * 2
;output - ax
;variables - none
;===========================
proc DeleteMatrix
	push si
	push cx
	mov si, [matrixOffset + bx]
	mov cx, 63
@@DeleteMat:
	mov [ds:si], 0
	inc si
loop @@DeleteMat
	pop cx
	pop si
	ret
endp DeleteMatrix







;===========================
;description - changes the cooardinates of the ghost to one number between 1 -64000
;input - xGhost yGhost, bx = ghost number * 2
;output - ax
;variables - none
;===========================
proc FindLocation 
    push cx
	push dx
    mov cx,[yGhost + bx]
    inc cx
    mov ax,320
    mul cx
    add ax, [xGhost + bx]
	pop dx
    pop cx
    ret
endp FindLocation





;==================
; Description  : copies a matrix from screen to ds
; Input        : 1. dx = Line Length, cx = Amount of Lines, Variable matrixOffset = Offset of the matrix you want to print, DI = Location to Print on screen(0 - 64,000), bx = ghost nubmer * 2
; Output:        On screen
;=================	
proc PutMatrixInData
	
	push es
	push ax
	push si
	
	mov ax, 0A000h
	mov es, ax
	cld
	
	push dx
	mov ax,cx
	mul dx
	mov bp,ax
	pop dx

	mov si,[matrixOffset + bx]

@@NextRow:	

	push cx
	mov cx, dx
	@@copy: ; Copy line to the data
		mov al, [es:di]
		mov [ds:si], al
		inc si
		inc di
		loop @@copy

	sub di,dx

	add di, 320
	pop cx
	loop @@NextRow

@@endProc:	
	pop si
	pop ax
	pop es
    ret

endp PutMatrixInData



;==================
; Description  : Print a Matrix from memory into Screen.
; Input        : 1. dx = Line Length, cx = Amount of Lines, Variable matrixOffset = Offset of the matrix you want to print, di = Location to Print on screen(0 - 64,000), bx = ghsot number * 2
; Output:        On screen
;=================
proc PutMatrixInScreen
	push es
	push ax
	push si
	
	mov ax, 0A000h
	mov es, ax
	cld ; for movsb direction si --> di
	
	
	mov si,[matrixOffset + bx]
	
@@NextRow:	
	push cx
	mov cx, dx
	rep movsb ; Copy whole line to the screen, si and di advances in movsb
	sub di,dx ; returns back to the begining of the line 
	add di, 320 ; go down one line by adding 320
	
	
	pop cx
	loop @@NextRow
	
		
	pop si
	pop ax
	pop es
    ret
endp PutMatrixInScreen







;===========================
;description - delets the fruit with a recursive algorithm that paints the inside of a shape (flood fill)
;input - cx = x, dx = y
;output - screen
;variables - none
;===========================
proc DeleteFruit

	
	push cx
	push dx
	
	
	push cx
	push dx
	call PixelColor
	call UpdateFruitColor
	cmp al, [FruitColor]
	je @@Cont 
	cmp al, [PeachColor]
	je @@Cont
	jmp @@Exit;pixel isn't fruit - out of the shape
@@Cont:
	mov bh, 0
	mov al, 0
	mov ah, 0ch
	int 10h
	
	;recursive part
	add cx, 1
	call DeleteFruit ;one pixel right
	sub cx, 2
	call DeleteFruit ;one pixel left
	add cx, 1 ;back to original x
	add dx ,1
	call DeleteFruit ;one pixel down
	sub dx, 2
	call DeleteFruit ; one pixel up
	
@@Exit:
	pop dx
	pop cx
	ret
endp DeleteFruit

;===========================
;description - Update the fruit and peach color according to the Palette
;input - none
;output - [FruitColor]
;variables - none
;===========================
proc UpdateFruitColor
	push ax
	push 263
	push 1
	call PixelColor
	mov [FruitColor], al
	push 263
	push 2
	call PixelColor
	mov [PeachColor], al
	pop ax
	ret
endp UpdateFruitColor







;===========================
;description - Show the score
;input - [score]
;output - screen
;files - ps.bmp (pacman score)
;===========================
proc ShowScore
	push bx
	push dx
	push ax
	
	mov bh, 0
	mov dh, 0
	mov dl, 74
	mov ah, 2
	int 10h
	mov dx ,offset ScoreString
	call PrintString
	mov bh, 0
	mov dh, 1
	mov dl, 74
	mov ah, 2
	int 10h
	push [score]
	call Print
	
	mov bh, 0
	mov dh, 3
	mov dl, 74
	mov ah, 2
	int 10h
	mov dx ,offset BestString
	call PrintString
	mov bh, 0
	mov dh, 4
	mov dl, 74
	mov ah, 2
	int 10h
	push [bestScore]
	call Print
	pop ax
	pop dx
	pop bx
	ret
endp ShowScore




;===========================
;description - Print the screen
;input - none
;output - screen
;variables - none
;files - bg.bmp 
;===========================
proc Background
	mov [FileName], 'b'
    mov [FileName + 1], 'g'
    mov [FileName + 2], '.'
    mov [FileName + 3], 'b'
    mov [FileName + 4], 'm'
    mov [FileName + 5], 'p'
    
    mov [BmpLeft], 0
    mov [BmpTop], 0
    mov [BmpColSize], 264
    mov [BmpRowSize], 200
    call Bmp
	
	ret
endp Background

;---------------------
;---------------------
;---------------------
;---------------------
;ghost proc section 
;---------------------
;---------------------
;---------------------
;---------------------




;===========================
;description - calls all the move ghosts command if they aren't eaten
;input - bx = ghost number * 2
;output - screen
;variables - x,y, 
;===========================
proc MoveGhosts
	push bx
	cmp [eaten], 1
	je @@RedEaten
	call MoveRedGhost
	
@@CheckPurple:
	cmp [eaten + 2], 1
	je @@PurpleEaten
	call MovePurpleGhost
	
	jmp @@Exit
	
@@RedEaten:
	mov bx, 0
	call DeleteGhost
	jmp @@CheckPurple
	
@@PurpleEaten:
	mov bx, 2
	call DeleteGhost
	jmp @@Exit

@@Exit:
	pop bx
	ret
endp MoveGhosts




;===========================
;description - call the correct move ghost acoording to pacman position. if the ghost is stuck in a wall decide randomly on the next direction. this is the algorithm for the red ghost
;input - none
;output - screen
;variables - x,y, 
;===========================
proc MoveRedGhost
	push ax
	push bx
	push cx
	push dx
	push di
	
	cmp [freeze], 1
	jne @@NormalBehavour
	
	;freeze ghost:
	mov [FileName], 'g'
    mov [FileName + 1], 'f'
	mov ax, [dirGhost]
	mov [FileName + 2], al
    mov [FileName + 3], '.'
    mov [FileName + 4], 'b'
    mov [FileName + 5], 'm'
    mov [FileName + 6], 'p'
	push ax
	mov ax, [xGhost]
	mov [BmpLeft], ax
	mov ax, [yGhost]
    mov [BmpTop], ax
	pop ax
    mov [BmpColSize], 8
    mov [BmpRowSize], 8
    call Bmp
	jmp @@Exit
@@NormalBehavour:
	
	
	mov ax, [xGhost]
	cmp ax, [x]
	je @@Stuck
	ja @@Left
	@@Right:
	mov bx, 0 ;ghost number
	call MoveGhostRight
	cmp [stuck], 1
	je @@Stuck
	jmp @@Cont
@@Left:
	mov bx, 0 ;ghost number
	call MoveGhostLeft
	cmp [stuck], 1
	je @@Stuck
	jmp @@Cont	
@@Cont:
	mov ax, [yGhost]
	cmp ax, [y]
	ja @@Up
	@@Down:
	mov bx, 0 ;ghost number
	call MoveGhostDown
	cmp [stuck], 1
	je @@Stuck
	jmp @@Exit
@@Up:
	mov bx, 0 ;ghost number
	call MoveGhostUp
	cmp [stuck], 1
	je @@Stuck
	jmp @@Exit

@@Stuck:
	mov [stuck], 0
	mov bl, 0
	mov bh, 3
	call RandomByCs
	cmp al, 0
	je @@Right
	cmp al, 1
	je @@Left
	cmp al, 2
	je @@Down
	cmp al, 3
	je @@Up

@@Exit:	
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	ret 
endp MoveRedGhost




;===========================
;description - call the correct move ghost randomly.this is the algorithm for the purple ghost
;input - none
;output - screen
;variables - x,y, 
;===========================
proc MovePurpleGhost
	push ax
	push bx
	
	cmp [freeze], 1
	jne @@NormalBehavour
	
	;freeze ghost:
	mov [FileName], 'g'
    mov [FileName + 1], 'f'
	mov ax, [dirGhost]
	mov [FileName + 2], al
    mov [FileName + 3], '.'
    mov [FileName + 4], 'b'
    mov [FileName + 5], 'm'
    mov [FileName + 6], 'p'
	push ax
	mov ax, [xGhost + 2]
	mov [BmpLeft], ax
	mov ax, [yGhost + 2]
    mov [BmpTop], ax
	pop ax
    mov [BmpColSize], 8
    mov [BmpRowSize], 8
    call Bmp
	jmp @@Exit
	
@@NormalBehavour:
	cmp [stuck + 2], 1
	je @@Stuck ;if ghost stuck in a wall change direciton
	cmp [purpleGhostCounter] , 10 
	jne @@MoveGhost ;only change direciton after ghost moved 10 times
	mov [stuck + 2], 0
	mov [purpleGhostCounter], 0
	mov bl, 0
	mov bh, 3
	call RandomByCs
	mov [purpleGhostDireciton], al
@@MoveGhost:
	inc [purpleGhostCounter]
	cmp [purpleGhostDireciton], 0
	je @@Right
	cmp [purpleGhostDireciton], 1
	je @@Down
	cmp [purpleGhostDireciton], 2
	je @@Left
	;direction = 3
	mov bx, 2
	call MoveGhostUp
	jmp @@Exit

@@Stuck:
	mov [stuck + 2], 0
	;change direciton on the other axis. for example if ghost moved up and than got stuck in a wall move right or left
	mov bl, 0
	mov bh, 1
	call RandomByCs
		cmp al, 0
		je @@RemoveOne
		inc [purpleGhostDireciton]
		jmp @@Modulo
	@@RemoveOne:
		dec [purpleGhostDireciton]
	@@Modulo: ;does modulo by 4
			cmp [purpleGhostDireciton], 0
			jae @@NonNegative
			add [purpleGhostDireciton], 4
			jmp @@MoveGhost
		@@NonNegative:
			cmp [purpleGhostDireciton], 4
			jb @@MoveGhost ;direction is between 0 - 3
			sub [purpleGhostDireciton], 4
			jmp @@MoveGhost

@@Right:
	mov bx, 2
	call MoveGhostRight
	jmp @@Exit
@@Down:
	mov bx, 2
	call MoveGhostDown
	jmp @@Exit
@@Left:
	mov bx, 2
	call MoveGhostLeft
	jmp @@Exit
	
@@Exit:
	pop bx
	pop ax
	ret 
endp MovePurpleGhost







;===========================
;description - deletes ghost
;input - bx = ghsot number * 2
;output - screen
;variables - x,y, 
;===========================
proc DeleteGhost
	push ax
	push di
	push cx
	push dx
	call FindLocation
	mov di, ax
	mov dx, 8
	mov cx, 8
	call PutMatrixInScreen
	pop dx
	pop cx
	pop di
	pop ax
	; push [xghost]
	; push [yghost]
	; push 9
	; push 8
	; push 0
	; call drawfullrect
	ret 
endp DeleteGhost




;===========================
;description - moves ghost right with animation
;input - bx = ghsot number * 2
;output - screen
;variables - x,y, 
;===========================
proc MoveGhostRight
	mov [dirGhost + bx], '1'
	
	mov [FileName], 'g'
	
	push ax
	xor ah, ah
	mov al, bl
	add al, '1'
    mov [FileName + 1], al
	
    mov [FileName + 2], '.'
    mov [FileName + 3], 'b'
    mov [FileName + 4], 'm'
    mov [FileName + 5], 'p'
	
	mov ax, [xGhost + bx]
	mov [BmpLeft], ax
	mov ax, [yGhost + bx]
    mov [BmpTop], ax
	pop ax
	
    mov [BmpColSize], 8
    mov [BmpRowSize], 8
    call Bmp

	push di
	push si
	mov di, [xGhost + bx]
	add di, 8
	mov si, [yGhost + bx]
	mov cx, 8
	@@Line: ;this loop checks if the next line is clear 
		push di
		push si
		call PixelColor
		call UpdateFruitColor
			cmp al, [FruitColor]
			je @@Fruit
			cmp al, [PeachColor]
			je @@Fruit
			cmp al, 0
			je @@Black
			mov [stuck + bx] ,1
			jmp @@Exit
		@@Fruit:
			
		@@Black:
			inc si
			loop @@Line

	call DeleteGhost
	
	inc [xGhost + bx]
	inc [BmpLeft]
	
	;back up the background before drawing ghost
	call FindLocation
	push di
	push cx
	push dx
	mov di, ax
	mov cx, 8
	mov dx, 8
	call PutMatrixInData
	pop dx
	pop cx
	pop di
			
	call Bmp
@@Exit:
	pop si
	pop di
	ret

endp MoveGhostRight



;===========================
;description - moves ghost left
;input - bx = ghost number * 2
;output - screen
;variables - x,y, 
;===========================
proc MoveGhostLeft	
	
	mov [dirGhost + bx], '2'
	
	mov [FileName], 'g'
	
	push ax
	xor ah, ah
	mov al, bl
	add al, '2'
    mov [FileName + 1], al
	
    mov [FileName + 2], '.'
    mov [FileName + 3], 'b'
    mov [FileName + 4], 'm'
    mov [FileName + 5], 'p'
	mov ax, [xGhost + bx]
	mov [BmpLeft], ax
	mov ax, [yGhost + bx]
    mov [BmpTop], ax
	pop ax
	
    mov [BmpColSize], 8
    mov [BmpRowSize], 8
    call Bmp

	push di
	push si
	mov di, [xGhost + bx]
	dec di
	mov si, [yGhost + bx]
	mov cx, 8			
	
	@@Line: ;this loop checks if the next line is clear 
		push di
		push si
		call PixelColor
		call UpdateFruitColor
			cmp al, [FruitColor]
			je @@Fruit
			cmp al, [PeachColor]
			je @@Fruit
			cmp al, 0
			je @@Black
			mov [stuck + bx] ,1
			jmp @@Exit
		@@Fruit:
			
		@@Black:
			inc si
			loop @@Line
	
	
	call DeleteGhost ;putmatrix in screen
	dec [xGhost + bx]
	dec [BmpLeft]
	
	;back up the background before drawing ghost
	call FindLocation
	push di
	push cx
	push dx
	mov di, ax
	mov cx, 8
	mov dx, 8
	call PutMatrixInData
	pop dx
	pop cx
	pop di
	
	call Bmp
@@Exit:
	pop si
	pop di
	
	ret

endp MoveGhostLeft




;===========================
;description - moves ghost down
;input - bx = ghost number
;output - screen
;variables - x,y, 
;===========================
proc MoveGhostDown
	push ax
	xor ah, ah
	
	mov [FileName], 'g'
	mov ax, [dirGhost]
	add ax, bx
    mov [FileName + 1], al
    mov [FileName + 2], '.'
    mov [FileName + 3], 'b'
    mov [FileName + 4], 'm'
    mov [FileName + 5], 'p'
	mov ax, [xGhost + bx]
	mov [BmpLeft], ax
	mov ax, [yGhost + bx]
    mov [BmpTop], ax
    mov [BmpColSize], 8
    mov [BmpRowSize], 8
    call Bmp
	
	pop ax
	
	push di
	push si
	mov di, [yGhost + bx]
	add di, 9
	mov si, [xGhost + bx]
	mov cx, 8
	@@Line: ;this loop checks if the next line is clear 
		push si
		push di
		call PixelColor
		call UpdateFruitColor
			cmp al, [FruitColor]
			je @@Fruit
			cmp al, [PeachColor]
			je @@Fruit
			cmp al, 0
			je @@Black
			mov [stuck + bx] ,1
			jmp @@Exit
		@@Fruit:
		@@Black:
			inc si
			loop @@Line
	call DeleteGhost ;putmatrix in screen
	inc [yGhost + bx]
	inc [BmpTop]
	
	;back up background before drawing ghost
	call FindLocation
	push di
	push cx
	push dx
	mov di, ax
	mov cx, 8
	mov dx, 8
	call PutMatrixInData
	pop dx
	pop cx
	pop di
	
	call Bmp
@@Exit:
	pop si
	pop di
	ret
endp MoveGhostDown




;===========================
;description - moves ghost up
;input - put in bx ghost nubmer
;output - screen
;variables - xGhost,yGhost, dirGhost 
;===========================
proc MoveGhostUp
	push ax
	xor ah, ah
	
	mov [FileName], 'g'
    mov ax, [dirGhost]
	add ax, bx
    mov [FileName + 1], al
    mov [FileName + 2], '.'
    mov [FileName + 3], 'b'
    mov [FileName + 4], 'm'
    mov [FileName + 5], 'p'
	mov ax, [xGhost + bx]
	mov [BmpLeft], ax
	mov ax, [yGhost + bx]
    mov [BmpTop], ax
	pop ax
    mov [BmpColSize], 8
    mov [BmpRowSize], 8
    call Bmp

	push di
	push si
	mov di, [yGhost + bx]
	dec di
	mov si, [xGhost + bx]
	mov cx, 8	
	
	@@Line: ;this loop checks if the next line is clear 
		push si
		push di
		call PixelColor
		call UpdateFruitColor
			cmp al, [FruitColor]
			je @@Fruit
			cmp al, [PeachColor]
			je @@Fruit
			cmp al, 0
			je @@Black
			mov [stuck + bx] ,1
			jmp @@Exit
		@@Fruit:
		
		@@Black:
			inc si
			loop @@Line
	call DeleteGhost
	dec [yGhost + bx]
	dec [BmpTop]
	
	;back up background before drawing ghost
	call FindLocation
	push di
	push cx
	push dx
	mov di, ax
	mov cx, 8
	mov dx, 8
	call PutMatrixInData
	pop dx
	pop cx
	pop di
	
	call Bmp
@@Exit:
	pop si
	pop di
	ret

endp MoveGhostUp





;---------------------
;---------------------
;---------------------
;---------------------
;pacman proc section 
;---------------------
;---------------------
;---------------------
;---------------------




;===========================
;description - deletes pacman
;input - none
;output - screen
;variables - x,y, 
;===========================
proc DeletePacman
	push [x]
	push [y]
	push 9
	push 8
	push 0
	call DrawFullRect
	ret 
endp DeletePacman


;===========================
;description - delete pacman and call the appropriate move proc according to the direciton
;input - head location, direction
;output - screen
;variables - x,y, direction
;===========================
proc MovePacman
	
	cmp [direction], 0
	je @@Right
	cmp [direction], 1
	je @@Down
	cmp [direction], 2
	je @@Left
	;direction = 3
	call MovePacmanUp
	jmp @@Exit
	
@@Right:
	call MovePacmanRight
	jmp @@Exit
@@Down:
	call MovePacmanDown
	jmp @@Exit
@@Left:
	call MovePacmanLeft
	jmp @@Exit
	
@@Exit:
	ret
endp MovePacman



;===========================
;description - move packman right 2 pixels if available, with animation
;input - head location
;output - screen
;variables - x,y 
;files - p1.bmp
;===========================
proc MovePacmanRight
	mov [FileName], 'p'
    mov [FileName + 1], '1'
    mov [FileName + 2], '.'
    mov [FileName + 3], 'b'
    mov [FileName + 4], 'm'
    mov [FileName + 5], 'p'
	push ax
	mov ax, [x]
	mov [BmpLeft], ax
	mov ax, [y]
    mov [BmpTop], ax
	pop ax
    mov [BmpColSize], 8
    mov [BmpRowSize], 8
    call Bmp
	call Delay100ms
	call Delay100ms

	push bx
	push di
	push si
	mov di, [x]
	add di, 8
	mov si, [y]
	mov cx, 8
	@@Line: ;this loop checks if the next line is clear 
		push di
		push si
		call PixelColor
		call UpdateFruitColor
			cmp al, [FruitColor]
			je @@Fruit
			cmp al, [PeachColor]
			je @@Peach
			cmp al, 0
			je @@Black
			jmp @@Exit
		@@Peach:
			add [score], 56
			push cx
			push dx
			mov cx, di
			mov dx, si
			call DeleteFruit
			pop dx
			pop cx
			mov [freeze], 1
			inc si
			loop @@Line
		@@Fruit:
			add [score], 14
			push cx
			push dx
			mov cx, di
			mov dx, si
			call DeleteFruit
			pop dx
			pop cx
		@@Black:
			inc si
			loop @@Line
	call DeletePacman
	inc [x]
	inc [BmpLeft]
	inc [filename + 1]
	call Bmp
@@Exit:
	pop si
	pop di
	pop bx
	ret
endp MovePacmanRight


;===========================
;description - move packman down 2 pixels if available, with animation
;input - head location
;output - screen
;variables - x,y 
;files - p3.bmp, p4.bmp
;===========================
proc MovePacmanDown
	mov [FileName], 'p'
    mov [FileName + 1], '3'
    mov [FileName + 2], '.'
    mov [FileName + 3], 'b'
    mov [FileName + 4], 'm'
    mov [FileName + 5], 'p'
	push ax
	mov ax, [x]
	mov [BmpLeft], ax
	mov ax, [y]
    mov [BmpTop], ax
	pop ax
    mov [BmpColSize], 8
    mov [BmpRowSize], 8
    call Bmp
	call Delay100ms
	call Delay100ms

	push di
	push si
	mov di, [y]
	add di, 9
	mov si, [x]
	mov cx, 8
	@@Line: ;this loop checks if the next line is clear 
		push si
		push di
		call PixelColor
		call UpdateFruitColor
			cmp al, [FruitColor]
			je @@Fruit
			cmp al, [PeachColor]
			je @@Peach
			cmp al, 0
			je @@Black
			jmp @@Exit
		@@Peach:
			add [score], 56
			push cx
			push dx
			mov cx, si
			mov dx, di
			call DeleteFruit
			pop dx
			pop cx
			mov [freeze], 1
			inc si
			loop @@Line
		@@Fruit:
			add [score], 14
			push cx
			push dx
			mov cx, si
			mov dx, di
			call DeleteFruit
			pop dx
			pop cx
		@@Black:
			inc si
			loop @@Line
	call DeletePacman
	inc [y]
	inc [BmpTop]
	inc [filename + 1]
	call Bmp
@@Exit:
	pop si
	pop di
	ret
endp MovePacmanDown




;===========================
;description - move packman left 2 pixels if available, with animation
;input - head location
;output - screen
;variables - x,y 
;files - p5.bmp, p6.bmp
;===========================
proc MovePacmanLeft
	mov [FileName], 'p'
    mov [FileName + 1], '5'
    mov [FileName + 2], '.'
    mov [FileName + 3], 'b'
    mov [FileName + 4], 'm'
    mov [FileName + 5], 'p'
	push ax
	mov ax, [x]
	mov [BmpLeft], ax
	mov ax, [y]
    mov [BmpTop], ax
	pop ax
    mov [BmpColSize], 8
    mov [BmpRowSize], 8
    call Bmp
	call Delay100ms
	call Delay100ms
	
	
	push di
	push si
	mov di, [x]
	dec di
	mov si, [y]
	mov cx, 8
	@@Line: ;this loop checks if the next line is clear 
		push di
		push si
		call PixelColor
		call UpdateFruitColor
			cmp al, [FruitColor]
			je @@Fruit
			cmp al, [PeachColor]
			je @@Peach
			cmp al, 0
			je @@Black
			jmp @@Exit
		@@Peach:
			add [score], 56
			push cx
			push dx
			mov cx, di
			mov dx, si
			call DeleteFruit
			pop dx
			pop cx
			mov [freeze], 1
			inc si
			loop @@Line
		@@Fruit:
			add [score], 14
			push cx
			push dx
			mov cx, di
			mov dx, si
			call DeleteFruit
			pop dx
			pop cx
		@@Black:
			inc si
			loop @@Line
	call DeletePacman
	dec [x]
	dec [BmpLeft]
	inc [filename + 1]
	call Bmp
@@Exit:
	pop si
	pop di
	ret
endp MovePacmanLeft



;===========================
;description - move packman up 2 pixels if available, with animation
;input - head location
;output - screen
;variables - x,y 
;files - p7.bmp, p8.bmp
;===========================
proc MovePacmanUp
	mov [FileName], 'p'
    mov [FileName + 1], '7'
    mov [FileName + 2], '.'
    mov [FileName + 3], 'b'
    mov [FileName + 4], 'm'
    mov [FileName + 5], 'p'
	push ax
	mov ax, [x]
	mov [BmpLeft], ax
	mov ax, [y]
    mov [BmpTop], ax
	pop ax
    mov [BmpColSize], 8
    mov [BmpRowSize], 8
    call Bmp
	call Delay100ms
	call Delay100ms
	
	push di
	push si
	mov di, [y]
	dec di
	mov si, [x]
	mov cx, 8
	@@Line: ;this loop checks if the next line is clear 
		push si
		push di
		call PixelColor
		call UpdateFruitColor
			cmp al, [FruitColor]
			je @@Fruit
			cmp al, [PeachColor]
			je @@Peach
			cmp al, 0
			je @@Black
			jmp @@Exit
		@@Peach:
			add [score], 56
			push cx
			push dx
			mov cx, si
			mov dx, di
			call DeleteFruit
			pop dx
			pop cx
			mov [freeze], 1
			inc si
			loop @@Line
		@@Fruit:
			add [score], 14
			push cx
			push dx
			mov cx, si
			mov dx, di
			call DeleteFruit
			pop dx
			pop cx
		@@Black:
			inc si
			loop @@Line
	call DeletePacman
	dec [y]
	dec [BmpTop]
	inc [filename + 1]
	call Bmp
@@Exit:
	pop si
	pop di
	ret
endp MovePacmanUp









;---------------------
;---------------------
;---------------------
;---------------------
;miscs proc section 
;---------------------
;---------------------
;---------------------
;---------------------

;===========================
;description - Delay for .1 seconds
;input - none
;output - none
;variables - none
;===========================
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




;---------------------
;---------------------
;---------------------
;---------------------
;bmp proc section 
;---------------------
;---------------------
;---------------------
;---------------------


;===========================
;description - Displays an image on the screen
;input - FileName contains the name, and BmpLeft, BmpTop, BmpColSize and BmpRowSize contains the respective values
;output - console
;variables - FileName, BmpLeft, BmpTop, BmpColSize, BmpRowSize
;===========================
proc Bmp
	push bx
	push dx
	push si
	push ax
	
	
	mov dx, offset FileName
	call OpenShowBmp
	cmp [ErrorFile],1
	jne @@cont 
	jmp @@exitError
@@cont:

	
    jmp @@exit
	
@@exitError:
	mov ax,2
	int 10h
	
    mov dx, offset BmpFileErrorMsg
	mov ah,9
	int 21h
	
@@exit:
	
	pop ax
	pop si
	pop dx	
	pop bx
    ret
endp Bmp

;===============
;the following next procs, are used to help the previous proc and shouldn't be called on their own
;===============

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





;---------------------
;---------------------
;---------------------
;---------------------
;basic input output proc section 
;---------------------
;---------------------
;---------------------
;---------------------



;===========================
;description - return pixel color
;input - push x,y 
;output - al (pixel color)
;variables - none
;===========================
proc PixelColor
	push bp
	mov bp, sp
	push cx
	push dx
	
	mov bh, 0
	mov cx, [bp + 6]
	mov dx, [bp + 4]
	mov ah, 0dh
	int 10h
	
	pop dx
	pop cx
	pop bp
	ret 4
endp PixelColor

;===========================
;description - Prints a new line
;input - none
;output - console
;variables - New_Line
;===========================
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

;===========================
;description - Prints a string
;input - put string offset in dx
;output - console
;variables - none
;===========================
proc PrintString
	push ax
	
	
	mov ah, 9h
	int 21h
	
	pop ax
	ret
endp


;===========================
;description - Prints a character
;input - put char ascii in dl
;output - console
;variables - none
;===========================
proc PrintChar
	push ax
	
	mov ah, 2
	int 21h
	
	pop ax
	ret
endp

;===========================
;description - Input a character
;input - console
;output - al contains the ascii
;variables - none
;===========================
proc InputChar
	mov ah, 1
	int 21h

	ret
endp

;===========================
;description - Input a string
;input - console, dx contains offset of the string
;output - [dx]
;variables - none
;===========================
proc InputString
	push ax
	
	mov ah, 1
	int 21h
	
	pop ax
	ret
endp

;===========================
;description - Draws a vertical line on the fruit only
;input -  push in that order: x,y,len,color
;output - screen
;variables - none
;===========================
proc DrawVerticalLineOnFruit

	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	
	
	mov bh, 0
	mov cx, [bp+6]
@@DrawVertLine:
	push cx
	call UpdateFruitColor
	push [bp + 10]
	push [bp + 8]
	call PixelColor
	cmp al, [FruitColor]
	jne @@Skip
	mov cx, [bp+10]
	mov dx, [bp+8]
	mov al, [bp+4]
	mov ah, 0ch
	int 10h
@@Skip:
	pop cx
	inc [bp+8]
	loop @@DrawVertLine
	
	;mov ax, 2
	;int 10h

	pop cx
	pop bx
	pop ax
	pop bp

	ret 8
endp DrawVerticalLineOnFruit



;===========================
;description - Draws a rectangle on fruit only
;input - push in that order: x,y,len,wid,color
;output - screen
;variables - none
;===========================
proc DrawFullRectOnFruit
	push bp
	mov bp, sp
	push cx
	
	mov cx, [bp+6]
@@DrawR:
	push [bp+12]
	push [bp+10]
	push [bp+8]
	push [bp+4]
	call DrawVerticalLineOnFruit
	add [bp+12], 1
	loop @@DrawR

	pop cx
	pop bp
	
	ret 10
endp DrawFullRectOnFruit

;===========================
;description - Draws a vertical line
;input -  push in that order: x,y,len,color
;output - screen
;variables - none
;===========================
proc DrawVerticalLine 

	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	
	
	mov bh, 0
	mov cx, [bp+6]
@@DrawVertLine:
	push cx
	mov cx, [bp+10]
	mov dx, [bp+8]
	mov al, [bp+4]
	mov ah, 0ch
	int 10h
	pop cx
	inc [bp+8]
	loop @@DrawVertLine
	
	;mov ax, 2
	;int 10h

	pop cx
	pop bx
	pop ax
	pop bp

	ret 8
endp DrawVerticalLine



;===========================
;description - Draws a rectangle
;input - push in that order: x,y,len,wid,color
;output - screen
;variables - none
;===========================
proc DrawFullRect
	push bp
	mov bp, sp
	push cx
	
	mov cx, [bp+6]
@@DrawR:
	push [bp+12]
	push [bp+10]
	push [bp+8]
	push [bp+4]
	call DrawVerticalLine
	add [bp+12], 1
	loop @@DrawR

	pop cx
	pop bp
	
	ret 10
endp DrawFullRect


;===========================
;description - Prints the contain of ax
;input - ax
;output - screen
;variables - none
;===========================
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
		
		mov bh, 0
		mov dh, 2
		mov dl, 74
		mov ah, 2
		int 10h
	   
	   mov dl, 20h
       mov ah, 2h
	   int 21h
   
	   pop dx
	   pop cx
	   pop bx
	   pop ax
	   
	   ret
endp ShowAxDecimal

;===========================
;description - prints any word size number in decimal
;input - push number
;output - screen
;variables - none
;===========================
proc Print
	push bp
	mov bp, sp
	push ax
	push bx
	push dx
	
	; mov bh, 0
	; mov dh, 0
	; mov dl, 200
	; mov ah, 2
	; int 10h
	
	mov ax, [bp +4]
	call ShowAxDecimal
	
	pop bp
	pop ax
	pop bx
	pop dx
	ret 2
endp

;===========================
;description - changes dosbox into Graphic mode
;input - none
;output - none
;variables - none
;===========================
proc  SetGraphic
	push ax
	mov ax,13h   ; 320 X 200 
				 ;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode 
	int 10h
	pop ax
	ret
endp 	SetGraphic

;===========================
;description - changes dosbox into text mode
;input - none
;output - none
;variables - none
;===========================
proc SetText
	push ax
	mov ax, 2
	int 10h
	pop ax
	ret
endp SetText


;---------------------
;---------------------
;---------------------
;---------------------
;Random proc section 
;---------------------
;---------------------
;---------------------
;---------------------




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


EndOfCsLbl:

END start