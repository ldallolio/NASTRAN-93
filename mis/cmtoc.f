      SUBROUTINE CMTOC        
C        
C     THIS SUBROUTINE GENERATES A TABLE OF CONTENTS FOR A COMBINE       
C     OPERATION. FOR EACH PSEUDO-STRUCTURE IT LISTS THE NAME, NUMBER    
C     OF COMPONENTS, AND EACH COMPONENT BASIC SUBSTRUCTURE NAME.        
C     THIS DATA IS THEN WRITTEN ON SCRATCH FILE SCTOC.        
C        
      EXTERNAL        RSHIFT,ANDF        
      LOGICAL         PRINT,TOCOPN        
      INTEGER         SCTOC,BUF5,COMBO,NAME(2),Z,SCORE,AAA(2),OUTT,     
     1                IHED(96),XXX,ANDF,RSHIFT        
      COMMON /CMB001/ SCR1,SCR2,SCBDAT,SCSFIL,SCCONN,SCMCON,SCTOC,      
     1                GEOM4,CASECC        
      COMMON /CMB002/ BUF1,BUF2,BUF3,BUF4,BUF5,SCORE,LCORE,INPT,OUTT    
      COMMON /CMB003/ COMBO(7,5),CONSET,IAUTO,TOLER,NPSUB,CONECT,TRAN,  
     1                MCON,RESTCT(7,7),ISORT,ORIGIN(7,3),IPRINT,TOCOPN  
CZZ   COMMON /ZZCOMB/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /OUTPUT/ ITITL(96),IHDR(96)        
      COMMON /SYSTEM/ XXX        
      DATA    IHED  / 7*4H     ,        
     1        4HP S , 4HE U , 4HD O , 4HS T , 4HR U , 4HC T , 4HU R ,   
     2        4HE   , 4HT A , 4HB L , 4HE   , 4HO F , 4H  C , 4HO N ,   
     3        4HT E , 4HN T , 4HS   , 15*4H         ,        
     4        4H PSE, 4HUDO-, 4H    , 4H   N, 4HO. O, 4HF   ,26*2H  ,   
     5        4HSTRU, 4HCTUR, 4HE   , 4H COM, 4HPONE, 4HNTS , 4H   -,   
     6        4H----, 4H----, 4H- CO, 4HMPON, 4HENT , 4HNAME, 4HS --,   
     7        4H----, 4H----, 4H-   , 8*4H     /        
      DATA    AAA   / 4HCMTO, 4HC   /        
      DATA    NHEQSS/ 4HEQSS/        
C        
      PRINT = .FALSE.        
      IF (ANDF(RSHIFT(IPRINT,1),1) .EQ. 1) PRINT = .TRUE.        
      TOCOPN = .TRUE.        
      ITOT = 0        
      DO 20 I = 1,96        
      IHDR(I) = IHED(I)        
   20 CONTINUE        
      IF (PRINT) CALL PAGE        
      CALL OPEN (*60,SCTOC,Z(BUF5),1)        
      DO 50 I = 1,NPSUB        
      NAME(1) = COMBO(I,1)        
      NAME(2) = COMBO(I,2)        
      CALL SFETCH (NAME,NHEQSS,1,ITEST)        
      CALL SUREAD (Z(SCORE),-1,NWDS,ITEST)        
      Z(SCORE  ) = NAME(1)        
      Z(SCORE+1) = NAME(2)        
      CALL WRITE (SCTOC,Z(SCORE),3,0)        
      ITOT = ITOT + 3        
      IA   = SCORE        
      IB   = SCORE+2        
      IF (PRINT) WRITE(OUTT,30) (Z(KDH),KDH=IA,IB)        
   30 FORMAT (34X,2A4,6X,I4)        
      COMBO(I,5) = Z(SCORE+2)        
      NWDS = NWDS - 4        
      IA   = SCORE+4        
      IB   = IA+NWDS-1        
      NT   = (IB - IA + 1)/8        
      IF (NT .EQ. 0) NT = 1        
      IF (PRINT) CALL PAGE2 (NT)        
      IF (PRINT) WRITE (OUTT,40) (Z(KDH),KDH=IA,IB)        
      ITOT = ITOT + NWDS        
   40 FORMAT (1H+,57X,2X,2A4,2X,2A4,2X,2A4,2X,2A4,/        
     1       (58X,2X,2A4,2X,2A4,2X,2A4,2X,2A4))        
      CALL WRITE (SCTOC,Z(SCORE+4),NWDS,1)        
   50 CONTINUE        
      CALL CLOSE (SCTOC,1)        
      CALL OPEN (*60,SCTOC,Z(BUF5),0)        
C        
C     DETERMINE WHETHER TO CLOSE FILE        
C        
      IF (ITOT .LE. XXX) RETURN        
      TOCOPN = .FALSE.        
      CALL CLOSE (SCTOC,1)        
      RETURN        
C        
   60 CALL MESAGE (-1,SCTOC,AAA)        
      RETURN        
      END        
