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

statusText db 'Total matches found: ', 0
statusSuffix db ' | Viewport Status: ACTIVE', 0

keyword db '8088', 0

matchCount dw 0

start:
    push cs
    pop ds
    cld

    mov ax, 0B800h
    mov es, ax
    xor di, di
    mov ax, 0720h
    mov cx, 2000
    rep stosw

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

    call draw_frame

    push word 1Eh
    push word 33
    push word 3
    push word titleText
    call write_line

    push word 07h
    push word 10
    push word 6
    push word line1
    call write_line

    push word 07h
    push word 10
    push word 8
    push word line2
    call write_line

    push word 07h
    push word 10
    push word 10
    push word line3
    call write_line

    push word 07h
    push word 10
    push word 12
    push word line4
    call write_line

    push word 07h
    push word 10
    push word 14
    push word line5
    call write_line

    push word 07h
    push word 10
    push word 16
    push word line6
    call write_line

    ; scroll interior upward by one row.
    push word 1
    push word 72
    push word 21
    push word 8
    push word 3
    call scroll_window_up

    mov ax, 4C00h
    int 21h

; parameters: string, row, column, attribute
write_line:
    push bp
    mov bp, sp
    push ax
    push bx
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

write_next:
    lodsb
    cmp al, 0
    je write_done
    stosw
    jmp write_next

write_done:
    pop es
    pop di
    pop si
    pop bx
    pop ax
    pop bp
    ret 8

; frame : top=3, left=8, bottom=21, right=72.
draw_frame:
    push ax
    push bx
    push cx
    push dx
    push di
    push es

    mov ax, 0B800h
    mov es, ax

    mov di, 3*160+8*2
    mov ax, 1EC9h
    stosw

    mov cx, 63
    mov ax, 1ECDh
top_loop:
    stosw
    loop top_loop

    mov ax, 1EBBh
    stosw

    mov bx, 4
side_loop:
    cmp bx, 21
    jae bottom_line

    mov ax, bx
    mov dx, 160
    mul dx
    mov di, ax

    add di, 16
    mov ax, 1EBAh
    stosw

    add di, 126
    mov ax, 1EBAh
    stosw

    inc bx
    jmp side_loop

bottom_line:
    mov di, 21*160+8*2
    mov ax, 1EC8h
    stosw

    mov cx, 63
    mov ax, 1ECDh
bottom_loop:
    stosw
    loop bottom_loop

    mov ax, 1EBCh
    stosw

    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; stack parameters: top, left, bottom, right, rows
; push order at caller: rows, right, bottom, left, top.
scroll_window_up:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es

    mov ax, 0B800h
    mov ds, ax
    mov es, ax
    cld

    mov ax, [bp+4]
    add ax, 2
    mov bx, 160
    mul bx
    mov di, ax

    mov ax, [bp+6]
    add ax, 2
    shl ax, 1
    add di, ax
    mov si, di

    mov ax, [bp+12]
    mov bx, 160
    mul bx
    add si, ax

    mov ax, [bp+8]
    sub ax, [bp+4]
    sub ax, 2
    sub ax, [bp+12]
    mov dx, ax

    mov ax, [bp+10]
    sub ax, [bp+6]
    sub ax, 3
    mov bx, ax

scroll_rows:
    cmp dx, 0
    je clear_rows

    mov cx, bx
    rep movsw

    add si, 160
    sub si, bx
    sub si, bx

    add di, 160
    sub di, bx
    sub di, bx

    dec dx
    jmp scroll_rows

clear_rows:
    mov ax, [bp+8]
    sub ax, [bp+12]
    mov dx, ax

clear_row_loop:
    cmp dx, [bp+8]
    jae scroll_done

    mov ax, dx
    mov bx, 160
    mul bx
    mov di, ax

    mov ax, [bp+6]
    add ax, 2
    shl ax, 1
    add di, ax

    mov cx, bx
    mov cx, [bp+10]
    sub cx, [bp+6]
    sub cx, 3

    mov ax, 0720h
    rep stosw

    inc dx
    jmp clear_row_loop

scroll_done:
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 10

