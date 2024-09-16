global get_words
global compare_func
global sort

section .data
    sep dw " .,", 0 ; sirul de separatori pentru cuvinte

section .text
    extern strtok
    extern qsort
    extern strlen
    extern strcmp

;; sort(char **words, int number_of_words, int size)
;  functia va trebui sa apeleze qsort pentru soratrea cuvintelor 
;  dupa lungime si apoi lexicografix
sort:
    enter 0, 0

    mov esi, [ebp + 8] ; words
	mov edx, [ebp + 12] ; n
	mov edi, [ebp + 16] ; size

    ; aplic qsort pe sir

    push edx ; dau push pe stiva lui edx pentru a-i pastra valoarea

    ; introducem argumentele pentru qsort pe stiva
    push compare_func
    push edi
    push edx
    push esi
    call qsort ; dam call la qsort
    add esp, 16

    pop edx ; il recuperam pe ecx

    leave
    ret

compare_func: ; functia de compare pentru qsort

    enter 0, 0

    mov ecx, [ebp + 8] ; cuvant 1
    mov edx, [ebp + 12] ; cuvant 2
    
    ; fac cast la parametri
    mov ecx, dword[ecx]
    mov edx, dword[edx]

    ; compar cele doua cuvinte, mai intai in functie de lungime
    push edx ; il salvam pe edx
    push ecx ; il salvam pe ecx

    push ecx
    call strlen
    add esp, 4

    pop ecx ; il recuperam pe ecx
    pop edx ; il recuperam pe edx

    
    push ecx ; pastram ecx ul ca si cuvant

    ; in eax avem lungimea cuvantului stocat in ecx
    mov ecx, eax ; mutam lungimea primului cuvant in ecx
    
    push edx
    push ecx ; pastram ecx-ul ca si lungime

    push edx
    call strlen
    add esp, 4

    pop ecx ; recuperam ecx-ul (ca si lungime)
    pop edx

    cmp ecx, eax ; comparam lungimile cuvintelor
    ; daca primul cuvant este mai scurt, in eax vom pune o valoare < 0
    jl return_negativ
    cmp ecx, eax ; comparam lungimile cuvintelor
    ; daca primul cuvant este mai scurt, in eax vom pune o valoare < 0
    jg return_pozitiv
    cmp ecx, eax ; comparam lungimile cuvintelor
    ; daca primul cuvant este mai scurt, in eax vom pune o valoare < 0
    je comparare_lexicografica

return_negativ:
    mov eax, -1
    pop ecx ; recuperam ecx de pe stiva
    jmp stop_comparare
return_pozitiv:
    mov eax, 1
    pop ecx ; recuperam ecx de pe stiva
    jmp stop_comparare
comparare_lexicografica:
    ; In acest punct al compararii se va ajunge daca sirurile au aceeasi
    ; lungime. Astfel, va trebui sa le comparam lexicografic
    pop ecx ; se recupereaza ecx (ca si cuvant)

    ; introducem cele doua cuvinte pe stiva si apelam strcmp
    push edx
    push ecx
    call strcmp
    add esp, 8
    ; eax va stoca fix o valoare analoaga cu ceea ce avem nevoie
    ; pentru functia de comparare

stop_comparare:
    leave
    ret

;; get_words(char *s, char **words, int number_of_words)
;  separa stringul s in cuvinte si salveaza cuvintele in words
;  number_of_words reprezinta numarul de cuvinte
get_words:
    enter 0, 0

    mov esi, [ebp + 8] ; s
	mov edi, [ebp + 12] ; words
	mov edx, [ebp + 16] ; number_of_words


xor ecx, ecx ; contor pentru numarul de cuvinte

introdu_in_words:
    ; primul apel al lui strtok
    ; strtok (s, sep)

    ; salvez registrul ecx dandu-i push pe stiva
    push ecx

    push sep
    push esi
    call strtok
    add esp, 8

    pop ecx

    ; in eax se va pastra cuvantul pe care tocmai l-am separat de sir
    ; acesta trebuie lipit la words
    ; dar la ce offset? ecx*4!
    mov [edi + ecx * 4], eax

inc ecx
    ; acum apelez strtok repetitiv pentru celelalte cuvinte
    ; strtok (NULL, sep)
repeta_strtok:
    cmp eax, 0 ; repetam bucata de cod cat timp cuvantul curent != NULL
    je stop

    push ecx

    push sep
    push 0
    call strtok
    add esp, 8

    pop ecx

    mov [edi + ecx * 4], eax

    ; repetam instructiunile
    inc ecx
    jmp repeta_strtok

stop:
    
    leave
    ret
