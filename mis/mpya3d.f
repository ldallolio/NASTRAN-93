      SUBROUTINE MPYA3D (AA,BB,NROW,BAND,CC)        
C        
C     WITH ENTRY MPYA3S (A,B,NROW,BAND,C)        
C        
C     WAS NAMED DATBAD/DATBAS IN UAI CODE        
C        
C     THESE ROUTINES PERFORM TRIPLE MATRIX MULTIPLY OF THE FORM        
C        
C                          T        
C                 C = C + A * B * A        
C        
C     ON TWO INCOMING ROW-LOADED MATRICES A AND B, AND ADD THEM TO      
C     MATRIX C        
C        
C     THE INCOMING MATRICES MUST BE SQUARE (AND OBVIOUSLY OF THE SAME   
C     SIZE, NROW.) AND        
C     SYMMETRICAL (SINCE WE OPERATE ONLY ON LOWER TRIANGULAR MATRICES)   
C        
C     MATRIX A CAN BE A PSUEDO-DIAGONAL MATRIX, I.E. A MATRIX HAVING    
C     SQUARE PARTITIONS OF NON-ZERO TERMS ALONG ITS DIAGONAL.        
C     THESE PARTITIONS ARE OF THE SIZE  BAND X BAND.        
C     NOTE THAT NROW MUST BE AN INTEGER MULTIPLE OF BAND.        
C        
C     THIS ALGORITHM IS SUITABLE FOR TRIPLE MULTIPLIES INVOLVING GLOBAL 
C     TRANSFORMATIONS.        
C        
C        
      INTEGER          BAND        
      REAL             A(1) ,B(1) ,C(1)        
      DOUBLE PRECISION AA(1),BB(1),CC(1),DD        
C        
C        
C     DOUBLE PRECISION VERSION        
C        
      II = 0        
      DO 50 IB = 1,NROW        
      IA1 = ((IB-1)/BAND+1)*BAND        
C        
      DO 40 ID1 = 1,NROW,BAND        
      ID2 = ID1 + BAND - 1        
      IF (ID1 .GT. IA1) GO TO 50        
C        
      ID11N = (ID1-1)*NROW        
      DO 30 ID = ID1,ID2        
C     JJ = (ID1-1)*NROW        
      JJ = ID11N        
      DD = 0.0D0        
C        
      DO 10 IC = ID1,ID2        
      IBIC = II + IC        
C     IF (BB(IBIC) .EQ. 0.0D0) GO TO 10        
      ICID = JJ + ID        
      IF (AA(ICID) .EQ. 0.0D0) GO TO 10        
      DD = DD + BB(IBIC)*AA(ICID)        
   10 JJ = JJ + NROW        
C        
      IF (DD .EQ. 0.0D0) GO TO 30        
      KK = (ID-1)*NROW        
C        
      DO 20 IA = ID,IA1        
      IBIA = II + IA        
      IF (AA(IBIA) .EQ. 0.0D0) GO TO 20        
      IAID = KK + ID        
      CC(IAID) = CC(IAID) + DD*AA(IBIA)        
   20 KK = KK + NROW        
C        
   30 CONTINUE        
   40 CONTINUE        
   50 II = II + NROW        
C        
C     COPY THE LOWER TRIANGLE TO THE UPPER        
C        
      KK = NROW - 1        
      II = 0        
      DO 70 I = 1,KK        
      IB = I + 1        
      JJ = I*NROW
      DO 60 J = IB,NROW        
      CC(II+J) = CC(JJ+I)        
   60 JJ = JJ + NROW        
   70 II = II + NROW        
C        
      RETURN        
C        
C        
      ENTRY MPYA3S (A,B,NROW,BAND,C)        
C     ==============================        
C        
C     SINGLE PRECISION VERSION        
C        
      II = 0        
      DO 150 IB = 1,NROW        
      IA1 = ((IB-1)/BAND+1)*BAND        
C        
      DO 140 ID1 = 1,NROW,BAND        
      ID2 = ID1 + BAND - 1        
      IF (ID1 .GT. IA1) GO TO 150        
C        
      ID11N = (ID1-1)*NROW        
      DO 130 ID = ID1,ID2        
C     JJ = (ID1-1)*NROW        
      JJ = ID11N        
      DD = 0.0D0        
C        
      DO 110 IC = ID1,ID2        
      IBIC = II + IC        
C     IF (B(IBIC) .EQ. 0.0) GO TO 110        
      ICID = JJ + ID        
      IF (A(ICID) .EQ. 0.0) GO TO 110        
      DD = DD + DBLE(B(IBIC))*DBLE(A(ICID))        
  110 JJ = JJ + NROW        
      IF (DD .EQ. 0.0D0) GO TO 130        
      KK = (ID-1)*NROW        
C        
      DO 120 IA = ID,IA1        
      IBIA = II + IA        
      IF (A(IBIA) .EQ. 0.0) GO TO 120        
      IAID = KK + ID        
      C(IAID) = SNGL(DBLE(C(IAID)) + DD*DBLE(A(IBIA)))        
  120 KK = KK + NROW        
C        
  130 CONTINUE        
  140 CONTINUE        
  150 II = II + NROW        
C        
C     COPY THE LOWER TRIANGLE TO THE UPPER        
C        
      KK = NROW - 1        
      II = 0        
      DO 170 I = 1,KK        
      IB = I + 1        
      JJ = I*NROW
      DO 160 J = IB,NROW        
      C(II+J) = C(JJ+I)        
  160 JJ = JJ + NROW        
  170 II = II + NROW        
C        
      RETURN        
      END        
