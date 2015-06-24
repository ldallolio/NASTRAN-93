      SUBROUTINE ROMBDK (B,PRECIS,ITDONE,FINTG,K,X)        
C        
C     INTEGRATE F(X) FROM 0.0 TO X = B        
C        
C         B      = UPPER LIMIT        
C         NOSIG  = NUMBER OF CORRECT SIGNIFICANT DIGITS DESIRED        
C                  (NOT MORE THAN 7) = 5        
C         PRECIS = 0.0  UPON RETURN, PRECIS = ACTUAL NUMBER        
C                  OF SIGNIFICANT DIGITS ATTAINED        
C         NUM    = MAXIMUM NUMBER OF HALVINGS OF B-A TO BE MADE        
C                  (NOT MORE THAN 99) = 15        
C     UPON RETURN FROM ROMBER, THE VALUE OF THE INTEGRAL WILL BE FOUND  
C     IN FINTG        
C        
C     IT IS CUSTOMARY TO MEASURE THE PRECISION OF LARGE NUMBERS IN      
C     TERMS OF NUMBER OF SIGNIFICANT DIGITS AND THE ACCURACY OF SMALL   
C     NUMBERS IN TERMS OF NUMBER OF SIGNIFICANT DECIMALS.  TO CONFORM   
C     TO THIS PRACTICE, THE SUBROUTINE TERMINATES WHEN EITHER OF THESE  
C     CONDITIONS IS MET.        
C        
      DOUBLE PRECISION DEN,CONST,B,PRECIS,FINTG,X,FAAAA,FAAAB,        
     1                 FAAAC,FAAAD,F,FAAAE,FAAAF,FAAAG,FAAAH,DIFF       
      DIMENSION        X(6),FAAAA(20),FAAAB(20)        
C        
      FAAAC = 0.00001D0        
      IAAAA = 1        
      FAAAD = B        
      X(1)  = 0.0D0        
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
C        
C     DO 9986 IAAAD = 1,IAAAC        
      IAAAD = 0        
 9986 IAAAD = IAAAD+1        
      FAAAF = IAAAD        
      X(1) = (2.0*FAAAF-1.0)*FAAAD        
      ASSIGN 300 TO IRET        
      GO TO (1000,2000,3000), K        
  300 CONTINUE        
      FAAAE = FAAAE + F        
C9986 CONTINUE        
      IF (IAAAD .LT. IAAAC) GO TO 9986        
C        
      FAAAB(1) = 0.5*FAAAA(1) + FAAAD*FAAAE        
      IAAAA = IAAAA+1        
      DO 9985 IAAAD = 2,IAAAA        
      FAAAG = 4.0**(IAAAD-1)        
      FAAAH = FAAAG-1.0        
      IAAAF = IAAAD-1        
 9985 FAAAB(IAAAD) = (FAAAG*FAAAB(IAAAF) - FAAAA(IAAAF))/FAAAH        
      IAAAC = 2*IAAAC+1        
      DIFF  = FAAAB(IAAAA) - FAAAA(IAAAA-1)        
      IF (DABS(DIFF)-DABS(FAAAC*FAAAB(IAAAA))) 9979,9981,9981        
 9981 DO 9980 IAAAD = 1,IAAAA        
 9980 FAAAA(IAAAD)  = FAAAB(IAAAD)        
      IF (IAAAA.LT.15) GO TO 9988        
 9979 PRECIS = DIFF        
      ITDONE = IAAAA - 1        
      FINTG  = FAAAB(IAAAA)        
      RETURN        
C        
C     THIS CODE REPLACES D4K        
C        
 1000 CONTINUE        
      IF (X(1) .EQ.0.0D0) GO TO 1010        
      DEN = X(3) - X(2)*X(5)*(1.D0-DCOS(X(1))) + X(2)*X(4)*DSIN(X(1))   
      F   = X(1)**(X(6)-1.D0)*DSIN(X(1))**2/DEN        
      GO TO 1020        
 1010 F = 0.0D0        
 1020 GO TO IRET, (100,200,300)        
C        
C     THIS CODE REPLACES D5K        
C        
 2000 CONTINUE        
      IF (X(1) .EQ. 0.0D0) GO TO 2010        
      DEN = X(3) - X(2)*X(5)*(1.D0-DCOS(X(1))) + X(2)*X(4)*DSIN(X(1))   
      F   = X(1)**(X(6)-1.D0)*2.*DSIN(X(1))*DCOS(X(1))/DEN        
      GO TO 2020        
 2010 F=0.0D0        
 2020 GO TO IRET, (100,200,300)        
C        
C     THIS CODE REPLACES D6K        
C        
 3000 CONTINUE        
      DEN = X(3) - X(2)*X(5)*(1.D0-DCOS(X(1))) + X(2)*X(4)*DSIN(X(1))   
      IF (X(6) .EQ. 1.D0) CONST = 1.D0        
      IF (X(6) .NE. 1.D0) CONST = X(1)**(X(6)-1.D0)        
      IF (DEN .EQ. 0.0D0) GO TO 3010        
      F = CONST*DCOS(X(1))**2/DEN        
      GO TO 3020        
 3010 F = 0.0D0        
 3020 GO TO IRET, (100,200,300)        
      END        
