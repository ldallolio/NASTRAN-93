      SUBROUTINE SMA1B (KE,J,II,IFILE,DAMPC)        
C        
C     SUBROUTINE SMA1B ADDS A N X N DOUBLE PRECISION MATRIX, KE, TO THE 
C     SUBMATRIX OF ORDER NROWSC X JMAX, WHICH IS IN CORE.  N IS 1 IF    
C     EITHER  NPVT, THE PIVOT POINT, IS A SCALAR POINT, OR J,THE SECOND 
C     SUBSCRIPT OF KE CORRESPONDS TO A SCALAR POINT, OR J .NE. TO ANY   
C     ENTRY IN THE GPCT.  OTHERWISE N IS 6.        
C        
      INTEGER          IZ(1),EOR,CLSRW,CLSNRW,FROWIC,TNROWS,OUTRW       
      DOUBLE PRECISION DZ(1),KE(36),DAMPC        
      COMMON /BLANK /  ICOM        
      COMMON /SYSTEM/  ISYS(21),LINKNO        
      COMMON /SEM   /  MASK(3),LNKNOS(15)        
C        
C     SMA1 I/O PARAMETERS        
C        
      COMMON /SMA1IO/  IFCSTM,IFMPT,IFDIT,IDUM1,IFECPT,IGECPT,        
     1                 IFGPCT,IGGPCT,IFGEI,IGGEI,IFKGG,IGKGG,        
     2                 IF4GG,IG4GG,IFGPST,IGGPST,INRW,OUTRW,        
     3                 CLSNRW,CLSRW,NEOR,EOR,MCBKGG(7),MCB4GG(7)        
C        
C     SMA1 VARIABLE CORE        
C        
CZZ   COMMON /ZZSMA1/  Z(1)        
      COMMON /ZZZZZZ/  Z(1)        
C        
C     SMA1 VARIABLE CORE BOOKKEEPING PARAMETERS        
C        
      COMMON /SMA1BK/  ICSTM,NCSTM,IGPCT,NGPCT,IPOINT,NPOINT,        
     1                 I6X6K,N6X6K,I6X64,N6X64        
C        
C     SMA1 PROGRAM CONTROL PARAMETERS        
C        
      COMMON /SMA1CL/  IOPT4,K4GGSW,NPVT,LEFT,FROWIC,LROWIC,        
     1                 NROWSC,TNROWS,JMAX,NLINKS,LINK(10),IDETCK,       
     2                 DODET,NOGO        
C        
C     ECPT COMMON BLOCK        
C        
      COMMON /SMA1ET/  ECPT(100)        
C        
      EQUIVALENCE      (Z(1),IZ(1),DZ(1))        
C        
C        
C     CALL EMG1B AND THEN RETURN IF THIS IS LINK 8.        
C     PROCEED NORMALLY FOR OTHER LINKS.        
C        
      IF (LINKNO .NE. LNKNOS(8)) GO TO 2        
      CALL EMG1B (KE,J,II,IFILE,DAMPC)        
      RETURN        
C        
C     DETERMINE WHICH MATRIX IS BEING COMPUTED.        
C        
    2 IBASE = I6X6K        
      IF (IFILE .EQ. IFKGG) GO TO 5        
      IF (IOPT4 .LT. 0) RETURN        
      IBASE = I6X64        
C        
C     SEARCH THE GPCT AND FIND AN INDEX M SUCH THAT        
C     IABS(GPCT(M)) .LE. J .LT. IABS(GPCT(M+1))        
C        
    5 LOW = IGPCT + 1        
      LIM = NGPCT + LOW - 2        
      IF (LOW .GT. LIM) GO TO 15        
      DO 10 I = LOW,LIM        
      ISAVE = I        
      IF (J .GE. IABS(IZ(I+1))) GO TO 10        
      IF (J .GE. IABS(IZ(I))  ) GO TO 20        
   10 CONTINUE        
      IF (J .GE. IABS(IZ(ISAVE+1))) ISAVE = ISAVE + 1        
      GO TO 20        
C        
C     IF II .GT. 0, WE ARE DEALING WITH A SCALAR POINT.        
C        
   15 ISAVE = LOW        
   20 IF (II .GT. 0) GO TO 60        
C        
C     AT THIS POINT IT HAS BEEN DETERMINED THAT J IS A SCALAR INDEX     
C     NUMBER WHICH CORRESPONDS TO A GRID POINT.  HENCE THE DOUBLE       
C     PRECISION 6 X 6 MATRIX, KE, WILL BE ADDED TO THE MATRIX.        
C        
      L1 = FROWIC - 1        
      JJ = IPOINT + ISAVE - IGPCT        
      J2 = IZ(JJ) - 1        
      I1 = 0        
      LIM= NROWSC - 1        
   30 IF (I1 .GT. LIM) RETURN        
      K1 = IBASE + I1*JMAX + J2        
      J1 = 0        
      L  = 6*L1        
      K  = K1        
   40 J1 = J1 + 1        
      IF (J1 .GT. 6) GO TO 50        
      K  = K + 1        
      L  = L + 1        
      IF (IFILE - IFKGG) 47,43,47        
   43 DZ(K) = DZ(K) + KE(L)        
      GO TO 40        
   47 DZ(K) = DZ(K) + DAMPC*KE(L)        
      GO TO 40        
   50 I1 = I1 + 1        
      L1 = L1 + 1        
      GO TO 30        
C        
C     AT THIS POINT WE ARE DEALING WITH A 1 X 1.        
C     FIRST COMPUTE THE ROW NUMBER, NROW        
C        
   60 NROW = II - NPVT + 1        
C        
C     THE FOLLOWING 2 FORTRAN STATEMENTS ARE MERELY TO CHECK THE PROGRAM
C     LOGIC.  EVENTUALLY THEY CAN BE DELETED.        
C        
      IF (NROW.GE.1 .AND. NROW.LE.TNROWS) GO TO 70        
      CALL MESAGE (-30,22,NROW)        
   70 LROWIC = FROWIC + NROWSC - 1        
C        
C     IF NROW, THE ROW INTO WHICH THE NUMBER KE(1) IS TO BE ADDED IS NOT
C     IN CORE IT CANNOT BE ADDED AT THIS TIME.        
C        
      IF (NROW.LT.FROWIC .OR. NROW.GT.LROWIC) RETURN        
      J2 = ISAVE        
      J3 = IPOINT + ISAVE - IGPCT        
      INDEX = IBASE + (NROW-1)*JMAX + IZ(J3) - IABS(IZ(J2)) + J        
      DZ(INDEX) = DZ(INDEX) + KE(1)        
      RETURN        
      END        
