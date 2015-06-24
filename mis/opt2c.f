      SUBROUTINE OPT2C (PT,IEL,IPR,PR,RR)        
C        
      LOGICAL         KPUN        
      INTEGER         B1,PT(2,1),COUNT,EID,EJECT,EST1,EST2,ETYP,HEADNG, 
     1                OUTTAP,IEL(1),IPR(1),IZ(100),NAME(2),NEOP(21),    
     2                SYSBUF,WDOPT(42),YCOR,ZCOR,MCB(7),IY(1),        
     3                TUBE,QUAD4,TRIM6,TRIA3        
      REAL            PR(1),RR(1),Y(1),BLK,PCD(2,21),G(2,10),PARM(8)    
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /BLANK / SKP1(2),COUNT,NCARD,SKP2,YCOR,B1,NELOP,NWDSE,     
     1                NWDSP,SKP3(2),EST1,SKP4,EST2,NELW,NPRW,NKLW,NTOTL,
     2                CONV        
      COMMON /OPTPW2/ ZCOR,Z(100)        
CZZ   COMMON /ZZOPT2/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /NAMES / NRD,NOEOR,NWRT,NWEOR        
      COMMON /SYSTEM/ SYSBUF,OUTTAP,SKPS1(6),NLPP,SKPS2(2),NLINES,      
     1                SKPS3(78),LPCH        
      COMMON /GPTA1 / NTYPES,LAST,INCR,NE(1)        
      EQUIVALENCE     (IZ(1),Z(1)),   (EID,Z(1)), (CORE(1),PARM(1),MAX),
     1                (G(1,1),IZ(100)), (G(1,10),IG10), (IPRNT,PARM(7)),
     2                (IY(1),Y(1),PARM(8))        
C     EQUIVALENT ARE  (IPR,PR)        
C        
C        
C     NOTE - CHANGE EQUIVALENCE IF AN ELEMENT TO BE OPTIMIZED HAS EST   
C     (EPT ONLY) ENTRIES BEYOND 100 WORDS.        
C        
      DATA   NAME   / 4H OPT, 4H2C   /        
      DATA   NMES   , YES,PLUS,BLK   /  0, 4HYES , 4H+AAA, 4H    /      
      DATA   TUBE   , QUAD4,TRIM6,TRIA3  / 3, 64 , 73, 83        /      
      DATA   PCD    /        
     1       4HPBAR,4H    , 4HPELB,4HOW  , 4HPIS2,4HD8  , 4HPQDM,4HEM  ,
     2       4HPQDM,4HEM1 , 4HPQDM,4HEM2 , 4HPQDP,4HLT  , 4HPQUA,4HD1  ,
     3       4HPQUA,4HD2  , 4HPROD,4H    , 4HPSHE,4HAR  , 4HPTRB,4HSC  ,
     4       4HPTRI,4HA1  , 4HPTRI,4HA2  , 4HPTRI,4HM6  , 4HPTRM,4HEM  ,
     5       4HPTRP,4HLT  , 4HPTUB,4HE   , 4HPSHE,4HLL  , 4HPSHE,4HLL  ,
     6       4HYYYY,4H    /        
C        
C     POINTERS TO WORDS ON EST TO CONVERT.  NEOP(ITP) IS POINTER INTO   
C     -WDOPT- ARRAY.  THE -WDOPT- FIRST ENTRY FOR THE ELEMENT IS THE    
C     NUMBER OF ENTRIES ON -EST- TO CONVERT FOLLOWED BY THE WORD NUMBERS
C     TO OPTIMIZE.        
C        
      DATA   NEOP   / 21,30,39,15,15,  15,27,17,15,1,  6,12,8,6,35,     
     1                 6,12, 4,41,41,   0/        
      DATA WDOPT /        
C        
C     ROD (A,J)        
     1  2,   5,6        
C        
C     TUBE (O.D.)        
     2, 1,   5        
C        
C     SHEAR(T), TRMEM(T), TRIA2(T)        
     3, 1,   7        
C        
C     TRIA1(T1,T2,I)        
     4, 3,   7,9,11        
C        
C     TRBSC(T2,I),TRPLT(T2,I)        
     5, 2,   7,9        
C        
C     QDMEM(T), QDMEM1(T), QDMEM2(T), QUAD2(T)        
     6, 1,   8        
C        
C     QUAD1(T1,T2,I)        
     7, 3,   8,10,12        
C        
C     BAR(A,J,I1,I2,I12)        
     8, 5,   17,18,19,20,33        
C        
C     QDPLT(T2,I)        
     9, 2,   8,10        
C        
C     ELBOW(A,J,I1,I2)        
     O, 4,   9,10,11,12        
C        
C     TRIM6(T1,T3,T5)        
     1, 3,   10,11,12        
C        
C     IS2D8(T)        
     2, 1,   13        
C        
C     QUAD4(T), TRIA3(T) PSHELL ONLY        
     3, 1,   14        
     * /        
C        
C     DETERMINE IF PROPTETY CARDS ARE TO BE PUNCHED        
C        
      KPUN = .FALSE.        
      KOUNT  = 0        
      HEADNG = 0        
      CH     = 1.0        
      ICP    = NTOTL        
      IF (COUNT.EQ.MAX .OR. CONV.EQ.2.0) KPUN =.TRUE.        
      IF (PARM(5) .NE. YES) KPUN = .FALSE.        
      IF (IPRNT .NE. 0) NLINES = NLPP        
      IE2 = 1        
      LEL = 0        
C        
C     READ EST1 ELEMENT TYPE        
C        
   10 CALL READ (*400,*360,EST1,ETYP,1,NOEOR,I)        
      CALL WRITE (EST2,ETYP,1,NOEOR)        
      ITP = IY(ETYP)        
      IF (ITP .EQ. 0) GO TO 20        
      IE1 = PT(1,ITP)        
C        
C     CHECK IF CORE ELEMENTS SKIPPED BECAUSE TYPE NOT ON EST        
C        
      IF (IE1 .GT. IE2) GO TO 60        
      IE2 = PT(1,ITP+1)        
      LEL = IEL(IE1)        
      IP1 = PT(2,ITP) - 1        
      IF (IE2 .GT. IE1) GO TO 40        
C        
C     SKIP THIS ELEMENT TYPE.  COPY RECORD TO EST2        
C        
   20 J = 1        
      N = ZCOR        
      CALL READ (*30,*30,EST1,Z,ZCOR,NOEOR,N)        
      J = 0        
   30 CALL WRITE (EST2,Z(1),N,J)        
      IF (J) 10,20,10        
C        
C     ELEMENT TYPE HAS CORE ENTRIES        
C        
   40 CONTINUE        
      NWDS = INCR*(ETYP-1) + 12        
      NWDS = NE(NWDS)        
      NPCARD = 0        
      IF (NWDS .GT. ZCOR) CALL MESAGE (-8,ZCOR,NAME)        
C        
C     READ ONE EST1 ELEMENT INTO CORE        
C        
   50 CALL READ (*350,*340,EST1,Z,NWDS,NOEOR,I)        
      IF (EID-LEL) 55,80,60        
C        
C     ELEMENT ID NOT IN CORE        
C        
   55 CALL WRITE (EST2,IZ(1),NWDS,NOEOR)        
      GO TO 50        
C        
C     ELEMENT IN CORE NOT ON EST        
C        
   60 I = EJECT(2)        
      IF (I .EQ. 0) GO TO 68        
      IF (COUNT.EQ.MAX .OR. CONV.EQ.2.0) GO TO 66        
      WRITE  (OUTTAP,65) COUNT        
   65 FORMAT (1H0,8X,45HPROPERTIES USED DURING INTERMEDIATE ITERATION,  
     1        I5, 10H BY OPTPR2/)        
      GO TO 68        
   66 WRITE  (OUTTAP,67) COUNT        
   67 FORMAT (1H0,8X,38HPROPERTIES USED DURING FINAL ITERATION,        
     1        I5, 10H BY OPTPR2/)        
   68 WRITE  (OUTTAP,70) SFM,ETYP,LEL,NAME        
   70 FORMAT (A25,' 2297, INCORRECT LOGIC FOR ELEMENT TYPE',I4,        
     1        ', ELEMENT',I8,2H (,2A4,2H).)        
      CALL MESAGE (-61,LEL,NAME)        
C        
C     ELEMENT IN CORE - CONVERT THE ENTRIES        
C        
   80 IPL = IEL(IE1+4) + IP1        
      IE1 = IE1 + NWDSE        
      LEL = IEL(IE1)        
      IF (IE1 .GT. IE2) LEL = 100000000        
      A = PR(IPL+4)        
      IF (A .GT. 0.0) GO TO 100        
      NMES = NMES + 1        
      IF (IPRNT.EQ.0 .OR. NMES.GT.100) GO TO 55        
      I = EJECT (2)        
      IF (I .EQ. 0) GO TO 88        
      IF (COUNT.EQ.MAX .OR. CONV.EQ.2.0) GO TO 84        
      WRITE (OUTTAP,65) COUNT        
      GO TO 88        
   84 WRITE  (OUTTAP,65) COUNT        
   88 WRITE  (OUTTAP,90) UIM,EID        
   90 FORMAT (A29,' 2305, OPTPR2 DETECTED NEGATIVE ALPHA FOR ELEMENT',  
     1        I8)        
      GO TO 55        
C        
  100 LOCF = NEOP(ITP)        
      J = LOCF        
      K = WDOPT(LOCF)        
      IRR = (IPL+NWDSP)/NWDSP        
      IF (ABS(PARM(3)-1.0) .LT. 0.0001) CH = 0.25*RR(IRR) + 0.75        
      C = (A/(A+(1.0-A)*PARM(3)))**CH        
      IF (ETYP .NE. TRIM6) GO TO 105        
C        
C     SPECIAL HANDLING FOR TRIM6        
C     IF THICKNESS-3 OR THICKNESS-5 IS ZERO, SET EQUAL TO THICKNESS-1   
C        
      DO 102 JJ = 1,K        
      J = J +1        
      L = WDOPT(J)        
      IF (JJ.NE.K .AND. ABS(Z(L+1)).LT.1.E-7) Z(L+1) = Z(L)        
      PC = Y(ICP+JJ)        
  102 Z(L) = Z(L)*(PC/(PC+(1.0-PC)*PARM(3)))        
      ICP = ICP + 4        
      GO TO 115        
C        
  105 DO 110 I = 1,K        
      J = J + 1        
      L = WDOPT(J)        
  110 Z(L) = C*Z(L)        
      IF (ETYP.NE.QUAD4 .AND. ETYP.NE.TRIA3) GO TO 112        
      Z(L+6) =  0.5*Z(L)        
      Z(L+7) = -0.5*Z(L)        
  112 IF (ETYP.EQ.TUBE .AND. Z(L).LT.2.*Z(L+1)) Z(L+1) = .5*Z(L)        
  115 CALL WRITE (EST2,Z(1),NWDS,NOEOR)        
C        
C     PUNCH AND/OR PRINT PROPERTY CARDS        
C        
      IF (IPRNT.EQ.0 .OR. IPR(IPL).LE.0) GO TO 50        
      GO TO (120,130,140,150,150,150,160,170,150,180,150,160,170,150,   
     1       180,150,160,190,170,170), ITP        
C        
C     PBAR        
C        
  120 K1 = 02222211        
      K2 = 22222222        
      K3 = 00000222        
      GO TO 250        
C        
C     PELBOW        
C        
  130 K1 = 02222211        
      K2 = 22222222        
      K3 = 22222222        
      GO TO 250        
C        
C     PIS2D8        
C        
  140 K1 = 00000211        
      GO TO 230        
C        
C     PQDMEM, PQDMEM1, PQDMEM2, PQUAD2, PSHEAR, PTRIA2, PTRMEM        
C        
  150 K1 = 00002211        
      GO TO 230        
C        
C     PQDPLT, PTRBSC, PTRPLT        
C        
  160 K1 = 22221211        
      GO TO 230        
C        
C     PQUAD1, PTRIA1, PSHELL        
C        
  170 K1 = 22121211        
      K2 = 00000022        
      GO TO 240        
C        
C     PROD, PTRIM6        
C        
  180 K1 = 00222211        
      GO TO 230        
C        
C     PTUBE        
C        
  190 K1 = 00022211        
C        
C     OUTPUT THE CARD(S)        
C        
  230 K2 = 0        
  240 K3 = 0        
  250 II = WDOPT(LOCF+1) - 4        
      KK = K1        
      G(1,1)   = PCD(1,ITP)        
      G(2,1)   = PCD(2,ITP)        
      IZ(II+2) = IPR(IPL)        
      IPR(IPL) =-IPR(IPL)        
  260 DO 270 I = 2,9        
      G(1,I) = BLK        
      G(2,I) = BLK        
      J = MOD(KK,10)        
      IF (J .EQ. 0) GO TO 270        
      IF (J .EQ. 1) CALL INT2A8 (*370,IZ(I+II),G(1,I))        
      IF (J .EQ. 2) CALL  FP2A8 (*380, Z(I+II),G(1,I))        
  270 KK = KK/10        
      G(1,10) = BLK        
      G(2,10) = BLK        
      IF (K2.EQ.0 .OR. (K2.EQ.-1 .AND. K3.EQ.0) .OR. K3.EQ.-1) GO TO 320
      KOUNT = KOUNT + 1        
      CALL INT2A8 (*375,KOUNT,G(1,10))        
      G(2,10) = G(1,10)        
      IG10 = KHRFN3(G(1,1),PLUS,-3,1)        
      IF (HEADNG .EQ. 0) GO TO 320        
  280 WRITE  (OUTTAP,290) G        
  290 FORMAT (5X,10(2A4,1X))        
      IF (.NOT.KPUN) GO TO 300        
      WRITE  (LPCH,295) G        
  295 FORMAT (20A4)        
      NCARD = NCARD + 1        
C        
C     SET UP FOR CONTINUATION CARD(S)        
C        
  300 IF (K2.EQ.0 .OR. (K2.EQ.-1 .AND. K3.EQ.0) .OR. K3.EQ.-1) GO TO 50 
      G(1,1) = G(1,10)        
      G(2,1) = G(2,10)        
      II     = II + 8        
      IF (K2) 315,50,310        
  310 KK = K2        
      K2 = -1        
      GO TO 260        
  315 KK = K3        
      K3 = -1        
      GO TO 260        
C        
C     PRINT HEADING        
C        
  320 HEADNG = 1        
      IF (EJECT(1) .EQ. 0) GO TO 280        
      IF (COUNT.EQ.MAX .OR. CONV.EQ.2.0) GO TO 330        
      WRITE (OUTTAP,65) COUNT        
      GO TO 280        
  330 WRITE (OUTTAP,67) COUNT        
      GO TO 280        
C        
C     EOR ON EST1        
C        
  340 CALL WRITE (EST2,0,0,NWEOR)        
      IF (IE1-IE2) 60,10,10        
C        
C     ERRORS        
C        
  350 CALL MESAGE (-2,EST1,NAME)        
  360 CALL MESAGE (-3,EST1,NAME)        
  370 J = 370        
      GO TO 390        
  375 J = 375        
      I = KOUNT        
      GO TO 390        
  380 J = 380        
  390 WRITE  (OUTTAP,395) J,G(1,1),G(2,1),I,II,IZ(I+II),Z(I+II)        
  395 FORMAT (16H0*** OPT2C/ERROR,I5,9X,5HELEM ,2A4,3I9,E10.4 )        
      GO TO 50        
C        
  400 CALL EOF (EST2)        
      MCB(1) = EST1        
      CALL RDTRL(MCB)        
      MCB(1) = EST2        
      CALL WRTTRL(MCB)        
      RETURN        
      END        
