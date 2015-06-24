      SUBROUTINE DDRMM        
C        
C     DYNAMIC-DATA-RECOVERY-MATRIX-METHOD        
C        
C     DMAP SEQUENCES. ONLY SORT2 IS USED        
C        
C     (TRANSIENT RESPONCE)        
C     ====================        
C     DDRMM    CASEXX,UHVT,PPT,IPHIP2,IQP2,IES2,IEF2,XYCDB,EST,MPT,DIT/ 
C              ZUPV2,ZQP2,ZES2,ZEF2, $        
C        
C     (FREQUENCY RESPONSE)        
C     ====================        
C     DDRMM    CASEXX,UHVF,PPF,IPHIP1,IQP1,IES1,IEF1,XYCDB,EST,MPT,DIT/ 
C              ZUPVC1,ZQPC1,ZESC1,ZEFC1, $        
C       OR        
C     DDRMM    CASEXX,UHVF,PPF,IPHIP2,IQP2,IES2,IEF2,XYCDB,EST,MPT,DIT/ 
C              ZUPVC2,ZQPC2,ZESC2,ZEFC2, $        
C        
      LOGICAL  TRNSNT  ,SORT2    ,COL1     ,FRSTID        
      INTEGER  OUTPT   ,SYSBUF   ,Z        ,RD       ,WRT      ,CLS     
      INTEGER  FILE    ,BUF(150) ,UV       ,RDREW    ,WRTREW   ,CLSREW  
      INTEGER  CASECC  ,PHASE    ,SUBR(2)  ,BUFF     ,DHSIZE        
      INTEGER  PP      ,DVA(3)   ,SCRT1    ,SCRT2    ,SCRT3    ,SCRT4   
      INTEGER  SCRT5   ,SCRT6    ,FRQSET   ,ENTRYS   ,SCRT     ,BUF1    
      INTEGER  BUF2    ,BUF3     ,BUF4     ,BUF5     ,BUF6        
      INTEGER  IFILE(4),OFILE(4) ,FILNAM   ,SETS     ,PASSES        
      INTEGER  EOR     ,OUTFIL   ,SETID    ,UVSOL    ,SCRT7        
      INTEGER  SAVDAT  ,SUBCAS   ,INBLK(15),OUBLK(15)        
C     INTEGER  XYCDB   ,EST      ,MPT      ,DIT        
      REAL     RZ(1)   ,LAMBDA   ,RIDREC(146)        
      CHARACTER         UFM*23   ,UWM*25   ,UIM*29   ,SFM*25   ,SWM*27  
      COMMON  /XMSSG /  UFM      ,UWM      ,UIM,SFM  ,SWM        
      COMMON  /SYSTEM/  SYSBUF   ,OUTPT    ,XSYS(22) ,ISWTCH        
      COMMON  /NAMES /  RD       ,RDREW    ,WRT      ,WRTREW   ,CLSREW  
     1                 ,CLS        
CZZ   COMMON  /ZZDDRM/  Z(1)        
      COMMON  /ZZZZZZ/  Z(1)        
      COMMON  /DDRMC1/  IDREC(146),BUFF(6) ,PASSES   ,OUTFIL   ,JFILE   
     1                 ,MCB(7)   ,ENTRYS   ,SETS(5,3),INFILE   ,LAMBDA  
     2                 ,FILE     ,SORT2    ,COL1     ,FRSTID   ,NCORE   
     3                 ,NSOLS    ,DHSIZE   ,FILNAM(2),RBUF(150),IDOUT   
     4                 ,ICC      ,NCC      ,ILIST    ,NLIST    ,NWDS    
     5                 ,SETID    ,TRNSNT   ,I1       ,I2       ,PHASE   
     6                 ,ITYPE1   ,ITYPE2   ,NPTSF    ,LSF      ,NWDSF   
     7                 ,SCRT(7)  ,IERROR   ,ITEMP    ,DEVICE   ,FORM    
     8                 ,ISTLST   ,LSTLST   ,UVSOL    ,NLAMBS   ,NWORDS  
     9                 ,OMEGA    ,IPASS    ,SUBCAS        
      COMMON  /STDATA/  LMINOR   ,NSTXTR   ,NPOS     ,SAVDAT(110)       
      EQUIVALENCE       (RZ(1),Z(1))   , (RBUF(1),BUF(1))        
      EQUIVALENCE       (SCRT1,SCRT(1)), (SCRT2,SCRT(2))        
      EQUIVALENCE       (SCRT3,SCRT(3)), (SCRT4,SCRT(4))        
      EQUIVALENCE       (SCRT5,SCRT(5)), (SCRT6,SCRT(6))        
      EQUIVALENCE       (SCRT7,SCRT(7)), (RIDREC(1),IDREC(1))        
      EQUIVALENCE       (BUF1,BUFF(1)) , (BUF2,BUFF(2))        
      EQUIVALENCE       (BUF3,BUFF(3)) , (BUF4,BUFF(4))        
      EQUIVALENCE       (BUF5,BUFF(5)) , (BUF6,BUFF(6))        
      DATA     IFROUT/  145 /,  DVA   / 20, 32, 29 /        
      DATA     ISTRES,  IFORCE, ISPCF / 23, 26, 35 /        
      DATA     ILSYM /  166 /        
      DATA     SUBR  /  4HDDRM, 4HM        /        
      DATA     EOR   ,  NOEOR  / 1,  0        /        
      DATA     CASECC,  UV, PP /  101, 102, 103 /        
      DATA     IFILE /  104, 105, 106, 107 /        
C     DATA     XYCDB ,  EST, MPT, DIT / 108, 109, 110, 111 /        
      DATA     OFILE /  201, 202, 203, 204 /        
C        
C     DETERMINE OPEN CORE AVAILABLE AND ALLOCATE BUFFERS.        
C        
      DO 5 I = 1,100        
    5 SAVDAT(I) = 0        
      DO 6 I = 6,8        
      SAVDAT(I   ) = 102        
    6 SAVDAT(I+11) = 102        
      SAVDAT(  15) = 102        
      SAVDAT(  76) = 2        
      SAVDAT(  77) = 10        
      DO 10 I = 1,7        
      SCRT(I) = I + 300        
   10 CONTINUE        
      NCORE = KORSZ(Z)        
      DO 20 I = 1,6        
      BUFF(I) = NCORE - SYSBUF - 2        
      NCORE   = BUFF(I) - 1        
   20 CONTINUE        
C        
C     GET FIRST SUBCASE OF CASE CONTROL INTO CORE        
C        
      IERROR = 0        
      SUBCAS = 1        
      ICC    = 1        
      FILE   = CASECC        
      CALL OPEN (*480,CASECC,Z(BUF1),RDREW)        
      CALL FWDREC (*490,CASECC)        
      CALL READ (*490,*30,CASECC,Z(ICC),NCORE-ICC,NOEOR,NWDS)        
      IERROR = 1        
      GO TO 510        
C        
   30 NCC = ICC + NWDS - 1        
      CALL CLOSE (CASECC,CLS)        
C        
C     READ TRAILER OF SOLUTION DATA BLOCK. IF SOLUTION IS        
C     COMPLEX, THEN FREQUENCY RESPONCE IS ASSUMED. IF REAL, THEN        
C     TRANSIENT RESPONSE IS ASSUMED.        
C        
      MCB(1) = UV        
      CALL RDTRL (MCB)        
      TRNSNT = .TRUE.        
      IF (MCB(5) .GT. 2) TRNSNT = .FALSE.        
C        
C     SET NUMBER OF EIGENVALUES = ROWS IN SOLUTION DATA BLOCK        
C        
      NLAMBS = MCB(3)        
C        
C     SET NUMBER OF SOLUTIONS.(TIME STEPS X 3, OR FREQUENCYS)        
C        
      NSOLS = MCB(2)        
C        
C     OPEN UV AND POSITION OVER HEADER RECORD.        
C        
      FILE = UV        
      CALL OPEN (*480,UV,Z(BUF1),RDREW)        
      CALL FWDREC (*490,UV)        
      CALL CLOSE (UV,CLS)        
C        
C     READ LIST OF FREQUENCYS OR TIME STEPS FROM INPUT LOAD MATRIX      
C     HEADER.        
C        
   33 ILIST = NCC + 1        
      FILE  = PP        
      CALL OPEN (*480,PP,Z(BUF1),RDREW)        
      IERROR = 2        
      CALL READ (*490,*500,PP,BUF(1),-2,NOEOR,NWDS)        
      CALL READ (*490,*35,PP,Z(ILIST),NCORE-ILIST,NOEOR,ENTRYS)        
      GO TO 510        
C        
   35 NLIST = ILIST + ENTRYS - 1        
      CALL CLOSE (PP,CLSREW)        
C        
C     IF FREQUENCY RESPONSE PROBLEM, AND USER HAS SPECIFIED A LIST OF   
C     FREQUENCYS TO BE USED AS A GUIDE IN DETERMINING A SUBSET OF       
C     SOLUTIONS FOR OUTPUT PURPOSES, AND NOT ALL SOLUTIONS WILL BE      
C     OUTPUT, THEN A MODIFIED SOLUTION MATRIX IS NOW FORMED ON        
C     SCRATCH-1. THIS WILL ELIMINATE UNNECESSARY MATRIX-MULTIPLIES LATER
C        
C     IN ANY EVENT THE NEXT SUBCASE-S SOLUTIONS ARE PLACED ON SCRT1.    
C        
      UVSOL = UV        
      IF (TRNSNT) GO TO 190        
C        
C     EXPAND LIST OF FREQS PLACING A FLAG AFTER EACH.        
C        
      J = NLIST        
      NLIST  = NLIST + ENTRYS        
      IERROR = 4        
      IF (NLIST .GT. NCORE) GO TO 510        
      K = NLIST - 1        
      DO 40 I = 1,ENTRYS        
      Z(K  ) = Z(J)        
      Z(K+1) = 0        
      K = K - 2        
      J = J - 1        
   40 CONTINUE        
C        
C     SET FLAGS OF FREQUENCYS TO BE OUTPUT.        
C        
      INDEX  = ICC + IFROUT - 1        
      FRQSET = Z(INDEX)        
      IF (FRQSET .LE. 0) GO TO 60        
      INDEX = ICC + ILSYM - 1        
      INDEX = Z(INDEX) + 1        
   50 ISETX = INDEX + 2        
      NSETX = ISETX + Z(INDEX+1) - 1        
      IF (Z(INDEX) .EQ. FRQSET) GO TO 80        
      INDEX = NSETX + 1        
      IF (INDEX .LT. NCC) GO TO 50        
      FRQSET = -1        
C        
C     ALL FREQUENCYS TO BE OUTPUT.        
C        
   60 DO 70 I = ILIST,NLIST,2        
      Z(I+1) = 1        
   70 CONTINUE        
      GO TO 110        
C        
C     COMPARE REQUESTED FREQS WITH ACTUAL FREQS.        
C        
   80 DO 100 I = ISETX,NSETX        
      K    = 0        
      DIFF = 1.0E+25        
      FRQ  = RZ(I)        
      DO 90 J = ILIST,NLIST,2        
      IF (Z(J+1) .NE. 0) GO TO 90        
      DIFF1 = ABS(RZ(J)-FRQ)        
      IF (DIFF1 .GE. DIFF) GO TO 90        
      DIFF = DIFF1        
      K    = J        
   90 CONTINUE        
      IF (K .NE. 0) Z(K+1) = 1        
  100 CONTINUE        
C        
  110 FILE = UV        
      IERROR = 5        
      CALL OPEN (*480,UV,Z(BUF1),RD)        
      FILE = SCRT1        
      CALL OPEN (*480,SCRT1,Z(BUF2),WRTREW)        
      CALL FNAME (SCRT1,FILNAM)        
      CALL WRITE (SCRT1,FILNAM,2,EOR)        
      FILE = UV        
C        
C     COPY SOLUTION COLUMNS TO BE USED BY NOTEING FREQS MARKED FOR USE. 
C        
      NSOLS    = 0        
      INBLK(1) = UV        
      OUBLK(1) = SCRT1        
      DO 150 I = ILIST,NLIST,2        
      IF (Z(I+1)) 130,120,130        
  120 CALL FWDREC (*490,UV)        
      GO TO 150        
C        
C     BLAST COPY THIS SOLUTION.        
C        
  130 ICOL = (I-ILIST)/2 + 1        
      CALL CPYSTR (INBLK,OUBLK,0,ICOL)        
      NSOLS = NSOLS + 1        
  150 CONTINUE        
C        
C     RESET -UV- DATA BLOCK DESIGNATOR TO POINT TO SCRT1, AND WRITE     
C     A TRAILER.        
C        
      CALL CLOSE (UV,CLS)        
      CALL CLOSE (SCRT1,CLSREW)        
      MCB(1) = UV        
      CALL RDTRL (MCB)        
      MCB(1) = SCRT1        
      MCB(2) = NSOLS        
      CALL WRTTRL (MCB)        
      UVSOL = SCRT1        
C        
C     SHRINK UP THE FREQUENCY LIST TO MATCH SOLUTION MATRIX        
C        
      J = ILIST - 1        
      DO  180 I = ILIST,NLIST,2        
      IF (Z(I+1)) 170,180,170        
  170 J = J + 1        
      Z(J) = Z(I)        
  180 CONTINUE        
      NLIST = J        
C        
C     IF THIS IS A TRANSIENT RESPONSE PROBLEM, THE SOLUTION MATRIX IS   
C     NOW PARTITIONED INTO 3 SOLUTION MATRICES FOR DISP, VEL, AND ACCEL.
C        
  190 IF (.NOT. TRNSNT) GO TO 260        
      FILE   = UV        
      IERROR = 6        
      CALL OPEN (*480,UV,Z(BUF1),RD)        
      MCB(1)   = UV        
      INBLK(1) = UV        
      CALL RDTRL (MCB)        
      DO  200 I = 1,3        
      FILE = SCRT(I)        
      IBUF = BUFF(I+1)        
      CALL OPEN (*480,FILE,Z(IBUF),WRTREW)        
      CALL FNAME (FILE,FILNAM)        
      CALL WRITE (FILE,FILNAM,2,EOR)        
      MCB(1) = FILE        
      MCB(2) = NSOLS/3        
      CALL WRTTRL (MCB)        
  200 CONTINUE        
      IERROR = 7        
      FILE   = UV        
      DO 240 I = 1,NSOLS,3        
      DO 230 J = 1,3        
      OUBLK(1) = SCRT(J)        
      CALL CPYSTR (INBLK,OUBLK,0,I)        
  230 CONTINUE        
  240 CONTINUE        
      CALL CLOSE (UV,CLSREW)        
      NSOLS = NSOLS/3        
C        
      DO 250 I = 1,3        
      CALL CLOSE (SCRT(I),CLSREW)        
  250 CONTINUE        
C        
C     SDR2 FORMED MODAL SOLUTIONS FOR DISPLACEMENTS, SINGLE-POINT-      
C     CONSTRAINT-FORCES, ELEMENT STRESSES, AND ELEMENT FORCES MAY BE    
C     PRESENT. (ALL WILL BE SORT1-REAL, OR SORT2-REAL)        
C        
C     IF THIS IS A TRANSIENT PROBLEM, THE SOLUTIONS PRESENT HAVE BEEN   
C     PARTITIONED INTO THE DISPLACEMENT, VELOCITY, AND ACCELERATION     
C     SUBSETS. ONLY WHEN OPERATING ON THE MODAL DISPLACEMENTS WILL THE  
C     VELOCITY AND ACCELERATION SOLUTION SUBSET MATRICES BE USED.       
C        
  260 JFILE  = 1        
  270 INFILE = IFILE(JFILE)        
C        
C     CHECK FOR EXISTENCE OF MODAL SOLUTION -INFILE-.        
C        
      CALL OPEN (*470,INFILE,Z(BUF1),RDREW)        
      CALL FWDREC (*460,INFILE)        
C        
C     INFILE DOES EXIST.SET PARAMETERS FOR PROCESSING        
C        
C        
C     OPEN OFP-FORMAT OUTPUT FILE FOR THIS INFILE.        
C        
      OUTFIL = OFILE(JFILE)        
      IWRT = WRTREW        
      IF (SUBCAS .GT. 1) IWRT = WRT        
      CALL OPEN (*280,OUTFIL,Z(BUF4),IWRT)        
      IF (SUBCAS .GT. 1) GO TO 305        
      GO TO 300        
  280 WRITE  (OUTPT,290) UWM,INFILE        
  290 FORMAT (A25,' 2331. (DDRMM-2) OUTPUT DATA BLOCK CORRESPONDING TO',
     1       ' INPUT MODAL SOLUTION DATA BLOCK',I4, /5X,        
     2       'IS NOT PRESENT.  INPUT DATA BLOCK IGNORED.')        
      GO TO 460        
C        
  300 CALL FNAME (OUTFIL,FILNAM)        
      CALL WRITE (OUTFIL,FILNAM,2,EOR)        
  305 CALL CLOSE (OUTFIL,CLS)        
C        
C     READ FIRST OFP-ID RECORD AND DETERMINE WHAT THE HELL IS REALLY    
C     PRESENT.        
C        
      IERROR = 14        
      CALL READ (*460,*460,INFILE,IDREC,146,EOR,NWDS)        
C        
C     MAJOR ID AND SORT1 OR SORT2 DETERMINATION.        
C        
      ITYPE1 = IDREC(2)/1000        
      SORT2  = .FALSE.        
      IF (ITYPE1 .GT. 1) SORT2 = .TRUE.        
      ITYPE1 = IDREC(2) - ITYPE1*1000        
C        
C     BRANCH ON MAJOR ID        
C        
      IF (ITYPE1.LT.1 .OR. ITYPE1.GT.7) GO TO 410        
      PASSES = 1        
      GO TO (410,410,370,380,390,410,310), ITYPE1        
C        
C     MODAL DISPLACEMENTS = EIGENVECTORS ARE ON INFILE.        
C        
  310 PASSES = 3        
      NWORDS = 2        
C        
C     DETERMINE DISP, VEL, AND ACCEL SET REQUESTS.        
C        
  312 IBASE = ICC + ILSYM - 1        
      IBASE = Z(IBASE) + 1        
      DO 350 I = 1,PASSES        
      IF (PASSES .EQ. 1) GO TO 315        
      ITEMP = ICC + DVA(I) - 1        
  315 SETS(1,I) = Z(ITEMP)        
      SETS(2,I) = Z(ITEMP+1)        
      SETS(3,I) = IABS(Z(ITEMP+2))        
      SETS(4,I) = 0        
      SETS(5,I) = 0        
      IF (SETS(1,I)) 350,350,320        
  320 INDEX = IBASE        
  330 ISETX = INDEX + 2        
      IF (Z(INDEX) .EQ. SETS(1,I)) GO TO 340        
      INDEX = ISETX + Z(INDEX+1)        
      IF (INDEX .LT. NCC) GO TO 330        
      SETS(1,I) = -1        
      GO TO 350        
  340 SETS(4,I) = ISETX        
      SETS(5,I) = Z(INDEX+1)        
  350 CONTINUE        
      GO TO 430        
C        
C     MODAL SPCF-S ARE ON INFILE.        
C        
  370 ITEMP  = ICC + ISPCF - 1        
      NWORDS = 2        
      GO TO 312        
C        
C     MODAL FORCES ARE ON INFILE.        
C        
  380 ITEMP  = ICC + IFORCE - 1        
      NWORDS = 1        
      GO TO 312        
C        
C     MODAL STRESSES ARE ON INFILE.        
C        
  390 ITEMP  = ICC + ISTRES - 1        
      NWORDS = 1        
      GO TO 312        
C        
C     ILLEGAL INFILE DATA.        
C        
  410 WRITE  (OUTPT,420) UWM,INFILE        
  420 FORMAT (A25,' 2332.  (DDRMM-4) INVALID INPUT DATA DETECTED IN ',  
     1       'DATA BLOCK',I5,'. PROCESSING STOPPED FOR THIS DATA BLOCK')
      GO TO 460        
C        
C     CALL PROCESSOR TO BUILD DATA-MATRIX ON SCRT5 AND MAPPING-DATA ON  
C     SCRT4, AND THEN PERFORM OUTPUT OF RESULTS TO OUTFIL.        
C        
  430 IF (SORT2) GO TO 440        
C        
C     SORT1 PROCESSOR        
C        
      CALL DDRMM1 (*480,*490,*500,*510)        
      GO TO 450        
C        
C     SORT2 PROCESSOR        
C        
  440 CALL DDRMM2 (*480,*490,*500,*510)        
C        
C     WRAP UP PROCESSING FOR THIS INFILE.        
C        
  450 MCB(1) = OUTFIL        
      MCB(2) = 1        
      CALL WRTTRL (MCB)        
  460 CALL CLOSE (OUTFIL,CLSREW)        
      CALL CLOSE (INFILE,CLSREW)        
      CALL CLOSE (SCRT4, CLSREW)        
      CALL CLOSE (SCRT5, CLSREW)        
C        
C     PROCESS NEXT MODAL SOLUTION INPUT.        
C        
  470 JFILE = JFILE + 1        
      IF (JFILE .LE. 4) GO TO 270        
C        
C     ALL WORK COMPLETE FOR THIS SUBCASE. IF FREQUENCY RESPONSE PROCESS 
C     NEXT SUBCASE.        
C        
      IF (TRNSNT) GO TO 479        
      FILE   = CASECC        
      IERROR = 471        
      CALL OPEN (*480,CASECC,Z(BUF1),RD)        
      CALL READ (*479,*472,CASECC,Z(ICC),NCORE-ICC,NOEOR,NWDS)        
      GO TO 510        
C        
  472 NCC    = ICC + NWDS - 1        
      SUBCAS = SUBCAS + 1        
      CALL CLOSE (CASECC,CLS)        
      GO TO 33        
C        
C//// SUBCAS  NUMBER NEEDS TO GET INTO OUTPUT BLOCKS        
C        
  479 IERROR = 511        
      CALL CLOSE (CASECC,CLSREW)        
      GO TO 560        
C        
C     ERRORS FORCING TERMINATION OF THIS MODULE.        
C        
  480 KK = 1        
      GO TO 520        
  490 KK = 2        
      GO TO 520        
  500 KK = 3        
      GO TO 520        
  510 KK = 8        
      GO TO 520        
  520 CALL MESAGE (KK,FILE,SUBR)        
      WRITE  (OUTPT,530) SWM,IERROR        
  530 FORMAT (A27,' 2333.  (DDRMM-1) MODULE DDRMM TERMINATED WITH ',    
     1       'VARIABLE IERROR =',I10)        
C        
C     INSURE ALL FILES CLOSED BEFORE RETURNING.        
C        
      DO 550 L = 100,300,100        
      DO 540 M = 1,11        
      JFILE = M + L        
      CALL CLOSE (JFILE,CLSREW)        
  540 CONTINUE        
  550 CONTINUE        
C        
C     INSURE ALL OUT-FILES HAVE AN EOF.        
C        
  560 DO 570 L = 201,204        
      CALL OPEN (*570,L,Z(BUF1),WRT)        
      CALL CLOSE (L,CLSREW)        
  570 CONTINUE        
      RETURN        
      END        
