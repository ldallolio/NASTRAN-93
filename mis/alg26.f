      SUBROUTINE ALG26
C
      REAL LOSS,LAMI,LAMIP1,LAMIM1
C
      DIMENSION XX1(21),DSDM(21),DRVWDM(21),DL(21),DSDL(21),FX1(21),FX2(
     121),VVOLD(21),AFUN(20),BFUN(20),HS(20),XM2(20),DVMDVM(20),DVMDM(21
     2),TBIP1(21),TEIP1(21)
C
      COMMON /UD300C/ NSTNS,NSTRMS,NMAX,NFORCE,NBL,NCASE,NSPLIT,NREAD,
     1NPUNCH,NPAGE,NSET1,NSET2,ISTAG,ICASE,IFAILO,IPASS,I,IVFAIL,IFFAIL,
     2NMIX,NTRANS,NPLOT,ILOSS,LNCT,ITUB,IMID,IFAIL,ITER,LOG1,LOG2,LOG3,
     3LOG4,LOG5,LOG6,IPRINT,NMANY,NSTPLT,NEQN,NSPEC(30),NWORK(30),
     4NLOSS(30),NDATA(30),NTERP(30),NMACH(30),NL1(30),NL2(30),NDIMEN(30)
     5,IS1(30),IS2(30),IS3(30),NEVAL(30),NDIFF(4),NDEL(30),NLITER(30),
     6NM(2),NRAD(2),NCURVE(30),NWHICH(30),NOUT1(30),NOUT2(30),NOUT3(30),
     7NBLADE(30),DM(11,5,2),WFRAC(11,5,2),R(21,30),XL(21,30),X(21,30),
     8H(21,30),S(21,30),VM(21,30),VW(21,30),TBETA(21,30),DIFF(15,4),
     9FDHUB(15,4),FDMID(15,4),FDTIP(15,4),TERAD(5,2),DATAC(100),
     1DATA1(100),DATA2(100),DATA3(100),DATA4(100),DATA5(100),DATA6(100),
     2DATA7(100),DATA8(100),DATA9(100),FLOW(10),SPEED(30),SPDFAC(10),
     3BBLOCK(30),BDIST(30),WBLOCK(30),WWBL(30),XSTN(150),RSTN(150),
     4DELF(30),DELC(100),DELTA(100),TITLE(18),DRDM2(30),RIM1(30),
     5XIM1(30),WORK(21),LOSS(21),TANEPS(21),XI(21),VV(21),DELW(21),
     6LAMI(21),LAMIM1(21),LAMIP1(21),PHI(21),CR(21),GAMA(21),SPPG(21),
     7CPPG(21),HKEEP(21),SKEEP(21),VWKEEP(21),DELH(30),DELT(30),VISK,
     8SHAPE,SCLFAC,EJ,G,TOLNCE,XSCALE,PSCALE,PLOW,RLOW,XMMAX,RCONST,
     9FM2,HMIN,C1,PI,CONTR,CONMX
C
      ITMAX=20
      LPMAX=10
      K=1
      IF(I.EQ.ISTAG)K=2
      XN=SPEED(I)*SPDFAC(ICASE)*PI/(30.0*SCLFAC)
      IF(I.EQ.1)GO TO 234
      DO 100 J=1,NSTRMS
      LAMI(J)=LAMIP1(J)
100   LAMIP1(J)=1.0
      IF(I.EQ.NSTNS)GO TO 234
      IF(NDATA(I+1).EQ.0)GO TO 210
      L1=NDIMEN(I+1)+1
      GO TO(110,130,150,170),L1
110   DO 120 J=1,NSTRMS
120   XX1(J)=R(J,I+1)
      GO TO 190
130   DO 140 J=1,NSTRMS
140   XX1(J)=R(J,I+1)/R(NSTRMS,I+1)
      GO TO 190
150   DO 160 J=1,NSTRMS
160   XX1(J)=XL(J,I+1)
      GO TO 190
170   DO 180 J=1,NSTRMS
180   XX1(J)=XL(J,I+1)/XL(NSTRMS,I+1)
190   L1=IS2(I+1)
      CALL ALG01(DATAC(L1),DATA4(L1),NDATA(I+1),XX1,XX1,X1,NSTRMS,NTERP
     1(I+1),0)
      DO 200 J=1,NSTRMS
200   LAMIP1(J)=1.0-XX1(J)
210   DO 220 J=1,NSTRMS
      X1=SQRT((R(J,I+1)-R(J,I))**2+(X(J,I+1)-X(J,I))**2)
      X2=SQRT((R(J,I)-RIM1(J))**2+(X(J,I)-XIM1(J))**2)
      X3=ATAN2(R(J,I+1)-R(J,I),X(J,I+1)-X(J,I))
      X4=ATAN2(R(J,I)-RIM1(J),X(J,I)-XIM1(J))
      PHI(J)=(X3+X4)/2.0
      CR(J)=(X3-X4)/(X1+X2)*2.0
      DSDM(J)=0.0
      DRVWDM(J)=0.0
      DVMDM(J)=0.0
      IF(IPASS.EQ.1)GO TO 220
      DSDM(J)=((S(J,I+1)-S(J,I))/X1+(S(J,I)-S(J,I-1))/X2)/2.0*G*EJ
      DRVWDM(J)=((R(J,I+1)*VW(J,I+1)-R(J,I)*VW(J,I))/X1+(R(J,I)*VW(J,I)-
     1RIM1(J)*VW(J,I-1))/X2)/(2.0*R(J,I))
      DVMDM(J)=((VM(J,I+1)-VM(J,I))/X1+(VM(J,I)-VM(J,I-1))/X2)*0.5
220   CONTINUE
      IF(IPASS.EQ.1.OR.NDATA(I).EQ.0.OR.NEQN.EQ.3.OR.NWORK(I).NE.0.OR.NW
     1ORK(I+1).EQ.0)GO TO 390
      L1=NDIMEN(I)+1
      GO TO(221,223,225,227),L1
221   DO 222 J=1,NSTRMS
222   TEIP1(J)=R(J,I)
      GO TO 229
223   DO 224 J=1,NSTRMS
224   TEIP1(J)=R(J,I)/R(NSTRMS,I)
      GO TO 229
225   DO 226 J=1,NSTRMS
226   TEIP1(J)=XL(J,I)
      GO TO 229
227   DO 228 J=1,NSTRMS
228   TEIP1(J)=XL(J,I)/XL(NSTRMS,I)
229   L1=IS2(I)
      CALL ALG01(DATAC(L1),DATA3(L1),NDATA(I),TEIP1,TEIP1,X1,NSTRMS,NTE
     1RP(I),0)
      X1=SPEED(I+1)*SPDFAC(ICASE)*PI/(30.0*SCLFAC)
      DO 230 J=1,NSTRMS
      TEIP1(J)=TAN(TEIP1(J)/C1)
230   TBIP1(J)=(VW(J,I)-X1*R(J,I))/VM(J,I)
      GO TO 390
234   DO 240 J=1,NSTRMS
      DVMDM(J)=0.0
      DSDM(J)=0.0
      DRVWDM(J)=0.0
240   CR(J)=0.0
      IF(I.EQ.1)GO TO 244
      DO 246 J=1,NSTRMS
246   PHI(J)=ATAN2(R(J,I)-RIM1(J),X(J,I)-XIM1(J))
      GO TO 390
244   DO 260 J=1,NSTRMS
260   PHI(J)=ATAN2(R(J,2)-R(J,1),X(J,2)-X(J,1))
      DO 270 J=1,NSTRMS
      XI(J)=H(J,1)
      LAMI(J)=1.0
270   LAMIP1(J)=1.0
      IF(NDATA(2).EQ.0)GO TO 390
      L2=NDIMEN(2)+1
      GO TO(290,310,330,350),L2
290   DO 300 J=1,NSTRMS
300   XX1(J)=R(J,2)
      GO TO 370
310   DO 320 J=1,NSTRMS
320   XX1(J)=R(J,2)/R(NSTRMS,2)
      GO TO 370
330   DO 340 J=1,NSTRMS
340   XX1(J)=XL(J,2)
      GO TO 370
350   DO 360 J=1,NSTRMS
360   XX1(J)=XL(J,2)/XL(NSTRMS,2)
370   L1=IS2(2)
      CALL ALG01(DATAC(L1),DATA4(L1),NDATA(2),XX1,XX1,X1,NSTRMS,NTERP(2
     1),0)
      DO 380 J=1,NSTRMS
380   LAMIP1(J)=1.0-XX1(J)
390   CALL ALG01(R(1,I),X(1,I),NSTRMS,R(1,I),X1,GAMA,NSTRMS,0,1)
      DO 400 J=1,NSTRMS
      GAMA(J)=ATAN(GAMA(J))
      SPPG(J)=GAMA(J)+PHI(J)
      CPPG(J)=COS(SPPG(J))
      SPPG(J)=SIN(SPPG(J))
400   VV(J)=VM(J,I)
      DO 410 J=1,ITUB
      DL(J)=XL(J+1,I)-XL(J,I)
410   DSDL(J)=(S(J+1,I)-S(J,I))*G*EJ/DL(J)
      IF(I.EQ.1.OR.NWORK(I).GE.5)GO TO 430
      DO 420 J=1,ITUB
      DVMDVM(J)=0.0
      FX1(J)=(VW(J+1,I)+VW(J,I))/(R(J+1,I)+R(J,I))*(R(J+1,I)*VW(J+1,I)-R
     1(J,I)*VW(J,I))/DL(J)
420   FX2(J)=(H(J+1,I)-H(J,I))/DL(J)*G*EJ
      GO TO 450
430   DO 440 J=1,ITUB
      FX1(J)=(TBETA(J+1,I)+TBETA(J,I))/(R(J+1,I)+R(J,I))*(R(J+1,I)*TBETA
     1(J+1,I)-R(J,I)*TBETA(J,I))/DL(J)
440   FX2(J)=(XI(J+1)-XI(J))/DL(J)*G*EJ
450   VMAX=0.0
      VMIN=2500.0
      ITER=0
460   ITER=ITER+1
      IFAIL=0
      ICONF1=0
      DO 470 J=1,NSTRMS
470   VVOLD(J)=VV(J)
      IF(I.EQ.1.OR.NWORK(I).GE.5)GO TO 810
      DO 580 J=1,ITUB
      X1=(H(J,I)+H(J+1,I))/2.0-(((VVOLD(J)+VVOLD(J+1))/2.0)**2+((VW(J,I)
     1+VW(J+1,I))/2.0)**2)/(2.0*G*EJ)
      IF(X1.GE.HMIN)GO TO 520
      IF(IPASS.LE.NFORCE)GO TO 510
      IF(LNCT.LT.NPAGE)GO TO 480
      WRITE(LOG2,500)
      LNCT=1
480   LNCT=LNCT+1
      WRITE(LOG2,490)IPASS,I,ITER,J,X1
490   FORMAT(5X,4HPASS,I3,9H  STATION,I3,11H  ITERATION,I3,12H  STREAMTU
     1BE,I3,53H  STATIC ENTHALPY BELOW LIMIT IN MOMENTUM EQUATION AT,E13
     2.5)                                                               
500   FORMAT(1H1)                                                       
510   IFAIL=1
      X1=HMIN
520   X2=(S(J,I)+S(J+1,I))/2.0
      X7=ALG7(X1,X2)
      X2=(CPPG(J)+CPPG(J+1))*0.5
      X3=(SPPG(J)+SPPG(J+1))*0.5
      AFUN(J)=-2.0*X3*(DVMDM(J)+DVMDM(J+1))/(VVOLD(J)+VVOLD(J+1))-X2*(CR
     1(J)+CR(J+1))
      BFUN(J)=2.0*(FX2(J)-X7*DSDL(J)-FX1(J))
      IF(IPASS.EQ.1.OR.I.EQ.NSTNS)GO TO 580
      IF(NDATA(I).EQ.0.OR.NEQN.EQ.3.OR.(NWORK(I).EQ.0.AND.NWORK(I+1).EQ.
     10))GO TO 560
      IF(NWORK(I).EQ.0)GO TO 540
      X4=(TBETA(J,I)+TBETA(J+1,I))*0.5
      X5=(TANEPS(J)+TANEPS(J+1))*0.5
530   BFUN(J)=BFUN(J)+X7*(DSDM(J)+DSDM(J+1))*(X3/(1.0+X4*X4)-X5*X4/(1.0+
     1X4*X4)*0.5)-X5*(DRVWDM(J)+DRVWDM(J+1))*(VVOLD(J)+VVOLD(J+1))*0.5
      GO TO 580
540   X4=(TBIP1(J)+TBIP1(J+1))*0.5
      X5 = (TEIP1(J)+TEIP1(J+1))*0.5
      GO TO 530
560   BFUN(J)=BFUN(J)+X7*(DSDM(J)+DSDM(J+1))*X3
580   VV(IMID)=VVOLD(IMID)**2
      J=IMID
      JINC=1
590   JOLD=J
      J=J+JINC
      JJ=JOLD
      IF(JINC.EQ.-1)JJ=J
      IF(ABS(AFUN(J)).LE.1.0E-5) GO TO 660
      X1=-AFUN(JJ)*(XL(J,I)-XL(JOLD,I))
      IF(ABS(X1).LE.1.0E-10)GO TO 660
      IF(X1.LE.88.0)GO TO 630
      IF(IPASS.LE.NFORCE)GO TO 620
      IF(LNCT.LT.NPAGE)GO TO 600
      WRITE(LOG2,500)
      LNCT=1
600   LNCT=LNCT+1
      WRITE(LOG2,610)IPASS,I,ITER,JJ,X1
610   FORMAT(5X,4HPASS,I3,9H  STATION,I3,11H  ITERATION,I3,12H  STREAMTU
     1BE,I3,43H  MOMENTUM EQUATION EXPONENT ABOVE LIMIT AT,E13.5)       
620   IFAIL=1
      X1=88.0
630   X1=EXP(X1)
      VV(J)=VV(JOLD)*X1+(1.0-X1)*BFUN(JJ)/AFUN(JJ)
640   IF(J.EQ.K)GO TO 670
      IF(J.EQ.NSTRMS)GO TO 650
      GO TO 590
650   J=IMID
      JINC=-1
      GO TO 590
660   VV(J)=VV(JOLD)+BFUN(JJ)*(XL(J,I)-XL(JOLD,I))
      GO TO 640
670   DO 710 J=K,NSTRMS
      IF(VV(J).LE.4.0*VVOLD(IMID)**2)GO TO 676
      IFAIL=1
      IF(IPASS.LE.NFORCE)GO TO 674
      CALL ALG03(LNCT,1)
      WRITE(LOG2,672)IPASS,I,ITER,J
672   FORMAT(5X,4HPASS,I3,9H  STATION,I3,11H  ITERATION,I3,12H  STREAMLI
     1NE,I3,50H  MERIDIONAL VELOCITY GREATER THAN TWICE MID VALUE)      
674   VV(J)=4.0*VVOLD(IMID)**2
676   IF(VV(J).GE.1.0)GO TO 702
      IF(IPASS.LE.NFORCE)GO TO 700
      IF(LNCT.LT.NPAGE)GO TO 680
      WRITE(LOG2,500)
      LNCT=1
680   LNCT=LNCT+1
      WRITE(LOG2,690)IPASS,I,ITER,J,VV(J)
690   FORMAT(5X,4HPASS,I3,9H  STATION,I3,11H  ITERATION,I3,12H  STREAMLI
     1NE,I3,46H  (MERIDIONAL VELOCITY) SQUARED BELOW LIMIT AT,E13.5)    
700   VV(J)=1.0
      IFAIL=1
      GO TO 710
702   VV(J)=SQRT(VV(J))
710   CONTINUE
      X1=0.0
      DO 712 J=K,ITUB
712   X1=X1+(XL(J+1,I)-XL(J,I))*ABS((VV(J+1)+VV(J))/(VVOLD(J+1)+VVOLD(J)
     1)-1.0)
      X1=X1/(XL(NSTRMS,I)-XL(K,I))
      X2=0.1
      IF(X1.LT.0.2)X2=EXP(-11.52*X1)
      DO 715 J=K,NSTRMS
715   VV(J)=VVOLD(J)+X2*(VV(J)-VVOLD(J))
      IF(NLOSS(I).EQ.1.AND.NL2(I).EQ.0)CALL ALG07
      DO 800 J=1,ITUB
      HS(J)=(H(J,I)+H(J+1,I))/2.0-(((VV(J)+VV(J+1))/2.0)**2+((VW(J,I)+VW
     1(J+1,I))/2.0)**2)/(2.0*G*EJ)
      IF(HS(J).GE.HMIN)GO TO 800
      IF(IPASS.LE.NFORCE)GO TO 790
      IF(LNCT.LT.NPAGE)GO TO 770
      WRITE(LOG2,500)
      LNCT=1
770   LNCT=LNCT+1
      WRITE(LOG2,780)IPASS,I,ITER,J,HS(J)
780   FORMAT(5X,4HPASS,I3,9H  STATION,I3,11H  ITERATION,I3,12H  STREAMTU
     1BE,I3,55H  STATIC ENTHALPY BELOW LIMIT IN CONTINUITY EQUATION AT,E
     213.5)                                                             
790   IFAIL=1
      HS(J)=HMIN
800   XM2(J)=ALG9(HS(J),(S(J,I)+S(J+1,I))/2.0,((VV(J)+VV(J+1))/2.0)**2)
      GO TO 1100
810   J=IMID
      JINC=1
820   LOOP=1
      JOLD=J
      J=J+JINC
      JJ=JOLD
      IF(JINC.EQ.-1)JJ=J
830   VOLD=VV(J)
      VAV=(VOLD+VV(JOLD))/2.0
      IFAIE=0
      ICONF2=0
      X2=(TBETA(J,I)+TBETA(JOLD,I))/2.0
      X1=(XI(J)+XI(JOLD))/2.0+((XN*(R(J,I)+R(JOLD,I))/2.0)**2-VAV**2*(1.
     10+X2*X2))/(2.0*G*EJ)
      IF(X1.GE.HMIN)GO TO 870
      IF(IPASS.LE.NFORCE)GO TO 860
      IF(LNCT.LT.NPAGE)GO TO 840
      WRITE(LOG2,500)
      LNCT=1
840   LNCT=LNCT+1
      WRITE(LOG2,850)IPASS,I,ITER,JJ,LOOP,X1
850   FORMAT(5X,4HPASS,I3,9H  STATION,I3,11H  ITERATION,I3,12H  STREAMTU
     1BE,I3,6H  LOOP,I3,43H  STATIC H IN MOMENTUM EQUN. BELOW LIMIT AT,E
     213.5)                                                             
860   IFAIE=1
      ICONF2 = 1
      X1=HMIN
870   X3=(S(J,I)+S(JOLD,I))/2.0
      X7=ALG7(X1,X3)
      X4=(SPPG(J)+SPPG(JOLD))*0.5
      X5=(CPPG(J)+CPPG(JOLD))*0.5
      X1=X5*(CR(J)+CR(JOLD))*0.5-FX1(JJ)
      X12=1.0/(1.0+X2*X2)
      X8=(TANEPS(J)+TANEPS(JOLD))*0.5
      X11=FX2(JJ)-X7*DSDL(JJ)
      X6=X4*(DVMDM(J)+DVMDM(JOLD))*0.5-2.0*XN*X2*COS((GAMA(J)+GAMA(JOLD)
     1)*0.5)
      IF(IPASS.EQ.1.OR.I.EQ.1.OR.I.EQ.NSTNS)GO TO 920
      IF(NEQN.EQ.3)GO TO 900
      X11=X11+X7*(DSDM(J)+DSDM(JOLD))*0.5*(X4*X12-X8*X2*X12)
      X6=X6-X8*(DRVWDM(J)+DRVWDM(JOLD))*0.5
      GO TO 920
900   X11=X11+X7*(DSDM(J)+DSDM(JOLD))*0.5*X4
920   DV2DL=2.0*X12*(VAV*(X6+VAV*X1)+X11)
      DVMDVM(JJ)=X12*(X1-X11/VAV**2)
      X1=VV(JOLD)**2+DV2DL*(XL(J,I)-XL(JOLD,I))
      IF(X1.LE.9.0*VVOLD(IMID)**2)GO TO 938
      ICONF2=1
      IFAIE=1
      IF(IPASS.LE.NFORCE)GO TO 936
      CALL ALG03(LNCT,1)
      X1=SQRT(X1)
      X2=3.0*VVOLD(IMID)
      WRITE(LOG2,934)IPASS,I,ITER,J,LOOP,X1,X2
934   FORMAT(5X,4HPASS,I3,9H  STATION,I3,11H  ITERATION,I3,12H  STREAMLI
     1NE,I3,6H  LOOP,I3,33H  MERIDIONAL VELOCITY ABOVE LIMIT,E13.5,9H  L
     2IMIT =,E13.5)                                                     
936   X1=9.0*VVOLD(IMID)**2
938   IF(X1.GE.1.0)GO TO 950
      IF(IPASS.LE.NFORCE)GO TO 944
      IF(LNCT.LT.NPAGE)GO TO 930
      WRITE(LOG2,500)
      LNCT=1
930   LNCT=LNCT+1
      WRITE(LOG2,940)IPASS,I,ITER,J ,LOOP,X1
940   FORMAT(5X,4HPASS,I3,9H  STATION,I3,11H  ITERATION,I3,12H  STREAMLI
     1NE,I3,6H  LOOP,I3,46H  (MERIDIONAL VELOCITY) SQUARED BELOW LIMIT A
     2T,E13.5)                                                          
944   X1=1.0
      IFAIE=1
      ICONF2=1
950   VV(J)=SQRT(X1)
      IF(ABS(VV(J)/VOLD-1.0).LE.TOLNCE/5.0)GO TO 990
      IF(LOOP.GE.LPMAX)GO TO 960
      LOOP=LOOP+1
      GO TO 830
960   ICONF2=1
      IF(IPASS.LE.NFORCE)GO TO 990
      IF(LNCT.LT.NPAGE)GO TO 970
      WRITE(LOG2,500)
      LNCT=1
970   LNCT=LNCT+1
      WRITE(LOG2,980)IPASS,I,ITER,J,VV(J),VOLD
980   FORMAT(5X,4HPASS,I3,9H  STATION,I3,11H  ITERATION,I3,12H  STREAMLI
     1NE,I3,38H  MERIDIONAL VELOCITY UNCONVERGED  VM=,E13.6,9H VM(OLD)=,
     2E13.6)                                                            
990   IF(IFAIE.EQ.1)IFAIL=1
      IF(ICONF2.EQ.1)ICONF1=1
      IF(J.EQ.NSTRMS)GO TO 1000
      IF(J.EQ.1)GO TO 1010
      GO TO 820
1000  J=IMID
      JINC=-1
      GO TO 820
1010  IF(I.EQ.1)GO TO 1014
      IF(NLOSS(I).EQ.2.OR.(NLOSS(I).EQ.1.AND.NL2(I).EQ.0))CALL ALG07
1014  DO 1090 J=1,ITUB
      X1=((VV(J)+VV(J+1))/2.0)**2*(1.0+((TBETA(J,I)+TBETA(J+1,I))/2.0)**
     12)
      HS(J)=(XI(J)+XI(J+1))/2.0+((XN*(R(J,I)+R(J+1,I))/2.0)**2-X1)/(2.0*
     1G*EJ)
      IF(HS(J).GE.HMIN)GO TO 1080
      IF(IPASS.LE.NFORCE)GO TO 1070
      IF(LNCT.LT.NPAGE)GO TO 1060
      WRITE(LOG2,500)
      LNCT=1
1060  LNCT=LNCT+1
      WRITE(LOG2,780)IPASS,I,ITER,J,HS(J)
1070  IFAIL=1
      HS(J)=HMIN
1080  XM2(J)=ALG9(HS(J),(S(J,I)+S(J+1,I))/2.0,X1)
      IF(I.EQ.1.OR.NLOSS(I).NE.1.OR.NL2(I).NE.0)GO TO 1090
      X1=(S(J,I)+S(J+1,I))/2.0
      X2=ALG4(HS(J),X1)
      X4=ALG8(HS(J),X1)
      X3=(XI(J)+XI(J))/2.0+(XN*((R(J,I)+R(J+1,I))/2.0))**2/(2.0*G*EJ)
      X3=ALG4(X3,X1)
      XM2(J)=XM2(J)*(1.0+X4*(LOSS(J)+LOSS(J+1))/2.0*X2/(X3*(1.0+(LOSS(J)
     1+LOSS(J+1))/2.0*(1.0-X2/X3))))
1090  CONTINUE
1100  DELW(1)=0.0
      DWDV=0.0
      X2=BBLOCK(I)*BDIST(I)
      X3=BBLOCK(I)*(1.0-BDIST(I))/XL(NSTRMS,I)
      DO 1200 J=1,ITUB
      X1=DL(J)*(R(J+1,I)+R(J,I))*ALG5(HS(J),(S(J,I)+S(J+1,I))/2.0)*(VV(J
     1)+VV(J+1))*(CPPG(J)+CPPG(J+1))*PI/(4.0*SCLFAC**2)
      X1=X1*((LAMI(J)+LAMI(J+1))/2.0-WWBL(I)-X2-X3*(XL(J,I)+XL(J+1,I)))
      DELW(J+1)=DELW(J)+X1
      X4=0.0
      IF(J.GE.IMID)GO TO 1130
      L1=J
1110  X4=X4+DVMDVM(L1)
      IF(L1.GE.IMID-1)GO TO 1120
      L1=L1+1
      GO TO 1110
1120  X4=X4/FLOAT(IMID-J)
      GO TO 1200
1130  L1=IMID+1
1140  X4=X4+DVMDVM(L1)
      IF(L1.GE.J)GO TO 1150
      L1=L1+1
      GO TO 1140
1150  X4=X4/FLOAT(J-IMID+1)
1200  DWDV=DWDV+X1*(1.0-XM2(J))*2.0/((VV(J)+VV(J+1))*(1.0-((XL(J,I)+XL(J
     1+1,I))*0.5-XL(IMID,I))*X4))
      W=DELW(NSTRMS)
      FM2=DWDV/W*VV(IMID)
      DO 1210 J=2,NSTRMS
1210  DELW(J)=DELW(J)/W
      IF(DWDV.LE.0.0)GO TO 1280
      IF(NMACH(I).EQ.1)GO TO 1330
      IF(W.LT.FLOW(ICASE).AND.ICONF1.EQ.0)VMAX=VV(IMID)
1220  DV=(FLOW(ICASE)-W)/DWDV
      IF(DV.LT.-0.1*VV(IMID))DV=-0.1*VV(IMID)
      IF(DV.GT. 0.1*VV(IMID))DV= 0.1*VV(IMID)
1230  IF(IPASS.EQ.1.OR.(I.NE.1.AND.NWORK(I).LE.4))GO TO 1234
      IF(VV(IMID)+DV.LT.VMIN)GO TO 1232
      DV=(VMIN-VV(IMID))*0.5
1232  IF(VV(IMID)+DV.GT.VMAX)GO TO 1234
      DV=(VMAX-VV(IMID))*0.5
1234  DO 1270 J=K,NSTRMS
      VV(J)=VV(J)+DV
      IF(VV(J).GE.1.0)GO TO 1270
      IF(IPASS.LE.NFORCE)GO TO 1260
      IF(LNCT.LT.NPAGE)GO TO 1240
      WRITE(LOG2,500)
      LNCT=1
1240  LNCT=LNCT+1
      WRITE(LOG2,1250)IPASS,I,ITER,J,VV(J)
1250  FORMAT(5X,4HPASS,I3,9H  STATION,I3,11H  ITERATION,I3,12H  STREAMLI
     1NE,I3,50H  MERIDIONAL VELOCITY BELOW LIMIT IN CONTINUITY AT,E13.5)
1260  VV(J)=1.0
      IFAIL=1
1270  CONTINUE
      GO TO 1340
1280  IF(NMACH(I).EQ.0)GO TO 1290
      IF(W.LT.FLOW(ICASE).AND.ICONF1.EQ.0)VMIN=VV(IMID)
      GO TO 1220
1290  IF(VV(IMID).LT.VMIN.AND.ICONF1.EQ.0)VMIN=VV(IMID)
      DV=-.1*VV(IMID)
1300  IFAIL=1
      IF(IPASS.LE.NFORCE)GO TO 1230
      IF(LNCT.LT.NPAGE)GO TO 1310
      WRITE(LOG2,500)
      LNCT=1
1310  LNCT=LNCT+1
      WRITE(LOG2,1320)IPASS,I,ITER
1320  FORMAT(5X,4HPASS,I3,9H  STATION,I3,11H  ITERATION,I3,43H  OTHER CO
     1NTINUITY EQUATION BRANCH REQUIRED)                                
      GO TO 1230
1330  IF(VV(IMID).GT.VMAX.AND.ICONF1.EQ.0)VMAX=VV(IMID)
      DV=0.1*VV(IMID)
      GO TO 1300
1340  X1=TOLNCE/5.0
      IF(NEVAL(I).GT.0)X1=X1/2.0
      IF(ABS(W/FLOW(ICASE)-1.0).GT.X1)GO TO 1354
      DO 1350 J=K,NSTRMS
      IF(ABS(VV(J)/VVOLD(J)-1.0).GT.X1)GO TO 1354
1350  CONTINUE
      GO TO 1390
1354  IF(ITER.GE.ITMAX)GO TO 1360
      IF(I.EQ.1)GO TO 460
      IF((NLOSS(I).EQ.1.AND.NL2(I).EQ.0).OR.(NWORK(I).GE.5.AND.NLOSS(I).
     1EQ.2))CALL ALG07
      GO TO 460
1360  IF(IPASS.LE.NFORCE)GO TO 1390
      IF(LNCT.LT.NPAGE)GO TO 1370
      WRITE(LOG2,500)
      LNCT=1
1370  LNCT=LNCT+1
      X1=W/FLOW(ICASE)
      X2=VV(K)/VVOLD(K)
      X3=VV(IMID)/VVOLD(IMID)
      X4=VV(NSTRMS)/VVOLD(NSTRMS)
      WRITE(LOG2,1380)IPASS,I,X1,X2,X3,X4
1380  FORMAT(5X,4HPASS,I3,9H  STATION,I3,49H  MOMENTUM AND/OR CONTINUITY
     1 UNCONVERGED W/WSPEC=,F8.5,16H VM/VM(OLD) HUB=,F8.5,5H MID=,F8.5,5
     2H TIP=,F8.5)                                                      
1390  IF(IFAIL.NE.0.AND.IFAILO.EQ.0)IFAILO=I
      DO 1400 J=1,NSTRMS
1400  VM(J,I)=VV(J)
      IF(I.NE.1)GO TO 1420
      DO 1410 J=1,NSTRMS
1410  VW(J,1)=VV(J)*TBETA(J,1)
      GO TO 1480
1420  IF(NMIX.NE.1)GO TO 1440
      DO 1430 J=1,NSTRMS
      S(J,I-1)=SKEEP(J)
      H(J,I-1)=HKEEP(J)
1430  VW(J,I-1)=VWKEEP(J)
1440  IF(NWORK(I).GE.5)GO TO 1460
      TBETA(1,I)=0.0
      DO 1450 J=K,NSTRMS
1450  TBETA(J,I)=(VW(J,I)-XN*R(J,I))/VV(J)
      GO TO 1480
1460  DO 1470 J=1,NSTRMS
      VW(J,I)=VV(J)*TBETA(J,I)+XN*R(J,I)
1470  H(J,I)=XI(J)+XN*R(J,I)*VW(J,I)/(G*EJ)
1480  CONTINUE
      RETURN
      END
