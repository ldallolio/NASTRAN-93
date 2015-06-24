      SUBROUTINE IFP1S (LIST,ISTOR,NLIST)        
C        
C     THIS ROUTINE FINDS ANY OVERLAPPING INTERVALS IN A SET LIST.       
C     IT WILL ALSO CHECK SINGLES        
C        
      INTEGER         OTPE        
      DIMENSION       LIST(1),ISTOR(1)        
      CHARACTER       UFM*23,UWM*25        
      COMMON /XMSSG / UFM,UWM        
      COMMON /SYSTEM/ SYSBUF,OTPE,INX(6),NLPP,INX1(2),LINE        
C        
      IPAIR = 0        
      DO 100 I = 1,NLIST        
      IF (LIST(I) .GT. 0) GO TO 100        
   10 IF (IPAIR   .NE. 0) GO TO 40        
   20 L = 2*IPAIR + 1        
      ISTOR(L  ) = LIST(I-1)        
      ISTOR(L+1) = LIST(I  )        
      IPAIR = IPAIR + 1        
   30 LIST(I  ) = 0        
      LIST(I-1) = 0        
      GO TO 100        
C        
C     PAIR FOUND - CHECK FOR OVERLAP        
C        
   40 L  = 1        
      IN = IABS(LIST(I-1))        
      IOUT = IABS(LIST(I  ))        
      K  = 2*L - 1        
   50 IF (IN.GE.ISTOR(K)   .AND. IN.LE.IABS(ISTOR(K+1))  ) GO TO 60     
      IF (IOUT.GE.ISTOR(K) .AND. IOUT.LE.IABS(ISTOR(K+1))) GO TO 60     
      L  = L + 1        
      IF (L .LE. IPAIR) GO TO 50        
C        
C     STORE NEW PAIR IN LIST        
C        
      GO TO 20        
C        
C     ERROR IN INTERVAL        
C        
   60 LIST(I-1) = MIN0(IN,ISTOR(K))        
      LIST(I  ) =-MAX0(IOUT,IABS(ISTOR(K+1)))        
      IF (LIST(I-1).EQ.ISTOR(K) .AND. LIST(I).EQ.ISTOR(K+1)) GO TO 30   
      IX = IABS(ISTOR(K+1))        
      WRITE  (OTPE,70) UWM,IN,IOUT,ISTOR(K),IX        
   70 FORMAT (A25,' 621, INTERVAL',I8,' THRU',I8,' OVERLAPS INTERVAL',  
     1       I8,' THRU', I8,'. THE MAXIMUM INTERVAL WILL BE USED.')     
      LINE = LINE + 3        
      IF (LINE .GE. NLPP) CALL PAGE        
C        
C     REMOVE PAIR L FROM ISTOR        
C        
   80 IF (L .GE. IPAIR) GO TO 90        
      M = 2*L + 1        
      K = 2*L - 1        
      ISTOR(K  ) = ISTOR(M  )        
      ISTOR(K+1) = ISTOR(M+1)        
      L = L + 1        
      GO TO 80        
   90 IPAIR = IPAIR - 1        
      GO TO 10        
  100 CONTINUE        
C        
C     ALL PAIRS PROCESSED - TRY SINGLES        
C        
      ISING = 0        
      M  = 2*IPAIR        
      DO 180 I = 1,NLIST        
      IN = LIST(I)        
      IF (IPAIR   .EQ. 0) GO TO 140        
      IF (LIST(I) .EQ. 0) GO TO 180        
C        
C     CHECK EACH PAIR        
C        
      L = 1        
  110 K = 2*L - 1        
      IF (IN.GE.ISTOR(K) .AND. IN.LE.IABS(ISTOR(K+1))) GO TO 120        
      L = L + 1        
      IF (L-IPAIR) 110,110,140        
C        
C     ERROR -- PAIR CONTAINS SINGLE        
C        
  120 IN1 = IABS(ISTOR(K+1))        
      WRITE  (OTPE,130) UWM,IN,ISTOR(K),IN1        
  130 FORMAT (A25,' 619, SET MEMBER',I8,' BELONGS TO',I8,' THRU',I8)    
      LINE = LINE + 3        
      IF (LINE .GE. NLPP) CALL PAGE        
      GO TO 180        
C        
C     CHECK FOR DUPLICATE SINGLES        
C        
  140 IF (ISING .EQ. 0) GO TO 170        
      DO 160 K = 1,ISING        
      L = 2*IPAIR + K        
      IF (IN .NE. ISTOR(L)) GO TO 160        
      WRITE  (OTPE,150) UWM,IN        
  150 FORMAT (A25,' 620, SET MEMBER',I8,' IS DUPLICATED IN SET LIST.')  
      LINE = LINE + 3        
      IF (LINE .GE. NLPP) CALL PAGE        
      GO TO 180        
  160 CONTINUE        
  170 M = M + 1        
      ISING = ISING + 1        
      ISTOR(M) = IN        
  180 CONTINUE        
C        
C     COPY GOOD STUFF INTO LIST        
C        
      DO 190 I = 1,M        
  190 LIST(I) = ISTOR(I)        
      NLIST = M        
C        
C     SORT LIST        
C        
      N1 = M - 1        
      DO 230 I = 1,N1        
      N2 = I + 1        
      DO 220 K = N2,M        
      IF (IABS(LIST(I))-IABS(LIST(K))) 220,220,210        
C        
C     SWITCH        
C        
  210 IN = LIST(I)        
      LIST(I) = LIST(K)        
      LIST(K) = IN        
  220 CONTINUE        
  230 CONTINUE        
C        
      RETURN        
      END        
