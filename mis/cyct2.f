      SUBROUTINE CYCT2        
C        
C     CYCT2 TRANSFORMS CYCLIC PROBLEMS BETWEEN SOLUTION VARIABLES AND   
C     THE CYCLIC COMPONENTS        
C        
C     INPUT DATA BLOCKS - CYCD    CYCLIC COMPONENT CONSTRAINT DATA      
C     INPUT DATA BLOCKS - KAA     MATRIX - STIFFNESS    MAY BE PURGED   
C     INPUT DATA BLOCKS - MAA     MATRIX - MASS         MAY BE PURGED   
C     INPUT DATA BLOCKS - V1I     MATRIX - LOAD OR DISP MAY BE PURGED   
C     INPUT DATA BLOCKS - V2I     MATRIX - EIGENVECTORS MAY BE PURGED   
C     INPUT DATA BLOCKS - LAMX    TABLE  - EIGENVALUES MUST EXIS IF V2I 
C        
C     OUTPUT DATA BLOCKS- KXX,MXX,V1O,V2O,LAMA        
C        
C     PARAMETERS - CDIR           INPUT,  BCD, (FORE OR BACK)        
C     PARAMETERS - NSEG           INPUT,  INTEGER,NUMBER OF SEGS        
C     PARAMETERS - KSEG           INPUT,  INTEGER,CYCLIC INDEX        
C     PARAMETERS - CYCSEQ         INPUT,  INTEGER,ALTERNATE=-1        
C     PARAMETERS - NLOAD          INPUT,  INTEGER,NUMBER OF LOAD COND   
C     PARAMETERS - NOGO           OUTPUT, INTEGER,-1 = ERROR        
C        
C     SCRATCH FILES (6)        
C        
C     DEFINITION OF VARIABLES        
C     LUA       LENGT OF A SET        
C     ITYP      TYPE (0=ROT, 1=DIH)        
C     IDIR      DIRECTION (0=FORE, 1=BACK)        
C     IFLAG     1 IMPLIES KSEG = 0 OR 2*KSEG = NSEG        
C     IPASS     1 IMPLIES SECOND PASS TRROUGH CYCD        
C     IGC       1 IMPLIES FIRST MATRIX TYPE (GC FOR ROT)        
C     ICS       1 IMPLIES FIRST COLUMN TYPE (COSINE FOR ROT)        
C        
C        
      INTEGER         CYCD,KAA,V1I,V2I,LAMX,V1O,V2O,CDIR(2),CYCSEQ,     
     1                SYSBUF,FILE,NAME(2),SCR1,SCR2,SCR3,MCB(14),FORE,  
     2                IZ(1),MCB1(7),MCB2(7),SCR4,SCR5,SCR6        
      DOUBLE PRECISION DZ,ARG,PI,COS,SIN,CONSTD        
      COMMON /UNPAKX/ ITC,IIK,JJK,INCR1        
      COMMON /ZBLPKX/ DZ(2),III        
      COMMON /PACKX / ITA,ITB,II,JJ,INCR        
CZZ   COMMON /ZZCYC2/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SYSTEM/ KSYSTM(65)        
      COMMON /CONDAD/ CONSTD(5)        
      COMMON /BLANK / CDIR,NSEG,KSEG,CYCSEQ,NLOAD,NOGO        
      EQUIVALENCE     (KSYSTM(1),SYSBUF),(KSYSTM(55),IPREC),        
     1                (CONSTD(1),PI    ),(KSEG,KINDEX),        
     2                (Z(1),IZ(1)),(MCB(1),MCB1(1)),(MCB(8),MCB2(1))    
      DATA    CYCD,KAA,MAA,V1I,V2I,LAMX,KXX,MXX,V1O,V2O,LAMA/        
     1        101 ,102,103,104,105,106 ,201,202,203,204,205 /        
      DATA    SCR1,SCR2,SCR3,SCR4,SCR5,SCR6  /        
     1        301 ,302 ,303 ,304 ,305 ,306   /        
      DATA    NAME,FORE /4HCYCT,4H2   ,4HFORE/        
C        
C        
CIBMNB 6/93
      CYCD = 101
      KAA  = 102
      MAA  = 103
      V1I  = 104
      V2I  = 105
      LAMX = 106
      KXX  = 201
      MXX  = 202
      V1O  = 203
      V2O  = 204
      LAMA = 205
      SCR1 = 301
      SCR2 = 302
      SCR3 = 303
      SCR4 = 304
      SCR5 = 305
      SCR6 = 306
CIBMNE
      NZ    = KORSZ(IZ)        
      NOGO  = 1        
      V1I   = 104        
      V1O   = 203        
      SCR3  = 303        
      MCB(1)= CYCD        
      CALL RDTRL (MCB)        
      LUA   = MCB(3)        
      ITYP  = MCB(2) - 1        
      IDIR  = 1        
      IF (CDIR(1) .EQ. FORE) IDIR = 0        
      NX    = NZ        
      IBUF1 = NZ - SYSBUF + 1        
      IBUF2 = IBUF1 - SYSBUF        
      IBUF3 = IBUF2 - SYSBUF        
      NZ    = IBUF3 - 1        
      IF (2*KSEG.GT.NSEG .OR. KSEG.LT.0 .OR. NSEG.LE.0) GO TO 640       
      J = 2        
      IF (MCB(5) .EQ. 4) J = 4        
      IF (NZ .LT. J*LUA) CALL MESAGE (-8,0,NAME)        
C        
C     PRODUCE GC AND GS MATRICES (ON SCR1 AND SCR2)        
C        
      ARG = FLOAT(KSEG)/FLOAT(NSEG)        
      ARG = ARG*PI        
      IF (ITYP .EQ. 0) ARG = 2.0D0*ARG        
C        
C     BRING IN CYCD        
C        
      CALL GOPEN (CYCD,IZ(IBUF1),0)        
      CALL FREAD (CYCD,IZ(1),LUA,1)        
      CALL CLOSE (CYCD,1)        
      CALL GOPEN (SCR1,IZ(IBUF1),1)        
C        
C     COMPUTE COS AND SIN        
C        
      IF (ITYP .EQ. 0) GO TO 30        
      IF (KSEG .EQ. 0) GO TO 10        
      IF (2*KSEG .EQ. NSEG) GO TO 20        
      GO TO 50        
   10 COS = 1.0        
      SIN = 0.0        
      GO TO 60        
   20 COS = 0.0        
      SIN = 1.0        
      GO TO 60        
   30 IF (KSEG   .EQ.    0) GO TO 10        
      IF (2*KSEG .EQ. NSEG) GO TO 40        
      GO TO 50        
   40 COS = -1.0        
      SIN = 0.0        
      GO TO 60        
   50 CONTINUE        
      COS = DCOS(ARG)        
      SIN = DSIN(ARG)        
   60 CONTINUE        
      IFLAG = 0        
      IF (KSEG.EQ.0 .OR. 2*KSEG.EQ.NSEG) IFLAG = 1        
      IF (ITYP.NE.0 .OR. IFLAG.EQ.0) CALL GOPEN (SCR2,IZ(IBUF2),1)      
      ITA = 2        
      ITB = 1        
      INCR= 1        
      II  = 1        
      JJ  = LUA        
      CALL MAKMCB (MCB1,SCR1,LUA,2,IPREC)        
      CALL MAKMCB (MCB2,SCR2,LUA,2,IPREC)        
      CALL WRTTRL (MCB1)        
      CALL WRTTRL (MCB2)        
      IPASS = 0        
      IF (ITYP .NE. 0) GO TO 200        
C        
C     BUILD ROTATIONAL MATRICES        
C        
   70 L  = 1        
   80 IF (IZ(L) .LT. 0) GO TO 190        
      MM = IZ(L)        
      IP = 1        
C        
C     FIRST BUILD GC        
C        
      IGC  = 1        
      FILE = SCR1        
C        
C     FIRST DO COSINE        
C        
      ICS = 1        
      IF (IPASS .NE. 0) ICS = 0        
C        
C     BUILD COLUMN        
C        
   90 CONTINUE        
      CALL BLDPK (2,IPREC,FILE,0,0)        
      IF (MM) 190,100,110        
C        
C     INTERIOR POINT        
C        
  100 CONTINUE        
      IF ((ICS.EQ.0 .AND. IGC.EQ.1) .OR. (ICS.EQ.1 .AND.  IGC.EQ.0))    
     1   GO TO 170        
      III   = L        
      DZ(1) = 1.0        
      CALL ZBLPKI        
      GO TO 170        
C        
C     SIDE 1 POINTS        
C        
  110 IF (ICS .NE. 0) GO TO 140        
C        
C     SINE COLUMN        
C        
      IF (IGC .NE. 0) GO TO 160        
C        
C     MATRIX IS GS        
C        
  120 IF (L .GT. MM) GO TO 130        
      DZ(1) = 1.0        
      III   = L        
      CALL ZBLPKI        
      DZ(1) = COS        
      III   = MM        
      CALL ZBLPKI        
      GO TO 170        
  130 III   = MM        
      DZ(1) = COS        
      CALL ZBLPKI        
      III   = L        
      DZ(1) = 1.0        
      CALL ZBLPKI        
      GO TO 170        
C        
C     COSINE COLUMN        
C        
  140 IF (IGC .NE. 0) GO TO 150        
C        
C     MATRIX IS GS        
C        
      III   = MM        
      DZ(1) =-SIN        
      CALL ZBLPKI        
      GO TO 170        
C        
C     MATRIX IS GC        
C        
  150 GO TO 120        
C        
C     MATRIX IS GC        
C        
  160 III   = MM        
      DZ(1) = SIN        
      CALL ZBLPKI        
      GO TO 170        
  170 CONTINUE        
      CALL BLDPKN (FILE,0,MCB(IP))        
      IF (CYCSEQ .EQ. 1) GO TO 180        
C        
C     NOW DO SINE COLUMN        
C        
      IF (ICS   .EQ. 0) GO TO 180        
      IF (IFLAG .EQ. 1) GO TO 190        
      ICS = 0        
      GO TO 90        
C        
C     NOW DO GS        
C        
  180 IF (IFLAG.EQ.1 .OR. IP.EQ.8) GO TO 190        
      IP  = 8        
      IGC = 0        
      ICS = 1        
      FILE = SCR2        
      GO TO 90        
C        
C     CONSIDER NEXT CYCD VALUE        
C        
  190 L = L + 1        
      IF (L .LE. LUA) GO TO 80        
C        
C     GONE THRU CYCD ONCE. DONE IF CYCSEQ = -1        
C        
      IF (CYCSEQ .EQ. -1) GO TO 400        
C        
C     MUST NOW DO SINE COLUMNS UNLESS IFLAG = 1        
C        
      IF (IPASS .EQ. 1) GO TO 400        
      IF (IFLAG .EQ. 1) GO TO 400        
      IPASS = 1        
      GO TO 70        
C        
C     BUILD DIHEDRAL MATRICES        
C        
  200 IPASS = 0        
  210 L     = 1        
  220 IP    = 1        
      IGC   = 1        
      FILE  = SCR1        
C        
C     FIRST DO S COLUMN        
C        
      ICS = 1        
      IF (IPASS .NE. 0) ICS = 0        
      MM  = IZ(L)        
      IF (MM.GT.0 .AND. IPASS.EQ.1) GO TO 390        
  230 CONTINUE        
      CALL BLDPK (2,IPREC,FILE,0,0)        
      IF (MM .GT. 0) GO TO 280        
C        
C     INTERIOR POINT        
C        
      IF (ICS .NE. 0) GO TO 260        
C        
C     A COLUMN        
C        
      IF (IGC .NE. 0) GO TO 250        
C        
C     MATRIX IS GA  - COLUMN IS A        
C        
  240 DZ(1) = 1.0        
      III = L        
      CALL ZBLPKI        
      GO TO 370        
C        
C     MATRIX IS GS - COLUMN IS A        
C        
  250 GO TO 370        
C        
C     SCOLUMN        
C        
  260 IF (IGC .NE. 0) GO TO 270        
C        
C     MATRIX IS GA - S COLUMN        
C        
      GO TO 370        
C        
C     MATRIX IS GS - COLUMN IS S        
C        
  270 GO TO 240        
C        
C     SIDE POINT        
C        
  280 IF (IGC .EQ. 0) GO TO 350        
C        
C     MATRIX IS GS        
C        
      GO TO (290,320,330,370), MM        
  290 III   = L        
  300 DZ(1) = COS        
  310 CALL ZBLPKI        
      GO TO 370        
  320 III   = L        
      DZ(1) =-SIN        
      GO TO 310        
  330 III   = L        
  340 DZ(1) = 1.0        
      GO TO 310        
C        
C     MATRIX IS GA        
C        
  350 III = L        
      GO TO (360,300,370,340), MM        
  360 DZ(1) = SIN        
      GO TO 310        
  370 CONTINUE        
      CALL BLDPKN (FILE,0,MCB(IP))        
      IF (CYCSEQ.EQ.1 .OR. MM.GT.0) GO TO 380        
C        
C     NOW DO A COLUMN        
C        
      IF (ICS .EQ. 0) GO TO 380        
      ICS = 0        
      GO TO 230        
C        
C     NOW DO GA        
C        
  380 IF (IP .EQ. 8) GO TO 390        
      IP  = 8        
      IGC = 0        
      FILE= SCR2        
      ICS = 1        
      GO TO 230        
C        
C     CONSIDER NEXT CYCD VALUE        
C        
  390 L = L + 1        
      IF (L .LE. LUA) GO TO 220        
C        
C     GONE THRU CYCD ONCE - DONE IF CYCSEQ = -1        
C        
      IF (CYCSEQ .EQ. -1) GO TO 400        
C        
C     NOW DO A COLUMNS        
C        
      IF (IPASS .EQ. 1) GO TO 400        
      IPASS = 1        
      GO TO 210        
C        
C     CLOSE UP SHOP        
C        
  400 CALL CLOSE (SCR1,1)        
      CALL CLOSE (SCR2,1)        
      CALL WRTTRL (MCB1)        
      IF (IFLAG.EQ.0 .OR. ITYP.NE.0) CALL WRTTRL (MCB2)        
      ITC = 1        
      IIK = 1        
      JJK = LUA        
      INCR1 = 1        
      IF (IDIR .NE. 0) GO TO 490        
C        
C     FORWARD TRANSFORMATIONS        
C        
C        
C     TRANSFORM MATRICES        
C        
      CALL CYCT2A (KAA,KXX,SCR1,SCR2,SCR3,SCR4,SCR5)        
      CALL CYCT2A (MAA,MXX,SCR1,SCR2,SCR3,SCR4,SCR5)        
C        
      MCB1(1) = KAA        
      MCB2(1) = MAA        
      CALL RDTRL (MCB1(1))        
      CALL RDTRL (MCB2(1))        
      IF (MCB1(5).GT.2 .OR.  MCB2(5).GT.2) GO TO 405        
      IF (MCB1(4).NE.6 .AND. MCB2(4).NE.6) GO TO 405        
      MCB1(1) = KXX        
      MCB2(1) = MXX        
      CALL RDTRL (MCB1(1))        
      CALL RDTRL (MCB2(1))        
      MCB1(4) = 6        
      MCB2(4) = 6        
      IF (MCB1(1) .GT. 0) CALL WRTTRL (MCB1(1))        
      IF (MCB2(1) .GT. 0) CALL WRTTRL (MCB2(1))        
C        
C     TRANSFORM LOADS        
C        
  405 MCB(1) = V1I        
      CALL RDTRL (MCB(1))        
      IF (MCB(1) .LE. 0) GO TO 460        
      ITC = MCB(5)        
      IF (ITC.EQ.4 .AND. NZ.LT.4*LUA) CALL MESAGE (-8,0,NAME)        
      CALL GOPEN (V1I,IZ(IBUF1),0)        
      CALL GOPEN (SCR3 ,IZ(IBUF2),1)        
      CALL GOPEN (SCR4,IZ(IBUF3),1)        
C        
C     COMPUTE NUMBER OF RECORDS TO SKIP        
C        
      CALL MAKMCB (MCB1,SCR3,LUA,2,MCB(5))        
      CALL MAKMCB (MCB2,SCR4,LUA,2,MCB(5))        
      IF (KSEG .EQ. 0) GO TO 420        
      NSKIP = NLOAD*KSEG*(ITYP+1)*2 - NLOAD*(ITYP+1)        
      FILE  = V1I        
      DO 410 I = 1,NSKIP        
      CALL FWDREC (*620,V1I)        
  410 CONTINUE        
  420 CONTINUE        
      CALL CYCT2B (V1I,SCR3,NLOAD,IZ,MCB1)        
      IF (ITYP  .EQ. 0) GO TO 430        
      IF (IFLAG .NE. 0) GO TO 430        
C        
C     COPY - PCA        
C        
      DO 421 J = 1,NLOAD        
      CALL FWDREC (*620,V1I)        
  421 CONTINUE        
      CALL CYCT2B (V1I,SCR3,NLOAD,IZ,MCB1)        
C        
C     NOW COPY ONTO PS        
C        
  430 IF (ITYP.EQ.0 .AND. IFLAG.NE.0) GO TO 440        
      CALL CYCT2B (V1I,SCR4,NLOAD,IZ,MCB2)        
      IF (IFLAG .NE. 0) GO TO 440        
      IF (ITYP  .EQ. 0) GO TO 440        
      CALL REWIND (V1I)        
      CALL FWDREC (*620,V1I)        
      NLPS = NSKIP + NLOAD        
      DO 431 J = 1,NLPS        
      CALL FWDREC (*620,V1I)        
  431 CONTINUE        
      ITC = -MCB(5)        
      CALL CYCT2B (V1I,SCR4,NLOAD,IZ,MCB2)        
      ITC = MCB(5)        
C        
C     DONE WITH COPY        
C        
  440 CALL CLOSE (V1I,1)        
      CALL CLOSE (SCR3,1)        
      CALL CLOSE (SCR4,1)        
      CALL WRTTRL (MCB1)        
      CALL WRTTRL (MCB2)        
      IF (IFLAG.NE.0 .AND. ITYP.EQ.0) GO TO 450        
      CALL SSG2B (SCR1,SCR3 ,0,SCR5,1,IPREC,1,V1O)        
      CALL SSG2B (SCR2,SCR4,SCR5,V1O,1,IPREC,1,SCR3)        
      GO TO 460        
C        
C     NO GS        
C        
  450 CALL SSG2B (SCR1,SCR3,0,V1O,1,IPREC,1,SCR5)        
C        
C     TRANSFORM EIGENVECTORS FORWARD        
C        
  460 IF (V1O .EQ. V2O) RETURN        
      MCB(1) = V2I        
      CALL RDTRL (MCB)        
      IF (MCB(1) .LE. 0) RETURN        
      ITC = MCB(5)        
      IF (ITC.EQ.4 .AND. NZ.LT.4*LUA) CALL MESAGE (-8,0,NAME)        
      IF (MOD(MCB(2),2).NE. 2) CALL MESAGE (-7,0,NAME)        
      IF (IFLAG.NE.1 .OR. ITYP.NE.0) GO TO 470        
C        
C     IN = OUT        
C        
      V1O  = V2O        
      SCR3 = V1I        
      GO TO 450        
  470 CALL GOPEN (V2I,IZ(IBUF1),0)        
      CALL GOPEN (SCR3,IZ(IBUF2),1)        
      CALL GOPEN (SCR4,IZ(IBUF3),1)        
      NCOPY = MCB(2)        
      CALL MAKMCB (MCB1,SCR3,LUA,2,MCB(5))        
      CALL MAKMCB (MCB2,SCR4,LUA,2,MCB(5))        
      DO 480 I = 1,NCOPY        
      FILE = SCR3        
      IP = 1        
      IF (MOD(I,2) .EQ. 0) IP = 8        
      IF (MOD(I,2) .EQ. 0) FILE = SCR4        
      CALL CYCT2B (V2I,FILE,1,IZ,MCB(IP))        
  480 CONTINUE        
      V1O = V2O        
      V1I = V2I        
      GO TO 440        
C        
C     DIRECTION IS BACK        
C        
  490 CONTINUE        
      MCB(1) = V1I        
      CALL RDTRL (MCB)        
      IF (MCB(1) .LE. 0) GO TO 560        
      IKS = MCB(3)        
      ITC = MCB(5)        
      IF (ITC.EQ.4 .AND. NZ.LT.4*LUA) CALL MESAGE (-8,0,NAME)        
C        
C     POSITION V1O        
C        
      MCB(1) = V1O        
      IF (KINDEX .EQ. 0) GO TO 495        
      CALL RDTRL (MCB)        
      IF (MCB(2) .GT. 0) GO TO 500        
  495 CONTINUE        
      CALL GOPEN  (V1O,IZ(IBUF1),1)        
      CALL CLOSE  (V1O,2)        
      CALL MAKMCB (MCB,V1O,LUA,2,MCB(5))        
      CALL WRTTRL (MCB)        
      GO TO 510        
  500 CONTINUE        
      CALL GOPEN  (V1O,IZ(IBUF1),0)        
      CALL SKPFIL (V1O,+1)        
      CALL SKPFIL (V1O,-1)        
      CALL CLOSE  (V1O,2)        
  510 CONTINUE        
      IF (ITYP .EQ. 0) GO TO 550        
C        
C     DISTRIBUTE UX1 AND UX2 FOR MULTIPLYS        
C        
      IF (IFLAG .EQ. 1) GO TO 550        
      CALL MAKMCB (MCB1,SCR3,IKS,2,MCB(5))        
      CALL MAKMCB (MCB2,SCR4,IKS,2,MCB(5))        
      CALL GOPEN  (V1I,IZ(IBUF1),0)        
      CALL GOPEN  (SCR3,IZ(IBUF2),1)        
      CALL GOPEN  (SCR4,IZ(IBUF3),1)        
      CALL CYCT2B (V1I,SCR3,NLOAD,IZ(1),MCB1)        
      CALL CYCT2B (V1I,SCR4,NLOAD,IZ(1),MCB2)        
      CALL CLOSE  (SCR3,1)        
      CALL WRTTRL (MCB1)        
      CALL CLOSE  (SCR4,1)        
      CALL WRTTRL (MCB2)        
      CALL CLOSE  (V1I,1)        
C        
C     COMPUTE UCS        
C        
  520 CALL SSG2B  (SCR1,SCR3,0,SCR5,0,IPREC,1,SCR6)        
      CALL GOPEN  (V1O,IZ(IBUF1),3)        
      CALL GOPEN  (SCR5,IZ(IBUF2),0)        
      MCB(1) = V1O        
      CALL RDTRL  (MCB(1))        
      CALL CYCT2B (SCR5,V1O,NLOAD,IZ(1),MCB)        
      IF (ITYP.EQ.0 .AND. IFLAG.NE.0) GO TO 540        
      CALL CLOSE  (V1O,2)        
      CALL CLOSE  (SCR5,1)        
      IF (ITYP.EQ.0 .OR. IFLAG.NE.0) GO TO 530        
C        
C     COMPUTE UCA        
C        
      CALL SSG2B  (SCR2,SCR4,0,SCR5,0,IPREC, 0,SCR6)        
      CALL GOPEN  (V1O,IZ(IBUF1),3)        
      CALL GOPEN  (SCR5,IZ(IBUF2),0)        
      CALL CYCT2B (SCR5,V1O,NLOAD,IZ(1),MCB)        
      CALL CLOSE  (V1O,2)        
      CALL CLOSE  (SCR5,1)        
C        
C     COMPUTE USS        
C        
      CALL SSG2B  (SCR1,SCR4,0,SCR5,0,IPREC,1,SCR6)        
      CALL GOPEN  (V1O,IZ(IBUF1),3)        
      CALL GOPEN  (SCR5,IZ(IBUF2),0)        
      CALL CYCT2B (SCR5,V1O,NLOAD,IZ(1),MCB)        
      CALL CLOSE  (SCR5,1)        
      CALL CLOSE  (V1O,2)        
C        
C     COMPUTE USA        
C        
  530 CONTINUE        
      CALL SSG2B  (SCR2,SCR3,0,SCR5,0,IPREC,1,SCR6)        
      CALL GOPEN  (V1O,IZ(IBUF1),3)        
      CALL GOPEN  (SCR5,IZ(IBUF2),0)        
      CALL CYCT2B (SCR5,V1O,NLOAD,IZ(1),MCB)        
  540 CONTINUE        
      CALL CLOSE  (SCR5,1)        
      CALL CLOSE  (V1O,1)        
      CALL WRTTRL (MCB)        
      GO TO 560        
C        
C     DO ROTATIONAL OR SPECIAL CASE DIH        
C        
  550 SCR3 = V1I        
      GO TO 520        
C        
C     SEE IF DONE        
C        
  560 MCB(1) = V2I        
      CALL RDTRL (MCB)        
      IF (MCB(1) .LE. 0) RETURN        
      SCR3 = 303        
      ITC  = MCB(5)        
      IF (ITC.EQ.4 .AND. NZ.LT.4*LUA) CALL MESAGE (-8,0,NAME)        
C        
C     NOW DO EIGENVECTORS        
C        
C        
C     COMPUTE NEW VECTORS        
C        
      CALL SSG2B (SCR1,V2I,0,SCR3,0,IPREC,1,SCR5)        
      IF (ITYP.EQ.0 .AND. IFLAG.EQ.1) GO TO 570        
      CALL SSG2B (SCR2,V2I,0,SCR4,0,IPREC,1,SCR5)        
  570 CONTINUE        
C        
C     POSITION FILES        
C        
C        
C      SET LAMA FLAG        
C        
      MCB(1) = LAMX        
      CALL RDTRL (MCB)        
      ILAMA  = 0        
      IF (MCB(1) .LE. 0) ILAMA = 1        
      CALL GOPEN (V2O,IZ(IBUF1),1)        
      IF (ILAMA .NE. 0) GO TO 571        
      CALL GOPEN (LAMA,IZ(IBUF2),1)        
      FILE = LAMX        
      CALL GOPEN (LAMX,IZ(IBUF3),0)        
      CALL READ  (*620,*630,LAMX,IZ(1),146,1,IFLAG)        
      CALL WRITE (LAMA,IZ(1),146,1)        
  571 CONTINUE        
      MCB(1) = V2I        
      CALL RDTRL (MCB)        
      NLOAD = MCB(2)        
      CALL MAKMCB (MCB,V2O,LUA,2,MCB(5))        
      IBUF4 = IBUF3 - SYSBUF        
      CALL GOPEN (SCR3,IZ(IBUF4),0)        
      IF (ITYP.EQ.0 .AND. IFLAG.EQ.1) GO TO 580        
      IBUF5 = IBUF4 - SYSBUF        
      CALL GOPEN (SCR4,IZ(IBUF5),0)        
  580 DO 590 I = 1,NLOAD        
      CALL CYCT2B (SCR3,V2O,1,IZ(1),MCB)        
      IF (ILAMA .NE. 0) GO TO 572        
      CALL READ  (*620,*630,LAMX,IZ(1),7,0,IFLAG)        
      CALL WRITE (LAMA,IZ(1),7,0)        
  572 CONTINUE        
      IF (ITYP.EQ.0 .AND. IFLAG.EQ.1) GO TO 590        
      IF (ILAMA .EQ. 0) CALL WRITE (LAMA,IZ(1),7,0)        
      CALL CYCT2B (SCR4,V2O,1,IZ(1),MCB)        
  590 CONTINUE        
      CALL WRTTRL (MCB)        
      CALL CLOSE  (V2O,1)        
      CALL CLOSE  (SCR3,1)        
      CALL CLOSE  (SCR4,1)        
      IF (ILAMA .NE. 0) GO TO 573        
      CALL CLOSE  (LAMA,1)        
      CALL CLOSE  (LAMX,1)        
      MCB(1) = LAMA        
      CALL WRTTRL (MCB)        
  573 CONTINUE        
C        
C     DONE        
C        
      RETURN        
C        
C     ERROR MESSAGES        
C        
C 600 IP1 = -1        
  610 CALL MESAGE (IP1,FILE,NAME)        
      GO TO 640        
  620 IP1 = -2        
      GO TO 610        
  630 IP1 = -3        
      GO TO 610        
  640 CALL MESAGE (7,0,NAME)        
      NOGO = -1        
      RETURN        
      END        
