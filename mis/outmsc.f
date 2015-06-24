      SUBROUTINE OUTMSC (*,*)        
C        
C     COPY DATA BLOCK(S) TO FORTRAN UNIT, IN MSC/OUTPUT2 COMPATIBLE     
C     RECORD FORMATS.        
C        
C     DMAP CALL -        
C     OUTPUT2  IN1,IN2,IN3,IN4,IN5/ /V,N,P1/V,N,P2/V,N,P3/V,N,P4/V,N,P5/
C                                    V,N,P6 $        
C        
C     THIS ROUTINE IS CALLED ONLY BY OUTPT2        
C     SEE OUTPT2 FOR PARAMETERS P1,P2,...,P6. (P6 = *MSC*)        
C        
C     IF P1 .NE. -9, ALTERNATE RETURN 1, OTHERWISE RETURN 2.        
C        
C     WRITTEN BY G.CHAN/UNISYS  3/93        
C        
      LOGICAL          DP        
      INTEGER          P1,P2,P3,P4,P5,P6,ENDREC,ENDFIL,OUT,BUF1,D, 
     1                 INP(13),MCB(7),NAME(2),NONE(2),SUB(2),TMP(2),    
     2                 DX(3),HDR(7),HDRX(7),TAPCOD(2),BLOCK(20)        
      REAL             XNS(1)        
      DOUBLE PRECISION DXNS(1)        
      CHARACTER        UFM*23,UWM*25,UIM*29,SFM*25,MO2*19        
      COMMON /XMSSG /  UFM,UWM,UIM,SFM        
      COMMON /BLANK /  P1,P2,P3(2),P4,P5,P6(2)        
      COMMON /MACHIN/  MACH        
      COMMON /SYSTEM/  IBUF,NOUT,IDUM4(6),NLPP,IDUM5(5),D(3)        
      COMMON /TYPE  /  IDUM6(2),NWDS(4)        
CZZ   COMMON /ZZOUT2/  Z(1)        
      COMMON /ZZZZZZ/  Z(1)        
CZZ   COMMON /XNSTRN/  XNS        
      EQUIVALENCE      (XNS(1),Z(1))        
      EQUIVALENCE      (XNS(1),DXNS(1))        
      DATA    HDR   /  4HNAST,4HRAN ,4HFORT,4H TAP,4HE ID,4H COD,4HE - /
      DATA    INP   /  4HUT1 ,4HUT2 ,4HUT3 ,4HINPT,4HINP1,4HINP2,4HINP3,
     1                 4HINP4,4HINP5,4HINP6,4HINP7,4HINP8,4HINP9       /
      DATA    MO2   /  '. MODULE OUTPUT2 - '      /        
      DATA    NONE  ,  SUB   /4H (NO,4HNE) ,4HOUTP,4HUT2*              /
C        
      WRITE  (NOUT,10) UIM        
   10 FORMAT (A29,'. USER REQUESTED RECORDS IN MSC/OUTPUT2 COMPATIBLE', 
     1       ' RECORDS')        
      ENDFIL = 0        
      ENDREC = 0        
      LCOR   = KORSZ(Z(1))        
      BUF1   = LCOR - IBUF + 1        
      IF (BUF1 .LE. 0) CALL MESAGE (-8,LCOR,SUB)        
      LEND   = BUF1 - 1        
      OUT    = P2        
      TAPCOD(1) = P3(1)        
      TAPCOD(2) = P3(2)        
C     OPEN (UNIT=P2,ACCESS='SEQUENTIAL',STATUS='NEW',FORM='UNFORMATTED',
C    1      ERR=760)        
      IF (P1 .EQ. -9) GO TO 210        
      IF (P1 .EQ. -3) GO TO 300        
      IF (P1 .LE. -2) GO TO 620        
      IF (P1 .LE.  0) GO TO 40        
C        
C     SKIP FORWARD n DATA BLOCKS, P1 = n        
C        
      I = 1        
   20 READ (OUT) KEY        
      KEYX = 2        
      IF (KEY .NE. KEYX) GO TO 720        
      READ (OUT) TMP        
      READ (OUT) KEY        
      IF (KEY .GE. 0) GO TO 740        
      ASSIGN 30 TO IRET        
      NSKIP = 1        
      GO TO 500        
   30 I = I + 1        
      IF (I .LE. P1) GO TO 20        
C        
   40 IF (P1 .NE. -1) GO TO 80        
      REWIND OUT        
      KEY = 3        
      WRITE (OUT) KEY        
      WRITE (OUT) D        
      KEY = 7        
      WRITE (OUT) KEY        
      WRITE (OUT) HDR        
      KEY = 2        
      WRITE (OUT) KEY        
      WRITE (OUT) P3        
      ENDREC = ENDREC - 1        
      WRITE (OUT) ENDREC        
      WRITE (OUT) ENDFIL        
      ENDREC = 0        
      WRITE  (NOUT,50) UIM,P3        
   50 FORMAT (A29,' FROM OUPUT2 MODULE.  THE LABEL IS ',2A4)        
C        
   80 DO 200 II = 1,5        
      INPUT  = 100 + II        
      MCB(1) = INPUT        
      CALL RDTRL (MCB(1))        
      IF (MCB(1) .LE. 0) GO TO 200        
      CALL FNAME (INPUT,NAME)        
      IF (NAME(1).EQ.NONE(1) .AND. NAME(2).EQ.NONE(2)) GO TO 200        
      BLOCK(1) = INPUT        
      NWD = NWDS(MCB(5))        
      DP  = MCB(5).EQ.2 .OR. MCB(5).EQ.4        
C        
C     OPEN INPUT DATA BLOCK TO READ WITH REWIND        
C        
      CALL OPEN (*600,INPUT,Z(BUF1),0)        
      KEY = 2        
      WRITE (OUT) KEY        
      WRITE (OUT) NAME        
      ENDREC = ENDREC - 1        
      WRITE (OUT) ENDREC        
      KEY = 7        
      WRITE (OUT) KEY        
      WRITE (OUT) MCB        
      ENDREC = ENDREC - 1        
      WRITE (OUT) ENDREC        
C        
C     COPY CONTENTS OF INPUT DATA BLOCK ONTO FILE        
C        
   90 CALL RECTYP (INPUT,K)        
      KEY = 1        
      WRITE (OUT) KEY        
      WRITE (OUT) K        
      IF (K .EQ. 0) GO TO 130        
C        
C     STRING RECORD        
C     BLOCK(2) = STRING TYPE, 1,2,3 OR 4        
C     BLOCK(4) = FIRST (OR LAST) ROW POSITION ON A MATRIX COLUMN        
C     BLOCK(5) = POINTER TO STRING, W.R.T. XNS ARRAY        
C     BLOCK(6) = NO. OF TERMS IN STRING        
C        
      BLOCK(8) = -1        
  100 CALL GETSTR (*170,BLOCK)        
      KEY = BLOCK(6)*NWD        
      WRITE (OUT) KEY        
C        
C     NEXT 3 LINES, ORIGINATED FROM MSC/OUTPUT2, DO NOT WORK FOR D.P.   
C     DATA ON VAX, AND POSSIBLY SILICON-GRAPHICS. THEY ARE REPLACED BY  
C     NEXT 8 LINES BELOW. BESIDE, TO WORK ON PROPER D.P. DATA BOUNDARY, 
C     THE K1 IN THE FOLLOWING LINE SHOULD BE  K1 = (BLOCK(5)-1)*NWD+1   
C        
C     K1  = BLOCK(5)        
C     K2  = K1 + KEY - 1        
C     WRITE (OUT) BLOCK(4),(XNS(K),K=K1,K2)        
C        
      K1  = BLOCK(5)*NWD        
      K2  = K1 + KEY -1        
      IF (DP) GO TO 110        
      WRITE (OUT) BLOCK(4),(XNS(K),K=K1,K2)        
      GO TO 120        
  110 K1  = K1/2        
      K2  = K2/2        
      WRITE (OUT) BLOCK(4),(DXNS(K),K=K1,K2)        
C        
  120 CALL ENDGET (BLOCK)        
      GO TO 100        
C        
C     NON-STRING RECORD        
C     MAKE SURE EACH RECORD IS NOT LONGER THAN P4 WORDS        
C        
  130 CALL READ (*180,*150,INPUT,Z(1),LEND,0,K1)        
      DO 140 I = 1,LEND,P4        
      KEY = LEND - I + 1        
      IF (KEY .GE. P4) KEY = P4        
      K2 = I + KEY - 1        
      WRITE (OUT) KEY        
      WRITE (OUT) (Z(K),K=I,K2)        
  140 CONTINUE        
      GO TO 130        
  150 DO 160 I = 1,K1,P4        
      KEY = K1 - I + 1        
      IF (KEY .GE. P4) KEY = P4        
      K2 = I + KEY - 1        
      WRITE (OUT) KEY        
      WRITE (OUT) (Z(K),K=I,K2)        
  160 CONTINUE        
C        
  170 ENDREC = ENDREC - 1        
      WRITE (OUT) ENDREC        
      GO TO 90        
C        
C     CLOSE INPUT DATA BLOCK WITH REWIND        
C        
  180 CALL CLOSE (INPUT,1)        
      WRITE (OUT) ENDFIL        
      ENDREC = 0        
      WRITE  (NOUT,190) UIM,NAME,OUT,INP(P2-10),MCB        
  190 FORMAT (A29,' 4144. DATA BLOCK ',2A4,' WRITTEN ON FORTRAN UNIT ', 
     1       I3,2H (,A4,1H), /5X,'TRAILER =',6I7,I11)        
C        
  200 CONTINUE        
C        
C     CLOSE FORTRAN TAPE WITHOUT END-OF-FILE AND WITHOUT REWIND        
C        
      RETURN 1        
C        
C     FINAL CALL TO OUTPUT2, P1 = -9        
C        
  210 WRITE (OUT) ENDFIL        
C     CLOSE (UNIT=OUT)        
      RETURN 2        
C        
C     OBTAIN LIST OF DATA BLOCKS ON FORTRAN TAPE, P1 = -3        
C        
  300 REWIND OUT        
      READ (OUT) KEY        
      KEYX = 3        
      IF (KEY .NE. KEYX) GO TO 720        
      READ (OUT) DX        
      READ (OUT) KEY        
      KEYX = 7        
      IF (KEY .NE. KEYX) GO TO 720        
      READ (OUT) HDRX        
      DO 310 K = 1,7        
      IF (HDRX(K) .NE. HDR(K)) GO TO 640        
  310 CONTINUE        
      READ (OUT) KEY        
      KEYX = 2        
      IF (KEY .NE. KEYX) GO TO 720        
      READ (OUT) TMP        
      IF (TMP(1).NE.P3(1) .OR. TMP(2).NE.P3(2)) GO TO 660        
  320 ASSIGN 330 TO IRET        
      NSKIP = 1        
      GO TO 500        
  330 K = 0        
  340 CALL PAGE1        
      WRITE  (NOUT,350) INP(P2-10),OUT        
  350 FORMAT (//42X,'CONTENTS OF ',A4,', FORTRAN UNIT',I3, /46X,        
     1       'FILE',18X,'NAME',/)        
  360 READ (OUT) KEY        
      IF (KEY) 680,400,370        
  370 READ (OUT) TMP        
      ASSIGN 380 TO IRET        
      NSKIP = 1        
      GO TO 500        
  380 K = K + 1        
      WRITE  (NOUT,390) K,TMP        
  390 FORMAT (45X,I5,18X,2A4)        
      IF (MOD(K,NLPP)) 360,340,360        
  400 ASSIGN 80 TO IRET        
      NSKIP = K + 1        
      IF (NSKIP .GT. 0) REWIND OUT        
      GO TO 500        
C        
C     SKIP NSKIP FILES ON FORTRAN TAPE        
C        
  500 IF (NSKIP .EQ. 0) GO TO 540        
      DO 530 J = 1,NSKIP        
  510 READ (OUT) KEYX        
      IF (KEYX) 510,530,520        
  520 IF (KEYX .GT. LCOR) GO TO 700        
      READ (OUT) (Z(L),L=1,KEYX)        
      GO TO 510        
  530 CONTINUE        
  540 GO TO IRET, (30,80,330,380)        
C        
C     ERRORS        
C        
  600 CALL FNAME (INPUT,TMP)        
      WRITE  (NOUT,610) SFM,MO2,TMP        
  610 FORMAT (A25,' 4116',A19,'UNABLE TO OPEN INPUT DATA BLOCK ',2A4)   
      GO TO  800        
  620 WRITE  (NOUT,630) UFM,MO2,P1        
  630 FORMAT (A23,' 4120',A19,'ILLEGAL FIRST PARAMETER ',I3)        
      GO TO  800        
  640 WRITE  (NOUT,650) UFM,MO2,HDRX        
  650 FORMAT (A23,' 4130',A19,'ILLEGAL TAPE HEADER CODE ',7A4)        
      GO TO  800        
  660 WRITE  (NOUT,670) UWM,TMP,P3        
  670 FORMAT (A25,' 4141. FORTRAN TAPE ID CODE - ',2A4,        
     1       ' DOES NOT MATCH OUTPUT2 THIRD PARAMETER NAME - ',2A4)     
      GO TO  320        
  680 WRITE  (NOUT,690) SFM,MO2        
  690 FORMAT (A25,' 4415',A19,'SHORT RECORD ENCOUNTERED')        
      GO TO  800        
  700 WRITE  (NOUT,710) UFM,LCOR,KEY        
  710 FORMAT (A23,' 2187. INSUFFICIENT WORKING CORE TO HOLD FORTRAN ',  
     1       'LOGICAL RECORD.', /5X,'LENGHT OF WORKING CORE =',I11,     
     2       '.   LENGTH OF FORTRAN LOGICAL RECORD =',I11)        
      GO TO  800        
  720 WRITE  (NOUT,730) SFM,KEY,KEYX        
  730 FORMAT (A25,' 2190. ILLEGAL VLUE FOR KEY =',I10,1H.,5X,        
     1       'EXPECTED VALUE =',I10)        
      GO TO  800        
  740 WRITE  (NOUT,750) SFM,KEY        
  750 FORMAT (A25,' 2190. ILLEGAL VALUE FOR KEY =',I10)        
C     GO TO  800        
C 760 WRITE  (NOUT,770) UFM,MO2,P2        
C 770 FORMAT (A23,A19,'CANNOT OPEN FORTRAN UNIT',I4,' FOR OUTPUT.')     
  800 CALL MESAGE (-61,0,SUB)        
      RETURN 1        
C        
      END        
