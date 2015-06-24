      SUBROUTINE CMAUTO        
C        
C     THIS SUBROUTINE PROCESSES THE AUTOMATIC CONNECTION OF        
C     SUBSTRUCTURES IN THE COMB1 MODULE        
C        
      EXTERNAL        RSHIFT,ANDF        
      LOGICAL         PRINT,FOUND,TDAT,BACK,IAUTO        
      INTEGER         SCSFIL,SCCONN,BUF1,BUF2,SNEXT(8),ST,NWD(8),SCORE, 
     1                Z,SPK,SNK,CE(9),SVKK,ANDF,AAA(2),SSIL(8),NSIL(8), 
     2                STS,COMBO,RESTCT,OUTT,NAME(14),RSHIFT,IHD(12),    
     3                IBITS(2),JBITS(2)        
      DIMENSION       RZ(1),A(3),B(3)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /CMB001/ SCR1,SCR2,SCBDAT,SCSFIL,SCCONN,SCMCON,SCTOC,      
     1                GEOM4,CASECC        
      COMMON /CMB002/ BUF1,BUF2,BUF3,BUF4,BUF5,SCORE,LCORE,INPT,OUTT    
      COMMON /CMB003/ COMBO(7,5),CONSET,IAUTO,TOLER,NPSUB,CONECT,TRAN,  
     1                MCON,RESTCT(7,7),ISORT,ORIGIN(7,3),IPRINT        
      COMMON /CMB004/ TDAT(6)        
CZZ   COMMON /ZZCOMB/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /BLANK / STEP,IDRY        
      COMMON /OUTPUT/ ITITL(96),IHEAD(96)        
      COMMON /SYSTEM/ XXX,IOT,JUNK(6),NLPP,JUNK1(2),LINE,JUNK2(2),      
     1                IDAT(3),JUNK7(7),ISW        
      EQUIVALENCE     (Z(1),RZ(1))        
      DATA    AAA   / 4HCMAU, 2HTO /, IBLNK / 4H    /        
      DATA    IHD   / 4H SUM, 4HMARY, 4H OF , 4H AUT, 4HOMAT, 4HICAL,   
     1                4HLY G, 4HENER, 4HATED, 4H CON, 4HNECT, 4HIONS/   
C        
      NLIN  = 1000        
      FOUND = .FALSE.        
      PRINT = .FALSE.        
      IF (ANDF(RSHIFT(IPRINT,10),1) .EQ. 1) PRINT = .TRUE.        
      NP2 = 2*NPSUB        
      DO 10 I = 1,NP2,2        
      J = I/2 + 1        
      NAME(I  ) = COMBO(J,1)        
      NAME(I+1) = COMBO(J,2)        
   10 CONTINUE        
      DO 20 I = 1,96        
      IHEAD(I) = IBLNK        
   20 CONTINUE        
      J = 1        
      DO 30 I = 75,86        
      IHEAD(I) = IHD(J)        
   30 J = J + 1        
      ISAVS = SCORE        
      ISAVL = LCORE        
      IFILE = SCCONN        
      CALL OPEN (*310,SCCONN,Z(BUF2),3)        
      IF (IAUTO) GO TO 40        
      CALL CLOSE (SCCONN,1)        
      RETURN        
C        
   40 IFILE = SCSFIL        
      CALL OPEN (*310,SCSFIL,Z(BUF1),0)        
      SSIL(1) = SCORE        
      NOUT = NPSUB + 2        
      IDIR = ISORT + 1        
      DO 110 I = 1,NPSUB        
      STS = SSIL(I)        
      NCSUB = COMBO(I,5)        
      DO 50 J = 1,NCSUB        
      CALL FWDREC (*320,SCSFIL)        
   50 CONTINUE        
C        
C     READ SIL,C FOR THE I-TH PSEUDOSTRUCTURE        
C        
      CALL READ (*320,*60,SCSFIL,Z(STS),LCORE,1,NSIL(I))        
      GO TO 330        
   60 LCORE = LCORE - NSIL(I)        
      SNEXT(I) = SCORE + NSIL(I)        
      SCORE = SCORE + NSIL(I)        
      ST = SNEXT(I)        
C        
C     READ BGSS FOR THE I-TH PSEUDOSTRUCTURE        
C        
      CALL READ (*320,*70,SCSFIL,Z(ST),LCORE,1,NWD(I))        
      GO TO 330        
   70 SNEXT(I+1) = SNEXT(I) + NWD(I)        
      SSIL(I+1)  = SNEXT(I) + NWD(I)        
      SCORE = SCORE + NWD(I)        
      CALL SKPFIL (SCSFIL,1)        
      LCORE = LCORE - NWD(I)        
      NI = NWD(I) + ST        
C        
C     WRITE THE IP NUMBER OVER THE CID IN THE BGSS        
C     WILL BE USED AFTER SORTING        
C        
      DO 100 J = ST,NI,4        
      JJ = (J-ST+4)/4        
      IF (Z(J)+1) 80,90,80        
   80 Z(J) = JJ        
      GO TO 100        
   90 Z(J) = -JJ        
  100 CONTINUE        
  110 CONTINUE        
C        
C     SORT EACH BGSS IN THE SPECIFIED COORDINATE DIRECTION        
C        
      DO 120 I = 1,NPSUB        
      ST = SNEXT(I)        
      CALL SORTF (0,0,4,IDIR,RZ(ST),NWD(I))        
  120 CONTINUE        
      I    = 1        
  130 K    = 0        
      KK   = 0        
      BACK = .FALSE.        
      SVKK = 0        
      IC1  = SSIL(I)        
      NIPI = NWD(I)/4        
      J    = I + 1        
      IF (RESTCT(I,J) .NE. 1) GO TO 280        
  140 IC2  = SSIL(J)        
      NIPJ = NWD(J)/4        
  150 SPK  = SNEXT(I) + K + 1        
      IF (Z(SPK-1) .LT. 0) GO TO 260        
      A(1) = RZ(SPK  )        
      A(2) = RZ(SPK+1)        
      A(3) = RZ(SPK+2)        
  160 SNK  = SNEXT(J) + KK + 1        
      IF (Z(SNK-1) .LT. 0) GO TO 270        
      B(1) = RZ(SNK  )        
      B(2) = RZ(SNK+1)        
      B(3) = RZ(SNK+2)        
      IF (A(ISORT) .LT. B(ISORT)-TOLER) GO TO 250        
      IF (B(ISORT) .LT. A(ISORT)-TOLER) GO TO 270        
      IF (BACK) GO TO 170        
      BACK = .TRUE.        
      SVKK = KK        
  170 CONTINUE        
      ASEJ = A(ISORT)        
      BSEJ = B(ISORT)        
      XSEJ = ASEJ - BSEJ        
      DO 180 MM = 1,3        
      IF (MM .EQ. ISORT) GO TO 180        
      ASEJ = A(MM)        
      BSEJ = B(MM)        
      XSEJ = A(MM) - B(MM)        
      IF (ABS(XSEJ) .GT. TOLER) GO TO 270        
  180 CONTINUE        
C        
C     GENERATE THE NEW CONNECTION ENTRY        
C        
      DO 190 KDH = 1,9        
  190 CE(KDH) = 0        
      CE(2)   = 2**(I-1) + 2**(J-1)        
      CE(2+I) = IABS(Z(SPK-1))        
      CE(2+J) = IABS(Z(SNK-1))        
      M1 = IABS(Z(SPK-1))        
      M2 = IABS(Z(SNK-1))        
      CE(1) = ANDF(Z(IC1+2*M1-1),Z(IC2+2*M2-1))        
      FOUND = .TRUE.        
C        
C     WRITE THE CONNECTION ENTRY ON SCCONN        
C        
      IF (CE(1) .NE. 0) CALL WRITE (SCCONN,CE,NOUT,1)        
      IF (  .NOT.PRINT) GO TO 240        
      IF (CE(1) .EQ. 0) GO TO 240        
      IF (NLIN .LT. NLPP) GO TO 220        
  200 NLIN = 0        
      CALL PAGE        
      WRITE  (OUTT,210) (NAME(KDH),KDH=1,NP2)        
  210 FORMAT (/14X,22HCONNECTED   CONNECTION,29X,22HPSEUDOSTRUCTURE  NAM
     1ES, /17X,3HDOF,9X,4HCODE,3X,7(3X,2A4)//)        
      NLIN = NLIN + 10        
  220 CALL BITPAT (CE(1),IBITS)        
      CALL BITPAT (CE(2),JBITS)        
      NLIN = NLIN + 1        
      IF (NLIN .GT. NLPP) GO TO 200        
      WRITE (OUTT,230) IBITS(1),IBITS(2),JBITS(1),JBITS(2),        
     1                 (CE(KDH+2),KDH=1,NPSUB)        
  230 FORMAT (16X,A4,A2,5X,A4,A3,2X,7(3X,I8))        
  240 CONTINUE        
      GO TO 270        
  250 KK   = SVKK        
      BACK = .FALSE.        
  260 K    = K + 4        
      IF (K/4 .LT. NIPI) GO TO 150        
      K    = 0        
      KK   = 0        
      SVKK = 0        
      BACK = .FALSE.        
      GO TO 280        
  270 KK = KK + 4        
      IF (KK/4 .LT. NIPJ) GO TO 160        
      GO TO 250        
  280 J = J + 1        
      IF (J .LE. NPSUB) GO TO 140        
      I = I + 1        
      J = I        
      IF (I .LT. NPSUB) GO TO 130        
      WRITE  (OUTT,290)        
  290 FORMAT (//40X,'NOTE - GRID POINTS IN PSEUDOSTRUCTURE INTERNAL',   
     1                  ' GRID NUMBERS')        
      CALL CLOSE (SCCONN,1)        
      CALL CLOSE (SCSFIL,1)        
      SCORE = ISAVS        
      LCORE = ISAVL        
      IF (FOUND .OR. TDAT(1).OR.TDAT(2)) RETURN        
C        
      WRITE  (OUTT,300) UFM        
  300 FORMAT (A23,' 6531, NO CONNECTIONS HAVE BEEN FOUND DURING ',      
     1       'AUTOMATIC CONNECTION PROCEDURE.')        
      IDRY = -2        
      RETURN        
C        
  310 IMSG = -1        
      GO TO 350        
  320 IMSG = -2        
      GO TO 350        
  330 IMSG = -8        
  350 CALL MESAGE (IMSG,IFILE,AAA)        
      RETURN        
      END        
