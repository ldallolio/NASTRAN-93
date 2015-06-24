      SUBROUTINE GUST1(CASECC,DIT,DLT,FRL,PP,FOL,GUSTL,NFREQ,NLOAD,     
     1  XO,V,NOGUST,CASNEW)        
C        
C     THE PURPOSE OF THI ROUTINE IS TO GERATE PP,GUSTL,FOL.        
C        
C     THE ROUTINE PROCEEDS AS FOLLOWS        
C        
C         FIND  GUST CARD(NO-CARDS--SET NOGUST=1 AND RETURN)        
C         PUT GUST CARDS IN CORE        
C         READ CASECC -- BUILD GUSTL        
C           SUPPLU DLOAD =   FROM GUST =        
C        
C         CALL GUST1A WITH NEW CASECC        
C        
      INTEGER CASECC,DIT,DLT,FRL,PP,FOL,GUSTL,CASNEW,SYSBUF,NAME(2),    
     1 FILE,IGUST(2),LGUST(5)        
      REAL  Z(1),RGUST(5)        
      COMMON /SYSTEM/SYSBUF        
CZZ   COMMON /ZZFRA1/ IZ(1)        
      COMMON /ZZZZZZ/ IZ(1)        
      EQUIVALENCE (IZ(1),Z(1)),(RGUST(1),LGUST(1))        
      DATA  NAME /4HGUST,1H1 /,IGUST /1005,10 /        
      DATA IGST /178/        
C        
C     INITIALIZE        
C        
      NZ = KORSZ(IZ)        
      IBUF1 = NZ-SYSBUF        
      IBUF2 = IBUF1-SYSBUF        
      IBUF3 = IBUF2-SYSBUF        
      NZ = IBUF3-1        
      NOGUST =-1        
      NOGO =0        
      CALL PRELOC(*1000,IZ(IBUF1),DIT)        
      CALL LOCATE(*1000,IZ(IBUF1),IGUST,IDX)        
C        
C     PUT  GUST CARDS IN CORE        
C        
      FILE =DIT        
      CALL READ(*910,*10,DIT,IZ,NZ,0,NLGUST)        
      CALL MESAGE(-8,0,NAME)        
   10 CONTINUE        
      CALL CLOSE(DIT,1)        
      ICC = NLGUST+1        
      CALL GOPEN(CASECC,IZ(IBUF1),0)        
      CALL GOPEN(CASNEW,IZ(IBUF2),1)        
      CALL GOPEN(GUSTL,IZ(IBUF3),1)        
      NZ = NZ - NLGUST        
C        
C     BLAST READ A CASE CONTROL RECORD INTO CORE        
C        
   20 CONTINUE        
      FILE = CASECC        
      CALL READ(*100,*30,CASECC,IZ(ICC),NZ,0,LCC)        
      CALL MESAGE(-8,0,NAME)        
   30 CONTINUE        
      IGSID = IZ(ICC+IGST)        
      IZ(ICC+12) = IGSID        
      CALL ZEROC(RGUST,5)        
      IF( IGSID .EQ.  0)  GO TO 90        
C        
C     FIND GUST ID AMONG GUST CARDS        
C        
      DO 40 I = 1 ,NLGUST,5        
      IF( IZ(I) .EQ. IGSID) GO TO 50        
   40 CONTINUE        
      CALL MESAGE(31,IGSID,NAME)        
      NOGO =1        
      GO TO 90        
C        
C     FOUND GUST CARD        
C        
   50 CONTINUE        
      IZ(ICC+12) = IZ(I+1)        
      IGUST(1) =IGSID        
      LGUST(2) = IZ(I+1)        
      RGUST(3) = Z(I+2)        
      RGUST(4) = Z(I+3)        
      RGUST(5) = Z(I+4)        
      XO =  RGUST(4)        
      V  =  RGUST(5)        
      NOGUST = 1        
C        
C     PUT OUT GUSTL /CASNEW        
C        
   90 CALL WRITE(CASNEW,IZ(ICC),LCC,1)        
      CALL WRITE(GUSTL,LGUST,5,1)        
      GO TO 20        
C        
C     END OF FILE ON CASECC        
  100 CONTINUE        
      IF( NOGO .EQ. 1) CALL MESAGE(-61,0,NAME)        
      CALL CLOSE(CASECC,1)        
      CALL CLOSE(GUSTL,1)        
      CALL CLOSE(CASNEW,1)        
C        
C     CALL GUST1A FOR LOADS(W)        
C        
      CALL GUST1A (DLT, FRL, -CASNEW, DIT, PP, 1, NFREQ, NLOAD, FRQSET, 
     1             FOL, NOTRD)        
      CALL DMPFIL(-PP,IZ,NZ)        
 1000 CALL CLOSE(DIT,1)        
      RETURN        
C        
C     FILE  ERRORS        
C        
  910 IP1 = -2        
      CALL MESAGE (IP1, FILE, NAME)        
      RETURN        
      END        
