      SUBROUTINE FDVECT (DELTA,PK)        
C        
      INTEGER          SYSBUF,ICORE(1),MCB(7)        
C    1,                NAME(2)        
      DOUBLE PRECISION DCORE(1),DMAX,PK        
      COMMON /SYSTEM/  KSYSTM(65)        
CZZ   COMMON /ZZDETX/  CORE(1)        
      COMMON /ZZZZZZ/  CORE(1)        
      COMMON /REGEAN/  IA(14),IVECT(7),IB(5),LC1,IB1(9),LOADS,LX,ICOUNT,
     1                 LAMA,IBUCK,NSYM        
      COMMON /PACKX /  IT1P,IT2P,IIP,JJP,INCRP        
      EQUIVALENCE      (ICORE(1),CORE(1),DCORE(1)),        
     1                 (KSYSTM(1),SYSBUF),(KSYSTM(55),IPREC)        
C     DATA    NAME  /  4HFDVE,4HCT  /        
C        
      NPROB = IA(3)        
      KPREC = IA(5)        
      IF (KPREC.NE.1 .AND. KPREC.NE.2) KPREC = IPREC        
      NPRO2 = NPROB        
      ICNT  = IVECT(2)        
      IM1   = 1        
      LCORE = (KORSZ(CORE)/2)*2 - LC1 - SYSBUF        
      X     = NPROB        
      Y     = ICOUNT        
      MCB(1)= IB(5)        
      CALL RDTRL (MCB(1))        
C        
      CALL DETFBS (NPRO2+1,ICORE(LCORE+1),MCB,NPROB,ICOUNT)        
C        
C     COPY FX ONTO IVECT + NORMALIZE        
C        
      IPM1 = IVECT(1)        
      IF (ICNT .EQ. 0) GO TO 40        
      CALL GOPEN (IVECT(1),ICORE(LCORE+1),0)        
      CALL SKPREC (IVECT(1),ICNT)        
      CALL CLOSE (IVECT(1),2)        
      IM1 = 3        
   40 CALL GOPEN (IVECT,ICORE(LCORE+1),IM1)        
      LCORE = LCORE - SYSBUF        
      IF (KPREC .EQ. 2) GO TO 71        
      XMAX = 0.0        
      DO 60  I = 1, NPROB        
   60 XMAX = AMAX1(XMAX,ABS(CORE(I)))        
      DO 70 I = 1,NPROB        
   70 CORE(I) = CORE(I)/XMAX        
      GO TO 73        
   71 DMAX = 0.0D0        
      DO 69 I = 1,NPROB        
      IF (DABS(DCORE(I)) .GT. DMAX) DMAX = DABS(DCORE(I))        
   69 CONTINUE        
      DO 72 I = 1,NPROB        
   72 DCORE(I) = DCORE(I)/DMAX        
   73 CONTINUE        
      IT1P = KPREC        
      IT2P = IPREC        
      IIP  = 1        
      JJP  = NPROB        
      INCRP = 1        
      CALL PACK (CORE,IVECT,IVECT)        
      CALL CLOSE (IVECT(1),1)        
      IPM1 = LAMA        
      CALL GOPEN (LAMA,ICORE(LCORE+1),3)        
      DCORE(1) = PK        
      CALL WRITE (LAMA,CORE,IPREC,1)        
      CALL CLOSE (LAMA,2)        
      RETURN        
      END        
