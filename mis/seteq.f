      SUBROUTINE SETEQ (NAME1,NAME2,PREFX,DRY2,ITEST,IMORE,LIM)        
C        
C     SETS THE SUBSTRUCTURE NAME2 EQUIVALENT TO THE SUBSTRUCTURE NAME1. 
C     THE OUTPUT VARIABLE ITEST TAKES ON ONE OF THE FOLLOWING VALUES    
C        
C         4  IF NAME1 DOES NOT EXIST        
C         8  IF DRY DOES NOT EQUAL ZERO AND NAME2 OR ONE OF THE NEW     
C            NAMES ALREADY EXISTS        
C         9  IF DRY IS EQUAL TO ZERO AND NAME2 OR ONE OF THE NEW NAMES  
C            DOES NOT EXIST        
C         1  OTHERWISE        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF,COMPLF        
      LOGICAL         DITUP,MDIUP,MORE        
      DIMENSION       NAME1(2),NAME2(2),ISAVE(50),NAMNEW(2),        
     1                IMORE(1),NMSBR(2)        
      CHARACTER       UFM*23,UWM*25,UIM*29        
      COMMON /XMSSG / UFM,UWM,UIM        
      COMMON /MACHIN/ MACH,IHALF,JHALF        
CZZ   COMMON /SOFPTR/ BUF(1)        
      COMMON /ZZZZZZ/ BUF(1)        
      COMMON /SOF   / DIT,DITPBN,DITLBN,DITSIZ,DITNSB,DITBL,        
     1                IO ,IODUM(7),MDI,MDIPBN,MDILBN,MDIBL,        
     2                NXTDUM(15),DITUP,MDIUP        
      COMMON /SYS   / BLKSIZ,DIRSIZ,SYS(3),IFRST        
      COMMON /OUTPUT/ TITLE(96),SUBTIT(96)        
      COMMON /SYSTEM/ NBUFF,NOUT,DUM(36),NBPC,NBPW,NCPW        
      COMMON /ITEMDT/ NITEM,ITEM(7,1)        
      DATA    PS, SS, IB, LL, CS, HL, BB,   IRD, IWRT,  INDSBR  /       
     1        1 , 1 , 1 ,  2,  2,  2,  1,     1,    2,      15  /       
      DATA    IEMPTY, MASK,   NMSBR         /        
     2        4H    , 4HMASK, 4HSETE,4HQ    /        
C        
      CALL CHKOPN (NMSBR(1))        
      IF (NITEM+IFRST-1 .GT. 50) GO TO 970        
      DRY   = DRY2        
      ITEST = 1        
      CALL FDSUB (NAME1(1),IND1)        
      IF (IND1 .EQ. -1) GO TO 900        
      MASK   = ANDF(MASK,2**(NBPW-4*NBPC)-1)        
      MASKSS = COMPLF(LSHIFT(1023,10))        
      MASKLL = COMPLF(LSHIFT(1023,20))        
      MASKBB = LSHIFT(1023,20)        
C        
C     IF NAME2 EXISTS - VERIFY THAT IT IS MARKED EQUIVALENT TO NAME1.   
C     NAME2 MAY ALREADY EXIST FOR RUN=GO OR OPTIONS=PA        
C        
      CALL FDSUB (NAME2(1),IND2)        
      IF (IND2 .EQ. -1) GO TO 10        
      DRY = 0        
C        
      CALL FMDI (IND2,IMDI)        
      IPS = ANDF(BUF(IMDI+PS),1023)        
      IF (IPS .EQ.    0) GO TO 920        
      IF (IPS .EQ. IND1) GO TO 10        
      CALL FMDI (IND1,IMDI)        
      IPP = ANDF(BUF(IMDI+PS),1023)        
      IF (IPS .NE. IPP) GO TO 920        
C        
C     STEP 1.  MAKE A LIST OF ALL THE SUBSTRUCTURES CONTRIBUTING TO THE 
C     SUBSTRUCTURE NAME1, AND STORE IT IN THE ARRAY IMORE        
C        
   10 ITOP  = 1        
      IMORE(ITOP) = IND1        
      IPTR  = 1        
   20 CALL FMDI (IND1,IMDI)        
      I     = BUF(IMDI+LL)        
      INDLL = RSHIFT(ANDF(I,1073741823),20)        
      INDCS = RSHIFT(ANDF(I,1048575)   ,10)        
      IF (INDLL .EQ. 0) GO TO 40        
      DO 30 J = 1,ITOP        
      IF (IMORE(J) .EQ. INDLL) GO TO 40        
   30 CONTINUE        
      ITOP  = ITOP + 1        
      IF (ITOP .GT. LIM) GO TO 960        
      IMORE(ITOP) = INDLL        
   40 IF (INDCS.EQ.0 .OR. IPTR.EQ.1) GO TO 60        
      DO 50 J = 1,ITOP        
      IF (IMORE(J) .EQ. INDCS) GO TO 60        
   50 CONTINUE        
      ITOP  = ITOP + 1        
      IF (ITOP .GT. LIM) GO TO 960        
      IMORE(ITOP) = INDCS        
   60 IF (IPTR .EQ. ITOP) GO TO 100        
      IPTR  = IPTR + 1        
      IND1  = IMORE(IPTR)        
      GO TO 20        
C        
C     STEP 2.  CREATE AN IMAGE SUBSTRUCTURE FOR EACH SUBSTRUCTURE IN THE
C     ARRAY IMORE, AND STORE ITS INDEX IN THE ARRAY IMAGE.  NOTE THAT   
C     SINCE IMORE(1) CONTAINS THE INDEX OF NAME1, IMAGE(1) WILL CONTAIN 
C     THE INDEX OF NAME2        
C     FOR EACH NEW NAME CHECK THAT MAKING ROOM FOR THE PREFIX DOES NOT  
C     TRUNCATE THE NAME        
C        
  100 IF (IPTR .NE. 1) GO TO 110        
      CALL FDSUB (NAME2(1),I)        
      GO TO 120        
  110 CALL FDIT (IND1,IDIT)        
      FIRST = KLSHFT(KRSHFT(PREFX,NCPW-1),NCPW-1)        
      REST  = KLSHFT(KRSHFT(BUF(IDIT),NCPW-3),NCPW-4)        
      NAMNEW(1) = ORF(ORF(FIRST,REST),MASK)        
      FIRST = KLSHFT(KRSHFT(BUF(IDIT),NCPW-4),NCPW-1)        
      REST  = KLSHFT(KRSHFT(BUF(IDIT+1),NCPW-3),NCPW-4)        
      NAMNEW(2)= ORF(ORF(FIRST,REST),MASK)        
      IF (KHRFN1(IEMPTY,4,BUF(IDIT+1),4) .NE. IEMPTY)        
     1    WRITE (NOUT,850) UWM,NAMNEW,BUF(IDIT),BUF(IDIT+1)        
C     CALL PAGE2 (-3)        
      CALL FDSUB (NAMNEW(1),I)        
  120 IF (DRY .NE. 0) GO TO 130        
      IF (I   .NE.-1) GO TO 170        
      GO TO 910        
  130 IF (I .EQ. -1) GO TO 150        
      IPTR = IPTR + 1        
      IF (IPTR .GT. ITOP) GO TO 920        
      DO 140 I = IPTR,ITOP        
      IMAGE = IMORE(LIM+I)        
      CALL FDIT (IMAGE,IDIT)        
      BUF(IDIT  ) = IEMPTY        
      BUF(IDIT+1) = IEMPTY        
      DITUP = .TRUE.        
  140 CONTINUE        
      GO TO 920        
  150 IF (IPTR .NE. 1) GO TO 160        
      CALL CRSUB (NAME2(1),I)        
      GO TO 170        
  160 CALL CRSUB (NAMNEW(1),I)        
  170 IMORE(IPTR+LIM) = I        
      IF (IPTR .EQ. 1) GO TO 200        
      IPTR = IPTR - 1        
      IND1 = IMORE(IPTR)        
      GO TO 100        
C        
C     STEP 3.  BUILD THE MDI OF NAME2, AND OF ALL IMAGE SUBSTRUCTURES   
C        
  200 IND2 = I        
  210 CALL FMDI (IND1,IMDI)        
      DO 220 J = 1,DIRSIZ        
      ISAVE(J) = BUF(IMDI+J)        
  220 CONTINUE        
C        
C     SET THE SS ENTRY FOR THE SUBSTRUCTURE WITH INDEX IND1        
C        
      IF (DRY .EQ. 0) GO TO 230        
      BUF(IMDI+SS) = ORF(ANDF(BUF(IMDI+SS),MASKSS),LSHIFT(IND2,10))     
      MDIUP = .TRUE.        
  230 CALL FMDI (IND2,IMDI)        
      IF (DRY .EQ. 0) GO TO 420        
      I = ISAVE(PS)        
C        
C     SET THE PS ENTRY FOR THE SUBSTRUCTURE WITH INDEX IND2        
C        
      IPS = ANDF(I,1023)        
      IF (IPS .EQ. 0) GO TO 240        
      BUF(IMDI+PS) = IPS        
      GO TO 250        
  240 BUF(IMDI+PS) = IND1        
C        
C     SET THE SS ENTRY FOR THE SUBSTRUCTURE WITH INDEX IND2        
C        
  250 ISS = RSHIFT(ANDF(I,1048575),10)        
      IF (ISS .EQ. 0) GO TO 260        
      BUF(IMDI+SS) = ORF(ANDF(BUF(IMDI+SS),MASKSS),LSHIFT(ISS,10))      
C        
C     SET THE BB ENTRY FOR THE SUBSTRUCTURE WITH INDEX IND2        
C        
  260 IBS = ANDF(I,MASKBB)        
      BUF(IMDI+BB) = ORF(ANDF(BUF(IMDI+BB),MASKLL),IBS)        
      I = ISAVE(LL)        
C        
C     SET THE HL ENTRY FOR THE SUBSTRUCTURE WITH INDEX IND2        
C        
      IF (IPTR .EQ. 1) GO TO 300        
      IHL = ANDF(I,1023)        
      IF (IHL.EQ.0) GO TO 280        
      ASSIGN 270 TO IRET        
      IWANT = IHL        
      GO TO 320        
  270 BUF(IMDI+HL) = IFND        
C        
C     SET THE CS ENTRY FOR THE SUBSTRUCTURE WITH INDEX IND2        
C        
  280 ICS = RSHIFT(ANDF(I,1048575),10)        
      IF (ICS .EQ. 0) GO TO 300        
      ASSIGN 290 TO IRET        
      IWANT = ICS        
      GO TO 320        
  290 BUF(IMDI+CS) = ORF(ANDF(BUF(IMDI+CS),MASKSS),LSHIFT(IFND,10))     
C        
C     SET THE LL ENTRY FOR THE SUBSTRUCTURE WITH INDEX IND2        
C        
  300 ILL = RSHIFT(ANDF(I,1073741823),20)        
      IF (ILL .EQ. 0) GO TO 400        
      ASSIGN 310 TO IRET        
      IWANT = ILL        
      GO TO 320        
  310 BUF(IMDI+LL) = ORF(ANDF(BUF(IMDI+LL),MASKLL),LSHIFT(IFND,20))     
      GO TO 400        
C        
C     FIND THE INDEX OF THE IMAGE SUBSTRUCTURE TO THE SUBSTRUCTURE WITH 
C     INDEX IWANT.  STORE THE FOUND INDEX IN IFND        
C        
  320 DO 330 K = 1,ITOP        
      IF (IMORE(K) .NE. IWANT) GO TO 330        
      IFND = IMORE(LIM+K)        
      GO TO IRET, (270,290,310)        
  330 CONTINUE        
      GO TO 930        
C        
C     SET THE POINTERS OF THE ITEMS BELONGING TO THE SUBSTRUCTURE WITH  
C     INDEX IND2        
C        
  400 DO 410 J = IFRST,DIRSIZ        
  410 BUF(IMDI+J) = 0        
  420 IF (IPTR .EQ. 1) GO TO 440        
C        
C     IMAGE SUBSTRUCTURE - SET POINTERS TO SHARED ITEMS AND SET IB BIT  
C        
      DO 430 J = 1,NITEM        
      IF (ITEM(4,J) .NE. 0) GO TO 430        
      ITM = J + IFRST - 1        
      IF (BUF(IMDI+ITM) .EQ. 0) BUF(IMDI+ITM) = ISAVE(ITM)        
  430 CONTINUE        
      BUF(IMDI+IB) = ORF(BUF(IMDI+IB),LSHIFT(1,30))        
      GO TO 500        
C        
C     SECONDARY SUBSTRUCTURE - SET POINTERS TO SHARED ITEMS        
C        
  440 DO 450 J = 1,NITEM        
      IF (ITEM(5,J) .NE. 0) GO TO 450        
      ITM = J + IFRST - 1        
      IF (BUF(IMDI+ITM) .EQ. 0) BUF(IMDI+ITM) = ISAVE(ITM)        
  450 CONTINUE        
C        
C     COPY APPROPRIATE ITEMS OF NAME1 AND WRITE THEM FOR        
C     NAME2 AFTER CHANGING NAME1 TO NAME2 AND INSERTING THE NEW PREFIX  
C     TO THE NAMES OF ALL CONTRIBUTING SUBSTRUCTURES        
C        
  500 DO 700 J = 1,NITEM        
      IF (ITEM(3,J) .EQ. 0) GO TO 700        
      KK = J + IFRST - 1        
      IF (BUF(IMDI+KK) .NE. 0) GO TO 700        
      IRDBL = ANDF(ISAVE(KK),JHALF)        
      IF (IRDBL.NE.0 .AND. IRDBL.NE.JHALF) GO TO 510        
      BUF(IMDI+KK) = ISAVE(KK)        
      GO TO 700        
  510 CALL SOFIO (IRD,IRDBL,BUF(IO-2))        
      CALL FDIT (IND2,IDIT)        
      BUF(IO+1) = BUF(IDIT  )        
      BUF(IO+2) = BUF(IDIT+1)        
      CALL GETBLK (0,IWRTBL)        
      IF (IWRTBL .EQ. -1) GO TO 940        
      NEWBLK = IWRTBL        
      NUMB = ITEM(3,J)/1000000        
      MIN  = (ITEM(3,J) - NUMB*1000000)/1000        
      INC  = ITEM(3,J) - NUMB*1000000 - MIN*1000        
      NUMB = BUF(IO+NUMB)        
      IF (NUMB.GT.1 .OR. ILL.NE.0 .OR. IPTR.NE.1) GO TO 530        
C        
C     BASIC SUBSTRUCTURE        
C        
      BUF(IO+MIN  ) = NAME2(1)        
      BUF(IO+MIN+1) = NAME2(2)        
      MORE = .FALSE.        
      GO TO 580        
C        
C     NOT A BASIC SUBSTRUCTURE        
C        
  530 IF (NUMB .LE. (BLKSIZ-MIN+1)/INC) GO TO 540        
      NUMB = NUMB - (BLKSIZ-MIN+1)/INC        
      MAX  = BLKSIZ        
      MORE = .TRUE.        
      GO TO 550        
  540 MAX  = MIN + INC*NUMB - 1        
      MORE = .FALSE.        
C        
C     INSERT THE NEW PREFIX TO THE NAMES OF ALL CONTRIBUTING SUBSTRUC-  
C     TURES        
C     IF THE COMPONENT IS FOR MODAL DOF ON THE SECONDARY SUBSTRUCTURE,  
C     USE THE ACTUAL NAME INSTEAD OF ADDING A PREFIX        
C        
  550 DO 570 K = MIN,MAX,INC        
      IF (BUF(IO+K).EQ.NAME1(1) .AND. BUF(IO+K+1).EQ.NAME1(2))        
     1    GO TO 560        
      FIRST = KLSHFT(KRSHFT(PREFX,NCPW-1),NCPW-1)        
      REST  = KLSHFT(KRSHFT(BUF(IO+K  ),NCPW-3),NCPW-4)        
      FIRST2= KLSHFT(KRSHFT(BUF(IO+K  ),NCPW-4),NCPW-1)        
      REST2 = KLSHFT(KRSHFT(BUF(IO+K+1),NCPW-3),NCPW-4)        
      BUF(IO+K  ) = ORF(ORF(FIRST ,REST ),MASK)        
      BUF(IO+K+1) = ORF(ORF(FIRST2,REST2),MASK)        
      GO TO 570        
C        
  560 BUF(IO+K  ) = NAME2(1)        
      BUF(IO+K+1) = NAME2(2)        
  570 CONTINUE        
C        
C     WRITE OUT UPDATED DATA BLOCK        
C        
  580 CALL SOFIO (IWRT,IWRTBL,BUF(IO-2))        
      CALL FNXT (IRDBL,INXT)        
      IF (MOD(IRDBL,2) .EQ. 1) GO TO 590        
      NEXT = ANDF(RSHIFT(BUF(INXT),IHALF),JHALF)        
      GO TO 600        
  590 NEXT = ANDF(BUF(INXT),JHALF)        
  600 IF (NEXT .EQ. 0) GO TO 620        
C        
C     MORE BLOCKS TO COPY        
C        
      IRDBL = NEXT        
      CALL GETBLK (IWRTBL,NEXT)        
      IF (NEXT.NE.-1) GO TO 610        
      CALL RETBLK (NEWBLK)        
      GO TO 940        
  610 IWRTBL = NEXT        
      CALL SOFIO (IRD,IRDBL,BUF(IO-2))        
      MIN = 1        
      IF (MORE) GO TO 530        
      GO TO 580        
C        
C     NO MORE BLOCKS TO COPY.  UPDATE MDI OF NAME2        
C        
  620 BUF(IMDI+KK) = ORF(LSHIFT(RSHIFT(ISAVE(KK),IHALF),IHALF),NEWBLK)  
  700 CONTINUE        
C        
      MDIUP = .TRUE.        
      IF (IPTR .EQ. ITOP) GO TO 720        
      IPTR = IPTR + 1        
      IND1 = IMORE(IPTR    )        
      IND2 = IMORE(IPTR+LIM)        
      GO TO 210        
C        
C     WRITE USER MESSAGES        
C        
  720 IF(DRY .EQ. 0) GO TO 780        
      DO 730 I = 1,96        
  730 SUBTIT(I) = IEMPTY        
      CALL PAGE        
      CALL PAGE2 (-4)        
      WRITE (NOUT,800) NAME2,NAME1        
      IMAGE = IMORE(LIM+1)        
      CALL FMDI (IMAGE,IMDI)        
      IPS = ANDF(BUF(IMDI+1),1023)        
      CALL FDIT (IPS,I)        
      CALL PAGE2 (-2)        
      WRITE (NOUT,810) NAME2,BUF(I),BUF(I+1)        
      IPTR = 2        
      IF (IPTR .GT. ITOP) GO TO 990        
      CALL PAGE2 (-2)        
      WRITE (NOUT,820)        
  740 DO 750 I = 1,16        
  750 IMORE(I) = IEMPTY        
      J = 1        
  760 IMAGE = IMORE(IPTR+LIM)        
      CALL FDIT (IMAGE,I)        
      IMORE(J  ) = BUF(I  )        
      IMORE(J+1) = BUF(I+1)        
      IPTR = IPTR + 1        
      IF (IPTR .GT. ITOP) GO TO 770        
      J = J + 2        
      IF (J .LT. 16) GO TO 760        
  770 CALL PAGE2 (-2)        
      WRITE (NOUT,830) (IMORE(J),J=1,16)        
      IF (IPTR .LE. ITOP) GO TO 740        
      GO TO 990        
C        
C     DRY RUN - PRINT MESSAGE INDICATING ONLY ADDITIONS MADE        
C        
  780 CALL PAGE2 (-3)        
      WRITE (NOUT,840) UIM,NAME2,NAME1,NAME2        
      GO TO 990        
C        
  800 FORMAT (32X,67HS U B S T R U C T U R E   E Q U I V A L E N C E   O
     1 P E R A T I O N ,///23X,13HSUBSTRUCTURE ,2A4,56H HAS BEEN CREATED
     2 AND MARKED EQUIVALENT TO SUBSTRUCTURE ,2A4)        
  810 FORMAT (1H0,22X,28HTHE PRIMARY SUBSTRUCTURE OF ,2A4,4H IS ,2A4)   
  820 FORMAT (1H0,22X, 56HTHE FOLLOWING IMAGE SUBSTRUCTURES HAVE BEEN GE
     1NERATED --)        
  830 FORMAT (1H0,22X,10(2A4,2X))        
  840 FORMAT (A29,' 6228, SUBSTRUCTURE ',2A4,' IS ALREADY AN EQUIVALENT'
     1,      ' SUBSTRUCTURE TO ',2A4, /36X,'ONLY ITEMS NOT PREVIOUSLY ',
     2       'EXISTING FOR ',2A4,' HAVE BEEN MADE EQUIVALENT.')        
  850 FORMAT (A25,' 6236, DURING THE CREATION OF A NEW IMAGE SUBSTRUC', 
     1       'TURE NAMED ',2A4,' THE LAST CHARACTER ', /5X,        
     2       'OF SUBSTRUCTURE NAMED ',2A4,' WAS TRUNCATED TO MAKE ROOM',
     3       ' FOR THE PREFIX.')        
C        
C     ERROR CONDITIONS        
C        
  900 ITEST = 4        
      GO TO 990        
  910 ITEST = 9        
      GO TO 990        
  920 ITEST = 8        
      GO TO 990        
  930 CALL ERRMKN (INDSBR,3)        
  940 WRITE  (NOUT,950) UFM        
  950 FORMAT (A23,' 6223, SUBROUTINE SETEQ - THERE ARE NO MORE FREE ',  
     1        'BLOCKS AVAILABLE ON THE SOF.')        
      K = -37        
      GO TO 980        
  960 K = -8        
      GO TO 980        
  970 CALL ERRMKN (INDSBR,10)        
  980 CALL SOFCLS        
      CALL MESAGE (K,0,NMSBR)        
C        
  990 RETURN        
      END        
