      SUBROUTINE TA1        
C        
C     TA1 CONTROLS THE EXECUTION OF THE TABLE ASSEMBLER.        
C        
C     DMAP CALL IS        
C        
C     TA1   ECT,EPT,BGPDT,SIL,GPTT,CSTM,MPT,EQEXIN/EST,GEI,GPECT,       
C           ECPT,GPCT,MPTX,PCOMPS,EPTX/V,N,LUSET/V,N,NOSIMP=-1/        
C           V,N,NOSUP=-1,1,2/V,N,NOGENEL=-1/V,N,GENEL/V,N,COMPS=1 $     
C        
C        
C     EITHER THE GPECT OR BOTH GPECT AND ECPT, GPCT MAY BE GENERATED.   
C     IF NOSUP .EQ. 1, GENERATE GPECT. IF NOSUP .EQ. 2 , GENERATE ALL.  
C     IF NOSUP .LT. 0, GENERATE NONE.        
C        
C   1. TA1 EXECUTES TA1A WHICH BUILDS THE ELEMENT SUMMARY TABLE (EST)   
C   2. TA1 EXECUTES TA1B WHICH BUILDS THE ELEMENT CONNECTION AND        
C      PROPERTIES TABLE (ECPT) AND THE GRID POINT CONNECTION TABLE(GPCT)
C   3. IF GENERAL ELEMENTS ARE PRESENT, TA1 EXECUTES TA1C WHICH BUILDS  
C      THE GENERAL ELEMENT INPUT (GEI).        
C   4. IF LAMINATED COMPOSITE ELEMENTS ARE PRESENT, TA1 EXECUTES        
C      TA1CPS/D WHICH -        
C      (1) CREATES PCOMPS DATA, WHICH INCLUDES THE ECHOING OF        
C          INTRINSIC LAYER PROPERTIES, AND        
C      (2) CALCULATES OVERALL MATERIAL PROPERTIES.        
C        
C        
      EXTERNAL        ANDF        
      INTEGER         GENL  ,ECT   ,EPT   ,BGPDT ,SIL   ,GPTT  ,        
     1                ECPT  ,GPCT  ,SCR1  ,SCR2  ,TWO   ,EST   ,        
     2                ANDF  ,SCR3  ,SCR4  ,GEI   ,CSTM  ,GPECT ,        
     3                PCOMPS,EPTX  ,COMPS ,EQEXIN,GENEL(2)        
      DIMENSION       MCB(7)        
      COMMON /BLANK / LUSET ,NOSIMP,NOSUP ,NOGENL,GENL  ,COMPS        
      COMMON /SYSTEM/ ISYSTM(54)   ,IPREC        
      COMMON /TA1COM/ NSIL  ,ECT   ,EPT   ,BGPDT ,SIL   ,GPTT  ,CSTM  , 
     1                MPT   ,EST   ,GEI   ,GPECT ,ECPT  ,GPCT  ,MPTX  , 
     2                PCOMPS,EPTX  ,SCR1  ,SCR2  ,SCR3  ,SCR4  ,EQEXIN  
      COMMON /TWO   / TWO(32)        
      DATA    GENEL / 4301 , 43 /        
C        
C     INITIALIZE        
C        
      CALL DELSET        
      ECT    = 101        
      EPT    = 102        
      BGPDT  = 103        
      SIL    = 104        
      GPTT   = 105        
      CSTM   = 106        
      MPT    = 107        
      EQEXIN = 108        
C        
      EST    = 201        
      GEI    = 202        
      GPECT  = 203        
      ECPT   = 204        
      GPCT   = 205        
      MPTX   = 206        
      PCOMPS = 207        
      EPTX   = 208        
C        
      SCR1   = 301        
      SCR2   = 302        
      SCR3   = 303        
      SCR4   = 304        
C        
C     TEST FOR PRESENCE OF GENERAL ELEMENTS        
C        
      NOGENL = -1        
      MCB(1) = ECT        
      CALL RDTRL (MCB)        
      IF (MCB(1) .LT. 0) GO TO 100        
      J = (GENEL(2)-1)/16        
      K =  GENEL(2)-16*J        
      IF (ANDF(MCB(J+2),TWO(K+16)) .NE. 0) NOGENL = 1        
C        
C     EXECUTE TA1A FOR ALL PROBLEMS        
C        
  100 CALL TA1A        
C        
C     EXECUTE TA1CPD/S TO BUILD PCOMPS DATA        
C        
      IF (NOSUP .EQ. 0) GO TO 300        
      IF (COMPS .NE.-1) GO TO 200        
      IF (IPREC .EQ. 1) CALL TA1CPS        
      IF (IPREC .EQ. 2) CALL TA1CPD        
  200 IF (NOSUP .EQ. 1) GO TO 400        
C        
C     EXECUTE TA1B IF SIMPLE ELEMENTS ARE PRESENT        
C        
  300 IF (NOSIMP.GT. 0) CALL TA1B        
      IF (NOSUP .EQ. 0) GO TO 500        
C        
C     CALL TA1H TO GENERATE GPECT        
C        
  400 IF (NOSIMP .GT. 0) CALL TA1H        
C        
C     EXECUTE TA1C IF GENERAL ELEMENTS ARE PRESENT        
C        
  500 IF (NOGENL .GT. 0) CALL TA1C        
      GENL = -NOGENL        
C        
      RETURN        
      END        
