      SUBROUTINE EQOUT1 (IA,LEN1,NS,LEN2,ISIL)        
C        
C     THIS ROUTINE GENERATES OUTPUT ENTRIES FOR CONNECTION TRACE        
C        
      EXTERNAL        LSHIFT,RSHIFT        
      INTEGER         IA(1),NS(1),IBITS(2),N1(17),N2(14),RSHIFT,OUTT    
      COMMON /CMB002/ JUNK(8),OUTT        
      COMMON /SYSTEM/ JUNK1(8),NLPP,JUNK2(2),NLINE        
      COMMON /CMB003/ ICOMB(7,5),CONSET,IAUTO,TOLER,NPSUB        
      COMMON /MACHIN/ MACH,IHALF        
      DATA    IBLANK/ 4H      /        
C        
C     SORT ON PSEUDOSTRUCTURE NUMBER        
C        
      IFIRST = 1        
      DO 28 K = 1,17        
      N1(K) = IBLANK        
   28 CONTINUE        
      DO 29 K = 1,14        
      N2(K) = IBLANK        
   29 CONTINUE        
      CALL SORT (0,0,4,1,IA(1),LEN1)        
      J = 1        
      N1(1) = IA(J+2)        
      ICODE = IA(J+3)        
      CALL BITPAT (ICODE,IBITS)        
      DO 1 I = 1,2        
      N1(I+1) = IBITS(I)        
    1 CONTINUE        
   13 IPS   = RSHIFT(IA(J),IHALF)        
      ISUB  = 2*(IPS-1) + 4        
      IDBAS = IA(J) - LSHIFT(IPS,IHALF)        
      N1(ISUB  ) = NS(2*IDBAS-1)        
      N1(ISUB+1) = NS(2*IDBAS  )        
      IA(J) = -IA(J)        
      CALL PUSH (IA(J+1),N2(2*IPS-1),1,8,1)        
      JJ = J        
   12 IF (JJ+4 .GT. LEN1) GO TO 14        
      IF (IA(JJ+4)) 11,11,50        
  50  IF (RSHIFT(IABS(IA(J)),IHALF) - RSHIFT(IA(JJ+4),IHALF)) 10,11,10  
   11 JJ = JJ + 4        
      GO TO 12        
   10 J = JJ + 4        
      GO TO 13        
C        
C     WRITE OUTPUT        
C        
   14 NLINE = NLINE + 3        
      IF (NLINE .LE. NLPP) GO TO 20        
      CALL PAGE        
      NLINE = NLINE + 3        
   20 CONTINUE        
      J = 3 + 2*NPSUB        
      IF (IFIRST .EQ. 1) WRITE(OUTT,1000) N1(1),ISIL,(N1(K),K=2,J)      
      IF (IFIRST .EQ. 0) WRITE(OUTT,1003) (N1(K),K=4,J)        
      WRITE (OUTT,1001) (N2(K),K=1,14)        
      IFIRST = 0        
      J = -3        
   15 J = J + 4        
      IF (J .GT. LEN1) GO TO 17        
      IF (IA(J)) 15,15,16        
   16 DO 18 K = 1,17        
      N1(K) = IBLANK        
   18 CONTINUE        
      DO 19 K = 1,14        
      N2(K) = IBLANK        
   19 CONTINUE        
      GO TO 13        
   17 WRITE  (OUTT,1002)        
 1000 FORMAT (8X,I6,6X,I6,8X,A4,A2,7(3X,2A4))        
 1001 FORMAT (40X,7(3X,2A4) )        
 1002 FORMAT (7X,4H  --,27(4H----),4H-    )        
 1003 FORMAT (/40X,7(3X,2A4) )        
      RETURN        
      END        
