      SUBROUTINE SUWRT (IA,NWORDS,ITEST)        
C        
C     COPIES DATA FROM THE ARRAY IA ON THE SOF.  NWORD IS AN INPUT      
C     PARAMETER INDICATING THE NUMBER OF WORDS TO BE COPIED.  ITEST IS  
C     AN INPUT PARAMETER WHERE ITEST=1 MEANS MORE TO COME, ITEST=2 MEANS
C     WRITE END OF GROUP, AND ITEST=3 MEANS WRITE END OF ITEM.        
C        
      EXTERNAL        LSHIFT,ANDF,ORF        
      LOGICAL         MDIUP        
      INTEGER         BUF,MDI,MDIPBN,MDILBN,MDIBL,BLKSIZ,DIRSIZ,ANDF,ORF
      DIMENSION       IA(1),NMSBR(2)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /MACHIN/ MACH,IHALF,JHALF        
CZZ   COMMON /SOFPTR/ BUF(1)        
      COMMON /ZZZZZZ/ BUF(1)        
      COMMON /SOF   / DITDUM(6),        
     1                IO,IOPBN,IOLBN,IOMODE,IOPTR,IOSIND,IOITCD,IOBLK,  
     2                MDI,MDIPBN,MDILBN,MDIBL,NXTDUM(15),DITUP,MDIUP    
      COMMON /SYS   / BLKSIZ,DIRSIZ        
      COMMON /SYSTEM/ NBUFF,NOUT        
      DATA    IDLE  , IWRT / 0,2    /        
      DATA    IEOG  , IEOI / 4H$EOG ,4H$EOI /, NMSBR /4HSUWR,4HT   /    
C        
      CALL CHKOPN (NMSBR(1))        
      ICOUNT = 0        
      IF (IOMODE .EQ. IWRT) GO TO 10        
      ITEST = 4        
      RETURN        
C        
C     KEEP COPYING DATA FROM THE ARRAY IA INTO THE INPUT/OUTPUT BUFFER  
C     UNTIL THE BUFFER IS FULL, OR UNTIL THE REQUESTED NUMBER OF WORDS  
C     HAS BEEN COPIED.        
C        
   10 IF (IOPTR .GT. BLKSIZ+IO) GO TO 30        
   20 IF (ICOUNT .EQ. NWORDS) GO TO (80,60,50), ITEST        
      ICOUNT = ICOUNT + 1        
      BUF(IOPTR) = IA(ICOUNT)        
      IOPTR = IOPTR + 1        
      GO TO 10        
C        
C     THE BUFFER IS FULL.  OUTPUT IT ON THE SOF.        
C        
   30 CALL SOFIO (IWRT,IOPBN,BUF(IO-2))        
      CALL GETBLK (IOPBN,J)        
      IF (J .EQ. -1) GO TO 40        
      IOPBN = J        
      IOLBN = IOLBN + 1        
      IOPTR = IO + 1        
      GO TO 20        
C        
C     THERE ARE NO MORE FREE BLOCKS ON THE SOF.  RETURN THE BLOCKS THAT 
C     HAVE BEEN USED SO FAR BY THE ITEM BEING WRITTEN, AND CLOSE THE SOF
C     THEN ISSUE A FATAL ERROR MESSAGE.        
C        
   40 CALL RETBLK (IOBLK)        
      CALL SOFCLS        
      GO TO 90        
C        
C     WRITE END OF ITEM, OUTPUT THE INPUT/OUTPUT BUFFER ON THE SOF, AND 
C     UPDATE THE MDI.        
C        
   50 BUF(IOPTR) = IEOI        
      CALL SOFIO (IWRT,IOPBN,BUF(IO-2))        
      CALL FMDI (IOSIND,IMDI)        
      BUF(IMDI+IOITCD) = IOBLK        
      BUF(IMDI+IOITCD) = ORF(ANDF(BUF(IMDI+IOITCD),JHALF),        
     1                       LSHIFT(IOLBN,IHALF))        
      MDIUP  = .TRUE.        
      IOMODE = IDLE        
      GO TO 70        
C        
C     WRITE END OF GROUP.        
C        
   60 BUF(IOPTR) = IEOG        
   70 IOPTR = IOPTR + 1        
   80 RETURN        
C        
C     ERROR MESSAGES.        
C        
   90 WRITE  (NOUT,100) UFM        
  100 FORMAT (A23,' 6223, THERE ARE NO MORE FREE BLOCKS AVAILABLE ON',  
     1       ' THE SOF FILE.')        
      CALL SOFCLS        
      CALL MESAGE (-61,0,0)        
      RETURN        
      END        
