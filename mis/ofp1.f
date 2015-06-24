      SUBROUTINE OFP1        
C        
C     THIS ROUTINE OUTPUTS A PAGE HEADING BASED ON PARAMETERS COMING    
C     THROUGH COMMON.        
C     THIS ROUTINE CALLS OPF1A, OFP1B OR OFP1C FOR ACTUAL PRINTING, SUCH
C     THAT OFP1A, OFP1B AND OFP1C CAN BE OVERLAYED IN PARALLEL.        
C        
      INTEGER         L123(5),ID(50),OF(6)        
      COMMON /SYSTEM/ KSYS(100)        
CZZ   COMMON /ZZOFPX/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      EQUIVALENCE     (CORE(1),OF(1),L123(1)), (ID(1),OF(6)),        
     1                (NOUT,KSYS(2)), (LINET,KSYS(12)), (IFLAG,KSYS(33))
C        
C     IFLAG IS WORD 33 OF /SYSTEM/ AND IS SET TO INCIDATE OFP PRINTED   
C     LAST.        
C        
      CALL PAGE1        
      IFLAG = 1        
      DO 1000 I = 1,5        
      LINE = L123(I)        
      IF (LINE) 1000,800,500        
 500  IF (LINE .GT. 174) GO TO 600        
C        
C ... 1 THRU 174-        
C        
      CALL OFP1A (LINE)        
      GO TO 1000        
 600  IF (LINE .GT. 380) GO TO 700        
C        
C ... 175 THRU 380 -        
C        
      CALL OFP1B (LINE)        
      GO TO 1000        
C        
C ... 381 UP -        
C        
 700  CALL OFP1C (LINE)        
      GO TO 1000        
C        
 800  WRITE  (NOUT,900)        
 900  FORMAT (1H )        
C        
 1000 CONTINUE        
      LINET = LINET + 4        
      RETURN        
      END        
