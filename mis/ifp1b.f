      SUBROUTINE IFP1B        
C        
C     THIS ROUTINE DETERMINES THE LOOP CONDITIONS AND CASE CONTROL      
C     REQUEST CHNGES        
C     LOOP$ -- THE CURRENT PROBLEM WILL LOOP        
C        
C     LOOP1$-- THE OLD PROBLEM WAS A LOOP AND CASE CONTROL IS CHANGED   
C     IN LENGTH        
C        
C     COMMENTS FROM G.C.  10/92        
C     IWORD AND IBIT 200 WORDS EACH CORRESPOND TO 200 WORDS IN CASECC   
C     ZERO IN IWORD MEANS NO FURTHER CHECKING        
C     INTEGER VALUE IN IBIT POINTS TO RESTART BIT POSITION, AND WILL BE 
C     SAVED IN BITS(17) AND BITS(18), BITS FOR LCC. (LBD = 16)        
C        
C     LAST REVISED  7/91, BY G.CHAN/UNISYS, TO ALLOW HUGE THRU-RANGE ON 
C     SET IN CASE CONTROL SECTION FOR PRINTOUT OR PLOTTING        
C        
      EXTERNAL        ANDF,ORF        
      LOGICAL         NEW,DEBUG        
      INTEGER         NAME(2),OPTP,CASECC,BITS,TWO1,CORE(2),CASE,CC,SS, 
     1                ORF,ANDF,COREY(401)        
      DIMENSION       ICASE(200,2),IWORD(200),IBIT(200)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /TWO   / TWO1(32)        
      COMMON /SYSTEM/ IBUF,NOUT        
      COMMON /IFPX0 / LBD,LCC,BITS(1)        
      COMMON /XIFP1 / IBLANK        
CZZ   COMMON /ZZIFP1/ COREX(1)        
      COMMON /ZZZZZZ/ COREX(1)        
      COMMON /IFP1A / SCR1,CASECC,IS,NWPC,NCPW4,NMODES,ICC,NSET,NSYM,   
     1                ZZZZBB,ISTR,ISUB,LENCC,IBEN,EQUAL,IEOR        
      EQUIVALENCE    (COREX(1),COREY(1),ICASE(1,1)),(CORE(1),COREY(401))
      DATA    NAME  / 4HIFP1,  4HB          /        
      DATA    CASE  , CC     / 4HCASE,4HCC  /        
      DATA    SS    / 4HSS   /        
      DATA    OPTP  / 4HOPTP /        
      DATA    IWORD /        
     1      -1,01,01,01,01,01,01,01,01,00,01,01,01,01,01,-1,00,01,01,00,
     2      01,01,00,01,01,00,01,01,00,01,01,00,01,01,00,01,01,01,-1,-1,
     3      -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     4      -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     5      -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     6      -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     7      -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,00,-1,-1,01,01,01,
     8      01,01,01,01,00,00,-1,01,01,-1,00,01,01,00,01,01,00,01,01,01,
     9      -1,-1,01,01,01,-1,00,01,01,00,01,01,00,01,01,00,01,01,01,00,
     X      01,01,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1/
      DATA    IBIT  /        
     1      00,02,03,04,05,06,07,08,09,10,10,10,13,14,15,00,18,18,18,18,
     2      18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,17,00,00,
     3      00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
     4      00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
     5      00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
     6      00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
     7      00,00,00,00,00,00,00,00,00,00,00,00,00,00,16,00,00,20,21,21,
     8      22,22,23,23,18,18,00,24,25,00,10,10,10,10,10,10,10,10,10,27,
     9      00,00,30,26,29,00,18,18,18,18,18,18,10,10,10,10,10,10,33,18,
     X      18,18,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00/
      DATA    NEW,DEBUG   / 2*.FALSE. /        
C        
      K  = LBD + 1        
      IFIROD = 0        
      IOLOOP = 0        
      ILOOP  = 0        
      IFIRST = 0        
      IEOPTP = 0        
C        
C     ALLOCATE GINO BUFFERS        
C        
      NZ     = KORSZ(CORE)        
      IBUF1  = NZ - IBUF + 1        
      IBUF2  = IBUF1 - IBUF        
      NZ     = NZ - 2*IBUF        
      ICRQ   =-NZ        
      IF (NZ .LE. 0) GO TO 700        
      IECASE = 0        
C        
C     TRY TO FIND CASECC ON OPTP - TRY TO ASSUME PROPER POSITION        
C        
      CALL OPEN (*560,OPTP,CORE(IBUF1),2)        
      IOPN = 0        
C        
C     FIND CASECC        
C        
   10 CALL READ (*600,*610,OPTP,CORE(1),2,1,IFLAG)        
      IF (CORE(1).EQ.CASE .AND. CORE(2).EQ.CC) GO TO 30        
      IF (CORE(1).EQ.CASE .AND. CORE(2).EQ.SS) GO TO 20        
      IF (IOPN .EQ. 0) CALL REWIND (OPTP)        
      IOPN = 1        
      CALL SKPFIL (OPTP,1)        
      GO TO 10        
C        
C     CASESS FOUND ON OPTP - SKIP TO CASECC        
C        
   20 CALL READ (*600,*610,OPTP,CORE(1),2,1,IFLAG)        
      IF (CORE(1).NE.CASE .OR. CORE(2).NE.CC) GO TO 20        
C        
C     CASECC FOUND ON OLD PROB TAPE        
C        
C     OPEN CASECC AND SKIP CASESS IF PRESENT        
C        
   30 CALL OPEN (*650,CASECC,CORE(IBUF2),0)        
   40 CALL READ (*670,*680,CASECC,CORE(1),2,1,IFLAG)        
      IF (CORE(1).NE.CASE .OR. CORE(2).NE.CC) GO TO 40        
      ASSIGN 50 TO IHOP        
   50 CALL READ (*550,*610,OPTP,ICASE(1,2),LENCC,0,IFLAG)        
      IF (ICASE(16,2) .EQ. 0) GO TO 60        
      CALL FWDREC (*600,OPTP)        
      GO TO 50        
   60 IF (ICASE(LENCC,2) .EQ. 0) GO TO 70        
      LSYM = ICASE(LENCC,2)        
      CALL READ (*600,*610,OPTP,CORE(1),-LSYM,0,IFLAG )        
   70 CALL READ (*600,*80 ,OPTP,CORE(1),   NZ,1,IFOPTP)        
      ICRQ = NZ        
      GO TO 700        
   80 CALL READ (*510,*680,CASECC,ICASE(1,1),LENCC,0,IFLAG)        
      IF (ICASE(16,1) .EQ. 0) GO TO 90        
      CALL FWDREC (*670,CASECC)        
      GO TO 80        
   90 IF (ICASE(LENCC,1) .EQ. 0) GO TO 100        
      LSYM = ICASE(LENCC,1)        
      CALL READ (*670,*680,CASECC,CORE(IFOPTP+1),-LSYM,0,IFLAG)        
  100 CALL READ (*670,*110,CASECC,CORE(IFOPTP+1),NZ-IFOPTP,1,IFCASE)    
      ICRQ = NZ - IFOPTP        
      GO TO 700        
C        
C     CHECK FOR LOOPING PROBLEM        
C        
  110 IF (IFIRST .NE. 0) GO TO 120        
      IFIRST= 1        
      ISPC  = ICASE(  3,1)        
      IMPC  = ICASE(  2,1)        
      IMTD  = ICASE(  5,1)        
      IFREQ = ICASE( 14,1)        
      ITFL  = ICASE( 15,1)        
      IK1   = ICASE(139,1)        
      IK2   = ICASE(140,1)        
      IM1   = ICASE(141,1)        
      IM2   = ICASE(142,1)        
      IB1   = ICASE(143,1)        
      IB2   = ICASE(144,1)        
      IF (ICASE(165,1).GT.0 .OR. ICASE(164,1).GT.0) GO TO 130        
      GO TO 140        
  120 IF (ICASE(  3,1) .NE. ISPC) GO TO 130        
      IF (ICASE(  2,1) .NE. IMPC) GO TO 130        
      IF (ICASE(  5,1) .NE. IMTD) GO TO 130        
      IF (ICASE(139,1).NE.IK1 .OR. ICASE(140,1).NE.IK2) GO TO 130       
      IF (ICASE(141,1).NE.IM1 .OR. ICASE(142,1).NE.IM2) GO TO 130       
      IF (ICASE(143,1).NE.IB1 .OR. ICASE(144,1).NE.IB2) GO TO 130       
      IF (ICASE( 15,1) .NE. ITFL ) GO TO 130        
      IF (ICASE( 14,1) .NE. IFREQ) GO TO 130        
      IF (ICASE(138,1) .GT. 0) GO TO 130        
      IF (ICASE( 38,1) .NE. 0) GO TO 130        
      GO TO 140        
C        
C     SET LOOP$        
C        
  130 BITS(K) = ORF(BITS(K),TWO1(11))        
      ILOOP = 1        
  140 CONTINUE        
C        
C     DETERMINE IF OLD PROBLEM WOULD HAVE LOOPED        
C        
      IF (IFIROD .NE. 0) GO TO 150        
      IFIROD= 1        
      ISPC1 = ICASE(  3,2)        
      IMPC1 = ICASE(  2,2)        
      IMTD1 = ICASE(  5,2)        
      IK11  = ICASE(139,2)        
      IK21  = ICASE(140,2)        
      IM11  = ICASE(141,2)        
      IM21  = ICASE(142,2)        
      IB11  = ICASE(143,2)        
      IB21  = ICASE(144,2)        
      ITFL1 = ICASE( 15,2)        
      IFREQ1= ICASE( 14,2)        
      IF (ICASE(164,2).GT.0 .OR. ICASE(165,2).GT.0) GO TO 160        
      GO TO 170        
C        
C     SECOND RECORD APPLY LOOP RULES        
C        
  150 IF (ICASE(  3,2) .NE. ISPC1) GO TO 160        
      IF (ICASE(  2,2) .NE. IMPC1) GO TO 160        
      IF (ICASE(  5,2) .NE. IMTD1) GO TO 160        
      IF (ICASE(139,2).NE.IK11 .OR. ICASE(140,2).NE.IK21) GO TO 160     
      IF (ICASE(141,2).NE.IM11 .OR. ICASE(142,2).NE.IM21) GO TO 160     
      IF (ICASE(143,2).NE.IB11 .OR. ICASE(144,2).NE.IB21) GO TO 160     
      IF (ICASE(138,2) .GT. 0) GO TO 160        
      IF (ICASE( 38,2) .NE. 0) GO TO 160        
      IF (ICASE( 15,2) .NE. ITFL1 ) GO TO 160        
      IF (ICASE( 14,2) .NE. IFREQ1) GO TO 160        
      GO TO 170        
  160 IOLOOP = 1        
  170 CONTINUE        
      IF (IECASE .NE. 1) GO TO 180        
      IF (IOLOOP .EQ. 1) GO TO 530        
      GO TO 520        
C        
C     CHECK FOR CHANGES -        
C        
  180 IF (IEOPTP .EQ. 1) IEOPTP = 2        
      DO 500 I = 1,LENCC        
      IF (IBIT(I) .EQ. 0) GO TO 500        
      L = IBIT(I)        
      IF (L.LE.32 .AND. ANDF(BITS(K),TWO1(L)).NE.0) GO TO 500        
      IF (IWORD(I) .EQ. 0) GO TO 210        
      IF (ICASE(I,1) .EQ. ICASE(I,2)) GO TO 500        
  190 IF (L .GT. 32) GO TO 200        
      BITS(K) = ORF(BITS(K),TWO1(L))        
      GO TO 500        
C        
C     SECOND CASECC WORD        
C        
  200 L = L - 31        
      BITS(K+1) = ORF(BITS(K+1),TWO1(L))        
      GO TO 500        
C        
C     CHECK FOR PRESENCE OF PRINT AND PLOT REQUESTS        
C        
  210 IF (I.NE.135 .AND. ICASE(I,1).EQ.0) GO TO 500        
      IF (I .NE. 135) GO TO 220        
      IF (ICASE(I,1).NE.0 .OR. ICASE(I,2).NE.0) GO TO 190        
      GO TO 500        
  220 IF (IBIT(I) .EQ. 18) BITS(K+1) = ORF(BITS(K+1),TWO1(3))        
      IF (IBIT(I) .EQ. 10) BITS(K+1) = ORF(BITS(K+1),TWO1(4))        
      IF (IEOPTP  .EQ.  2) GO TO 190        
      IF (ICASE(I,1).LT.0 .AND. ICASE(I,2).LT.0) GO TO 500        
      IF (ICASE(I,1).LT.0 .AND. ICASE(I,2).GE.0) GO TO 190        
      IF (ICASE(I,1).GT.0 .AND. ICASE(I,2).LE.0) GO TO 190        
      IPCASE = IFOPTP + 1        
  230 IF (IPCASE .GT. IFOPTP+IFCASE) GO TO 690        
      IF (CORE(IPCASE) .EQ. ICASE(I,1)) GO TO 240        
      IPCASE = IPCASE + CORE(IPCASE+1) + 2        
      GO TO 230        
  240 IPOPTP = 1        
  250 IF (IPOPTP .GT. IFOPTP) GO TO 620        
      IF (CORE(IPOPTP) .EQ. ICASE(I,2)) GO TO 260        
      IPOPTP = IPOPTP + CORE(IPOPTP+1) + 2        
      GO TO 250        
  260 IQCASE = IFOPTP + IFCASE + 1        
      IX = IPCASE        
      IY = IQCASE        
      ASSIGN 280 TO JUMP        
      IF (DEBUG) WRITE (NOUT,270)        
  270 FORMAT (/,' ------ NPTP PASS ------')        
      GO TO 360        
  280 IQOPTP = IY        
      IX = IPOPTP        
      ASSIGN 300 TO JUMP        
      IF (DEBUG) WRITE (NOUT,290)        
  290 FORMAT (/,' ------ OPTP PASS ------')        
      GO TO 360        
  300 LENG1 = IQOPTP - IQCASE        
      LENG2 = IY - IQOPTP        
      IF (DEBUG) WRITE (NOUT,310) CORE(IPCASE),LENG1,LENG2,IY,IQOPTP,   
     1                            IQCASE        
  310 FORMAT (//,' IFP1B/@310  CHECKING SETS',I9,' FROM NPTP AND OPTP', 
     1        /5X,'LENG1,LENG2, IY,IQOPTP,IQCASE =', 2I5,3I7)        
      IF (LENG1 .NE. LENG2) GO TO 340        
      DO 320 MM = 1,LENG1        
      IF (CORE(IQCASE+MM-1) .NE. CORE(IQOPTP+MM-1)) GO TO 340        
  320 CONTINUE        
      IF (DEBUG) WRITE (NOUT,330) CORE(IPCASE)        
  330 FORMAT (' ... NO DIFFERENCES IN SET',I8)        
      GO TO 500        
  340 WRITE  (NOUT,350) UIM,CORE(IPCASE)        
  350 FORMAT (A29,', SET',I9,' DEFINITION HAS BEEN CHANGED IN RESTART') 
      GO TO 190        
C        
C     A NEW NON-EXPANDING METHOD IS IMPLEMENTED HERE BY  G.CAHN/UNISYS  
C     8/91, IN CASE THE ORIGINAL LOGIC RUNS OUT OF CORE SPACE        
C        
C     THE NEW METHOD WILL CONCATINATE VARIATIONS OF SET DEFINITION TO   
C     THE SIMPLEST FORM.  E.G. THE NEXT 3 LINES SPECIFY THE SAME SET    
C     10 THRU 400000  (THIS IS THE SIMPLEST FORM)        
C     10, 11, 12 THRU 400008, 400009, 400000        
C     10 THRU 20, 21, 22, 23 THRU 200, 201 THRU 500, 501 502 THRU 400000
C        
  360 IF (NEW) GO TO 420        
      IN = CORE(IX+1)        
      IX = IX + 2        
      M  = 0        
  370 M  = M + 1        
      IF (M-IN) 380,400,490        
  380 IF (CORE(IX+M) .GT. 0) GO TO 400        
      M1 = CORE(IX+M-1)        
      M2 =-CORE(IX+M  )        
      ICRQ = IY + M2 - M1 - NZ        
      IF (ICRQ .GT. 0) GO TO 410        
      DO 390 MM = M1,M2        
      CORE(IY) = MM        
      IY = IY + 1        
  390 CONTINUE        
      M = M + 1        
      GO TO 370        
  400 ICRQ = IY - NZ        
      IF (IY .GT. NZ) GO TO 700        
      CORE(IY) = CORE(IX+M-1)        
      IY = IY + 1        
      GO TO 370        
C        
C     INSUFFICIENT CORE SPACE, SWITCH TO NEW METHOD        
C        
  410 NEW = .TRUE.        
      GO TO 260        
C        
C     NEW LOGIC WITHOUT THRU RANGE EXPANSION        
C        
  420 IN = CORE(IX+1)        
      IX = IX + 2        
      M0 = IY        
      CORE(IY) = CORE(IX)        
      IY = IY + 1        
      IF (IN .EQ. 1) GO TO 490        
      CORE(IY) = CORE(IX+1)        
      IF (CORE(IY) .EQ. CORE(IY-1)+1) CORE(IY) = -CORE(IY)        
      IY = IY + 1        
      M  = 1        
  430 M  = M + 1        
      IF (M .GE. IN) GO TO 470        
      M1 = CORE(IX+M)        
      M2 = IABS(M1)        
      IF (DEBUG) WRITE (NOUT,440) M,IN,IX,IY,M1,CORE(IY-1)        
  440 FORMAT (' @440   M,IN,IX,IY,M1,CORE(IY-1) =',6I8)        
      IF (M1 .LT. 0) GO TO 450        
      IF (M1 .NE. 1-CORE(IY-1)) GO TO 460        
      CORE(IY-1) = -M2        
      GO TO 430        
  450 IF (CORE(IY-1) .GT. 0) GO TO 460        
      CORE(IY-1) = -M2        
      GO TO 430        
  460 CORE(IY) = M1        
      IF (M1 .EQ. CORE(IY-1)+1) CORE(IY) = -M2        
      IY = IY + 1        
      GO TO 430        
  470 ICRQ = IY - NZ        
      IF (IY .GT. NZ) GO TO 700        
      M1 = IY - 1        
      IF (DEBUG) WRITE (NOUT,480) CORE(IX-2),(CORE(J),J=M0,M1)        
  480 FORMAT (/,' IFP1B/@480    SET',I8, /,(2X,15I8))        
C        
  490 GO TO JUMP, (280,300)        
C        
  500 CONTINUE        
      GO TO IHOP, (50,80)        
C        
C     EOF ON CASECC        
C        
  510 CALL CLOSE (CASECC,1)        
      IF (IEOPTP .NE. 0) GO TO 530        
      IECASE = 1        
      GO TO 150        
  520 CALL READ (*530,*610,OPTP,ICASE(1,2),LENCC,1,IFLAG)        
      IF (ICASE(16,2) .NE. 0) GO TO 520        
      GO TO 150        
  530 CALL CLOSE (OPTP,2)        
      IF (IEOPTP.EQ.1 .OR. IOLOOP.EQ.0) GO TO 540        
C        
C     SET LOOP1  THIS SHOULD REEXECUTE THE ENTIRE LOOP        
C        
      BITS(K) = ORF(BITS(K),TWO1(12))        
C        
C     CHECK FOR LOOP$ IF NOT ON SET NOLOOP$        
C        
  540 IF (ILOOP .EQ. 0) BITS(K) = ORF(BITS(K),TWO1(32))        
      RETURN        
C        
C     EOF ON  OPTP        
C        
  550 ASSIGN 80 TO IHOP        
      IEOPTP = 1        
      GO TO 80        
C        
C     ERROR MESSAGES        
C        
  560 IP1 = -1        
  570 IP2 = OPTP        
  580 CALL MESAGE (IP1,IP2,NAME)        
      RETURN        
C        
  600 IP1 = -2        
      GO TO 570        
  610 IP1 = -3        
      GO TO 570        
  620 CORE(1) = OPTP        
      CORE(2) = IBLANK        
  630 WRITE  (NOUT,640) SFM,CORE(1),CORE(2)        
  640 FORMAT (A25,' 651, LOGIC ERROR IN SUBROUTINE IFP1B WHILE ',       
     1       'PROCESSING SET DATA ON ',2A4,' FILE.')        
      IP1 = -37        
      GO TO 580        
  650 IP1 = -1        
  660 IP2 = CASECC        
      GO TO 580        
  670 IP1 = -2        
      GO TO 660        
  680 IP1 = -3        
      GO TO 660        
  690 CORE(1) = CASE        
      CORE(2) = CC        
      GO TO 630        
  700 IP1 = -8        
      IP2 = ICRQ        
      GO TO 580        
      END        
