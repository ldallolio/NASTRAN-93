      SUBROUTINE VARIAN        
C        
C     VARIANCE ANALYSIS POST PROCESSOR MODULE        
C        
C     INPUTS--O1,O2,O3,O4,O5 OR EDT        
C        
C     OUTPUTS--O1O,O2O,O3O,O4O,O5O        
C        
C     PARAMETERS--OP--BCD'DER' OR 'VAR'        
C                 DELTA--REAL--DEFAULT=1.0        
C        
      LOGICAL TAPBIT        
      INTEGER IT1,IT2,IT3,IT4,IT5,OT1,OT2,OT3,OT4,OT5,NAME(2),MCB(7),   
     1        SYSBUF,SCR1,SCR2,DER,VAR,FILE,ITF(5),ITO(5),VARL(3),      
     2        DERL(3),VARAN(2),IZ(260)        
      REAL    Z(200)        
      COMMON /SYSTEM/ SYSBUF,SKIP(91),JRUN        
      COMMON /BLANK / IOP(2),DELTA        
CZZ   COMMON /ZZVARI/ RZ(1)        
      COMMON /ZZZZZZ/ RZ(1)        
      EQUIVALENCE (IT1,ITF(1)),(ITF(2),IT2) ,(ITF(3),IT3),(ITF(4),IT4), 
     1            (ITF(5),IT5),(ITO(1) ,OT1),(ITO(2),OT2),(ITO(3),OT3), 
     2            (ITO(4),OT4),(ITO(5),OT5) ,(Z(1),IZ(1),RZ(1))        
      DATA IT1,IT2,IT3,IT4,IT5,OT1,OT2,OT3,OT4,SCR1,OT5,INPT, SCR2 /    
     1     101,102,103,104,105,201,202,203,204,301 ,205,4HINPT,302 /    
      DATA  DER   , VAR   , DERL  ,                 NAME             /  
     1      4HDER , 4HVAR , 4HDERI, 4HVATI, 4HVE  , 4HVARI, 4HAN     /  
      DATA  VARL  ,                 IBLNK , VARAN   ,       MCB      /  
     1      4HVARI, 4HANCE, 4H    , 4H    , 4202, 42,       7*0      /  
C        
      IBUF1 = KORSZ(Z(1))-SYSBUF        
      IBUF2 = IBUF1-SYSBUF        
      IBUF3 = IBUF2-SYSBUF        
      NZ    = IBUF3-1        
      IF (NZ .LE. 0) CALL MESAGE(-8,0,NAME)        
      IF (.NOT.TAPBIT(INPT)) CALL MESAGE(-7,0,NAME)        
      CALL INT2A8 (*5,JRUN,IZ)        
    5 NJRUN=IZ(1)        
      NW=1        
      IF (IOP(1) .EQ. VAR) GO TO 300        
      IF (IOP(1) .NE. DER) RETURN        
C        
C     DERIVATIVES SECTION        
C        
      IF (JRUN .NE. 0) GO TO 30        
C        
C     COPY INPUT FILES TO INPT TAPE        
C        
      CALL OPEN (*900,INPT,IZ(IBUF1),1)        
      I=1        
      ASSIGN 20 TO IRET        
   10 FILE = ITF(I)        
      GO TO 700        
   20 I = I + 1        
      IF (I .LE. 5) GO TO 10        
      CALL CLOSE (INPT,2)        
      RETURN        
C        
C     COMPUTE DERIVATIVES  DJ = (OJ - O0)/DELTA        
C        
   30 CONTINUE        
      CALL OPEN (*900,INPT,IZ(IBUF1),0)        
C        
      DO 250 I = 1,5        
      IFOUND = 0        
      CALL FWDREC (*220,INPT)        
      CALL OPEN (*230,ITF(I),IZ(IBUF2),0)        
      CALL FWDREC (*910,ITF(I))        
      CALL GOPEN (ITO(I),IZ(IBUF3),1)        
      FILE = ITF(I)        
   40 ASSIGN 60 TO IRTN        
   50 CALL READ (*220,*920,INPT,IZ(1),146,1,IFLAG)        
      GO TO IRTN, (60,70)        
   60 CALL READ (*230,*920,FILE,IZ(147),146,1,IFLAG)        
C        
C     CHECK FOR MATCH ON SUBCASE        
C        
   70 IF (IZ(4)-IZ(150)) 80,100,90        
C        
C     NEED NEW INPT RECORD        
C        
   80 CALL FWDREC (*910,INPT)        
      ASSIGN 70 TO IRTN        
      GO TO 50        
C        
C     NEED NEW FILE RECORD        
C        
   90 CALL FWDREC (*910,FILE)        
      GO TO 60        
C        
C     CHECK FOR MATCH ON TIME, FREQ ETC        
C        
  100 IF (Z(5)-Z(151)) 80,110,90        
C        
C     CHECK FOR MATCH ON ELTYPE        
C        
  110 IF (IZ(3)-IZ(149)) 80,120,90        
C        
C     WE GOT ONE        
C        
  120 CONTINUE        
      IZ(257) = DERL(1)        
      IZ(258) = DERL(2)        
      IZ(259) = DERL(3)        
      IZ(260) = NJRUN        
      IFOUND  = 1 + IFOUND        
      CALL WRITE (ITO(I),IZ(147),146,1)        
      NREC=IZ(10)        
  130 ASSIGN 150 TO IRTN1        
  140 CALL READ (*910,*190,INPT,IZ(1),NREC,0,IFLAG)        
      ID1 = IZ(1)/10        
      GO TO IRTN1, (150,160)        
  150 CALL READ (*910,*200,FILE,IZ(NREC+1),NREC,0,IFLAG)        
      ID2 = IZ(NREC+1)/10        
      ASSIGN 160 TO IRTN1        
  160 IF (ID1-ID2) 140,170,150        
C        
C     POINT CHECKS        
C        
  170 CONTINUE        
      DO 180 J=2,NREC        
      ITYPE = NUMTYP(IZ(J))        
      IF (ITYPE.NE.2 .AND. ITYPE.NE.0) GO TO 180        
      Z(NREC+J) = (Z(NREC+J) - Z(J))/DELTA        
  180 CONTINUE        
      CALL WRITE (ITO(I),IZ(NREC+1),NREC,0)        
      GO TO 130        
C        
C     END OF DATA RECORD        
C        
  190 CALL FWDREC (*910,FILE)        
      GO TO 210        
  200 CALL FWDREC (*910,INPT)        
  210 CALL WRITE (ITO(I),0,0,1)        
      GO TO 40        
C        
C     EOF ON INPT        
C        
  220 GO TO 240        
C        
C     EOF ON FILE        
C        
  230 CALL SKPFIL (INPT,1)        
  240 CALL CLOSE (FILE,1)        
      CALL CLOSE (ITO(I),1)        
      MCB(1)=ITO(I)        
      MCB(2)=IFOUND        
      IF (IFOUND .NE. 0) CALL WRTTRL (MCB)        
  250 CONTINUE        
C        
C     SKIP OVER OLD DERIVATIVES        
C        
      I = 5*JRUN - 5        
      CALL SKPFIL (INPT,I)        
      CALL CLOSE (INPT,2)        
      CALL GOPEN (INPT,IZ(IBUF1),3)        
      I = 1        
      ASSIGN 270 TO IRET        
  260 FILE = ITO(I)        
      MCB(1) = FILE        
      CALL RDTRL (MCB)        
      IF (MCB(2) .NE. 0) GO TO 700        
      CALL EOF (INPT)        
  270 I = I + 1        
      IF (I .LE. 5) GO TO 260        
      CALL CLOSE (INPT,2)        
  280 RETURN        
C        
C     VARIANCE SECTION        
C        
  300 IF (JRUN .EQ. 0) RETURN        
C        
C     SEE IF VARIANCE IS TO BE COMPUTED        
C        
      CALL PRELOC (*280,IZ(IBUF1),IT1)        
      CALL LOCATE (*320,IZ(IBUF1),VARAN,IFLAG)        
C        
C     READ IN VARIANCES        
C        
      CALL READ (*910,*310,IT1,IZ(1),NZ,0,IFLAG)        
      CALL MESAGE (-8,0,NAME)        
  310 IF (IFLAG-1 .EQ. JRUN) GO TO 330        
  320 CALL CLOSE (IT1,1)        
      RETURN        
C        
C     SET UP FOR VARIANCES        
C        
  330 CALL CLOSE (IT1,1)        
      CALL OPEN (*900,INPT,IZ(IBUF1),0)        
      CALL SKPFIL (INPT,5)        
      IN1 = INPT        
      IO1 = SCR1        
      DO 620 I = 1,JRUN        
      IF (I .EQ. JRUN) GO TO 340        
      CALL OPEN (*900,IO1,IZ(IBUF2),1)        
  340 CONTINUE        
      IF (I .EQ. 1) GO TO 350        
      CALL OPEN (*900,IN1,IZ(IBUF3),0)        
  350 CONTINUE        
      DO 610 J = 1,5        
      IF (I .NE. JRUN) GO TO 360        
C        
C     FIX UP FOR WRITING ON OUTPUT FILES        
C        
      CALL OPEN (*610,ITO(J),IZ(IBUF2),1)        
      CALL FNAME (ITO(J),MCB)        
      CALL WRITE (ITO(J),MCB,2,1)        
      IFOUND = 0        
      IO1 = ITO(J)        
  360 CONTINUE        
      CALL FWDREC (*590,INPT)        
  370 ASSIGN 400 TO IRTN2        
  380 CALL READ (*600,*920,IN1,IZ(JRUN+1),146,1,IFLAG)        
      IF (I .NE. 1) GO TO 390        
      IZ(JRUN+111) = VARL(1)        
      IZ(JRUN+112) = VARL(2)        
      IZ(JRUN+113) = VARL(3)        
      IZ(JRUN+114) = IBLNK        
      GO TO 460        
C        
C     CHECK FOR MATCH        
C        
  390 GO TO IRTN2, (400,410)        
  400 CALL READ (*580,*920,INPT,IZ(JRUN+147),146,1,IFLAG)        
  410 IF (IZ(JRUN+4)-IZ(JRUN+150)) 420,440,430        
  420 CALL FWDREC (*910,IN1)        
      ASSIGN 410 TO IRTN2        
      GO TO 380        
  430 CALL FWDREC (*910,INPT)        
      GO TO 400        
  440 IF ( Z(JRUN+5)- Z(JRUN+151)) 420,450,430        
  450 IF (IZ(JRUN+3)-IZ(JRUN+149)) 420,460,430        
C        
C     MATCH        
C        
  460 CALL WRITE (IO1,IZ(JRUN+1),146,1)        
      NREC = IZ(JRUN+10)        
      M = JRUN + NREC        
  470 ASSIGN 490 TO IRTN3        
  480 CALL READ (*910,*550,IN1,IZ(JRUN+1),NREC,0,IFLAG)        
      IF (I .EQ. 1) GO TO 510        
      ID1 = IZ(JRUN+1)/10        
      GO TO IRTN3, (490,500)        
  490 CALL READ (*910,*560,INPT,IZ(M+1),NREC,0,IFLAG)        
      ID2 = IZ(M+1) /10        
      ASSIGN 500 TO IRTN3        
  500 IF (ID1-ID2) 480,510,490        
C        
C     POINT MATCH        
C        
  510 CONTINUE        
      IF (I .EQ. JRUN) IFOUND = IFOUND +1        
      DO 540 K =2,NREC        
      ITYPE = NUMTYP(IZ(JRUN+K))        
      IF (ITYPE.NE.2 .AND. ITYPE.NE.0) GO TO 540        
      IF (I .NE. 1) GO TO 520        
      Z(JRUN+K) = (Z(JRUN+K)*Z(1))**2        
      GO TO 530        
  520 Z(JRUN+K) = Z(JRUN+K) + (Z(M+K)*Z(I))**2        
  530 IF (I .NE. JRUN) GO TO 540        
      Z(JRUN+K) = SQRT(Z(JRUN+K))        
  540 CONTINUE        
      CALL WRITE (IO1,IZ(JRUN+1),NREC,0)        
      GO TO 470        
C        
C     END OF DATA ON IN1        
C        
  550 IF (I .EQ. 1) GO TO 570        
      CALL FWDREC (*910,INPT)        
      GO TO 570        
  560 CALL FWDREC (*910,IN1)        
  570 CALL WRITE (IO1,0,0,1)        
      GO TO 370        
C        
C     EOF ON INPT        
C        
  580 CALL SKPFIL (IN1,1)        
  590 CALL EOF (IO1)        
      IF (I .NE. JRUN) GO TO 610        
      CALL CLOSE (IO1,1)        
      MCB(1) = IO1        
      MCB(2) = IFOUND        
      CALL WRTTRL (MCB)        
      GO TO 610        
  600 IF (I .EQ. 1) GO TO 590        
      CALL SKPFIL (INPT,1)        
      GO TO 590        
  610 CONTINUE        
C        
C     SWITCH FILES        
C        
      IF (I .NE. JRUN) CALL CLOSE (IO1,1)        
      IF (I .NE.    1) CALL CLOSE (IN1,1)        
      J=IN1        
      IN1=IO1        
      IO1=J        
      IF (I .EQ. 1) IO1 = SCR2        
  620 CONTINUE        
      CALL CLOSE (INPT,1)        
      JRUN = 9999999        
      RETURN        
C        
C     INTERNAL ROUTINE TO COPY FILES        
C        
  700 CONTINUE        
      CALL OPEN (*730,FILE,IZ(IBUF2),0)        
  710 IEOR = 1        
      CALL READ (*730,*720,FILE,IZ(1),NZ,0,IREAD)        
      IEOR = 0        
  720 CALL WRITE (INPT,IZ(1),IREAD,IEOR)        
      GO TO 710        
  730 CALL EOF (INPT)        
      CALL CLOSE (FILE,1)        
      GO TO IRET, (20,270)        
C        
C     ERROR MESSAGES        
C        
  900 IP1 = -1        
      GO TO 930        
  910 IP1 = -2        
      GO TO 930        
  920 IP1 = -3        
  930 CALL MESAGE (IP1,FILE,NAME)        
      STOP        
      END        
