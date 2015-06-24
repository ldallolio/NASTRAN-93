      SUBROUTINE LINE (X1,Y1,X2,Y2,PENX,OPT)        
C        
C     (X1,Y1) = STARTING POINT OF THE LINE        
C     (X2,Y2) = TERMINAL POINT OF THE LINE        
C     PENX    = PEN NUMBER OR DENSITY (DEPENDING ON PLOTTER)        
C     OPT     = -1  TO INITIATE  THE LINE MODE        
C             = +1  TO TERMINATE THE LINE MODE        
C             =  0  TO DRAW A LINE.        
C        
      INTEGER         PEN,PENX,OPT,PLOTER,TRA1,TRA2        
      REAL            XY(2,2),INFNTY        
      COMMON /PLTDAT/ MODEL,PLOTER,REG(2,2),SKPPLT(14),SKPA(6),NPENS    
      DATA    INFNTY/ 1.E+10 /        
C        
      IF (OPT .NE. 0) GO TO 220        
      SLP = INFNTY        
      B   = 0.        
      IF (X1 .EQ. X2) GO TO 10        
      SLP = (Y2-Y1)/(X2-X1)        
      B   =  Y1 - SLP*X1        
   10 XY(1,1) = X1        
      XY(2,1) = Y1        
      XY(1,2) = X2        
      XY(2,2) = Y2        
C        
C     CHECK TO SEE IF AN END OF THE LINE IS OUTSIDE THE PLOT REGION.    
C        
   20 DO 30 J = 1, 2        
      DO 30 I = 1,2        
      IF (XY(I,J).LT.REG(I,1) .OR. XY(I,J).GT.REG(I,2)) GO TO 40        
   30 CONTINUE        
      GO TO 210        
   40 DO 50 I = 1,2        
      IF (XY(I,1).LT.REG(I,1) .AND. XY(I,2).LT.REG(I,1)) GO TO 230      
      IF (XY(I,1).GT.REG(I,2) .AND. XY(I,2).GT.REG(I,2)) GO TO 230      
   50 CONTINUE        
C        
C     AN END IS OUTSIDE THE REGION, BUT NOT THE ENTIRE LINE. FIND THE   
C     END POINTS OF THE PORTION OF THE LINE WITHIN THE REGION.        
C        
      J = 1        
   60 I = 1        
   70 IF (XY(I,J) .GE. REG(I,1)) GO TO 130        
      ASSIGN 120 TO TRA2        
      GO TO (100,110), I        
  100 ASSIGN 350 TO TRA1        
      X = REG(1,1)        
      GO TO 300        
  110 ASSIGN 310 TO TRA1        
      Y = REG(2,1)        
      GO TO 300        
  120 XY(1,J) = X        
      XY(2,J) = Y        
C        
  130 IF (XY(I,J) .LE. REG(I,2)) GO TO 170        
      ASSIGN 160 TO TRA2        
      GO TO (140,150), I        
  140 ASSIGN 350 TO TRA1        
      X = REG(1,2)        
      GO TO 300        
  150 ASSIGN 310 TO TRA1        
      Y = REG(2,2)        
      GO TO 300        
  160 XY(1,J) = X        
      XY(2,J) = Y        
  170 I = I + 1        
      IF (I .EQ. 2) GO TO 70        
      J = J + 1        
      IF (J .EQ. 2) GO TO 60        
C        
C     MAKE SURE THE LINE SEGMENT IS WITHIN THE PLOT REGION.        
C        
      DO 200 J = 1,2        
      DO 200 I = 1,2        
      IF (XY(I,J)+.1.LT.REG(I,1) .OR. XY(I,J)-.1.GT.REG(I,2)) GO TO 400 
  200 CONTINUE        
C        
C     FIND THE CORRECT PEN NUMBER FOR THIS PLOTTER.        
C        
  210 PEN = PENX        
      PEN = PEN - NPENS*((PEN-1)/NPENS)        
C        
C     DRAW THE LINE.        
C        
  220 CALL LINE10 (XY(1,1),XY(2,1),XY(1,2),XY(2,2),PEN,OPT)        
      GO TO 400        
C        
  230 IFL = 0        
      DO 250 J = 1, 2        
      DO 240 M = 1, 2        
      IF (ABS(XY(I,J)-REG(I,M)) .GT. 1.0E-8) GO TO 240        
      IFL = 1        
      XY(I,J) = REG(I,M)        
  240 CONTINUE        
  250 CONTINUE        
      IF (IFL) 400,400,20        
C        
C        
C     CALCULATE THE EQUATION OF THE LINE TO BE DRAWN.        
C        
  300 GO TO TRA1, (310,350)        
C        
C     GIVEN Y, CALCULATE X.        
C        
  310 IF (SLP .EQ. INFNTY) GO TO 330        
      IF (SLP .EQ.     0.) GO TO 320        
      X = (Y-B)/SLP        
      GO TO 340        
  320 X = INFNTY        
      GO TO 340        
  330 X = X1        
  340 GO TO TRA2, (120,160)        
C        
C     GIVEN X, CALCULATE Y.        
C        
  350 IF (SLP .EQ. INFNTY) GO TO 370        
      IF (SLP .EQ.     0.) GO TO 360        
      Y = SLP*X + B        
      GO TO 380        
  360 Y = Y1        
      GO TO 380        
  370 Y = INFNTY        
  380 GO TO TRA2, (120,160)        
C        
  400 RETURN        
      END        
