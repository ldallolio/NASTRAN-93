      SUBROUTINE CMCONT        
C        
C     THIS ROUTINE DEFINES THE CONNECTION ENTRIES IN TERMS OF IP        
C     NUMBERS.        
C        
      EXTERNAL        LSHIFT,RSHIFT,ANDF        
      LOGICAL         ODD        
      INTEGER         SCSFIL,SCMCON,BUF3,BUF4,OFILE,SCR1,SCR2,BUF1,BUF2,
     1                SCORE,ISTRT(100),ILEN(100),II(9),IO(9),ANDF,      
     2                RSHIFT,DOF(6),IP(6),AAA(2),SCCONN,COMBO,OUTT      
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /CMB001/ SCR1,SCR2,SCBDAT,SCSFIL,SCCONN,SCMCON,SCTOC,      
     1                GEOM4,CASECC        
      COMMON /CMB002/ BUF1,BUF2,BUF3,BUF4,BUF5,SCORE,LCORE,INPT,OUTT    
      COMMON /CMB003/ COMBO(7,5),CONSET,IAUTO,TOLER,NPSUB        
      COMMON /CMBFND/ INAM(2),IERR        
      COMMON /BLANK / STEP,IDRY        
CZZ   COMMON /ZZCOMB/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      DATA    AAA   / 4HCMCO,4HNT   /        
C        
      ICOR  = SCORE        
      ICLEN = LCORE        
      MFILE = SCSFIL        
      CALL OPEN (*200,SCSFIL,Z(BUF3),0)        
      OFILE = SCR2        
      IFILE = SCR1        
      NWD   = 2 + NPSUB        
      ODD   = .FALSE.        
C        
      DO 120 I = 1,NPSUB        
      ODD   = .NOT.ODD        
      NCSUB = COMBO(I,5)        
C        
C     READ IN EQSS FOR ITH PSEUDO-STRUCTURE        
C        
      MFILE = IFILE        
      CALL OPEN (*200,IFILE,Z(BUF1),0)        
      MFILE = OFILE        
      CALL OPEN (*200,OFILE,Z(BUF2),1)        
C        
C     MOVE TO FIRST COMPONENT EQSS        
C        
      DO 20 J = 1,NCSUB        
      MFILE = SCSFIL        
      CALL READ (*210,*10,SCSFIL,Z(SCORE),LCORE,1,NNN)        
      GO TO 220        
   10 ISTRT(J) = SCORE        
      ILEN(J)  = NNN        
      SCORE = SCORE + NNN        
      LCORE = LCORE - NNN        
   20 CONTINUE        
      CALL SKPFIL (SCSFIL,1)        
C        
C     CONNECTION ENTRIES IN TERMS OF GRID POINT ID ARE ON SCR1        
C     IN THE FORM...        
C        C/CC/G1/G2/G3/G4/G5/G6/G7        
C        
C     READ CONNECTION ENTRY..        
C        
      MFILE = IFILE        
   30 CALL READ (*110,*40,IFILE,II,10,1,NNN)        
   40 CONTINUE        
      ICOMP = II(2+I)/1000000        
      IGRID = II(2+I) - 1000000*ICOMP        
      IF (IGRID .EQ. 0) GO TO 100        
C        
C     THE ABOVE RETRIEVED THE ORIGINAL GRID PT. NO., NOW FIND OUT       
C     IF IT HAS SEVERAL IP NO.        
C        
      IF (ILEN(ICOMP) .EQ. 0) GO TO 50        
      CALL GRIDIP (IGRID,ISTRT(ICOMP),ILEN(ICOMP),IP,DOF,NIP,Z,NNN )    
      IF (IERR .NE. 1) GO TO 70        
   50 IDRY = -2        
      WRITE  (OUTT,60) UFM,IGRID,COMBO(I,1),COMBO(I,2),ICOMP        
   60 FORMAT (A23,' 6535, A MANUAL CONNECTION SPECIFIES GRID ID ',I8,   
     1       ' OF PSEUDOSTRUCTURE ',2A4, /30X,        
     2       'COMPONENT STRUCTURE,I4,22H WHICH DOES NOT EXIST.')        
      GO TO 30        
   70 DO 90 J = 1,NIP        
      II2 = RSHIFT(DOF(J),26)        
      II2 = LSHIFT(II2,26)        
      DOF(J) = DOF(J) - II2        
      IO(1)  = ANDF(II(1),DOF(J))        
      IF (IO(1) .EQ. 0) GO TO 90        
      IO(2) = II(2)        
      DO 80 JJ = 1,NWD        
      IO(2+JJ) = II(2+JJ)        
   80 CONTINUE        
      IO(2+I) = IP(J)        
      CALL WRITE (OFILE,IO,NWD,1)        
   90 CONTINUE        
      GO TO 30        
  100 CALL WRITE (OFILE,II,NWD,1)        
      GO TO 30        
  110 CALL CLOSE (IFILE,1)        
      IF (I .EQ. NPSUB ) CALL CLOSE (OFILE,2)        
      IF (I .LT. NPSUB ) CALL CLOSE (OFILE,1)        
      ISAVE = IFILE        
      IFILE = OFILE        
      OFILE = ISAVE        
  120 CONTINUE        
      SCCONN = SCR1        
      IF (ODD) SCCONN = SCR2        
      IF (SCCONN .EQ. SCR1) SCR1 = 305        
      IF (SCCONN .EQ. SCR2) SCR2 = 305        
      SCORE = ICOR        
      LCORE = ICLEN        
      CALL CLOSE (SCSFIL,1)        
      RETURN        
C        
  200 IMSG = -1        
      GO TO 230        
  210 IMSG = -2        
      GO TO 230        
  220 IMSG = -8        
  230 CALL MESAGE (IMSG,MFILE,AAA)        
      RETURN        
      END        
