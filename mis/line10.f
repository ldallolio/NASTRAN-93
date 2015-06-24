      SUBROUTINE LINE10 (X1,Y1,X2,Y2,PENDEN,OPT)        
C        
C     X1,Y1  = STARTING POINT OF THE LINE        
C     X2,Y2  = TERMINAL POINT OF THE LINE        
C     PENDEN = PEN NUMBER OR LINE DENSITY        
C     OPT    = -1 TO INITIATE  THE LINE MODE        
C            = +1 TO TERMINATE THE LINE MODE        
C            = 0 TO DRAW A LINE        
C        
      INTEGER PENDEN,OPT,OPTX,A(6)        
      DATA    OPTX,LINE / -1, 5  /        
C        
      IF (OPTX .GE. 0) OPTX = OPT        
      IF (OPT) 200,100,150        
  100 A(1) = LINE        
      A(2) = PENDEN        
      A(3) = IFIX(X1+.1)        
      A(4) = IFIX(Y1+.1)        
      A(5) = IFIX(X2+.1)        
      A(6) = IFIX(Y2+.1)        
      IF (OPTX .EQ. 0) GO TO 120        
C        
C     INITIATE THE LINE MODE.        
C        
      A(1) = A(1) + 10        
      OPTX = 0        
C        
C     DRAW THE LINE.        
C        
  120 CALL WPLT10 (A,0)        
      GO TO 200        
C        
C     TERMINATE THE LINE MODE.        
C        
  150 CALL WPLT10 (A,1)        
      OPTX = -1        
C        
  200 RETURN        
      END        
