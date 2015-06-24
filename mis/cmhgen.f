      SUBROUTINE CMHGEN        
C        
C     THIS SUBROUTINE GENERATES THE (H) TRANSFORMATION MATRICES FOR     
C     COMPONENT SUBSTRUCTURES IN A COMBINE OPERATION AND WRITES THEM    
C     ON THE SOF        
C        
      LOGICAL         FRSFIL        
      INTEGER         BUFEX,SCR1,MCB(7),IHEAD(2),NAM(2),SCR3,BUF1,      
     1                CNAM,COMBO,Z,SSIL,LCORE,SCORE,SCSFIL,BUF2,BUF3,   
     2                SCBDAT,SCCONN,LISTO(32),LISTN(32),AAA(2),BUF4,    
     3                CE(10)        
      DIMENSION       T(6,6),TP(6,6),TPP(6,6),COLOUT(6),TID(6,6),       
     1                TTRAN(6,6)        
      COMMON /CMB001/ SCR1,SCR2,SCBDAT,SCSFIL,SCCONN,SCMCON,SCTOC,      
     1                GEOM4,CASECC,SCCSTM,SCR3        
      COMMON /CMB002/ BUF1,BUF2,BUF3,BUF4,BUF5,SCORE,LCORE,INPT,OUTT    
      COMMON /CMB003/ COMBO(7,5),CONSET,IAUTO,TOLER,NPSUB        
      COMMON /CMB004/ TDAT(6),NIPNEW,CNAM(2)        
CZZ   COMMON /ZZCOMB/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /PACKX / IIN,IOUT,IIII,NNNN,INCR        
      DATA    ZERO  / 0.0 /,AAA/ 4HCMHG,4HEN   /,IHEAD/ 4HHORG,4H    /  
      DATA    TID   / 1.,0.,0.,0.,0.,0., 0.,1.,0.,0.,0.,0.,        
     1                0.,0.,1.,0.,0.,0., 0.,0.,0.,1.,0.,0.,        
     2                0.,0.,0.,0.,1.,0., 0.,0.,0.,0.,0.,1. /        
      DATA    NHEQSS/ 4HEQSS   /        
C        
C     READ SIL,C FROM SOF FOR COMBINED STRUCTURE        
C        
      INCR  = 1        
      BUFEX = LCORE - BUF2 + BUF3        
      LCORE = BUFEX - 1        
      IF (LCORE .LT. 0) GO TO 320        
      IOEFIL = 310        
      CALL OPEN (*300,IOEFIL,Z(BUFEX),0)        
      MCB(1) = SCR1        
      MCB(4) = 2        
      MCB(5) = 1        
      IIN    = 1        
      IOUT   = 1        
      CALL SFETCH (CNAM,NHEQSS,1,ITEST)        
      NSUB = 0        
      DO 10 I = 1,NPSUB        
      NSUB = NSUB + COMBO(I,5)        
   10 CONTINUE        
      CALL SJUMP (NSUB+1)        
      CALL SUREAD (Z(SCORE),-1,NSILNW,ITEST)        
C        
C     LOOP ON NUMBER OF PSEUDO-STRUCTURES BEING COMBINED        
C        
      SSIL  = SCORE + NSILNW        
      LCORE = LCORE - NSILNW        
      IFILE = SCR3        
      CALL OPEN (*300,SCR3,Z(BUF1),0)        
      IFILE = SCSFIL        
      CALL OPEN (*300,SCSFIL,Z(BUF2),0)        
C        
      DO 260 I = 1,NPSUB        
      FRSFIL = .TRUE.        
      MCB(2) = 0        
      MCB(6) = 0        
      MCB(7) = 0        
C        
C     READ SIL,C FOR COMPONENT SUBSTRUCTURE        
C        
      NCS = COMBO(I,5) + 2        
      DO 20 J = 1,NCS        
      CALL FWDREC (*310,SCSFIL)        
   20 CONTINUE        
      IFILE = IOEFIL        
      CALL READ (*310,*30,IOEFIL,Z(SSIL),LCORE,1,NSLOLD)        
      GO TO 320        
   30 ISHPTR = SSIL + NSLOLD        
      IFILE  = SCSFIL        
      CALL READ (*310,*40,SCSFIL,Z(ISHPTR),LCORE,1,LHPTR)        
      GO TO 320        
   40 CALL SKPFIL (SCSFIL,1)        
C        
C     COMPUTE NUMBER OF ROWS IN MATRIX        
C        
      ICODE = Z(SSIL+NSLOLD-1)        
      CALL DECODE (ICODE, LISTO, NCOM)        
      MCB(3) = Z(SSIL+NSLOLD-2) + NCOM - 1        
C        
C     READ CONNECTION ENTRIES        
C        
C     READ TRANSFORMATION MATRIX FOR PSEUDOSTRUCTURE        
C        
      IFILE = SCR3        
      CALL READ (*310,*50,SCR3,TTRAN,37,1,NNN)        
   50 CONTINUE        
      CALL SKPFIL (SCR3,-1)        
      IF (I .NE. 1) CALL SKPFIL (SCR3,1)        
      IFILE = SCCONN        
      CALL OPEN (*300,SCCONN,Z(BUF3),0)        
      IFILE = SCR1        
      CALL OPEN (*300,SCR1,Z(BUF4),1)        
      CALL WRITE (SCR1,IHEAD,2,1)        
      IPNEW = 0        
   60 CALL READ (*250,*70,SCCONN,CE,10,1,NNN)        
   70 IPNEW  = IPNEW + 1        
      LOCIPN = SCORE + 2*(IPNEW-1) + 1        
      IF (CE(I+2) .EQ. 0) GO TO 230        
      IPOLD  = CE(I+2)        
      LOCIPO = SSIL + 2*(IPOLD-1) + 1        
      ICODE  = Z(LOCIPN)        
      CALL DECODE (ICODE,LISTN,NCN)        
      ICODE  = Z(LOCIPO)        
      CALL DECODE (ICODE,LISTO,NCO)        
C        
      IADDH = ISHPTR + IPOLD - 1        
      IDH   = Z(IADDH)        
      IF (IDH-1) 80,100,120        
C        
C     IDENTITY MATRIX        
C        
   80 CONTINUE        
      DO 90 I1 = 1,6        
      DO 90 I2 = 1,6        
      T(I1,I2) = TID(I1,I2)        
   90 CONTINUE        
      GO TO 160        
C        
C     TRANS MATRIX        
C        
  100 CONTINUE        
      DO 110 I1 = 1,6        
      DO 110 I2 = 1,6        
      T(I1,I2) = TTRAN(I1,I2)        
  110 CONTINUE        
      GO TO 160        
C        
C     MATRIX DUE TO GTRAN        
C        
  120 CONTINUE        
      IDHM1 = IDH - 1        
      DO 130 I1 = 1,IDHM1        
      CALL FWDREC (*310,SCR3)        
  130 CONTINUE        
      CALL READ (*310,*140,SCR3,T,37,1,NNN)        
  140 DO 150 I1 = 1,IDH        
      CALL BCKREC (SCR3)        
  150 CONTINUE        
  160 CONTINUE        
C        
C     DELETE ROWS OF (T) FOR EACH COLD EQUAL TO ZERO        
C        
      DO 180 J1 = 1,NCO        
      IR = LISTO(J1) + 1        
      DO 170 J2 = 1,6        
      TP(J1,J2) = T(IR,J2)        
  170 CONTINUE        
  180 CONTINUE        
      NROW = NCO        
C        
C     DELETE COLUMNS OF (T) FOR EACH CNEW EQUAL TO ZERO        
C        
      DO 200 J1 = 1,NCN        
      IC = LISTN(J1) + 1        
      DO 190 J2 = 1,NROW        
      TPP(J2,J1) = TP(J2,IC)        
  190 CONTINUE        
  200 CONTINUE        
      NCOL = NCN        
      DO 220 I1 = 1,NCOL        
      DO 210 I2 = 1,NROW        
      COLOUT(I2) = TPP(I2,I1)        
  210 CONTINUE        
      IIII = Z(LOCIPO-1)        
      NNNN = IIII + NROW - 1        
      CALL PACK (COLOUT,SCR1,MCB)        
  220 CONTINUE        
      GO TO 60        
  230 IIII = 1        
      NNNN = 1        
      ICODE = Z(LOCIPN)        
      CALL DECODE (ICODE,LISTN,NCN)        
      DO 240 I1 = 1,NCN        
      CALL PACK (ZERO,SCR1,MCB)        
  240 CONTINUE        
      GO TO 60        
  250 CONTINUE        
      CALL CLOSE (SCCONN,1)        
      CALL WRTTRL (MCB)        
      CALL CLOSE (SCR1,1)        
      NAM(1) = COMBO(I,1)        
      NAM(2) = COMBO(I,2)        
      CALL MTRXO (SCR1,NAM,IHEAD(1),Z(BUF4),ITEST)        
      CALL SKPFIL (SCR3,1)        
  260 CONTINUE        
C        
      CALL CLOSE (SCSFIL,1)        
      CALL CLOSE (SCR3,1)        
      CALL CLOSE (IOEFIL,1)        
      LCORE = BUFEX + BUF2 - BUF3        
      RETURN        
C        
  300 IMSG = -1        
      GO TO 330        
  310 IMSG = -2        
      GO TO 330        
  320 IMSG = -8        
  330 CALL MESAGE (IMSG,IFILE,AAA)        
      RETURN        
      END        
