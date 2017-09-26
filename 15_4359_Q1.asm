;Using the pixel-drawing capabilities of INT 10h, create a procedure 
;named DrawShapes that takes input parameters specifying the type of shape, 
;location of the upper left corner and the lower right corner, 
;and the color of the shape. Assign different letters to different shapes
;like C for circle, R for rectangle, D for diamond etc. 
;Whenever a user presses a specific key, 
;the corresponding shape is drawn on the screen at specified location. 
;Write a short test program that draws atleast 4 types of shapes of different sizes and colors.









[org 0x100]
jmp start
oldr: dd 0

; subroutine to clear the screen


drawrect:	push bp
		mov bp, sp
		sub sp, 8			; local variables
		push ax
		push si
		push di

		mov cl, [bp + 8]		; move bottom-right(x) to cl
		mov [bp - 2], cl
		mov ch, [bp + 10]		; move top-left(y) to ch
		mov [bp - 4], ch

		mov ch, [bp + 12]		; move top-left(x) to ch
		mov [bp - 6], ch
		mov cl, [bp + 6]		; move bottom-right(y) to cl
		mov [bp - 8], cl
		jmp printPlus
			
coordinate:	mov ax, 0xb800
		mov es, ax			; point es to video base
		
		mov al, 80			; load al with columns per row
		mul byte [bp + 10]		; multiuply with y position
		add ax, [bp + 12]		; add x position
		shl ax, 1			; turn into byte offset
		mov di, ax			; point di to the required location
		
		mov al, 80			; load al with columns per row
		mul byte [bp + 6]		; multiuply with y position
		add ax, [bp + 8]		; add x position
		shl ax, 1			; turn into byte offset
		mov si, ax			; point si to the required location

		mov ah, [bp + 4]		; load attribute in ah
		ret				; return 

printPlus:	call coordinate			; find the next display location
		mov al, 0x2B			; move hex of + to al
		mov [es : di], ax
		mov [es : si], ax
		mov bl, [bp - 8]		; check for complete rectangle
		cmp [bp + 10], bl
		je return
		mov bh, [bp - 2]		; check for (top-right) and (bottom-left) corner
		cmp [bp + 12], bh
		je printSlash

printMinus:	add byte [bp + 12], 1
		sub byte [bp + 8], 1
		mov bh, [bp - 2]		; check for (top-right) and (bottom-left) corner
		cmp [bp + 12], bh
		je printPlus
		call coordinate
		mov al, 0x2D
		mov [es : di], ax
		mov [es : si], ax
		jmp printMinus

printSlash:	add byte [bp + 10], 1
		sub byte [bp + 6], 1
		mov bh, [bp - 8]		; check for complete rectangle
		cmp [bp + 10], bh
		je return
		call coordinate
		mov al, 0x7c
		mov [es : di], ax
		mov [es : si], ax
		jmp printSlash

return:		pop di
		pop si
		pop ax
		pop es
		pop bp
		ret 10
		















clrscr:		push es
		push ax
		push di
		
		mov ax, 0xb800
		mov es, ax			; point es to video base
		mov di, 0			; point di to top left column
		
nextloc:	mov word [es : di], 0x0720	; clear next char on screen
		add di, 2			; move to next screen location
		cmp di, 4000			; has the whole screen cleared
		jne nextloc			; if no clear next position
			
		pop di
		pop ax
		pop es
		ret
		
; subroutine to draw a rectangle
drawrect:	push bp
		mov bp, sp
		sub sp, 8			; local variables
		push ax
		push si
		push di

		mov cl, [bp + 8]		; move bottom-right(x) to cl
		mov [bp - 2], cl
		mov ch, [bp + 10]		; move top-left(y) to ch
		mov [bp - 4], ch

		mov ch, [bp + 12]		; move top-left(x) to ch
		mov [bp - 6], ch
		mov cl, [bp + 6]		; move bottom-right(y) to cl
		mov [bp - 8], cl
		jmp printPlus
			
coordinate:	mov ax, 0xb800
		mov es, ax			; point es to video base
		
		mov al, 80			; load al with columns per row
		mul byte [bp + 10]		; multiuply with y position
		add ax, [bp + 12]		; add x position
		shl ax, 1			; turn into byte offset
		mov di, ax			; point di to the required location
		
		mov al, 80			; load al with columns per row
		mul byte [bp + 6]		; multiuply with y position
		add ax, [bp + 8]		; add x position
		shl ax, 1			; turn into byte offset
		mov si, ax			; point si to the required location

		mov ah, [bp + 4]		; load attribute in ah
		ret				; return 

printPlus:	call coordinate			; find the next display location
		mov al, 0x2B			; move hex of + to al
		mov [es : di], ax
		mov [es : si], ax
		mov bl, [bp - 8]		; check for complete rectangle
		cmp [bp + 10], bl
		je return
		mov bh, [bp - 2]		; check for (top-right) and (bottom-left) corner
		cmp [bp + 12], bh
		je printSlash

printMinus:	add byte [bp + 12], 1
		sub byte [bp + 8], 1
		mov bh, [bp - 2]		; check for (top-right) and (bottom-left) corner
		cmp [bp + 12], bh
		je printPlus
		call coordinate
		mov al, 0x2D
		mov [es : di], ax
		mov [es : si], ax
		jmp printMinus

printSlash:	add byte [bp + 10], 1
		sub byte [bp + 6], 1
		mov bh, [bp - 8]		; check for complete rectangle
		cmp [bp + 10], bh
		je return
		call coordinate
		mov al, 0x7c
		mov [es : di], ax
		mov [es : si], ax
		jmp printSlash

return:		pop di
		pop si
		pop ax
		pop es
		pop bp
		ret 10
		





mykbr:
push es

push ds

push cs

push ax

next:mov ah,0

int 0x16

cmp al,'R'

jne nextcmp

nextcmp:cmp al,'C'
jne nextcmp2
call clrscr

nextcmp2:cmp al,'D'
call clrscr
jne exit


call clrscr			; call the clrscr subroutine
			
		mov ax, 10 
		push ax				; push top-left (x)
		mov ax, 2
		push ax				; push top-left (y)

		mov ax, 50
		push ax				; push bottom-right (x)
		mov ax, 20 
		push ax				; push bottom-righ
 (y)
	
		mov ax, 2
		push ax				; push green on black attribute
			
		call drawrect

jmp next

exit:
pop ax

pop cs

pop ds

pop es

iret





start:
xor ax,ax

mov es,ax

mov ax,[es:10h*4]

mov [oldr],ax

mov ax,[es:10h*4+2]

mov [oldr+2],ax





mov word[es:10h*4],mykbr


mov [es:10h*4+2],cs



int 10h
jmp $