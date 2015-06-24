      SUBROUTINE MRED2H        
C        
C     THIS SUBROUTINE CREATES THE REDUCED SUBSTRUCTURE NEW TABLE ITEMS  
C     FOR THE MRED2 MODULE.        
C        
C     INPUT DATA        
C     GINO  - EQST   - TEMPORARY SUBSTRUCTURE EQUIVALENCE TABLE FOR     
C                      SUBSTRUCTURE BEING REDUCED        
C        
C     OUTPUT DATA        
C     SOF   - EQSS   - SUBSTRUCTURE EQUIVALENCE TABLE FOR REDUCED       
C                      SUBSTRUCTURE        
C             BGSS   - BASIC GRID POINT DEFINITION TABLE FOR REDUCED    
C                      SUBSTRUCTURE        
C             LODS   - LOAD SET DATA FOR REDUCED SUBSTRUCTURE        
C             LOAP   - APPENDED LOAD SET DATA FOR REDUCED SUBSTRUCTURE  
C             PLTS   - PLOT SET DATA FOR REDUCED SUBSTRUCTURE        
C             CSTM   - COORDINATE SYSTEM TRANSFORMATION DATA FOR REDUCED
C                      SUBSTRUCTURE        
C        
C     PARAMETERS        
C     INPUT - DRY    - MODULE OPERATION FLAG        
C             POPT   - LOAD OPTION FLAG        
C             GBUF1  - GINO BUFFER        
C             INFILE - INPUT FILE NUMBERS        
C             KORLEN - LENGTH OF OPEN CORE        
C             KORBGN - BEGINNING ADDRESS OF OPEN CORE        
C             OLDNAM - NAME OF SUBSTRUCTURE BEING REDUCED        
C             NEWNAM - NAME OF REDUCED SUBSTRUCTURE        
C             FREBDY - FREEBODY OPR        
C             FREBDY - FREEBODY OPTIONS FLAG        
C             IO     - OUTPUT OPTIONS FLAG        
C             MODPTS - NUMBER OF MODAL POINTS        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        RSHIFT,ANDF        
      LOGICAL         FREBDY,PONLY        
      REAL            ZERO,RZ(1)        
      DIMENSION       MODNAM(2),LSTBIT(32),ITRLR(7),ITMLST(3),ITMNAM(2) 
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /BLANK / IDUM1,DRY,POPT,GBUF1,IDUM2(5),INFILE(12),        
     1                IDUM3(16),KORLEN,KORBGN,OLDNAM(2),NEWNAM(2),      
     2                FREBDY,IDUM4(3),USRMOD,IO,IDUM6(4),MODPTS,IDUM9,  
     3                PONLY        
CZZ   COMMON /ZZMRD2/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SYSTEM/ IDUM5,IPRNTR,IDUM7(6),NLPP,IDUM8(2),LINE        
      EQUIVALENCE     (EQST,INFILE(4)), (RZ(1),Z(1))        
      DATA    MODNAM/ 4HMRED,4H2H  /        
      DATA    PAPP  , LODS,LOAP    /4HPAPP,4HLODS,4HLOAP/        
      DATA    FARIND, IZERO,ZERO   /6,0,0.0/        
      DATA    ITMLST/ 4HEQSS,4HBGSS,4HLAMS /        
      DATA    SOFEOG/ 4H$EOG       /        
C        
C     CHECK FOR LOADS PROCESSING ONLY        
C        
      IF (PONLY) GO TO 55        
C        
C     PROCESS EQSS, BGSS DATA        
C        
      IF (DRY .EQ. -2) GO TO 300        
      ITRLR(1) = EQST        
      CALL RDTRL (ITRLR)        
      ITMNAM(1) = NEWNAM(1)        
      ITMNAM(2) = NEWNAM(2)        
      IFILE = EQST        
      IF (ITRLR(1) .LT. 0) GO TO 210        
      CALL GOPEN (EQST,Z(GBUF1),0)        
      ITEST = 3        
      ITEM  = ITMLST(1)        
      CALL SFETCH (NEWNAM,4HEQSS,2,ITEST)        
      IF (ITEST .NE. 3) GO TO 250        
      NEWPTS = MODPTS        
      IF (FREBDY) NEWPTS = NEWPTS + FARIND        
C        
C     PROCESS EQSS GROUP 0 DATA        
C        
      IF (KORBGN+ITRLR(2)+2 .GE. KORLEN) GO TO 230        
      CALL READ (*215,*220,EQST,Z(KORBGN),ITRLR(2),1,NWDSRD)        
      NCSUBS = Z(KORBGN+2)        
      Z(KORBGN+2) = Z(KORBGN+2) + 1        
      Z(KORBGN+3) = Z(KORBGN+3) + NEWPTS        
      NEWCS = ITRLR(2)        
      Z(KORBGN+NEWCS  ) = NEWNAM(1)        
      Z(KORBGN+NEWCS+1) = NEWNAM(2)        
      NEWCS = ITRLR(2) + 2        
      CALL SUWRT (Z(KORBGN),NEWCS,2)        
C        
C     PROCESS REMAINING EQSS GROUPS        
C        
      NWDS = KORLEN - KORBGN        
      DO 20 I = 1,NCSUBS        
      CALL READ (*215,*10,EQST,Z(KORBGN),NWDS,1,NWDSRD)        
      GO TO 230        
   10 IF (KORBGN+1+NWDSRD .GE. KORLEN) GO TO 230        
   20 CALL SUWRT (Z(KORBGN),NWDSRD,2)        
C        
C     PROCESS MODAL AND FREE-BODY POINTS        
C        
      IF (KORBGN+3*NEWPTS .GE. KORLEN) GO TO 230        
      DO 30 I = 1,NEWPTS        
      KORE = 3*(I-1)        
      IF (.NOT.FREBDY) GO TO 24        
      IF (I .GT. FARIND) GO TO 22        
      Z(KORBGN+KORE) = I        
      GO TO 26        
   22 Z(KORBGN+KORE) = 100 + I - FARIND        
      GO TO 26        
   24 Z(KORBGN+KORE  ) = 100 + I        
   26 Z(KORBGN+KORE+1) = ITRLR(4)/2 + I        
   30 Z(KORBGN+KORE+2) = 1        
      NWDSRD = 3*NEWPTS        
      CALL SUWRT (Z(KORBGN),NWDSRD,2)        
C        
C     PROCESS EQSS SIL DATA        
C        
      IF (KORBGN+ITRLR(4)+2*NEWPTS .GE. KORLEN) GO TO 230        
      CALL READ (*215,*220,EQST,Z(KORBGN),ITRLR(4),1,NWDSRD)        
      NWDSRD = ITRLR(4) - 1        
      ICODE  = Z(KORBGN+NWDSRD)        
      CALL DECODE (ICODE,LSTBIT,NWDSD)        
      LSTSIL = Z(KORBGN+NWDSRD-1) + NWDSD - 1        
      DO 40 I = 1,NEWPTS        
      KORE = ITRLR(4) + 2*(I-1)        
      Z(KORBGN+KORE  ) = LSTSIL + I        
   40 Z(KORBGN+KORE+1) = 1        
      NWDSRD = ITRLR(4) + 2*NEWPTS        
      CALL SUWRT (Z(KORBGN),NWDSRD,2)        
      CALL SUWRT (Z(KORBGN),0,3)        
C        
C     PROCESS BGSS DATA        
C        
      IF (KORBGN+ITRLR(5)+4*NEWPTS .GE. KORLEN) GO TO 230        
      ITEM  = ITMLST(2)        
      ITEST = 3        
      CALL SFETCH (NEWNAM,4HBGSS,2,ITEST)        
      IF (ITEST .NE. 3) GO TO 250        
      CALL READ (*215,*220,EQST,Z(KORBGN),3,1,NWDSRD)        
      Z(KORBGN  ) = NEWNAM(1)        
      Z(KORBGN+1) = NEWNAM(2)        
      Z(KORBGN+2) = Z(KORBGN+2) + NEWPTS        
      LOCBGS = KORBGN        
      CALL SUWRT (Z(KORBGN),3,2)        
      CALL READ (*215,*220,EQST,Z(KORBGN),ITRLR(5),1,NWDSRD)        
      DO 50 I = 1,NEWPTS        
      KORE = ITRLR(5) + 4*(I-1)        
      Z(KORBGN+KORE   ) = -1        
      RZ(KORBGN+KORE+1) = 0.0        
      RZ(KORBGN+KORE+2) = 0.0        
   50 RZ(KORBGN+KORE+3) = 0.0        
      NWDSRD = ITRLR(5) + 4*NEWPTS        
      CALL SUWRT (Z(KORBGN),NWDSRD,2)        
      CALL SUWRT (Z(KORBGN),0,3)        
      KORBGN = KORBGN + ITRLR(5)        
C        
C     PROCESS LODS, LOAP ITEM        
C        
   55 ITEM = LODS        
      IF (POPT .EQ. PAPP) ITEM = LOAP        
      ITEST = 3        
      CALL SFETCH (OLDNAM,ITEM,1,ITEST)        
      IF (ITEST .EQ. 3) GO TO 60        
      CALL SUREAD (Z(KORBGN),-1,NWDSRD,ITEST)        
      IF ((KORBGN + NWDSRD) .GE. KORLEN) GO TO 230        
      Z(KORBGN  ) = NEWNAM(1)        
      Z(KORBGN+1) = NEWNAM(2)        
      Z(KORBGN+3) = Z(KORBGN+3) + 1        
      Z(KORBGN+NWDSRD  ) = NEWNAM(1)        
      Z(KORBGN+NWDSRD+1) = NEWNAM(2)        
      Z(KORBGN+NWDSRD+2) = SOFEOG        
      IWDS  = NWDSRD + 3        
      CALL SUREAD (Z(KORBGN+IWDS),-2,NWDSRD,ITEST)        
      IF (KORBGN+IWDS+NWDSRD+2 .GE. KORLEN) GO TO 230        
      Z(KORBGN+IWDS+NWDSRD  ) = 0        
      Z(KORBGN+IWDS+NWDSRD+1) = SOFEOG        
      IWDS  = IWDS + NWDSRD + 2        
      ITEST = 3        
      CALL SFETCH (NEWNAM,ITEM,2,ITEST)        
      IF (ITEST .NE. 3) GO TO 250        
      CALL SUWRT (Z(KORBGN),IWDS,3)        
      IF (PONLY) GO TO 130        
C        
C     PROCESS PLTS ITEM        
C        
   60 CALL SFETCH (OLDNAM,4HPLTS,1,ITEST)        
      IF (ITEST .EQ. 3) GO TO 70        
      CALL SUREAD (Z(KORBGN),-1,NWDSRD,ITEST)        
      Z(KORBGN  ) = NEWNAM(1)        
      Z(KORBGN+1) = NEWNAM(2)        
      ITEST = 3        
      CALL SFETCH (NEWNAM,4HPLTS,2,ITEST)        
      IF (ITEST .NE. 3) GO TO 250        
      ITEST = 2        
      CALL SUWRT (Z(KORBGN),NWDSRD,ITEST)        
      ITEST = 3        
      CALL SUWRT (Z(KORBGN),0,ITEST)        
C        
C     PROCESS CSTM ITEM        
C        
   70 CALL SFETCH (OLDNAM,4HCSTM,1,ITEST)        
      IF (ITEST .EQ. 3) GO TO 130        
      CALL SUREAD (Z(KORBGN),-2,NWDSRD,ITEST)        
      IF (KORBGN+2*NWDSRD .GE. KORLEN) GO TO 230        
      Z(KORBGN  ) = NEWNAM(1)        
      Z(KORBGN+1) = NEWNAM(2)        
      KORE = NWDSRD - 4        
      CALL SORT(0,0,14,1,Z(KORBGN+3),KORE)        
      KORE = KORE/14        
      IF (KORBGN+2*NWDSRD+KORE .GE. KORLEN) GO TO 230        
      DO 80 I = 1, KORE        
   80 Z(KORBGN+NWDSRD+I-1) = 0        
      NBGSS = ITRLR(5)/4        
      DO 100 I = 1, NBGSS        
      K = 4*(I-1)        
      IF (Z(LOCBGS+K) .LE. 0) GO TO 100        
      DO 90 J = 1,KORE        
      LOC = 14*(J-1)        
      IF (Z(KORBGN+3+LOC) .NE. Z(LOCBGS+K)) GO TO 90        
      Z(KORBGN+NWDSRD+J-1) = 1        
      GO TO 100        
   90 CONTINUE        
  100 CONTINUE        
      LOCNEW = 0        
      DO 120 I = 1,KORE        
      IF (Z(KORBGN+NWDSRD+I-1) .EQ. 0) GO TO 120        
      LOCOLD = 14*(I-1)        
      DO 110 J = 1,14        
  110 Z(KORBGN+NWDSRD+KORE+LOCNEW+J-1) = Z(KORBGN+3+LOCOLD+J-1)        
      LOCNEW = LOCNEW + 14        
  120 CONTINUE        
      IF (LOCNEW .EQ. 0) GO TO 130        
      ITEST = 3        
      CALL SFETCH (NEWNAM,4HCSTM,2,ITEST)        
      CALL SUWRT (NEWNAM,2,2)        
      CALL SUWRT (Z(KORBGN+NWDSRD+KORE),LOCNEW,2)        
      CALL SUWRT (Z(KORBGN),0,3)        
C        
C     OUTPUT EQSS ITEM        
C        
  130 CALL CLOSE (EQST,1)        
      IF (ANDF(RSHIFT(IO,4),1) .NE. 1) GO TO 150        
      CALL SFETCH (NEWNAM,4HEQSS,1,ITEST)        
      IF (ITEST .NE. 1) GO TO 250        
      CALL SUREAD (Z(KORBGN), 4,NWDSRD,ITEST)        
      CALL SUREAD (Z(KORBGN),-1,NWDSRD,ITEST)        
      LOC = KORBGN + NWDSRD        
      NCSUBS = NCSUBS + 1        
      DO 140 I = 1, NCSUBS        
      CALL SUREAD (Z(LOC),-1,NWDSRD,ITEST)        
      NAMLOC = KORBGN + 2*(I-1)        
      CALL CMIWRT (1,NEWNAM,Z(NAMLOC),LOC,NWDSRD,Z,Z)        
  140 CONTINUE        
      CALL SUREAD (Z(LOC),-1,NWDSRD,ITEST)        
      IF ((LOC + NWDSRD) .GE. KORLEN) GO TO 230        
      CALL CMIWRT (8,NEWNAM,0,LOC,NWDSRD,Z,Z)        
C        
C     OUTPUT BGSS ITEM        
C        
  150 IF (ANDF(RSHIFT(IO,5),1) .NE. 1) GO TO 160        
      CALL SFETCH (NEWNAM,4HBGSS,1,ITEST)        
      IF (ITEST .NE. 1) GO TO 250        
      NGRP = 1        
      CALL SJUMP (NGRP)        
      CALL SUREAD (Z(KORBGN),-1,NWDSRD,ITEST)        
      CALL CMIWRT (2,NEWNAM,NEWNAM,KORBGN,NWDSRD,Z,Z)        
C        
C     OUTPUT CSTM ITEM        
C        
  160 IF (ANDF(RSHIFT(IO,6),1) .NE. 1) GO TO 170        
      CALL SFETCH (NEWNAM,4HCSTM,1,ITEST)        
      IF (ITEST .EQ. 3) GO TO 170        
      NGRP = 1        
      CALL SJUMP (NGRP)        
      CALL SUREAD (Z(KORBGN),-1,NWDSRD,ITEST)        
      CALL CMIWRT (3,NEWNAM,NEWNAM,KORBGN,NWDSRD,Z,Z)        
C        
C     OUTPUT PLTS ITEM        
C        
  170 IF (ANDF(RSHIFT(IO,7),1) .NE. 1) GO TO 180        
      CALL SFETCH (NEWNAM,4HPLTS,1,ITEST)        
      IF (ITEST .EQ. 3) GO TO 180        
      CALL SUREAD (Z(KORBGN), 3,NWDSRD,ITEST)        
      CALL SUREAD (Z(KORBGN),-1,NWDSRD,ITEST)        
      CALL CMIWRT (4,NEWNAM,NEWNAM,KORBGN,NWDSRD,Z,Z)        
C        
C     OUTPUT LODS ITEM        
C        
  180 IF (ANDF(RSHIFT(IO,8),1) .NE. 1) GO TO 200        
      CALL SFETCH (NEWNAM,ITEM,1,ITEST)        
      IF (ITEST .EQ. 3) GO TO 200        
      CALL SUREAD (Z(KORBGN), 4,NWDSRD,ITEST)        
      CALL SUREAD (Z(KORBGN),-1,NWDSRD,ITEST)        
      LOC = KORBGN + NWDSRD        
      ITYPE = 5        
      IF (ITEM .EQ. LOAP) ITYPE = 7        
      DO 190 I = 1,NCSUBS        
      NAMLOC = KORBGN + 2*(I-1)        
      CALL SUREAD (Z(LOC),-1,NWDSRD,ITEST)        
      CALL CMIWRT (ITYPE,NEWNAM,Z(NAMLOC),LOC,NWDSRD,Z,Z)        
      ITYPE = 6        
  190 CONTINUE        
C        
C     OUTPUT MODAL DOF SUMMARY        
C        
  200 IF (ANDF(RSHIFT(IO,9),1) .NE. 1) GO TO 209        
      ITEM = ITMLST(3)        
      ITMNAM(1) = OLDNAM(1)        
      ITMNAM(2) = OLDNAM(2)        
      CALL SFETCH (OLDNAM,ITEM,1,ITEST)        
      IF (ITEST .NE. 1) GO TO 250        
      CALL SUREAD (Z(KORBGN),-1,NWDSRD,ITEST)        
      CALL PAGE1        
      WRITE (IPRNTR,901) NEWNAM        
      LINE = LINE + 11        
      NOFREQ = Z(KORBGN+3)        
      LAMLOC = KORBGN        
      MODUSE = LAMLOC + 7*NOFREQ + 1        
      CALL SUREAD (Z(KORBGN),-2,NWDSRD,ITEST)        
      IF ((KORBGN + NWDSRD) .GE. KORLEN) GO TO 230        
      IF (USRMOD .GT. 1) GO TO 205        
      ITEM = ITMLST(1)        
      ITMNAM(1) = NEWNAM(1)        
      ITMNAM(2) = NEWNAM(2)        
      CALL SFETCH (NEWNAM,ITEM,1,ITEST)        
      IF (ITEST .NE. 1) GO TO 250        
      KORBGN = KORBGN + MODUSE + NOFREQ        
      IF (KORBGN .GE. KORLEN) GO TO 230        
      CALL SUREAD (Z(KORBGN),-1,NWDSRD,ITEST)        
      DO 201 I = 1,NCSUBS        
      CALL SUREAD (Z(KORBGN),-1,NWDSRD,ITEST)        
      IF (KORBGN+NWDSRD .GE. KORLEN) GO TO 230        
  201 CONTINUE        
      IPRB = 0        
      IF (FREBDY) IPRB = Z(KORBGN+1) - 1        
      NWDSRD = NWDSRD/3        
      LOCEQS = KORBGN        
      DO 202 I = 1,NWDSRD        
      J = 1 + 3*(I-1)        
      IPID = Z(LOCEQS+J)        
      IF (Z(LOCEQS+J-1) .GT. 100) GO TO 203        
  202 CONTINUE        
  203 KORBGN = KORBGN + 3*NWDSRD        
      IPID = 2*IPID        
      IF (KORBGN+IPID .GE. KORLEN) GO TO 230        
      CALL SUREAD (Z(KORBGN),IPID,NWDSRD,ITEST)        
      IPS = Z(KORBGN+IPID-2)        
      IF (.NOT. FREBDY) GO TO 205        
      DO 204 I = 1,FARIND        
      J = 3*(I-1)        
      K = 2*((I-1) + IPRB)        
  204 WRITE (IPRNTR,902) IZERO,ZERO,IZERO,Z(LOCEQS+J),Z(KORBGN+K)       
  205 INDEX1 = -3        
      IF (FREBDY) INDEX1 = 3*FARIND - 3        
      DO 208 I = 1,NOFREQ        
      IF (LINE .LE. NLPP) GO TO 206        
      CALL PAGE1        
      WRITE (IPRNTR,901) NEWNAM        
      LINE = LINE + 11        
  206 IF ((Z(MODUSE+I-1) .GT. 1) .OR. (USRMOD .GT. 1)) GO TO 207        
      INDEX1 = INDEX1 + 3        
      MODE = 7*(I-1)        
      WRITE (IPRNTR,902) Z(LAMLOC+MODE),RZ(LAMLOC+MODE+4),Z(MODUSE+I-1),
     1       Z(LOCEQS+INDEX1),IPS        
      IPS = IPS + 1        
      GO TO 208        
  207 MODE = 7*(I-1)        
      WRITE (IPRNTR,902) Z(LAMLOC+MODE),RZ(LAMLOC+MODE+4),Z(MODUSE+I-1) 
  208 LINE = LINE + 1        
  209 CONTINUE        
      GO TO 300        
C        
C     PROCESS SYSTEM FATAL ERRORS        
C        
  210 IMSG = -1        
      GO TO 240        
  215 IMSG = -2        
      GO TO 240        
  220 IMSG = -3        
      GO TO 240        
  230 IMSG = -8        
      IFILE = 0        
  240 CALL SOFCLS        
      CALL MESAGE (IMSG,IFILE,MODNAM)        
      GO TO 300        
C        
C     PROCESS MODULE FATAL ERRORS        
C        
  250 GO TO (260,260,260,270,280,280), ITEST        
  260 CALL SMSG1 (-9,ITEM,ITMNAM,MODNAM)        
      DRY = -2        
      GO TO 300        
  270 IMSG = -2        
      GO TO 290        
  280 IMSG = -3        
  290 CALL SMSG (IMSG,ITEM,ITMNAM)        
  300 RETURN        
C        
  901 FORMAT (1H0,36X,43HMODAL DOF SUMMARY FOR REDUCED SUBSTRUCTURE ,   
     1       2A4, //30X,36HUSAGE CODES ARE 0 - RIGID BODY POINT, /46X,  
     2       25H1 - INCLUDED IN MODAL SET, /46X,20H2 - EXCLUDED FROM MO,
     3       36HDAL SET BECAUSE OF NON-PARTICIPATION,/46X,10H3 - EXCLUD,
     4       42HED FROM MODAL SET BECAUSE OF RANGE OR NMAX,//40X,4HMODE,
     5       22X,15HUSAGE      GRID, /39X,6HNUMBER,8X,6HCYCLES,8X,      
     6       26HCODE    POINT ID       SIL,/)        
  902 FORMAT (39X,I5,5X,1P,E13.6,6X,I1,6X,I8,4X,I6)        
C        
      END        
