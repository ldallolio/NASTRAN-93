      SUBROUTINE GELOOP(RBUF,BUF,XX,YY,ZZ,HC1,HC2,HC3)
C
C GELOOP COMPUTES MAGNETIC FIELD COMPONENTS HC1,HC2,HC3(IN BASIC
C COORDS. AT XX,YY,ZZ DUE TO GEMLOOP CARD. DATA FIELDS(EXCEPT SET ID)
C OF GEMLOOP ARE IN RBUF=REAL AND BUF=INTEGER
C
      INTEGER BUF(50),TI1,TI2
      DIMENSION RBUF(50),ZI(3),ZJ(3),ZK(3),ZJXI(3)
      DATA FPI/12.566371/                                               
C                                                                       
      HC1=0.
      HC2=0.
      HC3=0.
C
      XI=RBUF(1)
C
C ICID IS 0 FOR NOW AND UNUSED
C
      ICID=BUF(2)
      NPTS=BUF(3)
      NPTSM1=NPTS-1
      DO 10 I=1,NPTSM1
C
C 2 CONSECUTIVE POINTS DEFINE A SEGMENT OF A COIL. LET ZI BE THE VECTOR
C FROM 1ST POINT OF SEGMENT TO 2ND. LET ZJ BE VECTOR FROM FILED POINT
C XX,YY,ZZ TO 1ST POINT OF SEGMENT. ZK IS VECTOR FROM FILED POINT
C TO 2ND POINT. IF THE FILED POINT LIES ON A SEGMENT, IGNORE THE
C COMPUTATION FOR THAT SEGMENT FOR THAT POINT
C
      TI1=3*I+3
      TI2=3*(I+1)+3
      ZI(1)=RBUF(TI2-2)-RBUF(TI1-2)
      ZI(2)=RBUF(TI2-1)-RBUF(TI1-1)
      ZI(3)=RBUF(TI2)-RBUF(TI1)
      ZJ(1)=RBUF(TI1-2)-XX
      ZJ(2)=RBUF(TI1-1)-YY
      ZJ(3)=RBUF(TI1)-ZZ
      ZK(1)=RBUF(TI2-2)-XX
      ZK(2)=RBUF(TI2-1)-YY
      ZK(3)=RBUF(TI2)-ZZ
C
      ZKL=SQRT(ZK(1)**2+ZK(2)**2+ZK(3)**2)
      IF(ZKL.LT.1.E-8)GO TO 10
      ZJL=SQRT(ZJ(1)**2+ZJ(2)**2+ZJ(3)**2)
      IF(ZJL.LT.1.E-8)GO TO 10
      ZDOT=0.
      DO 5 II=1,3
      ZDOT=ZDOT+ZI(II)*(ZK(II)/ZKL-ZJ(II)/ZJL)
    5 CONTINUE
      ZJXI(1)=ZJ(2)*ZI(3)-ZJ(3)*ZI(2)
      ZJXI(2)=ZJ(3)*ZI(1)-ZJ(1)*ZI(3)
      ZJXI(3)=ZJ(1)*ZI(2)-ZJ(2)*ZI(1)
      ZLEN2=ZJXI(1)**2+ZJXI(2)**2+ZJXI(3)**2
      IF(ZLEN2.LT.1.E-8)GO TO 10
      FACTOR=XI*ZDOT/FPI/ZLEN2
      HC1=HC1+ZJXI(1)*FACTOR
      HC2=HC2+ZJXI(2)*FACTOR
      HC3=HC3+ZJXI(3)*FACTOR
   10 CONTINUE
      RETURN
      END
