      SUBROUTINE FBSINV (X,Y,IOBUFF)        
C        
C     SINGLE PRECISION VERSION        
C        
C     FBSINV IS A SPECIAL FORWARD-BACKWARD SUBSTITUTION ROUTINE FOR     
C     INVPWR. IT OPERATES ON CONJUNCTION WITH SDCOMP.        
C     THE ARITHMETIC PRECISION IS THAT OF THE INPUT FILE        
C        
C     FILEL  = MATRIX CONTROL BLOCK FOR THE LOWER TRIANGLE        
C     X      = THE LOAD VECTOR        
C     Y      = THE SOLUTION VECTOR        
C     IOBUFF = NOT USED        
C        
      INTEGER         FILEL   ,PARM(3)  ,IBLK(15)        
      REAL            X(1)    ,Y(1)        
      COMMON /FBSX  / FILEL(7)        
      EQUIVALENCE    (FILEL(3),NROW), (FILEL(5),LTYPE)        
      DATA    PARM  / 4H      ,4HFBSI, 4HNV   /        
C        
C     FORWARD PASS        
C        
      PARM(1) = FILEL(1)        
      IBLK(1) = FILEL(1)        
      IF (LTYPE .EQ. 2) GO TO 20        
      IF (LTYPE .NE. 1) GO TO 50        
C        
C     TRANSFER THE SINGLE PRECISION LOAD VECTOR TO THE SOLUTION VECTOR  
C        
      DO 10 I = 1,NROW        
   10 Y(I) = X(I)        
      CALL FBS1 (IBLK,Y,Y,NROW)        
      GO TO 40        
C        
C     TRANSFER THE DOUBLE PRECISION LOAD VECTOR TO THE SOLUTION VECTOR  
C        
   20 NROW2 = 2*NROW        
      DO 30 I = 1,NROW2        
   30 Y(I) = X(I)        
      CALL FBS2 (IBLK,Y,Y,NROW2)        
C        
   40 CALL REWIND (FILEL)        
      CALL SKPREC (FILEL,1)        
      RETURN        
C        
C     FATAL ERRORS        
C        
   50 CALL MESAGE (-7,PARM(1),PARM(2))        
      RETURN        
      END        
