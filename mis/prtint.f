      SUBROUTINE PRTINT        
C        
      INTEGER TRLR        
      INTEGER OPT, PRT        
C        
C     OPT = 0 IF MATRIX BY COLUMNS...1 IF BY ROWS.        
C        
      REAL NAME(2)        
C        
      COMMON /BLANK/ OPT, PRT        
      COMMON /XXMPRT/ TRLR(7)        
CZZ   COMMON /ZZPRTI/ X(1)        
      COMMON /ZZZZZZ/ X(1)        
C        
      IF (PRT.LT.0)  GO TO 100        
      TRLR(1) = 101        
      CALL RDTRL (TRLR)        
      IF (TRLR(1).LE.0)  GO TO 100        
      CALL FNAME (TRLR,NAME)        
      CALL INTPRT (X,OPT,1,NAME)        
  100 RETURN        
      END        
