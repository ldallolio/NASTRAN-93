      SUBROUTINE ALG03 (LNCT,L)
C
      COMMON /UPAGE / LIMIT,LQ
      COMMON /UD3PRT/ IPRTC
C
      LNCT=LNCT+L
      IF(LNCT.LE.LIMIT)RETURN
      LNCT=1+L
      IF (IPRTC .NE. 0) WRITE(LQ,100)
100   FORMAT(1H1)                                                       
      RETURN
      END
