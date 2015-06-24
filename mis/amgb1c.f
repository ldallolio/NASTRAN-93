      SUBROUTINE AMGB1C (Q)        
C        
C     UNSTEADY FLOW ANALYSIS OF A SUPERSONIC CASCADE        
C        
      INTEGER         SLN        
      COMPLEX         SBKDE1,SBKDE2,F4,F4S,AM4,F5S,F6S,AM4TST,SUM3,SUM4,
     1                AM5TT,AM6,SUMSV1,SUMSV2,SVKL1,SVKL2,F5,F5T,AM5,   
     2                AM5T,AI,A,B,BSYCON,ALP,F1,AM1,ALN,BLKAPM,BKDEL3,  
     3                F1S,C1,C2P,C2N,C2,AMTEST,FT2,BLAM1,FT3,AM2,SUM1,  
     4                SUM2,F2,BLAM2,FT2T,C1T,FT3T,F2P,AM2P,SUM1T,SUM2T, 
     5                C1P,C1N,BKDEL1,BKDEL2,BLKAP1,ARG,ARG2,FT3TST,BC,  
     6                BC2,BC3,BC4,BC5,CA1,CA2,CA3,CA4,CLIFT,CMOMT,      
     7                PRES1,PRES2,PRES3,PRES4,QRES4,FQA,FQB,FQ7,PRESU,  
     8                PRESL,Q,GUSAMP        
      DIMENSION       GYE(29,29),GEE(29,40),PRESU(29),PRESL(29),XUP(29),
     1                XTEMP(29),GEETMP(29,20),XLOW(29),AYE(10,29),      
     2                INDEX(29,3),Q(NSTNS,NSTNS),PRES1(21),PRES2(21),   
     3                PRES3(21),PRES4(21),QRES4(21),SBKDE1(201),        
     4                SBKDE2(201),SUMSV1(201),SUMSV2(201),SVKL1(201),   
     5                SVKL2(201),XLSV1(21),XLSV2(21),XLSV3(21),XLSV4(21)
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /SYSTEM/ SYSBUF,IBBOUT        
      COMMON /AMGMN / MCB(7),NROW,DUM(2),REFC,SIGM ,RFREQ        
      COMMON /BAMG1L/ IREF,MINMAC,MAXMAC,NLINES,NSTNS,REFSTG,REFCRD,    
     1                REFMAC,REFDEN,REFVEL,REFFLO,SLN,NSTNSX,STG,       
     2                CHORD,RADIUS,BSPACE,MACH,DEN,VEL,FLOWA,AMACHD,    
     3                REDFD,BLSPC,AMACHR,TSONIC        
      COMMON /BLK1  / SCRK,SPS,SNS,DSTR,AI,PI,DEL,SIGMA,BETA,RES        
      COMMON /BLK2  / BSYCON        
      COMMON /BLK3  / SBKDE1,SBKDE2,F4,F4S,AM4,F5S,F6S,AM4TST,SUM3,SUM4,
     1                AM5TT,AM6,SUMSV1,SUMSV2,SVKL1,SVKL2,F5,F5T,AM5,   
     2                AM5T,A,B,ALP,F1,AM1,ALN,BLKAPM,BKDEL3,F1S,C1,C2P, 
     3                C2N,C2,AMTEST,FT2,BLAM1,FT3,AM2,SUM1,SUM2,F2,     
     4                BLAM2,FT2T,C1T,FT3T,F2P,AM2P,SUM1T,SUM2T,C1P,C1N, 
     5                BKDEL1,BKDEL2,BLKAP1,ARG,ARG2,FT3TST,BC,BC2,BC3,  
     6                BC4,BC5,CA1,CA2,CA3,CA4,CLIFT,CMOMT,PRES1,PRES2,  
     7                PRES3,PRES4,QRES4,FQA,FQB,FQ7        
      COMMON /BLK4  / I,R,Y,A1,B1,C4,C5,GL,I6,I7,JL,NL,RI,RT,R5,SN,SP,  
     1                XL,Y1,AMU,GAM,IDX,INX,NL2,RL1,RL2,RQ1,RQ2,XL1,    
     2                ALP1,ALP2,GAMN,GAMP,INER,IOUT,REDF,STAG,STEP,     
     3                AMACH,BETNN,BETNP,BKAP1,XLSV1,XLSV2,XLSV3,XLSV4,  
     4                ALPAMP,AMOAXS,GUSAMP,DISAMP,PITAXS,PITCOR        
C        
C     THEORY DEPENDENT RESTRICTION OF NO MORE THAN 10 COMPUTING        
C     STATIONS PER STREAMLINE IS REFLECTED IN CODING.        
C        
      IF (NSTNS .GT. 10) GO TO 420        
C        
      REDF  = REDFD        
      AMACH = AMACHD        
      AI    = CMPLX(0.0,1.0)        
      PI    = 3.1415927        
      PITCOR= BLSPC        
      STAG  = 90.0 - STG        
      SIGMA = -SIGM*PI/180.0        
      BETA  = SQRT(AMACH**2 - 1.0)        
      SCRK  = REDF*AMACH/(BETA**2)        
      DEL   = SCRK*AMACH        
      AMU   = REDF/(BETA**2)        
      SP    = PITCOR*COS(STAG*PI/180.0)*2.0        
      SN    = PITCOR*SIN(STAG*PI/180.0)*2.0        
      SPS   = SP        
      SNS   = SN*BETA        
      DSTR  = SQRT(SPS**2 - SNS**2)        
      SPS1  = ABS(SPS - SNS)        
      IF (SPS1 .LT. .00001) GO TO 400        
C        
C     ZERO OUT GEE        
C        
      NSTNS2 = 2*NSTNS        
      NSTNS4 = 4*NSTNS        
      DO 10 I = 1,29        
      DO 10 J = 1,NSTNS4        
   10 GEE(I,J) = 0.0        
      PITAXS = 0.0        
      AMOAXS = 0.        
      CALL ASYCON        
      CALL AKP2        
      RL1 = 9        
      S1  = SPS - SNS        
      AA  = S1/RL1        
      XLSV1(1) = 0.0        
      DO 20 JL = 1,9        
   20 XLSV1(JL+1) = JL*AA        
      AA  = SPS - SNS        
      RL2 = 19        
      S1  = 2.0 + SNS - SPS        
      TEMP= S1/RL2        
      XL  = AA        
      DO 30 JL = 1,20        
      XLSV2(JL) = XL        
      XLSV3(JL) = XL + SNS - SPS        
   30 XL  = XL  + TEMP        
      XL  = SNS + 2.0 - SPS        
      TEMP= (SPS-SNS)/RL1        
      DO 40 JL = 1,10        
      XLSV4(JL) = XL        
   40 XL = XL + TEMP        
C        
C     ACCUMULATE PRESSURE VECTORS INTO G-MATRIX        
C        
      DO 140 NM = 1,NSTNS        
      NTIMES = 1        
      IF (NM .GT.2) NTIMES = 2        
      DO 130 NMM = 1,NTIMES        
C        
C     DEFINE -----------------------------        
C            ALPAMP - PITCHING AMP        
C            DISAMP - PLUNGING AMP        
C            GUSAMP - GUST AMP        
C            GL -GUST WAVE NUMBER        
C        
      ALPAMP = 0.0        
      IF (NM .EQ. 2) ALPAMP = 1.0        
      DISAMP = 0.0        
      IF (NM .EQ. 1) DISAMP = 1.0        
      GUSAMP = 0.0        
      GL     = 0.0        
      IF (NM.GT.2 .AND. NMM.EQ.1) GUSAMP =-REDF/2.0 + (NM-2)*PI/4.0     
      IF (NM.GT.2 .AND. NMM.EQ.1) GL = (NM-2)*PI/2.0        
      IF (NM.GT.2 .AND. NMM.EQ.2) GUSAMP = REDF/2.0 + (NM-2)*PI/4.0     
      IF (NM.GT.2 .AND. NMM.EQ.2) GL =-(NM-2)*PI/2.0        
C        
      A = (1.0+AI*REDF*PITAXS)*ALPAMP - AI*REDF*DISAMP        
      B =-AI*REDF*ALPAMP        
      IF (GL .EQ. 0.0) GO TO 50        
      A = GUSAMP        
      B = 0.0        
   50 CONTINUE        
      CALL SUBA        
C        
C     FIND  DELTA P(LOWER-UPPER)        
C        
      DO 80 NX = 1,10        
      PRESU(NX) = PRES1(NX)        
      XUP(NX)   = XLSV1(NX)        
      IF (NX .EQ. 10) GO TO 60        
      NXX = NX + 20        
      PRESL(NXX) = PRES4(NX+1)        
      XLOW( NXX) = XLSV4(NX+1)        
      GO TO 70        
   60 PRESU(NX) = (PRES1(10) + PRES2(1))/2.0        
      XUP(10)   = (XLSV1(10) + XLSV2(1))/2.0        
   70 CONTINUE        
   80 CONTINUE        
      DO 110 NX = 1,20        
      NXX = NX + 10        
      IF (NX .EQ. 20) GO TO 90        
      PRESU(NXX) = PRES2(NX+1)        
      XUP  (NXX) = XLSV2(NX+1)        
      PRESL(NX)  = PRES3(NX)        
      XLOW( NX)  = XLSV3(NX)        
      GO TO 100        
   90 PRESL(20) = (PRES3(20) + PRES4(1))/2.0        
      XLOW(20)  = (XLSV3(20) + XLSV4(1))/2.0        
  100 CONTINUE        
  110 CONTINUE        
      NM2 = NM + NSTNS        
      NM3 = NM + 2*NSTNS        
      NM4 = NM + 3*NSTNS        
      DO 120 NMMM = 1,29        
      GEE(NMMM,NM)  = GEE(NMMM,NM ) + REAL(PRESL(NMMM))        
      GEE(NMMM,NM2) = GEE(NMMM,NM2) + AIMAG(PRESL(NMMM))        
      GEE(NMMM,NM3) = GEE(NMMM,NM3) + REAL(PRESU(NMMM))        
      GEE(NMMM,NM4) = GEE(NMMM,NM4) + AIMAG(PRESU(NMMM))        
  120 CONTINUE        
  130 CONTINUE        
  140 CONTINUE        
C        
C     NOW DEFINE  I-MATRIX (NSTNS X 29)        
C        
      AYE(1,1) = 2.0        
      CON = 1.0        
      AYE(1,2) = 2.0        
      N1N = 27        
      DO 150 J = 1,N1N        
      AYE(1,J+2) = CON*4.0/J/PI        
  150 CON = 1.0 - CON        
      AYE(2,1) = 2.0        
      AYE(2,2) = 2.66666667        
      CON = 1.0        
      DO 160 J = 1,N1N        
      AYE(2,J+2) = CON*4/J/PI        
  160 CON = -CON        
      DO 170 I = 3,NSTNS        
      DO 170 J = 2,28        
      CON = 0.0        
      IF ((I-1) .EQ. J) CON = 1.0        
  170 AYE(I,J+1) = CON        
      DO 180 J = 3,NSTNS        
      AYE(J,1) = AYE(1,J)        
  180 AYE(J,2) = AYE(2,J)        
C        
C     Q DUE TO PRESL ONLY        
C        
C     NOW DEFINE LARGE G MATRIX        
C        
      DO 190 I = 1,29        
      GYE(1,I) = 0.0        
  190 GYE(I,1) = 1.0        
C        
C     PUT XLOW IN XTEMP        
C        
      DO 200 I = 1,29        
  200 XTEMP(I) = XLOW(I)        
      DO 210 J = 3,29        
      CONST = (J-2)*PI/2.0        
      DO 210 I = 2,29        
      GYE(I,J) = SIN(CONST*XTEMP(I))        
  210 CONTINUE        
      DO 220 I = 2,29        
  220 GYE(I,2) = XTEMP(I)        
C        
C     PUT PRESL PART OF GEE IN GEETMP        
C        
      DO 230 I = 1,29        
      DO 230 J = 1,NSTNS2        
  230 GEETMP(I,J) = GEE(I,J)        
C        
C     SOLVE FOR G-INVERSE G IN GEE MATRIV        
C     ISING = 1 NON-SINGULAR (GYE)        
C     ISING = 2  SIGULAR     (GYE)        
C     INDEX IS WORK STORAGE FOR ROUTINE INVERS        
C        
      ISING = -1        
      CALL INVERS (29,GYE,29,GEETMP,NSTNS2,DETERM,ISING,INDEX)        
      IF (ISING .EQ. 2) GO TO 410        
C        
C     NOW  MULTIPLY  I*G-INVERSE*G(DELTA P'S)        
C        
      DO 250 J = 1,NSTNS        
      DO 250 K = 1,NSTNS        
      NF   = K + NSTNS        
      SUMI = 0.0        
      SUMR = 0.0        
      DO 240 I = 1,29        
      SUMR = AYE(J,I)*GEETMP(I,K ) + SUMR        
      SUMI = AYE(J,I)*GEETMP(I,NF) + SUMI        
  240 CONTINUE        
C        
C  NOTE - NOTE THAT DUE TO CEXP( - I*OMEGA*T) TYPE OF TIME DEPENDENCE   
C         IN UCAS DEVELOPMENT, Q IS DEFINED AS THE COMPLEX CONJUGATE    
C         OF 'USUAL' Q        
C        
  250 Q(J,K) = 2.0*CMPLX(SUMR,-SUMI)        
C        
C     FINALLY, Q DUE TO (PRESL-PRESU) IS COMPUTED BY SUBTRACTING Q DUE  
C     TO PRESU FROM Q DUE TO PRESL ABOVE        
C        
C     LARGE G MATRIX        
C        
      DO 260 I = 1,29        
      GYE(1,I) = 0.0        
  260 GYE(I,1) = 1.0        
C        
C     PUT XUP IN XTEMP        
C        
      DO 270 I = 1,29        
  270 XTEMP(I) = XUP(I)        
      DO 280 J = 3,29        
      CONST = (J-2)*PI/2.0        
      DO 280 I = 2,29        
      GYE(I,J) = SIN(CONST*XTEMP(I))        
  280 CONTINUE        
      DO 290 I = 2, 29        
  290 GYE(I,2) = XTEMP(I)        
C        
C     PUT PRESU PART OF GEE IN GEETMP        
C        
      DO 300 I = 1,29        
      DO 300 J = 1,NSTNS2        
C        
      NSNS2 = NSTNS2 + J        
  300 GEETMP(I,J) = GEE(I,NSNS2)        
C        
C     SOLVE FOR G-INVERSE G IN GEETMP MATRIX        
C     ISING = 1  NON-SINGULAR (GYE)        
C     ISING = 2  SINGULAR GYE        
C     INDEX IS WORK STORAGE FOR ROUTINE INVERS        
C        
      ISING = -1        
      CALL INVERS (29,GYE,29,GEETMP,NSTNS2,DETERM,ISING,INDEX)        
C        
      IF (ISING .EQ. 2) GO TO 410        
C        
C     MULTIPLY I*G-INVERS*G        
C        
      DO 320 J = 1,NSTNS        
      DO 320 K = 1,NSTNS        
      NF = K + NSTNS        
      SUMI = 0.0        
      SUMR = 0.0        
      DO 310 I = 1,29        
C        
      SUMR = AYE(J,I)*GEETMP(I,K ) + SUMR        
      SUMI = AYE(J,I)*GEETMP(I,NF) + SUMI        
C        
  310 CONTINUE        
C        
  320 Q(J,K) = Q(J,K) - 2.0*CMPLX(SUMR,-SUMI)        
C        
      RETURN        
C        
  400 WRITE (IBBOUT,500) UFM        
      GO TO 430        
  410 WRITE (IBBOUT,510) UFM        
      GO TO 430        
  420 WRITE (IBBOUT,520) UFM,SLN,NSTNS        
  430 CALL MESAGE (-61,0,0)        
      RETURN        
C        
  500 FORMAT (A23,' - AMG MODULE -SUBROUTINE AMGB1C', /39X,        
     1        'AXIAL MACH NUMB. IS EQUAL TO OR GREATER THAN ONE.')      
  510 FORMAT (A23,' - AMG MODULE - LARGE G-MATRIX IS SINGULAR IN ',     
     2        'ROUTINE AMGBIC.')        
  520 FORMAT (A23,' - AMG MODULE - NUMBER OF COMPUTING STATIONS ON ',   
     1        'STREAMLINE',I8,4H IS ,I3,1H. , /39X,'SUPERSONIC CASCADE',
     2        ' ROUTINE AMGB1C ALLOWS ONLY A MAXIMUM OF 10.')        
      END        
