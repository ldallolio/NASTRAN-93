      SUBROUTINE SDR3
      INTEGER OFPFIL(6)
C
      COMMON /SYSTEM/ SYSBUF, L
C*****
C  MAIN DRIVER FOR THE SDR3 MODULE...
C*****
      CALL SDR3A( OFPFIL(1) )
C*****
C  IF ANY OF THE SIX DATA-BLOCKS DID NOT COMPLETE SORT2 CALL OFPDMP
C*****
      DO 10 I = 1,6
      IF( OFPFIL(I) .EQ. 0 ) GO TO 10
      WRITE(L,15)I,OFPFIL(I)
   15 FORMAT(1H1,20(131(1H*)/),95H0DUE TO ERRORS MENTIONED PREVIOUSLY, S
     1DR3 IS CALLING THE -OFP- TO OUTPUT SDR3-INPUT-DATA-BLOCK-,I2,17H I
     2N SORT-I FORMAT/ 28H THE SDR3 TRACEBACK NUMBER =,I3//20(131(1H*)/ 
     3))                                                                
      IFILE = I + 100
      CALL OFPDMP( IFILE )
   10 CONTINUE
      RETURN
      END
