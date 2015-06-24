      SUBROUTINE SETINP        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL         RSHIFT,COMPLF        
      REAL             FWRD        
      DOUBLE PRECISION DWRD        
      DIMENSION        NAME(2),EL(1),GP(1),CARD(65),TYP(100),AWRD(2),   
     1                 PCARD(20),POCARD(200)        
      CHARACTER        UFM*23,UWM*25,UIM*29        
      COMMON /XMSSG /  UFM,UWM,UIM        
      COMMON /BLANK /  SKP11,NSETS,SKP12(8),PCDB,SKP2(9),        
     1                 MERR,PLOT,MSETID,SKP3(7),MSET,IPCDB        
      COMMON /SYSTEM/  BUFSIZ,NOUT,NOGO,NIN,NSK(81),INTR        
      COMMON /GPTA1 /  NTYPES,LAST,INCR,NE(1)        
CZZ   COMMON /ZZPSET/  X(1)        
      COMMON /ZZZZZZ/  X(1)        
      EQUIVALENCE      (X(1),EL(1),GP(1))        
      EQUIVALENCE      (WORD,AWRD(1),IWRD,FWRD,DWRD)        
      DATA    INPREW,  OUTREW,REW,NOREW,EOR / 0, 1, 1, 3, 1000000      /
      DATA    BLNK  ,  STOP,GO,NAME /4H    ,4HSTOP,4HGO  ,4H SET,3HINP /
      DATA    SET   ,  INCL,  EXCL,  ELEM,  GRID,  POIN,  EXCE,  TO    /
     1        3HSET ,  4HINCL,4HEXCL,4HELEM,4HGRID,4HPOIN,4HEXCE,2HTO  /
      DATA    THRU  ,  ALL,    ILXX /4HTHRU,3HALL, 2HXX /        
C        
      CALL DELSET        
      B1 = KORSZ(X) - 5*BUFSIZ + 1        
      B2 = B1 + BUFSIZ        
      B3 = B2 + BUFSIZ        
      B4 = B3 + BUFSIZ        
      NOGO  = 0        
      ORG   = 0        
      PORG  = -1        
      ALLON = COMPLF(0)        
      POCARD(200) = RSHIFT(ALLON,1)        
      ENCARD = POCARD(200)        
C        
C     OPEN ALL NECESSARY FILES        
C        
      IOREW = INPREW        
      IF (INTR .LE. 0) GO TO 10        
      PCDB  = IPCDB        
      IOREW = OUTREW        
   10 CALL OPEN (*210,PCDB,X(B1),IOREW)        
      IF (INTR .LE. 0) GO TO 50        
C        
      WRITE (NOUT,270)        
   20 DO 25 J = 1,20        
   25 PCARD(J) = BLNK        
      DO 26 J = 1,199        
   26 POCARD(J) = BLNK        
      CALL XREAD (*28,PCARD)        
      IF (PCARD(1) .EQ. STOP) GO TO 220        
      IF (PCARD(1) .EQ.   GO) GO TO 40        
      CALL XRCARD (POCARD,199,PCARD)        
      CALL IFP1PC (1,ICONT,POCARD,ORG,PORG)        
      IF (NOGO .EQ. 0) GO TO 30        
      NOGO = 0        
   28 WRITE (NOUT,300)        
      GO TO 20        
   30 WRITE (1,290) PCARD        
      IE = 1        
      DO 33 J = 1,199        
      IF (POCARD(J) .NE. 0) GO TO 32        
      DO 31 JC = 1,5        
   31 IF (POCARD(J+JC) .NE. BLNK) GO TO 32        
      NW = J        
      GO TO 34        
   32 IF (POCARD(J) .NE. ENCARD) GO TO 33        
      NW = J        
      GO TO 34        
   33 CONTINUE        
      NW = 80        
   34 CALL WRITE (PCDB,POCARD,NW,IE)        
      GO TO 20        
   40 CALL CLOSE (PCDB,REW)        
      IF (INTR .GT. 10) NOUT = 1        
      CALL OPEN (*210,PCDB,X(B1),INPREW)        
   50 IF (INTR .LE. 0) CALL FREAD (PCDB,0,-2,1)        
      CALL GOPEN (PLOT,X(B2),OUTREW)        
      CALL GOPEN (MSET,X(B3),OUTREW)        
      CALL GOPEN (MSETID,X(B4),OUTREW)        
      CALL RDMODX (PCDB,MODE,WORD)        
C        
C     READ MODE FLAG.  SHOULD BE ALPHABETIC        
C        
  100 CALL READ (*200,*200,PCDB,MODE,1,0,I)        
      IF (MODE) 101,100,102        
  101 I = 1        
      IF (MODE .EQ. -4) I = 2        
      CALL FREAD (PCDB,0,-I,0)        
      GO TO 100        
  102 IF (MODE .LT. EOR) GO TO 103        
      CALL FREAD (PCDB,0,0,1)        
      GO TO 100        
  103 MODE = MODE + 1        
      CALL RDWORD (MODE,WORD)        
      CALL RDWORD (MODE,WORD)        
      IF (WORD.EQ.SET .AND. MODE.EQ.0) GO TO 115        
C        
C     THIS CARD IS A PLOT CONTROL CARD        
C        
  105 CALL BCKREC (PCDB)        
  106 CALL READ (*200,*110,PCDB,CARD,65,1,I)        
      WRITE  (NOUT,108)        
  108 FORMAT ('  ARRAY CARD OF 65 TOO SAMLL')        
      CALL MESAGE (-37,0,NAME)        
  110 CALL WRITE (PLOT,CARD,I,1)        
      IF (CARD(I)) 100,106,100        
C        
C     THIS CARD DEFINES A NEW SET        
C        
  115 ASSIGN 116 TO TRA        
      CALL RDMODE (*250,*105,*100,MODE,WORD)        
  116 SETID = IWRD        
      NELX  = 0        
      NGPX  = B1        
      NT    = 0        
      XX    = 1        
      ELGP  = 0        
C        
      IF (MODE .LE. 0) CALL RDMODE (*136,*121,*175,MODE,WORD)        
  121 CALL RDWORD (MODE,WORD)        
C        
C     CHECK FOR AN -INCLUDE- OR -EXCLUDE- CARD        
C        
  125 IF (WORD.NE.INCL .AND. WORD.NE.EXCL .AND. WORD.NE.EXCE) GO TO 128 
  126 IF (WORD .EQ. INCL) XX = 1        
      IF (WORD .EQ. EXCL) XX =-1        
      IF (WORD .EQ. EXCE) XX =-XX        
      IF (MODE.EQ.0) CALL RDMODE (*136,*127,*175,MODE,WORD)        
  127 CALL RDWORD (MODE,WORD)        
  128 IF (WORD .EQ. GRID) GO TO 131        
      IF (WORD .NE. ELEM) GO TO 147        
C        
C     ELEMENTS ARE TO BE INCLUDED OR EXCLUDED (BY ID OR TYPE)        
C        
      ELGP = 0        
      IF (MODE) 136,135,121        
C        
C     A LIST OF GRID POINTS IS TO BE INCLUDED OR EXCLUDED (PERTAIN ONLY 
C     TO DEFORMED PLOTS)        
C        
  131 IF (MODE .LE. 0) CALL RDMODE (*131,*132,*175,MODE,WORD)        
  132 CALL RDWORD (MODE,WORD)        
      IF (WORD.NE.POIN .OR. MODE.NE.0) GO TO 125        
      ELGP = 1        
C        
C     A LIST OF ELEMENT OR GRID POINT ID-S CAN BE EXPLICITLY LISTED, OR 
C     PREFERABLY A RANGE CAN BE SPECIFIED (SEPARATED BY THE WORD -TO-   
C     OR -THRU-)        
C        
  135 CALL RDMODE (*136,*121,*175,MODE,WORD)        
  136 ASSIGN 137 TO TRA        
      GO TO 250        
  137 IF (NELX+1 .GE. NGPX) CALL MESAGE (-8,0,NAME)        
      IF (ELGP .NE. 0) GO TO 138        
      NELX = NELX + 1        
      EL(NELX) = ISIGN(IWRD,XX)        
      GO TO 140        
  138 NGPX = NGPX - 1        
      GP(NGPX) = ISIGN(IWRD,XX)        
C        
  140 CALL RDMODE (*250,*141,*175,MODE,WORD)        
  141 CALL RDWORD (MODE,WORD)        
      IF (WORD.NE.TO .AND. WORD.NE.THRU) GO TO 125        
      IF (MODE .NE. 0) GO TO 125        
      ASSIGN 142 TO TRA        
      CALL RDMODE (*250,*125,*175,MODE,WORD)        
  142 IF (NELX+2 .GE. NGPX) CALL MESAGE (-8,0,NAME)        
      IF (ELGP .NE. 0) GO TO 143        
      EL(NELX+1) = TO        
      EL(NELX+2) = IWRD        
      NELX = NELX + 2        
      GO TO 135        
  143 GP(NGPX-1) = TO        
      GP(NGPX-2) = ISIGN(IWRD,XX)        
      NGPX = NGPX - 2        
      GO TO 135        
C        
C     AN ELEMENT TYPE CAN BE INCLUDED OR EXCLUDED        
C        
  145 IF (MODE .LE. 0) CALL RDMODE (*136,*146,*175,MODE,WORD)        
  146 CALL RDWORD (MODE,WORD)        
  147 IF (WORD.EQ.INCL .OR. WORD.EQ.EXCL .OR. WORD.EQ.EXCE) GO TO 126   
      IF (WORD.EQ.GRID .OR. WORD.EQ.ELEM) GO TO 128        
      IF (WORD .NE. ALL) GO TO 150        
      I  = NTYPES + 1        
  149 NT = NT + 2        
C        
C     SECOND WORD FOR EACH TYP LOCATES ELEMENT INCLUDE/EXCLUDE SEARCH   
C     POINTER.  ELEMENT ID-S GIVEN PRIOR TO NELX ARE SKIPPED        
C        
      TYP(NT-1) = ISIGN(I,XX)        
      TYP(NT  ) = NELX + 1        
      ELGP = 0        
      GO TO 145        
C        
  150 DO 151 I = 1,NTYPES        
      IDX = (I-1)*INCR        
C        
C     SKIP ELEMENTS WITH        
C       1 GRID        
C       SCALAR CONNECTIONS POSSIBLE        
C       SPECIAL PLOTTER MNEMONIC OF -XX-        
C        
      IF (NE(IDX+10).LE.1 .OR. NE(IDX+11).NE.0) GO TO 151        
      IF (NE(IDX+16) .EQ. ILXX) GO TO 151        
      IF (AWRD(1).EQ.NE(IDX+1) .AND. AWRD(2).EQ.NE(IDX+2)) GO TO 149    
  151 CONTINUE        
      WRITE  (NOUT,155) UFM,AWRD        
  155 FORMAT (A23,' 699,',2A4,' ELEMENT IS INVALID')        
      NOGO = 1        
      ELGP = 0        
      GO TO 145        
C        
C     A SET HAS BEEN COMPLETELY DEFINED.  FIRST, WRITE THE SET ID       
C        
  175 IF (NELX.EQ.0 .AND. NT.EQ.0) GO TO 100        
      CALL WRITE (MSETID,SETID,1,0)        
      CALL WRITE (MSET,SETID,1,0)        
C        
C     WRITE THE SET OF EXPICIT ELEMENT ID-S        
C        
      CALL WRITE (MSET,NELX,1,0)        
      CALL WRITE (MSET,EL,NELX,0)        
C        
C     DELETE ALL ELEMENT TYPE DUPLICATES + WRITE REMAINING ONES        
C        
      N = 0        
      IF (NT .EQ. 0) GO TO 178        
      DO 177 J = 1,NT,2        
      XX = TYP(J)        
      IF (XX .EQ. 0) GO TO 177        
      DO 176 I = J,NT,2        
      IF (I.EQ.J .OR. IABS(XX).NE.IABS(TYP(I))) GO TO 176        
C        
C     DELETE BOTH IF NEGATIVE OF OTHER        
C        
      IF (XX .EQ. -TYP(I)) TYP(J) = 0        
      TYP(I) = 0        
  176 CONTINUE        
      IF (TYP(J) .EQ. 0) GO TO 177        
      N = N + 2        
      TYP(N-1) = XX        
      TYP(N  ) = TYP(J+1)        
  177 CONTINUE        
  178 CALL WRITE (MSET,N,1,0)        
      CALL WRITE (MSET,TYP,N,0)        
C        
C     WRITE THE SET OF EXPLICIT GRID POINT ID-S        
C        
      N = B1 - NGPX        
      CALL WRITE (MSET,N,1,0)        
      CALL WRITE (MSET,GP(NGPX),N,1)        
      NSETS = NSETS + 1        
      GO TO 100        
C        
C     END OF -PCDB-        
C        
  200 CALL CLSTAB (MSET,REW)        
      CALL CLSTAB (PLOT,REW)        
      CALL CLSTAB (MSETID,NOREW)        
      CALL CLOSE  (PCDB,REW)        
      IF (NSETS .EQ. 0) WRITE (NOUT,205) UIM        
  205 FORMAT (A29,', NO SETS EXIST IN PLOT PACKAGE')        
      IF (NOGO .NE. 0) CALL MESAGE (-61,0,0)        
  210 RETURN        
  220 NOGO = 1        
      RETURN        
C        
C     READ AN INTEGER        
C        
  250 IF (MODE .EQ. -1) GO TO 260        
      IF (MODE .EQ. -4) IWRD = DWRD        
      IF (MODE .NE. -4) IWRD = FWRD        
  260 GO TO TRA, (116,137,142)        
C        
  270 FORMAT (' ENTER PLOT DEFINITION OR ''GO'' IF DONE.')        
  290 FORMAT (20A4)        
  300 FORMAT (' BAD CARD TRY AGIAN')        
      END        
