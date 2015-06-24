      SUBROUTINE MRED2P (NUS,NUF,N2)        
C        
C     THIS SUBROUTINE OUTPUTS THE HAB MATRIX TO THE SOF AS THE HORG ITEM
C     FOR THE MRED2 MODULE.        
C        
      INTEGER         DRY,GBUF1,OTFILE,Z,TYPIN,TYPOUT,HAB        
      DIMENSION       RZ(1),MODNAM(2),ITRLR1(7)        
      COMMON /BLANK / IDUM1,DRY,IDUM2,GBUF1,IDUM3(17),OTFILE(6),        
     1                ISCR(10),KORLEN,KORBGN,OLDNAM(2),IDUM4(12),NMODES 
CZZ   COMMON /ZZMRD2/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /PACKX / TYPIN,TYPOUT,IROW,NROW,INCR        
      COMMON /SYSTEM/ IDUM5,IPRNTR        
      EQUIVALENCE     (HAB,ISCR(2)),(RZ(1),Z(1))        
      DATA    MODNAM/ 4HMRED,4H2P  /        
      DATA    ITEM  / 4HHORG/        
C        
C     FORM HAB MATRIX        
C        
C        **   **   **     **        
C        *     *   *   .   *        
C        * HAB * = * I . 0 *        
C        *     *   *   .   *        
C        **   **   **     **        
C        
      IF (DRY .EQ. -2) GO TO 160        
      KOLMNS = NUS + NUF + N2        
      IF (N2 .EQ. 0) KOLMNS = KOLMNS + (NMODES - NUF)        
      TYPIN  = 1        
      TYPOUT = 1        
      IROW   = 1        
      NROW   = NUS + NUF        
      INCR   = 1        
      IFORM  = 2        
      CALL MAKMCB (ITRLR1,HAB,NROW,IFORM,TYPIN)        
      CALL GOPEN (HAB,Z(GBUF1),1)        
      DO 20 I = 1,KOLMNS        
      DO 10 J = 1,NROW        
      RZ(KORBGN+J-1) = 0.0        
      IF (I .GT. NUS+NUF) GO TO 10        
      IF (J .EQ. I) RZ(KORBGN+J-1) = 1.0        
   10 CONTINUE        
   20 CALL PACK (Z(KORBGN),HAB,ITRLR1)        
      CALL CLOSE (HAB,1)        
      CALL WRTTRL (ITRLR1)        
C        
C     STORE HAB MATRIX AS HORG ON SOF        
C        
      CALL MTRXO (HAB,OLDNAM,ITEM,0,ITEST)        
      IF (ITEST .NE. 3) GO TO 70        
      GO TO 160        
C        
C     PROCESS MODULE FATAL ERRORS        
C        
   70 GO TO (80,90,100,110,120,140), ITEST        
   80 IMSG = -9        
      GO TO 150        
   90 IMSG = -11        
      GO TO 150        
  100 IMSG = -1        
      GO TO 130        
  110 IMSG = -2        
      GO TO 130        
  120 IMSG = -3        
  130 CALL SMSG (IMSG,ITEM,OLDNAM)        
      GO TO 160        
  140 IMSG = -10        
  150 DRY = -2        
      CALL SMSG1 (IMSG,ITEM,OLDNAM,MODNAM)        
  160 RETURN        
      END        
