      SUBROUTINE DPSE2        
C        
C     THIS ROUTINE COMPUTES THE TWO 6 X 6 MATRICES K(NPVT,NPVT) AND     
C     K(NPVT,J), PRESSURE STIFFNESS MATRICES FOR A CPSE2 PRESSURE       
C     STIFFNESS ELEMENT (ROD, 2 GRID POINTS)        
C        
C     DOUBLE PRECISION VERSION        
C        
C     WRITTEN BY E. R. CHRISTENSEN/SVERDRUP  7/91, VERSION 1.0        
C     INSTALLED IN NASTRAN AS ELEMENT DPSE2 BY G.CHAN/UNISYS, 2/92      
C        
C     REFERENCE - E. CHRISTENEN: 'ADVACED SOLID ROCKET MOTOR (ASRM)
C                 MATH MODELS - PRESSURE STIFFNESS EFFECTS ANALYSIS',
C                 NASA TD 612-001-02, AUGUST 1991
C
C     LIMITATION -        
C     (1) ALL GRID POINTS USED BY ANY OF THE CPSE2/3/4 ELEMENTS MUST BE 
C         IN BASIC COORDINATE SYSTEM!!!        
C     (2) CONSTANT PRESSURE APPLIED OVER AN ENCLOSED VOLUMN ENCOMPASSED 
C         BY THE CPSE2/3/4 ELEMENTRS        
C     (3) PRESSURE ACTS NORMALLY TO THE CPSE2/3/4 SURFACES        
C        
C     SEE NASTRAN DEMONSTRATION PROBLEM -  T13021A
C        
C     ECPT FOR THE PRESSURE STIFFNESS        
C     CPSE2 ELEMENT                                CARD        
C                                                  TYPE  TYPE   TABLE   
C                                                 ------ ----- ------   
C     ECPT( 1) ELEMENT ID.                         CPSE2   I     ECT    
C     ECPT( 2) SCALAR INDEX NUMBER FOR GRD.PT. A   CPSE2   I     ECT    
C     ECPT( 3) SCALAR INDEX NUMBER FOR GRD.PT. B   CPSE2   I     ECT    
C     ECPT( 4) PRESSURE P                          PPSE    R     EPT    
C     ECPT( 5) NOT USED                            PPSE    R     EPT    
C     ECPT( 6) NOT USED                            PPSE    R     EPT    
C     ECPT( 7) NOT USED                            PPSE    R     EPT    
C     ECPT( 8) COOR. SYS. ID. NO. FOR GRD.PT. A    GRID    I    BGPDT   
C     ECPT( 9) X-COORDINATE OF GRD.PT. A (IN BASIC COOR)   R    BGPDT   
C     ECPT(10) Y-COORDINATE OF GRD.PT. A (IN BASIC COOR)   R    BGPDT   
C     ECPT(11) Z-COORDINATE OF GRD.PT. A (IN BASIC COOR)   R    BGPDT   
C     ECPT(12) COOR. SYS. ID. NO. FOR GRD.PT. B            I    BGPDT   
C     ECPT(13) X-COORDINATE OF GRD.PT. B (IN BASIC COOR)   R    BGPDT   
C     ECPT(14) Y-COORDINATE OF GRD.PT. B (IN BASIC COOR)   R    BGPDT   
C     ECPT(15) Z-COORDINATE OF GRD.PT. B (IN BASIC COOR)   R    BGPDT   
C     ECPT(16) ELEMENT TEMPERATURE        
C     ECPT(17) THRU ECPT(24) = DUM2 AND DUM6, NOT USED IN THIS ROUTINE  
C        
      DOUBLE PRECISION KE,TA,TB,D,X,Y,Z,XL,ALPHA        
      DIMENSION        IECPT(3)        
C     COMMON /SYSTEM/  IBUF,NOUT        
      COMMON /DS1AAA/  NPVT,ICSTM,NCSTM        
      COMMON /DS1AET/  ECPT(16),DUM2(2),DUM6(6)        
      COMMON /DS1ADP/  KE(36),TA(9),TB(9),D(18),X,Y,Z,XL,ALPHA        
      EQUIVALENCE      (ECPT(1),IECPT(1))        
C        
      IELEM = IECPT(1)        
      IF (IECPT(2) .EQ. NPVT) GO TO 10        
      IF (IECPT(3) .NE. NPVT) CALL MESAGE (-30,34,IECPT(1))        
      ITEMP = IECPT(2)        
      IECPT(2) = IECPT(3)        
      IECPT(3) = ITEMP        
      KA  = 12        
      KB  =  8        
      ALPHA = -1.0D0        
      GO TO 20        
   10 KA  =  8        
      KB  =  12        
      ALPHA = 1.0D0        
C        
C     AT THIS POINT KA POINTS TO THE COOR. SYS. ID. OF THE PIVOT GRID   
C     POINT. SIMILARLY FOR KB AND THE NON-PIVOT GRID POINT.        
C        
C     NOW COMPUTE THE LENGTH OF THE CPSE2 ELEMENT.        
C        
C        
C     WE STORE THE COORDINATES IN THE D ARRAY SO THAT ALL ARITHMETIC    
C     WILL BE DOUBLE PRECISION        
C        
C     CHECK TO SEE THAT THE CPSE2 HAS A NONZERO LENGTH        
C        
   20 D(1) = ECPT(KA+1)        
      D(2) = ECPT(KA+2)        
      D(3) = ECPT(KA+3)        
      D(4) = ECPT(KB+1)        
      D(5) = ECPT(KB+2)        
      D(6) = ECPT(KB+3)        
      X    = D(1) - D(4)        
      Y    = D(2) - D(5)        
      Z    = D(3) - D(6)        
      XL = DSQRT(X**2 + Y**2 + Z**2)        
      IF (XL .EQ. 0.0D0) GO TO 70        
C        
C     COMPUTE THE 3 X 3 NON-ZERO SUBMATRIX OF KDGG(NPVT,NONPVT)        
C        
      D(1) = 0.0D0        
      D(2) = ALPHA*ECPT(4)/2.0D0        
      D(3) = D(2)        
      D(4) =-D(2)        
      D(5) = 0.0D0        
      D(6) = D(2)        
      D(7) = D(4)        
      D(8) = D(4)        
      D(9) = 0.0D0        
C        
C     ZERO OUT KE MATRIX        
C        
      DO 30 I = 1,36        
   30 KE(I) = 0.0D0        
C        
C     FILL UP THE 6 X 6 KE        
C        
C     IF PIVOT GRID POINT IS IN BASIC COORDINATES, GO TO 40        
C        
      K1 = 1        
      IF (IECPT(KA) .EQ. 0) GO TO 40        
      CALL TRANSD (ECPT(KA),TA)        
      CALL GMMATD (TA,3,3,1, D(1),3,3,0, D(10))        
      K1  = 10        
      KB1 = 10        
      KB2 = 1        
      GO TO 50        
C        
C     IF NON-PIVOT GRID POINT IS IN BASIC COORDINATES, GO TO 60        
C        
   40 KB1 = 1        
      KB2 = 10        
   50 IF (IECPT(KB) .EQ. 0) GO TO 60        
      CALL TRANSD (ECPT(KB),TB)        
      CALL GMMATD (D(KB1),3,3,0, TB,3,3,0, D(KB2))        
      K1 = KB2        
C        
   60 KE( 1) = D(K1  )        
      KE( 2) = D(K1+1)        
      KE( 3) = D(K1+2)        
      KE( 7) = D(K1+3)        
      KE( 8) = D(K1+4)        
      KE( 9) = D(K1+5)        
      KE(13) = D(K1+6)        
      KE(14) = D(K1+7)        
      KE(15) = D(K1+8)        
      CALL DS1B (KE,IECPT(3))        
      RETURN        
C        
C     ERROR        
C        
   70 CALL MESAGE (30,26,IECPT(1))        
      NOGO = 1        
      RETURN        
      END        
