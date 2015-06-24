      SUBROUTINE T3PL4D        
C        
C     DOUBLE PRECISION ROUTINE TO PROCESS PLOAD4 PRESSURE DATA AND      
C     GENERATE EQUIVALENT NODAL LOADS FOR A TRIA3 ELEMENT.        
C        
C     WAS NAMED T3PRSD (LOADVC,RPDATA,IPDATA) IN UAI        
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
C    DATA IN THE PLOAD4 ENTRY, 11 WORDS IN ISLT ARRAY        
C        
C       EID - ELEMENT ID, IPDATA(0)=ISLT(1)        
C       PPP - CORNER GRID POINT PRESSURES PER UNIT SURFACE AREA,        
C             RPDATA (1-4)        
C       DUM - DUMMY DATA WORDS, IPDATA (5-6)        
C       CID - COORDINATE SYSTEM FOR DEFINITION OF PRESSURE VECTOR,      
C             IPDATA(7)        
C       NV  - PRESSURE DIRECTION VECTOR, RPDATA(8-10)        
C           - IF CID IS BLANK OR ZERO, THE PRESSURE ACTS NORMAL TO THE  
C             SURFACE OF THE ELEMENT.        
C        
C     EQUIVALENT NUMERICAL INTEGRATION POINT LOADS PP(III) ARE OBTAINED 
C     VIA BI-LINEAR INTERPOLATION        
C        
      LOGICAL          CONSTP,SHEART,NORMAL        
      INTEGER          IPDATA(7),ISLT(1),IGPDT(4,3),SIL(3),IORDER(3),   
     1                 ELID,CID,SYSBUF,NOUT,NOGO        
      REAL             GPTH(3),BGPDT(4,3),NV(3),NVX(3),LOCATE(3),       
     1                 PE(3,3),RPDATA(1),LOADVC        
      DOUBLE PRECISION DPE(3,3),SHP(3),WEIGHT,DETJAC,V3T(3),        
     1                 P,PPP(3),BTERMS(6),BMATRX(162),EGPDT(4,3),       
     2                 CENTE(3),GPNORM(4,3),EPNORM(4,3),TEB(9),TUB(9),  
     3                 DGPTH(3),TH,AVGTHK,AIC(1),EDGLEN(3),LX,LY        
      COMMON /SYSTEM/  SYSBUF,NOUT,NOGO        
CZZ   COMMON /ZZSSA1/  LOADVC(1)        
      COMMON /ZZZZZZ/  LOADVC(1)        
      COMMON /PINDEX/  EST(45),SLT(11)        
      EQUIVALENCE      (SLT( 1),ISLT(1)),(EST( 1),ELID),(EST(2),SIL(1)),
     1                 (EST( 5),GPTH(1)),(EST(12),ELTH),        
     2                 (EST(27),BGPDT(1,1),IGPDT(1,1)),        
     3                 (SLT( 2),IPDATA(1) ,RPDATA(1))        
C        
C     INITIALIZE        
C        
      WEIGHT = 1.0D0/6.0D0        
      SHEART = .FALSE.        
      NNODE  = 3        
      NDOF   = 3        
      DO 10 I = 1,NDOF        
      DO 10 J = 1,NNODE        
      DPE(I,J) = 0.0D0        
   10 CONTINUE        
C        
C     GET THE PRESSURE INFORMATION        
C        
C     EST (45 WORDS) AND SLT (11 WORDS) ARE THE DATA FOR EST AND SLT    
C     WHICH ARE READ IN BY EXTERN AND ARE READY TO BE USED        
C        
C     IF ISLT(1).GT.0, GET THE PLOAD4 DATA FROM THE PROCESSED PLOAD2    
C                      INFORMATION IN ARRAY SLT.        
C                      (NOT AVAILABLE IN COSMIC/NASTRAN)        
C     IF ISLT(1).LT.0, GET THE PLOAD4 DATA FROM THE ORIGINAL PLOAD4     
C                      INFORMATION IN ARRAY RPDATA.        
C                      (SET TO NEGATIVE BY PLOAD4 SUBROUTINE)        
C        
      IF (ISLT(1) .LT. 0) GO TO 20        
      NORMAL = .TRUE.        
      CONSTP = .TRUE.        
      P = DBLE(SLT(2))        
      GO TO 60        
C        
   20 DO 30 I = 1,NNODE        
      PPP(I) = DBLE(RPDATA(I))        
   30 CONTINUE        
      CONSTP = PPP(2).EQ.0.0D0 .AND. PPP(3).EQ.0.0D0        
      IF (CONSTP) P = PPP(1)        
      CID = IPDATA(7)        
C        
C     GET THE DIRECTION VECTOR AND NORMALIZE IT        
C        
      X = 0.0        
      DO 40 I = 1,NNODE        
      NV(I) = RPDATA(I+7)        
      X = X + NV(I)*NV(I)        
   40 CONTINUE        
      NORMAL = .TRUE.        
      IF (X .LE. 0.0) GO TO 60        
      NORMAL = .FALSE.        
      X = SQRT(X)        
      DO 50 I = 1,NNODE        
      NV(I) = NV(I)/X        
   50 CONTINUE        
C        
C     SET UP THE ELEMENT FORMULATION        
C        
   60 CALL T3SETD (IERR,SIL,IGPDT,ELTH,GPTH,DGPTH,EGPDT,GPNORM,EPNORM,  
     1             IORDER,TEB,TUB,CENTE,AVGTHK,LX,LY,EDGLEN,ELID)       
      IF (IERR .NE. 0) GO TO 200        
C        
C     START THE LOOP ON INTEGRATION POINTS        
C        
      DO 150 IPT = 5,7        
C        
      CALL T3BMGD (IERR,SHEART,IPT,IORDER,EGPDT,DGPTH,AIC,TH,DETJAC,SHP,
     1             BTERMS,BMATRX)        
      IF (IERR .NE. 0) GO TO 200        
C        
C     CALCULATE THE PRESSURE AT THIS POINT        
C        
      IF (CONSTP) GO TO 80        
      P = 0.0D0        
      DO 70 I = 1,NNODE        
      P = P + SHP(I)*PPP(I)        
   70 CONTINUE        
C        
C     SET THE DIRECTION OF PRESSURE AT THIS POINT.        
C     THE RESULTING VECTOR MUST BE IN THE BASIC COORD. SYSTEM        
C        
   80 IF (.NOT.NORMAL) GO TO 90        
      V3T(1) = TEB(7)*DETJAC        
      V3T(2) = TEB(8)*DETJAC        
      V3T(3) = TEB(9)*DETJAC        
      GO TO 120        
C        
   90 IF (CID .NE. 0) GO TO 100        
      V3T(1) = NV(1)*DETJAC        
      V3T(2) = NV(2)*DETJAC        
      V3T(3) = NV(3)*DETJAC        
      GO TO 120        
C        
C     FOR NON-ZERO CID, COMPUTE THE LOCATION OF THE INTEGRATION POINT SO
C     THAT WE CAN ROTATE THE USER VECTOR PER CID.  THIS LOCATION IS     
C     REQUIRED ONLY IF CID IS CYLINDRICAL OR SPHERICAL.        
C        
  100 LOCATE(1) = 0.0        
      LOCATE(2) = 0.0        
      LOCATE(3) = 0.0        
      DO 110 J  = 1,NNODE        
      LOCATE(1) = LOCATE(1) + BGPDT(2,J)*SHP(J)        
      LOCATE(2) = LOCATE(2) + BGPDT(3,J)*SHP(J)        
      LOCATE(3) = LOCATE(3) + BGPDT(4,J)*SHP(J)        
  110 CONTINUE        
C        
C     NOW ROTATE THE VECTOR        
C        
      CALL GLBBAS (NV(1),NVX(1),LOCATE(1),CID)        
      V3T(1) = NVX(1)*DETJAC        
      V3T(2) = NVX(2)*DETJAC        
      V3T(3) = NVX(3)*DETJAC        
C        
C     COMPUTE THE CONTRIBUTION TO THE LOAD MATRIX FROM THIS INTEGRATION 
C     POINT AS NT*P*V3T        
C        
  120 DO 130 I = 1,NNODE        
      DO 130 J = 1,NDOF        
      DPE(J,I) = DPE(J,I) + WEIGHT*P*SHP(I)*V3T(J)        
      PE(J,I)  = DPE(J,I)        
  130 CONTINUE        
C        
  150 CONTINUE        
C        
C     END OF NUMERICAL INTEGRATION LOOP        
C     ADD ELEMENT LOAD TO OVERALL LOAD.        
C        
      DO 170 J = 1,NNODE        
      IF (IGPDT(1,J) .NE. 0) CALL BASGLB (PE(1,J),PE(1,J),BGPDT(2,J),   
     1                                    IGPDT(1,J))        
      JP = SIL(J) - 1        
      DO 170 I = 1,NDOF        
      LOADVC(JP+I) = LOADVC(JP+I) + PE(I,J)        
  170 CONTINUE        
      GO TO 250        
C        
C     FATAL ERROR        
C        
  200 ISLT(1) = IABS(ISLT(1))        
      CALL MESAGE (30,224,ISLT(1))        
      NOGO = 1        
C        
  250 RETURN        
      END        
