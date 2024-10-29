global _start

section .data
first_array dw -40, -39, -38, -37, -36, -35, -34, -32, -31, 30
second_array dw  20, 21, 22 ,23, 24, 25, 26, 27, 28, 29
result_array  dw 10 dup(0)

array_lenght: db 10
result_sign: db 0

msg db " ",  0
space db " ",  0

message1 db "first  array: ", 0
message_length: equ $-message1      ; length of msg

message2 db "second array: ", 0
message3 db "result array: ", 0
void_row db "", 0xA

section .text           ; code section
_start:                 ; enter point
    mov edx, 0
    mov r8b, [array_lenght] ; save length
    movsx ecx, byte r8b

    sub_loop:
        mov esi, first_array
        movsx eax, word [esi + edx * 2] ; first_array element

        mov esi, second_array
        movsx edi, word [esi + ecx * 2 - 2]

        sub edi, eax
        mov esi, result_array
        mov [esi + edx * 2], edi

        movsx eax, byte [array_lenght]
        add edx, 1
    loop sub_loop

    mov [array_lenght], r8b ; restore length

    mov esi, message1
    mov edx, message_length
    call print_

    mov r9d, first_array
    mov esi, message1
    call print_all

    mov esi, message2
    mov edx, message_length
    call print_

    mov r9d, second_array
    mov rsi, message2
    call print_all

    mov esi, message3
    mov edx, message_length
    call print_

    mov r9d, result_array
    mov rsi, message3
    call print_all
    
    ; Завершение программы
    mov eax, 60 ; sys_exit
    mov edi, 0 ; код завершения 0
    syscall

print_all:
    mov r8d, 0
    movzx ecx, byte [array_lenght]

    print_loop:
        movsx eax, word [r9d + r8d * 2]
        
        mov r10d ,ecx ; save ecx

        call print_element
        mov ecx, r10d ; restore ecx

        mov dl, 0
        mov [result_sign], dl
        inc r8d
    loop print_loop

    call print_void_row
    ret

print_element:
    test eax, eax
    jns .output

    mov dl, 1
    mov [result_sign], dl
    neg eax

    .output:
        mov ecx, 0 
        mov ebx, 10
        .next_digit:
            xor edx, edx       ; clear rdx prior to dividing edx:eax by ebx
            div ebx            ; eax /= 10
            add dl, '0'        ; convert the remainder to ASCII 
            movsx r12, byte dl
            push r12
            
            inc ecx
            test eax, eax
        jnz .next_digit    ; repeat until

        mov dl, 1
        cmp [result_sign], dl
        jnz .write

        mov dl, '-' ; minus
        movsx r12, byte dl
        push r12
        inc ecx
        
        .write:
            mov esi, msg
            pop rdx
            mov [esi], dl
            mov ebx, ecx; save

            mov edx, 2      ; length of the string
            mov esi, msg
            mov edi, 1           ; file descriptor, in this case stdout
            mov eax, 1           ; syscall number for write
            syscall

            mov ecx, ebx;restore
        loop .write

        ; принт space
        mov edx, 2      ; length of the string
        mov esi, space
        call print_
    ret

print_void_row:
    mov edx, 1     ; length of the string
    mov esi, void_row
    call print_
    ret

print_:
    mov edi, 1           ; file descriptor, in this case stdout
    mov eax, 1           ; syscall number for write
    syscall
    ret