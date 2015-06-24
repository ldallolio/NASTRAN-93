      SUBROUTINE AUTOCK (IADD)        
C        
C     THIS ROUTINE GENERATES A CHKPT OSCAR RECORD WHEN THE PRECHK       
C     OPTION IS BEING USED, THE ADDRESS IADD IS THE STARTING        
C     LOCATION OF THE OUTPUT FILE NAMES TO BE TESTED        
C        
      EXTERNAL        LSHIFT,RSHIFT        
      INTEGER         PRENAM,PREFLG,OSPRC,OSBOT,OSPNT,LIST(100),XCHK(2),
     1                DMPCNT,RSHIFT,CASESS(2),CASECC(2),CASEI(2),       
     2                OSCAR(1),OS(5)        
      COMMON /AUTOCM/ PREFLG,NNAMES,PRENAM(100)        
CZZ   COMMON /ZZXGPI/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /XGPI4 / JUNK(2),ISEQN,DMPCNT        
      COMMON /AUTOHD/ IHEAD        
      EQUIVALENCE     (LOSCAR,CORE(1),OS(1)),(OSPRC,OS(2)),        
     1                (OSBOT,OS(3)),(OSPNT,OS(4)),(OSCAR(1),OS(5))      
      DATA    CASESS/ 4HCASE, 4HSS  /        
      DATA    CASECC/ 4HCASE, 4HCC  /        
      DATA    CASEI / 4HCASE, 4HI   /        
      DATA    XCHK  / 4HXCHK, 4H    /        
      DATA    IBLANK/ 0             /        
C        
      IHEAD = 0        
      IOP   = 0        
      IF (PREFLG) 200,200,5        
    5 PREFLG = IABS(PREFLG)        
      NOPF = OSCAR(IADD)        
      NWD  = 3*NOPF        
      IST  = IADD + 1        
      IFIN = IST + NWD - 1        
      NLIST= 0        
      INCR = 3        
C        
      GO TO (1,2,3), PREFLG        
C        
C     CHECK OUTPUT FILE AGAINST LIST        
C        
    1 N2 = 2*NNAMES        
      DO 10 I = IST,IFIN,INCR        
      DO 11 J = 1,N2,2        
      IF (PRENAM(J).EQ.CASESS(1) .AND.PRENAM(J+1).EQ.CASESS(2)) GO TO 11
      IF (PRENAM(J).EQ.CASECC(1) .AND.PRENAM(J+1).EQ.CASECC(2)) GO TO 11
      IF (PRENAM(J).EQ.CASEI( 1) .AND.PRENAM(J+1).EQ.CASEI( 2)) GO TO 11
      IF (PRENAM(J).NE.OSCAR(I) .OR. PRENAM(J+1).NE.OSCAR(I+1)) GO TO 11
      NLIST = NLIST + 1        
      LIST(2*NLIST-1) = OSCAR(I  )        
      LIST(2*NLIST  ) = OSCAR(I+1)        
   11 CONTINUE        
   10 CONTINUE        
      IF (IOP   .EQ. 1) GO TO 300        
      IF (NLIST .EQ. 0) RETURN        
      GO TO 100        
C        
C     PREFLG=ALL OPTION, CHECKPOINT ALL OUTPUT DATA BLOCKS        
C        
    2 DO 20 I = IST,IFIN,INCR        
      IF (OSCAR(I).EQ.IBLANK .AND. OSCAR(I+1).EQ.IBLANK) GO TO 20       
      IF (OSCAR(I).EQ.CASESS(1) .AND. OSCAR(I+1).EQ.CASESS(2)) GO TO 20 
      IF (OSCAR(I).EQ.CASECC(1) .AND. OSCAR(I+1).EQ.CASECC(2)) GO TO 20 
      IF (OSCAR(I).EQ.CASEI( 1) .AND. OSCAR(I+1).EQ.CASEI( 2)) GO TO 20 
      NLIST = NLIST + 1        
      LIST(2*NLIST-1) = OSCAR(I  )        
      LIST(2*NLIST  ) = OSCAR(I+1)        
   20 CONTINUE        
      IF (IOP .EQ. 1) GO TO 300        
      GO TO 100        
C        
C     CHECK OUTPUT FILES EXCEPT THOSE IN LIST        
C        
    3 N2 = 2*NNAMES        
      DO 30 I = IST,IFIN,INCR        
      DO 31 J = 1,N2,2        
      IF (PRENAM(J).EQ.OSCAR(I) .AND.PRENAM(J+1).EQ.OSCAR(I+1)) GO TO 30
   31 CONTINUE        
      IF (OSCAR(I).EQ.IBLANK .AND. OSCAR(I+1).EQ.IBLANK ) GO TO 30      
      IF (OSCAR(I).EQ.CASESS(1) .AND. OSCAR(I+1).EQ.CASESS(2)) GO TO 30 
      IF (OSCAR(I).EQ.CASECC(1) .AND. OSCAR(I+1).EQ.CASECC(2)) GO TO 30 
      IF (OSCAR(I).EQ.CASEI( 1) .AND. OSCAR(I+1).EQ.CASEI( 2)) GO TO 30 
      NLIST = NLIST + 1        
      LIST(2*NLIST-1) = OSCAR(I  )        
      LIST(2*NLIST  ) = OSCAR(I+1)        
   30 CONTINUE        
      IF (IOP   .EQ. 1) GO TO 300        
      IF (NLIST .EQ. 0) RETURN        
      GO TO 100        
C        
C     PURGE OR EQUIV DATA BLOCK LIST MUST BE CHECKED        
C        
  200 NWD = OSCAR(OSPNT)        
      MI  = RSHIFT(OSCAR(OSPNT+2),16)        
      IB  = OSPNT + 6        
      PREFLG = IABS(PREFLG)        
      NDB = OSCAR(IB)        
      IOP = 1        
      IF (MI .EQ.  9) IST  = IB + 1        
      IF (MI .EQ. 10) IST  = IB + 4        
      IF (MI .EQ.  9) IFIN = IST + 2*NDB - 1        
      IF (MI .EQ. 10) IFIN = IST + 2*NDB - 3        
      NWD  = NWD - 6        
      INCR = 2        
      NLIST= 0        
      GO TO (1,2,3), PREFLG        
300   NWD = NWD - 2*NDB - 2        
      IF (MI .EQ. 10) NWD = NWD - 1        
      IF (NWD.LE.0 .AND. NLIST.NE.0) GO TO 100        
      IF (NWD.LE.0 .AND. NLIST.EQ.0) GO TO 999        
      NDB = OSCAR(IFIN+2)        
      IF (MI .EQ.  9) IST = IFIN + 3        
      IF (MI .EQ. 10) IST = IFIN + 6        
      IFIN = IST + 2*NDB - 1        
      IF (MI .EQ. 10) IFIN = IFIN - 2        
      GO TO (1,2,3), PREFLG        
C        
C     UPDATE OSCAR PARAMETERS        
C        
  100 IHEAD = 1        
      OSPRC = OSBOT        
      OSBOT = OSCAR(OSBOT) + OSBOT        
      OSPNT = OSBOT        
      ISEQN = OSCAR(OSPRC+1) + 1        
C        
C     LOAD HEADER        
C        
      OSCAR(OSPNT  ) = 6        
      OSCAR(OSPNT+1) = ISEQN        
      OSCAR(OSPNT+2) = 4 + LSHIFT(3,16)        
      OSCAR(OSPNT+3) = XCHK(1)        
      OSCAR(OSPNT+4) = XCHK(2)        
      OSCAR(OSPNT+5) = DMPCNT        
      IF (IOP .EQ. 1) OSCAR(OSPNT+5) = OSCAR(OSPNT+5) - 1        
      OSCAR(OSPNT+6) = NLIST        
      CALL XLNKHD        
      IF (NLIST .EQ. 0) GO TO 110        
C        
C     LOAD CHKPNT INFORMATION        
C        
      NLIST = 2*NLIST        
      DO 101 I = 1,NLIST,2        
      OSCAR(OSPNT+6+I) = LIST(I)        
      OSCAR(OSPNT+7+I) = LIST(I+1)        
  101 CONTINUE        
  110 OSCAR(OSPNT) = OSCAR(OSPNT) + NLIST + 1        
  999 IHEAD = 0        
      RETURN        
      END        
