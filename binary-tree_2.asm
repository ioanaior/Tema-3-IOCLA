extern array_idx_2      ;; int array_idx_2

section .text
    global inorder_intruders

;   struct node {
;       int value;
;       struct node *left;
;       struct node *right;
;   } __attribute__((packed));

;;  inorder_intruders(struct node *node, struct node *parent, int *array)
;       functia va parcurge in inordine arborele binar de cautare, salvand
;       valorile nodurilor care nu respecta proprietatea de arbore binar
;       de cautare: |node->value > node->left->value, daca node->left exista
;                   |node->value < node->right->value, daca node->right exista
;
;    @params:
;        node   -> nodul actual din arborele de cautare;
;        parent -> tatal/parintele nodului actual din arborele de cautare;
;        array  -> adresa vectorului unde se vor salva valorile din noduri;

; ATENTIE: DOAR in frunze pot aparea valori gresite!
;          vectorul array este INDEXAT DE LA 0!
;          Cititi SI fisierul README.md din cadrul directorului pentru exemple,
;          explicatii mai detaliate!

; HINT: folositi variabila importata array_idx_2 pentru a retine pozitia
;       urmatorului element ce va fi salvat in vectorul array.
;       Este garantat ca aceasta variabila va fi setata pe 0 la fiecare
;       test al functiei inorder_intruders.      

inorder_intruders:
    enter 0, 0

    ; salvez valorile registrelor cu care lucrez
    push eax
    push edi
    push esi
    push ecx
    push edx

    mov eax, [ebp + 8] ; node
    mov edi, [ebp + 12] ; parent
    mov esi, [ebp + 16] ; array

    cmp eax, 0 ; verificam daca nodul este NULL
    je stop

    ; parcurgem nodul stang

    mov ecx, [eax + 4] ; mutam membrul left al structurii node in ecx
    ; punem parametrii pe stiva
    push esi
    push eax
    push ecx
    call inorder_intruders ; apelam recursiv pentru fiul stang
    add esp, 12 ; eliberam parametrii de pe stiva
    
    ; parcurgem nodul curent
    ; verificam daca acesta este frunza
    mov ecx, [eax + 4] ; mutam membrul left al structurii node in ecx
    cmp ecx, 0 ; verificam daca are fiu stang
    jne skip
    
    ; daca nu are fiu stang:
    mov ecx, [eax + 8]
    cmp ecx, 0 ; verificam daca are fiu drept
    jne skip

    ; daca nodul curent este frunza:
    ; trebuie sa verificam daca frunza este fiu stang sau drept al parintelui
    cmp [edi + 4], eax
    je verifica_stang_mai_mic
    cmp [edi + 8], eax
    je verifica_drept_mai_mare

; daca frunza este fiu stang al radacinii:
verifica_stang_mai_mic:
    mov ecx, dword [edi]
    cmp ecx, dword [eax] ; compar valoarea parintelui cu valoarea fiului stang
    jg skip ; radacina e mai mare decat fiul stang -> dam skip
    jmp gresit

; daca frunza este fiu drept al radacinii:
verifica_drept_mai_mare:
    mov ecx, dword [edi]
    cmp ecx, dword [eax] ; compar valoarea parintelui cu valoarea fiului drept
    jl skip ; radacina e mai mica decat fiul drept -> dam skip

; daca valoarea nodului este gresit pusa in arborele binar de cautare
gresit:
    mov ecx, dword [array_idx_2] ; salvam valoarea indexului in ecx
    mov edx, dword [eax]
    mov [esi + ecx * 4], edx ; stocam valoarea nodului in vector

    ; incrementam indexul pentru urmatorul element din vector
    inc dword [array_idx_2]

skip:
    ; parcurgem nodul drept

    ; introducem parametrii pe stiva
    push esi
    push eax ; parintele nodului urmator devine nodul curent
    mov ecx, [eax + 8]
    push ecx
    call inorder_intruders ; apelam recursiv pentru nodul drept
    add esp, 12 ; eliberam cei trei parametri de pe stivă

stop:
    ; recuperez valorile registrelor
    pop edx
    pop ecx
    pop esi
    pop edi
    pop eax

    leave
    ret
