      SUBROUTINE XDCODE        
C        
C     (MACHINE INDEPENDENT FORTRAN 77 ROUTINE)        
C        
C     XDCODE DECODES A 20A4 ARRAY IN RECORD INTO A 80A1 ARRAY IN ICHAR  
C        
C     XDCODE IS CALLED ONLY BY XRGDCF, XRGDTB, XRGSST, AND XRGSUB       
C        
      CHARACTER*80    TEMP        
      CHARACTER*8     TEMP8        
      COMMON /SYSTEM/ IBUF,    NOUT,  DM37(37),NBPW        
      COMMON /XRGDXX/ SKIP1(3),ICOL,  SKIP2(8),RECORD(20),ICHAR(80),    
     1                SKIP3(2),ICOUNT,SKIP4(2),NAME(2)        
      DATA    IBLANK/ 4H      /        
C        
      WRITE (TEMP,10) RECORD        
      READ  (TEMP,20) ICHAR        
 10   FORMAT (20A4)        
 20   FORMAT (80A1)        
      RETURN        
C        
      ENTRY XECODE        
C     ============        
C        
C     XECODE ENCODES A 8A1 BCD ARRAY IN ICHAR INTO A 2A4 BCD ARRAY      
C     IN NAME        
C     (THIS ENTRY REPLACES THE OLD MACHINE DEPENDENT ROUTINE OF THE     
C     SAME NAME)        
C        
C     THE INCOMING WORD IN CDC MACHINE WOULD BE ZERO FILLED, SUCH AS    
C     THE CARD TABLE AND THE MED TABLE IN XGPI RESTART PROCESSING.      
C     MAKE SURE THAT THE INCOMING WORD FROM A 60- OR 64- BIT MACHINE    
C     IS BLANK FILLED IF IT IS LESS THAN 8 BYTE LONG        
C        
C     XECODE IS CALL ONLY BY XRGDTB        
C        
      IF (NBPW.LT.60 .OR. ICOUNT.EQ.8) GO TO 25        
      DO 22 K = ICOUNT,7        
 22   ICHAR(ICOL+K) = IBLANK        
 25   CALL NA12A8 (*50,ICHAR(ICOL),8,NAME,NOTUSE)        
      IF (NBPW .NE. 60) RETURN        
C        
C     BLANK OUT 2ND WORD (CDC ONLY)        
C        
      WRITE (TEMP8,30) NAME(1)        
      NAME(1) = IBLANK        
      NAME(2) = IBLANK        
      READ (TEMP8,40) NAME        
 30   FORMAT (A8)        
 40   FORMAT (2A4)        
      RETURN        
C        
 50   WRITE  (NOUT,60)        
 60   FORMAT ('0BAD DATA/XECODE')        
      RETURN        
      END        
