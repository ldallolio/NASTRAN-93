      SUBROUTINE TIMTST        
C        
C     TIMETEST   /,/ C,N,N / C,N,M / C,N,T / C,N,O1 / C,N,O2 $        
C        
      INTEGER         T,O1,O2        
      CHARACTER       UFM*23,UWM*25        
      COMMON /XMSSG / UFM,UWM        
      COMMON /BLANK / N,M,T,O1,O2        
      COMMON /SYSTEM/ ISYSBF, NOUT        
C        
      IF (O1.LT.1 .OR. O1.GT.2) GO TO 9901        
      GO TO (100, 200), O1        
C        
  100 CONTINUE        
      CALL TIMTS1        
      GO TO 900        
C        
  200 CONTINUE        
      CALL TIMTS2        
C        
  900 CONTINUE        
      RETURN        
C        
C     ERROR MESSAGES        
C        
 9901 WRITE  (NOUT,9951) UWM        
 9951 FORMAT (A25,' 2195, ILLEGAL VALUE FOR P4 =',I7)        
C        
      WRITE  (NOUT,9996)        
 9996 FORMAT ('0*** MODULE TIMETEST TERMINAL ERROR.')        
C        
      RETURN        
C        
      END        
