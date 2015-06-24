      SUBROUTINE IFP4E (ID)        
C        
C     IFP4E, CALLED BY IFP4, CHECKS TO SEE THAT ID IS WITHIN PERMISSABLE
C     RANGE OF FROM 1 TO 499999.        
C        
      LOGICAL         NOGO        
      INTEGER         OUTPUT        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /SYSTEM/ SYSBUF,OUTPUT        
C        
      IF (ID .LT. 1) GO TO 100        
      IF (ID .LE. 499999) RETURN        
C        
C     ERROR        
C        
  100 NOGO = .TRUE.        
      WRITE  (OUTPUT,110) UFM,ID        
  110 FORMAT (A23,' 4041, ID =',I12,' IS OUT OF PERMISSIBLE RANGE OF 1',
     1       ' TO 499999.')        
      RETURN        
      END        
