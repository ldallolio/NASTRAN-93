      SUBROUTINE KTRM6S        
C        
C     STIFFNESS MATRIX FOR TRIANGULAR MEMBRANE ELEMENT  TRIM6        
C     SINGLEPRECISION VERSION        
C        
C     EST ENTRIES        
C        
C     EST( 1) = ELEMENT ID                              INTEGER        
C     EST( 2) = SCALAR INDEX NUMBER FOR GRID POINT 1    INTEGER        
C     EST( 3) = SCALAR INDEX NUMBER FOR GRID POINT 2    INTEGER        
C     EST( 4) = SCALAR INDEX NUMBER FOR GRID POINT 3    INTEGER        
C     EST( 5) = SCALAR INDEX NUMBER FOR GRID POINT 4    INTEGER        
C     EST( 6) = SCALAR INDEX NUMBER FOR GRID POINT 5    INTEGER        
C     EST( 7) = SCALAR INDEX NUMBER FOR GRID POINT 6    INTEGER        
C     EST( 8) = THETA                                   REAL        
C     EST( 9) = MATERIAL IDENTIFICATION NUMBER          INTEGER        
C     EST(10) = THICKNESS T1 AT GRID POINT 1            REAL        
C     EST(11) = THICKNESS T3 AT GRID POINT 3            REAL        
C     EST(12) = THICKNESS T5 AT GRID POINT 5            REAL        
C     EST(13) = NON-STRUCTURAL MASS                     REAL        
C        
C     X1,Y1,Z1 FOR ALL SIX POINTS ARE IN NASTRAN BASIC SYSTEM        
C        
C     EST(14) = COORDINATE SYSTEM ID FOR GRID POINT 1   INTEGER        
C     EST(15) = COORDINATE X1                           REAL        
C     EST(16) = COORDINATE Y1                           REAL        
C     EST(17) = COORDINATE Z1                           REAL        
C     EST(18) = COORDINATE SYSTEM ID FOR GRID POINT 2   INTEGER        
C     EST(19) = COORDINATE X2                           REAL        
C     EST(20) = COORDINATE Y2                           REAL        
C     EST(21) = COORDINATE Z2                           REAL        
C     EST(22) = COORDINATE SYSTEM ID FOR GRID POINT 3   INTEGER        
C     EST(23) = COORDINATE X3                           REAL        
C     EST(24) = COORDINATE Y3                           REAL        
C     EST(25) = COORDINATE Z3                           REAL        
C     EST(26) = COORDINATE SYSTEM ID FOR GRID POINT 4   INTEGER        
C     EST(27) = COORDINATE X4                           REAL        
C     EST(28) = COORDINATE Y4                           REAL        
C     EST(29) = COORDINATE Z4                           REAL        
C     EST(30) = COORDINATE SYSTEM ID FOR GRID POINT 5   INTEGER        
C     EST(31) = COORDINATE X5                           REAL        
C     EST(32) = COORDINATE Y5                           REAL        
C     EST(33) = COORDINATE Z5                           REAL        
C     EST(34) = COORDINATE SYSTEM ID FOR GRID POINT 6   INTEGER        
C     EST(35) = COORDINATE X6                           REAL        
C     EST(36) = COORDINATE Y6                           REAL        
C     EST(37) = COORDINATE Z6                           REAL        
C     EST(38) TO EST (43) = ELEMENT TEMPERATURES AT SIX GRID POINTS     
C        
      LOGICAL         IMASS,NOGO,UNIMEM        
      INTEGER         XU(12),YU(12),XV(12),YV(12),ELTYPE,ELID,ESTID,    
     1                DICT(11),SIL(6),SIL1,SIL2,SAVE(6),RK(3),SK(3),PI, 
     2                QI,PJ,QJ,PIMJ,PINJ,PIPJ,PIQJ,QIMJ,QINJ,QIPJ,QIQJ  
      REAL            IVECT(3),JVECT(3),KVECT(3),KTRM(12,12),KSUB(2,2), 
     1                KSUBT(3,2),KTR(3,3),KTR1(3,3),KTRMG(324),KRT(9),  
     2                KRT1(9)        
      REAL            NSM,GKT(12,12)        
      DIMENSION       F(6,6),XC(6),YC(6),ZC(6),Q(6,6),E(6),TRAND(9),    
     1                BALOTR(9),QINV(36),GKTRM(12,12),GK11(6,6),        
     2                GK12(6,6),GK22(6,6)        
      DIMENSION       IND(6,3),NAME(2),ICS(6),IEST(45),NL(6),CC(3)      
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /SYSTEM/ KSYSTM(63)        
      COMMON /EMGPRM/ IXTRA,IZR,NZR,DUMY(12),KMBGG(3),IPREC,NOGO        
      COMMON /BLANK / NOK,NOM        
      COMMON /EMGEST/ EST (45)        
      COMMON /EMGDIC/ ELTYPE,LDICT,NLOCS,ELID,ESTID        
      COMMON /MATIN / MATID,MATFLG,ELTEMP,PLA34,SINTH,COSTH        
      COMMON /MATOUT/ EM(6),RHOY,ALF(3),TREF,GSUBE,SIGTY,SIGCY,SIGSY,   
     1                RJ11,RJ12,RJ22        
      EQUIVALENCE     (KSYSTM(2),IOUTPT),(GKT(1,1),GKTRM(1,1)),        
     1                (EST(1),IEST(1)),(A,DISTA),(B,DISTB),(C,DISTC),   
     2                (CC(1),C1),(CC(2),C2),(CC(3),C3),        
     3                (KRT(1),KTR(1,1)),(KRT1(1),KTR1(1,1))        
      DATA    XU    / 0,1,0,2,1,0,6*0/ ,  YU / 0,0,1,0,1,2,6*0/        
      DATA    XV    / 6*0,0,1,0,2,1,0/ ,  YV / 6*0,0,0,1,0,1,2/        
      DATA    RK    / 0,1,0          / ,  SK / 0,0,1          /        
      DATA    DEGRA / 0.0174532925   / ,  BLANK / 4H          /        
      DATA    NAME  / 4HTRIM, 4H6    /        
C        
C     COMPONENT CODE,ICODE,IS  000111  AND HAS A VALUE OF 7        
C        
      ICODE   = 7        
      NDOF    = 18        
      NSQ     = NDOF**2        
      DICT(1) = ESTID        
      DICT(2) = 1        
      DICT(3) = NDOF        
      DICT(4) = ICODE        
      DICT(5) = GSUBE        
      IPASS   = 1        
      IMASS   =.FALSE.        
      IF (NOM .GT. 0) IMASS = .TRUE.        
C        
C     ALLOCATE EST VALUES TO RESPECTIVE  LOCAL  VARIABLES        
C        
      IDELE  = IEST(1)        
      DO 109 I = 1,6        
      NL(I)  = IEST(I+1)        
  109 CONTINUE        
      THETAM = EST(8)        
      MATID1 = IEST(9)        
      TMEM1  = EST(10)        
      TMEM3  = EST(11)        
      TMEM5  = EST(12)        
C        
C     IF  TMEM3 OR TMEM5 IS 0.0 OR BLANK,IT WILL BE SET EQUAL TO TMEM1  
C        
      IF (TMEM3.EQ.0.0 .OR. TMEM3.EQ.BLANK) TMEM3 = TMEM1        
      IF (TMEM5.EQ.0.0 .OR. TMEM5.EQ.BLANK) TMEM5 = TMEM1        
C        
      NSM = EST(13)        
      J   = 0        
      DO 120 I = 14,34,4        
      J   = J + 1        
      ICS(J) = IEST(I )        
      XC (J) = EST(I+1)        
      YC (J) = EST(I+2)        
      ZC (J) = EST(I+3)        
  120 CONTINUE        
      ELTEMP = (EST(38)+EST(39)+EST(40)+EST(41)+EST(42)+EST(43))/6.0    
      THETA1 = THETAM*DEGRA        
      SINTH  = SIN(THETA1)        
      COSTH  = COS(THETA1)        
      IF (ABS(SINTH) .LE. 1.0E-06) SINTH = 0.0        
C        
C     START ELEMENT CALCULATIONS FOR STIFFNESS MATRIX        
C        
C     EVALUATE  MATERIAL PROPERTIES        
C        
      MATFLG = 2        
      MATID  = MATID1        
      CALL MAT (IDELE)        
C        
C     CALCULATIONS FOR THE  TRIANGLE        
C        
      CALL TRIF (XC,YC,ZC,IVECT,JVECT,KVECT,A,B,C,IEST(1),NAME)        
C        
C     FILL THE E-MATRIX        
C        
      E(1) = IVECT(1)        
      E(2) = JVECT(1)        
      E(3) = IVECT(2)        
      E(4) = JVECT(2)        
      E(5) = IVECT(3)        
      E(6) = JVECT(3)        
C        
C     COMPUTE THE F FUCTION, AND CONSTANTS C1, C2, AND C3 IN THE LINEAR 
C     EQUS. FOR THICKNESS VARIATION        
C        
      CALL AF (F,6,A,B,C,C1,C2,C3,TMEM1,TMEM3,TMEM5,0)        
      AREA = F(1,1)        
      VOL  = C1*F(1,1) + C2*F(2,1) + C3*F(1,2)        
      UNIMEM = .FALSE.        
      IF (ABS(C2).LE.1.0E-06 .AND. ABS(C3).LE.1.0E-06) UNIMEM = .TRUE.  
C        
C     CALCULATIONS FOR  Q MATRIX AND ITS INVERSE        
C        
      DO 200 I = 1,36        
      Q(I,1) = 0.0        
  200 CONTINUE        
      DO 210 I = 1,6        
      Q(I,1) = 1.0        
      Q(I,2) = XC(I)        
      Q(I,3) = YC(I)        
      Q(I,4) = XC(I)*XC(I)        
      Q(I,5) = XC(I)*YC(I)        
      Q(I,6) = YC(I)*YC(I)        
  210 CONTINUE        
C        
C     FIND INVERSE OF Q MATRIX        
C        
C     NO NEED TO COMPUTE DETERMINANT SINCE IT IS NOT USED SUBSEQUENTLY. 
C        
      ISING = -1        
      CALL INVERS (6,Q,6,QINV(1),0,DETERM,ISING,IND)        
C        
C     ISING EQUAL TO 2 IMPLIES THAT Q MATRIX IS SINGULAR        
C        
      IF (ISING .EQ. 2) GO TO 904        
C        
C     GKTRM IS STIFFNESS MATRIX IN GENERALIZED CO-ORDINATES.        
C     KTRM  IS STIFFNESS MATRIX IN ELEMENT CO-ORDINATES.        
C     START EXECUTION FOR STIFFNESS MATRIX CALCULATIONS        
C        
      G11 = EM(1)        
      G12 = EM(2)        
      G13 = EM(3)        
      G22 = EM(4)        
      G23 = EM(5)        
      G33 = EM(6)        
C        
C     FORMULATION OF THE STIFFNESS MATRIX (FROM PROG. MANUAL,        
C     PAGE 8.24-7)        
C        
      DO 240 I = 1,12        
      MI   = XU(I)        
      NI   = YU(I)        
      PI   = XV(I)        
      QI   = YV(I)        
      DO 235 J = I,12        
      MJ   = XU(J)        
      NJ   = YU(J)        
      PJ   = XV(J)        
      QJ   = YV(J)        
      MIMJ = MI*MJ        
      MINJ = MI*NJ        
      MIPJ = MI*PJ        
      MIQJ = MI*QJ        
      NIMJ = NI*MJ        
      NINJ = NI*NJ        
      NIPJ = NI*PJ        
      NIQJ = NI*QJ        
      PIMJ = PI*MJ        
      PINJ = PI*NJ        
      PIPJ = PI*PJ        
      PIQJ = PI*QJ        
      QIMJ = QI*MJ        
      QINJ = QI*NJ        
      QIPJ = QI*PJ        
      QIQJ = QI*QJ        
      ST1  = 0.0        
      DO 225 K = 1,3        
      KR   = RK(K)        
      KS   = SK(K)        
      ST   = 0.0        
      IF (MIMJ .GT. 0) ST=ST + G11*MIMJ *F(MI+MJ+KR-1,NI+NJ+KS+1)       
      IF (QIQJ .GT. 0) ST=ST + G22*QIQJ *F(PI+PJ+KR+1,QI+QJ+KS-1)       
      IF (NINJ .GT. 0) ST=ST + G33*NINJ *F(MI+MJ+KR+1,NI+NJ+KS-1)       
      IF (PIPJ .GT. 0) ST=ST + G33*PIPJ *F(PI+PJ+KR-1,QI+QJ+KS+1)       
      IF (PIMJ .GT. 0) ST=ST + G13*PIMJ *F(PI+MJ+KR-1,QI+NJ+KS+1)       
      IF (MIPJ .GT. 0) ST=ST + G13*MIPJ *F(MI+PJ+KR-1,NI+QJ+KS+1)       
      IF (NIQJ .GT. 0) ST=ST + G23*NIQJ *F(MI+PJ+KR+1,NI+QJ+KS-1)       
      IF (QINJ .GT. 0) ST=ST + G23*QINJ *F(PI+MJ+KR+1,QI+NJ+KS-1)       
      IF (NIPJ+MIQJ.GT.0) ST=ST+(G33*NIPJ+G12*MIQJ)*F(MI+PJ+KR,NI+QJ+KS)
      IF (PINJ+QIMJ.GT.0) ST=ST+(G33*PINJ+G12*QIMJ)*F(PI+MJ+KR,QI+NJ+KS)
      IF (NIMJ+MINJ.GT.0) ST=ST+ G13*(NIMJ+MINJ) *F(MI+MJ+KR,NI+NJ+KS)  
      IF (PIQJ+QIPJ.GT.0) ST=ST+ G23*(PIQJ+QIPJ) *F(PI+PJ+KR,QI+QJ+KS)  
      ST1 = ST1 + ST*CC(K)        
      IF (UNIMEM) GO TO 230        
  225 CONTINUE        
  230 GKT(I,J) = ST1        
      GKT(J,I) = ST1        
  235 CONTINUE        
  240 CONTINUE        
C        
      IF (IPASS .EQ. 1) GO TO 260        
  241 RHO = RHOY        
      DO 255 I = 1,12        
      DO 250 J = I,12        
      MIMJ = XU(I) + XU(J)        
      NINJ = YU(I) + YU(J)        
      GKT(I,J) = NSM*F(MIMJ+1,NINJ+1)        
      DO 245 K = 1,3        
      KR = RK(K)        
      KS = SK(K)        
      GKT(I,J) = GKT(I,J) + RHO*CC(K)*F(MIMJ+KR+1,NINJ+KS+1)        
  245 CONTINUE        
      GKT(J,I) = GKT(I,J)        
  250 CONTINUE        
  255 CONTINUE        
C        
  260 DO 265 I = 1,6        
      DO 265 J = 1,6        
      GK11(I,J) = GKTRM(J  ,I  )        
      GK12(I,J) = GKTRM(J+6,I  )        
      GK22(I,J) = GKTRM(J+6,I+6)        
  265 CONTINUE        
      CALL  GMMATS (Q,6,6,0,GK11,6,6,0,QINV)        
      CALL  GMMATS (QINV,6,6,0,Q,6,6,1,GK11)        
      CALL  GMMATS (Q,6,6,0,GK12,6,6,0,QINV)        
      CALL  GMMATS (QINV,6,6,0,Q,6,6,1,GK12)        
      CALL  GMMATS (Q,6,6,0,GK22,6,6,0,QINV)        
      CALL  GMMATS (QINV,6,6,0,Q,6,6,1,GK22)        
      DO 270 I = 1,6        
      DO 270 J = 1,6        
      GKTRM(I  ,J  ) = GK11(I,J)        
      GKTRM(I  ,J+6) = GK12(I,J)        
      GKTRM(I+6,J  ) = GK12(J,I)        
      GKTRM(I+6,J+6) = GK22(I,J)        
  270 CONTINUE        
C        
C     REORDER THE STIFFNESS MATRIX SO THAT THE DISPLACEMENTS OF A GRID  
C     POINT ARE ARRANGED CONSECUTIVELY        
C        
      DO 278 K = 1,6        
      DO 277 I = 1,2        
      K1 = 6*(I-1) + K        
      I1 = 2*(K-1) + I        
      DO 276 J = 1,12        
      KTRM(I1,J) = GKTRM(K1,J)        
  276 CONTINUE        
  277 CONTINUE        
  278 CONTINUE        
      DO 288 K = 1,6        
      DO 287 I = 1,2        
      K1 = 6*(I-1) + K        
      I1 = 2*(K-1) + I        
      DO 286 J = 1,12        
      GKTRM(J,I1) = KTRM(J,K1)        
  286 CONTINUE        
  287 CONTINUE        
  288 CONTINUE        
C        
  290 DO 301 I = 1,324        
      KTRMG(I) = 0.0        
  301 CONTINUE        
      IF (IPASS .LE. 2) GO TO 305        
C        
C     LUMPED MASS MATRIX, IN THREE DOFS, NOT TWO        
C     (SINCE LUMPED MASS IS AN INVARIANT, TRANSFORMATION IS NOT NEEDED) 
C        
      RHO   = RHOY        
      AMASS = (RHO*VOL+NSM*AREA)/6.        
      DO 302 I = 1,324,19        
      KTRMG(I) = AMASS        
  302 CONTINUE        
      IPASS = 2        
      GO TO 400        
C        
C     TRANSFORM THE ELEMENT STIFFNESS MATRIX FROM ELEMENT CO-ORDINATES  
C     TO BASIC CO-ORDINATES        
C        
  305 DO 310 I = 1,6        
      SAVE(I) = NL(I)        
  310 CONTINUE        
      DO 314 I = 1,6        
      SIL(I) = I        
      ISIL = NL(I)        
      DO 313 J = 1,6        
      IF (ISIL .LE. NL(J)) GO TO 312        
      SIL(I) = J        
      ISIL = NL(J)        
  312 CONTINUE        
  313 CONTINUE        
      ISI = SIL(I)        
      NL (ISI) = 1000000        
  314 CONTINUE        
      DO 316 I = 1,6        
      NL(I) = SAVE(I)        
  316 CONTINUE        
      DO 380 I = 1,6        
      SIL1 = SIL(I)        
      DO 375 J = I,6        
      SIL2 = SIL(J)        
      DO 320 II = 1,9        
      BALOTR(II) = 0.0        
  320 CONTINUE        
      DO 324 K = 1,2        
      K1 = (SIL1-1)*2 + K        
      DO 323 L = 1,2        
      L1 = (SIL2-1)*2 + L        
      KSUB(K,L) = GKTRM(K1,L1)        
  323 CONTINUE        
  324 CONTINUE        
      CALL GMMATS (E,3,2,0,KSUB,2,2,0,KSUBT)        
      CALL GMMATS (KSUBT,3,2,0,E,3,2,1,KTR )        
      DO 325 K = 1,3        
      DO 325 L = 1,3        
      K1 = (K-1)*3 + L        
      L1 = (L-1)*3 + K        
      KRT1(L1) = KRT(K1)        
  325 CONTINUE        
C        
C     TRANSFORM THE KTR1 FROM BASIC TO GLOBAL CO-ORDINATES        
C        
      IF (NL(SIL1).EQ.0 .OR. ICS(SIL1).EQ.0) GO TO 340        
      I1 = 4*SIL1 + 10        
      CALL TRANSS (IEST(I1),TRAND)        
      CALL GMMATS (TRAND(1),3,3,1,KTR1,3,3,0,KTR)        
      DO 330 K = 1,9        
      KRT1(K) = KRT(K)        
  330 CONTINUE        
  340 CONTINUE        
      IF (NL(SIL2).EQ.0 .OR. ICS(SIL2).EQ.0) GO TO 365        
      IF (J .EQ. I) GO TO 355        
      J1 = 4*SIL2 + 10        
      CALL TRANSS (IEST(J1),TRAND)        
  355 CONTINUE        
      CALL GMMATS (KTR1,3,3,0,TRAND,3,3,0,KTR)        
      DO 360 K = 1,9        
      KRT1(K) = KRT(K)        
  360 CONTINUE        
  365 CONTINUE        
      DO 370 II = 1,3        
      DO 370 JJ = 1,3        
      I1   = (I-1)*3 + II        
      J1   = (J-1)*3 + JJ        
      I1J1 = (I1-1)*18 + J1        
      J1I1 = (J1-1)*18 + I1        
      KTRMG(J1I1) = KTR1(JJ,II)        
      KTRMG(I1J1) = KTR1(JJ,II)        
  370 CONTINUE        
  375 CONTINUE        
  380 CONTINUE        
C        
C     CALL INSERTION ROUTINE        
C        
  400 CALL EMGOUT (KTRMG(1),KTRMG(1),324,1,DICT,IPASS,IPREC)        
      IF (.NOT.IMASS .OR. IPASS.GE.2) RETURN        
C        
C     GO TO 290 TO COMPUTE LUMPED  MASS MATRIX        
C     GO TO 241 TO COMPUTE CONSIST.MASS MATRIX (THIS PATH DOES NOT WORK)
C        
      IPASS = 3        
      GO TO (905,241,290), IPASS        
C        
C     ERRORS        
C        
  904 CONTINUE        
      NOGO = .TRUE.        
      WRITE  (IOUTPT,2407) UFM,IEST(1)        
 2407 FORMAT (A23,' 2407, MATRIX RELATING GENERALIZED PARAMETERS AND ', 
     1       'GRID POINT DISPLACEMENTS IS SINGULAR.', //26X,        
     2       'CHECK COORDINATES OF ELEMENT  TRIM6 WITH ID',I9,1H.)      
  905 RETURN        
      END        
