      SUBROUTINE LINKUP (*,NAME)        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF,COMPLF        
      DIMENSION       NAME(2)        
      COMMON /MACHIN/ MACHX        
      COMMON /LNKLST/ ITOP,IBOT,ISN,KIND,ITYPE,MASK1,MASK2,MASK3        
CZZ   COMMON /ZZXGPI/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
C        
C     HASH INTO TABLE        
C        
      GO TO (10,10,10,20,30,30,30,30,30,30,   30,40,30,40,40,30,30,30,  
     1       30,30,   30,30), MACHX        
C        
C     IBM AND UNIVAC        
C        
   10 ITOTAL = NAME(1) + NAME(2)        
      GO TO 50        
C        
C     60-BIT MACHINE        
C        
   20 ITOTAL = RSHIFT(NAME(1),18) + RSHIFT(NAME(2),18)        
      GO TO 50        
C        
C     32-BIT MACHINES        
C        
   30 ITOTAL = RSHIFT(NAME(1), 1) + RSHIFT(NAME(2), 1)        
      GO TO 50        
C        
C     64-BIT MACHINES        
C        
   40 ITOTAL = RSHIFT(NAME(1),32) + RSHIFT(NAME(2),32)        
C        
   50 IHASH = 4*IABS(MOD(ITOTAL,250)) + 4        
      K = ANDF(Z(IHASH),MASK1)        
      IF (K.NE.0) GO TO 60        
C        
C     NO HASH CHAIN FOUND - CREATE CHAIN        
C        
      Z(IHASH) = Z(IHASH) + ITOP        
      GO TO 90        
C        
C     HASH CHAIN FOUND - CHECK PRESENCE OF NAME        
C        
   60 IF (Z(K).NE.NAME(1) .OR. Z(K+1).NE.NAME(2)) GO TO 70        
      IKIND = RSHIFT(ANDF(Z(K+3),MASK3),28)        
      IF ((IKIND+1)/2 .EQ. (KIND+1)/2) GO TO 100        
   70 L = ANDF(Z(K+3),MASK2)        
      IF (L .EQ. 0) GO TO 80        
      K = RSHIFT(L,14)        
      GO TO 60        
   80 Z(K+3) = Z(K+3) + LSHIFT(ITOP,14)        
C        
C     NO ENTRY FOUND - CREATE ENTRY        
C        
   90 Z(ITOP  ) = NAME(1)        
      Z(ITOP+1) = NAME(2)        
      Z(ITOP+2) = LSHIFT(ITYPE,28)        
      Z(ITOP+3) = Z(ITOP+3) + LSHIFT(IABS(KIND),28)        
      ITOP = ITOP + 4        
      IF (ITOP .GE. IBOT) RETURN 1        
      IF (KIND .LT.    0) RETURN        
      K = ITOP - 4        
C        
C     ADD STATEMENT NUMBER TO LIST        
C        
  100 L = ANDF(Z(K+2),MASK1)        
      IF (L .NE. 0) GO TO 110        
C        
C     LIST IS EMPTY - START LIST        
C        
      Z(K+2) = Z(K+2) + IBOT        
      GO TO 120        
C        
C     CHAIN ENTRY ON LIST        
C        
  110 L    = RSHIFT(ANDF(Z(K+2),MASK2),14)        
      Z(L) = ANDF(Z(L),COMPLF(MASK2))        
      Z(L) = ORF(Z(L),LSHIFT(IBOT,14))        
C        
C     ADD ENTRY TO LIST        
C        
  120 Z(IBOT)= ORF(LSHIFT(KIND,28),ISN)        
      Z(K+2) = ANDF(Z(K+2),COMPLF(MASK2))        
      Z(K+2) = Z(K+2) + LSHIFT(IBOT,14)        
      IBOT   = IBOT - 1        
      IF (ITOP .GE. IBOT) RETURN 1        
      RETURN        
      END        
