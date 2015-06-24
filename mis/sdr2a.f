       SUBROUTINE SDR2A        
C        
C     SDR2A PROCESSES THE CASE CONTROL DATA BLOCK. DEPENDING ON THE     
C     RIGID FORMAT AND THE VARIOUS OUTPUT REQUESTS, SDR2A SETS FLAGS    
C     AND PARAMETERS TO CONTROL OPERATION OF THE REMAINDER OF THE PHASES
C     OF SDR2        
C        
      EXTERNAL        LSHIFT,RSHIFT        
      LOGICAL         AXIC  ,DDRMM ,STRAIN        
      INTEGER         Z     ,CASECC,CSTM  ,FILE  ,BUF1  ,BUF2  ,BUF3  , 
     1                BUF4  ,BUF5  ,ALL   ,ANY   ,DISPL ,SPCF  ,STRESS, 
     2                ELDEF ,ANY1  ,SETNO ,ZI    ,RSHIFT,STRNFL,FORCE , 
     3                PREVS ,PREVF ,TWO   ,PLOTS ,RET   ,PASS  ,SYSBUF, 
     4                APP   ,STA   ,REI   ,DS0   ,DS1   ,FRQ   ,TRN   , 
     5                BK0   ,BK1   ,CEI   ,PLA   ,BRANCH,SORT2 ,VEL   , 
     6                ACC   ,TLOADS        
      COMMON /MACHIN/ MACH  ,IHALF ,JHALF        
CZZ   COMMON /ZZSDA2/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /BLANK / APP(2),SORT2,ISTRN  ,STRNFL,IDUMMY(5)    ,STRAIN  
      COMMON /SDR2X1/ IEIGEN,IELDEF,ITLOAD,ISYMFL,ILOADS,IDISPL,ISTR  , 
     1                IELF  ,IACC  ,IVEL  ,ISPCF ,ITTL  ,ILSYM        
      COMMON /SDR2X2/ CASECC,CSTM  ,MPT   ,DIT   ,EQEXIN,SIL   ,GPTT  , 
     1                EDT   ,BGPDT ,PG    ,QG    ,UGV   ,EST   ,PHIG  , 
     2                EIGR  ,OPG1  ,OQG1  ,OUGV1 ,OES1  ,OEF1  ,PUGV1 , 
     3                OEIGR ,OPHIG ,PPHIG ,ESTA  ,GPTTA ,HARMS        
      COMMON /SDR2X4/ NAM(2),END   ,MSET  ,ICB(7),OCB(7),MCB(7),DTYPE(8)
     1,               ICSTM ,NCSTM ,IVEC  ,IVECN ,TEMP  ,DEFORM,FILE  , 
     2                BUF1  ,BUF2  ,BUF3  ,BUF4  ,BUF5  ,ANY   ,ALL   , 
     3                TLOADS,ELDEF ,SYMFLG,BRANCH,KTYPE ,LOADS ,SPCF  , 
     4                DISPL ,VEL   ,ACC   ,STRESS,FORCE ,KWDEST,KWDEDT, 
     5                KWDGPT,KWDCC ,NRIGDS,STA(2),REI(2),DS0(2),DS1(2), 
     6                FRQ(2),TRN(2),BK0(2),BK1(2),CEI(2),PLA(22)      , 
     7                NRINGS,NHARMS,AXIC  ,KNSET ,ISOPL ,STRSPT,DDRMM   
      COMMON /NAMES / RD    ,RDREW ,WRT   ,WRTREW,CLSREW        
      COMMON /SYSTEM/ SYSBUF,OPTE  ,NOGO  ,INTAP ,MPCN  ,SPCN  ,METHOD, 
     1                LOADNN,SYMM  ,STFTMP,PAGE  ,LINE  ,TLINE ,MAXLIN, 
     2                DATE(3)      ,TIME  ,ECHO  ,PLOTS ,DDD(6),MN      
      COMMON /TWO   / TWO(32)        
      DATA    MMREIG/ 4HMMRE /        
C        
C        
C     CHECK FOR STRAIN OPTION        
C        
      STRAIN = .FALSE.        
      IF (ISTRN .GE. 0) STRAIN = .TRUE.        
C        
C     PERFORM BUFFER ALLOCATION.        
C        
      BUF1 = KORSZ(Z) - SYSBUF - 2        
      BUF2 = BUF1 - SYSBUF        
      BUF3 = BUF2 - SYSBUF        
      BUF4 = BUF3 - SYSBUF        
      BUF5 = BUF4 - SYSBUF        
C        
C     SET PARAMETER FOR APPROACH.        
C        
      N = 2*NRIGDS - 1        
C        
C     FIRST CHECK FOR SPECIAL APPROACH FOR DYNAMIC-DATA-RECOVERY-MATRIX-
C     METHOD.  IF APPROACH IS -MMREIG- THEN DDRMM FLAG IS SET TO INSURE 
C     ENOUGH OUTPUTS UNDER CERTAIN CONDITIONS.        
C        
      DDRMM = .FALSE.        
      IF (APP(1) .NE. MMREIG) GO TO 7        
      DDRMM = .TRUE.        
      I = 3        
      GO TO 20        
C        
    7 DO 10 I = 1,N,2        
      IF (STA(I) .EQ. APP(1)) GO TO 20        
   10 CONTINUE        
      CALL MESAGE (-30,75,APP)        
   20 BRANCH = (I+1)/2        
C        
C    OPEN CASE CONTROL. SKIP HEADER RECORD.        
C    IF DIFF. STIFF. PHASE 1 OR BUCKLING PHASE 1, SKIP 1ST CASECC RECORD
C        
      CALL GOPEN (CASECC,Z(BUF1),RDREW)        
      IF (APP(1).EQ.DS1(1) .OR. APP(1).EQ.BK1(1)) CALL SKPREC (CASECC,1)
      KWDCC = 0        
C        
C     INITIALIZE VARIOUS OUTPUT REQUEST FLAGS.        
C        
      ALL   = 0        
      ANY   = 0        
      DISPL = 0        
      VEL   = 0        
      ACC   = 0        
      SPCF  = 0        
      LOADS = 0        
      STRESS= 0        
      FORCE = 0        
      TLOADS= 0        
      ELDEF = 0        
      II    = 0        
      PREVS = 0        
      PREVF = 0        
C        
C     READ A RECORD IN CASE CONTROL.        
C     IF REQUEST FOR STRESSES IS PRESENT, TURN ON STRESS FLAG.        
C     IF REQUEST FOR FORCES   IS PRESENT, TURN ON FORCE  FLAG.        
C     -ANY- FLAG = STRESS .OR. FORCE.        
C     -ALL- FLAG = ANY REQUEST FOR ALL STRESSES OR FORCES.        
C     IF ANY.NE.0 .AND ALL.EQ.0, BUILD LIST OF UNIQUE ELEMENT IDS.      
C        
   40 CALL READ (*220,*50,CASECC,Z,BUF5-1,1,NCC)        
      CALL MESAGE (+8,0,NAM)        
      ALL  = 1        
   50 ANY1 = 0        
      KWDCC= MAX0(KWDCC,NCC)        
      MSET = MAX0(MSET,KWDCC+1)        
C        
C     SET DMAP FLAG FOR USE IN DISP R.F. 1        
C        
      IF (ISTRN.GE.0 .OR. STRNFL.GE.0) GO TO 55        
      J = 180        
      IF (Z(J) .NE. 0) STRNFL = 1        
   55 ISTR = 23        
      IF (STRAIN) ISTR = 180        
      IF (Z(ISTR)) 60,80,70        
   60 ALL = 1        
   70 STRESS = 1        
      ANY1 = 1        
   80 IF (Z(IELF)) 90,110,100        
   90 ALL = 1        
  100 FORCE = 1        
      ANY1  = 1        
  110 IF (ALL.NE.0 .OR. ANY1.EQ.0) GO TO 200        
C        
C     INITIALIZE TO PROCESS STRESS OUTPUT REQUEST.        
C     BUILD MASTER SET LIST ONLY IF CURRENT SET ID IS NEW        
C        
      ASSIGN 190 TO PASS        
      SETNO = Z(ISTR)        
      IF (SETNO .EQ. PREVS) GO TO 190        
      PREVS = SETNO        
C        
C     IF REQUEST PRESENT, LOCATE SET DEFINITION IN CASE CONTROL DATA.   
C        
  120 IF (SETNO .EQ. 0) GO TO PASS, (190,200)        
      ISETNO = ILSYM + Z(ILSYM) + 1        
  130 ISET = ISETNO + 2        
      NSET = Z(ISETNO+1) + ISET - 1        
      IF (Z(ISETNO) .EQ. SETNO) GO TO 140        
      ISETNO = NSET + 1        
      IF (ISETNO .LT. NCC) GO TO 130        
      ALL = 1        
      GO TO 200        
C        
C     PICK UP ELEMENT IDS IN SET. SAVE IN UNIQUE LIST.        
C        
  140 I = ISET        
  150 IF (I  .EQ.  NSET) GO TO 170        
      IF (Z(I+1) .GT. 0) GO TO 170        
      ZI= Z(I  )        
      N =-Z(I+1)        
      I = I + 1        
      ASSIGN 160 TO RET        
      GO TO 260        
  160 ZI = ZI + 1        
C     IF (ZI .LE. N) GO TO 260        
C     GO TO 180        
      IF (ZI .GT. N) GO TO 180        
      II =II + 1        
      IF (II .GT. BUF2) GO TO 280        
      Z(II) = ZI        
      GO TO 160        
  170 ZI = Z(I)        
      ASSIGN 180 TO RET        
      GO TO 260        
  180 I = I + 1        
      IF (I .LE. NSET) GO TO 150        
      GO TO PASS, (190,200)        
C        
C     INITIALIZE TO PROCESS FORCE OUTPUT REQUEST.        
C     BUILD MASTER SET LIST ONLY IF CURRENT SET ID IS NEW        
C        
  190 SETNO = Z(IELF)        
      IF (SETNO .EQ. PREVF) GO TO 200        
      PREVF = SETNO        
      ASSIGN 200 TO PASS        
      GO TO 120        
C        
C     TURN ON FLAGS FOR OTHER OUTPUT REQUESTS.        
C        
  200 IF (Z(ILOADS) .NE. 0) LOADS = 1        
      IF (Z(ISPCF ) .NE. 0) SPCF  = 1        
      IF (Z(IDISPL) .NE. 0) DISPL = 1        
      IF (Z(IVEL  ) .NE. 0) VEL   = 1        
      IF (Z(IACC  ) .NE. 0) ACC   = 1        
      IF (Z(IELDEF) .NE. 0) ELDEF = 1        
      IF (Z(ITLOAD) .NE. 0) TLOADS= 1        
      IF (Z(ILOADS+2).LT.0 .OR. Z(ISPCF +2).LT.0 .OR.        
     1    Z(IDISPL+2).LT.0 .OR. Z(IVEL  +2).LT.0 .OR.        
     2    Z(IACC  +2).LT.0 .OR. Z(ISTR  +2).LT.0 .OR.        
     3    Z(IELF  +2).LT.0 .OR. APP(     1).EQ.TRN(1)) SORT2 = 1        
      ANY = STRESS + FORCE        
C        
C     CONICAL SHELL PROBLEM        
C        
      AXIC = .FALSE.        
      IF (MN .EQ. 0) GO TO 210        
      NRINGS = RSHIFT(MN,IHALF)        
      NHARMS = MN - LSHIFT(NRINGS,IHALF)        
      AXIC = .TRUE.        
  210 CONTINUE        
C        
C     RETURN TO READ ANOTHER RECORD IN CASE CONTROL (UNLESS DIFF STIFF  
C     PHASE 0 OR BUCKLING PHASE 0)        
C        
      IF (APP(1).NE.DS0(1) .AND. APP(1).NE.BK0(1)) GO TO 40        
C        
C     IF ALL .EQ. 0, SORT LIST OF ELEMENT IDS AND MOVE LIST TO END OF   
C     CORE. AND THROW AWAY ANY DUPLICATE.        
C        
  220 IF (ALL.NE.0 .OR. ANY.EQ.0) GO TO 240        
      KN = II - MSET + 1        
      CALL SORT (0,0,1,-1,Z(MSET),KN)        
      JJ = BUF2 - 1        
  230 Z(JJ) = Z(II)        
C     JJ = JJ - 1        
C     II = II - 1        
  235 II = II - 1        
      IF (Z(II) .EQ. Z(JJ)) GO TO 235        
      JJ = JJ - 1        
      IF (II .GE. MSET) GO TO 230        
      MSET  = JJ + 1        
      KNSET = BUF2 - MSET        
      GO TO 250        
  240 MSET = BUF2 - 1        
C        
C     CLOSE CASE CONTROL AND RETURN        
C        
  250 CALL CLOSE (CASECC,CLSREW)        
      IF (APP(1) .NE. BK1(1)) RETURN        
      ELDEF = 0        
      TLOADS= 0        
      RETURN        
C        
C        
C     SEARCH LIST OF ELEM ID. IF CURRENT ID IS IN LIST RETURN        
C     OTHERWISE ADD ID TO LIST        
C        
C 260 IF (II .NE. 0) GO TO 270        
C     Z(MSET) = ZI        
C     II = MSET        
C     GO TO RET, (160,180)        
C 270 DO 280 J = MSET,II        
C     IF (Z(J) .EQ. ZI) GO TO RET, (160,180)        
C 280 CONTINUE        
C        
C     ADD ELEM ID TO LIST. NO NEED TO CHECK DUPLICATE ID HERE        
C        
  260 IF (II .EQ. 0) II = MSET - 1        
      II = II + 1        
      IF (II .LT. BUF2) GO TO 290        
  280 ALL = 1        
      GO TO 200        
  290 Z(II) = ZI        
      GO TO RET, (160,180)        
C        
      END        
