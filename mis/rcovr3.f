      SUBROUTINE RCOVR3        
C        
C     THE RCOVR3 MODULE RECOVERS DATA FOR SUBSTRUCTURE PHASE 3.        
C        
C     DISPLACEMENTS AND REACTIONS ARE COPIED FROM THE SOF TO GINO FILES.
C     FOR NORMAL MODES, LAMA IS CREATED FROM THE SOLN ITEM.        
C     FOR STATICS, THE LOADS AND ENFORCED DISPLACEMENTS ARE FACTORED    
C     AND COMBINED TO CORRESPOND WITH THE PHASE 2 SOLUTION SUBCASES.    
C        
C     JANUARY 1974        
C        
      LOGICAL         FIRST        
      INTEGER         RFNO     ,TRL      ,SYSBUF   ,TITLES   ,OTYPP    ,
     1                OTYPUN   ,IZ(10)   ,PG       ,PS       ,PO       ,
     2                YS       ,UAS      ,QAS      ,PGS      ,PSS      ,
     3                POS      ,YSS      ,LAMA     ,IVEC(4)  ,OVEC(4)  ,
     4                SOLN     ,UVEC     ,QVEC     ,INITM(3) ,OUTDB(3) ,
     5                SUBR(2)  ,SRD      ,HERE     ,BUF1     ,BUF2     ,
     6                BUF3     ,BUF4     ,RC       ,FSS(2)   ,FILE     ,
     7                SCR1     ,SCR2     ,SCR3        
      DIMENSION       MCBTRL(7)        
      CHARACTER       UFM*23   ,UWM*25   ,UIM*29   ,SFM*25        
      COMMON /XMSSG / UFM      ,UWM      ,UIM      ,SFM        
      COMMON /BLANK / RFNO     ,NAME(2)  ,NOUE     ,TRL(7)   ,HERE(6)  ,
     1                IBUF(3)        
      COMMON /SYSTEM/ SYSBUF   ,NOUT        
      COMMON /NAMES / RD       ,RDREW    ,WRT      ,WRTREW   ,REW      ,
     1                NOREW        
      COMMON /OUTPUT/ TITLES(1)        
      COMMON /PACKX / ITYPP    ,OTYPP    ,IROWP    ,NROWP    ,INCP      
      COMMON /UNPAKX/ OTYPUN   ,IROWUN   ,NROWUN   ,INCUN        
CZZ   COMMON /ZZRCV3/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (PG  ,IVEC(1) )    ,(PGS ,OVEC(1) )    ,        
     1                (PS  ,IVEC(2) )    ,(PSS ,OVEC(2) )    ,        
     2                (PO  ,IVEC(3) )    ,(POS ,OVEC(3) )    ,        
     3                (YS  ,IVEC(4) )    ,(YSS ,OVEC(4) )    ,        
     4                (SOLN,INITM(1))    ,(LAMA,OUTDB(1))    ,        
     5                (UVEC,INITM(2))    ,(UAS ,OUTDB(2))    ,        
     6                (QVEC,INITM(3))    ,(QAS ,OUTDB(3))    ,        
     7                (Z(1),IZ(1))        
      DATA     PG   , PS  ,PO  ,YS  ,UAS ,QAS ,PGS ,PSS ,POS ,YSS ,LAMA/
     1         101  , 102 ,103 ,104 ,201 ,202 ,203 ,204 ,205 ,206 ,207 /
      DATA     SCR1 , SCR2,SCR3     /        
     1         301  , 302 ,303      /        
      DATA     SOLN , UVEC  , QVEC   ,IBLANK  /        
     1        4HSOLN, 4HUVEC, 4HQVEC ,4H      /        
      DATA     SUBR         , SRD    /        
     1        4HRCOV, 4HR3  , 1      /        
C        
C     INITIALIZATION        
C        
      LCORE = KORSZ(Z)        
      BUF1  = LCORE - SYSBUF + 1        
      BUF2  = BUF1  - SYSBUF - 1        
      BUF3  = BUF2  - SYSBUF        
      BUF4  = BUF3  - SYSBUF        
      LCORE = BUF4  - 1        
      IF (LCORE .LE. 0) CALL MESAGE (-8,0,SUBR)        
      NOGO  = 0        
      ITYPP = 1        
      OTYPP = 1        
      IROWP = 1        
      INCP  = 1        
      OTYPUN= 1        
      IROWUN= 1        
      INCUN = 1        
      FIRST = .FALSE.        
      CALL SOFOPN (Z(BUF1),Z(BUF2),Z(BUF3))        
      DO 10 I = 1,6        
      HERE(I) = 0        
   10 CONTINUE        
C        
C     CHECK DATA        
C        
C     NO EXTRA POINTS        
C        
      IF (NOUE .NE. -1) GO TO 6372        
C        
C     SUBSTRUCTURE NAME        
C        
      CALL FDSUB (NAME,RC)        
      IF (RC .EQ. -1) CALL SMSG (-2,IBLANK,NAME)        
C        
C     PAIRS OF INPUT ITEMS AND OUTPUT BLOCKS        
C        
      CALL SFETCH (NAME,SOLN,SRD,RC)        
      IF (RC .NE. 1) CALL SMSG (2-RC,SOLN,NAME)        
      IF (RFNO.EQ.1 .OR. RFNO.EQ.2) GO TO 15        
      TRL(1) = OUTDB(1)        
      CALL RDTRL (TRL)        
      IF (TRL(1) .GT. 0) GO TO 15        
      CALL MESAGE (1,OUTDB(1),SUBR)        
      NOGO = 1        
   15 DO 30 I = 2,3        
      IF (I.EQ.1 .AND. (RFNO.EQ.1 .OR. RFNO.EQ.2)) GO TO 30        
      CALL SOFTRL (NAME,INITM(I),MCBTRL)        
      RC = MCBTRL(1)        
      IF (RC .NE. 1) GO TO 30        
      TRL(1) = OUTDB(I)        
      CALL RDTRL (TRL)        
      IF (TRL(1) .GT. 0) GO TO 20        
      CALL MESAGE (1,OUTDB(I),SUBR)        
      NOGO = 1        
      GO TO 30        
   20 HERE(I-1) = 1        
   30 CONTINUE        
C        
C     PAIRS OF DATA BLOCKS        
C        
      IF (RFNO.EQ.3 .OR. RFNO.EQ.8) GO TO 60        
      DO 50 I = 1,4        
      TRL(1) = IVEC(I)        
      CALL RDTRL (TRL)        
      IF (TRL(1) .LT. 0)  GO TO 50        
      IF (I.EQ.4 .AND. TRL(6).EQ.0) GO TO 50        
      TRL(1) = OVEC(I)        
      CALL RDTRL (TRL)        
      IF (TRL(1) .GT. 0) GO TO 40        
      CALL MESAGE (1,OVEC(I),SUBR)        
      NOGO = 1        
      GO TO 50        
   40 HERE(I+2) = 1        
   50 CONTINUE        
C        
C     TERMINATE IF THERE WERE ERRORS        
C        
   60 IF (NOGO .NE. 0) GO TO 9037        
C        
C     COPY DISPLACEMENTS AND REACTIONS FROM SOF TO GINO FILES        
C        
      IF (HERE(1) .EQ. 1) CALL MTRXI (UAS,NAME,UVEC,Z(BUF4),RC)        
      IF (HERE(2) .EQ. 1) CALL MTRXI (QAS,NAME,QVEC,Z(BUF4),RC)        
C        
C     BRANCH ON RIGID FORMAT NUMBER        
C        
      IF (RFNO .EQ. 3) GO TO 140        
C        
C     RIGID FORMAT  1 -- STATIC        
C     RIGID FORMAT  2 -- INERTIAL RELIEF        
C     RIGID FORMAT  8 -- FREQUENCY RESPONSE        
C     RIGID FORMAT  9 -- TRANSIENT RESPONSE        
C     *************************************        
C        
C     FETCH SOLN ITEM AND PROCESS GROUP 0 DATA        
C        
      CALL SFETCH (NAME,SOLN,SRD,RC)        
      IF (RC .NE. 1) CALL SMSG (2-RC,SOLN,NAME)        
      CALL SUREAD (FSS,2,N,RC)        
      WRITE (NOUT,63210) UIM,FSS,NAME        
      CALL SUREAD (IBUF,3,N,RC)        
      IF (IBUF(1) .NE. RFNO) GO TO 6322        
      IF (IBUF(2) .NE. 1) GO TO 6324        
      NC = IBUF(3)        
C        
C     WRITE NULL REACTIONS MATRIX TO PREVENT ERROR 3007 IN UMERGE       
C        
      IF (HERE(2) .EQ. 1) GO TO 80        
      NROWP = 1        
      CALL MAKMCB (TRL,QAS,1,2,1)        
      CALL GOPEN (QAS,Z(BUF4),WRTREW)        
      DO 70 I = 1,NC        
      CALL PACK (0,QAS,TRL)        
   70 CONTINUE        
      CALL CLOSE (QAS,REW)        
      CALL WRTTRL (TRL)        
C        
C     COPY FREQUENCIES ONTO PPF OR TIME STEPS ONTO TOL        
C        
   80 IF (RFNO .LT. 8) GO TO 120        
      J = 1        
      CALL SJUMP (J)        
      FILE = LAMA        
      CALL OPEN (*9001,LAMA,Z(BUF4),WRTREW)        
      CALL FNAME (LAMA,IBUF)        
      CALL WRITE (LAMA,IBUF,2,0)        
   90 CALL SUREAD (Z,LCORE,N,RC)        
      CALL WRITE (LAMA,Z,N,0)        
      IF (RC .EQ. 1) GO TO 90        
      CALL WRITE (LAMA,0,0,1)        
C        
C     WRITE NULL DYNAMIC LOADS MATRIX ONTO PPF        
C        
      CALL MAKMCB (TRL,LAMA,1,2,1)        
      IF (RFNO .EQ. 9) GO TO 110        
      DO 100 I = 1,NC        
      CALL PACK (0,LAMA,TRL)        
  100 CONTINUE        
  110 CALL WRTTRL (TRL)        
      CALL CLOSE (LAMA,REW)        
C        
C     FOR EACH SUBCASE READ FROM THE SOLN, FORM A COMBINED VECTOR FROM  
C     THE VECTORS OF THE APPLIED LOADS OR ENFORCED DISPLACEMENTS DATA   
C     BLOCKS        
C        
  120 LCORE = BUF3 - 1        
      DO 130 I = 1,4        
      IF (HERE(I+2) .EQ. 0) GO TO 130        
      CALL RCOVSL (NAME,0,IVEC(I),SCR1,SCR2,SCR3,OVEC(I),Z,Z,LCORE,     
     1             FIRST,RFNO)        
      IF (OVEC(I) .NE. 0) FIRST= .TRUE.        
  130 CONTINUE        
      GO TO 5000        
C        
C     RIGID FORMAT  3 -- NORMAL MODES        
C     *******************************        
C        
C     WRITE NULL REACTIONS MATRIX TO PREVENT ERROR 3007 IN UMERGE       
C        
  140 IF (HERE(2) .EQ. 1) GO TO 150        
      NROWP = 1        
      CALL MAKMCB (TRL,QAS,1,2,1)        
      CALL GOPEN (QAS,Z(BUF4),WRTREW)        
      CALL PACK (0,QAS,TRL)        
      CALL CLOSE (QAS,REW)        
      CALL WRTTRL (TRL)        
C        
C     GENERATE OFP ID RECORD FOR LAMA        
C        
  150 IF (LCORE .LT. 146) GO TO 9008        
      CALL GOPEN (LAMA,Z(BUF4),WRTREW)        
      DO 160 I = 3,50        
      IZ(I) = 0        
  160 CONTINUE        
      IZ( 1) = 21        
      IZ( 2) = 6        
      IZ(10) = 7        
      DO 170 I = 1,96        
      IZ(I+50) = TITLES(I)        
  170 CONTINUE        
      CALL WRITE (LAMA,Z,146,1)        
C        
C     GET SOLN ITEM AND CHECK GROUP 0 DATA        
C        
      CALL SFETCH (NAME,SOLN,SRD,RC)        
      IF (RC .NE. 1) CALL SMSG (2-RC,SOLN,NAME)        
      CALL SUREAD (FSS,2,N,RC)        
      WRITE (NOUT,63210) UIM,FSS,NAME        
      CALL SUREAD (IBUF,-1,N,RC)        
      IF (IBUF(1) .NE. RFNO) GO TO 6322        
      NEIGV = IBUF(2)        
      IF (NEIGV .GT. 0) GO TO 180        
C        
C     NO EIGENVALUES.  WRITE ZERO TRAILER TO INDICATE LAMA IS PURGED    
C        
      CALL CLOSE (LAMA,REW)        
      CALL MAKMCB (TRL,LAMA,0,0,0)        
      CALL WRTTRL (TRL)        
      GO TO 6323        
C        
C     COPY SOLN GROUP 1 TO LAMA RECORD 2 AND WRITE NON-ZERO TRAILER     
C        
  180 CALL SUREAD (Z,LCORE,N,RC)        
      CALL WRITE (LAMA,Z,N,0)        
      IF (RC .EQ. 1) GO TO 180        
      CALL WRITE (LAMA,0,0,1)        
      CALL CLOSE (LAMA,REW)        
      CALL MAKMCB (TRL,LAMA,0,0,0)        
      TRL(2) = 1        
      CALL WRTTRL (TRL)        
C        
C     NORMAL MODULE EXITS        
C        
 5000 CALL SOFCLS        
      RETURN        
C        
C     ABNORMAL MODULE EXITS        
C        
 6372 WRITE (NOUT,63720) UFM        
      GO TO 9061        
 9001 N = -1        
      GO TO 9200        
 6322 WRITE (NOUT,63220) SFM,IBUF(1),RFNO        
      GO TO 9061        
 6323 WRITE (NOUT,63230) UWM        
      GO TO 9300        
 6324 WRITE (NOUT,63240) UFM,NAME        
      GO TO 9061        
 9008 N = -8        
      GO TO 9200        
 9037 N = -37        
      GO TO 9200        
 9061 N = -61        
 9200 CALL SOFCLS        
      CALL MESAGE (N,FILE,SUBR)        
 9300 CALL SOFCLS        
      RETURN        
C        
C     FORMAT STATEMENTS FOR DIAGNOSTIC MESSAGES        
C        
63210 FORMAT (A29,' 6321, SUBSTRUCTURE PHASE 3 RECOVER FOR FINAL SOLUT',
     1       'ION STRUCTURE ',2A4, /35X,' AND BASIC SUBSTRUCTURE ',2A4) 
63220 FORMAT (A25,' 6322, SOLN HAS INCORRECT RIGID FORMAT NUMBER.',/32X,
     1       'PHASE 2 RIGID FORMAT WAS',I3,' AND PHASE 3 IS',I3)        
63230 FORMAT (A25,' 6323, NO EIGENVALUES FOR THIS SOLUTION')        
63240 FORMAT (A23,' 6324, PHASE 3 RECOVER ATTEMPTED FOR NON-BASIC ',    
     1       'SUBSTRUCTURE ',2A4)        
63720 FORMAT (A23,' 6372, NO EXTRA POINTS ALLOWED IN PHASE 3 ',        
     1       'SUBSTRUCTURING.')        
      END        
