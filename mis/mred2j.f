      SUBROUTINE MRED2J (NUF,N2)        
C        
C     THIS SUBROUTINE PARTITIONS THE PHISS MATRIX FOR THE MRED2 MODULE. 
C        
      INTEGER         DRY,GBUF1,OTFILE,TYPIN,TYPOUT,PHISS,RPRTN,        
     1                ITRLR1(7),MODNAM(2)        
      COMMON /BLANK / IDUM1,DRY,IDUM4,GBUF1,IDUM2(5),INFILE(12),        
     1                OTFILE(6),ISCR(10),KORLEN,KORBGN,IDUM3(14),NMODES 
CZZ   COMMON /ZZMRD2/ RZ(1)        
      COMMON /ZZZZZZ/ RZ(1)        
      COMMON /PACKX / TYPIN,TYPOUT,IROW,NROW,INCR        
      EQUIVALENCE     (PHISS,INFILE(3)),(PHISS1,ISCR(8)),        
     1                (PHISS2,ISCR(9)) ,(RPRTN,ISCR(10))        
      DATA    MODNAM/ 4HMRED,4H2J  /        
C        
C     SET UP PARTITIONING VECTOR        
C        
      IF (DRY .EQ. -2) RETURN        
      TYPIN  = 1        
      TYPOUT = 1        
      IROW   = 1        
C     NROW   = ITRLR1(3)        
      INCR   = 1        
C        
C     COMMENTS FROM G.CHAN/UNISYS    4/92        
C     ORIGINALLY AT THIS POINT, THE FOLLOWING DO 20 LOOP IS IN ERROR    
C       1. KOLUMN AND J ARE NOT DEFINED        
C       2. NROW AND ITRLR1 ARE ALSO NOT YET DEFINED        
C        
C     MY BEST GUESS IS THE NEXT 10 LINES THAT FOLLOW        
C        
C     DO 20 I = 1,KOLUMN        
C     RZ(KORBGN+I-1) = 0.0        
C     IF (I .GT. NUF) RZ(KORBGN+J-1) = 1.0        
C  20 CONTINUE        
C        
      IFILE = PHISS        
      ITRLR1(1) = PHISS        
      CALL RDTRL (ITRLR1)        
      IF (ITRLR1(1) .LT. 0) GO TO 30        
      KOLUMN = ITRLR1(2)        
      NROW   = ITRLR1(3)        
      DO 20 I = 1,KOLUMN        
      RZ(KORBGN+I-1) = 0.0        
      IF (I .GT. NUF) RZ(KORBGN+I-1) = 1.0        
   20 CONTINUE        
C        
      IFORM = 7        
      CALL MAKMCB (ITRLR1,RPRTN,NROW,IFORM,ITRLR1(5))        
      CALL GOPEN  (RPRTN,RZ(GBUF1),1)        
      CALL PACK   (RZ(KORBGN),RPRTN,ITRLR1)        
      CALL CLOSE  (RPRTN,1)        
      CALL WRTTRL (ITRLR1)        
C        
C     PARTITION PHISS MATRIX        
C        
C        **     **   **               **        
C        *       *   *        .        *        
C        * PHISS * = * PHISS1 . PHISS2 *        
C        *       *   *        .        *        
C        **     **   **               **        
C        
C     IFILE = PHISS        
      ITRLR1(1) = PHISS        
      CALL RDTRL (ITRLR1)        
C     IF (ITRLR1(1) .LT. 0) GO TO 30        
      N2 = NMODES - NUF        
      CALL GMPRTN (PHISS,PHISS1,0,PHISS2,0,RPRTN,0,NUF,N2,RZ(KORBGN),   
     1             KORLEN)        
      RETURN        
C        
C     PROCESS SYSTEM FATAL ERRORS        
C        
   30 IMSG = -1        
      CALL SOFCLS        
      CALL MESAGE (IMSG,IFILE,MODNAM)        
      RETURN        
      END        
