      SUBROUTINE EMA
C
C     DMAP SEQUENCE
C
C     EMA    GPECT,XEMD,XBLOCK/XGG/C,N,NOK4/C,N,WTMASS $
C
C            WHERE NOK4 .NE. -1 TO BUILD K4GG (USE DAMPING FACTOR),
C                       .EQ. -1 TO IGNORE DAMPING FACTOR
C
C     EMA USES TWO SCRATCH FILES
C
      EXTERNAL        LSHIFT,RSHIFT,ANDF  ,ORF
      LOGICAL         FIRST ,LAST  ,PIEZ
      INTEGER         BUF1  ,BUF2  ,SCRIN ,SCROUT,SCR1  ,SCR2  ,GPECT ,
     1                BUF   ,SYSBUF,RDREW ,WRTREW,RD    ,WRT   ,CLS   ,
     2                CLSREW,Z     ,BUF3  ,XEMD  ,OUTPUT,GPEWDS,GPECTX,
     3                HIGH  ,XBLOCK,SCALAS,XGG   ,ANDF  ,PREC  ,HDR   ,
     4                PPOINT,UNION ,ORF   ,OP    ,RSHIFT,COL   ,OLDCOD,
     5                COL1  ,COLN  ,Q     ,OPENR ,OPENW
      DOUBLE PRECISION       ZD    ,XD    ,D
      DIMENSION       BUF(100)     ,SCALAS(32)   ,HDR(6),MSG(4),MCB(7),
     1                MA1H(2)      ,ZD(1) ,XD(1) ,XS(2) ,IS(2) ,Y(1)  ,
     2                D(18) ,IHQ(180)
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25
      COMMON /XMSSG / UFM   ,UWM   ,UIM   ,SFM
      COMMON /MACHIN/ MACH  ,IHALF ,JHALF
      COMMON /LHPWX / LHPW(5)      ,KSHIFT
      COMMON /BLANK / NOK4  ,WTMASS
      COMMON /SYSTEM/ KSYSTM(100)
      COMMON /NAMES / RD    ,RDREW ,WRT   ,WRTREW,CLSREW,CLS
      COMMON /ZBLPKX/ Q(4)  ,IQ
CZZ   COMMON /ZZEMAX/ Z(1)
      COMMON /ZZZZZZ/ Z(1)
      COMMON /MA1XX / BUF   ,BUF1  ,BUF2  ,BUF3  ,COL   ,COLN  ,COL1  ,
     1                GPEWDS,HIGH  ,I     ,ICOL  ,ICOLX ,IDICT ,IELEM ,
     2                IGPX  ,ILIST ,IMAT  ,IMATN ,IPVT  ,IROW  ,IROWP ,
     3                IROWX ,JJ    ,K     ,KELEM ,KK    ,II    ,K4FLAG,
     4                L     ,J     ,LCORE ,LDICT ,LOW   ,L1    ,L2    ,
     5                M     ,MAXII ,MAXIPV,MAXN  ,MAXNPR,JNEXT ,N     ,
     6                NBRCOL,NBRROW,NBRWDS,NCOL  ,NGPS  ,NGRIDS,NHDR  ,
     7                NLIST ,NLOCS ,NMAT  ,NPVT  ,NREAD ,NREC  ,NROW  ,
     8                NROWP ,NSCA  ,NWDS  ,OLDCOD,OP    ,PREC  ,SCRIN ,
     9                SCROUT, UNION,SCALAS
      EQUIVALENCE    (KSYSTM( 1),SYSBUF), (KSYSTM( 2),OUTPUT),
     1               (KSYSTM(78),IPIEZ )
      EQUIVALENCE    (Z(1) ,ZD(1)), (XS(1),XD(1),IS(1)), (Z(1) ,Y(1) ),
     1               (BUF(1),D(1)), (IPVT ,IVPT ), (BUF(1),IHQ(1))
      DATA   LBUF  / 100/, MCB/ 7*0 /, MA1H/ 4HEMA ,2H   /, KONS/ 14 /,
     1       MDICT / 6  /, HDR/ 6*0 /
      DATA   GPECT , XEMD  , XBLOCK / 101, 102, 103 / ,
     1       XGG                    / 201           / ,
     2       SCR1  , SCR2           / 301, 302      /
C
C
C     RE-SET KONS IF HALF WORD IS LARGER THAN THAN 16 BITS
C
      IF (IHALF .GE. 18) KONS = 16
      IF (IHALF .GE. 30) KONS = 24
C
C     ALLOCATE BUFFERS. OPEN GPECT AND ALLOCATE A TABLE OF 4 WORDS
C     PER ELEMENT TYPE. OPEN SCRATCH FILE FOR GPECTX. OPEN XEMD.
C
      MCB(1) = 0
      MCB(2) = 0
      MCB(3) = 0
      MCB(4) = 0
      MCB(5) = 0
      MCB(6) = 0
      MCB(7) = 0
      MAXII  = 2**KONS - 1
      MAXBLK = 0
      KSFT   = KSHIFT
      MASK   = LSHIFT(JHALF,IHALF)
      BUF1   = KORSZ(Z) - SYSBUF
      BUF2   = BUF1 - SYSBUF
      BUF3   = BUF2 - SYSBUF
      LCORE  = BUF1 + SYSBUF - 1
      K4FLAG = 1
      IF (NOK4 .EQ. -1) K4FLAG = 0
C
C     SET LOGICAL VARIABLE TRUE IF THIS IS A PIEZOELECRRIC COUPLED
C     PROBLEM AND STRUCTURAL DAMPING FLAG IS ON
C
      PIEZ = .FALSE.
      IF (IPIEZ.EQ.1 .AND. K4FLAG.NE.0) PIEZ = .TRUE.
      BUF(1) = XBLOCK
      CALL RDTRL (BUF)
      IF (BUF(1) .LT. 0) GO TO 9132
      PREC   = BUF(2)
      BUF(1) = GPECT
      CALL RDTRL (BUF)
      IF (BUF(1) .LT. 0) GO TO 9131
      IDICT = 4*BUF(2) + 1
      NSIL  = BUF(3)
      MAXEL = BUF(4)
      MAXDOF= BUF(5)
      CALL GOPEN (GPECT,Z(BUF1),RDREW)
      L     = (2**(IHALF+IHALF-2)-1)*2 + 1
      MAXIPV= RSHIFT(L,KONS)
      SCRIN = GPECT
      SCROUT= SCR1
      CALL GOPEN (XEMD,Z(BUF3),RDREW)
      CALL OPEN (*9134,SCROUT,Z(BUF2),WRTREW)
      CALL WRITE (SCROUT,BUF,3,1)
C
C     SET SWITCHES FOR MULTIPLICATION BY DAMPING
C     OR WEIGHT MASS FACTOR (OR BOTH)
C
      EPS = ABS(WTMASS-1.0)
      IF (EPS.LT.1.E-6 .AND. K4FLAG.EQ.0) ASSIGN  1370 TO KFACT
      IF (EPS.LT.1.E-6 .AND. K4FLAG.NE.0) ASSIGN 13651 TO KFACT
      IF (EPS.GT.1.E-6 .AND. K4FLAG.EQ.0) ASSIGN 13652 TO KFACT
      IF (EPS.GT.1.E-6 .AND. K4FLAG.NE.0) ASSIGN 13653 TO KFACT
C
C     FILL CORE WITH ELEMENT MATRIX DICTIONARIES. FOR EACH ELEMENT TYPE
C     STORE POINTER TO 1ST DICT AND THE NBR OF DICTS IN TABLE AT TOP OF
C     CORE ALSO STORE LENGTH OF EACH DICTIONARY AND FORMAT CODE.
C
      L = IDICT
      DO 1012 I = 1,IDICT
 1012 Z(I)  = 0
      MAXN  = 0
      LAST  = .TRUE.
 1014 CALL READ (*1026,*9135,XEMD,HDR,3,0,NREAD)
      IELEM = 4*HDR(1) - 3
      LDICT = HDR(2)
      Z(IELEM  ) = L
      Z(IELEM+2) = LDICT
      Z(IELEM+3) = HDR(3)
 1016 IF (L+LDICT .GE. BUF3) GO TO 1024
      JDICT = LDICT
      CALL READ (*9136,*1018,XEMD,Z(L),LDICT,0,NREAD)
      L = L + LDICT
      GO TO 1016
 1018 IF (NREAD .NE. 0) GO TO 9001
      HIGH = Z(L-LDICT)
      Z(IELEM+1) = (L-Z(IELEM))/LDICT
      GO TO 1014
 1024 LAST = .FALSE.
      Z(IELEM+1) = (L-Z(IELEM))/LDICT
      HIGH = Z(L-JDICT)
      IF (Z(IELEM+1) .NE. 0) GO TO 1030
      Z(IELEM) = 0
      GO TO 1030
 1026 LAST = .TRUE.
      CALL CLOSE (XEMD,CLSREW)
C
C     PASS GPECT (OR PARTIALLY COMPLETED GPECTX) ENTRY BY ENTRY.
C     IF ENTRY HAS BEEN COMPLETED, COPY IT OUT.  OTHERWISE, LOCATE
C     DICTIONARY FOR ELEMENT (IF IN CORE) AND ATTACH IT.
C     DETERMINE LENGTH OF LONGEST RECORD IN GPECTX.
C     DETERMINE THE MAXIMUM LENGTH OF ONE COLUMN OF AN ELEMENT MATRIX.
C
 1030 NHDR = 2
      IF (LAST) NHDR = 5
      MAXGPE = 0
      LOW  = Z(IDICT)
      NGPS = 0
C
C     READ AND WRITE HEADER FOR RECORD (SIL, DOF, ETC.)
C
 1032 CALL READ (*1110,*9137,SCRIN,HDR,2,0,NREAD)
      CALL WRITE (SCROUT,HDR,NHDR,0)
      GPEWDS = NHDR
      NGPS   = NGPS + 1
C
C     READ FIRST WORD  OF ENTRY ON GPECT. TEST FOR DICT ALREADY ATTACHED
C
 1035 CALL READ (*9138,*1100,SCRIN,BUF,1,0,NREAD)
      IF (IABS(BUF(1)) .GT. LBUF) GO TO 9002
      IF (BUF(1) .LT. 0) GO TO 1040
C
C     DICTIONARY ALREADY ATTACHED---READ REMAINDER OF ENTRY AND
C     COPY ENTRY TO GPECTX.
C
      CALL READ (*9139,*9140,SCRIN,BUF(2),BUF(1),0,NREAD)
      N = BUF(1) + 1
 1038 CALL WRITE (SCROUT,BUF,N,0)
      GPEWDS = GPEWDS + N
      GO TO 1035
C
C     DICTIONARY NOT ATTACHED---TRY TO LOCATE DICT IN CORE
C
 1040 M = -BUF(1)
      CALL READ (*9141,*9142,SCRIN,BUF(2),M,0,NREAD)
      IF (BUF(2) .LT.  LOW) GO TO 1044
      IF (BUF(2) .GT. HIGH) GO TO 1042
      KELEM = 4*BUF(3) - 3
      IF (Z(KELEM) .EQ. 0) GO TO 1035
      L     = Z(KELEM  )
      N     = Z(KELEM+1)
      LDICT = Z(KELEM+2)
      NLOCS = Z(KELEM+3)
      CALL BISLOC (*1035,BUF(2),Z(L),LDICT,N,K)
      K = K + L - 1
      IF (K4FLAG.NE.0 .AND. Z(K+4).EQ.0) GO TO 1035
      GO TO 1050
 1042 IF (LAST) GO TO 1044
      N = M + 1
      GO TO 1038
 1044 CONTINUE
      GO TO 1035
C
C     DICTIONARY LOCATED---WRITE OUT COMPLETED ENTRY ON GPECTX
C         0             NO. OF WORDS IN ENTRY (NOT INCL THIS WORD)
C       1 - 5           ELEM ID, F, N, C, GE
C         6             LOC OF ELEMENT MATRIX COLUMNS FOR CURRENT PIVOT
C       7 - 6+NGRIDS    SIL-S OF CONNECTED GRID POINTS
C
 1050 NGRIDS = M - 2
      INDX   = K + MDICT - 1
      IF (NLOCS .EQ. 1) GO TO 1056
      IF (NGRIDS .GT. NLOCS) GO TO 9004
      KK = 1
      DO 1053 I = 1,NGRIDS
      IF (KK .EQ. 1) GO TO 10525
C
C     CHECK FOR DUPLICATE SILS - E.G. HBDY ELEMENT WITH AMBIENT PTS
C
10522 IF (BUF(KK+3) .NE. BUF(KK+2)) GO TO 10525
      KK = KK + 1
      GO TO 10522
10525 IF (BUF(KK+3) .NE. HDR(1)) GO TO 10530
C
C     SIL THAT MATCHES THE PIVOT FOUND.  NOW INSURE THAT THIS SIL
C     HAS NOT BEEN ALREADY CONNECTED DUE TO A PREVIOUS ENTRY IN THIS
C     GPECT RECORD.  (CAUSED BY DUPLICATE IDS I.E. CELAS2)
C
C     GINO-LOC WILL NOW BE ZERO IF THAT IS TRUE
C
      INDX = K + MDICT + I - 2
      IF (Z(INDX)) 1054,10530,1054
10530 KK = KK + 1
 1053 CONTINUE
      GO TO 1035
 1054 Z(K+MDICT-1) = Z(INDX)
      IF (Z(K+1) .NE. 2) GO TO 1056
      BUF(4) = BUF(I+3)
      NGRIDS = 1
 1056 IF (LDICT-NLOCS+1 .NE. MDICT) GO TO 9010
      N = MDICT + NGRIDS
      CALL WRITE (SCROUT,N,1,0)
      CALL WRITE (SCROUT,Z(K),MDICT,0)
      MAXBLK = MAX0(Z(INDX)/KSFT,MAXBLK)
C
C     ZERO GINO-LOC AS HAVING BEEN USED NOW.
C
      Z(INDX) = 0
      CALL WRITE (SCROUT,BUF(4),NGRIDS,0)
      MAXN   = MAX0(MAXN,Z(K+2))
      GPEWDS = GPEWDS + N + 1
      GO TO 1035
C
C     HERE ON END-OF-RECORD ON GPECT
C
 1100 CALL WRITE (SCROUT,0,0,1)
      MAXGPE = MAX0(MAXGPE,GPEWDS)
      GO TO 1032
C
C     HERE ON END-OF-FILE ON GPECT---TEST FOR COMPLETION OF GPECTX
C
 1110 CALL CLOSE (SCRIN ,CLSREW)
      CALL CLOSE (SCROUT,CLSREW)
      IF (NGPS .NE. NSIL) GO TO 9024
      IF (LAST) GO TO 1200
C
C     GPECTX NOT COMPLETE---SWITCH FILES AND MAKE ANOTHER PASS
C
      IF (SCRIN .EQ. GPECT) SCRIN = SCR2
      K = SCRIN
      SCRIN  = SCROUT
      SCROUT = K
      CALL GOPEN (SCRIN ,Z(BUF1),RDREW )
      CALL GOPEN (SCROUT,Z(BUF2),WRTREW)
      L = IDICT
      LDICT = Z(IELEM+2)
      NLOCS = Z(IELEM+3)
      DO 1114 I = 1,IDICT
 1114 Z(I) = 0
      LAST = .TRUE.
      Z(IELEM  ) = IDICT
      Z(IELEM+2) = LDICT
      Z(IELEM+3) = NLOCS
      GO TO 1016
C
C     HERE WE GO NOW FOR THE ASSEMBLY PHASE---PREPARE BY ALLOCATING
C     STORAGE FOR ONE ELEMENT MATRIX COLUMN AND ITS ROW POSITIONS
C
 1200 IROWP  = PREC*MAXN + 1
      IGPX   = IROWP + MAXN
      FIRST  = .TRUE.
      GPECTX = SCROUT
      MCB(1) = XGG
      MCB(4) = 6
      MCB(5) = PREC
      MCB(6) = 0
      MCB(7) = 0
      LAST   = .FALSE.
      NREC   = 0
      MAXNPR = MAXN*PREC
      OPENR  = RDREW
      OPENW  = WRTREW
      OLDCOD = 0
      ITAB   = BUF1 - MAXBLK
      NTAB   = BUF1 - 1
      IF (ITAB .LT. IGPX) GO TO 9011
C
C     BEGIN A PASS - OPEN GPECTX
C
 1210 IPVT = IGPX
      JJ   = ITAB - 3
      DO 1212 INDX = ITAB,NTAB
      Z(INDX) = 0
 1212 CONTINUE
      CALL GOPEN (GPECTX,Z(BUF1),OPENR)
C
C     READ A RECORD FROM GPECTX INTO CORE
C
 1220 IF (IVPT+MAXGPE.GE.JJ .OR. IPVT.GT.MAXIPV) GO TO 1304
      CALL READ (*9144,*1222,GPECTX,Z(IVPT),MAXGPE+1,1,NREAD)
      GO TO 9006
 1222 ICOL = IPVT + NREAD
      NREC = NREC + 1
C
C     MAKE A PASS THROUGH EACH ELEMENT CONNECTED TO THE PIVOT---FORM THE
C     UNION OF ALL CODE WORDS AND STORE ELEMENT POINTERS IN LIST AT THE
C     END OF OPEN CORE
C
      PPOINT = LSHIFT(IPVT,KONS)
      II     = IPVT + 5
      UNION  = 0
      Z(IPVT+2) = 0
      Z(IPVT+3) = 0
      Z(IPVT+4) = IPVT
      GO TO 1234
 1231 IF (Z(II) .LT. 0) GO TO 9007
      KK = II - IPVT
      IF (KK .GT. MAXII) GO TO 9008
      IF (JJ .LE. ICOL ) GO TO 1300
      Z(JJ  ) = Z(II+MDICT)
      Z(JJ+1) = ORF(PPOINT,KK)
      Z(JJ+2) = 0
      INDX    = ITAB + Z(JJ)/KSFT - 1
      IF (INDX .GT. NTAB) GO TO 9016
      IF (Z(INDX) .NE. 0) GO TO 1236
      Z(INDX) = ORF(LSHIFT(ITAB-JJ,IHALF),ITAB-JJ)
      GO TO 1237
 1236 JJLAST = ITAB - ANDF(Z(INDX),JHALF)
      Z(JJLAST+2) = JJ
      Z(INDX) = ORF(ANDF(Z(INDX),MASK),ITAB-JJ)
 1237 JJ = JJ - 3
      UNION = ORF(UNION,Z(II+4))
      II = II + Z(II) + 1
 1234 IF (II .LT. ICOL) GO TO 1231
      IF (II .NE. ICOL) GO TO 9022
C
C     FORM THE LIST OF NON-NULL COLUMNS TO BE BUILT FOR THIS PIVOT
C
      IF (UNION .EQ. 0) GO TO 1280
      IF (UNION .EQ. OLDCOD) GO TO 1243
      CALL DECODE (UNION,SCALAS,NSCA)
      OLDCOD = UNION
 1243 Z(IPVT+2) = ICOL
      IF (ICOL+NSCA .GE. JJ) GO TO 1300
      II = ICOL
      DO 1244 L = 1,NSCA
      Z(II) = Z(IPVT) + SCALAS(L)
      II = II + 1
 1244 CONTINUE
      IROW = II
C
C     NOW MAKE A PASS AGAIN THROUGH EACH ELEMENT CONNECTED TO CURRENT
C     PIVOT AND FORM A LIST OF UNIQUE ROW INDICES.
C
      II = IPVT + 5
 1252 L1 = II + MDICT + 1
      L2 = II + Z(II)
      IF (OLDCOD .EQ. Z(II+4)) GO TO 1253
      ICODE = Z(II+4)
      CALL DECODE (ICODE,SCALAS,NSCA)
      OLDCOD = Z(II+4)
 1253 CONTINUE
      KK = IROW
      IF (II .NE. IPVT+5) GO TO 1258
      DO 1256 L = L1,L2
C
C     IGNORE DUPLICATE IDS AS IN SOME CELAS2 ELEMENTS ETC.
C
      IF (L.GT.L1 .AND. Z(L).EQ.Z(L-1)) GO TO 1256
      DO 1254 I = 1,NSCA
      Z(KK) = Z(L) + SCALAS(I)
      KK = KK + 1
      IF (KK .GE. JJ) GO TO 1300
 1254 CONTINUE
 1256 CONTINUE
      NROW   = KK - 1
      NBRWDS = KK - IROW
      GO TO 1269
 1258 J = IROWP
      DO 1264 L = L1,L2
C
C     IGNORE DUPLICATE IDS AS IN SOME CELAS2 ELEMENTS ETC.
C
      IF (L.GT.L1 .AND. Z(L).EQ.Z(L-1)) GO TO 1264
      DO 1262 I = 1,NSCA
      Z(J) = Z(L) + SCALAS(I)
      J = J + 1
 1262 CONTINUE
 1264 CONTINUE
      IF (J .GT. IGPX) GO TO 9023
      M = J - IROWP
      IF (IROW+NBRWDS+M .GE. JJ) GO TO 1300
      CALL MRGE (Z(IROW),NBRWDS,Z(IROWP),M)
      NROW = IROW + NBRWDS - 1
      IF (NROW .GE. JJ) GO TO 1300
 1269 II = L2 + 1
      IF (II .LT. ICOL) GO TO 1252
      Z(IPVT+3) = IROW
C
C     NOW ALLOCATE STORAGE FOR COLUMNS OF XGG ASSOCIATED WITH THIS PIVOT
C
      IMAT   = NROW + 1
      NBRCOL = IROW - ICOL
      NBRROW = IMAT - IROW
      NBRWDS = PREC*NBRCOL*NBRROW
      NMAT   = IMAT + NBRWDS - 1
      IF (NMAT .GE. JJ) GO TO 1300
      DO 1272 I = IMAT,NMAT
      Z(I) = 0
 1272 CONTINUE
      Z(IPVT+4) = IMAT
      II = NMAT + 1
C
C     ADVANCE POINTER AND TRY TO GET ANOTHER PIVOT ALLOCATED
C
 1280 ILIST = JJ + 3
      NPVT  = IPVT
      IF (NREC .EQ. NGPS) GO TO 1310
      IPVT = II
      GO TO 1220
C
C     HERE WHEN STORAGE EXCEEDED DURING PROCESSING OF A PIVOT.
C     IF FIRST PIVOT ON PASS, INSUFFICIENT CORE FOR MODULE.
C     OTHERWISE, BACKSPACE GPECTX AND PREPARE TO PROCESS ALL
C     PIVOTS IN CORE WHICH HAVE BEEN COMPLETELY ALLOCATED.
C
 1300 IF (IPVT .EQ. IGPX) CALL MESAGE (-8,0,MA1H)
      CALL BCKREC (GPECTX)
      NREC = NREC - 1
 1304 OP   = CLS
      IF (IPVT .EQ. IGPX) CALL MESAGE (-8,0,MA1H)
      GO TO 1320
C
C     HERE WHEN LAST PIVOT POINT HAS BEEN READ AND ALLOCATED
C
 1310 LAST = .TRUE.
      OP   = CLSREW
C
C     CLOSE GPECTX. OPEN XBLOCK.
C
 1320 CALL CLOSE (GPECTX,OP)
      NWDS = BUF1 - ILIST
      IF (NWDS .LE. 0) GO TO 1402
      CALL GOPEN (XBLOCK,Z(BUF1),RDREW)
      OLDCOD = 0
C
C     PASS THE LIST OF ELEMENT MATRIX POINTERS. EACH ENTRY POINTS TO THE
C     PIVOT POINT AND ELEMENT DICTIONARY IN CORE AND TO THE POSITION IN
C     THE XBLOCK FILE CONTAINING THE ASSOCIATED ELEMENT MATRIX COLUMNS.
C     WHEN PROCESSING OF ALL ENTRIES IS COMPLETE, COLUMNS OF XGG NOW IN
C     CORE ARE COMPLETE.
C
      DO 1398 INDX = ITAB,NTAB
      IF (Z(INDX) .EQ. 0) GO TO 1398
      JJ = ITAB - RSHIFT(Z(INDX),IHALF)
      IF (JJ .LT. ILIST) GO TO 1398
 1330 CONTINUE
      CALL FILPOS (XBLOCK,Z(JJ))
      IPVT  = RSHIFT(Z(JJ+1),KONS)
      IF (IPVT .GT. NPVT) GO TO 9019
      IELEM = IPVT + ANDF(Z(JJ+1),MAXII)
      ICOL  = Z(IPVT+2)
      IROW  = Z(IPVT+3)
      IMAT  = Z(IPVT+4)
C
C     DECODE CODE WORD FOR ELEMENT. FORM LIST OF ROW INDICES DESCRIBING
C     TERMS IN THE ELEMENT MATRIX COLUMN. THEN CONVERT THESE INDICES TO
C     RELATIVE ADDRESSES IN XGG COLUMN IN CORE (USE LIST OF ROW INDICES
C     FOR XGG COLUMN TO DO THIS).
C
      IF (Z(IELEM+4) .EQ. OLDCOD) GO TO 1341
      ICODE = Z(IELEM+4)
      CALL DECODE (ICODE,SCALAS,NSCA)
      OLDCOD = Z(IELEM+4)
 1341 L1 = IELEM + MDICT + 1
      L2 = IELEM + Z(IELEM)
      K  = IROWP
      DO 1344 L = L1,L2
C
C     IGNORE DUPLICATE IDS AS IN SOME CELAS2 ELEMENTS ETC.
C
      IF (L.GT.L1 .AND. Z(L).EQ.Z(L-1)) GO TO 1344
      DO 1342 I = 1,NSCA
      Z(K) = Z(L) + SCALAS(I)
      K = K + 1
 1342 CONTINUE
 1344 CONTINUE
      NROWP = K - 1
      IF (NROWP.GE. IGPX) GO TO 9012
      NROW = IMAT - 1
      ID   = Z(IROWP)
      CALL BISLOC (*9020,ID,Z(IROW),1,(IMAT-IROW),IROWX)
      IROWX = IROW + IROWX - 1
      DO 1348 K = IROWP,NROWP
      DO 1346 I = IROWX,NROW
      IF (Z(K) .EQ. Z(I)) GO TO 1347
 1346 CONTINUE
      GO TO 9013
 1347 Z(K)  = (I-IROW)*PREC
      IROWX = I + 1
 1348 CONTINUE
      NBRROW = NROWP - IROWP + 1
C
C     PREPARE TO READ EACH COLUMN OF ELEMENT MATRIX
C
      NCOL  = IROW - 1
      ICOLX = ICOL
      NBRWDS= Z(IELEM+3)*PREC
      IF (Z(IELEM+2) .EQ.  2) NBRWDS = PREC
      IF (NBRWDS .GT. MAXNPR) GO TO 9014
      DO 1396 I = 1,NSCA
C
C     READ A COLUMN OF THE ELEMENT MATRIX AND DETERMINE ADDRESS
C     OF FIRST WORD OF ASSOCIATED COLUMN OF XGG IN CORE.
C
      CALL READ (*9145,*9146,XBLOCK,Z,NBRWDS,0,NREAD)
      COL = Z(IPVT) + SCALAS(I)
      DO 1362 K = ICOLX,NCOL
      IF (COL .EQ. Z(K)) GO TO 1364
 1362 CONTINUE
      GO TO 9015
 1364 IMATN = IMAT + (IMAT-IROW)*(K-ICOL)*PREC
      ICOLX = K + 1
      IF (Z(IELEM+2) .NE. 2) GO TO 1365
C
C     ELEMENT MATRIX IS DIAGONAL
C
      NBRROW = 1
      Z(IROWP) = Z(IROWP+I-1)
C
C     IF DAMPING OR WEIGHT MASS FACTOR (OR BOTH) PRESENT, MULTIPLY
C     EACH TERM IN THE ELEMENT MATRIX COLUMN BY THE FACTOR.
C
 1365 GO TO KFACT, (1370,13651,13652,13653)
13651 FACTOR = Y(IELEM+5)
      GO TO 13654
13652 FACTOR = WTMASS
      GO TO 13654
13653 FACTOR = Y(IELEM+5)*WTMASS
13654 CONTINUE
      IF (PREC .EQ. 2) GO TO 1367
      DO 1366 K = 1,NBRWDS
C
C     FOR PIEZOELECTRIC COUPLED PROBLEMS, ANY STRUCTURAL DAMPING COEFF.
C     SHOULD MULTIPLY ONLY THE UNCOUPLED STRUCTURAL TERMS. SO, SKIP
C     EVERY 4TH TERM IN A COLUMN AND SKIP EVERY 4TH COLUMN
C
      IF (PIEZ .AND. (I.EQ.NSCA .OR. MOD(K,4).EQ.0)) Y(K) = 0.
      Y(K) = FACTOR*Y(K)
 1366 CONTINUE
      GO TO 1371
 1367 M = NBRWDS/2
      DO 1368 K = 1,M
      IF (PIEZ .AND. (I.EQ.NSCA.OR.MOD(K,4).EQ.0)) ZD(K) = 0.D0
      ZD(K) = FACTOR*ZD(K)
 1368 CONTINUE
      GO TO 1374
C
C     NOW ADD TERMS OF THE ELEMENT MATRIX INTO XGG
C
 1370 IF (PREC .EQ. 2) GO TO 1374
C
C     DO ARITHMETIC IN SINGLE PRECISION
C
 1371 DO 1372 K = 1,NBRROW
      J = IMATN + Z(IROWP+K-1)
      Y(J) = Y(J) + Y(K)
 1372 CONTINUE
      GO TO 1396
C
C     DO ARITHMETIC IN DOUBLE PRECISION
C
 1374 DO 1376 K = 1,NBRROW
      J = IMATN + Z(IROWP+K-1)
C
C     XS(1) = Y(J  )
C     XS(2) = Y(J+1)
C     XD(1) = XD(1) + ZD(K)
C     Y(J  )= XS(1)
C     Y(J+1)= XS(2)
C
C     SOME MACHINES, SUCH AS DEC/ALPHA, USE 64-BIT REGISTER TO PERFORM
C     REAL*4 OPERATION AND SAVE THE RESULT BACK TO 32-BIT WORD. USING
C     XS AND Y, BOTH S.P. REAL, TO PICK UP D.P. DATA IN ZD ABOVE MAY GET
C     INTO TROUBLE. THE CODES BELOW USING IS AND Z, BOTH INTEGERS, WORK
C
      IS(1) = Z(J  )
      IS(2) = Z(J+1)
      XD(1) = XD(1) + ZD(K)
      Z(J  )= IS(1)
      Z(J+1)= IS(2)
C
 1376 CONTINUE
      GO TO 1396
C
C     END OF DO LOOPS
C
 1396 CONTINUE
      JJ = Z(JJ+2)
      IF (JJ .GE. ILIST) GO TO 1330
 1398 CONTINUE
C
C     ALL COLUMNS OF XGG IN CORE ARE NOW COMPLETE - SEND THEM
C     OUT TO THE XGG DATA BLOCK VIA THE BLDPK ROUTINE.
C
      CALL CLOSE (XBLOCK,CLSREW)
 1402 CALL GOPEN (XGG,Z(BUF1),OPENW)
      IPVT = IGPX
C
C     PREPARE TO PACK ALL COLUMNS FOR CURRENT PIVOT
C
 1410 COL1 = Z(IPVT)
      COLN = COL1 + Z(IPVT+1) - 1
      ICOL = Z(IPVT+2)
      IROW = Z(IPVT+3)
      IMAT = Z(IPVT+4)
      NCOL = IROW - 1
      NROW = IMAT - 1
      JNEXT  = ICOL
      NXTCOL = Z(JNEXT)
      II = IMAT
      DO 1430 COL = COL1,COLN
C
C     INITIATE PACKING BY CALLING BLDPK. TEST FOR NULL COL.
C
      CALL BLDPK (PREC,PREC,XGG,0,0)
      IF (ICOL .EQ. 0) GO TO 1428
      IF (COL .LT. NXTCOL) GO TO 1428
      JNEXT  = JNEXT + 1
      NXTCOL = Z(JNEXT)
      IF (JNEXT .GT. NCOL) NXTCOL = COLN + 1
      IF (PREC .EQ. 2) GO TO 1426
C
C     NON-NULL COLUMN - SEND THE TERMS OUT VIA ZBLPKI
C
C     SINGLE PRECISION
C
      DO 1424 K = IROW,NROW
      IQ   = Z(K)
      Q(1) = Z(II)
      CALL ZBLPKI
      II = II + 1
 1424 CONTINUE
      GO TO 1428
C
C     DOUBLE PRECISION
C
 1426 DO 1427 K = IROW,NROW
      IQ   = Z(K)
      Q(1) = Z(II  )
      Q(2) = Z(II+1)
      CALL ZBLPKI
      II = II + 2
 1427 CONTINUE
C
C     TERMINATE COLUMN BY CALLING BLDPKN
C
 1428 CALL BLDPKN (XGG,0,MCB)
 1430 CONTINUE
C
C     LOGIC TEST TO MAKE SURE POINTERS ENDED CORRECTLY
C
      NBRWDS = 5
      IF (ICOL .EQ. 0) GO TO 1440
      NBRWDS = (IMAT-IROW)*(IROW-ICOL)*PREC
      IF (II-IMAT.NE.NBRWDS .AND. Z(IPVT+1).NE.1) GO TO 9017
C
C     TEST FOR LAST PIVOT
C
 1440 IF (IPVT .GE. NPVT) GO TO 1450
      IPVT = IMAT + NBRWDS
      GO TO 1410
C
C     CLOSE XGG
C
 1450 CALL CLOSE (XGG,OP)
C
C     TEST FOR LAST PASS
C
      IF (LAST) GO TO 1490
      FIRST = .FALSE.
      OPENR = RD
      OPENW = WRT
      GO TO 1210
C
C     XGG NOW COMPLETE - WRITE ITS TRAILER.
C
 1490 MCB(3) = MCB(2)
      IF (MCB(2) .NE. Z(NPVT)+Z(NPVT+1)-1) GO TO 9018
      CALL WRTTRL (MCB)
      RETURN
C
C     FATAL ERROR MESSAGES
C
 9001 MSG(1) = 1016
      GO TO 9098
 9002 MSG(1) = 1035
      GO TO 9098
 9004 MSG(1) = 1052
      GO TO 9098
 9006 MSG(1) = 1220
      GO TO 9098
 9007 MSG(1) = 1231
      GO TO 9098
 9008 MSG(1) = 1232
      GO TO 9098
 9010 MSG(1) = 1056
      GO TO 9098
 9011 MSG(1) = 1202
      GO TO 9098
 9012 MSG(1) = 1344
      GO TO 9098
 9013 MSG(1) = 1346
      GO TO 9098
 9014 MSG(1) = 1352
      GO TO 9098
 9015 MSG(1) = 1362
      GO TO 9098
 9016 MSG(1) = 1238
      GO TO 9098
 9017 MSG(1) = 1432
      GO TO 9098
 9018 MSG(1) = 1490
      GO TO 9098
 9019 MSG(1) = 1332
      GO TO 9098
 9020 MSG(1) = 1345
      GO TO 9098
 9022 MSG(1) = 1235
      GO TO 9098
 9023 MSG(1) = 1264
      GO TO 9098
 9024 MSG(1) = 1110
      GO TO 9098
 9098 WRITE  (OUTPUT,9099) SFM,MSG(1)
 9099 FORMAT (A25,' 3102, LOGIC ERROR EMA - ',I4)
 9097 CONTINUE
      WRITE  (OUTPUT,9091)
 9091 FORMAT (/,' *** CONTENTS OF /MA1XX/')
      WRITE  (OUTPUT,9092) IHQ
 9092 FORMAT (5X,10I10)
      WRITE  (OUTPUT,9093)
 9093 FORMAT (/,' FIRST 250 WORDS OF OPEN CORE')
      J = 250
      WRITE (OUTPUT,9092) (Z(I),I=1,J)
      CALL MESAGE (-61,0,0)
 9100 CALL FNAME (MSG(3),MSG(1))
      WRITE  (OUTPUT,9101) SFM,(MSG(I),I=1,4)
 9101 FORMAT (A25,' 3001, ATTEMPT TO OPEN DATA SET ',2A4,', FILE (',I4,
     1    ') IN SUBROUTINE EMA (',I4,') WHICH WAS NOT DEFINED IN FIST.')
      GO TO 9097
 9110 CALL FNAME (MSG(3),MSG(1))
      WRITE  (OUTPUT,9111) SFM,(MSG(I),I=1,4)
 9111 FORMAT (A25,' 3002, EOF ENCOUNTERED WHILE READING DATA SET ',2A4,
     1       ', (FILE',I5,') IN SUBROUTINE EMA (',I4,1H))
      GO TO 9097
 9120 CALL FNAME (MSG(3),MSG(1))
      WRITE  (OUTPUT,9121) SFM,(MSG(I),I=1,4)
 9121 FORMAT (A25,' 3003, ATTEMPT TO READ PAST END OF LOGICAL RECORD IN'
     1,     ' DATA SET ',2A4,' (FILE',I5,') IN SUBROUTINE EMA (',I4,1H))
      GO TO 9097
 9131 MSG(3) = GPECT
      MSG(4) = 1002
      GO TO 9100
 9132 MSG(3) = XBLOCK
      MSG(4) = 1001
      GO TO 9100
 9134 MSG(3) = SCROUT
      MSG(4) = 1005
      GO TO 9100
 9135 MSG(3) = XEMD
      MSG(4) = 1014
      GO TO 9120
 9136 MSG(3) = XEMD
      MSG(4) = 1017
      GO TO 9110
 9137 MSG(3) = SCRIN
      MSG(4) = 1032
      GO TO 9120
 9138 MSG(3) = SCRIN
      MSG(4) = 1035
      GO TO 9110
 9139 MSG(3) = SCRIN
      MSG(4) = 1036
      GO TO 9110
 9140 MSG(3) = SCRIN
      MSG(4) = 1036
      GO TO 9120
 9141 MSG(3) = SCRIN
      MSG(4) = 1040
      GO TO 9110
 9142 MSG(3) = SCRIN
      MSG(4) = 1040
      GO TO 9120
 9144 MSG(3) = GPECTX
      MSG(4) = 1221
      GO TO 9110
 9145 MSG(3) = XBLOCK
      MSG(4) = 1360
      GO TO 9110
 9146 MSG(3) = XBLOCK
      MSG(4) = 1360
      GO TO 9120
      END
