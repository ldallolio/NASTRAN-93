      SUBROUTINE SSG3        
C        
C     DMAP FOR STATIC SOLUTION GENERATOR 3        
C        
C     SSG3   LLL,KLL,PL,LOO,KOOB,PO /ULV,UOV,RULV,RUOV/ V,N,OMIT/       
C            V,Y,IRES/V,N,SKIP/V,N,EPSI $        
C        
      INTEGER        LLL,KLL,PL,LOO,PO,ULV,UOV,SR1,SR2,OMIT,RULV,RUOV   
      COMMON /BLANK/ OMIT,IRES,NSKIP,EPSI        
      DATA    LLL  , KLL,  PL, LOO, KOOB, PO, ULV, UOV, RULV, RUOV /    
     1        101  , 102, 103, 104, 105, 106, 201, 202, 203 , 204  /    
      DATA    SR1  , SR2  /        
     1        301  , 302  /        
C        
      CALL SSG3A (KLL,LLL,PL,ULV,SR1,SR2,0,RULV)        
      IF (OMIT .GE. 0) CALL SSG3A (KOOB,LOO,PO,UOV,SR1,SR2,0,RUOV)      
      RETURN        
      END        
