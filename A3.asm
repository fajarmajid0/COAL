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
    mov ax, 0B800h
    mov es, ax
    xor di, di
    mov ax, 0720h
    mov cx, 2000
    cld
    rep stosw

   ;parameters: source, row, column, attribute.

    push word 07h
    push word 4
    push word 1
    push word instruction1
    call write_line

    push word 07h
    push word 4
    push word 2
    push word instruction2
    call write_line

    ; draw window: top, left, bottom, right.
    push word 72
    push word 21
    push word 8
    push word 3
    call draw_frame

    ; printing title
    push word 1Eh
    push word 30
    push word 4
    push word titleText
    call write_line

    ; print document lines
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

    ; parameters: top, left, bottom, right, rows.
    push word 1
    push word 72
    push word 21
    push word 8
    push word 3
    call scroll_window_up

    push word 4Fh
    push word 4
    push word keyword
    call find_and_highlight

    mov [matchCount], ax
	
	mov ax, 4C00h
    int 21h

; write_line parameters
; [bp+4]  = string address
; [bp+6]  = row
; [bp+8]  = column
; [bp+10] = attribute
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

    mov bx, [bp+8]
    shl bx, 1
    add ax, bx

    mov di, ax
    mov si, [bp+4]

    mov ah, [bp+10]

write_loop:

    lodsb
    cmp al, 0
    je write_done

    stosw
    jmp write_loop

write_done:

    pop es
    pop di
    pop si
    pop bx
    pop ax

    mov sp, bp
    pop bp
    ret 8

; put_cell parameters:
; [bp+4]  = row
; [bp+6]  = column
; [bp+8]  = character
; [bp+10] = attribute
put_cell:

    push bp
    mov bp, sp

    push ax
    push bx
    push di
    push es

    mov ax, 0B800h
    mov es, ax

    mov ax, [bp+4]
    mov bx, 160
    mul bx

    mov bx, [bp+6]
    shl bx, 1
    add ax, bx

    mov di, ax

    mov al, [bp+8]
    mov ah, [bp+10]
    stosw

    pop es
    pop di
    pop bx
    pop ax

    mov sp, bp
    pop bp
    ret 8

; draw frame parameters:
; [bp+4]  = top
; [bp+6]  = left
; [bp+8]  = bottom
; [bp+10] = right
draw_frame:

    push bp
    mov bp, sp

    push ax
    push bx

    ; Top-left corner.

    push word 07h
    push word 201
    push word [bp+6]
    push word [bp+4]
    call put_cell

    ; Top-right corner.

    push word 07h
    push word 187
    push word [bp+10]
    push word [bp+4]
    call put_cell

    ; Bottom-left corner.

    push word 07h
    push word 200
    push word [bp+6]
    push word [bp+8]
    call put_cell

    push word 07h
    push word 188
    push word [bp+10]
    push word [bp+8]
    call put_cell
	
    mov bx, [bp+6]
    inc bx

horizontal_loop:

    cmp bx, [bp+10]
    jae horizontal_done

    push word 07h
    push word 205
    push bx
    push word [bp+4]
    call put_cell

    push word 07h
    push word 205
    push bx
    push word [bp+8]
    call put_cell

    inc bx
    jmp horizontal_loop

horizontal_done:
    mov bx, [bp+4]
    inc bx

vertical_loop:
    cmp bx, [bp+8]
    jae vertical_done

    push word 07h
    push word 186
    push word [bp+6]
    push bx
    call put_cell

    push word 07h
    push word 186
    push word [bp+10]
    push bx
    call put_cell

    inc bx
    jmp vertical_loop

vertical_done:

    pop bx
    pop ax

    mov sp, bp
    pop bp
    ret 8

scroll_window_up:

    push bp
    mov bp, sp
    sub sp, 8

; local variables:
; [bp-2] = rows to copy
; [bp-4] = rows to clear
; [bp-6] = interior width
; [bp-8] = row gap in bytes

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

    mov ax, [bp+12]
    mov [bp-4], ax

    ; Interior width.

    mov ax, [bp+10]
    sub ax, [bp+6]
    sub ax, 3
    mov [bp-6], ax

    ; Row gap = 160 - width * 2.

    mov bx, ax
    shl bx, 1
    mov ax, 160
    sub ax, bx
    mov [bp-8], ax

    ; Number of rows to copy.

    mov ax, [bp+8]
    sub ax, [bp+4]
    sub ax, 2
    sub ax, [bp+12]
    mov [bp-2], ax

    ; Destination: row top+2, column left+2.

    mov ax, [bp+4]
    add ax, 2
    mov bx, 160
    mul bx

    mov bx, [bp+6]
    add bx, 2
    shl bx, 1
    add ax, bx
    mov di, ax

    ; Source: destination row plus N.

    mov ax, [bp+4]
    add ax, 2
    add ax, [bp+12]
    mov bx, 160
    mul bx

    mov bx, [bp+6]
    add bx, 2
    shl bx, 1
    add ax, bx
    mov si, ax

    ; Copy the interior rows.

    mov dx, [bp-2]

scroll_copy_loop:

    cmp dx, 0
    je scroll_clear_start

    mov cx, [bp-6]
    rep movsw

    add si, [bp-8]
    add di, [bp-8]

    dec dx
    jmp scroll_copy_loop

scroll_clear_start:

    ; Clear the last N rows of the interior.

    mov ax, [bp+8]
    sub ax, [bp+12]
    mov bx, 160
    mul bx

    mov bx, [bp+6]
    add bx, 2
    shl bx, 1
    add ax, bx
    mov di, ax

    mov ax, 0720h
    mov dx, [bp-4]

scroll_clear_loop:

    cmp dx, 0
    je scroll_done

    mov cx, [bp-6]
    rep stosw

    add di, [bp-8]

    dec dx
    jmp scroll_clear_loop

scroll_done:

    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax

    mov sp, bp
    pop bp
    ret 10


; searches rows 5-20 and columns 10-70 and returns match count in AX.
find_and_highlight:

    push bp
    mov bp, sp
    sub sp, 8

; local variables:
; [bp-2] = current row
; [bp-4] = current column
; [bp-6] = match count
; [bp-8] = screen offset

    push bx
    push cx
    push dx
    push si
    push di
    push es

    mov ax, 0B800h
    mov es, ax
    cld

    mov word [bp-6], 0
    mov word [bp-2], 5

search_row_loop:

    cmp word [bp-2], 20
    ja search_done

    mov word [bp-4], 10

search_column_loop:

    ; Column 67 is the last starting column for
    ; a four-character keyword ending by column 70.

    cmp word [bp-4], 67
    ja search_next_row

    ; Calculate screen offset = row*160 + column*2.

    mov ax, [bp-2]
    mov bx, 160
    mul bx

    mov bx, [bp-4]
    shl bx, 1
    add ax, bx

    mov [bp-8], ax

    mov si, [bp+4]
    mov di, [bp-8]
    mov cx, [bp+6]

search_compare_loop:

    mov al, [si]
    cmp al, [es:di]
    jne search_no_match

    inc si
    add di, 2

    loop search_compare_loop

    inc word [bp-6]

    ; highlighting attribute bytes only
    mov di, [bp-8]
    inc di
    mov cx, [bp+6]

highlight_loop:

    mov al, [bp+8]
    mov [es:di], al

    add di, 2
    loop highlight_loop

search_no_match:

    inc word [bp-4]
    jmp search_column_loop

search_next_row:

    inc word [bp-2]
    jmp search_row_loop

search_done:

    mov ax, [bp-6]

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx

    mov sp, bp
    pop bp
    ret 6

