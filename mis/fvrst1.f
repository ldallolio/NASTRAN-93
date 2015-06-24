      SUBROUTINE FVRST1        
C        
C        
C    1. ENTRY POINT - FVRST1        
C        
C    2. PURPOSE -  THIS MODULE IS USED FOR FORCED VIBRATION RESPONSE    
C                  ANALYSIS OF ROTATING CYCLIC STRUCTURES.        
C                  FVRSTR1 GENERATES DATA BLOCKS FRLX, B1GG, M1GG,      
C                  M2GG, BASEXG AND PDZERO. IT ALSO COMPUTES PARAMETERS 
C                  FKMAX AND NOBASEX.        
C        
C    3. DMAP CALLING SEQUENCE -        
C        
C         FVRSTR1  CASECC,BGPDT,CSTM,DIT,FRL,MGG,, / FRLX,B1GG,M1GG,    
C                  M2GG,BASEXG,PDZERO,, /V,N,NOMGG/V,Y,CYCIO/V,Y,NSEGS/ 
C                  V,Y,KMAX/V,N,FKMAX/V,Y,BXTID=-1/V,Y,BXPTID=-1/       
C                  V,Y,BYTID=-1/V,Y,BYPTID=-1/V,Y,BZTID=-1/        
C                  V,Y,BZPTID=-1/V,N,NOBASEX/V,N,NOFREQ/V,N,OMEGA  $    
C        
C    4. INPUT DATA BLOCKS -        
C        
C         CASECC - CASE CONTROL        
C         BGPDT  - BASIC GRID POINT DEFINITION TABLE.        
C         CSTM   - COORDINATE SYSTEM TRANSFORMATION MATRICES.        
C         DIT    - DIRECT INPUT TABLES.        
C         FRL    - FREQUENCY RESPONSE LIST. (FREQUENCIES IN RADIANS)    
C         MGG    - GLOBAL MASS MATRIX (G-SET).        
C        
C         NOTE   - (1) ALL INPUT DATA BLOCKS CAN BE PURGED IF ONLY      
C                      PARAMETERS FKMAX AND NOBASEX ARE TO BE COMPUTED. 
C                  (2) CASECC, DIT AND FRL CAN BE PURGED IF FRLX AND    
C                      BASEXG ARE PURGED.        
C        
C    5. OUTPUT DATA BLOCKS -        
C        
C         FRLX    - FREQUENCY RESPONSE LIST (MODIFIED).        
C         B1GG    - CORIOLIS ACCELERATION COEFFICIENT MATRIX (G-SET).   
C         M1GG    - CENTRIPETAL ACCELERATION COEFFICIENT MATRIX (G-SET).
C         M2GG    - BASE ACCELERATION COEFFICIENT MATRIX (G-SET).       
C         BASEXG  - BASE ACCELERATION MATRIX (G-SET).        
C         PDZERO  - LOAD MODIFICATION MATRIX IN BASE ACCELERATION       
C                   PROBLEMS.        
C        
C         NOTE    - (1) ALL OUTPUT DATA BLOCKS CAN BE PURGED IF        
C                       PARAMETER NOMGG =-1.        
C                   (2) B1GG AND M1GG CAN BE PURGED IF NOMGG =-1 OR     
C                       IF OMEGA = 0.0.        
C                   (3) FRLX AND PDZERO CAN BE PURGED IF OMEGA = 0.0.   
C                   (4) FRLX, PDZERO, M2GG AND BASEXG CAN BE PURGED     
C                       IF NOMGG =-1 OR NOFREQ =-1 OR CYCIO =+1 OR IF   
C                       ALL PARAMETERS BXTID = BXPTID = BYTID =-1.      
C        
C    6. PARAMETERS -        
C        
C        (A) NOMGG   - INPUT-INTEGER-NO DEFAULT.  MASS MATRIX WAS NOT   
C                      GENERATED IF NOMGG =-1.        
C        (B) CYCIO   - INPUT-INTEGER-NO DEFAULT.  THE INTEGER VALUE     
C                      OF THIS PARAMETER SPECIFIES THE FORM OF THE INPUT
C                      AND OUTPUT DATA FOR CYCLIC STRUCTURES. A VALUE   
C                      OF +1 IS USED TO SPECIFY PHYSICAL SEGMENT REPRE- 
C                      SENTATION AND A VALUE OF -1 FOR CYCLIC TRANSFOR- 
C                      MATION REPRESENTATION.        
C        (C) NSEGS   - INPUT-INTEGER-NO DEFAULT.  THE NUMBER OF        
C                      IDENTICAL SEGMENTS IN THE STRUCTURAL MODEL.      
C        (D) KMAX    - INPUT-INTEGER-NO DEFAULT.  THE INTEGER VALUE     
C                      OF THIS PARAMETER SPECIFIES THE MAXIMUM VALUE    
C                      OF THE HARMONIC INDEX.THE MAXIMUM VALUE OF       
C                      KMAX IS NSEGS/2.        
C        (E) FKMAX   - OUTPUT-INTEGER-NO DEFAULT.  FUNCTION OF KMAX.    
C        (F) BXTID   - INPUT -INTEGER-DEFAULTS.  THE VALUES OF THESE    
C        (G) BYTID     PARAMETERS DEFINE THE SET IDENTIFICATION NUMBERS 
C        (H) BZTID     OF THE TABLEDI BULK DATA CARDS WHICH DEFINE THE  
C        (I) BXPTID    COMPONENTS OF THE BASE ACCELERATION VECTOR. THE  
C        (J) BYPTID    TABLES REFERED TO BY BXTID, BYTID AND BZTID      
C        (K) BZPTID    DEFINE MAGNITUDE(LT-2) AND THE TABLES REFERED TO 
C                      BY BXPTID, BYPTID AND BZPTID DEFINE PHASE(DEGREE)
C                      THE DEFAULT VALUES ARE -1 WHICH MEANS THAT THE   
C                      RESPECTIVE TERMS ARE IGNORED.        
C        (L) NOBASEX - OUTPUT-INTEGER-NO DEFAULT.  NOBASEX =-1 IF DATA  
C                      BLOCK BASEXG IS NOT GENERATED.        
C        (M) NOFREQ  - INPUT-INTEGER-NO DEFAULT. NOFREQ =-1 IF FREQUENCY
C                      WAS NOT SELECTED IN THE CASE CONTROL DECK.       
C        (N) OMEGA   - INPUT-REAL-NO DEFAULT.  ROTATIONAL SPEED OF THE  
C                      STRUCTURE IN RADIANS. OMEGA = 2*PI*RPS.        
C        
C    7. METHOD -  SEE FUNCTIONAL MODULE DESCRIPTION.        
C        
C    8. SUBROUTINES - FVRST1 CALLS ROUTINES FVRS1A, FVRS1B, FVRS1C,     
C                     FVRS1D, FVRS1E, GMMATD, PRETRD, TRANSD, PRETAB,   
C                     TAB AND OTHER STANDARD NASTRAN UTILITY ROUTINES.  
C                     GINO ROUTINES.        
C        
C    9. DESIGN REQUIREMENTS -        
C        
C         (1) OPEN CORE IS DEFINED AT /ZZFVR1/.        
C         (2) NO SCRATCH FILES ARE USED.        
C         (3) FVRST1 RESIDES IN LINKNS07        
C         (4) OPEN CORE FOR 5 BUFFERS PLUS 14*NCSTM  PLUS NTYPE*NROW OF 
C             MGG IS REQUIRED.        
C        
C          NOTE - (1) NTYPE = 1 IF MGG IS REAL SP        
C                     NTYPE = 2 IF MGG IS REAL DP        
C        
C   10. DIAGNOSTIC MESSAGES -        
C        
C         THE FOLLOWING MESSAGES MAY BE ISSUED - 3001,3002,3003,3008    
C                                                AND 3031.        
C        
C        
      LOGICAL         MODFRL        
      INTEGER         CASECC,BGPDT,CSTM,DIT,FRL,FRLX,B1GG,BASEXG,PDZERO,
     1                CYCIO,FKMAX,BXTID,BXPTID,BYTID,BYPTID,BZTID,      
     2                BZPTID,ITLIST(13),ITID(6),FRQSET,CASE(14)        
      DOUBLE PRECISION Z,A(3,3),B(3,3),C(3,3),ROW(3),TA(3,3),AVGM,      
     1                DPI,DTWOPI,DRADEG,DDEGRA,D4PISQ        
      DIMENSION       MCBB1(7),MCBM1(7),MCBM2(7),MCB(7),COORD(4),       
     1                MODNAM(3),ZS(1),IZ(1),MCB1(7),MCB2(7),ROW2(3)     
      COMMON /BLANK / NOMGG,CYCIO,NSEGS,KMAX,FKMAX,BXTID,BXPTID,        
     1                BYTID,BYPTID,BZTID,BZPTID,NOBASX,NOFREQ,OMEGA     
CZZ   COMMON /ZZFVR1/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SYSTEM/ NBUF,NOUT,NERR        
      COMMON /UNPAKX/ IN1,NF1,NL1,INCR        
      COMMON /PACKX / IN,IOUT,NF,NL,INCR1        
      COMMON /CONDAD/ DPI,DTWOPI,DRADEG,DDEGRA,D4PISQ        
      EQUIVALENCE     (COORD(1),NCRD),(Z(1),ZS(1)),(Z(1),IZ(1)),        
     1                (MCB(1),MCB1(1)),(MCBM1(1),MCB2(1)),        
     2                (ITID(1),BXTID)        
      DATA    CASECC, BGPDT, CSTM, DIT, FRL, MGG     /        
     1        101,    102,   103,  104, 105, 106     /        
      DATA    FRLX, B1GG, M1GG, M2GG, BASEXG, PDZERO /        
     1        201,  202,  203,  204,  205   , 206    /        
      DATA    MODNAM / 4HFRL ,  4HFVRS,4HTR1         /        
      DATA    ITLIST / 4,  1105,11,1, 1205,12,2, 1305,13,3, 1405,14,4 / 
C     LOCATE  CODES FOR -  TABLED1    TABLED2    TABLED3    TABLED4     
C        
C     CALCULATE PARAMETERS        
C        
C     TEST TO SEE IF BASEXG IS TO BE GENERATED.        
C        
      NOBASX = -1        
      IF (NOMGG.EQ.-1 .OR.  CYCIO.NE.-1 .OR. NOFREQ.EQ.-1) GO TO 10     
      IF (BXTID.EQ.-1 .AND. BYTID.EQ.-1 .AND. BZTID.EQ.-1) GO TO 10     
      NOBASX =  1        
  10  CONTINUE        
C        
      IF (CYCIO .NE. -1) GO TO 25        
C        
C     DETERMINE FKMAX        
C        
      IF (MOD(NSEGS,2) .NE. 0) GO TO 23        
      IF (KMAX .EQ. NSEGS/2) GO TO 24        
  23  FKMAX = 2*KMAX + 1        
      GO TO 25        
  24  FKMAX = NSEGS        
C        
C     TEST TO SEE IF ANY DATA BLOCKS ARE TO BE GENERATED.        
C        
  25  IF (NOMGG .EQ. -1) GO TO 1000        
      IF (OMEGA.EQ.0.0 .AND. (CYCIO.NE.-1 .OR. NOFREQ.EQ.-1) .AND.      
     1   (BXTID.EQ.-1 .AND. BYTID.EQ.-1 .AND. BZTID.EQ.-1)) GO TO 1000  
C        
C     TEST TRAILER OF MGG TO SEE IF PURGED        
C        
      MCB(1) = MGG        
      CALL RDTRL (MCB)        
      NFILE = MGG        
      IF (MCB(1) .LE. 0) GO TO 902        
C        
C     COLUMN COUNT FOR MGG READ CHECK        
C        
      NCOLC = MCB(2)        
      NROWC = MCB(3)        
      NFORM = MCB(4)        
      NTYPE = MCB(5)        
C        
      NZ = KORSZ(Z)        
C        
C     ALLOCATE BUFFERS        
C        
C     MGG,CSTM (IBUF1 IS NBUF+1 LONG)        
C        
      IBUF1 = NZ - NBUF        
C        
C     BGPDT        
C        
      IBUF2 = IBUF1 - NBUF        
C        
C     B1GG        
C        
      IBUF3 = IBUF2 - NBUF        
C        
C     M1GG        
C        
      IBUF4 = IBUF3 - NBUF        
C        
C     M2GG        
C        
      IBUF5 = IBUF4 - NBUF        
      IF (OMEGA .EQ. 0.0) IBUF5 = IBUF3        
C        
C     CALCULATE LENGTH OF OPEN CORE        
C        
      NZ = IBUF5 - 1        
C        
C     PROCESS CSTM DATA BLOCK        
C        
      NFILE  = CSTM        
      MCB(1) = CSTM        
      CALL RDTRL (MCB)        
      IF (MCB(1) .LE. 0) GO TO 61        
C        
C     NO. OF COORDINATE SYSTEMS        
C        
      NCSYM = MCB(3)        
      LCSTM = 14*NCSYM        
C        
C     CSTM TABLE        
C        
      ICSTM = IBUF5 - LCSTM        
      NZ    = ICSTM - 1        
C        
C     CORE FOR ENOUGH CORE FOR CSTM        
C        
      IF (NZ .LT. 0) GO TO 901        
C        
C     CORE CHECK FULL COLUMN OF MGG READ ASSUMED        
C        
      IF (NZ-NTYPE*NROWC .LT. 0) GO TO 901        
      CALL GOPEN (CSTM,ZS(IBUF1),0)        
      CALL READ (*903,*904,CSTM,ZS(ICSTM),LCSTM,1,NWDS)        
      CALL PRETRD (ZS(ICSTM),LCSTM)        
      CALL CLOSE (CSTM,1)        
      GO TO 64        
C        
C     CORE CHECK NO CSTM        
C        
  61  IF (NZ-NTYPE*NROWC .LT. 0) GO TO 901        
  64  CONTINUE        
C        
C     BGPDT TABLE        
C        
      MCB(1) = BGPDT        
      CALL RDTRL (MCB)        
      NFILE = BGPDT        
      IF (MCB(1) .LE. 0) GO TO 902        
C        
C     NO. OF GRID POINTS AND SCALAR POINTS READ CHECK FOR BGPDT        
C        
      NGRID = MCB(2)        
      CALL GOPEN (BGPDT,ZS(IBUF2),0)        
C        
C     OPEN MGG AND OUTPUT MATRICES        
C        
      CALL GOPEN (MGG,ZS(IBUF1),0)        
      IF (OMEGA .EQ. 0.0) GO TO 65        
      CALL GOPEN (B1GG,ZS(IBUF3),1)        
      MCBB1(1) = B1GG        
      MCBB1(2) = 0        
      MCBB1(3) = NROWC        
      MCBB1(4) = 1        
      MCBB1(5) = NTYPE        
      MCBB1(6) = 0        
      MCBB1(7) = 0        
      CALL GOPEN (M1GG,ZS(IBUF4),1)        
      MCBM1(1) = M1GG        
      MCBM1(2) = 0        
      MCBM1(3) = NROWC        
      MCBM1(4) = NFORM        
      MCBM1(5) = NTYPE        
      MCBM1(6) = 0        
      MCBM1(7) = 0        
  65  IF (NOBASX .EQ. -1) GO TO 66        
      CALL GOPEN (M2GG,ZS(IBUF5),1)        
      MCBM2(1) = M2GG        
      MCBM2(2) = 0        
      MCBM2(3) = NROWC        
      MCBM2(4) = 1        
      MCBM2(5) = NTYPE        
      MCBM2(6) = 0        
      MCBM2(7) = 0        
C        
C     SET UP PACK AND UNPACK TERMS        
C        
  66  IN1  = NTYPE        
      IN   = 2        
      IOUT = NTYPE        
      INCR = 1        
      INCR1= 1        
C        
C     READ INTERNAL SORT BGPDT PICK UP CID,X,Y,Z        
C        
      NDOF = 0        
  70  CALL READ (*903,*800,BGPDT,COORD,4,0,M)        
      NDOF = NDOF + 1        
      IF (NCRD .NE. -1) GO TO 79        
C        
C     SCALAR POINT-UNPACK ONE COL OF MGG        
C     SAVE DIAGONAL TERM        
C        
      NF1  = 0        
      CALL UNPACK (*76,MGG,Z)        
      NROW = NDOF - NF1 + 1        
      NTERM= NL1 - NF1 + 1        
      IF (NROW.LT.1 .OR. NROW.GT.NTERM) GO TO 76        
      IF (NTYPE .EQ. 1) ROW(1) = ZS(NROW)        
      IF (NTYPE .EQ. 2) ROW(1) = Z(NROW)        
      NF = NDOF        
      NL = NDOF        
      GO TO 77        
C        
C     OUT OF RANGE OF NON-ZERO BAND        
C        
  76  ROW(1) = 0.0        
      NF = 1        
      NL = 1        
C        
C     NOW PUT DIAGONAL ELEMENT INTO OUTPUT MATRICES        
C        
  77  IF (OMEGA .EQ. 0.0) GO TO 78        
      CALL PACK (ROW,M1GG,MCBM1)        
      CALL PACK (ROW,B1GG,MCBB1)        
  78  IF (NOBASX .EQ. -1) GO TO 70        
      CALL PACK (ROW,M2GG,MCBM2)        
      GO TO 70        
C        
C     UNPACK 3 COL OF MGG AND SAVE DIAGONAL TERMS        
C        
  79  DO 80 I = 1,3        
      DO 80 J = 1,3        
  80  A(I,J) = 0.0        
      DO 100 I = 1,3        
      NF1 = 0        
      CALL UNPACK (*95,MGG,Z)        
C        
C     LOCATE DIAGONAL ELEMENT IN COL-NROW        
C        
      NROW  = NDOF - NF1 + I        
      NTERM = NL1  - NF1 + 1        
      IF (NROW.LT.1 .OR. NROW.GT.NTERM) GO TO 95        
      IF (NTYPE .EQ. 1) A(I,I) = ZS(NROW)        
      IF (NTYPE .EQ. 2) A(I,I) = Z(NROW)        
      GO TO 100        
C        
C     OUT OF RANGE OF NON-ZERO ELEMENT BAND        
C        
  95  A(I,I) = 0.0        
 100  CONTINUE        
C        
C     NOW TRANSFORM FROM LOCAL(GLOBAL) TO BASIC        
C        
      IF (NCRD .NE. 0) GO TO 150        
C        
C     ALREADY IN BASIC COORDINATES        
C        
      AVGM = (A(1,1) + A(2,2) + A(3,3))/3.0        
      GO TO 161        
C        
C     SELECT TRANSFORMATION MATRIX-TA        
C        
 150  CALL TRANSD (COORD,TA)        
      CALL GMMATD (TA,3,3,0,A,3,3,0,B)        
      CALL GMMATD (B,3,3,0,TA,3,3,1,C)        
C        
C     C-IS NOW IN BASIC COORDINATES-ROW,WISE        
C        
      AVGM = (C(1,1) + C(2,2) + C(3,3))/3.0        
C        
 161  IF (OMEGA .EQ. 0.0) GO TO 307        
C        
C     PROCESS M1GG        
C        
      DO 162 I = 1,3        
      DO 162 J = 1,3        
 162  A(I,J) = 0.0        
      A(2,2) = AVGM        
      A(3,3) = AVGM        
      IF (NCRD .NE. 0) GO TO 170        
      DO 165 I = 1,3        
      DO 165 J = 1,3        
 165  C(I,J) = A(I,J)        
      GO TO 180        
C        
C     TRANSFORM TO GLOBAL(LOCAL) FROM BASIC        
C        
 170  CALL GMMATD (TA,3,3,1,A,3,3,0,B)        
      CALL GMMATD (B,3,3,0,TA,3,3,0,C)        
C        
C     C- IS NOW M1-11 ROW WISE        
C        
 180  DO 200 I = 1,3        
      DO 190 K = 1,3        
 190  ROW(K) = C(I,K)        
      NF = NDOF        
      NL = NDOF + 2        
      CALL PACK (ROW,M1GG,MCBM1)        
 200  CONTINUE        
C        
C     WRITE OUT 3 NULL COLUMNS        
C        
      ROW(1) = 0.0        
      DO 205 K = 1,3        
      NF = 1        
      NL = 1        
      CALL PACK (ROW,M1GG,MCBM1)        
 205  CONTINUE        
C        
C     NOW TAKE CARE OF B1GG        
C        
      IF (NCRD .NE. 0) GO TO 240        
      DO 210 I = 1,3        
      DO 210 J = 1,3        
 210  C(I,J) = 0.0        
      C(3,2) =-AVGM        
      C(2,3) = AVGM        
      GO TO 250        
 240  DO 245 I = 1,3        
      DO245 J = 1,3        
 245  A(I,J) = 0.0        
      A(3,2) =-AVGM        
      A(2,3) = AVGM        
C        
C     TRANSFORM TO GLOBAL(LOCAL) FROM BASIC        
C        
      CALL GMMATD (TA,3,3,1,A,3,3,0,B)        
      CALL GMMATD (B,3,3,0,TA,3,3,0,C)        
C        
C     C-IS NOW B1-11 ROW WISE        
C        
 250  CONTINUE        
      DO 300 I = 1,3        
      DO 265 K = 1,3        
 265  ROW(K) = C(I,K)        
      NF = NDOF        
      NL = NDOF + 2        
      CALL PACK (ROW,B1GG,MCBB1)        
 300  CONTINUE        
C        
C     WRITE OUT 3 NULL COLUMNS        
C        
      ROW(1) = 0.0        
      DO 305 I = 1,3        
      NF = 1        
      NL = 1        
      CALL PACK (ROW,B1GG,MCBB1)        
 305  CONTINUE        
 307  IF (NOBASX .EQ. -1) GO TO 407        
C        
C     NOW PROCESS M2GG        
C        
      IF (NCRD .NE. 0) GOT O 340        
      DO 310 I = 1,3        
      DO 310 J = 1,3        
 310  C(I,J) = 0.0        
      C(1,1) = AVGM        
      C(2,2) = AVGM        
      C(3,3) = AVGM        
      C(3,2) = AVGM        
      C(2,3) =-AVGM        
      GO TO 350        
 340  DO 345 I = 1,3        
      DO 345 J = 1,3        
 345  A(I,J) = 0.0        
      A(1,1) = AVGM        
      A(2,2) = AVGM        
      A(3,3) = AVGM        
      A(3,2) = AVGM        
      A(2,3) =-AVGM        
C        
C     TRANSFORM TO GLOBAL(LOCAL) FROM BASIC        
C        
      CALL GMMATD (TA,3,3,1,A,3,3,0,C)        
C        
C     C-IS NOW M2-11 ROW WISE        
C        
 350  CONTINUE        
      DO 400 I = 1,3        
      DO 365 K = 1,3        
 365  ROW(K) = C(I,K)        
      NF = NDOF        
      NL = NDOF + 2        
      CALL PACK (ROW,M2GG,MCBM2)        
 400  CONTINUE        
C        
C     WRITE OUT 3 NULL COLUMNS        
C        
      ROW(1) = 0.0        
      DO 405 I = 1,3        
      NF = 1        
      NL = 1        
      CALL PACK (ROW,M2GG,MCBM2)        
 405  CONTINUE        
C        
C     SPACE DOWN 3 COL IN MGG        
C        
 407  CONTINUE        
      NDOF  = NDOF + 5        
      NFILE = MGG        
      CALL FWDREC (*903,MGG)        
      CALL FWDREC (*903,MGG)        
      CALL FWDREC (*903,MGG)        
      NFILE = BGPDT        
      GO TO 70        
C        
C     FINISH PROCESSING        
C        
 800  CALL CLOSE (MGG,1)        
      IF (NOBASX .EQ. -1) GO TO 802        
      CALL CLOSE (M2GG,1)        
      CALL WRTTRL (MCBM2)        
 802  IF (OMEGA .EQ. 0.0) GO TO 805        
      CALL CLOSE (B1GG,1)        
      CALL CLOSE (M1GG,1)        
      CALL WRTTRL (MCBB1)        
      CALL WRTTRL (MCBM1)        
 805  CALL CLOSE (BGPDT,1)        
C        
C     BEGIN PROCESSING OF FRLX, PDZERO AND BASEXG DATA BLOCKS.        
C        
C        
C     TEST TO SEE IF BASEXG IS TO BE GENERATED.        
C        
      IF (NOBASX .EQ. -1) GO TO 1000        
C        
C     RE-ESTABLISH LENGTH OF OPEN CORE FOR PHASE II PROCESSING        
C        
      NZ = IBUF3 - 1        
C        
C     PROCESS FRL, FRLX AND PDZERO        
C        
      MODFRL = .TRUE.        
      IF (OMEGA.EQ.0.0 .OR. BYTID.EQ.-1 .AND. BZTID.EQ.-1)        
     1    MODFRL = .FALSE.        
C        
      NFILE = FRL        
      MCB1(1) = FRL        
      CALL RDTRL (MCB1)        
      NFSETS = MCB1(2)        
      IFRL = 1        
      CALL OPEN (*902,FRL,ZS(IBUF1),0)        
C        
C     READ HEADER RECORD        
C        
      CALL READ (*903,*810,FRL,IZ(IFRL),NZ,1,NWRDS)        
      GO TO 901        
C        
C     OPEN CASECC        
C        
 810  NFILE = CASECC        
      CALL GOPEN (CASECC,ZS(IBUF2),0)        
C        
C     READ RECORD 1, WORD 14 (FREQUENCY SET ID)        
C        
      CALL READ (*903,*904,CASECC,CASE,14,0,DUMMY)        
      FRQSET = CASE(14)        
      CALL CLOSE (CASECC,1)        
C        
C     CHECK WHAT LOGICAL RECORD FRQSET IS IN FRL.        
C        
      MM = 0        
      II = IFRL + 2        
      DO 840 I = II,NWRDS        
      MM = MM + 1        
      IF (IZ(I) .EQ. FRQSET) GO TO 850        
 840  CONTINUE        
C        
C     FREQUENCY SET NOT FOUND.        
C        
      GO TO 905        
C        
C     MM IS LOGICAL RECORD NO. IN FRL FOR FRQSET.        
C        
 850  IF (.NOT.MODFRL) GO TO 852        
      CALL  OPEN (*902,FRLX,ZS(IBUF2),1)        
      CALL WRITE (FRLX,IZ(IFRL),NWRDS,1)        
      CALL GOPEN (PDZERO,ZS(IBUF3),1)        
      MCB2(1) = PDZERO        
      MCB2(2) = 0        
      MCB2(3) = 0        
      MCB2(4) = 1        
      MCB2(5) = 1        
      MCB2(6) = 0        
      MCB2(7) = 0        
      IN      = 1        
      IOUT    = 1        
      INCR1   = 1        
      ROW2(1) = 0.0        
      ROW2(2) = 1.0        
      ROW2(3) = 0.0        
 852  IFRL    = 1        
      NFS     = 0        
      NFSX    = 0        
      NFILE   = FRL        
      DO 859 I = 1,NFSETS        
      CALL READ (*903,*853,FRL,ZS(IFRL),NZ,1,M)        
      GO TO 901        
 853  IF (I .EQ. MM) NFS = M        
      IF (.NOT.MODFRL .AND.I.EQ.MM) GO TO 865        
      IF (.NOT.MODFRL) GO TO 859        
      IF (I  .NE.  MM) GO TO 858        
C        
C     SET POINTERS FOR SORT INDEX ,   FRLX AND PDZERO ARRAYS.        
C        
      INDEX = IFR L + NFS        
      IFRLX = INDEX + 3*NFS        
      IPDZ  = IFRLX + 3*NFS        
C        
C     RESET IFRL POINTER TO CONTINUE READING FRL RECORDS.        
C        
      IFRL  = IFRLX        
C        
C     CHECK CORE REQUIRED FOR EXPANDED FREQUENCY LIST AND SORT INDEX    
C        
      NZ = NZ - (IPDZ + 3*NFS) + 1        
      IF (NZ .LT. 0) GO TO 901        
C        
      LL = IFRLX - 1        
      KKK= IPDZ  - 1        
      DO 857 II = 1,NFS        
      IF (ZS(II) .EQ. 0.0) GO TO 856        
      DO 854 KK = 1,3        
      KKK = KKK + 1        
      ZS(KKK) = ROW2(KK)        
 854  CONTINUE        
      ZS(LL+1) = ABS(ZS(II)-OMEGA)        
      ZS(LL+2) = ZS(II)        
      ZS(LL+3) = ABS(ZS(II)+OMEGA)        
      LL = LL + 3        
      GO TO 857        
 856  ZS(LL+1) = 0.0        
      ZS(LL+2) = ABS(OMEGA)        
      KKK = KKK + 1        
      ZS(KKK) = ROW2(2)        
      KKK = KKK + 1        
      ZS(KKK) = ROW2(1)        
      LL  = LL + 2        
 857  CONTINUE        
C        
C     COMPUTE THE EXPANDED NUMBER OF FREQUIENCES, NFSX.        
C        
      NFSX = LL - IFRLX + 1        
C        
C     SORT EXPANDED W'S AND GET INDEX FOR SORTING BASE TABLE.        
C        
      CALL FVRS1E (ZS(IFRLX),IZ(INDEX),NFSX)        
      CALL WRITE (FRLX,ZS(IFRLX),NFSX,1)        
      GO TO 859        
 858  CALL WRITE (FRLX,ZS(IFRL),M,1)        
 859  CONTINUE        
      IF (.NOT.MODFRL) GO TO 865        
C        
C      FRLX IS A COPY OF FRL WITH THE SELECTED FREQUENCY SET, FRQSET,   
C      EXPANDED.        
C        
      CALL CLOSE (FRLX,1)        
      MCB1(1) = FRLX        
      CALL WRTTRL (MCB1)        
C        
C     SORT PDZERO BY INDEX JUST AS WAS DONE FOR FRLX        
C     USE WORK   AT ZS(IFRLX)        
C         INDEX  AT ZS(INDEX)   ALL NFSX LONG        
C         PDZERO AT ZS(IPDZ)        
C        
      DO 860 KK = 1,NFSX        
      LOC = IZ(INDEX+KK-1)        
 860  ZS(IFRLX+KK-1) = ZS(IPDZ+LOC-1)        
C        
C     NOW OUTPUT NFSX * FKMAX COLUMNS FOR PDZERO        
C        
      KKK = 0        
      DO 862 KK = 1,FKMAX        
      DO 861 JJ = 1,NFSX        
      KKK = KKK + 1        
      NF  = KKK        
      NL  = KKK        
      CALL PACK (ZS(IFRLX+JJ-1),PDZERO,MCB2)        
 861  CONTINUE        
 862  CONTINUE        
      CALL CLOSE (PDZERO,1)        
      MCB2(3) = MCB2(2)        
      CALL WRTTRL (MCB2)        
 865  CALL CLOSE (FRL,1)        
C        
C     RE-ESTABLISH OPEN CORE FOR PHASE III AND        
C     RESET POINTER TO ORIGINAL FREQUIENCIES.        
C        
      IFRL = 1        
      NZ   = IBUF1 - (NFS+NFSX) - 1        
C        
C     NFS  = THE ORIGINAL NUMBER OF FREQUIENCES        
C     NFSX = THE EXPANDED NUMBER OF FREQUIENCES.        
C        
C     GENERATE BASE ACCELERATION MATRIX BASEXG.        
C        
C        
C     BUILD A LIST OF UNIQUE TABLE IDS FOR PRETAB.        
C     INITIALIZE THE TABLE WITH A ZERO ENTRY.        
C        
      ITAB = NFS + NFSX + 1        
      NTABL=1        
      K = ITAB + NTABL        
      IZ(K) = 0        
C        
C     WE HAVE A LIST OF TABLE ID'S TO CONSIDER        
C     WE WANT ONLY A UNIQUE LIST OF TABLE ID'S GIVEN TO PRETAB        
C        
      DO 872 I = 1,6        
      IITID = ITID(I)        
C        
C     SEARCH EXISTING LIST OF TABLE ID'S TO SEE IF IITID IS ALREADY IN  
C     LIST        
C        
      IF (IITID.LE.0 .OR. IITID.GT.9999999) GO TO 872        
      DO 871 L = 1,NTABL        
      LL = ITAB + L        
      IF (IZ(LL) .EQ. IITID) GO TO 872        
 871  CONTINUE        
C        
C     IITID WAS NOT AMONG EXISTING TABLE ID'S IN LIST,        
C     IT'S A NEW TABLE ID,ADD IT TO LIST AND UPDATE LENGHT OF LIST      
C        
      NTABL = NTABL + 1        
      K = ITAB + NTABL        
      IZ(K) = IITID        
 872  CONTINUE        
C        
C     ALL TABLE ID'S HAVE BEEN PROCESSED,NOW PRETAB CAN BE CALLED       
C     NTABL IS THE NUMBER OF TID'S IN THE LIST.        
C        
      IZ(ITAB) = NTABL        
C        
C     ILTAB IS THE NEXT AVAILABLE LOCATION OF OPEN CORE FOR PRETAB.     
C        
      ILTAB = ITAB + NTABL + 1        
C        
C     COMPUTE LENGTH OF OPEN CORE AVAILABLE TO PRETAB.        
C        
      NZTAB = NZ - NTABL - 1        
      LTAB  = 0        
      CALL PRETAB (DIT,ZS(ILTAB),IZ(ILTAB),ZS(IBUF1),NZTAB,LTAB,        
     1             IZ(ITAB),ITLIST)        
C        
C     COMPUTE LENGTH OF OPEN CORE AFTER PRETAB AND NEXT AVAILABLE LOC.  
C        
      NZ   = NZ - LTAB        
      NEXT = ILTAB + LTAB        
C        
C     ALLOCATE COMPLEX ARRAYS FOR BASEXG. START ON DOUBLE WORD BOUNDARY.
C        
      IF (MOD(NEXT,2) .EQ. 0) NEXT = NEXT + 1        
C        
C     DEFINE NFSX IF MODFRL IS FALSE.        
C        
      IF (.NOT.MODFRL) NFSX = NFS        
C        
      N1 = NEXT        
      N2 = N1 + (3*NFSX)*2        
      N3 = N2 + (3*NFSX)*2        
      NT = N3 +    NROWC*2 - 1        
      IF (NZ .LT. NT) GO TO 901        
      CALL FVRS1A (ZS(N1),ZS(N2),ZS(N3),ZS(IFRL),ZS(IBUF1),ZS(INDEX),   
     1             MODFRL,BASEXG,NROWC,NFS,NFSX,FKMAX,OMEGA)        
      GO TO 1000        
C        
C     ERROR PROCESSING        
C        
C     NOT ENOUGH CORE (ERROR 3008)        
C        
 901  IP1 = -8        
      GO TO 999        
C        
C     DATA SET NOT IN FIST (ERROR 3001)        
C        
 902  IP1 = -1        
      GO TO 999        
C        
C     EOF ENCOUNTERED (ERROR 3002)        
C        
 903  IP1 = -2        
      GO TO 999        
C        
C     EOL ENCOUNTERED (ERROR 3003)        
C        
 904  IP1 = -3        
      GO TO 999        
C        
C     FREQUENCY SET NOT FOUND IN FRL (ERROR 3031)        
C        
 905  CALL MESAGE (-31,FRQSET,MODNAM)        
      GO TO 1000        
 999  CALL MESAGE (IP1,NFILE,MODNAM(2))        
 1000 RETURN        
      END        
