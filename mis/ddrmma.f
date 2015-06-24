      SUBROUTINE DDRMMA( SETUP )
C*****
C  UNPACKS DATA FROM A TRANSIENT OR FREQUENCY RESPONSE SOLUTION
C  COLUMN AS REQUIRED TO FORM ONE OFP OUTPUT LINE ENTRY.
C
C  BEFORE CALLING FOR ENTRY CONSTRUCTION ONE SETUP CALL IS REQUIRED
C  FOR EACH COLUMN. (SETUP = .TRUE.)
C*****
      REAL     LAMBDA   ,RBUFA(75),RBUFB(75)
C
      INTEGER BUF(150), BUFA(75), BUFB(75), ELWORK(300), PHASE, COMPLX
      INTEGER SCRT,BUFF,FILE,OUTFIL,SETID,DHSIZE,ENTRYS,FILNAM,PASSES
      INTEGER SETS,DEVICE,FORM,UVSOL
      INTEGER TYPOUT
      INTEGER SAVDAT,SAVPOS,BUFSAV
C
      LOGICAL  SETUP    ,TRNSNT   ,SORT2    ,COL1     ,FRSTID
      LOGICAL  LMINOR
C
      COMMON/STDATA/    LMINOR    ,NSTXTR   ,NPOS     ,SAVDAT(75)
     1                  ,SAVPOS(25)         ,BUFSAV(10)
      COMMON/DDRMC1/    IDREC(146),BUFF(6)  ,PASSES   ,OUTFIL   ,JFILE
     1                  ,MCB(7)   ,ENTRYS   ,SETS(5,3),INFILE   ,LAMBDA
     2                  ,FILE     ,SORT2    ,COL1     ,FRSTID   ,NCORE
     3                  ,NSOLS    ,DHSIZE   ,FILNAM(2),RBUF(150),IDOUT
     4                  ,ICC      ,NCC      ,ILIST    ,NLIST    ,NWDS
     5                  ,SETID    ,TRNSNT   ,I1       ,I2       ,PHASE
     6                  ,ITYPE1   ,ITYPE2   ,NPTSF    ,LSF      ,NWDSF
     7                  ,SCRT(7)  ,IERROR   ,ITEMP    ,DEVICE   ,FORM
     8                  ,ISTLST   ,LSTLST   ,UVSOL    ,NLAMBS   ,NWORDS
     9                  ,OMEGA    ,IPASS
      COMMON/CLSTRS/    COMPLX(1)
      COMMON/ZNTPKX/ A(4), IROW, IEOL, IEOR
C
      EQUIVALENCE(BUF(1),RBUF(1),BUFA(1),RBUFA(1))
     1          ,(RBUFB(1),BUFB(1),BUF(76))
C*****
C  PERFORM SOLUTION COLUMN SETUP WHEN SETUP = .TRUE.
C*****
      IF( .NOT. SETUP ) GO TO 10
      TYPOUT = 3
      IF( TRNSNT ) TYPOUT = 1
      ICOMP = 1
      CALL INTPK(*5,SCRT(6),0,TYPOUT,0)
      CALL ZNTPKI
      RETURN
    5 IROW = 0
      RETURN
C*****
C  FILL BUFFER WITH REAL AND OR COMPLEX VALUES.
C*****
   10 K = I1 - 1
      DO 20 I = 1,K
      BUFB(I) = BUFA(I)
   20 CONTINUE
      DO 70 I = I1,I2
      IF( ICOMP .EQ. IROW ) GO TO 30
      RBUFA(I) = 0.0
      RBUFB(I) = 0.0
      GO TO 60
C
C     NON-ZERO COMPONENT AVAILABLE.
C
   30 IF( .NOT. TRNSNT ) GO TO (31,32,33), IPASS
C
C     TRANSIENT RESPONSE
C
      RBUFA(I) = A(1)
      IF( IEOL ) 40,40,50
C
C     FREQUENCY RESPONSE FOR DISPLACEMENTS OR SPCFS PASS
C
   31 RBUFA(I) = A(1)
      RBUFB(I) = A(2)
      IF( IEOL ) 40,40,50
C
C     FREQUENCY RESPONSE VELOCITYS PASS
C
   32 RBUFA(I) = -OMEGA * A(2)
      RBUFB(I) =  OMEGA * A(1)
      IF( IEOL ) 40,40,50
C
C     FREQUENCY RESPONSE ACCELERATIONS PASS
C
   33 RBUFA(I) = OMEGA * A(1)
      RBUFB(I) = OMEGA * A(2)
      IF( IEOL ) 40,40,50
   40 CALL ZNTPKI
      GO TO 60
C
   50 IROW = 0
C
   60 ICOMP = ICOMP + 1
C
   70 CONTINUE
C*****
C  IF TRANSIENT (REAL) THEN RETURN. FOR FREQUENCY (COMPLEX) COMBINE DATA
C  FOR OUTPUT AND CONVERT TO MAGNITUDE PHASE IF NECESSARY.
C
C  BUFA CONTAINS THE REAL PART
C  BUFB CONTAINS THE IMAGINARY PART
C*****
      IF (TRNSNT) GO TO 81
      IF (ITYPE1 .EQ. 4)  GO TO 90
      IF (ITYPE1 .EQ. 5)  GO TO 81
C
C     POINT DATA
C
      DO 80 K = 1,6
      IF( FORM .EQ. 3 ) CALL MAGPHA( BUFA(K+2), BUFB(K+2) )
      BUFA(K+8) = BUFB(K+2)
   80 CONTINUE
      NWDSF = 14
      RETURN
C
C     ELEMENT STRESS OR FORCE DATA
C
   81 IF (LMINOR)  GO TO 90
      DO 82 K=1,NSTXTR
      J=SAVPOS(NPOS+K-1)
   82 BUF(J) = BUFSAV(K)
   90 IF (TRNSNT) RETURN
      IOUT = 0
      I = NPTSF
  100 NPT = COMPLX(I)
      IF( NPT ) 110,140,130
  110 NPT = -NPT
      IF( FORM .NE. 3 ) GO TO 130
C
C     COMPUTE MAGNITUDE PHASE
C
      CALL MAGPHA( BUFA(NPT), BUFB(NPT) )
  120 IOUT = IOUT + 1
      ELWORK(IOUT) = BUFA(NPT)
      I = I + 1
      GO TO 100
  130 IF( NPT .LE. LSF ) GO TO 120
      NPT = NPT - LSF
      IOUT = IOUT + 1
      ELWORK(IOUT) = BUFB(NPT)
      I = I + 1
      GO TO 100
C
C     MOVE OUTPUT DATA
C
  140 DO 150 I = 1,IOUT
      BUF(I) = ELWORK(I)
  150 CONTINUE
      NWDSF = IOUT
      RETURN
      END
