      SUBROUTINE GRAVL2(NVECT,FILD,PG)        
C        
      INTEGER PG(7),SYSBUF,FILD,SIL        
      INTEGER NAME(2)        
C        
      COMMON /BLANK/NROWSP        
      COMMON /SYSTEM/ SYSBUF        
      COMMON  /ZNTPKX/ A(4),LL,IEOL        
      COMMON /ZBLPKX/ B(4),II        
CZZ   COMMON /ZZSSA1/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON  /LOADX/ N(2),BGPDT,OLD,CSTM,SIL,ISTL,NN(8),MASS        
C        
      DATA NAME/4HGRAV,4HL2  /        
C        
C ----------------------------------------------------------------------
C        
      LCORE=KORSZ(CORE)        
      NZ = LCORE        
      LCORE=LCORE-SYSBUF        
      CALL OPEN(*170,PG(1),CORE(LCORE+1),0)        
      CALL SKPFIL (PG,1)        
      CALL SKPFIL (PG,-1)        
      CALL CLOSE (PG,2)        
      CALL OPEN(*170,PG(1),CORE(LCORE+1),3)        
      LCORE = LCORE-SYSBUF        
      CALL GOPEN(FILD,CORE(LCORE+1),0)        
      LCORE=LCORE-SYSBUF        
      CALL GOPEN( SIL,CORE(LCORE+1),0)        
      IBUF=LCORE        
      ISIL=0        
      DO 160 ILOOP=1,NVECT        
   50 CALL READ(*210,*130,SIL,ISIL1,1,0,FLAG)        
      IF(ISIL1) 50,60,60        
   60 ASSIGN 100 TO IOUT        
      CALL BLDPK(1,1,PG(1),0,0)        
      CALL INTPK(*150,FILD,0,1,0)        
   70 CALL READ(*210,*130,SIL,ISIL2,1,0,FLAG)        
      IF(ISIL2) 70,80,80        
   80 IF (ISIL2-ISIL1-1) 140,90,140        
   90 GO TO IOUT,(100,150)        
  100 IF (IEOL.NE.0) GO TO 150        
      CALL ZNTPKI        
      IF (LL-ISIL1) 120,90,70        
  120 B(1)=A(1)        
      II=LL        
      CALL ZBLPKI        
      GO TO 90        
  130 ASSIGN 150 TO IOUT        
      IF(NROWSP-ISIL1) 140,150,140        
  140 ISIL1 = 999999        
      GO TO 90        
  150 CALL REWIND(SIL)        
      CALL BLDPKN(PG(1),0,PG)        
      CALL SKPREC(SIL,1)        
      ISIL=0        
  160 CONTINUE        
      CALL CLOSE (SIL,1)        
      CALL CLOSE (FILD,1)        
      CALL WRTTRL (PG)        
      CALL CLOSE (PG,1)        
      RETURN        
C        
  170 IPM=PG(1)        
      CALL MESAGE (-1,IPM,NAME)        
C        
  210 CALL MESAGE (-3,SIL,NAME)        
      RETURN        
C        
      END        
