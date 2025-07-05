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
      INTEGER I, ERROR, IN, OUT
      LOGICAL INPUTDATA, SHOWPROMPT, STEP, TRACE
      COMMON /IOUNITS/ IN, OUT
      COMMON /OPMODE/ INPUTDATA, SHOWPROMPT, STEP, TRACE
      DATA ERROR /0/, IN /5/, OUT /6/, STATE /0/
      DATA INPUTDATA /.FALSE./, SHOWPROMPT /.TRUE./, STEP /.FALSE./,
     1TRACE /.FALSE./

C *** MESSAGES ***
1000  FORMAT(3HTM>)
1001  FORMAT(21HAlanZ80 v0.1 for CP/M)
1002  FORMAT(47HImplementation of the Turing machine in FORTRAN)
1003  FORMAT(42H(C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>)
1004  FORMAT(18HLicence: EUPL v1.2)
1005  FORMAT(35H- Read program from standard input.)
1006  FORMAT(24H- Reading is successful.)
1007  FORMAT(50H- Run Turing machine with following configuration:)
1008  FORMAT(1H_)
1009  FORMAT(1H_)
1010  FORMAT(1H_)
1011  FORMAT(1H_)
1012  FORMAT(1H_)

C *** ERROR MESSAGES ***
1101  FORMAT(31H  Paragraph PROG is not closed!)
1102  FORMAT(31H  Paragraph CARD is not closed!)
1103  FORMAT(40H  Optional paragraph TAPE is not closed!)
1104  FORMAT(40H  Optional paragraph COMM is not closed!)
1201  FORMAT(1H_)
1202  FORMAT(1H_)
1203  FORMAT(1H_)
1204  FORMAT(1H_)

C *** PRINT HEADER ***
      WRITE(OUT, 1001)
      WRITE(OUT, 1002)
      WRITE(OUT, 1003)
      WRITE(OUT, 1004)

C *** READ PROGRAM FROM STANDARD INPUT ***
      WRITE(OUT, 1005)
      ERROR = INTERPRETER()
      IF (ERROR .GT. 0) GOTO 97
      WRITE(OUT, 1006)
      IF (INPUTDATA) CALL PROMPT

C *** RUN TURING-MACHINE ***
      WRITE(OUT, 1007)

C     (...)  
      ERROR = MACHINE(SHOWPROMPT, STEP, TRACE)
      IF (ERROR .GT. 0) GOTO 98
      WRITE(OUT, 1008)
      GOTO 99

C *** PROGRAM READ ERROR ***1
97    IF (ERROR .EQ. 1) WRITE(OUT, 1101)
      IF (ERROR .EQ. 2) WRITE(OUT, 1102)
      IF (ERROR .EQ. 3) WRITE(OUT, 1103)
      IF (ERROR .EQ. 4) WRITE(OUT, 1104)

C *** PROGRAM RUN ERROR ***
98    IF (ERROR .EQ. 1) WRITE(OUT, 1201)
      IF (ERROR .EQ. 2) WRITE(OUT, 1202)
      IF (ERROR .EQ. 3) WRITE(OUT, 1203)
      IF (ERROR .EQ. 4) WRITE(OUT, 1204)

C *** END OF PROGRAM ***
99    STOP
      END

C *** SEGMENT PROMPT ***
      SUBROUTINE PROMPT()
C     (...)
      RETURN
      END
     
C *** SEGMENT INTERPRETER ***
      INTEGER FUNCTION INTERPRETER()
      CHARACTER*4 COL1
      CHARACTER*80 COL2, LINE
      INTEGER IN, OUT, ERROR
      LOGICAL INPUTDATA, SHOWPROMPT, STEP, TRACE
      LOGICAL BPROG, BCARD, BTAPE, BCOMM, EPROG, ECARD, ETAPE, ECOMM
      COMMON /OPMODE/ INPUTDATA, SHOWPROMPT, STEP, TRACE
      COMMON /IOUNITS/ IN, OUT
      DATA ERROR /0/
      DATA BPROG /.FALSE./, BCARD /.FALSE./, BTAPE /.FALSE./,
     1BCOMM /.FALSE./ EPROG /.FALSE./, ECARD /.FALSE./,
     2ETAPE /.FALSE./, ECOMM /.FALSE./ 

C     (HERE: remove space and tab chars from beginnig of line)
C     (HERE: remove double space and tab chars)

110   CONTINUE
C     READ LINE TO BUFFER
      READ(IN, 130, END = 120) LINE
C     INTERPRETING LINE      
      READ(LINE, 140) COL1, COL2
140   FORMAT(A4,1X,A) 
      IF (COL1 .EQ. 'PROG') BPROG = .TRUE.
      IF ((COL1 .EQ. 'CARD') .AND. (COL2 .EQ. 'BEGIN')) BCARD = .TRUE.
      IF ((COL1 .EQ. 'TAPE') .AND. (COL2 .EQ. 'BEGIN')) BTAPE = .TRUE.
      IF ((COL1 .EQ. 'COMM') .AND. (COL2 .EQ. 'BEGIN')) BCOMM = .TRUE.
      IF ((COL1 .EQ. 'PROG') .AND. (COL2 .EQ. 'END')) EPROG = .TRUE.
      IF ((COL1 .EQ. 'CARD') .AND. (COL2 .EQ. 'END')) ECARD = .TRUE.
      IF ((COL1 .EQ. 'TAPE') .AND. (COL2 .EQ. 'END')) ETAPE = .TRUE.
      IF ((COL1 .EQ. 'COMM') .AND. (COL2 .EQ. 'END')) ECOMM = .TRUE.

C     (...)
      GOTO 110
120   CONTINUE
130   FORMAT(A80)
      IF (BPROG .AND. .NOT. EPROG ) ERROR = 1
      IF (BCARD .AND. .NOT. ECARD ) ERROR = 2
      IF (BTAPE .AND. .NOT. ETAPE ) ERROR = 3
      IF (BCOMM .AND. .NOT. ECOMM ) ERROR = 4

C     (...)
      INTERPRETER = ERROR
      RETURN
      END

C *** SEGMENT TURING-MACHINE ***
      INTEGER FUNCTION MACHINE(SP, ST, TR)
      LOGICAL SP, ST, TR

C     (...)
      MACHINE = 0
      RETURN
      END
