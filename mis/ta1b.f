      SUBROUTINE TA1B        
C        
C     TA1B BUILDS THE ELEMENT CONNECTION AND PROPERTIES TABLE (ECPT)    
C     AND THE GRID POINT CONNECTION TABLE. THE ECPT CONTAINS ONE LOGICAL
C     RECORD FOR EACH GRID OR SCALAR POINT IN THE STRUCTURE.  EACH      
C     LOGICAL RECORD CONTAINS EST TYPE DATA FOR ELEMENTS CONNECTED TO   
C     THE GRID OR SCALAR POINT THE GPCT IS A SUMMARY OF THE ECPT.  EACH 
C     LOGICAL RECORD CONTAINS ALL GRID POINTS CONNECTED TO THE PIVOT (BY
C     MEANS OF STRUCTURAL ELEMENTS).        
C        
      EXTERNAL        ANDF        
      LOGICAL         EORFLG,ENDID ,RECORD        
      INTEGER         ANDF  ,GENL  ,ECT   ,EPT   ,BGPDT ,SIL   ,GPTT  , 
     1                CSTM  ,EST   ,GEI   ,ECPT  ,GPCT  ,SCR1  ,SCR2  , 
     2                SCR3  ,SCR4  ,Z     ,SYSBUF,TEMPID,ELEM  ,ELEMID, 
     3                OUTPT ,CBAR  ,PLOTEL,RD    ,RDREW ,WRT   ,WRTREW, 
     4                CLSREW,CLS   ,BUF   ,GPSAV ,FLAG  ,BUF1  ,BUF2  , 
     5                BUF3  ,FILE  ,RET   ,RET1  ,OP    ,TWO24 ,SCRI  , 
     6                SCRO  ,BLK   ,RET2  ,OUFILE,GPECT ,ELTYPE,OLDEL , 
     7                OLDEID,BUF4  ,EQEXIN,ZEROS(4)     ,QUADTS,TRIATS, 
     8                PLOT  ,REACT ,SHEAR ,TWIST ,BAR   ,PPSE        
      DIMENSION       NAM(2),BLK(2),ZZ(1) ,TGRID(33)    ,BUF(50),       
     1                BUFR(50)     ,GPSAV(34)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM   ,UWM   ,UIM   ,SFM        
      COMMON /BLANK / LUSET ,NOSIMP,NOSUP ,NOGENL,GENL  ,COMPS        
      COMMON /TA1COM/ NSIL  ,ECT   ,EPT   ,BGPDT ,SIL   ,GPTT  ,CSTM  , 
     1                MPT   ,EST   ,GEI   ,GPECT ,ECPT  ,GPCT  ,MPTX  , 
     2                PCOMPS,EPTX  ,SCR1  ,SCR2  ,SCR3  ,SCR4  ,EQEXIN  
      COMMON /SYSTEM/ KSYSTM(65)        
      COMMON /GPTA1 / NELEM ,JLAST ,INCR  ,ELEM(1)        
      COMMON /NAMES / RD    ,RDREW ,WRT   ,WRTREW,CLSREW,CLS        
      COMMON /TA1ETT/ ELTYPE,OLDEL ,EORFLG,ENDID ,BUFFLG,ITEMP ,IDFTMP, 
     1                IBACK ,RECORD,OLDEID        
CZZ   COMMON /ZZTAA2/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (KSYSTM( 1),SYSBUF) ,(KSYSTM(2),OUTPT ),        
     1                (KSYSTM(10),TEMPID) ,(IDFTMP   ,DEFTMP)        
      EQUIVALENCE     (BLK(1),NPVT), (BUF(1),BUFR(1)),(Z(1),ZZ(1)),     
     1                (BLK(2),N)        
      DATA    NAM   / 4HTA1B,3H   /,  CBAR/ 4HBAR  /, PLOT/ 4HPLOT    / 
      DATA    TWO24 / 8388608     /, ZEROS/ 0,0,0,0/, PPSE/ 4303      / 
      DATA    PLOTEL, REACT,SHEAR,TWIST,IHEX2,IHEX3,QUADTS,TRIATS,BAR / 
     1        5201  , 5251, 4,    5,    66,   67,   68,    69,    34  / 
C        
C     PERFORM GENERAL INITIALIZATION        
C        
      N2   = 2*NELEM - 1        
      N21  = N2 + 1        
      BUF1 = KORSZ(Z) - SYSBUF - 2        
      BUF2 = BUF1 - SYSBUF        
      BUF3 = BUF2 - SYSBUF        
      BUF4 = BUF3 - SYSBUF        
      NEQ1 = NSIL + 1        
      NEQ2 = 0        
      KSCALR = 0        
C        
C     THE GRID POINT COUNTER (GPC) HAS ONE ENTRY PER GRID OR SCALAR     
C     POINT IN THE STRUCTURE. EACH ENTRY CONTAINS THE NUMBER OF        
C     STRUCTURAL ELEMENTS CONNECTED TO THE POINT.        
C        
      DO 2001 I = 1,NSIL        
 2001 Z(I+1) = 0        
C        
C     OPEN THE ECT. INITIALIZE TO LOOP THRU BY ELEMENT TYPE.        
C        
      FILE = ECT        
      CALL PRELOC (*3200,Z(BUF1),ECT)        
      NOECT = 1        
      DO 2026 I = 1,JLAST,INCR        
C        
C     IGNORE PLOTEL ELEMENTS.  OTHERWISE, LOCATE AN ELEMENT TYPE.       
C     IF PRESENT, READ ALL ELEMENTS OF THAT TYPE AND INCREMENT THE GPC  
C     ENTRY FOR EACH POINT TO WHICH THE ELEMENT IS CONNECTED.        
C        
      IF (ELEM(I) .EQ. PLOT) GO TO 2026        
      CALL LOCATE (*2026,Z(BUF1),ELEM(I+3),FLAG)        
      NOECT = 0        
      LX = ELEM(I+12)        
      MM = LX + ELEM(I+9) - 1        
      M  = ELEM(I+5)        
      IF (ELEM(I+10) .EQ. 0) KSCALR = 1        
 2021 CALL READ (*3201,*2026,ECT,BUF,M,0,FLAG)        
      DO 2022 L = LX,MM        
      K  = BUF(L)        
      IF (K .NE. 0) Z(K+1) = Z(K+1) + 1        
 2022 CONTINUE        
      GO TO 2021        
 2026 CONTINUE        
      CALL CLOSE (ECT,CLSREW)        
      IF (NOECT .NE. 0) GO TO 3209        
C        
C     REPLACE ENTRIES IN THE GPC BY A RUNNING SUM THUS CREATING POINTERS
C     INTO ECPT0.  QUEUE WARNING MESSAGES FOR GRID PTS. WITH NO ELEMENTS
C     CONNECTED.        
C     (BRING IN EQEXIN AND ECHO OUT EXTERNAL GRID PT. ID  G.C/UNISYS 91)
C        
      Z(1)  = 1        
      MAXEL = 0        
      DO 2037 I = 1,NSIL        
      MAXEL = MAX0(MAXEL,Z(I+1))        
      IF (Z(I+1) .NE. 0) GO TO 2037        
C        
      J = 0        
      IF (NEQ2) 2035,2031,2033        
 2031 NEQ2 = -1        
      Z(NEQ1) = EQEXIN        
      CALL RDTRL (Z(NEQ1))        
      IF (Z(NEQ1) .LE. 0) GO TO 2035        
      FILE = EQEXIN        
      CALL GOPEN (EQEXIN,EQEXIN,Z(BUF1),RDREW)        
      CALL READ (*3200,*2032,EQEXIN,Z(NEQ1),BUF4,1,NEQ2)        
 2032 CALL CLOSE (EQEXIN,CLSREW)        
      CALL SORT (0,0,2,2,Z(NEQ1),NEQ2)        
 2033 J = Z((I-1)*2+NEQ1)        
C        
 2035 BUF(1) = I        
      BUF(2) = J        
      CALL MESAGE (30,15,BUF)        
 2037 Z(I+1) = Z(I) + Z(I+1)        
C        
C     DETERMINE BAND OF ENTRIES IN ECPT0 WHICH WILL FIT IN CORE        
C     NDX1 = POINTER IN GPC TO 1ST  ENTRY FOR CURRENT PASS.        
C     NDX2 = POINTER IN GPC TO LAST ENTRY FOR CURRENT PASS.        
C        
      NDX1 = 1        
      NDX2 = NSIL        
      LLX  = 1        
      IECPT0 = NSIL + 2        
      LENGTH = BUF1 - IECPT0        
      OP   = WRTREW        
 2042 IF (Z(NDX2+1)-Z(NDX1)+2 .LE. LENGTH) GO TO 2050        
      NDX2 = NDX2 - 1        
      GO TO 2042        
C        
C     PASS THE ECT. FOR EACH GRID PT IN RANGE ON THIS PASS,        
C     STORE ELEMENT POINTER = 2**24 * J + WORD POSITION IN ECT RECORD.  
C     WHERE J= (POINTER IN ELEM TABLE - 1)/INCR * 2 +1        
C        
 2050 CALL PRELOC (*3200,Z(BUF1),ECT)        
      IZERO = Z(NDX1)        
      J = 1        
      DO 2055 I = 1,JLAST,INCR        
      IF (ELEM(I) .EQ. PLOT) GO TO 2055        
      IDCNTR = TWO24*J        
      CALL LOCATE (*2055,Z(BUF1),ELEM(I+3),FLAG)        
      M  = ELEM(I+ 5)        
      LX = ELEM(I+12)        
      MM = LX + ELEM(I+9) - 1        
 2052 CALL READ (*3201,*2055,ECT,BUF,M,0,FLAG)        
      DO 2054 L = LX,MM        
      K  = BUF(L)        
      IF (K.LT.NDX1 .OR. K.GT.NDX2) GO TO 2054        
      IX = Z(K) - IZERO + IECPT0        
      Z(IX) = IDCNTR        
      Z(K ) = Z(K) + 1        
 2054 CONTINUE        
      IDCNTR = IDCNTR + M        
      GO TO 2052        
 2055 J = J + 2        
      CALL CLOSE (ECT,CLSREW)        
C        
C     WRITE ECPT0 AND TEST FOR ADDITIONAL PASSES        
C     ECPT0 CONTAINS ONE LOGICAL RECORD FOR EACH GRID OR SCALAR POINT.  
C     EACH LOGICAL RECORD CONTAINS N PAIRS OF(-1,ELEMENT POINTER)WHERE  
C     N= NUMBER OF ELEMENTS CONNECTED TO THE PIVOT.        
C     IF NO ELEMENTS CONNECTED TO POINT, RECORD IS ONE WORD = 0.        
C        
      FILE = SCR1        
      CALL OPEN (*3200,SCR1,Z(BUF1),OP)        
      BUF(1) = -1        
      LJ = IECPT0 - 1        
      DO 2062 I = NDX1,NDX2        
      M  = Z(I) - LLX        
      IF (M .NE. 0) GO TO 2063        
      CALL WRITE (SCR1,0,1,1)        
      GO TO 2062        
 2063 DO 2061 J = 1,M        
      LJ = LJ + 1        
      BUF(2) = Z(LJ)        
 2061 CALL WRITE (SCR1,BUF,2,0)        
      CALL WRITE (SCR1,0,0,1)        
 2062 LLX = Z(I)        
      IF (NDX2 .GE. NSIL) GO TO 2070        
      CALL CLOSE (SCR1,CLS)        
      NDX1 = NDX2 + 1        
      NDX2 = NSIL        
      OP   = WRT        
      GO TO 2042        
C        
C     READ AS MUCH OF ECT AS CORE CAN HOLD        
C     FIRST N21 CELLS OF CORE CONTAIN A POINTER TABLE WHICH HAS TWO     
C     ENTRIES PER ELEMENT TYPE. 1ST ENTRY HAS POINTER TO 1ST WORD OF    
C     ECT DATA IN CORE FOR AN ELEMENT TYPE  2ND ENTRY HAS WORD POSITION 
C     IN ECT RECORD OF THAT TYPE FOR LAST ENTRY READ ON PREVIOUS PASS.  
C        
 2070 CALL CLOSE (SCR1,CLSREW)        
      SCRI = SCR1        
      SCRO = SCR2        
      CALL PRELOC (*3200,Z(BUF1),ECT)        
      I = 1        
      IELEM = 1        
      DO 2071 J = 1,N21        
 2071 Z(J) = 0        
      L = N21 + 1        
 2072 IF (ELEM(IELEM+3).EQ.PLOTEL .OR. ELEM(IELEM+3).EQ.REACT)        
     1    GO TO 2074        
      CALL LOCATE (*2074,Z(BUF1),ELEM(IELEM+3),FLAG)        
      Z(I) = L        
      LL   = 0        
      M    = ELEM(IELEM+5)        
      LAST = BUF3 - M        
 2073 IF (L .GT. LAST) GO TO 2080        
      CALL READ (*3201,*2074,ECT,Z(L),M,0,FLAG)        
      L  = L  + M        
      LL = LL + M        
      GO TO 2073        
 2074 I  = I + 2        
      IELEM = IELEM + INCR        
      IF (IELEM .LE. JLAST) GO TO 2072        
C        
C     PASS ECPT0 ENTRIES LINE BY LINE        
C     ATTACH EACH REFERENCED ECT ENTRY WHICH IS NOW IN CORE        
C        
 2080 CALL OPEN (*3200,SCRI,Z(BUF2),RDREW)        
      CALL OPEN (*3200,SCRO,Z(BUF3),WRTREW)        
 2082 CALL READ (*2090,*2086,SCRI,BUF,1,0,FLAG)        
      IF (BUF(1)) 2083,2087,2085        
 2083 CALL READ (*3201,*3202,SCRI,BUF(2),1,0,FLAG)        
      K = BUF(2)/TWO24        
      KTWO24 = K*TWO24        
      IDPTR  = BUF(2) - KTWO24        
      KK = Z(K) + IDPTR - Z(K+1)        
      IF (Z(K).EQ.0 .OR. KK.GT.LAST) GO TO 2084        
      J  = ((K-1)/2)*INCR + 1        
      MM = ELEM(J+5)        
      BUF(1) = MM        
      BUF(2) = Z(KK) + KTWO24        
      CALL WRITE (SCRO,BUF,2,0)        
      CALL WRITE (SCRO,Z(KK+1),MM-1,0)        
      GO TO 2082        
 2084 CALL WRITE (SCRO,BUF,2,0)        
      GO TO 2082        
 2085 CALL READ  (*3201,*3202,SCRI,BUF(2),BUF(1),0,FLAG)        
      CALL WRITE (SCRO,BUF,BUF(1)+1,0)        
      GO TO 2082        
 2086 CALL WRITE (SCRO,0,0,1)        
      GO TO 2082        
 2087 CALL WRITE (SCRO,0,1,1)        
      CALL FWDREC (*3201,SCRI)        
      GO TO 2082        
C        
C     TEST FOR COMPLETION OF STEP        
C     IF INCOMPLETE, SET FOR NEXT PASS        
C        
 2090 CALL CLOSE (SCRI,CLSREW)        
      CALL CLOSE (SCRO,CLSREW)        
      IF (I .GT. N2) GO TO 2100        
      K    = SCRI        
      SCRI = SCRO        
      SCRO = K        
      L = N21 + 1        
      DO 2091 J = 1,N21        
 2091 Z(J) = 0        
      Z(I) = L        
      Z(I+1) = LL        
      GO TO 2073        
C        
C     READ THE EPT INTO CORE (IF PRESENT)        
C     FIRST N21 CELLS OF CORE CONTAINS PROPERTIES POINTER TABLE WHICH   
C     HAS TWO WORDS PER ELEMENT TYPE, 1ST WORD HAS POINTER TO 1ST WORD  
C     OF PROPERTY DATA FOR THAT ELEMENT TYPE. 2ND WORD HAS NUMBER OF    
C     PROPERTY CARDS FOR THAT TYPE.        
C        
 2100 CALL CLOSE (ECT,CLSREW)        
      DO 2101 I = 1,N21        
 2101 Z(I) = 0        
      L = 1        
      CALL PRELOC (*2120,Z(BUF1),EPT)        
      IELEM  = 1        
      LSTPRP = 0        
      L = N21 + 1        
      DO 2107 II = 1,N2,2        
      IF (ELEM(IELEM+6).EQ.LSTPRP .AND. LSTPRP.NE.PPSE) GO TO 2106      
      CALL LOCATE (*2107,Z(BUF1),ELEM(IELEM+6),FLAG)        
      LSTPRP = ELEM(IELEM+6)        
      M      = ELEM(IELEM+8)        
      ELTYPE = ELEM(IELEM+2)        
      Z(II)  = L        
 2102 IF (L+M .GE. BUF3) CALL MESAGE (-8,0,NAM)        
      CALL READ (*3201,*2103,EPT,Z(L),M,0,FLAG)        
      L = L + M        
      GO TO 2102        
 2103 N = L - Z(II)        
      Z(II+1) = N/M        
      IF (ELTYPE.EQ.SHEAR .OR. ELTYPE.EQ.TWIST) GO TO 2104        
      IF (M .GT. 4) GO TO 2107        
 2104 I = Z(II)        
      CALL SORT (0,0,M,1,Z(I),N)        
      GO TO 2107        
 2106 N = 4        
      IF (ELTYPE.EQ.IHEX2 .OR. ELTYPE.EQ.IHEX3) N = 2        
      Z(II  ) = Z(II-N  )        
      Z(II+1) = Z(II-N+1)        
 2107 IELEM   = IELEM + INCR        
      CALL CLOSE (EPT,CLSREW)        
C        
C     DETERMINE IF THE BGPDT AND SIL        
C     WILL FIT IN CORE ON TOP OF THE EPT.        
C        
      NUMBER = 4*KSCALR + 1        
      IBACK  = 0        
      LENGTH = BUF4 - L - 4*MAXEL        
      IF (NUMBER*NSIL .GT. LENGTH) GO TO 2150        
C        
C     IF YES, READ THE BGPDT,SIL AND GPTT INTO CORE        
C        
 2120 ASSIGN 2130 TO RET        
      IPASS = 1        
      GO TO 3050        
C        
C     PASS ECPT0 LINE BY LINE        
C     FOR EACH ECT ENTRY, 1. ATTACH PROPERTY DATA (IF DEFINED)        
C     2. ATTACH BASIC GRID POINT DATA (UNLESS SCALER ELEMENT), AND      
C     3. CONVERT GRID PT NOS TO SIL VALUES        
C     4. IF TEMPERATURE PROBLEM, ATTACH ELEMENT TEMP(UNLESS SCALAR ELEM)
C        
 2130 INFILE = SCRO        
      OUFILE = ECPT        
C        
C     OPEN ECPT0, ECPT AND GPCT FILES        
C        
 2144 GO TO 3060        
C        
C     WRITE PIVOT GRID POINT ON ECPT        
C        
 2131 IF (LL-LOCSIL .GE. NSIL) GO TO 2179        
      IF (IBACK .LE. 0) GO TO 21311        
      CALL BCKREC (GPTT)        
C        
C     RESET /TA1ETT/ VARIABLES        
C        
      IBACK  = 0        
      OLDEID = 0        
      OLDEL  = 0        
      EORFLG =.FALSE.        
      ENDID  =.TRUE.        
      CALL READ (*3201,*3202,GPTT,ISET,1,0,FLAG)        
      IF (ISET .EQ. TEMPID) GO TO 21311        
      WRITE (OUTPT,3084) SFM,ISET,TEMPID        
      CALL MESAGE (-61,0,0)        
21311 NPVT = Z(LL)        
      CALL WRITE (ECPT,NPVT,1,0)        
      IF (Z(LL+1)-Z(LL) .EQ. 1) NPVT = -NPVT        
      I = LOCGPC        
C        
C     READ AN ECT LINE FROM ECPT0. SET POINTERS AS A FUNCTION OF ELEM   
C     TYPE.  IF ELEMENT IS BAR, PROCESS ORIENTATION VECTOR.  AXIS AND   
C     THE STRESS AXIS DEFINITION BASED ON GRID POINTS MA AND SA.        
C        
 2132 CALL READ (*3201,*2138,INFILE,BUF(1),1,0,FLAG)        
      IF (BUF(1)) 3207,2143,2133        
 2133 CALL READ (*3201,*3202,INFILE,BUF(2),BUF(1),0,FLAG)        
      IK = BUF(2)/TWO24        
      II = ((IK-1)/2)*INCR + 1        
      LX = ELEM(II+12) + 1        
      M  = ELEM(II+ 8)        
      JSCALR =  ELEM(II+10)        
      MM = LX + ELEM(II+ 9) - 1        
      LQ = 4        
      IF (M .EQ. 0) LQ = 3        
      NAME  = ELEM(II   )        
      JTEMP = ELEM(II+13)        
      ELTYPE= ELEM(II+ 2)        
      NTEMP = 1        
      IF (JTEMP .EQ. 4) NTEMP = ELEM(II+14) - 1        
      IF (ELTYPE .EQ. QUADTS) GO TO 3083        
      IF (ELTYPE .EQ. TRIATS) GO TO 30841        
      IF (NAME   .EQ.   CBAR) GO TO 3080        
C        
C     SAVE INTERNAL GRID NOS AND CONVERT TO SIL NOS.        
C        
 2141 GO TO 3030        
C        
C     IF ONE   PASS, WRITE ECT       SECTION  OF ECPT LINE.        
C     IF TWO PASSES, WRITE ECT + EPT SECTIONS OF ECPT LINE.        
C        
 2134 ID = BUF(3)        
      NX = BUF(1) + 2 - LQ        
      BUF(1) = ELEM(II+2)        
      BUF(2) = BUF(2) - IK*TWO24        
      ELEMID = BUF(2)        
      CALL WRITE (ECPT,BUF(1),2,0)        
      CALL WRITE (ECPT,BUF(LQ),NX,0)        
      IF (IPASS .EQ. 2) GO TO 2137        
C        
C     IF PROPERTY DATA IS DEFINED, LOOK UP AND WRITE EPT SECTION OF ECPT
C        
      IF (M .EQ. 0) GO TO 2137        
      ASSIGN 2137 TO RET        
      GO TO 3040        
C        
C     IF ELEMENT IS NOT A SCALAR ELEMENT,        
C     WRITE BGPDT AND ELEMENT TEMPERATURE SECTIONS OF ECPT LINE.        
C        
 2137 IF (JSCALR .NE. 0) GO TO 2132        
      GO TO 3090        
C        
C     CLOSE ECPT RECORD. WRITE GPCT RECORD.        
C        
 2138 CALL WRITE (ECPT,0,0,1)        
      GO TO 3070        
C        
C     HERE IF NO ELEMENTS CONNECTED TO PIVOT.        
C        
 2143 CALL WRITE (ECPT,0,0,1)        
      IF (NOGPCT .NE. 0) CALL WRITE (GPCT,NPVT,1,1)        
      LL = LL + 1        
      CALL FWDREC (*3202,INFILE)        
      GO TO 2131        
C        
C     HERE IF ECPT CONSTRUCTION IS TWO PASSES.        
C     PASS ECPT0 LINE BY LINE FOR EACH ECT ENTRY, ATTACH PROPERTY DATA  
C     IF DEFINED        
C        
 2150 CALL OPEN (*3200,SCRO,Z(BUF1),RDREW)        
      CALL OPEN (*3200,SCRI,Z(BUF2),WRTREW)        
      OUFILE = SCRI        
C        
C     READ AN ECT LINE FROM ECT0. SET POINTERS AS FUNCTION OF ELEM TYPE.
C        
 2152 CALL READ (*2159,*2156,SCRO,BUF,1,0,FLAG)        
      IF (BUF(1)) 3207,2158,2153        
 2153 CALL READ (*3201,*3203,SCRO,BUF(2),BUF(1),0,FLAG)        
      IK = BUF(2)/TWO24        
      II = ((IK-1)/2)*INCR + 1        
      M  = ELEM(II+8)        
      NX = BUF(1) + 1        
C        
C     IF PROPERTY DATA IS DEFINED FOR ELEMENT, WRITE ECT DATA ON SCRI,  
C     THEN LOOK UP AND WRITE EPT DATA ON SCRI.        
C        
      IF (M .EQ. 0) GO TO 2155        
      ID = BUF(3)        
      BUF(1) = BUF(1) + M - 1        
      CALL WRITE (SCRI,BUF(1),NX,0)        
      ASSIGN 2152 TO RET        
      GO TO 3040        
C        
C     PROPERTY DATA NOT DEFINED. WRITE ECT LINE ON SCRI.        
C        
 2155 CALL WRITE (SCRI,BUF,NX,0)        
      GO TO 2152        
C        
C     CLOSE RECORD. RETURN FOR ANOTHER PIVOT.        
C        
 2156 CALL WRITE (SCRI,0,0,1)        
      GO TO 2152        
C        
C     ALL PIVOTS COMPLETE. CLOSE FILES.        
C        
 2159 CALL CLOSE (SCRO,CLSREW)        
      CALL CLOSE (SCRI,CLSREW)        
      GO TO 2160        
C        
C     HERE IF NO ELEMENTS CONNECTED TO PIVOT.        
C        
 2158 CALL WRITE  (SCRI,0,1,1)        
      CALL FWDREC (*3201,SCRO)        
      GO TO 2152        
C        
C     READ THE BGPDT, SIL AND, IF TEMPERATURE PROBLEM,        
C     THE GPTT INTO CORE.        
C        
 2160 L = 1        
      ASSIGN 2170 TO RET        
      GO TO 3050        
C        
C     SET POINTERS AND BRANCH TO COMMON CODE TO ASSEMBLE ECPT.        
C        
 2170 INFILE = SCRI        
      OUFILE = ECPT        
      IPASS  = 2        
      GO TO 2144        
C        
C     CLOSE FILES, WRITE TRAILERS AND EXIT.        
C        
 2179 CALL CLOSE (INFILE,CLSREW)        
      CALL CLOSE (GPTT,CLSREW)        
      CALL CLOSE (ECPT,CLSREW)        
      BUF(1) = ECT        
      CALL RDTRL (BUF(1))        
      BUF(3) = 0        
      K  = 8192        
      K1 = ANDF(BUF(5),K)        
      IF (K1 .NE. K) GO TO 2180        
      BUF(3) = 1        
      IRIGD  = 1        
 2180 CONTINUE        
      BUF(1) = ECPT        
      DO 21791 I = 2,7        
      BUF(I) = 7        
21791 CONTINUE        
      CALL WRTTRL (BUF)        
      IF (NOGPCT .EQ. 0) RETURN        
      CALL CLOSE (GPCT,CLSREW)        
      BUF(1) = GPCT        
      CALL WRTTRL (BUF)        
      RETURN        
C        
C        
C     INTERNAL BINARY SEARCH ROUTINE        
C        
 3000 KLO = 1        
 3001 K   = (KLO+KHI+1)/2        
 3008 KX  = (K-1)*M + LOCX        
      IF (ID-Z(KX)) 3002,3009,3003        
 3002 KHI = K        
      GO TO 3004        
 3003 KLO = K        
 3004 IF (KHI-KLO-1) 30091,3005,3001        
 3005 IF (K .EQ. KLO) GO TO 3006        
      K   = KLO        
      GO TO 3007        
 3006 K   = KHI        
 3007 KLO = KHI        
      GO TO 3008        
 3009 GO TO RET1, (3041)        
30091 GO TO RET2, (3205)        
C        
C        
C     INTERNAL ROUTINE TO SAVE GRID PTS IN AN ECT LINE        
C     AND CONVERT GRID PT NOS IN ECT LINE TO SIL VALUES        
C        
 3030 DO 3032 L = LX,MM        
      GPSAV(L) = 0        
      IF (BUF(L) .EQ. 0) GO TO 3032        
      GPSAV(L) = BUF(L)        
      K  = GPSAV(L) + LOCSIL - 1        
      BUF(L) = Z(K)        
      IX = 0        
      IF (Z(K+1)-Z(K) .EQ. 1) IX = 1        
      Z(I) = 2*Z(K) + IX        
      I  = I + 1        
 3032 CONTINUE        
      IF (I .GE. BUF3) CALL MESAGE (-8,0,NAM)        
      GO TO 2134        
C        
C        
C     INTERNAL ROUTINE TO ATTACH EPT DATA        
C        
 3040 LOCX = Z(IK)        
      IF (LOCX .EQ. 0) GO TO 3206        
      KHI  = Z(IK+1)        
      ASSIGN 3041 TO RET1        
      ASSIGN 3205 TO RET2        
      GO TO 3000        
 3041 CALL WRITE (OUFILE,Z(KX+1),M-1,0)        
      GO TO RET, (2137,2152)        
C        
C     INTERNAL ROUTINE TO READ THE BGPDT, SIL AND GPTT INTO CORE        
C        
 3050 NBGP   = 0        
      LOCBGP = L        
      IF (KSCALR .EQ. 0) GO TO 3059        
      CALL OPEN (*3200,BGPDT,Z(BUF1),RDREW)        
      CALL FWDREC (*3201,BGPDT)        
      NBGP  = 4*NSIL        
      CALL READ (*3201,*3202,BGPDT,Z(LOCBGP),NBGP,1,FLAG)        
      CALL CLOSE (BGPDT,CLSREW)        
 3059 L = L + NBGP        
      CALL OPEN (*3200,SIL,Z(BUF1),RDREW)        
      CALL FWDREC (*3201,SIL)        
      LOCSIL = LOCBGP + NBGP        
      CALL READ (*3201,*3203,SIL,Z(LOCSIL),NSIL,1,FLAG)        
      CALL CLOSE (SIL,CLSREW)        
      NX = LOCSIL + NSIL        
      Z(NX)  = LUSET + 1        
      LOCTMP = NX + 1        
      NTMP   = LOCTMP - 1        
      RECORD =.FALSE.        
      ITEMP  = TEMPID        
      IBACK  = 0        
      IF (TEMPID .EQ. 0) GO TO 3058        
      FILE   = GPTT        
      CALL OPEN (*3200,GPTT,Z(BUF4),RDREW)        
      CALL READ (*3201,*3051,GPTT,Z(LOCTMP),BUF3-LOCTMP,0,NID)        
      CALL MESAGE (-8,0,NAM)        
 3051 ITMPID = LOCTMP + 2        
      NTMPID = LOCTMP + NID - 3        
      DO 3052 IJK = ITMPID,NTMPID,3        
      IF (TEMPID .EQ. Z(IJK)) GO TO 3053        
 3052 CONTINUE        
      GO TO 3210        
 3053 IDFTMP = Z(IJK+1)        
      IF (IDFTMP . NE. -1) DEFTMP = ZZ(IJK+1)        
      N = Z(IJK+2)        
      IF (N .EQ. 0) GO TO 3058        
      RECORD =.TRUE.        
      N = N - 1        
      IF (N .EQ. 0) GO TO 3055        
      DO 3054 IJK = 1,N        
      CALL FWDREC (*3201,GPTT)        
 3054 CONTINUE        
C        
C     READ SET ID AND VERIFY FOR CORRECTNESS        
C        
 3055 CALL READ (*3201,*3202,GPTT,ISET,1,0,FLAG)        
      IF (ISET .EQ. TEMPID) GO TO 3061        
      WRITE  (OUTPT,3084) SFM,ISET,TEMPID        
 3084 FORMAT (A25,' 4021, TA1B HAS PICKED UP TEMPERATURE SET',I9,       
     1       ' AND NOT THE REQUESTED SET',I9,1H.)        
      CALL MESAGE (-61,0,NAM)        
C        
C     INITIALIZE /TA1ETT/ VARIABLES        
C        
 3061 OLDEID = 0        
      OLDEL  = 0        
      EORFLG =.FALSE.        
      ENDID  =.TRUE.        
 3058 GO TO RET, (2130,2170)        
C        
C        
C     INTERNAL ROUTINE TO OPEN SCRATCH, ECPT AND GPCT FILES        
C        
 3060 CALL OPEN (*3200,INFILE,Z(BUF1),RDREW)        
      CALL OPEN (*3200,ECPT,Z(BUF2),WRTREW)        
      CALL FNAME (ECPT,BUF)        
      CALL WRITE (ECPT,BUF,2,1)        
      NOGPCT = 0        
      CALL OPEN (*3062,GPCT,Z(BUF3),WRTREW)        
      NOGPCT = 1        
      CALL FNAME (GPCT,BUF)        
      CALL WRITE (GPCT,BUF,2,1)        
 3062 LL = LOCSIL        
      LOCGPC = NTMP + 1        
      GO TO 2131        
C        
C     INTERNAL ROUTINE TO SORT AND WRITE THE GPCT        
C        
 3070 IF (NOGPCT .EQ. 0) GO TO 3073        
      N = I - LOCGPC        
      CALL SORT (0,0,1,1,Z(LOCGPC),N)        
      Z(I) = 0        
      J  = LOCGPC        
      II = LOCGPC        
 3071 IF (Z(II) .EQ. Z(II+1)) GO TO 3072        
      NX = Z(II)/2        
      LX = Z(II) - 2*NX        
      IF (LX .NE. 0) NX = -NX        
      Z(J) = NX        
      J  = J  + 1        
 3072 II = II + 1        
      IF (II .LT. I) GO TO 3071        
      N  = J - LOCGPC        
      CALL WRITE (GPCT,BLK,2,0)        
      CALL WRITE (GPCT,Z(LOCGPC),N,1)        
 3073 LL = LL + 1        
      GO TO 2131        
C        
C     FOR BAR ELEMENTS, STORE COORDINATES AND        
C     COORDINATE SYSTEM ID FOR ORIENTATION VECTOR.        
C        
 3080 KX = 4*(BUF(4)-1) + LOCBGP        
      IF (BUF(9) .EQ. 1) GO TO 3082        
      BUF(9) = BUF(6)        
      IF (BUF(9) .EQ. 0) GO TO 3082        
      K = 4*(BUF(9)-1) + LOCBGP        
      BUFR(6) = ZZ(K+1) - ZZ(KX+1)        
      BUFR(7) = ZZ(K+2) - ZZ(KX+2)        
      BUFR(8) = ZZ(K+3) - ZZ(KX+3)        
      BUF(9)  = 0        
      GO TO 2141        
 3082 BUF(9)  = Z(KX)        
      GO TO 2141        
C        
C     FOR QUADTS AND TRIATS ELEMENTS, STORE COORDINATES FOR MATERIAL    
C     AND STRESS AXIS DEFINITION        
C        
 3083 IS1 = 12        
      GO TO 3085        
30841 IS1 = 10        
 3085 IS2 = IS1 + 9        
      DO 3086 IST = IS1,IS2,3        
      IGP = BUF(IST)        
      IF (IGP .EQ. 0) GO TO 3086        
      K = 4*(IGP-1) + LOCBGP        
      BUFR(IST  ) = ZZ(K+1)        
      BUFR(IST+1) = ZZ(K+2)        
      BUFR(IST+2) = ZZ(K+3)        
 3086 CONTINUE        
      GO TO 2141        
C        
C     CODE TO WRITE BGPDT AND ELEMENT TEMPERATURE SECTIONS OF ECAT LINE.
C        
 3090 DO 3095 L = LX,MM        
      IF (GPSAV(L) .EQ. 0) GO TO 3094        
      K = LOCBGP + 4*(GPSAV(L)-1)        
      CALL WRITE (ECPT,Z(K),4,0)        
      GO TO 3095        
 3094 CALL WRITE (ECPT,ZEROS,4,0)        
 3095 CONTINUE        
      CALL TA1ETD (ELEMID,TGRID,NTEMP)        
      IF (ELTYPE .EQ. BAR) TGRID(1) = (TGRID(1)+TGRID(2))/2.0        
      CALL WRITE (ECPT,TGRID,NTEMP,0)        
      GO TO 2132        
C        
C     FATAL ERROR MESAGES        
C        
 3200 J = -1        
      GO TO 3220        
 3201 J = -2        
      GO TO 3220        
 3203 CONTINUE        
 3202 J = -3        
      GO TO 3220        
 3205 BUF(1) = ELEMID        
      BUF(2) = ID        
      N = 10        
      GO TO 3219        
 3206 BUF(1) = ELEM(II  )        
      BUF(2) = ELEM(II+1)        
      N = 11        
      GO TO 3219        
 3207 BUF(1) = 0        
      BUF(2) = 0        
      N = 14        
      GO TO 3219        
 3209 BUF(1) = 0        
      BUF(2) = 0        
      N = 13        
      GO TO 3219        
 3210 BUF(1) = TEMPID        
      BUF(2) = 0        
      N = 44        
 3219 CALL MESAGE (-30,N,BUF)        
 3220 CALL MESAGE (J,FILE,NAM)        
      RETURN        
      END        
