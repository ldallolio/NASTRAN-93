      SUBROUTINE SGEN        
C        
C     THIS MODULE PREPARES THE INPUT FILES TO NASTRAN FROM A SUBSTRUCTUR
C     FORMULATION IN ORDER TO RUN THE SOLUTION PHASE OF NASTRAN.        
C     3 MAJOR STEPS ARE-        
C        
C     1.  READ CONSTRAINT AND DYNAMICS DATA, CONVERT TO PSEUDO-STRUCTURE
C         DATA, AND OUTPUT ON GP4S AND DYNS.        
C        
C     2.  READ LOAD COMBO. DATA AND ASSEMBLE SCALAR LOAD SETS ON OUTPUT 
C         FILE GP3S.        
C        
C     3.  BUILD DUMMY FILES FOR EXECUTION- CASEI, GPL, EQEXIN, GPDT,    
C         BGPDT, CSTM, AND SIL.        
C        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        ANDF,ORF,COMPLF        
      LOGICAL         NOLC,NOLS,PSUEDO,STEST        
      INTEGER         TEMP(10),TEMP2(10),TYPE(2),SPCS1(2),SPCSD(2),     
     1                MPCS(2),SPCS(2),LOADC(2),CTYPES(2,8),CTYPEO(2,8), 
     2                DAREAS(2),DELAYS(2),DPHSES(2),TICS(2),N65535(3),  
     3                MINUS(3),ICODE(4,9),ICOMP(32),LTAB(4,9),MCB(7),   
     4                LSLOAD(3),LLOAD(3),NSGEN(2),NCASEC(2),Z(4)        
      REAL            RZ,FACT,RTEMP(10),RTEMP2(10)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /BLANK / DRY,NAME(2),LUSET,NOGPDT        
      COMMON /SGENCM/ NONO,NSS,IPTR,BUF1,BUF2,BUF3,NZ        
CZZ   COMMON /ZZSGEN/ RZ(1)        
      COMMON /ZZZZZZ/ RZ(1)        
      COMMON /SYSTEM/ IBUF,OUTT        
      COMMON /TWO   / TWO(2)        
      COMMON /UNPAKX/ ITY,IROW,NROW,INCR        
      EQUIVALENCE     (RZ(1),Z(1)),            (TEMP(1),RTEMP(1)),      
     1                (TEMP2(1),RTEMP2(1)),        
     2                (CTYPES(1,1),MPCS(1)),   (CTYPES(1,2),SPCS(1)),   
     3                (CTYPES(1,3),SPCS1(1)),  (CTYPES(1,4),SPCSD(1)),  
     4                (CTYPES(1,5),DAREAS(1)), (CTYPES(1,6),DELAYS(1)), 
     5                (CTYPES(1,7),DPHSES(1)), (CTYPES(1,8),TICS(1))    
      DATA    MINUS , N65535 /3*-1, 3*65535      /,        
     1        EQSS  / 4HEQSS /,     LODS /4HLODS /        
      DATA    CASEC , GEOM3 ,GEOM4 ,DYNAM        /        
     1        101   , 102   ,103   ,104          /,        
     2        CASES , CASEI ,GPL   ,EQEX  ,GPDT  /        
     3        201   , 202   ,203   ,204   ,205   /,        
     4        BGPDT , SIL   ,GP3S  ,GP4S  ,DYNS  /        
     5        206   , 207   ,208   ,209   ,210   /,        
     6        SCRT  , SCRT2 /        
     7        201   , 202   /        
      DATA    PVEC  / 4HPVEC/      ,NSGEN / 4HSGEN,4H    /        
C        
C     BULK DATA CARD CODES        
C        
      DATA    ICODE /        
C             MPCS        
     1                1110  ,11    ,0     ,0      ,        
C             SPCS        
     2                810   ,8     ,0     ,0      ,        
C             SPCS1        
     3                710   ,7     ,0     ,0      ,        
C             SPCSD        
     4                610   ,6     ,0     ,0      ,        
C             LOADC        
     5                500   ,5     ,0     ,0      ,        
C             DAREAS        
     6                9027  ,90    ,0     ,0      ,        
C             DELAYS        
     7                9137  ,91    ,0     ,0      ,        
C             DPHASES        
     8                9277  ,92    ,0     ,0      ,        
C             TICS        
     9                9307  ,93    ,0     ,0      /        
C        
      DATA    NTYPEC / 4 /        
      DATA    NTYPED / 4 /        
      DATA    LTAB   /        
C             MPC        
     1                4901  ,49    ,17    ,1      ,        
C             SPC        
     2                5501  ,55    ,16    ,2      ,        
C             SPC1        
     3                5481  ,58    ,12    ,3      ,        
C             SPCD        
     4                5110  ,51    ,256   ,4      ,        
C             LOADC        
     5                500   ,5     ,264   ,0      ,        
C             DAREA        
     6                27    ,17    ,182   ,5      ,        
C             DELAY        
     7                37    ,18    ,183   ,6      ,        
C             DPHASE        
     8                77    ,19    ,184   ,7      ,        
C             TIC        
     9                6607  ,66    ,137   ,8      /        
      DATA    LLOAD / 4551  ,61    ,84    /       ,        
     1        LSLOAD/ 5401  ,54    ,25    /        
      DATA    MPCS  / 4HMPCS,4H    /,     SPCS   / 4HSPCS,4H     /,     
     1        SPCS1 / 4HSPCS,4H1   /,     SPCSD  / 4HSPCS,4HD    /,     
     2        LOADC / 4HLOAD,4HC   /,     DAREAS / 4HDARE,4HAS   /,     
     3        DELAYS/ 4HDELA,4HYS  /,     DPHSES / 4HDPHA,4HSES  /,     
     4        TICS  / 4HTICS,4H    /        
      DATA    NCASEC/ 4HCASE,4HCC  /        
      DATA    CTYPEO/ 4HMPC ,4H    ,        
     1                4HSPC ,4H    ,        
     2                4HSPC1,4H    ,        
     3                4HSPCD,4H    ,        
     4                4HDARE,4HA   ,        
     5                4HDELA,4HY   ,        
     6                4HDPHA,4HSE  ,        
     7                4HTIC ,4H    /        
      DATA    XXXX  / 4HXXXX       /        
C        
C     INITIALIZE        
C        
      ITY  = 1        
      INCR = 1        
      NONO = 0        
      LARGE= TWO(2)        
      NZ   = KORSZ(Z(1))        
      IBS1 = NZ   - IBUF + 1        
      IBS2 = IBS1 - IBUF - 1        
      IBS3 = IBS2 - IBUF        
      BUF1 = IBS3 - IBUF        
      BUF2 = BUF1 - IBUF        
      BUF3 = BUF2 - IBUF        
      BUF4 = BUF3 - IBUF        
      NZ   = BUF4 - 1        
      IF (NZ .LE. 0) GO TO 5011        
      IF (NAME(1).EQ.XXXX .AND. NAME(2).EQ.XXXX) GO TO 3000        
C        
C     INITIALIZE LUSET AND NOGPDT FLAGS        
C        
      LUSET  = 0        
      NOGPDT = -1        
C        
C     FORM TABLES OF REFERENCED SID-S FOR LOAD, MPC, AND SPC        
C     CASE CONTROL CARDS.        
C        
C     CALL GOPEN (CASEC,Z(BUF1),0)        
C  10 CALL FREAD (CASEC,TEMP,2,1)        
C     IF (TEMP(1).NE.NCASEC(1) .OR. TEMP(2).NE.NCASEC(2)) GO TO 10      
C     NSC = 0        
C  20 CALL READ (*30,*9003,CASEC,TEMP,4,1,NWDS)        
C     NSC = NSC + 1        
C     IF (NSC .GT. 100) GO TO 6328        
C     LOAD(NSC) = TEMP(4)        
C     MPC(NSC)  = TEMP(2)        
C     SPC(NSC)  = TEMP(3)        
C     GO TO 20        
C  30 CALL CLOSE (CASEC,1)        
C        
C     OPEN  SOF , GET EQSS ITEM , READ  SIL DATA INTO CORE        
C        
      CALL SOFOPN (Z(IBS1),Z(IBS2),Z(IBS3))        
      CALL SFETCH (NAME,EQSS,1,FLAG)        
      ITEM  = EQSS        
      IF (FLAG .NE. 1) GO TO 5001        
      CALL SUREAD (Z(1),NZ,NWDS,FLAG)        
      IF (FLAG .NE. 2) GO TO 5011        
      NSS = Z(3)        
      IZ  = NWDS + 1        
C        
C     READ SIL GROUP INTO CORE        
C        
      CALL SJUMP (NSS)        
      CALL SUREAD (Z(IZ),NZ-IZ+1,NSIL,FLAG)        
      IF  (FLAG .NE. 2) GO TO 5011        
      IPT =  IZ + NSIL - 2        
C        
C     FIND LENGTH OF VECTOR = LUSET        
C        
      IC = Z(IPT+1)        
      CALL DECODE (IC,ICOMP,NC)        
      LUSET = Z(IPT) + NC - 1        
      NOGPDT= LUSET        
C        
C     READ EQSS ( G ,IP, AND C AT A TIME) AND CONVERT IP TO SIL .       
C     WRITE ON SCRT        
C        
      IS   = 0        
      FILE = SCRT        
      CALL GOPEN (SCRT,Z(BUF2),1)        
      CALL SFETCH (NAME,EQSS,1,FLAG)        
      NJ = 1        
      CALL SJUMP (NJ)        
C        
   50 CALL SUREAD (TEMP,3,NWDS,FLAG)        
      IF (FLAG .NE. 1) GO TO 100        
      IPT  = IZ + 2*TEMP(2) - 2        
      TEMP(2) = Z(IPT)        
      CALL WRITE (SCRT,TEMP,3,0)        
      GO TO 50        
  100 IS = IS + 1        
      CALL WRITE (SCRT,TEMP,0,1)        
      IF (IS .LT. NSS) GO TO 50        
      CALL CLOSE (SCRT,1)        
C        
C     READ CONVERTED EQSS INTO CORE, STORE POINTERS TO THE BASIC  SUBS  
C     IN  Z(IPTR) TO Z(NPTR)        
C     CORE WILL CONTAIN-        
C       1. 4 WORD HEADER        
C       2. 2*NSS NAMES        
C       3. NSS+1 POINTERS TO EACH BASIC SUBST.BLOCK        
C       4. NSS BLOCKS OF G, IP, C DATA        
C       5. NZB LEFT OVER        
C        
C        
      IPTR = IZ        
      NPTR = IPTR        
      ISUB = IPTR + NSS + 1        
      NZB  = NZ - ISUB + 1        
      FILE = SCRT        
      CALL GOPEN (SCRT,Z(BUF2),0)        
      DO 200 I = 1,NSS        
      Z(NPTR) = ISUB        
      NPTR = NPTR + 1        
      CALL READ (*9002,*110,SCRT,Z(ISUB),NZB,1,NWDS)        
      GO TO 5011        
  110 ISUB = ISUB + NWDS        
      NZB  = NZB  - NWDS        
      IF (NZB .LE. 0) GO TO 5011        
  200 CONTINUE        
      Z(NPTR) = ISUB        
      CALL CLOSE (SCRT,1)        
C        
C     ***  GEOM4 DATA CONVERSION  ***        
C        
C          IN  - MPCS,SPCS,SPCS1,SPCSD CARDS        
C          OUT - MPC ,SPC ,SPC1 ,SCPD  ON SCRT        
C        
      FILE = GEOM4        
      NOG4 = 0        
      CALL PRELOC (*400,Z(BUF1),GEOM4)        
      MCB(1) = GEOM4        
      CALL RDTRL (MCB)        
      CALL GOPEN (SCRT,Z(BUF2),1)        
      STEST = .FALSE.        
C        
C     ***  MPCS CARDS  ***        
C        
C          IN  - NAME(2), G, C, F        
C          OUT - SIL, 0, F        
C        
      CALL LOCATE (*350,Z(BUF1),ICODE(1,1),IDX)        
      CALL WRITE (SCRT,ICODE(1,1),3,0)        
      STEST = .TRUE.        
      ICODE(4,1) = 1        
      TYPE(1) = MPCS(1)        
      TYPE(2) = MPCS(2)        
      IFL = 0        
      LID = 0        
  305 CALL READ (*9002,*346,GEOM4,J,1,0,NWDS)        
      IF (J .NE. LID) NSILD = 0        
      LID = J        
      CALL WRITE (SCRT,J,1,0)        
  310 CALL READ (*9002,*346,GEOM4,TEMP,5,0,NWDS)        
      IF (TEMP(3) .EQ.-1) GO TO 345        
      IF (TEMP(3) .EQ. 0) GO TO 310        
C        
C     FIND  REQUESTED SUBSTRUCTURE        
C        
      DO 320 I = 1,NSS        
      INAM = 2*I + 3        
      IF (Z(INAM).EQ.TEMP(1) .AND. Z(INAM+1).EQ.TEMP(2)) GO TO 330      
  320 CONTINUE        
C        
C     SUBSTRUCTURE NOT FOUND        
C        
      WRITE (OUTT,63290) UWM,TEMP(1),TEMP(2),TYPE,NAME        
      GO TO 310        
C        
C     FOUND SUBSTRUCTURE NAME        
C        
  330 IPT  = IPTR + I - 1        
      IGRD =  Z(IPT)        
      NGRD = (Z(IPT+1) - Z(IPT))/3        
C        
C     SEARCH FOR GRID POINT        
C        
      CALL BISLOC (*334,TEMP(3),Z(IGRD),3,NGRD,IGR)        
      IG = IGR + IGRD - 1        
  325 IF (Z(IG-3) .NE. Z(IG)) GO TO 331        
      IF (IG .LE. IGRD) GO TO 331        
      IG = IG - 3        
      GO TO 325        
  331 CODE = Z(IG+2)        
C        
C     FIND   THE  COMPONENT        
C        
      CALL DECODE (CODE,ICOMP,NC)        
      IF (TEMP(4) .EQ. 0) TEMP(4) = 1        
      DO 332 I = 1,NC        
      IF (TEMP(4) .NE. ICOMP(I)+1) GO TO 332        
      IC = I        
      GO TO 340        
  332 CONTINUE        
      IF (Z(IG+3) .NE. Z(IG)) GO TO 334        
      IF (IG+3 .GE. IGRD+3*NGRD) GO TO 334        
      IG = IG + 3        
      GO TO 331        
C        
C     BAD COMPONENT        
C        
  334 NONO = 1        
      WRITE (OUTT,60220) UFM,(TEMP(I),I=1,4),TYPE,NAME        
      GO TO 310        
C        
C     WRITE CONVERTED DATA ON SCRT        
C        
  340 TEMP(6) = Z(IG+1) + IC - 1        
      TEMP(7) = 0        
      TEMP(8) = TEMP(5)        
      CALL WRITE (SCRT,TEMP(6),3,0)        
C        
C     CHECK FOR DUPLICATE DEPENDENT SIL-S        
C        
      IF (IFL  .NE.  0) GO TO 310        
      IF (NSILD .EQ. 0) GO TO 343        
      DO 342 I = 1,NSILD        
      IF (Z(ISUB+I-1) .NE. TEMP(6)) GO TO 342        
      NONO = 1        
      WRITE (OUTT,63620) UFM,J,TEMP(1),TEMP(2),TEMP(3),TEMP(4)        
  342 CONTINUE        
      IF (NSILD .GT. NZB) GO TO 5011        
  343 Z(ISUB+NSILD) = TEMP(6)        
      NSILD = NSILD + 1        
      IFL = 1        
      GO TO 310        
C        
C     FINISHED ONE LOGICAL CARD, WRITE -1 FLAGS        
C        
  345 CALL WRITE (SCRT,MINUS,3,0)        
      IFL = 0        
      GO TO 305        
C        
C     FINISHED ALL MPCS CARDS, WRITE EOR AND UPDATE TRAILER        
C        
  346 CALL WRITE (SCRT,TEMP,0,1)        
C        
C     TURN OFF MPCS BIT        
C        
      J = (ICODE(2,1)-1)/16        
      I =  ICODE(2,1)- 16*J        
      MCB(J+2) = ANDF(COMPLF(TWO(I+16)),MCB(J+2))        
C        
C     TURN ON MPC BIT        
C        
      J = (LTAB(2,1)-1)/16        
      I =  LTAB(2,1)- 16*J        
      MCB(J+2) = ORF(TWO(I+16),MCB(J+2))        
C        
C     ***  SPCS CARDS  ***        
C        
C          IN  - SID, NAME(2), G, C, G, C, G, C, ..., -1, -1        
C          OUT - SID, SIL, 0, 0 - REPEATED FOR EACH GRID        
C        
  350 CALL SGENA (SPCS,Z(BUF1),MCB,GEOM4,ICODE(1,2),0,SCRT,LTAB(1,2),1) 
C        
C     ***  SPCS1 CARDS  ***        
C        
C          IN  - SID, NAME(2), C, G, G, G, ..., -1        
C          OUT - SID, 0, SIL, -1 - REPEATED FOR EACH GRID        
C        
      CALL SGENB (SPCS1,Z(BUF1),MCB,GEOM4,ICODE(1,3),0,SCRT,LTAB(1,3),1)
C        
C     ***  SPCSD CARDS  ***        
C        
C          IN  - SID, NAME(2), G, C, Y, ..., -1, -1, -1        
C          OUT - SID, SIL, 0, Y - REPEATED FOR EACH GRID        
C        
      CALL SGENA (SPCSD,Z(BUF1),MCB,GEOM4,ICODE(1,4),1,SCRT,LTAB(1,4),1)
C        
C     END OF CONSTRAINT CARD CONVERSION        
C        
      CALL CLOSE (GEOM4,1)        
      CALL CLOSE (SCRT,1)        
      MCB(1) = GP4S        
      CALL WRTTRL (MCB)        
      GO TO 700        
  400 NOG4 = 1        
C        
C     ***  DYNAMICS DATA CONVERSION  ***        
C        
C          IN  - DAREAS,DELAYS,DPHASES,TICS CARDS        
C          OUT - DAREA ,DELAY ,DPHASE ,TIC  ON SCRT        
C        
  700 FILE  = DYNAM        
      NODYN = 0        
      CALL PRELOC (*750,Z(BUF1),DYNAM)        
      MCB(1) = DYNAM        
      CALL RDTRL (MCB)        
      CALL GOPEN (SCRT2,Z(BUF2),1)        
C        
C     ***  DAREAS  CARDS ***        
C        
C          IN  - SID, NAME(2), G, C, A, ..., -1, -1, -1        
C          OUT - SID, SIL, 0, A - REPEATED FOR EACH GRID        
C        
      CALL SGENA (DAREAS,Z(BUF1),MCB,DYNAM,ICODE(1,6),1,SCRT2,LTAB(1,6),
     1            1)        
C        
C     ***  DELAYS CARDS  ***        
C        
C          IN  - SID, NAME(2), G, C, T, ..., -1, -1, -1        
C          OUT - SID, SIL, 0, T - REPEATED FOR EACH GRID        
C        
      CALL SGENA (DELAYS,Z(BUF1),MCB,DYNAM,ICODE(1,7),1,SCRT2,LTAB(1,7),
     1            1)        
C        
C    ***  DPHASES CARDS  ***        
C        
C         IN  - SID, NAME(2), G, C, TH, ..., -1, -1, -1        
C         OUT - SID, SIL, 0, TH - REPEATED FOR EACH GRID        
C        
      CALL SGENA (DPHSES,Z(BUF1),MCB,DYNAM,ICODE(1,8),1,SCRT2,LTAB(1,8),
     1            1)        
C        
C     ***  TICS CARDS  ***        
C        
C          IN  - SID, NAME(2), G, C, U, V, ..., -1, -1, -1, -1        
C          OUT - SID, SIL, 0, U, V - REPEATED FOR EACH GRID        
C        
      CALL SGENA (TICS,Z(BUF1),MCB,DYNAM,ICODE(1,9),2,SCRT2,LTAB(1,9),2)
C        
C     END OF DYNAMICS CONVERSION        
C        
      CALL CLOSE (DYNAM,1)        
      CALL CLOSE (SCRT2,1)        
      MCB(1) = DYNS        
      CALL WRTTRL (MCB)        
      GO TO 1000        
  750 NODYN = 1        
C        
C     MERGE CONVERTED DATA WITH EXISTING DATA - GEOM4        
C        
 1000 IF (NOG4 .EQ. 1) GO TO 1500        
      CALL SGENM (NTYPEC,GEOM4,SCRT,GP4S,ICODE(1,1),LTAB(1,1),        
     1            CTYPES(1,1),CTYPEO(1,1))        
C        
C     MERGE CONVERTED DATA WITH EXISTING DATA - DYNAMICS        
C        
 1500 IF (NODYN .EQ. 1) GO TO 2005        
      CALL SGENM (NTYPED,DYNAM,SCRT2,DYNS,ICODE(1,6),LTAB(1,6),        
     1            CTYPES(1,1),CTYPEO(1,1))        
C        
C        
C     ***  GEOM3 PROCESSING  ***        
C        
C     THE LOAD VECTORS ARE COMBINED BY THE FACTORS        
C     GIVEN ON THE LOADC CARDS AND MERGED WITH SLOAD CARDS        
C        
 2005 CONTINUE        
      NOLC = .TRUE.        
      NOLS = .TRUE.        
      CALL PRELOC (*2350,Z(BUF1),GEOM4)        
      CALL LOCATE (*2350,Z(BUF1),ICODE(1,5),IDX)        
C        
C     READ FIRST GROUP OF LODS ITEM FOR SOLUTION STRUCTURE        
C        
      ITEM = LODS        
      CALL SFETCH (NAME,LODS,1,FLAG)        
      GO TO (2045,5001,2042,5001,5001), FLAG        
C        
C     LODS ITEM DOES NOT EXIST        
C        
 2042 NOLC = .TRUE.        
      GO TO 2350        
 2045 CALL SUREAD (Z(1),NZ,NWDS,ITEST)        
      GO TO (5011,2047,5002), ITEST        
 2047 NSS = Z(4)        
      ISS1= 5        
      NL  = Z(3)        
      IPT = 2*NSS + 5        
      IZL = 2*NSS + IPT + 2        
      Z(IPT  ) = IZL        
      Z(IPT+1) = 0        
      IF (IZL+NSS+NL .LE. NZ) GO TO 2050        
C        
C     INSUFFICIENT CORE        
C        
      CALL CLOSE (GEOM4,1)        
      GO TO 5011        
C        
C     READ REMAINDER OF LODS INTO OPEN CORE AT Z(IZL)        
C        
 2050 DO 2100 I = 1,NSS        
      CALL SUREAD (Z(IZL),NZ-IZL+1,NWDS,ITEST)        
      GO TO (5011,2060,5002), ITEST        
 2060 IZL= IZL + NWDS        
      JG = IPT + 2*I        
      Z(JG  ) = IZL        
      Z(JG+1) = Z(JG-1) + NWDS - 1        
 2100 CONTINUE        
C        
C     CORE NOW CONTAINS        
C        
C            WORDS                 CONTENTS        
C        ------------------    -----------------------------------      
C        1--(IPT-1)            HEADER GROUP        
C        IPT--IPT+2*(NSS+1)    LOAD DATA POINTER, NO. OF PRIOR LOAD     
C                                  VECTORS (2 WORDS PER STRUCTURE)      
C        IPT+2*(NSS+1)+1 --=   NO OF LOADS + LOAD SET IDS        
C                                  GROUPED BY BASIC STRUCTURE        
C        
C     READ LOADC DATA CARDS AND CONVERT        
C        
C          IN  - SET ID, FACTOR, (NAME(2),SET,FACTOR) (REPEATED)        
C          OUT - SET ID, FACTOR, (VECTOR NO.,FACTOR)        
C        
      TYPE(1) = LOADC(1)        
      TYPE(2) = LOADC(2)        
      CALL OPEN (*9001,SCRT,Z(BUF2),1)        
 2150 CALL READ (*9002,*2300,GEOM4,TEMP,2,0,NWDS)        
      CALL WRITE (SCRT,TEMP,2,0)        
      LID = TEMP(1)        
      NOLC=.FALSE.        
C        
C     READ AN ENTRY        
C        
 2160 CALL FREAD (GEOM4,TEMP,4,0)        
      IF( TEMP(3) .EQ. -1) GO TO 2280        
C        
C     FIND SUBSTRUCTURE AND SET        
C        
      DO 2210 I = 1,NSS        
      INAM = ISS1 + 2*(I-1)        
      IF (Z(INAM).EQ.TEMP(1) .AND. Z(INAM+1).EQ.TEMP(2)) GO TO 2220     
 2210 CONTINUE        
C        
C     SUBSTRUCTURE NOT FOUND        
C        
      WRITE (OUTT,63290) UWM,TEMP(1),TEMP(2),TYPE,NAME        
      GO TO 2160        
C        
C     FOUND SUBSTRUCTURE NAME        
C        
 2220 JPT = IPT + 2*I - 2        
C        
C     POINTER TO LODS DATA FOR THIS SUBSTRUCTURE        
C        
      ILD = Z(JPT)        
C        
C     NUMBER OF SETS IN LODS DATA FOR THIS SUBSTRUCTURE        
C        
      NSET = Z(ILD)        
C        
C     FIND LOADC SET IN LODS DATA        
C        
      IF (NSET .EQ. 0) GO TO 2240        
      DO 2230 I = 1,NSET        
      IP = ILD + I        
      IF (Z(IP) .NE. TEMP(3)) GO TO 2230        
      LVEC = Z(JPT+1) + I        
      GO TO 2250        
 2230 CONTINUE        
C        
C     SET NOT FOUND        
C        
 2240 NONO = 1        
      WRITE (OUTT,63310) UFM,NAME,LID,TEMP(3),TEMP(1),TEMP(2)        
      GO TO 2160        
 2250 TEMP(1) = LVEC        
      TEMP(2) = TEMP(4)        
      CALL WRITE (SCRT,TEMP,2,0)        
      GO TO 2160        
C        
C     END OF LOGICAL LOADC CARD        
C        
 2280 CALL WRITE (SCRT,TEMP,0,1)        
      GO TO 2150        
C        
C     END OF LOADC RECORD        
C        
 2300 CALL CLOSE (SCRT,1)        
 2350 CALL CLOSE (GEOM4,1)        
C        
C     MERGE CONVERTED LOAD DATA WITH SLOAD DATA.        
C        
C        
C     IF ANY ERRORS WERE DETECTED, SKIP LOAD COMPUTATION        
C        
      IF (NONO .NE. 0) GO TO 3000        
      CALL GOPEN (GP3S,Z(BUF4),1)        
C        
C     COPY LOAD CARDS TO GP3S        
C        
      CALL PRELOC (*2430,Z(BUF1),GEOM3)        
      LDCD = 0        
      CALL LOCATE (*2420,Z(BUF1),LLOAD,IDX)        
      LDCD = 1        
      CALL WRITE (GP3S,LLOAD,3,0)        
 2405 CALL READ (*9002,*2410,GEOM3,Z(1),NZ,0,NWDS)        
      CALL WRITE (GP3S,Z(1),NZ,0)        
      GO TO 2405        
 2410 CALL WRITE (GP3S,Z(1),NWDS,1)        
C        
C     POSITION TO SLOAD CARDS        
C        
 2420 CALL LOCATE (*2430,Z(BUF1),LSLOAD,IDX)        
      NOLS = .FALSE.        
 2430 IF (NOLS) CALL CLOSE (GEOM3,1)        
      IF (.NOT.(NOLS .AND. NOLC)) CALL WRITE (GP3S,LSLOAD,3,0)        
      IF (NOLC) GO TO 2530        
C        
C     COPY LOAD VECTORS TO SCRATCH FILE        
C        
      FILE = SCRT2        
      ITEM = PVEC        
      IF (DRY .LT. 0) GO TO 2510        
      CALL MTRXI (SCRT2,NAME,PVEC,Z(BUF3),FLAG)        
      GO TO (2520,2431,5001,5001,5001,9001), FLAG        
 2431 FLAG = 3        
      GO TO 5001        
C        
C     IN DRY RUN MODE, LOADS PSEUDO-EXIST        
C        
 2510 PSUEDO =.TRUE.        
      GO TO 2530        
C        
C     LOADS EXIST        
C        
 2520 PSUEDO = .FALSE.        
      CALL GOPEN (SCRT2,Z(BUF3),0)        
      IREC   = 1        
      MCB(1) = SCRT2        
      CALL RDTRL (MCB)        
      NVEC  = MCB(2)        
      LUSET = MCB(3)        
      IF (2*LUSET .LT. NZ) GO TO 2530        
C        
C     INSUFFICIENT CORE        
C        
      CALL CLOSE (SCRT2,1)        
      CALL CLOSE (GP3S ,1)        
      CALL CLOSE (GEOM3,1)        
      GO TO 5011        
C        
C     MERGE REAL AND ARTIFICIAL SLOAD CARDS        
C        
 2530 SIDC = 0        
      IROW = 1        
      NROW = LUSET        
      IF (.NOT.NOLC) CALL OPEN (*9001,SCRT,Z(BUF2),0)        
 2550 IF (NOLS) GO TO 2560        
      FILE = GEOM3        
      CALL READ (*9002,*2560,GEOM3,TEMP2,3,0,NWDS)        
      GO TO 2570        
 2560 IF (NOLC) GO TO 2900        
      TEMP2(1) = LARGE        
 2570 SIDS = TEMP2(1)        
      IF (NOLC) GO TO 2635        
      IF (SIDC .GT. SIDS) GO TO 2600        
C        
C     READ THE SID AND FACTOR OF THE LOADC CARD ITSELF        
C        
      FILE = SCRT        
      CALL READ (*2580,*9003,SCRT,TEMP,2,0,NWDS)        
      GO TO 2600        
 2580 TEMP(1) = LARGE        
      NOLC = .TRUE.        
      CALL CLOSE (SCRT,1)        
      IF (NOLS) GO TO 2900        
 2600 CONTINUE        
      DO 2620 I = 1,LUSET        
 2620 RZ(I) = 0.0        
      SIDC = TEMP(1)        
      FACT = RTEMP(2)        
      IF (.NOT.NOLC) GO TO 2670        
 2635 IF (NOLS) GO TO 2900        
C        
C     NO MORE LOADC CARDS, WRITE ENTIRE  SLOAD  RECORD        
C        
      CALL WRITE (GP3S,TEMP2,3,0)        
      FILE = GEOM3        
 2640 CALL READ (*9002,*2650,GEOM3,Z(1),NZ,0,NWDS)        
      CALL WRITE (GP3S,Z(1),NZ,0)        
      GO TO 2640        
 2650 CALL WRITE (GP3S,Z(1),NWDS,1)        
      GO TO 2900        
 2670 IF (.NOT.NOLS) GO TO 2680        
C        
C     NO MORE SLOAD CARDS ARE PRESENT        
C        
      SIDS = LARGE        
      GO TO 2700        
C        
C     BOTH LOADC AND SLOAD CARDS ARE PRESENT        
C        
 2680 IF (SIDS .LT. SIDC) GO TO 2810        
C        
C     READ LOADC DATA, FIND VECTOR, UNPACK, MULT BY FACTOR, AND ADD     
C     TO FIND A MATRIX COLUMN,USING FWDREC, CHANGE ON 16        
C        
 2700 FILE = SCRT        
      CALL READ (*9002,*2790,SCRT,TEMP,2,0,NWDS)        
      IF (TEMP(1).EQ.0 .OR. PSUEDO .OR. TEMP(2).EQ.0) GO TO 2700        
      N = TEMP(1) - IREC        
      IF (N) 2710,2750,2720        
 2710 N = -N        
      DO 2715 I = 1,N        
      CALL BCKREC (SCRT2)        
 2715 CONTINUE        
      GO TO 2750        
 2720 DO 2725 I = 1,N        
      CALL FWDREC (*2730,SCRT2)        
 2725 CONTINUE        
      GO TO 2750        
C        
C     CANT FIND LOAD VECTOR        
C        
 2730 WRITE (OUTT,63320) SFM,TEMP(1),NVEC,LUSET,NAME        
      NONO = 1        
      GO TO 2900        
C        
C     NOW SCRT2 IS POSITIONED TO THE DESIRED LOAD VECTOR.  UNPACK IT AND
C     FACTOR AND ADD IT TO VECTOR AT TOP OF OPEN CORE        
C        
 2750 IREC = TEMP(1) + 1        
      CALL UNPACK (*2700,SCRT2,RZ(LUSET+1))        
      DO 2755 I = 1,LUSET        
      RZ(I) = RTEMP(2)*FACT*RZ(LUSET+I)+RZ(I)        
 2755 CONTINUE        
      GO TO 2700        
C        
C     HERE WHEN FINISHED COMBINING VECTORS FOR ONE LOADC CARD        
C        
 2790 CONTINUE        
      IF (SIDC .LT. SIDS) GO TO 2850        
 2810 IZ = TEMP2(2)        
      RZ(IZ) = RZ(IZ) +RTEMP2(3)        
      FILE = GEOM3        
      CALL READ (*9002,*2840,GEOM3,TEMP2,3,0,NWDS)        
      IF (TEMP2(1) .EQ. SIDS) GO TO 2810        
      SIDS = TEMP2(1)        
      GO TO 2850        
 2840 NOLS =.TRUE.        
C        
C     WRITE OUT LOAD VECTOR IN SLOAD FORMAT        
C        
 2850 TEMP(1) = MIN0(SIDS,SIDC)        
      DO 2860 I = 1,LUSET        
      IF (RZ(I) .EQ. 0.0) GO TO 2860        
      TEMP(2)  = I        
      RTEMP(3) = RZ(I)        
      CALL WRITE (GP3S,TEMP,3,0)        
 2860 CONTINUE        
      IF (SIDS .NE. SIDC) GO TO 2570        
      GO TO 2550        
C        
C     ALL LOADS PROCESSED        
C        
 2900 CALL WRITE (GP3S,0,0,1)        
      CALL WRITE (GP3S,N65535,3,1)        
      CALL CLOSE (SCRT,1)        
      CALL CLOSE (GP3S,1)        
      CALL CLOSE (SCRT2,1)        
      CALL CLOSE (GEOM3,1)        
      MCB(1) = GP3S        
C        
C     TURN ON SLOAD BIT IN GP3S TRAILER        
C     ALSO LOAD CARD BIT IF LOAD CARDS EXIST        
C        
      DO 2910 I = 2,7        
 2910 MCB(I) = 0        
      J = (LSLOAD(2)-1)/16        
      I = LSLOAD(2)-16*J        
      MCB(J+2) = TWO(I+16)        
      IF (LDCD .EQ. 0) GO TO 2920        
      J = (LLOAD(2)-1)/16        
      I = LLOAD(2)-16*J        
      MCB(J+2) = ORF(MCB(J+2),TWO(I+16))        
 2920 CALL WRTTRL (MCB)        
C        
C     SPLIT CASE CONTROL  INTO SUBSTRUCTURE AND NORMAL NASTRAN        
C        
 3000 CALL OPEN (*9001,CASEC,Z(BUF1),0)        
      CALL OPEN (*9001,CASES,Z(BUF2),1)        
      CALL OPEN (*9001,CASEI,Z(BUF3),1)        
      FILE = CASES        
 3250 CALL READ (*3800,*3350,CASEC,Z(1),NZ,0,NWDS)        
 3350 IF (Z(1).EQ.NCASEC(1) .AND. Z(2).EQ.NCASEC(2)) FILE = CASEI       
      CALL WRITE (CASES,Z,NWDS,1)        
      IF (FILE .EQ. CASEI) CALL WRITE (CASEI,Z(1),NWDS,1)        
      GO TO 3250        
 3800 CONTINUE        
      MCB(1) = CASEC        
      CALL RDTRL (MCB)        
      MCB(1) = CASES        
      CALL WRTTRL (MCB)        
      MCB(1) = CASEI        
      CALL WRTTRL (MCB)        
      CALL CLOSE (CASEC,1)        
      CALL CLOSE (CASEI,1)        
      CALL CLOSE (CASES,1)        
      IF (NAME(1).EQ.XXXX .AND. NAME(2).EQ.XXXX) RETURN        
      IF (NONO .NE. 0) GO TO 4050        
C        
C     GENERATE  FICTITIOUS GP1 DATA BLOCKS        
C        
C        
C     ***  GPL FILE  ***        
C        
C     GPL HEADER RECORD HAS 3 WORD, (SEE GP1)        
C     SET THE 3RD WORD, MULTIPLIER MULT, TO 1000        
C        
      DO 4005 I = 2,7        
 4005 MCB(I) = 0        
      MCB(1) = GPL        
      FILE   = GPL        
      N = -1        
      CALL OPEN (*9200,GPL,Z(BUF1),1)        
      CALL FNAME (GPL,TEMP(1))        
      TEMP(3) = 1000        
      CALL WRITE (GPL,TEMP(1),3,1)        
      DO 4010 I = 1,LUSET        
 4010 CALL WRITE (GPL,I,1,0)        
      CALL WRITE (GPL,I,0,1)        
      DO 4020 I = 1,LUSET        
      TEMP(1) = I        
      TEMP(2) = 1000*I        
      CALL WRITE (GPL,TEMP,2,0)        
 4020 CONTINUE        
      CALL WRITE (GPL,I,0,1)        
      CALL CLOSE (GPL,1)        
      MCB(2) = LUSET        
      CALL WRTTRL (MCB)        
C        
C     ***  EQEXIN FILE  ***        
C        
 4050 MCB(1) = EQEX        
      CALL GOPEN (EQEX,Z(BUF1),1)        
      DO 4060 I = 1,LUSET        
      TEMP(1) = I        
      TEMP(2) = I        
      CALL WRITE (EQEX,TEMP,2,0)        
 4060 CONTINUE        
      CALL WRITE (EQEX,TEMP,0,1)        
      DO 4070 I = 1,LUSET        
      TEMP(1) = I        
      TEMP(2) = 10*I + 2        
      CALL WRITE (EQEX,TEMP,2,0)        
 4070 CONTINUE        
      CALL WRITE (EQEX,TEMP,0,1)        
      CALL CLOSE (EQEX,1)        
      MCB(2) = LUSET        
      CALL WRTTRL (MCB)        
C        
C     ***  GPDT FILE  ***        
C        
      MCB(1) = GPDT        
      DO 4105 I = 3,7        
 4105 TEMP(I) = 0        
      TEMP(2) = -1        
      CALL GOPEN (GPDT,Z(BUF1),1)        
      DO 4120 I = 1,LUSET        
      TEMP(1) = I        
      CALL WRITE (GPDT,TEMP,7,0)        
 4120 CONTINUE        
      CALL WRITE (GPDT,TEMP,0,1)        
      CALL CLOSE (GPDT,1)        
      MCB(2) = LUSET        
      CALL WRTTRL (MCB)        
      IF (NONO .NE. 0) GO TO 4200        
C        
C     ***  BGPDT FILE  ***        
C        
      MCB(1) = BGPDT        
      DO 4160 I = 2,4        
 4160 TEMP(I) = 0        
      TEMP(1) =-1        
      CALL GOPEN (BGPDT,Z(BUF1),1)        
      DO 4170 I = 1,LUSET        
      CALL WRITE (BGPDT,TEMP,4,0)        
 4170 CONTINUE        
      CALL WRITE (BGPDT,TEMP,0,1)        
      CALL CLOSE (BGPDT,1)        
      MCB(2) = LUSET        
      CALL WRTTRL (MCB)        
C        
C     ***  SIL FILE  ***        
C        
 4200 MCB(1) = SIL        
      CALL GOPEN (SIL,Z(BUF1),1)        
      DO 4220 I = 1,LUSET        
      CALL WRITE (SIL,I,1,0)        
 4220 CONTINUE        
      CALL WRITE (SIL,I,0,1)        
      CALL CLOSE (SIL,1)        
C        
C        
      MCB(2) = LUSET        
      MCB(3) = LUSET        
      CALL WRTTRL (MCB)        
      IF (NONO .NE. 0) DRY=-2        
      CALL SOFCLS        
      RETURN        
C        
C     ERRORS        
C        
 5001 N = 2 - FLAG        
      GO TO 5010        
 5002 N = -ITEST - 4        
 5010 IF (DRY .LT. 0) N = IABS(N)        
      DRY = -2        
      CALL SMSG (N,ITEM,NAME)        
      RETURN        
 5011 N = -8        
      GO TO 9100        
C6328 WRITE (OUTT,63280) SFM        
C     N = -37        
C     GO TO 9100        
 9001 N = -1        
      GO TO 9100        
 9002 N = -2        
      GO TO 9100        
 9003 N = -3        
 9100 CALL SOFCLS        
      IF (DRY .LT. 0) N = IABS(N)        
      DRY = -2        
 9200 CALL MESAGE (N,FILE,NSGEN)        
      RETURN        
C        
C     MESSAGE FORMATS        
C        
60220 FORMAT (A23,' 6022, SUBSTRUCTURE ',2A4,', GRID POINT',I9,        
     1       ', COMPONENTS',I9,1H,, /30X,'REFERENCED ON ',2A4,        
     2       ' CARD, DO NOT EXIST ON SOLUTION STRUCTURE ',2A4)        
C63280FORMAT (A25,' 6328, MORE THAN 100 SUBCASES DEFINED.  SGEN PROGRAM'
C    1,      ' LIMIT EXCEEDED.')        
63290 FORMAT (A25,' 6329, SUBSTRUCTURE ',2A4,' REFERENCED ON ',2A4,     
     1       ' CARD', /30X,'IS NOT A COMPONENT BASIC SUBSTRUCTURE OF ', 
     2       'SOLUTION STRUCTURE ',2A4,/30X,'THIS CARD WILL BE IGNORED')
63310 FORMAT (A23,' 6331, SOLUTION SUBSTRUCTURE ',2A4,' - LOADC SET',I9,
     1       ' REFERENCES UNDEFINED LOAD', /30X,'SET',I9,        
     2       ' OF BASIC SUBSTRUCTURE ',2A4)        
63320 FORMAT (A25,' 6332, CANT FIND LOAD VECTOR NUMBER',I9,' IN LOAD ', 
     1       'MATRIX OF',I9,' COLUMNS', /32X,'BY',I9,        
     2       ' ROWS FOR SOLUTION STRUCTURE ',2A4)        
63620 FORMAT (A23,' 6362, MPCS SET',I9,' IS ILLEGAL.', //5X,        
     1       'SUBSTRUCTURE ',2A4,' GRID POINT',I9,' COMPONENT',I5,      
     2       ' SPECIFIES A NON-UNIQUE DEPENDENT DEGREE OF FREEDOM')     
      END        
