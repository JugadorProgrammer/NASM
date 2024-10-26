global _start

section .data
first_array dw 40, 39, 38, 37, 36, 5, 34, 32, 31, 30
second_array dw  20, 20, 20, 20, 20, 20, 20, 20, 20, 20
result_array  dw 10 dup(0)

array_lenght: db 10
result_sign: db 0

message1 db "first  -            ;", 0xA
message_length: equ $-message1      ; length of msg
free_space_in_message: equ 10

message2 db "second -            ;", 0xA
message3 db "result -            ;", 0xA

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

    mov r9d, first_array
    mov esi, message1
    call print_all

    call print_void_row
    mov r9d, second_array
    mov rsi, message2
    call print_all

    call print_void_row
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
        call print
        mov ecx, r10d ; restore ecx

        mov dl, 0
        mov [result_sign], dl
        inc r8d

    loop print_loop
    ret

print:
    test eax, eax
    jns .output

    mov dl, 1
    mov [result_sign], dl
    neg eax

    .output:
        mov r11d, message_length - 2
        add esi, message_length - 2

        mov ebx, 10
        .next_digit:
            xor edx, edx       ; clear rdx prior to dividing edx:eax by ebx
            div ebx            ; eax /= 10
            add dl, '0'        ; convert the remainder to ASCII 
            dec esi            ; store characters in reverse order
            mov [esi], dl
            dec r11d
            test eax, eax
        jnz .next_digit    ; repeat until

        mov dl, 1
        cmp [result_sign], dl
        jnz .write

        dec esi
        dec r11d
        mov dl, '-' ; minus
        mov [esi], dl
        
        .write:
            mov edx, message_length      ; length of the string
            sub esi, r11d         ; restore address of the string
            mov edi, 1           ; file descriptor, in this case stdout
            mov eax, 1           ; syscall number for write
            syscall
        ;call clearr11d_message
    ret

clear_message:
    mov ecx, free_space_in_message
    add esi, message_length - 2 
    xor edx, edx
    mov dl, ' '
    clear_loop:
        mov [esi], dl
        dec esi
        loop clear_loop
    ret

print_void_row:
    mov edx, 1      ; length of the string
    mov esi, void_row
    mov edi, 1           ; file descriptor, in this case stdout
    mov eax, 1           ; syscall number for write
    syscall
    ret