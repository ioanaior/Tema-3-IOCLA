section .data
	; declare global vars here
	vocale db 'aeiou', 0 ; sir global cu vocalele

section .text
	extern printf
	extern strchr
	global reverse_vowels

;;	void reverse_vowels(char *string)
;	Cauta toate vocalele din string-ul `string` si afiseaza-le
;	in ordine inversa. Consoanele raman nemodificate.
;	Modificare se va face in-place
reverse_vowels:
	push ebp
	push esp
	pop ebp
	pusha

	push dword[ebp + 8]
	pop edi ; pointer la inceputul sirului de caractere

	; acum trebuie sa parcurg sirul de la inceput si cand gasesc
	; o vocala sa o bag pe stiva ca dword (impreuna cu perechea de dupa)
	; trebuie sa ma opresc la sfarsitul sirului
pregatire_push:
	xor ecx, ecx ; luam ecx ca si contor
push_vocale:
	cmp byte[edi + ecx], 0
	je pregatire_pop

	; introduc pe stiva sirul si ecx pentru a le pastra valoarea
	push edi
	push ecx

	; introduc pe stiva parametrii pentru strchr:
	push dword[edi + ecx] ; caracterul curent
	push vocale ; sirul de vocale
	call strchr ; dam call la strchr
	add esp, 8

	; recuperam valorile lui ecx si edx
	pop ecx
	pop edi

	cmp eax, 0 ; daca eax != 0, inseamna ca am gasit vocala la pozitia curenta
	je skip_push

	; dau push ca dword la perechea de litere ce incepe cu vocala
	; astfel, vocalele (impreuna cu elementul imediat urmator) vor fi pastrate
	; pe stiva si cand le vom da pop, le vom putea accesa in ordinea inversa
	; intalnirii in sir
	push dword[edi + ecx]

skip_push: ; daca nu intalnim vocala "sarim" direct aici
	inc ecx
	jmp push_vocale

pregatire_pop:
	xor ecx, ecx ; contor pentru caractere
; parcurgem din nou sirul de la inceput pentru a pozitiona vocalele
; de pe stiva in locul celor curente din sir
pop_vocale:
	cmp dword[edi + ecx], 0 ; pana ajungem la "\0"
	je stop
	
	; introduc pe stiva sirul si ecx pentru a le pastra valoarea
	push edi
	push ecx

	; introduc pe stiva parametrii pentru strchr:
	push dword[edi + ecx] ; caracterul curent
	push vocale ; sirul de vocale
	call strchr ; dam call la strchr
	add esp, 8

	pop ecx
	pop edi

	cmp eax, 0 ; daca eax != 0, inseamna ca am gasit vocala la pozitia curenta
	je skip_pop ; daca nu am gasit vocala, trecem la urmatorul caracter
	; altfel dau pop ultimei perechi de pe stiva
	pop eax
	; punem 0 in al doilea byte al perechii (corespunzator literei
	; pe care NU dorim sa o punem in sir)
	xor ah, ah
	; punem 0 la pozitia curenta (unde avem vocala pe care dorim sa o inlocuim)
	and byte[edi + ecx], ah
	; facem OR intre cele 2 perechi
	or byte[edi + ecx], al
	or byte[edi + ecx + 1], ah
	; astfel in sir se vor pastra fix caracterele potrivite:
	; vocala curenta va fi inlocuita cu cea corespunzatoare de pe stiva, iar
	; litera imediat urmatoare va ramane neschimbata

skip_pop:
	inc ecx
	jmp pop_vocale

stop:
	push ebp
	pop esp
	pop ebp
	ret
