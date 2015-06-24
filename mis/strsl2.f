      SUBROUTINE STRSL2 (TI)        
C        
C     PHASE II OF STRESS DATA RECOVERY        
C        
      LOGICAL         FLAG        
      INTEGER         TLOADS        
      REAL            TI(6),SDELTA(3)        
      DIMENSION       REALI(4),NSIL(6),STR(18),NPH1OU(990),SI(36),      
     1                STOUT(68)        
CZZ   COMMON /ZZSDR2/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SDR2X4/ DUMMY(35),IVEC,IVECN,LDTEMP,DEFORM,DUM8(8),       
     1                TLOADS,MAXSIZ        
      COMMON /SDR2X7/ PH1OUT(1200),FORVEC(24)        
      COMMON /SDR2X8/ TEMP,DELTA,NPOINT,IJ1,IJ2,NPT1,VEC(5),TEM,        
     1                Z1 OVR I,Z2 OVR I,STRESS(18)        
      EQUIVALENCE     (NSIL(1),PH1OUT(2)),(NPH1OU(1),PH1OUT(1)),        
     1                (SI(1),PH1OUT(22)),(LDTEMP,FTEMP),(F1,N1)        
C        
C     PHASE I OUTPUT FROM THE PLATE IS THE FOLLOWING        
C        
C     PH1OUT(1)                        ELEMENT ID        
C     PH1OUT(2 THRU 7)                 6 SILS        
C     PH1OUT(8 THRU 10)                TMEM1,TMEM3,TMEM5        
C     PH1OUT(11 THRU 13) (14)-(21)     Z1 AND Z2  TBEND1,TBEND3,TBEND5  
C     PH1OUT (22 THRU 741)             4 S SUB I MATRICES,EACH 6X5X6 ARR
C     PH1OUT (742-753)                 4 - 3X3 S SUB T MATRICES        
C        
C     PHASE 1 OUTPUT FROM THE MEMBRANE IS THE FOLLOWING        
C        
C     PH1OUT(754)             ELEMENT ID        
C     PH1OUT(755-760)         6 SILS        
C     PH1OUT(761)             T SUB 0        
C     PH1OUT(762-1193)        4 SETS OF 6 NOS. 3 X 6 S SUB I        
C     PH1OUT(1194-1196)       S SUB T MATRIX        
C        
C     THE ABOVE ELEMENTS ARE COMPOSED OF PLATES AND MEMBRANES...        
C     SOME MAY ONLY CONTAIN PLATES WHILE OTHERS MAY ONLY CONTAIN        
C     MEMBRANES.        
C     A CHECK FOR A ZERO FIRST SIL IN THE PHASE I OUTPUT, WHICH        
C     INDICATES WHETHER ONE OR THE OTHER HAS BEEN OMITTED, IS MADE BELOW
C        
C     FIRST GET FORCE VECTOR FOR THE PLATE CONSIDERATION        
C        
C     M ,  M ,  M ,  V ,  V    FOR ALL SIX GRID POINTS        
C      X   Y   XY   X   Y        
C                                NPTS        
C     THE 5X1 FORCE VECTOR = SUMMATION  (S )(U )   FOR EACH POINT       
C                                I=1       I   I        
C        
C     ZERO FORVEC STORAGE        
C        
      NPTS = 6        
      DO 15 I = 1,24        
   15 FORVEC( I) = 0.0        
      FORVEC( 1) = PH1OUT(1)        
      FORVEC( 7) = PH1OUT(1)        
      FORVEC(13) = PH1OUT(1)        
      FORVEC(19) = PH1OUT(1)        
C     DO 155 II = 1,4        
      II = 0        
   17 II = II+1        
      IF (II .GT. 4) GO TO 155        
C        
C     ZERO OUT LOCAL STRESSES        
C        
      SIG X  1 = 0.0        
      SIG Y  1 = 0.0        
      SIG XY 1 = 0.0        
      SIG X  2 = 0.0        
      SIG Y  2 = 0.0        
      SIG XY 2 = 0.0        
C        
      IF (NSIL(1) .EQ. 0) GO TO 30        
C        
C     FORM SUMMATION        
C        
      DO 20 I = 1,6        
C        
C     POINTER TO DISPLACEMENT VECTOR IN VARIABLE CORE        
C        
      NPOINT = IVEC + NSIL(I) - 1        
C        
      II1 = (II-1)*180 + 30*I - 29        
      CALL GMMATS (SI(II1),5,6,0, Z(NPOINT),6,1,0, VEC(1))        
C        
      DO 10 J = 2,6        
      IJ = (II-1)*6 + J        
   10 FORVEC(IJ) = FORVEC(IJ) + VEC(J-1)        
   20 CONTINUE        
C        
      IF (TLOADS .EQ. 0) GO TO 23        
      JST  = 741 + (II-1)*3        
      I1   = (II-1)*6        
      FLAG = .FALSE.        
      F1   = TI(6)        
      IF (N1 .EQ. 1) GO TO 22        
      FORVEC(I1+2) = FORVEC(I1+2) - TI(2)        
      FORVEC(I1+3) = FORVEC(I1+3) - TI(3)        
      FORVEC(I1+4) = FORVEC(I1+4) - TI(4)        
      IF (TI(5).EQ.0.0 .AND. TI(6).EQ.0.0) FLAG = .TRUE.        
      GO TO 23        
   22 FORVEC(I1+2) = FORVEC(I1+2) + TI(2)*PH1OUT(JST+1)        
      FORVEC(I1+3) = FORVEC(I1+3) + TI(2)*PH1OUT(JST+2)        
      FORVEC(I1+4) = FORVEC(I1+4) + TI(2)*PH1OUT(JST+3)        
      IF (TI(3).EQ.0.0 .AND. TI(4).EQ.0.0) FLAG = .TRUE.        
   23 CONTINUE        
C        
C     FORCE VECTOR IS NOW COMPLETE        
C        
      IF (II .EQ. 4) GO TO 24        
      I1 = 13 + 2*II - 1        
      I2 = I1 + 1        
      Z1 OVR I = -12.0*PH1OUT(I1)/PH1OUT(10+II)**3        
      Z2 OVR I = -12.0*PH1OUT(I2)/PH1OUT(10+II)**3        
      GO TO 25        
   24 Z1 OVR I = -1.5/PH1OUT(20)**2        
      Z2 OVR I = -Z1 OVR I        
   25 CONTINUE        
      II1 = (II-1)*6        
C        
      K1  = 0        
      ASSIGN 26 TO IRETRN        
      GO TO 170        
C        
   26 SIG X  1 = FORVEC(II1+2)*Z1 OVR I-SDELTA(1)        
      SIG Y  1 = FORVEC(II1+3)*Z1 OVR I-SDELTA(2)        
      SIG XY 1 = FORVEC(II1+4)*Z1 OVR I-SDELTA(3)        
C        
      K1 = 1        
      ASSIGN 27 TO IRETRN        
      GO TO 170        
C        
   27 SIG X  2 = FORVEC(II1+2)*Z2 OVR I-SDELTA(1)        
      SIG Y  2 = FORVEC(II1+3)*Z2 OVR I-SDELTA(2)        
      SIG XY 2 = FORVEC(II1+4)*Z2 OVR I-SDELTA(3)        
C        
      GO TO 40        
   30 Z1 = 0.0        
      Z2 = 0.0        
C        
   40 IF (NPH1OU(754) .EQ. 0) GO TO 90        
C        
C     ZERO STRESS VECTOR STORAGE        
C        
      DO 42 I = 1,3        
   42 STRESS(I) = 0.0        
C        
C                            I=NPTS        
C        STRESS VECTOR = (  SUMMATION(S )(U )  ) - (S )(LDTEMP - T )    
C                            I=1       I   I         T            0     
C        
      DO 60 I = 1,6        
C        
C     POINTER TO I-TH SIL IN PH1OUT        
C     POINTER TO DISPLACEMENT VECTOR IN VARIABLE CORE        
C     POINTER TO S SUB I 3X3        
C        
      NPOINT = 754 + I        
      NPOINT = IVEC + NPH1OU(NPOINT) - 1        
      NPT1=762+(I-1)*18+(II-1)*108        
      CALL GMMATS (PH1OUT(NPT1),3,6,0, Z(NPOINT),6,1,0, VEC(1))        
C        
      DO 50 J = 1,3        
   50 STRESS(J) = STRESS(J) + VEC(J)        
C        
   60 CONTINUE        
C        
      IF (LDTEMP .EQ. -1) GO TO 80        
C        
C     POINTER TO T SUB 0 = 761        
C        
      TEM = FTEMP - PH1OUT(761)        
      DO 70 I = 1,3        
      NPOINT = 1193 + I        
   70 STRESS(I) = STRESS(I) - PH1OUT(NPOINT)*TEM        
C        
C     ADD MEMBRANE STRESSES TO PLATE STRESSES        
C        
   80 SIG X  1 = SIG X  1 + STRESS(1)        
      SIG Y  1 = SIG Y  1 + STRESS(2)        
      SIG XY 1 = SIG XY 1 + STRESS(3)        
      SIG X  2 = SIG X  2 + STRESS(1)        
      SIG Y  2 = SIG Y  2 + STRESS(2)        
      SIG XY 2 = SIG XY 2 + STRESS(3)        
C        
C     STRESS OUTPUT VECTOR IS THE FOLLOWING        
C        
C      1) ELEMENT ID        
C      2) Z1 = FIBER DISTANCE 1        
C      3) SIG X  1        
C      4) SIG Y  1        
C      5) SIG XY 1        
C      6) ANGLE OF ZERO SHEAR AT Z1        
C      7) SIG P1 AT Z1        
C      8) SIG P2 AT Z1        
C      9) TAU MAX = MAXIMUM SHEAR STRESS AT Z1        
C     10) ELEMENT ID        
C     11) Z2 = FIBER DISTANCE 2        
C     12) SIG X  2        
C     13) SIG Y  2        
C     14) SIG XY 2        
C     15) ANGLE OF ZERO SHEAR AT Z2        
C     16) SIG P1 AT Z2        
C     17) SIG P2 AT Z2        
C     S7) SIG P2 AT Z2        
C     18) TAU MAX = MAXIMUM SHEAR STRESS AT Z2        
C        
   90 IF (NPH1OU(755).EQ.0 .AND. NPH1OU(2).EQ.0) GO TO 120        
C        
C     COMPUTE PRINCIPAL STRESSES        
C        
      STR( 1) = PH1OUT(1)        
      STR( 2) = PH1OUT(II*2+12)        
      STR( 3) = SIG X 1        
      STR( 4) = SIG Y 1        
      STR( 5) = SIG XY 1        
      STR(10) = PH1OUT(1)        
      STR(11) = PH1OUT(II*2+13)        
      STR(12) = SIG X  2        
      STR(13) = SIG Y  2        
      STR(14) = SIG XY 2        
C        
      DO 110 I = 3,12,9        
      TEMP     = STR(I) - STR(I+1)        
      STR(I+6) = SQRT((TEMP/2.0)**2+STR(I+2)**2)        
      DELTA    = (STR(I)+STR(I+1))/2.0        
      STR(I+4) = DELTA + STR(I+6)        
      STR(I+5) = DELTA - STR(I+6)        
      DELTA    = 2.0*STR(I+2)        
      IF (ABS(DELTA).LT.1.0E-15 .AND. ABS(TEMP).LT.1.0E-15) GO TO 100   
      STR(I+3) = ATAN2(DELTA,TEMP)*28.6478898        
      GO TO 110        
  100 STR(I+3) = 0.0        
  110 CONTINUE        
      GO TO 140        
  120 DO 130 I = 2,18        
  130 STR( I) = 0.0        
  140 STR( 1) = PH1OUT(1)        
      STR(10) = PH1OUT(1)        
C        
C     ADDITION TO ELIMINATE 2ND ELEMENT ID IN OUTPUT        
C        
      IJK = (II-1)*17        
      STOUT(IJK+1) = PH1OUT(1)        
      DO 149 I = 2,9        
  149 STOUT(IJK+I) = STR(I)        
      DO 150 I = 10,17        
  150 STOUT (IJK+I) = STR(I+1)        
      GO TO 17        
  155 CONTINUE        
C        
      DO 156 I = 1,17        
  156 PH1OUT(100+I) = STOUT(I)        
      DO 159 J = 1,3        
      DO 159 I = 1,16        
      J1 = 117 + (J-1)*16 + I        
      J2 = (J-1)*17 + I + 18        
      PH1OUT(J1) = STOUT(J2)        
  159 CONTINUE        
      DO 157 I = 1,6        
  157 PH1OUT(200+I) = FORVEC(I)        
      DO 158 I = 1,5        
      PH1OUT(206+I) = FORVEC(I+ 7)        
  158 PH1OUT(211+I) = FORVEC(I+13)        
      RETURN        
C        
C     INTERNAL SUBROUTINE        
C        
  170 IF (TLOADS.EQ.0 .OR. FLAG) GO TO 200        
      JST = 741 + (II-1)*3        
      REALI(1) = PH1OUT(11)**3/12.0        
      REALI(2) = PH1OUT(12)**3/12.0        
      REALI(3) = PH1OUT(13)**3/12.0        
      REALI(4) = PH1OUT(20)**3/1.50        
      IF (N1 .EQ. 1) GO TO 190        
      FF = TI(K1+5) - TI(1)        
      IF (ABS(PH1OUT(K1+12+2*II)) .LE. 1.0E-07) GO TO 200        
      SDELTA(1) = (PH1OUT(JST+1)*FF +TI(2)*PH1OUT(K1+12+2*II))/REALI(II)
      SDELTA(2) = (PH1OUT(JST+2)*FF +TI(3)*PH1OUT(K1+12+2*II))/REALI(II)
      SDELTA(3) = (PH1OUT(JST+3)*FF +TI(4)*PH1OUT(K1+2*II+12))/REALI(II)
      GO TO 210        
  190 CONTINUE        
      IF (ABS(PH1OUT(K1+12+2*II)) .LE. 1.0E-07) GO TO 200        
      FF = (TI(K1+3) - PH1OUT(K1+12+2*II)*TI(2) - TI(1))/REALI(II)      
      SDELTA(1) = PH1OUT(JST+1)*FF        
      SDELTA(2) = PH1OUT(JST+2)*FF        
      SDELTA(3) = PH1OUT(JST+3)*FF        
      GO TO 210        
  200 SDELTA(1) = 0.0        
      SDELTA(2) = 0.0        
      SDELTA(3) = 0.0        
  210 GO TO IRETRN, (26,27)        
      END        
