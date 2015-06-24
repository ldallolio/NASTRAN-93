      SUBROUTINE RCOVE        
C        
C     THIS SUBROUTINE PRINTS THE ENERGIES ON THE MODAL COORDINATES      
C     IN A SUBSTRUCTURE THAT WAS MODAL REDUCED.  IT WILL ALSO PRINT     
C     THE ENERGIES ON THOSE MODES EXCLUDED FROM THE REDUCTION        
C     PROCESSING.        
C        
      EXTERNAL        ANDF        
      LOGICAL         MREDU      ,CREDU      ,NOEXCL        
      INTEGER         DRY        ,FSS        ,RSS        ,UA        ,   
     1                RFNO       ,Z(3)       ,RC         ,BUF(1)    ,   
     2                FILE       ,SOF1       ,SOF2       ,SOF3      ,   
     4                BUF1       ,BUF2       ,BUF3       ,SYSBUF    ,   
     5                NAME(2)    ,SCR3       ,SCR4       ,SCR6      ,   
     7                SCR7       ,EQSS       ,RSP        ,GRID      ,   
     8                SOLN       ,TRIGID(2)  ,TIMODE(2)  ,TEMODE(2) ,   
     9                TYPE(2)    ,CASESS     ,CASECC(2)  ,MCB(7)    ,   
     O                CMASK      ,ENERGY     ,BUF4       ,BLANK     ,   
     A                HIGHER(2)  ,ANDF       ,NAMES(2)        
      REAL            KENG       ,PENG        
      CHARACTER       UFM*23     ,UWM*25        
      COMMON /XMSSG / UFM        ,UWM        
      COMMON /BLANK / DRY        ,LOOP       ,STEP       ,FSS(2)    ,   
     1                RFNO       ,NEIGV      ,LUI        ,UINMS(2,5),   
     2                NOSORT     ,UTHRES     ,PTHRES     ,QTHRES        
      COMMON /RCOVCR/ ICORE      ,LCORE      ,BUF1       ,BUF2      ,   
     1                BUF3       ,BUF4       ,SOF1       ,SOF2      ,   
     2                SOF3        
      COMMON /RCOVCM/ MRECVR     ,UA         ,PA         ,QA        ,   
     1                IOPT       ,RSS(2)     ,ENERGY     ,UIMPRO    ,   
     2                RANGE(2)   ,IREQ       ,LREQ       ,LBASIC        
CZZ   COMMON /ZZRCEX/ RZ(1)        
      COMMON /ZZZZZZ/ RZ(1)        
      COMMON /SYSTEM/ SYSBUF     ,NOUT       ,DUM1(6)    ,NLPP      ,   
     1                DUM2(2)    ,NLINES        
      COMMON /UNPAKX/ ITINU      ,IRU        ,NRU        ,INCRU        
      COMMON /OUTPUT/ ITITLE(96)        
      COMMON /NAMES / RD         ,RDREW      ,WRT        ,WRTREW    ,   
     1                REW        ,NOREW      ,EOFNRW     ,RSP       ,   
     2                RDP        ,CSP        ,CDP        ,SQUARE    ,   
     3                RECT       ,DIAG        
CZZ   COMMON /SOFPTR/ BUF        
      EQUIVALENCE     (BUF(1)    ,RZ(1))        
      EQUIVALENCE     (RZ(1)     ,Z(1))        
      DATA    CASECC/ 4HCASE,4HCC   /        
      DATA    EQSS  , LAMS, SOLN    / 4HEQSS,4HLAMS,4HSOLN /        
      DATA    CASESS, SCR3, SCR4, SCR6, SCR7           /        
     1        101   , 303,  304,  306,  307            /        
      DATA    TRIGID/ 4HINER,4HTIAL /        
      DATA    TIMODE/ 4HIN-M,4HODE  /        
      DATA    TEMODE/ 4HEX-M,4HODE  /        
      DATA    IB    / 1             /        
      DATA    MMASK / 201326592     /        
      DATA    CMASK / 67108864      /        
      DATA    BLANK / 4H            /        
      DATA    NAME  / 4HRCOV,4HE    /        
C        
C     IF THIS IS A STATICS SOLUTION NO ENERGY CALCULATIONS CAN BE MADE  
C        
      IF (RFNO .LE. 2) RETURN        
C        
C     INITIALIZE        
C        
      SOF1 = KORSZ(Z) - SYSBUF + 1        
      SOF2 = SOF1 - SYSBUF - 1        
      SOF3 = SOF2 - SYSBUF        
      BUF1 = SOF3 - SYSBUF        
      BUF2 = BUF1 - SYSBUF        
      BUF3 = BUF2 - SYSBUF        
      BUF4 = BUF3 - SYSBUF        
      LCORE= BUF4 - 1        
      IF (LCORE .LE. 0) GO TO 9008        
C        
C     GET THE NAME OF THE HIGHER LEVEL SUBSTRUCTURE.  IF NONE EXISTS    
C     THEN RETURN.        
C        
      CALL SOFOPN (Z(SOF1),Z(SOF2),Z(SOF3))        
      NAMES(1) = RSS(1)        
      NAMES(2) = RSS(2)        
      CALL FNDNXL (RSS,HIGHER)        
      RC = 4        
      IF (HIGHER(1) .EQ. BLANK) GO TO 6000        
      IF (HIGHER(1).EQ.RSS(1) .AND. HIGHER(2).EQ.RSS(2)) GO TO 1000     
C        
C     CHECK IF THE HIGHER LEVEL SUBSTRUCTURE WAS MODAL REDUCED.        
C     IF NOT THEN WE HAVE NOTHING TO DO        
C        
      NAMES(1) = HIGHER(1)        
      NAMES(2) = HIGHER(2)        
      RC = 4        
      CALL FDSUB (HIGHER,IDIT)        
      IF (IDIT .LT. 0) GO TO 6000        
      CALL FMDI (IDIT,IMDI)        
      MREDU = .FALSE.        
      CREDU = .FALSE.        
      IF (ANDF(BUF(IMDI+IB),MMASK) .NE. 0) MREDU = .TRUE.        
      IF (ANDF(BUF(IMDI+IB),CMASK) .NE. 0) CREDU = .TRUE.        
      IF (.NOT.MREDU) GO TO 1000        
C        
C     READ THE MODAL GROUP OF THE EQSS TO DETERMINE IF THERE ARE ANY    
C     RIGID BODY DOF PRESENT.  ALSO GET THE SIL NUMBER OF THE FIRST     
C     MODAL CORDINATE.        
C        
      ITEM = EQSS        
      CALL SFETCH (HIGHER,EQSS,1,RC)        
      IF (RC .NE. 1) GO TO 6000        
      CALL SUREAD (Z(1),3,N,RC)        
      IF (RC .NE. 1) GO TO 6100        
      N = Z(3)        
      CALL SJUMP (N)        
      IF (N .LT. 0) GO TO 6200        
C        
      NRIGID = 0        
   10 CALL SUREAD (Z(1),3,N,RC)        
      IF (RC .NE. 1) GO TO 6100        
      IF (NRIGID .EQ. 0) IP = Z(2)        
      IF (Z(1) .GE. 100) GO TO 20        
      NRIGID = NRIGID + 1        
      GO TO 10        
C        
   20 IF (2*IP .GT. SOF3) GO TO 9008        
      N = 1        
      CALL SJUMP (N)        
      IF (N .LT. 0) GO TO 6200        
C        
      CALL SUREAD (Z(1),2*IP,N,RC)        
      IF (RC .NE. 1) GO TO 6100        
      I = 2*(IP-1) + 1        
      ISIL = Z(I)        
C        
C     CALCULATE THE ENERGIES ON THE EXCLUDED MODES        
C        
      NOEXCL = .TRUE.        
      NROWE  = 0        
      IF (CREDU .OR. RFNO.LT.3 .OR. RFNO.GT.8) GO TO 100        
      NOEXCL = .FALSE.        
      CALL RCOVEM (NOEXCL,NROWE)        
C        
C     CALCULATE THE ENERGIES ON THE INCLUDED MODE AND THE TOTAL        
C     ENERGIES ON EACH VECTOR        
C        
  100 CALL RCOVIM (HIGHER)        
      IF (IOPT .LT. 0) GO TO 9200        
      MCB(1) = SCR6        
      CALL RDTRL(MCB)        
      NCOL  = MCB(2)        
      NROWI = MCB(3)        
      NMODEI= NROWI - ISIL + 1        
C        
C     READ THE MODE DATA FROM LAMS AND SAVE THE MODE NUMBER AND        
C     THE FREQUENCY FOR EACH MODE.        
C        
      NAMES(1) = RSS(1)        
      NAMES(2) = RSS(2)        
      ITEM = LAMS        
      CALL SFETCH (RSS,LAMS,1,RC)        
      IF (RC .NE. 1) GO TO 6000        
      N = 1        
      CALL SJUMP (N)        
      IF (N .LT. 0) GO TO 6200        
      IMODE = 1        
      IF (NRIGID .EQ. 0) GO TO 210        
      N = 3*NRIGID        
      IMODE = IMODE + N        
      DO 200 I = 1,N,3        
      Z(I  ) = 0        
      Z(I+1) = 0        
  200 Z(I+2) = (I-1)/3 + 1        
  210 NMODE = 3*(NMODEI-1+NROWE)        
      IF (NMODE .GT. LCORE) GO TO 9008        
C        
      DO 300 I = IMODE,NMODE,3        
      CALL SUREAD (Z(I),7,N,RC)        
      IF (RC .NE. 1) GO TO 6100        
      Z(I+1) = Z(I+4)        
      Z(I+2) = 0        
  300 CONTINUE        
C        
C     READ THE LAST GROUP OF LAMS AND GENERATE GRID NUMBERS FOR THE     
C     INCLUDED MODES.        
C        
      N = 1        
      CALL SJUMP (N)        
      IF (N .LT. 0) GO TO 6200        
      IINC = 100        
      DO 400 I = IMODE,NMODE,3        
      CALL SUREAD (ICODE,1,N,RC)        
      IF (RC .NE. 1) GO TO 6100        
      IF (ICODE .GT. 1) GO TO 400        
      IINC = IINC + 1        
      Z(I+2) = IINC        
  400 CONTINUE        
C        
C     POSITION THE SOLN ITEM TO THE FREQUENCY OR TIME DATA        
C        
      ITEM = SOLN        
      CALL SFETCH (RSS,SOLN,1,RC)        
      IF (RC .NE. 1) GO TO 6000        
      N = 1        
      CALL SJUMP (N)        
      IF (N .LT. 0) GO TO 6200        
C        
C     ALLOCATE INCORE ARRAYS FOR THE ENERGY VECTORS        
C        
      IVEC1 = NMODE + 1        
      IVEC2 = IVEC1 + NMODEI        
      IVEC3 = IVEC2 + NMODEI        
      IVEC4 = IVEC3 + NROWE        
      ISETS = IVEC4 + NROWE        
      IF (ISETS .GT. LCORE) GO TO 9008        
C        
C     READ CASESS AND GET THE TITLE AND ANY SET INFORMATION        
C        
      FILE = CASESS        
      CALL GOPEN (CASESS,Z(BUF1),RDREW)        
  450 CALL FREAD (CASESS,Z(IVEC1),2,1)        
      IF (Z(IVEC1).NE.CASECC(1) .OR. Z(IVEC1+1).NE.CASECC(2)) GO TO 450 
C        
      CALL FREAD (CASESS,0,-38,0)        
      CALL FREAD (CASESS,ITITLE(1),96,0)        
C        
      IF (ENERGY .LE. 0) GO TO 485        
      CALL FREAD (CASESS,0,-31,0)        
      CALL FREAD (CASESS,LCC,1,0)        
      LSKIP = 167 - LCC        
      CALL FREAD (CASESS,0,LSKIP,0)        
      CALL READ (*9002,*480,CASESS,LSEQ,1,0,I)        
      IF (LSEQ .GT. 0) CALL FREAD (CASESS,0,LSEQ,0)        
C        
  460 CALL READ (*9002,*480,CASESS,ISET,1,0,I)        
      CALL FREAD (CASESS,LSET,1,0)        
      IF (ISET .EQ. ENERGY) GO TO 470        
      CALL FREAD (CASESS,0,-LSET,0)        
      GO TO 460        
  470 IF (ISETS+LSET .GT. LCORE) GO TO 9008        
      CALL FREAD (CASESS,Z(ISETS),LSET,0)        
      GO TO 485        
C        
  480 WRITE (NOUT,63650) UWM,ENERGY        
      ENERGY = -1        
C        
  485 CALL CLOSE (CASESS,REW)        
C        
C     LOOP OVER EACH COLUMN AND PRINT THE KINETIC AND POTENTIAL        
C     ENERGIES FOR EACH MODAL COORDINATE IF REQUESTED        
C        
      NEXT = 1        
      CALL GOPEN (SCR6,Z(BUF1),RDREW)        
      CALL GOPEN (SCR7,Z(BUF2),RDREW)        
      IF (NOEXCL) GO TO 490        
      CALL GOPEN (SCR3,Z(BUF3),RDREW)        
      CALL GOPEN (SCR4,Z(BUF4),RDREW)        
C        
  490 ITINU = RSP        
      INCRU = 1        
C        
      DO 800 ICOL = 1,NCOL        
C        
C     SET FLAGS FOR NULL COLUMNS        
C        
      IKFLAG = 0        
      IPFLAG = 0        
C        
C     GET THE FREQUENCY OR TIME FOR THIS VECTOR        
C        
      IF (RFNO .GT. 3) GO TO 500        
C        
C     NORMAL MODES SOLUTION        
C        
      CALL SUREAD (Z(IVEC1),7,N,RC)        
      IF (RC .NE. 1) GO TO 6100        
      STEP = RZ(IVEC1+4)        
      GO TO 505        
C        
C     DYNAMICS SOLUTION        
C        
  500 CALL SUREAD (STEP,1,N,RC)        
      IF (RC .NE. 1) GO TO 6100        
C        
C     SEE IF THIS COLUMN IS REQUESTED        
C        
  505 IF (ENERGY .LE. 0) GO TO 510        
      CALL SETFND (*790,Z(ISETS),LSET,ICOL,NEXT)        
C        
  510 IF (STEP.LT.RANGE(1) .OR. STEP.GT.RANGE(2)) GO TO 790        
C        
C     UNPACK THE KINETIC AND POTENTIAL ENERGIES ON INCLUDED MODES       
C        
      IRU = ISIL        
      NRU = NROWI        
      CALL UNPACK (*520,SCR6,RZ(IVEC1))        
      GO TO 540        
  520 DO 530 I = 1,NMODEI        
  530 RZ(IVEC1+I-1) = 0.0        
      RZ(IVEC1+NMODEI-1) = 1.0        
      IKFLAG = 1        
C        
  540 CALL UNPACK (*550,SCR7,RZ(IVEC2))        
      GO TO 570        
  550 DO 560 I = 1,NMODEI        
  560 RZ(IVEC2+I-1) = 0.0        
      RZ(IVEC2+NMODEI-1) = 1.0        
      IPFLAG = 1        
C        
C     UNPACK THE KINETIC AND POTENTIAL ENERGIES ON EXLUDED MODES        
C        
  570 IF (NOEXCL) GO TO 580        
      IRU = 1        
      NRU = NROWE        
      CALL UNPACK (*580,SCR3,RZ(IVEC3))        
      GO TO 600        
  580 DO 590 I = 1,NROWE        
  590 RZ(IVEC3+I-1) = 0.0        
C        
  600 IF (NOEXCL) GO TO 610        
      CALL UNPACK (*610,SCR4,RZ(IVEC4))        
      GO TO 630        
  610 DO 620 I = 1,NROWE        
  620 RZ(IVEC4+I-1) = 0.0        
C        
C     INITILIZE FOR THE OUTPUT        
C        
  630 NLINES = NLPP        
C        
C     GET TOTAL ENERGIES        
C        
      TKENG = RZ(IVEC1+NMODEI-1)        
      TPENG = RZ(IVEC2+NMODEI-1)        
      PERKT = 1.0        
      PERPT = 1.0        
C        
C     LOOP OVER EACH MODAL COORDINATE        
C        
      IINC = 0        
      IEXC = 0        
C        
      DO 700 I = 1,NMODE,3        
C        
      MODE = Z(I)        
      FREQ = RZ(I+1)        
      GRID = Z(I+2)        
C        
C     GET ENERGIES FORM THE PROPER VECTOR        
C        
      IF (NOEXCL) GO TO 650        
      IF (GRID .EQ. 0) GO TO 660        
 650  KENG = RZ(IVEC1+IINC)        
      PENG = RZ(IVEC2+IINC)        
      IINC = IINC + 1        
      TYPE(1) = TIMODE(1)        
      TYPE(2) = TIMODE(2)        
C        
      IF (MODE .NE. 0) GO TO 670        
      TYPE(1) = TRIGID(1)        
      TYPE(2) = TRIGID(2)        
      GO TO 670        
C        
  660 KENG = RZ(IVEC3+IEXC)        
      PENG = RZ(IVEC4+IEXC)        
      IEXC = IEXC + 1        
      TYPE(1) = TEMODE(1)        
      TYPE(2) = TEMODE(2)        
C        
C     CALCULATE THE ENERGY PERCENTAGES        
C        
  670 PERK = KENG/TKENG        
      IF (PERK .GE. 100.0) PERK = 99.9999        
      PERP = PENG/TPENG        
      IF (PERP .GE. 100.0) PERP = 99.9999        
      IF (GRID .NE. 0) GO TO 680        
      PERKT = PERKT + PERK        
      PERPT = PERPT + PERP        
C        
C     PRINT A LINE OF OUTPUT        
C        
  680 NLINES = NLINES + 1        
      IF (NLINES .LE. NLPP) GO TO 690        
      CALL PAGE1        
      WRITE (NOUT,5000) RSS        
      IF (RFNO .EQ. 9) WRITE (NOUT,5010) STEP        
      IF (RFNO .NE. 9) WRITE (NOUT,5020) STEP        
      WRITE (NOUT,5100)        
      NLINES = 0        
C        
  690 WRITE (NOUT,5200) GRID,TYPE,MODE,FREQ,KENG,PERK,PENG,PERP        
C        
  700 CONTINUE        
C        
C     PRINT THE TOTAL KINETIC AND POTENTIAL ENERGIES FOR THIS COLUMN    
C        
      IF (PERKT .GE. 100.0) PERKT = 99.9999        
      IF (PERPT .GE. 100.0) PERPT = 99.9999        
      IF (IKFLAG .EQ. 0) GO TO 710        
      TKENG = 0.0        
      PERKT = 0.0        
  710 IF (IPFLAG .EQ. 0) GO TO 720        
      TPENG = 0.0        
      PERPT = 0.0        
  720 WRITE (NOUT,5300) TKENG,PERKT,TPENG,PERPT        
      GO TO 800        
C        
C     THIS VECTOR IS NOT TO BE PRINTED SO SKIP IT        
C        
  790 CALL FWDREC (*9002,SCR6)        
      CALL FWDREC (*9002,SCR7)        
      IF (NOEXCL) GO TO 800        
      CALL FWDREC (*9002,SCR3)        
      CALL FWDREC (*9002,SCR4)        
C        
  800 CONTINUE        
C        
C     CLOSE FILES        
C        
      CALL CLOSE (SCR6,REW)        
      CALL CLOSE (SCR7,REW)        
      IF (NOEXCL) GO TO 1000        
      CALL CLOSE (SCR3,REW)        
      CALL CLOSE (SCR4,REW)        
C        
C     NORMAL RETURN        
C        
 1000 CALL SOFCLS        
      RETURN        
C        
C     ERRORS        
C        
 6000 CALL SMSG (RC-2,ITEM,NAMES)        
      GO TO 9200        
 6100 CALL SMSG (RC+4,ITEM,NAMES)        
      GO TO 9200        
 6200 CALL SMSG (7,ITEM,NAMES)        
      GO TO 9200        
 9002 N = 2        
      GO TO 9100        
 9008 N = 8        
 9100 CALL MESAGE (N,FILE,NAME)        
 9200 CALL SOFCLS        
      WRITE (NOUT,63710) UWM,RSS        
      RETURN        
C        
C     FORMAT STATEMENTS        
C        
 5000 FORMAT (//39X,43HMODAL COORDINATE ENERGIES FOR SUBSTRUCTURE ,2A4) 
 5010 FORMAT (//12X,7HTIME = ,1P,E13.6)        
 5020 FORMAT (//12X,12HFREQUENCY = ,1P,E13.6)        
 5100 FORMAT (//12X,4HGRID,6X,4HTYPE,6X,4HMODE,7X,9HFREQUENCY,10X,      
     1        7HKINETIC,8X,8HKE/TOTAL,6X,9HPOTENTIAL,7X,8HPE/TOTAL ,/)  
 5200 FORMAT (1H ,8X,I8,5X,2A4,2X,I5,5X,1P,E13.6,2(5X,1P,E13.6,5X,      
     1        0P,F7.4))        
 5300 FORMAT (1H ,55X,2(4X,14H--------------,4X,8H--------), /12X,      
     1        28HTOTAL ENERGY FOR THIS VECTOR,15X,2(5X,1P,E13.6,5X,     
     2        0P,F7.4))        
63710 FORMAT (A25,' 6371, MODAL REDUCTION ENERGY CALCULATIONS FOR ',    
     1       'SUBSTRUCTURE ',2A4,' ABORTED.')        
63650 FORMAT (A25,' 6365, REQUESTED OUTPUT SET ID',I6,' IS NOT ',       
     1       'DECLARED IN CASE CONTROL. ALL OUTPUT WILL BE PRODUCED')   
      END        
