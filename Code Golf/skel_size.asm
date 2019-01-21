; Craciunoiu Cezar 324CA
BITS 32
extern print_line
global mystery1:function
global mystery2:function
global mystery3:function
global mystery4:function
global mystery6:function
global mystery7:function
global mystery8:function
global mystery9:function

section .text

; Description: calculates the length of a given string
; @arg1: char* s - the string
; Return value: int
; Suggested name: strlen
mystery1:
    push ebp
    mov ebp, esp
    mov edi, [ebp + 8]
    xor eax, eax
    mov ecx, 100000
    repne scasb
    mov eax, edi
    sub eax, [ebp + 8]
    dec eax
    leave
    ret

; Description: checks if a character appears in a string
; @arg1: char* a - the string
; @arg2: char b - the character
; Return value: int
; Suggested name: strchr
mystery2:
    push ebp
    mov ebp, esp
    mov edx, [ebp + 0x8]
    push edx
    call mystery1
    add esp, 0x4
    mov ecx, eax
    xor eax, eax
    mov edi, [ebp + 0x8]
    mov al, byte [ebp + 0xc]
    repne scasb
    cmp ecx, 0x0
    jne mystery2_finish
    cmp byte [edi], 0
    je mystery2_finish
    mov eax, 0xffffffff
    leave
    ret
mystery2_finish:
    dec edi
    mov eax, edi
    sub eax, [ebp + 0x8]
    leave
    ret

; Description: checks if two strings are equal
; @arg1: char* a - the first string
; @arg2: char* b - the second string
; @arg3: int len - the number of characters to check for
; Return value: int
; Suggested name: strequal
mystery3:
    push ebp
    mov ebp, esp
    mov edi, [ebp + 0x8]
    mov esi, [ebp + 0xc]
    mov ecx, [ebp + 0x10]
    repe cmpsb
    xor eax, eax
    mov ch, byte [esi - 1]
    cmp byte [edi - 1], ch
    jne mystery3_fail
    xor ch, ch
    cmp ecx, 0x0
    je mystery3_finish

mystery3_fail:
    mov eax, 0x1
    
mystery3_finish:
    leave
    ret

; muta caracter cu caracter din ebx in eax?
; Description: copies content of a string to another one
; @arg1: char* a - the first string
; @arg2: char* b - the second string
; @arg3: int - copied string length
; Return value: void
; Suggested name: memcpy
mystery4:
    push ebp
    mov ebp, esp
    mov edi, [ebp + 0x8]
    mov esi, [ebp + 0xc]
    mov ecx, [ebp + 0x10]
    rep movsb
    leave
    ret
    
; Description: checks if a character is a figure
; @arg1: char a - the character
; Return value: int
; Suggested name: isNumber
mystery5:
    push ebp
    mov ebp, esp
    mov eax, [ebp + 8]
    sub al, 0x30
    cmp al, 0x9
    jg mystery5_fail
    mov eax, 0x1
    leave
    ret
mystery5_fail:
    xor eax, eax
    leave
    ret

; Description: reverses a string
; @arg1: char* a - the string
; Return value: void
; Suggested name: strReverse
mystery6:
    push ebp
    mov ebp, esp
    push dword [ebp + 8]
    call mystery1
    add esp, 4
    mov edi, [ebp + 8]
    mov esi, edi
    mov ecx, eax
    shr ecx, 1

mystery6_execution:
    dec eax
    mov dl, byte [edi]
    xchg dl, byte [esi + eax]
    mov byte [edi], dl
    inc edi
    dec ecx
    cmp ecx, 0
    jne mystery6_execution
    leave
    ret

; Description: Converts a string to a number
; @arg1: char* a - the string
; Return value: int
; Suggested name: strAtoi
mystery7:
    push ebp
    mov ebp, esp
    mov edi, [ebp + 8]
    xor eax, eax
    xor edx, edx
    xor ecx, ecx
    mov ebx, 10
mystery7_execution:
    push eax
    mov cl, byte [edi]
    push ecx
    call mystery5
    add esp, 4
    cmp eax, 0
    je mystery7_fail
    pop eax
    mul ebx
    sub cl, 0x30
    add eax, ecx
    inc edi
    cmp byte [edi], 0
    jne mystery7_execution
    jmp mystery7_finish
    
mystery7_fail:
    mov eax, 0xffffffff
    add esp, 4
    
mystery7_finish:
    leave
    ret

; Description: searches for a substring in a string
; @arg1: char* haystack - the first string, in which is searched
; @arg2: char* needle - the second string, that is searched for
; @arg3: int len - the length of the key/needle
; Return value: int
; Suggested name: strstr
mystery8:
    push ebp
    mov ebp, esp
    mov edi, [ebp + 8] ; haystack
    mov ecx, [ebp + 16]; needle strlen

mystery8_execution:
    mov esi, [ebp + 12]; needle
    mov al, byte [edi]
    cmp al, byte [esi]
    jne mystery8_continue
    push edi

mystery8_match:
    inc esi
    inc edi
    cmp byte [esi], 0
    je mystery8_success
    mov al, byte [edi]
    cmp al, 0xa
    je mystery8_failed
    cmp al, byte [esi]
    jne mystery8_continue_pop
    jmp mystery8_match

mystery8_success:
    mov eax, 1
    jmp mystery8_finish
    
mystery8_continue:
    inc edi
    cmp byte [edi], 0xa
    je mystery8_failed
    cmp byte [edi], 0
    jne mystery8_execution

mystery8_failed:
    xor eax, eax

mystery8_finish:
    leave
    ret

mystery8_continue_pop:
    pop edi
    jmp mystery8_continue

; Description: prints all strings separated by enter which are between
; are between start and stop and have the key in them
; @arg1: char* string - the string in which is searched
; @arg2: int start - the offset from which the search starts 
; @arg3: int stop - the position where the program stops
; @arg4: char* key - the key used by the mystery8 function 
; Return value: void
; Suggested name: strstr_bordered_print
mystery9:
    push ebp
    mov ebp, esp
    mov esi, [ebp + 20]; needle
    sub esp, 4
    push esi
    call mystery1
    add esp, 4
    mov edi, [ebp + 8] ; big haystack
    add edi, [ebp + 12]
    mov dword [ebp - 4], eax
    xor eax, eax

mystery9_execution:
    push dword [ebp - 4]
    push esi
    push edi
    call mystery8
    mov esi, [ebp + 20]
    cmp eax, 1
    jne mystery9_next_string_nopop
    pop edi
    cmp byte [edi], 0xa
    jne mystery9_print
    inc edi

mystery9_print:
    add esp, 8
    push edi
    mov al, 0xa
    mov ecx, 10000
    repne scasb
    mov edx, [ebp + 16]
    add edx, [ebp + 8]
    cmp edi, edx
    jg mystery9_finish
    call print_line
    add esp, 0x4
    jmp mystery9_execution
    
mystery9_next_string:
    inc edi
    mov edx, [ebp + 16]
    add edx, [ebp + 8]
    cmp edx, edi
    jle mystery9_finish
    cmp byte [edi], 0
    je mystery9_finish
    cmp byte [edi], 0xa
    jne mystery9_next_string
    inc edi
    mov edx, [ebp + 16]
    add edx, [ebp + 8]
    cmp edx, edi
    jle mystery9_finish
    cmp byte [edi], 0
    jne mystery9_execution
    
mystery9_finish:   
    leave
    ret

mystery9_next_string_nopop:
    add esp, 12
    dec edi
    jmp mystery9_next_string
