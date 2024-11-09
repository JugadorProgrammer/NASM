global _start

; С клавиатуры вводится целое число любой разрядности.
; Определить количество цифр в нем и их сумму. 
; Вывести на экран число, количество цифр и сумму
section .data
  length: dq 0

  ascii db 255 dup(0)
  ascii_length equ $-ascii

  message db "Char:         Count: ", 0
  message_len: equ $-message
  char_position: equ 5

  digit db " ", 0
  void_row db "", 0xA
  len: equ $-void_row

section .bss
  buffer resb 1      ; Резервируем 1 байт для строки

section .text
_start:
  mov rax, 0        ; sys_read
  mov rdi, 0        ; файл stdin
  mov rsi, buffer ; указатель на буфер, где сохраняем символ
  mov rdx, 4096        ; считываем 4096 байт - максимальное кол-во символов
  syscall

  mov rsi, buffer     ; указываем на начало буфера
  xor rdi, rdi        ; обнуляем счетчик длины
  mov rcx, ascii

  .count_length:
    ;TODO: 64 бита много, бери 8
    mov rdx, [rsi + rdi]
    cmp rdx, 0xA ; проверяем, не конец ли строки (символ 'n')
    je .done_counting         ; если да, выходим из цикла
    
    movzx rax, byte dl

    add rcx, rax
    mov rbx, 1
    add [rcx], rbx
    sub rcx, rax

    ;Идя в том, чтобы записывать каждый элемент массива с индексом  и переводить этот индекс в аски
    inc rdi                   ; увеличиваем счетчик
    jmp .count_length          ; продолжаем считать

.done_counting:
  mov r10, 0
  mov [length], rdi

  .cycle:
    mov rsi, message
    add rsi, char_position
    mov [rsi], r10
  
    mov rsi, message
    mov rdx, message_len
    call print_rsi

    mov rcx, ascii
    movsx rax, byte [rcx + r10]
    call print

    mov rsi, void_row
    mov rdx, len
    call print_rsi

    inc r10
    cmp r10, 255
  jne .cycle

  mov rax, 60 ; sys_exit
  mov rdi, 0  ; код завершения 0
  syscall

print:
  mov r9, 0
  mov rbx, 10
      
  .next_digit:
      xor rdx, rdx       ; clear rdx prior to dividing edx:eax by ebx
      div rbx            ; rax /= 10
      add dl, 48        ; convert the remainder to ASCII 

      xor r8, r8
      movsx r8, byte dl
      push r8

      add r9, 1
      cmp rax, 0
    jne .next_digit    ; repeat until    

    mov rsi, digit
    .write:
      xor rdx, rdx
      pop rdx

      mov [rsi], dl
      mov rdx, 1      ; length of the string
      call print_rsi

      dec r9
      test r9, r9
    jnz .write
  ret

print_rsi:
  mov rdi, 1           ; file descriptor, in this case stdout
  mov rax, 1           ; syscall number for write
  syscall
  ret