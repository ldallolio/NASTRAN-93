      SUBROUTINE DRAW (GPLST,X,U,S,DISP,STEREO,OPCOR,BUF1)        
C        
      EXTERNAL        ANDF        
      LOGICAL         DISP        
      INTEGER         ANDF,AXIS(3),BUF1,DAXIS,ELSET,GP,GPLST(1),OPCOR,  
     1                PCON,PEDGE,PEN,PLABEL,PLTNUM,PORIG,PPEN,PRJECT,   
     2                PSET,PSHAPE,PSYMBL,PSYMM,PVECTR,STEREO,SYM(2),    
     3                SUCOR,V,VEC(3),COLOR,DEFM        
      REAL            A(3),MAXDEF,S(2,1),SIGN(3),U(3,1),X(3,1),MIN,MAX  
      DOUBLE PRECISION DR,SUM        
      COMMON /BLANK / NGP,SKP11(3),PLTNUM,NGPSET,SKP12(4),SKP21(2),ELSET
      COMMON /XXPARM/ PBUFSZ,CAMERA(5),NOPENS,PAPSIZ(2),PENPAP(27),     
     1                SCALE,OBJMOD,SKPSCL,MAXDEF,DEFMAX,AXES(3),        
     2                DAXIS(3),VIEW(9),VANTX1,R0,VANTX2(3),D0,VANTX3(2),
     3                PRJECT,VANTX4,ORIGX1(14),EDGE(11,4),XY(11,3),     
     4                NCNTR(51),ICNTVL,SKP24(24),COLOR        
      COMMON /PLTDAT/ MODEL,PLOTER,REG(4),AXYMAX(14)        
      COMMON /RSTXXX/ CSTM(3,3),MIN(3),MAX(3)        
      COMMON /DRWDAT/ PSET,PLABEL,PORIG,PPEN,PSHAPE,PSYMBL(2),PSYMM(6), 
     1                PVECTR,PCON,PEDGE        
C        
C     /DRWDAT/ CONTROLS THIS ROUTINE        
C     PLABEL - LABELING GRIDS, ELEMENTS...        
C            -N = NONE        
C             0 = GID             3 = EID          6 = EID + GID        
C             1 = GID + SPC       4 = EID + PID        
C             2 = UNDEFINED.      5 = UNDEFINED        
C     PSHAPE - WHICH SHAPE OR OUTLINE OPTION TO DRAW...        
C             1 = UNDEFORMED      2 = DEFORMED     3 = BOTH        
C     PSYMBL(2) - DRAW SYMBOLS IF PSYMBL(1).NE.0        
C     PSYMM (6) - SYMMETRY FLAGS...        
C           (1) = X AXIS SIGN CHANGE   (4) = X DEFORMATION SIGN CHANGE  
C           (2) = Y                    (5) = Y        
C           (3) = Z                    (6) = Z        
C     PVECTR - DEFORMATION VECTORS DRAWN (AS INTERPRETED BY INTVEC)...  
C             0 = NONE        
C             1 = X     4 = Z     7 = XYZ        10 = RY    13 = RXZ    
C             2 = Y     5 = ZX    8 = UNDEFINED  11 = RXY   14 = RYZ    
C             3 = XY    6 = ZY    9 = RX         12 = RZ    15 = RXYZ   
C             THE NEGATIVE OF ABOVE, DO NOT DRAW SHAPE.        
C    PCON   - NONZERO MEANS CONTOUR PLOT...        
C    PEDGE  - 0 = SHAPE DRAWN,        
C             1 = OUTLINE (BORDER) DRAWN ACCORDING TO PSHAPE-S        
C             2 = HIDDEN LINE PLOT        
C             3 = OFFSET PLOT        
C             4 THRU N = SHRINK PLOT, ELEMENT SHRUNK BY THIS PERCENT    
C             200 +  N = HIDDEN LINE AND SHRINK PLOT, N.GT.2        
C             100 = FILL ?        
C        
C     OPCOR = NO. OF OPEN CORE WORDS AVAILABLE IN S        
C             IT IS NOT A POINTER TO S, NOR A OPEN CORE ARRAY IN S      
C     BUF1  = BUFFER AVAILABLE AT END OF CORE W.R.T. GPLST = BUFSIZ+1   
C        
C     OPEN CORE /ZZPLOT/        
C     SETID NSETS NDOF      NGP 3*NGPSET 3*NGPSET  OPCOR   N        
C     -----+-----+----+----+---+--------+--------+-------+--+--+-+-+-+-+
C          !          N1   N2  I1 (X)   I2 (U)   I3  (S)   DEFBUF..BUF..
C          !(DEFLST)       !        
C                          !(GPLST)                      N=2*NGPSET     
C        
C     NGP    = TOTAL NO. OF GRID POINTS IN THE STRUCTURE        
C     NGPSET = NO. OF GRID POINTS USED IN CURRENT SET OF PLOTTING       
C     GPLST  = TABLE OF NGP IN LENGTH,        
C              GPLST(I) = 0 IF THIS I-TH GRID POINT IS NOT USED FOR THE 
C              CURRENT PLOT. OTHERWISE GPLST(I) IS NON-ZERO.        
C     X      = X,Y,Z COORDINATES OF THE GRID POINTS CORRESPONDING TO THE
C              NON-ZERO GRID POINTS IN THE GPLST TABLE        
C              TOTALLY, THERE ARE NGPSET GRID POINTS IN X        
C     U      = X,Y,Z DISPLACEMENTS, ARRANGED SIMILARLY TO X        
C     S      = SCRATCH AREA        
C        
      SCALEX = 1.0        
      IF (PRJECT .EQ. 3) SCALEX = OBJMOD        
C        
C     SETUP THE PLOTTER REGION.        
C        
      IF (PSYMM(1).LT.0 .OR. PSYMM(2).LT.0 .OR. PSYMM(3).LT.0) GO TO 10 
      REG(1) = EDGE(PORIG,1)*AXYMAX(1)        
      REG(2) = EDGE(PORIG,2)*AXYMAX(2)        
      REG(3) = EDGE(PORIG,3)*AXYMAX(1)        
      REG(4) = EDGE(PORIG,4)*AXYMAX(2)        
      GO TO 20        
   10 REG(1) = 0.0        
      REG(2) = 0.0        
      REG(3) = AXYMAX(1)        
      REG(4) = AXYMAX(2)        
C        
C     REDUCE THE GRID POINT CO-ORDINATES TO PLOT SIZE + TRANSLATE TO    
C     THE SELECTED ORIGIN.        
C        
   20 DO 40 I = 1,3        
      MIN(I) = +1.E+20        
      MAX(I) = -1.E+20        
      IF (PSYMM(I) .GE. 0) GO TO 40        
      DO 30 GP = 1,NGPSET        
   30 X(I,GP) = -X(I,GP)        
   40 CONTINUE        
      CALL PROCES (X)        
      CALL PERPEC (X,STEREO)        
      XORIG = XY(PORIG,1)        
      IF (STEREO .NE. 0) XORIG = XY(PORIG,2)        
      DO 50 GP = 1,NGPSET        
      X(2,GP) = SCALE*X(2,GP) - XORIG        
      X(3,GP) = SCALE*X(3,GP) - XY(PORIG,3)        
   50 CONTINUE        
C        
      IF (.NOT.DISP .OR. MAXDEF.EQ.0 .OR. DEFMAX.EQ.0) GO TO 120        
C        
C     PROCESS THE DEFORMATIONS.        
C     EXCHANGE AXES, REDUCE THE MAXIMUM DEFORMATION TO -MAXDEF-.        
C        
      DO 100 I = 1,3        
      AXIS(I) = IABS(DAXIS(I))        
      SIGN(I) = 1.        
      IF (DAXIS(I) .LT. 0) SIGN(I) = -1.        
  100 CONTINUE        
      I = AXIS(1)        
      J = AXIS(2)        
      K = AXIS(3)        
      D = MAXDEF/DEFMAX        
      DO 110 GP = 1,NGPSET        
      IF (PSYMM(4) .LT. 0) U(1,GP) = -U(1,GP)        
      IF (PSYMM(5) .LT. 0) U(2,GP) = -U(2,GP)        
      IF (PSYMM(6) .LT. 0) U(3,GP) = -U(3,GP)        
      A(1) = U(I,GP)        
      A(2) = U(J,GP)        
      A(3) = U(K,GP)        
      U(1,GP) = A(1)*SIGN(1)*D        
      U(2,GP) = A(2)*SIGN(2)*D        
      U(3,GP) = A(3)*SIGN(3)*D        
  110 CONTINUE        
      CALL INTVEC (PVECTR)        
C        
C     IF PVECTR .LT. 0 NO SHAPE WILL BE DRAWN        
C     ATTEMPT TO REMOVE DUPLICATE LINES        
C        
  120 IOPT = -1        
      SUCOR = 2*NGPSET + 1        
      IF (.NOT.DISP) SUCOR = 1        
C        
C     FIRST DETERMINE OPTIONS - UNIQUE LINES FOR PSHAPE=3 MAY ONLY BE   
C     FOR THE UNDERLAY.  ISHAPE = 0 MEANS DRAW THE SHAPE..        
C        
      ISHAPE = -1        
      LATER  = 0        
C     IF (PVECTR.LT.0 .OR. PEDGE.NE.0) GO TO 130        
      IF (PVECTR.LT.0 .OR. (PEDGE.NE.0 .AND. PEDGE.NE.3)) GO TO 130     
      ISHAPE = 0        
      IF (OPCOR .LT. NGPSET+NGP+1) GO TO 130        
      IOPT = 0        
      DEFM = 0        
      IF (PSHAPE .GE. 2) DEFM = 1        
      CALL LINEL (S(SUCOR,1),IPTL,OPCOR,IOPT,X,PPEN,DEFM,GPLST)        
      IF (PEDGE .EQ. 3) GO TO 500        
      IF (IPTL  .LE. 0) IOPT = -1        
      CALL BCKREC (ELSET)        
  130 IF (PSHAPE.EQ.2 .AND. DISP) GO TO 260        
C        
C     DRAW UNDEFORMED SHAPE (USE PEN1 + SYMBOL 2 IF THE DEFORMED SHAPE  
C     OR DEFORMATION VECTORS ARE ALSO TO BE DRAWN).        
C        
      PEN = PPEN        
      IF (DISP .AND. PSHAPE.GT.2) PEN = 1        
      IF (ISHAPE .EQ. 0)        
     1    CALL SHAPE (*500,GPLST,X,0,PEN,0,IOPT,IPTL,S(SUCOR,1),OPCOR)  
      IF (PEDGE .LT. 2) GO TO 140        
      CALL HDSURF (GPLST,X,0,PEN,0,NMAX,MAXSF,S(SUCOR,1),BUF1,PEDGE,    
     1             OPCOR)        
      IF (PEDGE.NE.2 .AND. PEDGE.LT.200) GO TO 140        
      CALL HDPLOT (GPLST,NMAX,MAXSF,OPCOR,BUF1)        
      GO TO 220        
  140 IF (PCON .EQ. 0) GO TO 200        
      IF (.NOT.DISP .OR. PSHAPE.LT.3) GO TO 210        
      LATER = PCON        
      PCON  = 0        
  200 IF (PEDGE.EQ.0 .OR. PEDGE.GE.2) GO TO 220        
  210 IOPT = -1        
      CALL CONTOR (GPLST,X,0,U,S(SUCOR,1),S(SUCOR,1),PEN,0,BUF1,OPCOR)  
      IF (PEDGE .EQ. 1) CALL BORDER (GPLST,X,0,S(SUCOR,1),0,BUF1,OPCOR) 
      IF (PEDGE.EQ.1 .OR. COLOR.GE.0) GO TO 220        
      CALL GOPEN (ELSET,GPLST(BUF1),0)        
      CALL SHAPE (*500,GPLST,X,0,1,0,IOPT,IPTL,S(SUCOR,1),OPCOR)        
  220 PCON = MAX0(PCON,LATER)        
      IF (PPEN .GT. 31)        
     1    CALL SHAPE (*500,GPLST,X,0,1,0,IOPT,IPTL,S(SUCOR,1),OPCOR)    
      IF (PSHAPE .EQ. 1) PCON = 0        
      IF (PSYMBL(1) .EQ. 0) GO TO 250        
      IF (DISP) GO TO 230        
      SYM(1) = PSYMBL(1)        
      SYM(2) = PSYMBL(2)        
      GO TO 240        
  230 SYM(1) = 2        
      SYM(2) = 0        
  240 CALL GPTSYM (GPLST,X,0,SYM,0)        
  250 IF (PLABEL .LT. 0) GO TO 260        
      I = PLABEL/3        
      IF (I .NE. 1) CALL GPTLBL (GPLST,X,0,0,BUF1)        
      IF (I .LT. 1) GO TO 260        
      CALL ELELBL (GPLST,X,0,0,BUF1)        
      CALL BCKREC (ELSET)        
  260 IF (.NOT.DISP .OR. MAXDEF.EQ.0.0 .OR. DEFMAX.EQ.0.0) GO TO 500    
      IF (PEDGE .EQ. 3) GO TO 500        
      IF (PSHAPE.LT.2 .AND. LATER.EQ.0) GO TO 350        
C        
C     ROTATE THE DEFORMATIONS        
C        
      DO 290 GP = 1,NGPSET        
      DO 280 J  = 1,3        
      SUM = CSTM(J,1)*U(1,GP) + CSTM(J,2)*U(2,GP) + CSTM(J,3)*U(3,GP)   
      IF (J .NE. 1) GO TO 270        
      IF (PRJECT .NE. 1) DR = D0/(R0-SCALEX*(X(1,GP)+SUM))        
      GO TO 280        
  270 IF (PRJECT .NE. 1) SUM = SCALEX*DR*SUM        
      S(J-1,GP) = X(J,GP) + SCALE*SUM        
  280 CONTINUE        
  290 CONTINUE        
C        
C     DRAW THE DEFORMED SHAPE        
C        
      IF (PVECTR .LT. 0) GO TO 300        
      PEN = PPEN        
      IF (PSHAPE.EQ.2 .AND. PVECTR.NE.0) PEN = 1        
      IF (PEDGE .EQ. 0)        
     1    CALL SHAPE (*500,GPLST,X,S,PEN,1,IOPT,IPTL,S(SUCOR,1),OPCOR)  
      IF (PEDGE .LT. 2) GO TO 300        
      CALL HDSURF (GPLST,X,S,PEN,1,NMAX,MAXSF,S(SUCOR,1),BUF1,PEDGE,    
     1             OPCOR)        
      IF (PEDGE.EQ.2 .OR. PEDGE.GT.200)        
     1    CALL HDPLOT (GPLST,NMAX,MAXSF,OPCOR,BUF1)        
  300 IF (PCON.EQ.0 .OR. PEDGE.EQ.2 .OR. PEDGE.GT.200) GO TO 310        
      IF (ICNTVL.LE. 9 .AND. PSHAPE.EQ.1) GO TO 310        
      IF (ICNTVL.GT.13 .AND. PSHAPE.EQ.1) GO TO 310        
      CALL CONTOR (GPLST,X,S,U,S(SUCOR,1),S(SUCOR,1),PEN,0,BUF1,OPCOR)  
      IF (PEDGE.EQ.1 .OR. COLOR.GE.0) GO TO 310        
      CALL GOPEN (ELSET,GPLST(BUF1),0)        
      CALL SHAPE (*500,GPLST,X,0,1,0,IOPT,IPTL,S(SUCOR,1),OPCOR)        
  310 IF (PEDGE.EQ.  1) CALL BORDER (GPLST,X,S,S(SUCOR,1),1,BUF1,OPCOR) 
      IF (PPEN .GT. 31)        
     1    CALL SHAPE  (*500,GPL,X,0,1,0,IOPT,IPTL,S(SUCOR,1),OPCOR)     
      IF (PSYMBL(1) .EQ. 0) GO TO 340        
      IF (PSHAPE.EQ.2 .AND. PVECTR.NE.0) GO TO 320        
      SYM(1) = PSYMBL(1)        
      SYM(2) = PSYMBL(2)        
      GO TO 330        
  320 SYM(1) = 2        
      SYM(2) = 0        
  330 CALL GPTSYM (GPLST,X,S,SYM,1)        
  340 IF (PLABEL.LT.0 .OR. PSHAPE.NE.2) GO TO 350        
      I = PLABEL/3        
      IF (I .NE. 1) CALL GPTLBL (GPLST,X,S,1,BUF1)        
      IF (I .LT. 1) GO TO 350        
      CALL ELELBL (GPLST,X,S,1,BUF1)        
  350 IF (PVECTR .EQ. 0) GO TO 500        
      PVECTR = IABS(PVECTR)        
C        
C     PROCESS THE DEFORMATION VECTORS        
C        
      IF (PVECTR .LE. 7) GO TO 410        
      NV = 1        
      VEC(1) = 0        
      VEC(2) = 0        
      VEC(3) = 0        
      DO 400 V = 1,3        
      IF (ANDF(PVECTR,2**(V-1)) .EQ. 0) GO TO 400        
      IF (AXIS(1).EQ.V) VEC(1) = 1        
      IF (AXIS(2).EQ.V) VEC(2) = 1        
      IF (AXIS(3).EQ.V) VEC(3) = 1        
  400 CONTINUE        
      GO TO 420        
  410 NV = 3        
  420 DO 490 V = 1,NV        
      IF (PVECTR .GT. 7) GO TO 440        
      IF (ANDF(PVECTR,2**(V-1)) .EQ. 0) GO TO 490        
      DO 430 I = 1,3        
      VEC(I) = 0        
      IF (AXIS(I) .EQ. V) VEC(I) = 1        
  430 CONTINUE        
C        
C     ROTATE THE DEFORMATIONS (VEC = VECTOR DIRECTION TO BE DRAWN)      
C        
  440 DO 480 GP = 1,NGPSET        
      DO 470 J  = 1,3        
      SUM = 0.D0        
      DO 450 I = 1,3        
      IF (VEC(I) .NE. 0) SUM = SUM + CSTM(J,I)*U(I,GP)        
  450 CONTINUE        
      IF (J .NE. 1) GO TO 460        
      IF (PRJECT .NE. 1) DR = D0/(R0-SCALEX*(X(1,GP)+SUM))        
      GO TO 470        
  460 IF (PRJECT .NE. 1) SUM = SCALEX*DR*SUM        
      S(J-1,GP) = X(J,GP) + SCALE*SUM        
  470 CONTINUE        
  480 CONTINUE        
C        
C     DRAW THE DEFORMATION VECTOR        
C        
      CALL DVECTR (GPLST,X,S,PPEN)        
      IF (PSYMBL(1).EQ.0 .OR. PSHAPE.EQ.3) GO TO 490        
      J = 0        
      IF (PSHAPE .EQ. 1) J = 1        
      CALL GPTSYM (GPLST,X,S,PSYMBL,J)        
  490 CONTINUE        
C        
C     END OF PLOT        
C        
C     IF NOT CONTOUR PLOT, CALL PCOORD TO DRAW A SMALL X-Y-Z COORDINATE 
C     TRIAD AT THE LOWER RIGHT CORNER OF PLOT        
C        
  500 IF (PEDGE .NE. 1) CALL PCOORD (PEN)        
      RETURN        
      END        
