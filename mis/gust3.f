      SUBROUTINE GUST3 (QHJK,WJ,PP,GUSTL,PDEL,PGUST,Q,NFREQ,NLOAD,      
     1                  NROWJ,NCOLW)        
C        
C     THE PURPOSE OF THIS ROUTINE IS TO MULTIPLY QHJK(+) BY WJ        
C     FORMING PDEL        
C     PDEL IS THEN MULTIPLIED BY  Q*WG*PP(W)  FORMING PGUST        
C        
      INTEGER         QHJK,WJ,PP,GUSTL,PDEL,PGUST,IZ(1),SYSBUF,MCB(7),  
     1                NAME(2)        
      COMMON /PACKX / ITC1,ITC2,II1,JJ1,INCR1        
      COMMON /UNPAKX/ ITC,II,JJ,INCR        
      COMMON /SYSTEM/ SYSBUF        
CZZ   COMMON /ZZGUST/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (IZ(1),Z(1))        
      DATA    NAME  / 4HGUST,1H3 /        
C        
C     INITIALIZE        
C        
      IBUF1 = KORSZ(IZ)- SYSBUF+1        
      IBUF2 = IBUF1- SYSBUF        
      IBUF3 = IBUF2- SYSBUF        
      INCR1 = 1        
      INCR  = 1        
      IBUF4 = IBUF3- SYSBUF        
      MCB(1)= QHJK        
      CALL RDTRL(MCB)        
      ITC  = 3        
      ITC1 = ITC        
      ITC2 = ITC        
      CALL GOPEN (WJ,IZ(IBUF1),0)        
      CALL GOPEN (QHJK,IZ(IBUF2),0)        
      CALL GOPEN (PDEL,IZ(IBUF3),1)        
C        
C     SET UP TO PACK        
C        
      IT1 = 1        
      JJ1 = MCB(3) / NROWJ        
      NRQHJ = MCB(3)        
      NTQHJ = NRQHJ*2        
      CALL MAKMCB (MCB,PDEL,JJ1,2,ITC2)        
      II   = 1        
      IQHJ = 2*NFREQ+1        
      IWJ  = IQHJ+NTQHJ        
      NTWZ = NROWJ*2        
      IPDEL= IWJ + NTWZ        
      NTPDEL = JJ1*2        
      NZ = IBUF4-1 - IPDEL + 2*JJ1        
      IF (NZ  .LT. 0) CALL MESAGE (-8,0,NAME)        
      DO 100 I = 1,NFREQ        
      JJ = NRQHJ        
      CALL UNPACK (*10,QHJK,Z(IQHJ))        
C        
C     MULTIPY EACH IMAGINARY PART BY K        
C        
      DO 5 J = 1,NTQHJ,2        
      Z(IQHJ+J) = Z(IQHJ+J)*Z(2*I)        
   5  CONTINUE        
      GO TO 20        
C        
C     NULL COLUMN        
C        
   10 CALL ZEROC (Z(IQHJ),NTQHJ)        
   20 CONTINUE        
C        
C     BRING WJ COLUMN INTO CORE        
C        
      JJ = NROWJ        
      CALL UNPACK (*30,WJ,Z(IWJ))        
      GO TO 40        
   30 CALL ZEROC (Z(IWJ),NTWZ)        
   40 CONTINUE        
C        
C     MULTIPLY        
C        
      CALL GMMATC (Z(IQHJ),JJ1,NROWJ,0,Z(IWJ),NROWJ,1,0,Z(IPDEL))       
      CALL PACK (Z(IPDEL),PDEL,MCB)        
  100 CONTINUE        
      CALL CLOSE (WJ,1)        
      CALL CLOSE (QHJK,1)        
      CALL CLOSE (PDEL,1)        
      CALL WRTTRL (MCB)        
      CALL DMPFIL (-PDEL,Z,NZ)        
C        
C     REPEATEDLY READ PDEL MULTIPLYING BY Q,WG, AND PP        
C        
      CALL GOPEN (PDEL,IZ(IBUF1),0)        
      CALL GOPEN (PP,IZ(IBUF2),0)        
      CALL GOPEN (GUSTL,IZ(IBUF3),0)        
      CALL GOPEN (PGUST,IZ(IBUF4),1)        
      CALL MAKMCB (MCB,PGUST,MCB(3),MCB(4),MCB(5))        
      DO 400 I = 1,NLOAD        
      CALL REWIND (PDEL)        
      CALL SKPREC (PDEL,1)        
      CALL FREAD (GUSTL,IZ,5,1)        
      IZ2 = 2        
      QWG = Q*Z(IZ2+1)        
      DO 300 J = 1,NFREQ        
      JJ = 1        
      CALL UNPACK (*310,PP,Z)        
      QWGR = QWG * Z(1)        
      QWGC = QWG * Z(IZ2)        
      GO TO 320        
  310 CONTINUE        
      QWGR = 0.0        
      QWGC = 0.0        
  320 CONTINUE        
      JJ = JJ1        
      CALL UNPACK (*330,PDEL,Z)        
      GO TO 340        
  330 CALL ZEROC (Z,NTPDEL)        
  340 CONTINUE        
      DO 350 M = 1,NTPDEL,2        
      PGR = QWGR*Z(M  ) - QWGC*Z(M+1)        
      PGC = QWGR*Z(M+1) + QWGC*Z(M  )        
      Z(M  ) = PGR        
      Z(M+1) = PGC        
  350 CONTINUE        
      CALL PACK (Z,PGUST,MCB)        
  300 CONTINUE        
  400 CONTINUE        
      CALL CLOSE (PDEL,1)        
      CALL CLOSE (PP,1)        
      CALL CLOSE (GUSTL,1)        
      CALL CLOSE (PGUST,1)        
      CALL WRTTRL (MCB)        
      RETURN        
      END        
