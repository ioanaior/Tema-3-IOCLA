extern array_idx_1      ;; int array_idx_1

section .text
    global inorder_parc

;   struct node {
;       int value;
;       struct node *left;
;       struct node *right;
;   } __attribute__((packed));

;;  inorder_parc(struct node *node, int *array);
;       functia va parcurge in inordine arborele binar de cautare, salvand
;       valorile nodurilor in vectorul array.
;    @params:
;        node  -> nodul actual din arborele de cautare;
;        array -> adresa vectorului unde se vor salva valorile din noduri;

; ATENTIE: vectorul array este INDEXAT DE LA 0!
;          Cititi SI fisierul README.md din cadrul directorului pentru exemple,
;          explicatii mai detaliate!
; HINT: folositi variabila importata array_idx_1 pentru a retine pozitia
;       urmatorului element ce va fi salvat in vectorul array.
;       Este garantat ca aceasta variabila va fi setata pe 0 la fiecare
;       test.


inorder_parc:
    enter 0, 0
    
    mov eax, [ebp + 8] ; node
    mov esi, [ebp + 12] ; array

    cmp eax, 0 ; verifica daca nodul este nul
    je stop

    ; efectuam parcurgerea in inordine: stanga, radacina, dreapta

    ; parcurgem nodul stang
    push eax

    mov ecx, [eax + 4] ; mutam membrul left al structurii node in ecx
    push esi ; parametru 2 -> array
    push ecx ; parametru 1 -> nod curent (cel din stanga)
    call inorder_parc
    add esp, 8 ; eliberam parametrii de pe stiva

    pop eax

    ; salvam valoarea nodului in vector
    mov ecx, dword [array_idx_1] ; salvam valoarea lui array_idx_1 in ecx
    mov edx, [eax] ; salvam in edx membrul value al nodului curent
    mov [esi + ecx * 4], edx ; stocam valoarea nodului in vector

    ; incrementam indexul pentru urmatorul element din vector
    inc dword [array_idx_1]

    ; parcurgem nodul drept
    push eax

    push esi
    mov ecx, [eax + 8]
    push ecx ; apelam recursiv pentru nodul drept
    call inorder_parc
    add esp, 8

    pop eax

stop:
    leave
    ret
