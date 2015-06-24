      SUBROUTINE SCE1        
C        
C     MODULE 2.6 SCE PARTITIONS KNN,MNN,BNN,AND K4NN        
C        
C     TO ELIMINATE THE EFFECTS OF SINGLE POINT CONSTRAINTS IF US IS NOT 
C     NULL        
C        
      INTEGER        US,USET,BNN,BFF,UN,UF,PVECT        
      COMMON /PATX / N(2),N3,NN(3)        
      DATA    UN,UF, US /        
     1        27,26, 31 /        
      DATA    USET , KNN,MNN,BNN,K4NN,KFF,KFS,KSS,MFF,BFF,K4FF,PVECT /  
     1        101  , 102,103,104,105 ,201,202,203,204,205,206 ,301   /  
C        
      CALL UPART (USET,PVECT,UN,UF,US)        
      CALL MPART (KNN,KFF,0,KFS,KSS)        
      CALL MPART (MNN,MFF,0,0,0)        
      CALL MPART (BNN,BFF,0,0,0)        
      CALL MPART (K4NN,K4FF,0,0,0)        
      RETURN        
      END        
