      SUBROUTINE PREFIX (IPREFX,NAME)        
C        
      EXTERNAL        LSHIFT,RSHIFT,ORF        
      INTEGER         NAME(2),RSHIFT,ORF,RWORD        
      COMMON /SYSTEM/ JUNK(38),NBPC,NBPW,NCPW        
      DATA    IBLNK / 4H     /        
C        
      IBLANK = IBLNK        
C        
C     THIS ROUTINE PREFIXES THE TWO WORD VARIABLE 'NAME' WITH THE SINGLE
C     CHARACTER PREFIX 'IPREFX'.        
C        
C     SET RIGHT HAND PORTION OF WORDS TO ZERO.        
C        
      LWORD  = LSHIFT( RSHIFT( NAME(1),NBPW-4*NBPC ) , NBPW-4*NBPC )    
      RWORD  = LSHIFT( RSHIFT( NAME(2),NBPW-4*NBPC ) , NBPW-4*NBPC )    
      IPREFX = LSHIFT( RSHIFT( IPREFX,NBPW-NBPC ) , NBPW-NBPC )        
      IBLANK = RSHIFT( LSHIFT( IBLANK,4*NBPC ) , 4*NBPC )        
C        
C     MOVE RIGHT WORD ONE CHARACTER AND PREFIX WITH LAST CHARACTER      
C     OF LEFT WORD.        
C        
      RWORD = ORF( LSHIFT( LWORD,3*NBPC ) , RSHIFT( RWORD,NBPC ) )      
      RWORD = LSHIFT( RSHIFT( RWORD  ,NBPW-4*NBPC ) , NBPW-4*NBPC )     
      RWORD = ORF( RWORD , IBLANK )        
C        
C     MOVE LEFT WORD ONE CHARACTER TO RIGHT AND PREFIX WITH INPUT       
C     VALUE.        
C        
      LWORD = ORF( IPREFX , RSHIFT( LWORD,NBPC))        
      LWORD = LSHIFT( RSHIFT( LWORD  ,NBPW-4*NBPC ) , NBPW-4*NBPC )     
      LWORD = ORF( LWORD , IBLANK )        
C        
      NAME(1) = LWORD        
      NAME(2) = RWORD        
      RETURN        
      END        
