section .text
    global inorder_fixing

;   struct node {
;       int value;
;       struct node *left;
;       struct node *right;
;   } __attribute__((packed));

;;  inorder_fixing(struct node *node, struct node *parent)
;       functia va parcurge in inordine arborele binar de cautare, modificand
;       valorile nodurilor care nu respecta proprietatea de arbore binar
;       de cautare: |node->value > node->left->value, daca node->left exista
;                   |node->value < node->right->value, daca node->right exista.
;
;       Unde este nevoie de modificari se va aplica algoritmul:
;           - daca nodul actual este fiul stang, va primi valoare tatalui - 1,
;                altfel spus: node->value = parent->value - 1;
;           - daca nodul actual este fiul drept, va primi valoare tatalui + 1,
;                altfel spus: node->value = parent->value + 1;

;    @params:
;        node   -> nodul actual din arborele de cautare;
;        parent -> tatal/parintele nodului actual din arborele de cautare;

; ATENTIE: DOAR in frunze pot aparea valori gresite! 
;          Cititi SI fisierul README.md din cadrul directorului pentru exemple,
;          explicatii mai detaliate!

inorder_fixing:
    enter 0, 0

    ; salvez valorile registrelor cu care lucrez
    push eax
    push edi
    push ecx
    push edx


    mov eax, [ebp + 8] ; node
    mov edi, [ebp + 12] ; parent

    cmp eax, 0 ; verificam daca nodul este NULL
    je stop

    ; parcurgem nodul stang

    mov ecx, [eax + 4] ; mutam membrul left al structurii node in ecx
    ; punem parametrii pe stiva
    push eax
    push ecx
    call inorder_fixing ; apelam recursiv pentru fiul stang
    add esp, 8 ; eliberam parametrii de pe stiva
    
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
    ; modificam valoarea frunzei corespunzator
    ; valoare_frunza_stanga = valoare_radacina - 1
    mov ecx, dword [edi]
    dec ecx
    mov dword[eax], ecx
    jmp skip

; daca frunza este fiu drept al radacinii:
verifica_drept_mai_mare:
    mov ecx, dword[edi]
    cmp ecx, dword[eax] ; compar valoarea parintelui cu valoarea fiului drept
    jl skip ; radacina e mai mica decat fiul drept -> dam skip
    ; modificam valoarea frunzei corespunzator
    ; valoare_frunza_dreapta = valoare_radacina + 1
    mov ecx, dword[edi]
    inc ecx
    mov dword[eax], ecx
    jmp skip


skip:
; parcurgem nodul drept

    ; introducem parametrii pe stiva
    push eax ; parintele nodului urmator devine nodul curent
    mov ecx, [eax + 8]
    push ecx
    call inorder_fixing ; apelam recursiv pentru nodul drept
    add esp, 8 ; eliberam cei trei parametri de pe stivă

stop:
    ; recuperez valorile registrelor
    pop edx
    pop ecx
    pop edi
    pop eax

    leave
    ret
