      SUBROUTINE DLAMBY(INPUT,MATOUT,SKJ)        
C        
C     DRIVER FOR DOUBLET LATTICE WITH BODIES        
C        
      INTEGER         ECORE,SYSBUF,IZ(1),TSKJ,SKJ        
      INTEGER         SCR1,SCR2,SCR3,SCR4,SCR5        
      DIMENSION       NAME(2)        
      COMMON /SYSTEM/ SYSBUF        
CZZ   COMMON /ZZDAMB/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /BLANK / NK,NJ        
      COMMON /AMGMN / MCB(7),NROW,ND,NE,REFC,FMACH,RFK,TSKJ(7),ISK,NSK  
      COMMON /DLBDY / NJ1,NK1,NP,NB,NTP,NBZ,NBY,NTZ,NTY,NT0,NTZS,NTYS,  
     1                INC,INS,INB,INAS,IZIN,IYIN,INBEA1,INBEA2,INSBEA,  
     2                IZB,IYB,IAVR,IARB,INFL,IXLE,IXTE,INT121,INT122,   
     3                IZS,IYS,ICS,IEE,ISG,ICG,IXIJ,IX,IDELX,IXIC,IXLAM, 
     4                IA0,IXIS1,IXIS2,IA0P,IRIA,INASB,IFLA1,IFLA2,      
     5                ITH1A,ITH2A,ECORE,NEXT,SCR1,SCR2,SCR3,SCR4,SCR5,  
     6                NTBE        
      EQUIVALENCE     (IZ(1),Z(1))        
      DATA   NAME /4HDLAM,4HBY  /        
      DATA NHAERO,NHPOIN,NHCORE / 4HAERO,4HPOIN,4HCORE/        
C        
      SCR1 = 301        
      SCR2 = 302        
      SCR3 = 303        
      SCR4 = 304        
      SCR5 = 305        
C        
C     GET CORE THEN SET POINTERS TO ACPT TABLE ARRAYS        
C        
      ECORE = KORSZ(IZ) - 4*SYSBUF        
C        
C     READ LENGTHS OF ARRAYS        
C        
      CALL FREAD(INPUT,NJ1,13,0)        
C        
C     COMPUTE POINTERS TO OPEN CORE        
C        
      LNS = INC        
      INC = 1        
      INS = INC        
      INB = INS + NP        
      INAS = INB + NP        
      IZIN = INAS        
      IYIN = IZIN        
      INBEA1 = IYIN + NP        
      INBEA2 = INBEA1 + NB        
      INSBEA = INBEA2 + NB        
      IZB = INSBEA + NB        
      IYB = IZB + NB        
      IAVR = IYB + NB        
      IARB = IAVR + NB        
      INFL = IARB + NB        
      IXLE = INFL + NB        
      IXTE = IXLE + NB        
      INT121 = IXTE + NB        
      INT122 = INT121 + NB        
      IZS = INT122 + NB        
      N = 3*NP + 12 * NB        
C        
C     READ FIXED ARRAYS        
C        
      IF(N .GT. ECORE) GO TO 998        
      CALL FREAD(INPUT,IZ,N,0)        
C        
C     GET LENGTHS OF VARIABLE ARRAYS, PANELS THEN BODIES        
C        
      LNAS = 0        
      IF(NP .EQ. 0) GO TO 20        
      DO 10 I=1,NP        
   10 LNAS = LNAS + IZ(INAS+I-1)        
   20 LNB = 0        
      LNSB = 0        
      LNFL = 0        
      LT1 = 0        
      LT2 = 0        
      DO 30 I=1,NB        
      K = I-1        
      LNB = LNB + IZ(INBEA1+K)        
      LNSB = LNSB + IZ(INSBEA+K)        
      LNFL = LNFL + IZ(INFL+K)        
      LT1 = LT1 + IZ(INT121+K)        
   30 LT2 = LT2 + IZ(INT122+K)        
      NTBE = NTP+LNB        
C        
C     READ VARIABLE  ARRAYS AND SET POINTERS TO CORE        
C        
      NEXT = N+1        
      N = 2*NB + 5*LNS + 4*NTP + 3*LNB + 4*LNSB + LNAS + 2*LNFL        
     *  + LT1 + LT2        
      IF(NEXT+N+4*NJ.GE.ECORE) GO TO 998        
      CALL FREAD(INPUT,IZ(NEXT),N,1)        
      NEXT = NEXT + N + 1        
      IYS = IZS + NB + LNS        
      ICS = IYS        
      IEE = ICS + NB + LNS        
      ISG = IEE + LNS        
      ICG = ISG + LNS        
      IXIJ = ICG        
      IX = IXIJ + LNS        
      IDELX = IX + NTP + LNB        
      IXIC = IDELX + NTP + LNB        
      IXLAM = IXIC + NTP        
      IA0 = IXLAM + NTP        
      IXIS1 = IA0 + LNSB        
      IXIS2 = IXIS1 + LNSB        
      IA0P = IXIS2 + LNSB        
      IRIA = IA0P + LNSB        
      INASB = IRIA + LNB        
      IFLA1 = INASB + LNAS        
      IFLA2 = IFLA1 + LNFL        
      ITH1A = IFLA2 + LNFL        
      ITH2A = ITH1A + LT1        
C        
C     BUILD A MATRIX        
C        
      CALL BUG(NHAERO,100,ND,5)        
      CALL BUG(NHPOIN,100,NJ1,59)        
      CALL BUG(NHCORE,100,Z,NEXT)        
      N1 = NEXT        
      N = NEXT + 2*NTBE        
      NEXT = NEXT + 4*NTBE        
      IF(NT0 .NE. 0) CALL GENDSB(Z(INC),Z(INB),Z(ISG),Z(ICG),Z(INFL),   
     *   Z(INBEA1),Z(INBEA2),Z(IFLA1),Z(IFLA2),Z(N1),Z(N1),Z(N))        
      N = NTZS + NTYS        
      NEXT = N1        
      BETA = SQRT(1.0-FMACH**2)        
      IF( NT0 .NE. 0 .AND. N .NE. 0) CALL AMGROD(Z(N1),BETA)        
      CALL AMGSBA(MATOUT,Z(IA0),Z(IARB),Z(INSBEA),Z(N1),Z(IYB),Z(IZB))  
      NROW = NROW + NJ1        
C        
C     BUILD SKJ MATRIX BE SURE TO BUMP ISK NSK        
C        
      CALL AMGBFS(SKJ,Z(IEE),Z(IDELX),Z(INC),Z(INB),Z(IXIS2),Z(IXIS1),  
     *      Z(IA0),Z(IA0P),Z(INSBEA))        
 1000 RETURN        
C        
C     ERROR MESSAGES        
C        
  998 CALL MESAGE(-8,0,NAME)        
      GO TO 1000        
      END        
