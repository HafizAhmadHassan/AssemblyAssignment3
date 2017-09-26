[org 100h]
jmp start
sign: db '*'
tickcount: dw 0
second: dw 0
countarr: db 0,0,0,0,0,0,0,0,0,0
flag: dw 0
charcount: dw 0
total: dw 0

; subroutine to print a number at top left of screen
; takes the number to be printed as its parameter


message: db '*', 0 ; null terminated string
clrscr: push es
push ax
push cx
push di
mov ax, 0xb800
mov es, ax ; point es to video base
xor di, di ; point di to top left column
mov ax, 0x0720 ; space char in normal attribute
mov cx, 2000 ; number of screen locations
cld ; auto increment mode
rep stosw ; clear the whole screen
pop di
pop cx
pop ax
pop es
ret
printstr: push bp
mov bp, sp
push es
push ax
push cx
push si
push di
push ds
pop es ; load ds in es
mov di, [bp+4] ; point di to string
mov cx, 0xffff ; load maximum number in cx
xor al, al ; load a zero in al
repne scasb ; find zero in the string
mov ax, 0xffff ; load maximum number in ax
sub ax, cx ; find change in cx
dec ax ; exclude null from length
jz exit3 ; no printing if string is empty
mov cx, ax ; load string length in cx
mov ax, 0xb800
mov es, ax ; point es to video base
mov al, 80 ; load al with columns per row
mul byte [bp+8] ; multiply with y position
add ax, [bp+10] ; add x position
shl ax, 1 ; turn into byte offset
mov di,ax ; point di to required location
mov si, [bp+4] ; point si to string
mov ah, [bp+6] ; load attribute in ah
cld ; auto increment mode
nextchar: lodsb ; load next char in al
stosw ; print char/attribute pair1
loop nextchar ; repeat for the whole string
exit3: pop di
pop si
pop cx
pop ax
pop es
pop bp
ret 8
















timer: push ax
inc word [cs:tickcount]                       ; increment tick count
cmp word[cs:tickcount],18
je secon
jmp exit2
secon:add word[cs:second],1
mov word [cs:tickcount],0
exit2:mov al, 0x20
out 0x20, al ; end of interrupt
pop ax
iret

; display:
; mov dx,cx
; push si
; push di

; print:
; mov si,0
; mov di,78

; forward:
; mov [es:2000+di],ax
; mov [es:1920+si],ax
; mov bx,0
; mov cx,0
; call sleep
; call clear
; add si,2
; sub dx,1
; cmp dx,0
; je back
; sub di,2
; cmp si,78
; jbe forward

; backward:
; mov [es:2000+di],ax
; mov [es:1920+si],ax
; mov bx,0
; mov cx,0
; call sleep
; call clear
; add di,2
; sub si,2
; cmp di,76
; jbe backward
; loop forward

; clear:
; mov word[es:2000+di],0x0720
; mov word[es:1920+si],0x0720
; ret

; sleep:
; come:
; add bx,1
; cmp bx,40000
; jbe come
; add cx,2
; cmp cx,4000
; jbe sleep
; ret

; back:
; pop di
; pop si
; ret


start:

mov bx,countarr
m:
mov si,0
n:
mov ah,0
int 0x16
cmp al,'$'
je exit
inc word[charcount]
cmp word[second],1
jb n

f:
mov al,[charcount]
mov [bx+si],al
add si,1
add word[flag],1
mov word[second],0
mov word[charcount],0
cmp si,10
je m1
jmp n
m1:

jmp m

exit:

; mov al,[sign]
; mov ah,1
; mov bx,0xb800
; mov es,bx



;cmp word[flag],10
;jae next
;jmp ex
next:
mov cx,0
mov di,0
 mov si,countarr
g:add cx,[si]
add si,1
add di,1
cmp di,10
jne g
mov bx,0

e:

again:call clrscr
mov ax, 78
push ax ; push x position
mov ax, bx
add bx,1
push ax ; push y position
mov ax, 1 ; blue on black attribute
push ax ; push attribute
mov ax, message
push ax ; push address of message
call printstr ; call the printstr subroutine
cmp bx,24
jne again

mov dx,0xffff
fg:sub dx,1
cmp dx,0
jne fg

loop e

ex:
mov ax,4ch
int 21h