      SUBROUTINE ROMBER (B,PRECIS,ITDONE,FINTG,K,X)        
C        
C     TO INTEGRATE F(X) FROM X = A TO X = B        
C        
C         A = LOWER LIMIT = 0.0        
C         B = UPPER LIMIT        
C         NOSIG = NUMBER OF CORRECT SIGNIFICANT DIGITS DESIRED        
C                 (NOT MORE THAN 7) = 5        
C         PRECIS = 0.0  UPON RETURN, PRECIS = ACTUAL NUMBER        
C                       OF SIGNIFICANT DIGITS ATTAINED        
C         NUM = MAXIMUM NUMBER OF HALVINGS OF B-A TO BE MADE        
C               (NOT MORE THAN 99) = 15        
C         PROGRAMMER MUST ALSO PROGRAM SUBROUTINE FUNCT(F,X)        
C         GIVING F AS THE DESIRED FUNCTION OF X, UPON        
C         DEMAND OF ROMBER        
C         UPON RETURN FROM ROMBER, THE VALUE OF THE INTEGRAL        
C         WILL BE FOUND IN FINTG        
C         IT IS CUSTOMARY TO MEASURE THE PRECISION OF LARGE NUMBERS IN  
C     TERMS OF NUMBER OF SIGNIFICANT DIGITS AND THE ACCURACY OF SMALL   
C     NUMBERS IN TERMS OF NUMBER OF SIGNIFICANT DECIMALS.  TO CONFORM   
C     TO THIS PRACTICE, THE SUBROUTINE TERMINATES WHEN EITHER OF THESE  
C     CONDITIONS IS MET.        
C        
      DIMENSION   X(6)        
      DIMENSION   FAAAA(20),FAAAB(20)        
C        
      FAAAC = 0.00001        
      IAAAA = 1        
      FAAAD = B        
      X(1)  = 0.0        
      ASSIGN 100 TO IRET        
      GO TO (1000,2000,3000), K        
  100 CONTINUE        
      FAAAE = F        
      X(1)  = B        
      ASSIGN 200 TO IRET        
      GO TO (1000,2000,3000), K        
  200 CONTINUE        
      FAAAE = FAAAE+F        
      FAAAA(1) = 0.5*FAAAD*FAAAE        
 9988 FAAAD = 0.5*FAAAD        
      IAAAC = 2**(IAAAA-1)        
      FAAAE = 0.0        
C     DO 9986 IAAAD = 1,IAAAC        
      IAAAD = 0        
 9986 IAAAD = IAAAD + 1        
      FAAAF = IAAAD        
      X(1)  = (2.0*FAAAF-1.0)*FAAAD        
      ASSIGN 300 TO IRET        
      GO TO (1000,2000,3000), K        
  300 CONTINUE        
      FAAAE = FAAAE+F        
C9986 CONTINUE        
      IF (IAAAD .LT. IAAAC) GO TO 9986        
      FAAAB(1) = 0.5*FAAAA(1)+FAAAD*FAAAE        
      IAAAA = IAAAA+1        
      DO 9985 IAAAD = 2,IAAAA        
      FAAAG = 4.0**(IAAAD-1)        
      FAAAH = FAAAG-1.0        
      IAAAF = IAAAD-1        
 9985 FAAAB(IAAAD) = (FAAAG*FAAAB(IAAAF)-FAAAA(IAAAF))/FAAAH        
      IAAAC = 2*IAAAC+1        
      DIFF  = FAAAB(IAAAA)- FAAAA(IAAAA-1)        
      IF (ABS(DIFF) - ABS(FAAAC*FAAAB(IAAAA))) 9979,9981,9981        
 9981 DO 9980 IAAAD = 1,IAAAA        
 9980 FAAAA(IAAAD) = FAAAB(IAAAD)        
      IF (IAAAA .LT. 15) GO TO 9988        
 9979 PRECIS = DIFF        
      ITDONE = IAAAA - 1        
      FINTG  = FAAAB(IAAAA)        
      RETURN        
C        
C     THIS CODE REPLACES F4        
C        
 1000 CONTINUE        
      IF (X(1) .EQ. 0.0) GO TO 1020        
      DEN = X(3) - X(2)*X(5) + X(2)*X(5)*COS(X(1))+X(2)*X(4)*SIN(X(1))  
      F   = X(1)**(X(6)-1.0)* SIN(X(1))**2 / DEN        
 1010 GO TO IRET, (100,200,300)        
 1020 F = 0.0        
      GO TO 1010        
C        
C     THIS CODE REPLACES F5        
C        
 2000 CONTINUE        
      IF (X(1) .EQ. 0.0) GO TO 2020        
      DEN = X(3) - X(2)*X(5) + X(2)*X(5)*COS(X(1))+X(2)*X(4)*SIN(X(1))  
      F   = X(1)**(X(6)-1.0)*2. *SIN(X(1))*COS(X(1))/DEN        
 2010 GO TO IRET, (100,200,300)        
 2020 F = 0.0        
      GO TO 2010        
C        
C     THIS CODE REPLACES F6        
C        
 3000 CONTINUE        
      DEN = X(3) - X(2)*X(5) + X(2)*X(5)*COS(X(1))+X(2)*X(4)*SIN(X(1))  
      IF (X(6) .EQ. 1.0) CONST = 1.0        
      IF (X(6) .NE. 1.0) CONST = X(1)**(X(6) - 1.0)        
      IF (DEN  .EQ. 0.0) GO TO 3020        
      F = CONST*COS(X(1))**2 / DEN        
 3010 GO TO IRET, (100,200,300)        
 3020 F = 0.0        
      GO TO 3010        
      END        
