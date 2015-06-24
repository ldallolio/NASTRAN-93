      SUBROUTINE SHPSTS (SIGMA,VONMS,SIGP)        
C        
C     TO CALCULATE PRINCIPAL STRESSES AND THEIR ANGLES FOR THE        
C     ISOPARAMETRIC SHELL ELEMENTS        
C        
C        
C     INPUT :        
C           SIGMA  - ARRAY OF 3 STRESS COMPONENTS        
C           VONMS  - LOGICAL FLAG INDICATING THE PRESENCE OF VON-MISES  
C                    STRESS REQUEST        
C     OUTPUT:        
C           SIGP   - ARRAY OF PRINCIPAL STRESSES        
C        
C        
      LOGICAL VONMS        
      REAL    SIGMA(3),SIGP(4),SIG,PROJ,TAUMAX,EPS,TXY2        
      DATA    EPS / 1.0E-11 /        
C        
C        
C     CALCULATE PRINCIPAL STRESSES        
C        
      SIG  = 0.5*(SIGMA(1)+SIGMA(2))        
      PROJ = 0.5*(SIGMA(1)-SIGMA(2))        
      TAUMAX = PROJ*PROJ + SIGMA(3)*SIGMA(3)        
      IF (TAUMAX .NE. 0.0) TAUMAX = SQRT(TAUMAX)        
      IF (TAUMAX .LE. EPS) TAUMAX = 0.0        
C        
C     CALCULATE THE PRINCIPAL ANGLE        
C        
      TXY2 = SIGMA(3)*2.0        
      PROJ = PROJ*2.0        
      SIGP(1) = 0.0        
      IF (ABS(TXY2).GT.EPS .OR. ABS(PROJ).GT.EPS)        
     1    SIGP(1) = 28.64788976*ATAN2(TXY2,PROJ)        
C                   28.64788976 = 90./PI        
C        
      SIGP(2) = SIG + TAUMAX        
      SIGP(3) = SIG - TAUMAX        
      SIGP(4) = TAUMAX        
C        
C     OUTPUT VON MISES YIELD STRESS IF REQUESTED        
C        
      IF (.NOT.VONMS) RETURN        
      SIG = SIGP(2)*SIGP(2) + SIGP(3)*SIGP(3) - SIGP(2)*SIGP(3)        
      IF (SIG .NE. 0.0) SIG = SQRT(SIG)        
      IF (SIG .LE. EPS) SIG = 0.0        
      SIGP(4) = SIG        
C        
      RETURN        
      END        
