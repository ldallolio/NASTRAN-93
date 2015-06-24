      SUBROUTINE GPFDR        
C        
C     GRID-POINT-FORCE-DATA-RECOVERY (MODULE)        
C        
C     THIS MODULE FORMULATES OFP TYPE OUTPUT DATA BLOCKS OF ELEMENT-    
C     STRAIN ENERGYS AND GRID-POINT FORCE BALANCES.        
C        
C     DMAP CALLING SEQUENCES.        
C        
C     SOLUTION 1 -        
C     GPFDR  CASECC,UGV,KMAT,KDICT,ECT,EQEXIN,GPECT,PG,QG/ONRGY1,OGPF1/ 
C            *STATICS* $        
C     SOLUTION 3 -        
C     GPFDR  CASECC,PHIG,KMAT,KDICT,ECT,EQEXIN,GPECT,LAMA,/ONRGY1,OGPF1/
C            *REIG* $        
C        
C     COMMENT FROM G.CHAN/UNISYS, 1/88 -        
C     FOR MACHINES OF 32 OR 36 BIT WORDS, THE STRAIN ENERGY COMPUTATION 
C     (OTHER COMPUTATIONS TOO) MUST BE DONE IN DOUBLE PRECISION. SINCE  
C     THE K-MATRIX NORMALLY IN 10**7, AND THE DISPLACEMENT VECTOR IN    
C     10**-2 OR 10**-3 RANGE, SINGLE PRECISION COMPUTATION GIVES BAD    
C     RESULT.        
C        
      LOGICAL  DICOUT   ,ENGOUT   ,ENFLAG   ,ANYGP    ,DIAGM    ,ANY   ,
     1         DOUBLE   ,SILIN    ,ENFILE   ,GPFILE   ,EORST4   ,AXIC  ,
     2         AXIF        
      INTEGER  Z        ,CASECC   ,SCRT1    ,EOR      ,SYSBUF   ,TITLE ,
     1         NAMES(2) ,TYPOUT   ,UG       ,SCRT2    ,CORE     ,SUBR(2)
     2,        GSIZE    ,ECT      ,SCRT3    ,SYMFLG   ,EXTGP    ,SUBTIT,
     3         BUF(100) ,TRL(7)   ,ONRGY1   ,GPSET    ,POINTS   ,SCRT4 ,
     4         PG       ,QG       ,UGPGQG   ,OLOAD(2) ,OSPCF(2) ,III(2),
     5         ISUM(10) ,SCALE(2) ,KVEC(10) ,CLSEOF   ,RECIDX(3),OUTPT ,
     6         FILE     ,MCB(7)   ,EQEXIN   ,OGPF1    ,ELNSET   ,BRANCH,
     7         RD       ,APP      ,GPECT    ,SET      ,GPDVIS   ,SUBCAS,
     8         RDREW    ,ECTWDS   ,GRDPTS   ,COMPS(32),ELDVIS   ,BUF1  ,
     9         WRT      ,ELTYPE   ,GRID1    ,EXELID   ,DICLOC   ,BUF2  ,
     O         WRTREW   ,ELEM     ,NAME(2)  ,GRIDL    ,IDREC(10),BUF3  ,
     1         CLS      ,PHEAD(3) ,RECID(3) ,GPSIL    ,COMP     ,BUF4  ,
     2         CLSREW   ,ESTID    ,OLDCOD   ,OUT(10)  ,OLDID    ,BUF5  ,
     3         PIVOT    ,EXTID    ,PTR      ,ENTRYS   ,TOTAL    ,BUF6  ,
     5         METHOD(20)        
      REAL     RZ(1)    ,RBUF(5)  ,ROUT(10) ,VEC(6)   ,RIDREC(146)     ,
     1         RSUM(10) ,FVEC(10)        
      DOUBLE PRECISION   DIII     ,ELENGY   ,TOTENG   ,DZ(1)        
      CHARACTER          UFM*23   ,UWM*25   ,UIM*29   ,SFM*25   ,SWM*27 
      COMMON  /XMSSG /   UFM      ,UWM      ,UIM      ,SFM      ,SWM    
      COMMON  /SYSTEM/   SYSBUF   ,OUTPT        
      COMMON  /NAMES /   RD       ,RDREW    ,WRT      ,WRTREW  ,CLSREW ,
     1                   CLS      ,CLSEOF        
      COMMON  /GPTA1 /   NELEMS   ,LAST     ,INCR     ,ELEM(1)        
      COMMON  /UNPAKX/   TYPOUT   ,IROW     ,NROW     ,INCRX        
      COMMON  /ZNTPKX/   A(4)     ,IROWX    ,IEOL        
CZZ   COMMON  /ZZGPFD/   Z(1)        
      COMMON  /ZZZZZZ/   Z(1)        
      COMMON  /BLANK /   APP(2)        
      EQUIVALENCE        (Z(1),RZ(1),DZ(1)) ,(BUF(1),RBUF(1)),        
     1                   (OUT(1),ROUT(1))   ,(NAME1,NAMES(1)),        
     2                   (NAME2,NAMES(2))   ,(IDREC(1),RIDREC(1)),      
     3                   (DIII,III(1))      ,(ISUM(1),RSUM(1)),        
     4                   (KVEC(1),FVEC(1))        
      DATA     ENOEOR,   EOR / 0,1/   ,  LBUF/100/, SUBR/4HGPFD,4HR    /
      DATA     CASECC,   UG, KMAT,KDICT,ECT,EQEXIN,GPECT,PG, QG        /
     1         101   ,   102,103, 104,  105,106,   107,  108,109       /
      DATA     ONRGY1,   OGPF1,SCRT1,SCRT2,SCRT3,SCRT4  ,LAMA          /
     1         201   ,   202,  301,  302,  303,  304,    108           /
      DATA     METHS /   10/, OLOAD/4HAPP-,4HLOAD/, OSPCF/4HF-OF,4H-SPC/
      DATA     SCALE /   5, 0/, ISUM  / 0,0,4H*TOT,4HALS*,0,0,0,0,0,0  /
      DATA     METHOD/   4HSTAT,4HICS , 4HREIG,4HEN  , 4HDS0 ,4H       ,
     1                   4HDS1 ,4H    , 4HFREQ,4H    , 4HTRAN,4HSNT    ,
     2                   4HBKL0,4H    , 4HBKL1,4H    , 4HCEIG,4HEN     ,
     3                   4HPLA ,4H    /        
C        
C     CASE CONTROL POINTERS        
C        
      DATA     TITLE ,   SUBTIT, LABEL        / 39, 71,103             /
      DATA     ISYM  ,   IGP,IELN,ILSYM,ISUBC / 16,167,170,200,1       /
C        
C     DETERMINE APPROACH        
C        
      N = 2*METHS - 1        
      DO 10 I = 1,N,2        
      IF (APP(1) .EQ. METHOD(I)) GO TO 40        
   10 CONTINUE        
      WRITE  (OUTPT,30) UWM,APP        
   30 FORMAT (A25,' 2342, UNRECOGNIZED APPROACH PARAMETER ',2A4,        
     1       ' IN GPFDR INSTRUCTION.')        
      I = 19        
      NERROR = 0        
      GO TO 1810        
C        
   40 BRANCH = (I+1)/2        
C     IF (BRANCH .NE. 1) GO TO 20        
C        
C     INITIALIZATION AND BUFFER ALLOCATION.        
C        
      CORE = KORSZ(Z)        
      BUF1 = CORE - SYSBUF - 2        
      BUF2 = BUF1 - SYSBUF - 2        
      BUF3 = BUF2 - SYSBUF - 2        
      BUF4 = BUF3 - SYSBUF - 2        
      BUF5 = BUF4 - SYSBUF - 2        
      BUF6 = BUF5 - SYSBUF - 2        
      CORE = BUF6 - 1        
C        
C     READ IN FREQUENCIES IF APPROACH IS REIGEN        
C        
      IF (BRANCH .NE. 2) GO TO 70        
      MODE = 0        
      CALL OPEN (*70,LAMA,Z(BUF1),RDREW)        
      CALL FWDREC (*60,LAMA)        
      CALL FWDREC (*60,LAMA)        
      LFEQ = CORE        
   50 CALL READ (*60,*60,LAMA,BUF,7,0,IWORDS)        
      RZ(CORE) = RBUF(5)        
      CORE = CORE - 1        
      GO TO 50        
   60 CALL CLOSE (LAMA,CLSREW)        
C        
C     GPTA1 DUMMY ELEMENT SETUP CALL.        
C        
   70 CALL DELSET        
      NERROR = 1        
      IF (CORE) 1800,1800,80        
C        
C     OPEN CASE CONTROL        
C        
   80 FILE = CASECC        
      NERROR = 2        
      CALL OPEN (*1760,CASECC,Z(BUF1),RDREW)        
      CALL FWDREC (*1770,CASECC)        
C        
C     OPEN VECTOR FILE.        
C        
      FILE = UG        
      CALL OPEN (*1760,UG,Z(BUF2),RDREW)        
      CALL FWDREC (*1770,UG)        
      TRL(1) = UG        
      CALL RDTRL (TRL)        
      GSIZE = TRL(3)        
C        
C     PREPARE OUTPUT BLOCKS FOR ANY OUTPUTS POSSIBLE        
C        
      ENFILE = .FALSE.        
      CALL OPEN (*90,ONRGY1,Z(BUF3),WRTREW)        
      ENFILE = .TRUE.        
      CALL FNAME (ONRGY1,NAME)        
      CALL WRITE (ONRGY1,NAME,2,EOR)        
      CALL CLOSE (ONRGY1,CLSEOF)        
      MCB(1) = ONRGY1        
      CALL RDTRL (MCB)        
      MCB(2) = 0        
      CALL WRTTRL (MCB)        
C        
   90 GPFILE = .FALSE.        
      NERROR = 4        
      CALL OPEN (*100,OGPF1,Z(BUF3),WRTREW)        
      GPFILE = .TRUE.        
      CALL FNAME (OGPF1,NAME)        
      CALL WRITE (OGPF1,NAME,2,EOR)        
      CALL CLOSE (OGPF1,CLSEOF)        
C        
  100 MOVEPQ = 1        
      SILIN  = .FALSE.        
      TRL(1) = EQEXIN        
      CALL RDTRL (TRL)        
      POINTS = TRL(2)        
      ISILEX = 1        
      NSILEX = 2*POINTS        
      NERROR = 5        
      IF (NSILEX .GT. CORE) GO TO 1800        
      ICCZ = NSILEX        
      ICC  = ICCZ + 1        
      GO TO 120        
C        
C     OPEN CASECC AND UGV WITH NO REWIND        
C        
  110 FILE   = CASECC        
      NERROR = 8        
      CALL OPEN (*1760,CASECC,Z(BUF1),RD)        
      FILE = UG        
      CALL OPEN (*1760,UG,Z(BUF2),RD)        
C        
C     READ NEXT CASE CONTROL RECORD.        
C        
  120 CALL READ (*1750,*130,CASECC,Z(ICCZ+1),CORE-ICCZ,EOR,IWORDS)      
      NERROR = 7        
      GO TO 1800        
C        
  130 NCC    = ICCZ + IWORDS        
      ITEMP  = ICCZ + ISUBC        
      SUBCAS = Z(ITEMP)        
C        
C     SYMMETRY-REPCASE, GP-FORCE REQUEST, AND EL-ENERGY REQUEST CHECKS  
C        
      ITEMP  = ICCZ + ISYM        
      SYMFLG = Z(ITEMP)        
C        
C     SET REQUEST PARAMETERS FOR GP-FORCE AND EL-ENERGY.        
C        
      ITEMP  = ICCZ + IGP        
      GPSET  = Z(ITEMP)        
      IF (.NOT.GPFILE) GPSET = 0        
      GPDVIS = Z(ITEMP+1)        
      ITEMP  = ICCZ + IELN        
      ELNSET = Z(ITEMP)        
      IF (.NOT. ENFILE) ELNSET = 0        
      ELDVIS = Z(ITEMP+1)        
      IF (GPSET.LE.0 .AND. ELNSET.LE.0) GO TO 170        
C        
C     POINTERS TO SET LIST DOMAINS        
C        
      ITEMP = ICCZ + ILSYM        
      LSYM  = Z(ITEMP)        
      ITEMP = ITEMP + LSYM + 1        
  140 SET   = Z(ITEMP)        
      ISET  = ITEMP + 2        
      LSET  = Z(ITEMP+1)        
C        
C     CHECK IF THIS SET IS THE ONE FOR GP-FORCE        
C        
      IF (SET .NE. GPSET) GO TO 150        
      IGPLST = ISET        
      LGPLST = LSET        
C        
C     CHECK IF THIS SET IS THE ONE FOR EL-ENERGY        
C        
  150 IF (SET .NE. ELNSET) GO TO 160        
      IELLST = ISET        
      LELLST = LSET        
C        
  160 ITEMP = ISET + LSET        
      IF (ITEMP .LT. NCC) GO TO 140        
C        
C     IS THIS A REPCASE.  IF SO BACK-RECORD UG (REP-CASE OK ONLY FOR    
C                                               STATICS)        
C        
  170 IF (SYMFLG) 180,190,190        
C        
C     NEGATIVE SYMFLG IMPLIES A REP-CASE.        
C        
  180 IF (APP(1) .NE. METHOD(1)) GO TO 120        
C        
C     REP-CASE AND STATICS APPROACH THUS POSITION BACK ONE        
C     VECTOR ON UG UNLESS THERE IS NO REQUEST FOR GP-FORCE OR        
C     EL-ENERGY TO BEGIN WITH.        
C        
      IF (GPSET.EQ.0 .AND. ELNSET.EQ.0) GO TO 120        
      CALL BCKREC (UG)        
      MOVEPQ = MOVEPQ - 1        
      GO TO 210        
C        
C     NOT A REP-CASE BUT STILL IF THERE IS NO REQUEST FOR        
C     GP-FORCE OR EL-ENERGY POSITION OVER VECTORS ASSOCIATED        
C     WITH THIS CASE.        
C        
  190 IF (GPSET.NE.0 .OR. ELNSET.NE.0) GO TO 210        
      IF (SYMFLG) 120,200,120        
C        
C     NOT A SYMMETRY CASE (WHICH WOULD USE VECTORS ALREADY READ, THUS   
C     SKIP A VECTOR ASSOCIATED WITH THIS CASE.        
C        
  200 NERROR = 8        
CIBMD 6/93 CALL FWDREC (*1770,UG)        
CIBMNB 6/93
C  MAJOR LOOP OF MODULE TERMINATES WITH ENDING OF CASE CONTROL OR
C END OF EIGENVECTORS COMPUTED.  IF MODES CARD IS USED AND SPECIFIES
C MORE MODES THAN WERE COMPUTED, THEN THE FOLLOWING WILL TERMINATE
C THE LOOP.  (SEE DEMO T03011A WHICH COMPUTED 4 EIGENVALUES BUT HAD
C A MODES CARD SPECIFYING 5 MODES)
      CALL FWDREC (*1750,UG)        
CIBMNE
      MOVEPQ = MOVEPQ + 1        
      GO TO 120        
C        
C  BRING VECTOR INTO CORE, BRANCH IF SYMMETRY CASE.        
C        
  210 IVEC   = NCC + 1        
      IVECZ  = NCC        
      NVEC   = IVECZ + GSIZE        
      NERROR = 9        
      IF (NVEC .GT. CORE) GO TO 1800        
      ASSIGN 320 TO IRETRN        
      UGPGQG = UG        
  220 IF (SYMFLG) 230,230,260        
C        
  230 IROW   = 1        
      NROW   = GSIZE        
      INCRX  = 1        
      TYPOUT = 1        
      CALL UNPACK (*240,UGPGQG,RZ(IVEC))        
      GO TO 310        
C        
C     NULL VECTOR (SET VECTOR SPACE TO ZERO)        
C        
  240 DO 250 I = IVEC,NVEC        
      RZ(I) = 0.0        
  250 CONTINUE        
      GO TO 310        
C        
C     SYMMETRY SEQUENCE.  SUM VECTORS OF SEQUENCE APPLYING COEFFICIENTS.
C        
  260 ITEMP = ICCZ + ILSYM        
      LSYM  = Z(ITEMP)        
C        
C     BACK UP OVER THE VECTORS OF THE SEQUENCE        
C        
      DO 270 I = 1,LSYM        
      CALL BCKREC (UGPGQG)        
  270 CONTINUE        
C        
      DO 280 I = IVEC,NVEC        
      RZ(I) = 0.0        
  280 CONTINUE        
C        
      DO 300 I = 1,LSYM        
      ITEMP = ITEMP + 1        
      COEF  = RZ(ITEMP)        
C        
C     SUM IN COEF*VECTOR(I)        
C        
      CALL INTPK (*300,UGPGQG,0,1,0)        
  290 CALL ZNTPKI        
      J = IVECZ + IROWX        
      RZ(J) = RZ(J) + COEF*A(1)        
      IF (IEOL) 300,290,300        
  300 CONTINUE        
  310 GO TO IRETRN, (320,1460)        
C        
C     AT THIS POINT VECTOR IS IN CORE ALONG WITH THE CASE CONTROL RECORD
C        
C     NOW START ECT PASS.  IN THIS PASS GP-FORCES REQUESTED WILL BE     
C     WRITTEN TO PMAT (A SCRATCH SET ACTUALLY=SCRT1), AND BY THE GINO   
C     DIRECT-ACCESS METHOD.  ALSO EL-ENERGY OUTPUTS WILL BE FORMED FOR  
C     ANY REQUESTED ELEMENTS.        
C        
C     NOTE.  THE ASSEMBLY OF GP-FORCES FOR OUTPUT IS ACCOMPLISHED AFTER 
C     ALL GP-FORCES REQUESTED HAVE BEEN WRITTEN TO PMAT.        
C        
  320 CALL CLOSE (CASECC,CLS)        
      CALL CLOSE (UG,CLS)        
      IF (SILIN) GO TO 370        
C        
C     GET SECOND RECORD OF EQEXIN INTO CORE AND TRANSFER CODES FROM     
C     SILS TO EXTERNALS AND THEN INSURE SORT ON SILS.        
C        
      NERROR = 6        
      FILE   = EQEXIN        
      CALL OPEN (*1760,EQEXIN,Z(BUF1),RDREW)        
      CALL FWDREC (*1770,EQEXIN)        
      CALL FWDREC (*1770,EQEXIN)        
      CALL READ (*1770,*350,EQEXIN,Z(ISILEX),CORE-ISILEX,NOEOR,IWORDS)  
  330 WRITE  (OUTPT,340) SWM,EQEXIN        
  340 FORMAT (A27,' 2343.  DATA BLOCK',I5,' IS EITHER NOT -EQEXIN- OR ',
     1        'POSSIBLY INCORRECT.')        
      GO TO 1810        
C        
  350 IF (IWORDS .NE. 2*POINTS) GO TO 330        
      CALL CLOSE (EQEXIN,CLSREW)        
      DO 360 I = ISILEX,NSILEX,2        
      Z(I  ) = 10*Z(I) + MOD(Z(I+1),10)        
      Z(I+1) = Z(I+1)/10        
  360 CONTINUE        
      SILIN  = .TRUE.        
      CALL SORT (0,0,2,2,Z(ISILEX),NSILEX-ISILEX+1)        
C        
C     SET UP OFP ID RECORD WITH TITLE, SUBTITLE, AND LABEL.        
C        
  370 ITIT = ICCZ + TITLE        
      ISUB = ICCZ + SUBTIT        
      ILAB = ICCZ + LABEL        
      DO 380 I = 1,32        
      IDREC(I+ 50) = Z(ITIT)        
      IDREC(I+ 82) = Z(ISUB)        
      IDREC(I+114) = Z(ILAB)        
      ITIT = ITIT + 1        
      ISUB = ISUB + 1        
      ILAB = ILAB + 1        
  380 CONTINUE        
      DO 390 I = 1,50        
      IDREC(I) = 0        
  390 CONTINUE        
      FILE   = ECT        
      NERROR = 10        
      CALL OPEN (*1760,ECT,Z(BUF4),RDREW)        
      FILE = KMAT        
      CALL OPEN (*1760,KMAT,Z(BUF5),RDREW)        
C        
C     DETERMINE PRECISION OF KMAT DATA        
C        
      MCB(1) = KMAT        
      CALL RDTRL (MCB)        
      DOUBLE = .FALSE.        
      IF (MCB(2) .EQ. 2) DOUBLE = .TRUE.        
      FILE = KDICT        
      CALL OPEN (*1760,KDICT,Z(BUF6),RDREW)        
      CALL FWDREC (*1770,KDICT)        
C        
C     PMAT WILL BE ON SCRATCH1        
C     PDICT WILL BE ON SCRATCH2        
C        
      FILE   = SCRT1        
      NERROR = 11        
      CALL OPEN (*1760,SCRT1,Z(BUF1),WRTREW)        
      FILE = SCRT2        
      CALL OPEN (*1760,SCRT2,Z(BUF2),WRTREW)        
C        
C     REQUESTED OUTPUT ELEMENT ENERGIES WILL BE TEMPORARILY WRITTEN ON  
C     SCRT3 WHILE THE TOTAL ENERGY IS SUMMED.        
C        
      FILE   = SCRT3        
      IF (ELNSET .NE. 0) CALL OPEN (*1760,SCRT3,Z(BUF3),WRTREW)        
      NEXTGP = 1        
      LASTID = 0        
      OLDCOD = 0        
      TOTENG = 0.0D0        
      ESTID  = 0        
      AXIC   = .FALSE.        
      AXIF   = .FALSE.        
C        
C     ECT PASS OF ALL ELEMENT TYPES PRESENT.        
C        
C     DETERMINE NEXT ELEMENT TYPE TO FIND ON ECT AND THEN FIND ITS      
C     TYPE IN ECT.        
C        
  400 FILE = KDICT        
      NERROR = 12        
      CALL READ (*990,*1780,KDICT,RECID,3,NOEOR,IWORDS)        
      KT = RECID(1)        
C        
C           CCONAX       CTRIAAX       CTRAPAX        
      IF (KT.EQ.35 .OR. KT.EQ.70 .OR. KT.EQ.71) AXIC = .TRUE.        
C         CFLUID2/3/4  AND CFMASS        
      IF (KT.GE.43 .AND. KT.LE.46) AXIF = .TRUE.        
C         CAXIF2/3/4 AND CSLOT3/4        
      IF (KT.GE.47 .AND. KT.LE.51) AXIF = .TRUE.        
C        
      FILE = ECT        
      CALL FWDREC (*1770,ECT)        
  410 CALL READ (*1770,*1780,ECT,RECIDX,3,NOEOR,IWORDS)        
      IF (RECIDX(1) .EQ. 65535) GO TO 1770        
      DO 440 I = 1,LAST,INCR        
      IF (ELEM(I+3) .NE. RECIDX(1)) GO TO 440        
      ELTYPE = (I/INCR) + 1        
      ECTWDS = ELEM(I+5)        
      IF (ECTWDS .LE. LBUF) GO TO 430        
      WRITE  (OUTPT,420) SWM,ELEM(I),ELEM(I+1)        
  420 FORMAT (A27,' 2344. GPFDR FINDS ELEMENT = ',2A4,' HAS AN ECT ',   
     1        'ENTRY LENGTH TOO LONG FOR A PROGRAM LOCAL ARRAY.')       
      GO TO 1810        
C        
  430 GRDPTS= ELEM(I+ 9)        
      GRID1 = ELEM(I+12)        
      NAME1 = ELEM(I   )        
      NAME2 = ELEM(I+ 1)        
      GO TO 470        
  440 CONTINUE        
C        
C     UNRECOGNIZED ELEMENT DATA ON ECT.        
C        
      WRITE  (OUTPT,450) SWM,RECIDX        
  450 FORMAT (A27,' 2345.  GPFDR FINDS AND IS IGNORING UNDEFINED ECT ', 
     1        'DATA WITH LOCATE NUMBERS = ',3I8)        
      FILE = ECT        
C        
C     PASS THIS ECT RECORD BUT KEEP ESTID COUNTER IN SYNC.        
C        
  460 CALL READ (*1770,*410,ECT,BUF,ECTWDS,NOEOR,IWORDS)        
      ESTID = ESTID + 1        
      GO TO 460        
C        
  470 IF (ELTYPE .NE. RECID(1)) GO TO 460        
      FILE  = KDICT        
      LDICT = RECID(2)        
      IF (RECID(3) .EQ. GRDPTS) GO TO 500        
  480 WRITE  (OUTPT,490) SWM,ELTYPE,KDICT        
  490 FORMAT (A27,' 2346.  GPFDR FINDS DATA FOR EL-TYPE =',I9,        
     1       ' IN DATA BLOCK',I9, /5X,        
     2        'NOT TO BE IN AGREEMENT WITH THAT WHICH IS EXPECTED.')    
      GO TO 1810        
C        
  500 IKDIC  = NVEC + 1        
      NKDIC  = NVEC + LDICT        
      DICOUT = .FALSE.        
      ENGOUT = .FALSE.        
C        
C     ALLOCATE A P-DICTIONARY FOR THE ELEMENTS GP-FORCE VECTOR        
C     CONTRIBUTION.  CONTENTS = ESTID, EXT-EL.-ID, GINO-LOCS (GRDPTS)   
C        
      IPDIC = NKDIC + 1        
      NPDIC = IPDIC + GRDPTS + 1        
      LPDIC = GRDPTS + 2        
      NERROR= 13        
      IF (NPDIC .GT. CORE) GO TO 1800        
      ILOC1 = NKDIC - GRDPTS        
      PHEAD(1) = ELTYPE        
      PHEAD(2) = LPDIC        
      PHEAD(3) = GRDPTS        
C        
C     LOOP IS NOW MADE ON THE ELEMENT ENTRIES OF THIS ELEMENT TYPE.     
C        
      NEXTEN = 1        
C        
C     READ NEXT ELEMENT DICTIONARY FROM KDICT OF CURRENT ELEMENT TYPE   
C     AND FIND ECT ENTRY WITH SAME ESTID.        
C        
  510 FILE = KDICT        
      CALL READ (*1770,*980,KDICT,Z(IKDIC),LDICT,NOEOR,IWORDS)        
      FILE = ECT        
      NERROR = 14        
  520 CALL READ (*1770,*1780,ECT,BUF,ECTWDS,NOEOR,IWORDS)        
      ESTID = ESTID + 1        
      IF (Z(IKDIC)-ESTID) 480,530,520        
C        
C     DECODE THE CODE WORD INTO A LIST OF INTEGERS        
C        
  530 IF (Z(IKDIC+3) .EQ. OLDCOD) GO TO 540        
      OLDCOD = Z(IKDIC+3)        
      CALL DECODE (OLDCOD,COMPS,NCOMPS)        
      NCOMP2 = NCOMPS        
      IF (DOUBLE) NCOMP2 = NCOMPS + NCOMPS        
C        
C     DETERMINE ACTIVE CONNECTIONS        
C        
  540 NSIZE  = Z(IKDIC+2)        
      NGRIDS = NSIZE / NCOMP2        
      IF (NGRIDS .LE. GRDPTS) GO TO 560        
      WRITE  (OUTPT,550) UWM,BUF(1)        
  550 FORMAT (A25,' 2347.  GPFDR FINDS TOO MANY ACTIVE CONNECTING GRID',
     1       ' POINTS FOR ELEMENT ID =',I9)        
      GO TO 1810        
C        
C     ELEMENT ONLY DISPLACEMENT AND LOAD SPACE.        
C        
  560 IUGE = NPDIC + 1        
      IF (DOUBLE ) IUGE = IUGE/2 + 1        
      NUGE = IUGE + NSIZE - 1        
      IPGE = NUGE + 1        
      NPGE = NUGE + NSIZE        
      IF (NPGE .GT. CORE) GO TO 1800        
C        
C     ECT ENTRY AND K-DICTIONARY ENTRY NOW AT HAND.        
C        
C     SET FLAG IF EL-ENERGY IS TO BE OUTPUT FOR THIS ELEMENT.        
C        
      EXELID    = BUF(1)        
      Z(IPDIC)  = ESTID        
      Z(IPDIC+1)= EXELID        
      ENFLAG    = .FALSE.        
      IF (AXIC) EXELID = MOD(EXELID,10000  )        
      IF (AXIF) EXELID = MOD(EXELID,1000000)        
      IF (ELNSET) 580,590,570        
C        
C     FIND THIS EXTERNAL ELEMENT ID IN THE REQUESTED SET LIST FOR       
C     ELEMENT ENERGY OUTPUTS.        
C        
  570 CALL SETFND (*590,Z(IELLST),LELLST,EXELID,NEXTEN)        
  580 ENFLAG = .TRUE.        
  590 GRIDL  = GRID1 + GRDPTS - 1        
C        
C     REORDER ECT CONNECTION LIST ACCORDING TO SIL SEQUENCE.        
C        
      J = GRID1 - 1        
  600 J = J + 1        
      IF (J .GE. GRIDL) GO TO 620        
      GPSIL = ISILEX + 2*BUF(J) - 1        
      LSIL  = Z(GPSIL)        
      I = J        
  610 I = I + 1        
      IF (I .GT. GRIDL) GO TO 600        
      GPSIL = ISILEX + 2*BUF(I) - 1        
      ISIL  = Z(GPSIL)        
      IF (ISIL .GT. LSIL) GO TO 610        
      LSIL   = BUF(J)        
      BUF(J) = BUF(I)        
      BUF(I) = LSIL        
      LSIL   = ISIL        
      GO TO 610        
C        
C     NOW SET INTERNAL GRID POINT ID-S IN THE ECT ENTRY NEGATIVE IF THEY
C     ARE TO HAVE THEIR GP-FORCE BALANCE OUTPUT.        
C        
  620 ANYGP = .FALSE.        
      IF (GPSET .EQ. 0) GO TO 670        
      DO 660 I = GRID1,GRIDL        
      IF (BUF(I)) 660,660,630        
  630 IF (GPSET ) 650,660,640        
  640 IDX = ISILEX + 2*BUF(I)        
      ID  = Z(IDX-2)/10        
      IF (AXIC) ID = MOD(ID,1000000)        
      IF (AXIF) ID = MOD(ID,500000 )        
      IF (ID .LT. LASTID) NEXTGP = 1        
      LASTID = ID        
      CALL SETFND (*660,Z(IGPLST),LGPLST,ID,NEXTGP)        
  650 BUF(I) = -BUF(I)        
      ANYGP  = .TRUE.        
  660 CONTINUE        
C        
C     IF NO GRID POINTS OF THIS ELEMENT WERE FLAGGED AND THERE IS       
C     NO POTENTIAL OF ANY ELEMENT ENERGY OUTPUTS THEN SKIP THIS ELEMENT 
C     AT THIS POINT.        
C        
  670 IF (.NOT.ANYGP .AND. ELNSET.EQ.0) GO TO 510        
C        
C     BUILD A NON-EXPANDED ELEMENT DISPLACEMENT VECTOR AT THIS TIME.    
C        
      J = IUGE        
      DO 720 I = GRID1,GRIDL        
      IF (BUF(I)) 680,720,690        
  680 GPSIL = ISILEX - 2*BUF(I) - 1        
      GO TO 700        
  690 GPSIL = ISILEX + 2*BUF(I) - 1        
  700 ISIL  = Z(GPSIL)        
      DO 710 K = 1,NCOMPS        
      LSIL  = ISIL + COMPS(K)        
      DZ(J) = DBLE(RZ(IVECZ+LSIL))        
      J = J + 1        
  710 CONTINUE        
  720 CONTINUE        
C        
      IF (J-1 .EQ. NUGE) GO TO 740        
      WRITE  (OUTPT,730) SWM,BUF(1)        
  730 FORMAT (A27,' 2348.  GPFDR DOES NOT UNDERSTAND THE MATRIX-',      
     1        'DICTIONARY ENTRY FOR ELEMENT ID =',I9)        
      GO TO 1810        
C        
C     TOTAL ELEMENT FORCE VECTOR IS NOW COMPUTED.        
C        
  740 DO 750 I = IPGE,NPGE        
      DZ(I) = 0.0D0        
  750 CONTINUE        
C        
      JSIZE = NSIZE        
      IKMAT = NPGE  + 1        
      IF (.NOT.DOUBLE) GO TO 760        
      JSIZE = JSIZE + NSIZE        
      IKMAT = NPGE*2+ 1        
  760 NKMAT = IKMAT + JSIZE - 1        
C      WRITE (OUTPT,727) IKDIC,NKDIC,IPDIC,NPDIC,IUGE,NUGE,IPGE,NPGE,   
C    1        IKMAT,NKMAT,CORE, LDICT,GRDPTS,NSIZE,NSIZE,JSIZE        
C 727 FORMAT (/,' IKDIC,NKDIC,IPDIC,NPDIC,IUGE,NUGE,IPGE,NPGE,',        
C    1       'IKMAT,NKMAT,CORE=',/2X,11I10, /8X,5(I10,10X))        
      IF (NKMAT .GT. CORE) GO TO 1800        
      DIAGM = .FALSE.        
      IF (Z(IKDIC+1) .EQ. 2) DIAGM = .TRUE.        
C        
C     LOOP THROUGH ALL PARTITIONS ON KMAT FOR THIS ELEMENT.        
C        
      JPGE = IPGE        
      DO 870 I = 1,GRDPTS        
      ITEMP = ILOC1 + I        
      IF (Z(ITEMP)) 770,870,770        
  770 CALL FILPOS (KMAT,Z(ITEMP))        
      IF (DIAGM) GO TO 830        
C        
C     FULL MATRIX.  READ COLUMNS OF ROW-STORED VERETICAL PARTITION.     
C        
      NERROR = 16        
      DO 820 K = 1,NCOMPS        
      CALL READ (*1770,*1780,KMAT,Z(IKMAT),JSIZE,NOEOR,IWORDS)        
      JKMAT = IKMAT        
      IF (DOUBLE) GO TO 790        
      DO 780 J = IUGE,NUGE        
      DZ(JPGE) = DZ(JPGE) + DZ(J)*DBLE(RZ(JKMAT))        
      JKMAT = JKMAT + 1        
  780 CONTINUE        
      GO TO 810        
C        
  790 DO 800 J = IUGE,NUGE        
      III(1) = Z(JKMAT  )        
      III(2) = Z(JKMAT+1)        
      DZ(JPGE) = DZ(JPGE) + DZ(J)*DIII        
      JKMAT = JKMAT + 2        
  800 CONTINUE        
C        
  810 JPGE = JPGE + 1        
  820 CONTINUE        
      GO TO 870        
C        
C     DIAGONAL MATRIX.  THUS ONLY DIAGONAL TERMS OF PARTITION CAN       
C     BE READ.        
C        
  830 NERROR = 17        
      CALL READ (*1770,*1780,KMAT,Z(IKMAT),NCOMP2,NOEOR,IWORDS)        
      IF (DOUBLE) GO TO 850        
C        
      DO 840 J = 1,NCOMPS        
      DZ(JPGE) = DZ(IUGE+J-1)*DBLE(RZ(IKMAT+J-1))        
      JPGE = JPGE + 1        
  840 CONTINUE        
      GO TO 870        
C        
  850 JKMAT = IKMAT        
      DO 860 J = 1,NCOMPS        
      III(1) = Z(JKMAT)        
      III(2) = Z(JKMAT+1)        
      DZ(JPGE) = DZ(IUGE+J-1)*DIII        
      JKMAT = JKMAT + 2        
      JPGE  = JPGE + 1        
  860 CONTINUE        
C        
  870 CONTINUE        
C        
C     ENERGY COMPUTATION IS NOW MADE IF NECESSARY.        
C        
C       U   =  0.5(PG ) X (UG )        
C        T           E         E        
C        
C        
      IF (ELNSET) 880,900,880        
  880 JPGE  = IPGE        
      ELENGY= 0.0D0        
      DO 890 I = IUGE,NUGE        
      ELENGY= ELENGY + DZ(I)*DZ(JPGE)        
      JPGE  = JPGE + 1        
  890 CONTINUE        
C        
C     NOTE, TOTAL ENERGY WILL BE DIVIDED BY 2.0 LATER.        
C        
      TOTENG = TOTENG + ELENGY        
C        
C     WRITE THIS ELEMENTS ENERGY ON SCRT3 FOR LATER OUTPUT IF REQUESTED.
C        
      IF (.NOT. ENFLAG) GO TO 900        
      OUT (1) = BUF(1)        
      ROUT(2) = SNGL(ELENGY)*0.50        
      IF (.NOT.ENGOUT) CALL WRITE (SCRT3,NAMES,2,NOEOR)        
      CALL WRITE (SCRT3,OUT,2,NOEOR)        
      ENGOUT  = .TRUE.        
C        
C     GRID POINT FORCE BALANCE OUTPUTS FOR REQUESTED GIRD POINTS.       
C        
  900 IF (.NOT. ANYGP) GO TO 970        
C        
C     EXPAND TO 6X1 FROM PGE EACH GRID POINT FORCE TO BE OUTPUT.        
C        
C     FORCES COMPUTED FOR COMPONENTS OTHER THAN 1 THRU 6 ARE NOT        
C     NOW OUTPUT FROM MODULE GPFDR...  FUTURE ADDITIONAL CAPABLILITY.   
C     OFP MODS NEEDED AT THAT TIME.        
C        
      JPGE   = IPGE        
      DICLOC = IPDIC + 2        
      DO 910 I = DICLOC,NPDIC        
      Z(I) = 0        
  910 CONTINUE        
      DO 960 I = GRID1,GRIDL        
      IF (BUF(I)) 930,960,920        
C        
C     THIS GRID POINT NOT IN GP-FORCE BALANCE REQUEST LIST.        
C        
  920 JPGE = JPGE + NCOMPS        
      DICLOC = DICLOC + 1        
      GO TO 960        
C        
C     OK THIS GRID POINT GETS OUTPUT.        
C        
  930 DO  940 J = 1,6        
      VEC(J) = 0.0        
  940 CONTINUE        
      DO 950 J = 1,NCOMPS        
      COMP = COMPS(J)        
      IF (COMP .LE. 5) VEC(COMP+1) =-SNGL(DZ(JPGE))        
      JPGE = JPGE + 1        
  950 CONTINUE        
C        
      CALL WRITE  (SCRT1,VEC,6,EOR)        
      CALL SAVPOS (SCRT1,Z(DICLOC))        
      DICLOC = DICLOC + 1        
  960 CONTINUE        
C        
C     OUTPUT THE DICTIONARY        
C        
      IF (.NOT.DICOUT) CALL WRITE (SCRT2,PHEAD,3,NOEOR)        
      CALL WRITE (SCRT2,Z(IPDIC),LPDIC,NOEOR)        
      DICOUT = .TRUE.        
C        
C     GO FOR NEXT ELEMENT OF CURRENT TYPE.        
C        
  970 GO TO 510        
C        
C     END OF ELEMENT ENTRIES OF CURRENT ELEMENT TYPE.        
C     COMPLETE RECORDS IN PDIC, AND SCRT3=EL-ENERGY.        
C        
  980 IF (DICOUT) CALL WRITE (SCRT2,0,0,EOR)        
      IF (ENGOUT) CALL WRITE (SCRT3,0,0,EOR)        
C        
C     GO FOR NEXT ELEMENT TYPE        
C        
      GO TO 400        
C        
C     END OF ALL ELEMENT DATA ON ECT (WRAP UP PHASE I OF GPFDR).        
C        
  990 CALL CLOSE (KMAT,CLSREW)        
      CALL CLOSE (KDICT,CLSREW)        
      CALL CLOSE (ECT,CLSREW)        
      CALL CLOSE (SCRT1,CLSREW)        
      CALL CLOSE (SCRT2,CLSREW)        
      CALL CLOSE (SCRT3,CLSREW)        
C        
C     PREPARE AND WRITE THE ELEMENT ENERGY OUTPUTS NOW RESIDENT ON SCRT3
C        
      IF (ELNSET .EQ. 0) GO TO 1050        
C        
C     OFP ID RECORD DATA        
C     DEVICE, OFP-TYPE, TOTAL ENERGY, SUBCASE, ELEMENT NAME, WORDS      
C     PER ENTRY.        
C        
      IDREC( 1) = 10*BRANCH + ELDVIS        
      IDREC( 2) = 18        
      RIDREC(3) = SNGL(TOTENG)*0.50        
      IDREC( 4) = SUBCAS        
      IDREC(10) = 3        
C        
C     IF APPROACH IS REIG, PUT MODE NO. AND FREQ. INTO IDREC, 8 AND 9   
C     WORDS        
C        
      IF (BRANCH .NE. 2) GO TO 1000        
      RIDREC(9) = RZ(LFEQ-MODE)        
      MODE      = MODE + 1        
      IDREC( 8) = MODE        
C        
 1000 NERROR = 22        
      FILE = ONRGY1        
      CALL OPEN (*1760,ONRGY1,Z(BUF2),WRT)        
      FILE = SCRT3        
      CALL OPEN (*1760,SCRT3,Z(BUF3),RDREW)        
C        
C     TOTENG FACTOR FOR MULTIPLICATION TO GET DECIMAL PERCENTAGE BELOW  
C        
      IF (TOTENG .NE. 0.0D0) TOTENG = 200.0D0/TOTENG        
C        
C     READ ELEMENT NAME INTO IDREC RECORD.        
C        
      JTYPE = 0        
 1010 CALL READ  (*1040,*1780,SCRT3,IDREC(6),2,NOEOR,IWORDS)        
      CALL WRITE (ONRGY1,IDREC,146,EOR)        
 1020 CALL READ  (*1770,*1030,SCRT3,BUF,2,NOEOR,IWORDS)        
      JTYPE  = JTYPE + 1        
      BUF(1) = 10*BUF(1) + ELDVIS        
      RBUF(3)= RBUF(2)*SNGL(TOTENG)        
      CALL WRITE (ONRGY1,BUF,3,NOEOR)        
      GO TO 1020        
C        
 1030 CALL WRITE (ONRGY1,0,0,EOR)        
      GO TO 1010        
C        
 1040 CALL CLOSE (ONRGY1,CLSEOF)        
      MCB(1) = ONRGY1        
      CALL RDTRL (MCB)        
      MCB(2) = MCB(2) + JTYPE        
      CALL WRTTRL (MCB)        
      CALL CLOSE (SCRT3,CLSREW)        
      IDREC(3) = 0        
      IDREC(6) = 0        
      IDREC(7) = 0        
C        
C     A GRID-POINT-FORCE-BALANCE-OUTPUT-MAP IS NOW CONSTRUCTED. (GPFBOM)
C        
C     CONTENTS...  1 LOGICAL RECORD FOR EACH GRID POINT TO BE OUTPUT    
C     ===========        
C        
C     REPEATING 4       * EXTERNAL-ELEMENT-ID        
C     WORD ENTRIES     *  ELEMENT NAME FIRST 4H        
C     OF THE CON-      *  ELEMENT NAME LAST  4H        
C     NECTED ELEMENTS   * GINO-LOC OF THE 6X1 FORCE VECTOR CONTRIBUTION 
C        
C     FOR EACH RECORD WRITTEN ABOVE, A 3-WORD ENTRY IS WRITTEN TO A     
C     COMPANION DICTIONARY FILE GIVING,        
C        
C                      *  1-THE EXTERNAL GRID POINT ID        
C     REPEATING ENTRY *   2-THE GINO-LOC TO THE ABOVE RECORD        
C                      *  3-THE NUMBER OF ENTRIES IN THE RECORD        
C        
C        
C     ALLOCATE A TABLE WITH AN ENTRY FOR EACH ELEMENT TYPE.        
C     POSSIBLE IN IT.  EACH ENTRY TO HAVE 3 WORDS.        
C        
C     ENTRY I =      1= PTR TO DICTIONARY DATA FOR ELEMENT TYPE-I       
C     *********      2= LENGTH OF DICTIONARY DATA        
C                    3= NUMBER OF ENTRIES        
C        
 1050 IF (GPSET .EQ. 0) GO TO 110        
      IDTAB = NCC + 1        
      NDTAB = IDTAB + NELEMS*3 - 1        
      JDICTS= NDTAB + 1        
      IF (JDICTS .GT. CORE) GO TO 1800        
      DO 1060 I = IDTAB,NDTAB        
      Z(I) = 0        
 1060 CONTINUE        
C        
C     READ IN DICTIONARIES OF PMAT VECTORS.  (SCRT2)        
C        
      FILE = SCRT2        
      CALL OPEN (*1760,SCRT2,Z(BUF2),RDREW)        
C        
C     READ AN ELEMENT TYPE HEADER (FIRST 3-WORDS OF EACH RECORD)        
C        
 1070 CALL READ (*1090,*1780,SCRT2,BUF,3,NOEOR,IWORDS)        
      ITYPE = BUF(1)        
      LDICT = BUF(2)        
      GRDPTS= BUF(3)        
      K     = INCR*ITYPE - INCR        
      J     = IDTAB + 3*ITYPE - 3        
      Z(J)  = JDICTS        
C        
C     BLAST READ IN THE DICTIONARIES OF THIS TYPE.        
C        
      CALL READ (*1770,*1080,SCRT2,Z(JDICTS),CORE-JDICTS,NOEOR,IWORDS)  
      NERROR = 18        
      GO TO 1800        
C        
 1080 Z(J+1) = IWORDS        
      Z(J+2) = IWORDS/LDICT        
      JDICTS = JDICTS + IWORDS        
      NERROR = 19        
      IF (CORE-JDICTS) 1800,1800,1070        
C        
 1090 CALL CLOSE (SCRT2,CLSREW)        
C        
C     DICTIONARIES ALL IN CORE.  SCRT2 IS AVAILABLE FOR USE AS THE      
C     -GPFBOM-.        
C        
      NDICTS = JDICTS - 1        
C        
C     PASS THE -GPECT- AND BUILD THE -GPFBOM- (ON SCRT2) AND ITS        
C     COMPANION DICTIONARY FILE (ON SCRT3).        
C        
      FILE = SCRT2        
      CALL OPEN (*1760,SCRT2,Z(BUF2),WRTREW)        
      FILE = SCRT3        
      CALL OPEN (*1760,SCRT3,Z(BUF3),WRTREW)        
C        
      FILE = GPECT        
      CALL OPEN (*1760,GPECT,Z(BUF4),RDREW)        
      CALL FWDREC (*1770,GPECT)        
      OLDID = 0        
      NEXT  = 1        
C        
C     READ PIVOT HEADER DATA FROM -GPECT- RECORD.        
C        
 1100 CALL READ (*1240,*1780,GPECT,BUF,2,NOEOR,IWORDS)        
      PIVOT = BUF(1)        
C        
C     CONVERT SIL TO EX-ID        
C        
      CALL BISLOC (*1200,PIVOT,Z(ISILEX+1),2,POINTS,J)        
      J = ISILEX + J - 1        
      EXTID = Z(J)/10        
      IDEXT = EXTID        
      IF (AXIC) IDEXT = MOD(EXTID,1000000)        
      IF (AXIF) IDEXT = MOD(EXTID,500000 )        
      NENTRY = 0        
C        
C     CHECK FOR OUTPUT REQUEST THIS EX-ID        
C        
      IF (GPSET) 1120,1220,1110        
 1110 IF (IDEXT .LT. OLDID) NEXT = 1        
      OLDID = IDEXT        
      CALL SETFND (*1220,Z(IGPLST),LGPLST,IDEXT,NEXT)        
C        
C     YES GP-FORCE BALANCE FOR PIVOT IS TO BE OUTPUT.        
C        
C     PROCESS ALL ELEMENTS CONNECTING THIS PIVOT.        
C        
 1120 CALL READ (*1770,*1230,GPECT,LENGTH,1,NOEOR,IWORDS)        
      LENGTH = IABS(LENGTH)        
      IF (LENGTH .LE. LBUF) GO TO 1140        
      WRITE  (OUTPT,1130) SWM,PIVOT,GPECT        
 1130 FORMAT (A27,' 2349.  GPFDR FINDS AN ELEMENT ENTRY CONNECTING ',   
     1       'PIVOT SIL =',I9,' ON DATA BLOCK',I5, /5X,        
     2       'TOO LARGE FOR A LOCAL ARRAY. ENTRY IS BEING IGNORED.')    
      CALL READ (*1770,*1780,GPECT,0,-LENGTH,NOEOR,IWORDS)        
      GO TO 1120        
C        
C     LOCATE ELEMENT FORCE DICTIONARY FOR THIS ELEMENT ENTRY.        
C        
 1140 CALL READ (*1770,*1780,GPECT,BUF,LENGTH,NOEOR,IWORDS)        
      KTYPE = BUF(2)*3 - 3 + IDTAB        
      PTR   = Z(KTYPE)        
      LDICTS= Z(KTYPE+2)        
      IF (LDICTS .EQ. 0) GO TO 1180        
      N = Z(KTYPE+1)        
      CALL BISLOC (*1180,BUF(1),Z(PTR),N/LDICTS,LDICTS,J)        
      J = PTR + J        
      OUT(1) = Z(J)        
C        
C     FOUND DICTIONARY.  DETERMINE GINO-LOC TO USE.        
C        
      DO 1150 I = 3,LENGTH        
      J = J + 1        
      IF (BUF(I).EQ.PIVOT .AND. Z(J).GT.0) GO TO 1170        
 1150 CONTINUE        
      WRITE  (OUTPT,1160) SWM,PIVOT,OUT(1),GPECT        
 1160 FORMAT (A27,' 2350.  GPFDR CANNOT FIND PIVOT SIL =',I10, /5X,     
     1       'AMONG THE SILS OF ELEMENT ID =',I9,        
     2       ' AS READ FROM DATA BLOCK',I5,',  ENTRY THUS IGNORED.')    
      GO TO 1120        
C        
 1170 K = BUF(2)*INCR - INCR        
      OUT(2) = ELEM(K+1)        
      OUT(3) = ELEM(K+2)        
      OUT(4) = Z(J)        
C        
C     GINO-LOC IN P-DICTIONARY NO LONGER NEEDED, THUS SET IT NEGATIVE   
C     TO AVOID RE-USE IN CASE WHERE AN ELEMENT CONNECTS SAME GRID MORE  
C     THAN ONCE.        
C        
      Z(J) = -Z(J)        
C        
C     OUTPUT THE 4-WORD ENTRY TO -GPFBOM-        
C        
      CALL WRITE (SCRT2,OUT,4,NOEOR)        
C        
C     INCREMENT COUNTS        
C        
      NENTRY = NENTRY + 1        
C        
C     GET THE NEXT ELEMENT ENTRY.        
C        
      GO TO 1120        
C        
C     HERE WHEN PMAT DICTIONARY MISSING FOR AN ELEMENT        
C     CONNECTED TO A GRID POINT TO HAVE GP-FORCE BALANCE OUTPUT.        
C        
 1180 KKK = BUF(2)*INCR - INCR        
      WRITE  (OUTPT,1190) UIM,ELEM(KKK+1),ELEM(KKK+2),EXTID        
 1190 FORMAT (A29,' 2351. A FORCE CONTRIBUTION  DUE TO ELEMENT TYPE = ',
     1       2A4,', ON POINT ID =',I10, /5X,        
     2       'WILL NOT APPEAR IN THE GRID-POINT-FORCE-BALANCE SUMMARY.')
      GO TO 1120        
C        
C     SIL NOT FOUND IN LIST OF SILS, OR NOT REQUESTED.        
C        
 1200 WRITE  (OUTPT,1210) SWM,PIVOT,GPECT        
 1210 FORMAT (A27,' 2352.  GPFDR IS NOT ABLE TO FIND PIVOT SIL =',I10,  
     1       ' AS READ FROM DATA BLOCK',I5, /5X,'IN TABLE OF SILS.')    
C        
 1220 CALL FWDREC (*1770,GPECT)        
      GO TO 1100        
C        
C     HERE WHEN END OF RECORD ON GPECT.        
C     COMPLETE THE RECORD ON -GPFBOM- AND WRITE DICTIONARY ENTRY FOR THE
C     COMPLETED RECORD.        
C        
 1230 CALL WRITE (SCRT2,0,0,EOR)        
      BUF(1) = EXTID        
      BUF(3) = NENTRY        
      CALL SAVPOS (SCRT2,BUF(2))        
      CALL WRITE (SCRT3,BUF,3,NOEOR)        
C        
C     GO FOR NEXT PIVOT SIL        
C        
      GO TO 1100        
C        
C     HERE WHEN END OF FILE ON -GPECT-.        
C        
 1240 CALL CLOSE (GPECT,CLSREW)        
      CALL CLOSE (SCRT2,CLSREW)        
      CALL CLOSE (SCRT3,CLSREW)        
C        
C     SO AS TO OUTPUT THE FORCE BALANCES IN EXTERNAL GRID POINT ORDER   
C     THE FOLLOWING STEPS ARE NOW PERFORMED ON THE DICTIONARY ENTRIES OF
C     THE -GPFBOM- COMPANION FILE (SCRT3).        
C        
C     1) ALL OF THE COMPANION FILE DICTIONARIES ARE READ INTO CORE.     
C     2) THEY ARE SORTED ON THE EXTERNAL IDS.        
C     3) THEY ARE PARTITIONED INTO GROUPS BASED ON A CONSIDERATION OF   
C        THE NEED FOR 12 WORDS OF CORE FOR EACH ENTRY OF EACH -GPFBOM-  
C        RECORD REPRESENTED BY THE GROUP IN THE FINAL OUTPUT PASS.      
C     4) EACH ENTRYS 3-RD WORD (THE NUMBER OF ENTRIES IN THE RECORD) IS 
C        REPLACED WITH THE INTEGER POSITION OF THE ENTRY IN THE GROUP.  
C     5) EACH GROUP IS SORTED ON GINO-LOC AND WRITTEN BACK        
C        TO THE COMPANION FILE AS A LOGICAL RECORD.  (THIS INSURES THAT 
C        NO MORE THAN ONE PASS OF THE -GPFBOM- IS MADE PER GROUP WHEN   
C        CONSTRUCTING TABLE-1 AND TABLE-2 IN THE FINAL OUTPUT PASS.)    
C        
      FILE = SCRT3        
      NERROR = 20        
      CALL OPEN (*1760,SCRT3,Z(BUF3),RDREW)        
C        
C     BLAST-READ 3-WORD -GPFBOM- DICTIONARY ENTRIES INTO CORE.        
C        
      IDICTS = NCC + 1        
      CALL READ (*1770,*1250,SCRT3,Z(IDICTS),CORE-IDICTS,NOEOR,IWORDS)  
      GO TO 1800        
C        
 1250 NDICTS = IDICTS + IWORDS - 1        
      CALL CLOSE (SCRT3,CLSREW)        
      NERROR = 21        
      CALL OPEN (*1760,SCRT3,Z(BUF3),WRTREW)        
C        
C     SORT ENTRIES ON EXTERNAL ID        
C        
      CALL SORT (0,0,3,1,Z(IDICTS),IWORDS)        
C        
C     DETERMINE A -GPFBOM- GROUP OF RECORDS FOR OUTPUT.  EACH -GPFBOM-  
C     RECORDS ENTRY WILL REQUIRE 12 WORDS OF CORE IN THE FINAL OUTPUT   
C     PROCEEDURES.        
C        
      ENTRYS = (CORE-NCC)/12        
 1260 J = IDICTS        
      TOTAL = 0        
 1270 IF (TOTAL+Z(J+2) .GT. ENTRYS) GO TO 1280        
      TOTAL = TOTAL + Z(J+2)        
      J = J + 3        
      IF (J .LT. NDICTS) GO TO 1270        
C        
C     GROUP RANGE HAS BEEN FOUND.  REPLACE EACH ENTRYS -GPFBOM- ENTRY   
C     COUNT WITH THE OUTPUT ORDER OF THE EXTERNAL ID ENTRY HERE.        
C        
 1280 JDICTS = J - 1        
      K  = 1        
      DO 1290 I = IDICTS,JDICTS,3        
      JK = Z(I+2)        
      Z(I+2) = K        
      K  = K + JK        
 1290 CONTINUE        
C        
C     SORT THIS GROUP OF 3-WORD ENTRIES ON THE GINO-LOCS.        
C        
      LENGTH = JDICTS - IDICTS + 1        
      CALL SORT (0,0,3,2,Z(IDICTS),LENGTH)        
C        
C     OUTPUT AS A LOGICAL RECORD.        
C        
      CALL WRITE (SCRT3,Z(IDICTS),LENGTH,EOR)        
C        
C     PROCESS NEXT GROUP IF THERE ARE MORE.        
C        
      IDICTS = JDICTS + 1        
      IF (IDICTS .LT. NDICTS) GO TO 1260        
C        
C     ALL GROUPS HAVE BEEN DETERMINED, SEQUENCED, SORTED ON GINO-LOCS,  
C     AND OUTPUT.        
C        
      CALL CLOSE (SCRT3,CLSREW)        
C        
C     PREPARE GRID-POINT-FORCE-BALANCE ENTRIES WITH RESPECT TO APPLIED- 
C     LOAD AND SINGLE-POINT-CONSTRAINT FORCES.        
C        
C     LINE ENTRIES WILL BE WRITTEN TO SCRT4 FROM THE VECTOR IN CORE     
C     FOR EACH OF PG AND QG CONTAINING,        
C        
C     EXTERNAL GP ID, 0, 4H----, 4H----, T1, T2, T3, R1, R2, R3,        
C        
C     ONLY FOR THOSE POINTS WHICH MAY BE OUTPUT IN THE GRID-POINT FORCE 
C     BALANCE.        
C        
C     (NULL ENTRIES ARE NOT OUTPUT)        
C        
C     AFTER ALL ENTRIES FOR PG AND QG DESIRED HAVE BEEN WRITTEN TO      
C     SCRT4 THEY ARE BROUGHT BACK INTO CORE, SORTED ON EXTERNAL GP ID   
C     AND RE-OUTPUT TO SCRT4.        
C        
      FILE = SCRT4        
      CALL OPEN (*1760,SCRT4,Z(BUF1),WRTREW)        
C        
C     PROCESS PG.        
C        
      UGPGQG = PG        
      BUF(2) = 0        
      BUF(3) = OLOAD(1)        
      BUF(4) = OLOAD(2)        
      LASTID = 0        
      NEXTGP = 1        
      ASSIGN 1300 TO ICONT        
      GO TO 1400        
C        
C     PROCESS QG        
C        
 1300 UGPGQG = QG        
      BUF(3) = OSPCF(1)        
      BUF(4) = OSPCF(2)        
      LASTID = 0        
      NEXTGP = 1        
      ASSIGN 1310 TO ICONT        
      GO TO 1400        
C        
C     SORT SCRT4 ENTRIES ON EXTERNAL GP ID        
C        
 1310 CALL WRITE (SCRT4,0,0,EOR)        
      CALL CLOSE (SCRT4,CLSREW)        
      MOVEPQ = 0        
      CALL OPEN (*1760,SCRT4,Z(BUF1),RDREW)        
      CALL READ (*1770,*1330,SCRT4,Z(ICC),BUF1-ICC,NOEOR,IWORDS)        
      WRITE  (OUTPT,1320) UWM,SUBCAS        
 1320 FORMAT (A25,' 2353.  INSUFFICIENT CORE TO HOLD ALL NON-ZERO APP-',
     1       'LOAD AND F-OF-SPC OUTPUT LINE ENTRIES OF', /5X,        
     2       'GRID-POINT-FORCE-BALANCE REQUESTS. SOME POINTS REQUESTED',
     3       ' FOR OUTPUT WILL BE MISSING THEIR APP-LOAD OR F-OF-SPC',  
     4       /5X,'CONTRIBUTION IN THE PRINTED BALANCE.')        
      IWORDS = BUF1 - ICC - MOD(BUF1-ICC,10)        
 1330 CALL SORT  (0,0,10,1,Z(ICC),IWORDS)        
      CALL CLOSE (SCRT4,CLSREW)        
      CALL OPEN  (*1760,SCRT4,Z(BUF1),WRTREW)        
      CALL WRITE (SCRT4,Z(ICC),IWORDS,EOR)        
      CALL CLOSE (SCRT4,CLSREW)        
      GO TO 1560        
C        
C     INTERNAL ROUTINE TO GET A VECTOR IN CORE (PG OR QG) AND WRITE     
C     SELECTED NON-ZERO ENTRIES TO SCRT4 FOR INCLUSION LATER IN THE     
C     GRID-POINT-FORCE-BALANCE.        
C        
 1400 CALL OPEN (*1550,UGPGQG,Z(BUF2),RD)        
      IF (MOVEPQ) 1410,1450,1430        
C        
C     BACK POSITION DATA BLOCK        
C        
 1410 J = IABS(MOVEPQ)        
      DO 1420 I = 1,J        
      CALL BCKREC (UGPGQG)        
 1420 CONTINUE        
      GO TO 1450        
C        
C     FORWARD POSITION DATA BLOCK        
C        
 1430 FILE = UGPGQG        
      DO 1440 I = 1,MOVEPQ        
      CALL FWDREC (*1770,UGPGQG)        
 1440 CONTINUE        
C        
C     GET VECTOR INTO CORE.        
C        
 1450 ASSIGN 1460 TO IRETRN        
      GO TO 220        
C        
C     OUTPUT NON-ZERO ENTRIES REQUESTED        
C        
 1460 CALL CLOSE (UGPGQG,CLS)        
      DO 1540 I = ISILEX,NSILEX,2        
      ICODE = MOD(Z(I),10)        
      I1 = IVECZ + Z(I+1)        
      I2 = I1 + SCALE(ICODE)        
      DO 1470 J = I1,I2        
      IF (RZ(J)) 1480,1470,1480        
 1470 CONTINUE        
      GO TO 1540        
C        
C     NON-ZERO ENTRY.  CHECK FOR OUTPUT.        
C        
 1480 BUF(1) = Z(I)/10        
      IBUF1  = BUF(1)        
      IF (AXIC) IBUF1 = MOD(IBUF1,1000000)        
      IF (AXIF) IBUF1 = MOD(IBUF1,500000 )        
      IF (IBUF1 .LT. LASTID) NEXTGP = 1        
      LASTID = IBUF1        
      IF (GPSET) 1500,1550,1490        
 1490 CALL SETFND (*1540,Z(IGPLST),LGPLST,IBUF1,NEXTGP)        
 1500 L = 5        
      DO 1510 J = I1,I2        
      BUF(L) = Z(J)        
      L = L + 1        
 1510 CONTINUE        
      IF (L .GE. 11) GO TO 1530        
      DO 1520 J = L,10        
      RBUF(L) = 0.0        
 1520 CONTINUE        
 1530 BUF(1) = BUF(1)*10 + GPDVIS        
      CALL WRITE (SCRT4,BUF,10,NOEOR)        
 1540 CONTINUE        
 1550 GO TO ICONT, (1300,1310)        
 1560 CONTINUE        
C        
C     FINAL OUTPUT PHASE FOR CURRENT CASE CONTROL.        
C        
C     THE -GPFBOM- COMPANION FILE IS PROCESSED RECORD BY RECORD.        
C        
C     FOR EACH RECORD THEN,        
C        
C     1) A 3-WORD ENTRY IS READ GIVING 1) EXTERNAL GP-ID        
C                                      2) GINO-LOC OF -GPFBOM- RECORD   
C                                      3) OUTPUT ORDER WITHIN THE GROUP.
C        
C     2) -GPFBOM- IS POSITIONED USING THE GINO-LOC.        
C        
C     3) A POINTER IS DETERMINED INTO TABLE-2 OF WHERE OUTPUTS BELONG   
C        =10*ORDER - 10  (A ZERO POINTER) + TABLE BASE (A ZERO POINTER) 
C        
C     4) ENTRIES ARE READ FROM -GPFBOM- CONTAINING,        
C        
C                                      1) EXTERNAL ELEMENT ID        
C                                      2) ELEMENT NAME FIRST 4H        
C                                      3) ELEMENT NAME LAST  4H        
C                                      4) GINO LOC TO 6X1 FORCE VECTOR  
C        
C        UNTIL AN EOR IS ENCOUNTERED.        
C        
C        FOR EACH ENTRY READ A 2-WORD ENTRY IS ADDED TO TABLE-1        
C        CONSISTING OF                 1) GINO-LOC TO THE 6X1 VECTOR    
C                                      2) PTR INTO TABLE-2        
C        
C        AND A 10-WORD ENTRY IS ADDED TO TABLE-2 AT Z(PTR)        
C        CONSISTING OF                 1) EXTERNAL GP-ID        
C                                      2) EXTERNAL ELEMENT-ID        
C                                      3) NAME FIRST 4H        
C                                      4) NAME LAST  4H        
C                                      5 THRU 10)   NOT SET YET.        
C        
C     5) WHEN ALL ENTRIES OF THE -GPFBOM- RECORDS OF THE GROUP        
C        (AS SPECIFIED BY ONE RECORD ON THE COMPANINON FILE) ARE IN CORE
C        TABLE-1 IS SORTED ON GINO LOCS.        
C        THIS WILL PREVENT HAVING TO MAKE MORE THAN ONE PASS        
C        OF THE PMAT DATA PER GROUP.        
C        
C     6) A SERIAL PASS OF TABLE-1 IS MADE AND EACH 6X1 VECTOR IS        
C        READ DIRECTLY INTO Z(PTR+4) OF TABLE-2.        
C        
C     7) OUTPUT TO THE FORCE BALANCE DATA BLOCK IS MADE WITH THE        
C        STANDARD OFP METHOD OF HEADER RECORD, AND REPEATING ENTRY DATA 
C        RECORD.  A HEADER RECORD WILL BE OUTPUT EACH TIME THE GRID     
C        POINT CHANGES.        
C        
C        
C     ALLOCATE TABLE-1 AND TABLE-2        
C        
      ITAB1 = NCC + 1        
      NTAB1 = NCC + 2*ENTRYS        
      ITAB2 = NTAB1 + 1        
C        
C     OPEN -GPFBOM- (SCRT2) AND ITS COMPANION DICTIONARY FILE (SCRT3).  
C        
      FILE   = SCRT2        
      NERROR = 23        
      CALL OPEN (*1760,SCRT2,Z(BUF2),RDREW)        
      FILE = SCRT3        
      CALL OPEN (*1760,SCRT3,Z(BUF3),RDREW)        
C        
C     OPEN THE OUTPUT FILE FOR GP-FORCES.        
C        
      FILE = OGPF1        
      CALL OPEN (*1760,OGPF1,Z(BUF4),WRT)        
      LINES    = 0        
      IDREC(1) = 10*BRANCH + GPDVIS        
      IDREC(2) = 19        
      IDREC(4) = SUBCAS        
      IDREC(10)= 10        
C        
C     OPEN THE PMAT 6X1 FORCE VECTORS FILE.        
C        
      FILE = SCRT1        
      CALL OPEN (*1760,SCRT1,Z(BUF1),RDREW)        
C        
C     INITIALIZE INPUT OF APP-LOAD AND F-OF-SPC LINE ENTRIES FROM SCRT4.
C        
      FILE = SCRT4        
      CALL OPEN (*1760,SCRT4,Z(BUF5),RDREW)        
      CALL READ (*1770,*1570,SCRT4,KVEC,10,NOEOR,IWORDS)        
      EORST4 = .FALSE.        
      GO TO 1580        
 1570 EORST4 = .TRUE.        
 1580 CONTINUE        
C        
C     PROCESS ONE GROUP OF -GPFBOM- RECORDS AS SPECIFIED BY THE 3-WORD  
C     ENTRIES OF ONE RECORD ON SCRT3.        
C        
      ANY   = .FALSE.        
      OLDID = 0        
      CALL WRITE (OGPF1,IDREC,146,EOR)        
 1590 IPTR1 = ITAB1 - 1        
      JTAB1 = ITAB1 - 1        
      JTAB2 = ITAB2 - 1        
      FILE  = SCRT2        
 1600 CALL READ (*1740,*1620,SCRT3,BUF,3,NOEOR,IWORDS)        
      EXTGP = BUF(1)        
      LOC   = BUF(2)        
      IPTR2 = ITAB2 + 10*BUF(3) - 11        
C        
C     POSITION -GPFBOM- TO RECORD OF 4-WORD ENTRIES FOR THIS EXTERNAL GP
C        
      CALL FILPOS (SCRT2,LOC)        
      NERROR = 24        
C        
C     READ AND DISTRIBUTE THE DATA OF THE 4-WORD ENTRIES.        
C        
 1610 CALL READ (*1770,*1600,SCRT2,BUF,4,NOEOR,IWORDS)        
      Z(IPTR1+1) = BUF(4)        
      Z(IPTR1+2) = IPTR2        
      Z(IPTR2+1) = EXTGP        
      Z(IPTR2+2) = BUF(1)        
      Z(IPTR2+3) = BUF(2)        
      Z(IPTR2+4) = BUF(3)        
      IPTR1 = IPTR1 + 2        
      IPTR2 = IPTR2 + 10        
      JTAB1 = JTAB1 + 2        
      JTAB2 = JTAB2 + 10        
      GO TO 1610        
C        
C     HERE ON END OF A GROUP.  SORT TABLE-1 ON GINO LOCS.        
C     AND FILL TABLE-2 WITH 6X1 FORCE VECTORS.        
C        
 1620 CALL SORT (0,0,2,1,Z(ITAB1),JTAB1-ITAB1+1)        
C        
      NERROR= 25        
      FILE  = SCRT1        
      DO 1630 I = ITAB1,JTAB1,2        
      CALL FILPOS (SCRT1,Z(I))        
      PTR = Z(I+1)        
      CALL READ (*1770,*1780,SCRT1,Z(PTR+5),6,NOEOR,IWORDS)        
 1630 CONTINUE        
C        
C     OUTPUT DATA.  START NEW SUM WHEN ENCOUNTERING A NEW GP-ID.        
C     APPLIED-LOADS AND FORCES-OF-SPC WILL INITIALIZE SUM, IF THEY EXIST
C     FOR GRID POINT IN QUESTION,  OHTERWISE SUM IS INITIALIZED TO ZERO.
C        
      DO 1730 I = ITAB2,JTAB2,10        
C        
C     IS THIS SAME GRID POINT ID AS CURRENTLY BEING SUMMED.  IF SO,     
C     CONTINUE OUTPUT OF LINE ENTRY AND SUM IN.  OTHERWISE OUTPUT       
C     SUM LINE, AND NEW ID-S APPLIED-LOAD AND F-OF-SPC ENTRY.        
C        
 1640 IF (Z(I) .EQ. OLDID) GO TO 1710        
C        
C     CHANGE IN GRID POINT ID.        
C        
      ISUM(1) = OLDID*10 + GPDVIS        
      IF (ANY) CALL WRITE (OGPF1,ISUM,10,NOEOR)        
      IF (ANY) LINES = LINES + 1        
      ANY = .FALSE.        
C        
C     OUTPUT ALL LINE ENTRIES OF APP-LOADS AND F-OF-SPC UNTIL        
C     MATCH ON NEW ID IS FOUND OR CURRENT FVEC IS NOT YET NEEDED.       
C        
      IF (EORST4) GO TO 1690        
      IF (KVEC(1)/10 .GT. Z(I)) GO TO 1690        
      DO 1650 J = 5,10        
      RSUM(J) = FVEC(J)        
 1650 CONTINUE        
      OLDID = KVEC(1)/10        
      CALL WRITE (OGPF1,KVEC,10,NOEOR)        
      LINES = LINES + 1        
      ANY   = .TRUE.        
C        
C     SUM IN ANY MORE FROM SCRT4 OF CURRENT ID, OUTPUT LINE ENTRIES.    
C        
 1660 CALL READ (*1770,*1680,SCRT4,KVEC,10,NOEOR,IWORDS)        
      IF (KVEC(1)/10 .NE. OLDID) GO TO 1640        
      CALL WRITE (OGPF1,KVEC,10,NOEOR)        
      LINES = LINES + 1        
      DO 1670 J = 5,10        
      RSUM(J) = RSUM(J) + FVEC(J)        
 1670 CONTINUE        
      GO TO 1660        
C        
 1680 EORST4 = .TRUE.        
      GO TO 1640        
C        
C     NO APP-LOAD OR F-OF-SPC ENTRIES LEFT OR CURRENT ONE NOT NEEDED YET
C        
 1690 DO 1700 J = 5,10        
      RSUM(J) = 0.0        
 1700 CONTINUE        
      ANY  = .TRUE.        
      OLDID= Z(I)        
C        
 1710 Z(I) = 10*Z(I) + GPDVIS        
      CALL WRITE (OGPF1,Z(I),10,NOEOR)        
      LINES = LINES + 1        
      DO 1720 J = 5,10        
      RSUM(J) = RSUM(J) + RZ(I+J-1)        
 1720 CONTINUE        
C        
 1730 CONTINUE        
C        
      ISUM(1) = OLDID*10 + GPDVIS        
      IF (ANY) CALL WRITE (OGPF1,ISUM,10,NOEOR)        
      IF (ANY) LINES = LINES + 1        
      ANY = .FALSE.        
C        
C     GO FOR NEXT GROUP FROM THE -GPFBOM-.        
C        
      GO TO 1590        
C        
C     HERE ON EOF ON -GPFBOM- COMPANION FILE.  THUS AT CONCLUSION OF    
C     OUTPUT PHASE FOR GP-FORCE BALANCE ONE SUBCASE, OR ONE TIME STEP OF
C     ONE SUBCASE.        
C        
 1740 CALL CLOSE (SCRT1,CLSREW)        
      CALL CLOSE (SCRT2,CLSREW)        
      CALL CLOSE (SCRT3,CLSREW)        
      CALL CLOSE (SCRT4,CLSREW)        
      MCB(1) = OGPF1        
      CALL RDTRL (MCB)        
      MCB(2) = MCB(2) + LINES        
      CALL WRTTRL (MCB)        
      CALL CLOSE (OGPF1,CLSEOF)        
      GO TO 110        
C        
C     NORMAL COMPLETION.        
C        
 1750 CALL CLOSE (CASECC,CLSREW)        
      CALL CLOSE (UG,CLSREW)        
      RETURN        
C        
C     HERE ON ERROR CONDITIONS.        
C        
 1760 MM = 1        
      GO TO 1790        
 1770 MM = 2        
      GO TO 1790        
 1780 MM = 3        
 1790 CALL MESAGE (MM,FILE,SUBR)        
      GO TO 1810        
 1800 CALL MESAGE (8,0,SUBR)        
 1810 WRITE  (OUTPT,1820) SWM,NERROR        
 1820 FORMAT (A27,' 2354.' ,/5X,'GPFDR MODULE IS UNABLE TO CONTINUE ',  
     1       'AND HAS BEEN TERMINATED DUE TO ERROR MESSAGE PRINTED ',   
     2       'ABOVE OR BELOW THIS MESSAGE.', /5X,'THIS ERROR OCCURRED ',
     4       'IN GPFDR CODE WHERE THE VARIABLE -NERROR- WAS SET =',I5)  
      DO 1840 I = 100,300,100        
      DO 1830 J = 1,9        
      CALL CLOSE (I+J,CLSREW)        
 1830 CONTINUE        
 1840 CONTINUE        
      RETURN        
      END        
