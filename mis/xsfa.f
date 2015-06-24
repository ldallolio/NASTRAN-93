      SUBROUTINE XSFA (X)        
C        
C     ENTRY SIZE NUMBERS,  1=FIAT, 2=SOS, 3=MD, 4=DPD        
C        
C     REVISED  8/89,  SEE XSFABD        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF,COMPLF        
      DIMENSION       IPRT(23),NSFA(3),DDBN(1),DFNU(1),FCUM(1),        
     1                FCUS( 1),FDBN(1),FEQU(1),FILE(1),FKND(1),        
     2                FMAT( 1),FNTU(1),FPUN(1),FON (1),FORD(1),        
     3                MINP( 1),MLSN(1),MOUT(1),MSCR(1),SAL (1),        
     4                SDBN( 1),SNTU(1),SORD(1),PFIL(2,3)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
CIBMR 6/93     COMMON /BLNAK / IBNK(1)        
      COMMON /BLANK / IBNK(1)        
      COMMON /MACHIN/ MCH        
      COMMON /XFIAT / FIAT(7)        
      COMMON /XFIST / FIST        
      COMMON /XDPL  / DPD(6)        
CZZ   COMMON /ZZXSEM/ BUF1        
      COMMON /ZZZZZZ/ BUF1        
      COMMON /SYSTEM/ IBUFSZ,OUTTAP,DUM(17),PLTFLG,DUM1,THISLK,DUM2,    
     1                ICFIAT,DMM(14),NBPC,NBPW,NCPW        
      COMMON /IXSFA / LMT3,BFF,PAD,IDEFR1,IDEFR2        
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
      DATA  OSCAR1, OSCAR2/ 4HXOSC, 4HAR  /, POOL  / 4HPOOL  /        
      DATA  NSFA  / 4HXSFA, 4H    , 4H    /, NS14  / 4HNS14  /        
      DATA  IBEGN,  IEND  / 4HBEGN, 4HEND /        
      DATA  PLUS  / 1H+   /        
      DATA  PFIL  / 4HPLTP, 4HAR  , 4HGPSE, 4HTS  , 4HELSE, 4HTS   /    
C        
CIBMI 6/93
      CALL XSFADD
      NSFA(3) = IBEGN        
      CALL CONMSG (NSFA,3,0)        
C        
C     ALMSK  = O 377777777777     Z 7FFFFFFF        
      ALMSK  = RSHIFT(COMPLF(0),1)        
C        
C     THCRMK = O 777777000000     Z FFFFFF00        
      THCRMK = LSHIFT(ALMSK,NBPW-(3*NBPC))        
C        
C     S      = O 400000000000     Z 80000000        
      S      = LSHIFT(1,NBPW-1)        
C        
C     MACSFT = SHIFT COUNT TO PLACE INTEGER IN 4TH FROM LEFT CHARACTER  
      MACSFT = (NCPW-4)*NBPC        
C        
      ENTN1  = ICFIAT        
      CURSNO = X        
C        
C     GET OSCAR FILE POSITION AND SAVE IN FNOS        
C     ALSO SAVE RECORD POSITION IN RNOS        
C        
      CALL XPOLCK (OSCAR1,OSCAR2,FNOS,NX)        
      IF (FNOS .EQ. 0) GO TO 920        
      FNX  = FNOS        
      RNOS = CURSNO        
      CALL XSOSGN        
      IF (MLGN .EQ. 0) GO TO 930        
      CALL XCLEAN        
C        
C     INITIALIZE PRIOR TO FIRST MODULE ALLOCATION        
C        
      ASSIGN 670 TO ITEST        
C        
      LMT1  = MLGN *ENTN3        
      LMT8  = FUNLG*ENTN1        
      LMT8P1= LMT8 + 1        
      DO 110 I = 1,LMT8,ENTN1        
      IF (ANDF(TAPMSK,FILE(I)) .NE. 0) GO TO 120        
  110 CONTINUE        
      TAPMSK = 0        
C        
C     LOOP THRU ALL MODULES IN SOS        
C        
  120 I = 1        
  125 TOTIO = MINP(I)+ MOUT(I)        
      TOTF  = TOTIO  + MSCR(I)        
      ALCNT = 0        
      LMT2  = LMT3 + 1        
      LMT4  = LMT3 + MINP(I)*ENTN2        
      LMT5  = LMT4 + MOUT(I)*ENTN2        
      LMT3  = LMT3 + TOTF   *ENTN2        
      LMT9  = FCULG*ENTN1        
      NFCULG= LMT9 + 1        
      ITIORD= LSHIFT(MLSN(I),16)        
      DO 130 J = 1,LMT9,ENTN1        
  130 FCUM(J) = 0        
C        
C     SEQUENCE THRU SOS (ONE MODULE) LOOK FOR NAME MATCH + LTU COMPARE  
C        
  150 FLAG = 0        
      DO 260 K = LMT2,LMT3,ENTN2        
      IF (SAL(K) .LT. 0)  GO TO 260        
      ITPFLG = ANDF(TAPMSK,SNTU(K))        
C        
C     SEQUENCE THRU FIAT (NAME MATCH)        
C        
      DO 170 F1 = 1,LMT9,ENTN1        
      IF (SDBN(K).NE.FDBN(F1) .OR. SDBN(K+1).NE.FDBN(F1+1)) GO TO 170   
      IF (FPUN(F1) .LT. 0) GO TO 680        
      FNTU(F1) = ORF(ANDF(S,FON(F1)),SNTU(K))        
      FCUM(F1) = -1        
      FCUS(F1) = -1        
      IF (FKND(F1) .EQ. 0) FKND(F1) = 1        
      GO TO 230        
  170 CONTINUE        
      IF (MLSN(I) .LT. 0) GO TO 260        
      IF (K    .LE. LMT4) GO TO 260        
      IF (ANDF(APNDMK,SORD(K)) .EQ. APNDMK) GO TO 260        
C        
C     SEQUENCE THRU FIAT (LTU COMPARE)        
C        
      DO 220 F1 = 1,LMT9,ENTN1        
      IF (ITIORD .LE. ANDF(LMSK,FORD(F1))) GO TO 220        
      IF (FON (F1) .LT. 0) GO TO 220        
      IF (FCUM(F1) .LT. 0) GO TO 220        
      IF (FDBN(F1) .EQ. 0) GO TO 220        
      IF (ANDF(RMSK,FILE(F1)) .EQ. RMSK) GO TO 220        
      IF (ANDF(LMSK,FORD(F1)) .EQ. LMSK) GO TO 220        
      IF (ITPFLG.NE.0 .AND. ANDF(TAPMSK,FILE(F1)).EQ.0) GO TO 220       
      IF (FEQU(F1) .GE. 0) GO TO 210        
      FIL = ANDF(RMSK,FILE(F1))        
      DO 200 L = 1,LMT9,ENTN1        
      IF (FEQU(L) .GE. 0) GO TO 200        
      IF (F1      .EQ. L) GO TO 200        
      IF (FIL    .NE. ANDF(RMSK,FILE(L))) GO TO 200        
      IF (ITIORD .LE. ANDF(LMSK,FORD(L))) GO TO 220        
      IF (FON(L)  .LT. 0) GO TO 220        
      IF (FCUM(L) .LT. 0) GO TO 220        
  200 CONTINUE        
  210 IF (FCULG+PAD .GE. FMXLG) GO TO 680        
      FON(F1) = ORF(S,FON(F1))        
      FDBN(NFCULG  ) = SDBN(K  )        
      FDBN(NFCULG+1) = SDBN(K+1)        
      FORD(NFCULG  ) = ORF(ANDF(LXMSK,SORD(K)),ANDF(RXMSK,FILE(F1)))    
      FNTU(NFCULG  ) = SNTU(K)        
      FCUM(NFCULG  ) = -1        
      FCUS(NFCULG  ) = -1        
      FKND(NFCULG  ) = 2        
      NFCULG = NFCULG+ ENTN1        
      FCULG  = FCULG + 1        
      GO TO 230        
  220 CONTINUE        
      GO TO 260        
  230 SAL(K) = ORF(S,SAL(K))        
      ALCNT  = ALCNT + 1        
  260 CONTINUE        
      IF (ALCNT .EQ. TOTF) GO TO 600        
C        
C     SEQUENCE THRU SOS (ONE MODULE) LOOK FOR BLANK FILES + GREATER NTU 
C        
      DO 550 K = LMT2,LMT3,ENTN2        
      IF (SAL(K) .LT. 0) GO TO 550        
      IF (FLAG.NE.0 .AND. K.GT.LMT4 .AND. K.LE.LMT5) GO TO 150        
      IAPFLG = 0        
      IUNPFG = 0        
      IF (ANDF(APNDMK,SORD(K)) .EQ. APNDMK) IAPFLG = -1        
      ITPFLG = ANDF(TAPMSK,SNTU(K))        
C        
C     SEQUENCE THRU FIAT-UNIQUE (BLANK FILES)        
C        
      IF (BFF .LT. 0) GO TO 390        
      DO 330 F1 = 1,LMT8,ENTN1        
      IF (FDBN(F1) .NE. 0) GO TO 330        
      IF (ITPFLG.NE.0 .AND. ANDF(TAPMSK,FILE(F1)).EQ.0) GO TO 330       
      IF (K.GT.LMT4 .AND. IAPFLG.EQ.0) GO TO 310        
      CALL XPOLCK (SDBN(K),SDBN(K+1),FN,NX)        
      IF (IAPFLG.NE.0 .AND. FN.EQ.0) GO TO 310        
      IF (FN     .NE. 0) GO TO 300        
      IF (PLTFLG .NE. 0) GO TO 280        
      DO 270 IP = 1,3        
      IF (SDBN(K).EQ.PFIL(1,IP) .AND. SDBN(K+1).EQ.PFIL(2,IP)) GO TO 300
  270 CONTINUE        
  280 IF (THISLK .NE. NS14) CALL MESAGE (22,0,SDBN(K))        
      GO TO 320        
  300 FPUN(F1) = FN        
      IUNPFG   = F1        
  310 FDBN(F1  ) = SDBN(K  )        
      FDBN(F1+1) = SDBN(K+1)        
      FORD(F1) = ORF(ANDF(LXMSK,SORD(K)),FILE(F1))        
      FNTU(F1) = SNTU(K)        
      FCUM(F1) =-1        
      FCUS(F1) =-1        
      FKND(F1) = 3        
  320 SAL(K) = ORF(S,SAL(K))        
      ALCNT  = ALCNT + 1        
      GO TO 540        
  330 CONTINUE        
      IF (ITPFLG .EQ. 0) BFF = -1        
C        
C     SEQUENCE THRU FIAT (GREATEST NTU) FOR POOLING        
C        
  390 IF (MLSN(I) .LT. 0) GO TO 680        
C        
C     BEFORE PERMITTING POOLING CHECK IF AT LEAST ONE MODULE IS ALLOCATE
C        
      IF (I .NE. 1) GO TO 620        
  400 MXNTU  = CURSNO        
      MXNTUI = 0        
      DO 460 F1 = 1,LMT8,ENTN1        
      IF (FCUS(F1) .LT. 0) GO TO 460        
      IF (IDEFR2   .LT. 0) GO TO 420        
      IF (FMAT(F1).NE.0 .OR. FMAT(F1+1).NE.0 .OR. FMAT(F1+2).NE.0)      
     1   GO TO 410        
      IF (ENTN1.EQ.11 .AND. (FMAT(F1+5).NE.0 .OR. FMAT(F1+6).NE.0 .OR.  
     1   FMAT(F1+7).NE.0)) GO TO 410        
      GO TO 420        
  410 IDEFR1 = -1        
      GO TO 460        
  420 IF (FKND(F1) .LT. 0) GO TO 460        
      IF (FPUN(F1) .NE. 0) GO TO 460        
      IF (ITPFLG.NE.0 .AND. ANDF(TAPMSK,FILE(F1)).EQ.0) GO TO 460       
      TRIAL = ANDF(FNTU(F1),RMSK)        
      IF (TRIAL .LE. MXNTU) GO TO 460        
      MXNTU  = TRIAL        
      MXNTUI = F1        
  460 CONTINUE        
      IF (MXNTUI .NE. 0) GO TO 463        
C        
C     FILE NOT FOUND - HAS A PASS BEEN DEFERRED        
C        
      IF (IDEFR1 .EQ. 0) GO TO 680        
C        
C     PASS HAS BEEN DEFERRED - TRY IT NOW        
C        
      IDEFR1 = 0        
      IDEFR2 =-1        
      DO 462 IX = 1,LMT8,ENTN1        
  462 FKND(IX) = IABS(FKND(IX))        
      GO TO 400        
C        
C     A GREATER NTU FILE EXISTS        
C        
  463 N = 1        
C        
C     SEARCH FOR EQUIV OR STACKED MATCH        
C        
      FIL = ANDF(RMSK,FILE(MXNTUI))        
      DO 470 J = LMT8P1,LMT9,ENTN1        
      IF (FIL .NE. ANDF(RMSK,FILE(J))) GO TO 470        
C        
C     A MATCH IS FOUND, IS MATCHED FILE USED IN CURRENT SEG        
C        
      IF (FCUS(J) .LT. 0) GO TO 490        
C        
C     IF MATCHED FILE HAS NTU LESS - TEST AND SET DEFER FLAG        
C        
      IF (IDEFR2 .LT. 0) GO TO 465        
      IF (FMAT(J).NE.0 .OR.  FMAT(J+1).NE.0 .OR. FMAT(J+2).NE.0)        
     1    GO TO 464        
      IF (ENTN1.EQ.11 .AND. (FMAT(J+5).NE.0 .OR. FMAT(J+6).NE.0 .OR.    
     1    FMAT(J+7).NE.0)) GO TO 464        
      IF (ANDF(RMSK,FNTU(1)) .GE. ANDF(RMSK,FNTU(MXNTUI))) GO TO 465    
  464 IDEFR1 = -1        
      GO TO 490        
C        
C     MATCHED FILE IS O.K. - IS IT EQUIV OR STACKED        
C        
  465 IF (FEQU(J) .GE. 0) GO TO 467        
      FKND(J) = 7        
      N = N + 1        
      GO TO 470        
C        
C     STACKED - WIPE OUT MATCH (IF EMPTY)        
C        
  467 IF (FMAT(J).NE.0 .OR.  FMAT(J+1).NE.0 .OR. FMAT(J+2).NE.0)        
     1    GO TO 490        
      IF (ENTN1.EQ.11 .AND. (FMAT(J+5).NE.0 .OR. FMAT(J+6).NE.0 .OR.    
     1    FMAT(J+7).NE.0)) GO TO 490        
      FILE(J  ) = 0        
      FDBN(J  ) = 0        
      FDBN(J+1) = 0        
  470 CONTINUE        
      FPUN(MXNTUI) = ORF(S,N)        
      IF (K.GT.LMT4 .AND. IAPFLG.EQ.0) GO TO 520        
      CALL XPOLCK (SDBN(K),SDBN(K+1),FN,NX)        
      IF (IAPFLG.NE.0 .AND. FN.EQ.0) GO TO 520        
      IF (FN .NE. 0) GO TO 500        
      IF (THISLK .NE. 14) CALL MESAGE (22,0,SDBN(K))        
      GO TO 530        
  490 IF (FKND(MXNTUI) .EQ. 0) FKND(MXNTUI) = 9        
      FKND(MXNTUI) = -IABS(FKND(MXNTUI))        
      GO TO 400        
  500 FPUN(NFCULG) = FN        
      IUNPFG = NFCULG        
  520 IF (FCULG+PAD .GE. FMXLG) GO TO 680        
      FON(MXNTUI ) = ORF(S,FON(MXNTUI))        
      FORD(NFCULG) = ORF(ANDF(RXMSK,FILE(MXNTUI)),ANDF(LXMSK,SORD(K)))  
      FKND(NFCULG) = ORF(FKND(NFCULG),5)        
      FDBN(NFCULG  ) = SDBN(K  )        
      FDBN(NFCULG+1) = SDBN(K+1)        
      FNTU(NFCULG) = SNTU(K)        
      FCUM(NFCULG) = -1        
      FCUS(NFCULG) = -1        
      NFCULG = NFCULG+ ENTN1        
      FCULG  = FCULG + 1        
  530 SAL(K) = ORF(S,SAL(K))        
      ALCNT  = ALCNT+ 1        
  540 IF (IUNPFG   .EQ. 0) GO TO 550        
      IF (DFNU(NX) .GE. 0) GO TO 550        
      CALL XPLEQK (NX,IUNPFG)        
      LMT9  = FCULG*ENTN1        
      NFCULG= LMT9 + 1        
  550 CONTINUE        
C        
C     MODULE ALLOCATION COMPLETE        
C        
  600 CURSNO = ANDF(RMSK,MLSN(I)) + 1        
C        
C     END OF I MODULE PSEUDO LOOP        
C        
      I = I + ENTN3        
      IF (I .LE. LMT1) GO TO 125        
C        
  620 CALL XPUNP        
      CALL XDPH        
C        
C     REPOSITION OSCAR FOR SEM        
C        
      CALL XPOLCK (OSCAR1,OSCAR2,FNOS,NX)        
      IF (FNOS .EQ. 0) GO TO 920        
  630 CALL OPEN (*940,POOL,BUF1,0)        
      IF (FNOS .NE. 1) CALL SKPFIL (POOL,FNOS-1)        
      DO 650 J = 1,RNOS        
      CALL FWDREC (*950,POOL)        
  650 CONTINUE        
      CALL CLOSE (POOL,2)        
C        
  655 CONTINUE        
C        
C     DUMP FIAT IF SENSE SWITCH 2 IS ON        
C        
      CALL SSWTCH (2,IX)        
      IF (IX .NE. 1) GO TO ITEST, (670,715)        
      CALL PAGE1        
      CALL PAGE2 (-4)        
      WRITE  (OUTTAP,660) FIAT(1),FIAT(2),FIAT(3),X,CURSNO        
  660 FORMAT (15H0FIAT AFTER SFA,3I4,12H  OSCAR STR ,I4,6H, STP ,I4, //,
     1        ' EQ AP  LTU  TP  UNIT  NTU  OF SG KN TR DATA-BLK      *',
     2     6X,'*   TRAILER   *      *      *  PRI BLKS   SEC FLS/BLKS', 
     3     3X,'TER FLS/BLKS')        
      II = FIAT(3)*ENTN1        
      DO 665 IX = 1,II,ENTN1        
      IPRT( 1) = RSHIFT(FEQU(IX),NBPW-1)        
      IPRT( 2) = RSHIFT(ANDF(APNDMK,FORD(IX)),30)        
      IPRT( 3) = RSHIFT(ANDF(LMSK  ,FORD(IX)),16)        
      IPRT( 4) = RSHIFT(ANDF(TAPMSK,FILE(IX)),15)        
      IPRT( 5) = ANDF(RMSK,FILE(IX))        
      IPRT( 6) = ANDF(RMSK,FNTU(IX))        
      IPRT( 7) = RSHIFT(FON(IX),NBPW-1)        
      IPRT( 8) = FCUS(IX)        
      IPRT( 9) = FKND(IX)        
      IPRT(10) = RSHIFT(ANDF(TAPMSK,FNTU(IX)),15)        
      IPRT(11) = FDBN(IX  )        
      IPRT(12) = FDBN(IX+1)        
      IF (IPRT(11) .NE. 0) GO TO 661        
      IPRT(11) = NSFA(2)        
      IPRT(12) = NSFA(2)        
  661 IF (ENTN1 .EQ. 11) GO TO 662        
      IPRT(13) = RSHIFT(FMAT(IX),16)        
      IPRT(14) = ANDF(RXMSK,FMAT(IX))        
      IPRT(15) = RSHIFT(FMAT(IX+1),16)        
      IPRT(16) = ANDF(RXMSK,FMAT(IX+1))        
      IPRT(17) = RSHIFT(FMAT(IX+2),16)        
      IPRT(18) = ANDF(RXMSK,FMAT(IX+2))        
      GO TO 663        
  662 IPRT(13) = FMAT(IX  )        
      IPRT(14) = FMAT(IX+1)        
      IPRT(15) = FMAT(IX+2)        
      IPRT(16) = FMAT(IX+5)        
      IPRT(17) = FMAT(IX+6)        
      IPRT(18) = FMAT(IX+7)        
  663 IPRT(19) = RSHIFT(FMAT(IX+3),16)        
      ITEMP    = ANDF(FMAT(IX+3),RXMSK)        
      IPRT(20) = RSHIFT(ITEMP,8)        
      IPRT(21) = RSHIFT(FMAT(IX+4),16)        
      IPRT(22) = ITEMP - IPRT(20)*2**8        
      IPRT(23) = ANDF(RXMSK,FMAT(IX+4))        
      CALL PAGE2 (-1)        
      WRITE  (OUTTAP,664) (IPRT(IY),IY=1,23)        
  664 FORMAT (1H ,2(I2,1X),I5,1X,I2,2(1X,I5),4(1X,I2),1X,2A4,6I7,       
     1        4X,I5,1X,2(7X,I2,1H/,I5))        
  665 CONTINUE        
      CALL XFLSZD (0,BLKSIZ,0)        
      CALL PAGE2 (-2)        
      WRITE  (OUTTAP,628) BLKSIZ        
  628 FORMAT (30X,20H EACH BLOCK CONTAINS,I5,7H WORDS.)        
      WRITE  (OUTTAP,666)        
  666 FORMAT (52H POOL FILE CONTENTS   EQ    SIZE   FILE   DATA BLOCK)  
      II = DPD(3)*3        
      DO 668 IX = 1,II,3        
      IPRT(1) = RSHIFT(DFNU(IX),NBPW-1)        
      IPRT(2) = RSHIFT(DFNU(IX),16)        
      IPRT(3) = ANDF(RXMSK,DFNU(IX))        
      IPRT(4) = DDBN(IX  )        
      IPRT(5) = DDBN(IX+1)        
      CALL PAGE2 (-1)        
      WRITE  (OUTTAP,667) (IPRT(IY),IY=1,5)        
  667 FORMAT (22X,I2,I7,I7,3X,2A4)        
  668 CONTINUE        
C        
      GO TO ITEST, (670,715)        
C        
  670 J = MCH        
      IF (IABS(IBNK(ENTN1*5))/1000.NE.J .AND. J.GT.6) COMM(4) = J       
      X = CURSNO        
      NSFA(3) = IEND        
      CALL CONMSG (NSFA,3,0)        
      RETURN        
C        
C     MODULE ALLOCATION INCOMPLETE        
C        
  680 IF (I      .NE. 1) GO TO 620        
      IF (ITPFLG .EQ. 0) GO TO 700        
C        
C     LOOKING FOR A TAPE + AT LEAST ONE TAPE EXISTS        
C        
      NOAVAL = 0        
      DO 690 M = 1,LMT8,ENTN1        
      IF (ANDF(TAPMSK,FILE(M)) .EQ. 0) GO TO 690        
      IF (ANDF(TAPMSK,FNTU(M)) .EQ. 0) GO TO 710        
      NOAVAL = 1        
  690 CONTINUE        
      IF (NOAVAL .EQ. 0) GO TO 700        
      TAPMSK = 0        
      GO TO 790        
  700 CURSNO = 0        
      GO TO 630        
C        
C     A TAPE FILE EXIST CONTAINING A D.B. NOT REQUIRING A TAPE  -       
C     FREE THAT TAPE***  CHECK FOR EQUIV AND LTU D.B. ON SAME UNIT      
C        
  710 N = 1        
C        
      ASSIGN 715 TO ITEST        
      GO TO 655        
  715 CONTINUE        
      ASSIGN 670 TO ITEST        
C        
      TRIAL = ANDF(RMSK,FILE(M))        
      LMT   = LMT8 + 1        
      DO 750 J = LMT,LMT9,ENTN1        
      IF (TRIAL .NE. ANDF(RMSK,FILE(J))) GO TO 750        
      INAM1 = FDBN(J  )        
      INAM2 = FDBN(J+1)        
      IF (FEQU(M).LT.0 .AND. FEQU(J).LT.0) GO TO 720        
      FDBN(J) = ALMSK        
      GO TO 725        
  720 N = N + 1        
  725 DO 730 L = LMT2,LMT3,ENTN2        
      IF (INAM1.EQ.SDBN(L) .AND. INAM2.EQ.SDBN(L+1)) GO TO 740        
  730 CONTINUE        
      GO TO 750        
C        
C     TURN OFF ALLOC FLAG        
C        
  740 SAL(L) = ORF(ALMSK,SAL(L))        
      ALCNT  = ALCNT - 1        
  750 CONTINUE        
      INAM1 = FDBN(M  )        
      INAM2 = FDBN(M+1)        
      DO 760 L = LMT2,LMT3,ENTN2        
      IF (INAM1.EQ.SDBN(L) .AND. INAM2.EQ.SDBN(L+1)) GO TO 770        
  760 CONTINUE        
      GO TO 780        
  770 SAL(L) = ORF(ALMSK,SAL(L))        
      ALCNT  = ALCNT - 1        
  780 FPUN(M)= ORF(S,N)        
      CALL XPUNP        
      FDBN(M  ) = SDBN(K  )        
      FDBN(M+1) = SDBN(K+1)        
      FORD(M  ) = ORF(ANDF(LXMSK,SORD(K)),ANDF(RXMSK,FILE(M)))        
      FKND(M  ) = 8        
C        
      CALL SSWTCH (2,IX)        
      IF (IX .NE. 1) GO TO 790        
      CALL PAGE2 (-2)        
      WRITE  (OUTTAP,785)        
  785 FORMAT (38H0* XSFA REPEATS TO USE FREED TAPE FILE)        
C        
  790 BFF = 0        
      GO TO 150        
C        
  920 WRITE  (OUTTAP,921) SFM        
  921 FORMAT (A25,' 1001, OSCAR NOT FOUND IN DPL')        
      GO TO  1000        
  930 WRITE  (OUTTAP,931) SFM        
  931 FORMAT (A25,' 1002, OSCAR CONTAINS NO MODULES')        
      GO TO  1000        
  940 WRITE  (OUTTAP,941) SFM        
  941 FORMAT (A25,' 1003, POOL COULD NOT BE OPENED')        
      GO TO  1000        
  950 WRITE  (OUTTAP,951) SFM        
  951 FORMAT (A25,' 1004, ILLEGAL EOF ON POOL')        
 1000 CALL MESAGE (-37,0,NSFA)        
      RETURN        
      END        
