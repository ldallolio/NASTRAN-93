      SUBROUTINE RETBLK (IBL)        
C        
C     RETURNS BLOCK I AND ALL BLOCKS LINKED TO IT TO THE LIST OF FREE   
C     BLOCKS IN THE SUPERBLOCK TO WHICH BLOCK I BELONGS   IF SOME OF    
C     THE BLOCKS THAT ARE LINKED TO BLOCK I DO NOT BELONG TO THE SAME   
C     SUPERBLOCK, THEY ARE RETURNED TO THE FREE LIST OF THEIR OWN       
C     RESPECTIVE SUPERBLOCKS.        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF        
      LOGICAL         DITUP,NXTUP,REPEAT        
      DIMENSION       NMSBR(2)        
      COMMON /MACHIN/ MACH,IHALF,JHALF        
CZZ   COMMON /SOFPTR/ BUF(1)        
      COMMON /ZZZZZZ/ BUF(1)        
      COMMON /SOF   / DIT,DITPBN,DITLBN,DITSIZ,DITNSB,DITBL,        
     1                IODUM(8),MDIDUM(4),        
     2                NXT,NXTPBN,NXTLBN,NXTTSZ,NXTFSZ(10),NXTCUR,       
     3                DITUP,MDIUP,NXTUP        
      COMMON /SYS   / BLKSIZ,DIRSIZ,SUPSIZ,AVBLKS        
      COMMON /SOFCOM/ NFILES,FILNAM(10),FILSIZ(10)        
      DATA    IRD   , IWRT/ 1,2   /        
      DATA    INDSBR/ 13 /, NMSBR /4HRETB,4HLK  /        
C        
      CALL CHKOPN (NMSBR(1))        
      I = IBL        
      IF (I .LE. 0) GO TO 500        
      LMASK = LSHIFT(JHALF,IHALF)        
C        
C     COMPUTE THE NUMBER OF THE FILE TO WHICH BLOCK I BELONGS,        
C     THE INDEX OF BLOCK I WITHIN THAT FILE, THE NUMBER WITHIN THE      
C     FILE OF THE SUPERBLOCK TO WHICH BLOCK I BELONGS, AND THE LOGICAL  
C     BLOCK NUMBER OVER THE SYSTEM OF THAT SUPERBLOCK.        
C        
    5 LEFT = I        
      DO 7 L = 1,NFILES        
      IF (LEFT .GT. FILSIZ(L)) GO TO 6        
      FILNUM = L        
      GO TO 10        
    6 LEFT = LEFT - FILSIZ(L)        
    7 CONTINUE        
      GO TO 500        
   10 FILIND = LEFT        
      FILSUP = (FILIND-1)/SUPSIZ        
      IF (FILIND-1 .EQ. FILSUP*SUPSIZ) GO TO 20        
      FILSUP = FILSUP + 1        
   20 ILBN = 0        
      MAX  = FILNUM - 1        
      IF (MAX .LT. 1) GO TO 28        
      DO 25 L = 1,MAX        
      ILBN = ILBN + NXTFSZ(L)        
   25 CONTINUE        
   28 ILBN = ILBN + FILSUP        
      IF (ILBN .EQ. NXTLBN) GO TO 60        
C        
C     THE DESIRED BLOCK OF THE ARRAY NXT IS NOT IN CORE.        
C        
      IF (NXTLBN .EQ. 0) GO TO 30        
C        
C     THE IN CORE BUFFER SHARED BY THE DIT AND THE ARRAY NXT IS NOW     
C     OCCUPIED BY A BLOCK OF NXT.  IF THAT BLOCK HAS BEEN UPDATED,      
C     MUST WRITE IT OUT BEFORE READING IN THE NEW BLOCK.        
C        
      IF (.NOT.NXTUP) GO TO 50        
      CALL SOFIO (IWRT,NXTPBN,BUF(NXT-2))        
      NXTUP = .FALSE.        
      GO TO 50        
C        
C     THE IN CORE BUFFER SHARED BY THE DIT AND THE ARRAY NXT IS NOW     
C     OCCUPIED BY A BLOCK OF THE DIT.  IF THAT BLOCK HAS BEEN UPDATED,  
C     MUST WRITE IT OUT BEFORE READING IN THE NEW BLOCK.        
C        
   30 IF (.NOT.DITUP) GO TO 40        
      CALL SOFIO (IWRT,DITPBN,BUF(DIT-2))        
      DITUP  = .FALSE.        
   40 DITPBN = 0        
      DITLBN = 0        
C        
C     READ IN THE DESIRED BLOCK OF NXT.        
C        
   50 NXTLBN = ILBN        
      NXTPBN = 0        
      MAX = FILNUM - 1        
      IF (MAX .LT. 1) GO TO 58        
      DO 55 L = 1,MAX        
      NXTPBN = NXTPBN + FILSIZ(L)        
   55 CONTINUE        
   58 NXTPBN = NXTPBN + (FILSUP-1)*SUPSIZ + 2        
      CALL SOFIO (IRD,NXTPBN,BUF(NXT-2))        
C        
C     THE DESIRED BLOCK OF NXT IS IN CORE.        
C        
   60 BTFREE = ANDF(BUF(NXT+1),JHALF)        
      TPFREE = RSHIFT(BUF(NXT+1),IHALF)        
      IF (BTFREE .EQ. 0) GO TO 90        
C        
C     CHECK IF BLOCK I IS ALREADY IN THE LIST OF FREE BLOCKS.        
C        
      J = TPFREE        
   70 IF (J .EQ. I) GO TO 220        
      IF (J .EQ. 0) GO TO 90        
      IND = (J-NXTPBN+2)/2 + 1        
      IF (MOD(J,2) .EQ. 1) GO TO 80        
      J = RSHIFT(BUF(NXT+IND),IHALF)        
      GO TO 70        
   80 J = ANDF(BUF(NXT+IND),JHALF)        
      GO TO 70        
C        
C     BLOCK I IS NOT IN THE LIST OF FREE BLOCKS.        
C     SET TPFREE TO I        
C        
   90 BUF(NXT+1) = LSHIFT(I,IHALF)        
C        
C     EXAMINE THE BLOCKS THAT ARE LINKED TO BLOCK I.        
C        
      REPEAT = .FALSE.        
      IF (FILSUP .NE. NXTFSZ(FILNUM)) GO TO 123        
      LSTBLK = NXTPBN + FILSIZ(FILNUM) - (FILSUP-1)*SUPSIZ - 2        
      GO TO 126        
  123 LSTBLK = NXTPBN + SUPSIZ - 1        
  126 AVBLKS = AVBLKS + 1        
      IND = (I-NXTPBN+2)/2 + 1        
      IF (MOD(I,2) .EQ. 1) GO TO 130        
      ISV = RSHIFT(BUF(NXT+IND),IHALF)        
      GO TO 140        
  130 ISV = ANDF(BUF(NXT+IND),JHALF)        
  140 IF (ISV .EQ. 0) GO TO 160        
      IF (ISV.LT.NXTPBN .OR. ISV.GT.LSTBLK) GO TO 150        
      I = ISV        
      GO TO 126        
  150 REPEAT = .TRUE.        
C        
C     ALL THE BLOCKS IN THIS SUPERBLOCK HAVE BEEN FOUND.        
C     SET POINTER OF I TO VALUE OF OLD TPFREE.        
C        
  160 IF (MOD(I,2) .EQ. 1) GO TO 170        
      BUF(NXT+IND) = ORF(ANDF(BUF(NXT+IND),JHALF),LSHIFT(TPFREE,IHALF)) 
      GO TO 180        
  170 BUF(NXT+IND) = ORF(ANDF(BUF(NXT+IND),LMASK),TPFREE)        
  180 IF(BTFREE .EQ. 0) BTFREE = I        
C        
C     SET BTFREE TO LAST BLOCK IN CHAIN.        
C        
      BUF(NXT+1) = ORF(ANDF(BUF(NXT+1),LMASK),BTFREE)        
      NXTUP = .TRUE.        
      IF (.NOT. REPEAT) GO TO 220        
C        
C     ISV BELONGS TO A DIFFERENT SUPERBLOCK, REPEAT        
C     SUBROUTINE FOR BLOCK ISV.        
C        
      I = ISV        
      GO TO 5        
C        
C     NO MORE BLOCKS LINKED TO BLOCK I, RETURN.        
C        
  220 CONTINUE        
      RETURN        
C        
C     ERROR MESSAGE.        
C        
  500 CALL ERRMKN (INDSBR,2)        
      RETURN        
      END        
