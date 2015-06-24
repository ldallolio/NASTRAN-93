      SUBROUTINE SDCMQ (*,KEY,V1,V,DV1,DV,IC,Z)        
C        
C     THIS SUBROUTINE CREATES A SCRATCH FILE OF QUEUED SINGULARITY      
C     MESSAGES.  EACH MESSAGE IS A GINO RECORD DUE TO POSSIBLE CLOSE    
C     WITHOUT REWIND.        
C     THE -KEY- IS AS FOLLOWS,        
C      1  - NULL COLUMN       - INPUT MATRIX        
C      2  - ZERO DIAGONAL     - DECOMPOSED MATRIX.        
C      3  - NEGATIVE DIAGONAL - DECOMPOSED MATRIX        
C      4  - SINGULARITY TOLERANCE FAILURE - DECOMPOSED MATRIX.        
C      5  - UNEXPECTED NULL COLUMN OR END OF COLUMN - ABORT IMMIDIATELY.
C      6  - NONCONSERVATIVE COLUMN  D/A.GT.1.001        
C      7  - ZERO DIAGONAL     - INPUT MATRIX.        
C     OTHER ARGUMENTS ARE        
C      $  - NONSTANDARD RETURN IF DECOMPOSITION IS TO BE ABORTED.       
C      Z  - OPEN CORE.  BUFFER LOCATIONS RELATIVE TO Z(1).        
C      V  - RSP VALUE OF ENTRY IN ERROR (DV IS DOUBLE PRECISION).       
C      V1 - INPUT VALUE OF DIAGONAL (DV1 IS DOUBLE PRECISION VERSION).  
C      IC - COLUMN NUMBER IN ERROR.        
C    THE ARGUMENTS ARE NOT CHANGED.        
C    /SDCQ/ CONTAINS CONSTANT DATA.        
C      FILCUR - CURRENT FILE USING BUFFER FOR SCRATCH FILE.  NEGATIVE IF
C               NONE, ZERO IF FILSCR IS TO REMAIN OPEN        
C      STSCR  - GINO FILE STATUS FOR REOPENING FILCUR (1=READ,2=WRITE)  
C      FILSCR - SCRATCH FILE NAME.        
C      BUF    - BUFFER LOCATION RELATIVE TO Z(1).        
C      NERR(2)- COUNT OF NUMBER OF ERROR CALLS ( (1)=ES, (2)=PD CHECK)  
C      DIAGCK - EXIT FLAG FOR KEY=4 -- 0=NONFATAL, +N = MAX.-MESSAGES   
C               WITHOUT ABORTING, -N = IMMEDIATE ABORT        
C      IPREC  - 1=RSP, USE V. 2=RDP, USE DV.        
C      PDEFCK - EXIT FLAG FOR KEY=3.  0 = NONFATAL IF -V, FATAL AT END  
C               OF DECOMP FOR V=0.  +N = MAX-MESSAGES WITHOUT ABORTING. 
C               -N = IMMEDIATE ABORT        
C      NOGLEV - NOGO CODE.        
C             = 0, NO FATAL ERRORS,        
C             = 1, ABORT AT END OF DECOMP,        
C             = 2, ABORT AT END OF PREPASS        
C             = 3, ABORT,NONSTD RET.        
C             = 4, INTERNAL ERRORS.  ABORT AT MAJOR CHECK-POINTS.       
C-----        
      LOGICAL          OPNSCR,FIRST        
      INTEGER          BUF,DIAGCK,FILCUR,FILERR,FILSCR,IV(3),NAME(2),   
     1                 PARM,PDEFCK,STSCR,Z(1)        
      DOUBLE PRECISION DV,DV1        
      CHARACTER        UFM*23,UWM*25,UIM*29,SFM*25,SWM*27        
      COMMON /XMSSG /  UFM,UWM,UIM,SFM,SWM        
      COMMON /SDCQ  /  NERR(2),NOGLEV,BUF,FILSCR,FILCUR,STSCR,PDEFCK,   
     1                 DIAGCK,DIAGET,IPREC,PARM(4),OPNSCR,FIRST        
      COMMON /SFACT /  SKPSF(32),ICHLY        
      COMMON /NAMES /  KRD2,KRR0,KWT3,KWR1, SKPN,KCL2        
      COMMON /SYSTEM/  ISB,IOUT        
      EQUIVALENCE      (RV1,IV(2)),(RV,IV(3))        
      DATA    NAME  /  4HSDCM,2HQ  /        
C        
      IF (FILCUR .GT. 0) CALL CLOSE (FILCUR,KCL2)        
      FILERR = FILSCR        
      IF (OPNSCR) GO TO 10        
      IF (.NOT.FIRST) CALL OPEN (*200,FILSCR,Z(BUF),KWT3)        
      IF (FIRST) CALL OPEN (*200,FILSCR,Z(BUF),KWR1)        
      FIRST  = .FALSE.        
      OPNSCR = .TRUE.        
C        
   10 IV(1) = IC*10 + KEY        
      IF (IPREC .EQ. 1) GO TO 14        
      RV  = DV        
      RV1 = DV1        
      GO TO 17        
   14 RV  = V        
      RV1 = V1        
   17 CONTINUE        
      CALL WRITE (FILSCR,IV,3,1)        
C        
C     CONVERT FILES TO ORIGINAL STATUS        
C        
      IF (FILCUR .EQ. 0) GO TO 20        
      CALL CLOSE (FILSCR,KCL2)        
      OPNSCR = .FALSE.        
      IF (FILCUR .LE. 0) GO TO 20        
      FILERR = FILCUR        
C        
C     READ MODE ON CURRENT FILE        
C        
      IF (STSCR .EQ. 1) I = KRD2        
C        
C     WRITE MODE ON CURRENT FILE        
C        
      IF (STSCR .EQ. 2) I = KWT3        
      CALL OPEN (*200,FILCUR,Z(BUF),I)        
C        
C     DETERMINE ABORT FLAG        
C        
   20 CONTINUE        
      GO TO (65,30,40,50,60,50,50), KEY        
C        
C     ZERO DIAGONAL - DECOMPOSED MATRIX        
C        
   30 NOGLEV = MAX0(NOGLEV,1)        
      IF (IPREC .EQ. 1)  V = 1.0        
      IF (IPREC .EQ. 2) DV = 1.D0        
      GO TO 70        
C        
C     NEGATIVE DIAGONAL        
C        
   40 CONTINUE        
      IF (ICHLY  .NE. 1) GO TO 45        
      IF (IPREC  .EQ. 1)  V =-V        
      IF (IPREC  .EQ. 2) DV =-DV        
   45 IF (PDEFCK .EQ. 0) GO TO 70        
      NOGLEV = MAX0(NOGLEV,1)        
      GO TO 70        
C        
C     ES SINGULARITY CHECK, DIAG-IN=0.0, NON-CONSERVATIVE MATRIX        
C        
   50 CONTINUE        
      NERR(1) = NERR(1) + 1        
      IF (DIAGCK .EQ. 0) GO TO 100        
      NOGLEV = MAX0(NOGLEV,1)        
      IF (NERR(1) .GE. DIAGCK) NOGLEV = 3        
      GO TO 100        
C        
C     UNEXPECTED NULL COLUMN        
C        
   60 NOGLEV = 3        
      GO TO 70        
C        
   65 NOGLEV  = 2        
   70 NERR(2) = NERR(2) + 1        
      IF (NERR(2).GT.IABS(PDEFCK) .AND. PDEFCK.NE.0)  NOGLEV = 3        
C        
  100 CONTINUE        
      IF (NOGLEV .EQ. 3) RETURN 1        
      RETURN        
C        
C     UNABLE TO USE FILES - WRITE GINO NUMBER. ABORT AT MAJOR DECOMP    
C     CHCK        
C        
  200 CALL PAGE2 (2)        
      WRITE  (IOUT,210) SWM,FILERR,NAME,IC,KEY        
  210 FORMAT (A27,' 2379, FILE',I8,' COULD NOT BE OPENED IN',A4,A1,     
     1       '. COLUMN',I8,' SINGULAR, REASON',I3)        
      PARM(1) = -37        
      PARM(2) = FILSCR        
      PARM(3) = NAME(1)        
      PARM(4) = NAME(2)        
      NOGLEV  = 4        
      GO TO 100        
      END        
