      SUBROUTINE SJUMP (N)        
C        
C     JUMP OVER N GROUPS WITHIN AN ITEM WHEN IN READ MODE.  N WILL BE   
C     RETURNED AS -1 IF THE END OF ITEM IS REACHED BEFORE JUMPING OVER  
C     N GROUPS.        
C        
      EXTERNAL        ANDF,RSHIFT        
      INTEGER         ANDF,RSHIFT,BUF,EOG,EOI,BLKSIZ,DIRSIZ,NMSBR(2)    
      COMMON /MACHIN/ MACH,IHALF,JHALF        
CZZ   COMMON /SOFPTR/ BUF(1)        
      COMMON /ZZZZZZ/ BUF(1)        
      COMMON /SOF   / DITDUM(6),IO,IOPBN,IOLBN,IOMODE,IOPTR,IOSIND,     
     1                IOITCD,IOBLK        
      COMMON /SYS   / BLKSIZ,DIRSIZ        
      DATA    IRD   / 1   /        
      DATA    EOG   , EOI /  4H$EOG ,4H$EOI       /        
      DATA    INDSBR/ 17  /, NMSBR  /4HSJUM,4HP   /        
C        
      CALL CHKOPN (NMSBR(1))        
      IF (N .LE. 0) RETURN        
      ICOUNT = 0        
      IF (IOMODE .EQ. IRD) GO TO 20        
      N = -2        
      RETURN        
C        
C     SEARCH THROUGH SOF FOR END OF ITEM AND END OF GROUP.        
C        
   10 IOPTR = IOPTR + 1        
   20 IF (IOPTR .GT. BLKSIZ+IO) GO TO 50        
   30 IF (BUF(IOPTR) .NE.  EOI) GO TO 40        
      N = -1        
      RETURN        
C        
   40 IF (BUF(IOPTR) .NE. EOG) GO TO 10        
      ICOUNT = ICOUNT + 1        
      IF (ICOUNT .NE. N) GO TO 10        
      IOPTR = IOPTR + 1        
      RETURN        
C        
C     REACHED END OF BLOCK.  REPLACE THE BLOCK CURRENTLY IN CORE BY ITS 
C     LINK BLOCK.        
C        
   50 CALL FNXT (IOPBN,INXT)        
      IF (MOD(IOPBN,2) .EQ. 1) GO TO 60        
      NEXT = ANDF(RSHIFT(BUF(INXT),IHALF),JHALF)        
      GO TO 70        
   60 NEXT = ANDF(BUF(INXT),JHALF)        
   70 IF (NEXT .EQ. 0) GO TO 510        
      IOPBN = NEXT        
      IOLBN = IOLBN + 1        
      CALL SOFIO (IRD,IOPBN,BUF(IO-2))        
      IOPTR = IO + 1        
      GO TO 30        
  510 CALL ERRMKN (INDSBR,9)        
      RETURN        
      END        
