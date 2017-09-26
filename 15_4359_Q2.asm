; multitasking kernel as a TSR
[org 0x0100]
jmp start
; PCB layout:
; ax,bx,cx,dx,si,di,bp,sp,ip,cs,ds,ss,es,flags,next,dummy
; 0, 2, 4, 6, 8,10,12,14,16,18,20,22,24, 26 , 28 , 30
pcb: times 32*16 dw 0 ; space for 32 PCBs

tickcount: dw 0
stack: times 32*256 dw 0 ; space for 32 512 byte stacks
nextpcb: dw 1 ; index of next free pcb
current: dw 0 ; index of current pcb
column: dw 80
paramblock: times 5 dw 0 ; space for parameters
lineno: dw 0 ; line number for next thread
chars: db '\|/-' ; chracters for rotating bar
message: db 'a' ; moving string
message2: db ' ' ; to erase previous string
messagelen: dw 1; length of above strings
col: dw 0


printstr: push bp
mov bp, sp
push es
push ax
push bx
push cx
push dx
push si
push di
mov ax, 0xb800
mov es, ax ; point es to video base
mov di, 80 ; load di with columns per row
mov ax, [bp+10] ; load ax with row number
mul di ; multiply with columns per row
mov di, ax ; save result in di
add di, [bp+8] ; add column number
shl di, 1 ; turn into byte count
mov si, [bp+6] ; string to be printed
mov cx, [bp+4] ; length of string
mov ah, 0x07 ; normal attribute is fixed
nextchar: mov al, [si] ; load next char of string
mov [es:di], ax ; show next char on screen
add di, 2 ; move to next screen location
add si, 1 ; move to next char
loop nextchar ; repeat the operation cx times
pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop es
pop bp
ret 8



mytask3:
push bp
mov bp, sp
sub sp, 2 ; thread local variable
push ax
push bx
push cx
mov word [bp-2], 0 ; initialize line number to 0


push ax
push dx
mov ax,[tickcount]
div word[column]
mov [col],dx
pop dx
pop ax


nextline:
push word [bp-2] ; line number
mov bx, [col]

push bx ; column number 50
mov ax, message
push ax ; offset of string
push word [messagelen] ; length of string
call printstr ; print the string


mov cx, 0xffff
loop $ ; repeat ffff times


push word [bp-2] ; line number
mov bx, [col] ; column number 50
push bx
mov ax, message2
push ax ; offset of blank string
push word [messagelen] ; length of string
call printstr ; print the string

inc word [bp-2] ; update line number
cmp word [bp-2], 25 ; is this the last line
jne nextline
jmp $

pop cx
pop bx
pop ax
mov sp, bp
pop bp
retf





timer: push ds


inc word[tickcount]


push bx
push cs
pop ds ; initialize ds to data segment
mov bx, [current] ; read index of current in bx
shl bx, 1
shl bx, 1
shl bx, 1
shl bx, 1
shl bx, 1 ; multiply by 32 for pcb start
mov [pcb+bx+0], ax ; save ax in current pcb
mov [pcb+bx+4], cx ; save cx in current pcb
mov [pcb+bx+6], dx ; save dx in current pcb
mov [pcb+bx+8], si ; save si in current pcb
mov [pcb+bx+10], di ; save di in current pcb
mov [pcb+bx+12], bp ; save bp in current pcb
mov [pcb+bx+24], es ; save es in current pcb
pop ax ; read original bx from stack
mov [pcb+bx+2], ax ; save bx in current pcb
pop ax ; read original ds from stack
mov [pcb+bx+20], ax ; save ds in current pcb
pop ax ; read original ip from stack
mov [pcb+bx+16], ax ; save ip in current pcb
pop ax ; read original cs from stack
mov [pcb+bx+18], ax ; save cs in current pcb
pop ax ; read original flags from stack
mov [pcb+bx+26], ax ; save cs in current pcb
mov [pcb+bx+22], ss ; save ss in current pcb
mov [pcb+bx+14], sp ; save sp in current pcb
mov bx, [pcb+bx+28] ; read next pcb of this pcb
mov [current], bx ; update current to new pcb
mov cl, 5
shl bx, cl ; multiply by 32 for pcb start
mov cx, [pcb+bx+4] ; read cx of new process
mov dx, [pcb+bx+6] ; read dx of new process
mov si, [pcb+bx+8] ; read si of new process
mov di, [pcb+bx+10] ; read diof new process

mov bp, [pcb+bx+12] ; read bp of new process
mov es, [pcb+bx+24] ; read es of new process
mov ss, [pcb+bx+22] ; read ss of new process
mov sp, [pcb+bx+14] ; read sp of new process
push word [pcb+bx+26] ; push flags of new process
push word [pcb+bx+18] ; push cs of new process
push word [pcb+bx+16] ; push ip of new process
push word [pcb+bx+20] ; push ds of new process
mov al, 0x20
out 0x20, al ; send EOI to PIC
mov ax, [pcb+bx+0] ; read ax of new process
mov bx, [pcb+bx+2] ; read bx of new process
pop ds ; read ds of new process
iret
; software interrupt to register a new thread
; takes parameter block in ds:si
; parameter block has cs, ip, ds, es, and param in this order
initpcb: push ax
push bx
push cx
push di
mov bx, [cs:nextpcb] ; read next available pcb index
cmp bx, 32 ; are all PCBs used
je exit ; yes, exit
mov cl, 5
shl bx, cl ; multiply by 32 for pcb start
mov ax, [si+0] ; read code segment parameter
mov [cs:pcb+bx+18], ax ; save in pcb space for cs
mov ax, [si+2] ; read offset parameter
mov [cs:pcb+bx+16], ax ; save in pcb space for ip
mov ax, [si+4] ; read data segment parameter
mov [cs:pcb+bx+20], ax ; save in pcb space for ds
mov ax, [si+6] ; read extra segment parameter
mov [cs:pcb+bx+24], ax ; save in pcb space for es
mov [cs:pcb+bx+22], cs ; set stack to our segment
mov di, [cs:nextpcb] ; read this pcb index
mov cl, 9
shl di, cl ; multiply by 512
add di, 256*2+stack ; end of stack for this thread
mov ax, [si+8] ; read parameter for subroutine
sub di, 2 ; decrement thread stack pointer
mov [cs:di], ax ; pushing param on thread stack
sub di, 4 ; space for far return address
mov [cs:pcb+bx+14], di ; save di in pcb space for sp
mov word [cs:pcb+bx+26], 0x0200 ; initialize flags
mov ax, [cs:pcb+28] ; read next of 0th thread in ax
mov [cs:pcb+bx+28], ax ; set as next of new thread
mov ax, [cs:nextpcb] ; read new thread index
mov [cs:pcb+28], ax ; set as next of 0th thread
inc word [cs:nextpcb] ; this pcb is now used
exit: pop di
pop cx
pop bx
pop ax
iret
start: xor ax, ax
mov es, ax ; point es to IVT base
mov word [es:0x80*4], initpcb
mov [es:0x80*4+2], cs ; hook software int 80
cli
mov word [es:0x08*4], timer
mov [es:0x08*4+2], cs ; hook timer interrupt
sti

start2:

xor ah, ah ; service 0 – get keystroke
int 0x16 ; bios keyboard services
mov [message],al



mov [paramblock+0], cs ; code segment parameter
mov word [paramblock+2], mytask3 ; offset parameter
mov [paramblock+4], ds ; data segment parameter
mov [paramblock+6], es ; extra segment parameter
mov word [paramblock+8], 0 ; parameter for thread
mov si, paramblock ; address of param block in si
int 0x80 ; multitasking kernel interrupt
jmp start2