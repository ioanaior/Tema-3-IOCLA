section .data
	back db "..", 0
	curr db ".", 0
	slash db "/", 0
	aux dd 0 ; am declarat un sir auxliliar pe care il voi utiliza
	; pentru a pune mai apoi strungurile in ordinea potrivita in output

section .text
	global pwd
	extern strcat
	extern strcmp

;;	void pwd(char **directories, int n, char *output)
;	Adauga in parametrul output path-ul rezultat din
;	parcurgerea celor n foldere din directories
pwd:
	enter 0, 0

	mov esi, [ebp + 8] ; directories
	mov edx, [ebp + 12] ; n
	mov edi, [ebp + 16] ; output

	xor eax, eax ; contor pentru numarul de elemente de pe stiva
	xor ecx, ecx ; contor pentru linia din matrice

push_foldere:
	cmp ecx, edx
	jge pregateste_aux ; dupa ce parcurgem toate folderele din matrice

	push eax ; salvam valoarea lui eax

	mov eax, [esi + ecx*4] ; mut in eax folderul curent (sau ".."/".") din matrice
	; vreau sa compar eax cu ".."

	push edx
	push ecx

	push eax
	push back
	call strcmp
	add esp, 8

	pop ecx
	pop edx

	; acum am in eax rezultatul compararii
	cmp eax, 0
	jne pop_eax_1 ; daca nu am gasit "..", verificam si poate gasim "."
	
	pop eax ; recuperam valoarea lui eax (contorul)

	; daca nu avem doar slash in cale, dam pop la ultimele 2 elemente
	; (mutam adresa lui esp)
	cmp eax, 1
	jle skip_pop_eax

	add esp, 8
	sub eax, 2 ; se scade 2 din numarul de elemente de pe stiva
	jmp reia_push ; se reiau operatiile

pop_eax_1: ; recuperarea valorii lui eax in cazul in care nu se gaseste ".."
	pop eax
	jmp verifica_curr

skip_pop_eax:
jmp reia_push ; se reiau operatiile

; daca nu am intalnit ".." la pasul curent, verificam daca avem "."
verifica_curr:
	cmp ecx, edx
	jge pregateste_aux

	push eax ; salvam valoarea lui eax

	mov eax, [esi + ecx*4]

	push esi
	push edx
	push ecx

	; compar eax cu "."
	push eax
	push curr
	call strcmp
	add esp, 8

	pop ecx
	pop edx
	pop esi

	; acum am in eax rezultatul compararii
	cmp eax, 0
	jne pop_eax_2 ; daca nu am gasit "."
	
	pop eax ; recuperam valoarea lui eax

	; daca am gasit ".", pur si simplu trecem la pasul urmator
	jmp reia_push

pop_eax_2: ; recuperam valoarea lui eax si in cazul in care am gasit "."
	pop eax
	jmp verifica_folder

verifica_folder:
	; daca am ajuns aici inseamna ca stringul nostru este un folder
	; deci nu mai este nevoie sa facem strcmp

	; facem push la slash si la numele folderului
	push slash
	push dword[esi + ecx*4]

	; adunam 2 la eax (contorul pentru numarul de elemente de pe stiva)
	add eax, 2

reia_push: ; reluam procedeul de vrificare pentru fiecare linie a matricei
	inc ecx
	jmp push_foldere

pregateste_aux:
	push slash ; mai introducem un slash pe stiva pentru a-l avea la inceputul path-ului
	mov ecx, eax
; instructiune repetitiva pentru a introduce elementele de pe stiva in sirul auxiliar
; elementele sunt momentan stocate pe stiva in ordine inversa si ne folosim de
; acest procedeu pentru a rasturna path-ul
; mutarea stringurilor in aux se realizeaza de la dreapta la stanga
introdu_in_aux:
	cmp eax, -1 ; efectuam un pas in plus pentru ca am adaugat slashul
	je pregatire_output

	pop edx ; recuperam cate un element de pe stiva
	mov [aux + eax*4], edx ; si il introducem in sirul aux la adresa urmatoare
	
	dec eax ; scadem contorul
	jmp introdu_in_aux ; repetam procedeul

pregatire_output:
	xor eax, eax
	inc ecx
; vom introduce in sirul de output cuvintele din aux in ordine
baga_in_output:
	cmp eax, ecx
	je stop

	push eax
	push ecx

	push dword[aux + eax*4] ; sursa (cuvantul curent din aux)
	push edi ; destinatia (sirul de output)
	call strcat
	add esp, 8

	pop ecx
	pop eax

	inc eax
	jmp baga_in_output ; repetam procedeul pana ajungem la sfarsitul lui aux


stop:
	leave
	ret
