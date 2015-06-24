      SUBROUTINE CMRD2        
C        
C     THIS SUBROUTINE IS THE CMRED2 MODULE WHICH PERFORMS THE MAJOR     
C     COMPUTATIONS FOR THE COMPLEX MODAL REDUCE COMMAND.        
C        
C     DMAP CALLING SEQUENCE        
C     CMRED2   CASECC,LAMAMR,PHISSR,PHISSL,EQST,USETMR,KAA,MAA,BAA,K4AA,
C              PAA/KHH,MHH,BHH,K4HH,PHH,POVE/STEP/S,N,DRY/POPT $        
C        
C     INPUT  DATA        
C     GINO - CASECC - CASE CONTROL DATA        
C            LAMAMR - EIGENVALUE TABLE FOR SUBSTRUCTURE BEING REDUCED   
C            PHISSR - RIGHT HAND EIGENVECTORS FOR SUBSTRUCTURE BEING    
C                     REDUCED        
C            PHISSL - LEFT HAND EIGENVECTORS FOR SUBSTRUCTURE BEING     
C                     REDUCED        
C            EQST   - EQSS DATA FOR BOUNDARY SET FOR SUBSTRUCTURE BEING 
C                     REDUCED        
C            USETMR - USET TABLE FOR REDUCED SUBSTRUCTURE        
C            KAA    - SUBSTRUCTURE STIFFNESS MATRIX        
C            MAA    - SUBSTRUCTURE MASS MATRIX        
C            BAA    - SUBSTRUCTURE VISCOUS DAMPING MATRIX        
C            K4AA   - SUBSTRUCTURE STRUCTURE DAMPINF MATRIX        
C            PAA    - SUBSTRUCTURE LOAD MATRIX        
C     SOF  - LAMS   - EIGENVALUE TABLE FOR ORIGINAL SUBSTRUCTURE        
C            PHIS   - RIGHT HAND EIGENVECTOR TABLE FOR ORIGINAL        
C                     SUBSTRUCTURE        
C            PHIL   - LEFT HAND EIGENVECTOR TABLE FOR ORIGINAL        
C                     SUBSTRUCTURE        
C            HORG   - RIGHT HAND H TRANSFORMATION MATRIX FOR ORIGINAL   
C                     SUBSTRUCTURE        
C            HLFT   - LEFT HAND H TRANSFORMATION MATRIX FOR ORIGINAL    
C                     SUBSTRUCTURE        
C        
C     OUTPUT DATA        
C     GINO - KHH    - REDUCED STIFFNESS MATRIX        
C            MHH    - REDUCED MASS MATRIX        
C            BHH    - REDUCED VISCOUS DAMPING MATRIX        
C            K4HH   - REDUCED STRUCTURE DAMPING MATRIX        
C            PHH    - REDUCED LOAD MATRIX        
C            POVE   - INTERIOR POINT LOAD MATRIX        
C     SOF  - LAMS   - EIGENVALUE TABLE FOR ORIGINAL SUBSTRUCTURE        
C            PHIS   - RIGHT HAND EIGENVECTOR TABLE FOR ORIG.SUBSTRUCTURE
C            PHIL   - LEFT HAND EIGENVECTOR TABLE FOR ORIG. SUBSTRUCTURE
C            GIMS   - G TRANSFORMATION MATRIX FOR BOUNDARY POINTS FOR   
C                     ORIGINAL SUBSTRUCTURE        
C            HORG   - RIGHT HAND H TRANSFORMATION MATRIX FOR ORIGINAL   
C                     SUBSTRUCTURE        
C            HLFT   - LEFT HAND H TRANSFORMATION MATRIX FOR ORIGINAL    
C                     SUBSTRUCTURE        
C            UPRT   - PARTITIONING VECTOR FOR CREDUCE FOR ORIGINAL      
C                     SUBSTRUCTURE        
C            POVE   - INTERNAL POINT LOADS FOR ORIGINAL SUBSTRUCTURE    
C            POAP   - INTERNAL POINTS APPENDED LOADS FOR ORIGINAL       
C                     SUBSTRUCTURE        
C            EQSS   - SUBSTRUCTURE EQUIVALENCE TABLE FOR REDUCED        
C                     SUBSTRUCTURE        
C            BGSS   - BASIC GRID POINT DEFINITION TABLE FOR REDUCED     
C                     SUBSTRUCTURE        
C            CSTM   - COORDINATE SYSTEM TRANSFORMATION MATRICES FOR     
C                     REDUCED SUBSTRUCTURE        
C            LODS   - LOAD SET DATA FOR REDUCED SUBSTRUCTURE        
C            LOAP   - APPENDED LOAD SET DATA FOR REDUCED SUBSTRUCTURE   
C            PLTS   - PLOT SET DATA FOR REDUCED SUBSTRUCTURE        
C            KMTX   - STIFFNESS MATRIX FOR REDUCED SUBSTRUCTURE        
C            MMTX   - MASS MATRIX FOR REDUCED SUBSTRUCTURE        
C            PVEC   - LOAD MATRIX FOR REDUCED SUBSTRUCTURE        
C            PAPD   - APPENDED LOAD MATRIX FOR REDUCED SUBSTRUCTURE     
C            BMTX   - VISCOUS DAMPING MATRIX FOR REDUCED SUBSTRUCTURE   
C            K4MX   - STRUCTURE DAMPING MATRIX FOR REDUCED SUBSTRUCTURE 
C        
C     PARAMETERS        
C     INPUT  - STEP   - CONTROL DATA CASECC RECORD (INTEGER)        
C              POPT   - PVEC OR PAPP OPTION FLAG (BCD)        
C     OUTPUT - DRY    - MODULE OPERATION FLAG (INTEGER)        
C     OTHERS - GBUF   - GINO BUFFERS        
C              SBUF   - SOF BUFFERS        
C              INFILE - INPUT FILE NUMBERS        
C              OTFILE - OUTPUT FILE NUMBERS        
C              ISCR   - ARRAY OF SCRATCH FILE NUMBERS        
C              KORLEN - LENGTH OF OPEN CORE        
C              KORBGN - BEGINNING ADDRESS OF OPEN CORE        
C              OLDNAM - NAME OF SUBSTRUCTURE BEING REDUCED        
C              NEWNAM - NAME OF REDUCED SUBSTRUCTURE        
C              SYMTRY - SYMMETRY FLAG        
C              RANGE  - RANGE OF FREQUENCIES TO BE USED        
C              NMAX   - MAXIMUM NUMBER OF FREQUENCIES TO BE USED        
C              IO     - IO OPTIONS FLAG        
C              MODES  - OLDMODES OPTION FLAG        
C              RSAVE  - SAVE REDUCTION PRODUCT FLAG        
C              LAMSAP - BEGINNING ADDRESS OF MODE USE DESCRIPTION ARRAY 
C              MODLEN - LENGTH OF MODE USE ARRAY        
C              MODPTS - NUMBER OF MODAL POINTS        
C        
      EXTERNAL        ORF        
      LOGICAL         SYMTRY,MODES,RSAVE,PONLY        
      INTEGER         STEP,DRY,POPT,GBUF1,GBUF2,GBUF3,SBUF1,SBUF2,SBUF3,
     1                OTFILE,OLDNAM,Z,SYSBUF,CASECC,YES,PHISSL,ORF      
      DIMENSION       MODNAM(2),NMONIC(8),RZ(1),ITRLR(7)        
      COMMON /BLANK / STEP,DRY,POPT,GBUF1,GBUF2,GBUF3,SBUF1,SBUF2,SBUF3,
     1                INFILE(11),OTFILE(6),ISCR(11),KORLEN,KORBGN,      
     2                OLDNAM(2),NEWNAM(2),SYMTRY,RANGE(2),NMAX,IO,MODES,
     3                RSAVE,LAMSAP,MODPTS,MODLEN,PONLY,LSTZWD        
CZZ   COMMON /ZZCMRD/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SYSTEM/ SYSBUF,IPRNTR        
      EQUIVALENCE     (CASECC,INFILE(1)),(PHISSL,INFILE(4)),(RZ(1),Z(1))
      DATA    NMONIC/ 4HNAMA,4HNAMB,4HSYMF,4HRANG,4HNMAX,4HOUTP,4HOLDM, 
     1                4HRSAV/        
      DATA    KAA   / 107 /, IBLANK,YES /4H    , 4HYES /        
      DATA    MODNAM/ 4HCMRD,4H2   /        
      DATA    NHLODS, NHLOAP,NHHORG,NHHLFT /4HLODS,4HLOAP,4HHORG,4HHLFT/
C        
C     COMPUTE OPEN CORE AND DEFINE GINO, SOF BUFFERS        
C        
      IF (DRY .EQ. -2) RETURN        
      NOZWDS = KORSZ(Z(1))        
      LSTZWD = NOZWDS - 1        
      GBUF1  = NOZWDS - SYSBUF - 2        
      GBUF2  = GBUF1  - SYSBUF        
      GBUF3  = GBUF2  - SYSBUF        
      SBUF1  = GBUF3  - SYSBUF        
      SBUF2  = SBUF1  - SYSBUF - 1        
      SBUF3  = SBUF2  - SYSBUF        
      KORLEN = SBUF3  - 1        
      KORBGN = 1        
      IF (KORLEN .LE. KORBGN) GO TO 290        
C        
C     INITIALIZE SOF        
C        
      CALL SOFOPN (Z(SBUF1),Z(SBUF2),Z(SBUF3))        
C        
C     INITIALIZE CASE CONTROL PARAMETERS        
C        
      DO 6 I = 1,11        
      IF (I .GT. 6) GO TO 2        
      INFILE(I) = 100 + I        
      OTFILE(I) = 200 + I        
      ISCR(I) = 300 + I        
      GO TO 6        
    2 INFILE(I) = 100 + I        
      ISCR(I) = 300 + I        
    6 CONTINUE        
      DO 10 I = 1,2        
      OLDNAM(I) = IBLANK        
   10 NEWNAM(I) = IBLANK        
      RANGE(1) = -1.0E+35        
      RANGE(2) =  1.0E+35        
      SYMTRY = .FALSE.        
      NMAX   = 2147483647        
      IO     = 0        
      MODES  = .FALSE.        
      RSAVE  = .FALSE.        
      NRANGE = 0        
      PONLY  = .FALSE.        
C        
C     PROCESS CASE CONTROL        
C        
      IFILE = CASECC        
      CALL OPEN (*260,CASECC,Z(GBUF2),0)        
      IF (STEP) 20,40,20        
   20 DO 30 I = 1,STEP        
   30 CALL FWDREC (*280,CASECC)        
C        
C     READ CASECC        
C        
   40 CALL READ (*270,*280,CASECC,Z(KORBGN),2,0,NWDSRD)        
      NWDSCC = Z(KORBGN+1)        
      DO 200 I = 1,NWDSCC,3        
      CALL READ (*270,*280,CASECC,Z(KORBGN),3,0,NWDSRD)        
C        
C     TEST CASE CONTROL MNEMONICS        
C        
      DO 50 J = 1,8        
      IF (Z(KORBGN) .EQ. NMONIC(J)) GO TO 60        
   50 CONTINUE        
      GO TO 200        
C        
C     SELECT DATA TO EXTRACT        
C        
   60 GO TO (70,90,110,120,140,160,180,190), J        
C        
C     EXTRACT NAME OF SUBSTRUCTURE BEING REDUCED        
C        
   70 DO 80 K = 1,2        
   80 OLDNAM(K) = Z(KORBGN+K)        
      GO TO 200        
C        
C     EXTRACT NAME OF REDUCED SUBSTRUCTURE        
C        
   90 DO 100 K = 1,2        
  100 NEWNAM(K) = Z(KORBGN+K)        
      GO TO 200        
C        
C     EXTRACT SYMMETRY FLAG        
C        
  110 IF (Z(KORBGN+1) .NE. YES) GO TO 200        
      SYMTRY = .TRUE.        
      GO TO 200        
C        
C     EXTRACT FREQUENCY RANGE        
C        
  120 IF (NRANGE .EQ. 1) GO TO 125        
      NRANGE = 1        
      RANGE(1) = RZ(KORBGN+2)        
      GO TO 200        
  125 RANGE(2) = RZ(KORBGN+2)        
      GO TO 200        
C        
C     EXTRACT MAXIMUM NUMBER OF FREQUENCIES        
C        
  140 IF (Z(KORBGN) .EQ. 0) GO TO 200        
      NMAX = Z(KORBGN+2)        
      GO TO 200        
C        
C     EXTRACT OUTPUT FLAGS        
C        
  160 IO = ORF(IO,Z(KORBGN+2))        
      GO TO 200        
C        
C     EXTRACT OLDMODES FLAG        
C        
  180 IF (Z(KORBGN+1) .NE. YES) GO TO 200        
      MODES = .TRUE.        
      GO TO 200        
C        
C     EXTRACT REDUCTION SAVE FLAG        
C        
  190 IF (Z(KORBGN+1) .NE. YES) GO TO 200        
      RSAVE = .TRUE.        
  200 CONTINUE        
      CALL CLOSE (CASECC,1)        
C        
C     CHECK FOR SYMMETRY        
C        
      ITRLR(1) = PHISSL        
      CALL RDTRL (ITRLR)        
      NPASS = 2        
      IF (ITRLR(1) .GT. 0) GO TO 204        
      SYMTRY = .TRUE.        
      NPASS = 1        
C        
C     CHECK FOR RUN = GO        
C        
  204 IHORG = 0        
      IF (DRY .EQ. 0) GO TO 240        
C        
C     CHECK FOR STIFFNESS PROCESSING        
C        
      ITRLR(1) = KAA        
      CALL RDTRL (ITRLR)        
      IF (ITRLR(1) .GT. 0) GO TO 208        
C        
C     CHECK FOR LOADS ONLY PROCESSING        
C        
      CALL SFETCH (NEWNAM,NHLODS,3,ITEST)        
      IF (ITEST .EQ. 3) PONLY = .TRUE.        
      CALL SFETCH (NEWNAM,NHLOAP,3,ITEST)        
      IF (ITEST .EQ. 3) PONLY = .TRUE.        
      GO TO 240        
C        
C     PROCESS STIFFNESS MATRIX        
C        
  208 CALL CMRD2A        
C        
C     BEGIN COMPLEX MODAL REDUCTION        
C     NPASS .EQ. 1, SYMMETRIC REDUCTION        
C     NPASS .EQ. 2, UNSYMMETRIC REDUCTION        
C        
      DO 230 J = 1,NPASS        
C        
C     TEST FOR H TRANSFORMATION MATRICES        
C        
      GO TO (212,214), J        
  212 CALL SOFTRL (OLDNAM,NHHORG,ITRLR)        
      IF (ITRLR(1) .EQ. 1) GO TO 230        
      IHORG = IHORG + 1        
      GO TO 216        
  214 CALL SOFTRL (OLDNAM,NHHLFT,ITRLR)        
      IF (ITRLR(1) .EQ. 1) GO TO 230        
      IHORG = IHORG + 2        
C        
C     PREFORM GUYAN REDUCTION        
C        
  216 CALL CMRD2C (J)        
C        
C     PROCESS OLDMODES FLAG        
C        
      CALL CMRD2B (J)        
C        
C     CALCULATE MODAL TRANSFORMATION MATRIX        
C        
      CALL CMRD2D (J)        
      IF (J .EQ. 1) CALL CMRD2B (3)        
C        
C     CALCULATE H TRANSFORMATION MATRIX        
C        
      CALL CMRD2E (J)        
  230 CONTINUE        
C        
C     CALCULATE STRUCTURAL MATRICES        
C     IHORG .EQ. 0, BOTH HORG, HLFT ON SOF        
C     IHORG .EQ. 1, HORG CALCULATED, HLFT ON SOF        
C     IHORG .EQ. 2, HORG ON SOF, HLFT CALCULATED        
C     IHORG .EQ. 3, BOTH HORG, HLFT CALCULATED        
C        
  240 CALL CMRD2F (IHORG)        
      IF (IHORG .EQ. 0) GO TO 250        
C        
C     PROCESS NEW TABLE ITEMS        
C        
      CALL CMRD2G        
C        
C     CLOSE ANY OPEN FILES        
C        
  250 CALL SOFCLS        
      IF (DRY .EQ. -2) WRITE (IPRNTR,900)        
      RETURN        
C        
C     PROCESS SYSTEM FATAL ERRORS        
C        
  260 IMSG = -1        
      GO TO 300        
  270 IMSG = -2        
      GO TO 300        
  280 IMSG = -3        
      GO TO 300        
  290 IMSG = -8        
      IFILE = 0        
  300 CALL SOFCLS        
      CALL MESAGE (IMSG,IFILE,MODNAM)        
      RETURN        
C        
  900 FORMAT (50H0  MODULE CREDUCE TERMINATING DUE TO ABOVE ERRORS.)    
C        
      END        
