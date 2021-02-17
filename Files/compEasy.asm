;Description: this file holds the subroutine for the easy mode of the tictactoe game. The computer randomly places pieces down on the board.
	
	extern drawBoard
	extern randomNum
	extern checkWinner
	extern clearScoreBoard
	extern main
	
	section .data
welcome:	db	"Starting Easy Mode...", 10
len_welcome	equ	$-welcome

play:		db	"Enter a location on the board (1-16): ", 10
len_play	equ	$-play

computer:	db	"Computer is playing...", 10
len_comp	equ	$-computer

incorrect_msg:	db	"Incorrect input!", 10
len_incorrect	equ	$-incorrect_msg

tie_msg:	db      "Its a Tie", 10
len_tie_msg     equ     $-tie_msg
	
board:
	db	' '
	db	' '
	db	' '
	db	' '
	db	' '
	db	' '
	db	' '
	db	' '
	db	' '
	db	' '
	db	' '
	db	' '
	db	' '
	db	' '
	db	' '
	db	' '
	db	11
	
	section .bss
input		resb	16
	
	section .text
	global	compEasy
	
compEasy:
	;; clear game board and scoreBoard
	mov	rdi, board
	call	clearBoard
	call	clearScoreBoard

	;; welcome message
	mov	rsi, welcome
	mov	rdx, len_welcome
	call	print_out2
	
	call	gameLoop
	ret

gameLoop:
	;; by c calling convention, first parameter for function should be put in rdi
	mov	rdi, board
	call	drawBoard

	;; print
        mov     rsi, play
	mov     rdx, len_play
	call 	print_out2

	;; get validated user input
	call	getInput

	;; if game was not won, computer goes
	mov 	rsi, computer
	mov	rdx, len_comp
	call 	print_out2
	call	comp
	
	jmp	gameLoop

getInput:
	;;  get user input
	mov     rax, 0
	mov     rdi, 0
	mov     rsi, input
	mov     rdx, 16
	syscall

	xor	rax, rax
	mov	rdi, input
	call	strToInt
	;; result will be stored in r12 as it is callee saved
	mov	rax, r12
	sub	rax, 1
	mov	[input], rax
	
	;; jump to incorrect if input is less than 0 or greater than 15
	mov	r8, 0
	mov	r9, 15
	cmp	rax, r8
	jl	incorrect
	cmp	rax, r9
	jg	incorrect

	;; otherwise the input is valid and we can add it to the board and carry on
	mov	rcx, board
	add	rcx, [input]
	;; check at this spot if there is already a piece here
	cmp	byte[rcx], 'x'
	je	incorrect
	cmp	byte[rcx], 'o'
	je	incorrect

	;; otherwise place the piece at this location
	mov	byte[rcx], 'x'

	;; after placing piece, check winner
	;; subroutine expecting most recently played char in rsi and index in rdi
	mov	rdi, [input]
	mov	rsi, 'x'
	call	checkWinner
	mov	rdi, board
	call	tie
	ret
	
incorrect:
	mov	rsi, incorrect_msg
	mov	rdx, len_incorrect
	call	print_out2

	jmp	getInput
	ret

print_out2:
	mov     rax, 1
	mov     rdi, 1
	syscall
	ret

strToInt:
	;rdi contains address of input, rax will be our integer
	imul    rax, 10
	xor     rdx, rdx
	mov     dl, byte[rdi]
	sub     dl, 48
	add     rax, rdx
	inc     rdi

	;as long as next character is not a null, continue to loop
	cmp     byte[rdi], 10	;before we adjust for actual values, 10 is a newline
	jne     strToInt

	mov	r12, rax
	ret

comp:
	call	randomNum	;random number in rax
	sub	rax, 1		;to make it index

	mov     rcx, board
	add     rcx, rax
	;check at this spot if there is already a piece here
	cmp     byte[rcx], 'x'
	je      comp
	cmp     byte[rcx], 'o'
	je      comp
	;otherwise place the piece at this location
	mov     byte[rcx], 'o'

	;; check for winner after placing piece
	;; subroutine expecting most recently played char in rsi and index in rdi
	mov	rdi, rax
	mov	rsi, 'o'
	call checkWinner
	mov     rdi, board
	call    tie
	ret

clearBoard:
	;; clear the board, and replace every spot with a space
	mov	byte[rdi], ' '
	
	inc	rdi
	cmp	byte[rdi], 11
	jne	clearBoard
	ret

tie:
	cmp	byte[rdi], ' '
	je	notTie

	inc	rdi
	cmp	byte[rdi], 11
	jne	tie
	cmp	byte[rdi], 11
	je	tieFound

notTie:
	ret

tieFound:
	mov	rsi, tie_msg
	mov	rdx, len_tie_msg
	call	print_out2

	call main
	ret
