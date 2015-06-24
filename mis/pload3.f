      SUBROUTINE PLOAD3        
C        
C     COMPUTES THE CONTRIBUTION TO THE LOAD VECTOR DUE TO PRESSURES     
C     APPLIED TO THE FACES OF ISOPARAMETRIC SOLID ELEMENTS        
C        
      INTEGER     GP(32)     ,SEQ(32)    ,FACE       ,SGNCOL(6)  ,      
     1            COL        ,TYPE       ,CID(32)    ,N(3)       ,      
     2            IBGPD(4)        
C        
      DOUBLE PRECISION  SHP(32)    ,DSHP(3,32) ,JINV(3,3)  ,DETJ        
     1,     S(3,2)     ,ABSISA     ,PFACT      ,F(3,32)        
C        
      REAL  BXYZ(3,32) ,BGPD(4)    ,P(6)       ,RF(3,32)        
C        
      COMMON /LOADX /         LCORE      ,SLT        ,BGPDT      ,      
     1                        OLD        
CZZ   COMMON /ZZSSA1/         CORE(1)        
      COMMON /ZZZZZZ/         CORE(1)        
C        
      EQUIVALENCE (BGPD(1),IBGPD(1),DSHP(1,1))        
      EQUIVALENCE (SEQ(1),SHP(1))        
      EQUIVALENCE (N(1),NI)  ,(N(2),NJ)  ,(N(3),NK)        
      EQUIVALENCE (F(1,1),RF(1,1))        
C        
      DATA ABSISA/0.577350269189626D0/        
      DATA SGNCOL/-3,-2,1,2,-1,3/        
C        
C     READ PRESSURES AND GRID POINT ID S FROM THE SLT, DETERMINE        
C     ELEMENT TYPE AND NUMBER OF GRID POINTS AND GET BASIC COORDINATES. 
C        
      CALL READ(*500,*500,SLT,P,6,0,I)        
      CALL READ(*500,*500,SLT,GP,32,0,I)        
      TYPE=1        
      NGP=8        
      IF (GP(9) .EQ. 0) GO TO 10        
      TYPE=2        
      NGP=20        
      IF (GP(21) .EQ. 0) GO TO 10        
      TYPE=3        
      NGP=32        
   10 CALL PERMUT(GP,SEQ,NGP,OLD)        
      DO 30 I=1,NGP        
      J=SEQ(I)        
      CALL FNDPNT(BGPD,GP(J))        
      CID(J)=IBGPD(1)        
      DO 20 K=1,3        
      F(K,I)=0.0        
      BXYZ(K,J)=BGPD(K+1)        
   20 CONTINUE        
   30 CONTINUE        
C        
C     LOOP OVER SIX ELEMENT FACES        
C        
      DO 300 FACE=1,6        
      IF (P(FACE) .EQ. 0.0) GO TO 300        
      J=1        
      I=ISIGN(J,SGNCOL(FACE))        
      SGN=FLOAT(I)        
      COL=IABS(SGNCOL(FACE))        
      DO 50 I=1,3        
      IF (I .NE. COL) GO TO 40        
      S(I,1)=SGN        
      N(I)=1        
      GO TO 50        
   40 S(I,1)=-ABSISA        
      S(I,2)= ABSISA        
      N(I)=2        
   50 CONTINUE        
C        
C     INTEGRATION LOOPS        
C        
      DO 200 I=1,NI        
      DO 200 J=1,NJ        
      DO 200 K=1,NK        
C        
C     GENERATE SHAPE FUNCTIONS AND JACOBIAN MATRIX INVERSE.        
C        
      CALL IHEXSD(TYPE,SHP,DSHP,JINV,DETJ,0,S(1,I),S(2,J),S(3,K),BXYZ)  
      IF (DETJ .EQ. 0.0) CALL MESAGE(-61,0,0)        
      PFACT=DETJ*DBLE(SGN*P(FACE))        
C        
C     LOOP OVER GRID POINTS        
C        
      DO 100 L=1,NGP        
      IF (SHP(L) .EQ. 0.0) GO TO 100        
      DO 60 M=1,3        
   60 F(M,L)=PFACT*JINV(M,COL)*SHP(L)+F(M,L)        
  100 CONTINUE        
  200 CONTINUE        
  300 CONTINUE        
      J=3*NGP        
      DO 305 I=1,J        
  305 RF(I,1)=F(I,1)        
C        
C     TRANSFORM VECTOR TO GLOBAL AND ADD TO GLOBAL LOAD VECTOR.        
C        
      DO 400 I=1,NGP        
      IF (CID(I) .EQ. 0) GO TO 310        
      CALL BASGLB(RF(1,I),RF(1,I),BXYZ(1,I),CID(I))        
  310 CALL FNDSIL(GP(I))        
      DO 320 J=1,3        
      K=GP(I)+J-1        
      CORE(K)=CORE(K)+RF(J,I)        
  320 CONTINUE        
  400 CONTINUE        
      RETURN        
  500 CALL MESAGE(-61,0,0)        
      RETURN        
      END        
