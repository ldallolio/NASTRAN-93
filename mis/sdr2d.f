      SUBROUTINE SDR2D        
C        
C     SDR2D PERFORMS THE FINAL STRESS AND FORCE RECOVERY COMPUTATIONS.  
C     CASE CONTROL AND THE DISPLACEMENT VECTOR FILE ARE PROCESSED IN    
C     PARALLEL.  THE ESTA IS PASSED ONCE FOR EACH VECTOR IN UGV FOR     
C     WHICH A STRESS OR FORCE OUTPUT REQUEST EXISTS.  THE ESTA IS HELD  
C     COMPLETELY IN CORE IF POSSIBLE.  STRESS OUTPUT IS WRITTEN ON OES1.
C     FORCE OUTPUT IS WRITTEN ON OEF1.        
C        
      LOGICAL         AXIC     ,AXSINE   ,AXCOSI   ,EOFCC        
C    1,               IDSTRS   ,IDFORC   ,ILOGIC(2)        
      INTEGER         STRESX   ,FORCEX   ,UGVVEC   ,ESTAWD   ,ELTYPE  , 
     1                TLOAD    ,ELDEF    ,ELEMID   ,GPTT     ,OES1    , 
     2                OEF1     ,OEIGR    ,ESTA     ,EDT      ,ELESTA  , 
     3                KDEFRM(2),APP      ,SORT2    ,SPCF     ,DISPL   , 
     4                VEL      ,ACC      ,STRESS   ,FORCE    ,CSTM    , 
     5                CASECC   ,EQEXIN   ,SIL      ,BGPDT    ,PG      , 
     6                QG       ,UGV      ,PHIG     ,EIGR     ,OPG1    , 
     7                OQG1     ,OUGV1    ,OCB      ,BUF(50)  ,DTYPE   , 
     8                FILE     ,BUF1     ,BUF2     ,BUF3     ,BUF4    , 
     9                BUF5     ,BUF6     ,BUF7     ,SYMFLG   ,OUTFL   , 
     O                STA      ,REI      ,DS0      ,DS1      ,FRQ     , 
     1                TRN      ,BK0      ,BRANCH   ,SYSBUF   ,        
     2                DATE     ,PLOTS    ,QTYPE2   ,EOL      ,BK1     , 
     3                TIME     ,SETNO    ,FSETNO   ,Z        ,RETX    , 
     4                FORMT    ,FLAG     ,EOF      ,CEI      ,PLA     , 
     5                BUFA     ,BUFB     ,OFILE    ,DEVICE   ,OEF1L   , 
     6                PUGV1    ,XSETNS   ,SDEST    ,BUF8     ,OES1L   , 
     7                OPTE     ,XSET0    ,XSETNF   ,FDEST    ,PCOMPS  , 
     8                SORC     ,TLOADS   ,TMPREC   ,ITR(7)   ,COMPS     
      INTEGER         PCOMP(2) ,PCOMP1(2),PCOMP2(2),BUF0     ,BUFM1   , 
     1                NMES1L(2),NMEF1L(2)        
      REAL            ZZ(1)    ,BUFR(2)        
      CHARACTER       UFM*23   ,UWM*25        
      COMMON /XMSSG / UFM      ,UWM        
      COMMON /BLANK / APP(2)   ,SORT2    ,IDUM(2)  ,COMPS        
      COMMON /SDR2C1/ IPCMP    ,NPCMP    ,IPCMP1   ,NPCMP1   ,IPCMP2  , 
     1                NPCMP2   ,NSTROP        
      COMMON /SDR2X1/ IEIGEN   ,IELDEF   ,ITLOAD   ,ISYMFL   ,ILOADS  , 
     1                IDISPL   ,ISTR     ,IELF     ,IACC     ,IVEL    , 
     2                ISPCF    ,ITTL     ,ILSYM    ,IFROUT   ,ISLOAD  , 
     3                IDLOAD   ,ISORC        
      COMMON /SDR2X2/ CASECC   ,CSTM     ,MPT      ,DIT      ,EQEXIN  , 
     1                SIL      ,GPTT     ,EDT      ,BGPDT    ,PG      , 
     2                QG       ,UGV      ,EST      ,PHIG     ,EIGR    , 
     3                OPG1     ,OQG1     ,OUGV1    ,OES1     ,OEF1    , 
     4                PUGV1    ,OEIGR    ,OPHIG    ,PPHIG    ,ESTA    , 
     5                GPTTA    ,HARMS    ,XYCDB    ,SCR3     ,PCOMPS  , 
     6                OES1L    ,OEF1L        
      COMMON /SDR2X4/ NAM(2)   ,END      ,MSET     ,ICB(7)   ,OCB(7)  , 
     1                MCB(7)   ,DTYPE(8) ,ICSTM    ,NCSTM    ,IVEC    , 
     2                IVECN    ,TEMP     ,DEFORM   ,FILE     ,BUF1    , 
     3                BUF2     ,BUF3     ,BUF4     ,BUF5     ,ANY     , 
     4                ALL      ,TLOADS   ,ELDEF    ,SYMFLG   ,BRANCH  , 
     5                KTYPE    ,LOADS    ,SPCF     ,DISPL    ,VEL     , 
     6                ACC      ,STRESS   ,FORCE    ,KWDEST   ,KWDEDT  , 
     7                KWDGPT   ,KWDCC    ,NRIGDS   ,STA(2)   ,REI(2)  , 
     8                DS0(2)   ,DS1(2)   ,FRQ(2)   ,TRN(2)   ,BK0(2)  , 
     9                BK1(2)   ,CEI(2)   ,PLA(22)  ,NRINGS   ,NHARMS  , 
     O                AXIC     ,KNSET    ,ISOPL    ,STRSPT   ,DDRMM   , 
     1                ISOPL8        
      COMMON /SDR2X7/ ELESTA(100)        ,BUFA(100),BUFB(4076)        
      COMMON /SDR2X8/ ELWORK(300)        
CZZ   COMMON /ZZSDR2/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /NAMES / RD       ,RDREW    ,WRT      ,WRTREW   ,CLSREW    
      COMMON /SYSTEM/ SYSBUF   ,OPTE     ,NOGO     ,INTAP    ,MPCN    , 
     1                SPCN     ,METHOD   ,LOADNN   ,SYMM     ,STFTMP  , 
     2                PAGE     ,LINE     ,TLINE    ,MAXLIN   ,DATE(3) , 
     3                TIME     ,ECHO     ,PLOTS    ,DUM23(35),IHEAT     
      COMMON /UNPAKX/ QTYPE2   ,I2       ,J2       ,INCR2        
      COMMON /ZNTPKX/ XX(4)    ,IXX      ,EOL      ,EOR        
      COMMON /ZBLPKX/ Y(4)     ,IY        
      COMMON /SDR2DE/ BUF6     ,COEF     ,DEFTMP   ,DIFF     ,DIFF1   , 
     1                DEVICE   ,ESTAWD   ,ELEMID   ,ELTYPE   ,EOF     , 
     2                EOFCC    ,IREQX    ,FLAG     ,FN       ,FORCEX  , 
     3                FSETNO   ,FORMT    ,ICC      ,I        ,IEDT    , 
     4                ISETNO   ,ISETF    ,ISETS    ,IDEF     ,ISYMN   , 
     5                SDEST    ,IX       ,ISETNF   ,ISEQ     ,IRETRN  , 
     6                IRECX    ,ISAVE    ,FDEST    ,IPART    ,ILIST   , 
     7                IGPTTA   ,ICORE    ,IELEM    ,IESTA    ,BUF8    , 
     8                JFORC    ,JSTRS    ,JANY     ,JLIST    ,J       , 
     9                KTYPE1   ,KHI      ,KX       ,K        ,KLO     , 
     O                KN       ,KTYPEX   ,KFRQ     ,KCOUNT   ,LSYM    , 
     1                M        ,MIDVEC   ,NWDSA    ,NWDSTR   ,NLOGIC  , 
     2                NWDS     ,NDEF     ,N        ,N1       ,N2      , 
     3                NOTSET   ,NSETS    ,NSETF    ,NWORDS   ,NX      , 
     4                TGRID(4) ,NWDFOR   ,NGPTT    ,NESTA    ,NVECTS  , 
     5                NLIST    ,OFILE    ,OUTFL    ,RETX     ,SETNO   , 
     6                STRESX   ,SAVE     ,TLOAD    ,UGVVEC   ,IXSETS  , 
     7                NXSETS   ,IXSETF   ,NXSETF   ,XSETNS   ,XSETNF  , 
     8                SORC     ,TMPREC   ,BUF7     ,TGRD(33)        
      EQUIVALENCE     (BUF(1),BUFR(1))   ,(Z(1),ZZ(1))        
C    1,               (IDSTRS,ILOGIC(1)) ,(IDFORC,ILOGIC(2))        
      DATA    BUF   / 50*0/, KDEFRM/104,1/, XSET0/100000000/        
      DATA    NMES1L/ 4HOES1, 4HL   /    ,NMEF1L  / 4HOEF1, 4HL   /     
      DATA    PCOMP /  5502,  55    /,        
     1        PCOMP1/  5602,  56    /,        
     2        PCOMP2/  5702,  57    /        
C        
C     PERFORM GENERAL INITIALIZATION        
C        
      BUFM1  = KORSZ(Z) - SYSBUF + 1        
      BUF0   = BUFM1 - SYSBUF - 1        
      BUF1   = BUF0  - SYSBUF - 1        
      IF (COMPS .NE. -1) BUF1 = BUFM1        
      BUF2   = BUF1  - SYSBUF - 1        
      I2     = 1        
      INCR2  = 1        
      ICC    = 0        
      ILIST  = 1        
      NLIST  = 0        
      JLIST  = 1        
      KFRQ   = 0        
      AXSINE = .FALSE.        
      AXCOSI = .FALSE.        
      SORC   = 0        
C        
C     READ TRAILER ON INPUT FILE. SET PARAMETERS.        
C        
      ICB(1) = UGV        
      CALL RDTRL (ICB)        
      IF (ICB(1) .NE. UGV) GO TO 770        
      NVECTS = ICB(2)        
      IF (ICB(5) .GT. 2) GO TO 10        
C        
C     REAL VECTOR.        
C        
      KTYPE  = 1        
      QTYPE2 = 1        
      KTYPE1 = 2        
      NWDS   = 8        
      KTYPEX = 0        
      GO TO 20        
C        
C     COMPLEX VECTOR.        
C        
   10 KTYPE  = 2        
      QTYPE2 = 3        
      KTYPE1 = 3        
      NWDS   = 14        
      KTYPEX = 1000        
C        
C     OPEN CASE CONTROL AND SKIP HEADER. THEN BRANCH ON APPROACH.       
C        
   20 FILE  = CASECC        
      CALL OPEN (*740,CASECC,Z(BUF1),RDREW)        
      CALL FWDREC (*750,CASECC)        
      EOFCC = .FALSE.        
C        
      GO TO (100, 30,100, 60, 70, 70,100, 60, 30,100), BRANCH        
C            STA,REI,DS0,DS1,FRQ,TRN,BK0,BK1,CEI,PLA        
C        
C     EIGENVALUES - READ LIST OF MODE NOS. AND EIGENVALUES INTO CORE.   
C     BUCKLING POSSIBLE HERE TOO        
C        
   30 FILE = EIGR        
      CALL OPEN (*740,EIGR,Z(BUF2),RDREW)        
      CALL FWDREC (*750,EIGR)        
      CALL FWDREC (*750,EIGR)        
      I = ILIST        
      M = 8 - KTYPE        
      ISKIP = 0        
      INDEX = 2        
      IF (APP(1) .NE. REI(1)) GO TO 40        
C        
C     CHECK TO SEE IF ALL GENERALIZED MASS VALUES ARE ZERO        
C        
   35 CALL READ (*750,*37,EIGR,BUF,M,0,FLAG)        
      IF (BUF(6) .EQ. 0.0) GO TO 35        
      INDEX = 0        
   37 CALL SKPREC (EIGR,-1)        
   40 CALL READ (*750,*50,EIGR,BUF(1),M,0,FLAG)        
      IF (APP(1) .NE. REI(1)) GO TO 45        
      IF (INDEX .EQ. 2) GO TO 45        
C        
C     MATCH CORRECT MODE NOS. AND EIGENVALUES WITH PROPER        
C     FORCES AND STRESSES WHEN USING GIVENS METHOD WITH F1.GT.0.0       
C        
      IF (INDEX .EQ. 1) GO TO 45        
      IF (BUF(6) .NE. 0.0) GO TO 43        
      ISKIP  = ISKIP + 1        
      GO TO 40        
   43 INDEX  = 1        
   45 Z(I  ) = BUF(1) - ISKIP        
      Z(I+1) = BUF(3)        
      Z(I+2) = BUF(4)        
      I      = I + KTYPE1        
      GO TO 40        
   50 CALL CLOSE (EIGR,CLSREW)        
      NLIST  = I - KTYPE1        
      ICC    = I        
      GO TO 100        
C        
C     DIFF. STIFF. PHASE 1 OR BUCKLING PHASE 1 - SKIP 1ST DATA RECORD ON
C     CC.        
C        
   60 CALL FWDREC (*750,CASECC)        
      IF (APP(1) .EQ. BK1(1)) GO TO 30        
      GO TO 100        
C        
C     FREQUENCY OR TRANSIENT RESPONSE - READ LIST INTO CORE.        
C        
   70 FILE = PG        
      CALL OPEN (*740,FILE,Z(BUF2),RDREW)        
      I  = ILIST        
      M  = 3        
      IX = 1        
      IF (APP(1).EQ.FRQ(1) .OR. APP(1).EQ.TRN(1)) IX = 2        
   80 CALL READ (*750,*90,FILE,BUF(1),M,0,FLAG)        
      Z(I  ) = BUF(M)        
      Z(I+1) = 0        
      I = I + IX        
      M = 1        
      GO TO 80        
   90 CALL CLOSE (FILE,CLSREW)        
      NLIST = I - IX        
      ICC   = I        
C        
C     ALLOCATE CORE FOR CASE CONTROL, EDT, GPTT, ESTA, VECTOR        
C     BALANCE OF REQUIRED BUFFERS        
C       BUF1 = CASECC     BUF5 = GPTT        
C       BUF2 = VECTOR     BUF6 = EDT        
C       BUF3 = OES1       BUF7 = EQEXIN        
C       BUF4 = OEF1       BUF8 = ESTA        
C     SOME OF THE ABOVE MAY NOT BE REQUIRED AND THUS WILL NOT BE        
C     ALLOCATED..        
C        
  100 BUF3 = BUF2 - SYSBUF - 1        
      IF (STRESS .EQ. 0) BUF3 = BUF2        
      BUF4 = BUF3 - SYSBUF - 1        
      IF (FORCE  .EQ. 0) BUF4 = BUF3        
      BUF5 = BUF4 - SYSBUF - 1        
      IF (TLOADS .EQ. 0) BUF5 = BUF4        
      BUF6 = BUF5 - SYSBUF - 3        
      IF (KWDEDT .EQ. 0) BUF6 = BUF5        
      BUF7 = BUF6 - SYSBUF - 1        
      IF (ISOPL .EQ. 0) BUF7 = BUF6        
      BUF8 = BUF7 - SYSBUF - 1        
C        
C     IF COMPOSITE ELEMENTS ARE PRESENT, READ PCOMPS INTO CORE        
C        
      IF (COMPS .NE. -1) GO TO 109        
      FILE   = PCOMPS        
      N      = -1        
      CALL PRELOC (*760,Z(BUF2),PCOMPS)        
      IPCMP  = ICC + 1        
      IPCMP1 = IPCMP        
      IPCMP2 = IPCMP        
      NPCMP  = 0        
      NPCMP1 = 0        
      NPCMP2 = 0        
      N      = -2        
C        
      CALL LOCATE (*106,Z(BUF2),PCOMP,IDX)        
      CALL READ (*760,*106,PCOMPS,Z(IPCMP),BUF2-IPCMP,1,NPCMP)        
      CALL MESAGE (-8,0,NAM)        
  106 IPCMP1 = IPCMP1 + NPCMP        
      IPCMP2 = IPCMP1        
C        
      CALL LOCATE (*107,Z(BUF2),PCOMP1,IDX)        
      CALL READ (*760,*107,PCOMPS,Z(IPCMP1),BUF2-IPCMP1,1,NPCMP1)       
      CALL MESAGE (-8,0,NAM)        
  107 IPCMP2 = IPCMP2 + NPCMP1        
C        
      CALL LOCATE (*108,Z(BUF2),PCOMP2,IDX)        
      CALL READ (*760,*108,PCOMPS,Z(IPCMP2),BUF2-IPCMP2,1,NPCMP2)       
      CALL MESAGE (-8,0,NAM)        
  108 ICC = IPCMP2 + NPCMP2 - 1        
C        
      CALL CLOSE (PCOMPS,CLSREW)        
C        
C     IF ESTA FITS IN CORE BUF8 MAY BE BUF7 SINCE IT WILL ONLY BE USED  
C     TO READ ESTA IN ONCE..        
C        
  109 IEDT   = ICC + KWDCC + 1        
      IGPTTA = IEDT + KWDEDT        
      ITR(1) = EQEXIN        
      CALL RDTRL (ITR)        
      NEQEX  = 2*ITR(2)        
      IF (ISOPL8 .NE. 8) NEQEX = 0        
      IEQEX  = IGPTTA + KWDGPT        
      IVEC   = IEQEX + NEQEX        
      IVECN  = IVEC + KTYPE*ICB(3) - 1        
C        
C     IF CONICAL SHELL DOUBLE VECTOR SPACE        
C        
      IF (AXIC .AND. KTYPE.EQ.1) IVECN = IVECN + ICB(3)*KTYPE        
      IESTA  = IVECN + 1        
      MIDVEC = (IVEC+IVECN)/2 + 1        
      IF (AXIC .AND. KTYPE.EQ.1) MIDVEC = 0        
      IF (AXIC .AND. KTYPE.EQ.1) IVECN  = IVECN - ICB(3)*KTYPE        
      IF (KWDEST .LE. (BUF7-IESTA)) BUF8 = BUF7        
C        
C     OPEN ESTA        
C        
      FILE = ESTA        
      CALL OPEN (*740,ESTA,Z(BUF8),RDREW)        
C        
C     REMAINING CORE        
C        
      ICORE = BUF8 - IESTA        
      NESTA = 0        
C        
C     WILL ESTA FIT IN CORE        
C        
      IF (ICORE .LE. 0) CALL MESAGE (-8,0,NAM)        
      IF (KWDEST .GT. ICORE) GO TO 140        
C        
C     ESTA WILL FIT. READ IT IN PLACING A ZERO WORD AT END OF EACH      
C     RECORD.        
C        
      I = IESTA        
  110 CALL READ (*130,*120,ESTA,Z(I),ICORE,1,NWORDS)        
      CALL REWIND (ESTA)        
      ICORE = BUF8 - IESTA        
      GO TO 140        
  120 I = I + NWORDS + 1        
      Z(I-1) = 0        
      ICORE = ICORE - NWORDS - 1        
      GO TO 110        
C        
C     ALL ESTA NOW IN CORE        
C        
  130 NESTA = I - 1        
      CALL CLOSE (ESTA,CLSREW)        
      IF (NESTA .GT. IESTA) GO TO 140        
      WRITE  (OPTE,135) UWM        
  135 FORMAT (A25,' 3303, STRESSES OR FORCES REQUESTED FOR SET(S) ',    
     1       'WHICH CONTAIN NO VALID ELEMENTS.')        
      GO TO 640        
C        
C     OPEN INPUT FILE. SKIP HEADER RECORD.        
C        
  140 FILE  = UGV        
      CALL OPEN (*740,UGV,Z(BUF2),RDREW)        
      CALL FWDREC (*750,UGV)        
C        
C     IF ANY ISOPARAMETRIC ELEMENTS PRESENT, GET SECOND RECORD OF EQEXIN
C        
      IF (ISOPL .EQ. 0) GO TO 148        
      FILE = EQEXIN        
      CALL OPEN (*740,EQEXIN,Z(BUF7),RDREW)        
      CALL FWDREC (*750,EQEXIN)        
      CALL FWDREC (*750,EQEXIN)        
      ISOPL = EQEXIN        
      IF (ISOPL8 .NE. 8) GO TO 145        
      CALL FREAD (EQEXIN,Z(IEQEX),NEQEX,0)        
      CALL BCKREC (EQEXIN)        
  145 CONTINUE        
C        
C     IF ANY STRESS OUTPUT IS REQUESTED,        
C     OPEN OES1 AND WRITE HEADER RECORD        
C        
  148 IF (STRESS .EQ. 0) GO TO 155        
      FILE = OES1        
      CALL OPEN (*151,OES1,Z(BUF3),WRTREW)        
      CALL FNAME (OES1,OCB)        
      DO 150 I = 1,3        
  150 OCB(I+2) = DATE(I)        
      OCB(6) = TIME        
      OCB(7) = 1        
      CALL WRITE (OES1,OCB,7,1)        
      GO TO 155        
  151 CALL MESAGE (1,OES1,NAM)        
      STRESS = 0        
C        
C     IF ANY STRESS OR FORCE OUTPUT IS REQUESTED AND COMPOSITE ELEMENTS 
C     ARE PRESENT, OPEN OES1L AND OEF1L AND WRITE HEADER RECORDS        
C        
  155 IF (COMPS.NE.-1 .OR. (STRESS.EQ.0 .AND. FORCE.EQ.0)) GO TO 160    
      ILAYER = 0        
      FILE   = OES1L        
      CALL OPEN (*158,OES1L,Z(BUFM1),WRTREW)        
      CALL WRITE (OES1L,NMES1L,2,1)        
      FILE = OEF1L        
      CALL OPEN (*158,OEF1L,Z(BUF0),WRTREW)        
      CALL WRITE (OEF1L,NMEF1L,2,1)        
      GO TO 160        
  158 CALL MESAGE (1,FILE,NAM)        
      STRESS = 0        
      FORCE  = 0        
C        
C     IF ANY FORCE OUTPUT IS REQUESTED,        
C     OPEN OEF1 AND WRITE HEADER RECORD        
C        
  160 IF (FORCE .EQ. 0) GO TO 180        
      FILE = OEF1        
      CALL OPEN (*171,OEF1,Z(BUF4),WRTREW)        
      CALL FNAME (OEF1,OCB)        
      DO 170 I = 1,3        
  170 OCB(I+2) = DATE(I)        
      OCB(6) = TIME        
      OCB(7) = 1        
      CALL WRITE (OEF1,OCB,7,1)        
      GO TO 180        
  171 CALL MESAGE (1,OEF1,NAM)        
      FORCE = 0        
  180 IF (STRESS.EQ.0 .AND. FORCE.EQ.0) GO TO 640        
C        
C     INITIALIZE UGV VEC, WHICH WILL BE THE NUMBER OF THE VECTOR WE     
C     ARE NOW POSITIONED TO READ.        
C        
      UGVVEC = 1        
      ISVVEC = IVEC        
      ISVVCN = IVECN        
      IFLAG  = 0        
C        
C     READ A RECORD IN CASE CONTROL. SET SYMMETRY FLAG.        
C        
  190 CALL READ (*610,*200,CASECC,Z(ICC+1),KWDCC+1,1,FLAG)        
      CALL MESAGE (8,0,NAM)        
      GO TO 640        
  200 IX  = ICC + ISYMFL        
      SYMFLG = Z(IX)        
      NCC = ICC + FLAG        
C        
C     FOR CONICAL SHELL SET SORC FLAG        
C        
      IX = ICC + ISORC        
      IF (IFLAG  .EQ. 1) SORC   = ISVSRC        
      IF (SYMFLG .EQ. 0) SORC   = Z(IX)        
      IF (SORC   .EQ. 1) AXSINE = .TRUE.        
      IF (SORC   .EQ. 2) AXCOSI = .TRUE.        
      IF (AXIC .AND. SYMFLG.EQ.0) ISVSRC = SORC        
      IVEC  = ISVVEC        
      IVECN = ISVVCN        
      IFLAG = 0        
      IF (AXIC .AND. AXSINE .AND. AXCOSI .AND. UGVVEC.EQ.3) IFLAG = 1   
      IF (AXIC .AND. SORC.EQ.0) GO TO 620        
C        
C     DETERMINE IF OUTPUT REQUEST IS PRESENT.        
C     IF NOT, TEST FOR RECORD SKIP ON UGV THEN GO TO END OF THIS        
C     REQUEST. IF SO, SET POINTERS TO SET DEFINING REQUEST.        
C        
  210 IX = ICC + ISTR        
      STRESX = Z(IX  )        
      SDEST  = Z(IX+1)        
      XSETNS = -1        
      IX     = ICC + IELF        
      FORCEX = Z(IX  )        
      FDEST  = Z(IX+1)        
      XSETNF = -1        
      NSTROP = Z(ICC+183)        
C        
C     DEBUG PRINTOUT        
C        
C     WRITE  (OPTE,215) NSTROP        
C 215 FORMAT (' SDR2D - NSTROP = ', I5)        
C        
      IF (COMPS.EQ.-1 .AND. NSTROP.GT.1) ILAYER = ILAYER + 1        
      IF (STRESX) 240,240,220        
  220 IX = ICC + ILSYM        
      ISETNO = IX + Z(IX) + 1        
  230 ISETS  = ISETNO + 2        
      NSETS  = Z(ISETNO+1) + ISETS - 1        
      IF (Z(ISETNO) .EQ. STRESX) GO TO 235        
      ISETNO = NSETS + 1        
      IF (ISETNO .LE. NCC) GO TO 230        
      STRESX = -1        
      GO TO 240        
C        
C     IF REQUIRED, LOCATE PRINT/PUNCH SUBSET FOR STRESSES        
C        
  235 IF (STRESX .LT. XSET0) GO TO 240        
      XSETNS = SDEST/10        
      SDEST  = SDEST - 10*XSETNS        
      IF (XSETNS .EQ. 0) GO TO 240        
      IXSTNS = IX + Z(IX) + 1        
  236 IXSETS = IXSTNS + 2        
      NXSETS = Z(IXSTNS+1) + IXSETS - 1        
      IF (Z(IXSTNS) .EQ. STRESX) GO TO 240        
      IXSTNS = NXSETS + 1        
      IF (IXSTNS .LT. NCC) GO TO 236        
      STRESX = -1        
  240 IF (FORCEX) 270,270,250        
  250 IX = ICC + ILSYM        
      ISETNO = IX + Z(IX) + 1        
  260 ISETF  = ISETNO + 2        
      NSETF  = Z(ISETNO+1) + ISETF - 1        
      IF (Z(ISETNO) .EQ. FORCEX) GO TO 265        
      ISETNO = NSETF + 1        
      IF (ISETNO .LE. NCC) GO TO 260        
      FORCEX = -1        
      GO TO 290        
C        
C     IF REQUIRED, LOCATE PRINT/PUNCH SUBSET FOR FORCES        
C        
  265 IF (FORCEX .LT. XSET0) GO TO 290        
      XSETNF = FDEST/10        
      FDEST  = FDEST - 10*XSETNF        
      IF (XSETNF .EQ. 0) GO TO 290        
      IXSTNF = IX + Z(IX) + 1        
  266 IXSETF = IXSTNF + 2        
      NXSETF = Z(IXSTNF+1) + IXSETF - 1        
      IF (Z(IXSTNF) .EQ. FORCEX) GO TO 290        
      IXSTNF = NXSETF + 1        
      IF (IXSTNF .LT. NCC) GO TO 266        
      FORCEX = -1        
  270 IF (STRESX.NE.0 .OR. FORCEX.NE.0 .OR. AXIC) GO TO 290        
C        
C     NO REQUESTS THIS CC RECORD FOR STRESSES OR FORCES.        
C     THUS SKIP CORRESPONDING UGV RECORD UNLESS SYMFLG IS ON, IN WHICH  
C     CASE WE SKIP NO UGV RECORD SINCE THE SYMMETRY CASE HAS NO UGV     
C     VECTOR, BUT IN FACT WOULD HAVE USED A SUMMATION OF THE IMMEDIATELY
C     PRECEEDING LSYM VECTORS.        
C        
C     IF END OF CC AND NO STRESS OR FORCE OUTPUT REQUEST WE ARE DONE    
C        
      IF (EOFCC ) GO TO 620        
      IF (SYMFLG) 190,280,190        
  280 CALL FWDREC (*750,UGV)        
      UGV VEC = UGV VEC + 1        
      GO TO 570        
C        
C     THERE IS A REQUEST FOR STRESSES AND OR FORCES        
C     FIRST DETERMINE APPROPRIATE GPTT AND EDT RECORDS IF REQUIRED      
C        
  290 IX     = ICC + ITLOAD        
      TLOADS = Z(IX)        
      NGPTT  = 0        
      IF (TLOADS .EQ. 0) GO TO 370        
      FILE   = GPTT        
      CALL CLOSE (GPTT,CLSREW)        
      CALL OPEN (*740,GPTT,Z(BUF5),RDREW)        
C        
C     SKIP NAME        
C        
      CALL READ (*750,*751,GPTT,BUF,2,0,N)        
C        
C     PICK UP 3 WORDS OF SET INFORMATION        
C        
  295 CALL READ (*750,*751,GPTT,BUF,3,0,N)        
      IF (BUF(1) .NE. TLOADS) GO TO 295        
      DEFTMP = BUFR(2)        
      TMPREC = BUF(3)        
C        
  370 IX    = ICC + IELDEF        
      ELDEF = Z(IX)        
      IF (ELDEF.EQ.0 .OR. KWDEDT.EQ.0) GO TO 430        
      FILE  = EDT        
      CALL PRELOC (*740,Z(BUF6),EDT)        
      CALL LOCATE (*390,Z(BUF6),KDEFRM,FLAG)        
      IDEF  = IEDT        
      I     = IDEF        
  380 CALL READ (*750,*390,EDT,BUF(1),3,0,FLAG)        
      IF (BUF(1) .EQ. ELDEF) GO TO 410        
      GO TO 380        
  390 BUF(1) = ELDEF        
      BUF(2) = 0        
      CALL MESAGE (-30,46,BUF)        
  400 CALL READ (*750,*420,EDT,BUF(1),3,0,FLAG)        
      IF (BUF(1) .NE. ELDEF) GO TO 420        
  410 Z(I  ) = BUF(2)        
      Z(I+1) = BUF(3)        
      I = I + 2        
      IF (I .LT. IGPTTA) GO TO 400        
      CALL MESAGE (-8,0,NAM)        
  420 NDEF = I - 2        
      CALL CLOSE (EDT,CLSREW)        
C        
C     UNPACK VECTOR INTO CORE        
C        
  430 COEF1 = 1.0        
      IF (SYMFLG .EQ. 0) GO TO 490        
C        
C     SYMMETRY SEQUENCE-- BUILD VECTOR IN CORE.        
C        
      IX   = ICC + ILSYM        
      LSYM = Z(IX)        
C        
C     IF SYMFLG IS NEGATIVE, THIS IS A REPEAT SUBCASE.  USE PRESENT     
C     VECTOR IN CORE.        
C        
      IF (SYMFLG.LT.0 .AND. APP(1).EQ.STA(1)) GO TO 530        
      IF (SYMFLG .LT. 0) GO TO 190        
      DO 440 I = IVEC,IVECN        
  440 ZZ(I) = 0.0        
      IF (LSYM .GT. UGV VEC-1) GO TO 780        
      LIMIT = LSYM        
      IF (IFLAG .EQ. 1) LIMIT = 1        
      DO 450 I = 1,LIMIT        
  450 CALL BCKREC (UGV)        
      ISYMN = IX + LSYM        
      I = IX + 1        
      IF (IFLAG .EQ. 1) I = I + 1        
      J2 = ICB(3)        
  460 COEF = ZZ(I)        
      CALL INTPK (*480,UGV,0,QTYPE2,0)        
  470 CALL ZNTPKI        
      IX = IVEC + IXX - 1        
      IF (KTYPE .EQ. 1) GO TO 471        
      ZZ(IX+J2) = ZZ(IX+J2) + COEF*XX(1)        
      ZZ(IX   ) = ZZ(IX)    + COEF*XX(2)        
      GO TO 472        
  471 CONTINUE        
      ZZ(IX)= ZZ(IX) + COEF*XX(1)        
  472 CONTINUE        
      IF (EOL   .EQ. 0) GO TO 470        
  480 IF (IFLAG .EQ. 1) GO TO 485        
      I = I + 1        
      IF (I .LE. ISYMN) GO TO 460        
      GO TO 530        
C        
C     CONICAL SHELL BOTH CASE        
C     2 VECTORS IN CORE -        
C     2-ND VECTOR IS NOW IN CORE AT Z(IVEC) THRU Z(IVECN)...        
C     GET 1-ST VECTOR AND PUT IT AT Z(IVECN+1) THRU Z(2*IVECN-MIDVEC+1) 
C        
C        
  485 MIDVEC = IVEC        
      IVEC   = IVECN + 1        
      IVECN  = IVECN + (IVECN-MIDVEC+1)        
      COEF1  = ZZ(ICC + ILSYM+1)        
C        
C     IF FALL HERE AND SORC=1 THE VECTOR IN CORE IS THE SINE VECTOR AND 
C     IF SORC=2 THE VECTOR IN CORE IS THE COSINE VECTOR.  THUS THE FIRST
C     VECTOR WAS THE OTHER VECTOR RESPECTIVELY        
C     BY THE WAY THE VECTOR IN CORE IS THE SECOND VECTOR.        
C        
      CALL BCKREC (UGV)        
      CALL BCKREC (UGV)        
C        
C     NOT SYMMETRY-- UNPACK VECTOR.        
C        
  490 J2 = ICB(3)        
      IF (IFLAG .EQ. 1) GO TO 515        
      IF (UGVVEC .GT. NVECTS) GO TO 620        
  515 DO 510 I = IVEC,IVECN        
  510 ZZ(I) = 0.0        
      CALL INTPK (*500,UGV,0,QTYPE2,0)        
  491 CALL ZNTPKI        
      IX = IVEC + IXX-1        
      IF (KTYPE .EQ. 1) GO TO 492        
      ZZ(IX   ) = COEF1*XX(2)        
      ZZ(IX+J2) = COEF1*XX(1)        
      GO TO 493        
  492 CONTINUE        
      ZZ(IX) = COEF1*XX(1)        
  493 CONTINUE        
      IF (EOL .EQ. 0) GO TO 491        
  495 IF (APP(1) .NE. TRN(1)) GO TO 520        
      CALL FWDREC (*520,UGV)        
      UGVVEC = UGVVEC + 1        
      CALL FWDREC (*520,UGV)        
      UGVVEC = UGVVEC + 1        
      GO TO 520        
  500 CONTINUE        
      GO TO 495        
  520 IF (IFLAG .NE. 1) UGVVEC = UGVVEC + 1        
      IF (IFLAG .EQ. 1) CALL SKPREC (UGV,1)        
C        
C     READY NOW TO SWEEP THROUGH THE ESTA ONCE.        
C     SDR2E DOES ALL THE PROCESSING OF PHASE II ELEMENT COMPUTATIONS.   
C     THE ESTA FILE, BE IT IN CORE OR NOT, IS SWEPT THRU ONCE FOR THE   
C     FOLLOWING CALL.        
C        
  530 IF (IFLAG .EQ. 1) SORC = SORC + 1        
      IF (SORC  .EQ. 3) SORC = 1        
      CALL SDR2E (*640,IEQEX,NEQEX)        
C        
C     CONCLUDE PROCESSING OF THIS VECTOR        
C     INITIALIZE FOR NEXT VECTOR        
C     CANCEL THIS INITIALIZATION IN SOME CASES IF A REPEAT CASE.        
C        
  570 GO TO (580,581,620,581,590,582,620,581,581,580), BRANCH        
C        
  580 IF (.NOT.EOFCC) GO TO 190        
      GO TO 589        
  581 JLIST = JLIST + KTYPE1        
      IF (.NOT.EOFCC) GO TO 190        
      GO TO 589        
C        
C     TRANSIENT RESPONSE        
C        
  582 JLIST = JLIST + 2        
      IF (JLIST.LE.NLIST .AND. .NOT.EOFCC) GO TO 190        
      IF (JLIST.GT.NLIST  .OR. UGVVEC.GT.NVECTS) GO TO 620        
      GO TO 490        
C        
C     PROCESS ANY REMAINING VECTORS WITH LAST CC RECORD        
C        
  589 IF (UGV VEC.LE.NVECTS .AND. SYMFLG.EQ.0) GO TO 210        
      GO TO 620        
C        
C     FREQUENCY RESPONSE, PICK UP NEXT VECTOR UNLESS ALL FREQUENCIES    
C     COMPLETED        
C        
  590 JLIST = JLIST + 2        
      IF (JLIST.LE.NLIST .AND. UGV VEC.LE.NVECTS) GO TO 210        
      KFRQ  = 0        
      JLIST = ILIST        
      DO 600 I = ILIST,NLIST,2        
  600 Z(I+1) = 0        
      IF (UGV VEC .LE. NVECTS) GO TO 190        
      GO TO 620        
C        
C     EOF HIT ON CASECC FILE        
C     PROCESS ANY MORE VECTORS USING LAST CASECC RECORD        
C        
  610 EOFCC = .TRUE.        
      IF (NVECTS .GE. UGV VEC) GO TO 210        
C        
C     WRITE TRAILERS AND CLOSE ANY OPEN FILES        
C        
  620 OCB(2) = 63        
      IF (STRESS .EQ. 0) GO TO 630        
      OCB(1) = OES1        
      CALL WRTTRL (OCB(1))        
      IF (COMPS.NE.-1 .OR. ILAYER.EQ.0) GO TO 630        
      OCB(1) = OES1L        
      CALL WRTTRL (OCB(1))        
  630 IF (FORCE .EQ. 0) GO TO 640        
      OCB(1) = OEF1        
      CALL WRTTRL (OCB(1))        
      IF (COMPS.NE.-1 .OR. ILAYER.EQ.0) GO TO 640        
      OCB(1) = OEF1L        
      CALL WRTTRL (OCB(1))        
  640 DO 730 I = 1,12        
      GO TO (650,660,670,680,690,700,710,720,721,725,726,728), I        
  650 FILE = OES1        
      GO TO 730        
  660 FILE = OEF1        
      GO TO 730        
  670 FILE = UGV        
      GO TO 730        
  680 FILE = CASECC        
      GO TO 730        
  690 FILE = EDT        
      GO TO 730        
  700 FILE = GPTT        
      GO TO 730        
  710 FILE = PG        
      GO TO 730        
  720 FILE = EIGR        
      GO TO 730        
  721 FILE = ESTA        
      GO TO 730        
  725 FILE=EQEXIN        
      GO TO 730        
  726 FILE = OES1L        
      GO TO 730        
  728 FILE = OEF1L        
  730 CALL CLOSE (FILE,CLSREW)        
      RETURN        
C        
  740 N = 1        
      GO TO 760        
  750 N = 2        
      GO TO 760        
  751 N = 3        
      GO TO 760        
  760 CALL MESAGE (N,FILE,NAM)        
      GO TO 640        
C        
C     UGV FILE PURGED, CAN NOT PROCESS STRESSES OR FORCES        
C        
  770 CALL MESAGE (30,76,0)        
      GO TO 640        
  780 OCB(1) = LSYM        
      OCB(2) = UGV VEC - 1        
      CALL MESAGE (30,92,OCB(1))        
      GO TO 620        
      END        
