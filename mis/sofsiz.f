      INTEGER FUNCTION SOFSIZ (DUM)        
C*****        
C     RETURNS THE REMAINING NUMBER OF AVAILABLE WORDS ON THE SOF.       
C*****        
      INTEGER      BLKSIZ,AVBLKS        
      DIMENSION    NMSBR(2)        
      COMMON /SYS/ BLKSIZ,DIRSIZ,SUPSIZ,AVBLKS        
      DATA  NMSBR/ 4HSOFS,4HIZ  /        
C*****        
      CALL CHKOPN (NMSBR(1))        
      SOFSIZ = BLKSIZ*AVBLKS        
      RETURN        
      END        
