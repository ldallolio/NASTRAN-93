      SUBROUTINE APDB        
C        
C     AERODYNAMIC POOL DISTRIBUTOR AND GEOMETRY INTERPOLATOR FOR        
C     COMPRESSOR BLADES (AERODYNAMIC THEORY 6) AND SWEPT TURBOPROP      
C     BLADES (AERODYNAMIC THEORY 7).        
C        
C     THIS IS THE DMAP DRIVER FOR APDB        
C        
C     DMAP CALLING SEQUENCE        
C        
C     APDB     EDT,USET,BGPDT,CSTM,EQEXIN,GM,GO / AEROB,ACPT,FLIST,     
C              GTKA,PVECT / V,N,NK/V,N,NJ/V,Y,MINMACH/V,Y,MAXMACH/      
C              V,Y,IREF/V,Y,MTYPE/V,N,NEIGV/V,Y,KINDEX $        
C        
C     INPUT  DATA BLOCKS CSTM, GM AND GO MAY BE PURGED        
C     OUTPUT DATA BLOCK  PVECT MAY BE PURGED        
C     PARAMETERS NK AND NJ ARE OUTPUT, THE OTHERS ARE INPUT        
C        
C        
      LOGICAL         LMKAER,FIRST,DEBUG        
      INTEGER         SYSBUF,RD,RDREW,WRT,WRTREW,CLSREW,NOREW,EOFNRW,   
     1                NAME(2),AERO(3),MKAER1(3),MKAER2(3),FLUTTR(3),    
     2                FLFACT(3),ITRL(7),STRML1(3),STRML2(3),SCR1,FILE,  
     3                FLAG,NAME1(6,2),BUF(7),EDT,BGPDT,CSTM,EQEXIN,     
     4                AEROB,ACPT,FLIST,PVECT,CORWDS,PSTRM(100),TYPIN,   
     5                TYPOUT,SINE,IZ(6)        
      REAL            MINMAC,MAXMAC        
      CHARACTER       UFM*23,UWM*25        
      COMMON /XMSSG / UFM,UWM        
      COMMON /BLANK / NK,NJ,MINMAC,MAXMAC,IREF,MTYPE(2),NEIGV,KINDEX    
      COMMON /SYSTEM/ SYSBUF,IOUT,NSYS(91)        
      COMMON /APDBUG/ DEBUG        
      COMMON /PACKX / TYPIN,TYPOUT,II,NN,INCR        
CZZ   COMMON /ZZAPDB/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /NAMES / RD,RDREW,WRT,WRTREW,CLSREW,NOREW,EOFNRW        
C     NAMES  -VALUE =  2   0    3    1      1      2     3        
      EQUIVALENCE     (Z(1),IZ(1)), (MINMAC,MACMIN), (MAXMAC,MACMAX)    
      DATA    AERO  / 3202,32,0/, MKAER1 /3802,38,0/, MKAER2 /3702,37,0/
      DATA    FLUTTR/ 3902,39,0/, FLFACT /4102,41,0/        
      DATA    STRML1/ 3292,92,0/, STRML2 /3293,93,0/        
      DATA    EDT   , BGPDT,CSTM,EQEXIN  /        
     1        101   , 103  ,104 ,105     /        
      DATA    AEROB , ACPT ,FLIST,PVECT  /        
     1        201   , 202  ,203  ,205    /        
      DATA    NAME  / 4HAPDB,4H          /, SCR1 /301/        
      DATA    ITRL  / 7*0 / , FIRST / .TRUE./,  SINE / 4HSINE/        
      DATA    NAME1(1,1),NAME1(1,2) / 4HAERO,4H      /        
      DATA    NAME1(2,1),NAME1(2,2) / 4HMKAE,4HRO    /        
      DATA    NAME1(3,1),NAME1(3,2) / 4HFLFA,4HCT    /        
      DATA    NAME1(4,1),NAME1(4,2) / 4HFLUT,4HTER   /        
      DATA    NAME1(5,1),NAME1(5,2) / 4HSTRE,4HAML1  /        
      DATA    NAME1(6,1),NAME1(6,2) / 4HSTRE,4HAML2  /        
C        
      DEBUG = .FALSE.        
      CALL SSWTCH (20,J)        
      IF (J .EQ. 1) DEBUG = .TRUE.        
C        
C     SELECT AERODYNAMIC THEORY        
C        
C     COMPRESSOR BLADES (AERODYNAMIC THEORY 6).        
C     SWEPT TURBOPROPS  (AERODYNAMIC THEORY 7).        
C        
C     AT PRESENT THE USER SELECTS THE THEORY VIA THE NASTRAN CARD.      
C     SET SYSTEM(93)=0  FOR THEORY 6 OR SYSTEM(93)=1 FOR THEORY 7.      
C     NOTE - THE DEFAULT IS THEORY 6 (SYSTEM(93)=0).        
C        
C     FOR EXAMPLE, TO SELECT THEORY 7, USE THE FOLLOWING CARD -        
C     NASTRAN SYSTEM(93)=1        
C        
      IF (NSYS(91) .EQ. 0) MTHD = 6        
      IF (NSYS(91) .EQ. 1) MTHD = 7        
C        
      IF (DEBUG) CALL BUG1 ('BLANK COMM',1,NK,9)        
      NOGO  = 0        
      MAXSL = 100        
      IBUF1 = KORSZ(Z) - SYSBUF        
      IBUF2 = IBUF1 - SYSBUF        
      IBUF3 = IBUF2 - SYSBUF        
      LAST  = IBUF3 - SYSBUF - 1        
      IF (LAST .LE. 0) GO TO 991        
      LEFT = CORWDS(Z(1),Z(LAST))        
C        
C     CREATE AEROB DATA BLOCK        
C        
      CALL GOPEN (AEROB,Z(IBUF2),WRTREW)        
C        
C     READ AERO CARD VALUES - BREF, SYMXZ AND SYMXY        
C        
      FILE = EDT        
      CALL PRELOC (*992,Z(IBUF1),EDT)        
      CALL LOCATE (*981,Z(IBUF1),AERO,FLAG)        
      CALL READ   (*993,*994,EDT,Z(1),6,1,FLAG)        
      IF (DEBUG) CALL BUG1 ('AERO CARD ',2,Z,6)        
      IZ(1) = IZ(5)        
      IZ(2) = IZ(6)        
CC    Z(3)  = Z(3)        
      CALL WRITE (AEROB,Z,3,1)        
C        
C     READ IN MKAERO1 CARDS        
C        
      LMKAER = .FALSE.        
      NEXT = 1        
      CALL LOCATE (*60,Z(IBUF1),MKAER1,FLAG)        
      CALL READ (*993,*10,EDT,Z(NEXT),LEFT,1,NX)        
      GO TO 991        
   10 N1 = NEXT        
      IF (DEBUG) CALL BUG1 ('MKAERO1   ',10,Z(N1),NX)        
      LMKAER = .TRUE.        
   20 N2 = N1 + 7        
      DO 40 I = N1,N2        
      IF (IZ(I) .EQ. -1) GO TO 50        
      BUF(1) = IZ(I)        
      N3 = N2 + 1        
      N4 = N3 + 7        
      DO 30 J = N3,N4        
      IF (IZ(J) .EQ. -1) GO TO 40        
      BUF(2) = IZ(J)        
   30 CALL WRITE (AEROB,BUF,2,0)        
   40 CONTINUE        
   50 IF (N4-NEXT+1 .GE. NX) GO TO 60        
      N1 = N1 + 16        
      GO TO 20        
C        
C     READ IN MKAERO2 CARDS        
C        
   60 CALL LOCATE (*80,Z(IBUF1),MKAER2,FLAG)        
      CALL READ (*993,*70,EDT,Z(NEXT),LEFT,1,NX)        
      GO TO 991        
   70 CALL WRITE (AEROB,Z(NEXT),NX,0)        
      IF (DEBUG) CALL BUG1 ('MKAERO2   ',70,Z(NEXT),NX)        
      LMKAER = .TRUE.        
   80 CALL WRITE (AEROB,0,0,1)        
      CALL CLOSE (AEROB,CLSREW)        
      IF (.NOT.LMKAER) GO TO 982        
      ITRL(1) = AEROB        
      ITRL(2) = 1        
      CALL WRTTRL (ITRL)        
C        
C     CREATE FLIST TABLE        
C        
      CALL OPEN  (*85,FLIST,Z(IBUF2),WRTREW)        
      CALL FNAME (FLIST,IZ(NEXT))        
      CALL WRITE (FLIST,IZ(NEXT),2,1)        
      CALL LOCATE (*981,Z(IBUF1),AERO,FLAG)        
      CALL READ (*993,*90,EDT,Z(NEXT),LEFT,1,NX)        
      GO TO 991        
C        
C     FLIST CAN BE PURGED IF THE APPROACH IS NOT AERO        
C        
   85 IF (IABS(NSYS(19)) .NE. 4) GO TO 115        
      FILE = FLIST        
      GO TO 992        
   90 CALL WRITE (FLIST,AERO,3,0)        
      CALL WRITE (FLIST,Z(NEXT),NX,1)        
      IF (DEBUG) CALL BUG1 ('FLIST AERO',90,Z(NEXT),NX)        
      CALL LOCATE (*983,Z(IBUF1),FLFACT,FLAG)        
      CALL READ (*993,*100,EDT,Z(NEXT),LEFT,1,NX)        
      GO TO 991        
  100 CALL WRITE (FLIST,FLFACT,3,0)        
      CALL WRITE (FLIST,Z(NEXT),NX,1)        
      IF (DEBUG) CALL BUG1 ('FLIST FLFA',100,Z(NEXT),NX)        
      CALL LOCATE (*984,Z(IBUF1),FLUTTR,FLAG)        
      CALL READ (*993,*110,EDT,Z(NEXT),LEFT,1,NX)        
      GO TO 991        
  110 CALL WRITE (FLIST,FLUTTR,3,0)        
      CALL WRITE (FLIST,Z(NEXT),NX,1)        
      IF (DEBUG) CALL BUG1 ('FLIST FLUT',110,Z(NEXT),NX)        
      CALL CLOSE (FLIST,CLSREW)        
      ITRL(1) = EDT        
      CALL RDTRL (ITRL)        
      ITRL(1) = FLIST        
      CALL WRTTRL (ITRL)        
  115 CONTINUE        
C        
C     CREATE ACPT TABLE        
C        
      CALL GOPEN (ACPT,Z(IBUF2),WRTREW)        
C        
C     STORE EXTERNAL NODE NUMBER, INTERNAL NODE NUMBER AND BASIC        
C     COORDINATES OF ALL NODES ON BLADE ON SCR1        
C        
      CALL GOPEN (SCR1,Z(IBUF3),WRTREW)        
C        
C     READ STREAML1 AND STREAML2 CARDS. STORE IN-CORE        
C        
      NSL1A = NEXT        
      CALL LOCATE (*985,Z(IBUF1),STRML1,FLAG)        
      CALL READ (*993,*120,EDT,Z(NSL1A),LEFT,1,NSL1L)        
      GO TO 991        
  120 NSL1B = NSL1A + NSL1L - 1        
      IF (DEBUG) CALL BUG1 ('STREAML1  ',120,Z(NSL1A),NSL1L)        
      NSL2A = NSL1B + 1        
      LEFT  = CORWDS(Z(NSL2A),Z(LAST))        
      CALL LOCATE (*986,Z(IBUF1),STRML2,FLAG)        
      CALL READ (*993,*130,EDT,Z(NSL2A),LEFT,1,NSL2L)        
      GO TO 991        
  130 NSL2B = NSL2A + NSL2L - 1        
      IF (DEBUG) CALL BUG1 ('STREAML2  ',130,Z(NSL2A),NSL2L)        
      CALL CLOSE (EDT,CLSREW)        
C        
C     INPUT CHECKS  (ALL ARE THEORY DEPENDENT RESTRICTIONS)        
C     STREAML1 - ALL CARDS MUST HAVE THE SAME NUMBER OF NODES        
C     STREAML2 - THERE MUST BE AT LEAST THREE(3) STREAML2 CARDS.        
C                (THIS IS A THEORY DEPENDENT RESTRICTION,        
C                SEE AMG MODULE - COMPRESSOR BLADE CODE FOR AJJL)       
C              - NSTNS MUST BE THE SAME FOR ALL STREAML2 CARDS        
C                AND MUST EQUAL THE NO. OF NODES ON THE STRAML1 CARD    
C        
C     COUNT THE NUMBER OF STREAML2 CARDS        
C        
      NLINES = NSL2L/10        
      IF (DEBUG) CALL BUG1 ('NLINES    ',131,NLINES,1)        
      IF (NLINES .GE. 3) GO TO 135        
      NOGO = 1        
      WRITE (IOUT,3001) UFM,NLINES        
  135 IF (NLINES .GT. MAXSL) GO TO 988        
C        
C     LOCATE STREAML1 CARDS THAT CORRESPOND TO STREAML2 CARDS BY        
C     MATCHING SLN VALUES        
C        
      NLINE = 0        
      DO 140 ISLN = NSL2A,NSL2B,10        
      NLINE = NLINE + 1        
  140 PSTRM(NLINE) = -IZ(ISLN)        
C        
C     LOCATE SLN AND COUNT THE NUMBER OF COMPUTING STATIONS        
C        
      IPOS = NSL1A        
  145 DO 150 NS = IPOS,NSL1B        
      IF (IZ(NS) .EQ. -1) GO TO 155        
  150 CONTINUE        
C        
C     CHECK FOR VALID SLN        
C        
  155 DO 160 NLINE = 1,NLINES        
      IF (IZ(IPOS) .EQ. -PSTRM(NLINE)) GO TO 165        
  160 CONTINUE        
      GO TO 175        
  165 PSTRM(NLINE) = IPOS        
      NSTNSX = NS - IPOS - 1        
      IF (.NOT.FIRST) GO TO 170        
      NSTNS = NSTNSX        
      FIRST = .FALSE.        
      GO TO 175        
C        
C     ALL NSTNSX MUST BE THE SAME        
C        
  170 IF (NSTNSX .EQ. NSTNS) GO TO 175        
      NOGO = 2        
      WRITE (IOUT,3002) UFM,IZ(IPOS)        
  175 IPOS = NS + 1        
      IF (IPOS .LT. NSL1B) GO TO 145        
C        
C     IS THERE A STREAML1 CARD FOR EVERY STREAML2 CARD        
C        
      DO 180 NLINE = 1,NLINES        
      IF (PSTRM(NLINE) .GT. 0) GO TO 180        
      NOGO = 3        
      ISLN = -PSTRM(NLINE)        
      WRITE (IOUT,3003) UFM,ISLN        
  180 CONTINUE        
      IF (NOGO .GT. 0) GO TO 1000        
C        
C     READ BGPDT        
C        
      NBG1 = NSL2B + 1        
      LEFT = CORWDS(Z(NBG1),Z(LAST))        
      FILE = BGPDT        
      CALL GOPEN (BGPDT,Z(IBUF1),RDREW)        
      CALL READ (*993,*200,BGPDT,Z(NBG1),LEFT,1,NBGL)        
      GO TO 991        
  200 CALL CLOSE (BGPDT,CLSREW)        
      IF (DEBUG) CALL BUG1 ('BGPDT     ',200,Z(NBG1),NBGL)        
      NBG2 = NBG1 + NBGL - 1        
C        
C     READ EQEXIN (RECORD 1)        
C        
      NEQ1 = NBG2 + 1        
      LEFT = CORWDS(Z(NEQ1),Z(LAST))        
      FILE = EQEXIN        
      CALL GOPEN (EQEXIN,Z(IBUF1),RDREW)        
      CALL READ (*993,*210,EQEXIN,Z(NEQ1),LEFT,1,NEQL)        
      GO TO 991        
  210 NEQ2 = NEQ1 + NEQL - 1        
      IF (DEBUG) CALL BUG1 ('EQEXIN R1 ',210,Z(NEQ1),NEQL)        
C        
C     READ EQEXIN (RECORD 2)        
C        
      NEQ21 = NEQ2 + 1        
      LEFT = CORWDS(Z(NEQ21),Z(LAST))        
      CALL READ (*993,*215,EQEXIN,Z(NEQ21),LEFT,1,NEQ2L)        
      GO TO 991        
  215 NEQ22 = NEQ2 + NEQ2L - 1        
      IF (DEBUG) CALL BUG1 ('EQEXIN R2 ',212,Z(NEQ21),NEQ2L)        
      CALL CLOSE (EQEXIN,CLSREW)        
C        
C     WRITE ACPT        
C        
C     KEY WORD = 6 FOR COMPRESSOR BLADES, I.E. METHOD ID = 6        
C     KEY WORD = 7 FOR SWEPT TURBOPROPS , I.E. METHOD ID = 7        
C        
C     WRITE CONSTANT PARAMETERS, WORDS 1 - 6        
C        
      BUF(1) = MTHD        
      BUF(2) = IREF        
      BUF(3) = MACMIN        
      BUF(4) = MACMAX        
      BUF(5) = NLINES        
      BUF(6) = NSTNS        
      CALL WRITE (ACPT,BUF,6,0)        
      IF (DEBUG) CALL BUG1 ('ACPT WRT 1',216,BUF,6)        
C        
C     WRITE STREAMLINE DATA        
C        
      KN = NEQL/2        
      NLINE = 0        
      DO 240 NSL = NSL2A,NSL2B,10        
C        
C     MAKE SURE NSTNS ON ALL STREAML2 CARDS IS THE SAME        
C        
      IF (IZ(NSL+1) .EQ. NSTNS) GO TO 217        
      WRITE (IOUT,3004) UWM,IZ(NSL)        
      IZ(NSL+1) = NSTNS        
C        
C     WRITE STREAML2 DATA        
C        
  217 CALL WRITE (ACPT,Z(NSL),10,0)        
      IF (DEBUG) CALL BUG1 ('ACPT WRT 2',217,Z(NSL),10)        
C        
C     WRITE BASIC X, Y AND Z FOR EACH NODE ON STREAML1 CARD        
C        
      NLINE = NLINE + 1        
      IPOS  = PSTRM(NLINE)        
      IPOS1 = IPOS + 1        
      IPOS2 = IPOS + NSTNS        
      DO 230 IGDP = IPOS1,IPOS2        
C        
C     LOCATE INTERNAL NUMBER THAT CORRESOONDS TO THIS EXTERNAL NODE     
C        
      CALL BISLOC (*220,IZ(IGDP),IZ(NEQ1),2,KN,JLOC)        
      GO TO 225        
C        
C     STREAML1 REFERNCES AN EXTERNAL ID THAT DOES NOT EXIST        
C        
  220 NOGO = 5        
      WRITE (IOUT,3005) UFM,IZ(IPOS),IZ(IGDP)        
      GO TO 230        
C        
C     PICK-UP BASIC GRID DATA FOR THIS NODE        
C        
  225 INTRL  = IZ(NEQ1+JLOC)        
      ISILC  = IZ(NEQ21+JLOC)        
      JLOC   = NBG1 + (INTRL-1)*4        
      BUF(1) = IZ(IGDP)        
      BUF(2) = INTRL        
      BUF(3) = ISILC        
      BUF(4) = IZ(JLOC  )        
      BUF(5) = IZ(JLOC+1)        
      BUF(6) = IZ(JLOC+2)        
      BUF(7) = IZ(JLOC+3)        
C        
C     TEST FOR SCALAR POINT (CID = -1)        
C        
      IF (BUF(4) .GE. 0) GO TO 227        
      NOGO = 6        
      WRITE (IOUT,3006) UFM,IZ(IPOS),IZ(IGDP)        
  227 CALL WRITE (ACPT,BUF(5),3,0)        
      CALL WRITE (SCR1,BUF,7,0)        
      IF (DEBUG) CALL BUG1 ('ACPT WRT 3',227,BUF,7)        
C        
C-----DETERMINE DIRECTION OF BLADE ROTATION VIA Y-COORDINATES AT TIP    
C-----STREAMLINE. USE COORDINATES OF FIRST 2 NODES ON STREAMLINE.       
C        
      IF (NLINE.EQ.NLINES .AND. IGDP.EQ.IPOS1)   YTIP1 = Z(JLOC+2)      
      IF (NLINE.EQ.NLINES .AND. IGDP.EQ.IPOS1+1) YTIP2 = Z(JLOC+2)      
C        
  230 CONTINUE        
  240 CONTINUE        
C        
      XSIGN = 1.0        
      IF (YTIP2 .LT. YTIP1) XSIGN = -1.0        
      IF (DEBUG) CALL BUG1 ('XSIN      ',240,XSIGN,1)        
      CALL WRITE (ACPT,0,0,1)        
      CALL WRITE (SCR1,0,0,1)        
      CALL CLOSE (ACPT,CLSREW)        
      CALL CLOSE (SCR1,CLSREW)        
      ITRL(1) = ACPT        
      ITRL(2) = 1        
      ITRL(3) = 0        
      ITRL(4) = 0        
      ITRL(5) = 0        
      ITRL(6) = 0        
      ITRL(7) = 0        
      CALL WRTTRL (ITRL)        
      IF (NOGO .GT. 0) GO TO 1000        
C        
C     SET OUTPUT PARAMETERS NK AND NJ FOR APPROPRIATE THEORY.        
C        
C     COMPRESSOR BLADES (THEORY 6) - NK = NJ = NSTNS*NLINES.        
C     SWEPT TURBOPROPS  (THEORY 7) - NK = NJ = 2*NSTNS*NLINES.        
C        
      IF (MTHD .EQ. 6) NK = NSTNS*NLINES        
      IF (MTHD .EQ. 7) NK = 2*NSTNS*NLINES        
      NJ = NK        
      IF (DEBUG) CALL BUG1 ('BLANK COM ',241,NK,9)        
C        
C     CREATE PVECT PARTITIONING VECTOR     (PVECT MAY BE PURGED)        
C     PVECT IS A COLUMN PARTITIONING VECTOR TO BE USED BY MODULE PARTN  
C     TO PARTITION OUT EITHER THE SINE OR COSINE COLUMNS OF MATRIX      
C     PHIA WHICH IS OUTPUT BY THE CYCT2 MODULE  WHEN DOING A CYCLIC     
C     NORMAL MODES ANALYSIS        
C     PARAMETER MTYPE=SINE OR COSINE (DEFAULT IS COSINE)        
C        
C     OPEN PVECT AND WRITE HEADER        
C        
      CALL OPEN (*270,PVECT,Z(IBUF2),WRTREW)        
C        
C     TEST FOR VALID NEIGV AND KINDEX        
C        
      IF (NEIGV.LE.0 .OR. KINDEX.LT.0) GO TO 987        
C        
      CALL FNAME (PVECT,BUF)        
      CALL WRITE (PVECT,BUF,2,1)        
C        
C     PVECT IS TO BE GENERATED        
C        
      LEFT = LEFT - NEQ2        
      NCOL = NEIGV        
      IF (KINDEX .GT. 0) NCOL = 2*NCOL        
      IPOS1 = NEQ2 + 1        
      IPOS2 = NEQ2 + NCOL        
      DO 250 IPV = IPOS1,IPOS2        
  250 Z(IPV) = 0.0        
      IF (KINDEX .EQ. 0) GO TO 260        
      IPOS3 = IPOS1        
      IF (MTYPE(1) .NE. SINE) IPOS3 = IPOS1 + 1        
      DO 255 IPV = IPOS3,IPOS2,2        
  255 Z(IPV) = 1.0        
  260 TYPIN  = 1        
      TYPOUT = 1        
      II     = 1        
      NN     = NCOL        
      INCR   = 1        
      CALL MAKMCB (ITRL,PVECT,NCOL,2,1)        
      CALL PACK (Z(IPOS1),PVECT,ITRL)        
      IF (DEBUG) CALL BUG1 ('PVECT     ',260,Z(IPOS1),NCOL)        
      CALL CLOSE (PVECT,CLSREW)        
      CALL WRTTRL (ITRL)        
  270 CONTINUE        
C        
C     GENERATE GTKA TRANSFORMATION MATRIX        
C        
C     READ CSTM INTO CORE        
C        
      NCSTM1 = 1        
      NCSTML = 0        
      FILE   = CSTM        
      ITRL(1)= CSTM        
      CALL RDTRL (ITRL)        
      IF (ITRL(1) .NE. CSTM) GO TO 300        
      LEFT = CORWDS(Z(NCSTM1),Z(LAST))        
      CALL GOPEN (CSTM,Z(IBUF1),RDREW)        
      CALL READ (*993,*300,CSTM,Z(NCSTM1),LEFT,1,NCSTML)        
      GO TO 991        
  300 NCSTM2 = NCSTM1 + NCSTML - 1        
      IF (DEBUG) CALL BUG1 ('CSTM      ',300,Z(NCSTM1),NCSTML)        
      CALL CLOSE (CSTM,CLSREW)        
C        
C     ALLOCATE WORK STORAGE        
C        
      IP1  = NCSTM2 + 1        
      IP2  = IP1 + NSTNS        
      IP3  = IP2 + NSTNS        
      IP4  = IP3 + NSTNS        
      NEXT = IP4 + 4*NSTNS        
      LEFT = LEFT - NEXT + 1        
      IF (LEFT .LE. 0) GO TO 991        
C        
C     GENERATE GTKA TRANSFORMATION MATRIX FOR APPROPRIATE THEORY.       
C        
C     COMPRESSOR BLADES (AERODYNAMIC THEORY 6).        
C        
      IF (MTHD .EQ. 6) CALL APDB1 (IBUF1,IBUF2,NEXT,LEFT,NSTNS,NLINES,  
     1    XSIGN,NCSTML,Z(NCSTM1),Z(IP1),Z(IP2),Z(IP3),Z(IP4))        
C        
C     SWEPT TURBOPROPS (AERODYNAMIC THEORY 7).        
C        
      IF (MTHD .EQ. 7) CALL APDB2 (IBUF1,IBUF2,NEXT,LEFT,NSTNS,NLINES,  
     1    XSIGN,NCSTML,Z(NCSTM1),Z(IP1),Z(IP2),Z(IP3),Z(IP4))        
      GO TO 1000        
C        
C     ERROR MESSAGES        
C        
C     NO AERO CARD FOUND        
  981 KODE = 1        
      GO TO 989        
C        
C     NO MKAERO1 OR MKAERO2 CARDS FOUND        
C        
  982 KODE = 2        
      GO TO 989        
C        
C     NO FLFACT CARD FOUND        
C        
  983 KODE = 3        
      GO TO 989        
C        
C     NO FLUTTER CARD FOUND        
C        
  984 KODE = 4        
      GO TO 989        
C        
C     NO STREAML1 CARD FOUND        
C        
  985 KODE = 5        
      GO TO 989        
C        
C     NO STREAML2 CARD FOUND        
C        
  986 KODE = 6        
      GO TO 989        
C        
C     NEIGV OR KINDEX INVALID        
C        
  987 WRITE (IOUT,2987) UFM,NEIGV,KINDEX        
      GO TO 1091        
C        
C     MAXIMUM NUMBER OF STREAML2 CARDS EXCEEDED FOR        
C     LOCAL ARRAY PSTRM. SEE ERROR MESSAGE FOR FIX.        
C        
  988 WRITE (IOUT,3007) UFM,MAXSL        
      GO TO 1091        
  989 WRITE (IOUT,2989) UFM,NAME1(KODE,1),NAME1(KODE,2)        
      GO TO 1091        
C        
C     NOT ENOUGH CORE        
C        
  991 IP1 = -8        
      GO TO 999        
C        
C     DATA SET NOT IN FIST        
C        
  992 IP1 = -1        
      GO TO 999        
C        
C     E-O-F ENCOUNTERED        
C        
  993 IP1 = -2        
      GO TO 999        
C        
C     E-O-L ENCOUNTERED        
C        
  994 IP1 = -3        
  999 CALL MESAGE (IP1,FILE,NAME)        
C        
 1000 IF (NOGO .EQ. 0) GO TO 1099        
 1091 CALL MESAGE (-37,0,NAME)        
 1099 RETURN        
C        
 2987 FORMAT (A23,' - APDB MODULE - INVALID PARAMETER NEIGV OR KINDEX', 
     1       ' INPUT.', /40X,        
     2       'DATA BLOCK PVECT (FILE 205) CANNOT BE GENERATED.', /40X,  
     3       7HNEIGV =,I8,10H, KINDEX =,I8)        
 2989 FORMAT (A23,' - MODULE APDB - BULK DATA CARD ',2A4,        
     1       ' MISSING FROM INPUT DECK.')        
 3001 FORMAT (A23,' - APDB MODULE - THE NO. OF STREAML2 CARDS INPUT =', 
     1       I3, /40X,'THERE MUST BE AT LEAST THREE(3) STREAML2 CARDS', 
     2       ' INPUT.')        
 3002 FORMAT (A23,' - APDB MODULE - ILLEGAL NO. OF NODES ON STREAML1 ', 
     1       'CARD WITH SLN =',I8, /40X,        
     2       'ALL STREAML1 CARDS MUST HAVE THE SAME NUMBER OF NODES.')  
 3003 FORMAT (A23,' - APDB MODULE - NO STREAML1 CARD FOR THE STREAML2', 
     1       ' WITH SLN =',I8)        
 3004 FORMAT (A25,' - APDB MODULE - STREAML2 WITH SLN =',I8, /42X,      
     1       'NSTNS INCONSISTENT WITH NO. OF NODES ON STREAML2 CARD ',  
     2       'FOR BLADE ROOT.', /42X,'CORRECT VALUE OF NSTNS WILL BE ', 
     3       'SUBSTITUTED ON STREAML2 CARD.')        
 3005 FORMAT (A23,' - APDB MODULE - STREAML1 CARD WITH SLN =',I8,       
     1       ' REFERENCES NON-EXISTENT EXTERNAL NODE =',I8)        
 3006 FORMAT (A23,' - APDB MODULE - STREAML1 CARD WITH SLN =',I8,       
     1       ' REFERENCES A SCALAR POINT WITH EXTERNAL ID =',I8, /40X,  
     2       'SCALAR POINTS ARE ILLEGAL. USE A GRID POINT.')        
 3007 FORMAT (A23,' - APDB MODULE - MAXIMUM NUMBER OF STREAML2 CARDS ', 
     1       'EXCEEDED FOR LOCAL ARRAY PSTRM.', /40X,        
     2       'UPDATE VARABLE MAXSL AND ARRAY PSTRM IN ROUTINE APDB.',   
     3       /40X,'CURRENT VALUE OF MAXSL AND DIMENSION OF PSTRM =',I4) 
      END        
