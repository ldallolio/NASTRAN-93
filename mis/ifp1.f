      SUBROUTINE IFP1        
C        
C     READS AND INTERPRETS CASE CONTROL DECK FOR NASTRAN        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        RSHIFT,ANDF,ORF,COMPLF        
      LOGICAL         TAPBIT,SETCD,PLOTCD,BIT64        
      REAL            SYMSEQ(360),XCORE(1),XINTCD        
      DIMENSION       CASE(200,2),XCASE(200,2),NIFP(2),CASEN(11),       
     1                NAME(2),TTLCD(9),CCCD(9),CCCDS(54),XYPRM(5),      
     2                OUTOP(15),ISUBC(5),OUTPCH(13),CORE(7),COREY(401)  
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /OUTPUT/ TITLE(32),SUBTIT(32),LABEL(32),HEAD1(32),        
     1                HEAD2(32),HEAD3(32),PLTID(32)        
      COMMON /SYSTEM/ SYSBUF,OTPE,NOGO,INTP,MPCN,SPCN,LOGFL,LOADNN,NLPP,
     1                STFTEM,IPAGE,LINE,TLINE,MAXLIN,DATE(3),TIM,IECHO, 
     2                SPLOTS,APP,IDUM,LSYSTM,DUMMS(16),NBPW,DUMMY(28),  
     3                ISUBS,DUMZ(16),INTRA,DMZ(4),LPCH        
CZZ   COMMON /ZZIFP1/ COREX(1)        
      COMMON /ZZZZZZ/ COREX(1)        
      COMMON /XIFP1 / BLANK,BIT64        
      COMMON /IFP1A / SCR1,CASECC,IS,NWPC,NCPW4,NMODES,ICC,NSET,        
     1                NSYM,ZZZZBB,ISTR,ISUB,LENCC,IBEN,EQUAL,IEOR       
      COMMON /IFP1HX/ MSST,MISSET(20)        
      COMMON /XSORTX/ IBUF41        
      EQUIVALENCE     (COREX(1) ,XCASE(1,1) , CASE(1,1),COREY(1)),      
     1                (CORE(1)  ,XCORE( 1)  , COREY(401)        ),      
     2                (NONO     ,OUTOP(15)) , (IAXIC  ,DUMMS(4) ),      
     3                (IAXIF    ,DUMMS(15)) , (SET    ,CCCD( 7) ),      
     4                (PLOT     ,TTLCD(4) ) , (XYPL   ,XYPRM(1) ),      
     5                (OUTP     ,CCCD( 1) ) , (BEGI   ,CCCD( 2) ),      
     6                (BOTH     ,OUTOP(1) ) , (NONE   ,OUTOP(2) )       
      DATA    NIFP  / 4H  IF, 4HP1  /        
      DATA    CASEN / 4HC A , 4HS E , 4H   C, 4H O N, 4H T R, 4H O L,   
     1                4H   D, 4H E C, 4H K  , 4H E C, 4H H O  /        
      DATA    IBOB,   ISYMCM, LOADN , IOUT2 , INOMOR          /        
     A        0,      0,      1,      0,      0               /        
      DATA    OUTPCH/ 11,18 , 21,24 , 27,30 , 33,36 , 152,155,158,168,  
     1                171   /        
      DATA    BLANK4, CARD  , COUN  , T     , EQUAL1, NPTP   ,DOL1   /  
     1        4H    , 4HCARD, 4HCOUN, 4HT   , 4H=   , 4HNPTP ,4H$    /  
      DATA    NAME  / 4HCASE, 4HCC  /        
      DATA    TTLCD / 4HTITL, 4HSUBT, 4HLABE, 4HPLOT, 4HXTIT, 4HYTIT,   
     1                4HTCUR, 4HYTTI, 4HYBTI /        
      DATA    CCCD  / 4HOUTP, 4HBEGI, 4HSYM , 4HSUBC, 4HSYMC, 4HREPC,   
     1                4HSET , 4HNCHE, 4HSCAN /        
      DATA    CCCDS / 4HMPC , 4HSPC , 4HLOAD, 4HNLLO, 4HDEFO, 4HTEMP,   
     1                4HDLOA, 4HMETH, 4HFREQ, 4HIC  , 4HDISP, 4HVECT,   
     2                4HPRES, 4HTHER, 4HSTRE, 4HELST, 4HELFO, 4HFORC,   
     3                4HACCE, 4HVELO, 4HSPCF, 4HMAXL, 4HTSTE, 4HSYMS,   
     4                4HSUBS, 4HECHO, 4HMODE, 4HLINE, 4HDSCO, 4HK2PP,   
     5                4HM2PP, 4HB2PP, 4HTFL , 4HFMET, 4HOFRE, 4HOTIM,   
     6                4HCMET, 4HSDAM, 4HSDIS, 4HSVEC, 4HSVEL, 4HSACC,   
     7                4HNONL, 4HPLCO, 4HAXIS, 4HHARM, 4HRAND, 4HOLOA,   
     8                4HGPFO, 4HESE , 4HMPCF, 4HAERO, 4HGUST, 4HSTRA/   
      DATA    ALL   / 4HALL /, COSI / 4HCOSI/        
      DATA    DEFA  / 4HDEFA/, MAT  / 4HMATE/        
      DATA    OM    / 4HOM  /, ONEB / 4H1   /        
      DATA    PCDB  / 4HPCDB/, PLT1 / 4HPLT1/        
      DATA    PLT2  / 4HPLT2/, SINE / 4HSINE/        
      DATA    XYCB  / 4HXYCD/, XYOU / 4HXYOU/        
      DATA    PTIT  / 4HPTIT/, FLUI / 4HFLUI/        
      DATA    SYMM  / 4HSYMM/, ANTI / 4HANTI/        
      DATA    ANOM  / 4HANOM/        
      DATA    XYPRM / 4HXYPL, 4HXYPR, 4HXYPU, 4HXYPE, 4HXYPA /        
      DATA    OUTOP / 4HBOTH, 4HNONE, 4HUNSO, 4HSORT, 4HPUNC, 4HPRIN,   
     1                4HREAL, 4HIMAG, 4HPHAS, 4HNOPR, 4HMAXS, 4HVONM,   
     2                4HEXTR, 4HLAYE, 4HNONO/        
C        
C     INITIALIZE        
C        
      ICC    = 1        
      ICNT   = 0        
      NSET   = 0        
      NSYM   = 0        
      ISUB   = 1        
      MSST   = 0        
      ORG    = 0        
      PORG   =-1        
      ISTR   = 1        
      NCPW4  = 4        
      NWPC   = 20        
      JUMPH  = 0        
      NPCH   = 0        
      NOGOPC = 0        
      SCR1   = 301        
      SETCD  =.FALSE.        
      PLOTCD =.FALSE.        
      BLANK  = BLANK4        
      BIT64  = NBPW.EQ.64        
      CASECC = NAME(1)        
      ZZZZBB = 0        
      ZZZZBB = KHRFN1(ZZZZBB,1,ZZZZBB,4)        
      EQUAL  = KHRFN1(ZZZZBB,1,EQUAL1,1)        
      DOL    = KHRFN1(ZZZZBB,1,DOL1  ,1)        
      IBEN   = KHRFN1(ZZZZBB,1,BLANK ,1)        
      IS     = 9999999        
      IEOR   = RSHIFT(COMPLF(0),1)        
      NMODES = 1        
      LENCC  = 200        
      DO 50 J = 1,2        
      DO 50 I = 1,LENCC        
   50 CASE(I,J) = 0        
      CASE(166,1) = LENCC        
      DO 60 J = 1,2        
      DO 60 I = 1,96        
   60 CASE(I+38,J) = BLANK        
      DO 61 I = 1,5        
      ISUBC(I) = BLANK        
   61 CONTINUE        
      NZ = KORSZ(CORE) - NWPC - 1        
C        
C     BLANK TITLE        
C        
      DO 65 I = 1,96        
      TITLE(I) = BLANK        
   65 CONTINUE        
      DO 70 I = 1,11        
   70 HEAD1(I+9) = CASEN(I)        
      HEAD2(  4) = CARD        
      HEAD3(  4) = COUN        
      HEAD3(  5) = T        
C        
      I81 = NWPC + 1        
C        
C     READ IN DATA-- STORE TITLE CARDS        
C        
      NZ   = NZ  - SYSBUF        
      ICRQ = I81 - NZ        
      IF (I81 .GT. NZ) GO TO 330        
      CALL OPEN (*300,SCR1,COREX(NZ+1),1)        
   80 CALL XREAD (*2000,CORE(1))        
      CALL WRITE (SCR1,CORE(1),NWPC,0)        
      IF (IBUF41 .EQ. -1) GO TO 80        
C        
C     IS THIS A TITLE SUBTITLE,LABEL,ETC CARD        
C        
      CALL IFP1F (*80,IWORD,I2)        
      IF (BIT64) CALL MVBITS (BLANK,0,32,IWORD,0)        
      ASSIGN 80 TO IRET1        
      ISTR = 0        
      ISUB = 1        
      DO 100 I = 1,6        
      IF (IWORD .EQ. CCCD(I)) GO TO (145, 340, 140, 140, 140, 140), I   
C                                    OUTP BEGI SYM  SUBC SYMC REPC      
C        
  100 CONTINUE        
      IF (INOMOR .EQ. 1) GO TO 80        
      DO 101 I = 1,3        
      IF (IWORD .EQ. TTLCD(I)) GO TO (110, 120, 130), I        
C                                     TITL SUBT LABE        
C        
  101 CONTINUE        
      GO TO 80        
  110 IF (LOGFL .LE. 0) CALL LOGFIL (CORE(1))        
  115 ITYPE = 1        
      GO TO 150        
  120 ITYPE = 2        
      GO TO 150        
  130 ITYPE = 3        
      GO TO 150        
  131 ITYPE = 7        
      GO TO 150        
C        
C     STOP TITLE SEARCH        
C        
  140 INOMOR = 1        
      GO TO 80        
C        
C     IDENTIFY PLOT PACKETS        
C        
  145 CALL XRCARD (CORE(I81),NZ,CORE(1))        
      TEMP = CORE(I81+5)        
      IF (BIT64) CALL MVBITS (BLANK,0,32,TEMP,0)        
      IF (TEMP .EQ. PLOT) GO TO 146        
      IF (TEMP.EQ.XYPL .OR. TEMP.EQ.XYOU) GO TO 140        
      GO TO 80        
C        
C     SET PLOT FLAG        
C        
  146 CASE(135,1) = 1        
      GO TO 140        
C        
C     FIND EQUAL SIGN COPY REMAINING DATA ON CARD        
C        
  150 CALL IFP1G (ITYPE,CASE(1,1),ISUB)        
      GO TO IRET1, (80,350)        
C        
C     FILE ERRORS        
C        
  300 IP1 = -1        
  301 CALL MESAGE (IP1,FILE,NIFP)        
      RETURN        
C        
  310 IP1 = -2        
      GO TO 301        
  320 IP1 = -3        
      GO TO 301        
  330 IP1 = -8        
      FILE = ICRQ        
      GO TO 301        
  340 CALL CLOSE (SCR1,1)        
C        
C     START BUILDING RECORDS        
C        
      CALL PAGE        
      NWDSC  = NWPC + 1        
      ASSIGN 350 TO IRET1        
      IHOWDY = 1        
      NSYM   = 0        
      NSYMS  = 0        
      IUN    = 0        
      IXYPL  = 0        
      ICASEC = 0        
      ISTR   = 1        
      NSUB   = 0        
      MSST   = 0        
      IBUF1  = NZ + 1        
      FILE   = SCR1        
      CALL OPEN (*300,SCR1,COREX(IBUF1),0)        
      NZ     = NZ - SYSBUF        
      IBUF2  = NZ + 1        
      FILE   = CASECC        
      IF (ISUBS .EQ. 0) GO TO 603        
C        
C     IN SUBSTRUCTURES, THE CASECC FILE CONTAINS DATA ON THE FRONT.     
C     SKIP FILE BEFORE WRITING.        
C        
      CALL OPEN (*603,FILE,COREX(IBUF2),3)        
      CALL WRITE (FILE,NAME,2,1)        
  350 FILE  = SCR1        
      ICONT = 0        
      ICRQ  = I81 - NZ        
      IF (I81 .GT. NZ) GO TO 330        
  351 CONTINUE        
      CALL READ (*310,*320,SCR1,CORE(1),NWPC,0,FLAG)        
      WRITE  (OTPE,360) ICC,(CORE(I),I=1,NWPC)        
  360 FORMAT (11X,I8,6X,20A4)        
      ICC  = ICC  + 1        
      LINE = LINE + 1        
      IF (LINE .GE. NLPP) CALL PAGE        
      IF (DOL .EQ. KHRFN1(ZZZZBB, 1,CORE(1),1))  GO TO 350        
C        
C     IS THIS TITLE SUBTITLE OR LABEL CARD        
C        
      CALL IFP1F (*350,IWORD,I2)        
      IF (BIT64) CALL MVBITS (BLANK,0,32,IWORD,0)        
      DO 372 I = 1,4        
      IF (IWORD.EQ.TTLCD(I) .AND. IBOB+IXYPL.EQ.0)        
     1    GO TO (115, 120, 130, 131 ), I        
C                TITL SUBT LABE PLOT        
C        
  372 CONTINUE        
      IF (IWORD.EQ.PTIT .AND. IBOB.EQ.1) GO TO 1838        
      IF (IXYPL .NE. 1) GO TO 374        
      DO 373 I = 5,9        
      IF (IWORD .EQ. TTLCD(I)) GO TO 1838        
  373 CONTINUE        
  374 CALL XRCARD (CORE(I81),NZ,CORE(1))        
      IF (ICONT .EQ. 1) GO TO 650        
C        
      IF (BIT64) CALL MVBITS (BLANK,0,32,CORE(I81+1),0)        
      IF (CORE(I81+1) .EQ. OUTP) GO TO 590        
      IF (CORE(I81+1) .EQ. BEGI) GO TO 1320        
      IF (IBOB  .EQ. 1) GO TO 1500        
      IF (IXYPL .EQ. 1) GO TO 1836        
CIBMR 6/93 IF (CORE(I81+1) .LT. 0) GO TO 380        
      IF (CORE(I81) .LT. 0) GO TO 380        
      IWORD = CORE(I81+1)        
      DO 375 I = 3,9        
      IO = I - 2        
      IF (IWORD .EQ. CCCD(I))        
     1    GO TO (580, 1060, 1560, 1720, 1050, 791, 1055), IO        
C                SYM  SUBC  SYMC  REPC  SET  NCHE  SCAN        
C        
  375 CONTINUE        
C        
C        
C     FIND VALUE AFTER EQUAL SIGN        
C        
      L = 2*IABS(CORE(I81)) + I81        
      DO 376 I = I81,L        
      TEMP = CORE(I)        
      IF (BIT64) CALL MVBITS (BLANK,0,32,TEMP,0)        
      IF (TEMP .EQ. EQUAL1) GO TO 377        
  376 CONTINUE        
      IL = -617        
      GO TO 1291        
  377 I1 = I + 1        
      IF (I .EQ. L) I1 = I1 + 1        
C        
      IWORD = CORE(I81+1)        
      IF (BIT64) CALL MVBITS (BLANK,0,32,IWORD,0)        
      DO 379 I = 1,54        
      IF (IWORD .EQ. CCCDS(I))        
C        
C               MPC   SPC   LOAD  NLLO  DEFO  TEMP  DLOA  METH  FREQ    
     1  GO TO ( 400,  430,  440,  460,  540,  690,  550,  760,  560,    
C        
C                IC   DISP  VECT  PRES  THER  STRE  ELST  ELFO  FORC    
     2          570,  770,  770,  770,  770,  780,  780,  790,  790,    
C        
C               ACCE  VELO  SPCF  MAXL  TSTE  SYMS  SUBS  ECHO  MODE    
     3          800,  810,  820,  610,  620,  630,  630, 1420, 1490,    
C        
C               LINE  DSCO  K2PP  M2PP  B2PP  TFL   FMET  OFRE  OTIM    
     4         1630, 1660, 1680, 1700, 1710, 1730, 1880, 1740, 1740,    
C        
C               CMET  SDAM  SDIS  SVEC  SVEL  SACC  NONL  PLCO  AXIS    
     5         1750, 1760, 1780, 1780, 1790, 1800, 1810, 1665, 1850,    
C        
C               HARM  RAND  OLOA  GPFO  ESE   MPCF  AERO  GUST  STRA    
     6         1860, 1870,  480, 1890, 1900,  405, 1910, 1930, 1950), I 
C        
  379 CONTINUE        
C        
C     UNABLE TO FIND CARD TYPE        
C        
  380 CALL IFP1D (-601)        
      IUN  = IUN + 1        
      IF (IUN .LT. 10) GO TO 350        
C        
C     ASSUME BEGIN BULK MISSING        
C        
      CALL IFP1D (-611)        
      GO TO 1320        
C        
C     MPC CARD FOUND        
C        
  400 IK = 2        
      GO TO 490        
C        
C     MPCFORCE CARD        
C        
  405 IK = 173        
      GO TO 830        
C        
C     TOO MANY SPECIFICATIONS        
C        
  410 CALL IFP1D  (602)        
      GO TO IRET, (720,500,860)        
C        
C     SPC CARD DETECTED        
C        
  430 IK = 3        
      GO TO 490        
C        
C     LOAD SET SELECTION        
C        
  440 IK = 4        
      GO TO 490        
C        
C     PNL FOR VDR        
C        
  460 IK = 10        
      GO TO 830        
C        
C     OUTPUT LOAD SET        
C        
  480 IK = 17        
      GO TO 830        
  490 IF (CORE(I1) .LE. 0) CALL IFP1D (-617)        
  491 ASSIGN 500 TO IRET        
C        
C     SKIP CHECK FOR HARMONIC AS DEFAULT IS NON-ZERO        
C        
      IF (CASE(IK,ISUB) .NE. 0) GO TO 410        
  500 CASE(IK,ISUB) = CORE(I1)        
  501 IF (CORE(I1-1) .NE. -1) GO TO 520        
C        
C     CHECK FOR END OF DATA        
C        
      IF (CORE(I1+1) .EQ. IEOR) GO TO 350        
C        
C     DATA CARD DID NOT END PROPERLY        
C        
  503 CONTINUE        
      IL = -603        
      GO TO 1291        
C        
C     NO INTEGER IN INTEGER FIELD        
C        
  520 IL = -604        
      GO TO 1291        
C        
C     DEFORMATION SET        
C        
  540 IK = 6        
      GO TO 490        
C        
C     DLOAD CARD        
C        
  550 IK = 13        
      GO TO 490        
C        
C     FREQUENCY CARD        
C        
  560 IK = 14        
      GO TO 490        
C        
C     IC CARD        
C        
  570 IK = 9        
      GO TO 490        
C        
C     SYM CARD        
C        
  580 NSYM = NSYM + 1        
      IF (NSYM-361) 585,586,1070        
  585 SYMSEQ(NSYM) = 1.0        
      GO TO 1070        
  586 CALL IFP1D (-633)        
      GO TO 1070        
C        
C     OUTPUT        
C        
  590 IOUT2 = 1        
C        
C     BLANK CHECK        
C        
      TEMP = CORE(I81+5)        
      IF (BIT64) CALL MVBITS (BLANK,0,32,TEMP,0)        
      IF (CORE(I81+3).EQ.IEOR .AND. CORE(I81).EQ.1) GO TO 350        
      IF (TEMP .EQ. PLOT) GO TO 600        
      IF (IBOB.EQ.1 .AND. .NOT.(SETCD.AND.PLOTCD)) CALL IFP1D (-631)    
      IF (TEMP.EQ.XYPL .OR. TEMP.EQ.XYOU) GO TO 1830        
      IL = -617        
      GO TO 1291        
  600 IBOB = 1        
C        
C     TURN ON TRAIL BITS FOR PLOT        
C        
      CORE(1) = PCDB        
      CORE(2) = 0        
      CORE(3) = 0        
      CORE(4) = 0        
      CORE(5) = 7777        
      CORE(6) = 0        
      CORE(7) = 0        
      CALL WRTTRL (CORE(1))        
C        
C     CHECK FOR PRESENCE OF PLOT TAPE        
C     (SPLOTS COULD BE SET ALREADY BY NASTRAN PLTFLG CARD)        
C        
      IF (ISUBS.EQ.0 .AND. .NOT.TAPBIT(PLT1) .AND. .NOT.TAPBIT(PLT2))   
     1    CALL IFP1D (-618)        
      IF (SPLOTS .EQ. 0) SPLOTS = 1        
      IF (SPLOTS .LT. 0) SPLOTS =-SPLOTS        
      ASSIGN 605 TO IRET3        
      GO TO 1321        
C        
C     CLOSE OPEN STUFF        
C        
  605 IF (IXYPL .NE. 1) GO TO 602        
C        
C     TERMINANT XY PACKAGE        
C        
      IHOWDY = -1        
      CALL IFP1XY (IHOWDY,XINTCD)        
      CALL CLOSE (XYCB,1)        
      IXYPL = 0        
  602 CALL CLOSE (CASECC,1)        
C        
C     OPEN  PCDB        
C        
      FILE = PCDB        
C        
C     OPEN WRITE FILE        
C        
  603 CALL GOPEN (FILE,COREX(IBUF2),1)        
      GO TO 350        
C        
C     MAXLINES CARD        
C        
  610 MAXLIN = CORE(I1)        
      GO TO 501        
C        
C     TIME STEP CARD        
C        
  620 IK = 38        
      GO TO 490        
C        
C     SYMSEQ AND SUBSEQ        
C        
  630 IF (ISYMCM .NE. 0) GO TO 631        
C        
C     SYMSEQ  CARD WITHOUT SYMCOM        
C        
      IL = -605        
      GO TO 1291        
  631 NSYMSQ = 1        
      NSYM = 1        
  650 IF (NSYM-361) 655,665,660        
  655 SYMSEQ(NSYM) = XCORE(I1)        
  660 IF (CORE(I1+1)) 670,680,350        
  665 CALL IFP1D (-633)        
      GO TO 660        
C        
C     CHECK FOR END OF DATA        
C        
  670 IF (CORE(I1+1) .EQ. IEOR) GO TO 350        
      NSYM = NSYM + 1        
      I1   = I1 + 2        
      GO TO 650        
C        
C     CONTINUATION CARD        
C        
  680 ICONT = 1        
      NSYM  = NSYM + 1        
      I1    = I81  + 1        
      GO TO 351        
C        
C     TEMPERATURE CARD        
C        
  690 IF (CORE(I81) .EQ. 2) GO TO 710        
      TEMP = CORE(I81+5)        
      IF (BIT64) CALL MVBITS (BLANK,0,32,TEMP,0)        
      IF (TEMP .EQ. BOTH) GO TO 710        
      IF (TEMP .EQ.  MAT) GO TO 730        
C        
C     THERMAL LOAD        
C        
  700 IK = 7        
      GO TO 490        
C        
C     THERMAL + STIFFNESS        
C        
  710 ASSIGN 720 TO IRET        
  720 CASE(8,ISUB) = CORE(I1)        
      STFTEM = CORE(I1)        
      IF (ISUB .NE. 1) GO TO 740        
      GO TO 700        
C        
C     STIFNESS LOAD        
C        
  730 IK = 8        
      STFTEM = CORE(I1)        
      IF (ISUB .NE. 1) GO TO 740        
      GO TO 490        
C        
C     THERMAL REQUEST AT SUBCASE LEVEL        
C        
  740 IL = 606        
      GO TO 1291        
C        
C     METHOD        
C        
  760 IK = 5        
      GO TO 490        
C        
C     DISP(PLOT,1) CARD        
C        
  770 IK = 20        
      GO TO 830        
C        
C     STRESS CARD        
C        
  780 IK = 23        
      GO TO 830        
C        
C     ELFORCE CARD        
C        
  790 IK = 26        
      GO TO 830        
C        
C     NCHECK CARD        
C        
  791 IK = 146        
      IF (CORE(I81  ) .EQ.  1) GO TO 793        
      IF (CORE(I81+5) .EQ. -1) GO TO 792        
      IL = -617        
      GO TO 1291        
  792 CASE(IK,ISUB) = CORE(I81+6)        
      IF (CORE(I81+7) .NE. IEOR) GO TO 503        
      GO TO 350        
  793 CASE(IK,ISUB) = 5        
      GO TO 350        
C        
C     ACC        
C        
  800 IK = 29        
      GO TO 830        
C        
C     VEL CARD        
C        
  810 IK = 32        
      GO TO 830        
C        
C     SPC FORC        
C        
  820 IK = 35        
      GO TO 830        
C        
C     OUTPUT SPECIFICATION        
C     STRESS AND FORCE FLAGS MAY BE PRE-SET TO 2 (NOPRINT) BY IFP1H     
C        
  830 ASSIGN 860 TO IRET        
      IF ((IK.EQ.23 .OR. IK.EQ.26) .AND. CASE(IK+1,ISUB).EQ.2) GO TO 860
      IF (CASE(IK,ISUB) .NE. 0) GO TO 410        
C        
C     FIND EQUAL SIGN        
C        
  860 IDO = CORE(I81)        
      CASE(IK+1,ISUB) = 0        
      CASE(IK+2,ISUB) = 1        
      DO 950 I = 1,IDO        
      II   = I81 + 2*I        
      TEMP = CORE(II)        
      IF (BIT64) CALL MVBITS (BLANK,0,32,TEMP,0)        
      IF (TEMP .EQ. EQUAL1) GO TO 960        
      IWRD = CORE(II-1)        
      DO 880 IO = 4,14        
      IF (BIT64) CALL MVBITS (BLANK,0,32,IWRD,0)        
      IOP = IO - 3        
      IF (IWRD .EQ. OUTOP(IO)) GO TO        
     1   (940, 890, 900, 910, 920, 930, 905, 950, 943, 950, 946), IOP   
C         SORT PUNC PRIN REAL IMAG PHAS NOPR MAXS VONM EXTR LAYE        
C        
  880 CONTINUE        
      GO TO 950        
C        
C     PUNCH        
C        
  890 CASE(IK+1,ISUB) = CASE(IK+1,ISUB) + 4        
      GO TO 950        
C        
C     PRINT        
C        
  900 CASE(IK+1,ISUB) = CASE(IK+1,ISUB) + 1        
      GO TO 950        
C        
C     COMPUTE BUT NO PRINT        
C     DEVICE CODE IS 2 (AND SUBPRESS PRINT CODE 1)        
C        
  905 CASE(IK+1,ISUB) = CASE(IK+1,ISUB) - MOD(CASE(IK+1,ISUB),2) + 2    
      GO TO 950        
C        
C     REAL PRINT OUT FORMAT        
C        
  910 II = 1        
      GO TO 931        
C        
C     REAL AND IMAGINARY        
C        
  920 II = 2        
      GO TO 931        
C        
C     MAGNITUE AND PHASE ANGLE        
C        
  930 II = 3        
  931 CASE(IK+2,ISUB) = ISIGN(II,CASE(IK+2,ISUB))        
      GO TO 950        
C        
C     SORT TWO REQUEST        
C     (COMMENTS FORM G.C.  7/1989        
C     SINCE OES2L FILE HAS NOT BEEN IMPLEMENTED IN ALL DMAPS, SORT2     
C     STRESS REQUEST ON LAYERED ELEMENTS IS NOT AVAILABLE)        
C        
  940 TEMP = CORE(II)        
      IF (BIT64) CALL MVBITS (BLANK,0,32,TEMP,0)        
      IF (TEMP .EQ. ONEB) GO TO 950        
      IF (IK.EQ.23 .AND. CASE(183,ISUB).GE.2) CALL IFP1D (-645)        
      CASE(IK+2,ISUB) = -IABS(CASE(IK+2,ISUB))        
      GO TO 950        
C        
C     VON MISES STRESS        
C     (183 WORD ON CASECC, FIRST RIGHT-MOST BIT)        
C        
  943 CASE(183,ISUB) = ORF(CASE(183,ISUB),1)        
      GO TO 950        
C        
C     LAYER STRESSES FOR COMPOSITE ELEMENTS        
C     (183 WORD ON CASECC, SECOND RIGHT-MOST BIT)        
C     (SORT2 STRESS REQUEST ON LAYERED ELEMENTS NOT AVAILABLE)        
C        
  946 IF (IK .NE. 23) CALL IFP1D (-646)        
      IF (IK.EQ.23 .AND. CASE(25,ISUB).LT.0) CALL IFP1D (-645)        
      CASE(183,ISUB) = ORF(CASE(183,ISUB),2)        
C        
  950 CONTINUE        
  960 IF (CASE(IK+1,ISUB) .EQ. 0) CASE(IK+1,ISUB) = 1        
      IF (CORE(II+1) .NE.  0) GO TO 962        
      CALL IFP1D (610)        
      GO TO 970        
  962 TEMP = CORE(II+1)        
      IF (BIT64) CALL MVBITS (BLANK,0,32,TEMP,0)        
      IF (TEMP .EQ. ALL) GO TO 970        
      IF (TEMP.EQ.NONE .OR. TEMP.EQ.NONO) GO TO 980        
      IF (CORE(II+1) .EQ. -1) GO TO 964        
      IL = -617        
      GO TO 1291        
  964 I1 = II + 2        
      GO TO 990        
C        
C     ALL SPECIFIED -- SET SET NO. MINUS        
C        
  970 CASE(IK,ISUB) = -1        
      GO TO 1042        
C        
C     NONE SPECIFIED        
C        
  980 CASE(IK,ISUB) = NONE        
      GO TO 1042        
C        
C     FIND SET NUMBER        
C        
  990 IF (NSET .NE. 0) GO TO 1020        
C        
C     UNDEFINED SET ID ON CARD        
C        
 1000 CALL IFP1D (-608)        
      GO TO 350        
 1020 JJ = NWDSC        
      DO 1030 IL = 1,NSET        
      IF (CORE(JJ) .EQ. CORE(I1)) GO TO 1040        
      JJ = JJ + CORE(JJ+1) + 3        
 1030 CONTINUE        
      GO TO 1000        
 1040 CASE(IK,ISUB) =CORE(I1)        
 1042 IF (CORE(II+3) .NE. IEOR) GO TO 503        
      GO TO 350        
C        
C     SET CARD        
C        
 1050 NSET = NSET + 1        
      CALL IFP1C (I81,NZ)        
      GO TO 350        
C        
C     SCAN CARD        
C        
 1055 CALL IFP1H (I81,NZ,JUMPH)        
      GO TO 350        
C        
C     SUBCASE        
C        
 1060 TEMP = CORE(I81+2)        
      IF (BIT64) CALL MVBITS (BLANK,0,32,TEMP,0)        
      IF (TEMP   .EQ. OM) GO TO 1560        
      IF (ISYMCM .EQ.  1) GO TO 1330        
      NSYM  = 0        
      NSYMS = NSYMS + 1        
      IF (NSYMS-361) 1062,1064,1070        
 1062 SYMSEQ(NSYMS) = 1.0        
      GO TO 1070        
 1064 CALL IFP1D (-633)        
 1070 ASSIGN 350 TO IRET3        
      IF (ISUB .EQ. 2) GO TO 1080        
      ISUB  = 2        
      LOADN = CORE(I81+4)        
      CALL IFP1F (*350,IWORD,I2)        
      IF (BIT64) CALL MVBITS (BLANK,0,32,IWORD,0)        
      DO 1071 I = 1,5        
      ISUBC(I) = CORE(I2)        
      I2 = I2 + 1        
 1071 CONTINUE        
      IF (CORE(I81+3) + 1) 1290,350,1290        
C        
C     TURN STRESS AND FORCE NO-PRINT FLAGS ON IF INTERACTIVE FLAG IS ON 
C        
 1080 IF (INTRA .LT. 2) GO TO 1085        
      CASE(24,ISUB) = ORF(CASE(24,ISUB),8)        
      CASE(27,ISUB) = ORF(CASE(27,ISUB),8)        
C        
 1085 CASE(1,ISUB) = LOADN        
      IF (CORE(I81+4) .LE. LOADN+NMODES-1) GO TO 1310        
      LOADN = CORE(I81+4)        
      IF (CORE(I81+3) .NE. -1) GO TO 1310        
 1090 IF (CASE(137,1) .EQ.  0) CASE(137,1) = 1        
      CALL IFP1E (ISUBC(1),SYMSEQ,NWDSC,I81,ICASTE)        
      STFTEM = ICASTE        
      NSUB = NSUB + NMODES        
C        
C     CHECK SET NOS. THAT WERE SPECIFIED AFTER SCAN CARDS        
C        
C     FORM G.C./UNISYS   4/1990        
C     IFP1H IS BY-PASSING THIS NEW CODE HERE (MSST=0) BECAUSE SET DATA  
C     IS NOT AVAILABLE HERE. SAVE THIS CODE FOR FURTHER INVESTIGATION.  
C        
      IF (MSST .EQ. 0) GO TO 1281        
      MM = 0        
      LL = LENCC + CASE(LENCC,ISUB) + 1        
      DO 1094 M = 1,MSST        
      I  = LL        
      MSET = MISSET(M)        
C        
C     WRITE (6,2345) MSET,MSST,LL        
C2345 FORMAT ('   CHECKING SET',I5,' @IFP1.  MSST,LL=',2I5)        
C        
 1091 ISET = CASE(I,ISUB)        
C        
C     LX1 = I - 3        
C     LX2 = I + 3        
C     WRITE (6,6789) ISET,(CASE(LX,ISUB),LX=LX1,LX2)        
C6789 FORMAT ('    ISET FROM CASECC =',7I6)        
C        
      IF (ISET .EQ. 0) GO TO 1094        
      IF (MSET-ISET) 1092,1093,1092        
 1092 I = I + CASE(I+1,ISUB)        
      IF (I .GE. 400) GO TO 1094        
      GO TO 1091        
 1093 MISSET(M) = 0        
      MM = MM + 1        
 1094 CONTINUE        
      IF (MM .EQ. MSST) GO TO 1281        
      DO 1096 M = 1,MSST        
      IF (MISSET(M) .EQ. 0) GO TO 1096        
      WRITE  (OTPE,1095) UFM,MISSET(M)        
 1095 FORMAT (A23,' 608A, UNIDENTIFIED SET',I8,' WAS REQUESTED FOR ',   
     1       'SCAN')        
      NOGO = 1        
 1096 CONTINUE        
C        
 1281 GO TO IRET3, (350,1370,605,1835)        
C        
C     SUBCASE ID MISSING        
C        
 1290 IL = -609        
      LOADN = CASE(1,2)        
 1291 CALL IFP1D (IL)        
      GO TO 350        
 1310 CALL IFP1D (-609)        
      LOADN = CASE(1,2)        
      GO TO 1090        
C        
C     BEGIN BULK        
C        
 1320 ASSIGN 1370 TO IRET3        
 1321 CORE(I81+3) = -1        
      CORE(I81+4) = 9999999        
      IF (ICASEC .EQ. 1) GO TO 1281        
      ICASEC = 1        
      IF (ISYMCM .EQ. 1) GO TO 1330        
      NSYM = 0        
      GO TO 1080        
C        
C     PUT OUT SUBCOM OR SYMCOM RECORD        
C        
 1330 ISYMCM = 0        
 1340 IF (NSYMSQ.NE.0 .OR. NSYM.NE.0) GO TO 1360        
C        
C     NO SUBSEQ OR SYMSEQ CARD        
C        
      NSYM = NSYMS        
C        
 1360 NSYMSQ = 0        
      CASE(LENCC,2) = MAX0(NSYM,0)        
      CASE(16,2) = NSYM        
      GO TO 1080        
 1370 CALL CLOSE (SCR1,1)        
      IF (IBOB.NE.1 .AND. IXYPL.NE.1) CALL CLOSE (CASECC,1)        
      IF (IBOB .EQ. 1) CALL CLOSE (PCDB,1)        
      IF (IBOB.EQ.1 .AND. .NOT.(SETCD.AND.PLOTCD)) CALL IFP1D (-631)    
      IF (IXYPL .NE. 1) GO TO 1371        
C        
C     TERMINATE XYPLOT PACKAGE        
C        
      IHOWDY = -1        
      CALL IFP1XY (IHOWDY,XINTCD)        
      CALL CLOSE  (XYCB,1)        
C        
C     PUT CASECC ON NPTP        
C        
 1371 CONTINUE        
      FILE  = CASECC        
      CALL OPEN (*300,CASECC,COREX(IBUF1),0)        
      FILE  = NPTP        
      MAXCC = 0        
      CALL OPEN (*300,NPTP,COREX(IBUF2),3)        
 1380 CALL READ (*1400,*1390,CASECC,CORE(1),NZ,0,FLAG)        
      ICRQ  = NZ        
      GO TO 330        
 1390 CALL WRITE (NPTP,CORE(1),FLAG,1)        
      MAXCC = MAX0(MAXCC,FLAG)        
C        
C     CHECK ANY PUNCH REQUEST  ON OUTPUT DATA BLOCKS        
C        
      IF (NPCH.EQ.1 .OR. FLAG.LT.166) GO TO 1380        
      DO 1393 I = 1,13        
      J = OUTPCH(I)        
      IF (ANDF(CORE(J),4) .NE. 0) GO TO 1395        
 1393 CONTINUE        
      GO TO 1380        
 1395 NPCH = 1        
      GO TO 1380        
 1400 CALL CLOSE (CASECC,1)        
      CALL EOF (NPTP)        
      CALL CLOSE (NPTP,2)        
      IF (SPLOTS .LT. 0) SPLOTS = 0        
C        
C     IF THIS IS A RESTART  SET CHANGE FLAGS IN IFP1B        
C        
      IF (APP .LT. 0) CALL IFP1B        
      IF (IUN .NE. 0) CALL IFP1D (-612)        
      CALL MAKMCB (CORE,CASECC,NSUB,0,0)        
      CORE(2) = NSUB        
      CORE(4) = MAXCC        
      CALL WRTTRL (CORE)        
C        
C     SET NOGO FLAG TO -9 IF ERROR IN BULKDATA AND PLOT COMMANDS        
C     SET NOGO FLAG TO POSITIVE IF ERROR IN BULKDATA, AND NOT IN PLOT   
C     SET NOGO FLAG TO NEGATIVE IF NO ERROR IN BULKDATA, BUT IN PLOT    
C     PUNCH AN IDENTIFICATION CARD IF PUNCH IS REQUESTED ON OUTPUT DATA,
C     AND PRINT SCAN KEYWORDS IF ERROR FLAG (JUMPH) WAS TURNED ON       
C        
      IF (NOGO.NE.0 .AND. NOGOPC.EQ.-1) NOGO = -9        
      IF (NOGO .EQ. 0) NOGO = NOGOPC        
      IF (NPCH .EQ. 1) WRITE (LPCH,1415) (TITLE(J),J=1,17)        
 1415 FORMAT (2H$ ,17A4)        
      IF (JUMPH .EQ. 1) CALL IFP1H (0,0,2)        
      RETURN        
C        
C     ECHO REQUEST        
C        
 1420 IECHO = 0        
      IDO = CORE(I81) - 2        
      DO 1460 I = 1,IDO        
      IWRD = CORE(I1)        
      IF (BIT64) CALL MVBITS (BLANK,0,32,IWRD,0)        
      DO 1421 IO = 1,5        
      IF (IWRD .EQ. OUTOP(IO)) GO TO (1435, 1480, 1440, 1430, 1431), IO 
C                                     BOTH  NONE  UNSO  SORT  PUNC      
C        
 1421 CONTINUE        
      IF (IWRD .EQ. OUTOP(15)) GO TO 1470        
      CALL IFP1D (629)        
      GO TO 1432        
C        
C     SORTED ECHO        
C        
 1430 CONTINUE        
      IF (ANDF(IECHO,2) .NE. 0) CALL IFP1D (629)        
 1432 IECHO = ORF(IECHO,2)        
      GO TO 1450        
C        
C     PUNCH ECHO        
C        
 1431 CONTINUE        
      IF (ANDF(IECHO,4) .NE. 0) CALL IFP1D (629)        
      IECHO = ORF(IECHO,4)        
      NPCH  = 1        
      GO TO 1450        
C        
C     BOTH ECHO        
C        
 1435 CONTINUE        
      IF (ANDF(IECHO,3) .NE. 0) CALL IFP1D (629)        
      IECHO = ORF(IECHO,3)        
      GO TO 1450        
C        
C     UNSORTED ECHO        
C        
 1440 CONTINUE        
      IF (ANDF(IECHO,1) .NE. 0) CALL IFP1D (629)        
      IECHO = ORF(IECHO,1)        
 1450 I1 = I1 + 2        
 1460 CONTINUE        
C        
      GO TO 350        
C        
C     NONO ECHO - ABSOLUTELY NO ECHO, NO EVEN IN RESTART        
C        
 1470 IO = 16        
C        
C     NONE ECHO        
C        
 1480 CONTINUE        
      IF (IECHO.NE.0 .OR. I.LT.IDO) CALL IFP1D (630)        
      IECHO = -1        
      IF (IO .EQ. 16) IECHO = -2        
      GO TO 350        
C        
C     LOOP CONTROL FOR EIGENVALUE        
C        
 1490 NMODES = CORE(I1)        
      GO TO 350        
C        
C     PLOT DATA FOR BO BATA        
C        
 1500 I1 = I81        
C        
C     TEST FOR REQUIRED PLOT AND SET CARDS IN STRUCTURE PLOT OUTPUT PKG 
C        
      TEMP = CORE(I81+2)        
      IF (BIT64) CALL MVBITS (BLANK,0,32,TEMP,0)        
      IF (CORE(I81+1).EQ.PLOT .AND. TEMP.EQ.BLANK) PLOTCD =.TRUE.       
      IF (CORE(I81+1) .EQ. SET) SETCD  = .TRUE.        
C        
C     TEST FOR XYPLOT COMMAND CARDS IN STRUCTURE PLOT OUTPUT PACKAGE    
C        
      IWRD = CORE(I81+1)        
C     IF (BIT64) CALL MVBITS (BLANK,0,32,IWRD,0)        
      DO 1501 I = 1,5        
      IF (IWRD .EQ. XYPRM(I)) CALL IFP1D (-632)        
 1501 CONTINUE        
C        
C     TEST FORMAT OF PLOT COMMAND CARDS        
C        
      I = NOGO        
      NOGO = 0        
      CALL IFP1PC (I81,ICNT,XINTCD,ORG,PORG)        
      IF (NOGO .NE. 0) NOGOPC = -1        
      NOGO = I        
C        
C     COMPUTE LENGTH OF RECORD        
C        
      IK = 0        
 1510 IF (CORE(I1)) 1520,1550,1530        
 1520 CONTINUE        
      IP = 2        
      GO TO 1540        
 1530 IF (CORE( I1) .EQ. IEOR) GO TO 1550        
      IP = 2*CORE(I1) + 1        
 1540 IK = IK + IP        
      I1 = I1 + IP        
      GO TO 1510        
 1550 CALL WRITE (PCDB,CORE(I81),IK+1,1)        
      GO TO 350        
C        
C     PLOT TITLE CARD        
C        
 1555 CORE(I81  ) = 10        
      CORE(I81+1) = IWORD        
      CORE(I81+2) = BLANK        
      CALL IFP1G (ITYPE,CORE(I81+3),1)        
      CORE(I81+21) = 9999999        
      IK = 21        
      GO TO 1550        
C        
C     SYMCOM OR SUBCOM CARD        
C        
 1560 IF (ISYMCM .EQ. 0) GO TO 1570        
      ASSIGN 350 TO IRET3        
      GO TO 1340        
 1570 ISYMCM = 1        
      NSYMSQ = 0        
      GO TO 1070        
C        
C     LINE CARD - NLPP BOTTOM-LIMITED TO 10        
C        
 1630 CONTINUE        
      IF (CORE(I1-1) .NE. -1) GO TO 520        
      IF (IABS(CORE(I1)) .GT. 0) NLPP = IABS(CORE(I1))        
      IF (NLPP .LT. 10) NLPP = 10        
      GO TO 350        
C        
C     DIFFERENTIAL STIFFNESS OR PIECEWISE LINEAR COEFFICIENT SET        
C        
 1660 IK = 138        
      GO TO 1670        
 1665 IK = 164        
 1670 TEMP = CORE(I1)        
      IF (BIT64) CALL MVBITS (BLANK,0,32,TEMP,0)        
      IF (TEMP .NE. DEFA) GO TO 490        
      CORE(I1  ) = -1        
      CORE(I1+1) = IEOR        
      CORE(I1-1) = -1        
      GO TO 491        
C        
C     K2PP        
C        
 1680 IK = 139        
 1690 CASE(IK  ,ISUB) = CORE(I1  )        
      CASE(IK+1,ISUB) = CORE(I1+1)        
      GO TO 350        
C        
C     M2PP        
C        
 1700 IK = 141        
      GO TO 1690        
C        
C     B2PP        
C        
 1710 IK = 143        
      GO TO 1690        
C        
C     REPRINT OF ABOVE CASE        
C        
 1720 NSYM = -1        
      IF(ISUB .NE. 2) CALL IFP1D (-607)        
      GO TO 1560        
C        
C     TRANSFER FUNCTION SELECTION        
C        
 1730 IK = 15        
      GO TO 490        
C        
C     OUTPUT FREQUENCY LIST SET        
C        
 1740 IK = 145        
      TEMP = CORE(I1)        
      IF (BIT64) CALL MVBITS (BLANK,0,32,TEMP,0)        
      IF (TEMP .NE. ALL) GO TO 830        
      CORE(I1  ) = -1        
      CORE(I1-1) = -1        
      CORE(I1+1) = IEOR        
      GO TO 491        
C        
C     COMPLEX EIGENVALUE METHOD        
C        
 1750 IK = 148        
      GO TO 490        
C        
C     STRUCTURAL DAMPING TABLE        
C        
 1760 IK = 149        
      GO TO 490        
C        
C     INERTIA RELIEF SET SELECTION        
C        
C1770 IK = 150        
C     GO TO 490        
C        
C     ANALYSIS SET FOR VDR        
C        
 1780 IK = 151        
      GO TO 830        
C        
C     ANALYSIS VELOCITY        
C        
 1790 IK = 154        
      GO TO 830        
C        
C     ANALYSIS ACCELERATION        
C        
 1800 IK = 157        
      GO TO 830        
C        
C     NON LINEAR FORCE VECTOR FOR TRANSIENT ANALYSIS        
C        
 1810 IK = 160        
      GO TO 490        
C        
C     X-Y PLOTTER PACKAGE        
C        
 1830 ASSIGN 1835 TO IRET3        
      GO TO 1321        
 1835 CALL CLOSE (CASECC,1)        
      DO 1834 I = 2,6        
 1834 CORE(I) = 0        
      CORE(1) = XYCB        
      CORE(7) = 1        
      CALL WRTTRL (CORE(1))        
C        
C     OPEN XYCB        
C        
      IF (IBOB .NE. 1) GO TO 1837        
      CALL CLOSE (PCDB,1)        
      IBOB  = 0        
 1837 FILE  = XYCB        
      IXYPL = 1        
      I81   = NWPC + 1        
      GO TO 603        
C        
C     AXIS TITLE CARDS        
C        
 1838 ITYPE = 8        
      CORE(1) = IWORD        
      DO 1839 I = 1,32        
      K = I81 + I - 1        
      CORE(K) = BLANK        
 1839 CONTINUE        
      IF (IBOB .EQ. 1) GO TO 1555        
      CALL IFP1G (ITYPE,CORE(I81),1)        
C        
C     PROCESS XYPLOTTER CARD        
C        
 1836 CALL IFP1XY (IHOWDY,XINTCD)        
      GO TO 350        
C        
C     DELETE SETS FOR FORCE        
C        
C1840 IK = 161        
C     GO TO 490        
C        
C     AXISYM CARD        
C        
 1850 TEMP = CORE(I1)        
      IF (BIT64) CALL MVBITS (BLANK,0,32,TEMP,0)        
      IF (TEMP .EQ. SINE) GO TO 1851        
      IF (TEMP .EQ. COSI) GO TO 1852        
      IF (TEMP .EQ. FLUI) GO TO 1852        
      IF (TEMP .EQ. SYMM) GO TO 1853        
      IF (TEMP .EQ. ANTI) GO TO 1854        
      IF (TEMP .EQ. ANOM) GO TO 1855        
C        
C     ILLEGAL  SPECIFICATION        
C        
      IL = -617        
      GO TO 1291        
 1851 CASE(136,ISUB) = 1        
      IAXIC = 1        
      GO TO 350        
 1852 CASE(136,ISUB) = 2        
      IF (TEMP .EQ. COSI) IAXIC = 1        
      IF (TEMP .EQ. FLUI) IAXIF = 1        
      GO TO 350        
 1853 CASE(136,ISUB) = -2        
      GO TO 1856        
 1854 CASE(136,ISUB) = -1        
      GO TO 1856        
 1855 CASE(136,ISUB) = -30        
      GO TO 350        
 1856 TEMP = CORE(I1+1)        
      IF (BIT64) CALL MVBITS (BLANK,0,32,TEMP,0)        
      IF (TEMP .EQ. ANOM) CASE(136,ISUB) = CASE(136,ISUB)*10        
      GO TO 350        
C        
C     HARMONIC SELECTOR        
C        
 1860 IK = 137        
      TEMP = CORE(I1)        
      IF (BIT64) CALL MVBITS (BLANK,0,32,TEMP,0)        
      IF (TEMP .EQ.  ALL) GO TO 1861        
      IF (TEMP .EQ. NONE) GO TO 1862        
      CORE(I1) = CORE(I1) + 1        
      GO TO 490        
 1861 CORE(I1) = -1        
      GO TO 1863        
 1862 CASE(137,1)= 0        
      CORE(I1  ) = 0        
 1863 CORE(I1-1) = -1        
      CORE(I1+1) = IEOR        
      GO TO 491        
C        
C     RANDOM SET SELECTION        
C        
 1870 IK = 163        
      GO TO 490        
C        
C     FMETHOD        
C        
 1880 IK = 165        
      GO TO 490        
C        
C     GRID POINT FORCE REQUEST        
C        
 1890 IK = 167        
      GO TO 830        
C        
C     ELEMENT STRAIN ENERGY        
C        
 1900 IK = 170        
      GO TO 830        
C        
C     AEROFORCE OUTPUT REQUEST        
C        
 1910 IK = 176        
      GO TO 830        
C        
C     AEROELASTIC GUST LOAD REQUEST        
C        
 1930 IK = 179        
      GO TO 490        
C        
C     STRAIN CARD        
C     (180 THRU 182 WORDS OF CASECC)        
C        
 1950 IK = 180        
      GO TO 830        
C        
C     EOF ON INPUT UNIT        
C        
 2000 CALL IFP1D  (-624)        
      CALL MESAGE (-37,0,NIFP)        
      RETURN        
      END        
