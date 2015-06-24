      SUBROUTINE DGREE (NDSTK,NDEG,IOLD,IBW1,IPF1,NU)        
C        
C     THIS ROUTINE IS USED ONLY IN BANDIT MODULE        
C     DGREE COMPUTES THE DEGREE OF EACH NODE IN NDSTK AND STORES        
C     IT IN THE ARRAY NDEG.  THE BANDWIDTH AND PROFILE FOR THE ORIGINAL        
C     OR INPUT RENUMBERING OF THE GRAPH IS COMPUTED ALSO.        
C        
C     COMPUTE MAXIMUM DEGREE MM AND STORE IN IDEG.        
C        
C     INTEGER          BUNPK        
      DIMENSION        NDSTK(1), NDEG(1),  IOLD(1),  NU(1)        
      COMMON /BANDG /  N,        IDPTH,    IDEG        
      COMMON /BANDS /  NN,       MM        
C        
      IBW1=0        
      IPF1=0        
      IDEG=MM        
      MM=0        
      DO 100 I=1,N        
      NDEG(I)=0        
      IRW=0        
      CALL BUNPAK(NDSTK,I,IDEG,NU)        
      DO 80 J=1,IDEG        
C     ITST=BUNPK(NDSTK,I,J)        
      ITST=NU(J)        
      IF (ITST) 90,90,50        
   50 NDEG(I)=NDEG(I)+1        
      IDIF=IOLD(I)-IOLD(ITST)        
      IF (IRW.LT.IDIF) IRW=IDIF        
      MM=MAX0(MM,J)        
   80 CONTINUE        
   90 IPF1=IPF1+IRW        
      IF (IRW.GT.IBW1) IBW1=IRW        
  100 CONTINUE        
      IDEG=MM        
C        
C     INCLUDE DIAGONAL TERMS IN BANDWIDTH AND PROFILE        
      IBW1=IBW1+1        
      IPF1=IPF1+N        
      RETURN        
      END        
