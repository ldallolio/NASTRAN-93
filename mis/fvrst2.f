      SUBROUTINE FVRST2        
C        
C    1. ENTRY POINT - FVRST2        
C        
C    2. PURPOSE -  THIS MODULE IS USED DURING A FORCED VIBRATION        
C                  RESPONSE ANALYSIS OF ROTATING CYCLIC STRUCTURES      
C                  TO GENERATE TABLE DATA BLOCKS FRL AND FOL AND TO     
C                  GENERATE MATRIX DATA BLOCKS REORDER1 AND REORDER2.   
C                  FVRSTR2 ALSO COMPUTES PARAMETERS LMAX, NTSTEPS,      
C                  FLMAX, NORO1 AND NORO2.        
C        
C    3. DMAP CALLING SEQUENCE -        
C        
C         FVRSTR2  TOL,,,,,,, / FRL,FOL,REORDER1,REORDER2,,,, /        
C                  V,Y,NSEGS/ V,Y,CYCIO/ V,Y,LMAX=-1/ V,N,FKMAX/        
C                  V,N,FLMAX/ V,N,NTSTEPS/ V,N,NORO1/ V,N,NORO2  $      
C        
C    4. INPUT DATA BLOCKS -        
C        
C         TOL    - TIME OUTPUT LIST.        
C        
C         NOTE   - (1) TOL MUST BE PRESENT.        
C        
C    5. OUTPUT DATA BLOCKS -        
C        
C         FRL      - FREQUENCY RESPONSE LIST.        
C         FOL      - FREQUENCY OUTPUT LIST.        
C         REORDER1 - LOAD REORDERING MATRIX FO TIME-DEPENDENT PROBLEMS. 
C         REORDER2 - LOAD REORDERING MATRIX FO TIME-DEPENDENT PROBLEMS. 
C        
C         NOTE     - (1) FRL AND FOL CANNOT BE PURGED.        
C                    (2) REORDER1 AND REORDER2 SHOULD NOT BE PURGED.    
C        
C    6. PARAMETERS -        
C        
C        (A) NSEGS   - INPUT-INTEGER-NO DEFAULT.  THE NUMBER OF        
C                      IDENTICAL SEGMENTS IN THE STRUCTURAL MODEL.      
C        (B) CYCIO   - INPUT-INTEGER-NO DEFAULT.  THE INTEGER VALUE     
C                      OF THIS PARAMETER SPECIFIES THE FORM OF THE INPUT
C                      AND OUTPUT DATA FOR CYCLIC STRUCTURES. A VALUE   
C                      OF +1 IS USED TO SPECIFY PHYSICAL SEGMENT REPRE- 
C                      SENTATION AND A VALUE OF -1 FOR CYCLIC TRANSFOR- 
C                      MATION REPRESENTATION.        
C        (C) LMAX    - INPUT/OUTPUT-INTEGER.  THE INTEGER VALUE OF THIS 
C                      PARAMETER SPECIFIES THE MAXIMUM TIME HARMONIC    
C                      INDEX FOR CYCLIC STRUCTURES. THE DEFAULT VALUE   
C                      IS NTSTEPS/2, WHERE NTSTEPS IS THE NUMBER OF     
C                      TIME STEPS DEFINED BELOW.        
C        (D) FKMAX   - INPUT-INTEGER-NO DEFAULT.  FUNCTION OF KMAX.     
C        (E) FLMAX   - OUTPUT-INTEGER-NO DEFAULT.  FUNCTION OF LMAX.    
C        (F) NTSTEPS - OUTPUT-INTEGER-NO DEFAULT.  THE NUMBER OF        
C                      TIME STEPS FOUND IN DATA BLOCK TOL.        
C        (G) NORO1   - OUTPUT-INTEGER-NO DEFAULT.  NORO1 =-1 IF DATA    
C                      BLOCK REORDER1 IS NOT GENERATED.        
C        (H) NORO2   - OUTPUT-INTEGER-NO DEFAULT.  NORO2 =-1 IF DATA    
C                      BLOCK REORDER2 IS NOT GENERATED.        
C        
C    7. METHOD -        
C        
C         DATA BLOCK TOL IS READ AND THE LIST OF SOLUTION TIMES IS      
C         STORED. SET NTSTEPS TO THE NUMBER OF SOLUTION TIMES READ.     
C         IF NECESSARY COMPUTE THE DEFAULT VALUE OF LMAX AND THEN       
C         COMPUTE FLMAX.        
C         GENERATE TABLE DATA BLOCKS FOL AND FRL.        
C         GENERATE MATRIX DATA BLOCKS REORDER1 AND REORDER2 AND        
C         PARAMETERS NORO1 AND NORO2.        
C        
C    8. SUBROUTINES - FVRST2 CALLS SUBROUTINE FVRS2A AND OTHER        
C                     STANDARD NASTRAN UTILITY ROUTINES.        
C        
C    9. DESIGN REQUIREMENTS -        
C        
C         (1) OPEN CORE IS DEFINED AT /ZZFVR2/.        
C         (2) NO SCRATCH FILES ARE USED.        
C         (3) FVRST2 RESIDES IN LINKNS07.        
C         (4) OPEN CORE FOR ONE BUFFER+1 IS REQUIRED.        
C        
C   10. DIAGNOSTIC MESSAGES -        
C        
C         THE FOLLOWING MESSAGES MAY BE ISSUED - 3001,3002,3003,3008.   
C        
C        
      INTEGER          MODNAM(2),FILE,FNAM(2),TRL(7),DUM(2),SYSBUF,TOL, 
     1                 FRL,FOL,REORD1,REORD2,CYCIO,FKMAX,FLMAX        
      DOUBLE PRECISION PERIOD,FREQ,FACT,DPI,DTWOPI,DRADEG,DDEGRA,D4PISQ 
      COMMON /BLANK /  NSEGS,CYCIO,LMAX,FKMAX,FLMAX,NTSTPS,NORO1,NORO2  
CZZ   COMMON /ZZFVR2/  Z(1)        
      COMMON /ZZZZZZ/  Z(1)        
      COMMON /SYSTEM/  SYSBUF,NOUT        
      COMMON /CONDAD/  DPI,DTWOPI,DRADEG,DDEGRA,D4PISQ        
      DATA    MODNAM/  4HFVRS,4HTR2  /        
      DATA       TOL,  FRL, FOL, REORD1, REORD2 /        
     1           101,  201, 202, 203,    204    /        
C        
C        
C     DETERMINE LENGTH OF OPEN CORE AND ALLOCATE BUFFERS.        
C        
      NZ    = KORSZ(Z)        
      IBUF1 = NZ - SYSBUF        
      NZ    = IBUF1 - 1        
      IF (NZ .LE. 0) GO TO 9908        
C        
C     READ DATA BLOCK TOL (TIME OUTPUT LIST).        
C     LIST OF OUTPUT TIME VALUES ARE STORED IN TOL HEADER.        
C        
      FILE = TOL        
      ITOL = 1        
      CALL FNAME (FILE,FNAM)        
      CALL OPEN (*9901,FILE,Z(IBUF1),0)        
      CALL FREAD (FILE,DUM,2,0)        
      CALL READ (*9902,*10,FILE,Z(ITOL),NZ,1,NTIMES)        
C        
C     INSUFFICIENT CORE TO HOLD ALL TIMES.        
C        
      GO TO 9908        
C        
   10 CALL CLOSE (FILE,1)        
C        
      NZ   = NZ - NTIMES        
      NEXT = NTIMES + 1        
      IF (NZ .LE. 0) GO TO 9908        
C        
C     DEFINE PARAMETER NTSTEPS.        
C        
C     IF (CYCIO .EQ. -1) NTSTEPS = (NTIMES*FKMAX)/FKMAX        
C     IF (CYCIO .EQ. +1) NTSTEPS = (NTIMES*NSEGS)/NSEGS        
C        
      NTSTPS = NTIMES        
C        
C     SET DEFAULT VALUE OF PARAMETER LMAX.        
C        
      IF (LMAX .LT. 0) LMAX = NTSTPS/2        
C        
C     DEFINE PARAMETER FLMAX        
C        
      KK = (NTSTPS/2)*2        
      IF (KK .NE. NTSTPS) GO TO 20        
C        
C     NTSTPS IS EVEN.        
C        
      IF (LMAX .NE. NTSTPS/2) GO TO 20        
      FLMAX = NTSTPS        
      GO TO 30        
C        
C     NTSTPS IS ODD.        
C        
   20 FLMAX = 2*LMAX + 1        
C        
   30 CONTINUE        
C        
C     GENERATE DATA BLOCKS FRL AND FOL BY CONVERTING TOL TIMES        
C     TO THE FREQUENCY DOMAIN.        
C        
      NFREQ= FLMAX        
      IFOL = NEXT        
      NEXT = IFOL + NFREQ        
      NZ   = NZ   - NFREQ        
      IF (NZ .LE. 0) GO TO 9908        
C        
C     GENERATE FREQUENCY LIST FROM TOL TIME LIST.        
C        
      Z(IFOL) = 0.0        
      IF (NFREQ .LE. 1) GO TO 60        
C        
      PERIOD = DBLE(Z(ITOL+1)) + DBLE(Z(ITOL+NTIMES-1))        
      FREQ   = 1.0D0/PERIOD        
      FACT   = 1.0D0        
C        
      IFREQ1 = IFOL + 1        
      IFREQ2 = IFOL + NFREQ - 1        
C        
      DO 50 IFREQ = IFREQ1,IFREQ2,2        
      Z(IFREQ)   = FACT*FREQ        
      Z(IFREQ+1) = Z(IFREQ)        
      FACT       = FACT + 1.0D0        
   50 CONTINUE        
C        
      KK = (NFREQ/2)*2        
      IF (KK .NE. NFREQ) GO TO 60        
      Z(IFREQ2) = FACT*FREQ        
C        
   60 CONTINUE        
C        
C     OUTPUT FOL TABLE (FREQUENCY OUTPUT RESPONSE LIST).        
C        
      FILE = FOL        
      CALL FNAME (FILE,FNAM)        
      CALL OPEN (*9901,FILE,Z(IBUF1),1)        
      CALL WRITE (FILE,FNAM,2,0)        
      CALL WRITE (FILE,Z(IFOL),NFREQ,1)        
      CALL CLOSE (FILE,1)        
C        
      TRL(1) = FILE        
      TRL(2) = NFREQ        
      TRL(3) = 1        
      TRL(4) = 0        
      TRL(5) = 0        
      TRL(6) = 0        
      TRL(7) = 0        
      CALL WRTTRL (TRL)        
C        
C     GENERATE DATA BLOCK FRL FROM FOL (W = F*2*PI).        
C     USE SAME CORE WHERE FOL IS STORED.        
C        
      DO 70 IFREQ = IFREQ1,IFREQ2        
      Z(IFREQ) = Z(IFREQ)*DTWOPI        
   70 CONTINUE        
C        
C     OUTPUT FRL TABLE (FREQUENCY RESPONSE LIST).        
C        
      FILE = FRL        
      CALL FNAME (FILE,FNAM)        
      CALL OPEN (*9901,FILE,Z(IBUF1),1)        
      CALL WRITE (FILE,FNAM,2,0)        
      CALL WRITE (FILE,1,1,1)        
      CALL WRITE (FILE,Z(IFOL),NFREQ,1)        
      CALL CLOSE (FILE,1)        
C        
      TRL(1) = FILE        
      TRL(2) = 1        
      TRL(3) = 0        
      TRL(4) = 0        
      TRL(5) = 0        
      TRL(6) = 0        
      TRL(7) = 0        
      CALL WRTTRL (TRL)        
C        
C     GENERATE MATRIX DATA BLOCKS REORDER1 AND REORDER2 USED FOR        
C     REORDERING COLUMNS OF A MATRIX BY POST-MULTIPLYING THE MATRIX     
C     WHOSE COLUMNS ARE TO BE REORDERED.        
C        
      K1 = NTSTPS        
      K3 = FLMAX        
      IF (CYCIO .EQ. -1) K2 = FKMAX        
      IF (CYCIO .EQ. +1) K2 = NSEGS        
C        
C     GENERATE MATRIX REORDER1        
C        
      CALL FVRS2A (REORD1,K1,K2,NORO1,Z(IBUF1))        
C        
C     GENERATE MATRIX REORDER2        
C        
      CALL FVRS2A (REORD2,K2,K3,NORO2,Z(IBUF1))        
C        
      RETURN        
C        
C     ERROR PROCESSING        
C        
C     DATA SET NOT IN FIST        
C        
 9901 IP1 = -1        
      GO TO 9999        
C        
C     E-O-F ENCOUNTERED        
C        
 9902 IP1 = -2        
      GO TO 9999        
C        
C     E-O-L ENCOUNTERED        
C        
C9903 IP1 = -3        
C     GO TO 9999        
C        
C     NOT ENOUGH CORE        
C        
 9908 IP1 = -8        
      GO TO 9999        
 9999 CALL MESAGE (IP1,FILE,MODNAM)        
      CALL MESAGE (-37,0,MODNAM)        
C        
      RETURN        
      END        
