      SUBROUTINE SDR2B        
C        
C     SDR2B PROCESSES THE EST. FOR EACH ELEMENT IN THE MASTER SET,      
C     PRELIMINARY COMPUTATIONS ARE MADE. IF THE PROBLEM CONTAINS EXTRA  
C     POINTS, SIL NOS. ARE CONVERTED TO SILD NOS. THE DATA IS WRITTEN   
C     ON ESTA FOR INPUT TO SDR2D WHERE FINAL STRESS AND FORCE RECOVERY  
C     COMPUTATIONS ARE MADE.        
C        
C        
      IMPLICIT INTEGER (A-Z)        
      LOGICAL         ANYOUT,AXIC  ,HEAT  ,REJECT,STRAIN        
      INTEGER         NAME(2)        
      REAL            SCRTCH,ZZ(1) ,BUFR(1)        
      DIMENSION       KDEFRM(2)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25,SWM*27        
      COMMON /XMSSG / UFM   ,UWM   ,UIM   ,SFM   ,SWM        
CZZ   COMMON /ZZSDA2/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SYSTEM/ KSYSTM(63)        
      COMMON /BLANK / APP(2),SORT2 ,IDUMMY(7)    ,STRAIN        
      COMMON /SDR2X1/ IEIGEN,IELDEF,ITLOAD,ISYMFL,ILOADS,IDISPL,ISTR  , 
     1                IELF  ,IACC  ,IVEL  ,ISPCF ,ITTL  ,ILSYM        
      COMMON /SDR2X2/ CASECC,CSTM  ,MPT   ,DIT   ,EQEXIN,SIL   ,GPTT  , 
     1                EDT   ,BGPDT ,PG    ,QG    ,UGV   ,EST   ,PHIG  , 
     2                EIGR  ,OPG1  ,OQG1  ,OUGV1 ,OES1  ,OEF1  ,PUGV1 , 
     3                OEIGR ,OPHIG ,PPHIG ,ESTA  ,GPTTA ,HARMS        
      COMMON /HMATDD/ IHMAT ,NHMAT ,MPTMPT,IDIT        
      COMMON /GPTA1 / NELEM ,LAST  ,INCR  ,ELEM(1)        
      COMMON /SDR2X4/ NAM(2),END   ,MSET  ,ICB(7),OCB(7),MCB(7),DTYPE(8)
     1,               ICSTM ,NCSTM ,IVEC  ,IVECN ,TEMP  ,DEFORM,FILE  , 
     2                BUF1  ,BUF2  ,BUF3  ,BUF4  ,BUF5  ,ANY   ,ALL   , 
     3                TLOADS,ELDEF ,SYMFLG,BRANCH,KTYPE ,LOADS ,SPCF  , 
     4                DISPL ,VEL   ,ACC   ,STRESS,FORCE ,KWDEST,KWDEDT, 
     5                KWDGPT,KWDCC ,NRIGDS,STA(2),REI(2),DS0(2),DS1(2), 
     6                FRQ(2),TRN(2),BK0(2),BK1(2),CEI(2),PLA(22)      , 
     7                NRINGS,NHARMS,AXIC  ,KNSET ,ISOPL ,STRSPT,DDRMM , 
     8                ISOPL8        
      COMMON /SDR2X5/ BUF(100),BUFA(100)  ,BUFB(4176)        
      COMMON /SDR2X6/ SCRTCH(300)        
      COMMON /NAMES / RD    ,RDREW ,WRT   ,WRTREW,CLSREW        
      EQUIVALENCE     (KSYSTM( 1),SYSBUF) ,(KSYSTM( 2),IOUTPT),        
     1                (KSYSTM(55),IPREC ) ,(KSYSTM(56),ITHERM),        
     2                (Z(1)      ,ZZ( 1)) ,(BUFR(1)   ,BUF(1))        
      DATA   NAME   / 4HSDR2,4HB   /      ,STAR  / 4H* *      /        
      DATA   KDEFRM / 104,1/        
      DATA   IZ1ST  / 1    /        
C            IZ1ST  IS THE START OF OPEN CORE AVAILABLE        
C        
C        
C     IF APPROACH IS COMPLEX EIGENVALUES, FREQUENCY OR TRANSIENT        
C     RESPONSE, TEST FOR EXTRA POINTS. IF PRESENT, READ EQUIVALENCE     
C     TABLE (SIL,SILD) INTO CORE.        
C        
      CALL DELSET        
      HEAT = .FALSE.        
      IF (ITHERM .NE. 0) HEAT = .TRUE.        
      ISOPL = 0        
      ICSTM = IZ1ST        
      M8    =-8        
      NOEP  = 0        
      IF (APP(1).EQ.CEI(1) .OR. APP(1).EQ.FRQ(1) .OR. APP(1).EQ.TRN(1)) 
     1    GO TO 20        
      GO TO 40        
   20 ICB(1) = SIL        
      CALL RDTRL (ICB)        
      NOEP = ICB(3)        
      IF (NOEP .EQ. 0) GO TO 40        
      FILE = SIL        
      CALL OPEN (*560,SIL,Z(BUF1),RDREW)        
      CALL FWDREC (*570,SIL)        
      CALL FWDREC (*570,SIL)        
      CALL READ (*570,*30,SIL,Z,BUF2,1,NSIL)        
      CALL MESAGE (M8,0,NAM)        
   30 CALL CLOSE (SIL,CLSREW)        
      KNSIL = NSIL/2        
      ICSTM = NSIL + 1        
      IF (NSIL .LT. MSET) GO TO 40        
      MSET = BUF2 - 1        
      ALL  = 1        
C        
C     READ THE CSTM INTO CORE (IF PRESENT).        
C        
   40 NCSTM = 0        
      FILE  = CSTM        
      CALL OPEN (*60,CSTM,Z(BUF1),RDREW)        
      CALL FWDREC (*570,CSTM)        
      CALL READ (*570,*50,CSTM,Z(ICSTM),BUF2-ICSTM,1,NCSTM)        
      CALL MESAGE (M8,0,NAM)        
   50 CALL CLOSE (CSTM,CLSREW)        
      CALL PRETRS (Z(ICSTM),NCSTM)        
   60 IMAT = ICSTM + NCSTM        
      IF (IMAT .LT. MSET) GO TO 70        
      MSET = BUF2 - 1        
      ALL  = 1        
C        
C     READ MATERIAL PROPERTY DATA INTO CORE.        
C        
   70 N1MAT = BUF2 - IMAT        
      IF (.NOT.HEAT) GO TO 77        
C        
C     FOR HEAT PROBLEMS ONLY, -HMAT- ROUTINE IS USED.        
C        
      IHMAT = IMAT        
      NHMAT = BUF1 + SYSBUF        
      MPTMPT= MPT        
      IDIT  = DIT        
      CALL PREHMA (Z)        
      N2MAT = NHMAT - IHMAT+1 - 2*(SYSBUF+1)        
      GO TO 78        
C        
   77 CALL PREMAT (Z(IMAT),Z(IMAT),Z(BUF1),N1MAT,N2MAT,MPT,DIT)        
   78 IF (IMAT+N2MAT .LT. MSET) GO TO 80        
      MSET = BUF2 - 1        
      ALL  = 1        
C        
C     OPEN EST AND ESTA.        
C        
   80 FILE = EST        
      CALL OPEN (*620,EST,Z(BUF1),RDREW)        
      CALL FWDREC (*570,EST)        
      FILE = ESTA        
      CALL OPEN (*560,ESTA,Z(BUF2),WRTREW)        
      FILE   = EST        
      KWDEST = 0        
      KWDEDT = 0        
      KWDGPT = 0        
C        
C     READ ELEMENT TYPE. SET PARAMETERS AS A FUNCTION OF ELEM TYPE.     
C        
   90 CALL READ (*430,*580,EST,ELTYPE,1,0,FLAG)        
      IF (ELTYPE.LT.1 .OR. ELTYPE.GT.NELEM) GO TO 3800        
      ANYOUT = .FALSE.        
      IPR = IPREC        
      IF (IPR .NE. 1) IPR = 0        
      JLTYPE = 2*ELTYPE - IPR        
      IELEM  = (ELTYPE-1)*INCR        
      NWDS   = ELEM(IELEM+12)        
      NWDSA  = ELEM(IELEM+17)        
      IF (HEAT) NWDSA = 142        
      NGPS   = ELEM(IELEM+10)        
C        
C     READ DATA FOR AN ELEMENT.        
C     DETERMINE IF ELEMENT BELONGS TO MASTER SET.        
C        
  100 CALL READ (*570,*420,EST,BUF,NWDS,0,FLAG)        
      DO 105 I = 1,NWDS        
  105 SCRTCH(100+I) = BUFR(I)        
      STRSPT = 0        
      ISOPL  =-1        
      IDSAVE = BUF(1)        
      IF (ALL .NE. 0) GO TO 110        
      ITABL = MSET        
      KN  = KNSET        
      L   = 1        
      N12 = 1        
      ASSIGN 100 TO RET1        
      IF (.NOT. AXIC) GO TO 630        
C        
C     DECODE ELEMENT ID SINCE THIS IS A CONICAL SHELL PROBLEM        
C        
      BUF(1) = BUF(1)/1000        
      GO TO 630        
C        
C     CALL APPROPRIATE ELEMENT SUBROUTINE.        
C        
  110 CONTINUE        
      BUF(1) = IDSAVE        
C        
      IF (.NOT.STRAIN) GO TO 112        
C        
C     IF THE STRAIN FLAG IS TURNED ON, IGNORE ALL ELEMENTS        
C     EXCEPT CTRIA1, CTRIA2, CQUAD1 AND CQUAD2 ELEMENTS        
C        
      IF (ELTYPE.EQ. 6 .OR. ELTYPE.EQ.17 .OR. ELTYPE.EQ.18 .OR.        
     1    ELTYPE.EQ.19) GO TO 112        
      WRITE  (IOUTPT,111) SWM,ELEM(IELEM+1),ELEM(IELEM+2)        
  111 FORMAT (A27,', STRAIN REQUEST FOR ',2A4,' ELEMENTS WILL', /5X,    
     1       'NOT BE HONORED AS THIS OUTPUT IS NOT DEFINED FOR THIS ',  
     2       'ELEMENT TYPE.')        
      CALL FWDREC (*570,EST)        
      GO TO 420        
C        
  112 IF (HEAT) GO TO 389        
      LOCAL = JLTYPE - 100        
      IF (LOCAL) 114,114,115        
C        
C     PAIRED -GO TO- ENTRIES PER ELEMENT SINGLE/DOUBLE PRECISION        
C        
C             1 CROD      2 C.....    3 CTUBE     4 CSHEAR    5 CTWIST  
  114 GO TO (120,  120,  380,  380,  140,  140,  150,  150,  160,  160  
C        
C             6 CTRIA1    7 CTRBSC    8 CTRPLT    9 CTRMEM   10 CONROD  
     1,      180,  180,  190,  190,  200,  200,  210,  210,  120,  120  
C        
C            11 ELAS1    12 ELAS2    13 ELAS3    14 ELAS4    15 CQDPLT  
     2,      220,  220,  230,  230,  240,  240,  250,  250,  270,  270  
C        
C            16 CQDMEM   17 CTRIA2   18 CQUAD2   19 CQUAD1   20 CDAMP1  
     3,      280,  280,  290,  290,  300,  300,  310,  310,  380,  380  
C        
C            21 CDAMP2   22 CDAMP3   23 CDAMP4   24 CVISC    25 CMASS1  
     4,      380,  380,  380,  380,  380,  380,  380,  380,  380,  380  
C        
C            26 CMASS2   27 CMASS3   28 CMASS4   29 CONM1    30 CONM2   
     5,      380,  380,  380,  380,  380,  380,  380,  380,  380,  380  
C        
C            31 PLOTEL   32 C.....   33 C.....   34 CBAR     35 CCONE   
     6,      380,  380,  380,  380,  380,  380,  330,  330,  340,  340  
C        
C            36 CTRIARG  37 CTRAPRG  38 CTORDRG  39 CTETRA   40 CWEDGE  
     7,      350,  350,  360,  360,  370,  370,  371,  371,  372,  372  
C        
C            41 CHEXA1   42 CHEXA2   43 CFLUID2  44 CFLUID3  45 CFLUID4 
     8,      373,  373,  374,  374,  380,  380,  380,  380,  380,  380  
C        
C            46 CFLMASS  47 CAXIF2   48 CAXIF3   49 CAXIF4   50 CSLOT3  
     9,      380,  380,  375,  375,  376,  376,  377,  377,  378,  378  
C        
     *), JLTYPE        
C        
C        
C            51 CSLOT4   52 CHBDY    53 CDUM1    54 CDUM2    55 CDUM3   
  115 GO TO (379,  379,  380,  380,  451,  451,  452,  452,  453,  453  
C        
C            56 CDUM4    57 CDUM5    58 CDUM6    59 CDUM7    60 CDUM8   
     B,      454,  454,  455,  455,  456,  456,  457,  457,  458,  458  
C        
C            61 CDUM9    62 CQDMEM1  63 CQDMEM2  64 CQUAD4   65 CIHEX1  
     C,      459,  459,  460,  460,  461,  461,  462,  462,  383,  383  
C        
C            66 CIHEX2   67 CIHEX3   68 CQUADTS  69 CTRIATS  70 CTRIAAX 
     D,      383,  383,  383,  383,  465,  465,  466,  466,  467,  467  
C        
C            71 CTRAPAX  72 CAERO1   73 CTRIM6   74 CTRPLT1  75 CTRSHL  
     E,      468,  468,  380,  380,  469,  469,  470,  470,  471,  471  
C        
C            76 CFHEX1   77 CFHEX2   78 CFTETRA  79 CFWEDGE  80 CIS2D8  
     F,      380,  380,  380,  380,  380,  380,  380,  380,  472,  472  
C        
C            81 CELBOW   82 CFTUBE   83 CTRIA3        
     G,      473,  473,  380,  380,  463,  463        
C        
     *), LOCAL        
C        
  120 CALL SROD1        
      GO TO 390        
  140 CALL STUBE1        
      GO TO 390        
  150 K = 4        
      GO TO 170        
  160 K = 5        
  170 CALL SPANL1 (K)        
      GO TO 390        
  180 K = 1        
      GO TO 320        
  190 CALL STRBS1 (0)        
      GO TO 390        
  200 CALL STRPL1        
      GO TO 390        
  210 CALL STRME1 (0)        
      GO TO 390        
  220 K = 1        
      GO TO 260        
  230 K = 2        
      GO TO 260        
  240 K = 3        
      GO TO 260        
  250 K = 4        
  260 CALL SELAS1 (K)        
      GO TO 390        
  270 CALL SQDPL1        
      GO TO 390        
  280 CALL SQDME1        
      GO TO 390        
  290 K = 2        
      GO TO 320        
  300 K = 4        
      GO TO 320        
  310 K = 3        
  320 CALL STRQD1 (K)        
      GO TO 390        
  330 CALL SBAR1        
      GO TO 390        
  340 CALL SCONE1        
      GO TO 390        
  350 CALL STRIR1        
      GO TO 390        
  360 CALL STRAP1        
      GO TO 390        
  370 CALL STORD1        
      GO TO 390        
  371 CALL SSOLD1 (1)        
      GO TO 390        
  372 CALL SSOLD1 (2)        
      GO TO 390        
  373 CALL SSOLD1 (3)        
      GO TO 390        
  374 CALL SSOLD1 (4)        
      GO TO 390        
  375 K = 0        
      GO TO 381        
  376 K = 1        
      GO TO 381        
  377 K = 2        
  381 CALL SAXIF1 (K)        
      GO TO 390        
  378 K = 0        
      GO TO 382        
  379 K = 1        
  382 CALL SSLOT1 (K)        
      GO TO 390        
  383 CONTINUE        
      CALL SIHEX1 (ELTYPE-64,STRSPT,NIP)        
      IF (STRSPT .GE. NIP**3+1) STRSPT = 0        
      GO TO 390        
  451 CALL SDUM11        
      GO TO 391        
  452 CALL SDUM21        
      GO TO 391        
  453 CALL SDUM31        
      GO TO 391        
  454 CALL SDUM41        
      GO TO 391        
  455 CALL SDUM51        
      GO TO 391        
  456 CALL SDUM61        
      GO TO 391        
  457 CALL SDUM71        
      GO TO 391        
  458 CALL SDUM81        
      GO TO 391        
  459 CALL SDUM91        
      GO TO 391        
  460 CALL SQDM11        
      GO TO 390        
  461 CALL SQDM21        
      GO TO 390        
  462 CALL SQUD41        
      GO TO 390        
  463 CALL STRI31        
      GO TO 390        
  465 CONTINUE        
      GO TO 390        
  466 CONTINUE        
      GO TO 390        
  467 CALL STRAX1        
      GO TO 390        
  468 CALL STPAX1        
      GO TO 390        
  469 CALL STRM61        
      GO TO 390        
  470 CALL STRP11        
      GO TO 390        
  471 CALL  STRSL1        
      GO TO 390        
  472 CALL SS2D81        
      ISOPL8 = 8        
      GO TO 390        
  473 CALL SELBO1        
      GO TO 390        
C        
C     ELEMENT UNDEFINE TO SDR2BD        
C        
 3800 WRITE  (IOUTPT,385) STAR,STAR,ELTYPE        
      GO TO 388        
  380 WRITE  (IOUTPT,385) SWM,ELEM(IELEM+1),ELEM(IELEM+2),ELTYPE        
  385 FORMAT (A27,' 2184,  STRESS OR FORCE REQUEST FOR ELEMENT ',2A4,   
     1        ' (NASTRAN ELEM. TYPE =',I4,1H), /5X,'WILL NOT BE HONORED'
     2,       ' AS THIS ELEMENT IS NOT A STRUCTURAL ELEMENT.')        
  388 CALL FWDREC (*570,EST)        
      GO TO 420        
C        
C     HEAT PROBLEMS (ALL ELEMENTS).        
C        
  389 CALL SDHTF1 (ELTYPE,REJECT)        
      IF (ELTYPE.LT.65 .OR.  ELTYPE.GT.67) GO TO 3890        
      IF (ELTYPE.EQ.65 .AND. STRSPT.GE. 9) STRSPT = 0        
      IF (STRSPT .GE. 21) STRSPT = 0        
 3890 CONTINUE        
      IF (.NOT.REJECT) GO TO 390        
      CALL FWDREC (*570,EST)        
      GO TO 420        
C        
C     IF EXTRA POINTS PRESENT, CONVERT SIL NOS. TO SILD NOS.        
C        
  391 NWDSA = ELEM(IELEM+17)        
  390 IF (NOEP .EQ. 0) GO TO 410        
      N = NGPS + 101        
      ITABL = 1        
      KN  = KNSIL        
      N12 = 2        
      ASSIGN 740 TO RET1        
      L = 102        
      IF (BUF(L) .EQ. 0) GO TO 400        
      GO TO 630        
  400 L = L + 1        
      IF (L      .GT. N) GO TO 410        
      IF (BUF(L) .EQ. 0) GO TO 400        
      GO TO 630        
C        
C     WRITE ELEMENT COMPUTATIONS ON ESTA. GO TO READ ANOTHER ELEMENT.   
C        
  410 IF (ANYOUT) GO TO 411        
      CALL WRITE (ESTA,ELTYPE,1,0)        
      KWDEST = KWDEST + 2        
      ANYOUT = .TRUE.        
  411 CALL WRITE (ESTA,BUFA,NWDSA,0)        
C        
C     DIAG 20 OUTPUT ONLY        
C        
C     CALL BUG (4HESTA,0,BUFA,NWDSA)        
C        
      KWDEST = KWDEST + NWDSA        
      IF (STRSPT .EQ. 0) GO TO 100        
      STRSPT = STRSPT + 1        
      GO TO 112        
C        
C     CLOSE RECORD FOR CURRENT ELEMENT TYPE.        
C     GO TO READ ANOTHER ELEM TYPE.        
C        
  420 IF (ANYOUT) CALL WRITE (ESTA,0,0,1)        
      GO TO 90        
C        
C     CLOSE FILES.        
C        
  430 CALL CLOSE (EST ,CLSREW)        
      CALL CLOSE (ESTA,CLSREW)        
C        
C     IF ELEMENT DEFORMATIONS, DETERMINE MAXIMUM NO. OF        
C     WORDS IN ANY ONE DEFORMATION SET.        
C        
      IF (ELDEF .EQ. 0) RETURN        
      CALL PRELOC (*620,Z(BUF1),EDT)        
      CALL LOCATE (*600,Z(BUF1),KDEFRM,FLAG)        
      ID = 0        
      K  = 0        
  530 CALL READ (*600,*550,EDT,BUF,3,0,FLAG)        
      IF (BUF(1) .EQ. ID) GO TO 540        
      KWDEDT = MAX0(KWDEDT,K)        
      K  = 3        
      ID = BUF(1)        
      GO TO 530        
  540 K  = K + 3        
      GO TO 530        
  550 KWDEDT = MAX0(KWDEDT,K)        
      CALL CLOSE (EDT,CLSREW)        
      RETURN        
C        
C        
C     FATAL FILE ERRORS.        
C        
  560 N = -1        
      GO TO 590        
  570 N = -2        
      GO TO 590        
  580 N = -3        
      GO TO 590        
  590 CALL MESAGE (N,FILE,NAM)        
C        
C     ABNORMAL RETURN FROM SDR2B.        
C        
  600 CALL CLOSE (EDT,CLSREW)        
      ELDEF = 0        
      GO TO 620        
  620 CALL MESAGE (30,79,0)        
      STRESS = 0        
      FORCE  = 0        
      ANY    = 0        
      RETURN        
C        
C        
C     BINARY SEARCH ROUTINE        
C        
  630 KLO = 1        
      KHI = KN        
  640 K   = (KLO+KHI+1)/2        
  650 KX  = ITABL + N12*(K-1)        
      IF (BUF(L)-Z(KX)) 660,720,670        
  660 KHI = K        
      GO TO 680        
  670 KLO = K        
  680 IF (KHI-KLO-1 ) 730,690,640        
  690 IF (K .EQ. KLO) GO TO 700        
      K = KLO        
      GO TO 710        
  700 K = KHI        
  710 KLO = KHI        
      GO TO 650        
  720 IF (N12 .EQ. 1) GO TO 110        
      BUF(L) = Z(KX+1)        
      GO TO 400        
  730 GO TO RET1, (100,740)        
  740 CALL MESAGE (-61,0,NAME)        
      GO TO 740        
      END        
