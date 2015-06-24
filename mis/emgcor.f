      SUBROUTINE EMGCOR (BUF)        
C        
C     CORE ALLOCATION AND PARAMETER INITIALIZATION FOR MAIN -EMG-       
C     PROCESSOR -EMGPRO-.        
C        
      LOGICAL         ANYCON, ERROR, HEAT        
      INTEGER         Z, SYSBUF, OUTPT, SUBR(2), TYPE(3), BUF(8), BUFS, 
     1                BUF1, BUF2, RD, WRT, RDREW, WRTREW, CLS, PRECIS,  
     2                CLSREW, EST, CSTM, DIT, GEOM2, NAME(2), EOR,      
     3                FLAGS, SCR4        
      CHARACTER       UFM*23, UWM*25, UIM*29, SFM*25, SWM*27        
      COMMON /XMSSG / UFM, UWM, UIM, SFM, SWM        
      COMMON /BLANK / NOKMB(3), DUMMY(13), VOLUME, SURFAC        
      COMMON /SYSTEM/ KSYSTM(65)        
      COMMON /NAMES / RD, RDREW, WRT, WRTREW, CLSREW, CLS        
      COMMON /EMGFIL/ EST, CSTM, MPT, DIT, GEOM2, KMBMAT(3), KMBDIC(3)  
      COMMON /EMGPRM/ ICORE, JCORE, NCORE, ICSTM, NCSTM, IMAT, NMAT,    
     1                IHMAT, NHMAT, IDIT, NDIT, ICONG, NCONG, LCONG,    
     2                ANYCON, FLAGS(3), PRECIS, ERROR, HEAT,        
     3                ICMBAR, LCSTM, LMAT, LHMAT, KFLAGS(3), L38        
CZZ   COMMON /ZZEMGX/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (KSYSTM(1), SYSBUF)        
      EQUIVALENCE     (KSYSTM(2), OUTPT )        
      DATA    TYPE  / 4HSTIF,4HMASS,4HDAMP/        
      DATA    SCR4  / 304   /        
      DATA    SUBR  / 4HEMGC,4HOR  /,  EOR/ 1 /        
C        
      IF (L38 .EQ. 0) WRITE (OUTPT,5) UIM        
    5 FORMAT (A29,' 238, TURN DIAG 38 ON FOR ADDITIONAL ELEMENT ',      
     1        'PROCESSING INFORMATION',/)        
C        
C     DETERMINATION OF FUNCTIONS TO BE PERFORMED AND RESULTANT NUMBER   
C     OF BUFFERS NEEDED.        
C        
      BUFS = 1        
      DO 10 I = 1,3        
      FLAGS(I)  = 0        
      KFLAGS(I) = 0        
      IF (NOKMB(I) .EQ. -1) GO TO 10        
      FLAGS(I) = -1        
      BUFS = BUFS + 2        
   10 CONTINUE        
      IF (VOLUME.GT.0.0 .OR. SURFAC.GT.0.0) BUFS = BUFS + 1        
C        
C     ALLOCATE BUFFERS        
C        
      N = NCORE        
      DO 20 I = 1,BUFS        
      BUF(I) = N - SYSBUF - 2        
      N = BUF(I)        
   20 CONTINUE        
      NCORE = N - 1        
      IF (NCORE .LT. JCORE) CALL MESAGE (-8,JCORE-NCORE,SUBR)        
C        
C  OPEN REQUIRED DATA BLOCKS.        
C        
      BUF1 = BUF(1)        
      CALL OPEN (*60,EST,Z(BUF1),RDREW)        
      CALL SKPREC (EST,1)        
      IBUF = 1        
C        
C     K, M, OR B MATRIX DATA BLOCKS        
C        
      DO 50 I = 1,3        
      IF (FLAGS(I) .EQ. 0) GO TO 50        
      BUF1 = BUF(IBUF+1)        
      BUF2 = BUF(IBUF+2)        
      CALL OPEN (*30,KMBMAT(I),Z(BUF1),WRTREW)        
      CALL OPEN (*30,KMBDIC(I),Z(BUF2),WRTREW)        
      CALL FNAME (KMBMAT(I),NAME)        
      CALL WRITE (KMBMAT(I),NAME,2,EOR)        
      CALL FNAME (KMBDIC(I),NAME)        
      CALL WRITE (KMBDIC(I),NAME,2,EOR)        
      IBUF = IBUF + 2        
      KFLAGS(I) = 1        
      GO TO 50        
C        
C     FILE REQUIRED IS MISSING        
C        
   30 FLAGS(I) = 0        
      CALL PAGE2 (2)        
      WRITE  (OUTPT,40) UWM,KMBMAT(I),KMBDIC(I),TYPE(I)        
   40 FORMAT (A25,' 3103, EMGCOR OF EMG MODULE FINDS EITHER OF DATA ',  
     1        'BLOCKS ',I4,4H OR ,I4,' ABSENT AND THUS,', /5X,A4,       
     2        ' MATRIX WILL NOT BE FORMED.')        
   50 CONTINUE        
C        
C     IF VOLUME OR SURFACE COMPUTATION IS REQUESTED BY USER FOR THE 2-D 
C     AND 3-D ELEMENTS, OPEN SCR4 FILE. (ONLY TO BE CLOSED BY EMGFIN)   
C        
      IF (VOLUME.LE.0.0 .AND. SURFAC.LE.0.0) GO TO 55        
      IBUF = IBUF + 1        
      BUF1 = BUF(IBUF)        
      CALL OPEN (*80,SCR4,Z(BUF1),WRTREW)        
C        
C     ALL FILES READY TO GO.        
C        
   55 NCORE = BUF(IBUF) - 1        
      RETURN        
C        
C     EST MISSING        
C        
   60 CALL PAGE2 (2)        
      WRITE  (OUTPT,70) SWM,EST        
   70 FORMAT (A27,' 3104, EMGCOR FINDS EST (ASSUMED DATA BLOCK',I5,     
     2        ') MISSING.  EMG MODULE COMPUTATIONS LIMITED.')        
      FLAGS(1) = 0        
      FLAGS(2) = 0        
      FLAGS(3) = 0        
      RETURN        
C        
   80 CALL MESAGE (-1,SCR4,SUBR)        
      RETURN        
      END        
