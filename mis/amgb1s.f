      SUBROUTINE AMGB1S (INPUT,FMAT,XYZB,INDEX,RADII,WFACT,NLINE)       
C        
C     COMPUTE F(INVERSE) AND WFACT FOR THIS STREAMLINE        
C        
      LOGICAL         TSONIC,DEBUG        
      INTEGER         SLN        
      REAL            MINMAC,MAXMAC,MACH        
      DIMENSION       FMAT(NSTNS,NSTNS),XYZB(3,NSTNS),INDEX(1),RADII(1),
     1                TBL(3,3)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /SYSTEM/ SYSBUF,IOUT        
      COMMON /AMGMN / MCB(7),NROW,DUM(2),REFC,SIGMA,RFREQ        
      COMMON /CONDAS/ PI,TWOPI,RADEG,DEGRA,S4PISO        
      COMMON /BAMG1L/ IREF,MINMAC,MAXMAC,NLINES,NSTNS,REFSTG,REFCRD,    
     1                REFMAC,REFDEN,REFVEL,REFFLO,SLN,NSTNSX,STAGER,    
     2                CHORD,RADIUS,BSPACE,MACH,DEN,VEL,FLOWA,AMACH,     
     3                REDF,BLSPC,AMACHR,TSONIC,XSIGN        
      COMMON /AMGBUG/ DEBUG        
C        
C     READ STREAMLINE DATA        
C        
      NSTNS3 = 3*NSTNS        
      CALL FREAD (INPUT,SLN,10,0)        
      CALL FREAD (INPUT,XYZB,NSTNS3,0)        
      IF (DEBUG) CALL BUG1 ('ACPT-SLN  ',11,SLN,10)        
      IF (DEBUG) CALL BUG1 ('XYZB      ',12,XYZB,NSTNS3)        
C        
C     COMPUTE PARAMETERS        
C        
      AMACH  = MACH  *COS(DEGRA*(FLOWA-STAGER))        
      AMACHR = REFMAC*COS(DEGRA*(REFFLO-REFSTG))        
      IF (DEBUG) CALL BUG1 ('AMACH     ',13,AMACH,1)        
      IF (DEBUG) CALL BUG1 ('AMACHR    ',14,AMACHR,1)        
C        
C     (1) COMPUTE BASIC TO LOCAL TRANSFORMATION        
C         XYZB ARRAY CONTAINS X,Y,Z COORDINATES IN BASIC SYSTEM        
C         FOR ALL NODES ON THE STREAMLINE LEADING EDGE TO TRAILING EDGE 
C     (2) TRANSFORM BASIC X,Y,Z ON STREAMLINE TO LOCAL X,Y,Z-S        
C     (3) COMPUTE FMAT(NSTNS X NSTNS)        
C     (4) COMPUTE FMAT(INVERS) - USE -        
C         CALL INVERS(NSTNS,FMAT,NSTNS,DUM1,0,DETERM,ISING,INDEX)       
C     (5) COMPUTE WFACT FOR THIS STREAMLINE - NOTE - ALL RADIUS HAVE    
C         ALREADY BEEN STORED IN ARRAY RADII FOR ALL STREAMLINES        
C        
      XA =  XYZB(1,1)        
      YA =  XYZB(2,1)        
      ZA =  XYZB(3,1)        
      XB =  XYZB(1,NSTNS)        
      YB =  XYZB(2,NSTNS)        
      ZB =  XYZB(3,NSTNS)        
C        
C     EVALUATE  TBL  ROW 2        
C        
      XBA = XB - XA        
      YBA = YB - YA        
      ZBA = ZB - ZA        
      AL2SQ = XBA**2 + YBA**2        
      AL2 = SQRT(AL2SQ)        
      AL1SQ = AL2SQ  + ZBA**2        
      AL1=  SQRT(AL1SQ)        
      TBL(2,1) =-XSIGN*(YBA/AL2)        
      TBL(2,2) = XSIGN*(XBA/AL2)        
      TBL(2,3) = 0.0        
C        
C     EVAL  TBL  ROW 1        
C        
      TBL(1,1) = XBA/AL1        
      TBL(1,2) = YBA/AL1        
      TBL(1,3) = ZBA/AL1        
C        
C     EVALUATE TBL  ROW 3        
C        
      TBL(3,1) =-TBL(1,3)*(XBA/AL2)        
      TBL(3,2) =-TBL(1,3)*(YBA/AL2)        
      TBL(3,3) = AL2/AL1        
      FMAT(1,1)= 1.0        
      PIC =  PI/CHORD        
      CH2 = 2.0/CHORD        
      DO 40 I = 2,NSTNS        
      X = TBL(1,1)*(XYZB(1,I)-XYZB(1,1))        
     1  + TBL(1,2)*(XYZB(2,I)-XYZB(2,1))        
     2  + TBL(1,3)*(XYZB(3,I)-XYZB(3,1))        
      FMAT(1,I) = 0.0        
      FMAT(I,1) = 1.0        
      FMAT(I,2) = CH2*X        
      DO 30 J = 3,NSTNS        
      AN  = J - 2        
      ARG = PIC*AN*X        
  30  FMAT(I,J) = SIN(ARG)        
  40  CONTINUE        
      IF (DEBUG) CALL BUG1 ('FMAT      ',50,FMAT,NSTNS*NSTNS)        
      ISING = -1        
      CALL INVERS (NSTNS,FMAT,NSTNS,DUM1,0,DETERM,ISING,INDEX)        
      IF (DEBUG) CALL BUG1 ('FMAT-INV  ',60,FMAT,NSTNS*NSTNS)        
      IF (ISING .EQ. 2) GO TO 80        
      K = NLINE + 1        
      L = K - 2        
      IF (NLINE .EQ.      1) L = 1        
      IF (NLINE .EQ. NLINES) K = NLINES        
C        
C     COMPUT WFACT FOR THIS STREAMLINE        
C        
      WFACT = (DEN/REFDEN)*(VEL/REFVEL)**2 *        
     1        ((AMACH*REFMAC)/(MACH*AMACHR))**2 *        
     2        (RADII(K) - RADII(L))*0.5        
      IF (DEBUG) CALL BUG1 ('WFACT     ',70,WFACT,1)        
      RETURN        
C        
C     ERROR MESSAGE, SINGULAR MATRIX        
C        
   80 WRITE  (IOUT,90) UFM,SLN        
   90 FORMAT (A23,' -AMG MODULE- SINGULAR MATRIX IN ROUTINE AMGB1S FOR',
     1     ' STREAML2, SLN =',I3, /39X,'CHECK STREAML2 BULK DATA CARD.')
      CALL MESAGE (-61,0,0)        
      RETURN        
      END        
