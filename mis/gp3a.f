      SUBROUTINE GP3A
C
C     GP3A BUILDS THE STATIC LOADS TABLE (SLT).
C     FORCE, FORCE1, FORCE2, MOMENT, MOMNT1, MOMNT2, GRAV, PLOAD, SLOAD
C     AND LOAD CARDS ARE READ. EXTERNAL GRID NOS. ARE CONVERTED TO
C     INTERNAL INDICES. EACH LOAD SET ID (EXCEPT ON LOAD CARD) IS
C     WRITTEN IN THE HEADER RECORD OF THE SLT. THE SLT THEN COMPRISES
C     ONE LOGICAL RECORD PER LOAD SET. THE LAST RECORD OF THE SLT
C     CONTAINS THE LOAD CARDS. RFORCE CARD ADDED IN AUGUST, 1968.
C     PLOAD3 CARD ADDED ON HALLOWEEN 1972
C
      LOGICAL         PIEZ
      INTEGER         GEOM3 ,EQEXIN,SLT   ,GPTT  ,BUF1  ,BUF2  ,BUF   ,
     1                Z     ,RD    ,RDREW ,WRT   ,WRTREW,CLSREW,CARDID,
     2                CARDDT,STATUS,FILE  ,GPOINT,SCR1  ,SCR2  ,FIRST ,
     3                SETID ,FLAG  ,NAM(2),KSYSTM(80)
      CHARACTER       UFM*23
      COMMON /XMSSG / UFM
      COMMON /SYSTEM/ ISB   ,IPTR  ,IDM(6),NLPP  ,IDUM(2),LINES
      COMMON /BLANK / NOGRAV,NOLOAD,NOTEMP
      COMMON /GP3COM/ GEOM3 ,EQEXIN,GEOM2 ,SLT   ,GPTT  ,SCR1  ,SCR2  ,
     1                BUF1  ,BUF2  ,BUF(50)      ,CARDID(60)   ,IDNO(30)
     2               ,CARDDT(60)   ,MASK(60)     ,STATUS(60)   ,NTYPES,
     3                IPLOAD,IGRAV ,PLOAD2(2)    ,LOAD(2)      ,NOPLD2,
     4                TEMP(2)      ,TEMPD(2)     ,TEMPP1(2)    ,
     5                TEMPP2(2)    ,TEMPP3(2)    ,TEMPRB(2)    ,BUF3  ,
     6                PLOAD3(2)    ,IPLD3
      COMMON /NAMES / RD    ,RDREW ,WRT   ,WRTREW,CLSREW
CZZ   COMMON /ZZGP3X/ Z(1)
      COMMON /ZZZZZZ/ Z(1)
      EQUIVALENCE     (KSYSTM(1),ISB)
      DATA    NAM   / 4HGP3A,4H    / ,IRFRC / 9  /
C
C     READ EQEXIN INTO CORE. INITIALIZE BINARY SEARCH ROUTINE.
C
      FILE = EQEXIN
      CALL OPEN   (*570,EQEXIN,Z(BUF1),RDREW)
      CALL FWDREC (*580,EQEXIN)
      CALL READ   (*580,*20,EQEXIN,Z,BUF2,1,NEQX)
      CALL MESAGE (-8,0,NAM)
   20 CALL CLOSE  (EQEXIN,CLSREW)
      KN   = NEQX/2
      NOGO = 0
C
C     INITIALIZE POINTERS AND OPEN SCR1 AND GEOM3.
C
      ISET  = BUF2 - 2
      KSET  = ISET
      ILIST = NEQX + 1
      KLIST = ILIST
      KTABL = 1
      FIRST = 1
      FILE  = SCR1
      CALL OPEN (*570,SCR1,Z(BUF2),WRTREW)
C
C     IF PLOAD2 CARDS PRESENT, INITIALIZE TO READ PLOAD DATA FROM SCR2
C     INSTEAD OF GEOM3.
C
      IF (NOPLD2 .EQ. 0) GO TO 40
      FILE = SCR2
      CALL OPEN (*570,SCR2,Z(BUF1),RDREW)
      GO TO 60
   40 FIRST = 0
   50 FILE  = GEOM3
      CALL OPEN   (*570,GEOM3,Z(BUF1),RDREW)
      CALL FWDREC (*580,GEOM3)
C
C     READ 3-WORD RECORD ID. IF ID BELONGS TO LOAD SET, TURN NOLOAD FLAG
C     OFF.
C     SET 1ST WORD IN STATUS ENTRY TO CURRENT POINTER IN LIST TABLE.
C     SET PARAMETERS FOR CONVERSION OF GRID NOS. TO INTERNAL INDICES.
C
   60 CALL READ (*170,*60,FILE,BUF,3,0,FLAG)
      DO 70 I = 1,NTYPES,2
      IF (BUF(1).EQ.CARDID(I) .AND. BUF(2).EQ.CARDID(I+1)) GO TO 90
   70 CONTINUE
   80 CALL FWDREC (*170,FILE)
      GO TO 60
   90 NOLOAD = 1
      IF (FIRST .EQ. 1) GO TO 100
C
C     IF I POINTS TO PLOAD RECORD AND PLOAD2 CARDS ARE PRESENT, THEN
C     PLOAD DATA IS ALREADY PROCESSED. IN THIS CASE, SKIP PLOAD RECORD.
C     IF I POINTS TO PLOAD3 RECORD ON GEOM3, SKIP RECORD.
C
      IF (I.EQ.IPLOAD .AND. NOPLD2.NE.0 .AND. NOPLD2.NE.2) GO TO 80
      IF (I .EQ. IPLD3) GO TO 80
  100 CONTINUE
      STATUS(I) = KLIST - ILIST + 1
      NWDS  = CARDDT(I)
      NWDS1 = NWDS - 1
      JX  = CARDDT(I+1)
      JJ1 = JX + 1
      JJN = JX + MASK(JX)
      ID  = 0
C
C     READ A LOAD CARD. IF SET ID IS DIFFERENT FROM LAST READ (OR 1ST
C     ONE) STORE SET ID IN POINTER LIST AND IN SET LIST. STORE POINTER
C     IN POINTER LIST. IF NOT FIRST CARD OF TYPE, STORE WORD COUNT IN
C     POINTER LIST.
C
  110 CALL READ (*580,*160,FILE,BUF,NWDS,0,FLAG)
      IF (BUF(1) .EQ. ID) GO TO 120
      Z(KLIST  ) = BUF(1)
      Z(KLIST+1) = KTABL
      IF (ID .NE. 0) Z(KLIST-1) = N
      ID = BUF(1)
      N  = 0
      KLIST   = KLIST + 3
      Z(KSET) = BUF(1)
      KSET    = KSET - 1
C
C     CONVERT EXTERNAL GRID NOS. ON CARD TO INTERNAL NOS. INCREMENT
C     WORD COUNT. WRITE LOAD CARD (WITHOUT SET ID) ON SCR1.
C
  120 IF (JX .EQ. 0) GO TO 150
      JJ = JJ1
      JSTOP = 0
  130 IF (JSTOP .EQ. 0) GO TO 135
      JX = JX + 1
      GO TO 136
  135 JX = MASK(JJ)
      IF (JX .GT. 0) GO TO 136
      JX = -JX
      JSTOP = 1
  136 GPOINT = BUF(JX)
      PIEZ = .FALSE.
      IF (GPOINT.LT.0 .AND.  KSYSTM(78).EQ.1) PIEZ = .TRUE.
      IF (PIEZ) GPOINT = -GPOINT
      IF (GPOINT.EQ.-1 .AND. (CARDID(I).EQ.3209 .OR. CARDID(I).EQ.3409))
     1    GO TO 140
      IF (GPOINT .NE. 0) GO TO 450
  140 IF (PIEZ) GPOINT = -GPOINT
      BUF(JX) = GPOINT
      JJ = JJ + 1
      IF (JJ .LE. JJN) GO TO 130
C
C     CHECK FOR PLOAD4 CARD
C
  150 IF (I .NE. 49) GO TO 152
C
C     CHECK FOR THRU OPTION ON PLOAD4 CARD
C
      IF (BUF(7) .EQ. 0) GO TO 153
C
  152 CALL WRITE (SCR1,BUF(2),NWDS1,0)
      GO TO 158
C
C     PROCESS PLOAD4 DATA FOR ALL ELEMENT IDS IMPLIED BY THE THRU OPTION
C
  153 III = BUF(2)
      JJJ = BUF(8)
      BUF(7) =-1
      BUF(8) = 0
      DO 155 KKK = III,JJJ
      BUF(2) = KKK
      CALL WRITE (SCR1,BUF(2),NWDS1,0)
      N = N + NWDS1
      KTABL = KTABL + NWDS1
  155 CONTINUE
      GO TO 110
C
  158 N = N + NWDS1
      KTABL = KTABL + NWDS1
      GO TO 110
C
C     HERE WHEN ALL CARDS OF CURRENT CARD TYPE HAVE BEEN READ.
C     STORE WORD COUNT FOR LAST SET IN POINTER LIST. STORE POINTER
C     TO LAST ENTRY FOR CARD TYPE IN 2ND WORD OF STATUS ENTRY.
C     LOOP BACK TO READ NEXT CARD TYPE.
C
  160 Z(KLIST-1) = N
      STATUS(I+1) = KLIST - ILIST - 2
      GO TO 60
  170 IF (FIRST .EQ. 0) GO TO 175
      FIRST = 0
      CALL CLOSE (SCR2,CLSREW)
      GO TO 50
C
C     HERE WHEN END-OF-FILE ON GEOM3 ENCOUNTERED. IF ERROR CONDITION
C     NOTED, CALL PEXIT. IF NO LOAD CARDS FOUND, CLOSE FILES AND RETURN.
C
  175 IF (NOGO .NE. 0) CALL MESAGE (-61,0,0)
      IF (NOLOAD .NE. -1) GO TO 180
      CALL CLOSE (GEOM3,CLSREW)
      CALL CLOSE (SCR1,CLSREW)
      RETURN
C
C     IF GRAVITY LOADS WERE READ, TURN NOGRAV FLAG OFF.
C     CLOSE FILES AND MOVE POINTER LIST TO BEGINNING OF CORE.
C
  180 IF (STATUS(IGRAV).GT.0 .OR. STATUS(IRFRC).GT.0) NOGRAV = +1
      CALL WRITE (SCR1,0,0,1)
      CALL CLOSE (GEOM3,CLSREW)
      CALL CLOSE (SCR1, CLSREW)
      N = KLIST - ILIST
      DO 190 I = 1,N
      K = ILIST + I
  190 Z(I)  = Z(K-1)
      ILIST = 1
      NLIST = N - 2
C
C     CHECK UNIQUENESS OF LOAD SETS WITTH RESPECT TO GRAVITY LOAD SETS
C
      IF (STATUS(IGRAV) .LT. 0) GO TO 200
      K1 = STATUS(IGRAV  )
      K2 = STATUS(IGRAV+1)
      DO 194 I = ILIST,NLIST,3
      IF (I.GE.K1 .AND. I.LE.K2) GO TO 194
      SETID = Z(I)
      DO 193 K = K1,K2,3
      IF (Z(K) .NE. SETID) GO TO 193
      NOGO = 1
      CALL MESAGE (30,134,SETID)
  193 CONTINUE
  194 CONTINUE
C
C     SORT THE SET LIST AND DISCARD DUPLICATE SET NOS.
C
  200 N = ISET - KSET
      KSET = KSET + 1
      CALL SORT (0,0,1,1,Z(KSET),N)
      Z(ISET+1) = 0
      K = NLIST + 3
      DO 210 I = KSET,ISET
      IF (Z(I) .EQ. Z(I+1)) GO TO 210
      Z(K) = Z(I)
      K = K + 1
  210 CONTINUE
      ISET  = NLIST + 3
      NSET  = K - 1
      ITABL = NSET
C
C     OPEN SCRATCH FILE AND SLT FILE.
C     WRITE SET LIST IN HEADER RECORD OF THE SLT.
C
      CALL OPEN (*570,SCR1,Z(BUF1),RDREW)
      FILE = SLT
      CALL OPEN (*570,SLT,Z(BUF2),WRTREW)
      CALL FNAME (SLT,BUF)
      CALL WRITE (SLT,BUF,2,0)
      N = NSET - ISET + 1
      CALL WRITE (SLT,Z(ISET),N,1)
C
C     IF ALL LOAD CARDS WILL FIT IN CORE, READ THEM IN.
C
      NWDS  = KTABL - 1
      NCORE = ITABL + KTABL
      IF (NCORE .GE. BUF2) GO TO 370
      FILE  = SCR1
      CALL READ (*580,*590,SCR1,Z(ITABL+1),NWDS,1,FLAG)
      CALL CLOSE (SCR1,CLSREW)
C
C     FOR EACH LOAD SET IN THE SET LIST, LOOP THRU THE STATUS TABLE.
C     FOR EACH CARD TYPE PRESENT IN THE STATUS TABLE, PICK UP POINTERS
C     TO THE POINTER LIST. SEARCH THE POINTER LIST FOR A SET ID MATCH.
C     IF FOUND, PICK UP POINTERS TO THE DATA IN CORE. SORT THE DATA ON
C     INTERNAL INDEX (EXCEPT GRAV AND PLOAD CARDS).
C     THEN, WRITE CARD TYPE ID, NO. OF CARDS IN THE SET, AND THE DATA
C     ON THE CARDS. THUS, THE SLT IS COMPRISED OF ONE LOGICAL RECORD PER
C     SET DATA WITHIN EACH RECORD IS GROUPED BY CARD TYPE, AND, WITHIN
C     THE GROUP, IS SORTED BY INTERNAL INDEX (WHERE DEFINED).
C
      DO 280 K = ISET,NSET
      SETID = Z(K)
      II = 1
      DO 270 I = 1,NTYPES,2
      IF (STATUS(I) .LT. 0) GO TO 270
      JJ1 = STATUS(I  )
      JJN = STATUS(I+1)
      DO 250 JJ = JJ1,JJN,3
      IF (Z(JJ) .EQ. SETID) GO TO 260
  250 CONTINUE
      GO TO 270
C
  260 CONTINUE
      JX   = ITABL + Z(JJ+1)
      NWDS = Z(JJ+2)
      N    = CARDDT(I) - 1
      NKEY = 1
      IF (IDNO(II) .EQ. 20) NKEY = 5
      IF (IDNO(II) .EQ. 21) GO TO 265
      IF (IDNO(II).GE.22 .AND. IDNO(II).LE.24) GO TO 265
      IF (I.EQ.IPLOAD .OR. I.EQ.IPLD3 .OR. I.EQ.IGRAV) GO TO 265
      CALL SORT (0,0,N,NKEY,Z(JX),NWDS)
  265 BUF(1) = IDNO(II)
      BUF(2) = NWDS/N
      CALL WRITE (SLT,BUF,2,0)
      CALL WRITE (SLT,Z(JX),NWDS,0)
  270 II = II + 1
  280 CALL WRITE (SLT,0,0,1)
C
C     IF COMBINATION LOADS ARE PRESENT, SET IDS ARE CHECKED TO ASSURE
C     THAT THEY ARE UNIQUE WITH RESPECT TO LOAD CARDS.  THE SET IDS
C     SPECIFIED ON THE LOAD CARD ARE THEN CHECKED AGAINST THOSE IN THE
C     SET LIST TO VERIFY THAT ALL ARE AVAILABLE AND AGAINST EACH OTHER
C     TO ENSURE THAT NO DUPLICATE SPECIFICATIONS EXIST.  THE COMBINATION
C     LOADS ARE WRITTEN AS THE LAST LOGICAL RECORD OF THE SLT.
C
  290 FILE = GEOM3
      CALL PRELOC (*570,Z(BUF1),GEOM3)
      CALL LOCATE (*360,Z(BUF1),LOAD,FLAG)
  300 CALL READ   (*580,*350,GEOM3,BUF,2,0,FLAG)
      CALL WRITE  (SLT,BUF,2,0)
      DO 320 I = ISET,NSET
      IF (BUF(1) .EQ. Z(I)) GO TO 330
  320 CONTINUE
      GO TO 340
  330 NOGO = 1
      CALL MESAGE (30,106,BUF)
  340 LSET = NSET + 1
      MSET = NSET
      IDCMLD = BUF(1)
  341 CALL READ (*580,*350,GEOM3,BUF,2,0,FLAG)
      CALL WRITE (SLT,BUF,2,0)
      IF (BUF(1) .EQ. -1) GO TO 300
      DO 342 I = ISET,NSET
      IF (BUF(2) .EQ. Z(I)) GO TO 343
  342 CONTINUE
      NOGO = 1
      WRITE  (IPTR,3178) UFM,BUF(2),IDCMLD
 3178 FORMAT (A23,' 3178, LOAD SET',I9,' NOT FOUND.  REQUIRED FOR ',
     1        'DEFINITION OF COMBINATION LOAD',I9)
      LINES = LINES + 2
      IF (LINES .GE. NLPP) CALL PAGE
      GO TO 341
  343 IF (MSET .EQ. NSET) GO TO 345
      DO 344 I = LSET,MSET
      IF (BUF(2) .EQ. Z(I)) GO TO 346
  344 CONTINUE
  345 MSET = MSET + 1
      Z(MSET) = BUF(2)
      GO TO 341
  346 NOGO = 1
      WRITE  (IPTR,3179) UFM,BUF(2),IDCMLD
 3179 FORMAT (A23,' 3179, DUPLICATE LOAD SET',I9,' FOUND IN DEFINITION',
     1       ' OF COMBINATION LOAD',I9)
      LINES = LINES + 2
      IF (LINES .GE. NLPP) CALL PAGE
      GO TO 341
  350 CALL WRITE (SLT,0,0,1)
  360 CALL CLOSE (GEOM3,CLSREW)
      CALL CLOSE (SLT,CLSREW)
      BUF(1) = SLT
      BUF(2) = NSET - ISET + 1
      DO 361 I = 3,7
  361 BUF(I) = 0
      CALL WRTTRL (BUF)
      IF (NOGO .NE. 0) CALL MESAGE (-61,0,0)
      RETURN
C
C     HERE IF CORE WILL NOT HOLD ALL LOAD CARDS.
C     CODE IS SIMILAR TO THAT ABOVE EXCEPT THAT POINTER LIST NOW POINTS
C     TO THE DATA ON THE SCRATCH FILE INSTEAD OF IN CORE. THEREFORE, THE
C     SCRATCH FILE WILL HAVE TO BE PASSED ONCE FOR EACH SET IN THE SET
C     LIST.
C
  370 FILE  = SCR1
      DO 430 K = ISET,NSET
      SETID = Z(K)
      II    = 1
      NREAD = 0
      DO 420 I = 1,NTYPES,2
      IF (STATUS(I) .LT. 0) GO TO 420
      JJ1 = STATUS(I  )
      JJN = STATUS(I+1)
      DO 380 JJ = JJ1,JJN,3
      IF (Z(JJ) .EQ. SETID) GO TO 390
  380 CONTINUE
      GO TO 420
  390 NSKIP = Z(JJ+1) - NREAD - 1
      NWDS  = Z(JJ+2)
      N = CARDDT(I) - 1
      IF (NSKIP) 440,410,400
  400 CALL READ (*580,*590,SCR1,0,-NSKIP,0,FLAG)
  410 CALL READ (*580,*590,SCR1,Z(ITABL+1),NWDS,0,FLAG)
      NREAD = Z(JJ+1) + NWDS - 1
      NKEY  = 1
      IF (IDNO(II) .EQ. 20) NKEY = 5
      IF (IDNO(II) .EQ. 21) GO TO 415
      IF (IDNO(II).GE.22 .AND. IDNO(II).LE.24) GO TO 415
      IF (I.EQ.IPLOAD .OR. I.EQ.IPLD3 .OR. I.EQ.IGRAV) GO TO 415
      CALL SORT (0,0,N,NKEY,Z(ITABL+1),NWDS)
  415 BUF(1) = IDNO(II)
      BUF(2) = NWDS/N
      CALL WRITE (SLT,BUF,2,0)
      CALL WRITE (SLT,Z(ITABL+1),NWDS,0)
  420 II = II + 1
      CALL WRITE (SLT,0,0,1)
  430 CALL REWIND (SCR1)
      CALL CLOSE (SCR1,CLSREW)
      GO TO 290
  440 CALL MESAGE (-61,0,0)
C
C     BINARY SEARCH ROUTINE
C
  450 KLO = 1
      KHI = KN
  460 K = (KLO+KHI+1)/2
  470 IF (GPOINT-Z(2*K-1)) 480,540,490
  480 KHI = K
      GO TO 500
  490 KLO = K
  500 IF (KHI-KLO-1) 550,510,460
  510 IF (K .EQ. KLO) GO TO 520
      K = KLO
      GO TO 530
  520 K = KHI
  530 KLO = KHI
      GO TO 470
  540 GPOINT = Z(2*K)
      GO TO 140
  550 BUF(2) = GPOINT
      NOGO   = 1
      CALL MESAGE (30,8,BUF)
      GO TO 140
C
C     FATAL FILE ERRORS
C
  560 CALL MESAGE (N,FILE,NAM)
  570 N = -1
      GO TO 560
  580 N = -2
      GO TO 560
  590 N = -3
      GO TO 560
      END