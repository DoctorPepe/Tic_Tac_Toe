;Description: this file holds the subroutine for the HARD mode of the tictactoe game. The computer detects if the player can win if they go in a certain spot and prevents that. Otherwise, they place pieces down randomly
	
	extern drawBoard
	extern randomNum
	extern checkWinner
	extern clearScoreBoard
	extern getFutureMove
	extern main
	
	section .data
welcome:	db	"Starting HARD Mode...", 10
len_welcome	equ	$-welcome

play:		db	"Enter a location on the board (1-16): ", 10
len_play	equ	$-play

computer:	db	"Computer is playing...", 10
len_comp	equ	$-computer

incorrect_msg:	db	"Incorrect input!", 10
len_incorrect	equ	$-incorrect_msg

tie_msg:	db      "Its a Tie", 10
len_tie_msg	equ     $-tie_msg

fut_msg:	db	"A future move was found", 10
len_fut_msg	equ	$-fut_msg
	
no_fut_msg:	db	"No future move was found!", 10
len_no_fut_msg	equ	$-no_fut_msg
	
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
	global	compHard
	
compHard:
	;; clear game board and scoreBoard
	mov	rdi, board
	call	clearBoard2
	call	clearScoreBoard

	;; welcome message
	mov	rsi, welcome
	mov	rdx, len_welcome
	call	print_out3
	
	call	gameLoop2
	ret

gameLoop2:
	;; by c calling convention, first parameter for function should be put in rdi
	mov	rdi, board
	call	drawBoard

	;; print
        mov     rsi, play
	mov     rdx, len_play
	call 	print_out3

	;; get validated user input
	call	getInput2

	;; if game was not won, computer goes
	mov 	rsi, computer
	mov	rdx, len_comp
	call 	print_out3
	call	aI
	
	jmp	gameLoop2

getInput2:
	;;  get user input
	mov     rax, 0
	mov     rdi, 0
	mov     rsi, input
	mov     rdx, 16
	syscall

	xor	rax, rax
	mov	rdi, input
	call	strToInt2
	;; result will be stored in r12 as it is callee saved
	mov	rax, r12
	sub	rax, 1
	mov	[input], rax
	
	;; jump to incorrect if input is less than 0 or greater than 15
	mov	r8, 0
	mov	r9, 15
	cmp	rax, r8
	jl	incorrect2
	cmp	rax, r9
	jg	incorrect2

	;; otherwise the input is valid and we can add it to the board and carry on
	mov	rcx, board
	add	rcx, [input]
	;; check at this spot if there is already a piece here
	cmp	byte[rcx], 'x'
	je	incorrect2
	cmp	byte[rcx], 'o'
	je	incorrect2

	;; otherwise place the piece at this location
	mov	byte[rcx], 'x'

	;; after placing piece, check winner
	;; subroutine expecting most recently played char in rsi and index in rdi
	mov	rdi, [input]
	mov	rsi, 'x'
	call	checkWinner
	mov	rdi, board
	call 	tie2
	ret
	
incorrect2:
	mov	rsi, incorrect_msg
	mov	rdx, len_incorrect
	call	print_out3

	jmp	getInput2
	ret

print_out3:
	mov     rax, 1
	mov     rdi, 1
	syscall
	ret

strToInt2:
	;rdi contains address of input, rax will be our integer
	imul    rax, 10
	xor     rdx, rdx
	mov     dl, byte[rdi]
	sub     dl, 48
	add     rax, rdx
	inc     rdi

	;as long as next character is not a null, continue to loop
	cmp     byte[rdi], 10	;before we adjust for actual values, 10 is a newline
	jne     strToInt2

	mov	r12, rax
	ret

comp2:	
	call	randomNum	;random number in rax
	sub	rax, 1		;to make it index

	mov     rcx, board
	add     rcx, rax
	;check at this spot if there is already a piece here
	cmp     byte[rcx], 'x'
	je      comp2
	cmp     byte[rcx], 'o'
	je      comp2
	;otherwise place the piece at this location
	mov     byte[rcx], 'o'

	;; check for winner after placing piece
	;; subroutine expecting most recently played char in rsi and index in rdi
	mov	rdi, rax
	mov	rsi, 'o'
	call 	checkWinner
	mov	rdi, board
	call 	tie2
	ret

clearBoard2:
	;; clear the board, and replace every spot with a space
	mov	byte[rdi], ' '
	
	inc	rdi
	cmp	byte[rdi], 11
	jne	clearBoard2
	ret

tie2:
	cmp     byte[rdi], ' '
	je      notTie2

	inc     rdi
	cmp     byte[rdi], 11
	jne     tie2
	cmp     byte[rdi], 11
	je      tieFound2

notTie2:
	ret

tieFound2:
	mov     rsi, tie_msg
	mov     rdx, len_tie_msg
	call    print_out3

	call 	main
	ret

aI:
	;; get future moves and choose a case based off of the index we get back
	call	getFutureMove
	;; rax will be 11 if there is no future move
	cmp	rax, 11
	je	comp2

	call	compareRows
	call	compareColumns
	call	compareDiag
	ret

compareRows:
	cmp     rax, 0
	je      row0AI
	cmp     rax, 1
	je      row1AI
	cmp     rax, 2
	je      row2AI
	cmp     rax, 3
	je      row3AI
	ret

compareColumns:
	cmp	rax, 4
	je	col0AI
	cmp	rax, 5
	je	col1AI
	cmp	rax, 6
	je	col2AI
	cmp	rax, 7
	je	col3AI
	ret

compareDiag:
	cmp	rax, 8
	je	diagAI
	cmp	rax, 9
	je	antidiagAI
	ret
	
row0AI:
	;; check each possible index in row0 against a blank space, and put a piece in the blank spot
	;; row0: index 0-3
	mov	rdi, board
	mov	r9, 0
	cmp	byte[rdi], ' '
	je	placePiece

	inc	rdi
	add	r9, 1
	cmp	byte[rdi], ' '
	je	placePiece

	inc 	rdi
	add	r9, 1
	cmp	byte[rdi], ' '
	je	placePiece

	inc	rdi
	add	r9, 1
	cmp	byte[rdi], ' '
	je 	placePiece
	
	ret

row1AI:
;;;  row1: index 4-7
	mov     rdi, board
	mov     r9, 4
	add	rdi, 4
	cmp     byte[rdi], ' '
	je      placePiece

	inc     rdi
	add     r9, 1
	cmp     byte[rdi], ' '
	je      placePiece

	inc     rdi
	add     r9, 1
	cmp     byte[rdi], ' '
	je      placePiece

	inc     rdi
	add     r9, 1
	cmp     byte[rdi], ' '
	je      placePiece
	ret

row2AI:
;;;  row2: index 8-11
	mov     rdi, board
	mov     r9, 8
	add	rdi, 8
	cmp     byte[rdi], ' '
	je      placePiece

	inc     rdi
	add     r9, 1
	cmp     byte[rdi], ' '
	je      placePiece

	inc     rdi
	add     r9, 1
	cmp     byte[rdi], ' '
	je      placePiece

	inc     rdi
	add     r9, 1
	cmp     byte[rdi], ' '
	je      placePiece
	ret

row3AI:
;;;  row3: index 12-15
	mov     rdi, board
	mov     r9, 12
	add	rdi, 12
	cmp     byte[rdi], ' '
	je      placePiece

	inc     rdi
	add     r9, 1
	cmp     byte[rdi], ' '
	je      placePiece

	inc     rdi
	add     r9, 1
	cmp     byte[rdi], ' '
	je      placePiece

	inc     rdi
	add     r9, 1
	cmp     byte[rdi], ' '
	je      placePiece
	ret

col0AI:
	mov	rdi, board
	mov	r9, 0
	cmp	byte[rdi], ' '
	je	placePiece

	add	rdi, 4
	add	r9, 4
	cmp	byte[rdi], ' '
	je	placePiece

	add	rdi, 4
	add	r9, 4
	cmp	byte[rdi], ' '
	je	placePiece

	add	rdi, 4
	add	r9, 4
	cmp	byte[rdi], ' '
	je	placePiece
	ret

col1AI:
	mov     rdi, board
	add	rdi, 1
	mov     r9, 1
	cmp     byte[rdi], ' '
	je      placePiece

	add     rdi, 4
	add     r9, 4
	cmp     byte[rdi], ' '
	je      placePiece

	add     rdi, 4
	add     r9, 4
	cmp     byte[rdi], ' '
	je      placePiece

	add     rdi, 4
	add     r9, 4
	cmp     byte[rdi], ' '
	je      placePiece
	ret

col2AI:
	mov     rdi, board
	add     rdi, 2
	mov     r9, 2
	cmp     byte[rdi], ' '
	je      placePiece

	add     rdi, 4
	add     r9, 4
	cmp     byte[rdi], ' '
	je      placePiece

	add     rdi, 4
	add     r9, 4
	cmp     byte[rdi], ' '
	je      placePiece

	add     rdi, 4
	add     r9, 4
	cmp     byte[rdi], ' '
	je      placePiece
	ret

col3AI:
	mov     rdi, board
	add     rdi, 3
	mov     r9, 3
	cmp     byte[rdi], ' '
	je      placePiece

	add     rdi, 4
	add     r9, 4
	cmp     byte[rdi], ' '
	je      placePiece

	add     rdi, 4
	add     r9, 4
	cmp     byte[rdi], ' '
	je      placePiece

	add     rdi, 4
	add     r9, 4
	cmp     byte[rdi], ' '
	je      placePiece
	ret

diagAI:
	mov	rdi, board
	mov	r9, 0
	cmp	byte[rdi], ' '
	je	placePiece

	add	rdi, 5
	add	r9, 5
	cmp	byte[rdi], ' '
	je	placePiece

	add	rdi, 5
	add	r9, 5
	cmp	byte[rdi], ' '
	je	placePiece

	add	rdi, 5
	add	r9, 5
	cmp	byte[rdi], ' '
	je	placePiece
	ret

antidiagAI:
	mov	rdi, board
	mov	r9, 3
	add	rdi, 3
	cmp	byte[rdi], ' '
	je	placePiece

	add	rdi, 3
	add	r9, 3
	cmp	byte[rdi], ' '
	je	placePiece

	add	rdi, 3
	add	r9, 3
	cmp	byte[rdi], ' '
	je	placePiece

	add	rdi, 3
	add	r9, 3
	cmp	byte[rdi], ' '
	je	placePiece
	ret
	
placePiece:
	;; index of position to place piece is now in rax, so add piece as necessary
	mov	rdi, board
	add	rdi, r9
	mov	byte[rdi], 'o'
	;; check for winner and tie
	mov	rdi, r9
	mov	rsi, 'o'
	call	checkWinner
	mov	rdi, board
	call	tie2
	ret
