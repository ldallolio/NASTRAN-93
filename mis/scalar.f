      SUBROUTINE SCALAR        
C        
C     CONVERTS MATRIX ELEMENT TO PARAMETER        
C        
C     SCALAR   MTX//C,N,ROW/C,N,COL/V,N,RSP/V,N,RDP/V,N,SPLX/V,N,DPLX $ 
C        
C     INPUT GINO FILE        
C       MTX = ANY MATRIX, S.P. OR D.P.; REAL OR COMPLEX        
C     OUTPUT GINO FILE        
C       NONE        
C     INPUT PARAMETERS        
C       ROW, COL = ROW AND COLUMN OF MTX (DEFAULT ARE 1,1)        
C     OUTPUT PARAMETERS        
C       RSP  = VALUE OF MTX(ROW,COL), REAL SINGLE PRECISION        
C       RDP  = VALUE OF MTX(ROW,COL), REAL DOUBLE PRECISION        
C       SPLX = VALUE OF MTX(ROW,COL), S.P. COMPLEX        
C       DPLX = VALUE OF MTX(ROW,COL), D.P. COMPLEX        
C        
C     ORIGINALY WRITTEN BY R. MITCHELL, GSFC, NOV. 1972        
C        
C     COMPLETELY REWRITTEN BY G.CHAN/UNISYS IN JUNE 1988, SUCH THAT THE 
C     OUTPUT PARAMETERS ARE SAVED CORRECTLY ACCORDING TO THEIR PRECISION
C     TYPES. (THE PRTPARM MODULE WILL BE ABLE TO PRINT THEM OUT        
C     CORRECTLY.) PLUS IMPROVED MESSAGES (WHICH CAN BE SUPPRESSED BY    
C     DIAG 37)        
C        
      IMPLICIT INTEGER (A-Z)        
      LOGICAL          NOPRT        
      INTEGER          NAME(2),IA(7),FNM(2),PNM(2)        
      REAL             RSP,SPLX,A,VPS(1),SP(4)        
      DOUBLE PRECISION DA(2),RDP,DPLX(2),DP(2)        
      CHARACTER        UFM*23,UWM*25,UIM*29,TYPE(4)*10        
      COMMON /XMSSG /  UFM,UWM,UIM        
      COMMON /XVPS  /  IVPS(1)        
      COMMON /SYSTEM/  SYSBUF,NOUT        
      COMMON /ZNTPKX/  A(4),II,EOL,EOR        
CZZ   COMMON /ZZSCAL/  CORE(1)        
      COMMON /ZZZZZZ/  CORE(1)        
      COMMON /BLANK /  BK(1),ROW,COL,RSP,R2(2),SPLX(2),D4(4)        
      EQUIVALENCE      (R2(1),RDP),(D4(1),DPLX(1)),(IA(2),NCOL),        
     1                 (IA(3),NROW),(IA(4),FORM),(IA(5),PREC),        
     2                 (DA(1),A(1)),(DP(1),SP(1)),(VPS(1),IVPS(1))      
      DATA  IN1,NAME/  101, 4HSCAL,4HAR  / , FIRST / 12 /        
      DATA  TYPE    /  'S.P. REAL ' ,    'D.P. REAL '   ,        
     1                 'S.P. CMPLX' ,    'D.P. CMPLX'   /        
C        
C     SUPPRESS ALL SCALAR MESSAGES IF DIAG 37 IS ON        
C        
      CALL SSWTCH (37,I)        
      NOPRT = I .EQ. 1        
C        
C     MOVE VARIALBES IN /BLANK/ BY ONE WORD TO GET BY WORD BOUNDARY     
C     ALIGNMENT SITUATION        
C        
      J = 12        
      DO 10 I = 1,11        
      BK(J) = BK(J-1)        
   10 J = J - 1        
C        
C     INITIALIZATION        
C        
      LCORE = KORSZ(CORE)        
      IBUF  = LCORE - SYSBUF + 1        
      IF (IBUF .LT. 1) GO TO 400        
      RSP     = 0.        
      SPLX(1) = 0.        
      SPLX(2) = 0.        
      RDP     = 0.D0        
      DPLX(1) = 0.D0        
      DPLX(2) = 0.D0        
      DP(1)   = 0.D0        
      DP(2)   = 0.D0        
      CALL FNAME (IN1,FNM)        
      CALL PAGE2 (FIRST)        
      FIRST   = 3        
C        
C     GET STATUS OF INPUT MATRIX        
C     CHECK FOR PURGED INPUT OR OUT OF RANGE INPUT PARAMETERS        
C        
      IA(1) = IN1        
      CALL RDTRL (IA)        
      IF (IA(1).LT.   0) GO TO 410        
      IF (ROW .GT. NROW) GO TO 420        
C        
      GO TO (20,20,40,60,70,20,50,30), FORM        
C     SQUARE, RECTANGULAR OR SYMMETRIC MATRIX        
C        
   20 IF (COL .GT. NCOL) GO TO 420        
      GO TO 100        
C        
C     IDENTITY MATRIX        
C        
   30 IF (ROW .NE. COL) GO TO 200        
      RSP = 1.0        
      RDP = 1.D0        
      SPLX(1) = 1.        
      DPLX(1) = 1.D0        
      GO TO 200        
C        
C     DIAGONAL MATRIX        
C        
   40 IF (ROW .NE.  COL) GO TO 200        
      IF (COL .GT. NROW) GO TO 420        
C     SET COL TO 1 FOR SPECIAL DIAGONAL FORMAT        
      COL = 1        
      GO TO 100        
C        
C     ROW VECTOR        
C     SWITCH ROW AND COLUMN FOR PROPER INDEXING        
C        
   50 ROW = COL        
      COL = 1        
      GO TO 100        
C        
C     LOWER TRIANGULAR MATRIX (UPPER HALF= 0)        
C        
   60 IF (COL-ROW) 100,100,200        
C        
C     UPPER TRIANGULAR MATRIX (LOWER HALF= 0)        
C        
   70 IF (ROW-COL) 100,100,200        
C        
C     OPEN INPUT FILE AND SKIP HEADER RECORD AND UNINTERSTING COLUMNS   
C        
  100 CALL OPEN (*410,IN1,CORE(IBUF),0)        
      CALL SKPREC (IN1,COL)        
C        
C     READ AND SEARCH COLUMN CONTAINING DESIRED ELEMENT.        
C     RECALL THAT DEFAULT VALUE WAS SET TO ZERO        
C        
      CALL INTPK (*200,IN1,0,PREC,0)        
C        
C     FETCH ONE ELEMENT        
C     CHECK FOR DESIRED ELEMENT        
C     IF INDEX HIGHER, IT MEANS ELEMENT WAS 0.        
C        
  110 CALL ZNTPKI        
C     IF (EOR .EQ. 1) GO TO 160        
      IF (II-ROW) 120,130,200        
C        
C     CHECK FOR LAST NON-ZERO ELEMENT IN COLUMN.        
C        
  120 IF (EOL) 110,110,200        
C        
C     MOVE VALUES TO OUTPUT PARAMETER AREA.        
C     CHECK PRECISION OF INPUT VALUE.        
C        
  130 GO TO (140,150,170,180), PREC        
C        
  140 RSP = A(1)        
      RDP = DBLE(RSP)        
      GO TO 160        
C        
  150 RDP = DA(1)        
      RSP = SNGL(RDP)        
  160 SPLX(1) = RSP        
      DPLX(1) = RDP        
      GO TO 200        
C        
  170 SPLX(1) = A(1)        
      SPLX(2) = A(2)        
      DPLX(1) = DBLE(SPLX(1))        
      DPLX(2) = DBLE(SPLX(2))        
      GO TO 190        
C        
  180 DPLX(1) = DA(1)        
      DPLX(2) = DA(2)        
      SPLX(1) = SNGL(DPLX(1))        
      SPLX(2) = SNGL(DPLX(2))        
  190 RSP = 0.0        
      RDP = 0.D0        
C        
C     MOVE VALUES TO OUTPUT PARAMETERS AS REQUESTED BY USER, AND        
C     SAVE PARAMETERS        
C        
  200 IF (NOPRT) GO TO 215        
      CALL PAGE2 (3)        
      WRITE  (NOUT,210) UIM        
  210 FORMAT (A29,' FROM SCALAR MODULE -', /5X,        
     1        '(ALL SCALAR MESSAGES CAN BE SUPPRESSED BY DIAG 37)')     
  215 CALL FNDPAR (-3,J)        
      IF (J .LE. 0) GO TO 260        
      PNM(1) = IVPS(J-3)        
      PNM(2) = IVPS(J-2)        
      IF (PREC .GE. 3) GO TO 240        
      VPS(J) = RSP        
      IF (NOPRT) GO TO 260        
      WRITE (NOUT,220) RSP,PNM        
  220 FORMAT (73X,E15.8,4H  = ,2A4)        
      WRITE (NOUT,230) ROW,COL,TYPE(PREC),FNM        
  230 FORMAT (1H+,4X,'ELEMENT (',I5,'-ROW,',I5,'-COL) OF ',A10,' INPUT',
     1       ' FILE ',2A4,2H =)        
      GO TO 260        
  240 WRITE  (NOUT,250) UWM,PNM        
  250 FORMAT (A25,' - INVALID OUTPUT REQUEST.', /5X,'ORIG. ELEM. IN ',  
     1       'COMPLEX FORM. OUTPUT PARAMETER ',2A4,' NOT SAVED)',/)     
  260 CALL FNDPAR (-4,J)        
      IF (J .LE. 0) GO TO 290        
      PNM(1)   = IVPS(J-3)        
      PNM(2)   = IVPS(J-2)        
      IF (PREC .GE. 3) GO TO 280        
      DP(1)    = RDP        
      VPS(J  ) = SP(1)        
      VPS(J+1) = SP(2)        
      IF (NOPRT) GO TO 290        
      WRITE (NOUT,270) RDP,PNM        
  270 FORMAT (73X,D15.8,4H  = ,2A4)        
      WRITE (NOUT,230) ROW,COL,TYPE(PREC),FNM        
      GO TO 290        
  280 WRITE (NOUT,250) UWM,PNM        
  290 CALL FNDPAR (-5,J)        
      IF (J .LE. 0) GO TO 310        
      VPS(J  ) = SPLX(1)        
      VPS(J+1) = SPLX(2)        
      PNM(1)   = IVPS(J-3)        
      PNM(2)   = IVPS(J-2)        
      IF (NOPRT) GO TO 310        
      WRITE (NOUT,300) SPLX,PNM        
  300 FORMAT (73X,1H(,E15.8,1H,,E15.8,1H),4H  = ,2A4)        
      WRITE (NOUT,230) ROW,COL,TYPE(PREC),FNM        
  310 CALL FNDPAR (-6,J)        
      IF (J .LE. 0) GO TO 330        
      DP(1)    = DPLX(1)        
      DP(2)    = DPLX(2)        
      VPS(J  ) = SP(1)        
      VPS(J+1) = SP(2)        
      VPS(J+2) = SP(3)        
      VPS(J+3) = SP(4)        
      PNM(1)   = IVPS(J-3)        
      PNM(2)   = IVPS(J-2)        
      IF (NOPRT) GO TO 330        
      WRITE (NOUT,320) DPLX,PNM        
  320 FORMAT (73X,1H(,D15.8,1H,,D15.8,1H),4H  = ,2A4)        
      WRITE (NOUT,230) ROW,COL,TYPE(PREC),FNM        
C        
C     CLOSE INPUT UNIT AND RETURN        
C        
  330 CALL CLOSE (IN1,1)        
      RETURN        
C        
C     ERROR MESSAGES, SET THEM ALL TO NON-FATAL        
C        
C     NOT ENOUGH CORE FOR GINO BUFFER        
C        
  400 J = 8        
      GO TO 430        
C        
C     INPUT FILE ERROR        
C        
  410 J = 1        
      GO TO 430        
C        
C     INVALID ROW OR COLUMN NUMBER        
C        
  420 J = 7        
C        
  430 CALL MESAGE (J,IN1,NAME)        
      RETURN        
C        
      END        
