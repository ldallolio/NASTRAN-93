      SUBROUTINE TA1CPS
C
C     G3 MATRIX CALCULATION WITH NEW FORMULATION
C
C     THIS ROUTINE IS CALLED IN TA1 IF PARAM COMPS IS SET TO -1
C     INDICATING PCOMP, PCOMP1 OR PCOMP2 BULK DATA ENTRIES ARE
C     PRESENT. IT'S PRIMARY FUNCTION IS TO -
C       1. CREATE FILE PCOMPS WHICH WILL CONTAIN THE ECHO OF THE
C          'PCOMPS' ENTRIES ALONG WITH INDIVIDUAL LAYER INTRINISIC
C          PROPERTY MATRICES.
C       2. CALCULATE OVERALL MATERIAL PROPERTIES IN THE FORM OF MAT2
C          ENTRIES AND WRITE TO FILE MPTX.
C       3. GENERATE EQUIVALENT PSHELL PROPERTY ENTRIES AND WRITE TO
C          FILE EPTX.
C
      EXTERNAL        ANDF,ORF
      LOGICAL         OK UAI
      INTEGER         PCOMP(2),PCOMP1(2),PCOMP2(2),COMPS,PCBIT(3),EPTX,
     1                PSHLPR,EPTWDS,PSHBIT,RD,RDREW,WRT,WRTREW,CLSREW,
     2                CLS,IPSHEL(17),PSHNAM(3),PCOMPR,TYPC,TYPC1,TYPC2,
     3                FLAG,EPT,PCOMPS,EOF,ELID,PIDLOC,EOELOC,SYM,SYMMEM,
     4                EOE,SYSBUF,POS,POS1,Z,BUF0,BUF1,BUF2,BUF3,BUF4,
     5                BUF5,FILE,INDEX(6,3),INDEXX(3,3),ANDF,ORF,BLANK
      REAL            GLAY(25),GMEMBR(17),GBENDG(17),GMEMBD(17),
     1                GTRSHR(17),EXX,EYY,EIXX,EIYY,ZX,ZY,RPSHEL(17),
     2                ALFA1,ALFA2,ALFA12,TREF,GSUBE
      REAL            THETA,THETAR,C,C2,C4,S,S2,S4,PI,TWOPI,RADDEG,
     1                DEGRAD,T(9),GT(9),GBR(9),GBAR(3,3),G(25),GD(9),
     2                GDT(9),GDBR(9),GDBAR(3,3),GD2(3,3),U(9),G3I(9),
     3                G3IU(9),G3BR(9),G3BAR(3,3),G1(3,3),G2(3,3),
     4                G3(2,2),G4(3,3),TLAM,ZK,ZK1,ZREF,ZG1,ZG2,ZG4,ZI,
     5                TI,RHO,DETRMN,CONST,ZBARX,ZBARY,TRFLX(2,2),ZBARXT,
     6                ZBARXB,ZBARYT,ZBARYB,ZBAR(2),GTRFLX(2,2),GD4(3,3),
     7                G3INVD(2,2),EX,EY,E(2),FI(2),FII(2),RI(2),DETERM,
     8                DUM(6),DUMMY(3),STIFF(6,6),EI(2),GD1(3,3),EPSI
      DIMENSION       RZ(1),NPCMP(3),NPCMP1(3),NPCMP2(3),NAM(2),NAM1(2),
     1                NAM2(2),MATNAM(3),IPCOMP(7),IMEMBR(17),IBENDG(17),
     2                IMEMBD(17),ITRSHR(17),IMPTX(7),IEPTX(7)
      COMMON /BLANK / LUSET ,NOSIMP,NOSUP ,NOGENL,GENL  ,COMPS
      COMMON /TA1COM/ NSIL  ,ECT   ,EPT   ,BGPDT ,SIL   ,GPTT  ,CSTM  ,
     1                MPT   ,EST   ,GEI   ,GPECT ,ECPT  ,GPCT  ,MPTX  ,
     2                PCOMPS,EPTX  ,SCR1  ,SCR2  ,SCR3  ,SCR4
      COMMON /NAMES / RD    ,RDREW ,WRT   ,WRTREW,CLSREW,CLS
      COMMON /SYSTEM/ SYSBUF,NOUT  ,NOGO  ,DM(20),ICFIAT
      COMMON /MATIN / MATID ,INFLAG,ELTEMP
      COMMON /MATOUT/ RMTOUT(25)
CZZ   COMMON /ZZTAA1/ Z(1)
      COMMON /ZZZZZZ/ Z(1)
      COMMON /CONDAS/ PI    ,TWOPI ,RADDEG,DEGRAD
      COMMON /TWO   / TWO(32)
      EQUIVALENCE     (Z(1)     ,RZ(1)    ), (IPSHEL(1),RPSHEL(1)),
     1                (IMEMBR(1),GMEMBR(1)), (IBENDG(1),GBENDG(1)),
     2                (IMEMBD(1),GMEMBD(1)), (ITRSHR(1),GTRSHR(1))
C     DATA    MPT   / 107/
C     DATA    MPTX  / 206/
C     DATA    PCOMPS/ 207/
C     DATA    EPTX  / 208/
      DATA    PCOMP / 5502,55/
      DATA    PCOMP1/ 5602,56/
      DATA    PCOMP2/ 5702,57/
      DATA    NPCMP / 5502,55,280/
      DATA    NPCMP1/ 5602,56,281/
      DATA    NPCMP2/ 5702,57,282/
      DATA    PSHNAM/ 5802,58,283/
      DATA    MATNAM/ 203, 2, 78 /
      DATA    PCBIT / 55, 56, 57 /
      DATA    PSHBIT/ 58 /
      DATA    MT2BIT/ 2  /
      DATA    I1ST  / 1  /
      DATA    SYM   / 1  /
      DATA    MEM   / 2  /
      DATA    SYMMEM/ 3  /
      DATA    EOE   / -1 /
      DATA    NAM   / 4HTA1C, 4HPS   /
      DATA    NAM2  / 4HPCOM, 4HPS   /
      DATA    BLANK / 4HBLNK         /
      DATA    OK UAI/ .TRUE.         /
      DATA    EPSI  / 1.0E-15        /
C
      BUF0 = KORSZ(Z) - SYSBUF - 2
      BUF1 = BUF0 - SYSBUF - 2
      BUF2 = BUF1 - SYSBUF - 2
      BUF3 = BUF2 - SYSBUF - 2
      BUF4 = BUF3 - SYSBUF - 2
      BUF5 = BUF4 - SYSBUF - 2
C
C     PERFORM GENERAL INITILIZATION
C
      MATWDS = 0
      EOF    = 0
      ELID   = 0
      MAT2PR = 0
      PSHLPR = 0
      ICOUNT = 0
      RHO    = 0.0
C
C     OPEN EPTX AND WRITE HEADER RECORD
C
      FILE = EPTX
      CALL OPEN (*1200,EPTX,Z(BUF0),WRTREW)
      CALL FNAME (EPTX,NAM1)
      CALL WRITE (EPTX,NAM1,2,1)
C
C     OPEN MPTX AND WRITE HEADER RECORD
C
      FILE = MPTX
      CALL OPEN (*1200,MPTX,Z(BUF1),WRTREW)
      CALL FNAME (MPTX,NAM1)
      CALL WRITE (MPTX,NAM1,2,1)
C
C     OPEN MPT AND POSITION FILE
C
      FILE = MPT
      CALL OPEN (*1200,MPT,Z(BUF2),RDREW)
      CALL FWDREC (*1200,MPT)
C
C     OPEN PCOMPS AND WRITE HEADER RECORD
C     WRITE TO IPCOMP(1), THE GINO FILE NAME OF PCOMPS
C
      FILE = PCOMPS
      CALL OPEN (*1200,PCOMPS,Z(BUF3),WRTREW)
      CALL WRITE (PCOMPS,NAM2,2,1)
C
      IPCOMP(1) = PCOMPS
      DO 10 LL = 2,7
   10 IPCOMP(LL) = 0
C
C     COPY ALL EPT ENTRIES UP TO PSHELL TYPE TO FILE EPTX
C     IF NONE FOUND, MUST CREATE ONE BEFORE THE LAST RECORD IN FILE
C
C     SET AVAILABLE CORE
C
      N    = BUF5 - 1
      IEPT = I1ST
      FILE = EPT
      CALL OPEN (*1200,EPT,Z(BUF4),RDREW)
      CALL FWDREC (*1200,EPT)
      IREC = 0
   20 CALL FWDREC (*30,EPT)
      IREC = IREC + 1
      GO TO 20
C
   30 CALL REWIND (EPT)
      CALL FWDREC (*1200,EPT)
      IRED = 0
   40 CALL READ (*1200,*50,EPT,Z(IEPT),N,1,EPTWDS)
      CALL MESAGE (-8,0,NAM)
   50 IF (Z(IEPT) .EQ. 4902) GO TO 60
      IRED = IRED + 1
      IF (IRED .EQ. IREC) GO TO 70
      CALL WRITE (EPTX,Z(IEPT),EPTWDS,1)
      EPTWDS = 0
      GO TO 40
C
   60 PSHLPR = 1
   70 CALL BCKREC (EPT)
      CALL SAVPOS (EPT,POS1)
      CALL CLOSE (EPT,CLSREW)
C
C     OPEN EPT
C
      FILE = EPT
      CALL PRELOC (*1200,Z(BUF4),EPT)
C
C     COPY ALL MAT ENTRIES UP TO MAT2 TYPE TO FILE MPTX
C
C     SET AVAILABLE CORE
C
      N = BUF5 - 1
      IMAT = I1ST
   80 CALL READ (*110,*90,MPT,Z(IMAT),N,1,MATWDS)
      CALL MESAGE (-8,0,NAM)
   90 IF (Z(IMAT) .GE. 203) GO TO 100
      CALL WRITE (MPTX,Z(IMAT),MATWDS,1)
      MATWDS = 0
      GO TO 80
  100 CALL BCKREC (MPT)
      CALL SAVPOS (MPT,POS)
      IF (Z(IMAT) .EQ. 203) MAT2PR = 1
      GO TO 120
C
C    SET END OF FILE FLAG
C
  110 EOF = 1
C
C     CLOSE MPT BEFORE CALLING PREMAT
C
  120 CALL CLOSE (MPT,1)
C
C     SET POINTERS AND PERFORM INITILIZATION
C
      IPC1  = 1
      NPC   = 0
      NPC1  = 0
      NPC2  = 0
      TYPC  = 0
      TYPC1 = 0
      TYPC2 = 0
C
C     SET SIZE OF AVAILABLE CORE
C
      N   = BUF5 - 1
      IPC = 1
C
C     LOCATE PCOMP DATA AND READ INTO CORE
C
      CALL LOCATE (*140,Z(BUF4),PCOMP,FLAG)
C
      CALL READ (*1200,*130,EPT,Z(IPC),N,0,NPC)
      CALL MESAGE (-8,0,NAM)
  130 IF (NPC .GT. 0) TYPC = 1
      IPC1 = IPC + NPC
      IF (IPC1 .GE. BUF5) CALL MESAGE (-8,0,NAM)
      N = N - NPC
C
C     LOCATE PCOMP1 DATA AND READ INTO CORE
C
  140 CALL LOCATE (*160,Z(BUF4),PCOMP1,FLAG)
C
      IPC1 = IPC + NPC
      CALL READ (*180,*150,EPT,Z(IPC1),N,0,NPC1)
      CALL MESAGE (-8,0,NAM)
  150 IF (NPC1 .GT. 0) TYPC1 = 1
      IPC2 = IPC1 + NPC1
      IF (IPC2 .GE. BUF5) CALL MESAGE (-8,0,NAM)
      N = N - NPC1
C
C     LOCATE PCOMP2 DATA AND READ INTO CORE
C
  160 CALL LOCATE(*180,Z(BUF4),PCOMP2,FLAG)
C
      IPC2 = IPC1 + NPC1
      CALL READ (*180,*170,EPT,Z(IPC2),N,0,NPC2)
      CALL MESAGE (-8,0,NAM)
  170 IF (NPC2 .GT. 0) TYPC2 = 1
C
C     SET SIZE OF LPCOMP. NUMBER OF WORDS READ INTO CORE
C
  180 LPCOMP = IPC + NPC + NPC1 + NPC2
      IF (LPCOMP .GE. BUF5) CALL MESAGE (-8,0,NAM)
C
C     CLOSE EPT BEFORE PROCESSING PCOMPI
C
      CALL CLOSE (EPT,1)
C
C     READ MATERIAL PROPERTY TABLE INTO CORE
C
      IMAT  = LPCOMP + 1
      N1MAT = BUF5 - IMAT
      CALL PREMAT (Z(IMAT),Z(IMAT),Z(BUF5),N1MAT,N2MAT,MPT,DIT)
      IF (IMAT+N2MAT .GE. BUF5) CALL MESAGE (-8,0,NAM)
      ICORE = IMAT + N2MAT + 1
C
C     SET POINTERS
C
      ITYPE  =-1
      ISTART = 0
      IFINIS = 0
C
C     PROCESS ALL 'PCOMP' ENTRY TYPES SEQUENTIALLY
C
C     PCOMP ENTRIES
C
      IF (TYPC .EQ. 0) GO TO 190
      ITYPE  = 0
      ISTART = IPC
      IFINIS = IPC1 - 1
      NWDPC  = 8
      KPC    = 4
      PCOMPR = 1
      GO TO 220
C
C     PCOMP1 ENTRIES
C
  190 IF (TYPC1 .EQ. 0) GO TO 200
      ITYPE  = 1
      ISTART = IPC1
      IFINIS = IPC2 - 1
      NWDPC  = 8
      KPC    = 1
      PCOMPR = 1
      GO TO 220
C
C     PCOMP2 ENTRIES
C
  200 IF (TYPC2 .EQ. 0) GO TO 210
      ITYPE  = 2
      ISTART = IPC2
      IFINIS = LPCOMP - 1
      NWDPC  = 8
      KPC    = 2
C
C     CHECK IF NO PCOMP DATA HAS BEEN READ INTO CORE
C
  210 IF (TYPC.EQ.0 .AND. TYPC1.EQ.0 .AND. TYPC2.EQ.0) GO TO 1210
C
C     SET INFLAG = 12, SO THAT FOR LAMINA REFERENCING MAT1 OR MAT2
C     PROPERTY ENTRY WILL BE RETURNED IN MAT2 FORMAT. EXECPT FOR
C     THOSE REFERENCING MAT8 PROPERTY, IN WHICH CASE THE ENTRY
C     IS MERELY ECHOED.
C
  220 INFLAG = 12
C
C     SET POINTERS
C
C     WRITE 3-WORD IDENTITY FOR PCOMP DATA
C
C     PCOMP TYPE
C
      IF (ITYPE .NE. 0) GO TO 230
      CALL WRITE (PCOMPS,NPCMP,3,0)
      GO TO 250
C
C     PCOMP1 TYPE
C
  230 IF (ITYPE .NE. 1) GO TO 240
      CALL WRITE (PCOMPS,NPCMP1,3,0)
      GO TO 250
C
C     PCOMP2 TYPE
C
  240 CALL WRITE (PCOMPS,NPCMP2,3,0)
C
C     PROCESS ALL 'PCOMP' ENTRIES
C
  250 LEN    = 0
      NLAY   = 0
      EOELOC = 0
      PIDLOC = 1
      TLAM   = 0.0
      RHO    = 0.0
      ZK     = 0.0
      ZK1    = 0.0
      TREF   = 0.0
      GSUBE  = 0.0
      ALFA1  = 0.0
      ALFA2  = 0.0
      ALFA12 = 0.0
C
      DO 260 II = ISTART,IFINIS
      IF (Z(II) .EQ. -1) GO TO 270
  260 CONTINUE
C
  270 EOELOC = II
      PIDLOC = ISTART
      LEN    = EOELOC - PIDLOC
      NLAY   = (LEN - NWDPC)/KPC
      LAMOPT = Z(PIDLOC+7)
C
C     DETERMINE LAMINATE THICKNESS
C
C     PCOMP DATA
C
      IF (ITYPE .GT. 0) GO TO 290
      DO 280 K = 1,NLAY
      IIK  = (PIDLOC+5) + 4*K
      TLAM = TLAM + RZ(IIK)
  280 CONTINUE
      IF (LAMOPT.EQ.SYM .OR. LAMOPT.EQ.SYMMEM) TLAM = 2.0*TLAM
      GO TO  320
C
C     PCOMP1 DATA
C
  290 IF (ITYPE .GT. 1) GO TO 300
      IIK  = PIDLOC + 6
      TLAM = RZ(IIK)*NLAY
      IF (LAMOPT.EQ.SYM .OR. LAMOPT.EQ.SYMMEM) TLAM = 2.0*TLAM
      GO TO 320
C
C     PCOMP2 DATA
C
  300 DO 310 K = 1,NLAY
      IIK  = (PIDLOC+6) + 2*K
      TLAM = TLAM + RZ(IIK)
  310 CONTINUE
      IF (LAMOPT.EQ.SYM .OR. LAMOPT.EQ.SYMMEM) TLAM = 2.0*TLAM
C
C     WRITE TO PCOMPS
C      1. PID
C      2. NLAY - NUMBER OF LAYERS
C      3. REMAINDER OF PCOMP ENTRY
C
  320 CALL WRITE (PCOMPS,Z(PIDLOC),1,0)
      CALL WRITE (PCOMPS,NLAY,1,0)
C
C     SET LEN TO THE NO. WORDS TO BE WRITTEN TO PCOMPS
C
      LEN = LEN - 1
      CALL WRITE (PCOMPS,Z(PIDLOC+1),LEN,0)
C
C     CALL MAT TO GET LAYER PROPERTIES AND WRITE TO PCOMPS
C     NOTE FOR PCOMP1 AND PCOMP2 ENTRIES THE PROPERTY MATRIX
C     IS ONLY WRITTEN TO PCOMPS ONCE. (ALL LAYER PER ENTRY HAVE
C     THE SAME MID.
C     SIMILARILY FOR PCOMP ENTRY, IF ALL LAYERS REFERENCE THE SAME
C     MID, THEN THE PROPERTY MATRIX IS ONLY WRITTEN ONCE TO PCOMPS.
C
C          ITYPE = 0 PCOMP  ENTRY
C          ITYPE = 1 PCOMP1 ENTRY
C          ITYPE = 2 PCOMP2 ENTRY
C
      MID = 0
C
C     INITIALIZE G1, G2, G3 AND G4 MATRICES
C
      DO 330 LL = 1,3
      DO 330 MM = 1,3
      G1 (LL,MM) = 0.0
      GD1(LL,MM) = 0.0
      G2 (LL,MM) = 0.0
      GD2(LL,MM) = 0.0
      G4 (LL,MM) = 0.0
      GD4(LL,MM) = 0.0
  330 CONTINUE
C
      DO 340 LL = 1,2
      FII(LL)  = 0.0
      FI(LL)   = 0.0
      RI(LL)   = 0.0
      ZBAR(LL) = 0.0
      DO 340 MM = 1,2
      G3(LL,MM) = 0.0
      GTRFLX(LL,MM) = 0.0
      TRFLX(LL,MM)  = 0.0
      G3INVD(LL,MM) = 0.0
  340 CONTINUE
C
C     INTILIZISE ZBAR
C
      ZBARX   = 0.0
      ZBARY   = 0.0
      ZBARXT  = 0.0
      ZBARXB  = 0.0
      ZBARYT  = 0.0
      ZBARYB  = 0.0
      ZX      = 0.0
      ZY      = 0.0
C
      EIXX    = 0.0
      EIYY    = 0.0
C
C     LOOP OVER LAYERS
C
      DO 500 K = 1,NLAY
      IF (ITYPE .EQ. 0) MATID = Z(PIDLOC+4+4*K)
      IF (ITYPE.EQ.1 .OR. ITYPE.EQ.2) MATID = Z(PIDLOC+5)
      IF (K.GE.2 .AND. (ITYPE.EQ.0 .AND. MID.EQ.MATID)) GO TO 410
      IF (K.GE.2 .AND. (ITYPE.EQ.1 .OR.  ITYPE.EQ.2)  ) GO TO 420
C
      MID = MATID
      CALL MAT (ELID)
C
C     CALL LPROPS TO GET LAYER PROPERTY MATRICES
C
      CALL LPROPS (G)
C
C     COPY G(25) TO GLAY(25), FOR WRITING TO PCOMPS
C
      DO 400 KK = 1,25
  400 GLAY(KK) = G(KK)
C
C     NEX 20 LINES ARE NEW FROM 2/90 UAI CODE
C     COPY ALFA1, ALFA2 AND ALFA12 FROM GLAY(14 THRU 16)
C
      IF (.NOT.OK UAI) GO TO 410
      ALFA1  = GLAY(14)
      ALFA2  = GLAY(15)
      ALFA1  = GLAY(16)
C
C     IF PCOMP, COPY TREF AND GE FROM THE MAIN CARD TO MATERIAL
C     PROPERTY DATA. THIS IS DONE FOR THE FIRST LAYER
C
      IF (K     .EQ. 1) GO TO 410
      IF (ITYPE .GE. 1) GO TO 405
      TREF  = RZ(PIDLOC+5)
      GSUBE = RZ(PIDLOC+6)
      GLAY(24) = TREF
      GLAY(25) = GSUBE
      GO TO 410
  405 TREF  = GLAY(24)
      GSUBE = GLAY(25)
C
C     WRITE THE LAYER PROPERTY MATRIX G TO FILE PCOMPS
C
  410 CALL WRITE (PCOMPS,GLAY(1),25,0)
C
C     CALCULATE CONTRIBUTION OF EACH LAYER TO OVERALL PROPERTY
C     MATRICES G1, G2, G4
C
C     BUILD TRANSFORMATION MATRIX T
C
  420 IF (ITYPE .EQ. 0) THETA = RZ(PIDLOC+6+4*K)
      IF (ITYPE .EQ. 1) THETA = RZ(PIDLOC+7+  K)
      IF (ITYPE .EQ. 2) THETA = RZ(PIDLOC+7+2*K)
      C = ABS(THETA)
      IF (C .LT. 0.000002) C = 0.0
      IF (C.GT.89.99998 .AND. C.LT.90.00002) C =  90.0
      IF (C.GT.179.9998 .AND. C.LT.180.0002) C = 180.0
      IF (C.GT.269.9998 .AND. C.LT.270.0002) C = 270.0
      IF (C.GT.359.9998 .AND. C.LT.360.0002) C = 360.0
      IF (THETA .LT. 0.0) C = -C
      THETAR = C*DEGRAD
C
      C  = COS(THETAR)
      IF (ABS(C) .LT. EPSI) C = 0.0
      C2 = C*C
      C4 = C2*C2
      S  = SIN(THETAR)
      IF (ABS(S) .LT. EPSI) S = 0.0
      S2 = S*S
      S4 = S2*S2
C
      T(1) = C2
      T(2) = S2
      T(3) = C*S
      T(4) = S2
      T(5) = C2
      T(6) =-C*S
      T(7) =-2.0*C*S
      T(8) = 2.0*C*S
      T(9) = C2 - S2
C
C     CALCULATE GBAR = TT X G X T
C
C     MULTIPLY G X T AND WRITE TO GT
C
      CALL GMMATS (G(1),3,3,0, T(1),3,3,0, GT(1))
C
C     MULTIPLY TT X GT AND WRITE TO GBR
C
      CALL GMMATS (T(1),3,3,1, GT(1),3,3,0, GBR(1))
C
C     WRITE GBR IN TWO DIMENSIONED ARRAY GBAR
C
      DO 430 LL = 1,3
      DO 430 MM = 1,3
      NN = MM + 3*(LL-1)
      GBAR(LL,MM) = GBR(NN)
  430 CONTINUE
C
C     PROCESSING FOR G3 MATRIX
C
C     CALCULATE GDBAR = TT X GD X T
C
C     DETERMINE GD MATRIX, WHICH IS EQUAL TO G MATRIX WITH POISSONS
C     RATIO=0.0
C        GD(1) ---- YOUNGS MODULUS IN X-DIRN
C        GD(5) ---- YOUNGS MODULUS IN Y-DIRN
C        GD(9) ---- INPLANE SHEAR MODULUS
C
      DO 440 LL = 1,9
  440 GD(LL) = 0.0
      CONST = 1.0 - (G(2)*G(4))/(G(5)*G(1))
      GD(1) = G(1)*CONST
      GD(5) = G(5)*CONST
      GD(9) = G(9)
C
C     MULTIPLY GD X T AND WRITE TO GDT
C
      CALL GMMATS (GD(1),3,3,0, T(1),3,3,0, GDT(1))
C
C     MULTIPLY TT X GDT AND WRITE TO GDBR
      CALL GMMATS (T(1),3,3,1, GDT(1),3,3,0, GDBR(1))
C
C     WRITE GDBR IN TWO DIMENSIONED ARRAY GDBAR
C
      DO 450 LL = 1,3
      DO 450 MM = 1,3
      NN = MM + 3*(LL-1)
      GDBAR(LL,MM) = GDBR(NN)
  450 CONTINUE
C
C     *********************************************************
C     *   NOTE TO APPROXIMATE BEAM BEHAVIOUR THE CROSS AND    *
C     *   COUPLING TERMS IN THE GDBAR MATRIX NEED TO BE       *
C     *   DEGRADED I.E SET TO ZERO.                           *
C     *********************************************************
C
      GDBAR(1,2) = 0.0
      GDBAR(2,1) = 0.0
      GDBAR(1,3) = 0.0
      GDBAR(2,3) = 0.0
      GDBAR(3,1) = 0.0
      GDBAR(3,2) = 0.0
C
C     PERFORM INITIALIZATION
C
      ZREF = -TLAM/2.0
      ZK1  = ZK
      IF (K .EQ. 1) ZK1 = ZREF
      IF (ITYPE .EQ. 0) ZK = ZK1 + RZ(PIDLOC+5+4*K)
      IF (ITYPE .EQ. 1) ZK = ZK1 + RZ(PIDLOC+6    )
      IF (ITYPE .EQ. 2) ZK = ZK1 + RZ(PIDLOC+6+2*K)
      ZG1 = ZK - ZK1
      ZG4 =-(ZK**2 - ZK1**2)*0.5
      ZG2 = (ZK**3 - ZK1**3)*0.33333333
C
C     CALCULATE LAYER CONTRIBUTION TO G1, G2, DG2, AND G4 MATRICES
C
      DO 460 IR = 1,3
      DO 460 IC = 1,3
      G1 (IR,IC) =  G1(IR,IC) +  GBAR(IR,IC)*ZG1
      GD1(IR,IC) = GD1(IR,IC) + GDBAR(IR,IC)*ZG1
      IF (LAMOPT.EQ.MEM .OR. LAMOPT.EQ.SYMMEM) GO TO 460
      G2 (IR,IC) =  G2(IR,IC) +  GBAR(IR,IC)*ZG2
      GD2(IR,IC) =  GD2(IR,IC)+ GDBAR(IR,IC)*ZG2
      IF (LAMOPT .EQ. SYM) GO TO 460
      G4 (IR,IC) =  G4(IR,IC) +  GBAR(IR,IC)*ZG4
      GD4(IR,IC) = GD4(IR,IC) + GDBAR(IR,IC)*ZG4
  460 CONTINUE
C
C     CHECK LAMINATION OPTION AND IF SYMM OR SYMM.MEMB CALCULATE
C     LAYER CONTRIBUTION TO THE MEMBRANE, BENDING AND THE
C     MEMEBRANE-BENDING MATRICES
C
      IF (LAMOPT.NE.SYM .AND. LAMOPT.NE.SYMMEM) GO TO 480
C
      DO 470 IR = 1,3
      DO 470 IC = 1,3
      G1 (IR,IC) =  G1(IR,IC) +  GBAR(IR,IC)*ZG1
      GD1(IR,IC) = GD1(IR,IC) + GDBAR(IR,IC)*ZG1
      IF (LAMOPT .EQ. SYMMEM) GO TO 470
      G2 (IR,IC) =  G2(IR,IC) +  GBAR(IR,IC)*ZG2
      GD2(IR,IC) = GD2(IR,IC) + GDBAR(IR,IC)*ZG2
  470 CONTINUE
C
  480 CONTINUE
C
C     **************************************************************
C     CALCULATION OF ZBARX AND ZBARY
C            NEUTRAL SURFACE LOCATION IN X- AND Y- DIRECTION
C
C           TI  -  THICKNESS OF LAYER K
C           ZI  -  DISTANCE FROM REFERENCE SURFACE TO MID OF LAMINA K
C        EX,EY  -  APPARENT ENGINEERING PROPERTY. I.E YOUNGS MODULUS
C                  IN THE LONGITUDINAL AND TRANSVERSE DIRECTIONS IN
C                  THE MATERIAL COORDINATE SYSTEM.
C     **************************************************************
C
C     INVERT GDBAR TO DETERMINE EX AND EY
C
      ISING = -1
      CALL INVERS (3,GDBAR,3,DUMMY,0,DETERM,ISING,INDEXX)
C
C     THE YOUNGS MODULI EX AND EY IN THE MATERIAL COORD SYSTEM
C
      EX = 1.0/GDBAR(1,1)
      EY = 1.0/GDBAR(2,2)
C
      EXX = EX
      EYY = EY
C
C     WRITE EXX AND EYY TO PCOMPS
C
      CALL WRITE (PCOMPS,EXX,1,0)
      CALL WRITE (PCOMPS,EYY,1,0)
C
      IF (LAMOPT .EQ. SYM) GO TO 490
C
      TI = ZK - ZK1
      ZI = (ZK + ZK1)/2.0
C
      ZBARXT = ZBARXT + EX*TI*ZI
      ZBARXB = ZBARXB + EX*TI
      ZBARYT = ZBARYT + EY*TI*ZI
      ZBARYB = ZBARYB + EY*TI
C
C     CALCULATE CONTRIBUTION TO OVERALL DENSITY RHO
C
  490 IF (G(23) .EQ. 0.) GO TO 500
      RHO = RHO + G(23)*ZG1
C
C     PROCESS NEXT LAYER
C
  500 CONTINUE
C
C     JUMP IF LAMOPT IS MEMBRANE OR SYMM.MEMBRANE
C
      IF (LAMOPT.EQ.MEM .OR. LAMOPT.EQ.SYMMEM) GO TO 520
C
C     WRITE GD1, GD2 AND GD4 MATRICES TO STIFF MATRIX AND INVERT
C     TO DETERMINE THE OVERALL BENDING PROPERTY FOR THE LAMINATE.
C
      DO 510 LL = 1,3
      DO 510 MM = 1,3
      STIFF(LL  ,MM  ) = GD1(LL,MM)
      STIFF(LL  ,MM+3) = GD4(LL,MM)
      STIFF(LL+3,MM  ) = GD4(LL,MM)
      STIFF(LL+3,MM+3) = GD2(LL,MM)
  510 CONTINUE
C
C     INVERT STIFF
C
      ISING = -1
      CALL INVERS (6,STIFF,6,DUM,0,DETERM,ISING,INDEX)
C
      EI(1) = 1.0/STIFF(4,4)
      EI(2) = 1.0/STIFF(5,5)
C
      EIXX = EI(1)
      EIYY = EI(2)
C
C     WRITE EIXX AND EIYY TO PCOMPS
C
  520 CALL WRITE (PCOMPS,EIXX,1,0)
      CALL WRITE (PCOMPS,EIYY,1,0)
C
C     ***************************************************************
C     *   THE MEMBRANE, BENDING, AND MEMEBRANE-BENDING MATRICES     *
C     *   G1, G2, G3, AND G4  ARE GIVEN BY THE FOLLOWING            *
C     ***************************************************************
C
      DO 530 IR = 1,3
      DO 530 IC = 1,3
      G1(IR,IC)  = (1.0/TLAM)*G1(IR,IC)
      IF (LAMOPT.EQ.MEM .OR. LAMOPT.EQ.SYMMEM) GO TO 530
      G2(IR,IC)  = (12.0/TLAM**3)*G2(IR,IC)
      IF (LAMOPT .EQ. SYM) GO TO 530
      G4(IR,IC)  = (1.0/TLAM**2)*G4(IR,IC)
  530 CONTINUE
C
C     CALCULATE LOCATION OF NEUTRAL SURFACE ZBARX AND ZBARY
C     FOR LAMINATE
C
      IF (LAMOPT.EQ.SYM .OR. LAMOPT.EQ.MEM .OR. LAMOPT.EQ.SYMMEM)
     1    GO TO 540
      ZBARX = ZBARXT/ZBARXB
      ZBARY = ZBARYT/ZBARYB
      ZBAR(1) = ZBARX
      ZBAR(2) = ZBARY
C
      ZX = ZBARX
      ZY = ZBARY
C
C     WRITE ZX AND ZY TO PCOMPS
C
  540 CALL WRITE (PCOMPS,ZX,1,0)
      CALL WRITE (PCOMPS,ZY,1,0)
C
C     CALCULATE OVERALL DENSITY RHO
C
      IF (RHO .EQ. 0.) GO TO 550
      IF (LAMOPT.EQ.SYM .OR. LAMOPT.EQ.SYMMEM) RHO = 2.0*RHO
      RHO = RHO/TLAM
C
C     ****************************************************************
C     *   CHECK IF TRANSVERSE FLEXIBILITY MATRIX NEEDS TO CALCULATED *
C     *   OTHERWISE JUMP TO PROCEED AS PER NORMAL.                   *
C     ****************************************************************
C
  550 IF (LAMOPT.EQ.MEM .OR. LAMOPT.EQ.SYMMEM) GO TO 830
      IF (G(10) .EQ. 0.0) GO TO 830
C
C     LOOP OVER ALL THE LAYERS
C
      DO 700 K = 1,NLAY
      IF (ITYPE .EQ. 0) MATID = Z(PIDLOC+4+4*K)
      IF (ITYPE.EQ.1 .OR. ITYPE.EQ.2) MATID = Z(PIDLOC+5)
      IF (K.GE.2 .AND. (ITYPE.EQ.0 .AND. MID.EQ.MATID)) GO TO 560
      IF (K.GE.2 .AND. (ITYPE.EQ.1 .OR.  ITYPE.EQ.2)  ) GO TO 560
C
      MID = MATID
      CALL MAT (ELID)
C
C     CALL LPROPS TO GET LAYER PROPERTY MATRICES
C
      CALL LPROPS (G)
C
C     BUILD TRANSFORMATION MATRIX T
C
  560 IF (ITYPE .EQ. 0) THETA = RZ(PIDLOC+6+4*K)
      IF (ITYPE .EQ. 1) THETA = RZ(PIDLOC+7+  K)
      IF (ITYPE .EQ. 2) THETA = RZ(PIDLOC+7+2*K)
      C = ABS(THETA)
      IF (C .LT. 0.000002) C = 0.0
      IF (C.GT.89.99998 .AND. C.LT.90.00002) C =  90.0
      IF (C.GT.179.9998 .AND. C.LT.180.0002) C = 180.0
      IF (C.GT.269.9998 .AND. C.LT.270.0002) C = 270.0
      IF (C.GT.359.9998 .AND. C.LT.360.0002) C = 360.0
      IF (THETA .LT. 0.0) C = -C
      THETAR = C*DEGRAD
C
      C  = COS(THETAR)
      IF (ABS(C) .LT. EPSI) C = 0.0
      C2 = C*C
      C4 = C2*C2
      S  = SIN(THETAR)
      IF (ABS(S) .LT. EPSI) S = 0.0
      S2 = S*S
      S4 = S2*S2
C
      T(1) = C2
      T(2) = S2
      T(3) = C*S
      T(4) = S2
      T(5) = C2
      T(6) =-C*S
      T(7) =-2.0*C*S
      T(8) = 2.0*C*S
      T(9) = C2 - S2
C
C     PROCESSING FOR G3 MATRIX
C
C     CALCULATE GDBR = TT X GD X T
C
C     DETERMINE GD MATRIX, WHICH IS EQUAL TO G MATRIX WITH POISSONS
C     RATIO=0.0
C        GD(1) ---- YOUNGS MODULUS IN X-DIRN
C        GD(5) ---- YOUNGS MODULUS IN Y-DIRN
C        GD(9) ---- INPLANE SHEAR MODULUS
C
      DO 570 LL = 1,9
  570 GD(LL) = 0.0
      CONST = 1.0 - (G(2)*G(4))/(G(5)*G(1))
      GD(1) = G(1)*CONST
      GD(5) = G(5)*CONST
      GD(9) = G(9)
C
C     MULTIPLY GD X T AND WRITE TO GDT
C
      CALL GMMATS (GD(1),3,3,0, T(1),3,3,0, GDT(1))
C
C     MULTIPLY TT X GDT AND WRITE TO GDBR
C
      CALL GMMATS (T(1),3,3,1, GDT(1),3,3,0, GDBR(1))
C
C     WRITE GBR TO GDBAR
C
      DO 580 LL = 1,3
      DO 580 MM = 1,3
      NN = MM + 3*(LL-1)
      GDBAR(LL,MM) = GDBR(NN)
  580 CONTINUE
C
C     *************************************************************
C     *       NOTE TO APPROXIMATE BEAM BEHAVIOUR THE CROSS AND    *
C     *       COUPLING TERMS IN THE GDBAR MATRIX NEED TO BE       *
C     *       DEGRADED I.E SET TO ZERO.                           *
C     *************************************************************
C
      GDBAR(1,2) = 0.0
      GDBAR(2,1) = 0.0
      GDBAR(1,3) = 0.0
      GDBAR(2,3) = 0.0
      GDBAR(3,1) = 0.0
      GDBAR(3,2) = 0.0
C
C     INVERT GDBAR TO DETERMINE EX AND EY
C
      ISING = -1
      CALL INVERS (3,GDBAR,3,DUMMY,0,DETERM,ISING,INDEXX)
C
C     THE YOUNGS MODULI EX AND EY IN THE MATERIAL COORD SYSTEM ARE
C
      E(1) = 1.0/GDBAR(1,1)
      E(2) = 1.0/GDBAR(2,2)
C
C     PERFORM INTILIZATION
C
      ZREF = -TLAM/2.0
      ZK1  = ZK
      IF (K .EQ. 1) ZK1 = ZREF
      IF (ITYPE .EQ. 0) ZK = ZK1 + RZ(PIDLOC+5+4*K)
      IF (ITYPE .EQ. 1) ZK = ZK1 + RZ(PIDLOC+6    )
      IF (ITYPE .EQ. 2) ZK = ZK1 + RZ(PIDLOC+6+2*K)
C
C     BUILD TRANSFORMATION MATRIX U
C
      U(1) = C
      U(2) = S
      U(3) =-S
      U(4) = C
C
C     CALCULATE G3BAR = UT X G3I X U
C     G3I MATRIX  -  LAYER K TRANSFORMED G3, IN MATERIAL COORD-SYS
C
      DO 590 LL = 1,4
      MM = LL + 9
      G3I(LL) = G(MM)
  590 CONTINUE
C
C     MULTIPLY G3I X U AND WRITE TO G3IU
C
      CALL GMMATS (G3I(1),2,2,0, U(1),2,2,0, G3IU(1))
C
C     MULTIPLY UT X G3IU AND WRITE TO G3BR
C
      CALL GMMATS (U(1),2,2,1, G3IU(1),2,2,0, G3BR(1))
C
C     WRITE G3BR IN TWO DIMENSIONED ARRAY G3BAR
C
      DO 600 LL = 1,2
      DO 600 MM = 1,2
      NN = MM + 2*(LL-1)
      G3BAR(LL,MM) = G3BR(NN)
  600 CONTINUE
C
C     INVERT G3BAR
C
      DETRMN = G3BAR(1,1)*G3BAR(2,2) - G3BAR(1,2)*G3BAR(2,1)
      IF (DETRMN .EQ. 0.0) GO TO 1230
C
      G3INVD(1,1) = G3BAR(2,2)/DETRMN
      G3INVD(1,2) =-G3BAR(1,2)/DETRMN
      G3INVD(2,1) =-G3BAR(2,1)/DETRMN
      G3INVD(2,2) = G3BAR(1,1)/DETRMN
C
C     G3 MATRIX CALC
C
      ZI = (ZK + ZK1)/2.0
      TI =  ZK - ZK1
C
      DO 610 IR = 1,2
      RI(IR) = ((FI(IR)/E(IR)) + (ZBAR(IR)-ZK1)*TI - (TI*TI/3.0))
     1       * (FI(IR)/E(IR))
      RI(IR) = RI(IR) + ZBAR(IR)*TI*TI*((ZBAR(IR)-2.0*ZK1)/3.0
     1       - (TI/4.0))
      RI(IR) = RI(IR) + TI*TI*((ZK1*ZK1)/3.0 + (ZK1*TI)/4.0
     1       + (TI*TI)/20.0)
      RI(IR) = RI(IR)*E(IR)*E(IR)*TI
  610 CONTINUE
C
      DO 620 IR = 1,2
      DO 620 IC = 1,2
      GTRFLX(IR,IC) = GTRFLX(IR,IC) + RI(IR)*G3INVD(IR,IC)
  620 CONTINUE
C
      DO 630 IR = 1,2
      FII(IR) = E(IR)*TI*(ZBAR(IR)-ZI)
      FI(IR)  = FI(IR) + FII(IR)
  630 CONTINUE
C
C     PROCESS NEXT LAYER
C
  700 CONTINUE
C
C
C    FALL HERE IF LAMOPT IS SYMM AND G3 CALCULATION IS REQUIRED
C
C
      IF (LAMOPT .NE. SYM) GO TO  810
      DO 800 KK = 1,NLAY
      K = NLAY + 1 - KK
C
      IF (ITYPE .EQ. 0) MATID = Z(PIDLOC+4+4*K)
      IF (ITYPE.EQ.1 .OR. ITYPE.EQ.2) MATID = Z(PIDLOC+5)
      IF (K.GE.2 .AND. (ITYPE.EQ.0 .AND. MID.EQ.MATID)) GO TO 710
      IF (K.GE.2 .AND. (ITYPE.EQ.1 .OR.  ITYPE.EQ.2)  ) GO TO 710
C
      MID = MATID
      CALL MAT (ELID)
C
C     CALL LPROPS TO GET LAYER PROPERTY MATRICES
C
      CALL LPROPS (G)
C
C     BUILD TRANSFORMATION MATRIX T
C
  710 IF (ITYPE .EQ. 0) THETA = RZ(PIDLOC+6+4*K)
      IF (ITYPE .EQ. 1) THETA = RZ(PIDLOC+7+  K)
      IF (ITYPE .EQ. 2) THETA = RZ(PIDLOC+7+2*K)
      C = ABS(THETA)
      IF (C .LT. 0.000002) C = 0.0
      IF (C.GT.89.99998 .AND. C.LT.90.00002) C =  90.0
      IF (C.GT.179.9998 .AND. C.LT.180.0002) C = 180.0
      IF (C.GT.269.9998 .AND. C.LT.270.0002) C = 270.0
      IF (C.GT.359.9998 .AND. C.LT.360.0002) C = 360.0
      IF (THETA .LT. 0.0) C = -C
      THETAR = C*DEGRAD
C
      C  = COS(THETAR)
      IF (ABS(C) .LT. EPSI) C = 0.0
      C2 = C*C
      C4 = C2*C2
      S  = SIN(THETAR)
      IF (ABS(S) .LT. EPSI) S = 0.0
      S2 = S*S
      S4 = S2*S2
C
      T(1) = C2
      T(2) = S2
      T(3) = C*S
      T(4) = S2
      T(5) = C2
      T(6) =-C*S
      T(7) =-2.0*C*S
      T(8) = 2.0*C*S
      T(9) = C2 - S2
C
C     PROCESSING FOR G3 MATRIX
C
C     CALCULATE GDBR = TT X GD X T
C
C     DETERMINE GD MATRIX, WHICH IS EQUAL TO G MATRIX WITH POISSONS
C     RATIO=0.0
C        GD(1) ---- YOUNGS MODULUS IN X-DIRN
C        GD(5) ---- YOUNGS MODULUS IN Y-DIRN
C        GD(9) ---- INPLANE SHEAR MODULUS
C
      DO 720 LL = 1,9
  720 GD(LL) = 0.0
      CONST = 1.0 - (G(2)*G(4))/(G(5)*G(1))
      GD(1) = G(1)*CONST
      GD(5) = G(5)*CONST
      GD(9) = G(9)
C
C     MULTIPLY GD X T AND WRITE TO GDT
C
      CALL GMMATS (GD(1),3,3,0, T(1),3,3,0, GDT(1))
C
C     MULTIPLY TT X GDT AND WRITE TO GDBR
C
      CALL GMMATS (T(1),3,3,1, GDT(1),3,3,0, GDBR(1))
C
C     WRITE GBR TO GDBAR
C
      DO 730 LL = 1,3
      DO 730 MM = 1,3
      NN = MM + 3*(LL-1)
      GDBAR(LL,MM) = GDBR(NN)
  730 CONTINUE
C
C     *************************************************************
C     *       NOTE TO APPROXIMATE BEAM BEHAVIOUR THE CROSS AND    *
C     *       COUPLING TERMS IN THE GDBAR MATRIX NEED TO BE       *
C     *       DEGRADED I.E SET TO ZERO.                           *
C     *************************************************************
C
      GDBAR(1,2) = 0.0
      GDBAR(2,1) = 0.0
      GDBAR(1,3) = 0.0
      GDBAR(2,3) = 0.0
      GDBAR(3,1) = 0.0
      GDBAR(3,2) = 0.0
C
C     INVERT GDBAR TO DETERMINE EX AND EY
C
      ISING = -1
      CALL INVERS (3,GDBAR,3,DUMMY,0,DETERM,ISING,INDEXX)
C
C     THE YOUNGS MODULI EX AND EY IN THE MATERIAL COORD SYSTEM ARE
C
      E(1) = 1.0/GDBAR(1,1)
      E(2) = 1.0/GDBAR(2,2)
C
C     PERFORM INTILIZATION
C
      ZREF = -TLAM/2.0
      ZK1  = ZK
      IF (ITYPE .EQ. 0) ZK = ZK1 + RZ(PIDLOC+5+4*K)
      IF (ITYPE .EQ. 1) ZK = ZK1 + RZ(PIDLOC+6    )
      IF (ITYPE .EQ. 2) ZK = ZK1 + RZ(PIDLOC+6+2*K)
C
C     BUILD TRANSFORMATION MATRIX U
C
      U(1) = C
      U(2) = S
      U(3) =-S
      U(4) = C
C
C     CALCULATE G3BAR = UT X G3I X U
C     G3I MATRIX  -  LAYER K TRANSFORMED G3, IN MATERIAL COORD-SYS
C
      DO 740 LL = 1,4
      MM = LL + 9
      G3I(LL) = G(MM)
  740 CONTINUE
C
C     MULTIPLY G3I X U AND WRITE TO G3IU
C
      CALL GMMATS (G3I(1),2,2,0, U(1),2,2,0, G3IU(1))
C
C     MULTIPLY UT X G3IU AND WRITE TO G3BR
C
      CALL GMMATS (U(1),2,2,1, G3IU(1),2,2,0, G3BR(1))
C
C     WRITE G3BR IN TWO DIMENSIONED ARRAY G3BAR
C
      DO 750 LL = 1,2
      DO 750 MM = 1,2
      NN = MM + 2*(LL-1)
      G3BAR(LL,MM) = G3BR(NN)
  750 CONTINUE
C
C     INVERT G3BAR
C
      DETRMN = G3BAR(1,1)*G3BAR(2,2) - G3BAR(1,2)*G3BAR(2,1)
      IF (DETRMN .EQ. 0.0) GO TO 1230
C
      G3INVD(1,1) = G3BAR(2,2)/DETRMN
      G3INVD(1,2) =-G3BAR(1,2)/DETRMN
      G3INVD(2,1) =-G3BAR(2,1)/DETRMN
      G3INVD(2,2) = G3BAR(1,1)/DETRMN
C
C     THE CORRESSPONDING LAYER ON THE OTHER SIDE OF SYMMETRY
C
      ZI = (ZK + ZK1)/2.0
      TI =  ZK - ZK1
C
      DO 760 IR = 1,2
      RI(IR) = (FI(IR)/E(IR) +(-ZK1)*TI-TI*TI/3.0 )*FI(IR)/E(IR)
     1       + (ZK1*ZK1/3.0+ZK1*TI/4.0+TI*TI/20.0)*TI*TI
      RI(IR) = RI(IR)*E(IR)*E(IR)*TI
  760 CONTINUE
C
      DO 770 IR = 1,2
      DO 770 IC = 1,2
      GTRFLX(IR,IC) = GTRFLX(IR,IC) + RI(IR)*G3INVD(IR,IC)
  770 CONTINUE
C
      DO 780 IR = 1,2
      FII(IR) = E(IR)*TI*(ZBAR(IR)-ZI)
      FI(IR)  = FI(IR) + FII(IR)
  780 CONTINUE
C
C     PROCESS NEXT LAYER
C
  800 CONTINUE
C
  810 DO 820 IR = 1,2
      DO 820 IC = 1,2
      GTRFLX(IR,IC) = GTRFLX(IR,IC)*TLAM/(EI(IR)**2)
  820 CONTINUE
C
C     INVERT GTRFLX
C
      DETRMN = GTRFLX(1,1)*GTRFLX(2,2) - GTRFLX(1,2)*GTRFLX(2,1)
      IF (DETRMN .EQ. 0.0) GO TO 1230
C
      G3(1,1) = GTRFLX(2,2)/DETRMN
      G3(1,2) =-GTRFLX(1,2)/DETRMN
      G3(2,1) =-GTRFLX(2,1)/DETRMN
      G3(2,2) = GTRFLX(1,1)/DETRMN
C
C     BECAUSE G3(1,2) IS NOT EQUAL TO G3(2,1) IN GENERAL
C     AN AVERAGE VALUE WILL BE USED FOR THE COUPLING TERMS
C
      G3(1,2) = (G3(1,2) + G3(2,1))/ 2.0
      G3(2,1) = G3(1,2)
C
C     *****************************************************
C     WRITE THE NEWLY GENERATED G1, G2, G3, AND G4 MATRICES
C     TO MPTX IN THE FORM OF MAT2 DATA ENTRIES
C     *****************************************************
C
C      NOTE - THE MID FOR THESE MATRICES ARE AS FOLLOWS-
C         1. MID1  -- PID + 100000000
C         2. MID2  -- PID + 200000000
C         3. MID3  -- PID + 300000000
C         4. MID4  -- PID + 400000000
C
C    INITIALIZE G1, G2, G3, AND G4 MATRICES
C
  830 DO 840 JJ = 1,17
      GMEMBR(JJ) = 0.0
      GBENDG(JJ) = 0.0
      GTRSHR(JJ) = 0.0
      GMEMBD(JJ) = 0.0
  840 CONTINUE
C
      IMEMBR(1) = 0
      IBENDG(1) = 0
      ITRSHR(1) = 0
      IMEMBD(1) = 0
C
C     START GENERATING G1 MEMBRANE MATRIX
C
      IMEMBR( 1) = Z(PIDLOC) + 100000000
      GMEMBR( 2) = G1(1,1)
      GMEMBR( 3) = G1(1,2)
      GMEMBR( 4) = G1(1,3)
      GMEMBR( 5) = G1(2,2)
      GMEMBR( 6) = G1(2,3)
      GMEMBR( 7) = G1(3,3)
      GMEMBR( 8) = RHO
C
C     NEXT 5 LINES ARE NEW FROM 2/90 UAI CODE
C
      IF (.NOT.OK UAI) GO TO 845
      GMEMBR( 9) = ALFA1
      GMEMBR(10) = ALFA2
      GMEMBR(11) = ALFA12
      GMEMBR(12) = TREF
      GMEMBR(13) = GSUBE
C
  845 IF (LAMOPT.EQ.MEM .OR. LAMOPT.EQ.SYMMEM) GO TO 850
C
C     START GENERATING G2 BENDING MATRIX
C
      IBENDG( 1) = Z(PIDLOC) + 200000000
      GBENDG( 2) = G2(1,1)
      GBENDG( 3) = G2(1,2)
      GBENDG( 4) = G2(1,3)
      GBENDG( 5) = G2(2,2)
      GBENDG( 6) = G2(2,3)
      GBENDG( 7) = G2(3,3)
C
C     NEXT 3 LINES ARE NEW FROM 2/90 UAI CODE
C
      IF (.NOT.OK UAI) GO TO 847
C     GBENDG( 8) = ??
      GBENDG( 9) = ALFA1
      GBENDG(10) = ALFA2
      GBENDG(11) = ALFA12
C
C     START GENERATING G3 TRANSVERSE SHEAR FLEXIBILITY MATRIX
C
  847 ITRSHR( 1) = Z(PIDLOC) + 300000000
      GTRSHR( 2) = G3(1,1)
      GTRSHR( 3) = G3(1,2)
      GTRSHR( 4) = G3(2,1)
      GTRSHR( 5) = G3(2,2)
C
      IF (LAMOPT .EQ. SYM) GO TO 850
C
C     START GENERATING G4 MEMBRANE-BENDING COUPLING MATRIX
C
      IMEMBD( 1) = Z(PIDLOC) + 400000000
      GMEMBD( 2) = G4(1,1)
      GMEMBD( 3) = G4(1,2)
      GMEMBD( 4) = G4(1,3)
      GMEMBD( 5) = G4(2,2)
      GMEMBD( 6) = G4(2,3)
      GMEMBD( 7) = G4(3,3)
C
  850 CONTINUE
C
C     *******************************************************
C     GENERATE EQUIVALENT PSHELL BULK DATA ENTIES FOR EVERY
C     PCOMPI BULK DATA ENTRY. THIS IS NECESSARY FOR DEMG TO
C     FUNCTION CORRECTLY WHEN LAMINATED COMPOSITE ELEMENTS
C     ARE PRESENT.
C     *******************************************************
C
      IPSHEL( 1) = Z(PIDLOC)
      IPSHEL( 2) = Z(PIDLOC) + 100000000
      RPSHEL( 3) = TLAM
      IPSHEL( 4) = Z(PIDLOC) + 200000000
      RPSHEL( 5) = 1.0
      IPSHEL( 6) = Z(PIDLOC) + 300000000
      RPSHEL( 7) = 1.0
      RPSHEL( 8) = RZ(PIDLOC+2)
      RPSHEL( 9) =-TLAM/2.0
      RPSHEL(10) = TLAM/2.0
      IPSHEL(11) = Z(PIDLOC) + 400000000
C     IPSHEL(12) = 0
      RPSHEL(12) = 0.0
      IPSHEL(13) = 0
      IPSHEL(14) = 0
C     IPSHEL(15) = 0
      RPSHEL(15) = 0.0
      IPSHEL(16) = 0
C     IPSHEL(17) = 0
      RPSHEL(17) = 0.0
C
      ZOFFS = RZ(PIDLOC+1) + TLAM/2.0
      IF (Z(PIDLOC)  .EQ.  BLANK) ZOFFS = 0.0
      IF (LAMOPT.EQ.MEM .OR. LAMOPT.EQ.SYMMEM) ZOFFS = 0
      IF (ABS(ZOFFS) .LE. 1.0E-3) ZOFFS = 0.0
      RPSHEL(14) = ZOFFS
C
      IF (LAMOPT.NE.MEM .AND. LAMOPT.NE.SYMMEM) GO TO 860
      IPSHEL( 4) = 0
      IPSHEL( 6) = 0
      IPSHEL(11) = 0
      RPSHEL(14) = 0.0
  860 IF (LAMOPT .NE. SYM) GO TO 870
      IPSHEL(11) = 0
  870 CONTINUE
C
C     UPDATE COUNTER ICOUNT TO INDICATE MAT2 AND PSHELL DATA IS BEING
C     WRITTEN SECOND TIME
C
      ICOUNT = ICOUNT + 1
C
      IF (ICOUNT .GT. 1) GO TO 900
C
      IF (PSHLPR .NE. 1) GO TO 890
      ICORE = LPCOMP + 1 + N2MAT
      N = BUF5 - ICORE
      CALL OPEN (*1200,EPT,Z(BUF4),RDREW)
      CALL FILPOS (EPT,POS1)
      CALL READ (*900,*880,EPT,Z(ICORE),N,0,EPTWDS)
      CALL MESAGE (-8,0,NAM)
  880 CALL WRITE (EPTX,Z(ICORE),EPTWDS,0)
      GO TO 900
  890 CALL WRITE (EPTX,PSHNAM,3,0)
  900 CALL WRITE (EPTX,IPSHEL(1),17,0)
C
      IF (ICOUNT .GT. 1) GO TO 930
C
      IF (MAT2PR .NE. 1) GO TO 920
      ICORE = LPCOMP + 1 + N2MAT
      N = BUF5 - ICORE
      CALL OPEN (*1200,MPT,Z(BUF2),RDREW)
      CALL FILPOS (MPT,POS)
      CALL READ (*930,*910,MPT,Z(ICORE),N,0,MATWDS)
      CALL MESAGE (-8,0,NAM)
  910 CALL WRITE (MPTX,Z(ICORE),MATWDS,0)
      GO TO 930
  920 CALL WRITE (MPTX,MATNAM,3,0)
  930 CALL WRITE (MPTX,IMEMBR(1),17,0)
      IF (LAMOPT.EQ.MEM .OR. LAMOPT.EQ.SYMMEM) GO TO 940
      CALL WRITE (MPTX,IBENDG(1),17,0)
      CALL WRITE (MPTX,ITRSHR(1),17,0)
      IF (LAMOPT .EQ. SYM) GO TO 940
      CALL WRITE (MPTX,IMEMBD(1),17,0)
  940 CONTINUE
      CALL SSWTCH (40,L40)
      IF (L40 .EQ. 0) GO TO 980
C
C     WRITE THE NEWLY GENERATED PROPERTY MATRICES TO THE OUTPUT FILE
C
      CALL PAGE2 (2)
      WRITE (NOUT,960) IMEMBR(1),(GMEMBR(LL),LL=2,16)
      IF (LAMOPT.EQ.MEM .OR. LAMOPT.EQ.SYMMEM) GO TO 980
      CALL PAGE2 (2)
      WRITE (NOUT,960) IBENDG(1),(GBENDG(LL),LL=2,16)
      IF (GTRSHR(1) .EQ. 0.0) GO TO 950
      CALL PAGE2 (2)
      WRITE (NOUT,960) ITRSHR(1),(GTRSHR(LL),LL=2,16)
  950 IF (LAMOPT .EQ. SYM) GO TO 980
      CALL PAGE2 (2)
      WRITE  (NOUT,960) IMEMBD(1),(GMEMBD(LL),LL=2,16)
  960 FORMAT (/,' MAT2',7X,I9,7(1X,1P,E11.4),/,9X,8(1X,F11.1))
C
C     UPDATE LOCATION OF NEXT PID
C
  980 PIDLOC = EOELOC + 1
      ISTART = PIDLOC
C
C     WRITE END OF ENTRY (EOE) TO PCOMPS BEFORE PROCESSING
C     NEXT PCOMP ENTRY
C
      CALL WRITE (PCOMPS,EOE,1,0)
C
C     CHECK IF ALL 'PCOMP' TYPE ENTRIES HAVE BEEN PROCESSED
C
      IF (ISTART .GE. IFINIS) IF (ITYPE-1) 990,1000,1010
C
C     PROCESS NEXT 'PCOMP' ENTRY
C
      GO TO 250
C
  990 CALL WRITE (PCOMPS,0,0,1)
      IF (TYPC1 .GT. 0) GO TO 190
      IF (TYPC2 .GT. 0) GO TO 200
      GO TO 1020
C
 1000 CALL WRITE (PCOMPS,0,0,1)
      IF (TYPC2 .GT. 0) GO TO 200
      GO TO 1020
C
 1010 CALL WRITE (PCOMPS,0,0,1)
C
C     ALL 'PCOMP' TYPES PROCESSED
C     WRITE EOR ON MPTX AND EPTX
C
 1020 CALL WRITE (MPTX,0,0,1)
      CALL WRITE (EPTX,0,0,1)
C
C     COPY REMAINDER OF EPT TO EPTX
C
      ICORE = 1
      N = BUF5 - 1
      EPTWDS = 0
      IF (PSHLPR .NE. 1) CALL OPEN (*1200,EPT,Z(BUF4),RDREW)
      CALL FILPOS (EPT,POS1)
      IF (PSHLPR .EQ. 1) CALL FWDREC (*1050,EPT)
 1030 CALL READ (*1050,*1040,EPT,Z(ICORE),N,1,EPTWDS)
      CALL MESAGE (-8,0,NAM)
 1040 CALL WRITE (EPTX,Z(ICORE),EPTWDS,1)
      EPTWDS = 0
      GO TO 1030
C
C     READ TRAILER FROM EPT AND WRITE TO EPTX
C
 1050 DO 1060 KK = 1,7
 1060 IEPTX(KK) = 0
      IEPTX( 1) = EPT
C
      CALL RDTRL(IEPTX)
      IEPTX(1) = EPTX
      KT721 = ANDF(PSHBIT,511)
      K1 = (KT721-1)/16 + 2
      K2 = KT721 - (K1-2)*16 + 16
      IEPTX(K1) = ORF(IEPTX(K1),TWO(K2))
      CALL WRTTRL (IEPTX)
C
C     IF EOF ON MPT,THEN ALL MAT2 DATA COPIED TO MPTX
C
      IF (EOF .EQ. 1) GO TO 1090
C
C     OTHERWISE COPY REMAINDER OF MPT TO MPTX
C
      ICORE = 1
      N = BUF5 - 1
      MATWDS = 0
      IF (MAT2PR .NE. 1) CALL OPEN (*1200,MPT,Z(BUF2),RDREW)
      CALL FILPOS (MPT,POS)
      IF (MAT2PR .EQ. 1) CALL FWDREC (*1090,MPT)
 1070 CALL READ (*1090,*1080,MPT,Z(ICORE),N,1,MATWDS)
      CALL MESAGE (-8,0,NAM)
 1080 CALL WRITE (MPTX,Z(ICORE),MATWDS,1)
      MATWDS = 0
      GO TO 1070
C
C     READ TRAILER FROM MPT AND WRITE TO MPTX
C
 1090 DO 1100 KK = 1,7
 1100 IMPTX(KK) = 0
      IMPTX( 1) = MPT
C
      CALL RDTRL(IMPTX)
      IMPTX(1) = MPTX
      KT721 = ANDF(MT2BIT,511)
      K1 = (KT721-1)/16 + 2
      K2 = KT721 - (K1-2)*16 + 16
      IMPTX(K1) = ORF(IMPTX(K1),TWO(K2))
      CALL WRTTRL (IMPTX)
C
C     WRITE TO TRAILER OF PCOMPS
C
C     SET TRAILER BIT POSITION TO ZERO IF ENTRY TYPE DOES NOT EXIST
C
      IF (TYPC  .EQ. 0) PCBIT(1) = 0
      IF (TYPC1 .EQ. 0) PCBIT(2) = 0
      IF (TYPC2 .EQ. 0) PCBIT(3) = 0
C
      DO 1110 LL = 1,3
      KT721 = ANDF(PCBIT(LL),511)
      K1 = (KT721-1)/16 + 2
      K2 = KT721 - (K1-2)*16 + 16
      IPCOMP(K1) = ORF(IPCOMP(K1),TWO(K2))
 1110 CONTINUE
C
C     WHEN ICFIAT IS 11, A 65536 IS LEFT IN IPCOMP(2) ACCIDENTALLY
C     ZERO IT OUT
C
      IF (ICFIAT .EQ. 11) IPCOMP(2) = 0
      CALL WRTTRL (IPCOMP)
C
C     CLOSE ALL FILES
C
      CALL CLOSE (PCOMPS,1)
      CALL CLOSE (EPTX,1)
      CALL CLOSE (MPTX,1)
      CALL CLOSE (MPT,1)
      CALL CLOSE (EPT,1)
C
      RETURN
C
C     FATAL ERROR MESSAGES
C
 1200 CALL MESAGE (-1,FILE,NAM)
      GO TO 1300
 1210 CALL PAGE2 (2)
      WRITE  (NOUT,1220)
 1220 FORMAT ('0*** SYSTEM FATAL ERROR.  PCOMP, PCOMP1 OR PCOMP2',
     1        ' DATA NOT FOUND BY SUBROUTINE TA1CPS.')
      NOGO = 1
      GO TO 1300
 1230 CALL PAGE2 (4)
      WRITE (NOUT,1240) MATID
      NOGO = 1
 1240 FORMAT ('0*** USER FATAL ERROR.  IMPROPER DATA PROVIDED FOR',
     1       ' CALCULATION OF TRANSVERSE SHEAR FLEXIBILITY MATRIX',
     2       /,23X,'FOR LAMINA REFERENCING MID ',I8,'.',
     3       /,23X,'CHECK DATA ON MAT BULK DATA ENTRY.')
 1300 CONTINUE
      RETURN
      END