      SUBROUTINE GIGTKA(MULTI,SINGLE,OMIT)        
C        
      LOGICAL MULTI,SINGLE,OMIT        
      INTEGER CORE,USET1,GM,GO,GKA,GKG,GKNB,GKM,SCR1,GKAB,GKF,        
     *        GKS,GKO,USETA,GKN        
      INTEGER  UM,UO,UR,USG,USB,UL,UA,UF,US,UN,UG        
C        
      COMMON /PATX/  LC,N,NO,NY,USET1,IBC        
      COMMON /BITPOS/ UM,UO,UR,USG,USB,UL,UA,UF,US,UN,UG        
CZZ   COMMON /ZZSSA2/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON/GICOM/ SPLINE,USETA,CSTM,BGPT,SILA,EQAERO,GM,GO,GKA,       
     *              KSIZE,GSIZE,SCR1,GKG,GKNB,GKM,GKAB        
C        
C-----------------------------------------------------------------------
C        
      LC = KORSZ(CORE)        
      GKF = GKNB        
      GKS = GKM        
      GKO = GKS        
      USET1 = USETA        
C        
C     REDUCE TO N SET IF MULTI POINT CONSTRAINTS        
C        
      GKN = GKG        
      IF(.NOT.MULTI) GO TO 20        
      IF(.NOT.SINGLE.AND..NOT.OMIT) GKN = GKA        
      CALL CALCV(SCR1,UG,UN,UM,CORE)        
      CALL SSG2A(GKG,GKNB,GKM,SCR1)        
      CALL SSG2B(GM,GKM,GKNB,GKN,1,1,1,SCR1)        
C        
C     PARTITION INTO F SET IF SINGLE POINT CONSTRAINTS        
C        
   20 IF(.NOT.SINGLE) GO TO 30        
      IF(.NOT.OMIT) GKF = GKA        
      CALL CALCV(SCR1,UN,UF,US,CORE)        
      CALL SSG2A(GKN,GKF,  0,SCR1)        
      GO TO 40        
C        
C     REDUCE TO A SET IF OMITS        
C        
   30 GKF = GKN        
   40 IF(.NOT.OMIT) GO TO 50        
      CALL CALCV(SCR1,UF,UA,UO,CORE)        
      CALL SSG2A(GKF,GKAB,GKO,SCR1)        
      CALL SSG2B(GO,GKO,GKAB,GKA,1,1,1,SCR1)        
   50 RETURN        
      END        
