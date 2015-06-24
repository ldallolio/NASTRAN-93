      SUBROUTINE SS2D82 (IEQEX,NEQEX,TGRID)        
C        
C     PHASE 2 OF STRESS DATA RECOVERY FOR 2-D, 8 GRID POINT        
C     ISOPARAMETRIC STRUCTURAL ELEMENT        
C        
C     PH1OUT CONTAINS THE FOLLOWING        
C     ELEMENT ID        
C     8 SILS        
C     TREF        
C     ST ARRAY        
C     TRANSFORMATION MATRIX FROM GLOBAL TO ELEMENT COORDINATES        
C     COORD SYSTEM ID FOR STRESS OUTPUT        
C     G MATRIX        
C     DNX,DNY AT EACH GRID POINT -EVALUATED 8 TIMES        
C        
C        
      DIMENSION       TGRID(8),ST(3),TA(48),G(9),B(9),DB(72),DISP(24),  
     1                SIG(3),BB(72),DNX(8),DNY(8),TB(6),TEMP(9),        
     2                ISTRES(3),NSIL(1),NPH1(1),DN(8),XI(8),ETA(8),     
     3                PT(3),EX2D82(32),EX2D83(72),SIGS(27),SIGT(24),    
     4                IZ(1),STRESS(43)        
CZZ   COMMON /ZZSDR2/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SDR2X4/ DUMMY(35),IVEC,IVECN,LDTEMP,DEFORM        
      COMMON /SDR2X7/ PH1OUT(100),STR(250),FORVEC(250)        
      COMMON /SDR2X8/ DISP,DNX,DNY,DNZ,B,TB,BB,DB,SIG,IBASE,NSTRT,NPT,  
     1                IS,IDTEMP        
      EQUIVALENCE     (PH1OUT(1),NPH1(1)),(PH1OUT(1),ID),        
     1                (NSIL(1),PH1OUT(2)),(TREF,PH1OUT(10)),        
     2                (ST(1),PH1OUT(11)),(TA(1),PH1OUT(14)),        
     3                (G(1),PH1OUT(63)),(PH1OUT(62),ID1),        
     4                (ISTRES(1),STRESS(1)),(LDTEMP,ELTEMP),        
     5                (Z(1),IZ(1))        
      DATA    EX2D82/        
     1 1.86603,-.50000,-.50000, .13397,-.50000, .13397,1.86603,-.50000, 
     2  .13397,-.50000,-.50000,1.86603,-.50000,1.86603, .13397,-.50000, 
     3  .68301,-.18301, .68301,-.18301,-.18301,-.18301, .68301, .68301, 
     4 -.18301, .68301,-.18301, .68301, .68301, .68301,-.18301,-.18301/ 
      DATA    EX2D83/        
     1 2.18694,-.98589, .27778,-.98589, .44444,-.12522, .27778,-.12522, 
     2  .03528, .27778,-.12522, .03528,-.98589, .44444,-.12522,2.18694, 
     3 -.98589, .27778, .03528,-.12522, .27778,-.12522, .44444,-.98589, 
     4  .27778,-.98589,2.18694, .27778,-.98589,2.18694,-.12522, .44444, 
     5 -.98589, .03528,-.12522, .27778,-.00000,0.00000,-.00000,1.47883, 
     6 -.66667, .18784, .00000,-.00000,-.00000,-.00000, .18784, .00000, 
     7 -.00000,-.66667,-.00000, .00000,1.47883, .00000,-.00000,0.00000, 
     8  .00000, .18784,-.66667,1.47883, .00000,-.00000, .00000,-.00000, 
     9 1.47883, .00000,-.00000,-.66667,-.00000,-.00000, .18784,0.00000/ 
      DATA    XI    / -1., 1., 1.,-1., 0., 1., 0.,-1./        
      DATA    ETA   / -1.,-1., 1., 1.,-1., 0., 1., 0./        
C        
C     SET UP DISPLACEMENTS FOR THIS ELEMENT        
C        
      IS  = 0        
      DO 10 I = 1,8        
      NSTRT = IVEC + NSIL(I) - 1        
      DO 10 J = 1,3        
      IS  = IS + 1        
      NPT = NSTRT + J - 1        
      DISP(IS) = Z(NPT)        
   10 CONTINUE        
C        
C     INITIALIZE SOME MATRICES        
C        
      DO 30 I = 1,72        
   30 BB(I) = 0.        
C        
C     SET UP INDICATOR FOR GRID POINT TEMPERATURES        
C        
      IDTEMP = 0        
      DO 40 I = 1,8        
      IF (TGRID(I) .NE. 0.) GO TO 50        
   40 CONTINUE        
      GO TO 60        
   50 IDTEMP = 1        
C        
C     START LOOPING FOR STRESSES        
C        
   60 IDN = 4        
      IF (ID1 .EQ. 3) IDN = 9        
      III = 0        
      PT(1) = -0.57735027        
      PT(2) = -PT(1)        
      IF (ID1 .EQ. 2) GO TO 133        
      PT(1) = -0.77459667        
      PT(2) = 0.        
      PT(3) = -PT(1)        
  133 DO 135 JII = 1,ID1        
      DO 135 JJJ = 1,ID1        
      III = III + 1        
C        
C     COMPUTE BASE POINTER FOR PICKING UP DERIVATIVES        
C        
      IBASE = 71 + 16*(III-1)        
C        
      DO 70 N = 1,8        
      NX = N + IBASE        
      NY = N + IBASE + 8        
      DNX(N) = PH1OUT(NX)        
      DNY(N) = PH1OUT(NY)        
   70 CONTINUE        
C        
      DO 130 N = 1,8        
C        
C     SET UP THE B MATRIX        
C        
      DO 75 I = 1,9        
      TEMP(I) = 0.        
   75 B(I) = 0.        
      B(1) = DNX(N)        
      B(4) = DNY(N)        
      B(5) = DNY(N)        
      B(6) = DNX(N)        
C        
C     TRANSFORM TO ELEMENT COORDINATES        
C        
      KK = 6*N - 6        
      DO 80 I = 1,6        
      K  = KK + I        
      TB(I) = TA(K)        
   80 CONTINUE        
      CALL GMMATS (B,3,2,0,TB,2,3,0,TEMP(1))        
      N3 = 3*N        
      BB(N3- 2) = TEMP(1)        
      BB(N3- 1) = TEMP(2)        
      BB(N3   ) = TEMP(3)        
      BB(N3+22) = TEMP(4)        
      BB(N3+23) = TEMP(5)        
      BB(N3+24) = TEMP(6)        
      BB(N3+46) = TEMP(7)        
      BB(N3+47) = TEMP(8)        
      BB(N3+48) = TEMP(9)        
  130 CONTINUE        
C        
C     BRING IN G MATRIX        
C        
      CALL GMMATS (G,3,3,0,BB,3,24,0,DB)        
C        
C     COMPUTE STRESSES        
C        
      CALL GMMATS (DB,3,24,0,DISP,24,1,0,SIG)        
C        
C     STORE GAUSS POINT STRESSES INTO SIGT        
C        
      I3 = 3*(III-1)        
      DO 131 I = 1,3        
      ISUB = I3 + I        
      SIGS(ISUB) = SIG(I)        
  131 CONTINUE        
C        
C     COMPUTE GAUSS POINT  TEMPERATURES        
C        
      IF (LDTEMP .EQ. -1) GO TO 135        
      IF (IDTEMP .EQ.  1) GO TO 229        
      RGTEMP = ELTEMP - TREF        
      GO TO 250        
C        
C     ALL TEMPERATURES ARE DEFAULT VALUE        
C        
  229 DO 230 N = 1,4        
      DN(N) = .25*(1.+PT(JII)*XI(N))*(1.+PT(JJJ)*ETA(N))        
     1           *(PT(JII)*XI(N)+PT(JJJ)*ETA(N)-1.)        
  230 CONTINUE        
      DO 231 N = 5,7,2        
      DN(N) = .5*(1.-PT(JII)*PT(JII))*(1.+PT(JJJ)*ETA(N))        
  231 CONTINUE        
      DO 232 N = 6,8,2        
      DN(N) = .5*(1.+PT(JII)*XI(N))*(1.-PT(JJJ)*PT(JJJ))        
  232 CONTINUE        
      GSTEMP = 0.        
      DO 240 N = 1,8        
      GSTEMP = GSTEMP + DN(N)*TGRID(N)        
  240 CONTINUE        
      RGTEMP = GSTEMP - TREF        
  250 CONTINUE        
      DO 260 I = 1,3        
      ISUB = I3 + I        
      SIGS(ISUB) = SIGS(ISUB) - ST(I)*RGTEMP        
  260 CONTINUE        
C        
  135 CONTINUE        
C        
C     MULTIPLY BY TRANSFORMATION FROM GAUSS POINTS TO GRID POINTS       
C        
      IF (ID1 .EQ. 2) CALL GMMATS (EX2D82,8,4,0,SIGS,4,3,0,SIGT)        
      IF (ID1 .EQ. 3) CALL GMMATS (EX2D83,8,9,0,SIGS,9,3,0,SIGT)        
C        
C     FINISH UP        
C        
      DO 500 III = 1,8        
C        
C     MOVE A ROW OF SIGT INTO SIG        
C        
      I3 = 3*(III-1)        
      DO 132 I = 1,3        
      ISUB = I3 + I        
      SIG(I) = SIGT(ISUB)        
  132 CONTINUE        
C        
C     STORE STRESSES        
C        
      JSUB  = 5*(III-1) + 4        
      ISUB1 = IEQEX + 1        
      ISUB2 = IEQEX + NEQEX - 1        
      DO 161 JJJ = ISUB1,ISUB2,2        
      NS = IZ(JJJ)/10        
      IF (NS .NE. NSIL(III)) GO TO 161        
      ISTRES(JSUB) = IZ(JJJ-1)        
      GO TO 162        
  161 CONTINUE        
      CALL MESAGE (-30,164,IZ(JJJ))        
  162 CONTINUE        
      ISTRES(JSUB+1) = 0        
      DO 170 I = 1,3        
      JJSUB = JSUB + 1 + I        
      STRESS(JJSUB) = SIG(I)        
  170 CONTINUE        
C        
C     LOOP FOR OTHER GRID POINTS        
C        
  500 CONTINUE        
C        
C     FINISH UP        
C        
C     ELEMENT ID        
C        
      ISTRES(1) = ID        
C        
C     NUMBER OF GRID POINTS PER ELEMENT        
C        
      ISTRES(2) = 8        
C        
C     NUMBER OF STRESSES OUTPUT PER ELEMENT        
C        
      ISTRES(3) = 3        
C        
      DO 600 I = 1,43        
  600 STR(I) = STRESS(I)        
C        
      RETURN        
      END        
