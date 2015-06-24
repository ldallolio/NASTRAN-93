      SUBROUTINE EQSOUT        
C        
C     THIS ROUTINE WRITES THE CONNECTION TRACE FOR A NEWLY COMBINED     
C     PSEUDOSTRUCTURE.        
C        
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF        
      INTEGER         Z,SCORE,ORF,NBOT(7),NTOP(7),CNAM        
      INTEGER         COMBO,IORDS(2)        
      INTEGER         WORDS(6),IHD(64),STRING(32),ANDF,RSHIFT        
      COMMON /CMB002/ JUNK(5),SCORE        
      COMMON /CMB003/ COMBO(7,5),CONSET,IAUTO,TOLER,NPSUB,CONECT,TRAN,  
     1                MCON,RESTCT(7,7),ISORT,ORIGIN(7,3),IPRINT        
      COMMON /CMB004/ TDAT(6),NIPNEW,CNAM(2)        
CZZ   COMMON /ZZCOMB/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /OUTPUT/ ITITL(96),IHEAD(96)        
      COMMON /MACHIN/ MACH,IHALF        
      DATA IHD/ 10*4H     , 4H   S , 4HUMMA , 4HRY O , 4HF PS , 4HEUDO ,
     1                      4HSTRU , 4HCTUR , 4HE CO , 4HNNEC , 4HTIVI ,
     2                      4HTIES , 12*4H           , 4HINTE , 4HRNAL ,
     2                      4H   I , 4HNTER ,        
     3                      4HNAL  , 4H  DE , 4HGREE , 4HS OF ,        
     4                      4H  ** ,5*4H****, 4H P S , 4H E U ,        
     5                      4H D O , 4H S T , 4H R U , 4H C T , 4H U R ,
     6                      4H E   , 4H N A , 4H M E , 4H S * ,3*4H****,
     7                      3*4H      /        
      DATA WORDS / 4HPOIN , 4HT NO , 4HFREE , 4HDOM  , 4HDOF  , 4HNO   /
      DATA IBLANK,NHEQSS  / 4H     , 4HEQSS /        
C        
      IF (ANDF(RSHIFT(IPRINT,11),1) .NE. 1) RETURN        
      CALL SFETCH (CNAM,NHEQSS,1,ITEST)        
      CALL SUREAD (Z(SCORE),-1,NOUT,ITEST)        
      NCOMP = Z(SCORE+2)        
      NWRD  = NOUT - 4        
      ISTEQS= SCORE + NWRD        
C        
C     MOVE COMPONENT SUBSTRUCTURE NAMES INTO FIRST NWRD OF OPEN CORE.   
C        
      DO 100 I=1,NWRD        
      II = I - 1        
      Z(SCORE+II) = Z(SCORE+II+4)        
  100 CONTINUE        
      DO 1 I=1,32        
      STRING(I) = IBLANK        
    1 CONTINUE        
      CALL PUSH (WORDS(1),STRING, 5,8,0)        
      CALL PUSH (WORDS(5),STRING,17,8,0)        
      CALL PUSH (WORDS(3),STRING,29,8,0)        
      DO 2 I=1,NPSUB        
      IORDS(1) = COMBO(I,1)        
      IORDS(2) = COMBO(I,2)        
      LOC = 39+11*(I-1)        
      CALL PUSH (IORDS(1),STRING,LOC,8,0)        
    2 CONTINUE        
      DO 3 I=1,64        
      IHEAD(I) = IHD(I)        
    3 CONTINUE        
      DO 4 I=65,96        
      IHEAD(I) = STRING(I-64)        
    4 CONTINUE        
      CALL PAGE        
C        
C     COMPUTE FIRST AND LAST COMPONENT SUBSTRUCTURE ID NUMBERS        
C     FOR EACH PSEUDOSTRUCTURE.        
C        
      NBOT(1) = 1        
      DO 110 I=1,NPSUB        
      NTOP(I) = NBOT(I) + COMBO(I,5) - 1        
      II = I + 1        
      IF (I .EQ. NPSUB) GO TO 110        
      NBOT(II) = NTOP(I) + 1        
  110 CONTINUE        
C        
C     READ EQSS INTO OPEN CORE STARTING AT LOCATION ISTEQS        
C        
      JJ    = 0        
      ICOMP = 0        
  180 ICOMP = ICOMP + 1        
      IF (ICOMP .GT. NCOMP) GO TO 140        
  170 CALL SUREAD (Z(ISTEQS+JJ+1),3,NOUT,ITEST)        
      GO TO (130,120,140), ITEST        
  130 CONTINUE        
C        
C     NORMAL ROUTE - PROCESS ENTRIES        
C        
      Z(ISTEQS+JJ) = ICOMP        
      DO 160 J=1,NPSUB        
      IF (ICOMP.GE.NBOT(J) .AND. ICOMP.LE.NTOP(J)) GO TO 150        
  160 CONTINUE        
  150 Z(ISTEQS+JJ) = ORF(LSHIFT(J,IHALF),Z(ISTEQS+JJ))        
      JJ = JJ + 4        
      GO TO 170        
  120 GO TO 180        
C        
C     SORT ON INTERNAL POINT NUMBER        
C        
  140 CONTINUE        
      Z(ISTEQS+JJ  ) = 0        
      Z(ISTEQS+JJ+1) = 0        
      Z(ISTEQS+JJ+2) = 0        
      Z(ISTEQS+JJ+3) = 0        
      CALL SORT (0,0,4,3,Z(ISTEQS),JJ)        
      II   = 1        
      ISIL = 1        
      DO 200 I=1,JJ,4        
      IF (Z(ISTEQS+I+1) .NE. Z(ISTEQS+I+5)) GO TO 210        
      II = II + 1        
      GO TO 200        
  210 IW = 4*II        
      IOFF = I - 1 - 4*(II-1)        
      ICODE = Z(ISTEQS+IOFF+3)        
      CALL DECODE (ICODE,STRING,NDOF)        
      CALL EQOUT1 (Z(ISTEQS+IOFF),IW,Z(SCORE),NWRD,ISIL)        
      ISIL = ISIL + NDOF        
      II   = 1        
  200 CONTINUE        
      RETURN        
      END        
