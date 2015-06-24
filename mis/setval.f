      SUBROUTINE SETVAL        
C        
      EXTERNAL        ANDF,RSHIFT        
      INTEGER         ANDF,RSHIFT,P,OSCAR,VPS,SUBNAM(2)        
      COMMON /BLANK / P(2,5)        
      COMMON /SYSTEM/ KSYSTM(65)        
      COMMON /XVPS  / VPS(1)        
      COMMON /OSCENT/ OSCAR(1)        
      EQUIVALENCE     (KSYSTM(40),NBPW)        
      DATA    SUBNAM/ 4HSETV,4HAL   /        
C        
      J = 12        
      DO 100 I = 1,5        
C        
C     CHECK ODD PARAMETERS TO FIND VARIABLE ONES        
C        
      IF (ANDF(RSHIFT(OSCAR(J+1),NBPW-1),1) .EQ. 0) GO TO 200        
C        
C     PARAMETER IS VARIABLE        
C        
      K = ANDF(OSCAR(J+1),65535)        
      P(1,I) = P(2,I)        
      VPS(K) = P(1,I)        
      J = J + 2        
      IF (ANDF(RSHIFT(OSCAR(J),NBPW-1),1) .EQ. 0) J = J + 1        
  100 CONTINUE        
      GO TO 500        
C        
  200 CONTINUE        
      IF (I .GT. 1) GO TO 500        
      CALL MESAGE (-7,0,SUBNAM)        
C        
  500 CONTINUE        
      RETURN        
      END        
