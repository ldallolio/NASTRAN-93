      SUBROUTINE APD        
C        
      EXTERNAL        ANDF,ORF        
      LOGICAL         LMKAER ,LSKIP,LSET,LSPLIN        
      INTEGER         IZ(1),FLAG,SILGP        
      INTEGER         EID,PID,CP,CIDBX,ACSID,SILB,SCR1,SCR2,SCR3,SCR4,  
     1                SCR5,ECTA,BGPA,GPLA,USETA,SILA,CSTMA,ACPT,BUF10,  
     2                BUF11,BUF12        
      INTEGER         CAERO2(3),CAERO3(3),CAERO4(3),CAERO5(3)        
      INTEGER         PAERO2(3),PAERO3(3),PAERO4(3),PAERO5(3)        
      INTEGER         KSPL(3),ANDF,FILE        
      INTEGER         SPLIN3(3)        
      INTEGER         CAERO1(3),PAERO1(3),AERO(3),SPLIN 1(3),SPLIN 2(3),
     1                SET1(3),SET2(3),MKAER 2(3),MKAER 1(3),FLUTT R(3), 
     2                AEFACT(3),FLFACT(3),BUF(7),MSG(7),        
     3                BUF1,BUF2,BUF3,BUF4,BUF5,BUF6,BUF7,BUF8,BUF9,     
     4                EDT,EQDYN,ECT,BGPDT,SILD,USETD,CSTM,        
     5                EQAERO,SPLINE,AEROR,FLIST,GPLD,NAM(2),        
     6                AERX(3),SYMXZ,SYMXY,CORWDS,RDREW,CLSREW,        
     7                ORF,SYSBUF,WTREW,PSPA,NBCA(3)        
      INTEGER         CA2S,CA2E,CA3S,CA3E,CA4S,CA4E,CA5S,CA5E        
      INTEGER         PA2S,PA2E,PA3S,PA3E,PA4S,PA4E,PA5S,PA5E        
      INTEGER         MSG1(9),MSG2(5),MSG3(6),MSG4(10)        
      COMMON /BLANK / NK,NJ,LUSETA,BOV        
      COMMON /SYSTEM/ SYSBUF,NOT        
      COMMON /APD1C / EID,PID,CP,NSPAN,NCHORD,LSPAN,LCHORD,IGID,        
     1                X1,Y1,Z1,X12,X4,Y4,Z4,X43,XOP,X1P,ALZO,MCSTM,     
     2                NCST1,NCST2,CIDBX,ACSID,IACS,SILB,NCRD,        
     3                SCR1,SCR2,SCR3,SCR4,SCR5,ECTA,BGPA,GPLA,USETA,    
     4                SILA,CSTMA,ACPT,BUF10,BUF11,BUF12,NEXT,LEFT,ISILN,
     5                NCAM,NAEF1,NAEF2,NCA1,NCA2,CA2S,CA2E,CA3S,CA3E,   
     6                CA4S,CA4E,NPA1,NPA2,PA2S,PA2E,PA3S,PA3E,PA4S,PA4E,
     7                CA5S,CA5E,PA5S,PA5E        
      COMMON /TWO   / ITWO(32)        
      COMMON /BITPOS/ IBIT(64)        
CZZ   COMMON /ZZAPDX/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (Z(1), IZ(1))        
      EQUIVALENCE     (AERX(1),SYMXZ),(AERX(2),SYMXY),(AERX(3),BREF)    
      DATA    RDREW , CLSREW,WTREW /0,1,1 /        
      DATA    MSG1  / 4HSETI,4H AND,4H/OR ,4HSPLI,4HNEI ,4HCARD,4HS RE, 
     1                4HQUIR,4HED  /        
      DATA    MSG2  / 4HNO A,4HERO ,4HCARD,4H FOU,4HND    /        
      DATA    MSG3  / 4HNO C,4HAERO,4H  CA,4HARDS,4HFOUN,4HD    /       
      DATA    MSG4  / 4HNEIT,4HHER ,4HMKAE,4HRO1 ,4HOR  ,4HMKAE,4HRO2 , 
     1                4HCARD,4HS FO,4HUND /        
      DATA    CAERO2/ 4301,43, 0/ , CAERO3 /4401,44, 0 /        
      DATA    CAERO4/ 4501,45, 0/ , PAERO2 /4601,46, 0 /        
      DATA    PAERO3/ 4701,47, 0/ , PAERO4 /4801,48, 0 /        
      DATA    CAERO5/ 5001,50, 0/ , PAERO5 /5101,51, 0 /        
      DATA    SPLIN3/ 4901,49, 0/        
      DATA    KSPL  / 200 , 2, 0/        
      DATA    CAERO1/ 3002,30,16 /, PAERO1 /3102,31,0  /,        
     1        AERO  / 3202,32,0  /, SPLIN1 /3302,33,0  /,        
     2        SPLIN2/ 3402,34,0  /, SET1   /3502,35,0  /,        
     3        SET2  / 3602,36,0  /, MKAER2 /3702,37,0  /,        
     4        MKAER1/ 3802,38,0  /, FLUTTR /3902,39,0  /,        
     5        AEFACT/ 4002,40,0  /, FLFACT /4102,41,0  /,        
     6        NBCA  / 3002,46,0/        
      DATA    EDT   , EQDYN,  ECT, BGPDT, SILD, USETD, CSTM, GPLD /     
     1        101   , 102,    103, 104,   105,  106,   107,  108  /     
      DATA    EQAERO, SPLINE, AEROR, FLIST  /        
     1        201   , 206,    207,   209    /        
     2        
      DATA    MSG   / 7*0 /,  NAM / 4HAPD ,4H    /        
C        
      LCA  = CAERO1(3)        
      NOGO = 0        
      BUF1 = KORSZ(IZ) - SYSBUF        
      BUF2 = BUF1 - SYSBUF        
      BUF3 = BUF2 - SYSBUF        
      BUF4 = BUF3 - SYSBUF        
      BUF5 = BUF4 - SYSBUF        
      BUF6 = BUF5 - SYSBUF        
      BUF7 = BUF6 - SYSBUF        
      BUF8 = BUF7 - SYSBUF        
      BUF9 = BUF8 - SYSBUF        
      BUF10= BUF9 - SYSBUF        
      BUF11= BUF10- SYSBUF        
      BUF12= BUF11- SYSBUF        
      SCR1 = 301        
      SCR2 = 302        
      SCR3 = 303        
      SCR4 = 304        
      SCR5 = 305        
      ECTA = 202        
      BGPA = 203        
      SILA = 204        
      USETA= 205        
      ACPT = 208        
      CSTMA= 210        
      GPLA = 211        
      SILGP= 212        
      LAST = BUF12 - 1        
      IF (LAST .LE. 0) GO TO 995        
      NJ   = 0        
      NK   = 0        
      I17  = IBIT(17)        
      I20  = IBIT(20)        
      PSPA = ORF(ITWO(I17),ITWO(I20))        
C        
C     READ AERO CARDS        
C        
      LEFT = LAST        
      FILE = EDT        
      CALL PRELOC (*940,Z(BUF1),EDT)        
      CALL LOCATE (*800,Z(BUF1),AERO,FLAG)        
      CALL READ (*960,*970,EDT,Z(1),6,1,FLAG)        
      ACSID= IZ(1)        
      IZX  = 2        
      VSOUND = Z(IZX)        
      IZX  = 3        
      BREF = Z(IZX)        
      BOV  = 0.0        
      IF (VSOUND .NE. 0.0) BOV = BREF/(2.0*VSOUND)        
      IZX  = 5        
      SYMXZ= IZ(IZX)        
      IZX  = 6        
      SYMXY= IZ(IZX)        
C        
C     READ AEFACT CARDS        
C        
      NAEF2 = 0        
      CALL APDR (EDT,Z,LEFT,NAEF1,NAEF2,FLAG,BUF1,AEFACT)        
C        
C     READ CSTM TABLE        
C        
      FILE  = CSTM        
      NCST2 = NAEF2        
      NCST1 = 0        
      MCSTM = 0        
      BUF(1)= CSTM        
      CALL RDTRL(BUF)        
      IF (BUF(1) .NE. CSTM) GO TO 100        
      CALL GOPEN (CSTM,Z(BUF2),RDREW)        
      NCST1 = NCST2 + 1        
      CALL READ (*980,*80,CSTM,Z(NCST1),LEFT,0,NCST2)        
      GO TO 970        
   80 CALL CLOSE (CSTM,CLSREW)        
      LEFT  = LEFT  - NCST2        
      NCST2 = NCST1 + NCST2 - 1        
C        
C     FIND LARGEST CID OF CSTM        
C        
      DO 90 J = NCST1,NCST2,14        
      IF (IZ(J) .LT. MCSTM) GO TO 90        
      MCSTM = IZ(J)        
   90 CONTINUE        
C        
C     FIND AC TRANS        
C        
  100 IF (ACSID .EQ. 0) GO TO 120        
      IF (NCST1 .EQ. 0) GO TO 880        
      DO 110 IACS = NCST1,NCST2,14        
      IF (IZ(IACS) .EQ. ACSID) GO TO 120        
  110 CONTINUE        
      GO TO 880        
C        
C     WRITE CSTM TO CSTMA        
C        
  120 CALL GOPEN (CSTMA,Z(BUF2),WTREW)        
      IF (MCSTM .NE. 0) CALL WRITE (CSTMA,Z(NCST1),NCST2-NCST1+1,0)     
      NCSA = MCSTM        
C        
C     READ EQDYN INTO CORE        
C        
      NEXT = NCST2 + 1        
      FILE = EQDYN        
      CALL GOPEN (EQDYN,Z(BUF3),RDREW)        
      CALL SKPREC (EQDYN,1)        
      CALL READ (*980,*140,EQDYN,Z(NEXT),LEFT,0,NX)        
      GO TO 970        
  140 CALL CLOSE (EQDYN,CLSREW)        
      BUF(1) = EQDYN        
      CALL RDTRL (BUF)        
      NEXTRA = BUF(3)        
C        
C     CIDBX = LARGEST ID        
C     NCRD  = NUMBER OF GRID AND SCALAR POINTS        
C        
      NCRD  = BUF(2) - NEXTRA        
      NCRDO = NCRD        
      CIDBX = 1000000        
C        
C     WRITE SECOND RECORD OF EQDYN ONTO SCR1        
C        
      CALL GOPEN (SCR1,Z(BUF3),WTREW)        
      CALL WRITE (SCR1,Z(NEXT),NX,0)        
C        
C     READ BGPDT        
C        
      FILE = BGPDT        
      CALL GOPEN (BGPDT,Z(BUF4),RDREW)        
      CALL READ (*980,*150,BGPDT,Z(NEXT),LEFT,0,NX)        
      GO TO 970        
  150 CALL CLOSE (BGPDT,CLSREW)        
C        
C     WRITE BGPDT TO BGPA        
C        
      CALL GOPEN (BGPA,Z(BUF4),WTREW)        
      CALL WRITE (BGPA,Z(NEXT),NX,0)        
C        
C     READ USETD        
C        
      FILE = USETD        
      CALL GOPEN (USETD,Z(BUF5),RDREW)        
      CALL READ (*980,*160,USETD,Z(NEXT),LEFT,0,NX)        
      GO TO 970        
  160 CALL CLOSE (USETD,CLSREW)        
C        
C     MASK IN PS AND PA BITS        
C        
      N2 = NEXT + NX - 1        
      DO 170 I = NEXT,N2        
  170 IZ(I) = ORF(IZ(I),PSPA)        
C        
C     WRITE USETD TO USETA        
C        
      FILE = USETA        
      CALL GOPEN (USETA,Z(BUF5),WTREW)        
      CALL WRITE (USETA,Z(NEXT),NX,0)        
C        
C     READ ECT        
C        
      FILE   = ECT        
      BUF(1) = ECT        
      CALL GOPEN (ECTA,Z(BUF6),WTREW)        
      CALL RDTRL (BUF)        
      IF (BUF(1) .NE. ECT) GO TO 210        
      CALL GOPEN (ECT,Z(BUF7),RDREW)        
  180 CALL READ (*200,*190,ECT,Z(NEXT),LEFT,0,NX)        
      GO TO 970        
  190 CALL WRITE (ECTA,Z(NEXT),NX,1)        
      GO TO 180        
  200 CALL CLOSE (ECT,CLSREW)        
  210 CALL WRITE (ECTA,NBCA,3,0)        
C        
C     READ FIRST RECORD OF SILD INTO CORE        
C        
      FILE = SILD        
      CALL GOPEN (SILD,Z(BUF8),RDREW)        
      CALL READ (*980,*220,SILD,Z(NEXT),LEFT,0,NX)        
      GO TO 970        
C        
C     WRITE FIRST RECORD OF SILD ONTO SILA        
C        
  220 BUF(1) = SILD        
      CALL RDTRL (BUF)        
C        
C     SILB  + 6 = NEXT DOF IN PROBLEM        
C     ISILN + 6 = NEXT DOF WITHOUT EXTRA POINTS        
C        
      SILB  = BUF(2) - 5        
      ISILN = SILB - NEXTRA        
      CALL GOPEN (SILA,Z(BUF7),WTREW)        
      CALL WRITE (SILA,Z(NEXT),NX,0)        
C        
C     READ SECOND RECORD OF SILD INTO CORE        
C        
      CALL READ (*980,*230,SILD,Z(NEXT),LEFT,0,NX)        
      GO TO 970        
  230 CALL CLOSE (SILD,CLSREW)        
C        
C     WRITE SECOND RECORD OF SILD ONTO SCR2        
C        
      CALL GOPEN (SCR2,Z(BUF8),WTREW)        
      CALL WRITE (SCR2,Z(NEXT),NX,0)        
C        
C     COPY GPLD TO GPLA        
C        
      FILE = GPLD        
      CALL GOPEN (GPLD,Z(BUF9),RDREW)        
      CALL READ (*980,*235,GPLD,Z(NEXT),LEFT,0,NX)        
      GO TO 970        
  235 CALL CLOSE (GPLD,CLSREW)        
      CALL GOPEN (GPLA,Z(BUF9),WTREW)        
      CALL WRITE (GPLA,Z(NEXT),NX,0)        
C        
C     READ CAERO CARDS INTO CORE        
C        
      NCA2 = NCST2        
      LCAS = NCA2 + 1        
      CALL APDR (EDT,Z,LEFT,NCA1,NCA2,FLAG,BUF1,CAERO1)        
      CA2E = NCA2        
      CALL APDR (EDT,Z,LEFT,CA2S,CA2E,FLAG,BUF1,CAERO2)        
      CA3E = CA2E        
      CALL APDR (EDT,Z,LEFT,CA3S,CA3E,FLAG,BUF1,CAERO3)        
      CA4E = CA3E        
      CALL APDR (EDT,Z,LEFT,CA4S,CA4E,FLAG,BUF1,CAERO4)        
      CA5E = CA4E        
      CALL APDR (EDT,Z,LEFT,CA5S,CA5E,FLAG,BUF1,CAERO5)        
      LCAE = MAX0(NCA2,CA2E,CA3E,CA4E,CA5E)        
C        
C     READ PAERO CARDS INTO CORE        
C        
      NPA2 = CA5E        
      CALL APDR (EDT,Z,LEFT,NPA1,NPA2,FLAG,BUF1,PAERO1)        
      PA2E = NPA2        
      CALL APDR (EDT,Z,LEFT,PA2S,PA2E,FLAG,BUF1,PAERO2)        
      PA3E = PA2E        
      CALL APDR (EDT,Z,LEFT,PA3S,PA3E,FLAG,BUF1,PAERO3)        
      PA4E = PA3E        
      CALL APDR (EDT,Z,LEFT,PA4S,PA4E,FLAG,BUF1,PAERO4)        
      PA5E = PA4E        
      CALL APDR (EDT,Z,LEFT,PA5S,PA5E,FLAG,BUF1,PAERO5)        
      NEXT = PA5E + 1        
      CALL CLOSE (EDT,CLSREW)        
      IF (NCA1.EQ.0 .AND. CA2S.EQ.0 .AND. CA3S.EQ.0 .AND. CA4S.EQ.0     
     1   .AND. CA5S.EQ.0) GO TO 820        
C        
C     OPEN ACPT        
C        
      CALL GOPEN (ACPT,Z(BUF1),WTREW)        
C        
C     CALL CAERO TYPE        
C        
      IF (NCA1.NE.0 .OR. CA2S.NE.0) CALL APD12        
      IF (CA3S .NE. 0) CALL APD3        
      IF (CA4S .NE. 0) CALL APD4        
      IF (CA5S .NE. 0) CALL APD5        
      LUSETA = LUSETA + 5        
      CALL WRITE (CSTMA,0,0,1)        
      CALL CLOSE (CSTMA,CLSREW)        
      CALL CLOSE (ACPT,CLSREW)        
      CALL WRITE (ECTA,0,0,1)        
      CALL CLOSE (ECTA,CLSREW)        
      CALL WRITE (BGPA,0,0,1)        
      CALL CLOSE (BGPA,CLSREW)        
      CALL WRITE (GPLA,0,0,1)        
      CALL CLOSE (GPLA,CLSREW)        
      CALL WRITE (USETA,0,0,1)        
      CALL CLOSE (USETA,CLSREW)        
      CALL WRITE (SILA,0,0,1)        
      CALL WRITE (SCR1,0,0,1)        
      CALL CLOSE (SCR1,CLSREW)        
      CALL WRITE (SCR2,0,0,1)        
      CALL CLOSE (SCR2,CLSREW)        
C        
C     READ SECOND RECORD OF EQAERO TABLE OFF SCR1        
C        
      FILE = SCR1        
      CALL GOPEN (SCR1,Z(BUF3),RDREW)        
      I = NEXT        
  411 CONTINUE        
      IF (I+2 .GT. NEXT+LEFT) GO TO 970        
      CALL READ (*980,*420,SCR1,Z(I),2,0,NX)        
      IZ(I+2) = 0        
      I = I + 3        
      GO TO 411        
  420 CALL CLOSE (SCR1,CLSREW)        
      NX = I - NEXT        
C        
C     SORT TABLE ON SILD VALUE        
C        
      CALL SORT (0,0,3,2,Z(NEXT),NX)        
      NY = NEXT + NX - 1        
C        
C     REPLACE THIRD ENTRIES WITH INTERNAL GRID ID WITH OUT EXTRA        
C        
      K = 0        
      DO 412 I = NEXT,NY,3        
      IF (IZ(I+1)-(IZ(I+1)/10)*10 .EQ. 3) GO TO 412        
      K = K + 1        
      IZ(I+2) = K        
  412 CONTINUE        
C        
C     SORT EQAERO TABLE        
C        
      CALL SORT (0,0,3,1,Z(NEXT),NX)        
C        
C     CHECK FOR DUPLICATE EXT ID        
C        
      N1 = NEXT + 3        
      DO 430 I = N1,NY,3        
      IF (IZ(I-3) .NE. IZ(I)) GO TO 430        
      CALL EMSG (0,2329,1,2,0)        
      NOGO = 1        
      WRITE  (NOT,421) IZ(I)        
  421 FORMAT (10X,26HDUPLICATE EXTERNAL ID NO. ,I8,11H GENERATED.)      
  430 CONTINUE        
C        
C     WRITE FIRST RECORD OF EQAERO TABLE        
C        
      CALL GOPEN (EQAERO,Z(BUF3),WTREW)        
      DO 440 I = NEXT,NY,3        
      BUF(1) = IZ(I  )        
      BUF(2) = IZ(I+2)        
  440 CALL WRITE (EQAERO,BUF,2,0)        
      CALL WRITE (EQAERO,0,0,1)        
C        
C     WRITE SECOND RECORD OF EQAERO TABLE        
C        
      DO 441 I = NEXT,NY,3        
  441 CALL WRITE (EQAERO,IZ(I),2,0)        
      CALL WRITE (EQAERO,0,0,1)        
      CALL CLOSE (EQAERO,CLSREW)        
C        
C     PUT ON SPLINE A RECORD OF K POINTS WITH        
C     EXTERNAL ID , BGPA POINTERS, AND K COLUMN NUMBER        
C        
      FILE = USETA        
      N1   = NEXT + NX        
      CALL GOPEN (USETA,Z(BUF3),RDREW)        
      CALL READ (*980,*442,USETA,Z(N1),LEFT-NX,0,N2)        
      GO TO 970        
  442 CALL CLOSE (USETA,CLSREW)        
      CALL GOPEN (SPLINE,Z(BUF3),WTREW)        
      CALL WRITE (SPLINE,KSPL,3,0)        
      MASK = IBIT(19)        
      MASK = ITWO(MASK)        
      KO   = 1        
      N3   = (NCRDO+NEXTRA)*3 + NEXT        
      DO 444 I = NEXT,NY,3        
      IF (MOD(IZ(I+1),10) .NE. 1) GO TO 444        
      K  = 0        
      N4 = IZ(I+1)/10 - 2        
      DO 443 J = 1,6        
      IF (ANDF(IZ(N1+N4+J),MASK) .NE. 0) K = K + 1        
  443 CONTINUE        
      IF (K .EQ. 0) GO TO 444        
      BUF(1) = IZ(I  )        
      BUF(2) = IZ(I+2)        
      BUF(3) = KO        
      CALL WRITE (SPLINE,BUF,3,0)        
      KO = KO + K        
  444 CONTINUE        
      CALL WRITE (SPLINE,0,0,1)        
      CALL CLOSE (SPLINE,2)        
C        
C     READ SECOND RECORD OF SILA TABLE        
C        
      CALL GOPEN (SCR2,Z(BUF8),RDREW)        
      CALL READ  (*980,*450,SCR2,Z(NEXT),LEFT,0,NX)        
      GO TO 970        
  450 CALL CLOSE (SCR2,CLSREW)        
      CALL WRITE (SILA,Z(NEXT),NX,1)        
      CALL CLOSE (SILA,CLSREW)        
C        
C     BUILD SILGP TABLE        
C        
      CALL GOPEN (SILGP,Z(BUF8),W TREW)        
      NY = NEXT + NX - 1        
      K  = 0        
      DO 451 I = NEXT,NY,2        
      IZ(NEXT+K) = IZ(I)        
      K  = K + 1        
  451 CONTINUE        
      CALL WRITE (SILGP,IZ(NEXT),K,1)        
      CALL CLOSE (SILGP,CLSREW)        
C        
C     WRITE RECORD        
C        
      CALL GOPEN (AEROR,Z(BUF2),WTREW)        
      CALL WRITE (AEROR,AERX,3,1)        
C        
C     READ IN MKAERO1 CARDS        
C        
      FILE = EDT        
      CALL PRELOC (*940,Z(BUF1),EDT)        
      LMKAER = .FALSE.        
      CALL LOCATE (*510,Z(BUF1),MKAER1,FLAG)        
      CALL READ (*980,*460,EDT,Z(NEXT),LEFT,0,NX)        
      GO TO 970        
  460 N1 = NEXT        
      LMKAER = .TRUE.        
  470 N2 = N1 + 7        
      DO 490 I = N1,N2        
      IF (IZ(I) .EQ. -1) GO TO 500        
      BUF(1) = IZ(I)        
      N3 = N2 + 1        
      N4 = N3 + 7        
      DO 480 J = N3,N4        
      IF (IZ(J) .EQ. -1) GO TO 490        
      BUF(2) = IZ(J)        
  480 CALL WRITE (AEROR,BUF,2,0)        
  490 CONTINUE        
  500 IF (N4-NEXT+1 .GE. NX) GO TO 510        
      N1 = N1 + 16        
      GO TO 470        
C        
C     READ IN MKAER2 CARDS        
C        
  510 CALL LOCATE (*530,Z(BUF1),MKAER2,FLAG)        
      CALL READ (*980,*520,EDT,Z(NEXT),LEFT,0,NX)        
      GO TO 970        
  520 CALL WRITE (AEROR,Z(NEXT),NX,0)        
      LMKAER =.TRUE.        
  530 CALL WRITE (AEROR,0,0,1)        
      CALL CLOSE (AEROR,CLSREW)        
      IF (LMKAER) GO TO 540        
      GO TO 870        
C        
C     PROCESS SET1 CARDS        
C        
  540 CALL OPEN (*940,SPLINE,Z(BUF2),3)        
      LSET =.FALSE.        
      CALL LOCATE (*610,Z(BUF1),SET1,FLAG)        
      LSET =.TRUE.        
      CALL READ (*980,*550,EDT,Z(NEXT),LEFT,0,NX)        
      GO TO 970        
  550 N3 = NEXT + NX        
      CALL GOPEN (EQAERO,Z(BUF3),RDREW)        
      LEFT = CORWDS(IZ(N3),IZ(LAST))        
      FILE = EQAERO        
      CALL READ (*980,*560,EQAERO,Z(N3),LEFT,0,N4)        
      GO TO 970        
  560 N1 = NEXT        
      FILE = EDT        
      N2 = N1 + NX - 1        
      CALL CLOSE (EQAERO,CLSREW)        
      LEFT = CORWDS(IZ(NEXT),IZ(LAST))        
C        
C     CONVERT SET1 TO INTERNAL COOR NO        
C        
      LSKIP = .TRUE.        
      DO 600 I = N1,N2        
      IF (IZ(I) .EQ. -1) GO TO 590        
      IF (LSKIP) GO TO 580        
      KID = IZ(I)        
      CALL BISLOC (*930,KID,IZ(N3),2,N4/2,JP)        
      K = N3 + JP        
      IF (IZ(K) .GT. NCRDO) GO TO 930        
      IZ(I) = IZ(K)        
      GO TO 600        
  580 LSKIP =.FALSE.        
      GO TO 600        
  930 CALL EMSG (0,2330,1,2,0)        
      NOGO = 1        
      WRITE  (NOT,931) IZ(N1),IZ(I)        
  931 FORMAT (10X,24HSET1 OR SPLIN3 CARD NO. ,I8,28H REFERENCES EXTERNAL
     1 ID NO. ,I8,22H WHICH DOES NOT EXIST.)        
      GO TO 600        
  590 LSKIP = .TRUE.        
  600 CONTINUE        
C        
C     WRITE OUT SET1 CARD ON SPLINE        
C        
      CALL WRITE (SPLINE,SET1,3,0)        
      CALL WRITE (SPLINE,Z(NEXT),NX,1)        
C        
C     PROCESS SET2 CARDS        
C        
  610 CALL LOCATE (*660,Z(BUF1),SET2,FLAG)        
      LSET =.TRUE.        
      CALL WRITE (SPLINE,SET2,3,0)        
  620 CALL READ (*980,*650,EDT,Z(NEXT),8,0,NX)        
      CALL WRITE (SPLINE,Z(NEXT),10,0)        
      NX = IZ(NEXT+1)        
      DO 630 I = LCAS,LCAE,LCA        
      IF (IZ(I) .EQ. NX) GO TO 640        
  630 CONTINUE        
      GO TO 830        
  640 CALL WRITE (SPLINE,Z(I),LCA,0)        
      GO TO 620        
  650 CALL WRITE (SPLINE,0,0,1)        
C        
C     PROCESS SPLINE1 CARDS        
C        
  660 LSPLIN =.FALSE.        
      CALL LOCATE (*710,Z(BUF1),SPLIN1,FLAG)        
      LSPLIN =.TRUE.        
      CALL WRITE (SPLINE,SPLIN 1,3,0)        
      ASSIGN 670 TO IRET        
  670 CALL READ (*980,*700,EDT,Z(NEXT),6,0,NX)        
      GO TO 671        
C        
C     INTERNAL ROUTINE TO ATTACH CAERO DATA TO SPLINE        
C        
  671 CONTINUE        
      CALL WRITE (SPLINE,Z(NEXT),10,0)        
      NX = IZ(NEXT+1)        
      DO 680 I = LCAS,LCAE,LCA        
      IF (IZ(I) .EQ. NX) GO TO 690        
  680 CONTINUE        
      GO TO 810        
  690 CALL WRITE (SPLINE,Z(I),LCA,0)        
      IF (IZ(NEXT+2) .GT. IZ(NEXT+3)) GO TO 691        
      J1 = IZ(I+4)*IZ(I+3) + IZ(I) - 1        
      IF (IZ(NEXT+2).LT.IZ(I) .OR. IZ(NEXT+3).GT.J1) GO TO 691        
      GO TO 693        
  691 NOGO = 1        
      CALL EMSG (0,2331,1,2,0)        
      WRITE  (NOT,692) IZ(NEXT),IZ(I)        
  692 FORMAT (10X,30HBOX PICKED ON SPLINE CARD NO. ,I8,32HNOT GENERATED 
     1BY CAERO CARD NO. ,I8,1H.)        
  693 GO TO IRET, (670,720,7651)        
  700 CALL WRITE (SPLINE,0,0,1)        
C        
C     PROCESS SPLINE2 CARDS        
C        
  710 CALL LOCATE (*760,Z(BUF1),SPLIN2,FLAG)        
      LSPLIN =.TRUE.        
      CALL WRITE (SPLINE,SPLIN 2,3,0)        
      ASSIGN 720 TO IRET        
  720 CALL READ (*980,*750,EDT,Z(NEXT),10,0,NX)        
      GO TO 671        
  750 CALL WRITE (SPLINE,0,0,1)        
C        
C     PROCESS  SPLINE3 CARDS        
C        
  760 NSPLIE = NEXT - 1        
      CALL APDR (EDT,Z,LEFT,NSPLIS,NSPLIE,FLAG,BUF1,SPLIN3)        
      IF (NSPLIS .EQ. 0) GO TO 769        
      FILE = EQAERO        
      N3   = NSPLIE + 1        
      CALL GOPEN (EQAERO,Z(BUF3),RDREW)        
      CALL READ (*980,*761,EQAERO,Z(N3),LEFT,0,N4)        
      GO TO 970        
  761 FILE = EDT        
      CALL CLOSE (EQAERO,CLSREW)        
      N4   = N4/2        
      LSET = .TRUE.        
      LEFT = LEFT + FLAG        
      LSPLIN = .TRUE.        
      ASSIGN 7651 TO IRET        
      CALL WRITE (SPLINE,SPLIN3,3,0)        
      ISP = NSPLIS        
      NLS = 0        
C        
C     PICK UP NEXT SPLIN3 AND ATTACHED CAERO        
C        
  765 ISP = ISP + NLS        
      IF (ISP .GE. NSPLIE) GO TO 768        
      CALL APDOE (IZ(ISP),Z,ISP,NSPLIE,FLAG,NLS)        
      NLS = NLS + 1        
      NX  = IZ(ISP+1)        
      DO 766 I = LCAS,LCAE,LCA        
      J   = I        
      IF (IZ(I) .EQ. NX) GO TO 767        
  766 CONTINUE        
      GO TO 810        
  767 J1  = IZ(I+3)*IZ(I+4) + NX - 1        
      IZ(NEXT) = IZ(ISP)        
      IF (IZ(ISP+2) .LT. IZ(ISP+1)) GO TO 691        
      IF (IZ(ISP+2) .GT. J1) GO TO 691        
C        
C     CONVERT TO INTERNAL ID        
C        
      N2 = NLS - 4        
      DO 7652 I = 1,N2,3        
      N1 = IZ(ISP+I+3)        
      CALL BISLOC (*7653,N1,IZ(N3),2,N4,JP)        
      IF (IZ(N3+JP) .GT. NCRDO) GO TO 7653        
      IZ(ISP+I+3) = IZ(N3+JP)        
 7652 CONTINUE        
 7651 CALL WRITE (SPLINE,NLS+LCA,1,0)        
      CALL WRITE (SPLINE,IZ(ISP),NLS,0)        
      NLS = NLS + 1        
      CALL WRITE (SPLINE,IZ(J),LCA,0)        
      GO TO 765        
 7653 NOGO = 1        
      CALL EMSG (0,2330,1,2,0)        
      WRITE (NOT,931) IZ(ISP),N1        
      GO TO 7651        
  768 CALL WRITE (SPLINE,0,0,1)        
  769 CALL CLOSE (SPLINE,CLSREW)        
C        
C     CREATE FLIST TABLE        
C        
      CALL GOPEN (FLIST,Z(BUF2),WTREW)        
      CALL LOCATE (*800,Z(BUF1),AERO,FLAG)        
      CALL READ (*980,*770,EDT,Z(NEXT),LEFT,0,NX)        
      GO TO 970        
  770 CALL WRITE (FLIST,AERO,3,0)        
      CALL WRITE (FLIST,Z(NEXT),NX,1)        
      CALL LOCATE (*785,Z(BUF1),FLFACT,FLAG)        
      CALL READ (*980,*780,EDT,Z(NEXT),LEFT,1,NX)        
      GO TO 970        
  780 CALL WRITE (FLIST,FLFACT,3,0)        
      CALL WRITE (FLIST,Z(NEXT),NX,1)        
  785 CALL LOCATE (*900,Z(BUF1),FLUTTR,FLAG)        
      CALL READ (*980,*790,EDT,Z(NEXT),LEFT,0,NX)        
      GO TO 970        
  790 CALL WRITE (FLIST,FLUTT R,3,0)        
      CALL WRITE (FLIST,Z(NEXT),NX,1)        
  900 CALL CLOSE (FLIST,CLSREW)        
      CALL CLOSE (EDT,CLSREW)        
      MSG(1) = AEROR        
      MSG(2) = 1        
      CALL WRTTRL (MSG)        
      MSG(1) = EQDYN        
      CALL RDTRL (MSG)        
      MSG(1) = EQAERO        
      MSG(2) = NCRD + NEXTRA        
      CALL WRTTRL (MSG)        
      MSG(1) = BGPDT        
      CALL RDTRL (MSG(1))        
      MSG(3) = NCRD - MSG(2)        
      MSG(1) = BGPA        
      MSG(2) = NCRD        
      CALL WRTTRL (MSG)        
      MSG(1) = SILA        
      MSG(2) = LUSETA        
      MSG(3) = NEXTRA        
      CALL WRTTRL (MSG)        
      MSG(1) = ACPT        
      MSG(2) = 1        
      CALL WRTTRL (MSG)        
      MSG(1) = GPLA        
      MSG(2) = NCRD + NEXTRA        
      CALL WRTTRL (MSG)        
      MSG(1) = CSTM        
      CALL RDTRL (MSG)        
      IF (MSG(1) .LT.0) MSG(3) = 0        
      MSG(1) = CSTMA        
      MSG(3) = MSG(3) + MCSTM - NCSA        
      CALL WRTTRL (MSG)        
      MSG(1) = USETA        
      MSG(2) = LUSETA        
      MSG(3) = NEXTRA        
      MSG(4) = PSPA        
      CALL WRTTRL (MSG)        
      MSG(1) = EDT        
      CALL RDTRL (MSG)        
      MSG(1) = FLIST        
      CALL WRTTRL (MSG)        
      MSG(1) = EDT        
      CALL RDTRL (MSG)        
      MSG(1) = SPLINE        
      MSG(2) = ORF(MSG(2),ITWO(18))        
      CALL WRTTRL (MSG)        
      MSG(1) = ECT        
      CALL RDTRL (MSG)        
      N1     = (NBCA(2)-1)/16 + 2        
      N2     = NBCA(2) - (N1-2)*16 + 16        
      MSG(N1)= ORF(MSG(N1),ITWO(N2))        
      MSG(1) = ECTA        
      CALL WRTTRL (MSG)        
C        
C     PUT OUT SILGP TRAILER        
C        
      MSG(1) = SILGP        
      MSG(2) = NCRD        
      MSG(3) = LUSETA - NEXTRA        
      MSG(4) = 0        
      MSG(5) = 0        
      MSG(6) = 0        
      MSG(7) = 0        
      CALL WRTTRL (MSG)        
      IF (NOGO .EQ. 1) CALL MESAGE (-37,0,NAM)        
      IF (LSET .AND. LSPLIN) RETURN        
C        
C     ERROR MESSAGES        
C        
      CALL EMSG (35,-2328,1,2,MSG1)        
  800 CALL EMSG (18,-2318,1,3,MSG2)        
  810 CALL EMSG (0,-2324,1,2,0)        
      WRITE  (NOT,811) NX        
  811 FORMAT (10X,19HCAERO  ELEMENT NO. ,I8,        
     1        45H REFERENCED ON A SPLINEI CARD DOES NOT EXIST.)        
  812 CALL MESAGE (-61,0,NAM)        
  820 CALL EMSG (21,-2319,1,2,MSG3)        
  830 CALL EMSG (0,-2325,1,2,0)        
      WRITE  (NOT,831) NX        
  831 FORMAT (10X,19HCAERO  ELEMENT NO. ,I8,        
     1        42H REFERENCED ON A SET2 CARD DOES NOT EXIST.)        
      GO TO 812        
  870 CALL EMSG (38,-2322,1,2,MSG4)        
  880 CALL MESAGE (-30,25,ACSID)        
  940 IP1 = -1        
  950 CALL MESAGE (IP1,FILE,NAM)        
  995 IP1 = -8        
      GO TO 950        
  960 IP1 = -2        
      GO TO 950        
  970 IP1 = 3        
      GO TO 950        
  980 GO TO 960        
      END        
