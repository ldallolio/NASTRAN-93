      SUBROUTINE DFBS        
C        
C     FBS   L,U,B/X/V,Y,ISYM=0/V,Y,KSIGN=1/V,Y,IPREC=0/V,Y,ITYPE=0 $    
C        
C     ISYM  =  1  USE FBS        
C           = -1  USE GFBS        
C           =  0  CHOOSE WHICH BASED ON SUPPLIED INPUT        
C     KSIGN =  1, SOLVE LUX= B        
C             -1,       LUX=-B        
C     IPREC = REQUESTED PRECISION - DEFAULT BASED ON INPUT OR SYSTEM(55)
C     ITYPE = REQUESTED TYPE OF X - DEFAULT IS LOGICAL CHOICE ON INPUT  
C        
C     REVISED  12/91 BY G.CHAN/UNISYS        
C     FATAL ERROR IN FBS (NOT GFBS) IF INPUT MATRIX IS NOT A LOWER      
C     TRIANGULAR FACTOR        
C        
      INTEGER         L,U,B,X,SBNM(2),DOSI(3),REFUS(3),OUTPT,SCR        
      DIMENSION       ZZ(1)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25,SWM*27        
      COMMON /XMSSG / UFM,UWM,UIM,SFM,SWM        
      COMMON /BLANK / ISYM, KSIGN, IPREC, ITYPE        
      COMMON /SYSTEM/ KSYSTM(65)        
      COMMON /FBSX  / IL(7),IU(7),IB(7),IX(7),INX,IP1,IS1,ISCR        
      COMMON /GFBSX / JL(7),JU(7),JB(7),JX(7),JNX,JP1,JS1        
CZZ   COMMON /ZZDFB1/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
CZZ   COMMON /ZZDFB2/ ZZ        
      EQUIVALENCE     (ZZ(1),Z(1))        
      EQUIVALENCE     (KSYSTM(55),KPREC),(KSYSTM(2),OUTPT)        
      DATA    L, U, B, X, SCR   / 101,102,103,201,301 /        
      DATA    SBNM  / 4HDFBS,1H /        
      DATA    DOSI  / 4HSING, 4HDOUB, 4HMLTP/,  REFUS / 2*3H   ,3HREF/  
C        
C        
      JU(1) = U        
      CALL RDTRL (JU)        
   10 IF (ISYM) 150,20,30        
   20 ISYM  = -1        
      IF (JU(1) .LT. 0) ISYM = 1        
      GO TO 10        
C        
C     SET UP CALL TO FBS        
C        
   30 NOGO  = 0        
      IL(1) = L        
      CALL RDTRL (IL)        
      IF (IL(1) .GT. 0) GO TO 40        
      CALL MESAGE (30,198,L)        
      NOGO  = 1        
   40 CONTINUE        
      IF (IL(4) .NE. 4) GO TO 100        
      N     = IL(2)        
      IB(1) = B        
      CALL RDTRL (IB)        
      IF (NOGO .EQ. 0) GO TO 50        
      CALL MESAGE (-30,199,SBNM)        
   50 CONTINUE        
      INX   = KORSZ(Z)        
      IPREC1= MAX0(IL(5),IB(5),IU(5))        
      IF (IPREC1 .GT. 2) IPREC1 = IPREC1 - 2        
      IF (IPREC1.LT.1 .OR. IPREC1.GT.2) IPREC1 = KPREC        
      IF (IPREC.EQ.IPREC1 .OR. IPREC.EQ.0) GO TO 70        
      IF (IPREC.LT.1 .OR. IPREC.GT.2) IPREC = 3        
      WRITE  (OUTPT,60) SWM,DOSI(IPREC),REFUS(IPREC),SBNM,DOSI(IPREC1)  
   60 FORMAT (A27,' 2163, REQUESTED ',A4,'LE PRECISION ',A3,' USED BY ',
     1        2A4,2H. ,A4,'LE PRECISION IS LOGICAL CHOICE')        
      IF (IPREC .NE. 3) IPREC1 = IPREC        
   70 IPREC = IPREC1        
      IP1   = IPREC1        
      IS1   = KSIGN        
      LTYPE = IPREC1        
      IF (IL(5).EQ.3 .OR. IL(5).EQ.4 .OR. IU(5).EQ.3 .OR. IU(5).EQ.4 .OR
     1   .IL(5).EQ.3 .OR. IL(5).EQ.4)  LTYPE = IPREC1 + 2        
      IF (ITYPE.EQ.0 .OR. ITYPE.EQ.LTYPE) GO TO 90        
      JJ    = 1        
      IF (ITYPE.LT.1 .OR. ITYPE.GT.4) JJ = 3        
      WRITE  (OUTPT,80) SWM,ITYPE,REFUS(JJ),SBNM,LTYPE        
   80 FORMAT (A27,' 2164, REQUESTED TYPE ',I4,2H, ,A3,' USED BY ',2A4,  
     1       '. TYPE ',I4,' IS LOGICAL CHOICE.')        
      IF (JJ .NE. 3) LTYPE = ITYPE        
   90 ITYPE = LTYPE        
      IX(5) = ITYPE        
      IX(1) = X        
      ISCR  = SCR        
      CALL FBS (Z,Z)        
      IX(3) = N        
      IX(4) = 2        
      IF (IX(3) .EQ. IX(2)) IX(4) = 1        
      CALL WRTTRL (IX)        
      GO TO 200        
C        
  100 CALL FNAME (IL(1),IL(2))        
      WRITE  (OUTPT,110) IL(2),IL(3),IL(4)        
  110 FORMAT ('0*** INPUT MATRIX ',2A4,' TO FBS MODULE IS NOT A LOWER ',
     1        'TRIANGULAR FACTOR.  FORM =',I4)        
      CALL ERRTRC ('DFBS    ',110)        
      GO TO 200        
C        
C     SET UP CALL TO GFBS        
C        
  150 JL(1) = L        
      CALL RDTRL (JL)        
      N     = JL(2)        
      JB(1) = B        
      CALL RDTRL (JB)        
      JNX   = KORSZ(ZZ)        
      IPREC1= MAX0(JL(5),JB(5),JU(5))        
      IF (IPREC1 .GT. 2) IPREC1 = IPREC1 - 2        
      IF (IPREC1.LT.1 .OR. IPREC1.GT.2) IPREC1 = KPREC        
      IF (IPREC.EQ.IPREC1 .OR. IPREC.EQ.0) GO TO 160        
      IF (IPREC.LT.1 .OR. IPREC.GT.2) IPREC = 3        
      WRITE (OUTPT,60) SWM,DOSI(IPREC),REFUS(IPREC),SBNM,DOSI(IPREC1)   
      IF (IPREC .NE. 3) IPREC1 = IPREC        
  160 IPREC = IPREC1        
      JP1   = IPREC1        
      JS1   = KSIGN        
      JX(1) = X        
      LTYPE = IPREC1        
      IF (JL(5).EQ.3 .OR. JL(5).EQ.4 .OR. JU(5).EQ.3 .OR. JU(5).EQ.4 .OR
     1   .JL(5).EQ.3 .OR. JL(5).EQ.4) LTYPE = IPREC1 + 2        
      IF (ITYPE.EQ.0 .OR. ITYPE.EQ.LTYPE) GO TO 170        
      JJ    = 1        
      IF (ITYPE.LT.1 .OR. ITYPE.GT.4) JJ = 3        
      WRITE (OUTPT,80) SWM,ITYPE,REFUS(JJ),SBNM,LTYPE        
      IF (JJ .NE. 3) LTYPE = ITYPE        
  170 ITYPE = LTYPE        
      JX(5) = ITYPE        
      CALL GFBS (ZZ,ZZ)        
      JX(3) = N        
      JX(4) = 2        
      IF (JX(3) .EQ. JX(2)) JX(4) =  1        
      CALL WRTTRL (JX)        
C        
  200 RETURN        
      END        
