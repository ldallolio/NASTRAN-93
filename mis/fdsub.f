      SUBROUTINE FDSUB (NAME,I)        
C                                                           ** PRETTIED 
C     SEARCHES IF THE SUBSTRUCTURE NAME HAS AN ENTRY IN THE DIT. IF IT  
C     DOES, THE OUTPUT VALUE OF I WILL INDICATE THAT NAME IS THE ITH    
C     SUBSTRUCTURE IN THE DIT.  I WILL BE SET TO -1 IF NAME DOES NOT    
C     HAVE AN ENTRY IN THEDIT.        
C        
      LOGICAL         DITUP        
      INTEGER         BUF,DIT,DITPBN,DITLBN,DITSIZ,DITNSB,DITBL,        
     1                BLKSIZ,DIRSIZ        
      DIMENSION       NAME(2),NMSBR(2)        
CZZ   COMMON /SOFPTR/ BUF(1)        
      COMMON /ZZZZZZ/ BUF(1)        
      COMMON /SOF   / DIT,DITPBN,DITLBN,DITSIZ,DITNSB,DITBL,IODUM(8),   
     1                MDIDUM(4),NXTDUM(15),DITUP        
      COMMON /SYS   / BLKSIZ,DIRSIZ        
      DATA    NMSBR / 4HFDUB,4HB   /        
C        
C     NNMS IS THE NUMBER OF NAMES ON ONE BLOCK OF THE DIT, AND NBLKS IS 
C     THE SIZE OF THE DIT IN NUMBER OF BLOCKS.        
C        
      CALL CHKOPN (NMSBR(1))        
      IF (DITNSB .EQ. 0) GO TO 70        
      NNMS  = BLKSIZ/2        
      NBLKS = DITSIZ/BLKSIZ        
      IF (DITSIZ .EQ. NBLKS*BLKSIZ) GO TO 30        
      NBLKS = NBLKS + 1        
C        
C     START LOOKING FOR THE SUBSTRUCTURE NAME.        
C        
   30 MAX = BLKSIZ        
      DO 60 J = 1,NBLKS        
      I = 1 + (J-1)*NNMS        
      CALL FDIT (I,DUMMY)        
      IF (J .NE. NBLKS) GO TO 40        
      MAX = DITSIZ - (NBLKS-1)*BLKSIZ        
C        
C     SEARCH THE BLOCK OF THE DIT WHICH IS PRESENTLY IN CORE.        
C        
   40 DO 50 K = 1,MAX,2        
      IF (BUF(DIT+K).NE.NAME(1) .OR. BUF(DIT+K+1).NE.NAME(2)) GO TO 50  
      KK = K        
      GO TO 80        
   50 CONTINUE        
   60 CONTINUE        
C        
C     DID NOT FIND NAME IN THE DIT.        
C        
   70 I = -1        
      RETURN        
C        
C     DID FIND NAME IN THE DIT.  RETURN NAME INDEX NUMBER        
C        
   80 I = (DITLBN-1)*NNMS + (KK+1)/2        
      RETURN        
      END        
