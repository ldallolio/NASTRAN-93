      SUBROUTINE TMTSIO (*,DEBUG1)        
C        
C     TMTSIO TIME TESTS GINO AND THE PACK ROUTINES        
C        
C     COMMENT FORM G.CHAN/UNISYS   5/91        
C     BASICALLY THIS ROUTINE IS SAME AS TIMTS1.        
C        
      INTEGER         SYSBUF, OUTPUT, FILES(2), F1 , F2, BUF1  , BUF2  ,
     1                END   , MCB(7), EOL     , EOR    , TYPE  , TYPIN1,
     2                TYPOU1, TYPOU2, ABLK(15), BBLK(15),ZERO  , DEBUG1,
     3                ISUBR(2)        
      REAL            X(1)  , Z(1)  , T(16)        
      DOUBLE  PRECISION       ZD    , XD        
      CHARACTER       UFM*23, UWM*25, UIM*29  , SFM*25        
      COMMON /XMSSG / UFM   , UWM   , UIM     , SFM        
      COMMON /NTIME / NITEMS, TGINO , TBLDPK  , TINTPK , TPACK ,        
     1                TUNPAK, TGETST, TPUTST  ,        
     2                TTLRSP, TTLRDP, TTLCSP  , TTLCDP ,        
     3                TLLRSP, TLLRDP, TLLCSP  , TLLCDP , TGETSB        
      COMMON /SYSTEM/ SYSBUF, OUTPUT, IDUM(52), IPREC  , JDUM(21), ISY77
      COMMON /GINOX / G(86) , IG(75), NBUFF3  , PU(226), IWR(75)        
      COMMON /ZBLPKX/ ZD(2),  IZ        
      COMMON /ZNTPKX/ XD(2),  IX    , EOL     , EOR        
      COMMON /PACKX / TYPIN1, TYPOU1, I1 , J1 , INCR1        
      COMMON /UNPAKX/ TYPOU2, I2, J2, INCR2        
CZZ   COMMON /ZZTMIO/ A(1)        
      COMMON /ZZZZZZ/ A(1)        
      EQUIVALENCE     (ZD(1),Z(1)), (XD(1),X(1)), (T(1),TGINO)        
      DATA    FILES / 301, 304/, ZERO  / 0    /        
      DATA    I1000 / 1000    /, I1001 / 1001 /        
      DATA    ISUBR / 4HTMTS   , 4HIO  /        
C        
C        
C     CHECK KORSZ AND DUMMY SUBROUTINES HERE.        
C     IF NASTRAN SUBROUTINES WERE NOT COMPILED WITH STATIC OPTION, BUF1 
C     COULD BE NEGATIVE HERE.        
C     CALL DUMMY NEXT TO SEE WHETHER THE RIGHT DUMMY ROUTINE IS SET UP  
C     FOR THIS MACHINE        
C        
      KERR = 1        
      BUF1 = KORSZ(A)        
      IF (BUF1 .LE. 0) GO TO 930        
      IF (DEBUG1 .GT. 0) WRITE (OUTPUT,10)        
   10 FORMAT (' -LINK1 DEBUG- TMTSIO CALLINS DUMMY NEXT')        
      CALL DUMMY        
C        
C     NOTE - ISY77 (WHICH IS BULKDATA OPTION) AND TGINO DETERMINE TO    
C            SKIP TMTSIO AND TMTSLP OR NOT. DIAG 35 CAN NOT BE USED AT  
C            THIS POINT SINCE THE DIAG CARD HAS NOT BEEN READ YET.      
C        
      IF (TGINO.GT.0. .AND. ISY77.NE.-3) RETURN 1        
C        
C     INITIALIZE        
C        
      CALL PAGE1        
      WRITE  (OUTPUT,20)        
   20 FORMAT ('0*** USER INFORMATION MESSAGE 225, GINO TIME CONSTANTS ',
     1        'ARE BEING COMPUTED', /5X,        
     2       '(SEE NASINFO FILE FOR ELIMINATION OF THESE COMPUTATIONS)')
      IF (TGINO .GT. 0.) WRITE (OUTPUT,30) T        
   30 FORMAT ('0*** EXISTING TIME CONSTANTS IN /NTIME/ -',        
     1        /,2(/5X,9F8.3))        
      N = 50        
      M = N        
      TYPE = IPREC        
C     NITEMS = 16        
C        
      F1   = FILES(1)        
      F2   = FILES(2)        
      BUF1 = BUF1 - SYSBUF        
      BUF2 = BUF1 - SYSBUF        
      END  = N*M        
      IF (END .GE. BUF1-1) CALL MESAGE (-8,0,ISUBR)        
      DO 40 I = 1,END        
      A(I) = I        
   40 CONTINUE        
      N10 = N*10        
      M10 = M/10        
      IF (M10 .LE. 0) M10 = 1        
      FN  = N        
      FM  = M        
C        
C     WRITE TEST        
C        
      IF (DEBUG1 .GT. 0) WRITE (OUTPUT,50) NBUFF3,IG        
   50 FORMAT (' -LINK1 DEBUG- OPEN OUTPUT FILE NEXT FOR WRITE. NBUFF3 ='
     1,       I5, /5X,'GINO BUFADD 75 WORDS =', /,(2X,11I7))        
      CALL OPEN (*900,F1,A(BUF1),1)        
      IF (DEBUG1 .LE. 0) GO TO 60        
      WRITE  (OUTPUT,53) NBUFF3,IG        
   53 FORMAT (' -LINK1 DEBUG- FILE OPEN OK. NBUFF3 =',I5, /5X,        
     1        'GINO BUFADD 75 WORDS =', /,(2X,11I7))        
      WRITE  (OUTPUT,55) IWR(41)        
   55 FORMAT (5X,'RWFLG(41) =',I7, //,        
     1        ' -LINK1 DEBUG- CALLING SECOND NEXT')        
   60 CALL CPUTIM (T1,T1,1)        
      DO 70 I = 1,N        
      CALL WRITE (F1,A,M,1)        
   70 CONTINUE        
      CALL CPUTIM (T2,T2,1)        
      IF (DEBUG1 .GT. 0) WRITE (OUTPUT,80)        
   80 FORMAT (' -LINK1 DEBUG- CLOSE FILE NEXT')        
      CALL CLOSE  (F1,1)        
      IF (DEBUG1 .GT. 0) WRITE (OUTPUT,90)        
   90 FORMAT (' -LINK1 DEBUG- OPEN ANOTHER OUTPUT FILE NEXT FOR WRITE') 
      CALL OPEN   (*900,F2,A(BUF2),1)        
      CALL CPUTIM (T3,T3,1)        
      DO 100 I = 1,N10        
      CALL WRITE (F2,A,M10,1)        
  100 CONTINUE        
      CALL CPUTIM (T4,T4,1)        
      CALL CLOSE  (F2,1)        
      ASSIGN 610 TO IRET        
      GO TO 600        
C        
C     READ TEST        
C        
  110 IF (DEBUG1 .GT. 0) WRITE (OUTPUT,120)        
  120 FORMAT (' -LINK1 DEBUG- OPEN INPUT FILE NEXT FOR READ')        
      CALL OPEN (*900,F1,A(BUF1),0)        
      CALL CPUTIM (T1,T1,1)        
      DO 130 I = 1,N        
      CALL READ (*910,*920,F1,A(I1000),M,1,FLAG)        
  130 CONTINUE        
      CALL CPUTIM (T2,T2,1)        
      CALL CLOSE  (F1,2)        
      CALL OPEN   (*900,F2,A(BUF2),0)        
      CALL CPUTIM (T3,T3,1)        
      DO 140 I = 1,N10        
      CALL READ (*910,*920,F2,A(I1000),M10,1,FLAG)        
  140 CONTINUE        
      CALL CPUTIM (T4,T4,1)        
      CALL CLOSE  (F2,2)        
      ASSIGN 620 TO IRET        
      GO TO 600        
C        
C     BACKWARD READ TEST        
C        
  150 CONTINUE        
      CALL OPEN (*900,F1,A(BUF1),2)        
      CALL CPUTIM (T1,T1,1)        
      DO 160 I = 1,N        
      CALL BCKREC (F1)        
      CALL READ   (*910,*920,F1,A(I1000),M,1,FLAG)        
      CALL BCKREC (F1)        
  160 CONTINUE        
      CALL CPUTIM (T2,T2,1)        
      CALL CLOSE  (F1,1)        
      CALL OPEN   (*900,F2,A(BUF2),2)        
      CALL CPUTIM (T3,T3,1)        
      DO 170 I = 1,N10        
      CALL BCKREC (F2)        
      CALL READ   (*910,*920,F2,A(I1000),M10,1,FLAG)        
      CALL BCKREC (F2)        
  170 CONTINUE        
      CALL CPUTIM (T4,T4,1)        
      CALL CLOSE  (F2,1)        
      ASSIGN 630 TO IRET        
      GO TO 600        
C        
C     BLDPK TEST        
C        
  180 CONTINUE        
      CALL OPEN   (*900,F1,A(BUF1),1)        
      CALL MAKMCB (MCB,F1,M,2,TYPE)        
      CALL CPUTIM (T1,T1,1)        
      DO 200 I = 1,N        
      CALL BLDPK (TYPE,TYPE,F1,0,0)        
      DO 190 J = 1,M        
      Z(1) = 1.0        
      IZ   = J        
      CALL ZBLPKI        
  190 CONTINUE        
      CALL BLDPKN (F1,0,MCB)        
  200 CONTINUE        
      CALL CPUTIM (T2,T2,1)        
      CALL WRTTRL (MCB)        
      CALL CLOSE  (F1,1)        
      CALL MAKMCB (MCB,F2,M10,2,TYPE)        
      CALL OPEN   (*900,F2,A(BUF2),1)        
      CALL CPUTIM (T3,T3,1)        
      DO 220 I = 1,N10        
      CALL BLDPK (TYPE,TYPE,F2,0,0)        
      DO 210 J = 1,M10        
      Z(1) = 2.0        
      IZ   = J        
      CALL ZBLPKI        
  210 CONTINUE        
      CALL BLDPKN (F2,0,MCB)        
  220 CONTINUE        
      CALL CPUTIM (T4,T4,1)        
      CALL WRTTRL (MCB)        
      CALL CLOSE  (F2,1)        
      ASSIGN 640 TO IRET        
      GO TO 600        
C        
C     INTPK TEST        
C        
  230 CONTINUE        
      CALL OPEN   (*900,F1,A(BUF1),0)        
      CALL CPUTIM (T1,T1,1)        
      DO 250 I = 1,N        
      CALL INTPK  (*910,F1,0,TYPE,0)        
      DO 240 J = 1,M        
      CALL ZNTPKI        
      IF (IX  .NE. J) GO TO 800        
      IF (EOL .EQ. 0) GO TO 240        
      IF (IX  .NE. M) GO TO 800        
  240 CONTINUE        
      IF (EOL .EQ. 0) GO TO 800        
  250 CONTINUE        
      CALL CPUTIM (T2,T2,1)        
      CALL CLOSE  (F1,1)        
      CALL OPEN   (*900,F2,A(BUF2),0)        
      CALL CPUTIM (T3,T3,1)        
      DO 270 I = 1,N10        
      CALL INTPK (*910,F2,0,TYPE,0)        
      DO 260 J = 1,M10        
      CALL ZNTPKI        
      IF (IX  .NE. J) GO TO 800        
      IF (EOL .EQ. 0) GO TO 260        
      IF (IX  .NE. M10) GO TO 800        
  260 CONTINUE        
      IF (EOL .EQ. 0) GO TO 800        
  270 CONTINUE        
      CALL CPUTIM (T4,T4,1)        
      CALL CLOSE  (F2,1)        
      ASSIGN 650 TO IRET        
      GO TO 600        
C        
C     PACK TEST        
C        
  280 CONTINUE        
      CALL MAKMCB (MCB,F1,M,2,TYPE)        
      TYPIN1 = TYPE        
      TYPOU1 = TYPE        
      I1     = 1        
      J1     = M        
      INCR1  = 1        
      MX     = M*TYPE        
      DO 290 I = 1,MX        
      A(I+1000) = I        
  290 CONTINUE        
      CALL OPEN (*900,F1,A(BUF1),1)        
      CALL CPUTIM (T1,T1,1)        
      DO 300 I = 1,N        
      CALL PACK (A(I1001),F1,MCB)        
  300 CONTINUE        
      CALL CPUTIM (T2,T2,1)        
      CALL WRTTRL (MCB)        
      CALL CLOSE  (F1,1)        
      CALL MAKMCB (MCB,F2,M10,2,TYPE)        
      J1 = M10        
      CALL OPEN (*900,F2,A(BUF2),1)        
      CALL CPUTIM (T3,T3,1)        
      DO 310 I = 1,N10        
      CALL PACK (A(I1001),F2,MCB)        
  310 CONTINUE        
      CALL CPUTIM (T4,T4,1)        
      CALL WRTTRL (MCB)        
      CALL CLOSE  (F2,1)        
      ASSIGN 660 TO IRET        
      GO TO 600        
C        
C     UNPACK TEST        
C        
  320 CONTINUE        
      TYPOU2 = TYPE        
      I2     = 1        
      J2     = M        
      INCR2  = 1        
      CALL OPEN (*900,F1,A(BUF1),0)        
      CALL CPUTIM (T1,T1,1)        
      DO 330 I = 1,N        
      CALL UNPACK (*910,F1,A(I1001))        
  330 CONTINUE        
      CALL CPUTIM (T2,T2,1)        
      CALL CLOSE  (F1,1)        
      J2 = M10        
      CALL OPEN (*900,F2,A(BUF2),0)        
      CALL CPUTIM (T3,T3,1)        
      DO 340 I = 1,N10        
      CALL UNPACK (*910,F2,A(I1001))        
  340 CONTINUE        
      CALL CPUTIM (T4,T4,1)        
      CALL CLOSE  (F2,2)        
      ASSIGN 670 TO IRET        
      GO TO 600        
  350 CONTINUE        
C        
C     PUTSTR TEST        
C        
      KERR    = 2        
      ABLK(1) = F1        
      ABLK(2) = TYPE        
      ABLK(3) = 1        
      CALL GOPEN (F1,A(BUF1),1)        
      NWDS = TYPE        
      IF (TYPE .EQ. 3) NWDS = 2        
      CALL CPUTIM (T1,T1,1)        
      DO 400 I = 1,N        
      ABLK(4) = 0        
      ABLK(8) = -1        
      DO 390 J = 1,10        
      NBRSTR  = M10        
  360 CALL PUTSTR (ABLK)        
      IF (NBRSTR .EQ. 0) GO TO 930        
      ABLK(7) = MIN0(ABLK(6),NBRSTR)        
      ABLK(4) = ABLK(4) + ABLK(7) + 4        
      MM      = ABLK(7)*NWDS        
      DO 370 K = 1,MM        
      X(1) = A(K)        
  370 CONTINUE        
      IF (ABLK(7) .EQ. NBRSTR) GO TO 380        
      CALL ENDPUT (ABLK)        
      NBRSTR = NBRSTR - ABLK(7)        
      GO TO 360        
  380 IF (J .EQ. 10) ABLK(8) = 1        
      CALL ENDPUT (ABLK)        
  390 CONTINUE        
  400 CONTINUE        
      CALL CPUTIM (T2,T2,1)        
      CALL CLOSE (F1,1)        
      M100 = MAX0(M10/10,1)        
      CALL GOPEN (F2,A(BUF2),1)        
      KERR    = 3        
      BBLK(1) = F2        
      BBLK(2) = TYPE        
      BBLK(3) = 1        
      CALL CPUTIM (T3,T3,1)        
      DO 450 I = 1,N10        
      BBLK(4) = 0        
      BBLK(8) =-1        
      DO 440 J = 1,10        
      NBRSTR = M100        
  410 CALL PUTSTR (BBLK)        
      IF (NBRSTR .EQ. 0) GO TO 930        
      BBLK(7) = MIN0(BBLK(6),NBRSTR)        
      BBLK(4) = BBLK(4) + BBLK(7) + 4        
      MM = BBLK(7)*NWDS        
      DO 420 K = 1,MM        
      X(1) = A(K)        
  420 CONTINUE        
      IF (BBLK(7) .EQ. NBRSTR) GO TO 430        
      NBRSTR = NBRSTR - BBLK(7)        
      GO TO 410        
  430 IF (J .EQ. 10) BBLK(8) = 1        
      CALL ENDPUT (BBLK)        
  440 CONTINUE        
  450 CONTINUE        
      CALL CPUTIM (T4,T4,1)        
      CALL CLOSE  (F2,1)        
      ASSIGN 680 TO IRET        
      GO TO 600        
C        
C     GETSTR TEST (GET STRING FORWARD)        
C        
  460 CONTINUE        
      CALL GOPEN (F1,A(BUF1),0)        
      CALL CPUTIM (T1,T1,1)        
      DO 490 I = 1,N        
      ABLK(8) = -1        
  470 CALL GETSTR (*490,ABLK)        
      MM = ABLK(6)*NWDS        
      DO 480 K = 1,MM        
      X(1) = A(K)        
  480 CONTINUE        
      CALL ENDGET (ABLK)        
      GO TO 470        
  490 CONTINUE        
      CALL CPUTIM (T2,T2,1)        
C     CALL CLOSE  (F1,1)        
      CALL GOPEN  (F2,A(BUF2),0)        
      CALL CPUTIM (T3,T3,1)        
      DO 520 I = 1,N10        
      BBLK(8) = -1        
  500 CALL GETSTR (*520,BBLK)        
      MM = BBLK(6)*NWDS        
      DO 510 K = 1,MM        
      X(1) = A(K)        
  510 CONTINUE        
      CALL ENDGET (BBLK)        
      GO TO 500        
  520 CONTINUE        
      CALL CPUTIM (T4,T4,1)        
C     CALL CLOSE  (F2,1)        
      ASSIGN 690 TO IRET        
      GO TO 600        
C        
C     GETSTB TEST, (GET BACKWARD STRING)        
C     F1 AND F2 FILES ARE STILL OPENED, AND POSITIONED AT THE END       
C        
  530 CONTINUE        
C     CALL GOPEN (F1,A(BUF1),0)        
C     CALL REWIND (F1)        
C     CALL SKPFIL (F1,N+1)        
      CALL CPUTIM (T1,T1,1)        
      DO 560 I = 1,N        
      ABLK(8) = -1        
  540 CALL GETSTB (*560,ABLK)        
      MM = ABLK(6)*NWDS        
      DO 550 K = 1,MM        
      X(1) = A(K)        
  550 CONTINUE        
      CALL ENDGTB (ABLK)        
      GO TO 540        
  560 CONTINUE        
      CALL CPUTIM (T2,T2,1)        
      CALL CLOSE  (F1,1)        
C     CALL GOPEN  (F2,A(BUF2),0)        
C     CALL REWIND (F2)        
C     CALL SKPFIL (F2,N10+1)        
      CALL CPUTIM (T3,T3,1)        
      DO 590 I = 1,N10        
      BBLK(8) = -1        
  570 CALL GETSTB (*590,BBLK)        
      MM = BBLK(6)*NWDS        
      DO 580 K = 1,MM        
      X(1) = A(K)        
  580 CONTINUE        
      CALL ENDGTB (BBLK)        
      GO TO 570        
  590 CONTINUE        
      CALL CPUTIM (T4,T4,1)        
      CALL CLOSE  (F2,1)        
      ASSIGN 700 TO IRET        
C        
C     INTERNAL ROUTINE TO STORE TIMING DATA IN /NTIME/ COMMON BLOCK     
C        
  600 CONTINUE        
      TIME1  = T2 - T1        
      TIME2  = T4 - T3        
      TPRREC = 1.0E6*(TIME2 - TIME1)/(9.0*FN)        
      TPRWRD = (1.0E6*TIME1 - FN*TPRREC)/(FN*FM)        
      GO TO IRET, (610,620,630,640,650,660,670,680,690,700)        
  610 TGINO  = TPRWRD        
      GO TO 110        
  620 TGINO  = TGINO + TPRWRD        
      GO TO 150        
  630 TGINO  = TGINO + TPRWRD        
      TGINO  = TGINO/3.0        
      GO TO 180        
  640 TBLDPK = TPRWRD        
      GO TO 230        
  650 TINTPK = TPRWRD        
      GO TO 280        
  660 TPACK  = TPRWRD        
      GO TO 320        
  670 TUNPAK = TPRWRD        
      GO TO 350        
  680 TPUTST = TPRWRD        
      GO TO 460        
  690 TGETST = TPRWRD        
      GO TO 530        
  700 TGETSB = TPRWRD        
      IF (DEBUG1 .GT. 0) WRITE (OUTPUT,710)        
  710 FORMAT (' -LINK1 DEBUG- TMTSIO FINISHED')        
      RETURN        
C        
C     INTERNAL ROUTINE CALLED FOR AN ABORT IN THE INTPK TEST        
C        
  800 WRITE  (OUTPUT,810) SFM        
  810 FORMAT (A25,' 2197, ABORT CALLED DURING TIME TEST OF INTPK')      
C        
C     ABNORMAL RETURNS FROM GINO - ALL FATAL ERRORS        
C        
  900 CONTINUE        
  910 CONTINUE        
  920 CALL MESAGE (-61,0,0)        
  930 WRITE  (OUTPUT,940) KERR        
  940 FORMAT ('0*** TMTSIO FATAL ERROR',I7)        
      GO TO 920        
      END        
