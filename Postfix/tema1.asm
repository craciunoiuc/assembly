; Craciunoiu Cezar 324CA
%include "io.inc"

%define MAX_INPUT_SIZE 4096
%define SPACE 32
%define ZERO 48
%define DIVISION 47
%define SUBSTRACTION 45
%define MULTIPLICATION 42
%define ADDITION 43

section .bss
	expr: resb MAX_INPUT_SIZE

section .text
global CMAIN
CMAIN:
    push ebp
    mov ebp, esp
    GET_STRING expr, MAX_INPUT_SIZE
    
    xor eax, eax
    xor edx, edx
    xor ebx, ebx
    cld
    mov edi, expr
    jmp START_LOOP_L1 ; la primul pas edi se afla deja pe un caracter asa ca se
                      ; sare citirea
NEXT_CHAR_L1:
    xor ecx, ecx
    scasb
START_LOOP_L1:
    cmp byte [edi], 0
    je END_L1 ; daca e null se opreste programul
    cmp byte [edi], SPACE
    je END_L1 ; daca este space se sare
    cmp byte [edi], ZERO ; verific daca e numar
    jl NOT_NUMBER_L1
GO_TO_READ_NUMBER_L1:
    push eax ; suma e initial 0
    xor ebx, ebx
    mov dl, 10 ; numarul se va inmulti cu 10 apoi se va aduna o cifra
    cmp byte [edi - 1], '-'
    jnz NOT_NEGATIVE_L1
    mov ecx, 1 ; daca primul numar e negativ se sare peste minus si se
               ; marcheaza in ecx
NOT_NEGATIVE_L1:
READ_NUMBER_L1:
    mov eax, ebx ; calculul se face in eax care a fost salvat deoarece 
                 ; acesta e folosit la inmultire
    mul dl ; se inmulteste cu 10
    mov ebx, eax ; se pune la loc in ebx deoarece cu acesta se lucreaza
    add bl, byte [edi] ; se aduna urmatoarea cifra care este in cod ascii,
                       ; de aceea se scade codul lui 0
    sub bl, ZERO
    scasb
    cmp byte [edi], SPACE ; cat timp nu s-a dat de spatiu continua sa se
			 ; construiasca
    jnz READ_NUMBER_L1
    pop eax
    dec edi ; se scade edi deoarece s-a facut cu un pas in plus pana sa se
            ; opreasca
    cmp ecx, 1 ; daca numarul ar trebui sa fie negativ se pune minus
    jnz DO_NOT_MAKE_NEGATIVE_L1
    neg ebx
DO_NOT_MAKE_NEGATIVE_L1:
    push ebx ; se salveaza rezultatul pe stiva
    jmp END_L1
NOT_NUMBER_L1:
    cmp byte [edi], DIVISION ; se verifica daca este impartire operatia
    jnz NOT_DIVISION_L1
    xor ebx, ebx
    pop ebx ; se scot cei doi termeni
    pop eax
    cdq ; se extinde semnul in edx
    idiv ebx ; se face impartirea cu deimpartitul in edx:eax penru a se
             ; evide orice tip de eroare
    push eax ; se salveaza inapoi pe stiva
    jmp END_L1
NOT_DIVISION_L1:       
    cmp byte [edi], SUBSTRACTION ; se verifica daca este semnul '-'
    jnz NOT_SUBSTRACTION_L1
    xor edx, edx
    scasb
    cmp byte [edi], ZERO ; se verifica urmatorul byte daca este numar,
                         ; insemnand ca este un numar negativ
    jge GO_TO_READ_NUMBER_L1
    ; daca este operatie de scadere, nu un numar negativ
    pop ebx
    pop eax ; in mod similar se scot cei doi registrii si se scad,
            ; apoi punandu-se pe stiva
    sub eax, ebx
    push eax
    jmp END_L1
NOT_SUBSTRACTION_L1:
    cmp byte [edi], MULTIPLICATION ; daca este operatie de inmultire
    jnz NOT_MULTIPLICATION_L1
    pop ebx ; la fel se scot cei 2 registrii
    pop eax
    imul ebx ; inmultirea se face cu semn deoarece numerele pot fi negative
    push eax
    jmp END_L1
NOT_MULTIPLICATION_L1:
    cmp byte [edi], ADDITION ; daca se intalneste semnul +
    jnz NOT_ADDITION_L1
    pop ebx ; se scot cei 2 registrii si se aduna, iar rezultatul se salveaza
    pop eax
    add eax, ebx
    push eax
    jmp END_L1
NOT_ADDITION_L1:
    ; ca un caz default la switch, in caz ca nu s-a introdus un caracter
    ; corect se afiseaza o eroare
    PRINT_STRING "ERROR: INCORRECT CHARACTER, ABORTING"
    NEWLINE
    mov eax, -1
    ret
END_L1:
    cmp BYTE [edi], 0 ; daca se intalneste null se iese
    jne NEXT_CHAR_L1   
    pop eax ; se scoate rezultatul si se afiseaza
    PRINT_DEC 4, eax
    NEWLINE 
    xor eax, eax
    pop ebp
    ret
