      SUBROUTINE XLNKHD        
C        
C     THE PURPOSE OF XLNKHD IS TO GENERATE THE LINK HEADER SECTION FOR  
C     AN OSCAR ENTRY        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF        
      DIMENSION       MED(1),OSCAR(1),OS(5)        
      COMMON /SYSTEM/ ISYS(81),CPFLG        
      COMMON /XGPIC / ICOLD,ISLSH,IEQUL,NBLANK,NXEQUI,        
     1                NDIAG,NSOL,NDMAP,NESTM1,NESTM2,NEXIT,        
     2                NBEGIN,NEND,NJUMP,NCOND,NREPT,NTIME,NSAVE,NOUTPT, 
     3                NCHKPT,NPURGE,NEQUIV,        
     4                NCPW,NBPC,NWPC,        
     5                MASKHI,MASKLO,ISGNON,NOSGN,IALLON,MASKS(1)        
CZZ   COMMON /ZZXGPI/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /XGPI2 / LMPL,MPLPNT,MPL(1)        
      COMMON /XGPI4 / IRTURN,INSERT,ISEQN,DMPCNT,        
     1                IDMPNT,DMPPNT,BCDCNT,LENGTH,ICRDTP,ICHAR,NEWCRD,  
     2                MODIDX,LDMAP,ISAVDW,DMAP(1)        
      COMMON /XGPI5 / IAPP,START,ALTER(2),SOL,SUBSET,IFLAG,IESTIM,      
     1                ICFTOP,ICFPNT,LCTLFL,ICTLFL(1)        
      COMMON /XGPI6 / MEDTP,FNMTP,CNMTP,MEDPNT,LMED,DUMMY(5),IFIRST     
      COMMON /XMDMSK/ NMSKCD,NMSKFL,NMSKRF,MEDMSK(7)        
      COMMON /XOLDPT/ XX(4),SEQNO        
      COMMON /AUTOHD/ IHEAD        
      COMMON /XGPID / ICST,IUNST,IMST,IHAPP,IDSAPP,IDMAPP        
      EQUIVALENCE     (CORE(1),OS(1),LOSCAR),(OS(2),OSPRC),        
     1                (OS(3),OSBOT),(OS(4),OSPNT),        
     2                (OSCAR(1),MED(1),OS(5))        
      DATA    XCHK  / 4HXCHK   /        
C        
      OR (I,J) = ORF(I,J)        
      AND(I,J) = ANDF(I,J)        
      MPLER = MPL(MPLPNT+3)        
      IF (IHEAD .EQ. 1) MPLER = 4        
C        
C     CHECK FOR DECLARATIVE INSTRUCTION        
C        
      IF (IHEAD .EQ. 1) GO TO 20        
      IF (MPLER .NE. 5) GO TO 10        
      OSPNT = OSCAR(OSBOT) + OSBOT        
      GO TO 20        
C        
C     UPDATE OSCAR PARAMETERS        
C        
   10 OSPRC = OSBOT        
      OSBOT = OSCAR(OSBOT) + OSBOT        
      OSPNT = OSBOT        
      ISEQN = OSCAR(OSPRC+1) + 1        
C        
C     LOAD LINK HEADER INFORMATION        
C        
      OSCAR(OSPNT    ) = 6        
      OSCAR(OSPNT + 1) = ISEQN        
      OSCAR(OSPNT + 2) = MPLER + LSHIFT(MODIDX,16)        
      OSCAR(OSPNT + 3) = DMAP(DMPPNT    )        
      OSCAR(OSPNT + 4) = DMAP(DMPPNT + 1)        
      OSCAR(OSPNT + 5) = DMPCNT        
C        
      MPLPNT = MPLPNT + 4        
   20 OSCAR(OSPNT+5) = OR(ISGNON,OSCAR(OSPNT+5))        
C        
C     ALWAYS RAISE EXECUTE FLAG FOR COLD START RUNS        
C        
      IF (START .EQ. ICST)  GO TO 70        
C        
C     COMPARE SEQ NO. WITH REENTRY SEQ NO.        
C        
      IF (DMPCNT .LT. RSHIFT(SEQNO,16)) GO TO 30        
C        
C     WE ARE BEYOND REENTRY POINT - EXECUTE ALL MODULES HERE ON OUT.    
C        
      IF (ANDF(MASKHI,SEQNO).EQ.0 .AND. MPLER.NE.5)        
     1    SEQNO = OR(ISEQN,AND(MASKLO,SEQNO))        
      GO TO 70        
C        
C     WE ARE BEFORE REENTRY POINT - CHECK APPROACH AND TYPE OF RESTART  
C     ALWAYS RAISE EXECUTE FLAG FOR INSERT FOR MODIFIED RESTARTS.       
C        
   30 IF (INSERT.NE.0 .AND. START.EQ.IMST) GO TO 70        
      IF (START .EQ. IMST) GO TO 40        
C        
C     LOWER EXECUTE FLAG FOR UNMODIFIED RESTART RUNS.        
C        
      OSCAR(OSPNT+5) = AND(NOSGN,OSCAR(OSPNT+5))        
      IF (MPLER .EQ. 5) GO TO 90        
      RETURN        
C        
C     FOR RIGID FORMAT - CHECK DECISION TABLE FOR MODIFIED RESTART      
C        
   40 I = MED(MEDTP+1)        
      DO 50 J = 1,I        
      K = MEDPNT + J - 1        
      IF (AND(MED(K),MEDMSK(J)) .NE. 0) GO TO 70        
   50 CONTINUE        
      OSCAR(OSPNT+5) = AND(NOSGN,OSCAR(OSPNT+5))        
   70 IF (OSCAR(OSPNT+3).EQ.XCHK .AND. CPFLG.EQ.0)        
     1    OSCAR(OSPNT+5) = AND(NOSGN,OSCAR(OSPNT+5))        
      IF (OSCAR(OSPNT+5).GE.0 .AND. MPLER.NE.5) RETURN        
C        
C     PRINT COMPILE/EXECUTE FLAG FOR RESTART        
C        
   90 IF (START.EQ.ICST   .OR.  IFIRST.EQ.0) RETURN        
      IF (DMPCNT.EQ.IFLAG .AND. INSERT.EQ.0) RETURN        
      IFLAG = DMPCNT        
      I = 7        
      IF (MPLER .EQ. 5) I = 10        
      CALL XGPIMW (I,0,0,0)        
      RETURN        
      END        
