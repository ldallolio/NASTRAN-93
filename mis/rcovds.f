      SUBROUTINE RCOVDS        
C        
C     THIS ROUTINE GENERATES THE DYNAMIC SOLUTION ITEM FOR RIGID        
C     FORMATS 8 AND 9        
C        
      INTEGER         DRY        ,STEP       ,FSS        ,RFNO        , 
     1                RD         ,RDREW      ,WRT        ,WRTREW      , 
     2                REW        ,SYSBUF     ,RC         ,EQSS        , 
     3                SOLN       ,SRD        ,SWRT       ,EOI         , 
     4                EOG        ,IZ(5)      ,UPV        ,TRL(7)      , 
     5                BUF1       ,DLOAD      ,DLT        ,CASESS      , 
     6                GEOM4      ,LOADC(2)   ,TOLPPF     ,NAME(2)     , 
     7                FILE       ,DIT        ,TABLOC(13) ,CASECC(2)     
      CHARACTER       UFM*23     ,UWM*25        
      COMMON /XMSSG / UFM        ,UWM        
      COMMON /BLANK / DRY        ,LOOP       ,STEP       ,FSS(2)      , 
     1                RFNO       ,NEIGV      ,LUI        ,UINMS(2,5)  , 
     2                NOSORT     ,UTHRES     ,PTHRES     ,QTHRES        
      COMMON /RCOVCR/ ICORE      ,LCORE      ,BUF1       ,BUF2        , 
     1                BUF3       ,BUF4       ,SOF1       ,SOF2        , 
     2                SOF3        
      COMMON /RCOVCM/ MRECVR     ,UA         ,PA         ,QA          , 
     1                IOPT       ,RSS(2)     ,ENERGY     ,UIMPRO      , 
     2                RANGE(2)   ,IREQ       ,LREQ       ,LBASIC        
      COMMON /NAMES / RD         ,RDREW      ,WRT        ,WRTREW      , 
     1                REW        ,NOREW      ,EOFNRW        
CZZ   COMMON /ZZRCAX/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SYSTEM/ SYSBUF     ,NOUT        
      COMMON /CONDAS/ PI         ,TWOPI      ,RADEG      ,DEGRA        
      EQUIVALENCE     (Z(1),IZ(1)) ,  (ISCALE,SCALE)        
      DATA    NAME  / 4HRCOV,4HDS  /        
      DATA    EQSS  , SOLN,LODS    / 4HEQSS,4HSOLN,4HLODS /        
      DATA    SRD   , SWRT,EOG,EOI / 1,2,2,3      /        
      DATA    UPV   , DLT,CASESS,GEOM4,TOLPPF,DIT /        
     1        106   , 108,101   ,102  ,111   ,107 /        
      DATA    LOADC / 500,  5      /        
      DATA    TABLOC/ 4,1105,11,1,1205,12,2,1305,13,3,1405,14,4 /       
      DATA    CASECC/ 4HCASE,4HCC  /        
C        
C     CREATE SOLN FOR RIGID FORMAT 8 OR 9        
C        
C     GET NUMBER OF BASIC SUBSTRUCTURES (NS) FROM EQSS AND CREATE       
C     GROUP 0 OF SOLN AT TOP OF OPEN CORE        
C        
      LCORE = BUF1 - 1        
      CALL SFETCH (FSS,EQSS,SRD,RC)        
      IF (RC .EQ. 1) GO TO 110        
      CALL SMSG (RC-2,EQSS,FSS)        
      GO TO 810        
  110 CALL SUREAD (Z,2,NWDS,RC)        
      CALL SUREAD (NS,1,NWDS,RC)        
      IF (LCORE .LT. 2*NS+5) GO TO 9008        
      CALL SUREAD (Z,1,NWDS,RC)        
      IZ(1) = FSS(1)        
      IZ(2) = FSS(2)        
      IZ(3) = RFNO        
      IZ(4) = NS        
C        
C     GET THE BASIC SUBSTRUCTURE NAMES FROM EQSS        
C        
      DO 120 I = 1,NS        
      CALL SUREAD (Z(3*I+3),2,NWDS,RC)        
  120 CONTINUE        
C        
C     GET THE NUMBER OF LOAD VECTORS FOR EACH SUBSTRUCTURE FORM LODS    
C        
      CALL SFETCH (FSS,LODS,SRD,RC)        
      IF (RC .EQ. 1) GO TO 160        
      CALL SMSG (RC-2,LODS,FSS)        
      GO TO 9200        
  160 J = 1        
      CALL SJUMP (J)        
      DO 170 I = 1,NS        
      CALL SUREAD (Z(3*I+5),1,NWDS,RC)        
  170 CALL SJUMP  (J)        
C        
C     GET THE NUMBER OF TIME OR FREQUENCY STEPS FROM UPV OR UPVC        
C        
      TRL(1) = UPV        
      CALL RDTRL (TRL)        
      NSTEP = TRL(2)        
      IF (RFNO .EQ. 9) NSTEP = NSTEP/3        
      IZ(5) = NSTEP        
C        
C     GET THE REQUESTED DLOAD SET FROM CASE CONTROL        
C        
      FILE = CASESS        
      CALL GOPEN (CASESS,Z(BUF1),RDREW)        
  180 CALL FREAD (CASESS,TRL,2,1)        
      IF (TRL(1).NE.CASECC(1) .OR. TRL(2).NE.CASECC(2)) GO TO 180       
      CALL FREAD (CASESS,0,-12,0)        
      CALL FREAD (CASESS,DLOAD,1,0)        
      CALL CLOSE (CASESS,REW)        
C        
C     CHECK IF DLOAD SET POINTS TO A DLOAD COMBINATION CARD OR A        
C     SIMPLE LOAD CARD BY LOOKING AT SET IDS IN HEADER RECORD OF DLT    
C        
      I = 3*NS + 6        
      FILE = DLT        
      CALL OPEN (*9001,DLT,Z(BUF1),RDREW)        
      CALL READ (*9002,*200,DLT,Z(I),LCORE-I,1,NWDS)        
      GO TO 9008        
  200 IDLSET = I + 3        
      LDLSET = IDLSET + IZ(I+2) - 1        
      ILDSET = LDLSET + 1        
      LLDSET = I + NWDS - 1        
      IDLOAD = LLDSET + 1        
      IF (IDLSET .GT. LDLSET) GO TO 215        
      DO 210 I = IDLSET,LDLSET        
      IF (IZ(I) .EQ. DLOAD) GO TO 220        
  210 CONTINUE        
C        
C     NO DLOAD MATCH - MUST BE SIMPLE RLOAD OR TLOAD        
C        
  215 Z(IDLOAD) = 1.0        
      IZ(IDLOAD+1) = DLOAD        
      LDLOAD = IDLOAD + 1        
      GO TO 270        
C        
C     DLOAD MATCH FOUND - READ DLOAD DATA FORM DLT RECORD 1        
C        
  220 CALL FREAD (DLT,TRL,2,0)        
      IF (TRL(1) .EQ. DLOAD) GO TO 240        
  230 CALL FREAD (DLT,TRL,2,0)        
      IF (TRL(1) .NE. -1) GO TO 230        
      GO TO 220        
  240 I = IDLOAD        
      ISCALE = TRL(2)        
  250 CALL FREAD (DLT,Z(I),2,0)        
      IF (IZ(I) .EQ. -1) GO TO 260        
      Z(I) = Z(I)*SCALE        
      I = I + 2        
      IF (I .GT. LCORE) GO TO 9008        
      GO TO 250        
  260 LDLOAD = I - 1        
C        
C     READ THE RLOAD AND TLOAD DATA FORM DLT AND SAVE REQUESTED CARDS   
C        
  270 ILOAD = LDLOAD + 1        
      L = ILOAD        
      IF (IDLSET .LE. LDLSET) CALL FWDREC (*9002,DLT)        
      DO 310 I = ILDSET,LLDSET        
      DO 280 J = IDLOAD,LDLOAD,2        
      IF (IZ(J+1) .EQ. IZ(I)) GO TO 290        
  280 CONTINUE        
      CALL FWDREC (*9002,DLT)        
      GO TO 310        
C        
C     SAVE RLOAD DATA IF RIGID FORMAT 8        
C     SAVE TLOAD DATA IF RIGID FORMAT 9        
C        
  290 CALL FREAD (DLT,ITYPE,1,0)        
      IF (ITYPE.LE.2 .AND. RFNO.EQ.8) GO TO 300        
      IF (ITYPE.GE.3 .AND. RFNO.EQ.9) GO TO 300        
      CALL FWDREC (*9002,DLT)        
      GO TO 310        
C        
  300 IZ(L) = ITYPE        
      CALL FREAD (DLT,IZ(L+1),7,1)        
      IZ(J+1) = -L        
      L = L + 8        
      IF (L .GT. LCORE) GO TO 9008        
  310 CONTINUE        
C        
      LLOAD = L - 1        
      CALL CLOSE (DLT,REW)        
C        
C     READ THE LOADC DATA FROM GEOM4 AND SAVE ANY THAT WAS REQUESTED    
C     ON TLOAD OR RLOAD CARDS        
C        
C     NOTE - UNTIL A MODULE FRLG IS WRITTEN NO RLOAD CARD MAY REQUEST A 
C            SCALAR LOAD        
C        
      NSLOAD = 0        
      ILOADC = LLOAD  + 1        
      LLOADC = ILOADC - 1        
      ISLOAD = ILOADC        
      LSLOAD = ISLOAD - 1        
C        
      IF (RFNO .EQ. 8) GO TO 500        
C        
      CALL PRELOC (*500,Z(BUF1),GEOM4)        
      CALL LOCATE (*500,Z(BUF1),LOADC,I)        
      IOLD = 0        
      I1 = ILOADC        
      I2 = I1        
  320 CALL READ (*9002,*370,GEOM4,TRL(1),2,0,NWDS)        
      ISCALE = TRL(2)        
      IF (IOLD .EQ. TRL(1)) GO TO 360        
      IHIT = 0        
      DO 330 I = ILOAD,LLOAD,8        
      IF (TRL(1) .NE. IZ(I+1)) GO TO 330        
      IZ(I+1) = -I1        
      IHIT = IHIT + 1        
  330 CONTINUE        
      IF (IHIT .GT. 0) GO TO 350        
  340 CALL FREAD (GEOM4,TRL(1),4,0)        
      IF (TRL(3) .NE. -1) GO TO 340        
      GO TO 320        
C        
C     THIS LOADC DATA WAS REQUESTED - SAVE THE DATA AND A POINTER TO IT 
C        
  350 IOLD = TRL(1)        
      I1 = I2        
      IZ(I1) = 0        
      I2 = I1 + 1        
  360 CALL FREAD (GEOM4,Z(I2),4,0)        
      IF (IZ(I2+2) .EQ. -1) GO TO 320        
      IZ(I1) = IZ(I1) + 1        
      Z(I2+3) = Z(I2+3)*SCALE        
      I2 = I2 + 4        
      IF (I2 .GT. LCORE) GO TO 9008        
      GO TO 360        
C        
C     CONVERT LOADC LOAD SETS TO INTERNAL LOAD IDS BY USING THE LODS    
C     ITEM        
C        
  370 LLOADC = I2 - 1        
      IF (ILOADC .GT. LLOADC) GO TO 500        
      CALL SFETCH (FSS,LODS,SRD,RC)        
      I = 1        
      CALL SJUMP (I)        
      ILOD = 1        
      IDAT0= LLOADC + 1        
      IDAT = IDAT0  + 1        
      NDAT = LCORE  - LLOADC        
      ISUB = 6        
      LSUB = 3*NS + 5        
C        
C     FOR EACH BASIC READ THE LODS DATA INTO CORE        
C        
      DO 410 I = ISUB,LSUB,3        
      CALL SUREAD (Z(IDAT0),NDAT,NWDS,RC)        
      IF (RC .NE. 2) GO TO 9008        
      J = ILOADC        
  380 I1 = J + 1        
      I2 = J + IZ(J)*4        
      DO 400 K = I1,I2,4        
      IF (IZ(K).NE.IZ(I) .OR. IZ(K+1).NE.IZ(I+1)) GO TO 400        
C        
C     FOUND LOADC DATA FOR THIS BASIC - CONVERT LOAD SET ID        
C        
      IZ(K  ) = 0        
      IZ(K+1) = 0        
      NWDS = IDAT0 + NWDS - 1        
      DO 390 L = IDAT,NWDS        
      IF (IZ(L) .EQ. IZ(K+2)) GO TO 395        
  390 CONTINUE        
      WRITE (NOUT,6316) UWM,IZ(K+2),Z(I),Z(I+1),FSS        
      IZ(K+2) = -1        
      GO TO 400        
C        
  395 IZ(K+2) = ILOD + L - IDAT        
C        
  400 CONTINUE        
      J = I2 + 1        
      IF (J .LT. LLOADC) GO TO 380        
C        
  410 ILOD = ILOD + IZ(IDAT0)        
C        
C     CREATE A LIST OF INTERNAL LOAD VECTORS REQUESTED - ALSO CHECK IF  
C     ANY BASIC NAMES WERE NOT FOUND        
C        
      ISLOAD = LLOADC + 1        
      LSLOAD = ISLOAD - 1        
      NSLOAD = 0        
      J  = ILOADC        
  420 I1 = J + 1        
      I2 = J + IZ(J)*4        
      DO 460 K = I1,I2,4        
      IF (IZ(K) .EQ. 0) GO TO 430        
      WRITE (NOUT,6315) UWM,Z(K),Z(K+1),FSS,IZ(K+2),FSS        
      IZ(K+2) = -1        
      GO TO 460        
  430 IF (IZ(K+2) .LT. 0) GO TO 460        
      IF (NSLOAD  .EQ. 0) GO TO 455        
      DO 450 I = ISLOAD,LSLOAD        
      IF (IZ(I) .EQ. IZ(K+2)) GO TO 460        
  450 CONTINUE        
  455 NSLOAD = NSLOAD + 1        
      LSLOAD = LSLOAD + 1        
      IF (LSLOAD .GT. LCORE) GO TO 9008        
      IZ(LSLOAD) = IZ(K+2)        
  460 CONTINUE        
      J = I2 + 1        
      IF (J .LT. LLOADC) GO TO 420        
C        
C     SORT LIST OF IDS        
C        
      CALL SORT (0,0,1,1,Z(ISLOAD),NSLOAD)        
C        
C     MAKE ONE MORE PASS THROUGH THE LOAC DATA CONVERTING THE        
C     INTERNAL LOAD IDS TO A RELATIVE POSITION IN THE LOAD LIST        
C     STARTING AT ISLOAD        
C        
      J  = ILOADC        
  470 I1 = J + 1        
      I2 = J + IZ(J)*4        
      DO 495 K = I1,I2,4        
      IF (IZ(K+2) .LT. 0) GO TO 495        
      DO 480 L = ISLOAD,LSLOAD        
      IF (IZ(K+2) .EQ. IZ(L)) GO TO 490        
  480 CONTINUE        
      GO TO 495        
  490 IZ(K+2) = L - ISLOAD        
  495 CONTINUE        
      J = I2 + 1        
      IF (J .LT. LLOADC) GO TO 470        
C        
C     OK - NOW WE CAN WRITE OUT GROUP 0 OF THE SOLN ITEM        
C        
  500 CALL CLOSE (GEOM4,REW)        
      RC = 3        
      CALL SFETCH (FSS,SOLN,SWRT,RC)        
      CALL SUWRT (Z(1),3*NS+5,1)        
      CALL SUWRT (NSLOAD,1,1)        
      IF (NSLOAD .GT. 0) CALL SUWRT (Z(ISLOAD),NSLOAD,1)        
      CALL SUWRT (0,0,EOG)        
C        
C     COPY THE FREQUENCY STEPS FROM PPF OR THE TIME STEPS FROM TOL      
C     FOR GROUP 1 OF THE SOLN ITEM        
C        
      ISTEP = ISLOAD        
      LSTEP = ISTEP + NSTEP - 1        
      IF (LSTEP .GT. LCORE) GO TO 9008        
      FILE = TOLPPF        
      CALL OPEN (*9001,TOLPPF,Z(BUF1),RDREW)        
      CALL FREAD (TOLPPF,TRL,2,0)        
      CALL FREAD (TOLPPF,Z(ISTEP),NSTEP,0)        
      CALL CLOSE (TOLPPF,REW)        
C        
      CALL SUWRT (Z(ISTEP),NSTEP,EOG)        
C        
C     IF ANY SCALAR LOADS EXIST CALCULATE THE SCALE FACTORS FOR EACH    
C     LOAD AND WRITE THEM TO THE SOF - 1 GROUP PER TIME OR FREQUENCY    
C     STEP        
C        
      IF (NSLOAD .EQ. 0) GO TO 800        
      IVEC = LSTEP + 1        
      LVEC = IVEC + NSLOAD - 1        
      IF (LVEC .GT. LCORE) GO TO 9008        
C        
C     CALL PRETAB TO READ IN THE REQUIRED TABLE DATA - FIRST MAKE A     
C     LIST OF REQUESTED TABLE IDS        
C        
      ITAB0 = LVEC + 1        
      IZ(ITAB0) = 0        
      ITAB = ITAB0 + 1        
      LTAB = ITAB  - 1        
      DO 570 J = ILOAD,LLOAD,8        
      IF (IZ(J+1) .GE. 0) GO TO 570        
      ITYPE = IZ(J)        
      GO TO (510,510,520,570), ITYPE        
  510 I1 = J + 2        
      I2 = J + 3        
      GO TO 530        
  520 I1 = J + 2        
      I2 = J + 2        
  530 DO 560 K = I1,I2        
      IF (IZ(K) .EQ.   0) GO TO 560        
      IF (LTAB .LT. ITAB) GO TO 550        
      DO 540 L = ITAB,LTAB        
      IF (IZ(L) .EQ. IZ(K)) GO TO 560        
  540 CONTINUE        
  550 LTAB = LTAB + 1        
      IF (LTAB .GT. LCORE) GO TO 9008        
      IZ(LTAB ) = IZ(K)        
      IZ(ITAB0) = IZ(ITAB0) + 1        
  560 CONTINUE        
  570 CONTINUE        
C        
      IF (IZ(ITAB0) .EQ. 0) GO TO 585        
      ITABD = LTAB + 1        
      CALL PRETAB (DIT,Z(ITABD),IZ(ITABD),Z(BUF1),LCORE-ITABD,LTABD,    
     1             Z(ITAB0),TABLOC)        
       LTABD = ITABD + LTABD - 1        
  585 CONTINUE        
C        
C     LOOP OVER EACH TIME OR FREQUENCY STEP        
C        
      DO 790 I = ISTEP,LSTEP        
C        
C     ZERO A VECTOR IN CORE FOR THE SCALE FACTORS        
C        
      DO 590 J = IVEC,LVEC        
  590 IZ(J) = 0        
C        
C     PASS THROUGH THE DLOAD DATA        
C        
      DO 780 J = IDLOAD,LDLOAD,2        
      IF (IZ(J+1) .GE. 0) GO TO 780        
C        
C     PROCESS THE TLOAD OR RLOAD DATA THIS DLOAD ENTRY POINTS TO        
C        
      ILD = -IZ(J+1)        
      IF (IZ(ILD+1) .GE. 0) GO TO 780        
      ITYPE = IZ(ILD  )        
      ILDC  =-IZ(ILD+1)        
C        
C     CALCULATE THE SCALE FACTOR FOR THE CARD FOR THIS TIME OR FREQUENCY
C     STEP        
C        
      GO TO (600,640,680,720), ITYPE        
C        
C     RLOAD1 DATA        
C        
  600 SCALE = 0.0        
      GO TO 760        
C        
C     RLOAD2 DATA        
C        
  640 SCALE = 0.0        
      GO TO 760        
C        
C     TLOAD1 DATA        
C        
  680 CALL TAB (IZ(ILD+2),Z(I),SCALE)        
      GO TO 760        
C        
C     TLOAD2 DATA        
C        
  720 SCALE = 0.0        
      TT    = Z(I) - Z(ILD+2)        
      IF (TT .EQ. 0.0) GO TO 730        
      IF (TT.LT.0.0 .OR. TT.GT.Z(ILD+3)) GO TO 760        
      SCALE = TT**Z(ILD+7)*EXP(Z(ILD+6)*TT)*COS(TWOPI*Z(ILD+4)*TT       
     1        + Z(ILD+5)*DEGRA)        
      GO TO 760        
  730 IF (Z(ILD+7) .NE. 0.0) GO TO 760        
      SCALE = COS(Z(ILD+5))        
C        
C     NOW APPLY THIS SCALE FACTOR TO EACH LOADC ENTRY.        
C     TOTAL SCALE FACTOR = T(R)LOAD FACTOR*DLOAD FACTOR*LOADC FACTOR    
C        
  760 CONTINUE        
      IF (SCALE .EQ. 0.0) GO TO 780        
      I1 = ILDC + 1        
      I2 = ILDC + IZ(ILDC)*4        
      DO 770 K = I1,I2,4        
      IF (IZ(K+2) .LT. 0) GO TO 770        
      IFAC = IVEC + IZ(K+2)        
      Z(IFAC) = Z(IFAC) + SCALE*Z(J)*Z(K+3)        
  770 CONTINUE        
C        
  780 CONTINUE        
C        
C     WRITE OUT THESE FACTORS TO THE NEXT GROUP OF THE SOF        
C        
      CALL SUWRT (Z(IVEC),NSLOAD,EOG)        
  790 CONTINUE        
C        
C     FINISHED        
C        
  800 CALL SUWRT (0,0,EOI)        
  810 CALL SOFCLS        
      RETURN        
C        
C     DIAGNOSTICS        
C        
 6315 FORMAT (A25,' 6315, RCOVR MODULE - SUBSTRUCTURE ',2A4,' IS NOT A',
     1        ' COMPONENT OF ',2A4, /32X,'LOAD SET',I9,' FOR THAT ',    
     2        'SUBSTRUCTURE WILL BE IGNORED IN CREATING', /32X,        
     3        'THE SOLN ITEM FOR FINAL SOLUTION STRUCTURE ',2A4)        
 6316 FORMAT (A25,' 6316, RCOVR MODULE IS UNABLE TO FIND LOAD SET ',I8, 
     1        ' FOR SUBSTRUCTURE ',2A4, /32X,'AMONG THOSE ON LODS.  ',  
     2        'IT WILL BE IGNORED IN CREATING THE SOLN ITEM FOR FINAL', 
     3        /32X,'SOLUTION STRUCTURE ',2A4)        
 9001 N = 1        
      GO TO 9100        
 9002 N = 2        
      GO TO 9100        
 9008 N = 8        
 9100 CALL MESAGE (N,FILE,NAME)        
 9200 CALL SOFCLS        
      IOPT = -1        
      CALL CLOSE (CASESS,REW)        
      CALL CLOSE (DLT,REW)        
      CALL CLOSE (GEOM4,REW)        
      CALL CLOSE (TOLPPF,REW)        
      CALL CLOSE (DIT,REW)        
      RETURN        
      END        
