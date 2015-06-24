      SUBROUTINE INPTT3        
C        
C     THIS ROUTINE READS MATRIX DATA FROM AN INPUT TAPE, WRITTEN IN     
C     ROCKWELL INTERNATIONAL COMPANY'S CUSTOMARY FORMAT, INTO NASTRAN   
C     GINO MATRIX BLOCK.        
C     (THE RI DATA IS IN A COMPACT FORTRAN-FORMATTED CODED FORM, DOUBLE 
C     PRECISION, WHCIH APPEARS TO HAVE QUITE WIDESPREAD ACCEPTANCE IN   
C     THE AEROSPACE FIELD, AND PARTICULARY IN MARSHALL SPACE FLIEGHT    
C     CENTER (MSFC) AREA)        
C        
C     WRITTEN ORIGINALLY BY MEL MARTENS, ROCKWELL INTERNATIONAL, SPACE  
C     DIVISION (213) 922-2316, AND MODIFIED UP TO NASTRAN STANDARD BY   
C     G.CHAN/UNISYS, 2/1987        
C        
C     INPTT3  /O1,O2,O3,O4,O5/V,N,UNIT/V,N,ERRFLG/V,N,TEST  $        
C        
C             UNIT  = FORTRAN INPUT TAPE UNIT NO.        
C                     TAPE IS REWOUND BEFORE READ IF UNIT IS NEGATIVE   
C                     FORTRAN UNIT 11 (INPT) IS USED IF UNIT= 0 OR -1.  
C             ERRFLG= 1, JOB TERMINATED IF DATA BLOCK ON TAPE NO FOUND  
C                     0, NO TERMINATION IF DATA BLOCK NO FOUND ON TAPE  
C             TEST  = 0, NO CHECK ON FILE NAMES ON TAPE AND DMAP NAMES  
C                   = 1, NAMES CHECK, WILL SEARCH TAPE FOR MATCH.       
C        
      IMPLICIT INTEGER (A-Z)        
      INTEGER          MCB(7),  NAME(2),  NAMX(2), SUBNAM(2)        
      DOUBLE PRECISION DZ(1)        
      CHARACTER        UFM*23,  UWM*25,   UIM*29        
      COMMON /XMSSG /  UFM,     UWM,      UIM        
      COMMON /SYSTEM/  IBUF,    NOUT        
      COMMON /PACKX /  TYPIN,   TYPOUT,   II,      JJ,      INCR        
CZZ   COMMON /ZZINP3/  Z(1)        
      COMMON /ZZZZZZ/  Z(1)        
      COMMON /BLANK /  UNIT,    ERRFLG,   TEST        
      COMMON /NAMES /  RD,      RDREW,    WRT,     WRTREW,  REW        
      EQUIVALENCE      (Z(1),DZ(1))        
      DATA             END,     HEAD,     SUBNAM                  /     
     1                 -999,    -111,     4HINPT,  4HT3           /     
C        
      CORE = KORSZ(Z(1))        
      BUF1 = CORE - IBUF + 1        
      CORE = BUF1 - 1        
      TYPIN= 2        
      TYPOUT=2        
      INCR = 1        
C        
      IU = UNIT        
      IF (UNIT.EQ.0 .OR. UNIT.EQ.-1) IU = -11        
      IF (IU .GT. 0) GO TO 10        
      IU  = -IU        
      IREW= 0        
      REWIND IU        
C        
   10 DO 150 K = 1,5        
      FILE = 200 + K        
      MCB(1) = FILE        
      CALL RDTRL (MCB)        
      IF (MCB(1) .LE. 0) GO TO 150        
      CALL GOPEN (FILE,Z(BUF1),WRTREW)        
      CALL FNAME (FILE,NAME)        
   20 READ (IU,30,ERR=160,END=180) I,NAMX        
   30 FORMAT (I6,2A4)        
      IF (I .GT.    0) GO TO 20        
      IF (I .EQ.  END) GO TO 120        
      IF (I .NE. HEAD) GO TO 130        
      IF (NAMX(1).EQ.NAME(1) .AND. NAMX(2).EQ.NAME(2)) GO TO 50        
      WRITE  (NOUT,40) UIM,NAMX,NAME        
   40 FORMAT (A29,', DATA BLOCK ',2A4,' FOUND WHILE SEARCHING FOR ',2A4)
      IF (TEST) 20,70,20        
C        
C     FOUND        
C        
   50 WRITE  (NOUT,60) UIM,NAME        
   60 FORMAT (A29,', DATA BLOCK ',2A4,' FOUND')        
   70 READ   (IU,80) NR,NC,TYPE        
   80 FORMAT (3I6)        
      WRITE  (NOUT,90) NAME,NC,NR,TYPE        
   90 FORMAT (/5X,'MATRIX BLOCK ',2A4,' IS OF SIZE ',I6,'(COL) BY',I5,  
     1       '(ROW),  AND TYPE =',I6)        
      IF (NR .GT. CORE) CALL MESAGE (-8,NR-CORE,SUBNAM)        
      IREW= 1        
      II  = 1        
      JJ  = NR        
      CALL MAKMCB (MCB,FILE,NR,TYPE,2)        
      DO 110 I = 1,NC        
      READ (IU,100,ERR=160,END=180) (DZ(J),J=1,NR)        
  100 FORMAT (12X,1P,5D24.16)        
      CALL PACK (Z,FILE,MCB)        
  110 CONTINUE        
      CALL CLOSE (FILE,REW)        
      CALL WRTTRL (MCB)        
      GO TO 150        
C        
  120 IF (IREW .EQ. 0) GO TO 130        
      REWIND IU        
      IREW = 0        
      GO TO 20        
  130 WRITE  (NOUT,140) UWM,NAME        
  140 FORMAT (A25,', INPTT3 FAILED TO LOCATE DATA BLOCK ',2A4,' ON ',   
     1       'TAPE')        
      IF (ERRFLG .NE. 0) CALL MESAGE (-61,0,SUBNAM)        
      REWIND IU        
      IREW = 0        
  150 CONTINUE        
      RETURN        
C        
  160 WRITE  (NOUT,170) IU        
  170 FORMAT ('0*** ERROR DUING READ.  TAPE UNIT',I5)        
      CALL CLOSE (FILE,REW)        
      CALL MESAGE (-61,0,SUBNAM)        
  180 WRITE  (NOUT,190) UWM,IU        
  190 FORMAT (A25,' FROM INPTT3, EOF ENCOUNTERED ON INPUT TAPE',I4)     
      CALL CLOSE  (FILE,REW)        
      CALL WRTTRL (MCB)        
      RETURN        
      END        
