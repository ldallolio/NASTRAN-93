      SUBROUTINE GP4SP (IBUF1,IBUF2,IBUF3)        
C        
C     ROUTINE TO LOOK AT GPST TO ELIMINATE SINGULARITIES        
C        
C        
      EXTERNAL        ANDF  ,ORF   ,COMPLF,LSHIFT        
      INTEGER         ANDF  ,ORF   ,COMPLF,EQEXIN,GPST  ,OGPST ,SCR2  , 
     1                MCB(7),OMIT1 ,SPCSET,OGPST1(10)        
      DIMENSION       IPONTS(9)    ,JPONTS(9)    ,INDXMS(9)    ,        
     1                IEXCLD(9)    ,ISUBNM(2)    ,IWORD(8)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM   ,UWM   ,UIM   ,SFM        
      COMMON /BLANK / LUSET ,MPCF1 ,MPCF2 ,SINGLE,OMIT1 ,REACT ,NSKIP , 
     1                REPEAT,NOSETS,NOL   ,NOA   ,IDSUB ,IAUTSP        
      COMMON /GP4FIL/ DUM(3),IRGT        
      COMMON /GP4SPX/ MSKUM ,MSKUO ,MSKUR ,MSKUS ,MSKUL ,        
     1                MSKSNG,SPCSET,MPCSET,NAUTO ,IOGPST        
      COMMON /OUTPUT/ HEAD(1)        
      COMMON /SYSTEM/ ISYSBF,IOUTPT,JDUM(6),NLPP ,KDUM(2),LINE,        
     1                DD(78),IPUNCH        
      COMMON /UNPAKX/ ITYPOT,IIII  ,JJJJ  ,INCR        
CZZ   COMMON /ZZGP4X/ IZ(1)        
      COMMON /ZZZZZZ/ IZ(1)        
      DATA    EQEXIN, GPST, OGPST, SCR2 /103, 107, 205, 302/        
      DATA    ISUBNM /4HGP4S, 4HP       /        
      DATA    NCARD,  IERROR / 2*0      /        
      DATA    ISCR2,  IEQEXN / 2*-1     /        
C        
C        
      INDEX = IABS (IAUTSP)        
      IF (INDEX .GT. 2) GO TO 730        
      IF (INDEX.EQ.2 .AND. OMIT1.GT.0) INDEX = 3        
      MSKMS = ORF(MSKUM,MSKUS)        
      IF (IAUTSP .EQ. 0) GO TO 6        
      MULTI = 0        
      IF (MPCF1 .EQ. -1) GO TO 6        
      MSKIN = LSHIFT(1,12)        
      MSKXX = COMPLF(MSKIN)        
      CALL GOPEN (IRGT,IZ(IBUF1),0)        
      ITYPOT = 1        
      IIII   = 1        
      JJJJ   = 1        
      INCR   = 1        
      DO 4 I = 1,LUSET        
      CALL UNPACK (*4,IRGT,IDUM)        
      IF (ANDF(IZ(I),MSKMS) .NE. 0) GO TO 4        
      MULTI = 1        
      IZ(I) = ORF(IZ(I),MSKIN)        
    4 CONTINUE        
      CALL CLOSE (IRGT,1)        
    6 CONTINUE        
      CALL OPEN (*610,GPST,IZ(IBUF1),0)        
      IFILE = GPST        
      CALL FWDREC (*700,GPST)        
C        
   10 CALL READ (*480,*480,GPST,IORDR,1,0,IFLAG)        
      INITL = IORDR        
      IMS   = 0        
      ISPC  = 0        
      DO 20 I = 1, 9        
      INDXMS(I) = 0        
      IEXCLD(I) = 0        
      IPONTS(I) = 0        
      JPONTS(I) = 0        
   20 CONTINUE        
      CALL FREAD (GPST,NPTS,1,0)        
      CALL FREAD (GPST,IPONTS,NPTS,0)        
      IBASE = IPONTS(1)        
C        
C     SET VARIOUS FLAGS FOR THE SINGULARITIES        
C        
      DO 30 I = 1,NPTS        
      II = IPONTS(I)        
      J  = IZ(II)        
      IF (ANDF(J,MSKMS) .NE. 0) INDXMS(I) = 1        
      IF (IAUTSP        .EQ. 0) GO TO 30        
      IF (ANDF(J,MSKUO).NE.0 .AND. ANDF(J,MSKUL).NE.0) GO TO 740        
      IF (ANDF(J,MSKUO).NE.0 .AND. ANDF(J,MSKUR).NE.0) GO TO 740        
      IF (ANDF(J,MSKUR).NE.0 .AND. ANDF(J,MSKUL).NE.0) GO TO 740        
      IF (ANDF(J,MSKUR) .NE. 0) IEXCLD(I) = 1        
      IF (MULTI.EQ.0 .OR. INDXMS(I).NE.0) GO TO 25        
      IF (ANDF(J,MSKIN) .NE. 0) IEXCLD(I) = 1        
   25 IF (INDEX         .LT. 3) GO TO 30        
      IF (ANDF(J,MSKUL) .NE. 0) IEXCLD(I) = 1        
   30 CONTINUE        
C        
C     DETERMINE THE ORDER OF SINGULARITY        
C        
      IF (IORDR-2) 230,260,410        
C        
C        
   40 LOGIC = 100        
      IF (ISPC .GT. INITL) GO TO 750        
      IF (IEQEXN .EQ.   1) GO TO 60        
      IEQEXN = 1        
C        
C     BRING IN EQEXIN        
C        
      CALL GOPEN (EQEXIN,IZ(IBUF2),0)        
      CALL SKPREC (EQEXIN,1)        
      MCB(1) = EQEXIN        
      CALL RDTRL (MCB)        
      ICORE = LUSET + 2*(MCB(2)+1) - IBUF2        
      IF (ICORE .GE. 0) GO TO 720        
      IFILE = EQEXIN        
      CALL READ (*700,*50,EQEXIN,IZ(LUSET+1),IBUF2-LUSET,0,NEQEXN)      
      GO TO 720        
   50 CALL CLOSE (EQEXIN,1)        
      CALL SORT (0,0,2,2,IZ(LUSET+1),NEQEXN)        
      IZ(LUSET+NEQEXN+1) = 0        
      IZ(LUSET+NEQEXN+2) = 10*(LUSET+1)        
      NEQEXN = NEQEXN + 2        
C        
C     LOOK UP SIL IN EQEXIN        
C        
      ISTART = 2        
   60 KK = IBASE        
      DO 70 I = ISTART,NEQEXN,2        
      K = LUSET + I        
      ISIL = IZ(K)/10        
      IF (KK .LT. ISIL) GO TO 80        
   70 CONTINUE        
      LOGIC = 110        
      GO TO 750        
C        
C     PICK UP POINT ID AND TYPE (GRID OR SCALAR) FROM EQEXIN        
C        
   80 IGPID = IZ(K-3)        
      ISIL  = IZ(K-2)/10        
      ITYP  = IZ(K-2) - 10*ISIL        
      ISTART= I - 2        
      IF (ITYP .EQ. 1) GO TO 90        
C        
C     SCALAR POINT        
C        
      IORDR = 0        
      NPTS  = 0        
C        
C        
   90 IF (ISPC .EQ. 0) GO TO 140        
      LOGIC = 120        
      IF (ITYP.EQ.2 .AND. ISPC.GT.1) GO TO 750        
      IF (ITYP  .EQ. 2) JPONTS(1) = 0        
      IF (ISCR2 .EQ. 1) GO TO 100        
      ISCR2    = 1        
      IWORD(1) = SPCSET        
      IF (IWORD(1) .LE. 0) IWORD(1) = 1        
C        
C     INITIALIZE SCR2        
C        
      CALL GOPEN (SCR2,IZ(IBUF3),1)        
C        
C     WRITE AUTOMATICALLY GENERATED SPC1 DATA ON SCR2        
C        
  100 DO 130 I = 1,ISPC        
      IF (ITYP      .EQ. 2) GO TO 120        
      IF (JPONTS(I) .GT. 0) GO TO 110        
      LOGIC = 130        
      GO TO 750        
  110 JPONTS(I) = JPONTS(I) - ISIL + 1        
  120 CALL WRITE (SCR2,JPONTS(I),1,0)        
      CALL WRITE (SCR2,IGPID,    1,0)        
  130 CONTINUE        
      IF (ISPC+IMS .GE. INITL) GO TO 10        
C        
C        
  140 IF (IOGPST .EQ. 1) GO TO 150        
      IOGPST = 1        
C        
C     INITIALIZE OGPST        
C        
      CALL GOPEN (OGPST,IZ(IBUF2),1)        
      OGPST1( 1) = 0        
      OGPST1( 2) = 8        
      OGPST1( 3) = SPCSET        
      OGPST1( 4) = MPCSET        
      OGPST1(10) = 12        
      CALL WRITE (OGPST,OGPST1, 10,0)        
      CALL WRITE (OGPST,IZ,     40,0)        
      CALL WRITE (OGPST,HEAD(1),96,1)        
C        
C     PUT OUT ERROR RECORDS ON OGPST        
C        
  150 CALL WRITE (OGPST,IGPID,1,0)        
      CALL WRITE (OGPST,ITYP ,1,0)        
      CALL WRITE (OGPST,IORDR,1,0)        
      IORDR = IORDR + 1        
      IF (IORDR .EQ. 1) GO TO 180        
      DO 170 I = 1,NPTS        
      IF (IPONTS(I) .GT. 0) GO TO 160        
      LOGIC = 140        
      GO TO 750        
  160 IPONTS(I) = IPONTS(I) - ISIL + 1        
  170 CONTINUE        
      LOGIC = 150        
      GO TO (750,200,210,220), IORDR        
C        
C     SCALAR        
C        
  180 DO 190 I = 1,9        
  190 IPONTS(I) = 0        
      GO TO 220        
C        
C     FIRST ORDER OUTPUT        
C        
  200 IPONTS(4) = IPONTS(2)        
      IPONTS(7) = IPONTS(3)        
      IPONTS(2) = 0        
      IPONTS(3) = 0        
      IPONTS(5) = 0        
      IPONTS(6) = 0        
      IPONTS(8) = 0        
      IPONTS(9) = 0        
      GO TO 220        
C        
C     SECOND ORDER OUTPUT        
C        
  210 IPONTS(8) = IPONTS(6)        
      IPONTS(7) = IPONTS(5)        
      IPONTS(5) = IPONTS(4)        
      IPONTS(4) = IPONTS(3)        
      IPONTS(3) = 0        
      IPONTS(6) = 0        
      IPONTS(9) = 0        
C        
C     THIRD ORDER OUTPUT        
C        
  220 CALL WRITE (OGPST,IPONTS,9,0)        
      GO TO 10        
C        
C     FIRST ORDER SINGULARITY        
C        
  230 DO 240 I = 1,NPTS        
      IF (INDXMS(I) .NE. 0) GO TO 10        
  240 CONTINUE        
      IF (IAUTSP    .EQ. 0) GO TO 40        
      DO 250 I = 1,NPTS        
      IF (IEXCLD(I) .NE. 0) GO TO 250        
      II     = IPONTS(I)        
      IZ(II) = MSKSNG        
      NAUTO  = NAUTO + 1        
      ISPC   = ISPC  + 1        
      JPONTS(ISPC) = II        
      GO TO 40        
  250 CONTINUE        
      GO TO 40        
C        
C     SECOND ORDER SINGULARITY        
C        
  260 ILOOP = 1        
  270 DO 360 I = 1,NPTS,2        
      II = IPONTS(I)        
      IF (II        .EQ. 0) GO TO 310        
      IF (INDXMS(I) .NE. 0) GO TO 280        
      IF (ILOOP     .EQ. 1) GO TO 310        
      IF (IEXCLD(I) .NE. 0) GO TO 310        
      IZ(II) = MSKSNG        
      NAUTO  = NAUTO + 1        
      ISPC   = ISPC  + 1        
      JPONTS(ISPC) = II        
      GO TO 290        
  280 IMS   = IMS + 1        
  290 IORDR = 1        
      DO 300 III = 1,NPTS        
      IF (IPONTS(III) .EQ. II) IPONTS(III) = 0        
  300 CONTINUE        
      II = 0        
  310 JJ = IPONTS(I+1)        
      IF (JJ          .EQ. 0) GO TO 330        
      IF (INDXMS(I+1) .NE. 0) GO TO 320        
      IF (ILOOP       .EQ. 1) GO TO 360        
      IF (IEXCLD(I+1) .NE. 0) GO TO 360        
      IZ(JJ) = MSKSNG        
      NAUTO  = NAUTO + 1        
      ISPC   = ISPC  + 1        
      JPONTS(ISPC) = JJ        
      GO TO 330        
  320 IMS = IMS + 1        
  330 IF (II .NE. 0) GO TO 340        
      LOGIC = 160        
      IF (ISPC+IMS .LT. 2) GO TO 750        
      IF (ISPC     .EQ. 0) GO TO 10        
      GO TO 380        
  340 IORDR = 1        
      DO 350 III = 1, NPTS        
      IF (IPONTS(III) .EQ. JJ) IPONTS(III) = 0        
  350 CONTINUE        
  360 CONTINUE        
      IF (IAUTSP .EQ. 0) GO TO 370        
      IF (ILOOP  .EQ. 2) GO TO 370        
      ILOOP = 2        
      GO TO 270        
  370 IF (IORDR .EQ. 1) GO TO 380        
      IF (IORDR .EQ. 2) GO TO 40        
      LOGIC = 170        
      GO TO 750        
  380 IOK = 0        
      DO 400 I = 1, NPTS        
      IF (IPONTS(I) .EQ. 0) GO TO 400        
      IOK = IOK + 1        
      IPONTS(IOK) = IPONTS(I)        
      IF (IOK .NE.  I) IPONTS(I) = 0        
      IF (I .EQ. NPTS) GO TO 400        
      II = I + 1        
      DO 390 J = II,NPTS        
      IF (IPONTS(J) .EQ. 0) GO TO 390        
      IF (IPONTS(J) .EQ. IPONTS(IOK)) IPONTS(J) = 0        
  390 CONTINUE        
  400 CONTINUE        
      NPTS = IOK        
      IF (NPTS .EQ. 0) GO TO 40        
C        
      LOGIC = 180        
      IF (NPTS .GT. 2) GO TO 750        
      LOGIC = 190        
      IF (IPONTS(1) .EQ. IPONTS(2)) GO TO 750        
      GO TO 40        
C        
C     THIRD ORDER SINGULARITY        
C        
  410 IOK = 0        
      DO 450 I = 1,NPTS        
      IF (INDXMS(I) .NE. 0) GO TO 430        
      IF (IAUTSP    .EQ. 0) GO TO 420        
      IF (IEXCLD(I) .NE. 0) GO TO 420        
      II     = IPONTS(I)        
      IZ(II) = MSKSNG        
      NAUTO  = NAUTO + 1        
      ISPC   = ISPC  + 1        
      JPONTS(ISPC) = II        
      GO TO 440        
  420 IOK = 1        
      GO TO 450        
  430 IMS   = IMS   + 1        
  440 IORDR = IORDR - 1        
      IPONTS(I) = 0        
  450 CONTINUE        
      IF (IOK .EQ. 1) GO TO 460        
      LOGIC = 200        
      IF (ISPC+IMS .NE. 3) GO TO 750        
      IF (ISPC     .EQ. 0) GO TO 10        
      GO TO 40        
  460 IOK = 0        
      DO 470 I = 1,NPTS        
      IF (IPONTS(I) .EQ. 0) GO TO 470        
      IOK = IOK + 1        
      IPONTS(IOK) = IPONTS(I)        
      IF (IOK .NE. I) IPONTS(I) = 0        
  470 CONTINUE        
      NPTS = IOK        
      GO TO 40        
C        
  480 CALL CLOSE (GPST,1)        
      IF (IOGPST .NE. 1) GO TO 490        
      CALL CLOSE (OGPST,1)        
      IF (IERROR .NE. 0) GO TO 490        
      CALL MAKMCB (OGPST1,OGPST,0,0,0)        
      OGPST1(2) = 8        
      CALL WRTTRL (OGPST1)        
  490 IF (IAUTSP .EQ. 0) GO TO 610        
      IF (NAUTO  .GT. 0) GO TO 500        
      LOGIC = 210        
      IF (ISCR2  .EQ. 1) GO TO 750        
      IF (IOGPST.EQ.1 .AND. INDEX.LT.3) WRITE (IOUTPT,810) UWM        
      IF (IOGPST.EQ.1 .AND. INDEX.EQ.3) WRITE (IOUTPT,815) UWM        
      GO TO 610        
  500 LOGIC = 220        
      IF (ISCR2 .NE. 1) GO TO 750        
      CALL WRITE (SCR2,0,0,1)        
      CALL CLOSE (SCR2,1)        
      IF (IERROR .NE. 0) GO TO 610        
      IF (IOGPST .NE. 1) WRITE (IOUTPT,800) UIM        
      IF (IOGPST .EQ. 1) WRITE (IOUTPT,805) UIM        
      IF (IOGPST.EQ.1 .AND. INDEX.LT.3) WRITE (IOUTPT,820) UWM        
      IF (IOGPST.EQ.1 .AND. INDEX.EQ.3) WRITE (IOUTPT,825) UWM        
C        
C     PRINT OUT AND, IF REQUESTED, PUNCH OUT        
C     AUTOMATICALLY GENERATED SPC DATA CARDS        
C        
      CALL GOPEN (SCR2,IZ(IBUF3),0)        
      IFILE = SCR2        
      CALL READ (*700,*510,SCR2,IZ(LUSET+1),IBUF3-LUSET,0,IFLAG)        
      ICORE = LUSET + 2*NAUTO - IBUF3        
      GO TO 720        
  510 LOGIC = 230        
      IF (IFLAG .NE. 2*NAUTO) GO TO 750        
      CALL SORT (0,0,2,1,IZ(LUSET+1),IFLAG)        
      I    = LUSET + 1        
      IOLD = -1        
      IST  = I        
  520 J = 0        
  530 IF (I .GT. LUSET+IFLAG) GO TO 540        
      IF (IOLD.GE.0 .AND. IZ(I).NE.IOLD) GO TO 540        
      IOLD = IZ(I)        
      J = J + 2        
      I = I + 2        
      GO TO 530        
  540 CALL SORT (0,0,2,-2,IZ(IST),J)        
      IF (I .GT. LUSET+IFLAG) GO TO 550        
      IOLD = IZ(I)        
      IST  = I        
      GO TO 520        
C        
  550 I = LUSET + 1        
      IOLD = -1        
      CALL PAGE1        
      WRITE (IOUTPT,830)        
      LINE = LINE + 6        
  560 II = 2        
      DO 570 J = 1,6        
      IF (I .GT. LUSET+IFLAG) GO TO 580        
      IF (IOLD.GE.0 .AND. IZ(I).NE.IOLD) GO TO 580        
      IOLD = IZ(I)        
      IWORD(II+1) = IZ(I+1)        
      II = II + 1        
      I  = I  + 2        
  570 CONTINUE        
  580 IWORD(2) = IOLD        
      IF (LINE .LE. NLPP) GO TO 590        
      CALL PAGE1        
      WRITE (IOUTPT,830)        
      LINE = LINE + 6        
  590 NCARD = NCARD + 1        
      WRITE (IOUTPT,840) NCARD,(IWORD(J),J=1,II)        
      LINE = LINE + 1        
      IF (IAUTSP .LT. 0) WRITE (IPUNCH,850) (IWORD(J),J=1,II)        
      IF (I .GT. LUSET+IFLAG) GO TO 600        
      IOLD = IZ(I)        
      GO TO 560        
  600 CALL CLOSE (SCR2,1)        
  610 IF (IAUTSP.EQ.0 .OR. MULTI.EQ.0) RETURN        
      DO 620 I = 1,LUSET        
      IZ(I) = ANDF(IZ(I),MSKXX)        
  620 CONTINUE        
      RETURN        
C        
C     ERROR MESSAGES        
C        
  700 NUM = -2        
  710 CALL MESAGE (NUM,IFILE,ISUBNM)        
  720 NUM = -8        
      IFILE = ICORE        
      GO TO 710        
  730 IERROR = 1        
      WRITE (IOUTPT,870) UWM        
      GO TO 480        
  740 IERROR = 2        
      WRITE (IOUTPT,880) UWM        
      GO TO 480        
  750 WRITE (IOUTPT,860) SFM,LOGIC        
      CALL MESAGE (-61,0,0)        
C        
  800 FORMAT (A29,' 2435, AT USER''S REQUEST, ALL POTENTIAL ',        
     1        'SINGULARITIES HAVE BEEN REMOVED BY THE', /5X,        
     2        'APPLICATION OF SINGLE POINT CONSTRAINTS.  REFER TO PRINT'
     3,       'OUT OF AUTOMATICALLY GENERATED SPC1 CARDS FOR DETAILS.') 
  805 FORMAT (A29,' 2436, AT USER''S REQUEST, ONE OR MORE POTENTIAL ',  
     1        'SINGULARITIES HAVE BEEN REMOVED BY THE', /5X,        
     2        'APPLICATION OF SINGLE POINT CONSTRAINTS.  REFER TO PRINT'
     3,       'OUT OF AUTOMATICALLY GENERATED SPC1 CARDS FOR DETAILS.') 
  810 FORMAT (A25,' 2437A, IN SPITE OF THE USER''S REQUEST, NONE OF ',  
     1        'THE POTENTIAL SINGULARITIES HAS BEEN REMOVED', /5X,      
     2        'BECAUSE OF THG PRESENCE OF SUPORT CARDS AND/OR MULTI',   
     3        'POINT CONSTRAINTS OR RIGID ELEMENTS.', /5X,        
     4        'REFER TO THE GRID POINT SINGULARITY TABLE FOR DETAILS.') 
  815 FORMAT (A25,' 2437A, IN SPITE OF THE USER''S REQUEST, NONE OF ',  
     1        'THE POTENTIAL SINGULARITIES HAS BEEN REMOVED', /5X,      
     2        'BECAUSE OF THG PRESENCE OF SUPORT CARDS AND/OR MULTI',   
     3        'POINT CONSTRAINTS OR RIGID ELEMENTS', /5X,'OR BECAUSE ', 
     4        'THE SINGULARITIES ARE NOT PART OF THE OMIT SET (O-SET) ',
     5        'DEGREES OF FREEDOM.', /5X,        
     2        'REFER TO THE GRID POINT SINGULARITY TABLE FOR DETAILS.') 
  820 FORMAT (A25,' 2437, ONE OR MORE POTENTIAL SINGULARITIES HAVE NOT',
     1        ' BEEN REMOVED', /5X,'BECAUSE OF THG PRESENCE OF SUPORT ',
     2        'CARDS AND/OR MULTIPOINT CONSTRAINTS OR RIGID ELEMENTS.', 
     2    /5X,'REFER TO THE GRID POINT SINGULARITY TABLE FOR DETAILS.') 
  825 FORMAT (A25,' 2437, ONE OR MORE POTENTIAL SINGULARITIES HAVE NOT',
     1        ' BEEN REMOVED', /5X,'BECAUSE OF THG PRESENCE OF SUPORT ',
     2        'CARDS AND/OR MULTIPOINT CONSTRAINTS OR RIGID ELEMENTS',  
     3        /5X,'OR BECAUSE THE SINGULARITIES ARE NOT PART OF THE ',  
     4        'OMIT SET (O-SET) DEGREES OF FREEDOM.', /5X,        
     2        'REFER TO THE GRID POINT SINGULARITY TABLE FOR DETAILS.') 
  830 FORMAT (//32X, 'A U T O M A T I C A L L Y   ',        
     1               'G E N E R A T E D   ',        
     2               'S P C 1   C A R D S', /,        
     3        16X, 'CARD ',8X, /,        
     4        16X, 'COUNT',8X,        
     5             '---1--- +++2+++ ---3--- +++4+++ ---5--- ',        
     6             '+++6+++ ---7--- +++8+++ ---9--- +++10+++',/)        
C    5             '.   1  ..   2  ..   3  ..   4  ..   5  .',        
C    6             '.   6  ..   7  ..   8  ..   9  ..  10  .',/)        
  840 FORMAT (15X, I5, '-', 8X, 'SPC1    ',8I8)        
  850 FORMAT (                  'SPC1    ',8I8)        
  860 FORMAT (A25,' 2438, LOGIC ERROR NO.',I4,        
     1       ' IN SUBROUTINE GP4SP IN MODULE GP4')        
  870 FORMAT (A25,' 2439, ILLEGAL VALUE INPUT FOR PARAMETER AUTOSPC - ',
     1       'SINGULARITY PROCESSING SKIPPED IN MODULE GP4')        
  880 FORMAT (A25,' 2440, SINGULARITY PROCESSING SKIPPED IN MODULE GP4',
     1       ' BECAUSE OF INCONSISTENT SET DEFINITION')        
C        
      RETURN        
      END        
