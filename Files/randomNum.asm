; Description: generates a random number in range 1 to 16 with the result being placed in rax

	section .data
rmax:	dq	16
rseed:	dq	0
	
	section .text
	global randomNum

randomNum:
	;; seed random with systime, returns time in rax
	mov 	rax, 201
	xor	rdi, rdi
	syscall

	mov	[rseed], rax
	xor	rax, rax
	
	;; generate random number
	xor     rdx, rdx ;the output of mul and div is in rax, so we will use rax to compute our random number
	xor     rax, rax
	xor     r11, r11
	xor     r10, r10
	xor     r9, r9
	xor     r8, r8

	mov     rax, [rseed]
	mov     r11, 1103515245
	mov     r10, 12345
	
	mul     r11
	add     rax, r10

	mov     [rseed], al

	mov     r9, 65536
	div     r9

	mov     r8, [rmax]
	add     r8, 1

	xor     rdx, rdx ;modulus operation, clear the remainder in rdx from earlier and use newremainder as result
	div     r8

	mov     rcx, rdx ;take the absolute value of the final answer
	shr     rcx, 31
	xor     rdx, rcx
	sub     rdx, rcx
	mov     rax, rdx

	xor     rdx, rdx ;set random values to be in correct range
	xor     rcx, rcx
	mov     rcx, 16 - 1 + 1
	div     rcx
	mov     rax, rdx
	add     rax, 1

	ret

	
