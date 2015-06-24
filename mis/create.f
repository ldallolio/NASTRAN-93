      SUBROUTINE CREATE (GPLST,X,U,DEFORM,CONMIN,CONMAX,ELMTID,STORE,   
     1                   LCOR,B1,B2)        
C        
      INTEGER         GPLST(1),DEFORM,LAYER,IDUMMY(2),EST,PRNT,SCR1,    
     1                OES1,STRESS,B1,B2,WHERE,DIRECT,SUB,ESTSYM(7),     
     2                SKIPWD(20),ELID,ESYM,GPTS(12),ELMTID(100),        
     3                MSG1(20),ERR(2),OFFSET        
      REAL            X(3,1),U(2,1),STORE(202)        
      DIMENSION       ISYM(14),ITYPE(14),PT(2,5),THIRD(2),C(2,4),       
     1                CENTRD(2)        
      COMMON /BLANK / SKIP(12),EST,SKIP1(7),PRNT,SKI(2),OES1,SCR1,SCR2, 
     1                NEW        
      COMMON /XXPARM/ SKIP4(157),NCNTR,CNTR(50),ICNTVL,WHERE,DIRECT,SUB,
     1                FLAG,VALUE,SKP20(20),LAYER        
      EQUIVALENCE     (NEW,NEWOES), (KQ4,ISYM(13)), (KT3,ISYM(14))      
      DATA   NTYPES / 14  /        
      DATA   ISYM   / 2HSH,2HT1,2HTB,2HTP,2HTM,2HQP,2HQM,2HT2,2HQ2,2HQ1,
     1                2HM1,2HM2,2HQ4,2HT3/,    KBAR/2HBR/        
      DATA   ITYPE  / 4, 6, 7, 8, 9, 15, 16, 17, 18, 19, 62, 63, 64, 83/
      DATA   ESTSYM / 7*0 /        
      DATA   SKIPWD /-5,-6,-7,-1,-2,-3,-4,-5,-6,4*0,0,-1,-2,-5,-6,-7,0 /
      DATA   NMSG1  , MSG1/20,4H(48H,4H NO ,4HSTRE,4HSS C,4HALCU,4HLATI,
     1       4HON F , 4HOUND,4H FOR,4H ELE,4HMENT,4H NUM,4HBER ,4H,I8,, 
     2       4H19H  , 4H- EL,4HEMEN,4HT IG,4HNORE,4HD.)                /
C        
      TWOPI  = 8.0*ATAN(1.0)        
      IRDEST = 0        
      CALL GOPEN (SCR1,GPLST(B1),1)        
      STRESS = OES1        
      IF ((ICNTVL.GE.4 .AND. ICNTVL.LE.9) .AND. DIRECT.EQ.2)        
     1    STRESS = NEWOES        
      IF (STRESS.EQ.OES1 .AND. (ICNTVL.EQ.6 .OR. ICNTVL.EQ.8 .OR.       
     1    ICNTVL.EQ.9)) GO TO 130        
      IF (STRESS .EQ. OES1) SKIPWD(7) = -3        
      CALL OPEN (*130,STRESS,GPLST(B2),0)        
      CONMIN = 0.0        
      CONMAX = 0.0        
      IEOR   = 0        
C        
C     CREATE A LIST OF ELEMENTS TYPES TO BE PLOTTED IN THIS SET        
C        
      JTJ  = 1        
      K    = 1        
      KEST = 0        
      CALL READ (*135,*135,EST,ESYM,1,0,M)        
      IF (ICNTVL .EQ. 20) GO TO 7        
C        
C     ELIMINATE ALL BUT MAXSHEAR FOR CSHEAR ELEMENT        
C        
    3 IF (ESYM.EQ.ISYM(1) .AND. ICNTVL.NE.3) GO TO 7        
C        
C     ELIMINATE MID STRESS FOR TRIA1, QUAD1, TRPLT, OR QDPLT        
C        
      IF ((ESYM.EQ.ISYM(2) .OR. ESYM.EQ.ISYM(10) .OR. ESYM.EQ.ISYM(4)   
     1   .OR. ESYM.EQ.ISYM(6)) .AND. WHERE.EQ.3) GO TO 7        
C        
C     ELIMINATE Z2 AND AVER STRESS FOR CTRMEM, CQDMEM, MEM1, MEM2       
C        
      IF ((ESYM.EQ.ISYM(5) .OR. ESYM.EQ.ISYM(7) .OR. ESYM.EQ.ISYM(11)   
     1   .OR. ESYM.EQ.ISYM(12)) .AND. (WHERE.EQ.-1 .OR. WHERE.EQ.3))    
     2    GO TO 7        
C        
C     ELIMINATE Z1, Z2 AND MAX FOR TRIA2 OR TRBSC ELEMENTS        
C        
      IF ((ESYM.EQ.ISYM(8) .OR. ESYM.EQ.ISYM(3)) .AND.        
     1   (IABS(WHERE).EQ.1 .OR. WHERE.EQ.2)) GO TO 7        
      DO 5 I = 1,NTYPES        
      IF (ESYM .EQ. ISYM(I)) GO TO 6        
    5 CONTINUE        
      GO TO 7        
    6 ESTSYM(K) = I        
      K = K + 1        
    7 CALL FREAD (EST,NGPPE,1,0)        
C        
    8 OFFSET = 0        
      IF (ESYM .EQ. KBAR) OFFSET = 6        
      IF (ESYM.EQ.KT3 .OR. ESYM.EQ.KQ4) OFFSET = 1        
C        
C     FLUSH TO NEXT SYMBOL        
C        
    9 CALL FREAD (EST,ELID,1,0)        
      IF (ELID .EQ. 0) GO TO (11,25), JTJ        
      J = 1 + NGPPE + OFFSET        
      CALL FREAD (EST,0,-J,0)        
      GO TO 9        
C        
C     READ NEXT SYMBOL        
C        
   11 CALL READ (*12,*12,EST,ESYM,1,0,M)        
      GO TO 3        
C        
C     LOOP BACK UNTIL ALL EST SYMBOLS ARE IN CORE        
C        
   12 K = K - 1        
      CALL BCKREC (EST)        
      JTJ = 2        
C        
C     NOTE THAT THE ASSUMPTION THAT STRESS AND EST FILES ARE ORDERED IN 
C     THE SAME WAY IS NO LONGER NECESSARY        
C        
   15 IF (IEOR .EQ. 0) CALL FWDREC (*125,STRESS)        
      IF (ICNTVL .NE. 20) GO TO 20        
      CALL FWDREC (*125,STRESS)        
      GO TO 25        
   20 CALL READ  (*125,*120,STRESS,IDUMMY,2,0,M)        
      CALL FREAD (STRESS,IELTYP,1,0)        
      CALL FREAD (STRESS,ISUB,1,0)        
      CALL FREAD (STRESS,DETAIL,1,0)        
      CALL FREAD (STRESS,EIGEN,1,0)        
      EIGEN = SQRT(ABS(EIGEN))/TWOPI        
      CALL FREAD (STRESS,0,-3,0)        
      CALL FREAD (STRESS,NWDS,1,1)        
      IF (SUB.GT.0 .AND. ISUB.NE.SUB) GO TO 50        
      IF (FLAG.EQ.1.0 .AND. DETAIL.NE.VALUE) GO TO 50        
      IF (FLAG.EQ.2.0 .AND. ABS(EIGEN-VALUE).GT.1.0E-5) GO TO 50        
      IEOR = 0        
      DO 22 I = 1,K        
      J = ESTSYM(I)        
      IF (J .EQ. 0) GO TO 22        
      IF (IELTYP .EQ. ITYPE(J)) GO TO 25        
   22 CONTINUE        
      GO TO 50        
C        
C     YES, WE DO WANT THIS ELEMENT TYPES STRESS DATA.  FIND THIS TYPES  
C     ELEMENTS IN THE EST        
C        
   25 CALL READ (*905,*905,EST,ESYM,1,0,M)        
      IRDEST = 1        
      CALL FREAD (EST,NGPPE,1,0)        
      IF (ICNTVL.EQ.20 .OR. ESYM.EQ.ISYM(J)) GO TO 27        
C        
C     FLUSH THE FILE UNTIL FOUND        
C        
      GO TO 8        
C        
   27 CALL WRITE (SCR1,ESYM,1,0)        
      KEST = KEST + 1        
      MEM  = 0        
      IF (IELTYP.EQ.9  .OR. IELTYP.EQ.16 .OR. IELTYP.EQ.15 .OR.        
     1    IELTYP.EQ.62 .OR. IELTYP.EQ.63) MEM = 1        
C         TRMEM(9), QDMEM(16), QDPLT(15), QDMEM1(62), QDMEM2(63)        
C        
      IWDS = SKIPWD(ICNTVL)        
      IF (ICNTVL .GT. 13) GO TO 29        
      IF (MEM .EQ. 1) IWDS = IWDS + 1        
      IF (WHERE.EQ.-1 .AND. MEM.NE.1) IWDS = IWDS - 8        
      NWDS = -NWDS - IWDS + 2        
      IF (IABS(WHERE).NE.1 .AND. MEM.NE.1) NWDS = NWDS + 8        
      IF (WHERE.EQ.-1 .AND. MEM.EQ.1) GO TO 50        
      IF (IELTYP.EQ.4 .AND. ICNTVL.NE.3) GO TO 50        
C         SHEAR(4)        
C        
   29 IS = 0        
C        
C     READ STRESS FILE        
C        
   30 IS = IS + 1        
      CALL READ (*58,*58,STRESS,ELMTID(IS),1,0,M)        
      IF (ICNTVL.LE.9 .OR. ICNTVL.EQ.20) GO TO 35        
      CALL FREAD (STRESS,NLAYER,1,0)        
      LAYTOT = NLAYER*11        
      LAYSKP = -((LAYER-1)*10+2)        
      CALL FREAD (STRESS,0,LAYSKP,0)        
   35 IF (IELTYP .NE. 4) GO TO 40        
C        
C     MAXIMUM SHEAR FOR CSHEAR ELEMENT        
C        
      CALL FREAD (STRESS,STORE(IS),1,0)        
      CALL FREAD (STRESS,0,-2,0)        
      IF (IS .EQ. LCOR) GO TO 60        
      GO TO 30        
   40 CALL FREAD (STRESS,0,IWDS,0)        
      CALL FREAD (STRESS,STORE(IS),1,0)        
      IF (ICNTVL.LE.9 .OR. ICNTVL.EQ.20) GO TO 41        
      NLFIN = -(LAYTOT-1+LAYSKP+IWDS)        
      CALL FREAD (STRESS,0,NLFIN,0)        
      GO TO 30        
   41 IF (ICNTVL .LT. 20) GO TO 42        
      CALL FREAD (STRESS,0,-1,0)        
      GO TO 30        
   42 IF (IABS(WHERE).EQ.1 .OR. MEM.EQ.1) GO TO 45        
      CALL FREAD (STRESS,0,-7,0)        
      CALL FREAD (STRESS,CONTUR,1,0)        
   45 CALL FREAD (STRESS,0,NWDS,0)        
      IF (MEM.EQ.1 .AND. IS.GE.LCOR) GO TO 60        
      IF (MEM   .EQ. 1) GO TO 30        
      IF (WHERE .EQ. 2) STORE(IS) = AMAX1(STORE(IS),CONTUR)        
      IF (WHERE .EQ. 3) STORE(IS) = (STORE(IS)+CONTUR)/2.0        
      IF (IS .GE. LCOR) GO TO 60        
      GO TO 30        
C        
C     SKIP THIS TYPE        
C        
   50 CALL FWDREC (*125,STRESS)        
      GO TO 20        
C        
C     END OF RECORD ON STRESS FILE        
C        
   58 IEOR = 1        
      IS   = IS - 1        
C        
C     STORE STRESS VALUES WITH ELEMENT ID.S        
C        
   60 CALL FREAD (EST,ELID,1,0)        
      IF (ELID .EQ. 0) GO TO 90        
      CALL FREAD (EST,0,-1,0)        
      CALL FREAD (EST,GPTS,NGPPE+OFFSET,0)        
C        
C     THE VERY NEXT LINE WAS ACCIDENTALLY DROPPED IN 88 VERSION        
C        
      IF (ELID .GT. ELMTID(IS)/10) GO TO 100        
      DO 65 IST = 1,IS        
      IF (ELID .EQ. ELMTID(IST)/10) GO TO 70        
   65 CONTINUE        
      ERR(1) = 1        
      ERR(2) = ELID        
      CALL WRTPRT (PRNT,ERR,MSG1,NMSG1)        
      GO TO 60        
C        
C     FIND ELEMENTS CENTROID        
C        
   70 DO 75 I = 1,NGPPE        
      IG = GPTS(I)        
      IG = IABS(GPLST(IG))        
      IF (DEFORM .NE. 0) GO TO 74        
      PT(1,I) = X(2,IG)        
      PT(2,I) = X(3,IG)        
      GO TO 75        
   74 PT(1,I) = U(1,IG)        
      PT(2,I) = U(2,IG)        
   75 CONTINUE        
      THIRD(1) = PT(1,3)        
      THIRD(2) = PT(2,3)        
      INDEX = 1        
      PT(1,NGPPE+1) = PT(1,1)        
      PT(2,NGPPE+1) = PT(2,1)        
      IF (NGPPE .LT. 4) GO TO 80        
      INDEX = 4        
      CALL CENTRE (*90,PT(1,1),PT(2,1),PT(1,2),PT(2,2),PT(1,3),PT(2,3), 
     1             PT(1,4),PT(2,4),CENTRD)        
      THIRD(1) = CENTRD(1)        
      THIRD(2) = CENTRD(2)        
   80 DO 85 I = 1,INDEX        
      CALL CENTRE (*90,PT(1,I),PT(2,I),PT(1,I+1),PT(2,I+1),(THIRD(1)+   
     1            PT(1,I+1))*.5,(THIRD(2)+PT(2,I+1))*.5,        
     2            (THIRD(1)+PT(1,I))*.5,(THIRD(2)+PT(2,I))*.5,CENTRD)   
      C(1,I) = CENTRD(1)        
      C(2,I) = CENTRD(2)        
   85 CONTINUE        
      IF (NGPPE .LT. 4) GO TO 90        
      CALL CENTRE (*90,C(1,1),C(2,1),C(1,2),C(2,2),C(1,3),C(2,3),C(1,4),
     1            C(2,4),CENTRD)        
   90 CALL WRITE (SCR1,ELID,1,0)        
      IF (ELID .NE. 0) GO TO 91        
  905 IF (KEST .EQ. K) GO TO 120        
      CALL BCKREC (EST)        
      IRDEST = 0        
      GO TO 15        
   91 CONTINUE        
      CALL WRITE (SCR1,STORE(IST),1,0)        
      CALL WRITE (SCR1,CENTRD,2,0)        
      IF (CONMIN.NE.0.0 .OR. CONMAX.NE.0.0) GO TO 92        
      CONMIN = STORE(IST)        
      CONMAX = CONMIN        
      GO TO 60        
   92 CONMIN = AMIN1(CONMIN,STORE(IST))        
      CONMAX = AMAX1(CONMAX,STORE(IST))        
      GO TO 60        
C        
C     REFILL STRESS STORAGE AREA        
C        
  100 IS = 0        
      IF (IEOR .EQ. 0) GO TO 30        
      ERR(1) = 1        
      ERR(2) = ELID        
      CALL WRTPRT (PRNT,ERR,MSG1,NMSG1)        
      GO TO 60        
  120 IF (STRESS .EQ. NEWOES) GO TO 126        
      CALL READ  (*125,*125,OES1,0,-3,0,M)        
      CALL FREAD (OES1,ISUB,1,0)        
      CALL FREAD (OES1,DETAIL,1,0)        
      CALL FREAD (OES1,EIGEN,1,1)        
      EIGEN = SQRT(ABS(EIGEN))/TWOPI        
      IF (ISUB .NE. SUB) GO TO 125        
      IF (FLAG.EQ.1.0 .AND. DETAIL.NE.VALUE) GO TO 125        
      IF (FLAG.EQ.2.0 .AND. ABS(EIGEN-VALUE).GT.1.0E-5) GO TO 125       
      CALL FWDREC (*125,OES1)        
      GO TO 120        
  125 CALL BCKREC (STRESS)        
  126 CALL CLOSE (STRESS,2)        
  130 CALL WRITE (SCR1,0,0,1)        
      CALL CLOSE (SCR1,1)        
      IF (IRDEST) 140,140,135        
  135 CALL BCKREC (EST)        
  140 CONTINUE        
      RETURN        
      END        
