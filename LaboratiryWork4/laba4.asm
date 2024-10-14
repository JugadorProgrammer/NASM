global _start

section .data
first_array dw 1, 2 , 3, 4, 5, 6, 7, 8, 9, 10
second_array dw  20, 20, 20, 20, 20, 20, 20, 20, 20, 20
result_array  dw 10 dup(0)

array_lenght: db 10
result_sign: db 0
array_number_position: db 7

message db "array -           ", 0xA
message_length: equ $-message      ; length of msg

section .text           ; code section
_start:                 ; enter point
    mov edx, 0
    movzx ecx, word [array_lenght]

    sub_loop:
        mov esi, first_array
        movzx eax, word [esi + edx * 2] ; first_array element

        mov esi, second_array
        movzx edi, word [esi + ecx * 2 - 2]

        sub edi, eax
        mov esi, result_array
        mov [esi + edx * 2], edi

        movzx eax, word [array_lenght]
        add edx, 1
    loop sub_loop

    mov r9d, first_array
    ;call print_all

    mov r9d, second_array
    ;call print_all

    mov r9d, result_array
    call print_all
    
    ; Завершение программы
    mov eax, 60 ; sys_exit
    mov edi, 0 ; код завершения 0
    syscall

print_all:
    ; movzx ecx, word [array_lenght]
    mov r8, 0
    mov rcx, 10

    print_loop:
        movzx rax, word [r9d + r8d * 2]
        call print

        mov dl, 0
        mov [result_sign], dl
        add r8d, 1
    loop print_loop
    ret

print:
    mov r10 ,rcx
    test rax, rax
    jns .output

    mov dl, 1
    mov [result_sign], dl
    neg rax

    .output:
        mov rsi, message
        add rsi, message_length - 2
        mov rbx, 10
        .next_digit:
            xor rdx, rdx       ; clear rdx prior to dividing rdx:rax by rbx
            div rbx            ; rax /= 10
            add dl, '0'        ; convert the remainder to ASCII 
            dec rsi            ; store characters in reverse order
            mov [rsi], dl
            test rax, rax
        jnz .next_digit    ; repeat until

        mov dl, 1
        cmp [result_sign], dl
        jnz .write

        dec rsi
        mov dl, '-' ; minus
        mov [rsi], dl
        
        .write:
            mov rdx, message_length      ; length of the string
            mov rsi, message         ; address of the string
            mov rdi, 1           ; file descriptor, in this case stdout
            mov rax, 1           ; syscall number for write
            syscall
    mov rcx, r10
    ret