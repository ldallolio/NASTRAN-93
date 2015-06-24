      SUBROUTINE IFPPAR        
C        
C     SUBROUTINE TO TEST FOR PARAM CARD PARAMETERS REQUIRED BY VARIOUS  
C     RIGID FORMATS.        
C        
      LOGICAL         ABORT,HFREQ,LFREQ,LMODE,NODJE,P1,P2,P3,PTOT,      
     1                CTYPE,KINDX,NSEGS,LTEST,QUEUE        
      INTEGER         RF,APP,HFRE,CTYP,QUE,APPR(4)        
      CHARACTER       UFM*23,UWM*25        
      COMMON /XMSSG / UFM,UWM        
      COMMON /SYSTEM/ N1,NOUT,ABORT,N2(17),IAPP,N3(3),RF        
      COMMON /IFPDTA/ IDTA(509),NPARAM        
CZZ   COMMON /ZZIFPX/ IBUFF(1)        
      COMMON /ZZZZZZ/ IBUFF(1)        
      DATA    APPR  / 4HDMAP,   4HDISP, 4HHEAT,   4HAERO        /       
      DATA    HFRE  / 4HHFRE /, LFRE /  4HLFRE /, LMOD  /4HLMOD /       
      DATA    NODJ  / 4HNODJ /, IP1  /  4HP1   /, IP2   /4HP2   /       
      DATA    IP3   / 4HP3   /, QUE  /  4HQ                     /       
      DATA    CTYP  / 4HCTYP /, KIND /  4HKIND /, NSEG  /4HNSEG /       
      DATA    HFREQ / .FALSE./, LFREQ/  .FALSE./, LMODE /.FALSE./       
      DATA    NODJE / .FALSE./, CTYPE/  .FALSE./, KINDX /.FALSE./       
      DATA    NSEGS / .FALSE./, P1   /  .FALSE./, P    2/.FALSE./       
      DATA    QUEUE / .FALSE./, P3   /  .FALSE.                 /       
C        
      APP = IABS(IAPP)        
C        
C     NO PARAMS REQD FOR HEAT APPROACH,        
C     DMAPS DISP 1 THRU 9, DISP 13, AND DISP 16 THRU 19, AND        
C     AERO RF 9        
C        
      IF (APP.EQ.1 .OR.  APP.EQ.3) GO TO 9999        
      IF (APP.EQ.2 .AND. (RF.LE.9 .OR. RF.EQ.13 .OR. RF.GE.16))        
     1    GO TO 9999        
      IF (APP.EQ.4 .AND.  RF.EQ.9) GO TO 9999        
C        
C     FATAL ERROR IF NO PARAMS ENTERED AS REQUIRED        
C        
      IF (NPARAM .EQ. 0) GO TO 9800        
C        
C     LOOP TO TEST PARAMS IN PVT FOR PRESENCE OF REQUIRED ONES.        
C        
      IPM = 1        
  500 IPN = 2*N1 + IPM        
C        
      IF (RF .GE. 14) GO TO 1000        
      IF (IBUFF(IPN) .EQ. HFRE) HFREQ = .TRUE.        
      IF (IBUFF(IPN) .EQ. LFRE) LFREQ = .TRUE.        
      IF (IBUFF(IPN).EQ.LMOD .AND. IBUFF(IPN+2).NE.0) LMODE = .TRUE.    
C        
      IF (APP .NE. 4) GO TO 2000        
      IF (IBUFF(IPN).EQ.NODJ .AND. IBUFF(IPN+2).NE.0) NODJE = .TRUE.    
      IF (IBUFF(IPN) .EQ. IP1) P1 = .TRUE.        
      IF (IBUFF(IPN) .EQ. IP2) P2 = .TRUE.        
      IF (IBUFF(IPN) .EQ. IP3) P3 = .TRUE.        
      IF (IBUFF(IPN).EQ.QUE  .AND. IBUFF(IPN+2).NE.0) QUEUE = .TRUE.    
      GO TO 2000        
C        
 1000 IF (IBUFF(IPN).EQ.CTYP .AND. IBUFF(IPN+2).NE.0) CTYPE = .TRUE.    
      IF (IBUFF(IPN).EQ.NSEG .AND. IBUFF(IPN+2).NE.0) NSEGS = .TRUE.    
      IF (IBUFF(IPN).EQ.KIND .AND. IBUFF(IPN+2).NE.0) KINDX = .TRUE.    
C        
 2000 IPM = IPM + 4        
      IF (IBUFF(IPN+2).GE.3 .AND. IBUFF(IPN+2).LE.5) IPM = IPM + 1      
      IF (IBUFF(IPN+2) .GE. 6) IPM = IPM + 3        
      IF (IPM .LT. NPARAM) GO TO 500        
C        
C     TEST TO VERIFY THAT ALL REQUIRED PARAMS ARE PRESENT        
C        
      IF (RF.EQ.14 .OR. RF.EQ.15) GO TO 4000        
      IF (LMODE .AND.  .NOT.(HFREQ.OR.LFREQ)) GO TO 3000        
      IF (HFREQ .AND. LFREQ .AND. .NOT.LMODE) GO TO 3000        
C        
C     SOMETING AMISS - - IS AN LMODES, HFREQ, OR LFREQ MISSING        
C        
      IF (.NOT.(LMODE .OR. (HFREQ .AND. LFREQ))) GO TO 9810        
C        
C     IS LMODES PRESENT WITH HFREQ AND/OR LFREQ        
C        
      IF (LMODE .AND. (HFREQ .OR. LFREQ)) GO TO 9820        
C        
 3000 IF (APP .NE. 4) GO TO 9999        
C        
C     TEST FOR CORRECT NODJE SETUP FOR AERO RF 10 AND 11        
C        
      PTOT = P1 .AND. P2 .AND. P3        
      IF (NODJE .AND. PTOT) GO TO 3500        
      IF (NODJE .AND. .NOT.PTOT) GO TO 9830        
      IF ((P1.OR.P2.OR.P3) .AND. .NOT.NODJE) GO TO 9840        
C        
C     TEST FOR Q REQUIRED BY AERO RF 11        
C        
 3500 IF (RF .EQ. 10) GO TO 9999        
      IF (QUEUE) GO TO 9999        
      GO TO 9870        
C        
C     TEST FOR CTYPE, NSEGS, OR KINDEX REQD BY DISP RF 14 AND 15.       
C        
 4000 LTEST = CTYPE .AND. NSEGS        
      IF (.NOT.LTEST) GO TO 9850        
 4100 IF (RF .EQ. 14) GO TO 9999        
C        
      IF (KINDX) GO TO 9999        
      GO TO 9860        
C        
C     SET UP ERROR MESSAGE        
C        
 9800 ASSIGN 9900 TO IERR        
      MSGNO = 340        
      GO TO  9890        
 9810 ASSIGN 9910 TO IERR        
      MSGNO = 341        
      GO TO  9890        
 9820 ASSIGN 9920 TO IERR        
      MSGNO = 342        
      GO TO  9895        
 9830 ASSIGN 9930 TO IERR        
      MSGNO = 343        
      GO TO  9890        
 9840 ASSIGN 9940 TO IERR        
      MSGNO = 344        
      GO TO  9895        
 9850 ASSIGN 9950 TO IERR        
      MSGNO = 345        
      GO TO  9890        
 9860 ASSIGN 9960 TO IERR        
      MSGNO = 346        
      GO TO  9890        
 9870 ASSIGN 9970 TO IERR        
      MSGNO = 347        
C        
 9890 CALL PAGE2 (3)        
      WRITE  (NOUT,9891) UFM,MSGNO        
 9891 FORMAT (A23,I4)        
      ABORT = .TRUE.        
      GO TO 9898        
 9895 CALL PAGE2 (3)        
      WRITE  (NOUT,9896) UWM,MSGNO        
 9896 FORMAT (A25,I4)        
 9898 GO TO IERR, (9900,9910,9920,9930,9940,9950,9960,9970)        
C        
 9900 WRITE  (NOUT,9905) APPR(APP),RF        
 9905 FORMAT (' PARAM CARDS REQUIRED BY ',A4,' RIGID FORMAT',I3,        
     1        ' NOT FOUND IN BULK DATA.')        
      GO TO 9999        
C        
 9910 WRITE  (NOUT,9915) APPR(APP),RF        
 9915 FORMAT (' LMODES OR HFREQ/LFREQ PARAM REQUIRED BY ',A4,        
     1        ' RIGID FORMAT',I3,' NOT IN BULK DATA OR TURNED OFF.')    
      GO TO 3000        
C        
 9920 WRITE  (NOUT,9925)        
 9925 FORMAT (' LMODES PARAM FOUND IN BULK DATA WITH HFREQ OR LFREQ.',  
     X        '  LMODES TAKES PRECEDENCE.')        
      GO TO 3000        
C        
 9930 WRITE  (NOUT,9935) RF        
 9935 FORMAT (' NODJE PARAM SPECIFIED FOR AERO RIGID FORMAT',I3,        
     1        ' BUT P1, P2, OR P3 OMITTED.')        
      GO TO 3500        
C        
 9940 WRITE  (NOUT,9945)        
 9945 FORMAT (' P1, P2, OR P3 PARAM FOUND IN BULK DATA BUT NODJE ',     
     1        'MISSING OR TURNED OFF.')        
      GO TO 3500        
C        
 9950 WRITE  (NOUT,9955) RF        
 9955 FORMAT (' CTYPE OR NSEGS PARAM REQUIRED BY DISPLACEMENT RIGID ',  
     1        'FORMAT',I3,' MISSING OR INCORRECT.')        
      GO TO 4100        
C        
 9960 WRITE  (NOUT,9965)        
 9965 FORMAT (' KINDEX PARAM REQUIRED BY DISPLACEMENT RIGID FORMAT 15', 
     1        ' MISSING OR TURNED OFF.')        
      GO TO 9999        
C        
 9970 WRITE  (NOUT,9975)        
 9975 FORMAT (' DYNAMIC PRESSURE (Q) PARAM REQUIRED BY AERO RIGID FORM',
     1        'AT 11 NOT IN BULK DATA.')        
C        
 9999 RETURN        
      END        
