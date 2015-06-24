      SUBROUTINE MAGBDY        
C        
C     THIS ROUTINE PICKS UP THE GRIDS ON THE AIR/IRON INTERFACES        
C     FROM A PERMBDY CARD,CONVERTS EXTERNAL TO INTERNAL SILS, AND       
C     STORES RESULTS ON PERMBD WHICH IS READ IN SSG1. SSG1 WILL NEED TO 
C     COMPUTE MAGNETIC LOADS ONLY AT THESE POINTS.        
C        
C     MAGBDY   GEOM1,HEQEXIN/PERMBD/V,N,IPG $        
C        
      INTEGER         BUF1,FILE,GEOM1,EQEXIN,PERMBD,SYSBUF,PERMBY(2)    
      DIMENSION       IZ(1),NAM(2),MCB(7)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /SYSTEM/ SYSBUF,IOUT        
      COMMON /BLANK / IPG        
CZZ   COMMON /ZZMAGB/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (Z(1),IZ(1))        
      DATA    NAM   / 4HMAGB,4HDY  /        
      DATA    GEOM1 , EQEXIN,PERMBD/101,102,201/        
      DATA    PERMBY/ 4201,42 /        
C        
      LCORE = KORSZ(Z)        
      BUF1  = LCORE - SYSBUF        
      LCORE = BUF1 - 1        
      IF (LCORE .LE. 0) GO TO 1008        
C        
C     SEE IF A PERMBDY CARD EXISTS        
C        
      IPG  = -1        
      FILE = GEOM1        
      CALL PRELOC (*1001,Z(BUF1),GEOM1)        
      CALL LOCATE (*10,Z(BUF1),PERMBY,IDX)        
      IPG  = 1        
      GO TO 20        
C        
C     NO PERMBDY CARD - RETURN        
C        
   10 CALL CLOSE (GEOM1,1)        
      RETURN        
C        
C     READ PERMBDY INTO CORE        
C        
   20 CALL READ (*1002,*30,GEOM1,Z,LCORE,0,NPTS)        
      GO TO 1008        
   30 CALL CLOSE (GEOM1,1)        
C        
C     READ IN 1ST RECORD OF EQEXIN        
C        
      LCORE = LCORE - NPTS        
      IEQEX = NPTS        
      CALL GOPEN (EQEXIN,Z(BUF1),0)        
      FILE  = EQEXIN        
      CALL READ (*1002,*40,EQEXIN,Z(IEQEX+1),LCORE,0,NEQ)        
      GO TO 1008        
   40 CALL CLOSE (EQEXIN,1)        
      NGRIDS = NEQ/2        
      LCORE  = LCORE - NEQ        
C        
C     GET THE INTERNAL NUMBER (=SIL NUMBER FOR HEAT TRAMSFER)FOR EACH   
C     POINT ON PERMBDY AND STORE IT BACK ONTO EXTERNAL NUMBER,SINCE THE 
C     EXTERNAL IS NO LONGER NEEDED        
C        
      DO 50 I = 1,NPTS        
      CALL BISLOC (*60,IZ(I),IZ(IEQEX+1),2,NGRIDS,JLOC)        
      IZ(I) = IZ(IEQEX+JLOC+1)        
   50 CONTINUE        
      GO TO 70        
C        
   60 WRITE  (IOUT,65) UFM,IZ(I)        
   65 FORMAT (A23,', GRID',I9,' ON PERMBDY CARD DOES NOT EXIST')        
      CALL MESAGE(-61,0,0)        
C        
C     WRITE THESE INTERNAL ID-S ONTO PERMBD        
C        
   70 CALL GOPEN (PERMBD,Z(BUF1),1)        
      CALL WRITE (PERMBD,IZ(1),NPTS,1)        
      CALL CLOSE (PERMBD,1)        
      MCB(1) = PERMBD        
      MCB(2) = NPTS        
      DO 80 I = 3,7        
   80 MCB(I) = 0        
      CALL WRTTRL(MCB)        
C        
      RETURN        
C        
 1001 N =-1        
      GO TO 1010        
 1002 N =-2        
      GO TO 1010        
 1008 N =-8        
      FILE = 0        
 1010 CALL MESAGE (N,FILE,NAM)        
      RETURN        
      END        
