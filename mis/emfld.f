      SUBROUTINE EMFLD        
C        
C                                            SEE T01191A     ===========
C     COMPUTES TOTAL MAGNETIC FIELD STRENGTH AND INDUCTION FOR        
C     EACH ELEMENT IN BASIC COORDINATES BY ADDING HM AND HC        
C        
C     EMFLD    HOEF1,HEST,CASECC,HCFLD,MPT,DIT,REMFLD,GEOM1,CSTM,HCCEN/ 
C              HOEH1/V,N,HLUSET $        
C        
      INTEGER         HEST,HOEH1,HOEF1,CASECC,ESTFLD,HLUSET,DIT,        
     1                FILE,BUF1,BUF2,BUF3,BUF4,BUF5,SYSBUF,OTPE,TYPOUT, 
     2                ELTYPE,SUBCAS,ELID,OLDCAS,OLDEID,STRSPT,        
     3                REMFL,BUF6,IDUM(2),GEOM1,CSTM,HCCEN,HCOUNT        
      DIMENSION       COORD(4),ICOORD(4),TA(9),TEMP(3),MCB(7),HMG(3),   
     1                HM(3),HC(3),IBUF(150),RBUF(150),NAM(2),IZ(1),ZN(2)
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /BLANK / HLUSET        
      COMMON /GPTA1 / NELEMS,LAST,INCR,NE(1)        
      COMMON /SYSTEM/ SYSBUF,OTPE        
      COMMON /UNPAKX/ TYPOUT,II,NN,INCUR        
CZZ   COMMON /ZZEMFL/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (RBUF(1),IBUF(1)),(COORD(1),ICOORD(1)),        
     1                (Z(1),IZ(1))        
      DATA    HOEF1 , HEST,CASECC,MPT,DIT/ 101,102,103, 105,106/        
      DATA    REMFL , GEOM1,CSTM,HCCEN   / 107,108,109, 110    /        
      DATA    ESTFLD, HOEH1/301,201 /        
      DATA    NAM   / 4HEMFL,4HD    /, ZN/ 4HHOEH,4H1          /        
      DATA    HEX1  , HEX2, HEX3    /  4HHEX1,4HHEX2,4HHEX3    /        
C        
C     CHECK TO SEE IF HOEF1 EXISTS. IF NOT, THEN NO MAG. FIELD REQUESTS 
C        
      MCB(1) = HOEF1        
      CALL RDTRL (MCB)        
      IF (MCB(1) .LT. 0) GO TO 600        
      MCB(1) = HCCEN        
      CALL RDTRL (MCB)        
      NN = MCB(3)        
      IF (MCB(1) .GT. 0) GO TO 20        
      NN = 0        
      MCB(1) = REMFL        
      CALL RDTRL (MCB)        
      IF (MCB(1) .GT. 0) GO TO 20        
      WRITE  (OTPE,10)  UWM        
   10 FORMAT (A25,', DATA BLOCKS HCFLD AND REMFL ARE PURGED IN EM ',    
     1       'PROBLEM. ALL RESULTS ARE ZERO')        
      GO TO 600        
C        
   20 MCB(1) = HEST        
      CALL RDTRL (MCB)        
      NELX = 3*MCB(2)        
C        
      TYPOUT = 1        
      II     = 1        
      INCUR  = 1        
C        
C     CREATE ESTFLD WHICH LOOKS LIKE HEST BUT CONTAINS ONLY TYPE, ID,   
C     NUMBER OF SILS,SILS,3 X 3 MATERAIL MATRIX,AND 3 X 3 TRANSFORMATION
C     MATRIX FROM LOCAL TO BASIC,BFIELD,AND COORDS OF STRESS POINT FOR  
C     NON-RECTANGULAR BFIELD        
C        
      CALL ESTMAG (HEST,ESTFLD,MPT,DIT,GEOM1,IANY,KCOUNT)        
C        
C     KCOUNT SHOULD BE NUMBER OF TERMS IN ROW OF HCCEN        
C        
      IF (NN .EQ. 0) NN = KCOUNT        
      IF (NN .NE. KCOUNT) GO TO 500        
      NROWS = NN        
C        
C     NOW FETCH HC AT EACH POINT FROM HCFLD        
C        
      LCORE = KORSZ(Z)        
      BUF1  = LCORE- SYSBUF + 1        
      BUF2  = BUF1 - SYSBUF        
      BUF3  = BUF2 - SYSBUF        
      BUF4  = BUF3 - SYSBUF        
      BUF5  = BUF4 - SYSBUF        
      BUF6  = BUF5 - SYSBUF        
      LCORE = BUF6 - 1        
      IF (LCORE .LE. 0) GO TO 550        
C        
      NCOUNT = 0        
      OLDCAS = 0        
      HCOUNT = 0        
C        
C     COPY HEADER FROM HOEF1 TO HOEH1        
C        
      FILE = HOEH1        
      CALL OPEN (*520,HOEH1,Z(BUF5),1)        
      FILE = HOEF1        
      CALL OPEN (*520,HOEF1,Z(BUF4),0)        
      CALL READ (*530,*30,HOEF1,Z,LCORE,0,IWORDS)        
      GO TO 550        
   30 Z(1) = ZN(1)        
      I    = 2        
      Z(I) = ZN(2)        
      CALL WRITE (HOEH1,Z,IWORDS,1)        
C        
C     OPEN CSTM FOR NON-BASIC COORDINATE SYSTEM        
C        
      NCSTM = 0        
      IF (IANY .EQ. 0) GO TO 50        
      CALL GOPEN (CSTM,Z(BUF1),0)        
      CALL READ  (*530,*40,CSTM,Z,LCORE,0,NCSTM)        
      GO TO 550        
   40 CALL CLOSE  (CSTM,1)        
      CALL PRETRS (Z(1),NCSTM)        
C        
   50 NNCR = NCSTM + NROWS        
      NALL = NNCR  + NELX        
      CALL GOPEN (CASECC,Z(BUF1),0)        
      CALL GOPEN (HCCEN,Z(BUF2),0)        
      CALL GOPEN (ESTFLD,Z(BUF3),0)        
      CALL GOPEN (REMFL,Z(BUF6),0)        
C        
C     READ ID RECORD FROM HOEF1. COPY TO HOEH1, EXCEPT CHANGE NUMBER OF 
C     WORDS FROM +9 TO -9 AS AN INDICATOR FOR TITLES IN OFP. (+9 IS FOR 
C     HEAT TRANSFER) ALSO PICK UP SUBCASE NUMBER AND ELEMENT TYPE. IF   
C     SAME SUBCASE AS PREVIUUS ONE, USE SAME HCFLD VECTOR. IF NOT,      
C     CREATE A NEW ONE        
C        
   60 CALL READ (*410,*540,HOEF1,IBUF,146,1,IWORDS)        
      IBUF(10) = -9        
      CALL WRITE (HOEH1,IBUF,146,1)        
      ELTYPE = IBUF(3)        
      SUBCAS = IBUF(4)        
      OLDEID = 0        
      IF (SUBCAS .EQ. OLDCAS) GO TO 260        
      OLDCAS = SUBCAS        
      NCOUNT = 0        
      HCOUNT = 0        
      CALL REWIND (ESTFLD)        
      FILE   = ESTFLD        
      CALL FWDREC (*530,ESTFLD)        
C        
C     IF THIS SUBCASE IS NOT A SUBCOM, UNPACK NEXT COLUMN OF HCFLD. IF  
C     IT IS A SUBCOM, BCKREC HCFLD THE SAME NUMBER OF RECORDS AS THERE  
C     ARE FACTORS ON THE SUBSEQ AND COMBINE VECTORS TO PRODUCE ONE      
C     VECTOR.        
C        
      IF (LCORE .LT. 16) GO TO 550        
   70 FILE = CASECC        
      CALL READ (*530,*540,CASECC,Z(NCSTM+1),16,0,IWORDS)        
      IF (IZ(NCSTM+1) .EQ. SUBCAS) GO TO 80        
      CALL FWDREC (*530,CASECC)        
      FILE = HCCEN        
      CALL FWDREC (*530,HCCEN)        
      FILE = REMFL        
      CALL FWDREC (*530,REMFL)        
      GO TO 70        
C        
C     MATCH ON SUBCASE ID. SEE HOW LONG THE RECORD IS        
C        
   80 IF (IZ(NCSTM+16) .EQ. 0) GO TO 200        
C        
C     SUBCOM UNLESS IZ(16).LT.0. IN WHICH CASE IT IS A REPEAT SUBCASE   
C        
      IF (IZ(NCSTM+16) .GT. 0) GO TO 90        
      CALL BCKREC (HCCEN)        
      CALL BCKREC (REMFL)        
      GO TO 200        
C        
C     SUBCOM. GET NUMBER OF FACTORS AND BCKREC THAT MANY RECORDS ON     
C     HCFLD        
C        
C     OPEN CORE (AFTER NCSTM WORDS OF CSTM)        
C             1 - NEXTZ   CASECC        
C             NEXTZ+1 - NEXTZ+NROWS   COLUMN OF HCCEN        
C             NEXTZ+NROWS+1 - NEXTZ+2*NROWS=NEXTP  HCCEN COMBINATION    
C             NEXTP+1 - NEXTP+NELX  COLUMN OF REMFL        
C             NEXTP+NELX+1 - NEXTP+2*NELX  REMFL COMBINATION        
C        
   90 CALL READ (*530,*100,CASECC,Z(NCSTM+17),LCORE,0,IWORDS)        
      GO TO 550        
  100 LCC  = IZ(NCSTM+166)        
      LSYM = IZ(NCSTM+LCC)        
      DO 110 I = 1,LSYM        
      CALL BCKREC (HCCEN)        
      CALL BCKREC (REMFL)        
  110 CONTINUE        
      NEXTZ  = IWORDS + 16 + NCSTM        
      NROWS2 = 2*NROWS        
      NEXTR  = NEXTZ + NROWS        
      NELX2  = 2*NELX        
      NALL2  = NROWS2 + NELX2        
      NEXTP  = NEXTZ  + NROWS2        
      ISUB   = NEXTP  + NELX        
      IF (NEXTZ+NALL2 .GT. LCORE) GO TO 550        
C        
C     SET UP FOR SUBSEQ        
C        
      DO 120 I = 1,NALL2        
  120 Z(NEXTZ+I) = 0.        
      DO 170 I = 1,LSYM        
      COEF = Z(NCSTM+LCC+I)        
      IF (COEF .EQ. 0.) GO TO 160        
      NN = NROWS        
      CALL UNPACK (*140,HCCEN,Z(NEXTZ+1))        
      DO 130 J = 1,NROWS        
      Z(NEXTR+J) = Z(NEXTR+J) + COEF*Z(NEXTZ+J)        
  130 CONTINUE        
  140 NN = NELX        
      CALL UNPACK (*170,REMFL,Z(NEXTP+1))        
      DO 150 J = 1,NELX        
      Z(ISUB+J) = Z(ISUB+J) + COEF*Z(NEXTP+J)        
  150 CONTINUE        
      GO TO 170        
C        
C     COEF = 0.        
C        
  160 FILE = HCCEN        
      CALL FWDREC (*530,HCCEN)        
      FILE = REMFL        
      CALL FWDREC (*530,REMFL)        
  170 CONTINUE        
C        
C     MOVE THE VECTOR IN CORE        
C        
      DO 180 I = 1,NROWS        
  180 Z(NCSTM+I) = Z(NEXTR+I)        
      DO 190 I = 1,NELX        
  190 Z(NNCR+I) = Z(ISUB+I)        
      GO TO 260        
C        
C     NOT A SUBCOM        
C     UNPACK A COLUMN OF HCFLD. FIRST SKIP TO NEXT RECORD ON CASECC     
C        
  200 FILE = CASECC        
      CALL FWDREC (*530,CASECC)        
      NN = NROWS        
      CALL UNPACK (*210,HCCEN,Z(NCSTM+1))        
      GO TO 230        
  210 DO 220 I = 1,NROWS        
  220 Z(NCSTM+I) = 0.        
  230 NN = NELX        
      CALL UNPACK (*240,REMFL,Z(NNCR+1))        
      GO TO 260        
  240 DO 250 I = 1,NELX        
  250 Z(NNCR+I) = 0.        
C        
C     HCFLD VECTOR IS IN Z(NCSTM+1)-Z(NCSTM+NROWS=NNCR) AND REMFL IS IN 
C     Z(NNCR+1)-Z(NNCR+NELX). MATCH ELEMENT TYPE ON HOEF1 WITH ESTFLD   
C        
  260 FILE = ESTFLD        
  270 CALL READ (*530,*540,ESTFLD,IEL,1,0,IWORDS)        
      IEX = 3        
      IF (IEL.EQ.66 .OR. IEL.EQ.67) IEX = 63        
      IF (IEL .EQ. 65) IEX = 27        
      IPTS = IEX/3        
C        
C     SINCE IS2D8 HAS 9 POINTS ON HCCEN BUT ONLY ONE ON HEOF1 AND ESTFLD
C     RESET IPTS        
C        
      IF (IEL .EQ. 80) IPTS = 9        
      IF (IEL .EQ. ELTYPE) GO TO 290        
C        
C     NO MATCH. SKIP TO NEXT RECORD, BUT KEEP UP WITH NCOUNT        
C        
  280 CALL READ (*530,*270,ESTFLD,IDUM,2,0,IWORDS)        
      CALL FREAD (ESTFLD,IDUM,-(IDUM(2)+19+IEX),0)        
      NCOUNT = NCOUNT + 1        
      HCOUNT = HCOUNT + IPTS        
      GO TO 280        
C        
C     MATCH ON ELEMENT TYPE. FIND A MATCH ON ELEMENT ID        
C        
  290 FILE = HOEF1        
      CALL READ (*530,*380,HOEF1,RBUF,9,0,IWORDS)        
      ELID = IBUF(1)/10        
      FILE = ESTFLD        
C        
C     NEXT STATEMENT IS FOR ISOPARAMETRICS WHICH HAVE MULTIPLE POINTS   
C     ON HOEF1, BUT ONLY ONE SET OF INFO ON ESTFLD(BUT MULTIPLE COORDS  
C     FOR NON-BASIC COORDINATE SYSTEMS). IF MATERIAL IS ALLOWED TO BE   
C     TEMPERATURE-DEPENDENT AT SOME LATER DATE IN MAGNETICS PROBLEMS,   
C     THEN ESTFLD WILL HAVE MULTIPLE INFO. WRIITEN IN ESTMAG AND THIS   
C     STATEMENT CAN BE DELETED        
C        
      IF (OLDEID .NE. 0) GO TO 310        
C        
  300 CALL READ (*530,*540,ESTFLD,IZ(NALL+1),2,0,IWORDS)        
      NCOUNT = NCOUNT + 1        
      HCOUNT = HCOUNT + IPTS        
      IELID  = IZ(NALL+1)        
      NGRIDS = IZ(NALL+2)        
      NWORDS = NGRIDS + 19 + IEX        
      IF (NALL+NWORDS .GT. LCORE) GO TO 550        
      CALL READ (*530,*540,ESTFLD,Z(NALL+1),NWORDS,0,IWORDS)        
C        
      IF (ELID.EQ.IELID) GO TO 310        
      GO TO 300        
C        
C     MATCH ON ELEMENT ID. PICK UP HM FROM HOEF1(IN ELEMENT COORDS)     
C     PICK UP 3 X 3 TRANSFORMATION MATRIX FROM ESTFLD TO CONVERT ELEMENT
C     SYSTEM TO BASIC. THEN MULTIPLY        
C        
  310 HM(1) = RBUF(4)        
      HM(2) = RBUF(5)        
      HM(3) = RBUF(6)        
      CALL GMMATS (Z(NALL+NGRIDS+10),3,3,0,HM,3,1,0,HMG)        
C        
C     PICK UP HC FROM HCCEN VECTOR. FOR ALL EXCEPT ISOPARAMETRICS,HCOUNT
C     POINTS TO THE Z COMPONENT OF PROPER HC WHICH STARTS AT Z(NCSTM+1) 
C        
      IF (RBUF(2).NE.HEX1 .AND. RBUF(2).NE.HEX2 .AND. RBUF(2).NE.HEX3)  
     1   GO TO 330        
C        
C     ISOPARAMETRIC SOLIDS        
C        
      IF (OLDEID .EQ. ELID) GO TO 320        
      OLDEID = ELID        
      STRSPT = 0        
  320 STRSPT = STRSPT + 1        
      IF (STRSPT .GE. 21) OLDEID = 0        
      IF (RBUF(2).EQ.HEX1 .AND. STRSPT.GE.9) OLDEID = 0        
      GO TO 340        
  330 STRSPT = 1        
C        
C     NEXT LINE IS FOR IS2D8 WHICH HAS 9 POINTS ON HCCEN BUT ONE ON     
C     ESTFLD        
C        
      IF (IEL .EQ. 80) STRSPT = 9        
  340 ISUB  = NCSTM + 3*(HCOUNT-IPTS+STRSPT-1)        
      HC(1) = Z(ISUB+1)        
      HC(2) = Z(ISUB+2)        
      HC(3) = Z(ISUB+3)        
C        
      DO 350 I = 1,3        
  350 RBUF(I+3) = HMG(I) + HC(I)        
C        
C     TO GET INDUCTION B, MULTIPLY H BY MATERIALS        
C        
      CALL GMMATS (Z(NALL+NGRIDS+1),3,3,0,RBUF(4),3,1,0,RBUF(7))        
C        
C     ADD IN REMANENCE Z(NNCR+1)-Z(NNCR+NELX)        
C        
      ISUB = NNCR + 3*NCOUNT - 3        
      RBUF(7) = RBUF(7) + Z(ISUB+1)        
      RBUF(8) = RBUF(8) + Z(ISUB+2)        
      RBUF(9) = RBUF(9) + Z(ISUB+3)        
C        
C     CHECK FOR REQUEST FOR NON-BASIC COORD. SYSTEM. TA TRANSFORMS TO   
C     BASIC        
C        
      IFIELD = IZ(NALL+NGRIDS+19)        
      IF (IFIELD .EQ. 0) GO TO 370        
      ICOORD(1) = IFIELD        
C        
C     NEXT LINE IS FOR IS2D8 WHICH ONLY ONE POINT ON ESTFLD        
C        
      IF (IEL .EQ. 80) STRSPT = 1        
      ISUB = NALL + NGRIDS + 19 + 3*STRSPT - 3        
      COORD(2) = Z(ISUB+1)        
      COORD(3) = Z(ISUB+2)        
      COORD(4) = Z(ISUB+3)        
      CALL TRANSS (COORD,TA)        
      CALL GMMATS (TA,3,3,1,RBUF(7),3,1,0,TEMP)        
      DO 360 I = 1,3        
  360 RBUF(I+6) = TEMP(I)        
C        
  370 CONTINUE        
C        
C     WRITE OUT TO HOEH1        
C        
      CALL WRITE (HOEH1,RBUF,9,0)        
C        
C     GET ANOTHER ELEMENT OF THIS TYPE IN THIS SUBCASE        
C        
      GO TO 290        
C        
C     END OF ELEMENTS OF PRESENT TYPE AND/OR SUBCASE ON HOEF1        
C        
  380 CALL WRITE (HOEH1,0,0,1)        
      FILE = ESTFLD        
C        
C     SKIP RECORD BUT KEEP UP WITH NCOUNT        
C        
  390 CALL READ (*530,*400,ESTFLD,IDUM,2,0,IWORDS)        
      CALL FREAD (ESTFLD,IDUM,-(IDUM(2)+19+IEX),0)        
      NCOUNT = NCOUNT + 1        
      HCOUNT = HCOUNT + IPTS        
      GO TO 390        
  400 FILE = HOEF1        
      GO TO 60        
C        
C     EOF ON HOEF1 - ALL DONE        
C        
  410 CALL CLOSE (CASECC,1)        
      CALL CLOSE (HCCEN,1)        
      CALL CLOSE (ESTFLD,1)        
      CALL CLOSE (HOEF1,1)        
      CALL CLOSE (REMFL,1)        
      CALL CLOSE (HOEH1,1)        
      MCB(1) = HOEF1        
      CALL RDTRL (MCB)        
      MCB(1) = HOEH1        
      CALL WRTTRL (MCB)        
      GO TO 600        
C        
C     FATAL ERROR MESSAGES        
C        
  500 WRITE  (OTPE,510) SFM        
  510 FORMAT (A25,', ROW COUNT ON HCCEN IN EMFLD IS NOT CONSISTENT')    
      CALL MESAGE (-61,0,0)        
  520 N = -1        
      GO TO 560        
  530 N = -2        
      GO TO 560        
  540 N = -3        
      GO TO 560        
  550 N = -8        
      FILE = 0        
  560 CALL MESAGE (N,FILE,NAM)        
C        
  600 RETURN        
      END        
