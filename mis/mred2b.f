      SUBROUTINE MRED2B        
C        
C     THIS SUBROUTINE PERFORMS THE GUYAN REDUCTION ON THE STRUCTURE     
C     POINTS FOR THE MRED2 MODULE.        
C        
C     INPUT DATA        
C     GINO   - KII    - KII PARTITION MATRIX        
C     SOF    - GIMS   - G TRANSFORMATION MATRIX FOR BOUNDARY POINTS OF  
C                       ORIGINAL SUBSTRUCTURE        
C        
C     OUTPUT DATA        
C     GINO   - LII    - LII PARTITION MATRIX        
C     SOF    - LMTX   - LII PARTITION MATRIX        
C              GIMS   - G TRANSFORMATION MATRIX FOR BOUNDARY POINTS OF  
C                       ORIGINAL SUBSTRUCTURE        
C        
C     PARAMETERS        
C     INPUT  - GBUF   - GINO BUFFER        
C              ISCR   - SCRATCH FILE NUMBER ARRAY        
C              KORLEN - LENGTH OF OPEN CORE        
C              KORBGN - BEGINNING ADDRESS OF OPEN CORE        
C              OLDNAM - NAME OF SUBSTRUCTURE BEGING REDUCED        
C              BOUNDS - OLDBOUNDS OPTION FLAG        
C              RSAVE  - DECOMPOSITION SAVE FLAG        
C     OTHERS - KIB    - KIB PARTITION MATRIX FILE NUMBER        
C              KII    - KII PARTITION MATRIX FILE NUMBER        
C              LII    - LII PARTITION MATRIX FILE NUMBER (ISCR11)       
C        
      LOGICAL         BOUNDS,RSAVE        
      INTEGER         DRY,SBUF1,SBUF2,SBUF3,OLDNAM,Z,POWER,CHLSKY,U,    
     1                GIBT,PREC,SIGN,GIB,DBLKOR,DMR        
      DOUBLE          PRECISION DETR,DETI,MINDIA,DZ        
      DIMENSION       ITRLR(7),MODNAM(2),ITMLST(2),DZ(1)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25,SWM*27        
      COMMON /XMSSG / UFM,UWM,UIM,SFM,SWM        
      COMMON /BLANK / IDUM1,DRY,IDUM4(4),SBUF1,SBUF2,SBUF3,INFILE(12),  
     1                IDUM6(6),ISCR(10),KORLEN,KORBGN,OLDNAM(2),        
     2                IDUM2(8),BOUNDS,IDUM3,RSAVE,IDUM7(4),LSTZWD,ISCR11
CZZ   COMMON /ZZMRD2/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SFACT / KIIT(7),LIIT(7),ISCRQ(7),ISCRA,ISCRB,NZSF,        
     1                DETR,DETI,POWER,ISCRC,MINDIA,CHLSKY        
      COMMON /FBSX  / LIIFBS(7),U(7),KIBT(7),GIBT(7),NZFBS,PREC,SIGN    
      COMMON /SYSTEM/ IDUM5,IPRNTR        
      EQUIVALENCE     (DMR,INFILE(11)),(GIB,ISCR(6)),(DZ(1),Z(1)),      
     1                (KIB,ISCR(2)),(KII,ISCR(3)),(LII,ISCR11)        
      DATA    MODNAM/ 4HMRED,4H2B  /        
      DATA    LOWER / 4 /        
      DATA    ITMLST/ 4HLMTX,4HGIMS/        
C        
C     TEST FOR GUYAN REDUCTION        
C        
      IF (DRY .EQ. -2) GO TO 140        
      IF (.NOT.BOUNDS) GO TO 10        
      ITRLR(1) = DMR        
      CALL RDTRL (ITRLR)        
      IF (ITRLR(1) .LT. 0) GO TO 35        
      ITEM = ITMLST(1)        
      CALL SOFTRL (OLDNAM,ITEM,ITRLR)        
      IF (ITRLR(1) .EQ. 1) GO TO 35        
C        
C     DECOMPOSE INTERIOR STIFFNESS MATRIX        
C        
C                                 T        
C        **   **   **   ** **   **        
C        *     *   *     * *     *        
C        * KII * = * LII * * LII *        
C        *     *   *     * *     *        
C        **   **   **   ** **   **        
C        
   10 CALL SOFCLS        
      KIIT(1) = KII        
      CALL RDTRL (KIIT)        
      CALL MAKMCB (LIIT,LII,KIIT(3),LOWER,KIIT(5))        
      ISCRQ(1) = ISCR(6)        
      ISCRA  = ISCR(7)        
      ISCRB  = ISCR(8)        
      ISCRC  = ISCR(9)        
      POWER  = 1        
      CHLSKY = 0        
      DBLKOR = 1 + KORBGN/2        
      NZSF   = LSTZWD - 2*DBLKOR - 1        
      CALL SDCOMP (*40,DZ(DBLKOR),DZ(DBLKOR),DZ(DBLKOR))        
      CALL WRTTRL (LIIT)        
C        
C     SAVE LII AS LMTX ON SOF        
C        
      IF (.NOT. RSAVE) GO TO 20        
      CALL SOFOPN (Z(SBUF1),Z(SBUF2),Z(SBUF3))        
      IFILE = LII        
      ITEM  = ITMLST(1)        
      CALL MTRXO (LII,OLDNAM,ITEM,0,ITEST)        
      IF (ITEST .NE. 3) GO TO 70        
      IF (BOUNDS) GO TO 35        
      CALL SOFCLS        
C        
C     SOLVE STRUCTURE REDUCTION TRANSFORMATION MATRIX        
C        
C                       T        
C        **   ** **   ** **   **    **   **        
C        *     * *     * *     *    *     *        
C        * LII * * LII * * GIB * = -* KIB *        
C        *     * *     * *     *    *     *        
C        **   ** **   ** **   **    **   **        
C        
   20 IF (BOUNDS) GO TO 32        
      KIBT(1) = KIB        
      CALL RDTRL (KIBT)        
      DO 30 I = 1,7        
   30 LIIFBS(I) = LIIT(I)        
      CALL MAKMCB (GIBT,GIB,KIBT(3),KIBT(4),KIBT(5))        
      NZFBS = LSTZWD - 2*DBLKOR        
      PREC  = KIBT(5)        
      SIGN  = -1        
      CALL FBS (DZ(DBLKOR),DZ(DBLKOR))        
      CALL WRTTRL (GIBT)        
C        
C     SAVE GIB AS GIMS ON SOF        
C        
      CALL SOFOPN (Z(SBUF1),Z(SBUF2),Z(SBUF3))        
      IFILE = GIB        
      ITEM  = ITMLST(2)        
      CALL MTRXO (GIB,OLDNAM,ITEM,0,ITEST)        
      IF (ITEST .NE. 3) GO TO 70        
      GO TO 35        
   32 CALL SOFOPN (Z(SBUF1),Z(SBUF2),Z(SBUF3))        
   35 CONTINUE        
      GO TO 140        
C        
C     PROCESS SYSTEM FATAL ERRORS        
C        
   40 WRITE  (IPRNTR,45) SWM,OLDNAM        
   45 FORMAT (A27,' 6311, SDCOMP DECOMPOSITION FAILED ON KII MATRIX ',  
     1       'FOR SUBSTRUCTURE ',2A4)        
      IMSG  = -37        
      IFILE = 0        
      CALL MESAGE (IMSG,IFILE,MODNAM)        
      GO TO 140        
C        
C     PROCESS MODULE FATAL ERRORS        
C        
   70 GO TO (80,80,80,90,100,120), ITEST        
   80 IMSG = -9        
      GO TO 130        
   90 IMSG = -2        
      GO TO 110        
  100 IMSG = -3        
  110 CALL SMSG (IMSG,ITEM,OLDNAM)        
      GO TO 140        
  120 IMSG = -10        
  130 DRY = -2        
      CALL SMSG1 (IMSG,ITEM,OLDNAM,MODSAM)        
  140 RETURN        
C        
      END        
