global _start           ; делаем метку метку _start видимой извне

section .data
a: dq -6
b: dq 4
c: dq 8
d: dq 2
x: dq -2
x_delta: dq 1
x_destination: dq 5
result_sign: db 0
message db "f(x)=     ", 0xA
message_legth: equ $-message      ; length of msg

section .text           ; code section
_start:                 ; enter point
    mov rax, [x]
    cmp rax, 0

    jl .y1 ; if x < 0
    jg .y3 ; if x > 0
    jmp .y2 ; if x == 0

    .y1:
        ;2·a·x+5 start
        mov rax, [a]
        mov rdi, 2
        imul rdi

        mov rdi, [x]
        imul rdi
        add rax, 5
        ;2·a·x+5 end

        jmp .print_result
    .y2:
        ;(a-b)/d start
        mov rax, [a]
        sub rax, [b]

        cqo ; для знакового деления
        mov rdi, [d]
        idiv rdi
        ;(a-b)/d end
        jmp .print_result
    .y3:
        ;(a^2-x)/(c+d) start
        mov rax, [a]
        imul rax, rax
        sub rax, [x]

        mov rdi, [c]
        add rdi, [d]

        cqo ;для знакового деления
        idiv rdi
        ;(a^2-x)/(c+d) end
    .print_result:
        ; start print
        test rax, rax
        mov cl, ' '
        jns .output

        ; mov dl, 1
        ; mov [result_sign], dl
        mov cl, '-'
        neg rax

        ;Поготовка к выводу
        .output:
        mov rsi, message
        add rsi, message_legth-1
        mov rbx, 10
        .next_digit:
            xor rdx, rdx       ; clear rdx prior to dividing rdx:rax by rbx
            div rbx            ; rax /= 10
            add dl, '0'        ; convert the remainder to ASCII 
            dec rsi            ; store characters in reverse order
            mov [rsi], dl
            test rax, rax
            jnz .next_digit    ; repeat until

        dec rsi
        mov [rsi], cl
        mov rdx, message_legth      ; length of the string
        mov rsi, message         ; address of the string
        mov rdi, 1           ; file descriptor, in this case stdout
        mov rax, 1           ; syscall number for write
        syscall
        ; end print

    mov rax, [x]
    mov rdi, [x_destination]
    cmp rax, rdi
    jz .exit ; if x == x_destination

    ; x+=delta_x start
    mov rax, [x_delta]
    add rax, [x]
    mov [x], rax
    ; x+=delta_x end

    jmp _start
    .exit:
        ; Завершение программы
        mov rdi, 0 ; код завершения 0
        mov rax, 60 ; sys_exit
        syscall
