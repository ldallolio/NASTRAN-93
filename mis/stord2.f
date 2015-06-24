      SUBROUTINE STORD2 (TI)        
C        
C*****        
C THIS ROUTINE IS PHASE II OF STRESS DATA RECOVERY FOR AN AXI-SYMMETRIC 
C TOROIDAL THIN SHELL RING        
C*****        
C        
C        
C        
      DIMENSION          TI(2)        
      DIMENSION          DUM3(225)        
      DIMENSION          STRES(100),    FORCE(25)        
      DIMENSION          ISTRES(100),   IFORCE(25)        
C        
C        
C SDR2 VARIABLE CORE        
C        
CZZ   COMMON   /ZZSDR2/  ZZ(1)        
      COMMON   /ZZZZZZ/  ZZ(1)        
C        
C        
C SDR2 BLOCK FOR POINTERS AND LOADING TEMPERATURES        
C        
      COMMON   /SDR2X4/        
     1                   DUM1(33)        
     2,                  ICSTM,    NCSTM,    IVEC,     IVECN        
     3,                  TEMPLD,   ELDEFM        
C        
C        
C SDR2 INPUT AND OUTPUT BLOCK        
C        
      COMMON   /SDR2X7/        
     1                   IDEL,     IGP(2),   TZ        
     2,                  SEL(180), TS(30),   AK(144)        
C        
C        
C SCRATCH BLOCK        
C        
      COMMON   /SDR2X8/        
     1                   DISP(12), EFORC(12),ESTRES(15)        
C        
C        
      EQUIVALENCE (DUM3(1) , IDEL)        
      EQUIVALENCE  (DUM3(101) , STRES(1) , ISTRES(1))        
      EQUIVALENCE  (DUM3(201) , FORCE(1) , IFORCE(1))        
      EQUIVALENCE (LDTEMP, TEMPLD)        
C        
C        
C        
C INITIALIZE COUNTERS        
C        
      NDOF  = 6        
      NUMPT = 2        
      N = NDOF * NUMPT        
      NSP   = 3        
      NCOMP =  5        
      NS = NSP * NCOMP        
C        
C        
C LOCATE THE DISPLACEMENTS        
C        
      K = 0        
      DO 100 I = 1,NUMPT        
      ILOC = IVEC + IGP(I) - 2        
      DO 100 J = 1,NDOF        
      ILOC = ILOC + 1        
      K = K + 1        
      DISP(K) = ZZ(ILOC)        
  100 CONTINUE        
C        
C        
C COMPUTE THE GRID POINT FORCES        
C        
      CALL GMMATS ( AK(1) , N, N, 0, DISP(1) , N, 1, 0, EFORC(1) )      
C        
C        
C COMPUTE THE STRESSES        
C        
      CALL GMMATS ( SEL(1), NS, N, 0, DISP(1) , N, 1, 0, ESTRES(1) )    
C        
C        
C COMPUTE THERMAL STRESS IF THERMAL LOAD EXISTS        
C AND SUBTRACT FROM APPARENT STRESS        
C        
      IF (LDTEMP .EQ. (-1)) GO TO 300        
C        
      DTM1 = TI(1) - TZ        
      DTM2 = TI(2) - TI(1)        
      DTF1 = 0.0E0        
      DTF2 = 0.0E0        
C        
C THE TERMS DTF1 AND DTF2 ARE FUNCTIONS OF THE FLEXURAL GRADIENT        
C TEMPERATURE BUT SINCE THESE TEMPERATURES ARE NOT AVAILABLE        
C THE TERMS WILL BE SET TO ZERO. THEY ARE USUALLY DEFINED AS FOLLOWS,   
C     DTF1 = TF(1) - TZ        
C     DTF2 = TF(2) - TF(1)        
C WHERE TF(1) AND TF(2) ARE THE FLEXURAL GRADIENT TEMPERATURES AT       
C GRID POINTS 1 AND 2 RESPECTIVELY.        
C        
      K = 0        
      DO 250 I = 1,NSP        
      DO 225 J = 1,NCOMP        
      K = K + 1        
      IF (J.GT.2) GO TO 200        
      ESTRES(K) = ESTRES(K) - DTM1 * TS(K) - DTM2 * TS(K+15)        
      GO TO 225        
  200 CONTINUE        
      ESTRES(K) = ESTRES(K) - DTF1 * TS(K) - DTF2 * TS(K+15)        
  225 CONTINUE        
  250 CONTINUE        
C        
  300 CONTINUE        
C        
C        
C STORE RESULTS FOR OUTPUT PRINT        
C        
      K = 0        
      J = 1        
      ISTRES(1)   = IDEL        
      DO 400 KK = 1,NSP        
      DO 400 I = 1,NCOMP        
      J = J + 1        
      K = K + 1        
      STRES(J) = ESTRES(K)        
  400 CONTINUE        
C        
C        
      K = 0        
      J = 1        
      IFORCE(1)   = IDEL        
      DO 500 I = 1,NUMPT        
      DO 500 KK= 1,NDOF        
      J = J + 1        
      K = K + 1        
      FORCE(J) = EFORC(K)        
  500 CONTINUE        
C        
      RETURN        
      END        
