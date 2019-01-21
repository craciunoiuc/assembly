; Craciunoiu Cezar 324CA

extern puts
extern printf
extern strlen

%define BAD_ARG_EXIT_CODE -1

section .data
filename: db "./input0.dat", 0
inputlen: dd 2263

fmtstr:            db "Key: %d",0xa, 0
usage:             db "Usage: %s <task-no> (task-no can be 1,2,3,4,5,6)", 10, 0
error_no_file:     db "Error: No input file %s", 10, 0
error_cannot_read: db "Error: Cannot read input file %s", 10, 0

section .text
global main

bruteforce_strstr: ; intoarce 1 sau 0 in eax daca s-a gasit "force"
        push ebp
        mov ebp, esp
        mov edi, [ebp + 8]
bruteforce_strstr_search:
        cmp byte [edi], 'f'
        jne bruteforce_strstr_continue
        cmp byte [edi + 1], 'o'
        jne bruteforce_strstr_continue
        cmp byte [edi + 2], 'r'
        jne bruteforce_strstr_continue
        cmp byte [edi + 3], 'c'
        jne bruteforce_strstr_continue
        cmp byte [edi + 4], 'e'
        jne bruteforce_strstr_continue ; se cauta caracterele "force" unele
        mov eax, 1                     ; dupa altele, daca s-au gasit eax devine 1
        pop ebp
        ret
bruteforce_strstr_continue:        
        inc edi
        cmp byte [edi + 4], 0
        jne bruteforce_strstr_search        
        mov eax, 0 ; daca s-a ajuns la null si nu s-a gasit eax devine 0
        pop ebp
        ret

base32_to_value: ; daca e litera scade din aceasta valoarea ascii a lui 'A'
        push ebp ; daca e numar, scade '2' si aduna 26
        mov ebp, esp
        mov eax, [ebp + 8]
        sub eax, '='
        jz base32_to_value_exit ; daca este '=' se pune 0 in eax
        mov eax, [ebp + 8]
        cmp eax, 'A'
        jl base32_to_value_number
        sub eax, 'A'
        jmp base32_to_value_exit
base32_to_value_number:
        sub eax, '2'
        add eax, 26
base32_to_value_exit: ; rezultatul este pus in eax
        pop ebp
        ret

hex_to_int:      ; primeste un numar si il trece din hexazecimal ascii
        push ebp ; in valoarea sa numerica
        mov ebp, esp
        mov eax, [ebp + 8]
        cmp eax, 'a'
        jge hex_to_int_letter
        sub eax, '0' ; daca e cifra se scade '0'
        jmp hex_to_int_exit
hex_to_int_letter:
        sub eax, 'a' ; daca e litera se scade 'a' si se aduna 10 pentru
        add eax, 10  ; a se forma valoarea corespunzatoare
hex_to_int_exit:
        pop ebp
        ret    

xor_strings:
        push ebp
        mov ebp, esp
        mov eax, [ebp + 8]  ; valoare
        mov edi, [ebp + 12] ; cheie
xor_strings_iteration:
        mov cl, byte [edi] ; se parcurge cheia si stringul in acelasi
        xor [eax], cl      ; timp se face xor caracter cu caracter pentru
        inc edi            ; a se restaura stringul 
        inc eax
        cmp byte [eax], 0  ; itereaza pana la null
        jne xor_strings_iteration
        pop ebp
	ret

rolling_xor:
        push ebp
        mov ebp, esp
        mov edi, [ebp + 8] ; stringul
        mov al, 0   ; valoarea de oprire
        repne scasb ; se muta pointerl stringului la finalul sirului
        std         ; si se porneste invers pentru a decripta
        mov ecx, [ebp + 8]
        sub ecx, edi
        neg ecx ; se pune in ecx lungimea stringului fara null si se
        dec edi ; scade 1 deoarece se merge invers
        dec edi
        dec ecx
        dec ecx
rolling_xor_iteration:
        mov al, byte [edi - 1] ; se face xor intre fiecare byte al
        xor byte [edi], al     ; sirului si elementul anterior, mergand
        scasb                  ; invers
        loop rolling_xor_iteration
        cld
        pop ebp
	ret

xor_hex_strings:
        push ebp
        mov ebp, esp
        mov esi, [ebp + 8]  ; string
        mov edi, [ebp + 12] ; cheie
        mov ebx, esi        ; inceputul stringului
        xor ecx, ecx
        xor ax, ax
        
xor_hex_strings_iteration:
        mov al, byte [esi]
        push eax        ; rezultat pus in eax
        call hex_to_int ; fac trecerea de la ascii la valoare intreaga
        add esp, 4
        mov cl, al      ; numarul se construieste in cl
        
        mov al, byte [edi] ; mut valoarea caracterelor din string
        push eax           ; in cl/ch pentru a face xor
        call hex_to_int
        add esp, 4
        mov ch, al
        
        shl cl, 4 ; pregatesc registrii pentru primirea celui de-al
        shl ch, 4 ; doilea nibble
        
        mov al, byte [esi + 1] ; parcurg si urmatorul caracter pentru
        push eax               ; a avea un byte intreg
        call hex_to_int
        add esp, 4
        or cl, al ; se pune al doilea nibble
        
        mov al, byte [edi + 1]
        push eax
        call hex_to_int
        add esp, 4
        or ch, al
        
        xor cl, ch ; se face xor intre stringul si cheia obtinuta
        mov byte [ebx], cl
        scasb
        scasb
        inc esi ; se parcurg cate 2 caractere o data si cu ebx
        inc esi ; se scrie de la inceputul stringului cate un caracter
        inc ebx
        cmp byte [esi], 0
        jne xor_hex_strings_iteration
        mov byte [ebx], 0 ; la final se pune null deoarece stringul
        pop ebp           ; obtinut este mai scurt
	ret

base32decode:
        push ebp
        mov ebp, esp
        mov edi, [ebp + 8] ; parcurge stringul codat
        mov esi, [ebp + 8] ; scrie stringul decodat cate un caracter
        
base32decode_iteration:
        xor edx, edx
        xor eax, eax
        mov al, byte [edi] ; se ia primul caracter si se decodifica
        push eax
        call base32_to_value
        add esp, 4
        
        mov dl, al ; in dl se construieste primul byte din numar
        shl dl, 3  ; mai raman 3 biti de "umplut"
        mov al, byte [edi + 1]
        push eax
        call base32_to_value
        add esp, 4
        
        mov ah, al
        shr al, 2     ; se pun doar 3/5 biti in dl pentru completare
        or dl, al     ; acum primul byte este in dl
        mov [esi], dl ; se scrie in esi pentru a se putea refolosi dl
        inc esi
        xor edx, edx
        shl ah, 3 ; se sterg bitii care au fost folositi anterior
        shr ah, 3
        mov dl, ah  ; se pun cei 2 ramasi in dl urmand sa se construiasca
        shl edx, 30 ; in edx restul de 4 bytes, adica 6 caractere din sir
        xor eax, eax
        mov al, byte [edi + 2]
        push eax
        call base32_to_value
        add esp, 4
        shl eax, 25 ; se shift-eaza eax cu 30-5 biti
        or edx, eax ; si se pune rezultatul in edx
        
        xor eax, eax
        mov al, byte [edi + 3]
        push eax
        call base32_to_value
        add esp, 4
        shl eax, 20 ; se shift-eaza eax cu 25-5 biti
        or edx, eax
        
        xor eax, eax
        mov al, byte [edi + 4]
        push eax
        call base32_to_value
        add esp, 4
        shl eax, 15 ; se shift-eaza eax cu 20-5 biti
        or edx, eax
        
        xor eax, eax
        mov al, byte [edi + 5]
        push eax
        call base32_to_value
        add esp, 4
        shl eax, 10 ; se shift-eaza eax cu 15-5 biti
        or edx, eax
        
        xor eax, eax
        mov al, byte [edi + 6]
        push eax
        call base32_to_value
        add esp, 4
        shl eax, 5 ; se shift-eaza eax cu 10-5 biti
        or edx, eax
        
        xor eax, eax
        mov al, byte [edi + 7]
        push eax
        call base32_to_value
        add esp, 4
        or edx, eax ; nu mai este nevoie de shift-are
        
        mov byte [esi + 3], dl ; se scriu in sir caracterele in ordine inversa
        mov byte [esi + 2], dh
        shr edx, 16
        mov byte [esi + 1], dl
        mov byte [esi], dh
        
        add esi, 4 ; fiecare 8 caractere codificate reprezinta 5 bytes
        add edi, 8 ; unul din ei fiind scris mai sus
        cmp byte [edi], 0
        jne base32decode_iteration
                
        mov byte [esi], 0
        pop ebp
	ret

bruteforce_singlebyte_xor:
        push ebp
        mov ebp, esp
        mov edi, [ebp + 8]
        xor eax, eax
        xor edx, edx
        
bruteforce_singlebyte_xor_decode:
        xor byte [edi], dl
        scasb
        cmp byte [edi], 0
        jne bruteforce_singlebyte_xor_decode ; se aplica xor pe tot sirul
        
        mov edi, [ebp + 8]
        push edi
        call bruteforce_strstr ; se cauta "force"
        add esp, 4
        
        cmp eax, 1 ; daca eax e 1 inseamna ca sirul a fost decodificat
        je bruteforce_singlebyte_xor_exit
        
        mov edi, [ebp + 8] ; daca eax e 0 se reface stringul
bruteforce_singlebyte_xor_encode:
        xor byte [edi], dl
        scasb
        cmp byte [edi], 0
        jne bruteforce_singlebyte_xor_encode

        inc dl ; se incearca urmatoarea cheie
        mov edi, [ebp + 8]
        jmp bruteforce_singlebyte_xor_decode
        
bruteforce_singlebyte_xor_exit:
        mov eax, edx ; cheia corecta este pusa in eax
        pop ebp
	ret

decode_vigenere:
        push ebp
        mov ebp, esp
        mov edi, [ebp + 8] ; string
        mov esi, [ebp + 12] ; cheie

decode_vigenere_iteration:
        cmp byte [edi], 'a'
        jl decode_vigenere_continue ; se sare peste caracterele ce nu 
                                    ; sunt litere        
        mov al, byte [edi]
        mov ah, byte [esi]
        sub ah, 'a'
        sub al, ah
        cmp al, 'a' ; se scade din caracterul din string distanta fata de 'a'
        jge decode_vigenere_success
        
        mov ah, 'a' ; daca valoarea obtinuta prin rotirea la stanga este
        sub al, ah  ; sub 'a', atunci se scade din 'z' numarul de pozitii
        neg al      ; cu cat a depasit sub 'a'
        mov ah, 'z'
        sub al, ah
        neg al
        inc al
decode_vigenere_success:
        mov byte [edi], al
        inc esi
        cmp byte [esi], 0 ; daca cheia a ajuns la final se reia
        jne decode_vigenere_continue
        mov esi, [ebp + 12]
decode_vigenere_continue:        
        inc edi
        cmp byte [edi], 0
        jne decode_vigenere_iteration
        pop ebp
	ret

main:
	push ebp
	mov ebp, esp
	sub esp, 2300

	; test argc
	mov eax, [ebp + 8]
	cmp eax, 2
	jne exit_bad_arg

	; get task no
	mov ebx, [ebp + 12]
	mov eax, [ebx + 4]
	xor ebx, ebx
	mov bl, [eax]
	sub ebx, '0'
	push ebx

	; verify if task no is in range
	cmp ebx, 1
	jb exit_bad_arg
	cmp ebx, 6
	ja exit_bad_arg

	; create the filename
	lea ecx, [filename + 7]
	add bl, '0'
	mov byte [ecx], bl

	; fd = open("./input{i}.dat", O_RDONLY):
	mov eax, 5
	mov ebx, filename
	xor ecx, ecx
	xor edx, edx
	int 0x80
	cmp eax, 0
	jl exit_no_input

	; read(fd, ebp - 2300, inputlen):
	mov ebx, eax
	mov eax, 3
	lea ecx, [ebp-2300]
	mov edx, [inputlen]
	int 0x80
	cmp eax, 0
	jl exit_cannot_read

	; close(fd):
	mov eax, 6
	int 0x80

	; all input{i}.dat contents are now in ecx (address on stack)
	pop eax
	cmp eax, 1
	je task1
	cmp eax, 2
	je task2
	cmp eax, 3
	je task3
	cmp eax, 4
	je task4
	cmp eax, 5
	je task5
	cmp eax, 6
	je task6
	jmp task_done

task1:
        mov edx, ecx
        mov edi, ecx
        mov al, 0
        cld         ; se parcurge sirul pana cand se ajunge la null
        repne scasb ; acolo se afla urmatorul sir

        push edi
        push edx
        call xor_strings ; se apeleaza functia de decodificare
        add esp, 8
        
	push edx
	call puts ; se afiseaza sirul decodificat
	add esp, 4

	jmp task_done

task2:
        mov edx, ecx
        push ecx
        call rolling_xor ; se apeleaza functia de decodificare
        add esp, 4
        
	push edx
	call puts ; se afiseaza sirul decodificat
	add esp, 4

	jmp task_done

task3:
        mov edx, ecx
        mov edi, ecx
        mov al, 0x0
        cld
        repne scasb ; se parcurge pana la null pentru a se gasi cheia
        
        push edi
        push edx
        call xor_hex_strings ; se apeleaza functia de decodificare
        add esp, 8
        
	push edx
	call puts ; se afiseaza sirul decodificat
	add esp, 4

	jmp task_done

task4:
	push ecx
        call base32decode ; se apeleaza functia de decodificare
        add esp, 4
        
	push ecx
	call puts ; se afiseaza sirul decodificat
	pop ecx
	
	jmp task_done

task5:
        push ecx ; se apeleaza functia decodificatoare
        call bruteforce_singlebyte_xor
        pop ecx
        push eax
        
	push ecx
	call puts ; se afiseaza sirul decodificat
	pop ecx
        
        pop eax
	push eax
	push fmtstr ; se afiseaza cheia obtinuta pentru decodificare
	call printf
	add esp, 8

	jmp task_done

task6:
        mov edx, ecx
        mov edi, ecx
        mov al, 0
        cld
        repne scasb ; se cauta cheia utilizata pentru decodificare
        
        push edi
        push edx
        call decode_vigenere ; se apeleaza functia de decodificare
        add esp, 8
        
	push edx
	call puts ; se afiseaza sirul decodificat
	add esp, 4

task_done:
	xor eax, eax
	jmp exit

exit_bad_arg:
	mov ebx, [ebp + 12]
	mov ecx , [ebx]
	push ecx
	push usage
	call printf
	add esp, 8
	jmp exit

exit_no_input:
	push filename
	push error_no_file
	call printf
	add esp, 8
	jmp exit

exit_cannot_read:
	push filename
	push error_cannot_read
	call printf
	add esp, 8
	jmp exit

exit:
	mov esp, ebp
	pop ebp
	ret
