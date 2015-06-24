      SUBROUTINE SDCMM (Z,MSET,MSZE,MATRIX,USET,GPL,SIL,SUBNAM)        
C        
C     THIS ROUTINE WRITES THE EXTERNAL ID AND COMPONENT ID FOR VARIOUS  
C     MATRIX ERROR CONDITIONS.        
C     SCRATCH1 CONTAINS 3 WORDS/ERROR, EACH MESSAGE BEING 1 RECORD      
C         WORD 1 = COLUMN * 10 + ERROR CODE        
C         WORD 2 = INPUT DIAGONAL        
C         WORD 3 = OUTPUT DIAGONAL        
C     SUBROUTINE -MXCID- (NON-SUBSTRUCTURING) IS CALLED TO SUPPLY IDENT.
C     DATA FOR EACH COLUMN.  FOR SUBSTRUCTURING -MXCIDS- IS CALLED - IT 
C     RETURNS TWO WORDS/COLUMN PLUS THE BCD NAME OF THE SUBSTRUCTURES AT
C     THE START OF CORE.  IN EITHER CASE, THE 1ST WORD IS 10*ID +       
C         COMPONENT.        
C     THE SCRATCH FILE IS READ AND THE EXTERNAL ID INDEXED DIRECTLY.E   
C     NOTE - THAT EACH COLUMN MAY GENERATE MORE THAN 1 MESSAGE.        
C     OPEN CORE IS Z(1) TO Z(BUF-1).  TWO BUFFERS FOLLOW Z(BUF)        
C        
      INTEGER         BUF,BUF2,SIL,EXIT(8),ERR(14),FILMSG,GPID(4),GPL,  
     1                IN(3),INER(4),N(7),NAME(2),SUBNAM(2),TYP(6),USET, 
     2                Z(1)        
      CHARACTER       UFM*23,UWM*25        
      COMMON /XMSSG / UFM,UWM        
      COMMON /SDCQ  / NERR(2),NOGLEV,BUF,FILMSG        
      COMMON /NAMES / KRD2,KRR0,SKPN(3), KCL2        
      COMMON /SYSTEM/ KSYSTM(69)        
      EQUIVALENCE     (KSYSTM(1),NBUFSZ),(KSYSTM(2),IOUT),        
     1                (KSYSTM(69),ISUBST)        
      DATA    ERR   / 4HNULL, 4HCOL., 4HZERO, 4HDIAG, 4HNEG., 4HDIAG,   
     1                4HSING, 4HTEST, 4HBAD , 4HCOL., 4HNON-, 4HCONS,   
     2                4HZERO, 4HDIAG/        
      DATA    INER  / 4HINPU, 2HT   , 4HDECM, 2HP   /        
      DATA    EXIT  / 4HCONT, 4HINUE, 4HAT E, 4HND  , 4HAT S, 4HTART,   
     1                4HIN D, 4HECMP/        
      DATA    NAME  / 4HSDCM, 2HM   /        
      DATA    IBLK  / 4H    /        
C        
      BUF2 = BUF + NBUFSZ        
      N(1) = 0        
      N(2) = 0        
      N(3) = 0        
      N(4) = 0        
      N(5) = 0        
      N(6) = 0        
      N(7) = 0        
      IF (BUF .LE. 0) GO TO 50        
C        
C     GENERATE EXTERNAL ID        
C        
      IF (ISUBST .EQ. 0) GO TO 5        
C        
C     SUBSTRUCTURING - READ EQSS FILE ON THE SOF        
C        
C     4 BUFFERS NEEDED        
C        
      I = BUF - 2*NBUFSZ        
      IF (I .LE. 3*MSZE) GO TO 50        
      NWDS = 2        
      CALL MXCIDS (*50,Z,MSET,MSZE,NWDS,USET,I,SUBNAM)        
      NSTART = I - 1        
      GO TO  7        
C        
    5 NSTART = 0        
      NWDS   = 1        
C        
C     2 BUFFERS NEEDED        
C        
      CALL MXCID (*50,Z,MSET,MSZE,NWDS,USET,GPL,SIL,BUF)        
C        
    7 CALL OPEN (*110,FILMSG,Z(BUF2),KRR0)        
      CALL PAGE2 (3)        
      WRITE  (IOUT,10) UWM        
   10 FORMAT (A25,' 2377A, MATRIX CONDITIONING ERRORS GIVEN WITH ',     
     1       'EXTERNAL ID', /5X,'GID - C  INPUT-DIAG.   DECOMP-DIAG.',  
     2       6X,'TYPE',17X,'SUBSTRUCTURE')        
C        
      ASSIGN 30 TO IRET        
      TYP(5) = IBLK        
      TYP(6) = IBLK        
      IF (ISUBST.NE.0) ASSIGN 27 TO IRET        
C        
C     LOOP ON MESSAGES - 0 COLUMN IS FLAG TO QUIT        
C        
   20 CALL FREAD (FILMSG,IN,3,1)        
      IF (IN(1) .EQ. 0) GO TO 200        
      I = IN(1)/10        
      J = IN(1) - I*10        
      L = NSTART + I*NWDS        
      GPID(1) = Z(L)/10        
      GPID(2) = Z(L) - GPID(1)*10        
      GPID(3) = IN(2)        
      GPID(4) = IN(3)        
C        
C     INTERNAL FUNCTION        
C        
   25 CONTINUE        
      IF (J.LE.0 .OR. J.GT.7) GO TO 100        
      K = 2*J - 1        
      TYP(1) = ERR(K)        
      TYP(2) = ERR(K+1)        
      K = 1        
      IF (J.GT.1 .AND. J.LT.7) K = 3        
      TYP(3) = INER(K  )        
      TYP(4) = INER(K+1)        
      N(J) = N(J) + 1        
      CALL PAGE2 (2)        
      GO TO IRET, (27,30,80)        
C        
   27 TYP(5) = Z(2*L-1)        
      TYP(6) = Z(2*L  )        
   30 CONTINUE        
      WRITE  (IOUT,40) GPID,TYP        
   40 FORMAT (1H0,I9,2H -,I2,1P,2E14.6,3X,2A5,2H/ ,A4,A2,6HMATRIX,2X,   
     1        2A4)        
      GO TO 20        
C        
C     INSUFFICIENT CORE IN -MATCID-        
C        
   50 CALL PAGE2 (3)        
      WRITE  (IOUT,60) UWM        
   60 FORMAT (A25,' 2377B, MATRIX CONDITIONING ERRORS GIVEN WITH ',     
     1       'INTERNAL ID', /,5X,'COLUMN  INPUT DIAG.   DECOMP-DIAG.',  
     2       6X,'TYPE')        
C        
      CALL OPEN (*110,FILMSG,Z(BUF2),KRR0)        
      ASSIGN 80 TO IRET        
C        
C     LOOP        
C        
   70 CONTINUE        
      CALL FREAD (FILMSG,IN,3,1)        
      IF (IN(1) .EQ. 0) GO TO 200        
      I = IN(1)/10        
      J = IN(1) - I*10        
      IN(1) = I        
      GO TO 25        
C        
   80 CONTINUE        
      WRITE  (IOUT,90) IN,TYP        
   90 FORMAT (1H0,I8,1P,2E14.6,3X,2A5,2H/ ,A4,A2,6HMATRIX,2X,2A4)       
      GO TO 70        
C        
C     ILLEGAL DATA        
C        
  100 CALL MESAGE (7,FILMSG,NAME)        
      GO TO 200        
C        
C     SCRATCH FILE NOT AVAILABLE        
C        
  110 CALL MESAGE (1,FILMSG,NAME)        
C        
C     ALL DONE, SUMMARIZE        
C        
  200 CALL PAGE2 (11)        
      WRITE  (IOUT,210) MATRIX,MSZE,N        
  210 FORMAT (1H0,3X,10HFOR MATRIX,I4,6H, SIZE,I8,/I9,13H NULL COLUMNS, 
     1 /I9,15H ZERO DIAGONALS, /I9,19H NEGATIVE DIAGONALS, /I9,        
     2 31H SINGULARITY TOLERANCE EXCEEDED, /I9,12H BAD COLUMNS, /I9,    
     3 24H NONCONSERVATIVE COLUMNS, /I9,23H ZERO DIAGONALS (INPUT))     
C        
C     CHECK FOR EXIT CONDITIONS        
C        
      I = 2*NOGLEV + 1        
C        
C     NOTE - NOGLEV OF 4 ALSO HAS NEGATIVE PARM(1)        
C        
      IF (NOGLEV .EQ. 4) I = 7        
      J = I + 1        
      WRITE  (IOUT,220) EXIT(I),EXIT(J)        
  220 FORMAT (1H0,3X,13HABORT CODE = ,2A4)        
      CALL CLOSE (FILMSG,KCL2)        
      RETURN        
      END        
