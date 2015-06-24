      SUBROUTINE SYMBOL (X,Y,SYMX,OPT)        
C        
C     (X,Y) = POINT AT WHICH THE SYMBOLS ARE TO BE TYPED.        
C     SYMX  = SYMBOLS TO BE TYPED.        
C     OPT   = -1 TO INITIATE  THE TYPING MODE.        
C           = +1 TO TERMINATE THE TYPING MODE.        
C           =  0 TO TYPE THE SYMBOL.        
C        
      INTEGER SYM,SYMX(2),OPT,PLOTER,SYMBL        
      COMMON /PLTDAT/ MODEL,PLOTER        
      COMMON /SYMBLS/ NSYM, SYMBL(20,2)        
C        
      IF (OPT .EQ. 0) GO TO 110        
      CALL TIPE (0,0,0,0,0,OPT)        
      GO TO 200        
C        
  110 DO 150 I = 1,2        
      IF (SYMX(I) .LE. 0) GO TO 150        
      SYM = SYMX(I) - NSYM*((SYMX(I)-1)/NSYM)        
      SYM = SYMBL(SYM,PLOTER)        
      CALL TYPE10 (X,Y,0,SYM,0,0)        
      GO TO 150        
  150 CONTINUE        
C        
  200 RETURN        
      END        
