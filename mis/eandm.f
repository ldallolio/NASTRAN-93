      SUBROUTINE EANDM (ITYPE,IDO,NEXTZ,LCORE,NBDYS,ALL,NELOUT)        
C        
C     COMPUTES ADDITIONAL LOAD IN ZIEKIEWICZ PAPER DUE TO SPECIFIED     
C     MAGNETIC FIELD OR CURRENT LOOP        
C        
C     ITYPE = 20  SPCFLD        
C     ITYPE = 21  CEMLOOP        
C     ITYPE = 22  GEMLOOP        
C     ITYPE = 23  MDIPOLE        
C     ITYPE = 24  REMFLUX        
C     IDO   = NUMBER OF CARDS OF PRESENT TYPE        
C     NEXTZ = NEXT AVAILABLE POINTER INTO OPEN CORE        
C     LAST AVAILABLE POINTER INTO OPEN CORE        
C     *** ALL CEMLOOP, SPCFLD, GEMLOOP, AND MDIPOLE CARDS WERE COMBINED 
C     INTO ONE SPCFLD-TYPE CARD WITH 3*NROWSP WORDS-HCX, HCY, HCZ AT    
C     EACH POINT AND IS INDICATED BY ITYPE =-20. THESE 3*NROWSP WORDS   
C     ARE WRITTEN TO HCFLDS FOR LATER USE. THE OTHER CARDS ARE STILL ON 
C     SLT FOR USE IN THE NUMERICAL INTEGRATION.        
C        
      LOGICAL         DONE        
      INTEGER         FILE,BUF1,SYSBUF,EST,SLT,ELTYPE,ESTWDS,OUTPT,SCR6,
     1                HCFLDS,MCB(7),REMFLS,MCB1(7),MCB2(7)        
      DIMENSION       IZ(1),NAM(2),NECPT(1),NAME(2)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /BLANK / NROWSP        
      COMMON /SYSTEM/ KSYSTM(64)        
      COMMON /EMECPT/ ECPT(200)        
      COMMON /PACKX / ITA,ITB,II,JJ,INCUR        
      COMMON /ZBLPKX/ A(4),IROW        
CZZ   COMMON /ZZSSA1/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /GPTA1 / NELEMS,LAST,INCR,NE(1)        
      EQUIVALENCE     (KSYSTM(1),SYSBUF),(KSYSTM(2),OUTPT),(Z(1),IZ(1)),
     1                (KSYSTM(56),ITHRML),(ECPT(1),NECPT(1))        
      DATA    NAM   / 4HEAND,4HM              /        
      DATA    EST   , SLT, HCFLDS,REMFLS,SCR6 /        
     1        105   , 205, 304,   305,   306  /        
      DATA    MCB   / 304, 0, 0, 2, 1, 0, 0   /        
      DATA    MCB1  / 305, 0, 0, 2, 1, 0, 0   /        
      DATA    DONE  / .FALSE.                 /        
C        
C     CHECK IF THERMAL FORMULATION        
C        
      IF (ITHRML .EQ. 0) RETURN        
C        
C     READ A CARD TYPE FROM SLT. TYPE=-20 IS THE COMBINATION HC FOR ALL 
C     CARD TYPES EXCEPT REMFLUX AND SIGNIFIES END OF A SUBCASE. READ AND
C     PACK IT. SAME FOR TYPE = 24(REMFLUX). FOR TYPES 20-24, COMPUTE    
C     LOAD = INTEGRAL(GRAD(NI)*MU*HC)*D(VOL). WE WILL USE NUMERICAL     
C     INTEGRATION FOR ITYPE=24-REMFLUX-ONLY ONE CARD GIVING FLUX IN     
C     EACH ELEMENT COMPUTE INTEGRAL(GRAD NI*BR)*D(VOL)        
C        
      BUF1  = LCORE - SYSBUF + 1        
      ICORE = BUF1  - 1        
      IF (NEXTZ .GT. BUF1) GO TO 420        
C        
      IF (ITYPE.NE.-20 .AND. ITYPE.NE.24) GO TO 40        
      IF (IDO .NE. 1) GO TO 300        
C        
C     END OF SUBCASE-WRAP UP SCR6 AND CALL HCCOM TO COMBINE CENTROID    
C     RESULTS IF NOT REMFLUX, CALL HCCOM NOW.IF REMFLUX, WAIT UNTIL     
C     KCOUNT IS SET.        
C        
      CALL CLOSE (SCR6,1)        
      IF (ITYPE.EQ.-20) CALL HCCOM (ITYPE,LCORE,ICORE,NEXTZ,KCOUNT)     
      JJ = NROWSP        
C        
C     ITYPE=-20 OR +24--END OF SUBCASE. IF +24, WRITE ZEROS TO HCFLDS   
C     AND HCCENS AND REMFLUX VECTOR TO REMFLS. THEN CONTINUE ON TO      
C     COMPUTE LOADS. IF ITYPE=-20, WRITE ZRROS TO REMFLS, GRID POINT    
C     HC VALUES TO HCFLDS AND CENTROIDAL VALUES TO HCCENS (ALREADY DONE 
C     IN HCCOM). FOR ITYPE=-20, NO FURTHER PROCESSING IS DONE SINCE     
C     LOADS HAVE ALREADY BEEN COMPUTED.        
C        
      ITA = 1        
      ITB = 1        
      II  = 1        
      JJ  = 3*NROWSP        
      INCUR  = 1        
      MCB(3) = JJ        
      MCB2(1)= EST        
      CALL RDTRL (MCB2)        
      NEL = MCB2(2)        
      JJ1 = 3*NEL        
      MCB1(3)= JJ1        
C        
C     READ IN THE ONE SPCFLD OR REMFLUX-TYPE CARD        
C        
      NWORDS = 3*NROWSP        
      IF (ITYPE .NE. 24) GO TO 10        
      NWORDS = 3*NEL        
      JJ  = NWORDS        
      JJ1 = 3*NROWSP        
   10 ISTART = NEXTZ        
      IF (NEXTZ+NWORDS-1 .GT. ICORE) GO TO 420        
      CALL FREAD (SLT,Z(NEXTZ),NWORDS,0)        
C        
C     CREATE A ZERO VECTOR FOR EITHER REMFLS OR HCFLDS(WHICHEVER IS NOT 
C     USED IN THIS SET ID-REMEMBER THAT SPCFLD AND REMFLUX CANNOT HAVE  
C     THE SAME SET ID        
C        
C     PACK THE 3*NROWSP HC FIELD OUT TO BE USED LATER BY EMFLD. HCFLDS  
C     WILL CONTAIN ONE COLUMN PER CASE CONTROL SIMPLE SELECTION        
C     (SIMPLE LOADS ON LOAD CARDS ARE INCLUDED). COMBIN WILL COMBINE    
C     FOR LOAD BULK DATA CARDS AND PUT LOADS IN ORDER OF SELECTION ONTO 
C     HCFL (SAME HOLDS FOR 3*NEL WORDS OF REMFLS)        
C        
      IF (ITYPE .EQ. 24) GO TO 20        
      CALL PACK (Z(NEXTZ),HCFLDS,MCB)        
      CALL WRTTRL (MCB)        
      JJ = JJ1        
      CALL BLDPK  (1,1,REMFLS,0,0)        
      CALL BLDPKN (REMFLS,0,MCB1)        
      CALL WRTTRL (MCB1)        
      GO TO 30        
   20 CALL PACK(Z (NEXTZ),REMFLS,MCB1)        
      CALL WRTTRL (MCB1)        
      JJ = JJ1        
      CALL BLDPK  (1,1,HCFLDS,0,0)        
      CALL BLDPKN (HCFLDS,0,MCB)        
      CALL WRTTRL (MCB)        
C        
C     RETURN JJ TO VALUE EXPECTED IN EXTERN        
C        
   30 JJ = NROWSP        
      IF (ITYPE .EQ. -20) RETURN        
C        
C     GET INFO FROM EST        
C        
   40 FILE = EST        
      CALL GOPEN (EST,Z(BUF1),0)        
      NCOUNT = 0        
      IF (.NOT.DONE) KCOUNT = 0        
C        
C     READ IN ALL CARDS OF THIS TYPE FOR THIS SUBCASE. NO NEED TO READ  
C     IN THE ONE REMFLUX CARD SINCE IT WAS DONE ABOVE.        
C        
      IJK = ITYPE - 19        
      GO TO (50,60,70,80,100), IJK        
   50 IWORDS = 3*NROWSP        
      IF (IDO .NE. 1) GO TO 300        
      GO TO 90        
   60 IWORDS = 12        
      GO TO 90        
   70 IWORDS = 48        
      GO TO 90        
   80 IWORDS = 9        
   90 NWORDS = IWORDS*IDO        
      IF (NEXTZ+NWORDS-1 .GT. ICORE) GO TO 420        
      CALL FREAD (SLT,Z(NEXTZ),NWORDS,0)        
      ISTART = NEXTZ        
C        
  100 CALL READ (*260,*410,EST,ELTYPE,1,0,IFLAG)        
      IDX = (ELTYPE-1)*INCR        
      ESTWDS = NE(IDX+12)        
      NGRIDS = NE(IDX+10)        
      NAME(1)= NE(IDX+1)        
      NAME(2)= NE(IDX+2)        
C        
  120 CALL READ (*400,*100,EST,ECPT,ESTWDS,0,IFLAG)        
      NCOUNT = NCOUNT + 1        
      IF (DONE) GO TO 130        
      IF (ELTYPE .LT. 65) KCOUNT = KCOUNT + 3        
      IF (ELTYPE .EQ. 65) KCOUNT = KCOUNT + 27        
      IF (ELTYPE.EQ.66 .OR. ELTYPE.EQ.67) KCOUNT = KCOUNT + 63        
      IF (ELTYPE .EQ. 80) KCOUNT = KCOUNT + 27        
C        
  130 IF (ELTYPE .GT. 80) GO TO 230        
      GO TO (200,230,200,230,230,210,230,230,210,200,        
     1       230,230,230,230,230,210,210,210,210,230,        
     2       230,230,230,230,230,230,230,230,230,230,        
     3       230,230,230,200,230,210,210,230,220,220,        
     4       220,220,230,230,230,230,230,230,230,230,        
     5       230,230,230,230,230,230,230,230,230,230,        
     6       230,230,230,230,220,220,220,230,230,230,        
     7       230,230,230,230,230,230,230,230,230,210), ELTYPE        
C        
  200 CALL EM1D (ELTYPE,ISTART,ITYPE,NCOUNT,IDO,IWORDS,NBDYS,ALL,NELOUT)
      GO TO 120        
  210 CALL EM2D (ELTYPE,ISTART,ITYPE,NCOUNT,IDO,IWORDS,NBDYS,ALL,NELOUT)
      GO TO 120        
  220 CALL EM3D (ELTYPE,ISTART,ITYPE,NCOUNT,IDO,IWORDS,NBDYS,ALL,NELOUT)
      GO TO 120        
C        
  230 WRITE  (OUTPT,240) UFM,NAME        
  240 FORMAT (A23,', ELEMENT TYPE ',2A4,' WAS USED IN AN E AND M ',     
     1       'PROBLEM. NOT A LEGAL TYPE')        
  250 CALL MESAGE (-61,0,0)        
C        
C     DONE        
C        
  260 CALL CLOSE (EST,1)        
      IF (ITYPE .EQ. 24) GO TO 270        
      CALL WRITE (SCR6,0,0,1)        
      GO TO 280        
  270 CALL HCCOM (ITYPE,LCORE,ICORE,NEXTZ,KCOUNT)        
      JJ = NROWSP        
  280 DONE =.TRUE.        
      RETURN        
C        
C     FATAL ERROR MESSAGES        
C        
  300 WRITE  (OUTPT,310) UFM,NAM        
  310 FORMAT (A23,', LOGIC ERROR IN SUBROUTINE ',2A4,        
     1       '. ONLY ONE SPCFLD OR REMFLUX SHOULD NOW EXIST')        
      GO TO 250        
C        
  400 N = -2        
      GO TO 430        
  410 N = -3        
      GO TO 430        
  420 N = -8        
      FILE = 0        
  430 CALL MESAGE (N,FILE,NAM)        
      RETURN        
      END        
