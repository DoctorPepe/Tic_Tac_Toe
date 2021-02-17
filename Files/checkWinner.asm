;; Description: this file holds the subroutine which checks to see if either the computer or the player has won. the following is my general algorithm:
	;; check rows (1, 5, 9, 13) and columns (1-4), then diagonals for all the same character
	;; get the character at the leftmost spot. If either player has won, we can assume that this place will be filled by the winning piece type
	;; if all types of the row/column/diagonal we are checking has this piece (4 total) we have a winner

	extern main
	
	section .data
player_won_msg:		db	"You have won!", 10
len_play_won		equ	$-player_won_msg
	
comp_won_msg:		db	"The computer has won :(", 10
len_comp_won		equ	$-comp_won_msg

futMov:			db	0
	
scoreBoard:
	db	0		;row0 (index 0-3)
	db	0		;row1 (index 4-7)
	db	0		;row2 (index 8-11)
	db	0		;row3 (index 12-15)
	db	0		;col0 (index 0, 4, 8, 12)
	db	0		;col1 (index 1, 5, 9, 13)
	db	0		;col2 (index 2, 6, 10, 14)
	db	0		;col3 (index 3, 7, 11, 15)
	db	0		;diag (index 0, 5, 10, 15)
	db	0		;antidiag (index 3, 6, 9, 12)
	db	11		;end of array marker
	
	section .text
	global	checkWinner
	global	clearScoreBoard
	global	getFutureMove
	
checkWinner:
	;; the index -> rdi
	;; character most recently played -> rsi
	;; scoreBoard -> rdx
	;; to turn index (i) into an (x, y) coordinate:
	;; x = column = i % 4
	;; y = row = i / width (integer division)

	call	check_columns
	call	check_rows
	
	;; special case for diagonals
	call	diagonals
	ret

check_columns:
	cmp	rdi, 0
	je	col0
	cmp	rdi, 1
	je	col1
	cmp	rdi, 2
	je	col2
	cmp	rdi, 3
	je	col3
	cmp	rdi, 4
	je	col0
	cmp	rdi, 5
	je	col1
	cmp	rdi, 6
	je	col2
	cmp	rdi, 7
	je	col3
	cmp	rdi, 8
	je	col0
	cmp	rdi, 9
	je	col1
	cmp	rdi, 10
	je	col2
	cmp	rdi, 11
	je	col3
	cmp	rdi, 12
	je	col0
	cmp	rdi, 13
	je	col1
	cmp	rdi, 14
	je	col2
	cmp	rdi, 15
	je	col3
	ret

check_rows:
	cmp	rdi, 0
	je	row0
	cmp	rdi, 1
	je	row0
	cmp	rdi, 2
	je	row0
	cmp	rdi, 3
	je	row0
	cmp	rdi, 4
	je	row1
	cmp	rdi, 5
	je	row1
	cmp	rdi, 6
	je	row1
	cmp	rdi, 7
	je	row1
	cmp	rdi, 8
	je	row2
	cmp	rdi, 9
	je	row2
	cmp	rdi, 10
	je	row2
	cmp	rdi, 11
	je	row2
	cmp	rdi, 12
	je	row3
	cmp	rdi, 13
	je	row3
	cmp	rdi, 14
	je	row3
	cmp	rdi, 15
	je	row3
	ret
	
diagonals:
	cmp     rdi, 0
	je      diag
	cmp     rdi, 5
	je      diag
	cmp     rdi, 10
	je      diag
	cmp     rdi, 15
	je      diag

	cmp     rdi, 3
	je      antidiag
	cmp     rdi, 6
	je      antidiag
	cmp     rdi, 9
	je      antidiag
	cmp     rdi, 12
	je      antidiag
	ret
	
row0:
	mov     rdx, scoreBoard

	add     rdx, 0
	cmp     rsi, 'o'
	je      addO
	cmp     rsi, 'x'
	je      addX
	ret

row1:
	mov     rdx, scoreBoard

	add     rdx, 1
	cmp     rsi, 'o'
	je      addO
	cmp     rsi, 'x'
	je      addX
	ret

row2:
	mov     rdx, scoreBoard

	add     rdx, 2
	cmp     rsi, 'o'
	je      addO
	cmp     rsi, 'x'
	je      addX
	ret

row3:
	mov     rdx, scoreBoard

	add     rdx, 3
	cmp     rsi, 'o'
	je      addO
	cmp     rsi, 'x'
	je      addX
	ret

col0:
	mov     rdx, scoreBoard

	add     rdx, 4
	cmp     rsi, 'o'
	je      addO
	cmp     rsi, 'x'
	je      addX
	ret

col1:
	mov     rdx, scoreBoard

	add     rdx, 5
	cmp     rsi, 'o'
	je      addO
	cmp     rsi, 'x'
	je      addX
	ret

col2:
	mov     rdx, scoreBoard

	add     rdx, 6
	cmp     rsi, 'o'
	je      addO
	cmp     rsi, 'x'
	je      addX
	ret

col3:
	mov     rdx, scoreBoard

	add     rdx, 7
	cmp     rsi, 'o'
	je      addO
	cmp     rsi, 'x'
	je      addX
	ret
	
diag:
	;; add one to diag1 in point array
	;; load scoreBoard into rdx
	mov	rdx, scoreBoard
	;; index 8 is diag
	add	rdx, 8
	cmp	rsi, 'o'
	je	addO
	cmp	rsi, 'x'
	je	addX
	ret

antidiag:
	mov	rdx, scoreBoard
	add	rdx, 9

	cmp	rsi, 'o'
	je	addO
	cmp	rsi, 'x'
	je	addX
	ret
	
addO:
	;; expecting: rdx -> correct index of scoreBoard
	add	byte[rdx], -1

	mov	rdx, scoreBoard
	jmp	scanBoard
	ret

addX:
	;; expecting: rdx -> correct index of scoreBoard
	add	byte[rdx], 1

	mov	rdx, scoreBoard
	jmp	scanBoard
	ret

scanBoard:
	cmp	byte[rdx], 4
	je	playerWon

	cmp	byte[rdx], -4
	je	compWon

	inc 	rdx
	cmp	byte[rdx], 11		;end of array marker
	jne 	scanBoard
	ret

playerWon:
	mov     rax, 1
	mov     rdi, 1
	mov     rsi, player_won_msg
	mov     rdx, len_play_won
	syscall
	
	call    main
	ret

compWon:
	mov     rax, 1
	mov     rdi, 1
	mov     rsi, comp_won_msg
	mov     rdx, len_comp_won
	syscall
	
	call    main
	ret
	
clearScoreBoard:
	mov	rdx, scoreBoard
	call	clearLoop
	ret

clearLoop:
	mov	byte[rdx], 0
	inc	rdx
	cmp	byte[rdx], 11
	jne	clearLoop
	ret

getFutureMove:
	;; subroutine which returns the index of an score element in scoreBoard which contains 3. This would indicate the user is to win next time they play
	mov	rdx, scoreBoard
	mov	rax, 0
	call	getFutMovLoop
	;; index will be returned in rax, or will be 11 if no score of 3 is found
	ret

getFutMovLoop:
	cmp	byte[rdx], 3
	je	foundFutMov

	inc 	rdx
	add	rax, 1
	cmp	byte[rdx], 11
	je	noFutMov
	;; otherwise loop back through
	cmp	byte[rdx], 11
	jne	getFutMovLoop
	ret

foundFutMov:
	;; current position of rax is our index
	ret

noFutMov:
	;; no future move to report, set rax to 11 and return
	mov	rax, 11
	ret
	
