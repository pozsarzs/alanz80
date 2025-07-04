PROGRAM NUMSWAP

; Example program file for AlanZ80 Turing machine implementation
; The program swaps the numbers, prints the steps, and then exits.

CONF
  D  Swapping numbers back and forth
  S  0123456789
 |Q| 2
END CONF

CARD
  01 01R01 12R01 23R01 34R01 45R01 56R01 67R01 78R01 89R01 90R01 __S02
  02 09L02 10L02 21L02 32L02 43L02 54L02 65L02 76L02 87L02 98L02 __S00
END CARD

TAPE
  DATA 0123456789
  POS 1   
END TAPE

CMD
  TRACE ON
  NOPROMPT
END CMD

END PROGRAM
