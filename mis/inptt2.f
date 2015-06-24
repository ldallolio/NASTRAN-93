      SUBROUTINE INPTT2        
C        
C     READ DATA BLOCK(S) FROM A FORTRAN UNIT.        
C        
C     CALL TO THIS MODULE IS        
C        
C     INPUTT2   /O1,O2,O3,O4,O5/V,N,P1/V,N,P2/V,N,P3/V,N,P4/V,N,P5/     
C                               V,N,P6 $        
C        
C     PARAMETERS P1, P2, P4, AND P5 ARE INTEGER INPUT. P3 AND P6 ARE BCD
C        
C            P1 =+N, SKIP FORWARD N DATA BLOCKS BEFORE READ        
C               = 0, NO ACTION TAKEN BEFORE READ (DEFAULT)        
C               =-1, BEFORE READ, FORTRAN TAPE IS REWOUND AND TAPE      
C                    HEADER RECORD (RECORD NUMBER ZERO) IS CHECKED      
C               =-3, THE NAMES OF ALL DATA BLOCKS ON FORTRAN TAPE       
C                    ARE PRINTED AND READ OCCURS AT BEGINNING OF TAPE   
C               =-5, SEARCH FORTRAN TAPE FOR FIRST VERSION OF DATA      
C                    BLOCKS REQUESTED.        
C                    IF ANY ARE NOT FOUND, A FATAL TERMINATION OCCURS.  
C               =-6, SEARCH FORTRAN TAPE FOR FINAL VERSION OF DATA      
C                    BLOCKS REQUESTED.        
C                    IF ANY ARE NOT FOUND, A FATAL TERMINATION OCCURS.  
C               =-7, SEARCH FORTRAN TAPE FOR FIRST VERSION OF DATA      
C                    BLOCKS REQUESTED.        
C                    IF ANY ARE NOT FOUND, A WARNING OCCURS.        
C               =-8, SEARCH FORTRAN TAPE FOR FINAL VERSION OF DATA      
C                    BLOCKS REQUESTED.        
C                    IF ANY ARE NOT FOUND, A WARNING OCCURS.        
C        
C            P2 =    THE FORTRAN UNIT FROM WHICH THE DATA BLOCK(S)      
C                    WILL BE READ. (DEFAULT P2 = 11, OR 14)        
C        
C            P3 =    TAPE ID CODE FOR FORTRAN TAPE, AN ALPHANUMERIC     
C                    VARIABLE WHOSE VALUE MUST MATCH A CORRESPONDING    
C                    VALUE ON THE FORTRAN TAPE.        
C                    THIS CHECK IS DEPENDENT ON THE VALUE OF P1 AS      
C                    FOLLOWS..        
C        
C                    *P1*             *TAPE ID CHECKED*        
C                     +N                     NO        
C                      0                     NO        
C                     -1                    YES        
C                     -3                    YES (WARNING CHECK)        
C                     -5                    YES        
C                     -6                    YES        
C                     -7                    YES        
C                     -8                    YES        
C                    THE MPL DEFAULT VALUE FOR P3 IS XXXXXXXX .        
C        
C            P4 =    NOT USED IN INPUTT2.        
C                    (USED ONLY IN OUTPUT2 FOR MAXIMUM RECORD SIZE)     
C        
C            P5 = 0, NON-SPARSE MATRIX IF INPUT IS A MATRIX DATA BLOCK  
C               = NON-0, SPARSE MATRIX IF INPUT IS A MATRIX DATA BLOCK  
C                    (P4 IS IGNORED IF INPUT IS A TALBE DATA BLOCK.     
C                     P4 IS EQUIVALENT TO P5 IN OUTPUT2 MODULE)        
C        
C            P6 = BLANK, (DEFAULT)        
C               = 'MSC', THE INPUT TAPE WAS WRITTEN IN MSC/OUTPUT2      
C                     COMPATIBEL RECORD FORMAT.        
C        
C     OUTPT2 DOES NOT AUTOMATICALLY OUTPUT THE MATRIX IN STRING OR      
C     SPARSE FORM. UNLESS P5 IS REQUESTED.        
C     SIMILARILY, INPUT2 DOES NOT AUTOMATICALLY PROCESS MATRIX IN SPARSE
C     MATRIX FORM, UNLESS P5 IS REQUESTED).        
C        
C     REVISED  11/90 BY G.CHAN/UNISYS        
C              (1) TO ACCEPT MSC/OUTPUT2 DATA (CALLED FROM INPTT4, 11/90
C                  OR INPTT2, 2/93)        
C              (2) TO ACCEPT SPARSE MATRIX COMING FORM COSMIC/OUTPT2    
C                  (SEE P5 PARAMETER IN INPTT2 AND P5 IN OUTPT2)        
C        
      IMPLICIT INTEGER (A-Z)        
      LOGICAL          SPARSE,DP        
      INTEGER          TRL(8),NAME(2),SUBNAM(2),TYPIN,MCB(7),DX(3),     
     1                 NAMEX(2),IDHDR(7),IDHDRX(7),P3X(2),NT(5,3),      
     2                 TAPCOD(2),NONE(2),BCDBIN(4),BLK(20)        
      REAL             CORE(1)        
      DOUBLE PRECISION DCORE(1)        
      CHARACTER        UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG /  UFM,UWM,UIM,SFM        
      COMMON /BLANK /  P1,P2,P3(2),P4,P5,P6(2)        
     1       /SYSTEM/  KSYSTM(65)        
     2       /PACKX /  TYPIN,TYPOUT,IROW,NROW,INCR        
     3       /TYPE  /  PREC(2),NWDS(4)        
CZZ  4       /ZZINP2/  X(1)        
     4       /ZZZZZZ/  X(1)        
CZZ  5       /XNSTRN/  CORE        
      EQUIVALENCE      (CORE(1),X(1))        
      EQUIVALENCE      (KSYSTM(1),NB    ), (KSYSTM( 2),NOUT ),        
     1                 (KSYSTM(9),NLPP  ), (KSYSTM(12),LINE ),        
     2                 (BLK( 1)  ,BNAME ), (BLK( 2)   ,BTYP ),        
     3                 (BLK( 3)  ,BFORM ), (BLK( 4)   ,BROW ),        
     4                 (BLK( 5)  ,BPOINT), (BLK( 6)   ,BRAV ),        
     5                 (BLK( 7)  ,BWRT  ), (BLK( 8)   ,BFLAG),        
     6                 (BLK(12)  ,BCOL  ), (DCORE(1),CORE(1))        
      DATA    SUBNAM/  4HINPT, 4HT2  /  ,   NONE / 4H (NO,4HNE)       / 
      DATA    ZERO  ,  MONE,MTWO,MTRE,MFOR /0,-1,-2,-3,-4  /, I3 / 3  / 
     1        MFIV  ,  MSIX,METE /-5,-6,-8 /,    IPT2,IPT4 / 1H2, 1H4 / 
      DATA    IDHDR /  4HNAST,4HRAN ,4HFORT,4H TAP,4HE ID,4H COD,3HE -/ 
      DATA    BCDBIN/  4HBCD ,4H    ,4HBINA,4HRY    /, MSC / 4HMSC    / 
C        
C        
      IPTX  = IPT2        
      NTRL  = 8        
      IF (P4 .EQ. 0) GO TO 20        
      IF (P5 .NE. 0) GO TO 20        
      WRITE  (NOUT,10) UWM        
   10 FORMAT (A25,'. THE 4TH PARAMETER IN INPUTT2 MODULE IS NO LONGER ',
     1       'USED.', /5X,'SPARSE MATRIX FLAG IS NOW THE 5TH PARAMETER',
     2       ', A MOVE TO SYNCHRONIZE THE PARAMETERS USED IN OUTPUT2')  
      P5 = P4        
   20 SPARSE = .FALSE.        
      IF (P5 .NE. 0) SPARSE = .TRUE.        
      IF (P6(1) .NE. MSC) GO TO 100        
      GO TO 50        
C        
C        
      ENTRY INPUT2        
C     ============        
C        
C     INPUT2 IS CALLED TO HANDLE MSC/OUTPUT2 DATA.        
C     IT IS CALLED FROM INPTT2 WITH P6 PARAMETER = 'MSC', OR        
C     FROM INPTT4        
C        
      IPTX  = IPT4        
   50 WRITE  (NOUT,60) UIM,IPTX        
   60 FORMAT (A29,' FROM INPUTT',A1,'. USER INPUT TAPE IN MSC/OUTPUT2', 
     1       ' COMPATIBLE RECORDS')        
      IPTX  = IPT4        
      NTRL  = 7        
      IRECF = 0        
      SPARSE= .FALSE.        
      IF (P3(1).EQ.BCDBIN(1) .AND. P3(2).EQ.BCDBIN(2)) GO TO 1580       
      IF (P3(1).EQ.BCDBIN(3) .AND. P3(2).EQ.BCDBIN(4)) GO TO 1580       
C        
  100 LCOR = KORSZ(X) - NB        
      IF (LCOR .LE. 0) CALL MESAGE (-8,LCOR,SUBNAM)        
      OUBUF = LCOR + 1        
      TAPCOD(1) = P3(1)        
      TAPCOD(2) = P3(2)        
      IN = P2        
      IF (P1.LT.METE .OR. P1.EQ.MTWO .OR. P1.EQ.MFOR) GO TO 1420        
C        
      IF (P1 .LT. MFOR) GO TO 700        
      IF (P1 .EQ. MTRE) GO TO 500        
      IF (P1 .LE. ZERO) GO TO 130        
C        
      I = 1        
  110 READ (IN) KEY        
      KEYX = 2        
      IF (KEY .NE. KEYX) GO TO 1530        
      READ (IN) NAMEX        
      READ (IN) KEY        
      IMHERE = 115        
      IF (KEY .GE. 0) GO TO 1560        
      ASSIGN 120 TO RET        
      NSKIP = 1        
      GO TO 1300        
C        
  120 I = I + 1        
      IF (I .LE. P1) GO TO 110        
      GO TO 160        
C        
C     OPEN FORTRAN TAPE TO READ TAPE-LABEL WITHOUT REWIND.        
C        
  130 IF (P1 .NE. MONE) GO TO 160        
      REWIND IN        
      READ (IN) KEY        
      KEYX = 3        
      IF (KEY .NE. KEYX) GO TO 1530        
      READ (IN) DX        
      READ (IN) KEY        
      KEYX = 7        
      IF (KEY .NE. KEYX) GO TO 1530        
      READ (IN) IDHDRX        
      DO 140 KF = 1,7        
      IF (IDHDRX(KF) .NE. IDHDR(KF)) GO TO 1460        
  140 CONTINUE        
      READ (IN) KEY        
      KEYX = 2        
      IF (KEY .NE. KEYX) GO TO 1530        
      READ (IN) P3X        
      READ (IN) KEY        
      IMHERE = 145        
      IF (KEY .GE. 0) GO TO 1560        
      IF (P3X(1).NE.P3(1) .OR. P3X(2).NE.P3(2)) GO TO 1440        
      ASSIGN 150 TO RET        
      NSKIP = 1        
      GO TO 1300        
  150 CONTINUE        
C        
  160 DO 430 I = 1,5        
C        
      OUTPUT = 200 + I        
      TRL(1) = OUTPUT        
      CALL RDTRL (TRL)        
      IF (TRL(1) .LE. 0) GO TO 430        
      CALL FNAME (OUTPUT,NAME)        
      IF (NAME(1).EQ.NONE(1) .AND. NAME(2).EQ.NONE(2)) GO TO 430        
C        
C     READ FILE NAME HEADER RECORD.        
C        
      READ (IN) KEY        
      IF (KEY .EQ. 0) GO TO 440        
      KEYX = 2        
      IF (KEY .NE. KEYX) GO TO 1530        
      READ (IN) NAMEX        
      READ (IN) KEY        
      IMHERE = 163        
      IF (KEY .GE. 0) GO TO 1560        
C        
C     READ TRAILER RECORD.        
C        
      READ (IN) KEY        
      KEYX = NTRL        
      IF (KEY .NE. KEYX) GO TO 1530        
      READ (IN) (TRL(L),L=1,NTRL)        
      IF (IPTX .EQ. IPT2) IRECF = TRL(8)        
      READ (IN) KEY        
      IMHERE = 165        
      IF (KEY .GE. 0) GO TO 1560        
C        
C     OPEN OUTPUT DATA BLOCK TO WRITE WITH REWIND.        
C        
      CALL OPEN (*1400,OUTPUT,X(OUBUF),1)        
C        
C     COPY CONTENTS OF FORTRAN TAPE ONTO OUTPUT DATA BLOCK.        
C        
C     TRL(8) = 0, DATA BLOCK IS A TALBE        
C            = 1, DATA BLOCK IS A MATRIX, WRITTEN IN STRING FORMAT      
C            = 2, DATA BLOCK IS A VECTOR (1ST RECORD IS REGULAR, 2ND    
C                 RECORD IS A STRING)        
C        
      INDEX = 0        
      READ (IN) KEY        
      IF (IPTX .EQ. IPT2) GO TO 180        
      BNAME = OUTPUT        
      KEYX  = 1        
      IF (KEY .NE. KEYX) GO TO 1530        
      READ (IN) KREC        
      IMHERE = 170        
      IF (KREC .NE. 0) GO TO 1560        
C        
      READ (IN) KEY        
  180 KEYX  = 2        
      IF (KEY .LT. KEYX) GO TO 1530        
      IF (KEY .GT. LCOR) GO TO 1510        
      READ (IN) (X(L),L=1,KEY)        
      CALL WRITE (OUTPUT,NAME,2,0)        
      IF (KEY .EQ. KEYX) GO TO 200        
      CALL WRITE (OUTPUT,X(I3),KEY-2,0)        
C        
  200 IF (IPTX .EQ. IPT2) GO TO 220        
      READ (IN) KEY        
      IMHERE = 205        
      IF (KEY .GE. 0) GO TO 1560        
      BTYP  = TRL(5)        
      BFORM = 0        
      BCOL  = 0        
      NWD   = NWDS(BTYP)        
      DP    = BTYP.EQ.2 .OR. BTYP.EQ.4        
      CALL WRITE (OUTPUT,X,0,1)        
  210 READ (IN) KEY        
      KEYX = 1        
      IF (KEY .NE. KEYX) GO TO 1530        
      READ (IN) KREC        
      IF (KREC .NE. 0) GO TO 350        
C        
C     TABLE DATA BLOCK(S)        
C        
  220 READ (IN) KEY        
      IF (KEY) 240, 400, 230        
C              EOR, EOF, KEY        
C        
  230 IF (KEY .GT. LCOR) GO TO 1510        
      READ (IN) (X(L),L=1,KEY)        
      CALL WRITE (OUTPUT,X,KEY,0)        
      GO TO 220        
  240 CALL WRITE (OUTPUT,X,0,1)        
      IF (IPTX  .EQ. IPT4) GO TO 210        
      IF (IRECF .EQ.    0) GO TO 200        
      IF (IRECF.EQ.1 .OR. INDEX.GT.0) GO TO 250        
      INDEX = 1        
      GO TO 220        
C        
C     READ STRING FORMATTED MATRIX        
C        
  250 IF (IRECF.EQ.2 .AND. INDEX.EQ.2) GO TO 260        
      INDEX = 2        
      CALL MAKMCB (MCB(1),OUTPUT,TRL(3),TRL(4),TRL(5))        
      IROW  = 1        
      NROW  = TRL(3)        
      TYPIN = TRL(5)        
      TYPOUT= TRL(5)        
      NWDSX = NWDS(TYPOUT)        
      NCOL  = TRL(2)        
C        
C     CHECK FOR NULL MATRIX        
C        
      IF (NROW.EQ.0 .OR. NCOL.EQ.0) GO TO 400        
      IF (IRECF .EQ. 2) NCOL = 1        
      INCR  = 1        
      NWDSX = NROW*NWDSX        
  260 KEYX  = NWDSX        
C        
C     NWDSX IS NUMBER OF WORDS NEEDED PER COLUMN        
C        
      IF (SPARSE) GO TO 300        
      DO 270 L = 1,NCOL        
      READ (IN) KEY        
      IF (KEY .NE. KEYX) GO TO 1530        
      IF (KEY .GT. LCOR) GO TO 1510        
      READ (IN) (X(K),K=1,NWDSX)        
      CALL PACK (X,OUTPUT,MCB)        
      READ (IN) KEY        
      IMHERE = 265        
      IF (KEY .GT. 0) GO TO 1560        
  270 CONTINUE        
  280 IF (IRECF .EQ. 2) GO TO 200        
      KEYX = 0        
      READ (IN) KEY        
      IMHERE = 285        
      IF (KEY .NE. KEYX) GO TO 1530        
      GO TO 400        
C        
C     SPARSE MATRIX INPUT (P5 = NON-ZERO)        
C     (NOT CALLING FROM INPTT4 (IPTX=IPT2)        
C        
  300 DO 340 L = 1,NCOL        
      DO 310 K = 1,NWDSX        
  310 X(K) = 0.0        
  320 READ (IN) KEY,BASE        
      IF (KEY .LT. 0) GO TO 330        
      READ (IN) (X(K+BASE),K=1,KEY)        
      GO TO 320        
  330 CALL PACK (X,OUTPUT,MCB)        
  340 CONTINUE        
      GO TO 280        
C        
C     MATRIX DATA BLOCK - MSC/STRING RECORD. (IPTX=IPT4)        
C        
C        
  350 BFLAG = -1        
      BCOL  = BCOL + 1        
  360 READ (IN) KEY        
      CALL PUTSTR (BLK)        
      IMHERE = 360        
      IF (KEY)  390,1560, 370        
C       NULL or EOR, ERR, KEY        
C        
  370 BWRT = KEY/NWD        
      IMHERE = 370        
      IF (BWRT .GT. BRAV) GO TO 1560        
C        
C     COMMENTS FROM G.C./UNISYS   3/93        
C     UNLESS MSC/PUTSTR IS DIFFERENT FROM COSMIC/PUTSTR, THE FOLLOWING  
C     3 LINES, ORIGINATED FROM MSC SOURCE CODE, DO NOT WORK FOR D.P.    
C     DATA ON VAX, AND POSSIBLY SILICON-GRAHPICS. THEY ARE REPLACED BY  
C     NEXT 17 LINES BELOW.        
C     (I TRIED  SETTING L1=(BPOINT-1)*NWD+1, AND STILL DID NOT WORK.)   
C     THE PROBLEM HERE IS D.P. DATA MAY FALL SHORT ON DOUBLE WORD       
C     BOUNADRY, AND THEREFORE BECOME GARBAGE, WHICH MAY CAUSE FATAL     
C     ERROR IN PRINTING.        
C        
C     L1 = BPOINT        
C     L2 = L1 - 1 + KEY        
C     READ (IN) BROW,(CORE(L),L=L1,L2)        
C        
      L1 = BPOINT*NWD        
      L2 = L1 - 1 + KEY        
      IF (DP) GO TO 380        
C     L  = 375        
C     WRITE  (NOUT,375) L,L1,L2,KEY,BROW,BTYP,BPOINT        
C 375 FORMAT (' /@',I3,'  L1,L2,KEY,BROW,BTYP,BPOINT =',4I7,4I4)        
      READ   (IN) BROW,(CORE(L),L=L1,L2)        
C     WRITE  (NOUT,376,ERR=388) (CORE(L),L=L1,L2)        
C 376 FORMAT (10X,' CORE =',/,(1X,11E11.3))        
      GO TO 385        
  380 L1 = L1/2        
      L2 = L2/2        
C     L  = 382        
C     WRITE  (NOUT,375) L,L1,L2,KEY,BROW,BTYP,BPOINT        
      READ   (IN) BROW,(DCORE(L),L=L1,L2)        
C     WRITE  (NOUT,382,ERR=388) (DCORE(L),L=L1,L2)        
C 382 FORMAT (10X,'DCORE =',/,(1X,11D11.3))        
  385 CALL ENDPUT (BLK)        
      GO TO 360        
  390 BFLAG = +1        
      BWRT  =  0        
      CALL ENDPUT (BLK)        
      GO TO 210        
C        
C     CLOSE OUTPUT DATA BLOCK WITH REWIND AND EOF.        
C        
  400 CALL CLOSE (OUTPUT,1)        
C        
C     WRITE TRAILER.        
C        
      TRL(1) = OUTPUT        
      CALL WRTTRL (TRL)        
      CALL PAGE2 (-3)        
      WRITE  (NOUT,410) UIM,NAME,IN,NAMEX        
  410 FORMAT (A29,' 4105, DATA BLOCK ',2A4,' RETRIEVED FROM FORTRAN ',  
     1        'TAPE ',I2, /5X,'ORIGINAL NAME OF DATA BLOCK WAS ',2A4)   
      IF (SPARSE .AND. NTRL.EQ.8 .AND. TRL(8).NE.0)        
     1    WRITE (NOUT,420) TRL(2),TRL(3)        
  420 FORMAT (1H+,55X,'(A SPARSE MATRIX',I6,2H X,I6,')')        
C        
  430 CONTINUE        
C        
C     CLOSE FORTRAN TAPE WITHOUT REWIND.        
C        
  440 CONTINUE        
      RETURN        
C        
C     OBTAIN LIST OF DATA BLOCKS ON FORTRAN TAPE.        
C        
  500 REWIND IN        
      READ (IN) KEY        
      KEYX = 3        
      IF (KEY .NE. KEYX) GO TO 1530        
      READ (IN) DX        
      READ (IN) KEY        
      KEYX = 7        
      IF (KEY .NE. KEYX) GO TO 1530        
      READ (IN) IDHDRX        
      DO 510 KF = 1,7        
      IF (IDHDRX(KF) .NE. IDHDR(KF)) GO TO 1460        
  510 CONTINUE        
      READ (IN) KEY        
      KEYX = 2        
      IF (KEY .NE. KEYX) GO TO 1530        
      READ (IN) P3X        
      READ (IN) KEY        
      IMHERE = 515        
      IF (KEY .GE. 0) GO TO 1560        
      IF (P3X(1).NE.P3(1) .OR. P3X(2).NE.P3(2)) GO TO 1480        
  520 ASSIGN 530 TO RET        
      NSKIP = 1        
      GO TO 1300        
  530 KF   = 0        
  540 CALL PAGE1        
      LINE = LINE + 8        
      WRITE  (NOUT,550) IN        
  550 FORMAT (//50X,'FILE CONTENTS ON FORTRAN UNIT ',I2, /51X,32(1H-),  
     1        //54X,4HFILE,18X,4HNAME,//)        
  560 READ (IN) KEY        
      IF (KEY .EQ. 0) GO TO 590        
C     KEYX = 2        
C     IF (KEY .NE. KEYX) GO TO 9918        
      READ (IN) NAMEX        
C     READ (IN) KEY        
C     IF (KEY .GE. 0) GO TO 9919        
      ASSIGN 570 TO RET        
      NSKIP = 1        
      GO TO 1300        
  570 KF   = KF + 1        
      LINE = LINE + 1        
      WRITE  (NOUT,580) KF,NAMEX        
  580 FORMAT (53X,I5,18X,2A4)        
      IF (LINE - NLPP) 560,540,540        
  590 REWIND IN        
      ASSIGN 600 TO RET        
      NSKIP = 1        
      GO TO 1300        
  600 CONTINUE        
      GO TO 160        
C        
C     SEARCH MODE        
C        
C     EXAMINE OUTPUT REQUESTS AND FILL NAME TABLE.        
C        
  700 NNT = 0        
      DO 720 I = 1,5        
      OUTPUT = 200 + I        
      TRL(1) = OUTPUT        
      CALL RDTRL (TRL)        
      IF (TRL(1) .LE. 0) GO TO 710        
      CALL FNAME (OUTPUT,NAME)        
      IF (NAME(1).EQ.NONE(1) .AND. NAME(2).EQ.NONE(2)) GO TO 710        
      NT(I,1) = 0        
      NT(I,2) = NAME(1)        
      NT(I,3) = NAME(2)        
      NNT = NNT + 1        
      GO TO 720        
  710 NT(I,1) = -1        
C     IF (IPTX .NE. IPT2) GO TO 3050        
      NT(I,2) = NONE(1)        
      NT(I,3) = NONE(2)        
  720 CONTINUE        
C        
      IF (NNT .GT. 0) GO TO 800        
      CALL PAGE2 (-2)        
      WRITE  (NOUT,730) UWM,IPTX        
  730 FORMAT (A25,' 4137, ALL OUTPUT DATA BLOCKS FOR INPUTT',A1,        
     1        ' ARE PURGED.')        
C     CLOSE (UNIT=IN)        
      RETURN        
C        
C     CHECK TAPE ID LABEL.        
C        
  800 REWIND IN        
      READ (IN) KEY        
      KEYX = 3        
      IF (KEY .NE. KEYX) GO TO 1530        
      READ (IN) DX        
      READ (IN) KEY        
      KEYX = 7        
      IF (KEY .NE. KEYX) GO TO 1530        
      READ (IN) IDHDRX        
      DO 810 KF = 1,7        
      IF (IDHDRX(KF) .NE. IDHDR(KF)) GO TO 1460        
  810 CONTINUE        
      READ (IN) KEY        
      KEYX = 2        
      IF (KEY .NE. KEYX) GO TO 1530        
      READ (IN) P3X        
      READ (IN) KEY        
      IMHERE = 815        
      IF (KEY .GE. 0) GO TO 1560        
      IF (P3X(1).NE.P3(1) .OR. P3X(2).NE.P3(2)) GO TO 1440        
      ASSIGN 820 TO RET        
      NSKIP = 1        
      GO TO 1300        
  820 CONTINUE        
C        
C     BEGIN SEARCH OF TAPE.        
C        
      KF = 0        
  830 READ (IN) KEY        
      IF (KEY .EQ. 0) GO TO 1140        
C     KEYX = 2        
C     IF (KEY .NE. KEYX) GO TO 9918        
      READ (IN) NAMEX        
      READ (IN) KEY        
      IMHERE = 835        
      IF (KEY .GE. 0) GO TO 1560        
      KF = KF + 1        
C        
      DO 1100 I = 1,5        
      NAME(1) = NT(I,2)        
      NAME(2) = NT(I,3)        
      IF (NT(I,1) .LT. 0) GO TO 1100        
      IF (NAME(1).NE.NAMEX(1) .OR. NAME(2).NE.NAMEX(2)) GO TO 1100      
      NT(I,1) = NT(I,1) + 1        
      IF (NT(I,1).EQ.1 .OR. P1.EQ.MSIX .OR. P1.EQ.METE) GO TO 850       
      CALL PAGE2 (-3)        
      WRITE  (NOUT,840) UWM,NAME,KF,IN        
  840 FORMAT (A25,' 4138, DATA BLOCK ,',2A4,' (DATA BLOCK COUNT =',I6,  
     1       ')  HAS PREVIOUSLY BEEN RETRIEVED FROM ', /36X,        
     2       'FORTRAN TAPE ',I2,' AND WILL BE IGNORED.')        
      GO TO 1110        
  850 READ (IN) KEY        
      KEYX = NTRL        
      IF (KEY .NE. KEYX) GO TO 1530        
      READ (IN) (TRL(L),L=1,NTRL)        
      IF (IPTX .EQ. IPT2) IRECF = TRL(8)        
      READ (IN) KEY        
      IMHERE = 855        
      IF (KEY .GE. 0) GO TO 1560        
C        
      OUTPUT = 200 + I        
      CALL OPEN (*1400,OUTPUT,X(OUBUF),1)        
C        
      INDEX = 0        
C     IF (IPTX .EQ. IPT4) GO TO 890        ! FROM MSC/INPTT4        
      READ (IN) KEY        
      IF (IPTX .EQ. IPT2) GO TO 860        
      KEYX = 1        
      IF (KEY .EQ. KEYX) GO TO 1530        
      READ (IN) KREC        
      IMHERE = 857        
      IF (KREC .LT. 0) GO TO 1560        
      READ (IN) KEY        
  860 KEYX = 2        
      IF (KEY .LT. KEYX) GO TO 1530        
      IF (KEY .GT. LCOR) GO TO 1510        
      READ (IN) (X(L),L=1,KEY)        
      CALL WRITE (OUTPUT,NAME,2,0)        
      IF (KEY .EQ. KEYX) GO TO 870        
      CALL WRITE (OUTPUT,X(I3),KEY-2,0)        
C        
  870 IF (IPTX .EQ. IPT2) GO TO 890        
      READ (IN) KEY        
      IMHERE = 875        
      IF (KEY .GT. 0) GO TO 1560        
      BTYP  = TRL(5)        
      BFORM = 0        
      BCOL  = 0        
      NWD   = NWDS(BTYP)        
      DP    = BTYP.EQ.2 .OR. BTYP.EQ.4        
      CALL WRITE (OUTPUT,0,0,1)        
  880 READ (IN) KEY        
      KEYX = 1        
      IF (KEY .NE. KEYX) GO TO 1530        
      READ (IN) KREC        
      IF (KREC .NE. 0) GO TO 1010        
C        
C     TABLE DATA BLOCK(S)        
C        
  890 READ (IN) KEY        
      IF (KEY) 910,1060,900        
C              EOR, EOF, KEY        
C        
  900 IF (KEY .GT. LCOR) GO TO 1510        
      READ (IN) (X(L),L=1,KEY)        
      CALL WRITE (OUTPUT,X,KEY,0)        
      GO TO 890        
  910 CALL WRITE (OUTPUT,X,0,1)        
C     IF (IPTX .EQ. IPT4) GO TO 890        
      IF (IPTX .EQ. IPT4) GO TO 880        
      IF (IRECF .EQ. 0) GO TO 870        
      IF (IRECF .EQ. 1) GO TO 920        
      IF (INDEX .GT. 0) GO TO 920        
      INDEX = 1        
      GO TO 870        
C        
C     READ STRING FORMATTED MATRIX        
C        
  920 IF (IRECF.EQ.2 .AND. INDEX.EQ.2) GO TO 930        
      INDEX = 2        
      CALL MAKMCB (MCB(1),OUTPUT,TRL(3),TRL(4),TRL(5))        
      IROW  = 1        
      NROW  = TRL(3)        
      TYPIN = TRL(5)        
      TYPOUT= TRL(5)        
      NWDSX = NWDS(TYPOUT)        
      NCOL  = TRL(2)        
C        
C     CHECK FOR NULL MATRIX        
C        
      IF (NROW.EQ.0 .OR. NCOL.EQ.0) GO TO 1060        
      IF (IRECF .EQ. 2) NCOL = 1        
      INCR  = 1        
      NWDSX = NROW*NWDSX        
  930 KEYX  = NWDSX        
C        
C     NWDSX IS NUMBER OF WORDS NEEDED PER COLUMN        
C        
      IF (SPARSE) GO TO 960        
      DO 940 L = 1,NCOL        
      READ (IN) KEY        
      IF (KEY .NE. KEYX) GO TO 1530        
      IF (KEY .GT. LCOR) GO TO 1510        
      READ (IN) (X(K),K=1,NWDSX)        
      CALL PACK (X,OUTPUT,MCB)        
      READ (IN) KEY        
      IMHERE = 935        
      IF (KEY .GT. 0) GO TO 1560        
  940 CONTINUE        
  950 IF (IRECF .EQ. 2) GO TO 870        
      KEYX = 0        
      READ (IN) KEY        
      IF (KEY .NE. KEYX) GO TO 1530        
      GO TO 1060        
C        
C     SPARSE MATRIX INPUT (P4 = NON-ZERO)        
C     (NOT CALLING FROM INPTT4 (IPTX=IPT2)        
C        
  960 DO 1000 L = 1,NCOL        
      DO 970 K  = 1,NWDSX        
  970 X(K) = 0.0        
  980 READ (IN) KEY,BASE        
      IF (KEY .LT. 0) GO TO 990        
      READ (IN) (X(K+BASE),K=1,KEY)        
      GO TO 980        
  990 CALL PACK (X,OUTPUT,MCB)        
 1000 CONTINUE        
      GO TO 950        
C        
C     MATRIX DATA BLOCK, IPTX = IPT4.  MSC/STRING RECORD        
C        
C        
 1010 BFLAG = -1        
      BCOL  = BCOL + 1        
 1020 READ (IN) KEY        
      CALL PUTSTR (BLK)        
      IMHERE = 1025        
      IF (KEY)  1050,1560,1030        
C       NULL or EOR,  ERR, KEY        
C        
 1030 BWRT = KEY/NWD        
      IMHERE = 1030        
      IF (BWRT .GT. BRAV) GO TO 1560        
C        
C     L1 = BPOINT        
C     L2 = L1 - 1 + KEY        
C     READ (IN) BROW,(CORE(L),L=L1,L2)        
C        
      L1 = BPOINT*NWD        
      L2 = L1 - 1 + KEY        
      IF (DP) GO TO 1035        
      READ (IN) BROW,(CORE(L),L=L1,L2)        
      GO TO 1040        
 1035 L1 = L1/2        
      L2 = L2/2        
      READ (IN) BROW,(DCORE(L),L=L1,L2)        
 1040 CALL ENDPUT (BLK)        
      GO TO 1020        
 1050 BFLAG = +1        
      BWRT  =  0        
      CALL ENDPUT (BLK)        
      GO TO 880        
C        
C     CLOSE OUTPUT DATA BLOCK WITH REWIND AND EOF        
C        
 1060 CALL CLOSE (OUTPUT,1)        
C        
C     WRITE TRAILER        
C        
      TRL(1) = OUTPUT        
      CALL WRTTRL (TRL)        
      CALL PAGE2 (-2)        
      WRITE  (NOUT,1070) UIM,NAME,IN,KF        
 1070 FORMAT (A29,' 4139, DATA BLOCK ',2A4,' RETRIEVED FROM FORTRAN ',  
     1       'TAPE ',I2,' (DATA BLOCK COUNT =',I6,1H))        
      IF (NT(I,1) .GT. 1) GO TO 1080        
      NNT = NNT - 1        
      GO TO 1130        
 1080 WRITE  (NOUT,1090) UWM        
 1090 FORMAT (A25,' 4140, SECONDARY VERSION OF DATA BLOCK HAS REPLACED',
     1       ' EARLIER ONE.')        
      CALL PAGE2 (-2)        
      GO TO 1130        
 1100 CONTINUE        
C        
 1110 ASSIGN 1120 TO RET        
      NSKIP = 1        
      GO TO 1300        
 1120 CONTINUE        
 1130 IF (NNT.GT.0 .OR. P1.EQ.MSIX .OR. P1.EQ.METE) GO TO 830        
      GO TO 1200        
C        
 1140 IF (NNT .LE. 0) GO TO 1200        
      CALL PAGE2 (-7)        
      IF (P1.EQ.MFIV .OR. P1.EQ.MSIX) GO TO 1160        
      WRITE  (NOUT,1150) UWM        
 1150 FORMAT (A25,' 4141, ONE OR MORE DATA BLOCKS NOT FOUND ON FORTRAN',
     1       ' TAPE.')        
      GO TO 1170        
 1160 WRITE (NOUT,1500) UFM        
 1170 DO 1190 I = 1,5        
      IF (NT(I,1) .NE. 0) GO TO 1190        
      WRITE  (NOUT,1180) NT(I,2),NT(I,3)        
 1180 FORMAT (20X,21HNAME OF DATA BLOCK = ,2A4)        
 1190 IF (IPTX .EQ. IPT4) GO TO 1200        
      IF (P1.EQ.MFIV .OR. P1.EQ.MSIX) GO TO 1600        
C        
 1200 ASSIGN 1210 TO RET        
      NSKIP = -1        
      GO TO 1300        
 1210 CONTINUE        
      RETURN        
C        
C     SIMULATION OF SKPFIL (IN,NSKIP)        
C        
 1300 IF (NSKIP) 1320,1310,1330        
 1310 GO TO RET, (120,150,530,570,600,820,1120,1210)        
 1320 REWIND IN        
C        
C     NSKIP = COMPLEMENT OF NSKIP.        
C        
 1330 DO 1370 NS = 1,NSKIP        
 1340 READ (IN) KEY        
      IF (KEY) 1340,1360,1350        
C               EOR, EOF, KEY        
C        
 1350 IF (KEY .GT. LCOR) GO TO 1510        
      READ (IN) (X(L),L=1,KEY)        
      GO TO 1340        
 1360 CONTINUE        
 1370 CONTINUE        
      GO TO 1310        
C        
C     ERRORS        
C        
 1400 WRITE  (NOUT,1410) UFM,IPTX,OUTPUT        
 1410 FORMAT (A23,' 4108, SUBROUTINE INPTT',A1,' UNABLE TO OPEN OUTPUT',
     1        ' DATA BLOCK',I6)        
      GO TO  1600        
 1420 WRITE  (NOUT,1430) UFM,IPTX,P1        
 1430 FORMAT (A23,' 4113, MODULE INPUTT',A1,' - ILLEGAL VALUE FOR ',    
     1       'FIRST PARAMETER =',I20)        
      GO TO  1600        
 1440 WRITE  (NOUT,1450) UFM,P3X,IPTX,P3        
 1450 FORMAT (A23,' 4136, USER TAPE ID CODE -',2A4,'- DOES NOT MATCH ', 
     1       'THIRD INPUTT',A1,' DMAP PARAMETER -',2A4,2H-.)        
      LINE = LINE + 1        
      GO TO  1600        
 1460 WRITE  (NOUT,1470) UFM,IPTX,IDHDRX        
 1470 FORMAT (A23,' 4134, MODULE INPUTT',A1,' - ILLEGAL TAPE CODE ',    
     1        'HEADER = ',7A4)        
      GO TO  1600        
 1480 WRITE  (NOUT,1490) UWM,P3X,IPTX,P3        
 1490 FORMAT (A25,' 4135, USER TAPE ID CODE -',2A4,'- DOES NOT MATCH ', 
     1        'THIRD INPUTT',A1,' DMAP PARAMETER -',2A4,2H-.)        
      GO TO  520        
 1500 FORMAT (A23,' 4142, ONE OR MORE DATA BLOCKS NOT FOUND ON USER ',  
     1       'TAPE')        
 1510 WRITE  (NOUT,1520) UFM,LCOR,KEY        
 1520 FORMAT (A23,' 2187, INSUFFICIENT WORKING CORE TO HOLD FORTRAN ',  
     1       'LOGICAL RECORD.', /5X,'LENGTH OF WORKING CORE =',I11,     
     2       ',  LENGTH OF FORTRAN LOGICAL RECORD =',I11,1H.)        
      LINE = LINE + 1        
      GO TO  1600        
 1530 WRITE  (NOUT,1540) SFM,KEY,KEYX        
 1540 FORMAT (A25,' 2190, ILLEGAL VALUE FOR KEY =',I10,        
     1       ',   EXPECTED VALUE =',I11,1H.)        
      IF (KEY.EQ.2 .AND. KEYX.EQ.3) WRITE (NOUT,1550)        
 1550 FORMAT (5X,'POSSIBLY DUE TO IMPROPER TAPE GENERATION PROCEDURE')  
      GO TO  1600        
 1560 WRITE  (NOUT,1570) SFM,KEY,IMHERE        
 1570 FORMAT (A25,' 2190, ILLEGAL VALUE FOR KEY =',I10,'.  IMHERE =',I4)
      GO TO  1600        
 1580 WRITE  (NOUT,1590) UFM,P3        
 1590 FORMAT (A23,', ILLEGAL TAPE LABEL NAME -',2A4,'-  POSSIBLY ',     
     1       'THE 4TH PARAMETER OF INPTT4 IS IN ERROR')        
      GO TO  1600        
C        
 1600 LINE = LINE + 2        
      CALL MESAGE (-61,LCOR,SUBNAM)        
      RETURN        
C        
      END        
