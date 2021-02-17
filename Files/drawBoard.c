#include <stdio.h>

void drawBoard (char board[]) {
  /*convert int array to array of chars*/
  /*for(int i = 0; i < 16; i++) {
    if (in[i] == 0) {
      board[i] = ' ';
    }
    else if (in[i] == 1) {
      board[i] = 'x';
    }
    else if (in[i] == 2) {
      board[i] = 'o';
    }
  }
    */

  printf("%c|%c|%c|%c\n", board[0], board[1], board[2], board[3]);
  printf("-------\n");
  printf("%c%c%c%c%c%c%c\n", board[4], '|', board[5], '|', board[6], '|', board[7]);
  printf("-------\n");
  printf("%c%c%c%c%c%c%c\n", board[8], '|', board[9], '|', board[10], '|', board[11]);
  printf("-------\n");
  printf("%c%c%c%c%c%c%c\n", board[12], '|', board[13], '|', board[14], '|', board[15]);
  
  return;
}
