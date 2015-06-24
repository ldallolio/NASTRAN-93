      SUBROUTINE MPY3DR (Z)        
C        
C     SECONDARY DRIVER IF MPY3DR IS CALLED BY MPY3        
C     PRIMARY   DRIVER IF CALLED BY OTHERS (COMB2 AND MRED2 GROUP)      
C        
C     SETS UP OPEN CORE AND DETERMINES SOLUTION METHOD.        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL         ANDF,ORF,COMPLF,LSHIFT        
      LOGICAL          E        
      INTEGER          Z(1),MPY(3),MCB(7,3),NAME(2)        
      REAL             RHOA,RHOB,RHOE,TCOL,TIMCON,TIMEM,TIMEM1,TIMEM2,  
     1                 TIMEM3        
      DOUBLE PRECISION DD,NN,MM,PP,XX        
      CHARACTER        UFM*23,UWM*25,UIM*29        
      COMMON /XMSSG /  UFM,UWM,UIM        
      COMMON /MPY3TL/  FILEA(7),FILEB(7),FILEE(7),FILEC(7),SCR1,SCR2,   
     1                 SCR3,LKORE,CODE,PREC,LCORE,SCR(7),BUF1,BUF2,     
     2                 BUF3,BUF4,E        
      COMMON /MPY3CP/  ITRL,ICORE,N,NCB,M,NK,D,MAXA,DUMCP(34)        
      COMMON /NTIME /  TIMCON(16)        
      COMMON /SYSTEM/  SYSBUF,NOUT,DUM1(22),DIAG,DUM2(32),METH        
      COMMON /MPYADX/  MFILEA(7),MFILEB(7),MFILEE(7),MFILEC(7),MCORE,   
     1                 MT,SIGNAB,SIGNC,MPREC,MSCR,TIMEM        
      EQUIVALENCE      (AC,FILEA(2)), (AR,FILEA(3)),        
     1                 (BC,FILEB(2)), (BR,FILEB(3)),        
     2                 (BF,FILEB(4)), (EC,FILEE(2)),        
     3                 (ER,FILEE(3)), (EF,FILEE(4))        
      EQUIVALENCE      (MCB(1,1),FILEA(1))        
      DATA    NAME  /  4HMPY3,4HDR          /        
      DATA    MPY   /  4HMPY3,4H    ,4H     /        
      DATA    JBEGN ,  JEND  /4HBEGN,4HEND  /        
C        
C     RETURN IF EITHER A OR B IS PURGED        
C        
      IF (FILEA(1) .LT. 0) RETURN        
      IF (FILEB(1) .LT. 0) RETURN        
C        
C     TEST FOR MATRIX COMPATABILITY.        
C        
      MPY(3) = JBEGN        
      CALL CONMSG (MPY,3,0)        
C        
      SCR(1) = SCR3        
      IF (CODE .NE. 0) GO TO 5        
      IF (BF.EQ.2  .OR.  BF.EQ.  7) GO TO 901        
    5 IF (AR.NE.BR .AND. CODE.EQ.1) GO TO 902        
      IF (AR.NE.BC .AND. CODE.NE.1) GO TO 903        
      IF (FILEE(1) .LE. 0) GO TO 15        
      E = .TRUE.        
      IF (CODE .NE. 0) GO TO 10        
      IF (EF.EQ.2 .OR. EF.EQ.7) GO TO 905        
   10 IF (EC.NE.BC .AND. CODE.EQ.1) GO TO 909        
      IF (EC.NE.AC .AND. CODE.NE.1) GO TO 904        
      IF (ER.NE.AC .AND. CODE.EQ.1) GO TO 910        
      IF (ER.NE.BR .AND. CODE.EQ.2) GO TO 906        
      GO TO 30        
C        
   15 E = .FALSE.        
      DO 20 I = 1,7        
   20 FILEE(I) = 0        
C        
C     CORE ALLOCATION.        
C        
   30 BUF1 = LKORE - SYSBUF        
      BUF2 = BUF1  - SYSBUF        
      BUF3 = BUF2  - SYSBUF        
      BUF4 = BUF3  - SYSBUF        
      LCORE= BUF4  - 1        
      IF (LCORE .LT. 0) GO TO 2008        
C        
C     IF REQUESTED CALCULATE THE OUTPUT PRECISION        
C        
      IF (PREC.GE.1 .AND. PREC.LE.4) GO TO 46        
      IPRC = 1        
      ITYP = 0        
      DO 45 I = 1,3        
      IF (MCB(5,I).EQ.2 .OR. MCB(5,I).EQ.4) IPRC = 2        
      IF (MCB(5,I) .GE. 3) ITYP = 2        
   45 CONTINUE        
      PREC = ITYP + IPRC        
      IF (PREC .LE. 2) FILEC(5) = PREC        
   46 CONTINUE        
C        
C     DETERMINE NK, THE NUMBER OF COLUMNS OF B MATRIX ABLE TO BE HELD   
C     IN CORE.        
C        
      N   = FILEB(3)        
      NCB = FILEB(2)        
      M   = FILEA(2)        
      D   = FILEA(7) + 1        
      MAXA= FILEA(6)/FILEA(5)        
C     NK  = (LCORE - 2*N - D*(1+PREC)*N*M/10000 - PREC*M -        
C    1      (2+PREC)*MAXA)/(2+PREC*N)        
C        
C     (NCB SHOULD BE USED IN THE ABOVE EQUATION INSTEAD OF N. SEE       
C     MPY3IC)        
C        
      DD = D        
      NN = NCB        
      MM = M        
      PP = 1 + PREC        
      XX = DD*PP*NN*MM/10000.D0        
      IXX= XX + 0.5D0        
      NK = (LCORE - 2*NCB - IXX - PREC*M - PREC - (2+PREC)*MAXA)/       
     1     (2+PREC*N)        
C        
C     SET UP CONSTANTS IN MPYADX COMMON        
C        
      MSCR  = SCR2        
      MCORE = LKORE        
      MPREC = 0        
      SIGNAB= 1        
      SIGNC = 1        
C        
C     CALCULATE PROPERTIES OF THE MATRICES        
C        
      RHOA  = (FILEA(7)+1)/10000.        
      RHOB  = (FILEB(7)+1)/10000.        
      RHOE  = (FILEE(7)+1)/10000.        
      AELMS = AR*AC*RHOA        
      BELMS = BR*BC*RHOB        
      EELMS = ER*EC*RHOE        
C        
C     CALCULATE MPY3 TIME ESTIMATE - REMEMBER NO COMPLEX FOR MPY3       
C        
      CALL SSWTCH (19,L19)        
      TIMEM3 = 1.0E+10        
      IF (PREC .GE. 3) GO TO 100        
      IF (CODE .EQ. 1) GO TO 100        
      TIMEM3 = (RHOA + 2./FLOAT(M))*FLOAT(M)*FLOAT(N)*        
     1         (FLOAT(M) + FLOAT(N))*TIMCON(8+PREC) +        
     2         (FLOAT(N)**2 + FLOAT(M)**2 + RHOA*FLOAT(M)*        
     3         FLOAT(N)*(2. + FLOAT(M)))*TIMCON(5)        
      TIMEM3 = TIMEM3/1.0E6        
      IF (L19 .NE. 0) WRITE (NOUT,50) FILEA(1),AR,AC,AELMS,RHOA,        
     1                                FILEB(1),BR,BC,BELMS,RHOB,        
     2                                FILEE(1),ER,EC,EELMS,RHOE,        
     3                                CODE,LCORE,NK,TIMEM3        
   50 FORMAT (50H0(A MAT  ROWS  COLS   TERMS    DENS) (B MAT  ROWS ,    
     1        50H COLS   TERMS    DENS) (E MAT  ROWS  COLS   TERMS ,    
     2        32H   DENS) C  CORE    NK      TIME /        
     3        3(I6,I7,I6,I9,F7.4,1X),I2,I6,I6,F10.1 )        
C        
      IF (NK.GE.3 .OR. CODE.EQ.2) GO TO 70        
      DO 60 I = 1,7        
      MFILEA(I) = FILEA(I)        
   60 MFILEE(I) = FILEE(I)        
      CALL MAKMCB (MFILEB,SCR1,BR,2,PREC)        
      MFILEB(2) = AC        
      TCOL = FLOAT(BELMS)*FLOAT(AELMS)/FLOAT(AR)/FLOAT(AC)        
      MFILEB(6) = TCOL + 1.0        
      MFILEB(7) = TCOL/BR*1.0E+4        
      MFILEC(1) = -1        
      MFILEC(5) = PREC        
      MT = 1        
      CALL MPYAD (Z(1),Z(1),Z(1))        
      TIMEM3 = TIMEM3 + TIMEM        
C        
   70 WRITE  (NOUT,80) UIM,TIMEM3        
   80 FORMAT (A29,' 6525, TRIPLE MULTIPLY TIME ESTIMATE FOR MPY3 = ',   
     1        F10.1,' SECONDS.')        
C        
C     CALCULATE MPYAD TIME ESTIMATE FOR (AT*B)*A + E        
C        
  100 TIMEM1 = 1.0E+10        
      IF (CODE .EQ. 2) GO TO 200        
      DO 110 I = 1,7        
      MFILEA(I) = FILEA(I)        
      MFILEB(I) = FILEB(I)        
      IF (CODE .EQ. 1) MFILEE(I) = FILEE(I)        
      IF (CODE .NE. 1) MFILEE(I) = 0        
  110 CONTINUE        
      CALL MAKMCB (MFILEC,-1,AC,2,PREC)        
      MT = 1        
      CALL MPYAD (Z(1),Z(1),Z(1))        
      TIMEM1 = TIMEM        
      IF (CODE .EQ. 1) GO TO 130        
C        
      DO 120 I = 1,7        
      MFILEB(I) = MFILEA(I)        
      MFILEA(I) = MFILEC(I)        
  120 MFILEE(I) = FILEE(I)        
      MFILEA(1) = SCR1        
      MFILEA(2) = BC        
      TCOL = FLOAT(BELMS)*FLOAT(AELMS)/FLOAT(AR)/FLOAT(BC)        
      MFILEA(6) = TCOL + 1.0        
      MFILEA(7) = TCOL/AC*1.0E+4        
      MT = 0        
      CALL MPYAD (Z(1),Z(1),Z(1))        
      TIMEM1 = TIMEM1 + TIMEM        
C        
  130 WRITE  (NOUT,140) UIM,TIMEM1        
  140 FORMAT (A29,' 6525, TRIPLE MULTIPLY TIME ESTIMATE FOR MPYAD - ',  
     1       '(AT*B)*A + E = ',F10.1,' SECONDS.')        
C        
C     CALCULATE MPYAD TIME ESTIMATE FOR AT*(B*A) + E        
C        
  200 TIMEM2 = 1.0E+10        
      IF (CODE .EQ. 1) GO TO 290        
      DO 210 I = 1,7        
      MFILEA(I) = FILEB(I)        
      MFILEB(I) = FILEA(I)        
      IF (CODE .EQ. 2) MFILEE(I) = FILEE(I)        
      IF (CODE .NE. 2) MFILEE(I) = 0        
  210 CONTINUE        
      CALL MAKMCB (MFILEC,-1,BR,2,PREC)        
      MT = 0        
      CALL MPYAD (Z(1),Z(1),Z(1))        
      TIMEM2 = TIMEM        
      IF (CODE .EQ. 2) GO TO 230        
C        
      DO 220 I = 1,7        
      MFILEA(I) = MFILEB(I)        
      MFILEB(I) = MFILEC(I)        
  220 MFILEE(I) = FILEE(I)        
      MFILEB(1) = SCR1        
      MFILEB(2) = AC        
      TCOL = FLOAT(BELMS)*FLOAT(AELMS)/FLOAT(AR)/FLOAT(AC)        
      MFILEB(6) = TCOL + 1.0        
      MFILEB(7) = TCOL/BR*1.0E+4        
      MT = 1        
      CALL MPYAD (Z(1),Z(1),Z(1))        
      TIMEM2 = TIMEM2 + TIMEM        
C        
  230 WRITE  (NOUT,240) UIM,TIMEM2        
  240 FORMAT (A29,' 6525, TRIPLE MULTIPLY TIME ESTIMATE FOR MPYAD - ',  
     1        'AT*(B*A) + E = ',F10.1,' SECONDS.')        
C        
C     CHOOSE METHOD BASED ON THE BEST TIME ESTIMATE OR USER REQUEST     
C        
  290 CALL TMTOGO (TTG)        
      IF (FLOAT(TTG) .LE. 1.2*AMIN1(TIMEM3,TIMEM1,TIMEM2)) GO TO 908    
      DIAG  = ANDF(DIAG,COMPLF(LSHIFT(1,18)))        
      KMETH = METH        
      JMETH = METH        
      METH  = 0        
      IF (JMETH.LT.1 .OR. JMETH.GT.3) JMETH = 0        
      IF (JMETH.EQ.1 .AND. CODE.EQ.2) JMETH = 0        
      IF (JMETH.EQ.2 .AND. CODE.EQ.1) JMETH = 0        
      IF (JMETH.EQ.3 .AND. CODE.EQ.1) JMETH = 0        
      IF (JMETH .NE. 0) GO TO (400,500,300), JMETH        
      FILEC(4) = FILEB(4)        
C        
      IF (TIMEM3.LT.TIMEM1 .AND. TIMEM3.LT.TIMEM2) GO TO 300        
      IF (TIMEM1 .LT. TIMEM2) GO TO 400        
      GO TO 500        
C        
C     PERFORM MULTIPLY WITH MPY3        
C        
  300 IF (NK .LT. 3) GO TO 310        
      ICORE = 0        
      CALL MPY3IC (Z(1),Z(1),Z(1))        
      GO TO 9999        
C        
C     OUT OF CORE PROCESSING FOR MPY3        
C        
  310 ICORE = 1        
      WRITE  (NOUT,320) UIM        
  320 FORMAT (A29,' 6526,  THE CENTER MATRIX IS TOO LARGE FOR', /5X,    
     1       'IN-CORE PROCESSING.  OUT-OF-CORE PROCESSING WILL BE ',    
     2       'PERFORMED.')        
C        
      NK = (LCORE - 4*NCB - PREC*M - (2+PREC)*MAXA)/(2+PREC*N)        
      CALL MPY3OC (Z(1),Z(1),Z(1))        
      FILEC(4) = FILEB(4)        
      GO TO 9999        
C        
C     PERFORM MULTIPLY WITH MPYAD DOING (AT * B) FIRST        
C        
  400 DO 410 I = 1,7        
      MFILEA(I) = FILEA(I)        
      MFILEB(I) = FILEB(I)        
      IF (CODE .EQ. 1) MFILEE(I) = FILEE(I)        
      IF (CODE .NE. 1) MFILEE(I) = 0        
  410 CONTINUE        
      CALL MAKMCB (MFILEC,SCR1,AC,2,PREC)        
      IF (CODE .EQ. 1) MFILEC(1) = FILEC(1)        
      MT = 1        
      CALL MPYAD (Z(1),Z(1),Z(1))        
      IF (CODE .EQ. 1) GO TO 425        
      CALL WRTTRL (MFILEC)        
C        
      DO 420 I = 1,7        
      MFILEB(I) = MFILEA(I)        
      MFILEA(I) = MFILEC(I)        
  420 MFILEE(I) = FILEE(I)        
      CALL MAKMCB (MFILEC,FILEC(1),AC,FILEB(4),PREC)        
      MT = 0        
      CALL MPYAD (Z(1),Z(1),Z(1))        
  425 DO 430 I = 1,7        
  430 FILEC(I) = MFILEC(I)        
      GO TO 9999        
C        
C     PERFORM MULTIPLY WITH MPYAD DOING (B*A) FIRST        
C        
  500 DO 510 I = 1,7        
      MFILEA(I) = FILEB(I)        
      MFILEB(I) = FILEA(I)        
      IF (CODE .EQ. 2) MFILEE(I) = FILEE(I)        
      IF (CODE .NE. 2) MFILEE(I) = 0        
  510 CONTINUE        
      CALL MAKMCB (MFILEC,SCR1,BR,2,PREC)        
      IF (CODE .EQ. 2) MFILEC(1) = FILEC(1)        
      MT = 0        
      CALL MPYAD (Z(1),Z(1),Z(1))        
      IF (CODE .EQ. 2) GO TO 525        
      CALL WRTTRL (MFILEC)        
C        
      DO 520 I = 1,7        
      MFILEA(I) = MFILEB(I)        
      MFILEB(I) = MFILEC(I)        
  520 MFILEE(I) = FILEE(I)        
      CALL MAKMCB (MFILEC,FILEC(1),AC,FILEB(4),PREC)        
      MT = 1        
      CALL MPYAD (Z(1),Z(1),Z(1))        
  525 DO 530 I = 1,7        
  530 FILEC(I) = MFILEC(I)        
      GO TO 9999        
C        
C    ERROR MESSAGES.        
C        
  901 WRITE (NOUT,9001) UFM        
      GO TO 1001        
  902 WRITE (NOUT,9002) UFM        
      GO TO 1001        
  903 WRITE (NOUT,9003) UFM        
      GO TO 1001        
  904 WRITE (NOUT,9004) UFM        
      GO TO 1001        
  905 WRITE (NOUT,9005) UFM        
      GO TO 1001        
  906 WRITE (NOUT,9006) UFM        
      GO TO 1001        
  908 WRITE (NOUT,9008) UFM        
      GO TO 1001        
  909 WRITE (NOUT,9009) UFM        
      GO TO 1001        
  910 WRITE (NOUT,9010) UFM        
 1001 CALL MESAGE (-37,0,NAME)        
 2008 CALL MESAGE ( -8,0,NAME)        
 9001 FORMAT (A23,'6551, MATRIX B IN MPY3 IS NOT SQUARE FOR A(T)BA + E',
     1       ' PROBLEM.')        
 9002 FORMAT (A23,' 6552, NO. OF ROWS OF MATRIX A IN MPY3 IS UNEQUAL TO'
     1,      /5X,'NO. OF ROWS OF MATRIX B FOR A(T)B + E PROBLEM.')      
 9003 FORMAT (A23,' 6553, NO. OF ROWS OF MATRIX A IN MPY3 IS UNEQUAL TO'
     1       /5X,'NO. OF COLUMNS OF MATRIX B FOR A(T)BA + E PROBLEM.')  
 9004 FORMAT (A23,' 6554, NO. OF COLUMNS OF MATRIX E IN MPY3 IS UNEQUAL'
     1,      /5X,'TO NO. OF COLUMNS OF MATRIX A FOR A(T)BA +E PROBLEM.')
 9005 FORMAT (A23,' 6555, MATRIX E IN MPY3 IS NOT SQUARE FOR A(T)BA + ',
     1       'E PROBLEM.')        
 9006 FORMAT (A23,' 6556, NO. OF ROWS OF MATRIX E IN MPY3 IS UNEQUAL TO'
     1,      /5X,'NO. OF ROWS OF MATRIX B FOR BA + E PROBLEM.')        
 9008 FORMAT (A23,' 6558, INSUFFICIENT TIME REMAINING FOR MPY3 ',       
     1       'EXECUTION.')        
 9009 FORMAT (A23,' 6524, NO. OF COLUMNS OF MATRIX E IN MPY3 IS UNEQUAL'
     1,      ' TO',/5X,'NO. OF COLUMNS OF MATRIX B FOR A(T)B + E ',     
     2       'PROBLEM.')        
 9010 FORMAT (A23,' 6559, NO. OF ROWS OF MATRIX E IN MPY3 IS UNEQUAL TO'
     1,      /5X,'NO. OF COLUMNS OF MATRIX A FOR A(T)B + E PROBLEM.')   
C        
C     RETURN        
C        
 9999 DIAG = ORF(DIAG,LSHIFT(L19,18))        
      METH = KMETH        
      MPY(3) = JEND        
      CALL CONMSG (MPY,3,0)        
      RETURN        
      END        
