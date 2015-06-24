      SUBROUTINE SOFTOC        
C        
C     SOF TABLE OF CONTENTS ROUTINE        
C        
C        
C     THE CURRENT SUBSTRUCTURE TYPE BIT POSITIONS ARE -        
C        
C        NO BIT - BASIC SUBSTRUCTURE (EXCEPT IMAGE BIT)        
C        BIT 30 - IMAGE SUBSTRUCTURE        
C            29 - COMBINED SUBSTRUCTURE        
C            28 - GUYAN REDUCTUION SUBSTRUCTURE        
C            27 - MODAL REDUCTION SUBSTRUCTURE        
C            26 - COMPLEX MODAL REDUCTION SUBSTRUCTURE        
C        
C     TO ADD A NEW SUBSTRUCTURE TYPE BIT THE FOLLOWING UPDATES ARE      
C     REQUIRED.        
C        
C        1) INCREASE THE DEMENSION OF TYPE.        
C        2) INCREASE THE VALUE OF NTYPE IN THE DATA STATEMENT.        
C        3) ADD A NEW BCD TYPE VALUE TO THE DATA STATEMENT.        
C        
C        
C     THIS ROUTINE IS CURRENTLY CODED TO HANDLE UP TO 27 SOF ITEMS      
C     AUTOMATICALLY.        
C     TO INCREASE THIS TO 40 ITEMS PERFORM THE FOLLOWING UPDATES.       
C        
C        1) CHANGE THE DIMENSION OF HDR TO (40,4)        
C        2) CHANGE THE DIMENSION OF ITM TO (40)        
C        3) CHANGE THE VALUE OF MAXITM IN THE DATA STATEMENT TO 40      
C        4) CHANGE THE INNER GROUPS ON FORMAT 80 TO 39(A1,1X),A1        
C        5) CHANGE THE INNER GROUP ON FORMAT 100 TO 39(A1,1X),A1        
C        
      EXTERNAL        LSHIFT,RSHIFT,ANDF        
      INTEGER         AVBLKS,BLANK,DITNSB,BUF,SSNAME(2),ANDF,SS,PS,CS,  
     1                HL,RSHIFT,DIRSIZ,SOFSIZ,DITSIZ,NUM(10),BLKSIZ,    
     2                HIBLK,FILSIZ,TYPE(5),ITM(27),HDR(27,4)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25,SWM*27        
      COMMON /XMSSG / UFM,UWM,UIM,SFM,SWM        
      COMMON /MACHIN/ MACH,IHALF        
CZZ   COMMON /SOFPTR/ BUF(1)        
      COMMON /ZZZZZZ/ BUF(1)        
      COMMON /SOF   / DIT,DITPBN,DITLBN,DITSIZ,DITNSB,DITBL        
      COMMON /SYS   / BLKSIZ,DIRSIZ,SUPSIZ,AVBLKS,HIBLK,IFRST        
      COMMON /SOFCOM/ NFILES,FILNAM(10),FILSIZ(10)        
      COMMON /SYSTEM/ SYSBUF,NOUT,Z1(6),NLPP,Y(2),LINE,Z2(26),NBPC,NBPW 
      COMMON /ITEMDT/ NITEM,ITEM(7,1)        
      DATA    TYPE  / 2HB , 2HC , 2HR , 2HM , 2HCM /        
      DATA    NUM   / 1H1, 1H2, 1H3, 1H4, 1H5, 1H6 ,1H7, 1H8, 1H9, 1H0 /
      DATA    BLANK / 4H     /        
      DATA    IMAGE / 4HI    /        
      DATA    NTYPE / 6      /        
      DATA    MAXITM/ 27     /        
C        
      NITM = NITEM        
      IF (NITM .LE. MAXITM) GO TO 10        
      NITM = MAXITM        
      WRITE  (NOUT,6237) SWM,MAXITM        
 6237 FORMAT (A27,' 6237, THE SOFTOC ROUTINE CAN HANDLE ONLY',I4,       
     1       ' ITEMS.', /34X,'ADDITIONAL ITEMS WILL NOT BE SHOWN')      
C        
C     SET UP HEADINGS AND MASKS        
C        
   10 NSHFT = 0        
      DO 30 I = 1,4        
      DO 20 J = 1,NITM        
   20 HDR(J,I) = KLSHFT(ITEM(1,J),NSHFT/NBPC)        
      K = NITM + 1        
      IF (K .GT. MAXITM) GO TO 30        
      DO 22 J = K,MAXITM        
   22 HDR(J,I) = BLANK        
   30 NSHFT = NSHFT + NBPC        
C        
      LINE  = NLPP + 1        
      M0009 = 1023        
      M1019 = LSHIFT(1023,10)        
      M2029 = LSHIFT(1023,20)        
      IMASK = LSHIFT(1,30)        
C        
C     LOOP THROUGH DIT        
C        
      DO 110 JMKN = 1,DITSIZ,2        
      I = (JMKN-1)/2 + 1        
      CALL FDIT (I,K)        
      SSNAME(1) = BUF(K  )        
      SSNAME(2) = BUF(K+1)        
      IF (SSNAME(1).EQ.BLANK .AND. SSNAME(2).EQ.BLANK) GO TO 110        
      CALL FMDI (I,K)        
C        
C     TEST TYPE BITS IN MDI        
C        
      DO 40 IT = 2,NTYPE        
      IBIT = ANDF(BUF(K+1),LSHIFT(1,31-IT))        
      IF (IBIT .NE. 0) GO TO 50        
   40 CONTINUE        
      IT = 1        
   50 IS = ANDF(BUF(K+1),IMASK)        
      IM = BLANK        
      IF (IS .NE. 0) IM = IMAGE        
      SS = RSHIFT(ANDF(BUF(K+1),M1019),10)        
      PS = ANDF(BUF(K+1),M0009)        
      LL = RSHIFT(ANDF(BUF(K+2),M2029),20)        
      CS = RSHIFT(ANDF(BUF(K+2),M1019),10)        
      HL = ANDF(BUF(K+2),M0009)        
C        
C     LOOP THROUGH MDI ENTRY FOR THIS SUBSTRUCTURE DETERMINING THE      
C     SIZE OF EACH EXISTING ITEM.        
C        
      DO 70 J = 1,NITM        
      JJ = J + IFRST - 1        
      IF (BUF(K+JJ) .EQ. 0) GO TO 60        
      INUM = RSHIFT(BUF(K+JJ),IHALF)*BLKSIZ        
      INUM = ALOG10(FLOAT(INUM)) + .3        
      ITM(J) = NUM(INUM)        
      IF (IS.NE.0 .AND. ITEM(4,J).EQ.0) ITM(J) = NUM(10)        
      IF (PS.NE.0 .AND. IS.EQ.0 .AND. ITEM(5,J).EQ.0) ITM(J) = NUM(10)  
      GO TO 70        
   60 ITM(J) = BLANK        
   70 CONTINUE        
C        
      LINE = LINE + 1        
      IF (LINE .LE. NLPP) GO TO 90        
      CALL PAGE1        
      LINE = LINE + 9 - 4        
      WRITE  (NOUT,80) HDR        
   80 FORMAT (//,26X,90HS U B S T R U C T U R E   O P E R A T I N G   F 
     1I L E   T A B L E   O F   C O N T E N T S , //,        
     1 1H ,51X,26(A1,2X),A1,/1H ,51X,26(A1,2X),A1,/1H ,51X,26(A1,2X),A1,
     2 /,1H ,4X,12HSUBSTRUCTURE,35X,26(A1,2X),A1, /1H ,4X,3HNO.,3X,4HNAM
     3E,4X,4HTYPE,3X,2HSS,3X,2HPS,3X,2HLL,3X,2HCS,3X,2HHL,4X,80(1H-)/)  
C        
   90 WRITE  (NOUT,100) I,SSNAME,IM,TYPE(IT),SS,PS,LL,CS,HL,        
     1                  (ITM(L),L=1,NITM)        
  100 FORMAT (2X,I6,2X,2A4,2X,A1,A2,5(1X,I4),4X,26(A1,2X),A1)        
  110 CONTINUE        
C        
C     PRINT SOF SPACE UTILIZATION MESSAGE        
C        
      LINE = LINE + 8        
      IF (LINE .GT. NLPP) CALL PAGE1        
      K    = SOFSIZ(K)        
      NBLK = 0        
      DO 115 I = 1,NFILES        
  115 NBLK = NBLK + FILSIZ(I)        
      IPER = (AVBLKS*100)/NBLK        
      WRITE  (NOUT,120) K,AVBLKS,IPER,HIBLK        
  120 FORMAT (//,51X,80HSIZE OF ITEM IS GIVEN IN POWERS OF TEN   (0 INDI
     1CATES DATA IS STORED IN PRIMARY) ,/,        
     2        26H0*** UNUSED SPACE ON SOF = ,I9,7H WORDS.  ,/,        
     3        22X,                   4HOR = ,I9,8H BLOCKS. ,/,        
     4        22X,                   4HOR = ,I9,9H PERCENT.,/,        
     5        26H0*** HIGHEST BLOCK USED  = ,I9)        
      LINE = NLPP        
      RETURN        
      END        
