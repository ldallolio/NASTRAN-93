      SUBROUTINE OUTPT1        
C        
C     COPY DATA BLOCK(S) ONTO NASTRAN USER TAPE WHICH MUST BE SET-UP.   
C        
C     CALL TO THIS MODULE IS        
C        
C     OUTPUT1   IN1,IN2,IN3,IN4,IN5//V,N,P1/V,N,P2/V,N,P3 $        
C        
C               P1 = 0, NO ACTION TAKEN BEFORE WRITE (DEFAULT)        
C                  =+N, SKIP FORWARD N DATA BLOCKS BEFORE WRITE        
C                  =-1, USER TAPE IS REWOUND BEFORE WRITE        
C                  =-2, A NEW REEL IS MOUNTED BEFORE WRITE        
C                  =-3, THE NAMES OF ALL DATA BLOCKS ON USER TAPE ARE   
C                       PRINTED AND WRITE OCCURS AT THE END OF TAPE     
C                  =-4, AN INPUT TAPE IS TO BE DISMOUNTED.        
C                       A NEW OUTPUT REEL WILL THEN BE MOUNTED.        
C                  =-9, WRITE EOF, REWIND AND UNLOAD.        
C        
C               P2 = 0, FILE NAME IS INPT (DEFAULT)        
C                  = 1, FILE NAME IS INP1        
C                  = 2, FILE NAME IS INP2        
C                  = 3, FILE NAME IS INP3        
C                  = 4, FILE NAME IS INP4        
C                  = 5, FILE NAME IS INP5        
C                  = 6, FILE NAME IS INP6        
C                  = 7, FILE NAME IS INP7        
C                  = 8, FILE NAME IS INP8        
C                  = 9, FILE NAME IS INP9        
C        
C               P3 = TAPE ID CODE FOR USER TAPE, AN ALPHANUMERIC        
C                    VARIABLE WHOSE VALUE WILL BE WRITTEN ON A USER     
C                    TAPE. THE WRITTING OF THIS ITEM IS DEPENDENT ON    
C                    THE VALUE OF P1 AS FOLLOWS..        
C                          *P1*             *TAPE ID WRITTEN*        
C                           +N                     NO        
C                            0                     NO        
C                           -1                    YES        
C                           -2                    YES (ON NEW REEL)     
C                           -3                     NO (WARNING CHECK)   
C                           -4                    YES (ON NEW REEL)     
C                           -9                     NO        
C                    DEFAULT VALUE FOR P3 IS XXXXXXXX        
C        
C        
      IMPLICIT INTEGER (A-Z)        
      LOGICAL         TAPEUP,TAPBIT        
      INTEGER         TRL(7),NAME(2),SUBNAM(2),IN(5),NAMEX(2),OTT(10),  
     1                IDHDR(7),IDHDRX(7),P3X(2),D(3),DX(3),TAPCOD(2)    
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /MACHIN/ MACH        
      COMMON /BLANK / P1,P2,P3(2)        
     1       /SYSTEM/ KSYSTM(65)        
CZZ  2       /ZZOUT1/ X(1)        
     2       /ZZZZZZ/ X(1)        
      EQUIVALENCE     (KSYSTM( 1),NB  ),(KSYSTM( 2),NOUT),        
     1                (KSYSTM( 9),NLPP),(KSYSTM(12),LINE),        
     2                (KSYSTM(15),D(1))        
      DATA    SUBNAM/ 4HOUTP,4HT1        /        
      DATA    IN    / 101,102,103,104,105/        
      DATA    ZERO  , MONE,MTWO,MTRE,MFOR,MNIN/ 0,-1,-2,-3,-4,-9/       
      DATA    OTT   / 4HINPT,4HINP1,4HINP2,4HINP3,4HINP4,        
     1                4HINP5,4HINP6,4HINP7,4HINP8,4HINP9/        
      DATA    IDHDR / 4HNAST,4HRAN ,4HUSER,4H TAP,4HE ID,4H COD,4HE - / 
C        
C        
      LCOR = KORSZ(X) - 2*NB        
      IF (LCOR .LE. 0) GO TO 9908        
      INBUF = LCOR  + 1        
      OUBUF = INBUF + NB        
      TAPCOD(1) = P3(1)        
      TAPCOD(2) = P3(2)        
      IF (P2.LT.0 .OR. P2.GT.9) GO TO 9904        
      OUT = OTT(P2+1)        
      IF (MACH .GE. 5) GO TO 120        
      TAPEUP = TAPBIT(OUT)        
      IF (.NOT.TAPEUP ) GO TO 9909        
  120 IF (P1 .LT. MNIN) GO TO 9905        
      IF (P1.GT.MNIN .AND. P1.LT.MFOR) GO TO 9905        
C        
      IF (P1 .EQ. MNIN) GO TO 5000        
      IF (P1 .EQ. MTRE) GO TO 2000        
      IF (P1 .LE. ZERO) GO TO 150        
C        
      CALL GOPEN (OUT,X(OUBUF),2)        
      DO 130 I = 1,P1        
      CALL READ (*9903,*9903,OUT,NAMEX,2,1,NF)        
  130 CALL SKPFIL (OUT,1)        
      CALL CLOSE (OUT,2)        
      GO TO 190        
C        
  150 IF (P1.NE.MTWO .AND. P1.NE.MFOR) GO TO 190        
C        
C     P1 = -2 OR P1 = -4 IS ACCEPTABLE ONLY ON IBM OR UNIVAC        
C        
      IF (MACH.NE.2 .AND. MACH.NE.3) GO TO 9905        
C        
      IOLD = 3 + P1/2        
      CALL GOPEN  (OUT,X(OUBUF),3)        
      CALL TPSWIT (OUT,IOLD,2,TAPCOD)        
C        
C     OPEN USER TAPE TO WRITE WITHOUT REWIND        
C        
  190 CALL GOPEN (OUT,X(OUBUF),3)        
      IF (P1.NE.MONE .AND. P1.NE.MTWO .AND. P1.NE.MFOR) GO TO 195       
      CALL REWIND (OUT)        
      CALL WRITE (OUT,D,3,0)        
      CALL WRITE (OUT,IDHDR,7,0)        
      CALL WRITE (OUT,P3,2,1)        
      CALL EOF (OUT)        
      GO TO 195        
C        
  193 CALL CLOSE (OUT,2)        
      CALL GOPEN (OUT,X(OUBUF),3)        
C        
  195 DO 1000 I = 1,5        
      INPUT  = IN(I)        
      TRL(1) = INPUT        
      CALL RDTRL (TRL)        
      IF (TRL(1) .LE. 0) GO TO 1000        
      CALL FNAME (INPUT,NAME)        
C        
C     OPEN INPUT DATA BLOCK TO READ WITH REWIND.        
C        
      CALL OPEN  (*9901,INPUT,X(INBUF),0)        
      CALL WRITE (OUT,NAME,2,0)        
      CALL WRITE (OUT,TRL(2),6,1)        
C        
C     LEVEL 17.5, THE ABOVE 8 WORD RECORD WAS WRITTEN OUT IN 2 RECORDS  
C     2 BCD WORD NAME, AND 7 TRAILER WORDS        
C        
C     COPY CONTENTS OF INPUT DATA BLOCK ONTO USER TAPE.        
C        
      CALL CPYFIL (INPUT,OUT,X,LCOR,NF)        
C        
C     CLOSE INPUT DATA BLOCK WITH REWIND        
C        
      CALL CLOSE (INPUT,1)        
C        
      CALL EOF (OUT)        
      CALL PAGE2 (-4)        
      WRITE  (NOUT,350) UIM,NAME,OUT,(TRL(II),II=2,7)        
  350 FORMAT (A29,' 4114', //5X,'DATA BLOCK ',2A4,        
     1       ' WRITTEN ON NASTRAN FILE ',A4,', TRLR  =',6I10)        
C        
 1000 CONTINUE        
C        
C     CLOSE NASTRAN USER TAPE WITHOUT REWIND, BUT WITH END-OF-FILE      
C        
      CALL CLOSE (OUT,3)        
      RETURN        
C        
C     OBTAIN LIST OF DATA BLOCKS ON USER TAPE.        
C        
 2000 CALL OPEN (*9902,OUT,X(OUBUF),0)        
      CALL READ (*9911,*9912,OUT,DX,3,0,NF)        
      CALL READ (*9911,*9912,OUT,IDHDRX,7,0,NF)        
      DO 2005 KF = 1,7        
      IF (IDHDRX(KF) .NE. IDHDR(KF)) GO TO 9913        
 2005 CONTINUE        
      CALL READ (*9911,*9912,OUT,P3X,2,1,NF)        
      IF (P3X(1).NE.P3(1) .OR. P3X(2).NE.P3(2)) GO TO 9914        
 2006 CALL SKPFIL (OUT,1)        
      KF = 0        
 2007 CALL PAGE1        
      LINE = LINE + 5        
      WRITE  (NOUT,2010) OUT        
 2010 FORMAT (//50X,A4,14H FILE CONTENTS ,/46X,4HFILE,18X,4HNAME,//)    
 2020 CALL READ (*2050,*9915,OUT,NAMEX,2,1,NF)        
      CALL SKPFIL (OUT,1)        
      KF = KF + 1        
      LINE = LINE + 1        
      WRITE  (NOUT,2030) KF,NAMEX        
 2030 FORMAT (45X,I5,18X,2A4)        
      IF (LINE-NLPP) 2020,2007,2007        
 2050 CALL SKPFIL (OUT,-1)        
      GO TO 193        
C        
 5000 CONTINUE        
      CALL EOF (OUT)        
      CALL UNLOAD( OUT)        
      RETURN        
C        
C     ERRORS        
C        
 9901 MM = -1        
      GO TO 9996        
 9902 WRITE  (NOUT,9952) SFM,OUT        
 9952 FORMAT (A25,' 4117, SUBROUTINE OUTPT1 UNABLE TO OPEN NASTRAN FILE'
     1,       A4,1H.)        
      LINE = LINE + 2        
      GO TO 9995        
 9903 WRITE  (NOUT,9953) UFM,P1,OUT,I        
 9953 FORMAT (A23,' 4118, MODULE OUTPUT1 IS UNABLE TO SKIP FORWARD',I10,
     2        ' DATA BLOCKS ON PERMANENT NASTRAN FILE ',A4,1H., /5X,    
     3        'NUMBER OF DATA BLOCKS SKIPPED =',I6)        
      LINE = LINE + 3        
      GO TO 9995        
 9904 WRITE  (NOUT,9954) UFM,P2        
 9954 FORMAT (A23,' 4119, MODULE OUTPUT1 - ILLEGAL VALUE FOR SECOND ',  
     1       'PARAMETER =',I20)        
      LINE = LINE + 2        
      GO TO 9995        
 9905 WRITE  (NOUT,9955) UFM,P1        
 9955 FORMAT (A23,' 4120, MODULE OUTPUT1 - ILLEGAL VALUE FOR FIRST ',   
     1       'PARAMETER =',I20)        
      LINE = LINE + 2        
      GO TO 9995        
 9908 MM = -8        
      INPUT = -LCOR        
      GO TO 9996        
 9909 WRITE  (NOUT,9959) UFM,OUT        
 9959 FORMAT (A23,' 4127, USER TAPE ',A4,' NOT SET UP.')        
      LINE = LINE + 2        
      GO TO 9995        
 9911 WRITE  (NOUT,9961) UFM,OUT        
 9961 FORMAT (A23,' 4128, MODULE OUTPUT1 - END-OF-FILE ENCOUNTERED ',   
     1       'WHILE ATTEMPTING TO READ TAPE ID CODE ON USER TAPE ',A4)  
      LINE = LINE + 2        
      GO TO 9995        
 9912 WRITE  (NOUT,9962) UFM,OUT        
 9962 FORMAT (A23,' 4129, MODULE OUTPUT1 - END-OF-RECORD ENCOUNTERED ', 
     1       'WHILE ATTEMPTING TO READ TAPE ID CODE ON USER TAPE ',A4)  
      LINE = LINE + 2        
      GO TO 9995        
 9913 WRITE  (NOUT,9963) UFM,(IDHDRX(KF),KF=1,7)        
 9963 FORMAT (A23,' 4130, MODULE OUTPUT1 - ILLEGAL TAPE CODE HEADER = ',
     1        7A4)        
      LINE = LINE + 2        
      GO TO 9995        
 9914 WRITE  (NOUT,9964) UWM,P3X,P3        
 9964 FORMAT (A25,' 4131, USER TAPE ID CODE -',2A4,'- DOES NOT MATCH ', 
     1       'THIRD OUTPUT1 DMAP PARAMETER -',2A4,2H-.)        
      LINE = LINE + 2        
      GO TO 2006        
 9915 WRITE  (NOUT,9965) SFM        
 9965 FORMAT (A25,' 4115, MODULE OUTPUT1 - SHORT RECORD.')        
      LINE = LINE + 2        
      GO TO 9995        
C        
 9995 MM = -37        
 9996 CALL MESAGE (MM,INPUT,SUBNAM)        
      RETURN        
C        
      END        
