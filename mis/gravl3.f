      SUBROUTINE GRAVL3 (NVECT,GVECT,SR1,IHARM)        
C        
C     BUILD GRAVITY LOADS FOR AXISYMMETRIC SHELL        
C        
C     DEFINITION OF VARIABLES        
C        
C     NVECT    NUMBER OF GRAVITY LOADS        
C     GVECT    ARRAY OF G VECTORS        
C     SR1      FILE TO PUT ACCELERATION VECTOR ON        
C     IHARM    SINE OR COSINE SET FLAG -- 1 = SINE SET        
C     LUSET    LENGTH OF G SET        
C     MCB      MATRIX CONTROL BLOCK FOR SR1        
C     M        NUMBER OF RINGS        
C     N        NUMBER OF HARMONICS        
C     IL       POINTER IN GVECT ARRAY        
C        
      EXTERNAL        RSHIFT,ANDF        
      INTEGER         ANDF,RSHIFT,SYSBUF,MCB(7),SR1        
      DIMENSION       GVECT(1)        
      COMMON /MACHIN/ MACH,IHALF,JHALF        
      COMMON /BLANK / LUSET        
      COMMON /SYSTEM/ SYSBUF,IX(25),MN        
CZZ   COMMON /ZZSSA1/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /ZBLPKX/ B(4),II        
C        
C     INITIALIZE STUFF        
C        
      IBUF = KORSZ(Z) - SYSBUF + 1        
      CALL GOPEN (SR1,Z(IBUF),1)        
      CALL MAKMCB (MCB,SR1,LUSET,2,1)        
      IL    = 1        
      N= ANDF(MN,JHALF)        
      M= RSHIFT(MN,IHALF)        
C        
C     BUILD NVECT GRAVITY VECTORS        
C        
      DO 140 ILOOP = 1,NVECT        
      CALL BLDPK (1,1,MCB(1),0,0)        
C        
C     COMPUTE VALUES        
C        
      SINTH = 0.0        
      SINPH = 0.0        
      COSPH = 1.0        
      G = SQRT(GVECT(IL)*GVECT(IL)+GVECT(IL+1)*GVECT(IL+1)+GVECT(IL+2)* 
     1    GVECT(IL+2))        
      COSTH = GVECT(IL+2)/G        
      IF (GVECT(IL).EQ.0.0 .AND. GVECT(IL+1).EQ.0.0) GO TO 30        
      GXY   = SQRT(GVECT(IL)*GVECT(IL)+ GVECT(IL+1)*GVECT(IL+1))        
      SINTH = GXY/G        
      SINPH = GVECT(IL+1)/GXY        
      COSPH = GVECT(IL  )/GXY        
   30 CONTINUE        
      GO TO (40,50), IHARM        
C        
C     SINE SET        
C        
   40 B(1) = G*SINTH*SINPH        
      II = LUSET - M*(N-1)*6 + 1        
      DO 41 I = 1,M        
      CALL ZBLPKI        
      II = II +1        
      CALL ZBLPKI        
      II = II +5        
   41 CONTINUE        
      GO TO 110        
C        
C     COSINE SET        
C        
   50 B(1)=  G*COSTH        
      II  = LUSET - M*N*6 + 3        
C        
C     LOAD ZERO HARMONIC        
C        
      DO 51 I = 1,M        
      CALL ZBLPKI        
      II = II + 6        
   51 CONTINUE        
C        
C     LOAD 2-D HARMONIC        
C        
      II = II - 2        
      B(1) = G*SINTH*COSPH        
      DO 52 I = 1,M        
      CALL ZBLPKI        
      II = II +1        
      B(1) = -B(1)        
      CALL ZBLPKI        
      B(1) = -B(1)        
      II = II +5        
   52 CONTINUE        
C        
C     END OF COLUMN        
C        
  110 CALL BLDPKN (MCB(1),0,MCB(1))        
      IL = IL + 3        
  140 CONTINUE        
      CALL CLOSE (MCB(1),1)        
      CALL WRTTRL (MCB)        
      RETURN        
C        
      END        
