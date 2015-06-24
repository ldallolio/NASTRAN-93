      SUBROUTINE SD2RHD (ISTYP,ISETUP)        
C        
C     THIS ROUTINE WRITES HEADING FOR PRECISION CHECK IN SDR2E.        
C     WORDS 1,2,6 AND 7 PRESET BY CALLING ROUTINE.        
C     ISETUP.NE.0 FIRST CALL.        
C        
      INTEGER BRANCH, LDMD(8)  ,ISTYP(7)        
      COMMON /SDR2X4/ DUMMY(50),BRANCH        
      COMMON /SYSTEM/ ISYSB    ,NOUT        
      EQUIVALENCE     (ISTYP6,RSTYP6), (ISTYP7,RSTYP7)        
      DATA    LDMD  / 4HLOAD, 4HMODE, 4H, FR, 4HEQ.=, 4H, EI, 4HGEN=,   
     1                4H, TI, 4HME =  /        
C        
      IF (ISETUP .EQ. 0) GO TO 1510        
      GO TO (1501,1503,1501,1501,1503,1505,1501,1507,1507,1501), BRANCH 
C        
C     STATICS        
C        
 1501 N1 = 3        
      ISTYP(3) = LDMD(1)        
      GO TO 1510        
C        
C     EIGR,FREQ        
C        
 1503 N1 = 6        
      ISTYP(3) = LDMD(2)        
      ISTYP(4) = LDMD(3)        
      ISTYP(5) = LDMD(4)        
      GO TO 1510        
C        
C     TRANSIENT        
C        
 1505 N1 = 6        
      ISTYP(3) = LDMD(1)        
      ISTYP(4) = LDMD(7)        
      ISTYP(5) = LDMD(8)        
      GO TO 1510        
C        
C     BUCKLING, COMPLEX EIGENVALUE        
C        
 1507 N1 = 6        
      ISTYP(3) = LDMD(2)        
      ISTYP(4) = LDMD(5)        
      ISTYP(5) = LDMD(6)        
      IF (BRANCH.EQ.9) N1 = 7        
C        
 1510 CALL PAGE2 (3)        
      ISTYP6 = ISTYP(6)        
      ISTYP7 = ISTYP(7)        
      IF (N1 .EQ. 3) WRITE(NOUT,1512) (ISTYP(I),I=1,N1)        
      IF (N1 .EQ. 6) WRITE(NOUT,1512) (ISTYP(I),I=1,5),RSTYP6        
      IF (N1 .EQ. 7) WRITE(NOUT,1512) (ISTYP(I),I=1,5),RSTYP6,RSTYP7    
 1512 FORMAT (1H0,5X,45HE L E M E N T   P R E C I S I O N   C H E C K,  
     1   /4X,32HSIGNIFICANT DIGITS FOR SUBCASE =,I7,1H,,I7,3H = ,3A4,   
     2   1P,2E15.6)        
      RETURN        
      END        
