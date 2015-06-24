      SUBROUTINE SDCOMP (*,ZI,ZR,ZD)        
C        
C     SDCOMP PERFORMS THE TRIANGULAR DECOMPOSITION OF A SYMMETRIC       
C     MATRIX. THE MATRIX MAY BE REAL OR COMPLEX AND ITS PRECISION MAY   
C     BE SNGL OR DBL        
C        
      EXTERNAL LSHIFT  ,ANDF    ,ORF        
      LOGICAL  GO      ,SPILL   ,SPLOUT  ,SPLIN   ,ROWONE        
      INTEGER  PRC     ,WORDS   ,RLCMPX  ,CLOS    ,BUF1    ,BUF2    ,   
     1         BUF3    ,BUF4    ,BUF5    ,RC      ,PREC    ,TYPEA   ,   
     2         ZI(1)   ,CONFIG  ,POWER   ,DBA     ,DBL     ,DBC     ,   
     3         SCR1    ,SCR2    ,SYSBUF  ,FORMA   ,SYM     ,SQR     ,   
     4         SCRA    ,SCRB    ,C5MAX   ,BLK     ,PCMAX   ,SAVG    ,   
     5         NULL(20),COL     ,C       ,S       ,SPROW   ,STURM   ,   
     6         GROUPS  ,CAVG    ,CMAX    ,SC      ,PREVC   ,ROW     ,   
     7         FRSTPC  ,PCAVG   ,PCROW   ,PCSQR   ,SX      ,CI      ,   
     8         SCR3    ,WB      ,SCRC    ,SCRD    ,SPFLG   ,START   ,   
     9         WA      ,CHLSKY  ,BEGN    ,END     ,DBNAME(2)        ,   
     O         PCGROU  ,ABLK    ,BBLK    ,SUBNAM(5)                 ,   
     1         KEY(1)  ,ORF     ,STATFL  ,ANDF    ,TWO24   ,TWO25   ,   
     2         MTYPE(2),IREAL(2),ICMPLX(2)        
      REAL     ZR(2)   ,SAVE(6) ,MINDS        
      DOUBLE PRECISION  ZD(2)   ,MINDD   ,XDNS(1) ,DDR     ,DDC     ,   
     1                  RD      ,DSAVE3        
      CHARACTER*10      UNUSE   ,ADDI    ,UNADD        
      CHARACTER         UFM*23  ,UWM*25  ,UIM*29  ,SFM*25        
      COMMON  /XMSSG /  UFM     ,UWM     ,UIM     ,SFM        
      COMMON  /SFACT /  DBA(7)  ,DBL(7)  ,DBC(7)  ,SCR1    ,SCR2    ,   
     1                  LCORE   ,DDR     ,DDC     ,POWER   ,SCR3    ,   
     2                  MINDD   ,CHLSKY        
      COMMON  /NTIME /  NITEMS  ,TMIO    ,TMBPAK  ,TMIPAK  ,TMPAK   ,   
     1                  TMUPAK  ,TMGSTR  ,TMPSTR  ,TMT(4)  ,TML(4)      
      COMMON  /STURMX/  STURM   ,SHFTPT  ,KEEP    ,PTSHFT  ,NR        
      COMMON  /SYSTEM/  KSYSTM(63)        
      COMMON  /NAMES /  RDNRW   ,RDREW   ,WRT     ,WRTREW  ,REW     ,   
     1                  NOREW   ,EOFNRW  ,RSP     ,RDP     ,CSP     ,   
     2                  CDP     ,SQR     ,RECT    ,DIAG    ,LOWTRI  ,   
     3                  UPRTRI  ,SYM        
      COMMON  /TYPE  /  PRC(2)  ,WORDS(4),RLCMPX(4)        
CZZ   COMMON  /XNSTRN/  XNS(1)        
      COMMON  /ZZZZZZ/  XNS(1)        
      COMMON  /SDCOMX/  ROW     ,C       ,SPFLG   ,START   ,FRSTPC  ,   
     1                  LASTPL  ,LASTI   ,SC      ,IAC     ,NZZADR  ,   
     2                  WA      ,WB      ,PREVC   ,NZZZ    ,SPROW   ,   
     3                  S       ,BLK(15) ,ABLK(15),BBLK(20)        
      COMMON  /PACKX /  ITYPE1  ,ITYPE2  ,I1      ,J1      ,INCR1       
      COMMON  /UNPAKX/  ITYPE3  ,I2      ,J2      ,INCR2        
      EQUIVALENCE       (NROW,DBA(3)) ,(FORMA,DBA(4)) ,(TYPEA,DBA(5) ) ,
     1                  (JSTR,BLK(5)) ,(COL  ,BLK(4)) ,(NTERMS,BLK(6)) ,
     2                  (XDNS(1),XNS(1)),(ROW,KEY(1)) ,(DSR  ,DDR    ) ,
     3                  (RS  ,RD    ) ,(DSC  ,DDC   ) ,(MINDS,MINDD  )  
      EQUIVALENCE       (KSYSTM( 1),SYSBUF)  ,(KSYSTM( 2),NOUT       ) ,
     1                  (KSYSTM(28),CONFIG)  ,(KSYSTM(40),NBPW       ) ,
     2                  (KSYSTM(57),STATFL)  ,(DBNAME( 1),SUBNAM(4)  )  
      DATA     SUBNAM/  4HSDCO,2HMP,3*1H   / ,        
     1         NKEY  /  6 / ,  BEGN/  4HBEGN/ , END   / 4HEND  /      , 
     2         TWO24 /  16777216   /, TWO25 /   33554432       /        
      DATA     IREAL ,  ICMPLX     /  4HREAL,   4H    , 4HCOMP, 4HLEX / 
      DATA     UNUSE ,  ADDI       / '    UNUSED',    'ADDITIONAL'    / 
C        
C     STATEMENT FUNCTIONS        
C        
      NBRWDS(I) = I + NWDS*(I*(I+1))/2        
      SX(X)     = X - SQRT(AMAX1(X*(X+2.) + CMAX*4. - CONS, 1.)) - 1.0  
      MAXC(J)   = SQRT(FLOAT(2*J)/FNWDS - FLOAT(4*CMAX)) - 1.0        
C        
C     BUFFER ALLOCATION        
C        
      BUF1 = LCORE- SYSBUF        
      BUF2 = BUF1 - SYSBUF        
      BUF3 = BUF2 - SYSBUF        
      BUF4 = BUF3 - SYSBUF        
      BUF5 = BUF4 - SYSBUF        
      X    = 1.0        
      RKHR = 1.0E-10        
C        
C     INITIALIZATION AS A FUNCTION OF TYPE OF A MATRIX        
C     RC   = 1 IF A IS REAL, 2 IF A IS COMPLEX        
C     PREC = 1 IF A IS SINGLE, 2 IF A IS DOUBLE        
C     NOTE - PRC(1) = 1, PRC(2) = 2, AND        
C            PRC(3) = WORDS(1) = 1, PRC(4) = WORDS(2) = 2        
C        
      RC = RLCMPX(TYPEA)        
      MTYPE(1) = IREAL(1)        
      MTYPE(2) = IREAL(2)        
      IF (RC .EQ. 1) GO TO 10        
      MTYPE(1) = ICMPLX(1)        
      MTYPE(2) = ICMPLX(2)        
   10 PREC  = PRC(TYPEA)        
      NWDS  = WORDS(TYPEA)        
      FNWDS = NWDS        
      STURM = 0        
C        
C     CHECK INPUT PARAMETERS        
C        
      IF (DBA(2) .NE. DBA(3)) GO TO 2300        
      ICRQ = 100 - BUF5        
      IF (BUF5 .LT. 100) GO TO 2310        
      IF (NROW .EQ.   1) GO TO 1900        
C        
C     GENERAL INITIALIZATION        
C        
      LOOP   = 1        
      ISPILL = BUF5 - MAX0(100,NROW/100)        
      FCMAX  = 0.        
   20 ISPILL = ISPILL - (LOOP-1)*NROW/100        
      NSPILL = ISPILL        
      KROW   = NROW + 1        
      ICRQ   =-ISPILL        
      IF (ISPILL .LE. 0) GO TO 2310        
      ZI(ISPILL) = 0        
      PCGROU = 0        
      PCAVG  = 0        
      PCSQR  = 0        
      PCMAX  = 0        
      CSQR   = 0.0        
      SAVG   = 0        
      CLOS   = ALOG(FLOAT(NROW)) + 5.0        
      CLOS   = 999999        
      PCROW  = -CLOS        
      ZI(1)  = -NROW        
      ICRQ   = NROW - BUF5        
      IF (NROW .GE. BUF5) GO TO 2310        
      DO 30 I = 2,NROW        
   30 ZI(I)  = 0        
      CALL FNAME (DBA,DBNAME)        
      POWER  = 0        
      SCRA   = SCR3        
      SCRB   = IABS(DBC(1))        
      GO     =.TRUE.        
      SPILL  =.FALSE.        
      TIME   = 0.        
      GROUPS = 0        
      CMAX   = 0        
      CONS   = 2*ISPILL/NWDS        
      C5MAX  = MAXC(ISPILL)        
      DSR    = 1.0        
      DSC    = 0.        
      MINDS  = 1.E+25        
      IF (PREC .EQ. 1) GO TO 40        
      DDR    = 1.0        
      DDC    = 0.D0        
      MINDD  = 1.D+25        
   40 CONTINUE        
      CAVG   = 0        
      CSPILL = 0.        
C        
C     THE FOLLOWING CODE GENERATES THE ACTIVE COLUMN VECTOR FOR EACH    
C     ROW, SPILL GROUPS AND TIMING AND USER INFORMATION ABOUT THE       
C     DECOMPOSITION        
C        
      BLK(1)  = DBA(1)        
      ABLK(1) = SCRA        
      ABLK(2) = TYPEA        
      ABLK(3) = 0        
      CALL GOPEN ( DBA,ZI(BUF1),RDREW)        
      CALL GOPEN (SCRA,ZI(BUF2),WRTREW)        
      JLIST = 1        
      ROW   = 1        
      JJ    = 0        
      KK    = 0        
      NLIST = 0        
C        
C     BEGIN A ROW BY LOCATING THE DIAGONAL ELEMENT        
C        
   50 BLK(8) = -1        
      KR = KROW        
   60 CALL GETSTR (*70,BLK)        
      IF (PREC .EQ. 2) JSTR = 2*(JSTR-1) + 1        
      IF (COL .GT. ROW) GO TO 70        
      IF (COL+NTERMS-1 .GE. ROW) GO TO 90        
      CALL ENDGET (BLK)        
      GO TO 60        
   70 KK = KK + 1        
      ZI(KK) = ROW        
      GO = .FALSE.        
   80 IF (BLK(8) .NE. 1) CALL SKPREC (BLK,1)        
      ROW = ROW + 1        
      IF (ROW .LE. NROW) GO TO 50        
      GO TO 600        
C        
C     DIAGONAL TERM IS LOCATED - COMPLETE ENTRIES IN THE FULL COLUMN    
C     VECTOR AND SAVE THE TERMS FROM EACH STRING IN CORE        
C        
   90 IF (.NOT. GO) GO TO 80        
      JSTR   = JSTR + (ROW-COL)*NWDS        
      NTERMS = NTERMS - (ROW-COL)        
      COL  = ROW        
  100 ZI(KR  ) = COL        
      ZI(KR+1) = NTERMS        
      KR   = KR + 2        
      NSTR = JSTR + NTERMS*NWDS - 1        
      DO 110 JJ = JSTR,NSTR        
      ZR(KR) = XNS(JJ)        
      KR = KR + 1        
  110 CONTINUE        
      N = COL + NTERMS - 1        
      DO 170 J = COL,N        
      IF (ZI(J)) 120,130,160        
  120 M = IABS(ZI(J))        
      ZI(J) = ROW        
      IF (M .NE. 1) ZI(J+1) = -(M-1)        
      GO TO 170        
  130 I = J        
  140 I = I - 1        
      IF (I .LE. 0) GO TO 2000        
      IF (ZI(I)) 150,140,2010        
  150 M = IABS(ZI(I))        
      ZI(I) = -(J-I)        
      ZI(J) = ROW        
      LEFT  = M - (J-I+1)        
      IF (LEFT .GT. 0) ZI(J+1) = -LEFT        
      GO TO 170        
  160 IF (ZI(J).GT.ROW .AND. ZI(J).LT.TWO24) ZI(J) = ZI(J) +TWO24 +TWO25
  170 CONTINUE        
      ICRQ = KR - ISPILL        
      IF (KR .GE. ISPILL) GO TO 2310        
      CALL ENDGET (BLK)        
      CALL GETSTR (*180,BLK)        
      IF (PREC .EQ. 2) JSTR = 2*JSTR - 1        
      GO TO 100        
C        
C     EXTRACT ACTIVE COLUMN VECTOR FROM THE FULL COLUMN VECTOR        
C        
  180 IAC = KR        
      I   = IAC        
      J   = ROW        
      LASTPL = -1        
  190 IF (ZI(J)    ) 260,2020,200        
  200 IF (ZI(J)-ROW) 210,220,250        
  210 ZI(I) = J        
      GO TO 230        
  220 ZI(I) = -J        
      IF (LASTPL .LT. 0) LASTPL = I - IAC        
  230 I = I + 1        
  240 J = J + 1        
      GO TO 270        
  250 IF (ZI(J) .LT. TWO24) GO TO 240        
      IF (ZI(J) .LT. TWO25) GO TO 210        
      ZI(J) = ZI(J) - TWO25        
      GO TO 220        
  260 J = J - ZI(J)        
  270 IF (J .LE. NROW) GO TO 190        
      ICRQ = I - ISPILL        
      IF (I .GT. ISPILL) GO TO 2310        
      C = I - IAC        
      CMAX  = MAX0(CMAX,C)        
      C5MAX = MAXC(ISPILL)        
      NAC   = IAC + C - 1        
      IF (LASTPL .LT. 0) LASTPL = C        
C        
C     MAKE SPILL CALCULATIONS        
C        
      SPFLG = 0        
      FC    = C        
      START = 2        
      IF (C .EQ. 1) START = 0        
      FRSTPC = 0        
      IF (.NOT.SPILL) GO TO 370        
      IF (ROW .LT. LSTROW) GO TO 290        
C        
C     *3* CURRENT ROW IS LAST ROW OF A SPILL GROUP. DETERMINE IF ANOTHER
C         SPILL GROUP FOLLOWS AND, IF SO, ITS RANGE        
C        
  280 CONTINUE        
      START = 0        
      IF (C .GT. C5MAX) GO TO 380        
      SPILL = .FALSE.        
      GO TO 420        
C        
C     *2* CURRENT ROW IS NEITHER FIRST NOR LAST IN CURRENT SPILL GROUP. 
C         TEST FOR PASSIVE COL CONDITION. IF SO, TERMINATE SPILL GROUP. 
C         TEST FOR POSSIBLE REDEFINITION OF SPILL GROUP. IF SO, TEST FOR
C         OVERFLOW OF REDEFINITION TABLE,  IF SO, TRY A DIFFERENT       
C         STRATEGY FOR DEFINING S AND REDO PREFACE UP TO A LIMIT OF 3   
C         TIMES.        
C        
  290 CONTINUE        
      IF (IABS(ZI(IAC+1))-ROW .LT. CLOS) GO TO 300        
      ASSIGN 430 TO ISWTCH        
      LSTROW = ROW        
      SPILL  = .FALSE.        
      START  = 0        
      IF (NSPILL+2 .LT. BUF5) GO TO 350        
      GO TO 330        
  300 ASSIGN 460 TO ISWTCH        
      IF (C .LE. ZI(SPROW)) GO TO 460        
      JJ = NAC        
  310 IF (IABS(ZI(JJ)) .LE. LSTROW) GO TO 320        
      JJ = JJ - 1        
      GO TO 310        
  320 SC = JJ - IAC        
      M  = SX(FC)        
      IF (SC .LE. M) GO TO 460        
      IF (NSPILL+2 .LT. BUF5) GO TO 340        
  330 CONTINUE        
      FCMAX = AMAX1(FCMAX,FLOAT(CMAX))        
      CALL CLOSE (SCRA,REW)        
      CALL CLOSE ( DBA,REW)        
      LOOP = LOOP + 1        
      IF (LOOP .LE. 3) GO TO 20        
      ICRQ = BUF5 - NSPILL - 2        
      GO TO 2310        
  340 S = M        
      IJKL =  MAX0(IAC,JJ-(SC-M))        
      LSTROW = IABS(ZI(IJKL))        
  350 IF (ZI(NSPILL).NE.0 .AND. ZI(NSPILL).NE.SPROW) NSPILL = NSPILL + 3
      ZI(NSPILL  ) = SPROW        
      ZI(NSPILL+1) = S        
      ZI(NSPILL+2) = LSTROW        
      IF (ROW- LSTROW) 360,280,2070        
  360 CONTINUE        
      GO TO ISWTCH, (430,460)        
C        
C     *1* CURRENT ROW IS NOT PART OF A SPILL GROUP. TEST FOR CREATION OF
C         A NEW SPILL GROUP        
C        
  370 CONTINUE        
      IF (C .LE. C5MAX) GO TO 420        
  380 SPILL  = .TRUE.        
      SPROW  = ROW        
      GROUPS = GROUPS + 1        
      S  = MIN0(SX(FC),NROW-SPROW)        
      IF (LOOP .EQ. 1) GO TO 410        
      JJ = IAC + S - 1        
  390 IF (IABS(ZI(JJ)) .LE. SPROW+S) GO TO 400        
      JJ = JJ - 1        
      GO TO 390        
  400 S  = JJ - IAC + 1        
      IF (LOOP .EQ. 3) S = MIN0(S,SX(FCMAX))        
  410 S  = MIN0(S,NROW-SPROW)        
      LSTROW = IABS(ZI(IAC+S-1))        
      SPFLG  = S        
      FRSTPC = LSTROW        
      SAVG   = SAVG + S        
      GO TO 460        
C        
C     TEST FOR CONDITION IN WHICH PASSIVE COLUMNS ARE CREATED        
C        
  420 COL = IABS(ZI(IAC+1))        
      IF (ROW-PCROW.LT.CLOS .OR. C.LT.CLOS/2 .OR. COL-ROW.LT.CLOS)      
     1    GO TO 460        
C        
C     CREATE PASSIVE COLUMNS BY CHANGING THEIR FIRST        
C     APPEARANCE IN THE FULL COLUMN VECTOR        
C        
  430 FRSTPC = 2        
      PCROW  = ROW        
      PCAVG  = PCAVG + C - 1        
      PCSQR  = PCSQR + (C-1)**2        
      PCMAX  = MAX0(PCMAX,C-1)        
      PCGROU = PCGROU + 1        
      NAC    = IAC + C - 1        
      IJKL   = IAC + 1        
      DO 450 I = IJKL,NAC        
      JJ     = IABS(ZI(I))        
      IF (ZI(JJ) .LE. ROW) GO TO 440        
      ZI(JJ) = MIN0(ANDF(ZI(JJ),TWO24-1),COL)        
      GO TO 450        
  440 ZI(JJ) = COL        
  450 CONTINUE        
C        
C     WRITE ACTIVE COLUMN VECTOR        
C        
  460 CONTINUE        
      CALL WRITE (SCRA,KEY,NKEY,0)        
      CALL WRITE (SCRA,ZI(IAC),C,1)        
C        
C     WRITE ROW OF INPUT MATRIX        
C        
      ABLK( 8) = -1        
      ABLK(12) = ROW        
      KR = KROW        
  470 ABLK(4) = ZI(KR  )        
      NBRSTR  = ZI(KR+1)        
      KR = KR + 2        
  480 CALL PUTSTR (ABLK)        
      ABLK(7) = MIN0(ABLK(6),NBRSTR)        
      JSTR = ABLK(5)        
      IF (PREC .EQ. 2) JSTR = 2*JSTR - 1        
      NSTR = JSTR + ABLK(7)*NWDS - 1        
      DO 490 JJ = JSTR,NSTR        
      XNS(JJ) = ZR(KR)        
      KR = KR + 1        
  490 CONTINUE        
      IF (KR .GE. IAC) GO TO 500        
      CALL ENDPUT (ABLK)        
      IF (ABLK(7) .EQ. NBRSTR) GO TO 470        
      ABLK(4) = ABLK(4) + ABLK(7)        
      NBRSTR  = NBRSTR  - ABLK(7)        
      GO TO 480        
  500 ABLK(8) = 1        
      CALL ENDPUT (ABLK)        
C        
C     ACCUMULATE TIMING AND STATISTICS INFORMATION        
C        
      CAVG = CAVG + C        
      CSQR = CSQR + C**2        
      IF (SPILL) CSPILL = CSPILL + C**2        
      ZI(ROW) = C        
      IF (ROW .EQ. NROW) GO TO 600        
      ROW = ROW + 1        
      GO TO 50        
C        
C     HERE WHEN ALL ROWS PROCESSED - CLOSE FILES AND, IF SINGULAR       
C     MATRIX, PRINT SINGULAR COLUMNS AND GIVE ALTERNATE RETURN        
C        
  600 CALL CLOSE (SCRA,REW)        
      CALL CLOSE ( DBA,REW)        
      IF (GO) GO TO 620        
      CALL CLOSE (DBL,REW)        
      CALL PAGE2 (3)        
      WRITE  (NOUT,610) UFM,DBNAME,(ZI(I),I=1,KK)        
  610 FORMAT (A23,' 3097. SYMMETRIC DECOMPOSITION OF DATA BLOCK ',2A4,  
     1       ' ABORTED BECAUSE THE FOLLOWING COLUMNS ARE SINGULAR -',   
     2       /,(5X,20I6,/))        
      RETURN 1        
C        
C     CALCULATE TIME ESTIMATE, PRINT USER INFORMATION AND        
C     CHECK FOR SUFFICIENT TIME TO COMPLETE DECOMPOSITION        
C        
  620 DENS  = FLOAT(DBA(7))/10000.        
      IF (DENS .LT.  0.01) DENS =  0.01        
      IF (DENS .GT. 99.99) DENS = 99.99        
      IF (GROUPS .NE.  0) SAVG = SAVG/GROUPS        
      SAVG  = MAX0(SAVG,1)        
      TIME  = 0.5*TMT(TYPEA)*CSQR + 0.5*(TMPSTR+TMGSTR)*FLOAT(PCSQR) +  
     1        TMPSTR*FLOAT(CAVG)  + TMIO*(FNWDS+1.0)*CSPILL/FLOAT(SAVG) 
      MORCOR= NBRWDS(CMAX) - ISPILL + 1        
C        
      CAVG  = CAVG/NROW        
      IF (PCGROU .NE. 0) PCAVG = PCAVG/PCGROU        
      CALL TMTOGO (IJKL)        
      JKLM  = 1.E-6*TIME + 1.0        
      ICORE = IABS(MORCOR)        
      IF (DBC(1) .LE. 0) GO TO 645        
      UNADD = UNUSE        
      IF (MORCOR .GT. 0) UNADD = ADDI        
      CALL PAGE2 (4)        
      WRITE (NOUT,630,ERR=645) UIM, MTYPE, DBNAME, NROW,   DENS,        
     1                        JKLM, CAVG,   PCAVG, GROUPS, SAVG,        
     2                UNADD, ICORE, CMAX,   PCMAX, PCGROU, LOOP        
  630 FORMAT (A29,' 3023 - PARAMETERS FOR ',2A4,        
     1        ' SYMMETRIC DECOMPOSITION OF DATA BLOCK ',2A4,        
     2         5H (N =,I6, 5H, D =,F6.2,2H%), /14X,        
     3        17H  TIME ESTIMATE = , I7, 17H          C AVG = , I6,     
     4        17H         PC AVG = , I6,18H    SPILL GROUPS = , I6,     
     5        17H          S AVG = , I6,      /14X,        
     6        A10 ,      7H CORE = , I9,   15H WORDS  C MAX = , I6,     
     7        17H          PCMAX = , I6,18H       PC GROUPS = , I6,     
     8        17H  PREFACE LOOPS = , I6 )        
      IF (MORCOR .GT. 0) WRITE (NOUT,640)        
  640 FORMAT (14X,'(FOR OPTIMAL OPERATION)')        
  645 IF (JKLM .GE. IJKL) GO TO 2320        
C        
C     WRITE A END-OF-MATRIX STRING ON THE PASSIVE COLUMN FILE        
C        
      CALL GOPEN (SCRB,ZI(BUF2),WRTREW)        
      BBLK(1) = SCRB        
      BBLK(2) = TYPEA        
      BBLK(3) = 0        
      BBLK(8) =-1        
      BBLK(12)= 1        
      CALL PUTSTR(BBLK)        
      BBLK(4) = NROW + 1        
      BBLK(7) = 1        
      BBLK(8) = 1        
      CALL ENDPUT (BBLK)        
      CALL CLOSE  (SCRB,REW)        
      SUBNAM(3) = BEGN        
      CALL CONMSG (SUBNAM,5,0)        
C        
C     THE STAGE IS SET AT LAST TO PERFORM THE DECOMPOSITION -        
C     SO LETS GET THE SHOW UNDERWAY        
C        
      CALL GOPEN (SCRA,ZI(BUF1),RDREW )        
      CALL GOPEN (SCRB,ZI(BUF2),RDREW )        
      CALL GOPEN (DBL ,ZI(BUF3),WRTREW)        
      SCRC   = SCR1        
      SCRD   = SCR2        
      IF (ZI(NSPILL) .NE. 0) NSPILL = NSPILL + 3        
      ZI(NSPILL) = NROW + 1        
      SPLIN  = .FALSE.        
      SPLOUT = .FALSE.        
      SPILL  = .FALSE.        
      IF (GROUPS .NE. 0) SPILL = .TRUE.        
      NZZZ   = ORF(ISPILL-1,1)        
      ROWONE = .FALSE.        
      DBL(2) = 0        
      DBL(6) = 0        
C     DBL(7) = LSHIFT(1,NBPW-2)        
      DBL(7) = LSHIFT(1,NBPW-2 - (NBPW-32))        
C        
C     THIS 'NEXT TO SIGN' BIT WILL BE PICKED UP BY WRTTRL. ADD (NBPW-32)
C     SO THAT CRAY, WITH 48-BIT INTEGER, WILL NOT GET INTO TROUBLE      
C        
      BLK(1) = DBL(1)        
      BLK(2) = TYPEA        
      BLK(3) = 1        
      WA     = NZZZ        
      WB     = WA        
      PREVC  = 0        
      BBLK(8)= -1        
      CALL GETSTR (*2080,BBLK)        
      KSPILL = ISPILL        
C        
C     READ KEY WORDS AND ACTIVE COLUMN VECTOR FOR CURRENT ROW        
C        
  650 NAME = SCRA        
      IF (SPLIN) NAME = SCRD        
      CALL FREAD (NAME,KEY,NKEY,0)        
      IAC = C*NWDS + 1        
      CALL FREAD (NAME,ZI(IAC),C,1)        
      NAC = IAC + C - 1        
      IF (ZI(IAC) .LT. 0) PREVC = 0        
      IF (SPLIN) GO TO 700        
C        
C     READ TERMS FROM THE INPUT MATRIX        
C        
      ABLK(8) = -1        
      CALL GETSTR (*2090,ABLK)        
      N = IAC - 1        
      DO 670 I = 1,N        
      ZR(I) = 0.        
  670 CONTINUE        
      CALL SDCIN (ABLK,ZI(IAC),C,ZR,ZR)        
C        
C     IF DEFINED, MERGE ROW FROM PASSIVE COLUMN FILE        
C        
  680 IF (ROW-BBLK(4)) 710,690,2100        
  690 CALL SDCIN (BBLK,ZI(IAC),C,ZR,ZR)        
      BBLK(8) = -1        
      CALL GETSTR (*2110,BBLK)        
      GO TO 680        
C        
C     READ CURRENT PIVOT ROW FROM SPILL FILE. IF LAST ROW, CLOSE FILE   
C        
  700 PREVC = 0        
      CALL FREAD (SCRD,ZR,C*NWDS,1)        
      IF (ROW .LT. LSTSPL) GO TO 710        
      CALL CLOSE (SCRD,REW)        
C        
C     IF 1ST ROW OF A NEW SPILL GROUP, OPEN SCRATCH FILE TO WRITE       
C        
  710 IF (ROWONE) GO TO 740        
      IF (SPLOUT) GO TO 810        
      IF (SPFLG .EQ. 0) GO TO 810        
      SPLOUT = .TRUE.        
      CALL GOPEN (SCRC,ZI(BUF4),WRTREW)        
      SPROW  = ROW        
      S      = SPFLG        
      LSTROW = FRSTPC        
      FRSTPC = 0        
C        
C     IF S WAS REDEFINED, GET NEW DEFINITION        
C        
      DO 720 I = KSPILL,NSPILL,3        
      IF (ROW-ZI(I)) 740,730,720        
  720 CONTINUE        
      GO TO 740        
  730 S = ZI(I+1)        
      LSTROW = ZI(I+2)        
      KSPILL = I + 3        
C        
C     WRITE ANY TERMS ALREADY CALCULATED WHICH ARE        
C     BEYOND THE RANGE OF THE CURRENT SPILL GROUP        
C        
  740 IF (.NOT.SPLOUT) GO TO 810        
      N    = 0        
      IJKL = NAC        
  750 IF (IABS(ZI(IJKL)) .LE. LSTROW) GO TO 760        
      IJKL = IJKL - 1        
      GO TO 750        
  760 IJKL = IJKL + 1        
      IF (IJKL .GT. NAC) GO TO 780        
      DO 770 I = IJKL,NAC        
      IF (ZI(I) .GT. 0.) N = N + 1        
  770 CONTINUE        
      N = NWDS*N*(N+1)/2        
  780 CALL WRITE (SCRC,N,1,0)        
      CALL WRITE (SCRC,ZR(NZZZ-N),N,1)        
C        
C     MOVE WA TO ACCOUNT FOR ANY TERMS JUST WRITTEN        
C        
      IF (N .EQ. 0) GO TO 810        
      J = NZZZ        
      I = NZZZ - N        
      IF (NZZZ-WA .EQ. N) GO TO 800        
  790 J = J - 1        
      I = I - 1        
      ZR(J) = ZR(I)        
      IF (I .GT. WA) GO TO 790        
  800 WA = J        
C        
C     IF THE PIVOTAL ROW DID NOT COME FROM THE SPILL FILE, IT IS CREATED
C        
  810 IF (SPLIN) GO TO 1110        
      I = IAC        
      L = WA        
      IF (PREC .EQ. 2) L = (WA-1)/2 + 1        
      GO TO (820,890,960,1030), TYPEA        
C        
C     CREATE PIVOT ROW IN RSP, ACCUMULATE DETERMINANT AND MIN DIAGONAL  
C        
  820 CONTINUE        
      IF (ZI(IAC) .LT. 0) GO TO 850        
      DO 840 J = 1,C        
      IF (ZI(I) .LT. 0) GO TO 830        
      ZR(J) = ZR(J) + ZR(L)        
      L = L + 1        
  830 I = I + 1        
  840 CONTINUE        
  850 CONTINUE        
      ASSIGN 860 TO KHR        
      IF (ZR(1)) 860,1820,860        
  860 IF (ABS(DSR) .LT. 10.) GO TO 870        
      DSR   = DSR/10.        
      POWER = POWER + 1        
      GO TO 860        
  870 IF (ABS(DSR) .GT. 0.1) GO TO 880        
      DSR   = DSR*10.        
      POWER = POWER - 1        
      GO TO 870        
  880 DSR   = DSR*ZR(1)        
      MINDS = AMIN1(ABS(ZR(1)),MINDS)        
C        
C     COUNTING SIGN CHANGES OF THE LEADING PRINCIPLE MINORS IN STURM    
C     SEQ.        
C        
      IF (ZR(1) .LT. 0.) STURM = STURM + 1        
      GO TO 1100        
C        
C     CREATE PIVOT ROW IN RDP, ACCUMULATE DETERMINANT AND MIN DIAGONAL  
C        
  890 CONTINUE        
      IF (ZI(IAC) .LT. 0) GO TO 920        
      DO 910 J = 1,C        
      IF (ZI(I) .LT. 0) GO TO 900        
      ZD(J) = ZD(J) + ZD(L)        
      L = L + 1        
  900 I = I + 1        
  910 CONTINUE        
  920 CONTINUE        
      ASSIGN 930 TO KHR        
      IF (ZD(1)) 930,1820,930        
  930 IF (DABS(DDR) .LT. 10.0D0) GO TO 940        
      DDR   = DDR/10.D0        
      POWER = POWER + 1        
      GO TO 930        
  940 IF (DABS(DDR) .GT. 0.1D0) GO TO 950        
      DDR   = DDR*10.D0        
      POWER = POWER - 1        
      GO TO 940        
  950 DDR   = DDR*ZD(1)        
      MINDD = DMIN1(DABS(ZD(1)),MINDD)        
C        
C     COUNTING SIGN CHANGES (STURM SEQUENCE PROPERTY)        
C        
      IF (ZD(1) .LT. 0.D0) STURM = STURM + 1        
      GO TO 1100        
C        
C     CREATE PIVOT ROW IN CSP, ACCUMULATE DETERMINANT AND MIN DIAGONAL  
C        
  960 CONTINUE        
      IF (ZI(IAC) .LT. 0) GO TO 990        
      CI = 2*C - 1        
      DO 980 J = 1,CI,2        
      IF (ZI(I) .LT. 0) GO TO 970        
      ZR(J  ) = ZR(J  ) + ZR(L  )        
      ZR(J+1) = ZR(J+1) + ZR(L+1)        
      L = L + 2        
  970 I = I + 1        
  980 CONTINUE        
  990 CONTINUE        
      SAVE(3) = SQRT(ZR(1)**2 + ZR(2)**2)        
      IF (SAVE(3)) 1000,1840,1000        
 1000 IF (SQRT(DSR**2+DSC**2) .LT. 10.) GO TO 1010        
      DSR = DSR/10.        
      DSC = DSC/10.        
      POWER = POWER + 1        
      GO TO 1000        
 1010 IF (SQRT(DSR**2+DSC**2) .GT. 0.1) GO TO 1020        
      DSR = DSR*10.        
      DSC = DSC*10.        
      POWER = POWER - 1        
      GO TO 1010        
 1020 RS  = DSR*ZR(1) - DSC*ZR(2)        
      DSC = DSR*ZR(2) + DSC*ZR(1)        
      DRR = RS        
      MINDS = AMIN1(SAVE(3),MINDS)        
      GO TO 1100        
C        
C     CREATE PIVOT ROW IN CDP, ACCUMULATE DETERMINANT AND MIN DIAGONAL  
C        
 1030 CONTINUE        
      IF (ZI(IAC) .LT. 0) GO TO 1060        
      CI = 2*C - 1        
      DO 1050 J = 1,CI,2        
      IF (ZI(I) .LT. 0) GO TO 1040        
      ZD(J  ) = ZD(J  ) + ZD(L  )        
      ZD(J+1) = ZD(J+1) + ZD(L+1)        
      L = L + 2        
 1040 I = I + 1        
 1050 CONTINUE        
 1060 CONTINUE        
C        
C     IN COMPARING THE SOURCE CODES HERE FOR CSP AND CDP COMPUTATION,   
C     IT IS DECIDED TO CHANGE THE ORIGINAL LINES (COMMENTED OUT) TO THE 
C     NEW LINES USING DSAVE3 INSTEAD OF RD       BY G.CHAN/UNISYS, 8/84 
C        
C     RD     = DSQRT(ZD(1)**2 + ZD(2)**2)        
      DSAVE3 = DSQRT(ZD(1)**2 + ZD(2)**2)        
C     IF (RD) 1275,1435,1275        
      IF (DSAVE3) 1070,1840,1070        
 1070 IF (DSQRT(DDR**2+DDC**2) .LT. 10.D0) GO TO 1080        
      DDR   = DDR/10.D0        
      DDC   = DDC/10.D0        
      POWER = POWER + 1        
      GO TO 1070        
 1080 IF (DSQRT(DDR**2+DDC**2) .GT. 0.1D0) GO TO 1090        
      DDR   = DDR*10.D0        
      DDC   = DDC*10.D0        
      POWER = POWER - 1        
      GO TO 1080        
 1090 RD    = DDR*ZD(1) - DDC*ZD(2)        
      DDC   = DDR*ZD(2) + DDC*ZD(1)        
      DDR   = RD        
C     MINDD = DMIN1(    RD,MINDD)        
      MINDD = DMIN1(DSAVE3,MINDD)        
C        
C     CALCULATE WB        
C        
 1100 CONTINUE        
 1110 LASTI = 1        
      IF (START .EQ. 0) GO TO 1250        
      IF (SPLIN ) GO TO 1120        
      IF (SPLOUT) GO TO 1130        
      CI = C        
      SC = C        
      GO TO 1160        
 1120 CI = C - (START-2)        
      SC = CI        
      JJ = NAC        
      IF (SPLOUT) GO TO 1140        
      IF ((CI*(CI+1)+2*C)*NWDS/2+C .GT. NZZZ) GO TO 2120        
      GO TO 1160        
 1130 CI = C        
      SC = LSTROW - SPROW        
      JJ = MIN0(NAC,IAC+START+SC-2)        
 1140 IF (IABS(ZI(JJ)) .LE. LSTROW) GO TO 1150        
      JJ = JJ - 1        
      GO TO 1140        
 1150 SC = JJ - IAC - START + 2        
      IF (SC .GT. 0) GO TO 1160        
      SC = 0        
      WB = WA        
      GO TO 1180        
 1160 NTERMS = SC*(CI-1) - (SC*(SC-1))/2        
      NWORDS = NTERMS*NWDS        
      WB = NZZZ - NWORDS        
      IF (PREC .EQ. 2) WB = ORF(WB-1,1)        
      IF (WB .LT. IAC+C) GO TO 2060        
      IF (WB .GT. WA+NWDS*PREVC) GO TO 2130        
 1180 CONTINUE        
      IF (SPLIN .AND. ROW.EQ.LSTSPL) SPLIN = .FALSE.        
      LASTI = MIN0(START+SC-1,C)        
      IF (SC .EQ. 0) GO TO 1250        
C        
C     NOW CALCULATE CONTRIBUTIONS FROM CURRENT PIVOT ROW TO SECOND TERM 
C     IN EQUATION (4) IN MEMO CWM-19. NOTE-TERMS ARE CALCULATED ONLY    
C     FOR ROW/COL COMBINATIONS IN THE CURRENT SPILL GROUP        
C        
      GO TO (1210,1220,1230,1240), TYPEA        
 1210 CALL SDCOM1 (ZI,ZI(IAC),ZR(WA+  PREVC),ZR(WB))        
      GO TO 1250        
 1220 CALL SDCOM2 (ZI,ZI(IAC),ZR(WA+2*PREVC),ZR(WB))        
      GO TO 1250        
 1230 CALL SDCOM3 (ZI,ZI(IAC),ZR(WA+2*PREVC),ZR(WB))        
      GO TO 1250        
 1240 CALL SDCOM4 (ZI,ZI(IAC),ZR(WA+4*PREVC),ZR(WB))        
C        
C     SHIP PIVOT ROW OUT TO EITHER MATRIX OR SPILL FILE        
C        
 1250 IF (LASTI .EQ. C) GO TO 1290        
      IF (.NOT. SPLOUT) GO TO 2030        
C        
C     PIVOT ROW GOES TO SPILL FILE - SET INDEX WHERE TO BEGIN NEXT AND  
C     WRITE ROW AND ACTIVE COLUMNN VECTOR        
C        
      IJKL   = SPFLG        
      II     = FRSTPC        
      SPFLG  = 0        
      FRSTPC = 0        
      START  = LASTI + 1        
      CALL WRITE (SCRC,KEY,NKEY, 0)        
      CALL WRITE (SCRC,ZI(IAC),C,1)        
      CALL WRITE (SCRC,ZR,C*NWDS,1)        
      IF (ROW .LT. LSTROW) GO TO 1440        
C        
C     LAST ROW OF CURRENT SPILL GROUP - REWIND FILE AND OPEN IT TO READ.
C     IF ANOTHER SPILL GROUP, SET IT UP        
C        
      CALL CLOSE (SCRC,REW)        
      JKLM   = SCRC        
      SCRC   = SCRD        
      SCRD   = JKLM        
      CALL GOPEN (SCRD,ZI(BUF5),RDREW)        
      LSTSPL = ROW        
      SPLIN  =.TRUE.        
      SPLOUT =.FALSE.        
      IF (IJKL .EQ. 0) GO TO 1280        
      SPLOUT =.TRUE.        
      SPROW  = ROW        
      S      = IJKL        
      LSTROW = II        
      CALL GOPEN (SCRC,ZI(BUF4),WRTREW)        
C        
C     IF S WAS REDEFINED, GET NEW DEFINITION        
C        
      DO 1260 I = KSPILL,NSPILL,3        
      IF (ROW-ZI(I)) 1280,1270,1260        
 1260 CONTINUE        
      GO TO 1280        
 1270 S = ZI(I+1)        
      LSTROW = ZI(I+2)        
      KSPILL = I + 3        
C        
C     READ ANY TERMS SAVED FROM PREVIOUS SPILL GROUP        
C        
 1280 IF (ROW .EQ. NROW) GO TO 1500        
      CALL FREAD (SCRD,N,1,0)        
      WA = NZZZ - N        
      CALL FREAD (SCRD,ZR(WA),N,1)        
      ROWONE = .TRUE.        
      GO TO 650        
C        
C     PIVOT ROW GOES TO OUTPUT FILE - IF REQUIRED, CONVERT TO CHOLESKY  
C        
 1290 IF (ROW .NE. DBL(2)+1) GO TO 2040        
      IF (CHLSKY .EQ. 0) GO TO 1340        
      IF (RC     .EQ. 2) GO TO 2050        
      IF (PREC   .EQ. 2) GO TO 1320        
      IF (ZR(1) .LT. 0.) GO TO 1800        
      ZR(1) = SQRT(ZR(1))        
      IF (C .EQ. 1) GO TO 1340        
      DO 1310 I = 2,C        
      ZR(I) = ZR(I)*ZR(1)        
 1310 CONTINUE        
      GO TO 1340        
 1320 IF (ZD(1) .LT. 0.0D+0) GO TO 1800        
      ZD(1) = DSQRT(ZD(1))        
      IF (C .EQ. 1) GO TO 1340        
      DO 1330 I = 2,C        
      ZD(I) = ZD(I)*ZD(1)        
 1330 CONTINUE        
C        
C     WRITE THE ROW WITH PUTSTR/ENDPUT        
C        
 1340 CALL SDCOUT (BLK,0,ZI(IAC),C,ZR,ZR)        
C        
C     IF ACTIVE COLUMNS ARE NOW GOING PASSIVE, MERGE ROWS IN CORE       
C     WITH THOSE NOW ON THE PC FILE THUS CREATING A NEW PC FILE        
C        
      IF (FRSTPC .EQ. 0) GO TO 1430        
      IF (SPLIN .OR. SPLOUT) GO TO 2140        
      CALL GOPEN (SCRC,ZI(BUF4),WRTREW)        
      BLK(1) = SCRC        
      BLK(3) = 0        
      IJKL = IAC + 1        
      DO 1390 I = IJKL,NAC        
 1360 IF (IABS(ZI(I)) .LE. BBLK(4)) GO TO 1380        
      CALL CPYSTR (BBLK,BLK,1,0)        
      BBLK(8) = -1        
      CALL GETSTR (*2150,BBLK)        
      GO TO 1360        
 1380 CI = NAC - I + 1        
      CALL SDCOUT (BLK,0,ZI(I),CI,ZR(WB),ZR(WB))        
      WB = WB + CI*NWDS        
 1390 CONTINUE        
      ICRQ = WB - ISPILL        
      IF (WB .GT. ISPILL) GO TO 2310        
 1400 CALL CPYSTR (BBLK,BLK,1,0)        
      IF (BBLK(4) .EQ. NROW+1) GO TO 1410        
      BBLK(8) = -1        
      CALL GETSTR (*2160,BBLK)        
      GO TO 1400        
 1410 CALL CLOSE (SCRB,REW)        
      CALL CLOSE (SCRC,REW)        
      I = SCRB        
      SCRB = SCRC        
      SCRC = I        
      CALL GOPEN (SCRB,ZI(BUF2),RDREW)        
      BBLK(1) = SCRB        
      BBLK(8) = -1        
      CALL GETSTR (*2170,BBLK)        
      BLK(1) = DBL(1)        
      BLK(3) = 1        
C        
C     ACCUMULATE MCB INFORMATION FOR PIVOT ROW        
C        
 1430 CONTINUE        
      NWORDS = C*NWDS        
      DBL(2) = DBL(2) + 1        
      DBL(6) = MAX0(DBL(6),NWORDS)        
      DBL(7) = DBL(7) + NWORDS        
C        
C     PREPARE TO PROCESS NEXT ROW.        
C        
 1440 IF (ROW .EQ. NROW) GO TO 1500        
      PREVC  = C - 1        
      ROWONE = .FALSE.        
      WA = WB        
      GO TO 650        
C        
C     CLOSE FILES AND PUT END MESSAGE IN RUN LOG.        
C        
 1500 SUBNAM(3) = END        
      CALL CONMSG (SUBNAM,5,0)        
      CALL CLOSE (SCRA,REW)        
      CALL CLOSE (SCRB,REW)        
      CALL CLOSE ( DBL,REW)        
C        
C     PRINT ROOTS INFORMATION IF THIS IS EIGENVALUE PROBLEM, AND KEEP   
C     TWO LARGEST SHIFT POINT DATA IF SEVERAL SHIFT POINT MOVINGS ARE   
C     INVOLVED.        
C        
      IF (SHFTPT .GT. 0.) WRITE (NOUT,1510) STURM,SHFTPT        
 1510 FORMAT (20X,I5,13H ROOTS BELOW ,1P,E14.6)        
      IF (STURM .NE. 0) GO TO 1520        
      IF (KEEP  .LE. 0) GO TO 1530        
      STURM  = KEEP        
      SHFTPT = PTSHFT        
      GO TO 1530        
 1520 IF (KEEP .GT. STURM) GO TO 1530        
      JJ     = KEEP        
      RS     = PTSHFT        
      KEEP   = STURM        
      PTSHFT = SHFTPT        
      STURM  = JJ        
      SHFTPT = RS        
 1530 IF (STATFL .NE. 1) RETURN        
C        
C     PREPARE AND PRINT STATISTICS REGARDING DECOMPOSITION        
C        
      IF (2*NROW .LT. BUF2) GO TO 1600        
      CALL PAGE2 (2)        
      WRITE  (NOUT,1540) UIM        
 1540 FORMAT (A29,' 2316. INSUFFICIENT CORE TO PREPARE DECOMPOSITION ', 
     1       'STATISTICS.')        
      RETURN        
C        
 1600 CALL GOPEN (SCRA,ZI(BUF1),RDREW)        
      CALL GOPEN ( DBL,ZI(BUF2),RDREW)        
      ABLK(1) = SCRA        
      BBLK(1) = DBL(1)        
      ROW = 1        
      DO 1610 I = 1,6        
      NULL(I) = 0        
 1610 CONTINUE        
      NN = 2*NROW - 1        
      EPSMAX = 0.        
      N  = 0        
      DO 1710 J = 1,NN,2        
      ABLK(8) = -1        
      BBLK(8) = -1        
      CALL FWDREC (*2220,ABLK)        
C1620 CONTINUE        
      CALL GETSTR (*2180,ABLK)        
C1630 CONTINUE        
      CALL GETSTR (*2190,BBLK)        
C1640 CONTINUE        
      IF (ABLK(4) .NE. ROW) GO TO 2200        
C1650 CONTINUE        
      IF (BBLK(4) .NE. ROW) GO TO 2210        
      II = ABLK(5)        
      JJ = BBLK(5)        
      GO TO (1660,1670,1680,1690), TYPEA        
 1660 SAVE(2) = XNS(II)        
      SAVE(3) = XNS(JJ)        
      GO TO 1700        
 1670 SAVE(2) = XDNS(II)        
      SAVE(3) = XDNS(JJ)        
      GO TO 1700        
 1680 SAVE(2) = SQRT(XNS(II)**2 + XNS(II+1)**2)        
      SAVE(3) = SQRT(XNS(JJ)**2 + XNS(JJ+1)**2)        
      GO TO 1700        
 1690 SAVE(2) = DSQRT(XDNS(II)**2 + XDNS(II+1)**2)        
      SAVE(3) = DSQRT(XDNS(JJ)**2 + XDNS(JJ+1)**2)        
 1700 CALL FWDREC (*2220,ABLK)        
      CALL FWDREC (*2220,BBLK)        
      EPS = ABS(SAVE(2)/SAVE(3))        
      ZI(J  ) = ROW        
      ZI(J+1) = EPS        
      IF (SAVE(3) .LT. 0.) N = N + 1        
      EPSMAX = AMAX1(EPSMAX,EPS)        
      ROW = ROW + 1        
 1710 CONTINUE        
      CALL SORT (0,0,2,2,ZI,2*NROW)        
      CALL CLOSE (ABLK,REW)        
      CALL CLOSE (BBLK,REW)        
      SAVE(1) = 0.1*EPSMAX        
      DO 1720 I = 2,6        
      SAVE(I) = 0.1*SAVE(I-1)        
 1720 CONTINUE        
      DO 1780 J = 1,NN,2        
      IF (ZR(J+1) .GT. SAVE(1)) GO TO 1730        
      IF (ZR(J+1) .GT. SAVE(2)) GO TO 1740        
      IF (ZR(J+1) .GT. SAVE(3)) GO TO 1750        
      IF (ZR(J+1) .GT. SAVE(4)) GO TO 1760        
      IF (ZR(J+1) .GT. SAVE(5)) GO TO 1770        
      NULL(6) = NULL(6) + 1        
      GO TO 1780        
 1730 NULL(1) = NULL(1) + 1        
      GO TO 1780        
 1740 NULL(2) = NULL(2) + 1        
      GO TO 1780        
 1750 NULL(3) = NULL(3) + 1        
      GO TO 1780        
 1760 NULL(4) = NULL(4) + 1        
      GO TO 1780        
 1770 NULL(5) = NULL(5) + 1        
 1780 CONTINUE        
      I = MAX0(1,NN-8)        
      CALL PAGE2 (6)        
      WRITE  (NOUT,1790) UIM,DBNAME,N,EPSMAX,(NULL(J),J=1,6),        
     1                   (ZI(J),J=I,NN,2)        
 1790 FORMAT (A29,' 2314. STATISTICS FOR SYMMETRIC DECOMPOSITION OF ',  
     1        'DATA BLOCK ',2A4,7H FOLLOW,        
     2        /10X,23HNUMBER OF UII .LT. 0 = ,I5,        
     3        /10X,36HMAXIMUM ABSOLUTE VALUE OF AII/UII = ,1P,E12.5,    
     4        /10X,13HN1 THRU N6 = ,6I6,        
     5        /10X,36HROW NUMBERS OF 5 LARGEST  AII/UII = ,6I6 )        
      RETURN        
C        
C     DIAGONAL ELEMENT .LT. 0.0 IN CHOLESKY DECOMPOSITION        
C        
 1800 WRITE  (NOUT,1810) UFM        
 1810 FORMAT (A23,' 3181, ATTEMPT TO PERFORM CHOLESKY DECOMPOSITION ON',
     1       ' A NEGATIVE DEFINITE MATRIX IN SUBROUTINE SDCOMP.')       
      GO TO 2330        
C        
C     DIAGONAL ELEMENT .EQ. 0.0        
C        
 1820 ZR(1) = RKHR        
      IF (TYPEA .EQ. 2) ZD(1) = RKHR        
      CALL PAGE2 (3)        
      WRITE  (NOUT,1830) UWM,ROW,RKHR        
 1830 FORMAT (A25,' 2396, SDCOMP COMPUTED A ZERO ON THE DIAGONAL DURING'
     1,      ' DECOMPOSITION AT ROW NUMBER',I6,1H., /5X,        
     2       'USE OF DIAG 22 OUTPUT SHOULD PERMIT YOU TO CORRELATE THE',
     3       ' ROW WITH A MODEL D.O.F.', /5X,'A VALUE OF ',E13.6,       
     4       ' WILL BE USED IN PLACE OF THE ZERO, HOWEVER', /5X,        
     5       ' THE ACCURACY OF THE DECOMPOSITION MAY BE IN DOUBT.')     
      GO TO KHR, (860,930)        
 1840 CALL CLOSE (SCRA,REW)        
      CALL CLOSE (SCRB,REW)        
      CALL CLOSE ( DBL,REW)        
      CALL CLOSE (SCRC,REW)        
      CALL CLOSE (SCRD,REW)        
      RETURN 1        
C        
C     DECOMPOSE A 1X1 MATRIX        
C        
 1900 ITYPE1 = TYPEA        
      ITYPE2 = TYPEA        
      ITYPE3 = TYPEA        
      POWER  = 0        
      I1     = 1        
      J1     = 1        
      I2     = 1        
      J2     = 1        
      INCR1  = 1        
      INCR2  = 1        
      KK     = 1        
      NULL(1)= 1        
      GO     =.FALSE.        
      CALL GOPEN  (DBA,ZI(BUF1),RDREW)        
      CALL UNPACK (*600,DBA,ZR)        
      CALL CLOSE  (DBA,REW)        
      CALL GOPEN  (DBL,ZI(BUF1),WRTREW)        
      DBL(2) = 0        
      DBL(6) = 0        
      GO TO (1910,1920,1930,1940), TYPEA        
 1910 MINDS = ZR(1)        
      DSR   = ZR(1)        
      IF (ZR(1)) 1950,600,1950        
 1920 MINDD = ZD(1)        
      DDR   = ZD(1)        
      IF (ZD(1)) 1950,600,1950        
 1930 MINDS = SQRT(ZR(1)**2 + ZR(2)**2)        
      DSR   = ZR(1)        
      DSC   = ZR(2)        
      IF (MINDS) 1950,600,1950        
 1940 MINDD = DSQRT(ZD(1)**2 + ZD(2)**2)        
      DDR   = ZD(1)        
      DDC   = ZD(2)        
      IF (MINDD) 1950,600,1950        
 1950 CALL PACK  (ZR,DBL,DBL)        
      CALL CLOSE (DBL,REW)        
      RETURN        
C        
C     VARIOUS ERRORS LAND HERE        
C        
 2000 KERR = 1045        
      GO TO  2230        
 2010 KERR = 1046        
      GO TO  2230        
 2020 KERR = 1051        
      GO TO  2230        
 2030 KERR = 1310        
      GO TO  2230        
 2040 KERR = 1320        
      GO TO  2230        
 2050 KERR = 1300        
      GO TO  2230        
 2060 KERR = 1288        
      GO TO  2230        
 2070 KERR = 1065        
      GO TO  2230        
 2080 KERR = 1204        
      GO TO  2230        
 2090 KERR = 660        
      GO TO  2230        
 2100 KERR = 1215        
      GO TO  2230        
 2110 KERR = 1216        
      GO TO  2230        
 2120 KERR = 1288        
      GO TO  2230        
 2130 KERR = 1170        
      GO TO  2230        
 2140 KERR = 1350        
      GO TO  2230        
 2150 KERR = 1370        
      GO TO  2230        
 2160 KERR = 1340        
      GO TO  2230        
 2170 KERR = 1420        
      GO TO  2230        
 2180 KERR = 1620        
      GO TO  2230        
 2190 KERR = 1630        
      GO TO  2230        
 2200 KERR = 1640        
      GO TO  2230        
 2210 KERR = 1650        
      GO TO  2230        
 2220 KERR = 1407        
      GO TO  2230        
 2230 WRITE  (NOUT,2240) SFM,KERR        
 2240 FORMAT (A25,' 3130, LOGIC ERROR',I6,' OCCURRED IN SDCOMP.')       
      J = 66        
      WRITE  (NOUT,2250) (KEY(I),I=1,J)        
 2250 FORMAT (36H0   CONTENTS OF / SDCOMX / FOLLOW -- ,/(1X,10I12))     
      GO TO 2330        
C        
C     ERROR EXITS        
C        
 2300 IER = -7        
      IFL = 0        
      GO TO 2340        
 2310 IER = -8        
      IFL = ICRQ        
      GO TO 2340        
 2320 IER = -50        
      IFL = JKLM        
      GO TO 2340        
 2330 IER = -37        
      IFL = 0        
 2340 CALL MESAGE (IER,IFL,SUBNAM)        
      RETURN        
      END        
C        
C     THIS ROUTINE WAS RENUMBERED IN AUG. 1992        
C        
C                    TABLE OF OLD vs. NEW STATEMENT NUMBERS        
C        
C     OLD NO.    NEW NO.      OLD NO.    NEW NO.      OLD NO.    NEW NO.
C    --------------------    --------------------    -------------------
C       1000         10         1224        770         1380       1500 
C       1002         20         1226        780         1385       1510 
C       1006         30         1225        790         1390       1520 
C       1018         40         1227        800         1395       1530 
C       1030         50         1230        810         1402       1540 
C       1032         60         1240        820         1404       1600 
C       1034         70         1243        830         1405       1610 
C       1036         80         1244        840        14051      -1620 
C       1040         90         1242        850        14052      -1630 
C       1041        100         1245        860        14053      -1640 
C       1042        110         1246        870        14054      -1650 
C       1043        120         1248        880        14061       1660 
C       1044        130         1250        890        14062       1670 
C       1045        140         1253        900        14063       1680 
C       1046        150         1254        910        14064       1690 
C       1047        160         1252        920         1407       1700 
C       1049        170         1255        930         1408       1710 
C       1050        180         1256        940         1410       1720 
C       1051        190         1258        950         1411       1730 
C       1052        200         1260        960         1412       1740 
C       1053        210         1263        970         1413       1750 
C       1054        220         1264        980         1414       1760 
C       1055        230         1262        990         1415       1770 
C       1056        240         1265       1000         1419       1780 
C       1059        250         1266       1010         1422       1790 
C       1057        260         1268       1020         1425       1800 
C       1058        270         1270       1030        25000       1810 
C       1061        280         1273       1040         1430       1820 
C       1062        290         1274       1050        20000       1830 
C      10622        300         1272       1060         1435       1840 
C       1063        310         1275       1070         1440       1900 
C       1064        320         1276       1080         1441       1910 
C      10642        330         1278       1090         1442       1920 
C       1065        340         1280       1100         1443       1930 
C      10652        350         1281       1110         1444       1940 
C      10653        360         1282       1120         1446       1950 
C       1066        370         1284       1130         9001       2000 
C       1067        380         1285       1140         9002       2010 
C      10672        390         1286       1150         9003       2020 
C      10674        400         1288       1160         9004       2030 
C      10676        410         1289      -1170         9005       2040 
C       1070        420         1287       1180         9006       2050 
C       1072        430         1300      -1200         9007       2060 
C       1073        440         1301       1210         9009       2070 
C       1076        450         1302       1220         9011       2080 
C       1080        460         1303       1230         9012       2090 
C       1085        470         1304       1240         9013       2100 
C       1086        480         1310       1250         9014       2110 
C       1087        490         1313       1260         9015       2120 
C       1088        500         1314       1270         9016       2130 
C       1090        600         1315       1280         9017       2140 
C       1092        610         1320       1290         9018       2150 
C       1100        620         1321      -1300         9020       2160 
C       1102        630         1322       1310         9021       2170 
C       1103        640         1324       1320         9022       2180 
C       1210        650         1325       1330         9023       2190 
C       1212       -660         1326       1340         9024       2200 
C       1213        670         1330      -1350         9025       2210 
C       1215        680         1332       1360         9026       2220 
C       1216        690         1333      -1370         9100       2230 
C       1218        700         1334       1380         9101       2240 
C       1220        710         1338       1390         9102       2250 
C       1221        720         1340       1400         9207       2300 
C      12212        730         1342       1410         9208       2310 
C       1222        740         1344      -1420         9250       2320 
C      12222        750         1360       1430         9261       2330 
C      12224        760         1370       1440         9299       2340 
