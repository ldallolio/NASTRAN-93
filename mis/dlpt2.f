      SUBROUTINE DLPT2 (INPUT,W1JK,W2JK)        
C        
      INTEGER         W1JK,W2JK,SYSBUF,ECORE,TW1JK,TW2JK,NAME(2)        
      DIMENSION       A(2),NP(4),IZ(1)        
      COMMON /PACKX / ITI,ITO,II,NN,INCR        
      COMMON /AMGP2 / TW1JK(7),TW2JK(7)        
      COMMON /AMGMN / MCB(7),NROW,ND,NE,REFC,FMACH,RFK        
      COMMON /SYSTEM/ SYSBUF        
CZZ   COMMON /ZZDLPT/ WORK(1)        
      COMMON /ZZZZZZ/ WORK(1)        
      EQUIVALENCE     (NP(2),NSTRIP),(NP(3),NTP)        
      EQUIVALENCE     (WORK(1),IZ(1))        
      DATA     NAME / 4HDLPT,4H2   /        
C        
C     READ IN NP,NSIZE,NTP,F        
C        
      CALL READ(*999,*999,INPUT,NP,4,0,N)        
C        
C     COMPUTE POINTERS AND SEE IF THERE IS ENOUGH CORE        
C        
      ECORE = KORSZ(IZ)        
      ECORE = ECORE - 4*SYSBUF        
      NN = II +1        
      INC = 0        
      INB = INC + NP(1)        
      IYS = INB + NP(1)        
      IZS = IYS + NSTRIP        
      IEE = IZS + NSTRIP        
      ISG = IEE + NSTRIP        
      ICG = ISG + NSTRIP        
      IXIC = ICG + NSTRIP        
      IDELX = IXIC + NTP        
      IXLAM = IDELX + NTP        
      NREAD = IXLAM + NTP        
C        
C     FILL IN DATA        
C        
      IF(NREAD.GT. ECORE) GO TO 998        
      CALL READ(*999,*999,INPUT,WORK,NREAD,1,N)        
C        
C     COMPUTE TERMS AND PACK        
C        
      DO 10 I = 1,NTP        
      A(1) = 0.0        
      A(2) = 1.0        
      CALL PACK(A,W1JK,TW1JK)        
      A(1) = -(2.0/REFC)        
      A(2)=WORK(IDELX+I) / (2.0*REFC)        
      CALL PACK(A,W2JK,TW2JK)        
C        
C     BUMP PACK INDEXES        
C        
      II = II +2        
      IF(I.EQ.NTP) GO TO 10        
      NN = NN + 2        
   10 CONTINUE        
      RETURN        
C        
C     ERROR MESSAGES        
C        
C     NOT ENOUGH CORE        
  998 CALL MESAGE(-8,0,NAME)        
C     FILE NOT POSITIONED PROPERLY        
  999 CALL MESAGE(-7,0,NAME)        
      RETURN        
      END        
