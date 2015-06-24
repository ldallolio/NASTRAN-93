      SUBROUTINE BIOTSV (XX,YY,ZZ,HCX,HCY,HCZ)        
C        
C     THIS ROUTINE COMPUTES THE MAGNETIC FIELD AT A POINT (XX,YY,ZZ)    
C     DUE TO MAGNETIC SOIRCES. THE ROUTINE IS USED BY PROLATE IN        
C     COMPUTING HC POTENTIALS USING LINE INTEGRALS. AT Z(IST) IS STORED 
C     LOAD INFO. NEEDED FOR THIS SUBCASE (WHICH COULD BE A LOAD        
C     COMBINATION) AS STORED BY ROUTINE LOADSU. THE INFO. IS STORED AS  
C     FOLLOWS -        
C        
C     OVERALL SCALE FACTOR - ALLS        
C     NUMBER OF SIMPLE LOADS - NSIMP        
C     SCALE FACTOR FOR 1ST SIMPLE LOAD        
C     NUMBER OF LOAD CARDS FOR 1ST SIMPLE LOAD        
C     SCALE FACTOR FOR 2ND SIMPLE LOAD        
C     NUMBER OF LOAD CARDS FOR 2ND SIMPLE LOAD        
C      .        
C     ETC.        
C      .        
C     TYPE(NOBLD) OF 1ST CARD FOR 1ST SIMPLE LOAD        
C     NUMBER OF CARDS FOR THIS TYPE - IDO        
C     LOAD INFO FOR THIS TYPE FOR 1ST SIMPLE LOAD        
C     ANOTHER TYPE FOR 1ST SIMPLE LOAD        
C      .        
C     ETC        
C      .        
C     LOAD CARDS FOR SUBSEQUENT SIMPLE LOADS FOR THIS SUBCASE        
C        
      INTEGER         HEST,BGPDT,SCR1,FILE,BUF2,SUBCAS        
      DIMENSION       NAM(2),IZ(1),BUF(50),IBUF(50),MCB(7),HC(3),HC1(3),
     1                HC2(3)        
      COMMON /BIOT  / NG1,NG2,IST,SUBCAS,X1,Y1,Z1,X2,Y2,Z2,BUF2,REMFL,  
     1                MCORE,LOAD,NSLT,SCR1,HEST,NTOT        
      COMMON /SYSTEM/ SYSBUF,IOUT        
CZZ   COMMON /ZZPROL/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (Z(1),IZ(1)),(BUF(1),IBUF(1))        
      DATA    NAM   / 4HBIOT,4HSV  /        
C        
      HCX    = 0.        
      HCY    = 0.        
      HCZ    = 0.        
      SCR1   = 301        
      BGPDT  = 103        
      MCB(1) = BGPDT        
      CALL RDTRL (MCB)        
      NROWSP = MCB(2)        
      MCB(1) = SCR1        
      CALL RDTRL (MCB)        
      N3     = MCB(3)        
      NGRIDS = N3/3        
C        
      ALLS   = Z(IST+1)        
      NSIMP  = IZ(IST+2)        
      ISIMP  = IST + 2*NSIMP + 2        
C        
C     LOOP ON NUMBER OF SIMPLE LOADS        
C        
      DO 270 NS = 1,NSIMP        
      NC     = 0        
      HC(1)  = 0.        
      HC(2)  = 0.        
      HC(3)  = 0.        
C        
      FACTOR = Z(IST+2*NS+1)        
      NCARDS = IZ(IST+2*NS+2)        
   15 NOBLD  = IZ(ISIMP+1)        
      IDO    = IZ(ISIMP+2)        
      ISIMP  = ISIMP + 2        
C        
C        
      KTYPE  = NOBLD - 19        
      GO TO (20,30,40,50,60), KTYPE        
   20 MWORDS = 3*NROWSP        
      GO TO 70        
   30 MWORDS = 12        
      GO TO 70        
   40 MWORDS = 48        
      GO TO 70        
   50 MWORDS = 9        
      GO TO 70        
   60 MWORDS = 0        
C        
   70 DO 245 J = 1,IDO        
C        
      GO TO (145,150,150,150,180), KTYPE        
C        
C     SPCFLD DATA STARTS AT Z(ISIMP+1)        
C        
  145 CONTINUE        
C        
C        
C     NG1 AND NG2 ARE THE SIL NUMBERS OF THE END POINTS OF THE LINE     
C     INTEGRL WITH (X1,Y1,Z1) AND (X2,Y2,Z2) BEING THE COORDINATES.     
C     LINEARLY INTERPOLATE TO (XX,YY,ZZ). THE SILS ARE POINTERS INTO    
C     THE SPCFLD DATA        
C        
      ISUB   = ISIMP + 3*NG1        
      HC1(1) = Z(ISUB-2)        
      HC1(2) = Z(ISUB-1)        
      HC1(3) = Z(ISUB)        
      ISUB   = ISIMP + 3*NG2        
      HC2(1) = Z(ISUB-2)        
      HC2(2) = Z(ISUB-1)        
      HC2(3) = Z(ISUB)        
  148 TLEN   = SQRT((X2-X1)**2 + (Y2-Y1)**2 + (Z2-Z1)**2)        
      XLEN   = SQRT((XX-X1)**2 + (YY-Y1)**2 + (ZZ-Z1)**2)        
      RATIO  = XLEN/TLEN        
      HC(1)  = HC(1) + (1.-RATIO)*HC1(1) + RATIO*HC2(1)        
      HC(2)  = HC(2) + (1.-RATIO)*HC1(2) + RATIO*HC2(2)        
      HC(3)  = HC(3) + (1.-RATIO)*HC1(3) + RATIO*HC2(3)        
      GO TO 240        
C        
C     CEMLOOP,GEMLOOP,MDIPOLE        
C        
  150 DO 152 K = 1,MWORDS        
  152 BUF(K) = Z(ISIMP+K)        
      LTYPE  = KTYPE - 1        
      GO TO (155,160,165), LTYPE        
  155 CALL AXLOOP (BUF,IBUF,XX,YY,ZZ,HCA,HCB,HCC)        
      GO TO 170        
  160 CALL GELOOP (BUF,IBUF,XX,YY,ZZ,HCA,HCB,HCC)        
      GO TO 170        
  165 CALL DIPOLE (BUF,IBUF,XX,YY,ZZ,HCA,HCB,HCC)        
C        
  170 HC(1)  = HC(1) + HCA        
      HC(2)  = HC(2) + HCB        
      HC(3)  = HC(3) + HCC        
      GO TO 240        
C        
C     REMFLUX - BRING IN VALUES FROM SCR1 AFTER POSITIONING TO PROPER   
C     CASE        
C        
  180 CALL GOPEN (SCR1,Z(BUF2),0)        
      IC = SUBCAS - 1        
      IF (IC .EQ. 0) GO TO 200        
      DO 190 I = 1,IC        
      CALL FWDREC (*520,SCR1)        
  190 CONTINUE        
C        
  200 ISIMP1 = 6*NGRIDS + NTOT        
      CALL FREAD (SCR1,Z(ISIMP1+1),N3,1)        
C        
      CALL CLOSE (SCR1,1)        
C        
C     MUST MATCH NG1 AND NG2 TO SIL-S IN CORE TO LOCATE REMFLUX INFO ON 
C    SCR1        
C        
      ING1 = 0        
      ING2 = 0        
      DO 220 I = 1,NGRIDS        
      IF (NG1 .EQ. IZ(I)) GO TO 205        
      IF (NG2 .EQ. IZ(I)) GO TO 210        
      GO TO 220        
  205 ING1 = I        
      IF (ING2 .EQ. 0) GO TO 220        
      GO TO 230        
  210 ING2 = I        
      IF (ING1 .EQ. 0) GO TO 220        
      GO TO 230        
  220 CONTINUE        
      GO TO 510        
  230 ISUB   = 3*ING1 + ISIMP1        
      HC1(1) = Z(ISUB-2)        
      HC1(2) = Z(ISUB-1)        
      HC1(3) = Z(ISUB)        
      ISUB   = 3*ING2 + ISIMP1        
      HC2(1) = Z(ISUB-2)        
      HC2(2) = Z(ISUB-1)        
      HC2(3) = Z(ISUB)        
C        
C     INTERPOLATE AS WITH SPCFLD        
C        
      GO TO 148        
C        
C     DONE FOR ONE CARD OF PRESENT TYPE  - GET ANOTHER        
C        
  240 ISIMP = ISIMP + MWORDS        
      NC = NC + 1        
C        
  245 CONTINUE        
C        
C     CHECK TO SEE IF WE ARE DONE WITH THIS LOAD FACTOR        
C        
      IF (NC .LT. NCARDS) GO TO 15        
C        
C     DONE WITH THIS SIMPLE LOAD. APPLY INDIVIDUAL AND OVERALL SCALE    
C     FACTORS THEN GET ANOTHER SIMPLE LOAD        
C        
      FAC = FACTOR*ALLS        
      HCX = HCX + FAC*HC(1)        
      HCY = HCY + FAC*HC(2)        
      HCZ = HCZ + FAC*HC(3)        
C        
  270 CONTINUE        
C        
C     DONE        
C        
      RETURN        
C        
  510 WRITE  (IOUT,511) NG1,NG2        
  511 FORMAT ('0*** LOGIC ERROR, SILS',2I8,        
     1       ' CANNOT BE FOUND IN PROLATE LIST IN BIOTSV')        
      CALL MESAGE (-61,0,0)        
C        
  520 CALL MESAGE (-2,FILE,NAM)        
      RETURN        
      END        
