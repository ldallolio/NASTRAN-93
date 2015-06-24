      SUBROUTINE GP1        
C        
C     GP1  BUILDS THE FOLLOWING DATA BLOCKS--        
C       1. GRID POINT LIST (GPL)        
C       2. EXTERNAL INTERNAL GRID POINT EQUIVALENCE TABLE (EQEXIN)      
C       3. GRID POINT DEFINITION TABLE (GPDT)        
C       4. COORDINATE SYSTEM TRANSFORMATION MATRICES (CSTM)        
C       5. BASIC GRID POINT DEFINITION TABLE (BGPDT)        
C       6. SCALAR INDEX LIST (SIL)        
C        
C     THE FOLLOWING CARDS ARE READ BY GP1--        
C       1. GRID        
C       2. CELASI, CDAMPI, CMASSI  (I=1,2,3,4)        
C       3. SPOINT        
C       4. SEQGP   (SEQEP IS PROCESSED IN DPD1)        
C       5. CORDIJ  (I=1,2,  J=R,S,C)        
C        
C     IMPORTANT        
C     =========        
C     REVISED  7/89 BY G.CHAN/UNISYS, TO ALLOW GRID, SCALAR AND EXTRA   
C     POINT EXTERNAL ID UP TO 8 DIGITS FOR ALL 32-BIT MACHINES        
C     PREVIOUSLY, ID OF 2000000 IS THE UPPER LIMIT FOR IBM AND VAX      
C        
C     REVISED  8/89 BY G.CHAN/UNISYS, AS PART OF THE EFFORT TO ALLOW A  
C     NASTRAN JOB TO EXCEED 65535 LIMIT.        
C     NORMALLY, IF GRID POINTS OR SCALAR POINTS DO NOT HAVE VERY LARGE  
C     EXTERNAL ID NUMBERS, THEIR ID NOS. ARE MULTIPLIED BY 1000, SO THAT
C     999 ADDITIONAL POINTS CAN SQUEEZE IN VIA SEQGP CARDS. (NOTE - A   
C     7- OR 8-DIGIT ID NO., TIMES 1000, EXCEEDS A 32-BIT WORD COMPUTER  
C     HARDWARE LIMIT). THIS MULTIPLY FACTOR IS NOW ADJUSTABLE, 1000,100,
C     OR 10, SO THAT ADDITIONAL DIGITS CAN BE USED FOR THE EXTERNAL GRID
C     OR SCALAR POINTS IN CASE THERE ARE LIMITTED SEQGP CARDS PRESENT.  
C     THIS VARIABLE MULTIPLIER (10,100, OR 1000) IS ALSO RECORDED IN THE
C     3RD WORD OF THE HEADER RECORD OF THE GPL DATA BLOCK FOR LATER USE.
C     THE ACTUAL FACTOR OF THE MULTIPLIER IS ALSO MACHINE DEPENDENT.    
C     UNIVAC, A 36-BIT MACHINE, CAN HAVE A MULTIPLIER OF 100 OR 1000.   
C     OTHER 60- OR 64- BIT MACHINES, THE MULTIPLIER REMAINS AT 1000     
C     IF THE MULTIPLIER IS 1000, THE SEQGP AND SEQEP CARDS, AS BEFORE,  
C     CAN HAVE 4 SEQID LEVELS, SUCH AS XXX.X.X.X        
C     IF THE MULTIPLIER IS 100, SEQGP AND SEQEP CARDS ARE LIMITED TO    
C     3 SEQID LEVELS, XXX.X.X        
C     FINALLY, IF MULTIPLIER IS 10, SEQGP AND SEQEP ARE LIMITED TO XXX.X
C        
C     SPECIAL CONSIDERATION FOR THE AXISYM. AND HYDROELAS. PROBLEMS - 10
C     IS USED FOR THE MULTIPLIER, AND THEREFOR A ONE SEQID LEVEL IS     
C     AVAILABLE. PREVIOUSLY, SEQGP CARDS WERE NOT USED IN AXISYM. AND   
C     HYDROELAS. PROBLEMS, AND NO USER WARNING MESSAGE PRINTED        
C        
C     NO ADJUSTABLE MULTIPLY FACTOR FOR SUBRSTRUCTURING (MULT=1000,     
C     SEE ALSO SGEN)        
C        
C     THE 65535 LIMITATION INVOLVES ONLY A SAMLL CHANGE IN STA 973      
C        
      EXTERNAL        RSHIFT        
      INTEGER         RD,WRT,CLS,FILE,ELEM,AXIC,Z,SYSBUF,BUF1,BUF2,     
     1                BUF3,GEOMP,GPL,EQEXIN,GPDT,CSTM,BGPDT,SIL,SCR1,   
     2                SCR2,WRTREW,RDREW,A,SPOINT,FLAG,GRID,CLSREW,      
     3                SEQGP,GPFL,CORD,CORDIJ,GP1AH,GEOM1,GEOM2,PTR,     
     4                SOLV,SOLVP,SCALPT,TYPE,OFFSET,RSHIFT        
      REAL            LENGTH        
      DIMENSION       A(34),AA(34),AB(3),AC(3),AI(3),AJ(3),AK(3),AX(3), 
     1                AR(3),SPOINT(2),GRID(2),SEQGP(2),CORDIJ(12),      
     2                CORD(6),GP1AH(2),SCALPT(2),ZZ(1),MCB(7)        
      CHARACTER*29    LVL1,LVL2        
      CHARACTER       UFM*23,UWM*25,UIM*29        
      COMMON /XMSSG / UFM,UWM,UIM        
      COMMON /BLANK / LUSET,NOGPDT,NOCSTM        
      COMMON /CONDAS/ PI,TWOPI,RADEG,DEGRA,S4PISQ        
CZZ   COMMON /ZZGP1X/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SYSTEM/ KSYSTM(100)        
      COMMON /SETUP / NFILE(6),PTR        
      COMMON /GPTA1 / NELEM,LASTX,INCRX,ELEM(1)        
      COMMON /NAMES / RD,RDREW,WRT,WRTREW,CLSREW,CLS        
      EQUIVALENCE     (KSYSTM( 1),SYSBUF), (KSYSTM( 2),IOUT ),        
     1                (KSYSTM(24),ICFIAT), (KSYSTM(27),AXIC ),        
     2                (KSYSTM(38),IAXIF ), (KSYSTM(40),NBPW ),        
     3                (KSYSTM(56),ITHERM), (KSYSTM(69),ISUBS)        
      EQUIVALENCE     (Z( 1),ZZ(1)), (A( 1),AA(1)), (A( 4),AB(1)),      
     1                (A( 7),AC(1)), (A(10),AI(1)), (A(13),AJ(1)),      
     2                (A(16),AK(1)), (A(19),AX(1)), (A(22),AR(1)),      
     3                (NOCSTM,IFL ), (GEOMP,GEOM1), (MCB(2),KN  )       
      EQUIVALENCE     (IGPDT,ICSDT)        
      DATA    GEOM1 / 101/, GEOM2 / 102/,        
     1        GPL   / 201/, EQEXIN/ 202/, GPDT  / 203/,        
     2        CSTM  / 204/, BGPDT / 205/, SIL   / 206/,        
     3        SCR1  / 301/, SCR2  / 302/        
      DATA    GP1AH / 4HGP1 , 4H    /,        
     1        CORD  / 6,6,6,13,13,13/,        
     2        GRID  / 4501,45  /,        
     3        SEQGP / 5301,53  /,        
     4        CORDIJ/ 1701,17,1801,18,1901,19,2001,20,2101,21,2201,22/, 
     5        SCALPT/ 5551,49  /        
      DATA    MCB   / 7*0      /,        
     1        LARGE / 100000000/,        
     2        LVL1  / '3  I.E.  XXX.X.X.X TO XXX.X.X' /,        
     3        LVL2  / '2  I.E.  XXX.X.X.X TO XXX.X  ' /        
C        
C     PERFORM GENERAL INITIALIZATION        
C        
      CALL DELSET        
      NZ     = KORSZ(Z)        
      BUF1   = NZ - SYSBUF - 2        
      BUF2   = BUF1 - SYSBUF        
      BUF3   = BUF2 - SYSBUF        
      NOGO   = 0        
      NOCSTM = 0        
      NOGPDT =-1        
      NOGMP1 = 1        
      MAXA1  = 0        
      MULT   = 1000        
      AXI    = 0        
      IF (AXIC.NE.0 .OR. IAXIF.NE.0) AXI = 1        
      IF (AXI   .NE. 0) MULT = 10        
      IF (ISUBS .NE. 0) MULT = 1000        
      IMAX = LARGE        
      IF (NBPW .EQ. 32) IMAX =  2147483        
      IF (NBPW .EQ. 36) IMAX = 34359738        
C         2147483=2**31/1000   34359738=2**35/1000        
C        
C     READ SCALAR ELEMENT CONNECTION CARDS (IF PRESENT).        
C     EXTRACT SCALAR POINTS AND WRITE THEM ON SCR2.        
C        
      FILE = SCR2        
      CALL OPEN (*1170,SCR2,Z(BUF2),WRTREW)        
      NOSCLR= 0        
      M8    =-8        
      A(11) =-1        
      DO 30 K = 12,16        
   30 A(K) = 0        
      CALL PRELOC (*80,Z(BUF1),GEOM2)        
      I = 1        
      DO 60 I = 1,LASTX,INCRX        
      KK = ELEM(I+10)        
      IF (KK .EQ. 0) GO TO 60        
      CALL LOCATE (*60,Z(BUF1),ELEM(I+3),FLAG)        
      NN = ELEM(I+5)        
   40 CALL READ (*1180,*60,GEOM2,A,NN,0,FLAG)        
      DO 50 K = 3,4        
      IF (A(K).EQ.0 .OR. (KK.EQ.1 .AND. A(K+2).NE.0)) GO TO 50        
      A(10)  = A(K)        
      NOSCLR = 1        
      CALL WRITE (SCR2,A(10),1,0)        
   50 CONTINUE        
      GO TO 40        
   60 CONTINUE        
C        
C     COPY SCALAR POINTS DEFINED ON SPOINT CARDS (IF PRESENT) ONTO SCR2.
C        
      CALL LOCATE (*80,Z(BUF1),SCALPT,FLAG)        
      NOSCLR = 1        
      CALL READ   (*1180,*70,GEOM2,Z,BUF2-1,1,N)        
      CALL MESAGE (M8,0,GP1AH)        
   70 CALL WRITE  (SCR2,Z,N,0)        
C        
C     CLOSE FILES. IF SCALAR POINTS PRESENT, SORT LIST.        
C     THEN DISCARD DUPLICATES AND WRITE UNIQUE LIST ON SCR2.        
C        
   80 CALL WRITE (SCR2,0,0,1)        
      CALL CLOSE (SCR2,CLSREW)        
      CALL CLOSE (GEOM2,CLSREW)        
      IF (NOSCLR .EQ. 0) GO TO 110        
      NFILE(1) = GPDT        
      NFILE(2) = BGPDT        
      NFILE(3) = SIL        
      CALL OPEN  (*1170,SCR2,Z(BUF1),RDREW)        
      CALL SORTI (SCR2,0,1,1,Z,BUF1-1)        
      CALL CLOSE (SCR2,CLSREW)        
      FILE = NFILE(6)        
      CALL OPEN (*1170,FILE,Z(BUF1),RDREW)        
      CALL OPEN (*1170,SCR2,Z(BUF2),WRTREW)        
      LAST = -1        
   90 CALL READ (*1180,*100,FILE,A(10),1,0,FLAG)        
      IF (A(10) .EQ. LAST) GO TO 90        
      CALL WRITE (SCR2,A(10),1,0)        
      LAST = A(10)        
      GO TO 90        
  100 CALL WRITE (SCR2,0,0,1)        
      CALL CLOSE (SCR2,CLSREW)        
      CALL CLOSE (FILE,CLSREW)        
      CALL OPEN  (*1170,SCR2,Z(BUF3),RDREW)        
C        
C     READ GRID ENTRIES (IF PRESENT).        
C     MERGE GRID AND SCALAR NOS.        
C     CREATING LIST IN CORE OF EXTERNAL NO., MULT * EXTERNAL NO.        
C     WRITE 7-WORD GRID AND SCALAR ENTRIES ON SCR1.        
C        
  110 A(1)  = LARGE        
      A(10) = LARGE        
      FILE  = SCR1        
      IF (MAXA1 .EQ. 0) CALL OPEN (*1170,SCR1,Z(BUF2),WRTREW)        
      I = -1        
      NOGRID = 0        
      IF (MAXA1 .EQ. 0) CALL PRELOC (*190,Z(BUF1),GEOM1)        
      CALL LOCATE (*200,Z(BUF1),GRID,FLAG)        
      NOGRID = 1        
      CALL READ  (*1180,*1200,GEOM1,A,8,0,FLAG)        
      CALL WRITE (SCR1,A,7,0)        
  120 IF (NOSCLR .EQ. 0) GO TO 140        
      CALL READ  (*1180,*1200,SCR2,A(10),1,0,FLAG)        
      CALL WRITE (SCR1,A(10),7,0)        
  130 IF (NOGRID .EQ. 0) GO TO 160        
      IF (NOSCLR .EQ. 0) GO TO 140        
      IF (A(1) -  A(10)) 140,1250,160        
C        
C     GRID NO. .LT. SCALAR NO.        
C        
  140 I = I + 2        
      Z(I) = A(1)        
C        
C     GRID POINT EXTERNAL ID * MULT IS LIMITED TO COMPUTER MAXIMUM      
C     INTEGER SIZE        
C        
      IF (A(1).LE.IMAX .OR. AXI.NE.0) GO TO 142        
      IF (A(1) .GT. MAXA1) MAXA1 = A(1)        
      GO TO 146        
  142 Z(I+1) = MULT*A(1)        
  146 CALL READ  (*1180,*150,GEOM1,A,8,0,FLAG)        
      CALL WRITE (SCR1,A,7,0)        
      GO TO 130        
  150 NOGRID = 0        
      A(1) = LARGE        
      IF (NOSCLR .EQ. 0) GO TO 180        
C        
C     SCALAR NO. .LT. GRID NO.        
C        
  160 I = I + 2        
      Z(I) = A(10)        
C        
C     SCALAR POINT EXTERNAL ID * MULT IS LIMITED TO COMPUTER MAXIMUM    
C     INTEGER SIZE        
C        
      IF (A(10).LE.IMAX .OR. AXI.NE.0) GO TO 162        
      IF (A(10) .GT. MAXA1) MAXA1 = A(10)        
      GO TO 166        
  162 Z(I+1) = MULT*A(10)        
  166 CALL READ  (*1180,*170,SCR2,A(10),1,0,FLAG)        
      CALL WRITE (SCR1,A(10),7,0)        
      GO TO 130        
  170 NOSCLR = 0        
      A(10)  = LARGE        
      IF (NOGRID .EQ. 0) GO TO 180        
      GO TO 140        
C        
C     LIST COMPLETE ONLY IF MAXA1 .LE. ZERO        
C        
C     IF MAXA1 IS .GT. ZERO, SOME LARGE GRID OR SCALAR POINTS HAD BEEN  
C     LEFT OUT IN LIST. MAXA1 IS THE LARGEST GRID OR SCALAR POINT       
C     EXTERNAL ID.  RESET MULT AND REPEAT COMPILING LIST        
C        
  180 IF (MAXA1 .LE. 0) GO TO 185        
      IF (ISUBS .NE. 0) GO TO 183        
      CALL REWIND (SCR1)        
      CALL REWIND (GEOM1)        
      IF (NOSCLR .NE. 0) CALL REWIND (SCR2)        
      MULT = 100        
      IF (MAXA1 .GT. IMAX*10) MULT = 10        
      IMAX  = (IMAX/MULT)*1000        
      MAXA1 = -1        
      CALL PAGE (-3)        
      IF (MULT .EQ. 100) WRITE (IOUT,182) UWM,LVL1        
      IF (MULT .EQ.  10) WRITE (IOUT,182) UWM,LVL2        
  182 FORMAT (A25,' 2140A, DUE TO THE PRESENCE OF ONE OR MORE GRID OR ',
     1       'SCALAR POINTS WITH VERY LARGE EXTERNAL ID''S, THE SEQGP' ,
     2       /5X,'AND SEQEP CARDS, IF USED, ARE FORCED TO REDUCE FROM ',
     3       'ALLOWABLE 4 SEQID LEVELS TO ',A29,/)        
      GO TO 110        
C        
  183 WRITE  (IOUT,184) UFM        
  184 FORMAT (A23,' 2140B, EXTERNAL GRID OR SCALAR POINT ID TOO BIG')   
      CALL MESAGE (-61,0,0)        
C        
  185 N    = I        
      NEQEX= N        
      N1   = N + 1        
      N2   = N + 2        
      IGPDT= N2        
      ILIST= N2        
      KN   = N1/2        
      CALL CLOSE (SCR1,CLSREW)        
      CALL CLOSE (SCR2,CLSREW)        
      GO TO 210        
C        
C     NO GRID CARDS PRESENT-- TEST FOR ANY SCALAR PTS.        
C        
  190 NOGMP1 = 0        
  200 IF (NOSCLR .EQ. 0) GO TO 980        
      GO TO 120        
C        
C     READ THE SEQGP TABLE (IF PRESENT)        
C     FOR EACH ENTRY, FIND MATCH IN THE SORTED EXTERNAL GRID POINTS     
C     AND REPLACE SEQUENCE NO. WITH SEQGP NO.        
C        
  210 NOSEQ  = 0        
      NOGPDT = 1        
C     IF (AXI .NE. 0) GO TO 250        
      IF (NOGMP1 .EQ. 0) GO TO 260        
      ASSIGN 230 TO NDX        
      SPOINT(2) = 0        
      IERR = 1        
      ASSIGN 220 TO NERR        
      CALL LOCATE (*250,Z(BUF1),SEQGP,FLAG)        
      NOSEQ = 1        
      IFAIL = 0        
 2010 CALL READ (*1180,*2020,GEOMP,Z(N2),BUF1-1,1,FLAG)        
      IFAIL = IFAIL + 1        
      GO TO 2010        
 2020 IF (IFAIL .EQ. 0) GO TO 2060        
      NWDS = (IFAIL-1)*(BUF1-1) + FLAG        
      WRITE  (IOUT,2040) UFM,NWDS        
 2040 FORMAT (A23,' 3135, UNABLE TO PROCESS SEQGP DATA IN SUBROUTINE ', 
     1       'GP1 DUE TO INSUFFICIENT CORE.', //5X,        
     2       'ADDITIONAL CORE REQUIRED =',I10,7H  WORDS)        
      CALL MESAGE (-61,0,0)        
C        
C     CHECK FOR MULTIPLE REFERENCES TO GRID (OR SCALAR) POINT ID NOS.   
C     AND SEQUENCE ID NOS. ON SEQGP CARDS        
C        
 2060 K  = N2        
      KK = N2 + FLAG - 1        
      JJ = KK - 2        
 2080 DO 2285 I = K,JJ,2        
      IF (Z(I).LT.0 .OR. I.GE.KK) GO TO 2275        
      II = I + 2        
      IFAIL = 0        
      DO 2270 J = II,KK,2        
      IF (Z(I) .NE. Z(J)) GO TO 2270        
      IF (IFAIL .NE.   0) GO TO 2260        
      IFAIL = 1        
      NOGO  = 1        
      IF (K .NE. N2) GO TO 2110        
      WRITE  (IOUT,2100) UFM,Z(I)        
 2100 FORMAT (A23,' 3136, MULTIPLE REFERENCES TO GRID (OR SCALAR) POINT'
     1,      ' ID NO.',I9,'  ON SEQGP CARDS.')        
      GO TO 2260        
 2110 IDSEQ1 = Z(I)/1000        
      IRMNDR = Z(I) - 1000*IDSEQ1        
      IF (IRMNDR.NE.0 .AND. MULT.GE.10) GO TO 2140        
      IF (AXI .NE. 0) GO TO 2130        
      WRITE  (IOUT,2120) UFM,IDSEQ1        
 2120 FORMAT (A23,' 3137, MULTIPLE REFERENCES TO SEQUENCE ID NO.',I6,6X,
     1       ' ON SEQGP CARDS.')        
      GO TO 2260        
 2130 IF (AXI .EQ. 1) WRITE (IOUT,2135) UFM        
 2135 FORMAT (A23,' 3137A, SEQGP CARDS WITH MORE THAN ONE SEQID LEVEL ',
     1       'ARE ILLEGAL FOR AXISYSM. OR HYDROELAS. PROBLEM')        
      AXI  = 2        
      NOGO = 1        
      GO TO 2260        
 2140 IDSEQ2 = IRMNDR/100        
      IRMNDR = IRMNDR - 100*IDSEQ2        
      IF (IRMNDR.NE.0 .AND. MULT.GE.100) GO TO 2180        
      WRITE  (IOUT,2160) UFM,IDSEQ1,IDSEQ2        
 2160 FORMAT (A23,' 3137, MULTIPLE REFERENCES TO SEQUENCE ID NO.',I6,   
     1        1H.,I1,5X,'ON SEQGP CARDS.')        
      GO TO 2260        
 2180 IDSEQ3 = IRMNDR/10        
      IRMNDR = IRMNDR - 10*IDSEQ3        
      IF (IRMNDR .NE. 0) GO TO 2220        
      WRITE  (IOUT,2200) UFM,IDSEQ1,IDSEQ2,IDSEQ3        
 2200 FORMAT (A23,' 3137, MULTIPLE REFERENCES TO SEQUENCE ID NO.',I6,   
     1       1H.,I1,1H.,I1,4X,'ON SEQGP CARDS.')        
      GO TO 2260        
 2220 WRITE  (IOUT,2240) UFM,IDSEQ1,IDSEQ2,IDSEQ3,IRMNDR        
 2240 FORMAT (A23,' 3137, MULTIPLE REFERENCES TO SEQUENCE ID NO.',I6,   
     1        1H.,I1,1H.,I1,1H.,I1,'  ON SEQGP CARDS.')        
 2260 Z(J) = -Z(J)        
 2270 CONTINUE        
C        
 2275 IF (JJ.LT.KK .OR. MULT.EQ.1000) GO TO 2285        
      L = Z(I)        
      IF (MULT   .LE.   10) GO TO 2280        
      IF (MOD(L,10) .NE. 0) GO TO 2276        
      Z(I) = L/10        
      GO TO 2285        
 2276 IF (MAXA1 .EQ. 0) GO TO 2285        
      MAXA1 = 0        
      NOGO  = 1        
      WRITE  (IOUT,2277) UFM        
 2277 FORMAT (A23,' 2140B, ILLEGAL DATA IN SEQGP CARD, POSSIBLY CAUSED',
     1       ' BY LARGE GRID OR SCALAR POINTS')        
      GO TO 2285        
 2280 IF (MULT .EQ. 1) GO TO 2282        
      IF (MOD(L,100) .NE. 0) GO TO 2276        
      Z(I) = L/100        
      GO TO 2285        
 2282 IF (AXI .EQ. 0) CALL MESAGE (-37,0,NAM)        
      IF (MOD(L,1000) .EQ. 0) GO TO 2285        
      IF (AXI .EQ. 1) WRITE (IOUT,2135) UFM        
      AXI  = 2        
      NOGO = 1        
 2285 CONTINUE        
C        
      IF (K .NE. N2) GO TO 2290        
      JJ = KK        
      K  = K + 1        
      GO TO 2080        
C        
 2290 DO 2300 I = N2,KK,2        
      IF (Z(I) .LT. 0) Z(I) = -Z(I)        
 2300 CONTINUE        
      IF (NOGO .EQ. 1) GO TO 2400        
C        
C     CHECK TO SEE IF ANY SEQUENCE ID NO. ON SEQGP CARDS IS THE SAME    
C     AS A GRID (OR SCALAR) POINT ID NO. THAT HAS NOT BEEN RESEQUENCED  
C        
      DO 2390 I = K,KK,2        
      IF (Z(I) .LT. 0) GO TO 2390        
      IDSEQ1 = Z(I)/MULT        
      IRMNDR = Z(I) - MULT*IDSEQ1        
      IF (IRMNDR .NE. 0) GO TO 2390        
      DO 2320 J = N2,KK,2        
      IF (IDSEQ1 .EQ. Z(J)) GO TO 2390        
 2320 CONTINUE        
      DO 2340 J = 1,N1,2        
      IF (IDSEQ1 .EQ. Z(J)) GO TO 2360        
 2340 CONTINUE        
      GO TO 2390        
 2360 NOGO = 1        
      WRITE  (IOUT,2380) UFM,IDSEQ1        
 2380 FORMAT (A23,' 3138, SEQUENCE ID NO.',I6,' ON SEQGP CARDS IS THE ',
     1       'SAME AS A', /5X,'GRID (OR SCALAR) POINT ID NO. THAT HAS ',
     2       'NOT BEEN RESEQUENCED.')        
 2390 CONTINUE        
 2400 CONTINUE        
      I = -1        
  220 I = I + 2        
      IF (I .GT. FLAG) GO TO 240        
      A(1) = Z(N2+I-1)        
      A(2) = Z(N2+I  )        
      GO TO 1060        
  230 Z(2*K) = A(2)        
      GO TO 220        
C        
C     SORT THE CORE TABLE BY INTERNAL GRID PT NO        
C     THUS FORMING THE GPL (EXTERNAL GRID PT NOS IN SORT BY INTERNAL NO)
C        
  240 IF (NOGO .NE. 0) GO TO 1165        
      CALL SORTI (0,0,2,2,Z,N1)        
C        
C     CLOSE GEOM1. WRITE THE GPL. FIRST RECORD IS A SINGE ENTRIED LIST  
C     OF EXTERNAL GRID NOS. IN INTERNAL SORT. SECOND RECORD IS A DOUBLE 
C     ENTRIED LIST OF EXTERAL GRID NO., SEQUENCE NO. (SORT IS INTERNAL).
C     ADD THE MULTIPLIER, MULT, TO THE 3RD WORD OF GPL HEADER RECORD    
C        
  250 IF (NOGMP1 .NE. 0) CALL CLOSE (GEOM1,CLSREW)        
  260 CALL FNAME (GPL,A)        
      FILE = GPL        
      CALL OPEN (*1170,GPL,Z(BUF1),WRTREW)        
      A(3) = MULT        
      CALL WRITE (GPL,A,3,1)        
      DO 270 I = 1,N,2        
  270 CALL WRITE (GPL,Z(I),1,0)        
      CALL WRITE (GPL,0,0,1)        
      CALL WRITE (GPL,Z,N1,1)        
      CALL CLOSE (GPL,CLSREW)        
      MCB(1) = GPL        
      CALL WRTTRL (MCB)        
C        
C     FORM INTERNAL INDEX FOR EACH EXTERNAL GRID PT. NO.        
C        
      I = 2        
      Z(I) = 1        
      IF (N .EQ. 1) GO TO 310        
      DO 290 I = 3,N,2        
  290 Z(I+1) = Z(I-1) + 1        
C        
C     TEST TO SEE IF EXTERNAL GRID PT NOS ARE STILL IN EXTERNAL SORT    
C     I.E., IF NO SEQGP TABLE, THEN SORT IS MAINTAINED        
C     OTHERWISE, SORT ON EXTERNAL GRID NO.        
C        
      IF (NOSEQ .NE. 0) CALL SORTI (0,0,2,1,Z,N1)        
C        
C     DETERMINE IF THE GPDT CAN BE HELD IN CORE        
C     NWDS= TOTAL NO OF WORDS IN THE GPDT        
C     M= MAX NO OF ENTRIES CORE CAN HOLD WITH ONE BUFFER OPEN        
C     IF NWDS/7.LE.M,CORE WILL HOLD THE GPDT        
C     OTHERWISE THE FILE SORT ROUTINE WILL BE USED        
C        
  310 NWDS = 7*KN        
      M    = (BUF1-N1)/7        
      GPFL = 0        
      IF (KN .GT. M) GPFL = 7        
      FILE = SCR1        
C        
C     READ THE GRID AND SPOINT TABLES FROM SCR1        
C     REPLACE THE EXTERNAL GRID PT NO WITH THE INTERNAL INDEX        
C     IF CORE WILL HOLD THE GPDT, USE THE INTERNAL INDEX AS A POINTER   
C     OTHERWISE, WRITE THE UNSORTED GPDT ON SCR2        
C        
      CALL OPEN (*1170,SCR1,Z(BUF1),RDREW)        
      FILE = SCR2        
      IF (GPFL .NE. 0) CALL OPEN (*1170,SCR2,Z(BUF2),WRTREW)        
      FILE = SCR1        
      ASSIGN 340 TO NDX        
      IERR = 2        
      ASSIGN 330 TO NERR        
  330 CALL READ (*1180,*370,SCR1,A,7,0,FLAG)        
      GO TO 1060        
  340 IF (GPFL .NE. 0) GO TO 360        
      J = N1 + 7*(A(1)-1)        
      DO 350 K = 1,7        
      I = J+K        
  350 Z(I) = A(K)        
      GO TO 330        
  360 CALL WRITE (SCR2,A,7,0)        
      GO TO 330        
  370 IF (NOGO .NE. 0) GO TO 1165        
      CALL CLOSE (SCR1,CLSREW)        
C        
C     OPEN OUTPUT FILE FOR GPDT AND WRITE HEADER DATA        
C     IF GPDT IS IN CORE, WRITE IT OUT        
C        
      FILE = GPDT        
      CALL FNAME (GPDT,A)        
      CALL OPEN  (*1170,GPDT,Z(BUF1),WRTREW)        
      CALL WRITE (GPDT,A,2,1)        
      IF (GPFL .NE. 0) GO TO 390        
      CALL WRITE (GPDT,Z(IGPDT),NWDS,1)        
      GO TO 400        
C        
C     IF GPDT NOT IN CORE, CALL SORT        
C        
  390 NFILE(1) = SCR1        
      NFILE(2) = CSTM        
      NFILE(3) = BGPDT        
      CALL CLOSE (SCR2,CLSREW)        
      FILE = SCR2        
      CALL OPEN  (*1170,SCR2,Z(BUF2),RDREW)        
      CALL SORTI (SCR2,GPDT,7,1,Z(IGPDT),BUF2-IGPDT)        
      CALL CLOSE (SCR2,CLSREW)        
  400 CALL CLOSE (GPDT,CLSREW)        
      MCB(1) = GPDT        
      CALL WRTTRL (MCB)        
C        
C     READ THE CORDIJ TABLES INTO CORE (IF PRESENT)        
C        
      IFL = -1        
      M   = ICSDT        
      NOLIST = 0        
      IF (NOGMP1 .EQ. 0) GO TO 810        
      NDX   = BUF1 - 15        
      NCORE = BUF1 - 15        
      DO 420 I = ICSDT,BUF1        
  420 Z(I) = 0        
      FILE = GEOMP        
      CALL PRELOC (*1170,Z(BUF1),GEOMP)        
      DO 440 I = 1,6        
      IJ = I + I - 1        
      CALL LOCATE (*440,Z(BUF1),CORDIJ(IJ),FLAG)        
      IFL = 1        
  430 CALL READ (*1180,*440,GEOMP,Z(M),CORD(I),0,FLAG)        
      M = M + 16        
      IF (M .GT. NCORE) CALL MESAGE (-8,0,GP1AH)        
      GO TO 430        
  440 CONTINUE        
      CALL CLOSE (GEOMP,CLSREW)        
      M = M - 16        
      NCSDT = M        
C        
C     TEST FOR PRESENCE OF ANY CORDIJ TABLES        
C        
      IF (IFL .EQ. -1) GO TO 810        
C        
C     REPLACE EXTERNAL GRID PT NO IN CORD1J ENTRIES (IF ANY)        
C     WITH CORRESPONDING INTERNAL INDEX        
C     SAVE A TABLE OF GRID PTS REFERENCED ON CORD1J ENTRIES        
C        
      JJ   = ICSDT        
      ILIST= NCSDT + 16        
      II   = ILIST - 1        
      NCORE= BUF1  - 3        
      IERR = 3        
  470 IF (Z(JJ+2).NE.1) GO TO 510        
      NOLIST = 1        
      ASSIGN 480 TO NDX        
      ASSIGN 485 TO NERR        
      A(1) = Z(JJ+3)        
      SPOINT(2) =  Z(JJ+1)        
      GO TO 1060        
  480 Z(JJ+3) = A(1)        
      Z(II+1) = A(1)        
  485 ASSIGN 490 TO NDX        
      ASSIGN 495 TO NERR        
      A(1) = Z(JJ+4)        
      GO TO 1060        
  490 Z(JJ+4) = A(1)        
      Z(II+2) = A(1)        
  495 ASSIGN 500 TO NDX        
      ASSIGN 505 TO NERR        
      A(1) = Z(JJ+5)        
      GO TO 1060        
  500 Z(JJ+5) = A(1)        
      Z(II+3) = A(1)        
  505 II = II+3        
      IF (II .GT. NCORE) CALL MESAGE (-8,0,GP1AH)        
  510 JJ = JJ + 16        
      IF (JJ .LE. NCSDT) GO TO 470        
      IF (NOGO .NE.   0) GO TO 1165        
C        
C     IF ANY CORD1J ENTRIES, PASS THE GPDT AND CREATE A TABLE OF THE    
C     REFERENCED GRID PTS. THIS TABLE IS CALLED CSGP        
C        
      IF (NOLIST .EQ. 0) GO TO 550        
      NLIST = II        
      ICSGP = NLIST + 1        
      CALL SORTI (0,0,1,1,Z(ILIST),ICSGP-ILIST)        
      Z(ICSGP) = 0        
      JJ = ILIST        
      DO 530 KK = ILIST,NLIST        
      IF (Z(KK+1) .EQ. Z(KK)) GO TO 530        
      Z(JJ) = Z(KK)        
      JJ = JJ + 1        
  530 CONTINUE        
      NLIST = JJ - 1        
      ICSGP = JJ        
      FILE  = GPDT        
      CALL OPEN   (*1170,GPDT,Z(BUF1),RDREW)        
      CALL FWDREC (*1180,GPDT)        
      NCORE = BUF1 - 5        
      I = ILIST        
  540 CALL READ (*1180,*1200,GPDT,Z(JJ),7,0,FLAG)        
      IF (Z(JJ) .NE. Z(I)) GO TO 540        
      JJ = JJ + 5        
      IF (JJ .GT. NCORE) CALL MESAGE (-8,0,GP1AH)        
      I  = I + 1        
      IF (I .LE. NLIST) GO TO 540        
      NCSGP = JJ - 5        
      CALL CLOSE (GPDT,CLSREW)        
C        
C     LOOP THRU THE CSDT SOLVING AS MANY COORDINATE SYSTEMS AS POSSIBLE 
C     ON EACH PASS.        
C        
  550 NN = (NCSDT-ICSDT)/16 + 1        
      SOLV  = 0        
      SOLVP = 0        
  560 II = ICSDT        
  570 IF (Z(II+2)-2) 580,620,690        
C        
C     *****  TYPE = 1 *****        
C     CHECK TO SEE IF EACH OF THE 3 REFERENCE GRID PTS IS IN BASIC SYS  
C     IF SO,CALCULATE THE TRANSFORMATION TO BASIC AND SET COORD SYSTEM  
C     AS SOLVED, IF NOT CONTINUE TO NEXT COORDINATE SYSTEM        
C        
  580 I = 0        
  590 K = II + I        
      J = ICSGP - 1        
  600 IF (Z(J+1) .EQ. Z(K+3)) GO TO 610        
      J = J + 5        
      IF (J .LT. NCSGP) GO TO 600        
      GO TO 1220        
  610 IF (Z(J+2).NE.0) GO TO 700        
      K = I*3        
      AA(K+1) = ZZ(J+3)        
      AA(K+2) = ZZ(J+4)        
      AA(K+3) = ZZ(J+5)        
      I = I+1        
      IF (I .LE. 2) GO TO 590        
      GO TO 1020        
C        
C     ***** TYPE = 2 *****        
C     CHECK THE DEFINING LOCAL COORDINATE SYSTEM        
C     IF BASIC, SOLVE AS IN TYPE=1        
C     IF NOT BASIC, FIND THE REFERENCED COORD SYSTEM AND TEST IF THAT   
C     SYSTEM IS SOLVED. IF YES, CALCULATE THE TRANSFORMATION TO BASIC   
C     IF NO, CONTINUE THRU THE CSDT        
C        
  620 IF (Z(II+3) .NE. 0) GO TO 640        
      DO 630 I = 1,9        
      K = II + I        
  630 AA(I) = ZZ(K+3)        
      GO TO 1020        
  640 I = ICSDT        
  650 IF (Z(I) .EQ. Z(II+3)) GO TO 660        
      I = I + 16        
      IF (I .LE. NCSDT) GO TO 650        
      GO TO 1230        
  660 IF (Z(I+2).NE.3 .OR. Z(I+3).NE.0) GO TO 700        
      K = 0        
      ASSIGN 680 TO NDX        
  670 L = K + II        
      AX(1) = ZZ(L+4)        
      AX(2) = ZZ(L+5)        
      AX(3) = ZZ(L+6)        
      IF (Z(I+1)-2) 990,1000,1010        
  680 AA(K+1) = AR(1)        
      AA(K+2) = AR(2)        
      AA(K+3) = AR(3)        
      K = K + 3        
      IF (K .LE. 6) GO TO 670        
      GO TO 1020        
C        
C     ***** TYPE = 3 *****        
C     CHECK THE DEFINING LOCAL COORDINATE SYSTEM        
C     IF BASIC, CONTINUE THRU CSDT        
C     IF NOT BASIC, ERROR CONDITION        
C        
  690 IF (Z(II+3) .NE. 0) GO TO 1190        
C        
C     TEST FOR COMPLETION OF PASS THRU CSDT        
C        
  700 II = II + 16        
      IF (II .LE. NCSDT) GO TO 570        
C        
C     LOOP THRU THE CSGP (IFPRESENT) AND TRANSFORM ALL        
C     POSSIBLE GRID PTS TO BASIC        
C        
      IF (NOLIST .EQ. 0) GO TO 770        
      JJ = ICSGP        
  720 IF (Z(JJ+1) .EQ. 0) GO TO 760        
      I = ICSDT        
  730 IF (Z(JJ+1) .EQ. Z(I)) GO TO 740        
      I = I + 16        
      IF (I .LE. NCSDT) GO TO 730        
      IERR = 6        
      SPOINT(1) = Z(JJ  )        
      SPOINT(2) = Z(JJ+1)        
      GO TO 1190        
  740 IF (Z(I+2).NE.3 .OR. Z(I+3).NE.0) GO TO 760        
      AX(1) = ZZ(JJ+2)        
      AX(2) = ZZ(JJ+3)        
      AX(3) = ZZ(JJ+4)        
      ASSIGN 750 TO NDX        
      IF (Z(I+1)-2) 990,1000,1010        
  750 ZZ(JJ+2) = AR(1)        
      ZZ(JJ+3) = AR(2)        
      ZZ(JJ+4) = AR(3)        
      ZZ(JJ+1) = 0        
  760 JJ = JJ + 5        
      IF (JJ .LE. NCSGP) GO TO 720        
C        
C     TEST TO SEE IF ALL COORDINATE SYSTEMS SOLVED        
C     IF NOT, TEST TO SEE IF ANY NEW SOLUTIONS ON LAST PASS        
C     IF NONE, INCONSISTANT DEFINITION OF COORDINATE SYSTEMS        
C     OTHERWISE LOOP BACK THRU THE CSDT        
C        
  770 IF (SOLV .EQ.    NN) GO TO 780        
      IF (SOLV .EQ. SOLVP) GO TO 1240        
      SOLVP = SOLV        
      GO TO 560        
C        
C     WRITE THE CSTM        
C        
  780 CALL FNAME (CSTM,A)        
      FILE = CSTM        
      CALL OPEN  (*1170,CSTM,Z(BUF1),WRTREW)        
      CALL WRITE (CSTM,A,2,1)        
      DO 800 II = ICSDT,NCSDT,16        
      CALL WRITE (CSTM,Z(II),2,0)        
      CALL WRITE (CSTM,Z(II+4),12,0)        
  800 CONTINUE        
      CALL CLOSE (CSTM,CLSREW)        
      NOCSTM = NN        
      MCB(3) = NN        
      MCB(1) = CSTM        
      CALL WRTTRL (MCB)        
C        
C     OPEN EQEXIN AND WRITE HEADER RECORD.        
C     THEN WRITE FIRST RECORD (PAIRS OF EXTERNAL GRID NO., INTERNAL NO. 
C     IN EXTERNAL SORT).        
C        
  810 FILE = EQEXIN        
      CALL OPEN  (*1170,EQEXIN,Z(BUF1),WRTREW)        
      CALL FNAME (EQEXIN,A)        
      CALL WRITE (EQEXIN,A,2,1)        
      CALL WRITE (EQEXIN,Z,N1,1)        
      CALL CLOSE (EQEXIN,CLS)        
C        
C     A LIST OF DEGREES OF FREEDOM FOR EACH GRID OR SCALAR POINT IS     
C     FORMED BEGINNING AT Z(ILIST) BY READING GEOM2 AND USING THE       
C     CONNECTION INFORMATION IN CONJUNCTION WITH THE ELEM TABLE IN      
C     /GPTA1/.        
C        
      FILE   = GEOM2        
      ILIST0 = ILIST - 1        
      NLIST  = ILIST + (NEQEX+1)/2        
      IF (NLIST .GE. BUF3) CALL MESAGE (-8,0,GP1AH)        
      DO 8102 I = ILIST,NLIST        
      Z(I) = 0        
 8102 CONTINUE        
      JERR = 0        
      CALL OPEN   (*8130,GEOM2,Z(BUF1),RDREW)        
 8103 CALL FWDREC (*1180,GEOM2)        
 8104 CALL ECTLOC (*8130,GEOM2,A,I)        
C        
C     ELEMENT TYPE LOCATED--PREPARE TO PROCESS EACH ELEMENT        
C        
      IF (ELEM(I+9) .EQ. 0) GO TO 8103        
      J1 = ELEM(I+12)        
      NREAD = J1 + ELEM(I+9) - 1        
      NSKIP =-(ELEM(I+5 ) - NREAD)        
      MAXDOF=  ELEM(I+24)        
      ITYPE =  ELEM(I+2 )        
C        
C     READ CONNECTION DATA FOR ELEMENT AND LOCATE EXT. GRID NBR IN      
C     EQEXIN UPDATE DOF LIST FOR EACH GRID NBR        
C        
 8110 CALL READ (*1180,*8104,GEOM2,A,NREAD,0,M)        
      DO 8128 I = J1,NREAD        
      IF (A(I) .EQ. 0) GO TO 8128        
      CALL BISLOC (*8122,A(I),Z,2,KN,K)        
      J = ILIST0 + Z(K+1)        
      IF (ITYPE.GE.76 .AND. ITYPE.LE.79) GO TO 8115        
C        
C     STRUCTURE ELEMENT AND OTHERS        
C        
      IF (Z(J) .LT. 0) GO TO 8124        
      Z(J) = MAX0(Z(J),MAXDOF)        
      GO TO 8128        
C        
C     FLUID ELEMENT (CFHEX1,CFHEX2,CFWEDGE,CFTETRA)        
C        
 8115 IF (Z(J) .GT. 0) GO TO 8124        
C        
      Z(J) = -1        
      GO TO 8128        
 8122 WRITE  (IOUT,8123) UFM,A(1),A(I)        
 8123 FORMAT (A23,' 2007, ELEMENT',I8,' REFERENCES UNDEFINED GRID ',    
     1       'POINT',I8)        
      JERR = JERR + 1        
      GO TO 8128        
 8124 WRITE  (IOUT,8125) UFM,A(I)        
 8125 FORMAT (A23,' 8011, GRID POINT',I8,' HAS BOTH STRUCTURE AND ',    
     1       'FLUID ELEMENTS CONNECTED')        
      JERR = JERR + 1        
 8128 CONTINUE        
      CALL READ (*1180,*8104,GEOM2,A,NSKIP,0,M)        
      GO TO 8110        
C        
C     END-OF-FILE ON GEOM2---IF FATAL ERRORS, TERMINATE        
C        
 8130 CONTINUE        
      IF (JERR .NE. 0) CALL MESAGE (-61,A,Z)        
C        
C     OPEN BGPDT AND SIL. WRITE HEADER RECORDS. OPEN GPDT. SKIP HEADER. 
C        
      OFFSET = RSHIFT(KN,5)        
      CALL FNAME (BGPDT,A)        
      CALL FNAME (SIL,A(3))        
      FILE = BGPDT        
      CALL OPEN (*1170,BGPDT,Z(BUF1),WRTREW)        
      FILE = SIL        
      CALL OPEN (*1170,SIL,Z(BUF2),WRTREW)        
      FILE = GPDT        
      CALL OPEN   (*1170,GPDT,Z(BUF3),RDREW)        
      CALL FWDREC (*1180,GPDT)        
      CALL WRITE  (BGPDT,A,2,1)        
      CALL WRITE  (SIL,A(3),2,1)        
      LUSET = 1        
C        
C     READ AN ENTRY FROM THE GPDT.        
C     TEST FOR DEFINING COORDINATE SYSTEM.        
C        
  820 CALL READ (*1180,*970,GPDT,A,7,0,FLAG)        
      IF (A(2)) 910,880,830        
C        
C     COORDINATE SYSTEM NOT BASIC--        
C     USE CSDT IN CORE TO TRANSFORM TO BASIC.        
C        
  830 IF (NOCSTM .EQ. -1) GO TO 850        
      I = ICSDT        
  840 IF (Z(I).EQ.A(2)) GO TO 860        
      I = I + 16        
      IF (I .LE. NCSDT) GO TO 840        
  850 IERR = 6        
      SPOINT(1) = A(1)        
      SPOINT(2) = A(2)        
      GO TO 1190        
  860 AX(1) = AA(3)        
      AX(2) = AA(4)        
      AX(3) = AA(5)        
      ASSIGN 870 TO NDX        
      IF (Z(I+1)-2) 990,1000,1010        
  870 AA(3) = AR(1)        
      AA(4) = AR(2)        
      AA(5) = AR(3)        
C        
C     GRID POINT NOW BASIC--        
C     STORE DISPLACEMENT SYSTEM COORD. SYSTEM ID AND SET TYPE.        
C     MAKE SURE DISPLACEMENT COORD. SYSTEM IS DEFINED.        
C        
  880 A(2) = A(6)        
      TYPE = 1        
      KHR  = ILIST0 + A(1)        
      INCR = Z(KHR)        
C        
C     IF INCR NEGATIVE - SPECIAL HYDROELASTIC GRID POINT WITH SINGLE    
C     DEGREE OF FREEDOM        
C        
      IF (INCR .LT. 0) GO TO 905        
      IF (INCR .EQ. 0) INCR = 6        
C        
C     ///////////////////////////////        
C        
C     TEMP PATCH        
C        
      INCR = MAX0(INCR,6)        
C        
C     ///////////////////////////////        
C        
      IF (A(2).EQ.0 .AND. ITHERM.EQ.0) GO TO 920        
C        
C     IF A(2) WHICH EQUALS A(6) IS EQUAL TO -1 THEN A FLUID GRID POINT  
C     AS CREATED BY IFP4 IS AT HAND AND HAS ONLY 1 DEGREE OF FREEDOM    
C     ..... IF -HEAT- PROBLEM THEN ALL GRIDS HAVE 1 DEGREE OF FREEDOM.  
C        
      IF (A(2).EQ.(-1) .OR. ITHERM.GT.0) GO TO 905        
      IF (NOCSTM .EQ. -1) GO TO 900        
      DO 890 IJK = ICSDT,NCSDT,16        
      IF (A(2) .EQ. Z(IJK)) GO TO 920        
  890 CONTINUE        
  900 NOGO = 1        
      CALL MESAGE (30,104,A(2))        
      GO TO 920        
C        
C     SCALAR POINT-- SET TYPE.        
C        
  905 A(2) = 0        
      A(6) = 0        
  910 TYPE = 2        
      INCR = 1        
C        
C     WRITE ENTRY ON BGPDT AND SIL.        
C        
  920 CALL WRITE (BGPDT,A(2),4,0)        
      CALL WRITE (SIL, LUSET,1,0)        
C        
C     REPLACE INTERNAL NO. IN EQEXIN WITH CODED SIL NO.        
C     THEN INCREMENT SIL NO.        
C        
      NCODE = 10*LUSET + TYPE        
      IF (NOSEQ .NE. 0) GO TO 925        
      K = 2*A(1)        
      IF (Z(K) - A(1)) 950,960,950        
  925 NCODE = -NCODE        
      LMT1  = MAX0(2*(A(1)-OFFSET),2)        
      DO 930 K = LMT1,N1,2        
      IF (Z(K) .EQ. A(1)) GO TO 960        
  930 CONTINUE        
      DO 940 K = 2,LMT1,2        
      IF (Z(K) .EQ. A(1)) GO TO 960        
  940 CONTINUE        
  950 CALL MESAGE (-30,2,A)        
  960 Z(K)  = NCODE        
      LUSET = LUSET + INCR        
      GO TO 820        
C        
C     CLOSE BGPDT AND SIL. WRITE TRAILERS.        
C        
  970 CALL CLOSE (BGPDT,CLSREW)        
      CALL CLOSE (SIL,CLSREW)        
      CALL CLOSE (GPDT,CLSREW)        
      LUSET = LUSET - 1        
      IF (LUSET .LE. 65535) GO TO 974        
      IF (ICFIAT .NE. 11) WRITE (IOUT,972) UFM,LUSET        
      IF (ICFIAT .EQ. 11) WRITE (IOUT,973) UIM,LUSET        
  972 FORMAT (A23,' 3175, TOTAL NUMBER OF DEGREES OF FREEDOM IN THE ',  
     1       'PROBLEM (',I8,') EXCEEDS 65535.')        
  973 FORMAT (A29,' 3175, PROBLEM SIZE,',I8,' DOF''S, EXCEEDS THE OLD ',
     1       'LIMIT OF 65535.', /5X,'GOOD NEWS, JOB WILL CONTINUE')     
      IF (ICFIAT .NE. 11) CALL MESAGE (-61,0,0)        
  974 MCB(1) = BGPDT        
      MCB(3) = 0        
      CALL WRTTRL (MCB)        
      MCB(1) = SIL        
      MCB(3) = LUSET        
      CALL WRTTRL (MCB)        
C        
C     IF GRID NOS. ARE RESEQUENCED, SWITCH SIGN ON CODED SIL NO.        
C     WRITE SECOND RECORD OF EQEXIN. CLOSE FILE AND WRITE TRAILER.      
C        
      IF (NOSEQ .EQ. 0) GO TO 978        
      DO 976 K = 2,N1,2        
      Z(K) = -Z(K)        
  976 CONTINUE        
  978 FILE = EQEXIN        
      CALL OPEN  (*1170,EQEXIN,Z(BUF1),WRT)        
      CALL WRITE (EQEXIN,Z,N1,1)        
      CALL CLOSE (EQEXIN,CLSREW)        
      MCB(1) = EQEXIN        
      MCB(3) = 0        
      CALL WRTTRL (MCB)        
      CALL SSWTCH (36,K)        
      IF (K    .EQ. 1) CALL DIAG36 (Z,BUF1,GPL,SIL,EQEXIN)        
      IF (NOGO .NE. 0) CALL MESAGE (-61,0,0)        
      RETURN        
C        
C     ABNORMAL EXIT FROM GP1        
C        
  980 CALL CLOSE (SCR1,CLSREW)        
      CALL CLOSE (GEOM1,CLSREW)        
      NOCSTM = -1        
      RETURN        
C        
C     ===============================================================   
C        
C     INTERNAL SUBROUTINE TO TRANSFORM A RECTANGULAR GRID PT TO BASIC   
C     I POINTS TO THE CSDT ENTRY WHERE THE TRANSFORMATION IS DEFINED    
C     THE GRID PT TO BE TRANSFORMED IS STORED AT AX(1,2,3)        
C     THE TRANSFORMED GRID PT WILL BE STORED AT AR(1,2,3)        
C        
  990 AR(1) = ZZ(I+ 7)*AX(1) + ZZ(I+ 8)*AX(2) + ZZ(I+ 9)*AX(3) + ZZ(I+4)
      AR(2) = ZZ(I+10)*AX(1) + ZZ(I+11)*AX(2) + ZZ(I+12)*AX(3) + ZZ(I+5)
      AR(3) = ZZ(I+13)*AX(1) + ZZ(I+14)*AX(2) + ZZ(I+15)*AX(3) + ZZ(I+6)
      GO TO NDX, (680,750,870)        
C        
C     INTERNAL SUBROUTINE TO TRANSFORM A CYLINDRICAL GRID PT TO BASIC   
C     R,THETA,Z IS STORED AX(1,2,3)        
C        
 1000 R     = AX(1)        
      AX(2) = DEGRA*AX(2)        
      AX(1) = R*COS(AX(2))        
      AX(2) = R*SIN(AX(2))        
      GO TO 990        
C        
C        
C     INTERNAL SUBROUTINE TO TRANSFORM A SPHERICAL GRID PT TO BASIC     
C     RHO,THETA,PHI IS STORED AT AX(1,2,3)        
C        
 1010 AX(2) = DEGRA*AX(2)        
      AX(3) = DEGRA*AX(3)        
      RSTH  = AX(1)*SIN(AX(2))        
      RCTH  = AX(1)*COS(AX(2))        
      AX(1) = RSTH *COS(AX(3))        
      AX(2) = RSTH *SIN(AX(3))        
      AX(3) = RCTH        
      GO TO 990        
C        
C        
C     INTERNAL SUBROUTINE TO CALCULATE THE 3X3 TRANSFORMATION MATRIX    
C     AND 3X1 TRANSLATION VECTOR GIVEN THREE POINTS IN THE BASIC SYSTEM 
C     THE RESULTS ARE STORED BACK IN THE CSDT        
C        
C     STORE R0 = A IN THE CSDT        
C        
 1020 ZZ(II+4) = AA(1)        
      ZZ(II+5) = AA(2)        
      ZZ(II+6) = AA(3)        
C        
C     FORM B - A        
C        
      DO 1030 I = 1,3        
 1030 AK(I) = AB(I) - AA(I)        
C        
C     FORM K = (B - A)/LENGTH(B - A)        
C     FORM C - A        
C        
      LENGTH = SQRT(AK(1)**2 + AK(2)**2 + AK(3)**2)        
      DO 1040 I = 1,3        
      AK(I) = AK(I)/LENGTH        
 1040 AC(I) = AC(I) - AA(I)        
C        
C     FORM K X (C - A)        
C        
      AJ(1) = AK(2)*AC(3) - AK(3)*AC(2)        
      AJ(2) = AK(3)*AC(1) - AK(1)*AC(3)        
      AJ(3) = AK(1)*AC(2) - AK(2)*AC(1)        
C        
C     FORM J = (K X (C-A))/LENGTH(K X (C-A))        
C        
      LENGTH =  SQRT(AJ(1)**2 + AJ(2)**2 + AJ(3)**2)        
      DO 1050 I = 1,3        
 1050 AJ(I) = AJ(I)/LENGTH        
C        
C     FORM I = J X K        
C        
      AI(1) = AJ(2)*AK(3) - AJ(3)*AK(2)        
      AI(2) = AJ(3)*AK(1) - AJ(1)*AK(3)        
      AI(3) = AJ(1)*AK(2) - AJ(2)*AK(1)        
C        
C     STORE 3X3 ROTATION MATRIX = ((IX,JX,KX),(IY,JY,KY),(IZ,JZ,KZ))    
C     IN THE CSDT        
C        
      ZZ(II+ 7) = AI(1)        
      ZZ(II+ 8) = AJ(1)        
      ZZ(II+ 9) = AK(1)        
      ZZ(II+10) = AI(2)        
      ZZ(II+11) = AJ(2)        
      ZZ(II+12) = AK(2)        
      ZZ(II+13) = AI(3)        
      ZZ(II+14) = AJ(3)        
      ZZ(II+15) = AK(3)        
C        
C     SET WD 3 OF CSDT = 3 AND WD 4 = 0 TO INDICATE  SOLVED SYSTEM      
C     INCREMENT SOLVED SYSTEM COUNT        
C        
      Z(II+2) = 3        
      Z(II+3) = 0        
      SOLV = SOLV + 1        
      GO TO 700        
C        
C        
C     INTERNAL SUBROUTINE TO PERFORM BINARY SEARCH ON FIRST ENTRY       
C     OF A DOUBLE ENTRIED TABLE STORED AT Z(1) THRU Z(N+1)        
C        
 1060 KLO = 1        
      KHI = KN        
 1070 K = (KLO+KHI+1)/2        
 1080 IF (A(1)-Z(2*K-1)) 1090,1150,1100        
 1090 KHI = K        
      GO TO 1110        
 1100 KLO = K        
 1110 IF (KHI-KLO-1) 1160,1120,1070        
 1120 IF (K.EQ.KLO) GO TO 1130        
      K = KLO        
      GO TO 1140        
 1130 K = KHI        
 1140 KLO = KHI        
      GO TO 1080        
 1150 A(1) = Z(2*K)        
      GO TO NDX,  (230,340,480,490,500)        
 1160 CALL MESAGE (30,IERR,A(1))        
      NOGO = 1        
      GO TO NERR, (220,330,485,495,505)        
 1165 CALL MESAGE (-61,0,0)        
C        
C        
C     FATAL ERROR MESAGES        
C        
 1170 NDX = -1        
      GO TO 1210        
 1180 NDX = -2        
      GO TO 1210        
 1190 CALL MESAGE (-30,IERR,SPOINT)        
 1200 NDX = -3        
      GO TO 1210        
 1210 CALL MESAGE (NDX,FILE,GP1AH)        
 1220 SPOINT(1) = Z(K+3)        
      SPOINT(2) = Z(II )        
      IERR = 3        
      GO TO 1190        
 1230 SPOINT(1) = Z(II  )        
      SPOINT(2) = Z(II+3)        
      IERR = 4        
      GO TO 1190        
 1240 SPOINT(1) = 0        
      SPOINT(2) = 0        
      IERR = 5        
      GO TO 1190        
 1250 SPOINT(1) = A(1)        
      SPOINT(2) = 0        
      IERR = 12        
      GO TO 1190        
      END        
