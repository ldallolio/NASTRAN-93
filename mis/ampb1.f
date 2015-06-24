      SUBROUTINE AMPB1(IPVCT,NOH,NOE)        
C        
C     THIS ROUTINE BUILDS A PARTITIONING VECTOR WHICH WILL APPEND NOE   
C       TERM(OR COLUMNS)        
C        
      INTEGER SYSBUF,MCB(7)        
C        
      COMMON  /ZBLPKX/A(4),II        
      COMMON /SYSTEM/SYSBUF        
CZZ   COMMON /ZZAMB1/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
C        
C-----------------------------------------------------------------------
C        
      IBUF1=KORSZ(Z)-SYSBUF+1        
      CALL GOPEN(IPVCT,Z(IBUF1),1)        
      CALL MAKMCB(MCB,IPVCT,NOH+NOE,2,1)        
      CALL BLDPK(1,1,IPVCT,0,0)        
      II=NOH        
      DO 10 I=1,NOE        
      A(1)=1.0        
      II=II+1        
      CALL ZBLPKI        
   10 CONTINUE        
      CALL BLDPKN(IPVCT,0,MCB)        
      CALL CLOSE(IPVCT,1)        
      CALL WRTTRL(MCB)        
      RETURN        
      END        
