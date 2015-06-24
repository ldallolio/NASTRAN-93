      SUBROUTINE WRTTRL (FILBLK)        
C        
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF        
      INTEGER         FILBLK(7),FIAT,FIST,NAME(2),ORF,RSHIFT,ANDF,      
     1                FILBK(7),LB(2)        
      REAL            WORDS(4)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25,SWM*27        
      COMMON /XMSSG / UFM,UWM,UIM,SFM,SWM        
      COMMON /MACHIN/ MACH        
      COMMON /XFIAT / FIAT(3)        
      COMMON /XFIST / FIST(2)        
      COMMON /XSORTX/ ISAV(6)        
      COMMON /L15 L8/ L15,L8        
      COMMON /SYSTEM/ SYSTEM(40)        
      EQUIVALENCE     (SYSTEM(2),IOUT), (SYSTEM(24),ICFIAT),        
     1                (SYSTEM(40),NBPW)        
      DATA    MBIT  / 0 /   ,WORDS / 1.0, 2.0, 2.0, 4.0 /        
      DATA    NAME  / 4HWRTT,4HRL  /        
      DATA    MASK  / 65535 /        
C        
C        
C     IF ICFIAT= 8, WRTTRL WILL PACK SIX SIXTEEN BIT POSITIVE INTEGERS  
C     INTO THREE THIRTY-TWO BIT WORDS AND STORE THEM IN THE FIAT        
C     NO SUCH PACKING IF ICFIAT=11        
C        
C        
C     SEARCH FIST FOR THE FILE        
C        
C     WRTTRL WILL NOT CHANGE TRAILER FOR 100 SERIES FILES        
C        
      IF (FILBLK(1).GT.100 .AND. FILBLK(1).LT.199) CALL MESAGE (-40,    
     1    FILBLK(1),NAME)        
C        
C     ONLY MATGEN, OPTION 10, SENDS FILE 199 OVER HERE        
C        
      IF (FILBLK(1) .EQ. 199) FILBLK(1) = 101        
C        
C     THIS 'NEXT TO SIGN' MBIT IS SET BY SDCOMP AND SDCMPS        
C        
      MBIT = LSHIFT(1,NBPW-2 - (NBPW-32))        
      NOUT = IOUT        
      IF (MACH.EQ.2 .OR. MACH.GE.5) NOUT = 4        
C        
C     VERIFY SQUARE AND SYMM. MATRICES        
C        
      IF (L8.EQ.0 .OR. L15.EQ.0) GO TO 20        
      IF (FILBLK(7)  .LT.  MBIT) GO TO 20        
      IF (FILBLK(4).NE.1 .AND. FILBLK(4).NE.6) GO TO 20        
      IF (FILBLK(2) .EQ. FILBLK(3)) GO TO 20        
      CALL FNAME (FILBLK(1),LB(1))        
      WRITE  (IOUT,10) SWM,LB(1),LB(2),FILBLK(2),FILBLK(3),FILBLK(4)    
   10 FORMAT (A27,', DATA BLOCK ',2A4,1H,,I9,3H BY,I8,', IS MIS-LABLED',
     1       ' SQUARE OR SYMM.  (FORM=',I3,1H), /5X,        
     2       'TURN DIAGS 1, 8 AND 15 ON FOR ERROR TRACEBACK')        
      CALL SSWTCH (1,N)        
      IF (N .NE. 0) CALL ERRTRC ('WRTTRL  ',10)        
C        
   20 CONTINUE        
      N = FIST(2)*2 + 1        
      DO 30 I = 3,N,2        
      IF (FIST(I) .NE. FILBLK(1)) GO TO 30        
      INDEX = FIST(I+1) + 1        
      GO TO 40        
   30 CONTINUE        
      CALL MESAGE (-11,FILBLK(1),NAME)        
C        
C     IF (1) BIT 'NEXT TO SIGN BIT' IS ON IN FILBLK(7), (2) FILBLK(2)   
C     AND FILBLK(3), WHICH ARE COLUMN AND ROW, ARE NON ZEROS, AND       
C     FILBLK(5), WHICH IS TYPE, IS 1,2,3 OR 4, THE INCOMING TRAILER IS  
C     A MATRIX TRAILER. IN THIS CASE FILBLK(7) IS CONVERTED TO A DENSITY
C     PERCENTAGE BEFORE STORING IN THE FIAT.        
C        
   40 IF (FILBLK(7) .LT. MBIT) GO TO 50        
      COUNT = FILBLK(7) - MBIT        
      I = FILBLK(5)        
      IF (FILBLK(2).EQ.0 .OR. FILBLK(3).EQ.0 .OR. I.LT.1 .OR. I.GT.4)   
     1    GO TO 50        
      FN = FILBLK(2)        
      FM = FILBLK(3)        
      FILBLK(7) = (COUNT/(FN*FM*WORDS(I)))*1.E4 + 1.0E-3        
      IF (FILBLK(7).EQ.0 .AND. FILBLK(6).NE.0) FILBLK(7) = 1        
   50 CONTINUE        
C        
      IF (L8 .EQ. 0) GO TO 100        
      WRITE  (NOUT,60,ERR=70) FIAT(INDEX+1),FIAT(INDEX+2),        
     1                        (FILBLK(I),I=2,7)        
   60 FORMAT (' *** DIAG 8, MESSAGE -- TRAILER FOR DATA BLOCK ',2A4,    
     1        2H =,6I10)        
      GO TO 100        
   70 CALL SSWTCH (1,N)        
      IF (N .EQ. 0) GO TO 100        
      WRITE  (NOUT,80,ERR=90) (FILBLK(I),I=2,7)        
CIBMR 6/93  80 FORMAT (3H  (,6O20,1H))        
   80 FORMAT (3H  (,6I8,1H))        
   90 CALL ERRTRC ('WRTTRL  ',70)        
C        
C     IF ICFIAT IS 8, PACK THE TRAILER INFORMATION IN THE FIAT.        
C     BEFORE PACKING MAKE SURE NUMBERS ARE POSITIVE AND .LE. 16 BITS.   
C        
C     IF ICFIAT IS 11, 6 TRAILER WORDS ARE STORED DIRECTLY INTO 4TH,    
C     5TH, 6TH, 9TH, 10TH AND 11TH WORD OF A FIAT ENTRY        
C        
  100 IF (ICFIAT .EQ. 11) GO TO 120        
      DO 110 I = 2,7        
      FILBLK(I) = ANDF(MASK,IABS(FILBLK(I)))        
  110 CONTINUE        
      FIAT(INDEX+ 3) = ORF(FILBLK(3),LSHIFT(FILBLK(2),16))        
      FIAT(INDEX+ 4) = ORF(FILBLK(5),LSHIFT(FILBLK(4),16))        
      FIAT(INDEX+ 5) = ORF(FILBLK(7),LSHIFT(FILBLK(6),16))        
      GO TO 130        
  120 FIAT(INDEX+ 3) = FILBLK(2)        
      FIAT(INDEX+ 4) = FILBLK(3)        
      FIAT(INDEX+ 5) = FILBLK(4)        
      FIAT(INDEX+ 8) = FILBLK(5)        
      FIAT(INDEX+ 9) = FILBLK(6)        
      FIAT(INDEX+10) = FILBLK(7)        
  130 IF (FIAT(INDEX) .GE. 0) GO TO 150        
C        
C     FIND EQUIVALENCED FILES IN FIAT AND WRITE TRAILER ON THEM        
C        
      IUCB  = ANDF(FIAT(INDEX),MASK)        
      IENDF = FIAT(3)*ICFIAT - 2        
      DO 140 I = 4,IENDF,ICFIAT        
      IF (FIAT(I) .GE. 0) GO TO 140        
C        
C     PICK UP UNIT CONTROL BLOCK        
C        
      ITUCB = ANDF(FIAT(I),MASK)        
      IF (ITUCB .NE. IUCB) GO TO 140        
C        
C     FOUND FILE        
C        
      FIAT(I+ 3) = FIAT(INDEX+ 3)        
      FIAT(I+ 4) = FIAT(INDEX+ 4)        
      FIAT(I+ 5) = FIAT(INDEX+ 5)        
      IF (ICFIAT .EQ. 8) GO TO 140        
      FIAT(I+ 8) = FIAT(INDEX+ 8)        
      FIAT(I+ 9) = FIAT(INDEX+ 9)        
      FIAT(I+10) = FIAT(INDEX+10)        
  140 CONTINUE        
C        
C     SAVE THE TRAILER IN ISAV IF FILE IS SCRATCH 1        
C     (SAVED FOR GINOFILE MODULE, SUBROUTINE GINOFL)        
C        
  150 IF (FILBLK(1) .NE. 301) RETURN        
      ISAV(1) = FIAT(INDEX+ 3)        
      ISAV(2) = FIAT(INDEX+ 4)        
      ISAV(3) = FIAT(INDEX+ 5)        
      IF (ICFIAT .EQ. 8) GO TO 160        
      ISAV(4) = FIAT(INDEX+ 8)        
      ISAV(5) = FIAT(INDEX+ 9)        
      ISAV(6) = FIAT(INDEX+10)        
  160 RETURN        
C        
C        
      ENTRY RDTRL (FILBK)        
C     ===================        
C        
C     RDTRL WILL UNPACK THE THREE WORDS STORED IN THE FIAT AND RETURN   
C     THE SIX WORDS OF TRAILER INFORMATION        
C        
C        
C     SEARCH THE FIST FOR THE FILE        
C        
      N = FIST(2)*2 + 1        
      DO 200 I = 3,N,2        
      IF (FIST(I) .NE. FILBK(1)) GO TO 200        
      INDEX = FIST(I+1) + 1        
      GO TO 210        
  200 CONTINUE        
C        
C     FILE WAS NOT FOUND, SET THE FILE NAME NEGATIVE        
C        
      FILBK(1) = -IABS(FILBK(1))        
      RETURN        
C        
C     CHECK FIAT ENTRY 8 OR 11 WORDS PER ENTRY        
C        
  210 IF (ICFIAT .EQ. 11) GO TO 220        
C        
C     8 WORD ENTRY, UNPACK THE TRAILER INFORMATION        
C        
      FILBK(2) = RSHIFT(FIAT(INDEX+3),16)        
      FILBK(3) = ANDF(FIAT(INDEX+3),MASK)        
      FILBK(4) = RSHIFT(FIAT(INDEX+4),16)        
      FILBK(5) = ANDF(FIAT(INDEX+4),MASK)        
      FILBK(6) = RSHIFT(FIAT(INDEX+5),16)        
      FILBK(7) = ANDF(FIAT(INDEX+5),MASK)        
      GO TO 230        
C        
C     11 WORD ENTRY, TRAILER NOT PACKED        
C        
  220 FILBK(2) = FIAT(INDEX+ 3)        
      FILBK(3) = FIAT(INDEX+ 4)        
      FILBK(4) = FIAT(INDEX+ 5)        
      FILBK(5) = FIAT(INDEX+ 8)        
      FILBK(6) = FIAT(INDEX+ 9)        
      FILBK(7) = FIAT(INDEX+10)        
C        
  230 RETURN        
      END        
