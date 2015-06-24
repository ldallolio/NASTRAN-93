      SUBROUTINE STPAX2 (SORC,TI)        
C        
C     THIS ROUTINE IS PHASE II OF STRESS RECOVERY FOR THE TRAPEZOIDAL   
C     CROSS SECTION RING        
C        
C     OUTPUTS FROM PHASE I ARE THE FOLLOWING..        
C     IDEL, IGP(4), TZ, SEL(360), TS(06), AK(144), PHI(14)        
C     AKUPH(48), AKPH2(16), SELP1(120), SELP2(180), SELP3(60)        
C        
C     ANY GROUP OF STATEMENTS PREFACED BY AN IF STATEMENT CONTAINING    
C     ...KSYS78 OR LSYS78 ...  INDICATES CODING NECESSARY FOR THIS      
C     ELEMENT*S PIEZOELECTRIC CAPABILITY        
C        
C     KSYS78 = 0   ELASTIC, NON-PIEZOELECTRIC MATERIAL        
C     KSYS78 = 1   ELECTRICAL-ELASTIC COUPLED, PIEZOELETRIC MATERIAL    
C     KSYS78 = 2   ELASTIC ONLY, PIEZOELECTRIC MATERIAL        
C     LSYS78 = .TRUE. IF KSYS78 = 0, OR 2        
C        
      LOGICAL         ZERO,ZERON,LSYS78        
      INTEGER         SORC,IBLOCK(62,14),ISTRES(100),IFORCE(25),ELEMID, 
     1                ICLOCK(62,14)        
      REAL            NPHI        
      DIMENSION       TI(4),DUM3(225),STRES(100),FORCE(25),AKUPH(48),   
     1                AKPH2(16),SELP1(120),SELP2(180),SELP3(60),D4(4),  
     2                D15(15),D30(30),DISPP(4),ECHRG(4),EFLUX(15)       
C        
C     SDR2 VARIABLE CORE        
C        
CZZ   COMMON /ZZSDR2/ ZZ(1)        
      COMMON /ZZZZZZ/ ZZ(1)        
C        
C     SDR2 BLOCK FOR POINTERS AND LOADING  TEMPERATURES        
C        
      COMMON /SDR2X4/ DUM1(33),ICSTM,NCSTM,IVEC,IVECN,TEMPLD,ELDEFM,    
     1                DUM4(12),KTYPE        
C        
C     SCRATCH BLOCK        
C        
      COMMON /SDR2X8/ DISP(12),EFORC(12),ESTRES(30),HARM,N,SINPHI,      
     1                CONPHI,NPHI,NANGLE,ELEMID,UNU(93),NELHAR,KANGLE,  
     2                KLEMID        
C        
C     SDR2 INPUT AND OUTPUT BLOCK        
C        
      COMMON /SDR2X7/ IDEL,IGP(4),TZ,SEL(360),TS(6),AK(144),PHI(14),    
     1                DUM2(424),BLOCK(62,14),CLOCK(62,14)        
C        
      COMMON /SYSTEM/ KSYSTM(77),KSYS78        
      COMMON /SDR2DE/ DUM5(33), IPART        
      COMMON /CONDAS/ CONSTS(5)        
      EQUIVALENCE     (IBLOCK(1,1),BLOCK(1,1)),(ICLOCK(1,1),CLOCK(1,1)),
     1                (DUM3(1),IDEL),(DUM3(101),STRES(1),ISTRES(1)),    
     2                (DUM3(201),FORCE(1),IFORCE(1)),(CONSTS(4),DEGRAD),
     3                (LDTEMP,TEMPLD),(DUM2(1),AKUPH(1)),        
     4                (DUM2(49),AKPH2(1)),(DUM2(65),SELP1(1)),        
     5                (DUM2(185),SELP2(1)),(DUM2(365),SELP3(1)),        
     6                (UNU(1),D4(1)),(UNU(5),D15(1)),(UNU(20),D30(1))   
      DATA    ZERON / .FALSE. /        
      DATA    IOSORC/ 0       /        
C        
      ELEMID = IDEL / 1000        
      NELHAR = IDEL - ELEMID*1000        
      KLEMID = ELEMID        
      LSYS78 =.FALSE.        
      IF (KSYS78.EQ.0 .OR. KSYS78.EQ.2) LSYS78 = .TRUE.        
C        
C     SET BLOCK = 0 IF HARMONIC = 0        
C        
      N = NELHAR - 1        
      IF (N .NE. 0) GO TO 21        
      IF (N.EQ.0 .AND. ZERON .AND. IOSORC .NE. SORC) GO TO 14        
      ZERON  = .TRUE.        
      IOSORC = SORC        
      DO 15 I = 2,62        
      DO 15 J = 1,14        
      IF (KTYPE.NE.2 .OR. IPART.NE.2) BLOCK(I,J) = 0.0        
      CLOCK(I,J) = 0.0        
   15 CONTINUE        
C        
C     SET ANGLES CONTROL FOR SUMMATION        
C        
      ZERO = .FALSE.        
      J = 0        
      DO 16 I = 1,14        
      IF (PHI(I)) 17,18,17        
   18 IF (ZERO) GO TO 16        
      ZERO = .TRUE.        
   17 J = J + 1        
      BLOCK(1,J) = PHI(I)        
      CLOCK(1,J) = PHI(I)        
   16 CONTINUE        
      J = J + 1        
      IF (J .GT. 14) GO TO 21        
      IBLOCK(1,J) = 1        
      ICLOCK(1,J) = 1        
      GO TO 21        
   14 ZERON = .FALSE.        
   21 HARM  = N        
C        
C     INITIALIZE LOCAL VARIABLES        
C        
      NDOF  = 3        
      NUMPT = 4        
      N     = NDOF*NUMPT        
      NSP   = 5        
      NCOMP = 6        
      NS    = NSP*NCOMP        
C        
C     FIND GRID POINTS DISPLACEMENTS        
C        
      K = 0        
      DO 100 I = 1,NUMPT        
      ILOC = IVEC + IGP(I) - 2        
C        
      IF (LSYS78) GO TO 90        
      ILOCP = ILOC + 4        
      DISPP(I) = ZZ(ILOCP)        
   90 CONTINUE        
C        
      DO 100 J = 1,NDOF        
      ILOC = ILOC + 1        
      K = K + 1        
      DISP(K) = ZZ(ILOC)        
  100 CONTINUE        
C        
C     COMPUTE THE GRID POINT FORCES        
C        
      CALL GMMATS (AK(1),N,N,0, DISP(1),N,1,0, EFORC(1))        
C        
      DO 109 I = 1,4        
  109 ECHRG(I) = 0.0        
C        
      IF (LSYS78) GO TO 125        
      CALL GMMATS (AKUPH(1),N,NUMPT,0, DISPP(1),NUMPT,1,0, D15(1))      
      DO 110 I = 1,12        
  110 EFORC(I) = EFORC(I) + D15(I)        
C        
      CALL GMMATS (AKUPH(1),N,NUMPT,1, DISP(1),N,1,0, D4(1))        
      CALL GMMATS (AKPH2(1),NUMPT,NUMPT,0, DISPP(1),NUMPT,1,0, ECHRG(1))
      DO 120 I = 1,4        
  120 ECHRG(I) = ECHRG(I) + D4(I)        
  125 CONTINUE        
C        
C     COMPUTE THE STRESSES        
C        
      CALL GMMATS (SEL(1),NS,N,0, DISP(1),N,1,0, ESTRES(1))        
C        
      DO 129 I = 1,15        
  129 EFLUX(I) = 0.0        
C        
      IF (LSYS78) GO TO 145        
      CALL GMMATS (SELP1(1),NS,NUMPT,0, DISPP(1),NUMPT,1,0, D30(1))     
      DO 130 I = 1,30        
  130 ESTRES(I) = ESTRES(I) + D30(I)        
C        
      CALL GMMATS (SELP2(1),15,N,0, DISP(1),N,1,0, EFLUX(1))        
      CALL GMMATS (SELP3(1),15,NUMPT,0, DISPP(1),NUMPT,1,0, D15(1))     
      DO 140 I = 1,15        
  140 EFLUX(I) = EFLUX(I) + D15(I)        
  145 CONTINUE        
C        
C     COMPUTE THERMAL STRESS IF IT IS EXISTS        
C        
      IF (LDTEMP .EQ. -1) GO TO 300        
      K = 0        
      T = TZ        
      IF (HARM .GT. 0.0) T = 0.0        
      DO 200 I = 1,NSP        
      DT = TI(I) - T        
      IF (I .EQ. 5) DT = (TI(1)+TI(2)+TI(3)+TI(4))/4.0 - T        
      DO 200 J = 1,NCOMP        
      K = K + 1        
      ESTRES(K) = ESTRES(K) - DT*TS(J)        
  200 CONTINUE        
  300 CONTINUE        
C        
C     BRANCH TO INSERT HARMONIC STRESSES AND FORCES INTO BLOCK OR CLOCK 
C        
C     KTYPE = 1 - REAL OUTPUT, STORED IN BLOCK, NOTHING IN CLOCK        
C     KTYPE = 2 - COMPLEX OUTPUT        
C     IPART = 1 - IMAGINARY PART OF COMPLEX OUTPUT, STORED IN BLOCK     
C     IPART = 2 - REAL PART OF COMPLEX OUTPUT, STORED IN CLOCK        
C        
      IF (KTYPE.EQ.2 .AND. IPART.EQ.2) GO TO 550        
C        
C     INSERT HARMONIC STRESSES AND FORCES INTO BLOCK        
C        
      DO 370 I = 1,14        
      IF (IBLOCK(1,I) .EQ. 1) GO TO 380        
      IF (HARM .EQ. 0.0) GO TO 350        
      NPHI   = HARM*BLOCK(1,I)*DEGRAD        
      SINPHI = SIN(NPHI)        
      CONPHI = COS(NPHI)        
      GO TO (330,310), SORC        
C        
  310 CONTINUE        
      DO 315 IE = 1,5        
      KE   = 9*(IE-1)        
      KEPZ = 6*(IE-1)        
      BLOCK(2+KE,I) = BLOCK(2+KE,I) + CONPHI*ESTRES(1+KEPZ)        
      BLOCK(3+KE,I) = BLOCK(3+KE,I) + CONPHI*ESTRES(2+KEPZ)        
      BLOCK(4+KE,I) = BLOCK(4+KE,I) + CONPHI*ESTRES(3+KEPZ)        
      BLOCK(5+KE,I) = BLOCK(5+KE,I) + CONPHI*ESTRES(4+KEPZ)        
      BLOCK(6+KE,I) = BLOCK(6+KE,I) + SINPHI*ESTRES(5+KEPZ)        
      BLOCK(7+KE,I) = BLOCK(7+KE,I) + SINPHI*ESTRES(6+KEPZ)        
C        
      IF (LSYS78) GO TO 315        
      KEPZ2 = KEPZ/2        
      BLOCK( 8+KE,I) = BLOCK( 8+KE,I) + CONPHI*EFLUX (1+KEPZ2)        
      BLOCK( 9+KE,I) = BLOCK( 9+KE,I) + CONPHI*EFLUX (2+KEPZ2)        
      BLOCK(10+KE,I) = BLOCK(10+KE,I) + SINPHI*EFLUX (3+KEPZ2)        
  315 CONTINUE        
C        
      DO 320 IR = 1,4        
      KR   = 4*(IR-1)        
      KRPZ = 3*(IR-1)        
      BLOCK(47+KR,I) = BLOCK(47+KR,I) + CONPHI*EFORC(1+KRPZ)        
      BLOCK(48+KR,I) = BLOCK(48+KR,I) + SINPHI*EFORC(2+KRPZ)        
      BLOCK(49+KR,I) = BLOCK(49+KR,I) + CONPHI*EFORC(3+KRPZ)        
      KR3 = 1 + KRPZ/3        
      IF(.NOT.LSYS78) BLOCK(50+KR,I) = BLOCK(50+KR,I) +CONPHI*ECHRG(KR3)
  320 CONTINUE        
      GO TO 370        
C        
  330 CONTINUE        
      DO 335 IE = 1,5        
      KE   = 9*(IE-1)        
      KEPZ = 6*(IE-1)        
      BLOCK(2+KE,I) = BLOCK(2+KE,I) + SINPHI*ESTRES(1+KEPZ)        
      BLOCK(3+KE,I) = BLOCK(3+KE,I) + SINPHI*ESTRES(2+KEPZ)        
      BLOCK(4+KE,I) = BLOCK(4+KE,I) + SINPHI*ESTRES(3+KEPZ)        
      BLOCK(5+KE,I) = BLOCK(5+KE,I) + SINPHI*ESTRES(4+KEPZ)        
      BLOCK(6+KE,I) = BLOCK(6+KE,I) - CONPHI*ESTRES(5+KEPZ)        
      BLOCK(7+KE,I) = BLOCK(7+KE,I) - CONPHI*ESTRES(6+KEPZ)        
C        
      IF (LSYS78) GO TO 335        
      KEPZ2 = KEPZ/2        
      BLOCK( 8+KE,I) = BLOCK( 8+KE,I) + SINPHI*EFLUX(1+KEPZ2)        
      BLOCK( 9+KE,I) = BLOCK( 9+KE,I) + SINPHI*EFLUX(2+KEPZ2)        
      BLOCK(10+KE,I) = BLOCK(10+KE,I) - CONPHI*EFLUX(3+KEPZ2)        
  335 CONTINUE        
C        
      DO 340 IR = 1,4        
      KR   = 4*(IR-1)        
      KRPZ = 3*(IR-1)        
      BLOCK(47+KR,I) = BLOCK(47+KR,I) + SINPHI*EFORC(1+KRPZ)        
      BLOCK(48+KR,I) = BLOCK(48+KR,I) - CONPHI*EFORC(2+KRPZ)        
      BLOCK(49+KR,I) = BLOCK(49+KR,I) + SINPHI*EFORC(3+KRPZ)        
      KR3 = 1 + KRPZ/3        
      IF(.NOT.LSYS78) BLOCK(50+KR,I) = BLOCK(50+KR,I) +SINPHI*ECHRG(KR3)
  340 CONTINUE        
      GO TO 370        
C        
  350 DO 355 IE = 1,5        
      KE   = 9*(IE-1)        
      KEPZ = 6*(IE-1)        
      BLOCK(2+KE,I) = ESTRES(1+KEPZ)        
      BLOCK(3+KE,I) = ESTRES(2+KEPZ)        
      BLOCK(4+KE,I) = ESTRES(3+KEPZ)        
      BLOCK(5+KE,I) = ESTRES(4+KEPZ)        
      BLOCK(6+KE,I) = ESTRES(5+KEPZ)        
      BLOCK(7+KE,I) = ESTRES(6+KEPZ)        
C        
      IF (LSYS78) GO TO 355        
      KEPZ2 = KEPZ/2        
      BLOCK( 8+KE,I) = EFLUX(1+KEPZ2)        
      BLOCK( 9+KE,I) = EFLUX(2+KEPZ2)        
      BLOCK(10+KE,I) = EFLUX(3+KEPZ2)        
  355 CONTINUE        
C        
      DO 360 IR = 1,4        
      KR   = 4*(IR-1)        
      KRPZ = 3*(IR-1)        
      BLOCK(47+KR,I) = EFORC(1+KRPZ)        
      BLOCK(48+KR,I) = EFORC(2+KRPZ)        
      BLOCK(49+KR,I) = EFORC(3+KRPZ)        
      KR3 = 1 + KRPZ/3        
      IF(.NOT.LSYS78) BLOCK(50+KR,I) = ECHRG(KR3)        
  360 CONTINUE        
C        
  370 CONTINUE        
C        
C     COPY STRESSES AND FORCES INTO OUTPUT BLOCKS        
C        
  380 CONTINUE        
      J = 2        
      K = 1        
      L = 0        
      ISTRES (1) = ELEMID        
      ISTRES (2) = NELHAR        
      DO 400 I = 1,NS        
      J = J + 1        
      STRES(J) = ESTRES(I)        
C        
      IF (I/6 .NE. K) GO TO 400        
      K = K + 1        
      DO 390 II = 1,3        
      J = J + 1        
      L = L + 1        
      STRES(J) = EFLUX(L)        
  390 CONTINUE        
C        
  400 CONTINUE        
      K = 0        
      J = 2        
      L = 1        
      IFORCE(1) = ELEMID        
      IFORCE(2) = NELHAR        
      DO 500 I  = 1,NUMPT        
      DO 500 KK = 1,NDOF        
      J = J + 1        
      K = K + 1        
      FORCE(J) = EFORC(K)        
C        
      IF (K/3 .NE. L) GO TO 500        
      J = J + 1        
      FORCE(J) = ECHRG(L)        
      L = L + 1        
C        
  500 CONTINUE        
C        
      IF (KTYPE.EQ.1 .OR. (KTYPE.EQ.2 .AND. IPART.EQ.1)) GO TO 1001     
  550 CONTINUE        
C        
C     INSERT HARMONIC STRESSES AND FORCES INTO CLOCK        
C        
      DO 690 I = 1,14        
      IF (ICLOCK(1,I) .EQ. 1) GO TO 700        
      IF (HARM .EQ. 0.0) GO TO 660        
      NPHI   = HARM*CLOCK(1,I)*DEGRAD        
      SINPHI = SIN(NPHI)        
      CONPHI = COS(NPHI)        
      GO TO (630,600), SORC        
  600 CONTINUE        
C        
      DO 610 IE = 1,5        
      KE   = 9*(IE-1)        
      KEPZ = 6*(IE-1)        
      CLOCK(2+KE,I) = CLOCK(2+KE,I) + CONPHI*ESTRES(1+KEPZ)        
      CLOCK(3+KE,I) = CLOCK(3+KE,I) + CONPHI*ESTRES(2+KEPZ)        
      CLOCK(4+KE,I) = CLOCK(4+KE,I) + CONPHI*ESTRES(3+KEPZ)        
      CLOCK(5+KE,I) = CLOCK(5+KE,I) + CONPHI*ESTRES(4+KEPZ)        
      CLOCK(6+KE,I) = CLOCK(6+KE,I) + SINPHI*ESTRES(5+KEPZ)        
      CLOCK(7+KE,I) = CLOCK(7+KE,I) + SINPHI*ESTRES(6+KEPZ)        
C        
      IF (LSYS78) GO TO 610        
      KEPZ2 = KEPZ/2        
      CLOCK( 8+KE,I) = CLOCK( 8+KE,I) + CONPHI*EFLUX (1+KEPZ2)        
      CLOCK( 9+KE,I) = CLOCK( 9+KE,I) + CONPHI*EFLUX (2+KEPZ2)        
      CLOCK(10+KE,I) = CLOCK(10+KE,I) + SINPHI*EFLUX (3+KEPZ2)        
  610 CONTINUE        
C        
      DO 620 IR = 1,4        
      KR   = 4*(IR-1)        
      KRPZ = 3*(IR-1)        
      CLOCK(47+KR,I) = CLOCK(47+KR,I) + CONPHI*EFORC(1+KRPZ)        
      CLOCK(48+KR,I) = CLOCK(48+KR,I) + SINPHI*EFORC(2+KRPZ)        
      CLOCK(49+KR,I) = CLOCK(49+KR,I) + CONPHI*EFORC(3+KRPZ)        
      KR3 = 1 + KRPZ/3        
      IF(.NOT.LSYS78) CLOCK(50+KR,I) = CLOCK(50+KR,I) +CONPHI*ECHRG(KR3)
  620 CONTINUE        
      GO TO 690        
C        
  630 CONTINUE        
      DO 640 IE = 1,5        
      KE   = 9*(IE-1)        
      KEPZ = 6*(IE-1)        
      CLOCK(2+KE,I) = CLOCK(2+KE,I) + SINPHI*ESTRES(1+KEPZ)        
      CLOCK(3+KE,I) = CLOCK(3+KE,I) + SINPHI*ESTRES(2+KEPZ)        
      CLOCK(4+KE,I) = CLOCK(4+KE,I) + SINPHI*ESTRES(3+KEPZ)        
      CLOCK(5+KE,I) = CLOCK(5+KE,I) + SINPHI*ESTRES(4+KEPZ)        
      CLOCK(6+KE,I) = CLOCK(6+KE,I) - CONPHI*ESTRES(5+KEPZ)        
      CLOCK(7+KE,I) = CLOCK(7+KE,I) - CONPHI*ESTRES(6+KEPZ)        
C        
      IF (LSYS78) GO TO 640        
      KEPZ2 = KEPZ/2        
      CLOCK( 8+KE,I) = CLOCK( 8+KE,I) + SINPHI*EFLUX(1+KEPZ2)        
      CLOCK( 9+KE,I) = CLOCK( 9+KE,I) + SINPHI*EFLUX(2+KEPZ2)        
      CLOCK(10+KE,I) = CLOCK(10+KE,I) - CONPHI*EFLUX(3+KEPZ2)        
  640 CONTINUE        
C        
      DO 650 IR = 1,4        
      KR   = 4*(IR-1)        
      KRPZ = 3*(IR-1)        
      CLOCK(47+KR,I) = CLOCK(47+KR,I) + SINPHI*EFORC(1+KRPZ)        
      CLOCK(48+KR,I) = CLOCK(48+KR,I) - CONPHI*EFORC(2+KRPZ)        
      CLOCK(49+KR,I) = CLOCK(49+KR,I) + SINPHI*EFORC(3+KRPZ)        
      KR3 = 1 + KRPZ/3        
      IF(.NOT.LSYS78) CLOCK(50+KR,I) = CLOCK(50+KR,I) +SINPHI*ECHRG(KR3)
  650 CONTINUE        
      GO TO 690        
C        
  660 DO 670 IE = 1,5        
      KE   = 9*(IE-1)        
      KEPZ = 6*(IE-1)        
      CLOCK(2+KE,I) = ESTRES(1+KEPZ)        
      CLOCK(3+KE,I) = ESTRES(2+KEPZ)        
      CLOCK(4+KE,I) = ESTRES(3+KEPZ)        
      CLOCK(5+KE,I) = ESTRES(4+KEPZ)        
      CLOCK(6+KE,I) = ESTRES(5+KEPZ)        
      CLOCK(7+KE,I) = ESTRES(6+KEPZ)        
C        
      IF (LSYS78) GO TO 670        
      KEPZ2 = KEPZ/2        
      CLOCK( 8+KE,I) = EFLUX(1+KEPZ2)        
      CLOCK( 9+KE,I) = EFLUX(2+KEPZ2)        
      CLOCK(10+KE,I) = EFLUX(3+KEPZ2)        
  670 CONTINUE        
C        
      DO 680 IR = 1,4        
      KR   = 4*(IR-1)        
      KRPZ = 3*(IR-1)        
      CLOCK(47+KR,I) = EFORC(1+KRPZ)        
      CLOCK(48+KR,I) = EFORC(2+KRPZ)        
      CLOCK(49+KR,I) = EFORC(3+KRPZ)        
      KR3 = 1 + KRPZ/3        
      IF(.NOT.LSYS78) CLOCK(50+KR,I) = ECHRG(KR3)        
  680 CONTINUE        
C        
  690 CONTINUE        
C        
C     COPY STRESSES AND FORCES INTO OUTPUT BLOCKS        
C        
  700 CONTINUE        
      J = 2        
      K = 1        
      L = 0        
      ISTRES (1) = ELEMID        
      ISTRES (2) = NELHAR        
      DO 720 I = 1,NS        
      J = J + 1        
      STRES(J) = ESTRES(I)        
C        
      IF (I/6 .NE. K) GO TO 720        
      K = K + 1        
      DO 710 II = 1,3        
      J = J + 1        
      L = L + 1        
      STRES(J) = EFLUX(L)        
  710 CONTINUE        
  720 CONTINUE        
C        
      K = 0        
      J = 2        
      L = 1        
      IFORCE(1) = ELEMID        
      IFORCE(2) = NELHAR        
      DO 800 I  = 1,NUMPT        
      DO 800 KK = 1,NDOF        
      J = J + 1        
      K = K + 1        
      FORCE(J) = EFORC(K)        
C        
      IF (K/3 .NE. L) GO TO 800        
      J = J + 1        
      FORCE(J) = ECHRG(L)        
      L = L + 1        
  800 CONTINUE        
C        
 1001 CONTINUE        
C        
      RETURN        
      END        
