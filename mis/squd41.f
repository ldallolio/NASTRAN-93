      SUBROUTINE SQUD41        
C        
C     PHASE 1  STRESS DATA RECOVERY FOR CQUAD4 ELEMENT        
C        
C                EST  LISTING        
C        
C     WORD       TYPE         DESCRIPTION        
C     --------------------------------------------------------------    
C       1          I    ELEMENT ID, EID        
C       2 THRU 5   I    SILS, GRIDS 1 THRU 4        
C       6 THRU 9   R    MEMBRANE THICKNESSES T AT GRIDS 1 THRU 4        
C      10          R    MATERIAL PROPERTY ORIENTATION ANGLE, THETA      
C               OR I    COORD. SYSTEM ID (SEE TM ON CQUAD4 CARD)        
C      11          I    TYPE FLAG FOR WORD 10        
C      12          R    GRID ZOFF  (OFFSET)        
C      13          I    MATERIAL ID FOR MEMBRANE, MID1        
C      14          R    ELEMENT THICKNESS, T (MEMBRANE, UNIFORMED)      
C      15          I    MATERIAL ID FOR BENDING, MID2        
C      16          R    BENDING INERTIA FACTOR, I        
C      17          I    MATERIAL ID FOR TRANSVERSE SHEAR, MID3        
C      18          R    TRANSV. SHEAR CORRECTION FACTOR TS/T        
C      19          R    NON-STRUCTURAL MASS, NSM        
C      20 THRU 21  R    Z1, Z2  (STRESS FIBRE DISTANCES)        
C      22          I    MATERIAL ID FOR MEMBRANE-BENDING COUPLING, MID4 
C      23          R    MATERIAL ANGLE OF ROTATION, THETA        
C               OR I    COORD. SYSTEM ID (SEE MCSID ON PSHELL CARD)     
C      24          I    TYPE FLAG FOR WORD 23        
C      25          I    INTEGRATION ORDER        
C      26          R    STRESS ANGLE OF ROTATION, THETA        
C               OR I    COORD. SYSTEM ID (SEE SCSID ON PSHELL CARD)     
C      27          I    TYPE FLAG FOR WORD 26        
C      28          R    ZOFF1 (OFFSET)  OVERRIDDEN BY EST(12)        
C      29 THRU 44  I/R  CID,X,Y,Z - GRIDS 1 THRU 4        
C      45          R    ELEMENT TEMPERATURE        
C        
C        
      LOGICAL         BADJAC,MEMBRN,BENDNG,SHRFLX,MBCOUP,NORPTH,NOCSUB  
      INTEGER         NEST(45),NPHI(2395),SIL(4),KSIL(4),KCID(8),       
     1                IGPDT(4,4),ELID,SCSID,FLAGS,FLAGM,NECPT(4),       
     2                INDEX(3,3),MID(4),Q4STRS,IPN(4),HUNMEG,ROWFLG,    
     3                TYPE,NAME(2)        
      REAL            BGPDM(3,4),CENT(3),GPTH(4),GPNORM(4,4),BGPDT(4,4),
     1                MATSET,MOMINR,TMPTHK(4),TGRID(4,4),EPNORM(4,4),   
     2                EGPDT(4,4),G(6,6),GI(36),SHP(4),DSHP(8),GGE(9),   
     3                GGU(9),PTINT(2),PTINTP(3),TBS(9),TEU(9),TSE(9),   
     4                TEB(9),TBG(9),TUB(9),TUM(9),TSU(9),U(9),GT(9),    
     5                TBM(9),TEM(9),TMI(9),ECPT(4),GPC(3),XA(4),YB(4),  
     6                ALFA(3),GPTH2(4),RELOUT(300),NUNORX,NUNORY,       
     7                UGPDM(3,4),CENTE(3),BMATRX(192),XYBMAT(96),       
     8                JACOB(3,3),PHI(9),PSITRN(9),TMPSHP(4),DSHPTP(8),  
     9                KHEAT,TMS(9),DQ(24),JACOBU(9),JACBS(9),JACOBE(9), 
     O                ZC(4),VNT(3,4)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /SDR2X5/ EST(100),PHIOUT(2395)        
      COMMON /SDR2X6/ IELOUT(300)        
      COMMON /CONDAS/ PI,TWOPI,RADDEG,DEGRAD        
      COMMON /SYSTEM/ SYSTM(100)        
      COMMON /MATIN / MATID,INFLAG,ELTEMP        
      COMMON /MATOUT/ RMTOUT(25)        
      COMMON /Q4DT  / DETJ,HZTA,PSITRN,NNODE,BADJAC,NODE        
      COMMON /TERMS / MEMBRN,BENDNG,SHRFLX,MBCOUP,NORPTH        
      COMMON /HMTOUT/ KHEAT(7),TYPE        
      COMMON /Q4COMS/ ANGLEI(4),EDGSHR(3,4),EDGEL(4),UNV(3,4),        
     1                UEV(3,4),ROWFLG,IORDER(4)        
      EQUIVALENCE     (IGPDT(1,1),BGPDT(1,1)),(EST(1)  ,NEST(1)   ),    
     1                (BGPDT(1,1),EST(29)   ),(GPTH(1) ,EST(6)    ),    
     2                (ELTH      ,EST(14)   ),(SIL(1)  ,NEST(2)   ),    
     3                (NPHI(1)   ,PHIOUT(1) ),(INT     ,NEST(25)  ),    
     4                (ZOFF      ,NEST(12)  ),(ZOFF1   ,EST(28)   ),    
     5                (IELOUT(1) ,RELOUT(1) ),(MATSET  ,RMTOUT(25)),    
     6                (NECPT(1)  ,ECPT(1)   ),(SYSTM(2),NOUT      ),    
     7                (PHIOUT(65),GPTH2(1)  ),(SYSTM(3),NOGO      ),    
     8                (HTCP      ,KHEAT(4)  ),(ITHERM  ,SYSTM(56) )     
      DATA    EPS1  / 1.0E-16/   ,IPN / 1,4,2,3 /        
      DATA    NAME  / 4HQUAD,4H4      /        
      DATA    HUNMEG/ 100000000       /        
      DATA    CONST / 0.57735026918962/        
C        
C     PHIOUT DATA BLOCK        
C     --------------------------------------------------------------    
C     PHIOUT(1)                 = ELID (ELEMENT ID)        
C     PHIOUT(2-9)               = SIL NUMBERS        
C     PHIOUT(10-17)             = ARRAY IORDER        
C     PHIOUT(18)                = TSUB0 (REFERENCE TEMP.)        
C     PHIOUT(19-20)             = Z1 & Z2 (FIBER DISTANCES)        
C     PHIOUT(21)                = AVGTHK  (AVERAGE THICKNESS)        
C     PHIOUT(22)                = MOMINR  (MOMENT OF INER. FACTOR)      
C     PHIOUT(23-58)             = GBAR (BASIC MAT. PROP. MATRIX)        
C                                 (W/O SHEAR)        
C     PHIOUT(59-61)             = THERMAL EXPANSION COEFFICIENTS        
C                                 FOR MEMBRANE MATERIAL        
C     PHIOUT(62-64)             = THERMAL EXPANSION COEFFICIENTS        
C                                 FOR BENDING MATERIAL        
C     PHIOUT(65-68)             = CORNER NODE THICKNESSES        
C     PHIOUT(69-77)             = 3X3 TRANSFORMATION FROM USER TO       
C                                 MATERIAL COORD. SYSTEM        
C     PHIOUT(78)                = OFFSET OF ELEMENT FROM GP PLANE       
C     PHIOUT(79)                = ID OF THE ORIGINAL PCOMP(I)        
C                                 PROPERTY ENTRY FOR COMPOSITES        
C     PHIOUT(80-(79+9*NNODE))   = 3X3 TRANSFORMATIONS FROM GLOBAL       
C                                 TO ELEMENT COORDINATE SYSTEM        
C                                 FOR EACH EXISTING NODE        
C        
C     THE FOLLOWING IS REPEATED FOR EACH EVALUATION POINT AND THE       
C     CENTER POINT (10 TIMES). THE EVALUATION POINTS ARE AT THE        
C     STANDARD 2X2X2 GAUSSIAN POINTS. THE CHOICE OF THE        
C     FINAL STRESS AND FORCE OUTPUT POINTS IS MADE AT THE SUBCASE       
C     LEVEL (PHASE 2.)        
C        
C              1                  THICKNESS OF THE ELEMENT AT THIS      
C                                 EVALUATION POINT        
C            2 - 10               3X3 TRANSFORMATION FROM TANGENT       
C                                 TO STRESS C.S. AT THIS EVAL. PT.      
C           11 - 19               CORRECTION TO GBAR-MATRIX FOR        
C                                 MEMBRANE-BENDING COUPLING AT THIS     
C                                 EVALUATION POINT        
C           20 - 28               3X3 TRANSFORMATION FROM MATERIAL      
C                                 TO INTEGRATION PT. COORDINATE        
C                                 SYSTEM        
C           29 - 32               2X2 PROPERTY MATRIX FOR OUT-OF-       
C                                 PLANE SHEAR (G3)        
C         32+1 - 32+NNODE         ELEMENT SHAPE FUNCTIONS        
C   32+NNODE+1 - 32+NNODE+8*NDOF  STRAIN RECOVERY MATRIX        
C        
C        
C              IELOUT DATA BLOCK      (TOTAL OF NWORDS = 102)        
C     --------------------------------------------------------------    
C              1                  ELEMENT ID        
C              2                  AVERAGE THICKNESS        
C        
C     THE FOLLOWING IS REPEATED FOR EACH CORNER POINT.        
C        
C         WORD  1                 SIL NUMBER        
C         WORD  2-10              TBS TRANSFORMATION FOR Z1        
C         WORD 11-19              TBS TRANSFORMATION FOR Z2        
C         WORD 20-22              NORMAL VECTOR IN BASIC C.S.        
C         WORD 23-25              GRID COORDS IN BASIC C.S.        
C        
C        
      Q4STRS = 0        
      ELID   = NEST(1)        
      NPHI(1)= ELID        
      NORPTH =.FALSE.        
      NODE   = 4        
      NNODE  = 4        
      NDOF   = NNODE*6        
      ND2    = NDOF*2        
      ND3    = NDOF*3        
      ND4    = NDOF*4        
      ND5    = NDOF*5        
      ND6    = NDOF*6        
      ND7    = NDOF*7        
      ND8    = NDOF*8        
C        
C     FILL IN ARRAY GGU WITH THE COORDINATES OF GRID POINTS 1, 2 AND 4. 
C     THIS ARRAY WILL BE USED LATER TO DEFINE THE USER COORD. SYSTEM    
C     WHILE CALCULATING  TRANSFORMATIONS INVOLVING THIS COORD. SYSTEM.  
C        
      DO 10 I = 1,3        
      II = (I-1)*3        
      IJ = I        
      IF (IJ .EQ. 3) IJ = 4        
      DO 10 J = 1,3        
      JJ = J + 1        
   10 GGU(II+J) = BGPDT(JJ,IJ)        
      CALL BETRNS (TUB,GGU,0,ELID)        
C        
C     STORE INCOMING BGPDT FOR ELEMENT C.S.        
C        
      DO 20 I = 1,3        
      I1 = I + 1        
      DO 20 J = 1,4        
   20 BGPDM(I,J) = BGPDT(I1,J)        
C        
C     TRANSFORM BGPDM FROM BASIC TO USER C.S.        
C        
      DO 30 I = 1,3        
      IP = (I-1)*3        
      DO 30 J = 1,4        
      UGPDM(I,J) = 0.0        
      DO 30 K = 1,3        
      KK = IP + K        
   30 UGPDM(I,J) = UGPDM(I,J) + TUB(KK)*((BGPDM(K,J))-GGU(K))        
C        
C     THE ORIGIN OF THE ELEMENT C.S. IS IN THE MIDDLE OF THE ELEMENT    
C        
      DO 40 J = 1,3        
      CENT(J) = 0.0        
      DO 40 I = 1,4        
   40 CENT(J) = CENT(J) + UGPDM(J,I)/NNODE        
C        
C     STORE THE CORNER NODE DIFF. IN THE USER C.S.        
C        
      X31 = UGPDM(1,3) - UGPDM(1,1)        
      Y31 = UGPDM(2,3) - UGPDM(2,1)        
      X42 = UGPDM(1,4) - UGPDM(1,2)        
      Y42 = UGPDM(2,4) - UGPDM(2,2)        
      AA  = SQRT(X31*X31 + Y31*Y31)        
      BB  = SQRT(X42*X42 + Y42*Y42)        
C        
C     NORMALIZE XIJ'S        
C        
      X31 = X31/AA        
      Y31 = Y31/AA        
      X42 = X42/BB        
      Y42 = Y42/BB        
      EXI = X31 - X42        
      EXJ = Y31 - Y42        
C        
C     STORE GGE ARRAY, THE OFFSET BETWEEN ELEMENT C.S. AND USER C.S.    
C        
      GGE(1) = CENT(1)        
      GGE(2) = CENT(2)        
      GGE(3) = CENT(3)        
C        
      GGE(4) = GGE(1) + EXI        
      GGE(5) = GGE(2) + EXJ        
      GGE(6) = GGE(3)        
C        
      GGE(7) = GGE(1) - EXJ        
      GGE(8) = GGE(2) + EXI        
      GGE(9) = GGE(3)        
C        
C     START FILLING IN IELOUT ARRAY WITH DATA TO BE STORED IN GPSRN     
C        
      IELOUT(1) = ELID        
      DO 50 I = 1,4        
      IELOUT(3+(I-1)*25) = SIL(I)        
      DO 50 J = 1,3        
      RELOUT(25*I+J-1) = BGPDT(J+1,I)        
   50 CONTINUE        
C        
C     THE ARRAY IORDER STORES THE ELEMENT NODE ID IN        
C     INCREASING SIL ORDER.        
C        
C     IORDER(1) = NODE WITH LOWEST  SIL NUMBER        
C     IORDER(4) = NODE WITH HIGHEST SIL NUMBER        
C        
C     ELEMENT NODE NUMBER IS THE INTEGER FROM THE NODE LIST G1,G2,G3,G4.
C     THAT IS, THE 'I' PART OF THE 'GI' AS THEY ARE LISTED ON THE       
C     CONNECTIVITY BULK DATA CARD DESCRIPTION.        
C        
C        
      DO 60 I = 1,4        
      IORDER(I) = 0        
   60 KSIL(I) = SIL(I)        
C        
      DO 80 I = 1,4        
      ITEMP = 1        
      ISIL  = KSIL(1)        
      DO 70 J = 2,4        
      IF (ISIL .LE. KSIL(J)) GO TO 70        
      ITEMP = J        
      ISIL  = KSIL(J)        
   70 CONTINUE        
      IORDER(I)   = ITEMP        
      KSIL(ITEMP) = 99999999        
   80 CONTINUE        
C        
C     ADJUST EST DATA        
C        
C     USE THE POINTERS IN IORDER TO COMPLETELY REORDER THE        
C     GEOMETRY DATA INTO INCREASING SIL ORDER.        
C     DON'T WORRY!! IORDER ALSO KEEPS TRACK OF WHICH SHAPE        
C     FUNCTIONS GO WITH WHICH GEOMETRIC PARAMETERS!        
C        
      DO 100 I = 1,4        
      KSIL(I)   = SIL(I)        
      TMPTHK(I) = GPTH(I)        
      KCID(I)   = IGPDT(1,I)        
      DO 90 J = 2,4        
      TGRID(J,I) = BGPDT(J,I)        
   90 CONTINUE        
  100 CONTINUE        
      DO 120 I = 1,4        
      IPOINT  = IORDER(I)        
      GPTH(I) = TMPTHK(IPOINT)        
      IGPDT(1,I) = KCID(IPOINT)        
      SIL(I)     = KSIL(IPOINT)        
      NPHI(I+1 ) = KSIL(IPOINT)        
      NPHI(I+5 ) = 0        
      NPHI(I+9 ) = IPOINT        
      NPHI(I+13) = 0        
      DO 110 J = 2,4        
      BGPDT(J,I) = TGRID(J,IPOINT)        
  110 CONTINUE        
  120 CONTINUE        
C        
      NPHI(19) = NEST(20)        
      NPHI(20) = NEST(21)        
      PHIOUT(18) = 0.0        
      OFFSET   = ZOFF        
      IF (ZOFF .EQ. 0.0) OFFSET = ZOFF1        
      PHIOUT(78) = OFFSET        
C        
C     COMPUTE NODE NORMALS        
C        
      CALL Q4NRMS (BGPDT,GPNORM,IORDER,IFLAG)        
      IF (IFLAG .EQ. 0) GO TO 130        
      WRITE (NOUT,1710) UFM,ELID        
      GO TO 1430        
  130 CONTINUE        
C        
C     PUT NORMALS IN IELOUT        
C        
      DO 140 I = 1,NNODE        
      IO  = IORDER(I)        
      IOP = (IO-1)*25 + 21        
      RELOUT(IOP+1) = GPNORM(2,I)        
      RELOUT(IOP+2) = GPNORM(3,I)        
      RELOUT(IOP+3) = GPNORM(4,I)        
  140 CONTINUE        
C        
C     COMPUTE NODE NORMALS        
C        
      AVGTHK = 0.0        
      DO 160 I = 1,NNODE        
      IO = IORDER(I)        
      IF (GPTH(I) .EQ. 0.0) GPTH(I) = ELTH        
      IF (GPTH(I) .GT. 0.0) GO TO 150        
      WRITE (NOUT,1700) UFM,ELID,SIL(I)        
      GO TO 1430        
  150 AVGTHK = AVGTHK + GPTH(I)/NNODE        
      GPTH2(IO) = GPTH(I)        
  160 CONTINUE        
C        
      MOMINR = 0.0        
      TSFACT = 5.0/6.0        
      NOCSUB = .FALSE.        
      IF (NEST(15) .NE.  0) MOMINR = EST(16)        
      IF (NEST(17) .NE.  0) TS = EST(18)        
      IF ( EST(18) .EQ. .0) TS = 5.0/6.0        
      PHIOUT(21) = AVGTHK        
      PHIOUT(22) = MOMINR        
C        
C     SET LOGICAL NOCSUB IF EITHER MOMINR OR TS ARE NOT DEFAULT        
C     VALUES. THIS WILL BE USED TO OVERRIDE ALL CSUBB COMPUTATIONS.     
C     I.E. DEFAULT VALUES OF UNITY ARE USED.        
C        
      EPSI = ABS(MOMINR - 1.0)        
      EPST = ABS(TS  - TSFACT)        
      EPS  = .05        
C     NOCSUB = EPSI.GT.EPS .OR. EPST.GT.EPS        
C        
C     PUT THE AVERAGE THICKNESS IN RELOUT        
C        
      RELOUT(2) = AVGTHK        
C        
C     THE COORDINATES OF THE ELEMENT GRID POINTS HAVE TO BE        
C     TRANSFORMED FROM THE BASIC C.S. TO THE ELEMENT C.S.        
C        
      CALL BETRNS (TEU,GGE,0,ELID)        
      CALL GMMATS (TEU,3,3,0, TUB,3,3,0, TEB)        
      CALL GMMATS (TUB,3,3,1, CENT,3,1,0, CENTE)        
C        
      DO 170 I = 1,3        
      II = I + 1        
      IP = (I-1)*3        
      DO 170 J = 1,NNODE        
      EPNORM(II,J) = 0.0        
      EGPDT (II,J) = 0.0        
      DO 170 K = 1,3        
      KK = IP + K        
      K1 = K + 1        
      CC = BGPDT(K1,J) - GGU(K) - CENTE(K)        
      EPNORM(II,J) = EPNORM(II,J) + TEB(KK)*GPNORM(K1,J)        
  170 EGPDT (II,J) = EGPDT (II,J) + TEB(KK)*CC        
C        
C     INITIALIZE MATERIAL VARIABLES        
C        
C     SET INFLAG = 12 SO THAT SUBROUTINE MAT WILL SEARCH FOR-        
C     ISOTROPIC MATERIAL PROPERTIES AMONG THE MAT1 CARDS,        
C     ORTHOTROPIC MATERIAL PROPERTIES AMONG THE MAT8 CARDS, AND        
C     ANISOTROPIC MATERIAL PROPERTIES AMONG THE MAT2 CARDS.        
C        
      INFLAG = 12        
      RHO    = 0.0        
      ELTEMP =  EST(45)        
      MID(1) = NEST(13)        
      MID(2) = NEST(15)        
      MID(3) = NEST(17)        
      MID(4) = NEST(22)        
      MEMBRN = MID(1).GT.0        
      BENDNG = MID(2).GT.0 .AND. MOMINR.GT.0.0        
      SHRFLX = MID(3).GT.0        
      MBCOUP = MID(4).GT.0        
C        
C     CHECK FOR COMPOSITE MATERIAL        
C        
      NPHI(79) = 0        
      DO 180 IMG = 1,4        
      IF (MID(IMG) .GT. HUNMEG) GO TO 190        
  180 CONTINUE        
      GO TO 200        
  190 NPHI(79) = MID(IMG) - IMG*HUNMEG        
  200 CONTINUE        
C        
C     DETERMINE FACTORS TO BE USED IN CSUBB CALCULATIONS        
C        
      IF (.NOT.BENDNG) GO TO 250        
      DO 220 I = 1,4        
      DO 210 J = 1,NNODE        
      JO = IORDER(J)        
      IF (I .NE. JO) GO TO 210        
      XA(I) = EGPDT(2,J)        
      YB(I) = EGPDT(3,J)        
      ZC(I) = EGPDT(4,J)        
      VNT(1,I) = EPNORM(2,J)        
      VNT(2,I) = EPNORM(3,J)        
      VNT(3,I) = EPNORM(4,J)        
  210 CONTINUE        
  220 CONTINUE        
C        
      A = 0.5*(XA(2) + XA(3) - XA(1) - XA(4))        
      B = 0.5*(YB(4) + YB(3) - YB(1) - YB(2))        
      IF (A .GT. B) ASPECT = B/A        
      IF (A .LE. B) ASPECT = A/B        
C        
C     IRREGULAR 4-NODE CODE-  GEOMETRIC VARIABLES        
C        
C     CALCULATE AND NORMALIZE- UNIT EDGE VECTORS,UNIT NORMAL VECTORS    
C        
      DO 230 I = 1,4        
      J = I + 1        
      IF (J .EQ. 5) J = 1        
      UEV(1,I) = XA(J) - XA(I)        
      UEV(2,I) = YB(J) - YB(I)        
      UEV(3,I) = ZC(J) - ZC(I)        
      UNV(1,I) = (VNT(1,J)+VNT(1,I))*0.50        
      UNV(2,I) = (VNT(2,J)+VNT(2,I))*0.50        
      UNV(3,I) = (VNT(3,J)+VNT(3,I))*0.50        
      CC       = UEV(1,I)**2 + UEV(2,I)**2 + UEV(3,I)**2        
      IF (CC .GE. 1.0E-8) CC = SQRT(CC)        
      EDGEL(I) = CC        
      UEV(1,I) = UEV(1,I)/CC        
      UEV(2,I) = UEV(2,I)/CC        
      UEV(3,I) = UEV(3,I)/CC        
      CC       = SQRT(UNV(1,I)**2 + UNV(2,I)**2 + UNV(3,I)**2)        
      UNV(1,I) = UNV(1,I)/CC        
      UNV(2,I) = UNV(2,I)/CC        
      UNV(3,I) = UNV(3,I)/CC        
  230 CONTINUE        
C        
C     CALCULATE INTERNAL NODAL ANGLES        
C        
      DO 240 I = 1,4        
      J = I - 1        
      IF (J .EQ. 0) J = 4        
      ANGLEI(I) =-UEV(1,I)*UEV(1,J)-UEV(2,I)*UEV(2,J)-UEV(3,I)*UEV(3,J) 
      IF (ABS(ANGLEI(I)) .LT. 1.0E-8) ANGLEI(I) = 0.0        
  240 CONTINUE        
  250 CONTINUE        
C        
C     SET THE INTEGRATION POINTS        
C        
      PTINT(1) = -CONST        
      PTINT(2) =  CONST        
C        
      IF (ITHERM .NE. 0) GO TO 1500        
C        
C     IN PLANE SHEAR REDUCTION        
C        
      XI  = 0.0        
      ETA = 0.0        
      KPT = 1        
C        
      CALL Q4SHPS (XI,ETA,SHP,DSHP)        
C        
C     SORT THE SHAPE FUNCTIONS AND THEIR DERIVATIVES INTO SIL ORDER.    
C        
      DO 260 I = 1,4        
      TMPSHP(I  ) = SHP (I  )        
      DSHPTP(I  ) = DSHP(I  )        
  260 DSHPTP(I+4) = DSHP(I+4)        
      DO 270 I = 1,4        
      KK = IORDER(I)        
      SHP( I  ) = TMPSHP(KK  )        
      DSHP(I  ) = DSHPTP(KK  )        
  270 DSHP(I+4) = DSHPTP(KK+4)        
C        
      DO 280 IZTA = 1,2        
      ZETA = PTINT(IZTA)        
C        
C     COMPUTE THE JACOBIAN AT THIS GAUSS POINT,        
C     ITS INVERSE AND ITS DETERMINANT.        
C        
      HZTA = ZETA/2.0        
C        
      CALL JACOBS (ELID,SHP,DSHP,GPTH,EGPDT,EPNORM,JACOB)        
      IF (BADJAC) GO TO 1430        
C        
C     COMPUTE PSI TRANSPOSE X JACOBIAN INVERSE.        
C     HERE IS THE PLACE WHERE THE INVERSE JACOBIAN IS FLAGED TO BE      
C     TRANSPOSED BECAUSE OF OPPOSITE MATRIX LOADING CONVENTION BETWEEN  
C     INVER AND GMMAT.        
C        
      CALL GMMATS (PSITRN,3,3,0, JACOB,3,3,1, PHI)        
C        
C     CALL Q4BMGS TO GET B MATRIX        
C     SET THE ROW FLAG TO 2. IT WILL SAVE THE 3RD ROW OF B-MATRIX AT    
C     THE TWO INTEGRATION POINTS.        
C        
      ROWFLG = 2        
      CALL Q4BMGS (DSHP,GPTH,EGPDT,EPNORM,PHI,XYBMAT(KPT))        
      KPT = KPT + ND2        
  280 CONTINUE        
C        
C     FETCH MATERIAL PROPERTIES        
C        
C     SET THE ARRAY OF LENGTH 4 TO BE USED IN CALLING TRANSS.        
C     NOTE THAT THE FIRST WORD IS THE COORDINATE SYSTEM ID WHICH        
C     WILL BE SET IN POSITION LATER.        
C        
  290 DO 300 IEC = 2,4        
  300 ECPT(IEC) = 0.0        
C        
C        
C     EACH MATERIAL PROPERTY MATRIX G HAS TO BE TRANSFORMED FROM        
C     THE MATERIAL COORDINATE SYSTEM TO THE ELEMENT COORDINATE        
C     SYSTEM. THESE STEPS ARE TO BE FOLLOWED-        
C        
C     1- IF MCSID HAS BEEN SPECIFIED, SUBROUTINE TRANSS IS CALLED       
C        TO CALCULATE TBM-MATRIX (MATERIAL TO BASIC TRANSFORMATION).    
C        THIS WILL BE FOLLOWED BY A CALL TO SUBROUTINE BETRNS        
C        TO CALCULATE TEB-MATRIX (BASIC TO ELEMENT TRANSFORMATION).     
C        TBM-MATRIX IS THEN PREMULTIPLIED BY TEB-MATRIX TO OBTAIN       
C        TEM-MATRIX. THEN STEP 3 WILL BE TAKEN.        
C        
C     2- IF THETAM HAS BEEN SPECIFIED, SUBROUTINE ANGTRS IS CALLED      
C        TO CALCULATE TEM-MATRIX (MATERIAL TO ELEMENT TRANSFORMATION).  
C        
C                          T        
C     3-           G   =  U   G   U        
C                   E          M        
C        
C        
      FLAGM = NEST(11)        
      IF (FLAGM .EQ. 0) GO TO 360        
      MCSID = NEST(10)        
C        
C     CALCULATE TUM-MATRIX USING MCSID        
C        
  310 IF (MCSID .GT. 0) GO TO 330        
      DO 320 I = 1,9        
  320 TEM(I) = TEB(I)        
      GO TO 340        
  330 NECPT(1) = MCSID        
      CALL TRANSS (ECPT,TBM)        
C        
C     MULTIPLY TEB AND TBM MATRICES        
C        
      CALL GMMATS (TEB,3,3,0, TBM,3,3,0, TEM)        
C        
C     CALCULATE THETAM FROM THE PROJECTION OF THE X-AXIS OF THE        
C     MATERIAL C.S. ON TO THE XY PLANE OF THE ELEMENT C.S.        
C        
  340 CONTINUE        
      XM = TEM(1)        
      YM = TEM(4)        
      IF (ABS(XM).GT.EPS1 .OR. ABS(YM).GT.EPS1) GO TO 350        
      NEST(2) = MCSID        
      J = 231        
      GO TO 1440        
  350 THETAM = ATAN2(YM,XM)        
      GO TO 370        
C        
C     CALCULATE TEM-MATRIX USING THETAM        
C        
  360 THETAM = EST(10)*DEGRAD        
      IF (THETAM .EQ. 0.0) GO TO 380        
  370 CALL ANGTRS (THETAM,1,TUM)        
      CALL GMMATS (TEU,3,3,0, TUM,3,3,0, TEM)        
      GO TO 400        
C        
C     DEFAULT IS CHOSEN, LOOK FOR VALUES OF MCSID AND/OR THETAM        
C     ON THE PSHELL CARD.        
C        
  380 FLAGM = NEST(24)        
      IF (FLAGM .EQ. 0) GO TO 390        
      MCSID = NEST(23)        
      GO TO 310        
C        
  390 THETAM = EST(23)*DEGRAD        
      GO TO 370        
C        
  400 CONTINUE        
C        
C     STORE TUM IN PHIOUT        
C        
      DO 410 IEM = 1,9        
  410 PHIOUT(68+IEM) = TUM(IEM)        
C        
      IF (ITHERM .NE. 0) GO TO 1600        
C        
C     BEGIN THE LOOP TO FETCH PROPERTIES FOR EACH MATERIAL ID        
C        
      DO 420 LL = 1,36        
  420 GI(LL) = 0.0        
C        
      M    = 0        
      IT0  = 0        
      IGOBK= 0        
  430 M    = M + 1        
      IF (M .GT. 4) GO TO 680        
      IF (M.EQ.4 .AND. IGOBK.EQ.1) GO TO 690        
      MATID = MID(M)        
      IF (MATID.EQ.0 .AND. M.NE.3) GO TO 430        
      IF (MATID.EQ.0 .AND. M.EQ.3 .AND. .NOT.BENDNG) GO TO 430        
      IF (MATID.EQ.0 .AND. M.EQ.3 .AND. BENDNG) MATID = MID(2)        
C        
      IF (M-1) 460,450,440        
  440 IF (MATID.EQ.MID(M-1) .AND. IGOBK.EQ.0) GO TO 460        
  450 CALL MAT (ELID)        
  460 CONTINUE        
C        
      IF (IT0 .GT. 0) GO TO 470        
      TSUB0 = RMTOUT(11)        
      IF (MATSET .EQ. 8.0) TSUB0 = RMTOUT(10)        
      PHIOUT(18) = TSUB0        
      IT0 = 1        
  470 CONTINUE        
C        
      COEFF = 1.0        
C     IF (M .EQ. 2) COEFF = MOMINR        
      IF (M .EQ. 3) COEFF = TS        
      LPOINT = (M-1)*9 + 1        
C        
      CALL Q4GMGS (M,COEFF,GI(LPOINT))        
C        
      IF (M .GT. 0) GO TO 490        
      IF (.NOT.SHRFLX .AND. BENDNG) GO TO 480        
      NEST(2) = MATID        
      J = 231        
      GO TO 1440        
C        
  480 M = -M        
  490 CONTINUE        
      MTYPE = IFIX(MATSET+.05) - 2        
      IF (NOCSUB) GO TO 580        
      GO TO (580,500,540,580), M        
C        
  500 IF (MTYPE) 510,520,530        
  510 ENORX = RMTOUT(16)        
      ENORY = RMTOUT(16)        
      GO TO 580        
  520 ENORX = RMTOUT(1)        
      ENORY = RMTOUT(4)        
      GO TO 580        
  530 ENORX = RMTOUT(1)        
      ENORY = RMTOUT(3)        
      GO TO 580        
C        
  540 IF (MTYPE) 550,560,570        
  550 GNORX = RMTOUT(6)        
      GNORY = RMTOUT(6)        
      GO TO 580        
  560 GNORX = RMTOUT(1)        
      GNORY = RMTOUT(4)        
      GO TO 580        
  570 GNORX = RMTOUT(6)        
      GNORY = RMTOUT(5)        
      IF (GNORX .EQ. 0.0) GNORX = RMTOUT(4)        
      IF (GNORY .EQ. 0.0) GNORY = RMTOUT(4)        
  580 CONTINUE        
C        
      IF (MATSET .EQ. 1.0) GO TO 610        
      IF (M      .EQ.   3) GO TO 590        
      U(1) = TEM(1)*TEM(1)        
      U(2) = TEM(2)*TEM(2)        
      U(3) = TEM(1)*TEM(2)        
      U(4) = TEM(4)*TEM(4)        
      U(5) = TEM(5)*TEM(5)        
      U(6) = TEM(4)*TEM(5)        
      U(7) = TEM(1)*TEM(4)*2.0        
      U(8) = TEM(2)*TEM(5)*2.0        
      U(9) = TEM(1)*TEM(5) + TEM(2)*TEM(4)        
      L    = 3        
      GO TO 600        
C        
  590 U(1) = TEM(5)*TEM(9) + TEM(6)*TEM(8)        
      U(2) = TEM(4)*TEM(9) + TEM(6)*TEM(7)        
      U(3) = TEM(2)*TEM(9) + TEM(3)*TEM(8)        
      U(4) = TEM(1)*TEM(9) + TEM(3)*TEM(7)        
      L    = 2        
C        
  600 CALL GMMATS (U(1),L,L,1, GI(LPOINT),L,L,0, GT(1))        
      CALL GMMATS (GT(1),L,L,0, U(1),L,L,0, GI(LPOINT))        
C        
C     TRANSFORM THERMAL EXPANSION COEFF'S AND STORE THEM IN PHIOUT      
C        
  610 CONTINUE        
      IF (M      .GT. 2 ) GO TO 430        
      IF (MATSET .EQ. 2.) GO TO 620        
      IF (MATSET .EQ. 8.) GO TO 640        
C        
C     MAT1        
C        
      ALFA(1) = RMTOUT(8)        
      ALFA(2) = RMTOUT(8)        
      ALFA(3) = 0.0        
      GO TO 650        
C        
C     MAT2        
C        
  620 DO 630 IMAT = 1,3        
  630 ALFA(IMAT) = RMTOUT(7+IMAT)        
      GO TO 650        
C        
C     MAT8        
C        
  640 ALFA(1) = RMTOUT(8)        
      ALFA(2) = RMTOUT(9)        
      ALFA(3) = 0.0        
C        
  650 MPOINT = (M-1)*3 + 59        
      IF (MATSET .EQ. 1.0) GO TO 660        
      CALL INVERS (3,U,3,BDUM,0,DETU,ISNGU,INDEX)        
      CALL GMMATS (U,3,3,0, ALFA,3,1,0, PHIOUT(MPOINT))        
      GO TO 430        
  660 DO 670 IALF = 1,3        
      MP = MPOINT - 1 + IALF        
  670 PHIOUT(MP) = ALFA(IALF)        
      GO TO 430        
  680 CONTINUE        
      IF (MID(3) .LT. HUNMEG) GO TO 690        
      IF (GI(19).NE.0. .OR. GI(20).NE.0. .OR. GI(21).NE.0. .OR.        
     1    GI(22).NE.0.) GO TO 690        
      IGOBK = 1        
      M = 2        
      MID(3) = MID(2)        
      GO TO 430        
  690 CONTINUE        
C        
      NOCSUB = ENORX.EQ.0.0 .OR. ENORY.EQ.0.0 .OR.        
     1         GNORX.EQ.0.0 .OR. GNORY.EQ.0.0 .OR.        
     2        MOMINR.EQ.0.0        
C        
C        
C     FILL IN THE BASIC 6X6 MATERIAL PROPERTY MATRIX G        
C        
      DO 700 IG = 1,6        
      DO 700 JG = 1,6        
  700 G(IG,JG) = 0.0        
C        
      IF (.NOT.MEMBRN) GO TO 720        
      DO 710 IG = 1,3        
      IG1 = (IG-1)*3        
      DO 710 JG = 1,3        
      JG1 = JG + IG1        
      G(IG,JG) = GI(JG1)        
  710 CONTINUE        
C        
  720 IF (.NOT.BENDNG) GO TO 750        
      DO 730 IG = 4,6        
      IG2 = (IG-2)*3        
      DO 730 JG = 4,6        
      JG2 = JG + IG2        
      G(IG,JG) = GI(JG2)        
  730 CONTINUE        
C        
      IF (.NOT.MEMBRN) GO TO 750        
      DO 740 IG = 1,3        
      KG  = IG + 3        
      IG1 = (IG-1)*3        
      DO 740 JG = 1,3        
      LG  = JG + 3        
      JG1 = JG + IG1        
      G(IG,LG) = GI(JG1)        
      G(KG,JG) = GI(JG1)        
  740 CONTINUE        
C        
C     STORE 6X6 GBAR-MATRIX IN PHIOUT        
C        
  750 IG1 = 22        
      DO 760 IG = 1,6        
      DO 760 JG = 1,6        
      IG1 = IG1 + 1        
  760 PHIOUT(IG1) = G(IG,JG)        
C        
C        
C     STRESS TRANSFORMATIONS        
C     ----------------------        
C        
C     THE NECESSARY TRANSFORMATIONS ARE PERFORMED IN THE FOLLOWING      
C     MANNER-        
C        
C     1- ALL THE TRANSFORMATIONS ARE CALCULATED IN PHASE I AND THEN     
C        TRANSFERED THRU DATA BLOCK 'PHIOUT' TO PHASE II WHERE THE      
C        ACTUAL MULTIPLICATIONS ARE PERFORMED.        
C        
C     2- THE STRAIN RECOVERY MATRIX B        
C        IS EVALUATED IN THE ELEMENT COORDINATE SYSTEM IN PHASE I       
C        AND TRANSFERED TO PHASE II. THE DISPLACEMENTS, HOWEVER,        
C        ENTER PHASE II IN GLOBAL COORDINATES. THEREFORE,        
C        2A) 3X3 TRANSFORMATIONS FROM GLOBAL TO ELEMENT COORDINATE      
C            SYSTEM (TEG) FOR EACH GRID POINT ARE CALCULATED AND        
C            STORED IN  PHIOUT (80 - (79+9*NNODE)).        
C            USING THESE TRANSFORMATIONS THE DISPLACEMENTS AT        
C            EACH GRID POINT WILL BE EVALUATED IN THE ELEMENT        
C            COORDINATE SYSTEM AFTER ENTERING PHASE II.        
C        
C        2B) A 3X3 TRANSFORMATION FROM THE TANGENT TO THE USER-        
C            DEFINED STRESS COORDINATE SYSTEM (TSI) IS CALCULATED       
C            FOR EACH INTEGRATION POINT AND STORED ALONG WITH OTHER     
C            DATA FOR THAT INTEGRATION POINT AT POSITIONS 2-10 OF       
C            THE REPEATED DATA FOR EACH EVALUATION POINT.        
C            IT WILL BE USED TO TRANSFORM THE STRESS OUTPUT TO        
C            ANY DESIRED COORDINATE SYSTEM.        
C            NOTE THAT THESE CALCULATIONS WILL BE PERFORMED INSIDE      
C            THE DOUBLE LOOP.        
C        
C     CALCULATIONS FOR TEG-MATRIX        
C        
C     CALCULATE  TBG-MATRIX (GLOBAL TO BASIC), THEN        
C     MULTIPLY  TEB AND TBG MATRICES  TO GET  TEG-MATRIX        
C     FOR THIS GRID POINT AND STORE IT IN PHIOUT.        
C        
      DO 820 I = 1,NNODE        
      IP = 80 + (I-1)*9        
      IF (IGPDT(1,I) .LE. 0) GO TO 800        
      CALL TRANSS (IGPDT(1,I),TBG)        
      CALL GMMATS (TEB,3,3,0, TBG,3,3,0, PHIOUT(IP))        
      GO TO 820        
C        
  800 DO 810 J = 1,9        
  810 PHIOUT(IP+J-1) = TEB(J)        
  820 CONTINUE        
C        
C     INITIALIZE THE ARRAYS USED IN THE DOUBLE LOOP CALCULATION.        
C     EVALUATION OF STRESSES IS DONE AT 2X2 POINTS AND AT THE        
C     CENTER OF THE ELEMENT, AT THE MID-SURFACE.        
C        
      IF (BENDNG) GO TO 840        
      J = ND3 + 1        
      DO 830 IBMX = J,ND8        
  830 BMATRX(IBMX) = 0.0        
  840 CONTINUE        
C        
      ICOUNT = -(8*NDOF+NNODE+32) + 79 + 9*NNODE        
C        
      PTINTP(1) =-CONST        
      PTINTP(2) = CONST        
      PTINTP(3) = 0.0        
C        
C        
C     HERE BEGINS THE TRIPLE LOOP ON STATEMENTS 835 AND 840        
C     -----------------------------------------------------        
C        
      DO 1420 IXSI = 1,3        
      XI = PTINTP(IXSI)        
C        
      DO 1420 IETA = 1,3        
      ETA = PTINTP(IETA)        
      IF (IXSI.EQ.3 .AND. IETA.NE.3) GO TO 1420        
      IF (IXSI.NE.3 .AND. IETA.EQ.3) GO TO 1420        
C        
      CALL Q4SHPS (XI,ETA,SHP,DSHP)        
C        
C     SORT THE SHAPE FUNCTIONS AND THEIR DERIVATIVES INTO SIL ORDER.    
C        
      DO 900 I = 1,4        
      TMPSHP(I  ) = SHP (I  )        
      DSHPTP(I  ) = DSHP(I  )        
  900 DSHPTP(I+4) = DSHP(I+4)        
      DO 910 I = 1,4        
      KK = IORDER(I)        
      SHP (I  ) = TMPSHP(KK  )        
      DSHP(I  ) = DSHPTP(KK  )        
  910 DSHP(I+4) = DSHPTP(KK+4)        
C        
      TH = 0.0        
      DO 920 ITH = 1,NNODE        
  920 TH = TH + SHP(ITH)*GPTH(ITH)        
      REALI = MOMINR*TH*TH*TH/12.0        
      TSI = TS*TH        
C        
      IF (NOCSUB) GO TO 970        
      IF (.NOT.BENDNG) GO TO 970        
C     NUNORX = MOMINR*ENORX/(2.0*GNORX) - 1.0        
C     NUNORY = MOMINR*ENORY/(2.0*GNORY) - 1.0        
      EIX = MOMINR*ENORX        
      EIY = MOMINR*ENORY        
      TGX = 2.0*GNORX        
      TGY = 2.0*GNORY        
      NUNORX = EIX/TGX - 1.0        
      IF (EIX .GT. TGX) NUNORX = 1.0 - TGX/EIX        
      NUNORY = EIY/TGY - 1.0        
      IF (EIY .GT. TGY) NUNORY = 1.0 - TGY/EIY        
      IF (NUNORX .GT. 0.999999) NUNORX = 0.999999        
      IF (NUNORY .GT. 0.999999) NUNORY = 0.999999        
C     IF (NUNORX .GT. .49) NUNORX = 0.49        
C     IF (NUNORY .GT. .49) NUNORY = 0.49        
      CC = ASPECT        
      AX = A        
      IF (ETA .LT. 0.0) AX = A + CONST*(XA(2)-XA(1)-A)        
      IF (ETA .GT. 0.0) AX = A + CONST*(XA(3)-XA(4)-A)        
      PSIINX = 32.0*REALI/((1.0-NUNORX)*TSI*AX*AX)        
      BY = B        
      IF (XI .LT. 0.0) BY = B + CONST*(YB(4)-YB(1)-B)        
      IF (XI .GT. 0.0) BY = B + CONST*(YB(3)-YB(2)-B)        
      PSIINY = 32.0*REALI/((1.0-NUNORY)*TSI*BY*BY)        
      IF (.NOT.SHRFLX) GO TO 930        
      TSMFX = PSIINX        
      TSMFY = PSIINY        
      IF (TSMFX .GT. 1.0) TSMFX = 1.0        
      IF (TSMFY .GT. 1.0) TSMFY = 1.0        
      GO TO 980        
  930 IF (PSIINX .GE. 1.0) GO TO 940        
      TSMFX = PSIINX/(1.0-PSIINX)        
      IF (TSMFX .LE. 1.0) GO TO 950        
  940 TSMFX = 1.0        
  950 IF (PSIINY .GE. 1.0) GO TO 960        
      TSMFY = PSIINY/(1.0-PSIINY)        
      IF (TSMFY .LE. 1.0) GO TO 980        
  960 TSMFY = 1.0        
      GO TO 980        
C        
  970 TSMFX = 1.0        
      TSMFY = 1.0        
  980 CONTINUE        
C        
C     IRREGULAR 4-NODE CODE-  CALCULATION OF NODAL EDGE SHEARS        
C                             AT THIS INTEGRATION POINT        
C        
C        
      DO 1050 IJ = 1,4        
      II = IJ - 1        
      IF (II .EQ. 0) II = 4        
      IK = IJ + 1        
      IF (IK .EQ. 5) IK = 1        
C        
      DO 1000 IR = 1,4        
      IF (IJ .NE. IORDER(IR)) GO TO 1000        
      IOJ = IR        
      GO TO 1010        
 1000 CONTINUE        
 1010 DO 1020 IR = 1,4        
      IF (IK .NE. IORDER(IR)) GO TO 1020        
      IOK = IR        
      GO TO 1030        
 1020 CONTINUE        
 1030 AA = SHP(IOJ)        
      BB = SHP(IOK)        
C        
      DO 1040 IS = 1,3        
      EDGSHR(IS,IJ) = (UEV(IS,IJ)+ANGLEI(IJ)*UEV(IS,II))*AA/        
     1                (1.0-ANGLEI(IJ)*ANGLEI(IJ))        
     2              + (UEV(IS,IJ)+ANGLEI(IK)*UEV(IS,IK))*BB/        
     3                (1.0-ANGLEI(IK)*ANGLEI(IK))        
 1040 CONTINUE        
 1050 CONTINUE        
C        
      DO 1410 IZTA = 1,2        
      ZETA = PTINT(IZTA)        
      HZTA = ZETA/2.0        
      IBOT = (IZTA-1)*ND2        
C        
C     SET THE PHIOUT POINTER        
C        
      ICOUNT = ICOUNT + 32 + NNODE + 8*NDOF        
C        
      PHIOUT(ICOUNT+1) = TH        
C        
C     STORE SHAPE FUNCTION VALUES IN PHIOUT        
C        
      DO 1060 I = 1,NNODE        
      PHIOUT(ICOUNT+32+I) = SHP(I)        
 1060 CONTINUE        
C        
C     STORE THE CORRECTION TO GBAR-MATRIX IN PHIOUT        
C        
      IG1 = ICOUNT + 10        
      IG4 = 28        
      DO 1070 IG = 1,9        
      IG1 = IG1 + 1        
      PHIOUT(IG1) = -GI(IG4)*ZETA*6.0        
 1070 IG4 = IG4 + 1        
C        
C     STORE G3-MATRIX IN PHIOUT        
C        
      IPH = ICOUNT + 28        
      PHIOUT(IPH+1) = TSMFY*GI(19)        
      PHIOUT(IPH+2) = SQRT(TSMFX*TSMFY)*GI(20)        
      PHIOUT(IPH+3) = SQRT(TSMFX*TSMFY)*GI(21)        
      PHIOUT(IPH+4) = TSMFX*GI(22)        
C        
C     COMPUTE THE JACOBIAN AT THIS GAUSS POINT,        
C     ITS INVERSE AND ITS DETERMINANT.        
C        
      CALL JACOBS (ELID,SHP,DSHP,GPTH,EGPDT,EPNORM,JACOB)        
      IF (BADJAC) GO TO 1430        
C        
C     COMPUTE PSI TRANSPOSE X JACOBIAN INVERSE.        
C     HERE IS THE PLACE WHERE THE INVERSE JACOBIAN IS FLAGED TO BE      
C     TRANSPOSED BECAUSE OF OPPOSITE MATRIX LOADING CONVENTION BETWEEN  
C     INVER AND GMMAT.        
C        
      CALL GMMATS (PSITRN,3,3,0, JACOB,3,3,1, PHI)        
C        
      CALL GMMATS (TEM,3,3,1, PSITRN,3,3,1, TMI)        
C        
C     STORE TMI-MATRIX IN PHIOUT        
C        
      IPH = ICOUNT + 20        
      DO 1080 I = 1,9        
      PHIOUT(IPH) = TMI(I)        
 1080 IPH = IPH + 1        
C        
C     ARRAY ECPT(4) WHICH IS USED IN TRANSS CONSISTS OF THE C.S. ID     
C     AND THE COORDINATES (IN BASIC C.S.) OF THE POINT FROM (OR TO)     
C     WHICH THE TRANSFORMATION IS BEING PERFORMED. THE COORDINATES      
C     ARE NOT USED IF THE DESIGNATED COORDINATE SYSTEM IS RECTANGULAR.  
C        
      DO 1100 I = 1,3        
      GPC(I) = 0.0        
      II = I + 1        
      DO 1090 J = 1,NNODE        
 1090 GPC(I) = GPC(I) + SHP(J)*(BGPDT(II,J) + HZTA*GPTH(J)*GPNORM(II,J))
 1100 ECPT(II) = GPC(I)        
C        
C     CALCULATIONS FOR TSE-MATRIX        
C        
      FLAGS = NEST(27)        
      IF (FLAGS .EQ. 0) GO TO 1300        
C        
C     FLAGS IS 1, I.E. SCSID HAS BEEN SPECIFIED.        
C     CALCULATE TBS-MATRIX (STRESS TO BASIC)        
C        
      SCSID = NEST(26)        
      IF (SCSID .LE. 0) GO TO 1200        
      NECPT(1) = SCSID        
      CALL TRANSS (ECPT,TBS)        
      GO TO 1220        
 1200 DO 1210 I = 1,3        
      II = (I-1)*3        
      DO 1210 J = 1,3        
      JJ = (J-1)*3        
 1210 TSU(II+J) = TUB(I+JJ)        
      GO TO 1230        
C        
C     MULTIPLY        
C               T         T        
C            TBS  AND  TUB  TO GET TSU-MATRIX (USER TO STRESS)        
C        
 1220 CALL GMMATS (TBS,3,3,1, TUB,3,3,1, TSU)        
C        
C     CALCULATE THETAS FROM THE PROJECTION OF THE X-AXIS OF THE        
C     STRESS C.S. ON TO THE XY PLANE OF THE ELEMENT C.S.        
C        
 1230 CONTINUE        
      XS = TSU(1)        
      YS = TSU(2)        
      IF (ABS(XS).GT.EPS1 .OR. ABS(YS).GT.EPS1) GO TO 1240        
      NEST(2) = SCSID        
      J = 233        
      GO TO 1440        
 1240 THETAS = ATAN2(YS,XS)        
      GO TO 1310        
C        
C     FLAGS IS 0, I.E. THETAS HAS BEEN SPECIFIED.        
C     SUBROUTINE ANGTRS RETURNS THE 3X3 TRANSFORMATION USING THETAS.    
C     NOTE THAT IF THETAS IS LEFT BLANK (DEFAULT), THE TRANSFORMATION   
C     WILL BE IDENTITY,  I.E. THE STRESSES WILL BE OUTPUT IN THE        
C     ELEMENT COORDINATE SYSTEM.        
C     IF Q4STRS IS SET EQUAL TO 1, STRESSES WILL BE OUTPUT IN THE E C.S.
C     WHICH COOINCIDES WITH MSC'S  VERSION OF ELEMENT COORDINATE SYSTEM.
C        
 1300 THETAS = EST(26)*DEGRAD        
 1310 IF (Q4STRS .EQ. 1) GO TO 1320        
      CALL ANGTRS (THETAS,0,TSU)        
      CALL GMMATS (TSU,3,3,0, TEU,3,3,1, TSE)        
      GO TO 1330        
 1320 CALL ANGTRS (THETAS,0,TSE)        
C                                   T        
C     CALCULATE  TSI  = TSE X PSITRN  AND STORE IT IN PHIOUT        
C        
 1330 CALL GMMATS (TSE,3,3,0, PSITRN,3,3,1, PHIOUT(ICOUNT+2))        
C        
C     FOR CORNER POINTS (THE STRESS EVALUATION POINTS EXCEPT FOR THE    
C     ONES AT THE CENTER), CALCULATE TSB-MATRIX AND STORE IT IN IELOUT. 
C        
      IF (IXSI+IETA .GT. 4) GO TO 1340        
      IP  = (IXSI-1)*2 + IETA        
      IP1 = IPN(IP)        
      IP2 = (IP1-1)*25 + 4 + (IZTA-1)*9        
      CALL GMMATS (TSE,3,3,0, TEB,3,3,0, RELOUT(IP2))        
 1340 CONTINUE        
C        
C     CALL Q4BMGS TO GET B MATRIX        
C     SET THE ROW FLAG TO 3 TO CREATE THE FIRST 6 ROWS. THEN SET IT     
C     TO 1 FOR THE LAST 2 ROWS.        
C        
      ROWFLG = 3        
      CALL Q4BMGS (DSHP,GPTH,EGPDT,EPNORM,PHI,BMATRX(1))        
      DO 1350 IX = 1,NDOF        
 1350 BMATRX(IX+ND2) = XYBMAT(IBOT+IX)        
C        
      IF (.NOT.BENDNG) GO TO 1370        
      ROWFLG = 1        
      CALL Q4BMGS (DSHP,GPTH,EGPDT,EPNORM,PHI,BMATRX(1+ND6))        
      DO 1360 IX = 1,NDOF        
 1360 BMATRX(IX+ND5) = XYBMAT(IBOT+IX+NDOF)        
 1370 CONTINUE        
C        
C        
C     HERE WE SHIP OUT THE STRAIN RECOVERY MATRIX.        
C     --------------------------------------------        
C        
      KCOUNT = ICOUNT + 32 + NNODE        
      DO 1400 IPH = 1,ND8        
 1400 PHIOUT(KCOUNT+IPH) = BMATRX(IPH)        
 1410 CONTINUE        
 1420 CONTINUE        
      RETURN        
C        
 1430 NOGO = 1        
      RETURN        
C        
 1440 CALL MESAGE (30,J,NAME)        
      GO TO 1430        
C        
C     BEGINNING OF HEAT RECOVERY.        
C        
 1500 CONTINUE        
      MATID    = NEST(13)        
      INFLAG   = 2        
      NPHI(22) = 2        
      NPHI(23) = NNODE        
      NPHI(24) = NAME(1)        
      NPHI(25) = NAME(2)        
      XI  = 0.0        
      ETA = 0.0        
      CALL Q4SHPS (XI,ETA,SHP,DSHP)        
C        
C     SORT THE SHAPE FUNCTIONS AND THEIR DERIVATIVES INTO SIL ORDER.    
C        
      DO 1510 I = 1,4        
      TMPSHP(I  ) = SHP (I  )        
      DSHPTP(I  ) = DSHP(I  )        
 1510 DSHPTP(I+4) = DSHP(I+4)        
      DO 1520 I = 1,4        
      KK = IORDER(I)        
      SHP (I  ) = TMPSHP(KK  )        
      DSHP(I  ) = DSHPTP(KK  )        
 1520 DSHP(I+4) = DSHPTP(KK+4)        
C        
      HZTA = 0.0        
      CALL JACOBS (ELID,SHP,DSHP,GPTH,EGPDT,EPNORM,JACOBE)        
      IF (BADJAC) GO TO 1430        
C        
      DO 1530 I = 2,4        
      ECPT(I) = 0.0        
      DO 1530 J = 1,NNODE        
 1530 ECPT(I) = ECPT(I) + SHP(J)*BGPDT(I,J)        
C        
      FLAGS = NEST(27)        
      IF (FLAGS .EQ. 0) GO TO 1580        
      SCSID = NEST(26)        
      IF (SCSID .LE. 0) GO TO 1540        
      NECPT(1) = SCSID        
      CALL TRANSS (ECPT,TBS)        
      CALL GMMATS (TBS,3,3,1, TUB,3,3,1, TSU)        
      GO TO 1560        
 1540 DO 1550 I = 1,3        
      II = (I-1)*3        
      DO 1550 J = 1,3        
      JJ = (J-1)*3        
 1550 TSU(II+J) = TUB(I+JJ)        
 1560 CONTINUE        
      XS = TSU(1)        
      YS = TSU(2)        
      IF (ABS(XS).GT.EPS1 .OR. ABS(YS).GT.EPS1) GO TO 1570        
      NEST(2) = SCSID        
      J = 233        
      GO TO 1440        
 1570 THETAS = ATAN2(YS,XS)        
      GO TO 1590        
 1580 THETAS = EST(26)*DEGRAD        
 1590 CALL ANGTRS (THETAS,0,TSU)        
      SINMAT = 0.0        
      COSMAT = 1.0        
      CALL HMAT (ELID)        
      PHIOUT(26) = KHEAT(1)        
      PHIOUT(27) = KHEAT(2)        
      PHIOUT(28) = KHEAT(2)        
      PHIOUT(29) = KHEAT(3)        
C        
C     BRANCH IF THERMAL CONDUCTIVITY KHEAT IS ISOTROPIC.        
C     OTHERWISE, FIND TBM, TBS AND TMS AND COMPUTE THE KHEAT        
C     TENSOR IN 2-DIMENSIONAL STRESS COORDINATE SYSTEM.        
C        
C     COMMENTS FROM G.CHAN/UNISYS     10/88        
C     HMAT ROUTINE DOES NOT RETURN 'TYPE' IN COSMIC NASTRAN        
C     SO WE CAN ONLY ASSUME THERMAL CONDUCTIVITY IS ISOTROPIC AND       
C     BRANCH TO 1610 UNCONDITIOANLLY BY SETTING TYPE =-1        
C        
                                                TYPE =-1        
C        
      IF (TYPE.EQ.4 .OR. TYPE.EQ.-1) GO TO 1610        
      GO TO 290        
 1600 CONTINUE        
      CALL GMMATS (TUM,3,3,1, TSU,3,3,1, TMS)        
      TMS(3) = TMS(4)        
      TMS(4) = TMS(5)        
      CALL GMMATS (TMS,2,2,1, PHIOUT(26),2,2,0, TUM)        
      CALL GMMATS (TUM,2,2,0, TMS,2,2,0, PHIOUT(26))        
 1610 CONTINUE        
      CALL GMMATS (TEU,3,3,1, JACOBE,3,3,0, JACOBU)        
      CALL GMMATS (TSU,3,3,0, JACOBU,3,3,0, JACBS)        
      DO 1620 J = 1,NNODE        
      DQ(J) = DSHP(J)        
      JN = J + NNODE        
      DQ(JN) = DSHP(J+4)        
      JN = JN + NNODE        
 1620 DQ(JN) = 0.0        
      CALL GMMATS (JACBS,3,3,0, DQ,3,NNODE,0, PHIOUT(35))        
      RETURN        
C        
 1700 FORMAT (A23,', QUAD4 ELEMENT HAS UNDEFINED THICKNESS.  ELEMENT',  
     1       ' ID =',I8,', SIL ID =',I8)        
 1710 FORMAT (A23,', MODULE SDR2 DETECTS BAD OR REVERSE GEOMETRY FOR ', 
     1       'ELEMENT ID =',I8)        
      END        
