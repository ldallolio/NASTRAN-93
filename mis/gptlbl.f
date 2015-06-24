      SUBROUTINE GPTLBL (GPLST,X,U,DEFORM,BUF)        
C        
      INTEGER         GPLST(1),DEFORM,EXGPID,REW,GP,GPT,GPX,BUF        
      REAL            X(3,1),U(2,1)        
      COMMON /BLANK / NGP,SKP1(9),SKP2(5),EXGPID        
      COMMON /PLTDAT/ SKPPLT(20),SKPA(3),CNTX        
      DATA    INPREW, REW / 0,1 /        
C        
      CALL GOPEN (EXGPID,GPLST(BUF),INPREW)        
      CALL TYPINT (0,0,0,0,0,-1)        
      DO 120 GP = 1,NGP        
      CALL FREAD (EXGPID,GPT,1,0)        
      CALL FREAD (EXGPID,GPX,1,0)        
      GPX = GPLST(GPX)        
C        
C     IF THE GRID POINT INDEX IS 0 (NOT IN SET) OR NEGATIVE (EXCLUDED), 
C     NEVER PUT A LABEL AT THAT GRID POINT.        
C        
      IF (GPX .LE. 0) GO TO 120        
C        
C     TYPE THE GRID POINT ID        
C        
      IF (DEFORM .NE. 0) GO TO 111        
      XX = X(2,GPX)        
      YY = X(3,GPX)        
      GO TO 112        
  111 XX = U(1,GPX)        
      YY = U(2,GPX)        
  112 CALL TYPINT (XX+CNTX,YY,1,GPT,0,0)        
  120 CONTINUE        
C        
      CALL CLOSE (EXGPID,REW)        
      CALL TYPINT (0,0,0,0,0,1)        
      RETURN        
      END        
