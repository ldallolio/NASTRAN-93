      SUBROUTINE TLTR3D        
C        
C     DOUBLE PRECISION ROUTINE TO GENERATE EQUIVALENT THERMAL LOADS FOR 
C     THE CTRIA3 ELEMENT.        
C        
C     WAS NAMED T3THLD (LOADVC,INTZ,Z) IN UAI        
C        
C        
C        
C                 EST  LISTING        
C        
C        WORD     TYP       DESCRIPTION        
C     ----------------------------------------------------------------  
C     ECT:        
C         1        I   ELEMENT ID, EID        
C         2-4      I   SIL LIST, GRIDS 1,2,3        
C         5-7      R   MEMBRANE THICKNESSES T, AT GRIDS 1,2,3        
C         8        R   MATERIAL PROPERTY ORIENTAION ANGLE, THETA        
C               OR I   COORD. SYSTEM ID (SEE TM ON CTRIA3 CARD)        
C         9        I   TYPE FLAG FOR WORD 8        
C        10        R   GRID OFFSET, ZOFF        
C    EPT:        
C        11        I   MATERIAL ID FOR MEMBRANE, MID1        
C        12        R   ELEMENT THICKNESS,T (MEMBRANE, UNIFORMED)        
C        13        I   MATERIAL ID FOR BENDING, MID2        
C        14        R   MOMENT OF INERTIA FACTOR, I (BENDING)        
C        15        I   MATERIAL ID FOR TRANSVERSE SHEAR, MID3        
C        16        R   TRANSV. SHEAR CORRECTION FACTOR, TS/T        
C        17        R   NON-STRUCTURAL MASS, NSM        
C        18-19     R   STRESS FIBER DISTANCES, Z1,Z2        
C        20        I   MATERIAL ID FOR MEMBRANE-BENDING COUPLING, MID4  
C        21        R   MATERIAL ANGLE OF ROTATION, THETA        
C               OR I   COORD. SYSTEM ID (SEE MCSID ON PSHELL CARD)      
C                      (DEFAULT FOR WORD 8)        
C        22        I   TYPE FLAG FOR WORD 21 (DEFAULT FOR WORD 9)       
C        23        I   INTEGRATION ORDER FLAG        
C        24        R   STRESS ANGLE OF RATATION, THETA        
C               OR I   COORD. SYSTEM ID (SEE SCSID ON PSHELL CARD)      
C        25        I   TYPE FLAG FOR WORD 24        
C        26        R   OFFSET, ZOFF1 (DEFAULT FOR WORD 10)        
C    BGPDT:        
C        27-38   I/R   CID,X,Y,Z  FOR GRIDS 1,2,3        
C    ETT:        
C        39        I   ELEMENT TEMPERATURE        
C        
C        
C        
      LOGICAL          MEMBRN,BENDNG,SHRFLX,MBCOUP,NORPTH,COMPOS,       
     1                 TEMPP1,TEMPP2,SHEART,NOALFA        
      INTEGER          HUNMEG,NEST(39),ELID,PID,MID(4),SIL(3),        
     1                 IGPDT(4,3),NECPT(4),IORDER(3),COMPS,FLAG,        
     2                 INDXG2(3,3),SYSBUF,NOUT,NOGO        
      REAL             GPTH(3),BGPDT(4,3),ECPT(4),TSUB0,STEMP,Z,        
     1                 LOADVC(1)        
      DOUBLE PRECISION PT(6,3),PTG(6,3),PI,TWOPI,RADDEG,DEGRAD,        
     1                 EGPDT(4,3),EPNORM(4,3),GPNORM(4,3),DGPTH(6),RHO, 
     2                 THETAM,CENTE(3),SHPT(3),WEIGHT,WTSTIF,LX,LY,     
     3                 BMATRX(162),BTERMS(6),DETJAC,G(6,6),GI(36),      
     4                 AIC(1),DETG2,G2(3,3),EGNOR(4),MOMINR,TS,TH,      
     5                 REALI,AVGTHK,TEM(9),TBG(9),TEB(9),TEU(9),TUB(9), 
     6                 TUM(9),ALPHA(6),ALFAM(3),ALFAB(3),TALFAM(3),     
     7                 TALFAB(3),TBAR,TGRAD,TMEAN,FTHERM(6),THRMOM(3),  
     8                 GTEMPS(3),EPSLNT(6),EPSUBT(6),GEPSBT(6),        
     9                 TRANS(27),OFFSET,TMPTRN(36),EPS,THETAE,EDGLEN(3) 
      COMMON /SYSTEM/  SYSBUF,NOUT,NOGO        
      COMMON /MATIN /  MATID,INFLAG,ELTEMP,DUMMY,SINMAT,COSMAT        
      COMMON /BLANK /  NROWSP,IPARAM,COMPS        
      COMMON /CONDAD/  PI,TWOPI,RADDEG,DEGRAD        
      COMMON /TERMS /  MEMBRN,BENDNG,SHRFLX,MBCOUP,NORPTH        
CZZ   COMMON /ZZSSB1/  Z(1)        
      COMMON /ZZZZZZ/  Z(1)        
      COMMON /SGTMPD/  STEMP(7)        
      COMMON /TRIMEX/  EST(39)        
      EQUIVALENCE      (EST( 1),NEST(1)),(EST( 2),SIL(1)),        
     1                 (EST( 5),GPTH(1)),(EST(10),ZOFF  ),        
     2                 (EST(12),ELTH   ),(EST(26),ZOFF1 ),        
     3                 (EST(39),TEMPEL ),(EST(27),BGPDT(1,1),IGPDT(1,1))
      EQUIVALENCE      (NECPT(1),ECPT(1)),(STEMP(7),FLAG),        
     1                 (Z(1),LOADVC(1))        
      DATA    HUNMEG,  EPS / 100000000, 1.0D-7 /        
C        
C        
C     INITIALIZE        
C        
      NNODE  = 3        
      ELID   = NEST(1)        
      WEIGHT = 1.0D0/6.0D0        
      SHEART =.FALSE.        
      NOALFA =.FALSE.        
      TGRAD  = 0.0D0        
      ELTEMP = TEMPEL        
      OFFSET = ZOFF        
      IF (ZOFF .EQ. 0.0) OFFSET = ZOFF1        
C        
      DO 10 LL = 1,3        
      TALFAM(LL) = 0.0D0        
      TALFAB(LL) = 0.0D0        
      FTHERM(LL) = 0.0D0        
      FTHERM(LL+3) = 0.0D0        
   10 CONTINUE        
C        
C     TEST FOR COMPOSITE ELEMENT        
C        
      PID    = NEST(11) - HUNMEG        
      COMPOS = COMPS.EQ.-1 .AND. PID.GT.0        
C        
C     CHECK FOR THE TYPE OF TEMPERATURE DATA        
C     - TYPE TEMPP1 ALSO INCLUDES TYPE TEMPP3.        
C     - IF TEMPPI ARE NOT SUPPLIED, GRID POINT TEMPERATURES ARE PRESENT.
C        
      TEMPP1 = FLAG .EQ. 13        
      TEMPP2 = FLAG .EQ. 2        
C        
C     SET UP THE ELEMENT FORMULATION        
C        
      CALL T3SETD (IERR,SIL,IGPDT,ELTH,GPTH,DGPTH,EGPDT,GPNORM,EPNORM,  
     1             IORDER,TEB,TUB,CENTE,AVGTHK,LX,LY,EDGLEN,ELID)       
      IF (IERR .NE. 0) GO TO 520        
      CALL GMMATD (TEB,3,3,0, TUB,3,3,1, TEU)        
C        
C     SET THE NUMBER OF DOF'S        
C        
      NNOD2 = NNODE*NNODE        
      NDOF  = NNODE*6        
      NPART = NDOF*NDOF        
      ND2   = NDOF*2        
      ND6   = NDOF*6        
      ND7   = NDOF*7        
      ND8   = NDOF*8        
C        
C     OBTAIN MATERIAL INFORMATION        
C        
C     PASS THE LOCATION OF THE ELEMENT CENTER FOR MATERIAL        
C     TRANSFORMATIONS.        
C        
      DO 20 IEC = 2,4        
      ECPT(IEC) = CENTE(IEC-1)        
   20 CONTINUE        
C        
C     SET MATERIAL FLAGS        
C     0.833333333D0 = 5.0D0/6.0D0        
C        
      IF (NEST(13) .NE.  0) MOMINR = EST(14)        
      IF (NEST(13) .NE.  0) TS = EST(16)        
      IF ( EST(16) .EQ. .0) TS = 0.83333333D0        
      IF (NEST(13).EQ.0 .AND. NEST(11).GT.HUNMEG) TS = 0.83333333D0     
C        
      MID(1) = NEST(11)        
      MID(2) = NEST(13)        
      MID(3) = NEST(15)        
      MID(4) = NEST(20)        
C        
      MEMBRN = MID(1).GT.0        
      BENDNG = MID(2).GT.0 .AND. MOMINR.GT.0.0D0        
      SHRFLX = MID(3).GT.0        
      MBCOUP = MID(4).GT.0        
      NORPTH = MID(1).EQ.MID(2) .AND. MID(1).EQ.MID(3) .AND. MID(4).EQ.0
     1         .AND. DABS(MOMINR-1.0D0).LE.EPS        
C        
C     SET UP TRANSFORMATION MATRIX FROM MATERIAL TO ELEMENT COORD.SYSTEM
C        
      CALL SHCSGD (*530,NEST(9),NEST(8),NEST(8),NEST(21),NEST(20),      
     1             NEST(20),NECPT,TUB,MCSID,THETAM,TUM)        
      CALL GMMATD (TEU,3,3,0, TUM,3,3,0, TEM)        
C        
C     CALCULATE THE ANGLE BETWEEN THE MATERIAL AXIS AND THE ELEMENT AXIS
C        
      THETAE = DATAN2(TEM(4),TEM(1))        
C        
C     FETCH MATERIAL PROPERTIES        
C        
      CALL SHGMGD (*540,ELID,TEM,MID,TS,NOALFA,GI,RHO,GSUBE,TSUB0,      
     1             EGNOR,ALPHA)        
C        
      DO 30 IAL = 1,3        
      ALFAM(IAL) = ALPHA(IAL  )        
      ALFAB(IAL) = ALPHA(IAL+3)        
   30 CONTINUE        
C        
C     TURN OFF THE COUPLING FLAG WHEN MID4 IS PRESENT WITH ALL        
C     CALCULATED ZERO TERMS.        
C        
      IF (.NOT.MBCOUP) GO TO 50        
      DO 40 I = 28,36        
      IF (DABS(GI(I)) .GT. EPS) GO TO 50        
   40 CONTINUE        
      MBCOUP = .FALSE.        
C        
C     OBTAIN TEMPERATURE INFORMATION        
C        
C     IF TEMPP1 DATA, GET AVERAGE TEMP AND THERMAL GRADIENT.        
C        
   50 IF (.NOT.TEMPP1) GO TO 60        
      TMEAN = STEMP(1)        
      TGRAD = STEMP(2)        
      GO TO 90        
C        
C     IF TEMPP2 DATA, GET THERMAL MOMENTS.        
C        
   60 IF (.NOT.TEMPP2) GO TO 70        
      TMEAN = STEMP(1)        
C        
      THRMOM(1) = STEMP(2)        
      THRMOM(2) = STEMP(3)        
      THRMOM(3) = STEMP(4)        
C        
      FTHERM(4) = THRMOM(1)        
      FTHERM(5) = THRMOM(2)        
      FTHERM(6) = THRMOM(3)        
      GO TO 90        
C        
C     TEMPPI TEMPERATURE DATA IS NOT AVAILABLE, THEREFORE SORT THE GRID 
C     POINT TEMPERATURES (IN STEMP(1-7)).        
C        
   70 DO 80 I = 1,NNODE        
      IPNT = IORDER(I)        
      GTEMPS(I) = STEMP(IPNT)        
   80 CONTINUE        
      TMEAN = (GTEMPS(1)+GTEMPS(2)+GTEMPS(3))/3.0D0        
   90 TBAR = TMEAN - TSUB0        
C        
C     CALCULATE THERMAL STRAINS FOR COMPOSITE ELEMENTS        
C        
      IF (.NOT.COMPOS) GO TO 100        
      CALL SHCTSD (IERR,ELID,PID,MID,AVGTHK,TMEAN,TGRAD,THETAE,FTHERM,  
     1             EPSLNT,Z,Z)        
      IF (IERR .NE. 0) GO TO 500        
C        
C     INITIALIZE FOR THE MAIN INTEGRATION LOOP        
C        
  100 DO 110 I = 1,6        
      EPSUBT(I) = 0.0D0        
      DO 110 J = 1,NNODE        
      PT (I,J)  = 0.0D0        
      PTG(I,J)  = 0.0D0        
  110 CONTINUE        
C        
C     MAIN INTEGRATION LOOP        
C        
      DO 400 IPT = 1,NNODE        
      CALL T3BMGD (IERR,SHEART,IPT,IORDER,EGPDT,DGPTH,AIC,TH,DETJAC,    
     1             SHPT,BTERMS,BMATRX)        
      IF (IERR .NE. 0) GO TO 520        
C        
      WTSTIF = DETJAC*WEIGHT        
      REALI  = MOMINR*TH*TH*TH/12.0D0        
C        
C     FILL IN THE 6X6 [G]        
C        
      DO 200 IG = 1,6        
      DO 200 JG = 1,6        
      G(IG,JG) = 0.0D0        
  200 CONTINUE        
C        
      IF (.NOT.MEMBRN) GO TO 220        
      DO 210 IG = 1,3        
      IG1 = (IG-1)*3        
      DO 210 JG = 1,3        
      G(IG,JG) = GI(IG1+JG)*TH        
  210 CONTINUE        
C        
  220 IF (.NOT.BENDNG) GO TO 250        
      DO 230 IG = 4,6        
      IG2 = (IG-2)*3        
      DO 230 JG = 4,6        
      G(IG,JG) = GI(IG2+JG)*REALI        
  230 CONTINUE        
C        
      IF (.NOT.MBCOUP) GO TO 250        
      DO 240 IG = 1,3        
      IG4 = (IG+8)*3        
      DO 240 JG = 1,3        
      G(IG,JG+3) = GI(IG4+JG)*TH*TH        
      G(IG+3,JG) = G(IG,JG+3)        
  240 CONTINUE        
C        
C     PREPARE THERMAL STRAINS FOR COMPOSITE ELEMENTS        
C        
  250 IF (.NOT.COMPOS) GO TO 270        
      DO 260 IR = 1,6        
      EPSUBT(IR) = WTSTIF*EPSLNT(IR)        
  260 CONTINUE        
      GO TO 370        
C        
C     CALCULATE THERMAL STRAINS FOR NON-COMPOSITE ELEMENTS        
C        
  270 IF (.NOT.MEMBRN) GO TO 290        
      DO 280 I = 1,3        
      TALFAM(I) = TBAR*ALFAM(I)        
  280 CONTINUE        
C        
  290 IF (.NOT.BENDNG) GO TO 350        
      IF (.NOT.TEMPP1) GO TO 310        
      DO 300 I = 1,3        
      TALFAB(I) = -TGRAD*ALFAB(I)        
  300 CONTINUE        
      GO TO 350        
C        
  310 IF (.NOT.TEMPP2) GO TO 330        
      DO 320 IG = 1,3        
      DO 320 JG = 1,3        
      G2(IG,JG) = G(IG+3,JG+3)        
  320 CONTINUE        
C        
      CALL INVERD (3,G2,3,GDUM,0,DETG2,ISNGG2,INDXG2)        
      CALL GMMATD (G2,3,3,0, THRMOM,3,1,0, TALFAB)        
      GO TO 350        
C        
  330 DO 340 I = 1,3        
      TALFAB(I) = 0.0D0        
  340 CONTINUE        
C        
  350 DO 360 I = 1,3        
      EPSUBT(I  ) = WTSTIF*TALFAM(I)        
      EPSUBT(I+3) = WTSTIF*TALFAB(I)        
  360 CONTINUE        
C        
C                                T        
C     [P]  = [P]  + WTSTIF*[B] [G][EPS]        
C        T      T                      T        
C        
  370 CALL GMMATD (G,6,6,0, EPSUBT,6,1,0, GEPSBT)        
      CALL GMMATD (BMATRX,6,NDOF,-1, GEPSBT,6,1,0, PT)        
C        
  400 CONTINUE        
C        
C     END OF MAIN INTEGRATION LOOP        
C        
C     PICK UP THE ELEMENT TO GLOBAL TRANSFORMATION FOR EACH NODE.       
C        
      DO 420 I = 1,NNODE        
      IPOINT = 9*(I-1)+1        
      CALL TRANSD (BGPDT(1,I),TBG)        
      CALL GMMATD (TEB,3,3,0, TBG,3,3,0, TRANS(IPOINT))        
  420 CONTINUE        
C        
C     TRANSFORM THE THERMAL LOAD VECTOR INTO THE INDIVIDUAL GLOBAL      
C     COORDINATE SYSTEMS OF EACH NODE.        
C        
C                 T        
C     [PT] = [TEG] [PT]        
C         G            E        
C        
      DO 430 I = 1,NNODE        
      CALL TLDRD  (OFFSET,I,TRANS,TMPTRN)        
      CALL GMMATD (TMPTRN,6,6,1, PT(1,I),6,1,0, PTG(1,I))        
  430 CONTINUE        
C        
C     ADD THE THERMAL LOAD VECTOR TO THE GLOBAL LOAD VECTOR WHICH       
C     RESIDES IN [LOADVC].        
C        
      DO 440 I = 1,NNODE        
      K = SIL(I) - 1        
      DO 440 J = 1,6        
      LOADVC(K+J) = LOADVC(K+J) + SNGL(PTG(J,I))        
  440 CONTINUE        
      GO TO 600        
C        
C     FATAL ERRORS        
C        
  500 WRITE  (NOUT,510)        
  510 FORMAT ('0*** SYSTEM FATAL ERROR.  APPROPRIATE COMPOSITE DATA ',  
     1        'NOT FOUND IN MODULE SSG1.')        
      GO TO 560        
  520 J = 224        
      GO TO 550        
  530 J = 225        
      NEST(2) = MCSID        
      GO TO 550        
  540 J = 226        
      NEST(2) = MID(3)        
  550 CALL MESAGE (30,J,NEST(1))        
  560 NOGO = 1        
C        
  600 RETURN        
      END        
