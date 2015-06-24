      SUBROUTINE ALG13 (IBL,YS,YP,XS,XP,YSEMI,XSEMI,LOG1,LOG2,N,IPRINT, 
     1                BETA1,BETA2,P,Q,YZERO,T,YONE,XDEL,YDEL,Z,AXIALC,  
     2                LNCT,IFCORD,SQ,SB,ISECN,XSEMJ,YSEMJ,ISTAK,XHERE,  
     3                X,SS,NSTNS,R,DX,Y,DY,SS1,BX,SIGMA,CCORD,ISPLIT,   
     4                YZEROS,TS,YONES,ZSPMXT,PERSPJ,INAST,IRLE,IRTE,    
     5                THARR)        
C        
      REAL            IX,IY,IXY,IPX,IPY,IXD,IYD,IXN,IYN,IXYN        
      DIMENSION       CCORD(1),NAME(2),XXM(81),SNADUM(10),THARR(21,10)  
      DIMENSION       YS(21,80),YP(21,80),XS(21,80),XP(21,80),        
     1                YSEMI(21,31),XSEMI(21,31),S(80),PHI(11),        
     2                THICK2(80),XM(81),YM(80),AM(80),XSEMJ(21,31),     
     3                YSEMJ(21,31),XHERE(100),X(100),SS(100),R(10,21),  
     4                DX(100),DY(100),SS1(80,4),Y(100),SIGMA(100)       
      DIMENSION       XSPLTM(45),YSPLTM(45),SSPLTM(45),XSPLTS(45),      
     1                YSPLTS(45),XSPLTP(45),YSPLTP(45),THICK(45)        
      COMMON /UDSTR2/ NBLDES,STAG(21),CHORDD(21)        
      DATA    NAME  / 4HALG1, 4H3    /        
C        
      F1(A) = A*EXP(1.0-A*SQ)*SQ        
      F2(A) = (SQ-1.0)*A*EXP(1.0+A*(1.0-SQ))        
      F3(A,B,C,D) = B/A**3*EXP(A*XD)*(A*XD-2.0) + C*(XD+SQ) + D        
      F4(A,B) = ABS(A-B)/(A-B)        
      F5(A,B,C) = B/A**2*EXP(A*XD)*(A*XD-1.0) + C        
      F6(XAB) = SQRT(RDIUS**2-(XAB-X1)**2) + Y1        
      F7(XAB) =-SQRT(RDIUS**2-(XAB-X1)**2) + Y1        
      F8(XAB) =-1./SQRT(RDIUS**2-(XAB-X1)**2)*(XAB-X1)        
C        
10    FORMAT (1H1)        
      A    = 0.        
      D    = 0.        
      BTA1 = BETA1        
      BTA2 = BETA2        
      BETA3= 0.0        
      PI   = 3.1415926535        
      C1   = 180.0/PI        
      IF (IPRINT .GE. 2) GO TO 40        
      WRITE  (LOG2,20) IBL,P,Q,BETA1,BETA2,YZERO,T,YONE,Z,AXIALC        
20    FORMAT (1H1,44X,43HSTREAMSURFACE GEOMETRY ON STREAMLINE NUMBER,I3,
     1 /45X,46(1H*), //20X,1HP,1        
     25X,1H=,F7.4,6X,72H(D2YDX2 OF MEANLINE AT LEADING EDGE AS A FRACTIO
     3N OF ITS MAXIMUM VALUE.), /20X,1HQ,15X,1H=,F7.4,6X,73H(D2YDX2 OF M
     4EANLINE AT TRAILING EDGE AS A FRACTION OF ITS MAXIMUM VALUE.), /20
     5X,5HBETA1,11X,1H=,F7.3,6X,20H(BLADE INLET ANGLE.), /20X,5HBETA2,11
     6X,1H=,F7.3,6X,21H(BLADE OUTLET ANGLE.), /20X,5HYZERO,11X,1H=,F8.5,
     75X,51H(BLADE LEADING EDGE RADIUS AS A FRACTION OF CHORD.), /20X,1H
     8T,15X,1H=,F8.5,5X,49H(BLADE MAXIMUM THICKNESS AS A FRACTION OF CHO
     9RD.), /20X,4HYONE,12X,1H=,F8.5,5X,60H(BLADE TRAILING EDGE HALF-THI
     OCKNESS AS A FRACTION OF CHORD.), /20X,1HZ,15X,1H=,F7.4,6X,59H(LOCA
     1TION OF MAXIMUM THICKNESS AS A FRACTION OF MEAN LINE.), /20X,4HCOR
     2D,12X,1H=,F7.4,6X,39H(CHORD OR MERIDIONAL CHORD OF SECTION.))     
      IF (ISECN.EQ.1 .OR. ISECN.EQ.3) WRITE (LOG2,30) SQ,SB        
30    FORMAT (20X,1HS,15X,1H=,F7.4,6X,53H(INFLECTION POINT AS A FRACTION
     1 OF MERIDIONAL CHORD.), /20X,5HBETA3,11X,1H=,F7.3,6X,36H(CHANGE IN
     2 ANGLE FROM LEADING EDGE.))        
   40 IF (IPRINT .EQ. 3) GO TO 55        
      LNCT = LNCT + 2        
      IF (LNCT .LE. 60)GO TO 45        
      LNCT = 3        
      WRITE  (LOG2,10)        
45    WRITE  (LOG2,50) IBL,P,Q,BETA1,BETA2,YZERO,T,YONE,Z,AXIALC        
50    FORMAT (2X, /5X,4HLINE,I3,4H  P=,F7.4,4H  Q=,F7.4,8H  BETA1=,F7.3,
     18H  BETA2=,F7.3,8H  YZERO=,F7.5,6H  T/C=,F7.5,7H  YONE=,F7.5,4H  Z
     2=,F7.4,6H  AXC=,F7.3)        
55    IF (ISECN .EQ. 1) GO TO 60        
      IF (ISECN .EQ. 3) GO TO 130        
      IF (ISECN .EQ. 2) GO TO 150        
      H  = 1.0/(1.0+SQRT((1.0-Q)/(1.0-P)))        
      HH = H*H        
      OA = 4.0*(TAN(BETA1/C1)-TAN(BETA2/C1))/(P/(1.0-P)*HH+H-1.0/3.0)   
      OA48 = OA/48.0        
      XK2  =-HH/(8.0*(1.0-P))*OA        
      B    = HH*H/12.0*OA+TAN(BETA1/C1)        
      C    =-HH*HH*OA48        
      XMLC = SQRT(1.0+(OA48*(1.0-H)**4+XK2+B+C)**2)        
      GO TO 160        
60    NQ = 1        
      SB = BETA1+SB        
      G1 = 1.0/SQ        
      R1 = F1(G1)        
      G2 = G1+5.0        
      R2 = F1(G2)        
      S2 = F4(R2,P)        
70    G3 = G2+(P-R2)*(G2-G1)/(R2-R1)        
      R3 = F1(G3)        
      S3 = F4(R3,P)        
      IF (ABS(R3-P) .LE. 0.0001) GO TO 90        
      IF (NQ .GT. 50) GO TO 1290        
      NQ = NQ + 1        
      IF (ABS(S2-S3) .LE. 0.0001) GO TO 80        
      G1 = G3        
      R1 = R3        
      GO TO 70        
80    G2 = G3        
      R2 = R3        
      S2 = S3        
      GO TO 70        
90    A1 = G3        
      NQ = 1        
      G1 = 1.0/(SQ-1.0)        
      R1 = F2(G1)        
      G2 = G1-5.0        
      R2 = F2(G2)        
      S2 = F4(R2,Q)        
100   G3 = G2+(Q-R2)*(G2-G1)/(R2-R1)        
      R3 = F2(G3)        
      S3 = F4(R3,Q)        
      IF (ABS(R3-Q) .LE. 0.0001) GO TO 120        
      IF (NQ .GT. 50) GO TO 1290        
      NQ = NQ + 1        
      IF (ABS(S2-S3) .LE. 0.0001) GO TO 110        
      G1 = G3        
      R1 = R3        
      GO TO 100        
110   G2 = G3        
      R2 = R3        
      S2 = S3        
      GO TO 100        
120   A2 = G3        
      B1 = A1**2*(TAN(BETA1/C1)-TAN(SB/C1))/        
     1     (1.0-(A1*SQ+1.0)*EXP(-A1*SQ))        
      CC1= TAN(SB/C1)+B1/A1**2        
      E1 = (A1*SQ+2.0)*B1/A1**3*EXP(-A1*SQ)        
      B2 = A2**2*(TAN(BETA2/C1)-TAN(SB/C1))/        
     1     (1.0+(A2*(1.0-SQ)-1.0)*EXP(A2*(1.0-SQ)))        
      CC2= TAN(SB/C1)+B2/A2**2        
      D2 = 2.*(B2/A2**3-B1/A1**3)+SQ*(CC1-CC2) + E1        
      XD = 1.0-SQ        
      R2 = F3(A2,B2,CC2,D2)        
      XMLC = SQRT(1.0+R2**2)        
      GO TO 160        
130   I1 = 1        
      BETA3 = BETA1+SB        
      S0 = 0.        
      X0 = 0.        
      Y0 = 0.        
      Y21= 0.0        
      I2 = FLOAT(N)*SQ        
      IF (I2 .LE. 1) SQ = 0.0        
      IF (I2 .LE. 1) BETA3 = BETA1        
      IF (I2 .LE. 1) GO TO 140        
      XRNGE = SQ        
      FACT  = SQ        
      CALL ALG18 (BETA1,BETA3,I1,I2,FACT,X0,Y0,S0,XRNGE,Y11,X11,Y21,    
     1            RDIUS1,S,C1)        
      I1 = I2        
      X0 = SQ        
      Y0 = Y21        
      S0 = S(I1)        
140   I2 = N        
      FACT  = 1.-SQ        
      XRNGE = FACT        
      CALL ALG18 (BETA3,BETA2,I1,I2,FACT,X0,Y0,S0,XRNGE,Y12,X12,Y22,    
     1            RDIUS2,S,C1)        
      XMLC = SQRT(1.0+Y22**2)        
      GO TO 160        
150   CALL ALG18 (BETA1,BETA2,1,N,1.0,0.0,0.0,0.0,1.0,Y1,X1,Y2,RDIUS,   
     1            S,C1)        
      XMLC  = SQRT(1.+Y2**2)        
      CHORD = XMLC/(1.-2.*YZERO*(1.-XMLC))        
      FCSLMN= 1.0 - CHORD*2.*YZERO        
      GO TO 170        
160   CHORD = XMLC/(1.0-YZERO+XMLC*(YZERO+ABS(YONE*SIN(BETA2/C1))))     
      FCSLMN= 1.0 - CHORD*(YZERO+ABS(YONE*SIN(BETA2/C1)))        
170   IF (IFCORD .EQ. 1) AXIALC = AXIALC/CHORD        
      YZERO = YZERO*CHORD/FCSLMN        
      YONE  = YONE*CHORD/FCSLMN        
      T   = T*CHORD/FCSLMN        
      S(1)= 0.0        
      XX  = 0.0        
      XN  = N        
      IF (ISECN .EQ. 2) GO TO 240        
      AT = (YZERO-T/2.0)/(2.0*Z**3)        
      CT = (T/2.0-YZERO)*3.0/(2.0*Z)        
      DT = YZERO        
      ET = (YONE-T/2.0)/(1.0-Z)**3 - 1.5*(YZERO-T/2.0)/(Z**2*(1.0-Z))   
      FT = 1.5*(YZERO-T/2.0)/Z**2        
      HT = T/2.0        
      IF (ISECN .EQ. 3) GO TO 240        
      DELX = 1.0/(10.0*(XN-1.0))        
      ASSIGN 190 TO ISEC1        
      ASSIGN 290 TO ISEC2        
      IF (ISECN .EQ. 0) GO TO 180        
      ASSIGN 200 TO ISEC1        
      ASSIGN 300 TO ISEC2        
180   DO 230 J  = 2,N        
      DO 220 JJ = 1,11        
      GO TO ISEC1, (190,200)        
190   PHI(JJ) = SQRT(1.0+(OA/12.0*(XX-H)**3+XK2*2.0*XX+B)**2)        
      GO TO 220        
200   XD = XX - SQ        
      IF (XD .GT. 0.0) GO TO 210        
      PHI(JJ) = SQRT(1.0+(F5(A1,B1,CC1))**2)        
      GO TO 220        
210   PHI(JJ) = SQRT(1.+(F5(A2,B2,CC2))**2)        
220   XX = XX + DELX        
      XX = XX - DELX        
230   S(J) = S(J-1)+ (PHI(1)+ PHI(11)+ 4.0*(PHI(2)+PHI(4)+PHI(6)+PHI(8)+
     1       PHI(10))+2.0*(PHI(3)+PHI(5)+PHI(7)+PHI(9)))/(30.0*(XN-1.0))
240   DELX = 1.0/(XN-1.0)        
      IF (ISECN .NE. 2) GO TO 250        
      T2 = T/2.        
      TPRIM2 = T2 - YZERO        
      C2 = 2.*C1        
      AFORM = (TPRIM2+RDIUS*(1.-COS((BETA1-BETA2)/C2)))/XMLC*2.        
      PHIS  = ACOS((1.-AFORM**2)/(1.+AFORM**2))        
      RS    = YZERO + XMLC/2./SIN(PHIS)        
      YSS   = RDIUS - RS + T2        
      BFORM = (RDIUS*(1.-COS((BETA1-BETA2)/C2))-TPRIM2)/XMLC*2.        
      PHIP  = ACOS((1.-BFORM**2)/(1.+BFORM**2))        
      PHI2  = ABS((BETA1-BETA2)/C1)        
250   XM(1) = 0.0        
      IF (ISECN .NE. 3) GO TO 260        
      YMM = 0.0        
      XMM = 0.0        
      I2  = SQ*FLOAT(N)        
      I3  = I2        
      IF (I2 .LE.  1) I2 = N + 1        
      DELX= SQ/FLOAT(I2-1)        
      IF (I3 .NE. I2) I3 = 1        
      DELXX = (1.-SQ)/FLOAT(N-I3)        
      IF (I2 .EQ. N+1) DELX = DELXX        
260   DO 380 J = 1,N        
      SN = S(J)/S(N)        
      IF (ISECN .EQ. 2) GO TO 340        
      IF (SN    .GT. Z) GO TO 270        
      THICK2(J) = (AT*SN**2+CT)*SN + DT        
      GO TO 280        
270   SN = SN - Z        
      THICK2(J) = (ET*SN+FT)*SN**2 + HT        
280   IF (ISECN .EQ. 3) GO TO 320        
      GO TO ISEC2, (290,300)        
290   YM(J)  = OA48*(XM(J)-H)**4+XK2*XM(J)**2 + B*XM(J) + C        
      YPRIME = OA/12.0*(XM(J)-H)**3 + XK2*2.0*XM(J) + B        
      GO TO 370        
300   XD = XM(J) - SQ        
      IF (XD .GT. 0.0) GO TO 310        
      YM(J)  = F3(A1,B1,CC1,E1)        
      YPRIME = F5(A1,B1,CC1)        
      GO TO 370        
310   YM(J)  = F3(A2,B2,CC2,D2)        
      YPRIME = F5(A2,B2,CC2)        
      GO TO 370        
320   IF (XM(J)-SQ.GT.0.0 .OR. XM(J).EQ.0.0 .AND. SQ.EQ.0.0) GO TO 330  
      IF (BETA1 .EQ. BETA3) GO TO 360        
      BTA1  = BETA1        
      BTA2  = BETA3        
      RDIUS = RDIUS1        
      Y1 = Y11        
      X1 = X11        
      GO TO 350        
330   IF (BETA2 .EQ. BETA3) GO TO 360        
      RDIUS = RDIUS2        
      X1 = X12        
      Y1 = Y12        
      BTA1 = BETA3        
      BTA2 = BETA2        
      GO TO 350        
340   PHIX = (SN-0.5)*PHI2        
      THICK2(J) = YSS*COS(PHIX) + SQRT(RS**2-YSS**2*SIN(PHIX)**2) -RDIUS
350   YM(J)  = F6(XM(J))        
      YPRIME = F8(XM(J))        
      IF (BTA1-BTA2 .LT. 0.0) YPRIME = -YPRIME        
      IF (BTA1-BTA2 .LT. 0.0) YM(J) = F7(XM(J))        
      IF (ISECN .EQ. 2) GO TO 370        
      IF (J .EQ. I3) DELX = DELXX        
      GO TO 370        
360   YPRIME = TAN(BETA3/C1)        
      IF (J .NE. 1) XMM = XM(J-1)/FCSLMN - YZERO        
      IF (J .NE. 1) YMM = YM(J-1)/FCSLMN        
      YM(J) = YPRIME*(XM(J)-XMM) + YMM        
      IF (J .EQ. I3) DELX = DELXX        
370   XM(J+1) = XM(J) + DELX        
      FYPR = 1.0/SQRT(1.0+YPRIME**2)        
      XS(IBL,J) = (XM(J)-THICK2(J)*YPRIME*FYPR+YZERO)*FCSLMN        
      YS(IBL,J) = (YM(J)+THICK2(J)*FYPR)*FCSLMN        
      XP(IBL,J) = (XM(J)+THICK2(J)*YPRIME*FYPR+YZERO)*FCSLMN        
      YP(IBL,J) = (YM(J)-THICK2(J)*FYPR)*FCSLMN        
      AM(J)  = ATAN(YPRIME)*C1        
      XXM(J) = XM(J)        
      IF(J .EQ. N) STAGER = ATAN(YM(N)/XM(N))*C1        
      IF(J .EQ. N) STAG(IBL) = STAGER        
      XM(J) = (XM(J)+YZERO)*FCSLMN        
      YM(J) = YM(J)*FCSLMN        
      THICK2(J) = THICK2(J)*FCSLMN        
380   S(J) = S(J)*FCSLMN        
      IF (ISPLIT .EQ. 0) GO TO 530        
      XSPLTM(1) = 1. - PERSPJ        
      K1 = 25        
      XSPLTM(K1) = 1.        
      K11 = K1 - 1        
      DELXX = PERSPJ/FLOAT(K11)        
      DO 390 J = 2,K11        
390   XSPLTM(J) = XSPLTM(J-1) + DELXX        
      CALL ALG15 (XM,YM,N,XSPLTM,YSPLTM,K1,1)        
      YLE = YSPLTM(1)        
      CALL ALG15 (XM,S,N,XSPLTM,SSPLTM,K1,1)        
      CALL ALG15 (XM,AM,N,XSPLTM,SS1(1,3),K1,1)        
      SSPLS = SSPLTM(1)        
      DO 400 J = 1,K1        
400   SSPLTM(J) = SSPLTM(J) - SSPLS        
      GO TO (410,420), ISPLIT        
410   XNORMS = SQRT((XSPLTM(K1)-XSPLTM(1))**2+(YSPLTM(K1)-YSPLTM(1))**2)
      CHORDS = XNORMS/(1.-YZEROS+XNORMS*(YZEROS+ABS(YONES*SIN(BETA2/    
     1         C1))))        
      FCSLMS = (PERSPJ-CHORDS*(YZEROS+ABS(YONES*SIN(BETA2/C1))))/PERSPJ 
      YZEROS = YZEROS*CHORDS/FCSLMS        
      YONES  = YONES *CHORDS/FCSLMS        
      TS  = TS*CHORDS/FCSLMS        
      AT  = (YZEROS-TS/2.)/(2.*ZSPMXT**3)        
      CT  = (TS/2.-YZEROS)*3./(2.*ZSPMXT)        
      DT  = YZEROS        
      ET  = (YONES-TS/2.)/(1.-ZSPMXT)**3-1.5*(YZEROS-TS/2.)/        
     1      (ZSPMXT**2*(1.-ZSPMXT))        
      FT  = 1.5*(YZEROS-TS/2.)/ZSPMXT**2        
      HT  = TS/2.        
      GO TO 450        
420   YZS = YZEROS        
      TS1 = TS        
      BETA1 = SS1(1,3)        
      Y1  =-COS(BETA1/C1)/(SIN(BETA1/C1)-SIN(BETA2/C1))        
      X1  = SIN(BETA1/C1)/(SIN(BETA1/C1)-SIN(BETA2/C1))        
      RDIUS = ABS(1./(SIN(BETA1/C1)-SIN(BETA2/C1)))        
      Y2  = TAN((BETA1+BETA2)/(2.*C1))        
      XMLCS  = SQRT(1.+Y2**2)        
      CHORDS = XMLCS/(1.0-2.*YZEROS*(1.0-XMLCS))        
      FCSLMS = 1.0-CHORDS*2.*YZEROS        
      YZEROS = YZEROS*CHORDS/FCSLMS        
      TS  = TS*CHORDS/FCSLMS        
      SS1(1,1) = 0.        
      DELX  = 1./(XN-1.)        
      T2    = TS/2.        
      TPRIM2= T2-YZEROS        
      C2    = 2.*C1        
      AFORM = (TPRIM2+RDIUS*(1.-COS((BETA1-BETA2)/C2)))/XMLCS*2.        
      PHIS  = ACOS((1.-AFORM**2)/(1.+AFORM**2))        
      RS    = YZEROS + XMLCS/2./SIN(PHIS)        
      YSS   = RDIUS - RS + T2        
      BFORM = (RDIUS*(1.-COS((BETA1-BETA2)/C2))-TPRIM2)/XMLCS*2.        
      PHIP  = ACOS((1.-BFORM**2)/(1.+BFORM**2))        
      RP    = XMLCS/2./SIN(PHIP)-YZEROS        
      YPP   = RDIUS - RP - T2        
      XX = 0.        
      DO 430 J = 2,N        
      XX = XX + DELX        
      PHI1 = ATAN(-1./SQRT(RDIUS**2-(XX-X1)**2)*(XX-X1))        
      IF (BETA1 .LT. 0.) PHI1 = -PHI1        
      PHI2 = ABS(BETA1/C1-PHI1)        
430   SS1(J,1) = RDIUS*PHI2        
      DO 440 J = 1,N        
      SS1(J,1) = SS1(J,1)/SS1(N,1)        
      PHIX = (SS1(J,1)-.5)*PHI2        
440   SS1(J,2) =(YSS*COS(PHIX)+SQRT(RS**2-YSS**2*SIN(PHIX)**2)-RDIUS)/T2
      CALL ALG14 (XSPLTM,YSPLTM,K1,XSPLTM,XDUM,SS1(1,3),K1,1)        
      XNORMS = SQRT(PERSPJ**2+(YSPLTM(K1)-YSPLTM(1))**2)        
      CHORDS = XNORMS/(1.-2.*YZS*(1.-XNORMS))        
      FCSLMS = (PERSPJ-CHORDS*2.*YZS)/PERSPJ        
      TS     = TS1*CHORDS/FCSLMS        
      YZEROS = YZS*CHORDS/FCSLMS        
450   DO 500 J = 1,K1        
      SN = SSPLTM(J)/SSPLTM(K1)        
      IF (ISPLIT  .GT. 1) GO TO 480        
      IF (SN .GT. ZSPMXT) GO TO 460        
      THICK(J) = (AT*SN**2+CT)*SN + DT        
      GO TO 470        
460   SN = SN - ZSPMXT        
      THICK(J) = (ET*SN+FT)*SN**2 + HT        
470   FYPR   = 1./SQRT(1.+TAN(SS1(J,3)/C1)**2)        
      YPRIME = TAN(SS1(J,3)/C1)        
      GO TO 490        
480   CALL ALG15 (SS1,SS1(1,2),N,SN,THICK(J),1,1)        
      THICK(J) = THICK(J)*TS/2.        
      FYPR   = 1.0/SQRT(1.0+SS1(J,3)**2)        
      YPRIME = SS1(J,3)        
490   XSPLTP(J) = (XSPLTM(J)-(1.-PERSPJ)+THICK(J)*YPRIME*FYPR+YZEROS)*  
     1             FCSLMS+(1.-PERSPJ)        
      XSPLTS(J) = (XSPLTM(J)-(1.-PERSPJ)-THICK(J)*YPRIME*FYPR+YZEROS)*  
     1             FCSLMS+(1.-PERSPJ)        
      YSPLTP(J) = (YSPLTM(J)-YLE-THICK(J)*FYPR)*FCSLMS+YLE        
      YSPLTS(J) = (YSPLTM(J)-YLE+THICK(J)*FYPR)*FCSLMS+YLE        
      XSPLTM(J) = (XSPLTM(J)-(1.-PERSPJ)+YZEROS)*FCSLMS+(1.-PERSPJ)     
      YSPLTM(J) = (YSPLTM(J)-YLE)*FCSLMS+YLE        
      THICK(J)  = THICK(J)*FCSLMS        
500   SSPLTM(J) = SSPLTM(J)*FCSLMS        
      IF (ISPLIT .GT. 1) SS1(1,3) = ATAN(SS1(1,3))*C1        
      YZEROS = YZEROS*FCSLMS        
      AREAS  = PI/2.*YZEROS**2        
      AREA2  = AREAS        
      YINT   =-4./(3.*PI)*YZEROS*AREAS*SIN(SS1(1,3)/C1)        
      XINT   = YZEROS*(1.-COS(SS1(1,3)/C1)*4./(3.*PI))*AREAS        
      DO 510 J = 2,K1        
      DELA  = (THICK(J)+THICK(J-1))*(SSPLTM(J)-SSPLTM(J-1))        
      AREAS = AREAS + DELA        
      XINT  = XINT + DELA*(XSPLTM(J)+XSPLTM(J-1))/2.        
510   YINT  = YINT + DELA*(YSPLTM(J)+YSPLTM(J-1))/2.        
      IF (ISPLIT .LT. 2) GO TO 520        
      XINT  = XINT + AREA2*(XSPLTM(K1)+4.*YZEROS/(3.*PI)*COS(BETA2/C1)) 
      YINT  = YINT + AREA2*(YSPLTM(K1)+4.*YZEROS/(3.*PI)*SIN(BETA2/C1)) 
      AREAS = AREAS + AREA2        
520   XBARS = XINT/AREAS        
      YBARS = YINT/AREAS        
530   CONTINUE        
      YZERO = YZERO*FCSLMN        
      IF (INAST .EQ. 0) GO TO 550        
      NASNUM = IRTE - IRLE + 1        
      CALL ALG15 (X,SS,100,XHERE(IRLE),SNADUM(IRLE),NASNUM,1)        
      SNDUM1 = SNADUM(IRLE)        
      SNDUM2 = SNADUM(IRTE)        
      DO 540 J = IRLE,IRTE        
      SNADUM(J) = (SNADUM(J)-SNDUM1)/(SNDUM2-SNDUM1)        
      CALL ALG15 (XXM,THICK2,N,SNADUM(J),THARR(IBL,J),1,1)        
540   THARR(IBL,J) = THARR(IBL,J)*2.*AXIALC        
550   CONTINUE        
      AREA = PI/2.0*YZERO**2        
      XINT = YZERO*(1.0-COS(BETA1/C1)*4.0/(3.0*PI))*AREA        
      YINT =-4.0/(3.0*PI)*YZERO*AREA*SIN(BETA1/C1)        
      DO 560 J = 2,N        
      DELA = (THICK2(J)+THICK2(J-1))*(S(J)-S(J-1))        
      AREA = AREA + DELA        
      XINT = XINT + DELA*(XM(J)+XM(J-1))/2.0        
560   YINT = YINT + DELA*(YM(J)+YM(J-1))/2.0        
      IF (ISECN .NE. 2) GO TO 570        
      AREA2= PI/2.*YZERO**2        
      XINT = XINT + AREA2*(XM(N)+4.*YZERO/(3.*PI)*COS(BETA2/C1))        
      YINT = YINT + AREA2*(YM(N)+4.*YZERO/(3.*PI)*SIN(BETA2/C1))        
      AREA = AREA + AREA2        
570   XBAR = XINT/AREA        
      YBAR = YINT/AREA        
      XBARB= XBAR        
      YBARB= YBAR        
      YBAR = YBAR + YDEL/AXIALC        
      XBAR = XBAR + XDEL/AXIALC        
      AX   = 1./99.        
      DX(1)= 0.        
      DO 580 IK = 2,100        
580   DX(IK) = DX(IK-1) + AX        
      YMM = 0.0        
      XMM = 0.0        
      DO 660 IK = 1,100        
      XAB = DX(IK)        
      IF (ISECN .EQ. 0) GO TO 590        
      IF (ISECN .EQ. 1) GO TO 600        
      IF (ISECN .EQ. 2) GO TO 640        
      IF (ISECN .EQ. 3) GO TO 620        
590   Y(IK) = (OA48*(XAB-H)**4+XAB**2*XK2+B*XAB+C)*FCSLMN        
      SS1(IK,1) = OA/12.*(XAB-H)**3+XK2*2.*XAB+B        
      GO TO 660        
600   XD = XAB - SQ        
      IF (XD .GT. 0.) GO TO 610        
      Y(IK) = F3(A1,B1,CC1,E1)*FCSLMN        
      SS1(IK,1) = F5(A1,B1,CC1)        
      GO TO 660        
610   Y(IK) = F3(A2,B2,CC2,D2)*FCSLMN        
      SS1(IK,1) = F5(A2,B2,CC2)        
      GO TO 660        
620   IF (XAB-SQ.GT.0.0 .OR. XAB.EQ.0.0 .AND. SQ.EQ.0.0) GO TO 630      
      IF (BETA1 .EQ. BETA3) GO TO 650        
      RDIUS = RDIUS1        
      X1 = X11        
      Y1 = Y11        
      BTA1 = BETA1        
      BTA2 = BETA3        
      GO TO 640        
630   IF (BETA2 .EQ. BETA3) GO TO 650        
      RDIUS = RDIUS2        
      X1 = X12        
      Y1 = Y12        
      BTA1 = BETA3        
      BTA2 = BETA2        
640   Y(IK) = F6(XAB)*FCSLMN        
      SS1(IK,1) = F8(XAB)        
      IF (BTA1-BTA2 .LT. 0.0) SS1(IK,1) = -SS1(IK,1)        
      IF (BTA1-BTA2 .LT. 0.0) Y(IK) = F7(XAB)*FCSLMN        
      GO TO 660        
650   SS1(IK,1) = TAN(BETA3/C1)        
      IF (IK .NE. 1) YMM = Y(IK-1)/FCSLMN        
      IF (IK .NE. 1) XMM = DX(IK-1)        
      Y(IK) = (SS1(IK,1)*(XAB-XMM)+YMM)*FCSLMN        
660   SIGMA(IK) = DX(IK)*FCSLMN + YZERO        
      CALL ALG15 (SIGMA,Y,100,DX,DY,100,1)        
      CALL ALG15 (SIGMA,SS1(1,1),100,DX,Y,100,1)        
      CALL ALG15 (DX,DY,100,XBAR,XAB,1,1)        
      CALL ALG15 (DX,Y,100,XBAR,XBC,1,1)        
      XBAR = XBARB        
      YBAR = YBARB        
      IX   = 0.0        
      IY   = 0.0        
      IXY  = 0.0        
      DO 670 J = 2,N        
      DELA = (THICK2(J)+THICK2(J-1))*(S(J)-S(J-1))        
      IXD  = (THICK2(J)+THICK2(J-1))**3*(S(J)-S(J-1))/12.0        
      IYD  = (THICK2(J)+THICK2(J-1))*(S(J)-S(J-1))**3/12.0        
      COSANG = COS((AM(J)+AM(J-1))/C1)        
      IXN  = (IXD+IYD+(IXD-IYD)*COSANG)/2.0        
      IYN  = (IXD+IYD-(IXD-IYD)*COSANG)/2.0        
      IXYN = 0.0        
      IF (AM(J)+AM(J-1) .NE. 0.0) IXYN = ((IXN-IYN)*COSANG-IXD+IYD)/    
     1   (2.0*SIN((AM(J)+AM(J-1))/C1))        
      IX  = IX + IXN + DELA*((YM(J)+YM(J-1))/2.0-YBAR)**2        
      IY  = IY + IYN + DELA*((XM(J)+XM(J-1))/2.0-XBAR)**2        
670   IXY = IXY+ IXYN+ DELA*(YBAR-(YM(J)+YM(J-1))/2.0)*(XBAR-(XM(J)+    
     1      XM(J-1))/2.0)        
      ANG = ATAN(2.0*IXY/(IY-IX))        
      IPX = (IX+IY)/2.0+(IX-IY)/2.0*COS(ANG)-IXY*SIN(ANG)        
      IPY = (IX+IY)/2.0-(IX-IY)/2.0*COS(ANG)+IXY*SIN(ANG)        
      ANG = ANG/2.0*C1        
      XML = XM(N)        
      YML = YM(N)        
      CAMBER = BETA1 - BETA2        
      IF (IPRINT .GE. 2) GO TO 790        
      LNCT = 47        
      IF (ISECN.EQ.1 .OR. ISECN.EQ.3) LNCT = 49        
      WRITE (LOG2,680) CHORD,STAGER,CAMBER,AREA,XBAR,YBAR,IX,IY,IXY,ANG,
     1                 IPX,ANG,IPY,ANG        
680   FORMAT ( /16X,100HNORMALISED RESULTS - ALL THE FOLLOWING REFER TO 
     1ABLADE HAVING A MERIDIONAL CHORD PROJECTION OF UNITY, /16X,100(1H*
     2),//20X,11HBLADE CHORD,4X,1H=,F7.4, //20X,16HSTAGGER ANGLE  =,F7.3
     3, //20X,16HCAMBER ANGLE   =,F7.3, //20X,16HSECTION AREA   =,F7.5, 
     4//20X,45HLOCATION OF CENTROID RELATIVE TO LEADING EDGE, //30X,6HXB
     5AR =,F8.5, /30X,6HYBAR =,F8.5, //20X,37HSECOND MOMENTS OF AREA ABO
     6UT CENTROID, //30X,6HIX   =,F8.5, /30X,6HIY   =,F8.5, /30X,6HIXY  
     7=,F8.5, //20X,58HANGLE OF INCLINATION OF (ONE) PRINCIPAL AXIS TO  
     8X  AXIS =,F7.3, //20X,47HPRINCIPAL SECOND MOMENTS OF AREA ABOUT CE
     9NTROID, //30X,6HIPX  =,F7.5,6X,3H(AT,F7.3,15H WITH  X  AXIS), /30X
     $,6HIPY  =,F7.5,6X,3H(AT,F7.3,15H WITH  Y  AXIS), //)        
690   FORMAT (27X,5HPOINT,8X,24HM E A N L I N E  D A T A,13X,23HSURFACE 
     1COORDINATE DATA, /27X,6HNUMBER,5X,1HX,7X,1HY,5X,15HANGLE THICKNESS
     2,9X,2HX1,6X,2HY1,6X,2HX2,6X,2HY2, //)        
      WRITE (LOG2,690)        
      DO 710 J = 1,N        
      IF (LNCT .NE. 60) GO TO 700        
      WRITE (LOG2,10)        
      WRITE (LOG2,690)        
      LNCT = 4        
700   LNCT = LNCT + 1        
      TM   = THICK2(J)*2.0        
710   WRITE (LOG2,720) J,XM(J),YM(J),AM(J),TM,XS(IBL,J),YS(IBL,J),      
     1                 XP(IBL,J),YP(IBL,J)        
720   FORMAT (27X,I3,F13.5,F8.5,F7.3,F8.5,F16.5,3F8.5)        
      IF (ISPLIT .EQ. 0) GO TO 760        
      IF (LNCT  .LE. 40) GO TO 730        
      WRITE (LOG2,10)        
      LNCT = 1        
730   WRITE  (LOG2,740)        
740   FORMAT (//10X,20HSPLITTER COORDINATES, /10X,21(1H*), //2X)        
      WRITE (LOG2,690)        
      LNCT = LNCT + 11        
      N  = K1        
      DO 750 J = 1,N        
      TM = THICK(J)*2.        
      XS(IBL,J) = XSPLTS(J)        
      XP(IBL,J) = XSPLTP(J)        
      YP(IBL,J) = YSPLTP(J)        
      YS(IBL,J) = YSPLTS(J)        
      WRITE (LOG2,720) J,XSPLTM(J),YSPLTM(J),SS1(J,3),TM,XS(IBL,J),     
     1                 YS(IBL,J),XP(IBL,J),YP(IBL,J)        
      LNCT = LNCT + 1        
      IF (LNCT .LE. 60) GO TO 750        
      WRITE (LOG2,10)        
      WRITE (LOG2,690)        
      LNCT = 4        
750   CONTINUE        
760   CONTINUE        
      DO 770 J = 1,N        
      XM(J) = XS(IBL,J)        
      YM(J) = YS(IBL,J)        
      AM(J) = XP(IBL,J)        
770   THICK2(J) = YP(IBL,J)        
      WRITE  (LOG2,780) IBL        
780   FORMAT (1H1,45X,33HNORMALISED PLOT OF SECTION NUMBER,I3, /2X)     
      CALL ALG16 (N,LOG2,XM,YM,AM,THICK2)        
790   A2  = AXIALC**2        
      A4  = A2**2        
      IX  = IX*A4        
      IY  = IY*A4        
      IXY = IXY*A4        
      IPX = IPX*A4        
      IPY = IPY*A4        
      IF (ISTAK .GT. 1) GO TO 800        
      XBAR= ISTAK        
      IF (ISTAK .EQ. 0) YBAR = 0.        
      IF (ISTAK .EQ. 1) YBAR = YML        
800   RLE = YZERO*AXIALC        
      IF (ISPLIT .NE. 0) GO TO 810        
      CHORD = CHORD*AXIALC        
      CCORD(IBL) = CHORD        
      AREA = AREA*A2        
      XC  = RLE - XBAR*AXIALC - XDEL        
      YC  =-YBAR*AXIALC - YDEL        
      XTC = (XML-XBAR)*AXIALC - XDEL        
      YTC = (YML-YBAR)*AXIALC - YDEL        
      GO TO 860        
810   RLE = YZEROS*AXIALC        
      CHORD = CHORDS*AXIALC        
      AREAS = AREAS*AXIALC**2        
      XC  = (XSPLTM(1)-XBAR)*AXIALC - XDEL        
      YC  = (YSPLTM(1)-YBAR)*AXIALC - YDEL        
      XTC = (XSPLTM(K1)-XBAR)*AXIALC - XDEL        
      YTC = (YSPLTM(K1)-YBAR)*AXIALC - YDEL        
      XBARS = (XBARS-XBAR)*AXIALC - XDEL        
      YBARS = (YBARS-YBAR)*AXIALC - YDEL        
      IF (IPRINT .GE. 2) GO TO 940        
      GO TO (820,840), ISPLIT        
820   WRITE  (LOG2,830) CHORD,RLE,XC,YC,XBARS,YBARS,AREAS        
830   FORMAT (1H1,31X,69HDIMENSIONAL RESULTS - ALL RESULTS REFER TO A BL
     1ADE OF SPECIFIED CHORD, /32X,69(1H*), //20X,11HBLADE CHORD,4X,1H=,
     21P,E12.5,//20X,10HEND RADIUS,5X,1H=,1P,E12.5,8X,14HCENTERED AT X=,
     31P,E12.5,3H Y=,1P,E13.5, //20X,26HLOCATION OF CENTROID AT X=,     
     41P,E12.5,7H AND Y=,1P,E12.5, //20X,16HSECTION AREA   =,1P,E12.5,  
     5 //2X)        
      GO TO 900        
840   WRITE  (LOG2,850) CHORD,RLE,XC,YC,XTC,YTC,XBARS,YBARS,AREAS       
850   FORMAT (1H1,31X,69HDIMENSIONAL RESULTS - ALL RESULTS REFER TO A BL
     1ADE OF SPECIFIED CHORD, /32X,69(1H*), //20X,11HBLADE CHORD,4X,1H=,
     21P,E12.5,//20X,10HEND RADIUS,5X,1H=,1P,E12.5,8X,14HCENTERED AT X=,
     31P,E12.5,3H Y=,1P,E13.5, /64X,6HAND X=,1P,E12.5,3H Y=,1P,E13.5,   
     4 /20X,26HLOCATION OF CENTROID AT X=,1P,E12.5,7H AND Y=,1P,E12.5,  
     5 //20X,16HSECTION AREA   =,1P,E12.5, //2X)        
      GO TO 900        
860   CONTINUE        
      IF (IPRINT .GE. 2) GO TO 940        
      IF (ISECN  .EQ. 2) GO TO 880        
      WRITE  (LOG2,870) CHORD,RLE,XC,YC,AREA,IX,IY,IXY,IPX,ANG,IPY,ANG  
870   FORMAT (1H1,31X,69HDIMENSIONAL RESULTS - ALL RESULTS REFER TO A BL
     1ADE OF SPECIFIED CHORD, /32X,69(1H*),//20X,11HBLADE CHORD,4X,1H=, 
     31P,E12.5,//20X,10HL.E.RADIUS,5X,1H=,1P,E12.5,8X,14HCENTERED AT X=,
     41P,E13.5,3H Y=,1P,E13.5, //20X,16HSECTION AREA   =,1P,E12.5,//20X,
     537HSECOND MOMENTS OF AREA ABOUT CENTROID, //30X,6HIX   =,1P,E12.5,
     6 /30X,6HIY   =,1P,E12.5, /30X,6HIXY  =,1P,E12.5, //20X,47HPRINCIPA
     7L SECOND MOMENTS OF AREA ABOUT CENTROID, //30X,6HIPX  =,1P,E12.5, 
     85H  (AT,0P,F7.3,15H WITH  X  AXIS), /30X,6HIPY  =,1P,E12.5,       
     95H  (AT,0P,F7.3,15H WITH  Y  AXIS), //)        
      GO TO 910        
880   CONTINUE        
      WRITE (LOG2,890) CHORD,RLE,XC,YC,XTC,YTC,AREA,IX,IY,IXY,IPX,ANG,  
     1                 IPY,ANG        
890   FORMAT (1H1,31X,69HDIMENSIONAL RESULTS - ALL RESULTS REFER TO A BL
     1ADE OF SPECIFIED CHORD, /32X,69(1H*),//20X,11HBLADE CHORD,4X,1H=, 
     21P,E12.5, //20X,9HEND RADII,6X,1H=,1P,E12.5,8X,14HCENTERED AT X=, 
     31P,E13.5,3H Y=,1P,E13.5, /64X,6HAND X=,1P,E13.5,3H Y=,1P,E13.5,   
     4 /20X,16HSECTION AREA   =,1P,E12.5, //20X,37HSECOND MOMENTS OF ARE
     5A ABOUT CENTROID, //30X,6HIX   =,1P,E12.5, /30X,6HIY   =,1P,E12.5,
     6 /30X,6HIXY  =,1P,E12.5, //20X,47HPRINCIPAL SECOND MOMENTS OF AREA
     7 ABOUT CENTROID, //30X,6HIPX  =,1P,E12.5,5H  (AT,0P,F7.3,        
     815H WITH  X  AXIS), /30X,6HIPY  =,1P,E12.5,5H  (AT,0P,F7.3,       
     915H WITH  Y  AXIS), //)        
900   CONTINUE        
910   WRITE (LOG2,920)        
      WRITE (LOG2,930)        
920   FORMAT(4X,2HPT,5X,7HSURFACE,10(1H-),3HONE,8X,7HSURFACE,10(1H-),3HT
     1WO,10X,2HPT,5X,7HSURFACE,10(1H-),3HONE,8X,7HSURFACE,10(1H-),3HTWO)
930   FORMAT (4X,2HNO,8X,1HX,13X,1HY,13X,1HX,13X,1HY,12X,2HNO,8X,1HX,13X
     1,1HY,13X,1HX,13X,1HY, //)        
      LNCT = 24        
940   DO 970 J = 1,N        
      XS(IBL,J) = (XS(IBL,J) - XBAR)*AXIALC - XDEL        
      YS(IBL,J) = (YS(IBL,J) - YBAR)*AXIALC - YDEL        
      XP(IBL,J) = (XP(IBL,J) - XBAR)*AXIALC - XDEL        
      YP(IBL,J) = (YP(IBL,J) - YBAR)*AXIALC - YDEL        
      IF (IPRINT  .GE. 2) GO TO 970        
      IF ((J/2)*2 .NE. J) GO TO 970        
      IF (LNCT   .NE. 60) GO TO 950        
      LNCT = 4        
      WRITE (LOG2,10)        
      WRITE (LOG2,920)        
      WRITE (LOG2,930)        
950   LNCT = LNCT + 1        
      JM1  = J - 1        
      WRITE (LOG2,960) JM1,XS(IBL,JM1),YS(IBL,JM1),XP(IBL,JM1),        
     1                 YP(IBL,JM1),J,XS(IBL,J),YS(IBL,J),XP(IBL,J),     
     2                 YP(IBL,J)        
960   FORMAT (3X,I3,4(2X,1P,E12.5),6X,I3,4(2X,1P,E12.5))        
970   CONTINUE        
      CHORDD(IBL) = CHORD        
      IF (ISPLIT .GT. 1) ISECN = ISPLIT        
      IF (IPRINT .GE. 2) GO TO 1000        
      IF (LNCT  .GT. 24) WRITE (LOG2,980)        
980   FORMAT (1H1)        
      IF (LNCT .GT. 24) LNCT = 2        
      LNCT = LNCT + 5        
      IF (ISECN .EQ. 2) GO TO 1030        
      WRITE  (LOG2,990)        
990   FORMAT (//48X,37HPOINTS DESCRIBING LEADING EDGE RADIUS, //48X,    
     1        9HPOINT NO.,6X,1HX,13X,1HY, /2X)        
1000  EPS = BETA1 + 180.0        
      IF (ISECN .EQ. 2) GO TO 1030        
      DO 1020 J = 1,31        
      XSEMI(IBL,J) = XC - RLE*SIN(EPS/C1)        
      YSEMI(IBL,J) = YC + RLE*COS(EPS/C1)        
      EPS = EPS - 6.0        
      IF (IPRINT .GE. 2) GO TO 1020        
      WRITE (LOG2,1010) J,XSEMI(IBL,J),YSEMI(IBL,J)        
      LNCT = LNCT + 1        
1010  FORMAT (48X,I5,1P,E17.5,1P,E14.5)        
1020  CONTINUE        
      GO TO 1090        
1030  PHISS = PHIS - ABS((BETA1-BETA2)/C2)        
      PHIPP = ABS((BETA1-BETA2))/C2 - PHIP        
      EPS   = BETA1 + 180.0        
      EPS2  = BETA2 + 90.        
      DELEP = (180.-(PHISS+PHIPP)*C1)/28.        
      DO 1060 J = 1,31        
      IF (J .NE. 1) GO TO 1040        
      XSEMI(IBL,J) = XP(IBL,1)        
      YSEMI(IBL,J) = YP(IBL,1)        
      XSEMJ(IBL,J) = XS(IBL,N)        
      YSEMJ(IBL,J) = YS(IBL,N)        
      EPS  = EPS  - PHIPP*C1        
      EPS2 = EPS2 - PHISS*C1        
      GO TO 1060        
1040  IF (J .NE. 31) GO TO 1050        
      XSEMI(IBL,J) = XS(IBL,1)        
      YSEMI(IBL,J) = YS(IBL,1)        
      YSEMJ(IBL,J) = YP(IBL,N)        
      XSEMJ(IBL,J) = XP(IBL,N)        
      GO TO 1060        
1050  XSEMI(IBL,J) = XC  - RLE*SIN(EPS/C1)        
      YSEMI(IBL,J) = YC  + RLE*COS(EPS/C1)        
      XSEMJ(IBL,J) = XTC + RLE*COS(EPS2/C1)        
      YSEMJ(IBL,J) = YTC + RLE*SIN(EPS2/C1)        
      EPS  = EPS  - DELEP        
      EPS2 = EPS2 - DELEP        
1060  CONTINUE        
      IF (IPRINT .GE. 2) GO TO 1090        
      WRITE  (LOG2,1070)        
1070  FORMAT (//39X,44HPOINTS DESCRIBING LEADING AND TRAILING EDGES,    
     1 /25X,12HLEADING EDGE,22X,13HTRAILING EDGE, /2X,9HPOINT NO.,4X,8X,
     2 1HX,14X,1HY,12X,8X,1HX,14X,1HY, /2X)        
      WRITE (LOG2,1080) (J,XSEMI(IBL,J),YSEMI(IBL,J),XSEMJ(IBL,J),      
     1                   YSEMJ(IBL,J),J=1,31)        
      LNCT = LNCT + 31        
1080  FORMAT (6X,I2,7X,1P,E17.5,1P,E14.5,2X,1P,E17.5,1P,E14.5)        
1090  SSURF = AXIALC        
      SS2   =  BX - AXIALC*XBAR  - XDEL        
      SBAR  = SS2 + AXIALC*XBARB + XDEL        
      DO 1100 IK = 1,100        
1100  SS(IK) = SS(IK) - SBAR        
      CALL ALG15 (SS,X,100,0.0,SBAR,1,1)        
      CALL ALG15 (XHERE,R(1,IBL),NSTNS,SBAR,RXBAR,1,0)        
      XBARC = XBAR        
      YBARC = YBAR        
      XBAR  = XBARB + XDEL/AXIALC        
      YBAR  = YBARB + YDEL/AXIALC        
      SS1(1,1) = SS(1)        
      S23 = AXIALC/99.        
      SS(1) = SS(1) + SS2        
      DO 1110 IK = 2,100        
      SS1(IK,1) = SS(IK)        
1110  SS(IK) = SS(IK-1) + S23        
      SIGMAO = (XAB-YBAR)/RXBAR*AXIALC        
      DO 1120 IK = 2,100        
      IF (XBAR .EQ. DX(IK)) GO TO 1140        
      IF (XBAR.GT.DX(IK-1) .AND. XBAR.LT.DX(IK)) GO TO 1150        
1120  CONTINUE        
      WRITE  (LOG2,1130)        
1130  FORMAT (1H1,23H XBAR CANNOT BE LOCATED)        
1140  SIGMA(IK) = SIGMAO        
      KL = IK + 1        
      GO TO 1160        
1150  KL = IK        
      SIGMA(IK-1) = SIGMAO        
1160  SSDUM = SS(KL-1)        
      SS(KL-1) = 0.        
      YP1 = XBC        
      RX1 = RXBAR        
      DO 1170 IK = KL,100        
      XSURF = SS2 + DX(IK)*SSURF + SS1(1,1)        
      CALL ALG15 (SS1(1,1),X,100,XSURF,XDUM,1,1)        
      CALL ALG15 (XHERE,R(1,IBL),NSTNS,XDUM,RX2,1,0)        
      SIGMA(IK) = SIGMA(IK-1) + (Y(IK)/RX2+YP1/RX1)/2.*(SS(IK)-SS(IK-1))
      YP1 = Y(IK)        
1170  RX1 = RX2        
      SS(KL-1) = SSDUM        
      SSDUM  = SS(KL)        
      SIGDUM = SIGMA(KL)        
      SIGMA(KL) = SIGMAO        
      SS(KL) = 0.        
      RX1 = RXBAR        
      YP1 = XBC        
      KM  = KL - 1        
      DO 1180 IK = 1,KM        
      KJ  = KL - IK        
      XSURF = SS2 + DX(KJ)*SSURF + SS1(1,1)        
      CALL ALG15 (SS1(1,1),X,100,XSURF,XDUM,1,1)        
      CALL ALG15 (XHERE,R(1,IBL),NSTNS,XDUM,RX2,1,0)        
      SIGMA(KJ) = SIGMA(KJ+1)-(Y(KJ)/RX2+YP1/RX1)/2.*(SS(KJ+1)-SS(KJ))  
      YP1 = Y(KJ)        
1180  RX1 = RX2        
      SIGMA(KL) = SIGDUM        
      SS(KL) = SSDUM        
      DO 1190 IK = 1,100        
1190  SS(IK) = SS1(IK,1)        
      XBAR = XBARC        
      YBAR = YBARC        
      DO 1200 IK = 1,N        
      SS1(IK,1) = SS2 + ((XS(IBL,IK)+XDEL)/AXIALC+XBAR)*SSURF+SS(1)     
1200  SS1(IK,2) = SS2 + ((XP(IBL,IK)+XDEL)/AXIALC+XBAR)*SSURF+SS(1)     
      DO 1210 IK =1,31        
1210  SS1(IK,3) = SS2 + ((XSEMI(IBL,IK)+XDEL)/AXIALC+XBAR)*SSURF+SS(1)  
      IF (ISECN .NE. 2) GO TO 1230        
      DO 1220 IK = 1,31        
1220  SS1(IK,4) = SS2 + ((XSEMJ(IBL,IK)+XDEL)/AXIALC+XBAR)*SSURF+SS(1)  
      CALL ALG15 (SS,X,100,SS1(1,4),SS1(1,4),31,1)        
1230  CALL ALG15 (SS,X,100,SS1(1,1),SS1(1,1),N,1)        
      CALL ALG15 (SS,X,100,SS1(1,2),SS1(1,2),N,1)        
      CALL ALG15 (SS,X,100,SS1(1,3),SS1(1,3),31,1)        
      IF (ISTAK .GT. 1) GO TO 1250        
      IF (ISTAK .EQ. 1) SIGMAO = SIGMA(100)        
      IF (ISTAK .EQ. 0) SIGMAO = SIGMA(1)        
      DO 1240 IK = 1,100        
1240  SIGMA(IK) = SIGMA(IK) - SIGMAO        
1250  DO 1260 IK = 1,100        
      DX(IK) = (DX(IK)-XBAR)*AXIALC - XDEL        
1260  DY(IK) = (DY(IK)-YBAR)*AXIALC - YDEL        
      DO 1280 MK = 1,4        
      IF (ISECN.NE.2 .AND. MK.EQ.4) GO TO 1280        
      IF (MK.EQ.4 .OR. MK.EQ.3) NNN = 31        
      IF (MK.EQ.1 .OR. MK.EQ.2) NNN = N        
      DO 1270 IK = 1,NNN        
      IF (MK .EQ. 1) YP1 = YS(IBL,IK)        
      IF (MK .EQ. 2) YP1 = YP(IBL,IK)        
      IF (MK .EQ. 3) YP1 = YSEMI(IBL,IK)        
      IF (MK .EQ. 4) YP1 = YSEMJ(IBL,IK)        
      IF (MK .EQ. 1) RX1 = XS(IBL,IK)        
      IF (MK .EQ. 2) RX1 = XP(IBL,IK)        
      IF (MK .EQ. 3) RX1 = XSEMI(IBL,IK)        
      IF (MK .EQ. 4) RX1 = XSEMJ(IBL,IK)        
      CALL ALG15 (DX,DY,100,RX1,RXBAR,1,1)        
      DELLY = YP1 - RXBAR        
      CALL ALG15 (XHERE,R(1,IBL),NSTNS,SS1(IK,MK),RAB,1,0)        
      DELSIG = DELLY/RAB        
      CALL ALG15 (DX,SIGMA,100,RX1,XAB,1,1)        
1270  SS1(IK,MK) = XAB + DELSIG        
1280  CONTINUE        
      RETURN        
C        
1290  WRITE  (LOG2,1300)        
1300  FORMAT (1H1,10X,54HITERATIVE SOLUTION FOR CONSTANT FAILS - CASE AB
     1ANDONED)        
      CALL MESAGE (-37,0,NAME)        
      END        
