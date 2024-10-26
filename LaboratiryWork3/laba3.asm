global _start ; _start

section .data
a: dw 29 ;11101
b: dw 18 ;10010
c: dw 31 ;11111
d: dw -14 ;-1110

; (!b + c * a) + d
result db '00000000000000000', 0xA  ; Место для хранения битов (64 бита)
result_legth: equ $-result         ; length of msg

section .text           ; code section
_start:                 ; enter point
    ; c * a start
    mov ax, [c]
    mov di, [a]
    and ax, di
    ; c * a end

    ; call print_bits

    ; (!b + c * a) start
    mov di, [b]
    not di
    or ax, di
    ; (!b + c * a) end

    ; call print_bits

    ; (!b + c * a) + d start
    mov di, [d]
    or ax, di
    ; (!b + c * a) + d end
    
    call print_bits

    ; Завершение программы
    mov ax, 60 ; sys_exit
    mov di, 0 ; код завершения 0
    syscall

print_bits:
    mov cx, 17
    mov esi, result

    .shift:
        shl ax, 1
        jc .set_one
        
        mov dl, '0'
        mov [esi], dl
        jmp .continue

        .set_one:
            mov dl, '1'
            mov [esi], dl

        .continue:
            inc esi
    loop .shift

    mov edx, result_legth ; length of the string
    mov esi, result       ; address of the string
    mov edi, 1            ; file descriptor, in this case stdout
    mov eax, 1            ; syscall number for write
    syscall

    ret