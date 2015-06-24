      SUBROUTINE SOLVER (LOWER,X,B,IN,OUT,EPS,IFL,SCR)        
C        
C    SOLVER PERFORMS THREE OPERATIONS--        
C    1. SOLVES FOR B BY FORWARD-BACKWARD SUBSTITUTION        
C    2. COMPUTES OUT = IN + B(T)*X        
C    3. IF REQUESTED, COMPUTES EPSILON = NORM(OUT)/NORM(IN)        
C        
      INTEGER         X     ,OUT   ,FILEL ,FILEU ,FILEB ,FILEX ,SCR    ,
     1                PREC  ,SIGN  ,FILEE ,FILEF ,FILEG ,FILEH ,T      ,
     2                SIGNC ,SIGNAB,PRECX ,EOL   ,EOR   ,SYSBUF,SCRTCH ,
     3                B     ,SCR1  ,NAME(2)        
      DOUBLE PRECISION       AD    ,NUM   ,DENOM        
      DIMENSION       FILEL(7)     ,FILEU(7)     ,FILEB(7)     ,        
     1                FILEX(7)     ,FILEE(7)     ,FILEF(7)     ,        
     2                FILEG(7)     ,FILEH(7)        
      CHARACTER       UFM*23,UWM*25        
      COMMON /XMSSG / UFM   ,UWM        
CZZ   COMMON /ZZSLVR/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /FBSX  / FILEL ,FILEU ,FILEB ,FILEX ,NZ    ,PREC  ,SIGN   ,
     1                SCR1        
      COMMON /MPYADX/ FILEE ,FILEF ,FILEG ,FILEH ,NZZ   ,T     ,SIGNAB ,
     1                SIGNC ,PRECX ,SCRTCH        
      COMMON /ZNTPKX/ AD(2) ,I     ,EOL   ,EOR        
      COMMON /SYSTEM/ KSYSTM(65)        
      EQUIVALENCE     (KSYSTM(1),SYSBUF)  ,(KSYSTM(55),IPREC)  ,        
     1                (KSYSTM(2),IOUTPT)        
C        
C     INITIALIZE MATRIX CONTROL BLOCKS FOR FORWARD-BACKWARD SOLUTION    
C        
      NZ = KORSZ(Z)        
      FILEL(1) = LOWER        
      CALL RDTRL (FILEL)        
      FILEB(1) = B        
      CALL RDTRL (FILEB)        
      CALL MAKMCB (FILEX,X,FILEB(3),FILEB(4),IPREC)        
      PREC = IPREC        
      SIGN = -1        
C        
C     SOLVE A*X = -B FOR X WHERE A HAS BEEN FACTORED        
C        
      SCR1 = SCR        
      CALL FBS (Z,Z)        
      CALL WRTTRL (FILEX)        
C        
C     INITIALIZE MATRIX CONTROL BLOCKS FOR MPYAD OPERATION        
C        
      DO 50 K = 1,7        
      FILEE(K) = FILEB(K)        
   50 FILEF(K) = FILEX(K)        
      FILEG(1) = IN        
      CALL RDTRL (FILEG)        
      CALL MAKMCB (FILEH,OUT,FILEG(3),FILEG(4),IPREC)        
      NZZ = NZ        
      T   = 1        
      SIGNAB = 1        
      SIGNC  = 1        
      PRECX  = IPREC        
      SCRTCH = SCR        
C        
C     COMPUTE OUT = IN + B(T)*X        
C        
      CALL MPYAD  (Z,Z,Z)        
      CALL WRTTRL (FILEH)        
C        
C     IF REQUESTED,COMPUTE EPS = NORM(OUT) / NORM(IN)        
C        
      IF (IFL .EQ. 0) RETURN        
      N1 = NZ - SYSBUF        
      N2 = N1 - SYSBUF        
      CALL GOPEN (OUT,Z(N1+1),0)        
      CALL GOPEN ( IN,Z(N2+1),0)        
      NUM   = 0.0D0        
      DENOM = 0.0D0        
      NCOL  = FILEG(2)        
      DO 130 K = 1,NCOL        
      CALL INTPK (*110,OUT,0,2,0)        
  100 CALL ZNTPKI        
      NUM = NUM + DABS(AD(1))*DABS(AD(1))        
      IF (EOL .EQ. 0) GO TO 100        
  110 CALL INTPK (*130,IN,0,2,0)        
  120 CALL ZNTPKI        
      DENOM = DENOM + DABS(AD(1))*DABS(AD(1))        
      IF (EOL .EQ. 0) GO TO 120        
  130 CONTINUE        
      IF (DENOM .EQ. 0.0D0) GO TO 160        
      EPS = DSQRT(NUM/DENOM)        
      GO TO 180        
  160 CALL FNAME (IN,NAME)        
      WRITE  (IOUTPT,170) UWM,NAME        
  170 FORMAT (A25,' 2401, ',2A4,' MATRIX IS NULL.  AN ARBITRARY VALUE ',
     1       'OF 1.0 IS THEREFORE ASSIGNED TO', /5X,        
     2       'THE RIGID BODY ERROR RATIO (EPSILON SUB E).')        
      EPS = 1.0        
  180 CALL CLOSE (IN, 1)        
      CALL CLOSE (OUT,1)        
      RETURN        
      END        
