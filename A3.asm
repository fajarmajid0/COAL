org 100h

jmp start

titleText db 'Text Viewport Manager', 0

instruction1 db 'Text Viewport Manager with Windowed Scrolling', 0
instruction2 db '8088 will be highlighted in the text', 0

line1 db 'I am learning about the 8088 processor.', 0
line2 db 'Assembly language is a little difficult.', 0
line3 db 'This window makes it easier to read the text.', 0
line4 db 'I can move the text up without moving the border.', 0
line5 db '8088 helps us understand how computers work.', 0
line6 db 'It is fun to see my code working on the screen.', 0

statusText db 'Total Matches Found: ', 0
statusSuffix db ' | Viewport Status: ACTIVE', 0

keyword db '8088', 0

matchCount dw 0

start:
    push cs
    pop ds

    mov ax, 0B800h
    mov es, ax

    xor di, di
    mov ax, 0720h
    mov cx, 2000
    cld
    rep stosw

    mov ax, 0B800h
    mov es, ax

    push word 07h
    push word 8
    push word 0
    push word instruction1
    call write_line

    push word 07h
    push word 8
    push word 1
    push word instruction2
    call write_line

    mov ax, 4C00h
    int 21h
	
; parameters:
; [bp+4] = string address
; [bp+6] = row
; [bp+8] = column
; [bp+10] = attribute
write_line:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push si
    push di
    push es

    mov ax, 0B800h
    mov es, ax

    mov ax, [bp+6]
    mov bx, 160
    mul bx
    mov di, ax

    mov ax, [bp+8]
    shl ax, 1
    add di, ax

    mov si, [bp+4]
    mov ah, [bp+10]

print_next:
    lodsb
    cmp al, 0
    je print_done

    stosw
    jmp print_next

print_done:
    pop es
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    pop bp
    ret 8
