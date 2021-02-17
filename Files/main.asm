;;  Description: this is the main file for the tictactoe game. In main, we display the starting menu and take in user input to decide what level of computer opponent they want to play aginast.

	extern compEasy
	extern compHard
	extern checkWinner
	
	section .data
new_line	db	10
welcome_msg:	db	"Welcome to Tic-Tac-Toe!", 10
len_wel		equ	$-welcome_msg
	
main_menu:	db	"Main Menu:", 10, "a. Easy Mode", 10, "b. Hard Mode", 10, "q. quit", 10
len_main	equ	$-main_menu

wrong_in_msg:	db	"This input does not match a menu option!", 10
len_wrong	equ	$-wrong_in_msg

egg_msg:	db	"Congratulations! You activated the Easter egg!", 10
len_egg_msg	equ	$-egg_msg

eggCount:	db	0
	
	section .bss
input		resb	16
	
	section .text
	global main
main:
	;; welcome message
	mov	rsi, welcome_msg
	mov	rdx, len_wel
	call	print_out

	;;     print menu
	mov     rsi, main_menu
	mov     rdx, len_main
	call    print_out

	;;     get user input
	mov     rax, 0
	mov     rdi, 0
	mov     rsi, input
	mov     rdx, 16
	syscall

	cmp     byte[input], "a"
	je      compEasy

	cmp     byte[input], "b"
	je      compHard
	
	cmp     byte[input], "q"
	je      exit

	;; if we get to here, input was incorrect
	call	incorrect
	
	jmp     main
	
exit:
	mov	rax,60
	xor	rdi, rdi
	syscall

print_out:
	mov     rax, 1
	mov     rdi, 1
	syscall	
	ret

incorrect:
	mov	rsi, wrong_in_msg
	mov	rdx, len_wrong
	call	print_out

	cmp     byte[input], "c"
	je      easterEgg
	ret

easterEgg:
	mov	rax, [eggCount]
	add	rax, 1
	mov	[eggCount], rax

	cmp	rax, 4
	je	doEgg
	ret

doEgg:
	mov	rsi, egg_msg
	mov	rdx, len_egg_msg
	call	print_out
	ret
