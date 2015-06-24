      SUBROUTINE FILSWI (NAME1,NAME2)        
C        
C     FILSWI SWITCHES THE UNITS ASSIGNED TO THE SPECIFIED DATA BLOCKS.  
C        
      EXTERNAL        COMPLF,ANDF,ORF        
      INTEGER         FIST,FIAT,COMPLF,SYS,ANDF,UNIT1,UNIT2,ORF,UNIT    
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /XFIST / NFIST,LFIST,FIST(1)        
     1       /XFIAT / FIAT(4)        
     2       /SYSTEM/ SYS,NOUT,SKIP(21),ICFIAT        
      DATA    MASK1 / 32767/        
C                     '7FFF'X        
C        
C     SEARCH FIST FOR POINTERS TO FIAT.        
C        
      IF (NAME1 .EQ. NAME2) RETURN        
      K1 = 0        
      K2 = 0        
      N  = 2*LFIST - 1        
      DO 8 I = 1,N,2        
      IF (FIST(I) .EQ. NAME1) K1 = FIST(I+1)        
      IF (FIST(I) .EQ. NAME2) K2 = FIST(I+1)        
    8 CONTINUE        
      IF (K1.GT.0 .AND. K2.GT.0) GO TO 10        
      WRITE  (NOUT,9) SFM        
    9 FORMAT (A23,' 2178, GINO REFERENCE NAMES, IMPROPER FOR ',        
     1       'SUBROUTINE FILSWI.')        
      CALL MESAGE (-61,0,0)        
C        
C     SWITCH UNIT REFERENCE NUMBERS IN FIAT.        
C        
   10 MASK2 = COMPLF(MASK1)        
      UNIT1 = ANDF(FIAT(K1+1),MASK1)        
      UNIT2 = ANDF(FIAT(K2+1),MASK1)        
      N     = ICFIAT*FIAT(3) - 2        
      DO 12 I = 4,N,ICFIAT        
      UNIT  = ANDF(FIAT(I),MASK1)        
      IF (UNIT .EQ. UNIT1) FIAT(I) = ORF(ANDF(FIAT(I),MASK2),UNIT2)     
      IF (UNIT .EQ. UNIT2) FIAT(I) = ORF(ANDF(FIAT(I),MASK2),UNIT1)     
   12 CONTINUE        
      RETURN        
      END        
