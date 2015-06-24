      SUBROUTINE TRIF (XC,YC,ZC,IVECT,JVECT,KVECT,A,B,C,ID,ELEM)        
C        
C     CALCULATEIONS FOR THE TRIANGLE USED IN TRIM6,TRPLT1,TRSHL - THE HI
C     LEVEL PLATE ELEMENTS.  COMPUTATIONS IN SINGLE PRECISION ONLY      
C        
C     IVECT, JVECT, AND KVECT ARE UNIT VECTORS OF THE TRIANGLE        
C     B IS THE DISTANCE OF THE GRID POINT 1        
C     A IS THE DISTANCE OF THE GRID POINT 3        
C     C IS THE DISTANCE OF THE GRID POINT 5        
C        
      LOGICAL         NOGO        
      REAL            IVECT(3),JVECT(3),KVECT(3),XC(6),YC(6),ZC(6),     
     1                ELEM(2)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /SYSTEM/ IBUF,NOUT,NOGO        
C        
C     EVALUATE DIRECTIONAL COSINES        
C        
      X1 = XC(3) - XC(1)        
      Y1 = YC(3) - YC(1)        
      Z1 = ZC(3) - ZC(1)        
      X2 = XC(5) - XC(1)        
      Y2 = YC(5) - YC(1)        
      Z2 = ZC(5) - ZC(1)        
      TEMP = X1*X1 + Y1*Y1 + Z1*Z1        
      IF (TEMP .LE. 1.0E-10) GO TO 40        
      TEMP = SQRT(TEMP)        
C        
C     I-VECTOR        
C        
      IVECT(1) = X1/TEMP        
      IVECT(2) = Y1/TEMP        
      IVECT(3) = Z1/TEMP        
      SAVE = TEMP        
C        
C     NON-NORMALIZED K-VECTOR        
C        
      KVECT(1) = IVECT(2)*Z2 - Y2*IVECT(3)        
      KVECT(2) = IVECT(3)*X2 - Z2*IVECT(1)        
      KVECT(3) = IVECT(1)*Y2 - X2*IVECT(2)        
      TEMP = SQRT(KVECT(1)**2 + KVECT(2)**2 + KVECT(3)**2)        
      IF (TEMP .LE. 1.0E-10) GO TO 50        
C        
C     NORMALIZE K-VECTOR        
C     DISTANCE C OF THE TRAINGLE IS TEMP        
C        
      KVECT(1) = KVECT(1)/TEMP        
      KVECT(2) = KVECT(2)/TEMP        
      KVECT(3) = KVECT(3)/TEMP        
      C = TEMP        
C        
C     J-VECTOR = K X I VECTORS        
C        
      JVECT(1) = KVECT(2)*IVECT(3) - IVECT(2)*KVECT(3)        
      JVECT(2) = KVECT(3)*IVECT(1) - IVECT(3)*KVECT(1)        
      JVECT(3) = KVECT(1)*IVECT(2) - IVECT(1)*KVECT(2)        
      TEMP = SQRT(JVECT(1)**2 + JVECT(2)**2 + JVECT(3)**2)        
      IF (TEMP .LE. 1.0E-10) GO TO 60        
C        
C     NORMALIZE J-VECTOR TO MAKE SURE        
C        
      JVECT(1) = JVECT(1)/TEMP        
      JVECT(2) = JVECT(2)/TEMP        
      JVECT(3) = JVECT(3)/TEMP        
C        
C     DISTANCE B OF THE TRIANGLE IS OBTAINED BY DOTTING (X2,Y2,Z2) WITH 
C     THE IVECT UNIT VECTOR        
C        
      B = X2*IVECT(1) + Y2*IVECT(2) + Z2*IVECT(3)        
C        
C     THE LOCAL X AND Y COORINATES OF THE SIX GRID PTS. ARE AS FOLLOWS  
C        
      YC(1) = 0.0        
      YC(2) = 0.0        
      YC(3) = 0.0        
      YC(4) = C*0.5        
      YC(5) = C        
      YC(6) = YC(4)        
C        
C     THE TRIANGLE SHOULD BELONG TO        
C        
C     KASE1 (ACUTE ANGLES AT GRID POINTS 1 AND 3),        
C     KASE2 (OBTUSE ANGLE AT GRID POINT 3), OR        
C     KASE3 (OBTUSE ANGLE AT GRID POINT 1)        
C        
C     KASE  = 1        
C     IF (B .GT. SAVE) KASE = 2        
C     IF (B .LT.  0.0) KASE = 3        
      TEMP  = -B        
C     IF (KASE .EQ. 3) TEMP = ABS(B)        
C     IF (B .LT.  0.0) TEMP = ABS(B)        
      XC(1) = TEMP        
      XC(2) = TEMP + SAVE*0.5        
      XC(3) = TEMP + SAVE        
      XC(4) = XC(3)*0.5        
      XC(5) = 0.0        
      XC(6) = XC(1)*0.5        
C        
C     RE-SET DISTANCE A AND B        
C        
      B = ABS(B)        
      A = ABS(XC(3))        
      RETURN        
C        
C     GEOMETRY ERRORS        
C        
 40   WRITE (NOUT,140) UFM,ELEM,ID        
      GO TO 80        
 50   WRITE (NOUT,150) UFM,ELEM,ID        
      GO TO 80        
 60   WRITE (NOUT,160) UFM,ELEM,ID        
 80   NOGO = .TRUE.        
C        
 140  FORMAT (A23,' 2404, GRID POINTS 1 AND 3 OF ',A4,A2,        
     1       ' WITH ELEMENT ID =',I9,' HAVE SAME COORDINATES.')        
 150  FORMAT (A23,' 2405, GRID POINTS 1, 3, AND 5 OF ',A4,A2,' WITH ',  
     1       'ELEMENT ID =',I9,' APPEAR TO BE ON A STRAIGHT LINE.')     
 160  FORMAT (A23,' 2406, GRID POINTS 1 AND 5 OF ',A4,A2,        
     1       ' WITH ELEMENT ID =',I9,' HAVE SAME COORDINATES.')        
      RETURN        
      END        
