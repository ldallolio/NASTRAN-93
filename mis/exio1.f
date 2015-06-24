      SUBROUTINE EXIO1        
C        
C     EXIO1 SERVICES INTERNAL FORMAT FUNCTIONS FOR EXIO.        
C        
      EXTERNAL LSHIFT   ,RSHIFT   ,ANDF     ,ORF        
      LOGICAL  FIRST    ,OPNSOF   ,DITUP    ,MDIUP    ,NXTUP     ,      
     1         NXTRST   ,TAPBIT        
      INTEGER  DRY      ,COR(1)   ,DEVICE   ,UNAME    ,POS       ,      
     1         DATYPE   ,PDATE    ,PTIME    ,TIME     ,SEC       ,      
     2         HOURS    ,SSNAME   ,SAVREC   ,HDREC    ,REWI2     ,      
     3         BUF      ,SYSBUF   ,DATE     ,RD       ,RDREW     ,      
     4         WRT      ,WRTREW   ,REW      ,EOFNRW   ,FILNAM    ,      
     5         FILSIZ   ,STATUS   ,PASSWD   ,BLKSIZ   ,DIRSIZ    ,      
     6         SUPSIZ   ,AVBLKS   ,DIT      ,DITPBN   ,DITLBN    ,      
     7         DITSIZ   ,DITNSB   ,DITBL    ,Z        ,TAPE      ,      
     8         DISK     ,SOFIN    ,SOFOUT   ,CHECK    ,APPEND    ,      
     9         COMPRS   ,REWI     ,EQF      ,ALL      ,TABLES    ,      
     O         PHASE3   ,DUMP     ,RESTOR   ,WHOLE(2) ,XITEMS(50),      
     1         SUBR(2)  ,BLANK    ,SOF      ,EOI      ,HDR       ,      
     2         Q        ,QQQQ     ,XXXX     ,SCR1     ,SRD       ,      
     3         SWRT     ,RSHIFT   ,ANDF     ,SOFSIZ   ,ORF       ,      
     4         BUF1     ,BUF2     ,BUF3     ,BUF4     ,UNIT      ,      
     5         RC       ,FLAG     ,OLDTSZ   ,BUF5     ,SCR2      ,      
     6         HEAD1    ,HEAD2    ,INBLK(15),OUTBLK(15)        
      CHARACTER          UFM*23   ,UWM*25   ,UIM*29   ,SFM*25    ,      
     1                   SWM*27   ,SIM*31        
      COMMON  /XMSSG /   UFM      ,UWM      ,UIM      ,SFM       ,      
     1                   SWM      ,SIM        
      COMMON  /MACHIN/   MACH     ,IHALF    ,JHALF        
      COMMON  /BLANK /   DRY      ,XMACH    ,DEVICE(2),UNAME(2)  ,      
     1                   FORMT(2) ,MODE(2)  ,POS(2)   ,DATYPE(2) ,      
     2                   NAMES(10),PDATE    ,PTIME    ,TIME(3)   ,      
     3                   SSNAME(2),SAVREC(9),HDREC(10),BUF(10)        
      COMMON  /SYSTEM/   SYSBUF   ,NOUT     ,X1(6)    ,NLPP      ,      
     1                   X2(2)    ,LINE     ,X3(2)    ,DATE(3)   ,      
     2                   X4(21)   ,NBPC     ,NBPW     ,NCPW        
      COMMON  /NAMES /   RD       ,RDREW    ,WRT      ,WRTREW    ,      
     1                   REW      ,NOREW    ,EOFNRW        
      COMMON  /SOFCOM/   NFILES   ,FILNAM(10)         ,FILSIZ(10),      
     1                   STATUS   ,PASSWD(2),FIRST    ,OPNSOF        
      COMMON  /SYS   /   BLKSIZ   ,DIRSIZ   ,SUPSIZ   ,AVBLKS    ,      
     1                   NOBLKS   ,IFRST        
      COMMON  /ITEMDT/   NITEM    ,ITEMS(7,1)        
      COMMON  /OUTPUT/   HEAD1(96),HEAD2(96)        
      COMMON  /SOF   /   DIT      ,DITPBN   ,DITLBN   ,DITSIZ    ,      
     1                   DITNSB   ,DITBL    ,IO       ,IOPBN     ,      
     2                   IOLBN    ,IOMODE   ,IOPTR    ,IOSIND    ,      
     3                   IOITCD   ,IOBLK    ,MDI      ,MDIPBN    ,      
     4                   MDILBN   ,MDIBL    ,NXT      ,NXTPBN    ,      
     5                   NXTLBN   ,NXTTSZ   ,NXTFSZ(10)          ,      
     6                   NXTCUR   ,DITUP    ,MDIUP    ,NXTUP     ,      
     7                   NXTRST        
CZZ   COMMON  /ZZEXO1/   Z(1)        
      COMMON  /ZZZZZZ/   Z(1)        
CZZ   COMMON  /SOFPTR/   COR        
      EQUIVALENCE        (COR(1)  ,Z(1))        
      EQUIVALENCE        (TIME(1) ,HOURS)   ,(TIME(2) ,MIN)      ,      
     1                   (TIME(3) ,SEC)        
      DATA     TAPE     ,DISK     ,SOFIN    ,SOFOUT   ,CHECK     /      
     1         4HTAPE   ,4HDISK   ,4HSOFI   ,4HSOFO   ,4HCHEC    /,     
     2         APPEND   ,COMPRS   ,NOREWI   ,REWI     ,EQF       /      
     3         4HAPPE   ,4HCOMP   ,4HNORE   ,4HREWI   ,4HEOF     /,     
     4         ALL      ,MATRIC   ,TABLES   ,PHASE3   ,DUMP      /      
     5         4HALL    ,4HMATR   ,4HTABL   ,4HPHAS   ,4HDUMP    /,     
     6         RESTOR   ,WHOLE              ,REWI2               /      
     8         4HREST   ,4HWHOL   ,4HESOF   ,4HND                /,     
     9         SUBR               ,BLANK    ,SOF      ,EOI       /      
     O         4HEXIO   ,4H1      ,4H       ,4HSOF    ,4HEOI     /,     
     1         ID       ,HDR      ,Q        ,QQQQ     ,XXXX      /      
     2         4H$ID$   ,4H$HD$   ,4HQ      ,4HQQQQ   ,4HXXXX    /      
      DATA     SCR1     ,SCR2     ,SRD      ,SWRT     ,IZ2       /      
     1         301      ,302      ,1        ,2        ,2         /      
C        
C     INITIALIZE        
C        
      IF (NITEM .GT. 50) CALL ERRMKN (25,10)        
      LCORE = KORSZ(Z)        
      BUF1  = LCORE- SYSBUF + 1        
      BUF2  = BUF1 - SYSBUF - 1        
      BUF3  = BUF2 - SYSBUF        
      BUF4  = BUF3 - SYSBUF        
      BUF5  = BUF4 - SYSBUF        
      LCORE = BUF5 - 1        
      NCORE = LCORE        
      NOS   = 0        
      IDM   = 1        
      IF (LCORE .LE. 0) CALL MESAGE (-8,0,SUBR)        
      IF (MODE(1) .NE. RESTOR) CALL SOFOPN (Z(BUF1),Z(BUF2),Z(BUF3))    
      UNIT  = UNAME(1)        
C        
C     CHECK TAPE BIT IF DEVICE=TAPE        
C        
      IF (DEVICE(1) .EQ. DISK .OR. MODE(1) .EQ. COMPRS .OR.        
     1    MODE(1) .EQ. APPEND) GO TO 10        
      IF (DEVICE(1) .NE. TAPE) GO TO 1810        
      IF (.NOT.  TAPBIT(UNIT)) GO TO 1800        
C        
C     SET REWIND VARIABLE        
C        
C     IF SOFOUT COMMAND POSITION TO END-OF-FILE IF REQUESTED        
C        
C     IF POSITION = REWIND AND WE ARE WRITING THEN BCKREC OVER LAST EOF 
C        
C     IF POSITION = EOF AND WE ARE WRITING THEN BCKREC FIRST TO INSURE  
C     WE ARE INFRONT OF AND EOF AND THEN SEARCH FOR EOF        
C        
   10 IPOS = -1        
      IF (POS(1).EQ.NOREWI .OR. POS(1).EQ.EQF) IPOS = 2        
      IF (POS(1) .EQ. REWI) IPOS = 0        
      IF (IPOS .LT. 0) GO TO 1830        
      IF (MODE(1).EQ.DUMP .OR. MODE(1).EQ.RESTOR) IPOS = 0        
      IF (IPOS .NE. 0) GO TO 20        
      HEAD2(13) = REWI        
      HEAD2(14) = REWI2        
   20 IF (MODE(1) .NE. SOFOUT) GO TO 60        
      IF (IPOS .EQ. 0) GO TO 60        
      CALL OPEN (*1860,UNIT,Z(BUF4),RD)        
      CALL BCKREC (UNIT)        
      IF (POS(1) .EQ. NOREWI) GO TO 50        
   30 CALL FWDREC (*40,UNIT)        
      GO TO 30        
   40 CALL BCKREC (UNIT)        
   50 CALL CLOSE (UNIT,NOREW)        
C        
C     BRANCH ON MODE OF OPERATION        
C        
   60 IF (MODE(1).EQ.SOFOUT .OR. MODE(1).EQ.  DUMP) GO TO 70        
      IF (MODE(1).EQ.SOFIN  .OR. MODE(1).EQ.RESTOR) GO TO 370        
      IF (MODE(1) .EQ. CHECK ) GO TO 1160        
      IF (MODE(1) .EQ. APPEND) GO TO 1220        
      IF (MODE(1) .EQ. COMPRS) GO TO 1500        
      GO TO 1820        
C        
C        
C     **********************   W R I T E   **********************       
C        
C     OPEN FILE AND WRITE 9 WORD ID RECORD        
C        
   70 CALL OPEN (*1860,UNIT,Z(BUF4),WRTREW+IPOS)        
      CALL WALTIM (SEC)        
      HOURS= SEC/3600        
      SEC  = MOD(SEC,3600)        
      MIN  = SEC/60        
      SEC  = MOD(SEC,60)        
      HDREC(1) = ID        
      HDREC(2) = PASSWD(1)        
      HDREC(3) = PASSWD(2)        
      DO 80 I = 1,3        
      HDREC(I+3) = DATE(I)        
      HDREC(I+6) = TIME(I)        
   80 CONTINUE        
      CALL WRITE (UNIT,HDREC,9,1)        
      CALL PAGE        
      WRITE (NOUT,2120) UIM,PASSWD,DATE,TIME        
      LINE = LINE + 1        
C        
C     WRITE DIT AND MDI CONTROL WORDS        
C        
      N = DITSIZ/2        
      CALL WRITE (UNIT,N,1,0)        
      DO 90 I = 1,N        
      CALL FDIT(I,J)        
      CALL WRITE (UNIT,COR(J),2,0)        
      CALL FMDI  (I,J)        
      CALL WRITE (UNIT,COR(J+1),2,0)        
   90 CONTINUE        
      CALL WRITE (UNIT,0,0,1)        
      CALL WRITE (UNIT,EOI,1,1)        
      IF (MODE(1) .NE. DUMP) GO TO 110        
C        
C        
C     DUMP FORM --        
C        
C     COPY OUT ALL SOF SUPERBLOCKS WHICH HAVE BEEN USED WITHOUT REGARD  
C     TO THE DATA SEQUENCE OR CONTENT.        
C        
C        
      DO 100 I = 1,NOBLKS        
      CALL SOFIO (SRD,I,Z(BUF1))        
      CALL WRITE (UNIT,Z(BUF1+3),BLKSIZ,0)        
  100 CONTINUE        
      CALL WRITE (UNIT,0,0,1)        
      CALL CLOSE (UNIT,REW)        
      WRITE (NOUT,2130) UIM,NOBLKS,NXTTSZ,UNAME        
      GO TO 1740        
C        
C     STANDARD FORM --        
C        
C     COPY OUT EACH SUBSTRUCTURE/ITEM WITH ITS DATA IN THE CORRECT      
C     SEQUENCE.        
C        
C     SETUP THE ARRAY XITEMS OF NAMES OF ITEMS TO BE COPIED.        
C        
  110 IF (DATYPE(1) .NE. ALL) GO TO 130        
      NITEMS = NITEM        
      DO 120 I = 1,NITEM        
  120 XITEMS(I) = ITEMS(1,I)        
      GO TO 200        
  130 IF (DATYPE(1) .NE. TABLES) GO TO 150        
      NITEMS = 0        
      DO 140 I = 1,NITEM        
      IF (ITEMS(2,I) .GT. 0) GO TO 140        
      NITEMS = NITEMS + 1        
      XITEMS(NITEMS) = ITEMS(1,I)        
  140 CONTINUE        
      GO TO 200        
  150 IF (DATYPE(1) .NE. MATRIC) GO TO 170        
      NITEMS = 0        
      DO 160 I = 1,NITEM        
      IF (ITEMS(2,I) .LE. 0) GO TO 160        
      NITEMS = NITEMS + 1        
      XITEMS(NITEMS) = ITEMS(1,I)        
  160 CONTINUE        
      GO TO 200        
  170 IF (DATYPE(1) .NE. PHASE3) GO TO 190        
      NITEMS = 0        
      DO 180 I = 1,NITEM        
      IF (ANDF(ITEMS(7,I),8) .EQ. 0) GO TO 180        
      NITEMS = NITEMS + 1        
      XITEMS(NITEMS) = ITEMS(1,I)        
  180 CONTINUE        
      GO TO 200        
  190 NITEMS = 2        
      XITEMS(1) = DATYPE(1)        
      XITEMS(2) = DATYPE(2)        
      IF (XITEMS(2) .EQ. BLANK) NITEMS = 1        
C        
C     LOOP OVER SUBSTRUCTURE NAMES.  FOR EACH SUBSTRUCTURE, WRITE OUT   
C     THE NITEMS IN XITEMS.        
C        
  200 ISS = 0        
  210 ISS = ISS + 1        
      IF (NAMES(1).NE.WHOLE(1) .OR. NAMES(2).NE.WHOLE(2)) GO TO 220     
C        
C     WRITE ALL SUBSTRUCTURES IN THE RESIDENT SOF.        
C        
      IF (ISS .GT. DITSIZ/2) GO TO 360        
      CALL FDIT (ISS,I)        
      IF (COR(I) .EQ. BLANK) GO TO 210        
      SSNAME(1) = COR(I  )        
      SSNAME(2) = COR(I+1)        
      GO TO 230        
C        
C     WRITE ONLY THOSE SUBSTRUCTURES IN THE PARAMETER LIST        
C        
  220 IF (ISS .GT. 5) GO TO 360        
      IF (NAMES(2*ISS-1) .EQ. XXXX) GO TO 210        
      SSNAME(1) = NAMES(2*ISS-1)        
      SSNAME(2) = NAMES(2*ISS  )        
C        
C     LOOP OVER ALL ITEMS OF THIS SUBSTRUCTURE.        
C        
  230 DO 350 ITEM = 1,NITEMS        
      KDH = ITTYPE(XITEMS(ITEM))        
      IF (KDH .EQ. 1) GO TO 260        
      CALL SFETCH (SSNAME,XITEMS(ITEM),SRD,RC)        
      GO TO (260,240,350,250,250), RC        
  240 LINE = LINE + 2        
      IF (LINE .GT. NLPP) CALL PAGE        
      WRITE (NOUT,2160) UWM,SSNAME,XITEMS(ITEM)        
      GO TO 350        
  250 LINE = LINE+2        
      IF (LINE .GT. NLPP) CALL PAGE        
      CALL SMSG (RC-2,XITEMS(ITEM),SSNAME)        
      GO TO 350        
C        
C     WRITE SUBSTRUCTURE/ITEM HEADER RECORD        
C        
  260 CALL WALTIM (SEC)        
      HOURS = SEC/3600        
      SEC   = MOD(SEC,3600)        
      MIN   = SEC/60        
      SEC   = MOD(SEC,60)        
      HDREC(1) = HDR        
      HDREC(2) = SSNAME(1)        
      HDREC(3) = SSNAME(2)        
      HDREC(4) = XITEMS(ITEM)        
      DO 270 I = 1,3        
      HDREC(I+4) = DATE(I)        
      HDREC(I+7) = TIME(I)        
  270 CONTINUE        
      IF (KDH .EQ. 1) GO TO 310        
      CALL WRITE (UNIT,HDREC,10,1)        
C        
C     COPY DATA        
C        
  280 CALL SUREAD (Z(1),LCORE,NWDS,RC)        
      GO TO (290,300,340), RC        
  290 CALL WRITE (UNIT,Z,LCORE,0)        
      GO TO 280        
  300 CALL WRITE (UNIT,Z,NWDS,1)        
      GO TO 280        
C        
C     COPY MATRIX DATA ITEMS        
C        
  310 IFILE = SCR1        
      CALL MTRXI (SCR1,SSNAME,XITEMS(ITEM),0,RC)        
      GO TO (320,240,350,250,250,2010), RC        
  320 CALL WRITE (UNIT,HDREC,10,1)        
      Z(1) = SCR1        
      CALL RDTRL (Z(1))        
      CALL WRITE (UNIT,Z(IZ2),6,1)        
      CALL OPEN  (*2010,SCR1,Z(BUF5),RDREW)        
      CALL CPYFIL(SCR1,UNIT,Z,LCORE,ICOUNT)        
      CALL CLOSE (SCR1,1)        
C        
C     WRITE END-OF-ITEM RECORD AND USER MESSAGE        
C        
  340 CALL WRITE (UNIT,EOI,1,1)        
      LINE = LINE + 1        
      IF (LINE .GT. NLPP) CALL PAGE        
      WRITE (NOUT,2170) UIM,SSNAME,XITEMS(ITEM),SOF,UNIT,DATE,TIME      
  350 CONTINUE        
C        
C     BOTTOM OF LOOP OVER SUBSTRUCTURES        
C        
      GO TO 210        
C        
C     ALL SUBSTRUCTURE/ITEMS HAVE NOW BEEN COPIED.  CLOSE WITH EOF AND  
C     NO REWIND (IN CASE MORE DATA TO FOLLOW).        
C        
C     WRITE EOF FOR NOU BECAUSE LEVEL 16 GINO OPT=3 DOESN T AS        
C     ADVERTISED        
C        
  360 CALL EOF (UNIT)        
      CALL CLOSE (UNIT,EOFNRW)        
      GO TO 1740        
C        
C     ***********************   R E A D  ************************       
C        
C     BRANCH FOR RESTORE OR STANDARD READ        
C        
  370 IF (MODE(1) .NE. RESTOR) GO TO 400        
C        
C     RESTORE FORM --        
C        
C     COPY EACH LOGICAL RECORD ON THE EXTERNAL FILE INTO CONSEQUTIVE,   
C     CONTIGUOUS BLOCKS ON THE RESIDENT SOF.        
C        
C     MAKE SURE THE RESIDENT SOF IS EMPTY.        
C        
      IF (STATUS .NE. 0) GO TO 1840        
      CALL SOFOPN (Z(BUF1),Z(BUF2),Z(BUF3))        
      CALL SOFCLS        
C        
C     OPEN FILE AND READ THE ID RECORD        
C        
      CALL OPEN (*1860,UNIT,Z(BUF4),RDREW)        
      CALL READ (*1850,*1850,UNIT,HDREC,9,1,FLAG)        
      IF (HDREC(1) .NE. ID) GO TO 1850        
      CALL PAGE        
      LINE = LINE+1        
      WRITE (NOUT,2120) UIM,(HDREC(I),I=2,9)        
      CALL FWDREC (*1870,UNIT)        
      CALL FWDREC (*1870,UNIT)        
C        
C     BEGIN DATA TRANSFER        
C        
      I = 1        
  380 CALL READ (*1870,*390,UNIT,Z(BUF1+3),BLKSIZ,0,FLAG)        
      CALL SOFIO (SWRT,I,Z(BUF1))        
      I = I+1        
      GO TO 380        
C        
C     RESTORE COMPLETE.  CLOSE FILE AND GIVE USER THE NEWS.        
C        
  390 CALL CLOSE (UNIT,REW)        
      I = I - 1        
      WRITE (NOUT,2200) UIM,I        
      GO TO 1750        
C        
C     STANDARD FORM -        
C        
C     COPY IN EACH INDIVIDUAL SUBSTRUCTURE/ITEM.        
C        
  400 ISS = 0        
C        
C     SETUP ARRAY OF NAMES OF ITEMS TO BE COPIED.        
C        
      IF (DATYPE(1) .NE. ALL) GO TO 420        
      NITEMS = NITEM        
      DO 410 I = 1,NITEM        
  410 XITEMS(I) = ITEMS(1,I)        
      GO TO 490        
  420 IF (DATYPE(1) .NE. TABLES) GO TO 440        
      NITEMS = 0        
      DO 430 I = 1,NITEM        
      IF (ITEMS(2,I) .GT. 0) GO TO 430        
      NITEMS = NITEMS + 1        
      XITEMS(NITEMS) = ITEMS(1,I)        
  430 CONTINUE        
      GO TO 490        
  440 IF (DATYPE(1) .NE. MATRIC) GO TO 460        
      NITEMS = 0        
      DO 450 I = 1,NITEM        
      IF (ITEMS(2,I) .LE. 0) GO TO 450        
      NITEMS = NITEMS + 1        
      XITEMS(NITEMS) = ITEMS(1,I)        
  450 CONTINUE        
      GO TO 490        
  460 IF (DATYPE(1) .NE. PHASE3) GO TO 480        
      NITEMS = 0        
      DO 470 I = 1,NITEM        
      IF (ANDF(ITEMS(7,I),8) .EQ. 0) GO TO 470        
      NITEMS = NITEMS + 1        
      XITEMS(NITEMS) = ITEMS(1,I)        
  470 CONTINUE        
      GO TO 490        
  480 NITEMS = 2        
      XITEMS(1) = DATYPE(1)        
      XITEMS(2) = DATYPE(2)        
      IF (XITEMS(2) .EQ. BLANK) NITEMS = 1        
C        
C     DETERMINE NUMBER OF SUBSTRUCTURE/ITEMS TO BE COPIED AND INITIALIZE
C     COUNTER.        
C        
  490 JCOPY = 0        
      NCOPY = 0        
      IF (NAMES(1).EQ.WHOLE(1) .AND. NAMES(2).EQ.WHOLE(2)) GO TO 510    
      DO 500 I = 1,5        
      IF (NAMES(2*I-1) .NE. XXXX) NCOPY = NCOPY + 1        
  500 CONTINUE        
      NCOPY = NCOPY*NITEMS        
      IF (PDATE .NE. 0) NCOPY = 1        
C        
C     OPEN THE EXTERNAL FILE AND READ THE IDENTIFICATION OR HEADER      
C     RECORD.        
C     REMEMBER IT IN CASE THE USER HAS REQUESTED A SUBSTRUCTURE/ITEM    
C     WHICH IS NOT PRESENT ON THE FILE.        
C        
  510 CALL PAGE        
      CALL OPEN (*1860,UNIT,Z(BUF4),RDREW+IPOS)        
  520 CALL READ (*530,*540,UNIT,HDREC,10,1,LREC1)        
      LREC1 = 10        
      GO TO 540        
  530 CALL REWIND (UNIT)        
      GO TO 520        
  540 DO 550 I = 1,LREC1        
  550 BUF(I) = HDREC(I)        
      IF (HDREC(1) .NE.  ID) GO TO 560        
      GO TO 610        
  560 IF (HDREC(1) .NE. HDR) GO TO 1850        
      GO TO 610        
C        
C     SCAN THROUGH THE EXTERNAL TAPE.  FOR EACH SUBSTRUCTURE/ITEM       
C     ENCOUNTERED, CHECK TO SEE IF IT SHOULD BE READ.  THEN, EITHER     
C     READ OR SKIP IT.        
C        
C     FOR EACH SUBSTRUCTURE/ITEM WHICH IS READ, SAVE THE HEADER RECORD  
C     IN OPEN CORE.  WHEN DUPLICATES ARE FOUND, AND THE DATE AND TIME   
C     PARAMETERS HAVE NOT BEEN SET, ISSUE A WARNING AND USE THE MOST    
C     RECENT.        
C        
C     IF THE DATE AND TIME PARAMETERS ARE NON-ZERO, READ ONLY THE       
C     SUBSTRUCTURE/ITEM WHICH HAS MATCHING VALUES AND IGNORE THE        
C     SUBSTRUCTURE AND ITEM NAME PARAMETERS.        
C        
C     READ AN IDENTIFICATION OR HEADER RECORD        
C        
  570 CALL READ (*580,*590,UNIT,BUF,10,1,FLAG)        
      GO TO 590        
  580 IF (NAMES(1).EQ.WHOLE(1) .AND. NAMES(2).EQ.WHOLE(2)) GO TO 1150   
      CALL REWIND (UNIT)        
      GO TO 570        
C        
C     CHECK IT AGAINST THE FIRST RECORD READ.  IF IT MATCHES, THE ENTIRE
C     TAPE HAS BEEN SCANNED, BUT NOT ALL ITEMS WERE FOUND.        
C        
  590 DO 600 I = 1,LREC1        
      IF (BUF(I) .NE. HDREC(I)) GO TO 610        
  600 CONTINUE        
      GO TO 1080        
C        
C     IF THAT WAS AN ID RECORD, ISSUE MESSAGE AND GO BACK TO READ THE   
C     IMMEDIATELY FOLLOWING HEADER RECORD.        
C        
  610 IF (BUF(1) .NE. ID) GO TO 620        
C        
C     READ OLD DIT AND MDI DATA        
C        
      CALL READ (*1870,*1880,UNIT,NOS,1,0,FLAG)        
      LCORE= NCORE - 4*NOS        
      IDM  = LCORE + 1        
      IF (LCORE .LE. 0) GO TO 1890        
      NOS4 = NOS*4        
      CALL READ (*1870,*1880,UNIT,Z(IDM),NOS4,1,FLAG)        
      CALL FWDREC (*1870,UNIT)        
      LINE = LINE + 1        
      IF (LINE .GT. NLPP) CALL PAGE        
      WRITE (NOUT,2120) UIM,(BUF(I),I=2,9)        
      GO TO 570        
C        
C     READ OR SKIP THE SUBSTRUCTURE/ITEM DATA.        
C        
  620 IF (PDATE .NE. 0) GO TO 820        
      IF (NAMES(1).EQ.WHOLE(1) .AND. NAMES(2).EQ.WHOLE(2)) GO TO 680    
      DO 630 I = 1,5        
      IF (NAMES(2*I-1) .EQ. XXXX) GO TO 630        
      IF (BUF(2).EQ.NAMES(2*I-1) .AND. BUF(3).EQ.NAMES(2*I)) GO TO 640  
  630 CONTINUE        
      GO TO 660        
  640 DO 650 I = 1,NITEMS        
      IF (BUF(4) .EQ. XITEMS(I)) GO TO 680        
  650 CONTINUE        
C        
C     SKIP -        
C        
  660 CALL RECTYP (UNIT,IREC)        
      IF (IREC .EQ. 0) GO TO 670        
C        
C     STRING RECORD - SKIP IT        
C        
      CALL FWDREC (*1870,UNIT)        
      GO TO 660        
C        
C     NORMAL GINO RECORD - CHECK IF EOI        
C        
  670 CALL READ (*1870,*660,UNIT,I,1,1,FLAG)        
      IF (I-EOI) 660,570,660        
C        
C     READ -        
C        
C     CHECK HEADER RECORDS SAVED IN CORE FOR DUPLICATE        
C        
  680 IF (ISS .EQ. 0) GO TO 850        
      DO 700 I = 1,ISS        
      JSS = 10*(I-1)        
      DO 690 J = 1,3        
      IF (BUF(J+1) .NE. Z(JSS+J)) GO TO 700        
  690 CONTINUE        
      GO TO 710        
  700 CONTINUE        
      GO TO 850        
C        
C     DUPLICATE SUBSTRUCTURE/ITEM ENCOUNTER.  USE MOST RECENT.        
C        
  710 IF (Z(JSS+10) .NE. 0) GO TO 780        
      LINE = LINE+3        
      IF (LINE .GT. NLPP) CALL PAGE        
C        
C     CHECK YEAR, MONTH, DAY, HOUR, MINUTE, SECOND        
C        
      IF (Z(JSS+6)-BUF( 7)) 800,720,770        
  720 IF (Z(JSS+4)-BUF( 5)) 800,730,770        
  730 IF (Z(JSS+5)-BUF( 6)) 800,740,770        
  740 IF (Z(JSS+7)-BUF( 8)) 800,750,770        
  750 IF (Z(JSS+8)-BUF( 9)) 800,760,770        
  760 IF (Z(JSS+9)-BUF(10)) 800,780,770        
C        
C     MOST RECENT VERSION IS THE ONE ALREADY READ.  THEREFORE, SKIP THE 
C     ONE ON TAPE.        
C        
  770 WRITE (NOUT,2210) UWM,BUF(2),BUF(3),BUF(4),UNAME,(BUF(I),I=5,10)  
  780 CALL RECTYP (UNIT,IREC)        
      IF (IREC .EQ. 0) GO TO 790        
C        
C     STRING RECORD - SKIP IT        
C        
      CALL FWDREC (*1870,UNIT)        
      GO TO 780        
C        
C     NORMAL GINO RECORD - CHECK IF EOI        
C        
  790 CALL READ (*1870,*780,UNIT,I,1,1,FLAG)        
      IF (I-EOI) 780,570,780        
C        
C     MOST RECENT VERSION IS ON TAPE.  REPLACE OLDER VERSION ALREADY    
C     READ.        
C        
  800 WRITE (NOUT,2210) UWM,BUF(2),BUF(3),BUF(4),UNAME,(Z(JSS+I),I=4,9) 
      DO 810 I = 1,9        
  810 Z(JSS+I) = BUF(I+1)        
      JCOPY = JCOPY - 1        
      CALL DELETE (BUF(2),BUF(4),RC)        
      GO TO 870        
C        
C     IF DATE AND TIME PARAMETERS WERE INVOKED, CHECK THEM.        
C        
  820 IF (MOD(PDATE,100)       .EQ.BUF( 7) .AND.        
     1    PDATE/10000          .EQ.BUF( 5) .AND.        
     2    MOD(PDATE,10000)/100 .EQ.BUF( 6) .AND.        
     3    PTIME/10000          .EQ.BUF( 8) .AND.        
     4    MOD(PTIME,10000)/100 .EQ.BUF( 9) .AND.        
     5    MOD(PTIME,100)       .EQ.BUF(10)) GO TO 870        
C        
C     DATE AND TIME DONT MATCH. SKIP THIS SUBSTRUCTURE/ITEM.        
C        
  830 CALL RECTYP (UNIT,IREC)        
      IF (IREC .EQ. 0) GO TO 840        
C        
C     STRING RECORD - SKIP IT        
C        
      CALL FWDREC (*1870,UNIT)        
      GO TO 830        
C        
C     NORMAL GINO RECORD - CHECK IF EOI        
C        
  840 CALL READ (*1870,*830,UNIT,I,1,1,FLAG)        
      IF (I-EOI) 830,570,830        
C        
C     NO DUPLICATE.  ADD THIS HEADER TO THOSE IN CORE.        
C        
  850 IF (10*(ISS+1) .GT. LCORE) GO TO 1890        
      DO 860 I = 1,9        
  860 Z(10*ISS+ I) = BUF(I+1)        
      Z(10*ISS+10) = 0        
      ISS = ISS+1        
C        
C     FETCH THE ITEM ON THE SOF.        
C        
  870 RC  = 3        
      KDH = ITTYPE(BUF(4))        
      IF (KDH .EQ. 1) GO TO 970        
      CALL SFETCH (BUF(2),BUF(4),SWRT,RC)        
      IF (RC .EQ. 3) GO TO 930        
      LINE = LINE + 2        
      IF (LINE .GT. NLPP) CALL PAGE        
      GO TO (880,930,930,890,900), RC        
C        
C     ITEM ALREADY EXISTS.        
C        
  880 WRITE (NOUT,2220) UWM,BUF(2),BUF(3),BUF(4)        
      Z(10*ISS) = 1        
      GO TO 910        
C        
C     SUBSTRUCTURE DOES NOT EXIST.  ADD IT TO THE SOF HIERARCHY.        
C        
  890 CALL EXLVL (NOS,Z(IDM),BUF(2),Z(10*ISS+1),LCORE-10*ISS)        
      GO TO 870        
C        
C     INVALID ITEM NAME        
C        
  900 CALL SMSG (3,BUF(4),BUF(2))        
C        
C     BECAUSE OF ERRORS, NO COPY.  SKIP DATA.        
C        
  910 CALL RECTYP (UNIT,IREC)        
      IF (IREC .EQ. 0) GO TO 920        
C        
C     STRING RECORD - SKIP IT        
C        
      CALL FWDREC (*1870,UNIT)        
      GO TO 910        
C        
C     NORMAL GINO RECORD - CHECK IF EOI        
C        
  920 CALL READ (*1870,*910,UNIT,I,1,1,FLAG)        
      IF (I-EOI) 910,570,910        
C        
C     COPY THE DATA FROM THE GINO FILE TO THE SOF.        
C        
  930 I = 10*ISS + 1        
      J = LCORE - I + 1        
      IF (J .LT. 2) GO TO 1890        
  940 CALL READ (*1870,*950,UNIT,Z(I),J,0,FLAG)        
      RC = 1        
      CALL SUWRT (Z(I),J,RC)        
      GO TO 940        
  950 IF (Z(I) .EQ. EOI) GO TO 960        
      RC = 2        
      CALL SUWRT (Z(I),FLAG,RC)        
      GO TO 940        
  960 RC = 3        
      CALL SUWRT (0,0,RC)        
      GO TO 1070        
C        
C     COPY MATRIX DATA FROM THE GINO FILE TO THE SOF.        
C        
  970 IFILE = SCR2        
      I = 10*ISS + 1        
      J = LCORE - I + 1        
      IF (J .LT. 7) GO TO 1890        
      CALL READ (*2020,*2030,UNIT,Z(I+1),6,1,NW)        
      Z(I) = SCR2        
      CALL WRTTRL (Z(I))        
      INBLK(1)  = UNIT        
      OUTBLK(1) = SCR2        
      CALL OPEN (*2010,SCR2,Z(BUF5),WRTREW)        
  980 CALL RECTYP (UNIT,ITYPE)        
      IF (ITYPE .NE. 0) GO TO 1010        
  990 CALL READ (*2010,*1000,UNIT,Z(I),J,0,NW)        
      CALL WRITE (SCR2,Z(I),J,0)        
      GO TO 990        
 1000 IF (Z(I) .EQ. EOI) GO TO 1020        
      CALL WRITE (SCR2,Z(I),NW,1)        
      GO TO 980        
 1010 CALL CPYSTR (INBLK,OUTBLK,0,0)        
      GO TO 980        
 1020 CALL CLOSE (SCR2,1)        
 1030 CALL MTRXO (SCR2,BUF(2),BUF(4),0,RC)        
      GO TO (1040,1070,1070,1050,1060,2010), RC        
C        
C     ITEM ALREADY EXISTS        
C        
 1040 LINE = LINE + 2        
      IF (LINE .GT. NLPP) CALL PAGE        
      WRITE (NOUT,2220) UWM,BUF(2),BUF(3),BUF(4)        
      Z(10*ISS) = 1        
      GO TO 570        
C        
C     SUBSTRUCTURE DOES NOT EXIST - ADD IT TO THE SOF HIERARCHY        
C        
 1050 CALL EXLVL (NOS,Z(IDM),BUF(2),Z(10*ISS+1),LCORE-10*ISS)        
      GO TO 1030        
C        
C     ILLEGAL ITEM NAME        
C        
 1060 LINE = LINE + 2        
      IF (LINE .GT. NLPP) CALL PAGE        
      CALL SMSG (3,BUF(4),BUF(2))        
      GO TO 570        
C        
C     ITEM COPIED - PRINT MESSAGE        
C        
 1070 LINE = LINE + 1        
      IF (LINE .GT. NLPP) CALL PAGE        
      WRITE (NOUT,2170) UIM,BUF(2),BUF(3),BUF(4),UNIT,SOF,        
     1                  (BUF(I),I=5,10)        
C        
C     INCREMENT NUMBER OF ITEMS COPIED.  IF NOT ALL ARE COPIED, LOOP    
C     BACK TO FIND NEXT SUBSTRUCTURE/ITEM ON THE EXTERNAL FILE TO BE    
C     COPIED.        
C        
      JCOPY = JCOPY + 1        
      IF (NCOPY-JCOPY) 570,1150,570        
C        
C     THE ENTIRE EXTERNAL FILE HAS NOW BEEN SCANNED, BUT NOT ALL ITEMS  
C     WERE FOUND.  WARN USER OF EACH ITEM NOT FOUND.        
C        
C     SKIP REMAINDER OF CURRENT ITEM SO FILE IS PROPERLY POSITIONED     
C     FOR NEXT EXECUTION OF MODULE.        
C        
 1080 DO 1120 I = 1,9,2        
      IF (NAMES(I) .EQ. XXXX) GO TO 1120        
      DO 1110 ITEM = 1,NITEMS        
      IF (ISS .EQ. 0) GO TO 1100        
      DO 1090 J = 1,ISS        
      JSS = 10*(J-1)        
      IF (NAMES(I).EQ.Z(JSS+1) .AND. NAMES(I+1).EQ.Z(JSS+2) .AND.       
     1    XITEMS(ITEM) .EQ. Z(JSS+3)) GO TO 1110        
 1090 CONTINUE        
 1100 LINE = LINE + 2        
      IF (LINE .GT. NLPP) CALL PAGE        
      WRITE (NOUT,2230) UWM,NAMES(I),NAMES(I+1),XITEMS(ITEM),UNAME      
 1110 CONTINUE        
 1120 CONTINUE        
 1130 CALL RECTYP (UNIT,IREC)        
      IF (IREC .EQ. 0) GO TO 1140        
C        
C     STRING RECORD - SKIP IT        
C        
      CALL FWDREC (*1870,UNIT)        
      GO TO 1130        
C        
C     NORMAL GINO RECORD - CHECK IF EOI        
C        
 1140 CALL READ (*1870,*1130,UNIT,I,1,1,FLAG)        
      IF (I-EOI) 1130,1150,1130        
C        
C     READ OPERATION COMPLETE        
C        
 1150 CALL CLOSE (UNIT,NOREW)        
      GO TO 1740        
C        
C     *********************   C H E C K   ***************************   
C        
C     REWIND THE EXTERNAL FILE AND PRINT A LIST OF ALL SUBSTRUCTURE/    
C     ITEMS ON IT WITH THE DATE AND TIME WHEN THEY WERE WRITTEN THERE.  
C        
 1160 CALL OPEN (*1860,UNIT,Z(BUF4),RDREW)        
      CALL PAGE        
      WRITE (NOUT,2240) UIM,UNAME        
      LINE = LINE + 1        
      CALL READ (*1870,*1880,UNIT,BUF,9,1,FLAG)        
      GO TO 1180        
 1170 CALL READ (*1210,*1180,UNIT,BUF,10,1,FLAG)        
      LINE = LINE + 1        
      IF (LINE .GT. NLPP) CALL PAGE        
      WRITE (NOUT,2250) (BUF(I),I=2,10)        
      GO TO 1190        
 1180 LINE = LINE + 1        
      IF (LINE .GT. NLPP) CALL PAGE        
      WRITE (NOUT,2120) UIM,(BUF(I),I=2,9)        
 1190 CALL RECTYP (UNIT,IREC)        
      IF (IREC .EQ. 0) GO TO 1200        
C        
C     STRING RECORD - SKIP IT        
C        
      CALL FWDREC (*1870,UNIT)        
      GO TO 1190        
C        
C     NORMAL GINO RECORD - CHECK IF EOI        
C        
 1200 CALL READ (*1870,*1190,UNIT,I,1,1,FLAG)        
      IF (I-EOI) 1190,1170,1190        
 1210 CALL BCKREC (UNIT)        
      CALL CLOSE (UNIT,NOREW)        
      GO TO 1740        
C        
C     ********************   A P P E N D   ***************************  
C        
C     ADD AN EXISTING SOF IN ITS RANDOM ACCESS FORM TO THE RESIDENT SOF.
C     THE MDI AND DIT OF THE EXTERNAL SOF ARE MERGED INTO THOSE OF THE  
C     RESIDENT SOF.  THE NXT OF THE EXTERNAL SOF IS INCREMENTED BY THE  
C     NUMBER OF BLOCKS IN THE RESIDENT SOF.  THE COMMON BLOCKS /SYS/,   
C     /SOF/, AND /SOFCOM/ ARE UPDATED AND WRITTEN TO THE FIRST PHYSICAL 
C     BLOCK ON EACH FILE OF THE RESIDENT SOF BY SOFCLS.  NOTE THAT NO   
C     USER DATA IS ACTUALLY MOVED.        
C        
C     FIRST, ADD THE EXTERNAL SOF TO /SOFCOM/ SO THAT SOFIO CAN BE USED 
C     TO READ IT.        
C        
 1220 IF (NFILES .LT. 10) GO TO 1230        
      WRITE (NOUT,2260) UWM,UNAME        
      WRITE (NOUT,2270)        
      GO TO 1910        
 1230 NFILES = NFILES + 1        
      FILNAM(NFILES) = UNIT        
      FILSIZ(NFILES) = 4        
      NSAVE = NOBLKS + 1        
C        
C     READ THE FIRST PHYSICAL BLOCK OF THE EXTERNAL SOF AND SEE THAT IT 
C     IS COMPATIBLE WITH THE RESIDENT SOF.        
      INCBLK =-4        
      DO 1240 I = 1,NFILES        
 1240 INCBLK = INCBLK+FILSIZ(I)        
      CALL SOFIO (SRD,INCBLK+1,Z(BUF4))        
C        
C     PASSWORD CHECK        
C        
      IF (Z(BUF4+3).EQ.DATYPE(1) .AND. Z(BUF4+4).EQ.DATYPE(2))        
     1    GO TO 1250        
      WRITE (NOUT,2260) UWM,UNAME        
      WRITE (NOUT,2310)        
      INCBLK =-1        
C        
C     FILE SEQUENCE NUMBER CHECK        
C        
 1250 IF (Z(BUF4+5) .EQ. 1) GO TO 1260        
      WRITE (NOUT,2260) UWM,UNAME        
      WRITE (NOUT,2280)        
      INCBLK =-1        
C        
C     NUMBER OF EXTERNAL FILES CHECK        
C        
 1260 IF (Z(BUF4+6) .EQ. 1) GO TO 1270        
      WRITE (NOUT,2260) UWM,UNAME        
      WRITE (NOUT,2290)        
      INCBLK =-1        
C        
C     BLOCKSIZE CHECK        
C        
 1270 IF (Z(BUF4+27) .EQ. BLKSIZ) GO TO 1280        
      WRITE (NOUT,2260) UWM,UNAME        
      WRITE (NOUT,2300) BLKSIZ,Z(BUF4+27)        
      INCBLK =-1        
 1280 IF (INCBLK .LT. 0) GO TO 1490        
C        
C     COMPLETE THE UPDATING OF THE COMMON BLOCKS        
C        
      FILSIZ(NFILES) = Z(BUF4+17)        
      AVBLKS = AVBLKS + Z(BUF4+30)        
      NXTCUR = 1        
      NXTRST =.TRUE.        
      NXTFSZ(NFILES) = Z(BUF4+36)        
      J = NFILES-1        
      NXTTSZ = 0        
      DO 1290 I = 1,J        
 1290 NXTTSZ = NXTTSZ + NXTFSZ(I)        
      OLDTSZ = NXTTSZ + 1        
      NXTTSZ = NXTTSZ + Z(BUF4+35)        
C        
C     READ THE DIT OF THE EXTERNAL SOF AND ADD EACH SUBSTRUCTURE THERE  
C     TO THE DIT OF THE RESIDENT SOF.  KEEP A TABLE IN OPEN CORE OF TWO 
C     WORDS PER SUBSTRUCTURE -        
C        
C     (1)  SUBSTRUCTURE NUMBER FROM THE EXTERNAL SOF.        
C     (2)  NEW SUBSTRUCTURE NUMBER ON THE RESIDENT SOF.        
C        
      NOLD = Z(BUF4+32)        
      IF (2*NOLD .GT. LCORE) GO TO 1890        
      ISS = 1        
      K   = 1        
      KDIT = Z(BUF4+33) + INCBLK        
      KMDI = Z(BUF4+34) + INCBLK        
 1300 CALL SOFIO (SRD,KDIT,Z(BUF4))        
      DO 1350 I = 1,BLKSIZ,2        
      SSNAME(1) = Z(BUF4+I+2)        
      SSNAME(2) = Z(BUF4+I+3)        
      IF (SSNAME(1) .EQ. BLANK) GO TO 1350        
 1320 CALL FDSUB (SSNAME,J)        
      IF (J .EQ. -1) GO TO 1330        
C        
C     DUPLICATE NAME ON RESIDENT SOF.  PREFIX IT WITH -Q- AND TRY AGAIN.
C        
      WRITE (NOUT,2320) UWM,SSNAME        
      CALL PREFIX (Q,SSNAME)        
      IF (SSNAME(2) .NE. QQQQ) GO TO 1320        
      WRITE (NOUT,2330)        
      Z(ISS  ) = (I+1)/2        
      Z(ISS+1) = 0        
      ISS = ISS + 2        
      GO TO 1340        
 1330 CALL CRSUB (SSNAME,J)        
      Z(ISS  ) = K        
      Z(ISS+1) = J        
      ISS = ISS + 2        
      K   = K + 1        
 1340 IF (ISS/2 .GE. NOLD) GO TO 1380        
 1350 CONTINUE        
C        
C     GET THE NEXT BLOCK OF THE DIT FROM THE EXTERNAL SOF        
C        
      CALL FNXT (KDIT,J)        
      IF (MOD(KDIT,2) .EQ. 1) GO TO 1360        
      I = ANDF(RSHIFT(COR(J),IHALF),JHALF)        
      GO TO 1370        
 1360 I = ANDF(COR(J),JHALF)        
 1370 KDIT = I + INCBLK        
      GO TO 1300        
C        
C     THE DIT OF THE EXTERNAL SOF HAS NOW BEEN MERGED WITH THE DIT OF   
C     THE RESIDENT SOF.  NOW MERGE THE MDI        
C        
 1380 ISS = 0        
 1390 CALL SOFIO (SRD,KMDI,Z(BUF4))        
      DO 1420 I = 1,BLKSIZ,DIRSIZ        
      IF (BLKSIZ-I+1 .LT. DIRSIZ) GO TO 1420        
      ISS = ISS  + 1        
      JMDI= BUF4 + I + 1        
      CALL BISLOC (*1900,ISS,Z,2,NOLD,K)        
      CALL FMDI (Z(K+1),JRMDI)        
C        
C     PUT THE CONVERTED SUBSTRUCTURE INDICES IN THE FIRST TWO WORDS OF  
C     THE MDI OF THE RESIDENT SOF.        
C        
      DO 1400 J = 1,6        
      MASK = LSHIFT(1023,10*((J-1)/2))        
C                   1023 = 2*10-1, LEFT SHIFT 0, 10, AND 20 BITS        
C        
      K = MOD(J-1,2) + 1        
      JSS = ANDF(Z(JMDI+K),MASK)        
      IF (JSS .EQ. 0) GO TO 1400        
      CALL BISLOC (*1900,JSS,Z,2,NOLD,K)        
      JSS = Z(K+1)        
      COR(JRMDI+K) = ANDF(COR(JRMDI+K),LSHIFT(JSS,10*((J-1)/2)))        
 1400 CONTINUE        
C        
C     INCREMENT THE BLOCK INDICES OF THE ITEMS IN THIS MDI DIRECTORY BY 
C     THE NUMBER OF BLOCKS ON THE RESIDENT SOF.        
C        
      DO 1410 J = IFRST,DIRSIZ        
      IF (ANDF(Z(JMDI+J),JHALF) .EQ. 0) GO TO 1410        
      COR(JRMDI+J) = Z(JMDI+J) + INCBLK        
 1410 CONTINUE        
      IF (ISS .EQ. NOLD) GO TO 1450        
 1420 CONTINUE        
C        
C     GET THE NEXT BLOCK OF THE MDI FROM THE EXTERNAL SOF.        
C        
      CALL FNXT (KMDI,J)        
      IF (MOD(KMDI,2) .EQ. 1) GO TO 1430        
      I = ANDF(RSHIFT(COR(J),IHALF),JHALF)        
      GO TO 1440        
 1430 I = ANDF(COR(J),JHALF)        
 1440 KMDI = I + INCBLK        
      GO TO 1390        
C        
C     THE MDI OF THE EXTERNAL SOF HAS NOW BEEN MERGED WITH THE MDI OF   
C     THE RESIDENT SOF.  NOW UPDATE THE NXT OF THE EXTERNAL SOF.        
C        
 1450 N = BLKSIZ        
      KNXT = INCBLK + 2        
      INCBLK = ORF(INCBLK,LSHIFT(INCBLK,IHALF))        
      DO 1470 I = OLDTSZ,NXTTSZ        
      CALL SOFIO (SRD,KNXT,Z(BUF4))        
      IF (I-OLDTSZ+1 .EQ. NXTFSZ(NFILES))        
     1    N = (MOD(FILSIZ(NFILES)-2,SUPSIZ)+1)/2 + 1        
      DO 1460 J = 1,N        
 1460 Z(BUF4+J+2) = Z(BUF4+J+2) + INCBLK        
      CALL SOFIO (SWRT,KNXT,Z(BUF4))        
      KNXT = KNXT + SUPSIZ        
 1470 CONTINUE        
C        
C     RELEASE THE BLOCKS USED BY THE MDI AND DIT OF THE EXTERNAL SOF.   
C     (THIS WILL CAUSE THE EXTERNAL SOF TO BE UNUSEABLE IN ITS ORIGINAL 
C     FORM.)        
C        
      INCBLK = ANDF(INCBLK,JHALF)        
      CALL SOFIO (SRD,INCBLK+1,Z(BUF4))        
      KDIT = Z(BUF4+33) + INCBLK        
      KMDI = Z(BUF4+34) + INCBLK        
      CALL RETBLK (KDIT)        
      CALL RETBLK (KMDI)        
C        
C     WRITE ON ALL BLOCKS BETWEEN THE HIGHEST BLOCK WRITTEN ON THE      
C     ORIGINAL RESIDENT SOF AND THE FIRST BLOCK OF THE APPENDED SOF.    
C     THIS IS REQUIRED TO AVOID DATA TRANSMISSION ERRORS.        
C        
      N = FILSIZ(NFILES-1)        
      DO 1480 I = NSAVE,N        
      CALL SOFIO (SWRT,NSAVE,Z(BUF4))        
 1480 CONTINUE        
C        
C     SOFCLS WILL UPDATE THE FIRST PHYSICAL BLOCK ON EACH SOF UNIT.     
C        
      CALL SOFCLS        
C        
C     APPEND OPERATION COMPLETED SUCCESSFULLY.  TELL USER THE NEWS.     
C        
      WRITE (NOUT,2340) UIM,UNAME        
      N = SOFSIZ(N)        
      WRITE (NOUT,2360) UIM,AVBLKS,N        
      GO TO 1750        
C        
C     APPEND OPERATION ABORTED.  RESTORE THE COMMON BLOCKS FOR THE      
C     RESIDENT SOF.        
C        
 1490 FIRST =.TRUE.        
      OPNSOF=.FALSE.        
      CALL SOFOPN (Z(BUF1),Z(BUF2),Z(BUF3))        
      GO TO 1900        
C        
C     ********************   C O M P R E S S   **********************   
C        
C     FOR EACH SUBSTRUCTURE IN THE DIT, COPY EACH ITEM WHICH EXISTS OR  
C     PSEUDO-EXISTS TO SCR1 AND DELETE THE ITEM ON THE SOF.  THEN COPY  
C     ALL ITEMS BACK.  ALL INTERMEDIATE FREE BLOCKS WILL THUS BE        
C     ELIMINATED AND THE DATA FOR ANY ONE ITEM WILL BE STORED ON        
C     CONTIGUOUS BLOCKS.        
C        
C     THE FORMAT OF THE SCRATCH FILE IS --        
C        
C                                      +------------+        
C     SUBSTRUCTURE NAME (2 WORDS)      I            I+        
C     ITEM NAME (1 WORD)               I HEADER     I +        
C     PSEUDO FLAG -- 2 FOR PSEUDO-ITEM I RECORD     I  +        
C                    3 FOR REAL DATA   I            I   +   REPEATED    
C                                      +------------+    +  FOR EACH    
C     DATA -- 1 SOF GROUP PER          I DATA       I   +   SUBS./ITEM  
C             GINO LOGICAL RECORD      I RECORDS    I  +        
C                                      +------------+ +        
C     END OF ITEM FLAG (1 WORD)        I EOI RECORD I+        
C                                      +------------+        
C        
 1500 UNIT = SCR1        
      CALL OPEN (*1860,SCR1,Z(BUF4),WRTREW)        
C        
C     COPY OUT DIT AND MDI INFORMATION        
C        
      ISS = 0        
      DO 1510 K = 1,DITSIZ,2        
      ISS = ISS + 1        
      CALL FDIT  (ISS,J)        
      CALL WRITE (SCR1,COR(J),2,0)        
      CALL FMDI  (ISS,J)        
      CALL WRITE (SCR1,COR(J+1),2,0)        
 1510 CONTINUE        
      CALL WRITE (SCR1,0,0,1)        
C        
C     COPY OUT SUBSTRUCTURE ITEMS        
C        
      ISS = 0        
      DO 1600 K = 1,DITSIZ,2        
      ISS = ISS + 1        
      CALL FDIT (ISS,J)        
      SSNAME(1) = COR(J  )        
      SSNAME(2) = COR(J+1)        
      IF (SSNAME(1) .EQ. BLANK) GO TO 1600        
      DO 1590 ITEM = 1,NITEM        
      KDH = ITEMS(2,ITEM)        
      IF (KDH .EQ. 1) GO TO 1570        
      CALL SFETCH (SSNAME,ITEMS(1,ITEM),SRD,RC)        
      GO TO (1540,1530,1590,1520,1520), RC        
 1520 CALL SMSG (RC-2,ITEMS(1,ITEM),SSNAME)        
      GO TO 1590        
C        
C     ITEM PSEUDO-EXISTS.  WRITE PSEUDO-HEADER RECORD AND EOI RECORD.   
C        
 1530 CALL WRITE (SCR1,SSNAME,2,0)        
      CALL WRITE (SCR1,ITEMS(1,ITEM),1,0)        
      CALL WRITE (SCR1,2,1,1)        
      CALL WRITE (SCR1,EOI,1,1)        
      GO TO 1590        
C        
C     ITEM EXISTS.  COPY IT OUT.        
C        
 1540 CALL WRITE (SCR1,SSNAME,2,0)        
      CALL WRITE (SCR1,ITEMS(1,ITEM),1,0)        
      CALL WRITE (SCR1,3,1,1)        
 1550 CALL SUREAD(Z,LCORE,N,RC)        
      IF (RC .GT. 1) GO TO 1560        
      CALL WRITE (SCR1,Z,LCORE,0)        
      GO TO 1550        
 1560 CALL WRITE (SCR1,Z,N,1)        
      IF (RC .EQ. 2) GO TO 1550        
C        
C     END OF ITEM HIT.  WRITE EOI RECORD        
C        
      CALL WRITE (SCR1,EOI,1,1)        
      GO TO 1590        
C        
C     PROCESS MATRIX ITEMS        
C        
 1570 CALL MTRXI (SCR2,SSNAME,ITEMS(1,ITEM),0,RC)        
      IFILE = SCR2        
      GO TO (1580,1530,1590,1520,1520,2010), RC        
 1580 CALL WRITE (SCR1,SSNAME,2,0)        
      CALL WRITE (SCR1,ITEMS(1,ITEM),1,0)        
      CALL WRITE (SCR1,3,1,1)        
      CALL OPEN  (*2010,SCR2,Z(BUF5),RDREW)        
      Z(1) = SCR2        
      CALL RDTRL (Z(1))        
      CALL WRITE (SCR1,Z(IZ2),6,1)        
      CALL CPYFIL(SCR2,SCR1,Z,LCORE,ICOUNT)        
      CALL WRITE (SCR1,EOI,1,1)        
      CALL CLOSE (SCR2,1)        
 1590 CONTINUE        
 1600 CONTINUE        
C        
C     COPY ALL ITEMS BACK TO THE SOF        
C        
      CALL CLOSE (SCR1,REW)        
      CALL OPEN  (*1860,SCR1,Z(BUF4),RDREW)        
C        
C     RE-INITIALIZE THE SOF, THEN RESTORE THE OLD DIT AND MDI        
C        
      CALL SOFCLS        
      STATUS= 0        
      FIRST =.TRUE.        
      CALL SOFOPN (Z(BUF1),Z(BUF2),Z(BUF3))        
      CALL PAGE        
      ISS = 0        
 1610 CALL READ (*1870,*1620,SCR1,BUF,4,0,FLAG)        
      ISS = ISS + 1        
      IF (BUF(1) .EQ. BLANK) GO TO 1610        
      CALL CRSUB (BUF,I)        
      CALL FMDI  (I,J)        
      COR(J+1) = BUF(3)        
      COR(J+2) = BUF(4)        
      MDIUP = .TRUE.        
      GO TO 1610        
C        
C     READ HEADER RECORD AND FETCH THE SOF ITEM        
C        
 1620 CALL READ (*1730,*1880,SCR1,BUF,4,1,FLAG)        
      KDH = ITTYPE(BUF(3))        
      IF (KDH .EQ. 1) GO TO 1660        
      CALL SFETCH (BUF,BUF(3),2,BUF(4))        
C        
C     COPY THE DATA        
C        
 1630 CALL READ (*1870,*1640,SCR1,Z,LCORE,0,FLAG)        
      IF (Z(1) .EQ. EOI) GO TO 1650        
      CALL SUWRT (Z,LCORE,1)        
      GO TO 1630        
 1640 IF (Z(1) .EQ. EOI) GO TO 1650        
      CALL SUWRT (Z,FLAG,2)        
      GO TO 1630        
C        
C     EOI FOUND        
C        
 1650 CALL SUWRT (0,0,3)        
      GO TO 1720        
C        
C     COPY IN MATRIX ITEMS        
C        
 1660 CALL OPEN (*2010,SCR2,Z(BUF5),WRTREW)        
      CALL READ (*1870,*1880,SCR1,Z(IZ2),6,1,NW)        
      Z(1) = SCR2        
      CALL WRTTRL (Z(1))        
      INBLK(1)  = SCR1        
      OUTBLK(1) = SCR2        
 1670 CALL RECTYP (SCR1,ITYPE)        
      IF (ITYPE .NE. 0) GO TO 1700        
 1680 CALL READ (*1870,*1690,SCR1,Z,LCORE,0,NW)        
      CALL WRITE (SCR2,Z,LCORE,0)        
      GO TO 1680        
 1690 IF (Z(1) .EQ. EOI) GO TO 1710        
      CALL WRITE (SCR2,Z,NW,1)        
      GO TO 1670        
 1700 CALL CPYSTR (INBLK,OUTBLK,0,0)        
      GO TO 1670        
C        
C     EOI FOUND        
C        
 1710 CALL CLOSE (SCR2,1)        
      CALL MTRXO (SCR2,BUF,BUF(3),0,RC)        
 1720 CONTINUE        
      LINE = LINE + 1        
      IF (LINE .GT. NLPP) CALL PAGE        
      WRITE (NOUT,2350) UIM,BUF(1),BUF(2),BUF(3)        
      GO TO 1620        
C        
C     COMPRESS COMPLETE        
C        
 1730 CALL CLOSE (SCR1,REW)        
C        
C     **********************   C O D A   ************************       
C        
C     NORMAL TERMINATION        
C        
 1740 CALL SOFCLS        
 1750 RETURN        
C        
C     ERRORS CAUSING MODULE AND/OR JOB TERMINATION        
C        
 1800 WRITE (NOUT,2100) UWM,UNAME        
      GO TO 1910        
 1810 WRITE (NOUT,2110) UWM,DEVICE        
      GO TO 1910        
 1820 WRITE (NOUT,2140) UWM,MODE        
      GO TO 1910        
 1830 WRITE (NOUT,2150) UWM,POS        
      GO TO 1910        
 1840 WRITE (NOUT,2180) UWM        
      GO TO 1910        
 1850 WRITE (NOUT,2190) SWM,UNAME        
      CALL CLOSE (UNIT,NOREW)        
      GO TO 1910        
C        
 1860 N = -1        
      GO TO 2000        
 1870 N = -2        
      GO TO 2000        
 1880 N = -3        
      GO TO 2000        
 1890 N = 8        
      GO TO 2000        
 1900 N = -61        
      GO TO 2000        
 1910 CALL SOFCLS        
      DRY = -2        
      WRITE (NOUT,2370) SIM        
      RETURN        
C        
 2000 CALL SOFCLS        
      CALL MESAGE (N,UNIT,SUBR)        
      DRY = -2        
      WRITE (NOUT,2370) SIM        
      RETURN        
C        
 2010 N = -1        
      GO TO 2040        
 2020 N = -2        
      GO TO 2040        
 2030 N = -3        
 2040 CALL SOFCLS        
      CALL MESAGE (N,IFILE,SUBR)        
      RETURN        
C        
C     TEXT OF ERROR MESSAGES        
C        
 2100 FORMAT (A25,' 6334, EXIO DEVICE PARAMETER SPECIFIES TAPE, BUT ',  
     1        'UNIT ',2A4,' IS NOT A PHYSICAL TAPE')        
 2110 FORMAT (A25,' 6335, ',2A4,' IS AN INVALID DEVICE FOR MODULE EXIO')
 2120 FORMAT (A29,' 6336, EXIO FILE IDENTIFICATION.  PASSWORD= ',2A4,   
     1       '  DATE=',I3,1H/,I2,1H/,I2,7H  TIME=,I3,1H.,I2,1H.,I2)     
 2130 FORMAT (A29,' 6337,',I6,' BLOCKS (',I4,' SUPERBLOCKS) OF THE SOF',
     1       ' SUCCESSFULLY DUMPED TO EXTERNAL FILE ',2A4)        
 2140 FORMAT (A25,' 6338, ',2A4,' IS AN INVALID MODE PARAMETER FOR ',   
     1       'MODULE EXIO')        
 2150 FORMAT (A25,' 6339, ',2A4,' IS AN INVALID FILE POSITIONING ',     
     1       'PARAMETER FOR MODULE EXIO')        
 2160 FORMAT (A25,' 6340, SUBSTRUCTURE ',2A4,' ITEM ',A4,        
     1       ' PSEUDOEXISTS ONLY AND CANNOT BE COPIED OUT BY EXIO')     
 2170 FORMAT (A29,' 6341, SUBSTRUCTURE ',2A4,' ITEM ',A4,        
     1       ' SUCCESSFULLY COPIED FROM ',A4,' TO ',A4,2H (,        
     2       I2,1H/,I2,1H/,I2,2H, ,I2,1H.,I2,1H.,I2,1H))        
 2180 FORMAT (A25,' 6342, SOF RESTORE OPERATION FAILED.  THE RESIDENT ',
     1       'SOF IS NOT EMPTY')        
 2190 FORMAT (A27,' 6343, ',2A4,' IS NOT AN EXTERNAL SOF FILE')        
 2200 FORMAT (A29,' 6344, SOF RESTORE OF ',I6,' BLOCKS SUCCESSFULLY ',  
     1       'COMPLETED')        
 2210 FORMAT (A25,' 6345, SUBSTRUCTURE ',2A4,' ITEM ',A4,        
     1       ' IS DUPLICATED ON EXTERNAL FILE ',2A4, /32X,        
     2       'OLDER VERSION (',I2,1H/,I2,1H/,I2,2H, ,I2,1H.,I2,1H.,I2,  
     3       ') IS IGNORED')        
 2220 FORMAT (A25,' 6346, SUBSTRUCTURE ',2A4,' ITEM ',A4,        
     1       ' NOT COPIED.  IT ALREADY EXISTS ON THE SOF')        
 2230 FORMAT (A25,' 6348, SUBSTRUCTURE ',2A4,' ITEM ',A4,        
     1       ' NOT FOUND ON EXTERNAL FILE ',2A4)        
 2240 FORMAT (A29,' 6349, CONTENTS OF EXTERNAL SOF FILE ',2A4,' FOLLOW')
 2250 FORMAT (5X,'SUBSTRUCTURE ',2A4,5X,'ITEM ',A4,10X,5HDATE ,I2,1H/,  
     1       I2,1H/,I2,10X,5HTIME ,I2,1H.,I2,1H.,I2)        
 2260 FORMAT (A25,' 6350, SOF APPEND OF FILE ',2A4,' FAILED')        
 2270 FORMAT (32X,'TOO MANY PHYSICAL SOF UNITS. MAXIMUM ALLOWED IS 10') 
 2280 FORMAT (32X,'THE SEQUENCE NUMBER OF THE EXTERNAL SOF FILE IS NOT',
     1       ' 1')        
 2290 FORMAT (32X,'THE EXTERNAL SOF FILE MUST CONSIST OF ONLY ONLY ONE',
     1       ' PHYSICAL UNIT')        
 2300 FORMAT(32X,45HTHE EXTERNAL SOF HAS INCOMPATIBLE BLOCK SIZE., /    
     1       32X, 32HBLOCK SIZE OF THE RESIDENT SOF = ,I5, /        
     2       32X, 32HBLOCK SIZE OF THE EXTERNAL SOF = ,I5 )        
 2310 FORMAT (32X,17HINVALID PASSWORD.)        
 2320 FORMAT (A25,' 6351, DUPLICATE SUBSTRUCTURE NAME ',2A4,        
     1       ' FOUND DURING SOF APPEND OF FILE ',2A4, /32X,        
     2       'THE SUBSTRUCTURE WITH THIS NAME ON THE FILE BEING ',      
     3       'APPENDED WILL BE PREFIXED WITH Q')        
 2330 FORMAT (1H0,31X, 37HPREFIX FAILED.  SUBSTRUCTURE IGNORED.)        
 2340 FORMAT (A29,' 6352, EXTERNAL SOF FILE ',2A4,        
     1       ' SUCCESSFULLY APPENDED TO THE RESIDENT SOF')        
 2350 FORMAT (A29,' 6353, SUBSTRUCTURE ',2A4,' ITEM ',A4,        
     1       ' HAS BEEN SUCCESSFULLY COMPRESSED')        
 2360 FORMAT (A29,' 6354, THERE ARE',I7,' FREE BLOCKS (',I9,        
     1       ' WORDS) ON THE RESIDENT SOF')        
 2370 FORMAT (A31,' 6355, EXIO TERMINATED WITH ERRORS.  DRY RUN MODE ', 
     1       'ENTERED')        
      END        
C        
C     THIS ROUTINE WAS RENUMBERED BY G.CHAN/UNISYS  8/1992        
C        
C                    TABLE OF OLD vs. NEW STATEMENT NUMBERS        
C        
C     OLD NO.    NEW NO.      OLD NO.    NEW NO.      OLD NO.    NEW NO.
C    --------------------    --------------------    -------------------
C        110         10         2290        750         4220       1490 
C        112         20         2300        760         5000       1500 
C        115         30         2310        770         5005       1510 
C        118         40         2320        780         5010       1520 
C        119         50         2322        790         5020       1530 
C        120         60         2330        800         5030       1540 
C       1000         70         2340        810         5040       1550 
C       1002         80         2350        820         5050       1560 
C       1004         90         2352        830         5051       1570 
C       1010        100         2354        840         5052       1580 
C       1020        110         2355        850         5070       1590 
C       1030        120         2360        860         5080       1600 
C       1040        130         2370        870         5085       1610 
C       1050        140         2380        880         5090       1620 
C       1060        150         2390        890         5100       1630 
C       1070        160         2400        900         5110       1640 
C       1080        170         2410        910         5120       1650 
C       1085        180         2412        920         5116       1660 
C       1090        190         2420        930         5111       1670 
C       1100        200         2430        940         5112       1680 
C       1110        210         2440        950         5113       1690 
C       1120        220         2450        960         5117       1700 
C       1130        230         2451        970         5115       1710 
C       1140        240         2452        980         5114       1720 
C       1150        250         2453        990         5130       1730 
C       1160        260         2454       1000         6000       1740 
C       1165        270         2461       1010         6100       1750 
C       1170        280         2462       1020         6334       1800 
C       1180        290         2459       1030         6335       1810 
C       1190        300         2455       1040         6338       1820 
C       1194        310         2456       1050         6339       1830 
C       1195        320         2457       1060         6342       1840 
C       1198       -330         2458       1070         6343       1850 
C       1200        340         2460       1080         9001       1860 
C       1210        350         2470       1090         9002       1870 
C       1220        360         2480       1100         9003       1880 
C       2000        370         2490       1110         9008       1890 
C       2010        380         2500       1120         9061       1900 
C       2020        390         2505       1130         9100       1910 
C       2030        400         2507       1140         9200       2000 
C       2040        410         2510       1150        10001       2010 
C       2050        420         3000       1160        10002       2020 
C       2060        430         3010       1170        10003       2030 
C       2070        440         3020       1180        10200       2040 
C       2080        450         3040       1190        63340       2100 
C       2085        460         3042       1200        63350       2110 
C       2088        470         3050       1210        63360       2120 
C       2090        480         4000       1220        63370       2130 
C       2100        490         4010       1230        63380       2140 
C       2101        500         4020       1240        63390       2150 
C       2102        510         4025       1250        63400       2160 
C       2103        520         4030       1260        63410       2170 
C       2105        530         4040       1270        63420       2180 
C       2110        540         4050       1280        63430       2190 
C       2120        550         4052       1290        63440       2200 
C       2130        560         4054       1300        63450       2210 
C       2140        570         4055      -1310        63460       2220 
C       2150        580         4060       1320        63480       2230 
C       2160        590         4070       1330        63490       2240 
C       2170        600         4080       1340        63491       2250 
C       2180        610         4090       1350        63500       2260 
C       2190        620         4100       1360        63501       2270 
C       2200        630         4110       1370        63502       2280 
C       2210        640         4120       1380        63503       2290 
C       2220        650         4130       1390        63504       2300 
C       2230        660         4140       1400        63505       2310 
C       2232        670         4150       1410        63510       2320 
C       2240        680         4160       1420        63511       2330 
C       2250        690         4170       1430        63520       2340 
C       2255        700         4180       1440        63530       2350 
C       2257        710         4190       1450        63540       2360 
C       2260        720         4200       1460        63550       2370 
C       2270        730         4210       1470            0          0 
C       2280        740        
