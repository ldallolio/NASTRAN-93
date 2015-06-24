      SUBROUTINE SSG1A (N1,ILIST,NEDT,NTEMP,NCENT,CASECC,IHARM)        
C        
C     ROUTINE ANALIZES CASECC AND SLT TO BUILD LISTS OF SELECTED        
C     LOADS        
C        
      INTEGER         SYSTEM,SLT,BGPDT,CSTM,SIL,ECPT,MPT,GPTT,EDT,      
     1                CASECC,CORE(138),NAME(2),NAME1(2),ILIST(1),       
     2                IDEFML(1080),ITEMPL(1080),ICOMB(1080)        
      COMMON /LOADX / LC,SLT,BGPDT,OLD,CSTM,SIL,ISIL,ECPT,MPT,GPTT,EDT, 
     1                N(3),LODC,MASS,NOBLD        
      COMMON /BLANK / NROWSP,LOADNN        
      COMMON /SYSTEM/ SYSTEM,NOUT,DUM53(53),ITHERM        
CZZ   COMMON /ZZSSA1/ ICORE(1)        
      COMMON /ZZZZZZ/ ICORE(1)        
      EQUIVALENCE     (ICORE(1),CORE(1))        
      DATA    NAME  / 4HSSG1,4HA   /        
      DATA    NAME1 / 4HSLT ,4HSSG1/        
C        
C        
C     INITIALIZE.        
C        
      NEDT  = 0        
      NTEMP = 0        
      NCENT = 0        
      IFOUND= 0        
      N1    = 0        
      LC1   = LC - SYSTEM        
      ISLT  = 0        
      CALL OPEN (*20,SLT,CORE(LC1+1),0)        
      ISLT = 1        
      CALL READ (*320,*10,SLT,ILIST(1), -2,0,N1)        
      CALL READ (*320,*10,SLT,ILIST(1),LC1,1,N1)        
C        
C     ALLOW FOR 360 LOADS        
C        
   10 IF (N1 .LE. 360) GO TO 12        
      NAME(2) = N1        
      CALL MESAGE (-30,137,NAME)        
   12 LC1   = LC1 - SYSTEM        
      LLIST = N1        
   20 CALL OPEN (*350,CASECC,CORE(LC1+1),0)        
      IONE  = 0        
      DO 30 I = 1,LOADNN        
   30 CALL FWDREC (*350,CASECC)        
      IFRST = 0        
   40 CALL READ (*110,*350,CASECC,CORE(1),166,1,FLAG)        
      IF (IFRST .NE. 0) GO TO 41        
      IFRST = 1        
      ISPCN = CORE(3)        
      MPCN  = CORE(2)        
C        
C     TEST FOR SYMMETRY BUCKLING, OR DIFFERENTIAL STIFFNESS        
C        
   41 IF (CORE(16).NE.0 .OR. CORE(5).NE.0 .OR. CORE(138).NE.0) GO TO 40 
      IF (CORE(2).NE.MPCN .OR. CORE(3).NE.ISPCN) GO TO 110        
      IHARM  = CORE(136)        
      IONE   = 1        
      IF (CORE(6) .EQ. 0) GO TO 50        
C        
C     SEE IF EL DEFORM LOAD ALREADY APPLIED        
C        
      IF (NEDT .EQ. 0) GO TO 52        
      DO 51 I = 1,NEDT        
      IF (IDEFML(I) .EQ. CORE(6)) GO TO 50        
   51 CONTINUE        
C        
C     ADD TO LIST        
C        
   52 CONTINUE        
      NEDT = NEDT + 1        
      IDEFML(NEDT) = CORE(6)        
   50 IF (CORE(7) .EQ. 0) GO TO 60        
C        
C     SEE IF TEMP LOAD ALREADY APPLIED        
C        
      IF (ITHERM .NE. 0) GO TO 60        
      IF (NTEMP  .EQ. 0) GO TO 54        
      DO 53 I = 1,NTEMP        
      IF (ITEMPL(I) .EQ. CORE(7)) GO TO 60        
   53 CONTINUE        
   54 CONTINUE        
      NTEMP = NTEMP + 1        
      ITEMPL(NTEMP) = CORE(7)        
   60 IF (CORE(4) .EQ. 0) GO TO 40        
      IF (ISLT .EQ. 0) CALL MESAGE (-31,CORE(4),NAME1)        
      IF (N1   .EQ. 0) GO TO 90        
      DO 80 I = 1,N1        
      IF (CORE(4) .EQ. IABS(ILIST(I))) GO TO 100        
   80 CONTINUE        
C        
C     MUST LOOK AT LOAD CARDS        
C        
   90 IFOUND = IFOUND + 1        
      ICOMB(IFOUND) = CORE(4)        
      GO TO 40        
  100 ILIST (I) = -IABS(ILIST(I))        
      GO TO 40        
  110 CALL CLOSE (CASECC,1)        
      IF (IONE  .EQ. 0) GO TO 360        
      IF (NTEMP .EQ. 0) GO TO 130        
      DO 120 I = 1,NTEMP        
      J = N1 + I        
  120 ILIST(J) = ITEMPL (I)        
  130 IF(NEDT .EQ. 0) GO TO 150        
      DO 140 I = 1,NEDT        
      J = N1 + NTEMP + I        
  140 ILIST(J) = IDEFML(I)        
  150 IF (IFOUND .EQ. 0) GO TO 270        
C        
C     LOOK AT LOAD CARDS        
C        
      DO 180 I = 1,N1        
      CALL FWDREC (*320,SLT)        
  180 CONTINUE        
      I = 1        
      NOGO = 0        
      CALL READ (*370,*190,SLT,CORE(1),LC1,1,IFLAG)        
  190 LLIST = N1 + NEDT + NTEMP        
      IF (LLIST .EQ. 0) GO TO 370        
      DO 260 I = 1,IFOUND        
      J = 1        
  200 IF (ICOMB(I) .EQ. CORE(J)) GO TO 220        
      J = J + 6        
  210 IF (J-1 .GT. IFLAG) GO TO 255        
      IF (CORE(J-1) .EQ. -1) GO TO 200        
      J = J + 2        
      GO TO 210        
  220 J = J + 3        
  230 IF (CORE(J) .EQ. -1) GO TO 260        
      DO 250 K = 1,LLIST        
      IF (CORE(J) .NE. IABS(ILIST(K))) GO TO 250        
      ILIST(K) = -IABS(ILIST(K))        
      J = J + 2        
      GO TO 230        
  250 CONTINUE        
  255 CALL MESAGE (31,ICOMB(I),NAME1)        
      NOGO = 1        
  260 CONTINUE        
      IF (NOGO .NE. 0) GO TO 390        
  270 IF (ISLT .NE. 0) CALL CLOSE (SLT,1)        
      IF (N1 .EQ. 0) GO TO 310        
      DO 300 I = 1,N1        
      IF (ILIST (I)) 290,300,280        
  280 ILIST (I) = 0        
      GO TO 300        
  290 ILIST (I) = -ILIST(I)        
  300 CONTINUE        
  310 RETURN        
C        
C     ERROR MESSAGES.        
C        
  320 IP1 = SLT        
  330 IP2 = -1        
      CALL MESAGE (IP2,IP1,NAME)        
  350 IP1 = CASECC        
      GO TO 330        
  360 WRITE  (NOUT,365)        
  365 FORMAT ('0*** MISSING LOAD CARD IN CASE CONTROL')        
      CALL MESAGE (-7,0,NAME)        
  370 IP2 = 31        
      DO 380 I = 1,IFOUND        
      IP1 = ICOMB(I)        
      CALL MESAGE (IP2,IP1,NAME1)        
  380 CONTINUE        
  390 CALL MESAGE (-61,0,NAME)        
      RETURN        
C        
      END        
