      SUBROUTINE RAND7 (IFILE,NFILE,PSDL,DIT,ICOUP,NFREQ,NPSDL,NTAU,    
     1                  LTAB,CASECC,XYCDB)        
C        
C     STORES STUFF IN CORE FOR LATER RANDOM ANALSIS        
C        
      INTEGER ITLIST(7),PSDL,FILE,SYSBUF,DIT,NAME(2),CASECC,        
     1        IFILE(1),XYCDB,IPSDL(6)        
      REAL    Z(1)        
C        
      COMMON /SYSTEM/ SYSBUF        
CZZ   COMMON /ZZRAND/ IZ(1)        
      COMMON /ZZZZZZ/ IZ(1)        
C        
      EQUIVALENCE (Z(1),IZ(1))        
C        
      DATA NAME  /4HRAND,1H7/        
      DATA ITLIST/2,  55,25,1,  56,26,5 /        
C *****        
C     IDENTIFICATION OF VARIABLES        
C *****        
C     IFILE    ARRAY OF INPUT FILES        
C     NFILE    LENGTH OF IFILE ARRAY        
C     PSDL     POWER SPECTRAL DENSITY LISTS FROM DPD        
C     DIT      DIRECT INPUT TABLES        
C     ICOUP    COUPLED,UNCOUPLED, OR NOGO FLAG        
C     NFREQ    NUMBER OF FRENQUICIES        
C     NPSDL    NUMBER OF PSDL  SETS        
C     NTAU     NUMBER OF TAUS        
C     LTAB     LENGTH OF DATA FOR TAB ROUTINE        
C     CASECC   CASECONTROL FILE        
C     SYSBUF   LENGTH OF ONE GINO BUFFER        
C     NTABL    NUMBER OF UNIQUE TABLE ID-S        
C     ITABL    POINTER TO LIST OF TABLE ID-S        
C        
C        
C     BUILD FREQUENCY LIST        
C        
      ICOUP = 0        
      LCORE = KORSZ(IZ)        
      IBUF1 = LCORE-SYSBUF        
C        
C     XYCDB MUST BE PRESENT        
C        
      FILE = XYCDB        
      CALL OPEN (*700,XYCDB,IZ(IBUF1),0)        
      CALL CLOSE (XYCDB,1)        
      LCORE = IBUF1-1        
C        
C     EXTRACT  SET NO FROM CASECC        
C        
      CALL GOPEN (CASECC,IZ(IBUF1),0)        
      CALL FREAD (CASECC,IZ,166,1)        
      I163  = 163        
      IRAND = IZ(I163)        
      CALL CLOSE (CASECC,1)        
      IF (IRAND .EQ. 0) GO TO 700        
C        
C     FIND DATA FILE        
C        
      DO 10 I = 1,NFILE        
      FILE = IFILE(I)        
      CALL OPEN (*10,FILE,IZ(IBUF1),0)        
      CALL SKPREC (FILE,1)        
      CALL FREAD (FILE,IZ,10,1)        
      I10 = 10        
      LEN = IZ(I10)-1        
      NFREQ = 0        
C        
C     EXTRACT FREQUENCIES        
C        
    5 CALL READ (*910,*30,FILE,F,1,0,J)        
      CALL FREAD (FILE,IZ,-LEN,0)        
      NFREQ = NFREQ +1        
      Z(NFREQ) = F        
      GO TO  5        
   30 CALL CLOSE (FILE,1)        
      GO TO 40        
   10 CONTINUE        
C        
C     NO DATA FILES--EXIT        
C        
  700 ICOUP = -1        
      GO TO 90        
C        
C     BRING IN PSDL CARDS        
C        
   40 LCORE = LCORE -NFREQ        
      FILE  = PSDL        
      CALL OPEN (*700,PSDL,Z(IBUF1),0)        
      L = NFREQ+1        
      NPSDL = 0        
      ITAU  =-1        
      CALL READ (*910,*41,PSDL,IZ(NFREQ+1),LCORE,0,J)        
      GO TO 980        
   41 K = NFREQ +3        
      IF (J .EQ. 2) GO TO 45        
      J = K+J-1        
C        
C     DETERMINE RECORD THAT RANDOM TAU-S ARE IN        
C        
      DO 42 I = K,J        
      IF (IZ(I) .EQ. IRAND) GO TO 43        
   42 CONTINUE        
      ITAU = -1        
      GO TO 45        
C        
C     FOUND RANDT CARDS        
C        
   43 ITAU = I-K        
C        
C     FIND SELECTED PSDL CARDS        
C        
   45 CALL READ (*910,*47,PSDL,IPSDL(1),6,0,J)        
      IF (IPSDL(1) .NE. IRAND) GO TO 45        
      NPSDL   = NPSDL+1        
      IZ(L  ) = IPSDL(2)        
      IZ(L+1) = IPSDL(3)        
      IZ(L+2) = IPSDL(4)        
      IZ(L+3) = IPSDL(5)        
      IZ(L+4) = IPSDL(6)        
      L = L+5        
      GO TO 45        
   47 IF (NPSDL .NE. 0) GO TO 48        
C        
C     UNABLE TO FIND SELECTED PSDL CARDS        
C        
      CALL CLOSE (PSDL,1)        
      GO TO 700        
C        
C     POSITION TAPE FOR TAUS        
C        
   48 IF (ITAU .LE. 0) GO TO 49        
      CALL SKPREC (PSDL,ITAU)        
   49 LCORE = LCORE-NPSDL*5        
C        
C     EXTRACT LIST OF TABLES  AND CHECK FOR COUPLED SYSTEM        
C        
      JJ = NFREQ +1        
      K  = NFREQ +5*NPSDL        
      NTABL = 0        
      ITABL = IBUF1-1        
      DO 60  I = JJ,K,5        
      IF (IZ(I) .EQ. IZ(I+1)) GO TO 61        
C        
C     COUPLED        
C        
      ICOUP =1        
   61 IF (NTABL .EQ. 0) GO TO 62        
      DO 63 J=1,NTABL        
      L = ITABL +J        
      IF (IZ(L) .EQ. IZ(I+4)) GO TO 60        
   63 CONTINUE        
C        
C     STORE TABLE ID        
C        
   62 NTABL = NTABL +1        
      IZ(ITABL) = IZ(I+4)        
      ITABL = ITABL -1        
   60 CONTINUE        
      IZ(ITABL) = NTABL        
C        
C     BRING IN  TAU-S        
C        
      NTAU  = 0        
      LCORE = LCORE- NTABL-1        
      IF(ITAU .EQ. -1) GO TO 70        
      CALL READ (*70,*70,PSDL,Z(K+1),LCORE,0,NTAU)        
      GO TO 980        
   70 CALL CLOSE (PSDL,1)        
C        
C     SETUP FOR TABLES        
C        
      LCORE = LCORE -NTAU        
      LTAB  = 0        
      IF(NTABL .EQ. 0) GO TO 90        
      L =  K +NTAU+1        
      CALL PRETAB (DIT,IZ(L),Z(L),IZ(IBUF1),LCORE,LTAB,IZ(ITABL),ITLIST 
     1 (1))        
   90 RETURN        
C        
C     FILE ERRORS        
C        
  901 CALL MESAGE (IP1,FILE,NAME)        
  910 IP1 =-2        
      GO TO 901        
  980 IP1= -8        
      GO TO 901        
      END        
