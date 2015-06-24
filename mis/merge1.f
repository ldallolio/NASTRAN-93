      SUBROUTINE MERGE1        
C        
C     THIS IS THE DMAP MODULE MERGE WHICH MERGES 1 TO 4 PARTITIONS      
C     A11, A21, A12, A22, INTO A SINGLE MATRIX -A-.        
C        
C          **                  **           **                  **      
C          *       I            *           *                    *      
C          *  A11  I    A12     *           *                    *      
C          *       I            *           *                    *      
C          * ------+----------- *  BECOMES  *          A         *      
C          *       I            *           *                    *      
C          *       I            *           *                    *      
C          *  A21  I    A22     *           *                    *      
C          *       I            *           *                    *      
C          **                  **           **                  **      
C        
C     BASED ON THE ZEROS AND NON-ZEROS IN THE ROW PARTITIONING VECTOR   
C     -RP- AND THE COLUMN PARTITIONING VECTOR -CP-.        
C        
C     DMAP CALLING SEQUENCE.        
C        
C     MERGE  A11,A21,A12,A22,CP,RP/ A /V,Y,SYM  /V,Y,TYPE/V,Y,FORM/     
C                                      V,Y,CPCOL/V,Y,RPCOL  $        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        RSHIFT  ,ANDF        
      LOGICAL         CPNULL  ,RPNULL   ,CPHERE   ,RPHERE   ,ONLY    ,  
     1                PASS        
      DIMENSION       SUBR(2) ,HEAD(2)  ,AIJ(4)   ,MCB(7,4) ,MCBA(7) ,  
     1                ELEM1(4),ELEM2(4 ),REFUS(3) ,BLOCK(80)        
      CHARACTER       UFM*23  ,UWM*25   ,UIM*29   ,SFM*25   ,SWM*27     
      COMMON /XMSSG / UFM     ,UWM      ,UIM      ,SFM      ,SWM        
      COMMON /SYSTEM/ SYSBUF  ,OUTPT    ,XXX(37)  ,NBPW        
      COMMON /NAMES / RD      ,RDREW    ,WRT      ,WRTREW   ,CLSREW  ,  
     1                CLS        
      COMMON /ZBLPKX/ ELEM(4) ,ROW        
      COMMON /PRTMRG/ CPSIZE  ,RPSIZE   ,CPONES   ,RPONES   ,CPNULL  ,  
     1                RPNULL  ,CPHERE   ,RPHERE   ,ICP      ,NCP     ,  
     2                IRP     ,NRP        
CZZ   COMMON /ZZPTMG/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /BLANK / SYM     ,TYPE     ,FORM     ,CPCOL    ,RPCOL   ,  
     1                DUMFOR(3)         ,IREQCL        
      DATA    SUBR  / 4HMERG  ,4HE1   /, EOR    / 1      /        
      DATA    AIJ   / 101,102 ,103,104/, CP,RP  / 105,106/     ,A /201/ 
      DATA    NAFORM/ 4HFORM /,NATYPE /  4HTYPE /,REFUS/2*3H   ,3HREF / 
C        
C     OPEN MATRICES TO BE MERGED.  IF ALL ARE PURGED, RETURN IS MADE.   
C        
      CORE = KORSZ(Z)        
      M = 0        
      DO 20 I = 1,4        
      KFILE = AIJ(I)        
      MCB(1,I) = KFILE        
      CALL RDTRL (MCB(1,I))        
      IF (MCB(1,I)) 20,20,10        
   10 BUFF = CORE - SYSBUF - 2        
      CORE = BUFF - 1        
      IF (CORE .LT. 10) CALL MESAGE (-8,0,SUBR)        
      CALL OPEN (*20,KFILE,Z(BUFF),RDREW)        
      CALL SKPREC (KFILE,1)        
      M = 1        
   20 CONTINUE        
      IF (M .EQ. 0) RETURN        
      BUFF = CORE - SYSBUF - 2        
      CORE = BUFF - 1        
      IF (CORE .LT. 10) CALL MESAGE (-8,0,SUBR)        
      CALL OPEN (*440,A,Z(BUFF),WRTREW)        
      CALL CLOSE (A,CLSREW)        
C        
C     CALL TO PARTN2 WILL PROCESS -CP- AND -RP- INTO BIT STRINGS AND    
C     DETERMINE SIZES OF PARTITIONS REQUIRED.        
C        
C     STANDARDISE BLANK COMMON FOR PARTN2 CALLS FROM MERGE1-PARTN1      
C        
      DUMFOR(2) = CPCOL        
      DUMFOR(3) = RPCOL        
      CALL PARTN2 (CP,RP,CORE,Z(BUFF))        
      CPCOL = DUMFOR(2)        
      RPCOL = DUMFOR(3)        
C        
C     IF CPSIZE OR RPSIZE IS 0 AS A RESULT OF A NULL VECTOR (PURGED     
C     VECTOR) THERE SIZE IS ESTIMATED HERE FROM THEIR RESPECTIVE        
C     PARTITIONS.        
C        
      IF (CPSIZE .NE. 0) GO TO 24        
      IF (MCB(1,1)) 25,25,23        
   23 CPSIZE = MCB(2,1)        
      GO TO 24        
C        
   25 IF (MCB(1,2)) 24,24,26        
   26 CPSIZE = MCB(2,2)        
      GO TO 24        
C        
   24 IF (RPSIZE .NE. 0) GO TO 29        
      IF (MCB(1,1)) 21,21,22        
   22 RPSIZE = MCB(3,1)        
      GO TO 29        
C        
   21 IF (MCB(1,3)) 29,29,27        
   27 RPSIZE = MCB(3,3)        
C        
C     MATRIX COMPATIBILITY CHECKS.        
C        
   29 CPZERO = CPSIZE - CPONES        
      RPZERO = RPSIZE - RPONES        
      IPR    = 1        
      IRLCX  = 0        
      DO 70 I = 1,4        
      IF (MCB(1,I)) 70,70,30        
   30 COLS = MCB(2,I)        
      ROWS = MCB(3,I)        
      ICOL = CPZERO        
      IROW = RPZERO        
      IF (MCB(5,I).EQ.2 .OR. MCB(5,I).EQ.4) IPR   = 2        
      IF (MCB(5,I).EQ.3 .OR. MCB(5,I).EQ.4) IRLCX = 2        
      IF (I.EQ.3 .OR. I.EQ.4) ICOL = CPONES        
      IF (I.EQ.2 .OR. I.EQ.4) IROW = RPONES        
      IF (ICOL) 70,70,40        
   40 IF (IROW) 70,70,50        
C        
C     CHECK PARTITION SIZE WITH PARTITIONING VECTOR DEMANDS.        
C        
   50 IF (ROWS.EQ.IROW .AND. COLS.EQ.ICOL) GO TO 70        
      WRITE  (OUTPT,60) SWM,AIJ(I),ROWS,COLS,IROW,ICOL        
   60 FORMAT (A27,' 2161, PARTITION FILE',I4,' IS OF SIZE',I10,        
     1       ' ROWS BY',I10,' COLUMNS.', /5X,'PARTITIONING VECTORS ',   
     2       'INDICATE THAT THIS PARTITION SHOULD BE OF SIZE',I10,      
     3       ' ROWS BY',I10,' COLUMNS FOR A SUCCESSFUL MERGE.')        
   70 CONTINUE        
C        
C     CHECK OF FORM VALUE.        
C        
      NFORM = FORM        
      IF (NFORM.LT.1 .OR. NFORM.GT.8) GO TO 120        
      GO TO (80,140,110,80,80,80,110,80), NFORM        
C        
C     FORM = SQUARE        
C        
   80 IF (CPSIZE .EQ. RPSIZE) GO TO 140        
   90 WRITE  (OUTPT,100) SWM,NFORM,RPSIZE,CPSIZE        
  100 FORMAT (A27,' 2162, THE FORM PARAMETER AS GIVEN TO THE MERGE ',   
     1       'MODULE IS INCONSISTANT WITH THE SIZE OF THE', /5X,        
     2       'MERGED MATRIX, HOWEVER IT HAS BEEN USED.  FORM =',I9,     
     3       ' SIZE =',I10,' ROWS BY',I10,' COLUMNS.')        
      GO TO 140        
  110 IF (CPSIZE .EQ. 1) GO TO 140        
      GO TO 90        
  120 NFORM = 2        
      IF (ROWS.NE.COLS .AND. CPSIZE.NE.RPSIZE) GO TO 122        
      NFORM = 1        
      IF (SYM .LT. 0) NFORM= 6        
  122 IF (FORM.EQ.0 .OR. FORM.EQ.NFORM) GO TO 132        
      WRITE  (OUTPT,130) SWM,NAFORM,FORM,REFUS(3),SUBR,NFORM        
  130 FORMAT (A27,' 2163, REQUESTED VALUE OF ',A4,I10,2X,A3,'USED BY ', 
     1        2A4,'. LOGICAL CHOICE IS',I10)        
  132 FORM = NFORM        
C        
C     CHECK PARAMETER -TYPE-        
C        
  140 NTYPE =   IRLCX + IPR        
      IF (NTYPE .EQ. TYPE) GO TO 160        
      IF (TYPE  .EQ.    0) GO TO 154        
      IF (TYPE.LT.0 .OR. TYPE.GT.4) GO TO 152        
      WRITE (OUTPT,130) SWM,NATYPE,TYPE,REFUS(1),SUBR,NTYPE        
      NTYPE = TYPE        
      GO TO 160        
  152 WRITE (OUTPT,130) SWM,NATYPE,TYPE,REFUS(3),SUBR,NTYPE        
  154 TYPE = NTYPE        
C        
C     THE ROW PARTITIONING BIT STRING IS AT THIS POINT CONVERTED TO A   
C     CORE VECTOR ONE WORD PER BIT.  EACH WORD CONATINS THE ACTUAL ROW  
C     POSITION THE SUB-PARTITON ELEMENT WILL OCCUPY IN THE MERGED       
C     MATRIX.        
C        
  160 IZ = NRP + 1        
      NZ = IZ + RPSIZE - 1        
      IF (NZ .GT. CORE) CALL MESAGE (-8,0,SUBR)        
      IF (.NOT.RPNULL .AND. RPONES.NE.0) GO TO 180        
      K = 0        
      DO 170 I = IZ,NZ        
      K = K + 1        
      Z(I) = K        
  170 CONTINUE        
      GO TO 240        
  180 K = 0        
      ZERO = IZ - 1        
      ONES = ZERO + RPZERO        
      DO 230 I = IRP,NRP        
      DO 220 J = 1,NBPW        
      SHIFT = NBPW - J        
      BIT   = RSHIFT(Z(I),SHIFT)        
      K = K + 1        
      IF (K -  RPSIZE) 190,190,240        
  190 IF (ANDF(BIT,1)) 210,200,210        
  200 ZERO = ZERO + 1        
      Z(ZERO) = K        
      GO TO 220        
  210 ONES = ONES + 1        
      Z(ONES) = K        
  220 CONTINUE        
  230 CONTINUE        
C        
C     OPEN OUTPUT FILE AND FILL MCB.        
C        
  240 CALL OPEN (*440,A,Z(BUFF),WRTREW)        
      CALL FNAME (A,HEAD)        
      CALL WRITE (A,HEAD,2,EOR)        
      CALL MAKMCB (MCBA,A,RPSIZE,NFORM,NTYPE)        
C        
C     MERGE OPERATIONS.  LOOPING ON OUTPUT COLUMNS OF -A-.        
C        
      I1 = IZ - 1        
      I2 = I1 + RPZERO        
      DO 430 I = 1,CPSIZE        
C        
C     START A COLUMN OUT ON -A-        
C        
      CALL BLDPK (NTYPE,NTYPE,A,0,0)        
      IF (CPNULL) GO TO 250        
      IL1   = I - 1        
      BITWD = IL1/NBPW + ICP        
      SHIFT = NBPW - MOD(IL1,NBPW) - 1        
      BIT   = RSHIFT(Z(BITWD),SHIFT)        
      IF (ANDF(BIT,1)) 260,250,260        
C        
C     ZERO-S COLUMN (LEFT PARTITONS A11 AND A21 USED THIS PASS)        
C        
  250 IFILE  = 1        
      IBLOCK = 1        
      GO TO 270        
C        
C     ONE-S COLUMN (RIGHT PARTITIONS A12 AND A22 USED THIS PASS)        
C        
  260 IFILE  = 3        
      IBLOCK = 41        
      GO TO 270        
C        
C     START UNPACKING COLUMN OF EACH PARTITION BEING USED THIS PASS.    
C        
  270 KFILE  = IFILE        
      KBLOCK = IBLOCK        
      MPART  = 0        
      DO 300 J = 1,2        
      IF (MCB(1,KFILE)) 290,290,280        
  280 CALL INTPK (*290,MCB(1,KFILE),BLOCK(KBLOCK),NTYPE,1)        
      MPART  = MPART  + J        
  290 KFILE  = KFILE  + 1        
      KBLOCK = KBLOCK + 20        
  300 CONTINUE        
      IF (MPART) 420,420,310        
C        
C     UNPACK NON-ZEROS FROM EACH OF THE TWO PARTITIONS AS NEEDED UNTIL  
C     BOTH PARTITIONS HAVE THIS COLUMN EXHAUSED.        
C        
  310 EOL1  = 1        
      EOL2  = 1        
      NAM1  = MCB(1,IFILE)        
      NAM2  = MCB(1,IFILE+1)        
      IBLOC1= IBLOCK        
      IBLOC2= IBLOCK + 20        
      IF (MPART.EQ.1 .OR. MPART.EQ.3) EOL1 = 0        
      IF (MPART .GT. 1) EOL2 = 0        
      PASS = .FALSE.        
      ONLY = .FALSE.        
      IF (EOL1) 320,320,340        
  320 IF (EOL2) 350,350,330        
  330 ONLY = .TRUE.        
      GO TO 350        
  340 ONLY = .TRUE.        
      GO TO 360        
C        
C     UNPACK A NON-ZERO FROM THE ZEROS PARTITION        
C        
  350 CALL INTPKI (ELEM1,IROW1,NAM1,BLOCK(IBLOC1),EOL1)        
C        
C     SET OUTPUT ROW POSITION        
C        
      JROW  = I1 + IROW1        
      IPOS1 = Z(JROW)        
      IF (ONLY) GO TO 380        
      IF (PASS) GO TO 370        
C        
C     UNPACK A NON-ZERO FROM THE ONE-S PARTITION        
C        
  360 CALL INTPKI (ELEM2,IROW2,NAM2,BLOCK(IBLOC2),EOL2)        
C        
C     SET OUTPUT ROW POSITION        
C        
      JROW  = I2 + IROW2        
      IPOS2 = Z(JROW)        
      IF (ONLY) GO TO 400        
      PASS  = .TRUE.        
C        
C     OK COMING HERE MEANS THERE IS ONE ELEMENT FORM EACH PARTITION     
C     AVAILABLE FOR OUTPUT.  THUS OUTPUT THE ONE WITH THE LOWEST        
C     OUTPUT ROW NUMBER.        
C        
  370 IF (IPOS2 .LT. IPOS1) GO TO 400        
C        
C     OUTPUT ELEMENT FROM ZERO-S PARTITION.        
C        
  380 ROW     = IPOS1        
      ELEM(1) = ELEM1(1)        
      ELEM(2) = ELEM1(2)        
      ELEM(3) = ELEM1(3)        
      ELEM(4) = ELEM1(4)        
      CALL ZBLPKI        
      IF (EOL1) 350,350,390        
  390 IF (ONLY) GO TO 420        
      ONLY = .TRUE.        
      GO TO 400        
C        
C     OUTPUT ELEMENT FROM ONES-PARTITION.        
C        
  400 ROW     = IPOS2        
      ELEM(1) = ELEM2(1)        
      ELEM(2) = ELEM2(2)        
      ELEM(3) = ELEM2(3)        
      ELEM(4) = ELEM2(4)        
      CALL ZBLPKI        
      IF (EOL2) 360,360,410        
  410 IF (ONLY) GO TO 420        
      ONLY = .TRUE.        
      GO TO 380        
C        
C     COMPLETE THE COLUMN BEING OUTPUT        
C        
  420 CALL BLDPKN (A,0,MCBA)        
  430 CONTINUE        
C        
C     MERGE IS COMPLETE.  WRAP UP.        
C        
      CALL CLOSE (A,CLSREW)        
      CALL WRTTRL (MCBA)        
  440 DO 460 I = 1,4        
      IF (MCB(1,I)) 460,460,450        
  450 CALL CLOSE (MCB(1,I),CLSREW)        
  460 CONTINUE        
      RETURN        
C        
      END        
