      SUBROUTINE CFNOR2 (RIGHT,LEFT,SIZE2,OPTION,RI)        
C        
C     CFNOR2 IS A DOUBLE-PRECISION ROUTINE (CREATED FOR USE BY        
C     THE COMPLEX FEER METHOD) WHICH NORMALIZES A COMPLEX PAIR        
C     OF VECTORS TO MAGNITUDE UNITY        
C        
C     DEFINITION OF INPUT PARAMETERS        
C        
C     RIGHT    = ORIGINAL RIGHT-HANDED COMPLEX DOUBLE PRECISION VECTOR  
C     LEFT     = ORIGINAL LEFT -HANDED COMPLEX DOUBLE PRECISION VECTOR  
C     SIZE2    = LENGTH OF EITHER VECTOR IN DOUBLE PRECISION WORDS      
C                (I.E., TWICE THE LENGTH OF THE COMPLEX VECTORS)        
C     OPTION   = 0  NORMALIZE THE INPUT VECTORS, AND OUTPUT THE        
C                   SQUARE ROOT OF THE INNER PRODUCT IN RI(2)        
C              = 1  ONLY OUTPUT INNER-PRODUCT, IN RI(2)        
C              = 2  ONLY OUTPUT SQUARE ROOT OF INNER-PRODUCT, IN RI(2)  
C        
C     DEFINITION OF OUTPUT PARAMETERS        
C        
C     RIGHT    = NORMALIZED RIGHT-HANDED VECTOR        
C     LEFT     = NORMALIZED LEFT -HANDED VECTOR        
C     RI       = INNER-PRODUCT, OR SQUARE ROOT OF INNER-PRODUCT (SEE    
C                OPTION)        
C        
      LOGICAL          SKIP     ,QPR        
      INTEGER          SIZE2    ,OPTION        
      DOUBLE PRECISION RIGHT(1) ,LEFT(1)  ,RI(2)    ,RSQRT    ,        
     1                 THETA2   ,RJ(2)        
      CHARACTER        UFM*23   ,UWM*25        
      COMMON  /XMSSG / UFM      ,UWM        
      COMMON  /FEERXC/ DUMXC(21),QPR        
      COMMON  /SYSTEM/ KSYSTM(65)        
      EQUIVALENCE      (KSYSTM(2),NOUT)        
C        
      SKIP = .FALSE.        
C        
C     COMPUTE INNER PRODUCT (LEFT*RIGHT)        
C        
    5 RI(1) = 0.D0        
      RI(2) = 0.D0        
      DO 10 I = 1,SIZE2,2        
      J = I + 1        
      RI(1) = RI(1) + LEFT(I)*RIGHT(I) - LEFT(J)*RIGHT(J)        
   10 RI(2) = RI(2) + LEFT(J)*RIGHT(I) + LEFT(I)*RIGHT(J)        
      IF (OPTION .EQ. 1) GO TO 50        
      IF (SKIP) GO TO 200        
C        
C     COMPUTE MAGNITUDE OF SQUARE ROOT        
C        
      RSQRT = DSQRT(DSQRT(RI(1)**2 + RI(2)**2))        
      IF (RSQRT .GT. 0.D0) GO TO 30        
      WRITE  (NOUT,20) UWM        
   20 FORMAT (A25,' 3162', //5X,'ATTEMPT TO NORMALIZE NULL VECTOR. ',   
     1        'NO ACTION TAKEN.'//)        
      GO TO 50        
C        
C     COMPUTE MODULUS OF SQUARE ROOT        
C        
   30 THETA2 = .5D0*DATAN2(RI(2),RI(1))        
C        
C     COMPUTE REAL AND IMAGINARY PARTS OF SQUARE ROOT OF INNER PRODUCT  
C        
      RI(1) = RSQRT*DCOS(THETA2)        
      RI(2) = RSQRT*DSIN(THETA2)        
      IF (OPTION .EQ. 2) GO TO 50        
      RJ(1) = RI(1)        
      RJ(2) = RI(2)        
C        
C     INVERT THE ABOVE COMPLEX NUMBER (THETA2 IS DUMMY)        
C        
      THETA2= 1.D0/(RI(1)**2 + RI(2)**2)        
      RI(1) = RI(1)*THETA2        
      RI(2) =-RI(2)*THETA2        
C        
C     NORMALIZE THE INPUT VECTORS        
C        
      DO 40 I = 1,SIZE2,2        
      J = I + 1        
      THETA2   = RIGHT(I)        
      RIGHT(I) = RI(1)*RIGHT(I) - RI(2)*RIGHT(J)        
      RIGHT(J) = RI(2)*THETA2   + RI(1)*RIGHT(J)        
      THETA2   = LEFT(I)        
      LEFT(I)  = RI(1)*LEFT(I)  - RI(2)*LEFT(J)        
   40 LEFT(J)  = RI(2)*THETA2   + RI(1)*LEFT(J)        
C        
C     ----------- SPECIAL PRINT ----------------------------------------
      IF (.NOT.QPR) GO TO 45        
      SKIP = .TRUE.        
      GO TO 5        
  200 THETA2 = DSQRT(RI(1)**2 + RI(2)**2)        
      WRITE  (NOUT,300) THETA2,RI        
  300 FORMAT (3H --,32(4H----), /,7H CFNOR2,26X,        
     1       16HOUTPUT MAGNITUDE,D16.8,8X,2D16.8, /,3H --,32(4H----))   
      WRITE  (NOUT,400) (RIGHT(I),I=1,SIZE2)        
  400 FORMAT ((1H ,4D25.16))        
      WRITE  (NOUT,500)        
  500 FORMAT (3H --,32(4H----))        
      WRITE  (NOUT,400) (LEFT(I),I=1,SIZE2)        
      WRITE  (NOUT,500)        
C     ------------------------------------------------------------------
C        
   45 RI(1) = RJ(1)        
      RI(2) = RJ(2)        
   50 RETURN        
      END        
