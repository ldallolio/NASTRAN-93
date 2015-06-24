      SUBROUTINE XYCHAR (ROW,COL,CHAR)        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF,COMPLF        
      LOGICAL         PASS,EXCEED        
      DIMENSION       MASK(4)        
      COMMON /MACHIN/ MACH        
      COMMON /SYSTEM/ DUM(38),BPERCH,BPERWD        
      COMMON /XYPPPP/ IFRAME,TITLEC(32),TITLEL(14),TITLER(14),        
     1                XTITLE(32),ID(300),MAXPLT,XMIN,XINC,EXCEED,       
     2                I123,MAXROW        
CZZ   COMMON /ZZXYTR/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      DATA    PASS  / .FALSE. /        
C        
      IF (ROW .LE. MAXROW) GO TO 1        
      EXCEED = .TRUE.        
      RETURN        
C        
    1 IF (COL.GT.119 .OR. COL.LT.1 .OR. ROW.LT.1) RETURN        
C        
C     CHAR COMING IN IS ASSUMED LEFT ADJUSTED        
C        
      IF (PASS) GO TO 20        
      PASS = .TRUE.        
C        
C     SET UP MASKS FIRST TIME THROUGH AFTER LOADING        
C        
      N = 2**BPERCH  -  1        
      ISHIFT = BPERWD - BPERCH        
      N = LSHIFT(N,ISHIFT)        
      NMASK = N        
      DO 10 I = 1,4        
      MASK(I) = COMPLF(N)        
      N = RSHIFT(N,BPERCH)        
   10 CONTINUE        
C        
C     COMPUTE WORD AND CHARACTER OF WORD        
C        
   20 IWORD = (COL-1)/4 + 1        
      ICHAR = COL - (IWORD-1)*4        
      IWORD = (ROW-1)*30 + IWORD        
C        
C     PACK THE CHARACTER        
C        
      IF (MACH.EQ.5 .OR. MACH.EQ.6 .OR. MACH.EQ.21) GO TO 30        
      LET = RSHIFT(ANDF(CHAR,NMASK),BPERCH*(ICHAR-1))        
      Z(IWORD) = ORF(ANDF(Z(IWORD),MASK(ICHAR)),LET)        
      RETURN        
C        
C     VAX, ULTRIX, AND ALPHA        
C        
   30 Z(IWORD) = KHRFN1(Z(IWORD),ICHAR,CHAR,1)        
      RETURN        
      END        
