      SUBROUTINE PLOAD
C
      INTEGER         NAME(2),GRIDP,PONT
      DIMENSION       GRIDP(5),IGPCO(4,4),GPCO1(3),GPCO2(3),GPCO3(3),
     1                PONT(4),IORD(4),VECT(3),VECT1(3),VECT2(3),
     2                PLOADS(3,4),GPCO4(3),VECT3(3)
      COMMON /LOADX / LCORE,SLT,BGPDT,OLD,CSTM,NN(11),NOBLD
      COMMON /SYSTEM/ KSYS(87),KSYS88
CZZ   COMMON /ZZSSA1/ CORE(1)
      COMMON /ZZZZZZ/ CORE(1)
      EQUIVALENCE     (PMAG,GRIDP(1)),
     1                (IGPCO(2,1),GPCO1(1)),(IGPCO(2,2),GPCO2(1)),
     2                (IGPCO(2,3),GPCO3(1)),(IGPCO(2,4),GPCO4(1))
      DATA    NAME  / 4HPLOA,4HD   /, PI / 3.141592654 /
C
C
      DO 10 I = 1,3
   10 PLOADS(I,4) = 0.0
      CALL READ (*150,*150,SLT,GRIDP(1),5,0,FLAG)
      PONT(1) = GRIDP(2)
      PONT(2) = GRIDP(3)
      PONT(3) = GRIDP(4)
      PONT(4) = GRIDP(5)
      N1 = 4
      IF (GRIDP(5) .EQ. 0) N1 = 3
      CALL PERMUT (PONT(1),IORD(1),N1,OLD)
      DO 20 I = 1,N1
      L = IORD(I)
   20 CALL FNDPNT (IGPCO(1,L),PONT(L))
      IF (N1 .EQ. 4) GO TO 160
C
C     THREE  POINTS
C
      DO 30 I = 1,3
      VECT3(I) = GPCO1(I) - GPCO2(I)
      VECT2(I) = GPCO3(I) - GPCO1(I)
   30 VECT1(I) = GPCO2(I) - GPCO3(I)
      CALL CROSS (VECT3(1),VECT1(1),VECT(1))
C
      DO 40 I = 1,3
      DO 40 J = 1,3
   40 PLOADS(J,I) = -VECT(J)
C
      IF (KSYS88 .EQ. 1) GO TO 50
C
C     KSYS88 = 0, PRESSURE LOAD IS DISTRIBUTED EVENLY (ONE-THIRD) TO
C     EACH OF THE 3 GRID POINTS. TRIANGULAR GEOMETRY IS NOT CONSIDERED.
C
      PMAG    = PMAG/6
      VECT(1) = PMAG
      VECT(2) = PMAG
      VECT(3) = PMAG
      GO TO 80
C
C     IMPLEMENTED BY G.CHAN/UNISYS   3/1990
C     KSYS88 = 1, PRESSURE LOAD IS DISTRIBUTED PROPORTIONALLY TO THE
C     THREE ANGLE SIZES.
C     E.G. A 45-90-45 DEGREE TRIANGLE ELEMENT WILL HAVE TWICE THE LOAD
C     AT THE 90 DEGREE ANGLE TO THAT OF THE 45 DEGREE ANGLE.
C     RECTANGULAR ELEMENT (4 POINTS) IS NOT AFFECTED
C
C     GET AREA(2X), SIDES (VI) AND ANGLES (AI) OF THE TRIANGLE
C
   50 CONTINUE
      AREA = SQRT(VECT (1)**2 + VECT (2)**2 + VECT (3)**2)
      V1   = SQRT(VECT1(1)**2 + VECT1(2)**2 + VECT1(3)**2)
      V2   = SQRT(VECT2(1)**2 + VECT2(2)**2 + VECT2(3)**2)
      V3   = SQRT(VECT3(1)**2 + VECT3(2)**2 + VECT3(3)**2)
C
C     CHOOSE AN ANGLE, WHICH IS NOT THE LARGEST, TO START COMPUTING
C     THE THREE ANGLES
C
      IF (V2.GT.V1 .AND. V2.GT.V3) GO TO 60
      SIN2 = AREA/(V3*V1)
      SIN1 = V1*SIN2/V2
      SIN3 = V3*SIN2/V2
      A2   = ASIN(SIN2)
      IF (SIN1 .GE. 0.0) A1 = ASIN(SIN1)
      IF (SIN3 .GE. 0.0) A3 = ASIN(SIN3)
      IF (V1 .GT. V3) A1 = PI - A2 - A3
      IF (V3 .GT. V1) A3 = PI - A2 - A1
      GO TO 70
C
   60 SIN3 = AREA/(V2*V1)
      SIN2 = V2*SIN3/V3
      SIN1 = V1*SIN3/V3
      A3   = ASIN(SIN3)
      IF (SIN2 .GE. 0.0) A2 = ASIN(SIN2)
      IF (SIN1 .GE. 0.0) A1 = ASIN(SIN1)
      IF (V1 .GT. V2) A1 = PI - A3 - A2
      IF (V2 .GT. V1) A2 = PI - A3 - A1
   70 PMAG    = 0.5*PMAG/PI
      VECT(1) = PMAG*A1
      VECT(2) = PMAG*A2
      VECT(3) = PMAG*A3
C
C     TRANSFORM TO GLOBAL AND ADD CONTRIBUTIONS
C
   80 DO 130 I = 1,N1
      DO 90  J = 1,3
      IF (N1 .EQ. 4) PLOADS(J,I) = -PLOADS(J,I)*PMAG
      IF (N1 .EQ. 3) PLOADS(J,I) = -PLOADS(J,I)*VECT(I)
   90 CONTINUE
      IF (IGPCO(1,I) .NE. 0) CALL BASGLB (PLOADS(1,I),PLOADS(1,I),
     1                                    IGPCO(2,I),IGPCO(1,I))
      CALL FNDSIL (PONT(I))
      DO 120 J = 1,3
      IN = PONT(I) + J - 1
      CORE(IN) = PLOADS(J,I) + CORE(IN)
  120 CONTINUE
  130 CONTINUE
  140 RETURN
C
  150 CALL MESAGE (-1,SLT,NAME)
      GO TO 140
C
C     FOUR  POINTS
C
C
C     TRIANGLE  1,2,3
C
  160 DO 170 I = 1,3
      VECT1(I) = GPCO1(I) - GPCO2(I)
  170 VECT2(I) = GPCO3(I) - GPCO2(I)
      CALL CROSS (VECT1(1),VECT2(1),VECT(1))
      DO 180 I = 1,3
      DO 180 J = 1,3
  180 PLOADS(J,I) = VECT(J)
C
C     TRIANGLE  2,3,4
C
      DO 190 I  =1,3
      VECT1(I) = GPCO2(I) - GPCO3(I)
  190 VECT2(I) = GPCO4(I) - GPCO3(I)
      CALL CROSS (VECT1(1),VECT2(1),VECT(1))
      DO 200 I = 2,4
      DO 200 J = 1,3
  200 PLOADS(J,I) = PLOADS(J,I) + VECT(J)
C
C     TRIANGLE  3,1,4
C
      DO 210 I = 1,3
      VECT1(I) = GPCO4(I) - GPCO1(I)
  210 VECT2(I) = GPCO3(I) - GPCO1(I)
      CALL CROSS (VECT1(1),VECT2(1),VECT(1))
      DO 230 I = 1,4
      IF (I .EQ. 2) GO TO 230
      DO 220 J = 1,3
  220 PLOADS(J,I) = PLOADS(J,I)+VECT(J)
  230 CONTINUE
C
C     TRIANGLE (4,1,2)
C
      DO 240 I = 1,3
      VECT1(I) = GPCO4(I) - GPCO1(I)
  240 VECT2(I) = GPCO2(I) - GPCO1(I)
      CALL CROSS (VECT1(1),VECT2(1),VECT(1))
      DO 260 I = 1,4
      IF (I .EQ. 3) GO TO 260
      DO 250 J = 1,3
  250 PLOADS(J,I) = PLOADS(J,I) + VECT(J)
  260 CONTINUE
      PMAG = PMAG/12.0
      GO TO 80
      END