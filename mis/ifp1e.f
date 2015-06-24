      SUBROUTINE IFP1E (ISUBC,SYMSEQ,NWDSC,I81,ICASTE)        
C        
C     IFP1E WRITES CASECC OUT FROM CASE        
C        
      LOGICAL         BIT64        
      INTEGER         ISUBC(5),CASE(200,2),BLANK,CASECC,SYMSEQ(1),      
     1                CORE(1),COREY(401)        
CZZ   COMMON /ZZIFP1/ COREX(1)        
      COMMON /ZZZZZZ/ COREX(1)        
      COMMON /XIFP1 / BLANK,BIT64        
      COMMON /IFP1A / SCR1,CASECC,IS,NWPC,NCPW4,NMODES,ICC,NSET,        
     1                NSYM,ZZZZBB,ISTR,ISUB,LENCC,IBEN,EQUAL,IEOR       
      EQUIVALENCE    (COREX(1),COREY(1),CASE(1,1)),(CORE(1),COREY(401)) 
      DATA    NONE  / 4HNONE/        
C        
C     INITIALIZE        
C        
C        
C     SKIP FILTER INTO SUBCASES FOR SYM SUBCASES        
C        
      DO 1100 I = 1,16        
      IF (CASE(I,2) .EQ. 0) CASE(I,2) = CASE(I,1)        
 1100 CONTINUE        
      IF (CASE(38,2) .EQ. 0) CASE(38,2) = CASE(38,1)        
      IF (NSYM.GT.1 .AND. CASE(16,2).EQ.0) GO TO 1140        
      DO 1130 I = 1,7        
      IK = (I-1)*3 + 17        
      IF (CASE(IK,2) .NE. 0) GO TO 1125        
      DO 1120 J = 1,3        
      II = IK + J - 1        
 1120 CASE(II,2) = CASE(II,1)        
 1125 IWORD = CASE(IK,2)        
      IF (BIT64) CALL MVBITS (BLANK,0,32,IWORD,0)        
      IF (IWORD .EQ. NONE) CASE(IK,2) = 0                               
 1130 CONTINUE        
 1140 DO 1170 J = 1,3        
      DO 1150 I = 1,32        
      K = 32*J + I + 6        
      IWORD = CASE(K,2)        
      IF (BIT64) CALL MVBITS (BLANK,0,32,IWORD,0)        
      IF (IWORD .NE. BLANK) GO TO 1170        
 1150 CONTINUE        
      DO 1160 I = 1,32        
      K = 32*J + I + 6        
 1160 CASE(K,2) = CASE(K,1)        
 1170 CONTINUE        
      J = 129        
      DO 1171 I = 1,5        
      CASE(J,2) = ISUBC(I)        
      J = J + 1        
 1171 CONTINUE        
      DO 1180 I = 135,LENCC        
      IF (CASE(I,2) .EQ. 0) CASE(I,2) = CASE(I,1)        
 1180 CONTINUE        
C     IMOV = CASE(136,2)*100000000  !! VAX/IBM INTGER OVERFLOW FOR ANOMA
      IMOV = CASE(136,2)        
      IF (IMOV .LT. 0) IMOV = 0        
      IMOV = IMOV*100000000        
      CASE(136,2) = IABS(CASE(136,2))        
      CASE(2,2) = CASE(2,2) + IMOV        
      CASE(3,2) = CASE(3,2) + IMOV        
      IF (CASE(7,2) .NE. 0) CASE(7,2) = CASE(7,2) + IMOV        
      IF (CASE(8,2) .NE. 0) CASE(8,2) = CASE(8,2) + IMOV        
      ICASTE = CASE(8,2)        
      DO 1220 ILOOP = 1,NMODES        
      IF (CASE(1,2) .GT. 99999999) CALL IFP1D (-625)        
C        
C     CHECK FOR METHOD AND LOAD IN SAME SUBCASE        
C        
      IF (CASE(5,2).NE.0 .AND. CASE(4,2)+CASE(6,2)+CASE(7,2).NE.0)      
     1    CALL IFP1D (-627)        
      IF (CASE(4,2).EQ.CASE(6,2) .AND. CASE(4,2).NE.0 .OR.        
     1    CASE(6,2).EQ.CASE(7,2) .AND. CASE(6,2).NE.0 .OR.        
     2    CASE(4,2).EQ.CASE(7,2) .AND. CASE(4,2).NE.0) CALL IFP1D (-628)
      CALL WRITE (CASECC,CASE(1,2),LENCC,0)        
      CASE(1,2) = CASE(1,2) + 1        
      IF (CASE(16,2) .LE. 0) GO TO 1200        
      IDO = CASE(LENCC,2)        
      CALL WRITE (CASECC,SYMSEQ(1),IDO,0)        
 1200 IF (NSET .EQ. 0) GO TO 1220        
      IP = NWDSC + 1        
      DO 1210 I = 1,NSET        
      NWOR = CORE(IP)        
      CALL WRITE (CASECC,CORE(IP-1),   2,0)        
      CALL WRITE (CASECC,CORE(IP+2),NWOR,0)        
      IP = IP + NWOR + 3        
 1210 CONTINUE        
 1220 CALL WRITE (CASECC,CORE(1),0,1)        
      NMODES = 1        
      IF (NSET .EQ. 0) GO TO 1270        
C        
C     REMOVE ALL SETS REFERING TO SUBCASE ONLY        
C        
      IUP  = NWDSC        
      IP   = NWDSC        
      NSET1= NSET        
      IMOV = 0        
      DO 1260 I = 1,NSET        
      IF (CORE(IP+2) .NE. 1) GO TO 1250        
      IF (IMOV       .EQ. 0) GO TO 1240        
      IDO = CORE(IP+1) + 3        
      DO 1230 J = 1,IDO        
      II = IUP + J - 1        
      IK = IP  + J - 1        
 1230 CORE(II) = CORE(IK)        
 1240 IUP = IUP+CORE(IP+1) + 3        
      IP  = IP +CORE(IP+1) + 3        
      GO TO 1260        
 1250 IMOV = 1        
      NSET1= NSET1 - 1        
      IP   = IP + CORE(IP+1) + 3        
 1260 CONTINUE        
      NSET = NSET1        
      I81  = IUP        
 1270 CONTINUE        
      DO 1280 I = 1,LENCC        
      CASE(I,2) = 0        
      IF (I.GT.38 .AND. I.LT.135) CASE(I,2) = BLANK        
 1280 CONTINUE        
      CALL IFP1F (*1281,IWORD,I2)        
      DO 1282 I = 1,5        
      ISUBC(I) = CORE(I2)        
      I2 = I2 + 1        
 1282 CONTINUE        
 1281 RETURN        
      END        
