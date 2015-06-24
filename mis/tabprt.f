      SUBROUTINE TABPRT (INAME1)        
C        
C     WILL PRINT TABLE - USING 1P,E13.6, I13, OR (9X,A4) FORMAT        
C        
C     ALL REAL NUMBERS ARE ASSUMED TO BE SINGLE PRECISION.        
C        
C     REVISED  3/91 BY G.CHAN/UNISYS        
C     THREE PARAMETERS ARE ADDED - OP CODE (OP), RECORDD NO. (IRC), AND 
C     WORD NO. (IWD)        
C     THE DEFAULTS OF THESE PARAMETERS ARE - BLANK, 3, AND 3        
C     OP CODE OPTIONS ARE 'PUREBCD', 'PUREFPN', AND 'PUREINT'        
C        
C     LAST REVISED, 12/92, BY G.CHAN/UNISYS, TO INCLUDE 3 SPECIAL TABLES
C     - KELM, MELM, BELM  - WHICH CONTAIN D.P. DATA WORDS IN 32- AND 36-
C     BIT WORD MACHINES.        
C        
C     IF OP CODE IS 'PUREBCD', RECORDS IRC AND THEREAFTER, AND BEGINNING
C     FROM WORD IWD OF EACH RECORD TO THE END OF THAT RECORD, ARE ALL   
C     BCD  WORDS.        
C     SIMILARILY FOR 'PUREINT' FOR INTEGER WORDS, AND 'PUREFPN' FOR     
C     FLOATING POINT NUMBERS        
C        
C     THESE PARAMETER OPTIONS ARE NECESSARY BECAUSE IF THE PRINTED DATA 
C     IS NOT OF STRING TYPE, SUBROUTINE NUMTYP IS CALLED TO FIND OUT    
C     WHAT TYPE OF DATA IN EACH DATA WORD.  HOWEVER NUMTYP IS NOT 100   
C     PERCENT FOOL-PROOF. ONCE IN A FEW THOUSANDS NUMTYP CAN NOT        
C     DISTINGUISH A REAL NUMBER FROM A BCD WORD        
C        
C  $MIXED_FORMATS        
C        
      LOGICAL          DEC        
      INTEGER          BLOCK(20),TYPES(4),FORMAT,FORMS(2),JPOINT,ROW,   
     1                 TYPE,FLAG,RECF,STRNBR,SYSBUF,OTPE,PURE,BCD,FPN,  
     2                 OP,NAME(2),ICORE(133)        
      REAL             XNS(1),SP(3)        
      DOUBLE PRECISION XND(1),DCORE(1)        
      CHARACTER        UFM*23,UWM*25        
      COMMON /XMSSG /  UFM,UWM        
      COMMON /BLANK /  OP(2),IRC,IWD        
      COMMON /MACHIN/  MACH        
      COMMON /SYSTEM/  SYSBUF,OTPE,INX(6),NLPP,INX1(2),LINE,DUM(42),IPRC
      COMMON /OUTPUT/  HEAD1(96),HEAD2(96)        
CZZ   COMMON /ZZTBPR/  CORE(1)        
      COMMON /ZZZZZZ/  CORE(1)        
CZZ   COMMON /XNSTRN/  XND        
      EQUIVALENCE      (XND(1),CORE(1))        
      EQUIVALENCE      (XNS(1),XND(1)),  (ICORE(1),CORE(1),DCORE(1)),   
     1                 (BLOCK(2), TYPE   ), (BLOCK(3), FORMAT),        
     2                 (BLOCK(4), ROW    ), (BLOCK(5), JPOINT),        
     3                 (BLOCK(6), NTERMS ), (BLOCK(8), FLAG  )        
      DATA    OPAREN,  CPAREN,EC,EC1,EC2,INTGC,ALPHC,ALPHC1,CONT,UNED / 
     1        4H(1X ,  4H)   ,4H,1P,,4HE13.,2H6 ,4H,I13,4H,9X,,4HA4   , 
     2        4HCONT,  4HINUE   /  D/2HD  /, NAME  / 4HTABP,4HRT      / 
      DATA    BLANK ,  TABL,EBB /  1H  ,4HTABL, 1HE     /        
      DATA    TYPES /  3HRSP,3HRDP,3HCSP ,3HCDP/, FORMS / 3HYES ,2HNO / 
      DATA    PURE  ,  BCD,FPN,INT /   4HPURE, 4HBCD , 4HFPN , 4HINT  / 
      DATA    NSP   ,  SP / 3, 4HKELM, 4HMELM, 4HBELM   /        
C        
      NZ  = KORSZ(CORE) - SYSBUF        
      IF (NZ .LE. 0) CALL MESAGE (-8,-NZ,NAME)        
      DEC = MACH.EQ.5 .OR. MACH.EQ.6 .OR. MACH.EQ.10 .OR. MACH.EQ.21    
      INAME = INAME1        
      CALL OPEN (*190,INAME,CORE(NZ+1),0)        
      DO 10 I = 1,96        
   10 HEAD2(I) = BLANK        
      HEAD2(1) = TABL        
      HEAD2(2) = EBB        
      CALL FNAME (INAME,HEAD2(3))        
      CALL PAGE        
      HEAD2(6) = CONT        
      HEAD2(7) = UNED        
      HEAD2(8) = D        
      IF (IPRC.EQ.1 .OR. INAME.NE.101) GO TO 15        
      CALL PAGE2 (-2)        
      WRITE  (OTPE,13) UWM        
   13 FORMAT (A25,', TABPRT MODULE ASSUMES ALL REAL DATA ARE IN S.P.,', 
     1       ' D.P. DATA THEREFORE MAY BE PRINTED ERRONEOUSLY')        
   15 INUM     = NZ/2 - 1        
      INUM     = MAX0(INUM,133)        
      NS       = INUM + 1        
      LLEN     = 0        
      CORE(1)  = OPAREN        
      IREC     = 0        
      IRCD     = 999999999        
      IXXX     = 999999999        
      IF (OP(1).NE.PURE .OR. OP(2).EQ.BLANK) GO TO 20        
      IF (OP(2) .EQ. INT) JJ = 2        
      IF (OP(2) .EQ. FPN) JJ = 3        
      IF (OP(2) .EQ. BCD) JJ = 4        
      IF (IRC .GT. 0) IRCD = IRC        
      IF (IWD .GT. 0) IXXX = IWD + INUM        
      IF (IRC .LE. 0) IRCD = 3        
      IF (IWD .LE. 0) IXXX = 3 + INUM        
   20 CALL PAGE2 (-2)        
      IF (DEC .AND. IREC.EQ.0) WRITE (OTPE,25)        
   25 FORMAT (4X,'(ALL INTEGERS EXCEEDING 16000 ARE PRINTED AS REAL ',  
     1        'NUMBERS. ALL REAL NUMBERS OUTSIDE E-27 OR E+27 RANGE ',  
     2        'ARE PRINTED AS INTEGERS)')        
      WRITE  (OTPE,30) IREC        
   30 FORMAT (/,' RECORD NO.',I6)        
      IREC = IREC + 1        
      DO 35 I  = 1,NSP        
      IF (HEAD2(3) .NE. SP(I)) GO TO 35        
      ICORE(1) = INAME        
      CALL RDTRL (ICORE)        
      IF (ICORE(2) .EQ. 2) GO TO 60        
   35 CONTINUE        
      IX   = INUM        
      NRED = 0        
      NP   = INUM - 1        
      BLOCK(1) = INAME1        
      CALL RECTYP (BLOCK,RECF)        
      IF (RECF .NE. 0) GO TO 200        
      JV   = 4        
   40 IX   = IX + 1        
      IOUT = 4        
      NRED = NRED + 1        
      NP   = NP + 1        
      CALL READ (*170,*160,INAME,CORE(IX),1,0,IFLAG)        
C        
      IF (IREC.GT.IRCD .OR. IX.GT.IXXX) GO TO 50        
      JJ = NUMTYP(ICORE(IX)) + 1        
      IF (JJ.EQ.1 .AND. JV.NE.4) JJ = JV        
      JV = JJ        
   50 GO TO (140,140,100,120), JJ        
C        
C     TABLES KELM, MELM, AND BELM - D.P. DATA ONLY        
C        
   60 CALL READ (*170,*170,INAME,CORE(1),2,1,IFLAG)        
      WRITE  (OTPE,65) ICORE(1),ICORE(2)        
   65 FORMAT (10X,2A4)        
   70 WRITE  (OTPE,30) IREC        
      CALL READ (*170,*80,INAME,CORE(1),NZ,1,IFLAG)        
      CALL MESAGE (-8,0,NAME)        
   80 NP   = IFLAG/2        
      JJ   = (NP+9)/10        
      CALL PAGE2 (-JJ)        
      IREC = IREC + 1        
      WRITE  (OTPE,90,ERR=70) (DCORE(I),I=1,NP)        
   90 FORMAT (1X,1P,10D13.6)        
      GO TO 70        
C        
C     REAL NUMBER  (1)        
C        
  100 IOUT = 1        
      IF (LLEN+13 .GT. 132) GO TO 160        
  110 CORE(NRED+1) = EC        
      CORE(NRED+2) = EC1        
      CORE(NRED+3) = EC2        
      NRED = NRED + 2        
  115 LLEN = LLEN + 13        
      GO TO 40        
C        
C     ALPHA  (2)        
C        
  120 IOUT = 2        
      IF (LLEN+6 .GT. 132) GO TO 160        
  130 CORE(NRED+1) = ALPHC        
      CORE(NRED+2) = ALPHC1        
      NRED = NRED + 1        
      GO TO 115        
C        
C     INTEGER  (3)        
C        
  140 IOUT = 3        
      IF (LLEN+13 .GT. 132) GO TO 160        
  150 ICORE(NRED+1) = INTGC        
      GO TO 115        
C        
C     BUFFER FULL- END RECORD AND PRINT THE LINE        
C        
C     PREVIOUSLY, THE FORMAT IS IN CORE, WHICH IS DIMENSIONED TO 1.     
C     THIS MAY NOT WORK IN SOME MACHINES. THE FORMAT IS NOW SPECIFIED IN
C     ICORE, WHICH IS DIMENSIONED TO 133.        
C     (CORE AND ICORE ARE EQUIVALENT)        
C        
  160 CORE(NRED+1) = CPAREN        
      IF (NRED .GE. 133) CALL MESAGE (-37,0,NAME)        
      CALL PAGE2 (-1)        
      IF (NRED .EQ. 1) GO TO 165        
C     IF (MACH .EQ. 3) GO TO 162        
C 161 CONTINUE        
      WRITE (OTPE,ICORE,ERR=164) (CORE(I),I=NS,NP)        
C     GO TO 164        
C        
C     UNIVAC ONLY        
C        
C     (COMMENT FROM G.CHAN/UNISYS   1/93        
C     UNIVAC FTN VERSION SHOULD BE ABLE TO USE ABOVE WRITE STATEMENT.   
C     SUBROUTINE WRTFMT.MDS IS USED ONLY HERE AND IN WRTMSG. IT IS      
C     THEREFORE REMOVED FROM NASTRAN SOURCE CODE)        
C        
C 162 CALL WRTFMT (ICORE(NS),NP-NS+1,CORE)        
C        
  164 CONTINUE        
      LLEN = 0        
      NRED = 1        
      NP   = INUM        
C        
C     FINISH SEMI-PROCESSED WORD.        
C        
      CORE(INUM+1) = CORE(IX)        
      IX = INUM + 1        
      GO TO (110,130,150,20), IOUT        
C        
  165 WRITE  (OTPE,166)        
  166 FORMAT (' THIS RECORD IS NULL.')        
C        
C     GO TO 161 IS LOGICALLY UNSOUND. CHANG TO 164. (G.CHAN/UNISYS 1/93)
C     GO TO 161        
      GO TO 164        
C        
  170 CALL CLOSE (INAME,1)        
      CALL PAGE2 (-2)        
      WRITE  (OTPE,180)        
  180 FORMAT (//,' END OF FILE')        
C        
C     PRINT TRAILER FOR FILE        
C        
  190 ICORE(1) = INAME        
      CALL RDTRL (ICORE)        
      CALL PAGE2 (-2)        
      WRITE  (OTPE,195) (ICORE(I),I=2,7)        
  195 FORMAT ('0TRAILER WORD1 =',I8,' WORD2 =',I8,' WORD3 =',I8,        
     1                ' WORD4 =',I8,' WORD5 =',I8,' WORD6 =',I8)        
      RETURN        
C        
C        
C     HERE IF STRING FORMATTED RECORD        
C        
  200 FLAG   =-1        
      STRNBR = 1        
      CALL GETSTR (*250,BLOCK)        
      IFORM = FORMAT + 1        
  205 CALL PAGE2 (-2)        
      WRITE  (OTPE,206) STRNBR,ROW,TYPES(TYPE),FORMS(IFORM),NTERMS      
  206 FORMAT ('0STRING NO.',I5,'   ROW POSITION=',I5,'   STRING TYPE=', 
     1        A3,'   STRING TRAILERS=',A3,'   NUMBER OF TERMS=',I5)     
      STRNBR = STRNBR + 1        
      GO TO (210,220,230,240), TYPE        
C        
C     PRINT REAL SINGLE PRECISION STRING        
C        
  210 NPOINT = JPOINT + NTERMS - 1        
      J = JPOINT        
  211 N = MIN0(J+7,NPOINT)        
      CALL PAGE2 (-1)        
      WRITE  (OTPE,212) (XNS(I),I=J,N)        
  212 FORMAT (1X,8(1P,E15.7))        
      IF (N .EQ. NPOINT) GO TO 214        
      J = N + 1        
      GO TO 211        
  214 CALL ENDGET (BLOCK)        
      CALL GETSTR (*20,BLOCK)        
      GO TO 205        
C        
C     PRINT STRING IN REAL DOUBLE PRECISION        
C        
  220 NPOINT = JPOINT + NTERMS - 1        
      J = JPOINT        
  221 N = MIN0(J+7,NPOINT)        
      CALL PAGE2 (-1)        
      WRITE  (OTPE,222) (XND(I),I=J,N)        
  222 FORMAT (1X,8(1P,D15.7))        
      IF (N .EQ. NPOINT) GO TO 224        
      J = N + 1        
      GO TO 221        
  224 CALL ENDGET (BLOCK)        
      CALL GETSTR (*20,BLOCK)        
      GO TO 205        
C        
C     PRINT STRING IN COMPLEX SINGLE PRECISION        
C        
  230 NPOINT = JPOINT + 2*NTERMS - 1        
      J = JPOINT        
  231 N = MIN0(J+7,NPOINT)        
      CALL PAGE2 (-1)        
      WRITE  (OTPE,232) (XNS(I),I=J,N)        
  232 FORMAT (1X,4(1P,E14.7,1P,E15.7,2H//))        
      IF (N .EQ. NPOINT) GO TO 234        
      J = N + 1        
      GO TO 231        
  234 CALL ENDGET (BLOCK)        
      CALL GETSTR (*20,BLOCK)        
      GO TO 205        
C        
C     PRINT STRING IN COMPLEX DOUBLE PRECISION        
C        
  240 NPOINT = JPOINT + 2*NTERMS - 1        
      J = JPOINT        
  241 N = MIN0(J+7,NPOINT)        
      CALL PAGE2 (-1)        
      WRITE  (OTPE,242) (XND(I),I=J,N)        
  242 FORMAT (1X,4(1P,D14.7,1P,D15.7,2H//))        
      IF (N .EQ. NPOINT) GO TO 244        
      J = N + 1        
      GO TO 241        
  244 CALL ENDGET (BLOCK)        
      CALL GETSTR (*20,BLOCK)        
      GO TO 205        
C        
C     PRINT NULL COLUMN        
C        
  250 CALL PAGE2 (-1)        
      WRITE  (OTPE,252)        
  252 FORMAT (5X,'NULL COLUMN')        
      GO TO 20        
C        
      END        
