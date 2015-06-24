      SUBROUTINE AMGB1 (INPUT,MATOUT,SKJ)        
C        
C     DRIVER FOR COMPRESSOR BLADE THEORY.        
C     COMPUTATIONS ARE FOR THE AJJL AND SKJ MATRICES.        
C     FOR COMPRESSOR BLADES K-SET = J-SET = NLINES*NSTNS.        
C     SKJ = W*F(INVERS)TRANSPOSE.        
C        
C        
      LOGICAL         TSONIC,DEBUG        
      INTEGER         ECORE,SYSBUF,IZ(1),NAME(2),SLN,SKJ,TSKJ        
      REAL            MINMAC,MAXMAC,MACH,RADII(50)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /AMGMN / MCB(7),NROW,DUM(2),REFC,SIGMA,RFREQ,TSKJ(7),ISK,  
     1                NSK        
      COMMON /CONDAS/ PI,TWOPI,RADEG,DEGRA,S4PISQ        
      COMMON /BAMG1L/ IREF,MINMAC,MAXMAC,NLINES,NSTNS,REFSTG,REFCRD,    
     1                REFMAC,REFDEN,REFVEL,REFFLO,SLN,NSTNSX,STAGER,    
     2                CHORD,RADIUS,BSPACE,MACH,DEN,VEL,FLOWA,AMACH,     
     3                REDF,BLSPC,AMACHR,TSONIC,XSIGN        
CZZ   COMMON /ZZMGB1/ WORK(1)        
      COMMON /ZZZZZZ/ WORK(1)        
      COMMON /SYSTEM/ SYSBUF,IOUT        
      COMMON /PACKX / ITI,ITO,II,NN,INCR        
      COMMON /BLANK / NK,NJ        
      COMMON /AMGBUG/ DEBUG        
      EQUIVALENCE     (WORK(1),IZ(1))        
      DATA    NAME  / 4HAMGB,4H1   /        
C        
C     READ PARAMETERS IREF,MINMAC,MAXMAC,NLINES AND NSTNS        
C        
      CALL READ (*999,*999,INPUT,IREF,5,0,N)        
      IF (DEBUG) CALL BUG1 ('ACPT-REF  ',5,IREF,5)        
C        
C     READ REST OF ACPT RECORD INTO OPEN CORE AND LOCATE REFERENCE      
C     PARAMETERS REFSTG,REFCRD,REFMAC,REFDEN,REFVEL AND REFFLO        
C     STORE STREAMLINE RADIUS FOR ALL STREAMLINES        
C        
      ECORE = KORSZ(IZ) - 4*SYSBUF        
      CALL READ (*10,*10,INPUT,IZ,ECORE,1,NWAR)        
      GO TO 998        
   10 IRSLN = 0        
      IF (DEBUG) CALL BUG1 ('ACPT-REST ',10,IZ,NWAR)        
      NTSONX= 0        
      NDATA = 3*NSTNS + 10        
      NLINE = 0        
      DO 20 I = 1,NWAR,NDATA        
C        
C     LOCATE REFERENCE STREAMLINE NUMBER (IREF = SLN)        
C        
      IF (IREF .EQ. IZ(I)) IRSLN = I        
C        
C     STORE AMACH FOR LATER DATA CHECK. COUNT TRANSONIC STREAMLINES     
C        
      AMACHL = WORK(I+6)*COS(DEGRA*(WORK(I+9)-WORK(I+2)))        
      IF (AMACHL.GT.MAXMAC .AND. AMACHL.LT.MINMAC) NTSONX = NTSONX + 1  
      NLINE = NLINE + 1        
      WORK(NWAR+NLINE) = AMACHL        
      RADII(NLINE) = WORK(I+4)        
   20 CONTINUE        
C        
C     DETERMINE DIRECTION OF BLADE ROTATION VIA Y-COORDINATES AT TIP    
C     STREAMLINE. USE COORDINATES OF FIRST 2 NODES ON STREAMLINE.       
C        
      IPTR  = NDATA*(NLINES-1)        
      XSIGN = 1.0        
      IF (WORK(IPTR+15) .LT. WORK(IPTR+12)) XSIGN = -1.0        
C        
      IF (DEBUG) CALL BUG1 ('RADII     ',25,RADII,NLINES)        
C        
C     INPUT CHECKS -        
C     (1) AMACH MUST INCREASE FROM BLADE ROOT TO BLADE TIP        
C     (2) ALL TRANSONIC AMACH-S ARE NOT ALLOWED AT PRESENT        
C        
      IBAD = 0        
      IF (NTSONX .LT. NLINES) GO TO 30        
      IBAD = 1        
      WRITE (IOUT,1001) UFM        
   30 CONTINUE        
      NW1 = NWAR + 1        
      NW2 = NWAR + NLINES - 1        
      DO 35 I = NW1,NW2        
      IF (WORK(I) .GT. WORK(I+1)) GO TO 40        
   35 CONTINUE        
      GO TO 45        
   40 IBAD = 1        
      ISLN = (I-NWAR-1)*NDATA + 1        
      WRITE (IOUT,1002) UFM,IZ(ISLN)        
   45 IF (IBAD .NE. 0) GO TO 997        
C        
C     SET TSONIC IF THERE ARE ANY TRANSONIC STREAMLINES        
C        
      TSONIC = .FALSE.        
      IF (NTSONX .GT. 0) TSONIC = .TRUE.        
C        
C     STORE REFERENCE PARAMETERS        
C     DID IREF MATCH AN SLN OR IS THE DEFAULT TO BE TAKEN  (BLADE TIP)  
C        
      IF (IRSLN .EQ. 0) IRSLN = (NLINES-1)*NDATA + 1        
      REFSTG = WORK(IRSLN+2)        
      REFCRD = WORK(IRSLN+3)        
      REFMAC = WORK(IRSLN+6)        
      REFDEN = WORK(IRSLN+7)        
      REFVEL = WORK(IRSLN+8)        
      REFFLO = WORK(IRSLN+9)        
C        
C     REPOSITION ACPT TO BEGINNING OF COMPRESSOR BLADE DATA        
C        
      CALL BCKREC (INPUT)        
      CALL FREAD (INPUT,0,-6,0)        
      IF (DEBUG) CALL BUG1 ('BAMG1L    ',47,IREF,26)        
C        
C     COMPUTE POINTERS AND SEE IF THERE IS ENOUGH CORE        
C     IP1 AND IP2 ARE COMPLEX POINTERS        
C        
      NAJJC  = NSTNS        
      NTSONX = 1        
      IF (TSONIC) NAJJC  = NLINES*NSTNS        
      IF (TSONIC) NTSONX = NLINES        
      IP1  = 1        
      IP2  = IP1 + 2*(NSTNS*NAJJC)        
      IP3  = IP2 + 2*NSTNS        
      IP4  = IP3 + NTSONX        
      IP5  = IP4 + NTSONX        
      NEXT = IP5 + NTSONX        
      IF (NEXT .GT. ECORE) GO TO 998        
C        
C     CALL ROUTINE TO COMPUTE AND OUTPUT AJJL.        
C        
      ITI = 3        
      ITO = 3        
C        
      CALL AMGB1A (INPUT,MATOUT,WORK(IP1),WORK(IP2),WORK(IP3),        
     1             WORK(IP4),WORK(IP5))        
      IF (DEBUG) CALL BUG1 ('AJJL      ',48,WORK(IP1),IP2-1)        
C        
C     COMPUTE F(INVERSE) AND W(FACTOR) FOR EACH STREAMLINE        
C        
C     COMPUTE POINTERS AND SEE IF THERE IS ENOUGH CORE        
C        
      NSNS = NSTNS*NSTNS        
      IP1  = 1        
      IP2  = IP1 + NSNS        
      NEXT = IP2 + 3*NSTNS        
      IF (NEXT .GT. ECORE) GO TO 998        
C        
C     REPOSITION ACPT TO BEGINNING OF COMPRESSOR BLADE DATA        
C        
      CALL BCKREC (INPUT)        
      CALL FREAD  (INPUT,0,-6,0)        
C        
      ITI = 1        
      ITO = 3        
C        
      II  = ISK        
      NSK = NSK + NSTNS        
      NN  = NSK        
      DO 100 NLINE = 1,NLINES        
      CALL AMGB1S (INPUT,WORK(IP1),WORK(IP2),WORK(IP2),RADII,WFACT,     
     1             NLINE)        
C        
C     OUTPUT SKJ (= WFACT*F(INVERS)TRANSPOSE) FOR THIS STREAMLINE       
C        
      IP3 = IP2 + NSTNS - 1        
      DO 60 I = 1,NSTNS        
      K  = I        
      DO 50 J = IP2,IP3        
      WORK(J) = WORK(K)*WFACT        
   50 K  = K + NSTNS        
      CALL PACK (WORK(IP2),SKJ,TSKJ)        
      IF (DEBUG) CALL BUG1 ('SKJ       ',55,WORK(IP2),NSTNS)        
   60 CONTINUE        
      II = II + NSTNS        
      IF (NLINE .EQ. NLINES) GO TO 100        
      NN = NN + NSTNS        
  100 CONTINUE        
C        
C     UPDATE NROW AND PACK POINTERS        
C        
      NROW = NROW + NLINES*NSTNS        
      IF (DEBUG) CALL BUG1 ('NEW-NROW  ',110,NROW,1)        
      ISK = II        
      NSK = NN        
      RETURN        
C        
C     ERROR MESSAGES        
C        
C     BAD STREAMLINE DATA        
C        
  997 CALL MESAGE (-61,0,0)        
C        
C     NOT ENOUGH CORE        
C        
  998 CALL MESAGE (-8,0,NAME)        
C        
C     INPUT NOT POSITIONED PROPERLY OR INCORRECTLY WRITTEN        
C        
  999 CALL MESAGE (-7,0,NAME)        
      RETURN        
C        
 1001 FORMAT (A23,' -AMG MODULE- ALL TRANSONIC STREAMLINES NOT ALLOWED',
     1       /39X,'CHECK MACH ON STREAML2 BULK DATA CARDS OR', /39X,    
     2       'CHANGE PARAMETERS MINMACH AND MAXMACH.')        
 1002 FORMAT (A23,' -AMG MODULE- MACH NUMBERS MUST INCREASE FROM BLADE',
     1       ' ROOT TO BLADE TIP.', /39X,        
     2       'CHECK STREAML2 BULK DATA CARD WITH SLN =',I3)        
      END        
