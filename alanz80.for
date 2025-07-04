C +--------------------------------------------------------------------+
C | AlanZ80 v0.1 * Turing machine                                      |
C | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>               |
C | alanz80.for                                                        |
C | Main program (Microsoft Fortan-80)                                 |
C +--------------------------------------------------------------------+
C
C This program is free software: you can redistribute it and/or modify
C it under the terms of the European Union Public License 1.2 version.
C
C This program is distributed in the hope that it will be useful, but
C WITHOUT ANY WARRANTY; without even the implied warranty of
C MERCHANTABILITY or FITNESS A PARTICULAR PURPOSE.

C *** MAIN SEGMENT ***
      PROGRAM ALANZ80

C *** VARIABLES AND CONSTANTS ***
      CHARACTER*80 LINE
      INTEGER I, ERROR, IN, OUT
      COMMON /LINEBUFFER/ LINE
      COMMON /IOUNITS/ IN, OUT
      DATA IN /5/, OUT /6/

C *** MESSAGES ***
1000  FORMAT(3HTM>)
1001  FORMAT(21HAlanZ80 v0.1 for CP/M)
1002  FORMAT(47HImplementation of the Turing machine in FORTRAN)
1003  FORMAT(42H(C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>)
1004  FORMAT(18HLicence: EUPL v1.2)
1005  FORMAT(35H- Load program from standard input.)
1006  FORMAT(49H- The loading is complete and contains no errors.)
1007  FORMAT(1H_)
1008  FORMAT(1H_)
1009  FORMAT(1H_)
1010  FORMAT(1H_)
1011  FORMAT(1H_)
1012  FORMAT(1H_)

C *** PRINT HEADER ***
      WRITE(OUT, 1001)
      WRITE(OUT, 1002)
      WRITE(OUT, 1003)
      WRITE(OUT, 1004)

C *** LOAD PROGRAM FROM STANDARD INPUT ***
      WRITE(OUT, 1005)
10    CONTINUE
      READ(IN, 30, END = 20) LINE
      ERROR = INTERPRETER()
      IF (ERROR.GT.0) GOTO 98
      GOTO 10
20    CONTINUE
30    FORMAT(A80)
      WRITE(OUT, 1006)
    
C     (...)  

C *** LOAD ERROR ***
98    IF (ERROR.EQ.1) WRITE(OUT, 1007)
      IF (ERROR.EQ.1) WRITE(OUT, 1008)
      IF (ERROR.EQ.1) WRITE(OUT, 1009)
      IF (ERROR.EQ.1) WRITE(OUT, 1010)
      IF (ERROR.EQ.1) WRITE(OUT, 1011)
      IF (ERROR.EQ.1) WRITE(OUT, 1012)

C *** END OF PROGRAM ***
99    STOP
      END
      
C *** SEGMENT INTERPRETER ***
      INTEGER FUNCTION INTERPRETER()
      CHARACTER*80 LINE
      INTEGER I, IN, OUT
      COMMON /IOUNITS/ IN, OUT
      COMMON /LINEBUFFER/ LINE
      INTEGER IE
      DATA IE/0/

      write(OUT,55) LINE
55    FORMAT(A80) 

      INTERPRETER=IE
      RETURN
      END
