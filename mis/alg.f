      SUBROUTINE ALG        
C        
C     THIS IS THE DRIVER SUBROUTINE FOR THE ALG MODULE        
C        
      INTEGER         APRESS,ATEMP,STRML,PGEOM,NAME(2),SYSBUF,        
     1                TITLE1(18),WD(2),ALGDB        
      CHARACTER       UFM*23,UWM*25,UIM*29        
      COMMON /XMSSG / UFM,UWM,UIM        
      COMMON /BLANK / APRESS,ATEMP,STRML,PGEOM,IPRTK,IFAIL,SIGN,ZORIGN, 
     1                FXCOOR,FYCOOR,FZCOOR        
      COMMON /SYSTEM/ SYSBUF,NOUT        
      COMMON /ALGINO/ ISCR3,ALGDB        
      COMMON /UDSTR2/ NBLDES,STAG(21),CHORDD(21)        
      COMMON /UD3PRT/ IPRTC,ISTRML,IPGEOM        
CZZ   COMMON /ZZALGX/ IZ(1)        
      COMMON /ZZZZZZ/ IZ(1)        
      COMMON /CONTRL/ NANAL,NAERO,NARBIT,LOG1,LOG2,LOG3,LOG4,LOG5,LOG6  
      DATA    NAME  / 4HALG ,4H    /        
      DATA    WD    / 2HNO  ,2HAN  /        
      DATA    ISCR1 , ISCR2 / 301,302 /        
C        
      ISCR3  = 303        
      ISCR4  = 304        
      ISTRML = STRML        
      IPGEOM = PGEOM        
      IF (IPGEOM .EQ. 3) IPGEOM = 1        
      IPRTC = IPRTK        
      NZ    = KORSZ(IZ)        
      IBUF1 = NZ - SYSBUF + 1        
      IBUF2 = IBUF1 - SYSBUF        
      IBUF3 = IBUF2 - SYSBUF        
      IF (3*SYSBUF .GT. NZ) CALL MESAGE (-8,0,NAME)        
      CALL ALGPR (IERR)        
      IF (IERR .LT. 0) GO TO 400        
      ALGDB = ISCR1        
      IF (IERR .EQ. 1) ALGDB = ISCR2        
      LOG1  = ALGDB        
      LOG2  = NOUT        
      LOG3  = 7        
      LOG4  = ALGDB        
      LOG5  = ISCR4        
      LOG6  = 9        
      CALL GOPEN (LOG1,IZ(IBUF1),0)        
      CALL FREAD (LOG1,TITLE1,18,1)        
      CALL FREAD (LOG1,NANAL,1,0)        
      CALL FREAD (LOG1,NAERO,1,1)        
      NARBIT = 0        
      IF (IPRTC .EQ. 1) WRITE (LOG2,20) TITLE1,NANAL,WD(NAERO+1)        
      IF (IPRTC .EQ. 0) WRITE (LOG2,40) UIM        
   20 FORMAT (1H1,/40X,48HALG MODULE - COMPRESSOR DESIGN - CONTROL SECTI
     1ON , /40X,48(1H*), //10X,8HTITLE = ,18A4, /10X,39HNUMBER OF ANALYT
     2IC MEALINE BLADEROWS = ,I3, /10X,14HTHERE WILL BE ,A2,33H ENTRY TO
     3 THE AERODYNAMIC SECTION )        
   40 FORMAT (A29,' - MODULE ALG ENTERED.')        
C        
      IF (NANAL .EQ. 0) GO TO 200        
      IFILE = LOG5        
      CALL OPEN (*500,LOG5,IZ(IBUF2),1)        
      CALL ALGAN        
      CALL CLOSE (LOG5,1)        
  200 IF (NAERO .EQ. 0) GO TO 300        
      IFILE = LOG5        
      CALL OPEN (*500,LOG5,IZ(IBUF2),0)        
      IFILE = ISCR3        
      CALL OPEN (*500,ISCR3,IZ(IBUF3),1)        
      CALL ALGAR        
      CALL CLOSE (ISCR3,1)        
      CALL CLOSE (LOG5,1)        
  300 CALL CLOSE (LOG1,1)        
      CALL ALGPO (ISCR3)        
  400 GO TO 600        
  500 CALL MESAGE(-1,IFILE,NAME)        
C        
  600 RETURN        
      END        
