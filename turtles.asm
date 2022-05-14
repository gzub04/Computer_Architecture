section .data

BYTES_PER_ROW equ 1800
HEADER_SIZE equ 122

%define two_main_bytes [ebp-4]
%define up_down [ebp-8]
%define direction [ebp-12]
%define x_coordinate [ebp-16]
%define y_coordinate [ebp-20]
%define colour [ebp-24]
%define iterator [ebp-28]
%define commands_pointer [ebp-32]
%define BMP_file_address [ebp-36]

section .text

global turtle

turtle:
    ; prologue
    push ebp;
    mov ebp, esp
    ;sub esp, 28

    push ebx
    push edi
    push esi

    mov eax, [ebp+8]
    mov BMP_file_address, eax   ; mov address of the BMP file into BMP_file_address

    mov ecx, [ebp + 16]         ; create iterator
    shr ecx, 1
    mov iterator, ecx
    
    mov ebx, [ebp + 12]
    mov commands_pointer, ebx   ; move adress of commands to ebx

loop:
    ; check if the function has finished
    mov ecx, iterator
    cmp ecx, 0
    je finish

    ; take 2-byte and move forwards (I refer to the two main bytes that conatain command as "2-byte")
    XOR eax, eax                ; clear eax so we can put 2-bytes there
    mov ebx, commands_pointer
    mov ah, BYTE [ebx]          ; move first byte containing command to two_main_bytes
    inc ebx                     ; increment pointer
    mov al, BYTE [ebx]          ; move second byte
    mov two_main_bytes, eax
    inc ebx                      ; increment pointer to the next 2-byte
    mov commands_pointer, ebx

    and eax, 3                  ; extract from eax type of command (set pos / set dir / move / set pen state)

    dec ecx                  ; iterator--
    mov iterator, ecx

    ; select command
    cmp eax, 0              ; set pen state
    je instr00
    cmp eax, 1              ; move turtle
    je instr01
    cmp eax, 2              ; set direction
    je instr10
    cmp eax, 3              ; set position
    je instr11

instr00:    ; set pen state
    ; R
    mov edi, two_main_bytes
    and edi, 0xf000         ; 0xf000 because we want bits no. 15-12
    shl edi, 8              ; all shifts in this function exist to paint pixels more easily
    mov esi, edi            ; move it to the esi which will contain colours at the end of the function
     ; -esi stores all colours

    ; G
    mov edi, two_main_bytes
    and edi, 0xf00
    shl edi, 4
    add esi, edi            ; we add the result to esi


    ; B
    mov edi, two_main_bytes
    and edi, 0xf0
    add esi, edi            ; we add results to esi

    mov colour, esi         ; put all the colours from esi into memory

    
    ; up/down
    mov esi, two_main_bytes
    and esi, 0x8
    shr esi, 3
    mov up_down, esi

    jmp loop

instr01:    ; move turtle

    ; edi - distance
    mov edi, two_main_bytes
    shr edi, 6             ; shift distance value to the least significant bits
    
    ; choosing where the turtle goes
    mov eax, direction

    cmp eax, 0
    je right

    cmp eax, 1
    je up

    cmp eax, 2
    je left

    cmp eax, 3
    je down

right:
    ; edge case
    mov esi, x_coordinate
    cmp esi, 599
    je loop

    ; limit
    add esi, edi        ; esi = x + distance

    cmp esi, 599
    jle go_right
    mov esi, 599        ; happens only if x is too high

go_right:
    mov ebx, esi        ; both have new x
    mov eax, up_down
    cmp eax, 0
    je skip_right       ; to skip painting

paint_right:
    mov esi, x_coordinate           ; esi = x
    inc esi
    mov x_coordinate, esi           ; x+=1

    ; put_pixel
    mov edi, y_coordinate           ; edi = x
    imul edi, BYTES_PER_ROW
    imul esi, 3
    add esi, edi                ; edi - pixel offset
    mov edi, BMP_file_address   ; bmp adress
    add edi, HEADER_SIZE
    add esi, edi                ; esi - pixel address

    ; set new colour
    ; puts lowest byte of edx into appropriate place where esi points, then shifts edx
    mov edx, colour
    mov BYTE [esi], dl      ; B
    shr edx, 8
    mov BYTE [esi + 1], dl  ; G
    shr edx, 8
    mov BYTE [esi + 2], dl  ; R

    mov esi, x_coordinate
    cmp esi, ebx
    jl paint_right          ; check if we still have to paint

skip_right:
    mov x_coordinate, ebx
    jmp loop

up:
    ; edge case
    mov esi, y_coordinate
    cmp esi, 49
    je loop

    ; limit
    add esi, edi        ; esi = y + distance

    cmp esi, 49
    jle go_up
    mov esi, 49         ; happens only if y is too high

go_up:
    mov ebx, esi        ; has new y 
    mov eax, up_down
    cmp eax, 0
    je skip_up       ; to skip painting

paint_up:
    mov esi, y_coordinate           ; esi = y
    inc esi
    mov y_coordinate, esi           ; y+=1

    ; put_pixel
    mov edi, x_coordinate          ; edi = x
    imul esi, BYTES_PER_ROW
    imul edi, 3
    add esi, edi        ; esi - pixel offset
    mov edi, BMP_file_address  ; bmp adress
    add edi, HEADER_SIZE
    add esi, edi        ; esi - pixel address

    ; set new colour
    ; puts lowest byte of edx into appropriate place where esi points, then shifts edx
    mov edx, colour
    mov BYTE [esi], dl      ; B
    shr edx, 8
    mov BYTE [esi + 1], dl  ; G
    shr edx, 8
    mov BYTE [esi + 2], dl  ; R

    mov esi, y_coordinate
    cmp esi, ebx
    jl paint_up             ; check if we still have to paint

skip_up:
    mov y_coordinate, ebx

    jmp loop

left:
    ; edge case
    mov esi, x_coordinate
    cmp esi, 0
    je loop

    ; limit
    sub esi, edi        ; esi = x - distance

    cmp esi, 0
    jge go_left
    mov esi, 0          ; happens only if x is too high

go_left:
    mov ebx, esi        ; has new x 
    mov eax, up_down
    cmp eax, 0
    je skip_left       ; to skip painting

paint_left:
    mov esi, x_coordinate           ; esi = x
    dec esi
    mov x_coordinate, esi           ; x-=1

    ; put_pixel
    mov edi, y_coordinate           ; edi = x
    imul edi, BYTES_PER_ROW
    imul esi, 3
    add esi, edi        ; esi - pixel offset
    mov edi, BMP_file_address  ; bmp adress
    add edi, HEADER_SIZE
    add esi, edi        ; esi - pixel address

    ; set new colour
    ; puts lowest byte of edx into appropriate place where esi points, then shifts edx
    mov edx, colour
    mov BYTE [esi], dl      ; B
    shr edx, 8
    mov BYTE [esi + 1], dl  ; G
    shr edx, 8
    mov BYTE [esi + 2], dl  ; R

    mov esi, x_coordinate
    cmp esi, ebx
    jg paint_left           ; check if we still have to paint

skip_left:
    mov x_coordinate, ebx
    jmp loop

down:
    ; edge case
    mov esi, y_coordinate
    cmp esi, 0
    je loop

    ; limit
    sub esi, edi        ; esi = y + distance

    cmp esi, 0
    jge go_down
    mov esi, 0          ; happens only if y is too high

go_down:
    mov ebx, esi        ; has new y 
    mov eax, up_down
    cmp eax, 0
    je skip_down       ; to skip painting

paint_down:
    mov esi, y_coordinate           ; esi = y
    dec esi
    mov y_coordinate, esi           ; esi-=y

    ; put_pixel
    mov edi, x_coordinate          ; edi = x
    imul esi, BYTES_PER_ROW
    imul edi, 3
    add esi, edi        ; esi - pixel offset
    mov edi, BMP_file_address  ; bmp adress
    add edi, HEADER_SIZE
    add esi, edi        ; esi - pixel address

    ; set new colour
    ; puts lowest byte of edx into appropriate place where esi points, then shifts edx
    mov edx, colour
    mov BYTE [esi], dl      ; B
    shr edx, 8
    mov BYTE [esi + 1], dl  ; G
    shr edx, 8
    mov BYTE [esi + 2], dl  ; R

    mov esi, y_coordinate
    cmp esi, ebx
    jg paint_down           ; check if we still have to paint

skip_down:
    mov y_coordinate, ebx

    jmp loop


instr10:    ; set direction
    mov eax, two_main_bytes
    shr eax, 14
    mov direction, eax

    jmp loop

instr11:    ; set position
    ; y
    mov eax, two_main_bytes
    and eax, 0xfc
    shr eax, 2
    mov y_coordinate, eax

    ; error: wrong y - ret 2
    cmp eax, 49
    jg error_y_instr11

    ; move to next 2-byte
    XOR eax, eax
    mov ebx, commands_pointer
    mov ah, BYTE [ebx]  ; move 2-byte containing command to two_main_bytes
    inc ebx
    mov al, BYTE [ebx]
    mov two_main_bytes, eax
    inc ebx                      ; shift pointer to the next 2-byte
    mov commands_pointer, ebx

    mov ecx, iterator       ;
    dec ecx                 ; iterator--
    mov iterator, ecx       ;

    ; x
    and eax, 0x03ff
    mov x_coordinate, eax

    ; error: wrong x - ret 1
    cmp eax, 599
    jg error_x_instr11

    jmp loop


error_x_instr11:
    mov eax, 1
    jmp finish_error

error_y_instr11:
    mov eax, 2
    jmp finish_error

finish:
    mov eax, 0

finish_error
    ; epilogue
        pop esi
        pop edi
        pop ebx

        pop ebp
        ret
