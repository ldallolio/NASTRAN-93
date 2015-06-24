      SUBROUTINE FVRS2A (FILE,KK1,KK2,NORO,BUFFER)
C
C     GENERATE COLUMN REORDERING MATRIX. THIS MATRIX WILL REORDER
C     COLUMNS OF A MATRIX BY POST-MULTIPLYING THE MATRIX WHOSE
C     COLUMNS ARE TO BE REORDERED BY THE REORDERING MATRIX.
C
C     THE MATRIX WILL BE A REAL SINGLE-PRECISION SQUARE MATRIX.
C
      INTEGER FILE,ROW,TRL(7),BUFFER(1),TYPIN,TYPOUT
C
      COMMON /PACKX/ TYPIN,TYPOUT,II,NN,INCR
C
      NORO = -1
      IF(KK1.EQ.1 .OR. KK2.EQ.1) RETURN
C
      NORO = 1
C
      TYPIN  = 1
      TYPOUT = 1
      INCR   = 1
C
      TRL(1) = FILE
      TRL(2) = 0
      TRL(3) = KK1*KK2
      TRL(4) = 1
      TRL(5) = TYPOUT
      TRL(6) = 0
      TRL(7) = 0
C
      CALL GOPEN(FILE,BUFFER,1)
C
      VALUE = 1.0
C
      DO 20 K1 = 1,KK1
      ROW = K1
      DO 10 K2 = 1,KK2
C
      II = ROW
      NN = ROW
      CALL PACK(VALUE,FILE,TRL)
C
      ROW = ROW + KK1
C
   10 CONTINUE
   20 CONTINUE
C
      CALL CLOSE(FILE,1)
      CALL WRTTRL(TRL)
C
      RETURN
      END
