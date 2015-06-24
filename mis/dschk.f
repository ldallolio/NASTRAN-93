      SUBROUTINE DSCHK        
C        
C     MODULE TO PERFORM DIFFERENTIAL STIFFNESS CONVERGENCE TESTS        
C        
C     DSCHK    PGI,PGIP1,UGIP1//EPSIO,DSEPSI,NT,TOUT,TIN,DONE,SHIFT,    
C                               COUNT,BETA        
C        
C     EPSIO    ACCEPTABLE RATIO OF ENERGY ERROR TO TOTAL ERROR(R) INPUT 
C     DSEPSI   EPSI(SUB I -1)   (REAL)                            IN/OUT
C     NT       TOTAL NUMBER OF ITERATIONS ALLOWED                 INPUT 
C     TOUT     START TIME FOR OUTER LOOP                          INPUT 
C     TIN      START TIME FOR INNER LOOP                          INPUT 
C     DONE     EXIT FLAG FOR SKIP TO SDR2                         OUTPUT
C     SHIFT    EXIT FLAG FOR SHIFT                                IN/OUT
C     COUNT    CURRENT STEP NUMBER                                IN/OUT
C     BETA     SHIFT DECISION FACTOR (REAL)                       INPUT 
C        
C     EXIT FLAG VALUES (IEXIT)                                    LOCAL 
C          0   NOT SET        
C          1   CONVERGED        
C          2   DIVERGED        
C          3   INSUFFICIENT TIME        
C          4   ITERATION LIMIT        
C          5   ZERO EPSIO        
C          6   ZERO EPSI        
C        
      INTEGER         PGI,PGIP1,UGIP1,TOUT,TIN,DONE,SHIFT,COUNT,IZ(1),  
     1                SYSBUF,SCR1,SCR2,SCR3,FILE,TNOW,TI,TO,TLEFT,BETA  
      CHARACTER       UFM*23,UWM*25,UIM*29        
      COMMON /XMSSG / UFM,UWM,UIM        
      COMMON /SYSTEM/ SYSBUF,NOUT,KSYSTM(52),IPREC        
      COMMON /UNPAKX/ ITA,II,JJ,INCR        
      COMMON /BLANK / EPSIO,DSEPSI,NT,TOUT,TIN,DONE,SHIFT,COUNT,BETA    
CZZ   COMMON /ZZDSCH/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (COUNT,NI), (Z(1),IZ(1))        
      DATA    PGI   , PGIP1,UGIP1,SCR1,SCR2,SCR3 /        
     1        101   , 102,  103,  301, 302, 303  /        
C        
C     INITIALIZE        
C        
      IBUF1 = KORSZ(IZ) - SYSBUF + 1        
      IEXIT = 0        
      IFRST = SHIFT        
      SHIFT = 1        
      NF    = 1        
      CALL KLOCK (TNOW)        
      TI    = TNOW - TIN        
      CALL TMTOGO (TLEFT)        
      TO    = TNOW - TLEFT        
C        
C     COMPUTE DSEPSI(I)        
C        
      CALL SSG2B (UGIP1,PGI  ,0   ,SCR1,1,IPREC,1,SCR3)        
      CALL SSG2B (UGIP1,PGIP1,SCR1,SCR2,1,IPREC,2,SCR3)        
C        
      II   = 1        
      JJ   = 1        
      INCR = 1        
      ITA  = 1        
      FILE = SCR2        
      ASSIGN 10 TO IRETN        
      GO TO 300        
C        
C     GET DENOMINATOR        
C        
   10 EPSI = VALUE        
      FILE = SCR1        
      ASSIGN 20 TO IRETN        
      GO TO 300        
   20 IF (VALUE .EQ. 0.0) GO TO 40        
      EPSI  = ABS(EPSI/VALUE)        
      COUNT = COUNT + 1        
      IF (IFRST .EQ.  -1) GO TO 30        
      IF (EPSI  .EQ. 0.0) GO TO 210        
      XLAMA = ABS(DSEPSI/EPSI)        
      IF (XLAMA .LE. 1.0) GO TO 60        
   30 DSEPSI = EPSI        
      IF (EPSI .GT. EPSIO) GO TO 50        
C        
C     CONVERGED        
C        
   40 IEXIT = 1        
      DONE  =-1        
      GO TO 220        
C        
C     MAKE FIRST TEST        
C        
   50 IF (IFRST .EQ. -1) GO TO 80        
C        
C     NOT FIRST TIME        
C        
      IF (EPSIO .LE. 0.0) GO TO 200        
      NF  = ALOG(EPSI/EPSIO)/ALOG(XLAMA)        
      CALL KLOCK (TNOW)        
      CALL TMTOGO (TLEFT)        
      TI  = TNOW - TIN        
      TO  = TNOW - TOUT        
      GO TO 70        
C        
C     DIVERGED        
C        
   60 IEXIT = 2        
      DONE  =-1        
      DSEPSI = EPSI        
      GO TO 220        
C        
C     CONVERGENT        
C        
   70 IF (NF .GT. NT-NI) GO TO 90        
      IF (TI*NF .GT. TO+BETA*TI) GO TO 100        
   80 IF (TLEFT .GE. 3*TI) GO TO 120        
C        
C     INSUFFICIENT TIME        
C        
      IEXIT = 3        
      DONE  =-1        
      GO TO 220        
   90 IF (NT-NI-BETA) 80,100,100        
C        
C     SET SHIFT FLAG        
C        
  100 SHIFT =-1        
      IF (TLEFT .LT. TO+BETA*TI) GO TO 80        
C        
C     WRAP UP FOR SHIFT        
C        
      DONE  = NF        
      IEXIT = 0        
      GO TO 220        
C        
C     USER LIMIT ITERATION NUMBER EXPIRED        
C        
  110 CONTINUE        
      IEXIT = 4        
      DONE  =-1        
      GO TO 220        
C        
C     WRAP UP FOR NO SHIFT        
C        
  120 CONTINUE        
      IF (NI .GE. NT) GO TO 110        
      SHIFT = 1        
      DONE  = NF        
      GO TO 220        
C        
C     PARAMETER ERROR, EPSIO HAS NO VALUE        
C        
  200 IEXIT = 5        
      GO TO 220        
C        
C     AFTER SSG2B, EPSI IS ZERO DUE TO THE FIRST VAULE FROM SCR2 IS ZERO
C     WHILE VALUE FROM SCR1 IS NOT ZERO        
C        
  210 IEXIT = 6        
C        
C     EXIT FROM MODULE        
C        
  220 CALL PAGE2 (-9)        
      WRITE  (NOUT,230) UIM,IEXIT,COUNT,DONE,SHIFT,DSEPSI        
  230 FORMAT (A29,' 7019, MODULE DSCHK IS EXITING FOR REASON',I4, /5X,  
     1       'ON ITERATION NUMBER',I7,1H.,        
     2       /5X,'PARAMETER VALUES ARE AS FOLLOWS',/10X,'DONE   =',I10, 
     3       /10X,'SHIFT  =',I10, /10X,'DSEPSI =',1P,E14.7)        
      IF (IEXIT .GE. 5) WRITE (NOUT,240) EPSIO,EPSI        
  240 FORMAT ( 10X,'EPSIO  =',1P,E10.3, /10X,'EPSI   =',1P,E10.3)       
      RETURN        
C        
C     INTERNAL ROUTINE TO OBTAIN VALUE FROM MATRIX        
C        
  300 CALL GOPEN (FILE,IZ(IBUF1),0)        
      CALL UNPACK (*310,FILE,VALUE)        
      GO TO 320        
  310 VALUE = 0.0        
  320 CALL CLOSE (FILE,1)        
      GO TO IRETN, (10,20)        
      END        
