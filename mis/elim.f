      SUBROUTINE ELIM (IN1,IN2,IN3,IN4,OUT1,SCR1,SCR2,SCR3)        
C        
C     ELIM EVALUATES THE MATRIX EQUATION -        
C        
C     OUT1 = IN1 + IN4(T)*IN2 + IN2(T)*IN4 + IN4(T)*IN3*IN4        
C        
      INTEGER         OUT1  ,SCR1  ,SCR2  ,SCR3  ,FILEA ,FILEB ,FILEC  ,
     1                FILED ,T     ,SIGNAB,SIGNC ,PREC  ,RDP   ,PLUS   ,
     2                SCRTCH        
      DIMENSION       FILEA(7)     ,FILEB(7)     ,FILEC(7)     ,FILED(7)
C    1,               MCB(7)        
      COMMON /MPYADX/ FILEA ,FILEB ,FILEC ,FILED ,NZ    ,T     ,SIGNAB ,
     1                SIGNC ,PREC  ,SCRTCH        
      COMMON /SYSTEM/ IDUM(54)     ,IPREC        
CZZ   COMMON /ZZELIM/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      DATA    PLUS  / +1 /        
C        
      RDP = IPREC        
C        
C     PERFORM GENERAL INITIALIZATION        
C        
      NZ     = KORSZ(Z)        
      SIGNAB = PLUS        
      SIGNC  = PLUS        
      PREC   = RDP        
      SCRTCH = SCR3        
C        
C     INITIALIZE MATRIX CONTROL BLOCKS FOR IN3,IN4,IN2 AND SCR1        
C        
      FILEA(1) = IN3        
      CALL RDTRL (FILEA)        
      FILEB(1) = IN4        
      CALL RDTRL (FILEB)        
      FILEC(1) = IN2        
      CALL RDTRL (FILEC)        
      FILED(1) = SCR1        
      FILED(3) = FILEC(3)        
      FILED(4) = FILEC(4)        
      FILED(5) = RDP        
C        
C     COMPUTE SCR1 = IN3*IN4 + IN2        
C        
      T = 0        
      CALL MPYAD (Z,Z,Z)        
C        
C     SAVE MATRIX CONTROL BLOCK FOR SCR1        
C        
C     DO 41 I = 1,7        
C  41 MCB(I) = FILED(I)        
      CALL WRTTRL (FILED)        
C        
C     INITIALIZE MATRIX CONTROL BLOCKS FOR IN2, IN4, IN1 AND SCR2       
C        
      DO 51 I = 1,7        
   51 FILEA(I) = FILEC(I)        
      FILEC(1) = IN1        
      CALL RDTRL (FILEC)        
      FILED(1) = SCR2        
      FILED(3) = FILEC(3)        
      FILED(4) = FILEC(4)        
C        
C     COMPUTE SCR2 = IN2(T)*IN4 + IN1        
C        
      T = 1        
      CALL MPYAD  (Z,Z,Z)        
      CALL WRTTRL (FILED)        
C        
C     INITIALIZE MATRIX CONTROL BLOCKS FOR IN4,SCR1,SCR2 AND OUT1       
C        
C     DO 71 I = 1,7        
C     FILEA(I) = FILEB(I)        
C     FILEB(I) = MCB(I)        
C  71 FILEC(I) = FILED(I)        
      FILEA(1) = FILEB(1)        
      FILEB(1) = SCR1        
      FILEC(1) = FILED(1)        
      CALL RDTRL (FILEA)        
      CALL RDTRL (FILEB)        
      CALL RDTRL (FILEC)        
      FILED(1) = OUT1        
      FILED(3) = FILEC(3)        
      FILED(4) = FILEC(4)        
C        
C     COMPUTE  OUT1= IN4(T)*SCR1 + SCR2        
C        
      T = 1        
      CALL MPYAD (Z,Z,Z)        
C        
C     WRITE TRAILER FOR OUT1 AND RETURN        
C        
      CALL WRTTRL (FILED)        
      RETURN        
      END        
