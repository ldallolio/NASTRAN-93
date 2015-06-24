      SUBROUTINE GUST        
C        
C     THE PURPOSE OF THIS MODULE IS TO COMPUTE STATIONARY VERTICAL GUST 
C         LOADS FOR USE IN AEROLASTIC ANALYSIS        
C        
C     DMAP CALLING SEQUENCE        
C        
C         GUST   CASECC,DLT,FRL,QHJL,,,ACPT,CSTMA,PHF1/PHF/V,N,NOGUST/  
C                V,N,BOV/C,Y,MACH/C,Y,Q  $        
C        
C     GUST USES SEVEN SCRATCH FILES        
      INTEGER CASECC,DLT,FRL,QHJL,ACPT,CSTMA,PHF1,PHF,SCR1,SCR2,SCR3,   
     1  SCR4,SCR5,SCR6,SCR7,SYSBUF,NAME(2),DIT,IBLOCK(11)        
      REAL XM(2),RBLOCK(11)        
      COMMON /SYSTEM/SYSBUF        
CZZ   COMMON /ZZGUST/ IZ(1)        
      COMMON /ZZZZZZ/ IZ(1)        
      COMMON /BLANK/NOGUST,BOV,RMACH,Q        
      EQUIVALENCE  (XM(1),NOGUST),(IBLOCK(1),RBLOCK(1))        
      DATA CASECC,DLT,FRL,QHJL,ACPT,CSTMA,PHF1,PHF,SCR1,SCR2,SCR3,SCR4  
     1   /  101  ,102,103,105 ,108 ,109  ,110 ,201,301 ,302 ,303 ,304 / 
      DATA  DIT,SCR5,SCR6,SCR7 /        
     1      104,305 ,306 ,307  /,NAME/4HGUST,1H /,RBLOCK /11*0.0/       
C        
C     GUST1  GENERATES A FREQUENCY FUNCTION TABLE(SCR1)        
C                        FOL DATA BLOCK          (SCR2)        
C                        A IMAGE OF GUST CARDS  SID,DLOAD,WG,X0,V(SCR4) 
C                      AND SUPPLIES NFREQ,NLOAD,XO,V,NOGUST        
C        
      CALL GUST1(CASECC,DIT,DLT,FRL,SCR1,SCR2,SCR4,NFREQ,NLOAD,XO,V,    
     1   NOGUST,SCR3)        
      IF( NOGUST .LT. 0) RETURN        
C        
C     GUST2 COMPUTES WJ MATRIX(SCR3)        
C        
      CALL GUST2(SCR2,SCR3,ACPT,XO,V,CSTMA,QHJL)        
C        
C     SET UP FOR ADRI        
C        
      NZ = KORSZ(IZ)        
      IBUF1 = NZ-SYSBUF+1        
      XM(1) =BOV        
      XM(2) = RMACH        
      CALL GOPEN(SCR2,IZ(IBUF1),0)        
      CALL BCKREC(SCR2)        
      CALL FREAD(SCR2,IZ,-2,0)        
      CALL FREAD(SCR2,IZ,NFREQ,1)        
      CALL CLOSE(SCR2,1)        
      NZ= NZ-NFREQ        
C        
C     ADRI INTERPOLATES ON QHJL PUTTING OUTPUT ON SCR2 (QHJK)        
C        
      CALL ADRI(IZ,NFREQ,NZ,QHJL,SCR2,SCR5,SCR6,SCR7,NROWJ,NCOLW,NOGO)  
      IF( NOGO .EQ. 1) CALL MESAGE(-61,0,NAME)        
C        
C     GUST3  MULTIPLIES QHJK BY WJ ONTO SCR5        
C             SCR5 IS MULTIPLIED BY LOAD FUNCTION,WG,AND Q ONTO        
C             SCR6        
C        
      CALL GUST3(SCR2,SCR3,SCR1,SCR4,SCR5,SCR6,Q,NFREQ,NLOAD,NROWJ,NCOLW
     1)        
C                QHJK  WJ  P    GUST POEL        
C        
C        
C     SET UP TO ADD LOADS        
C        
      NOGUST=1        
      IBLOCK(1) =1        
      RBLOCK(2) =1.0        
      IBLOCK(7) =1        
      RBLOCK(8) =1.0        
      CALL SSG2C(SCR6,PHF1,PHF,1,IBLOCK)        
      RETURN        
      END        
