      SUBROUTINE ENDPUT (IBLK)        
C        
      INTEGER         IDUM1(1)     ,IDUM2(1)     ,IBLK(1)      ,        
     1                BUFADD(75)        
      COMMON /GINOX / LENGTH,IFILEX,IEOR  ,IOP   ,IENTRY,LSTNAM,        
     1                N     ,NAME  ,IXYZ(3)      ,ITABAD(150)  ,        
     2                NBUFF3,IRDWRT,IUNITS(300)  ,IBLOCK(20)        
      COMMON /ZZZZZZ/ ICORE(1)        
      EQUIVALENCE     (ITABAD(76)  , BUFADD(1))        
      DATA    MASK6F/ '00FFFFFF'X  /        
CUNIX DATA    MASK6F/ X'00FFFFFF'  /        
C        
      NAME   = IBLK(1)        
      IENTRY = 13        
      DO 10 I = 2,12        
      IBLOCK(I) = IBLK(I)        
   10 CONTINUE        
C        
      IFILEX = IBLOCK(11)        
CUNIX JBUFF  =  AND(BUFADD(IFILEX),MASK6F)        
      JBUFF  = IAND(BUFADD(IFILEX),MASK6F)                              
C        
      CALL GINO (*30,*30,ICORE(JBUFF),IDUM1,IDUM2,IRDWRT)        
      RETURN        
C        
   30 CALL VAXEND        
      END        
