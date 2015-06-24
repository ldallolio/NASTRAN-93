      SUBROUTINE XPUNP        
C        
C     THIS SUBROUTINE POOLS AND UNPOOLS FILES AS PRESCRIBED BY XFIAT    
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        LSHIFT    ,ANDF    ,ORF        
      DIMENSION       HEADER( 8),HEAD( 2),NPUNP( 2),BLOCK(1000),        
     1                DDBN  ( 1),DFNU( 1),FCUM ( 1),FCUS (   1),        
     2                FDBN  ( 1),FEQU( 1),FILE ( 1),FKND (   1),        
     3                FMAT  ( 1),FNTU( 1),FPUN ( 1),FON  (   1),        
     4                FORD  ( 1),MINP( 1),MLSN ( 1),MOUT (   1),        
     5                MSCR  ( 1),SAL ( 1),SDBN ( 1),SNTU (   1),        
     6                SORD  ( 1)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /XFIAT / FIAT(7)        
      COMMON /XPFIST/ PFIST        
      COMMON /XFIST / FIST(2)        
      COMMON /XDPL  / DPD(6)        
      COMMON /SYSTEM/ IBUFSZ,OUTTAP        
CZZ   COMMON /ZZXSEM/ BUF1(1)        
      COMMON /ZZZZZZ/ BUF1(1)        
      COMMON /XSFA1 / MD(401),SOS(1501),COMM(20),XF1AT(5)        
      EQUIVALENCE               (DPD  (1),DNAF    ),(DPD  (2),DMXLG   ),
     1      (DPD  (3),DCULG   ),(DPD  (4),DDBN (1)),(DPD  (6),DFNU (1)),
     2      (FIAT (1),FUNLG   ),(FIAT (2),FMXLG   ),(FIAT (3),FCULG   ),
     3      (FIAT (4),FEQU (1)),(FIAT (4),FILE (1)),(FIAT (4),FORD (1)),
     4      (FIAT (5),FDBN (1)),(FIAT (7),FMAT (1)),(MD   (1),MLGN    ),
     5      (MD   (2),MLSN (1)),(MD   (3),MINP (1)),(MD   (4),MOUT (1)),
     6      (MD   (5),MSCR (1)),(SOS  (1),SLGN    ),(SOS  (2),SDBN (1)),
     7      (SOS  (4),SAL  (1)),(SOS  (4),SNTU (1)),(SOS  (4),SORD (1)),
     8      (XF1AT(1),FNTU (1)),(XF1AT(1),FON  (1)),(XF1AT(2),FPUN (1)),
     9      (XF1AT(3),FCUM (1)),(XF1AT(4),FCUS (1)),(XF1AT(5),FKND (1)) 
      EQUIVALENCE               (COMM (1),ALMSK   ),(COMM (2),APNDMK  ),
     1      (COMM (3),CURSNO  ),(COMM (4),ENTN1   ),(COMM (5),ENTN2   ),
     2      (COMM (6),ENTN3   ),(COMM (7),ENTN4   ),(COMM (8),FLAG    ),
     3      (COMM (9),FNX     ),(COMM(10),LMSK    ),(COMM(11),LXMSK   ),
     4      (COMM(12),MACSFT  ),(COMM(13),RMSK    ),(COMM(14),RXMSK   ),
     5      (COMM(15),S       ),(COMM(16),SCORNT  ),(COMM(17),TAPMSK  ),
     6      (COMM(18),THCRMK  ),(COMM(19),ZAP     )        
      DATA  N/1000/  ,POOL/4HPOOL/  ,ENTN5/2/,  NPUNP/4HXPUN,4HP   /    
C        
C     ENTRY SIZE NUMBERS,  1=FIAT, 4=DPD        
C        
      ISW1 = 0        
      ISW2 = 0        
      ENTN1X  = ENTN1- 1        
      FIST(2) = 1 + PFIST        
C        
C     COMPUTE INDEX FOR DUMMY ENTRY IN FIST        
C        
      FSTIDX = FIST(2)*2 + 1        
      LMT3   = FCULG* ENTN1        
C        
C     CHECK FOR ANY FILES TO POOL        
C        
      FIST(FSTIDX) = 101        
      DO 360 I = 1,LMT3,ENTN1        
      IF (FPUN(I) .GE. 0) GO TO 360        
      NN = ANDF(ALMSK,FPUN(I))        
      FPUN(I)= 0        
      IF (FMAT(I).NE.0 .OR.  FMAT(I+1).NE.0 .OR. FMAT(I+2).NE.0)        
     1    GO TO 105        
      IF (ENTN1.EQ.11 .AND. (FMAT(I+5).NE.0 .OR. FMAT(I+6).NE.0 .OR.    
     1    FMAT(I+7).NE.0)) GO TO 105        
      NN = 1        
      GO TO 268        
  105 CALL XPOLCK (FDBN(I),FDBN(I+1),FN,NX)        
      IF (FN .EQ. 0) GO TO 110        
      J = NX        
      GO TO 268        
  110 IF (ISW1 .NE. 0) GO TO 220        
      ISW1 = 1        
      CALL OPEN (*900,POOL,BUF1,2)        
      CALL XFILPS (DNAF)        
      CALL CLOSE (POOL,2)        
      CALL OPEN (*900,POOL,BUF1,3)        
      FNX = DNAF        
  220 FIST(FSTIDX+1) = I + ENTN5        
      CALL OPEN (*900,101,BUF1(IBUFSZ+1),0)        
      NCNT = 0        
C        
C     WRITE SPECIAL FILE HEADER RECORD -- XPOOL DICT NAME    ( 2 WORDS )
C                                       + DATA BLOCK TRAILER ( 3 WORDS  
C                                                         OR   6 WORDS )
C        
      CALL WRITE (POOL,FDBN(I),2,0)        
      IF (ENTN1 .EQ. 11) GO TO 230        
      CALL WRITE (POOL,FMAT(I),3,1)        
      GO TO 240        
  230 CALL WRITE (POOL,FMAT(I  ),3,0)        
      CALL WRITE (POOL,FMAT(I+5),3,1)        
C        
C     READ AND WRITE 1ST 2 WORDS OF DATA BLOCK HEADER.        
C     THEN CALL CPYFIL TO COPY REMAINDER OF FILE.        
C        
  240 CALL READ (*910,*920,101,HEAD,2,0,FLAG)        
      CALL WRITE (POOL,HEAD,2,0)        
      CALL CPYFIL (101,POOL,BLOCK,N,FLAG)        
      NCNT = ANDF(LXMSK,LSHIFT(FLAG/1000+1,16))        
      CALL EOF (POOL)        
      CALL CLOSE (101,1)        
C        
C     ADD FILE NAME OF FILE JUST POOLED TO DPD        
C        
      J = DCULG* ENTN4+ 1        
      DCULG = DCULG+ 1        
      IF (DCULG .GT. DMXLG) GO TO 700        
      DFNU(J  ) = ORF(DNAF,NCNT)        
      DDBN(J  ) = FDBN(I  )        
      DDBN(J+1) = FDBN(I+1)        
      CALL SSWTCH (3,L)        
      IF (L .NE. 1)  GO TO 267        
      CALL PAGE2 (-2)        
      WRITE  (OUTTAP,266) DDBN(J),DDBN(J+1),HEAD(1),HEAD(2)        
  266 FORMAT (16H0POOL FILE NAME , 2A4, 17H DATA BLOCK NAME ,2A4)       
  267 DNAF = DNAF + 1        
      FNX  = FNX  + 1        
  268 HOLD = ANDF(RXMSK,FILE(I))        
      LMT4 = I + ENTN1X        
      DO 269 KK = I,LMT4        
  269 FILE(KK) = 0        
      FILE(I)  = HOLD        
      FDBN(I)  = ALMSK        
C        
C     CHECK FOR EQUIV FILES        
C        
      IF (NN .EQ. 1) GO TO 360        
C        
C     THERE ARE EQUIV FILES        
C        
      DFNU(J) = ORF(S,DFNU(J))        
      DFNUSV  = DFNU(J)        
      DO 280 K = 1,LMT3,ENTN1        
      IF (FEQU(K).GE.0 .OR. I.EQ.K) GO TO 280        
      IF (ANDF(RMSK,FILE(I)) .NE. ANDF(RMSK,FILE(K))) GO TO 280        
C        
C     THIS IS AN EQUIV FILE        
C        
      CALL XPOLCK (FDBN(K),FDBN(K+1),FN,NX)        
      IF (FN .EQ. 0) GO TO 272        
      IF (DFNU(NX) .EQ. DFNUSV) GO TO 277        
      DDBN(NX  ) = 0        
      DDBN(NX+1) = 0        
  272 J = J + ENTN4        
      DCULG = DCULG + 1        
      IF (DCULG .GT. DMXLG) GO TO 700        
      DFNU(J  ) = DFNUSV        
      DDBN(J  ) = FDBN(K)        
      DDBN(J+1) = FDBN(K+1)        
      LMT4= K+ ENTN1X        
      DO 275 KK = K,LMT4        
  275 FILE(KK) =  0        
  277 NN = NN - 1        
      IF (NN .EQ. 1) GO TO 360        
  280 CONTINUE        
      GO TO 930        
  360 CONTINUE        
      IF (ISW1 .EQ. 0) GO TO 400        
      CALL CLOSE (POOL,1)        
      FNX = 1        
C        
C     CHECK FOR ANY FILES TO UNPOOL        
C        
  400 FIST(FSTIDX) = 201        
  405 FN = DNAF        
      DO 420 I = 1,LMT3,ENTN1        
      IF (FPUN(I).LE. 0 .OR. FPUN(I).GE.FN) GO TO 420        
      FN = FPUN(I)        
      II = I        
  420 CONTINUE        
      IF (FN .EQ. DNAF) GO TO 570        
      FPUN(II) = 0        
      IF (ISW2 .NE. 0) GO TO 470        
      ISW2 = 1        
      CALL OPEN (*900,POOL,BUF1,0)        
      FNX = 1        
  470 CALL XFILPS (FN)        
      FNX= FN        
      FIST(FSTIDX+1) = II + ENTN5        
      CALL OPEN (*900,201,BUF1(IBUFSZ+1),1)        
C        
C     READ SPECIAL FILE HEADER RECORD AND, IF DIAG 3 IS ON, PRINT MSG   
C        
      CALL READ (*910,*920,POOL,HEADER,ENTN1-3,1,FLAG)        
      CALL SSWTCH (3,L)        
      IF (L .NE. 1) GO TO 500        
      CALL PAGE2 (-2)        
      WRITE  (OUTTAP,501) FDBN(II),FDBN(II+1),HEADER(1),HEADER(2)       
  501 FORMAT (17H0XUNPL-DICT NAME ,2A4, 16H POOL FILE NAME , 2A4 )      
C        
C     COPY FILE USING CPYFIL        
C        
  500 CALL CPYFIL (POOL,201,BLOCK,N,FLAG)        
      CALL CLOSE (201,1)        
      FNX = FNX + 1        
      FMAT(II  ) = HEADER(3)        
      FMAT(II+1) = HEADER(4)        
      FMAT(II+2) = HEADER(5)        
      IF (ENTN1 .NE. 11) GO TO 510        
      FMAT(II+5) = HEADER(6)        
      FMAT(II+6) = HEADER(7)        
      FMAT(II+7) = HEADER(8)        
C        
C     IS FILE EQUIVALENCED        
C        
  510 IF (FEQU(II) .GE. 0) GO TO 405        
C        
C     YES, COPY SAME TRAILER INTO ALL EQUIV FILES        
C        
      HOLD = ANDF(RMSK,FILE(II))        
      DO 560 J = 1,LMT3,ENTN1        
      IF (FEQU(J).GE.0 .OR. II.EQ.J) GO TO 560        
      IF (HOLD .NE. ANDF(RMSK,FILE(J))) GO TO 560        
      FMAT(J  ) = HEADER(3)        
      FMAT(J+1) = HEADER(4)        
      FMAT(J+2) = HEADER(5)        
      IF (ENTN1 .NE.11) GO TO 560        
      FMAT(J+5) = HEADER(6)        
      FMAT(J+6) = HEADER(7)        
      FMAT(J+7) = HEADER(8)        
  560 CONTINUE        
      GO TO 405        
  570 IF (ISW2 .EQ. 0) GO TO 600        
      CALL CLOSE (POOL,1)        
      FNX = 1        
  600 CONTINUE        
      RETURN        
C        
C        
  700 WRITE  (OUTTAP,701)        
  701 FORMAT (1H0,23X,19H 1031, DPL OVERFLOW)        
      GO TO 1000        
  900 WRITE  (OUTTAP,901)        
  901 FORMAT (1H0,23X,62H 1032, POOL OR FILE BEING POOLED/UN-POOLED COUL
     1D NOT BE OPENED)        
      GO TO 1000        
  910 WRITE  (OUTTAP,911)        
  911 FORMAT (1H0,23X,39H 1033, ILLEGAL EOF ON FILE BEING POOLED)       
      GO TO 1000        
  920 WRITE  (OUTTAP,921)        
  921 FORMAT (1H0,23X,39H 1034, ILLEGAL EOR ON FILE BEING POOLED)       
      GO TO 1000        
  930 WRITE  (OUTTAP,931)        
  931 FORMAT (1H0,23X,33H 1035, EQUIV INDICATED,NONE FOUND)        
 1000 CALL PAGE2 (-4)        
      WRITE  (OUTTAP,1001) SFM        
 1001 FORMAT (A25,1H.)        
      CALL MESAGE (-37,0,NPUNP)        
      RETURN        
      END        
