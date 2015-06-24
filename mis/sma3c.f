      SUBROUTINE SMA3C(IFLAG,K)        
C        
C     THIS ROUTINE WILL MERGE ZINVS,ZS,STZ,AND STZS INTO KE AND        
C       BUILD KE UP TO G SIZE.  IF INFLAG .LT. 0 THERE ARE NO        
C       UD-S        
C        
      DOUBLE PRECISION A11,B11,D11        
      INTEGER ZINVS,ZS,STZ,STZS,GEI,SYSBUF,NAME(2),IZ(1)        
      DIMENSION BLOCK1(20),BLOCK2(20),K(7)        
C        
      COMMON /BLANK/LUSET        
CZZ   COMMON /ZZSM3C/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /ZBLPKX/ D11(2),ID        
      COMMON /SYSTEM/ SYSBUF, DUMMY(53), IPREC        
      COMMON /GENELY/GEI,DUM(4),STZS(1),ZINVS(1),ZS(1),STZ(1),DUM1(62), 
     1  M,N        
C        
      EQUIVALENCE (Z(1),IZ(1))        
      DATA NAME / 4HSMA3,4HC    /        
C        
C     IUI IS POINTER TO UI SET, IUD IS POINTER TO UD SET        
C        
      IUI =1        
      IUD =M+1        
      NZ = KORSZ(Z)        
C        
C     OPEN GEI(WITHOUT REWIND)        
C        
      NZ = NZ -SYSBUF        
      CALL GOPEN(GEI,Z(NZ+1),2)        
C        
C     READ IN UI SET        
C        
      CALL FREAD(GEI,Z,-3,0)        
      CALL FREAD(GEI,Z, M,0)        
C        
C     READ IN UD        
C        
      IF (IFLAG .LT. 0) GO TO 10        
      CALL FREAD(GEI,Z(IUD),N,1)        
C        
C     OPEN BUFFERS FOR MATRICES        
C        
   10 LLEN = M+N+2*SYSBUF        
      IF(IFLAG .GE. 0) LLEN = LLEN+3*SYSBUF        
      IF (LLEN .GT. NZ) GO TO 220        
      NZ = NZ-SYSBUF        
      CALL GOPEN(K,Z(NZ+1),1)        
      NZ = NZ -SYSBUF        
      CALL GOPEN(ZINVS,Z(NZ+1),0)        
      IF (IFLAG .LT. 0) GO TO 20        
      NZ =NZ -SYSBUF        
      CALL GOPEN(ZS,Z(NZ+1),0)        
      NZ =NZ -SYSBUF        
      CALL GOPEN(STZ,Z(NZ+1),0)        
      NZ =NZ -SYSBUF        
      CALL GOPEN(STZS,Z(NZ+1),0)        
C        
C     LOOP ON LUSET MAKING COLUMNS OF KGG        
C        
   20 K(2) = 0        
      K(3) = LUSET        
      K(4) = 6        
      K(5) = 2        
      K(6) = 0        
      K(7) = 0        
      IIP = 0        
      IDP = 0        
      DO 170 I=1,LUSET        
      CALL BLDPK (2, IPREC, K(1), 0, 0)        
      IF( IIP.GE.M )  GO TO 25        
      L = IUI + IIP        
      IF (I .EQ. IZ(L)) GO TO 30        
   25 CONTINUE        
      IF (IFLAG .LT. 0) GO TO 160        
      IF( IDP.GE.N )  GO TO 160        
      L = IUD + IDP        
      IF (I .EQ. IZ(L)) GO TO 40        
      GO TO 160        
C        
C     USING UI -- ZINVS AND STZ        
C        
   30 IIP = IIP +1        
      NAM1 = ZINVS(1)        
      NAM2 = STZ(1)        
      GO TO 50        
C        
C     USING UD ZS AND STZS        
C        
   40 IDP = IDP +1        
      NAM1 = ZS(1)        
      NAM2 = STZS(1)        
C        
C     MERGE ROUTINE FOR COLUMN        
C        
   50 IAD = 0        
      IBD = 0        
      IHOP = 0        
      CALL INTPK(*140,NAM1,BLOCK1(1),2,1)        
   60 IF(IFLAG .LT. 0) GO TO 150        
      CALL INTPK(*150,NAM2,BLOCK2(1),2,1)        
   70 CALL INTPKI(A11,IA,NAM1,BLOCK1(1),IAEOL)        
      L=  IUI +IA -1        
      II = IZ(L)        
      IF (IHOP .EQ. 1) GO TO 90        
      IHOP = 1        
   80 CALL INTPKI(B11,IB,NAM2,BLOCK2(1),IBEOL)        
      L = IUD +IB -1        
      JJ = IZ(L)        
   90 IF (II-JJ) 100,320,120        
C        
C     PUT IN A11        
C        
  100 D11(1) =A11        
      ID = II        
      CALL ZBLPKI        
      IF (IAEOL) 110,70,110        
  110 IAD = 1        
      II = 99999        
      IF(IBD) 160,120,160        
C        
C     PUT IN BUU        
C        
  120 D11(1) = B11        
      ID = JJ        
      CALL ZBLPKI        
      IF (IBEOL) 130,80,130        
  130 IBD = 1        
      JJ = 99999        
      IF(IAD) 160,100,160        
C        
C     NULL NAM1        
C        
  140 IAD =1        
      II = 99999        
      GO TO 60        
C        
C     NO NAM2        
C        
  150 IBD =1        
      JJ = 99999        
      IHOP =1        
      GO TO 70        
C        
C     END OF COLUMN        
C        
  160 CALL BLDPKN(K(1),0,K)        
C        
C     END LOOP        
C        
  170 CONTINUE        
      CALL WRTTRL (K)        
      CALL CLOSE (K(1),1)        
      CALL CLOSE (ZINVS(1),1)        
      IF (IFLAG .LT. 0) GO TO 180        
      CALL CLOSE (STZ(1),1)        
      CALL CLOSE (STZS(1),1)        
      CALL CLOSE (ZS(1),1)        
  180 RETURN        
C        
C     ERROR MESAGES        
C        
  220 CALL MESAGE(-8,GEI,NAME)        
  320 CALL MESAGE(-7,0,NAME)        
      RETURN        
      END        
