      LOGICAL FUNCTION TAPBIT (FILE)        
C        
      EXTERNAL  ANDF        
      INTEGER   FIST,XFIAT,FIAT,FILE,ANDF,NAM(2)        
      COMMON   /XXFIAT/ XFIAT(1)        
     1         /XPFIST/ NPFIST        
     2         /XFIST / NFIST,LFIST,FIST(1)        
     3         /XFIAT / MFIAT,NFIAT,LFIAT,FIAT(1)        
      COMMON   /SYSTEM/ IB(45)        
      COMMON   /TWO   / ITWO(32)        
      DATA      NAM   / 4HTAPB,4HIT   /        
C        
      TAPBIT = .TRUE.        
      DO 10 J = 1,NPFIST        
      IF (FIST(2*J-1) .EQ. FILE) GO TO 20        
   10 CONTINUE        
      NPF1 = NPFIST + 1        
      DO 15 J = NPF1,LFIST        
      IF (FIST(2*J-1) .EQ. FILE) GO TO 30        
   15 CONTINUE        
      CALL MESAGE (-21,FILE,NAM)        
C        
   20 J = -FIST(2*J)        
      IF (ANDF(ITWO(32-J),IB(45)) .NE. 0) RETURN        
      IF (ANDF(XFIAT(J+1),32768)  .EQ. 0) TAPBIT = .FALSE.        
      RETURN        
C        
   30 J = FIST(2*J)        
      IF (ANDF(FIAT(J+1),32768) .EQ. 0) TAPBIT = .FALSE.        
      RETURN        
      END        
