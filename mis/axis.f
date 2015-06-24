      SUBROUTINE AXIS (XA,YA,XB,YB,PENX,OPT)        
C        
C     (XA,YA) = STARTING POINT OF THE AXIS.        
C     (XB,YB) = TERMINAL POINT OF THE AXIS.        
C     PENX    = PEN NUMBER OR LINE DENSITY (DEPENDS ON PLOTTER).        
C     OPT     = -1 TO INITIATE  THE LINE MODE.        
C             = +1 TO TERMINATE THE LINE MODE.        
C             =  0 TO DRAW A LINE.        
C        
      INTEGER PEN,PENX,OPT,PLOTER        
      COMMON /PLTDAT/ MODEL,PLOTER,SKPPLT(18),SKPA(6),NPENS        
C        
      IF (OPT .NE. 0) GO TO 110        
      PEN = MAX0(PENX,1)        
      PEN = PEN - NPENS*((PEN-1)/NPENS)        
C        
  110 CALL AXIS10 (XA,YA,XB,YB,PEN,OPT)        
      RETURN        
      END        
