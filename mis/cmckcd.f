      SUBROUTINE CMCKCD        
C        
C     THIS SUBROUTINE DETERMINES WHETHER MANUALLY SPECIFIED CONNECTION  
C     ENTRIES ARE ALLOWABLE BASED ON THE PRESCRIBED GEOMETRIC TOLERANCE.
C        
      INTEGER         SCSFIL,COMBO,SCORE,IST(7),SCCONN,CE(9),AAA(2),    
     1                BUF2,OUTT        
      DIMENSION       IPNUM(7),COORD(7,3),DIFF2(3)        
      CHARACTER       UFM*23,UWM*25,UIM*29        
      COMMON /XMSSG / UFM,UWM,UIM        
      COMMON /CMB001/ SCR1,SCR2,SCBDAT,SCSFIL,SCCONN,SCMCON,SCTOC,      
     1                GEOM4,CASECC,SCCSTM,SCR3        
      COMMON /CMB002/ BUF1,BUF2,BUF3,BUF4,BUF5,SCORE,LCORE,INTP,OUTT    
      COMMON /CMB003/ COMBO(7,5),CONSET,IAUTO,TOLER,NPSUB,CONECT,TRAN,  
     1                MCON,RESTCT(7,7),ISORT,ORIGIN(7,3),IPRINT        
CZZ   COMMON /ZZCOMB/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /BLANK / STEP,IDRY        
      DATA    AAA   / 4HCMCK,4HCD   /        
C        
C     READ ALL BGSS INTO OPEN CORE        
C        
      IT    = 2        
      IERR  = 0        
      LLCO  = LCORE        
      J     = 0        
      IFILE = SCSFIL        
      CALL OPEN (*200,SCSFIL,Z(BUF2),0)        
      DO 30 I = 1,NPSUB        
      NREC  = COMBO(I,5) + 1        
      DO 10 JJ = 1,NREC        
      CALL FWDREC (*210,SCSFIL)        
   10 CONTINUE        
      CALL READ (*210,*20,SCSFIL,Z(SCORE+J),LLCO,1,NNN)        
      GO TO 220        
   20 IST(I) = SCORE + J        
      J = J + NNN        
      LLCO  = LLCO - NNN        
      CALL SKPFIL (SCSFIL,1)        
   30 CONTINUE        
      CALL CLOSE (SCSFIL,1)        
C        
C     READ CONNECTION ENTRIES AND LOAD INTO COORD ARRAY        
C        
      IFILE = SCCONN        
      CALL OPEN (*200,SCCONN,Z(BUF2),0)        
   40 CALL READ (*180,*50,SCCONN,CE,10,1,NNN)        
C        
C     LOAD COORD ARRAY        
C     CE(3)... UP TO CE(9) ARE INTERNAL POINT NO.        
C     IZ(IADD) IS THE COORD (CSTM) ID OF THE INTERNAL PTS.        
C     Z(IADD+1,+2,+3) ARE THE COORD. ORIGINS        
C        
   50 NPT  = 0        
      DO 80 I = 1,NPSUB        
      IF (CE(I+2)) 80,80,60        
   60 NPT  = NPT + 1        
      IADD = 4*(CE(I+2)-1) + IST(I)        
      IPNUM(NPT) = CE(I+2)        
      DO 70 J = 1,3        
      COORD(NPT,J) = Z(IADD+J)        
   70 CONTINUE        
   80 CONTINUE        
C        
C     COMPARE ALL PAIRS OF COORDINATES AGAINST TOLER.        
C        
      NPTM1 = NPT - 1        
      DO 170 I = 1,NPTM1        
      IT = IT - 1        
      JJ = I  + 1        
      DO 160 J = JJ,NPT        
      DO 90 KK = 1,3        
      DIFF2(KK) = (COORD(J,KK)-COORD(I,KK))**2        
   90 CONTINUE        
      SUM  = 0.0        
      DO 100 KK = 1,3        
      SUM  = SUM + DIFF2(KK)        
  100 CONTINUE        
      DIST = SQRT(SUM)        
      IF (DIST .LE. TOLER) GO TO 160        
      IF (IT .GT. 1) GO TO 120        
      WRITE  (OUTT,110) UFM        
  110 FORMAT (A23,' 6514, ERRORS HAVE BEEN FOUND IN MANUALLY SPECIFIED',
     1       ' CONNECTION ENTRIES. SUMMARY FOLLOWS')        
      IERR = 1        
      IDRY =-2        
      IT   = 2        
  120 IF (IT .GT. 2) GO TO 140        
      WRITE  (OUTT,130) (CE(KDH),KDH=1,NNN)        
  130 FORMAT ('0*** GEOMETRIC ERRORS HAVE BEEN FOUND IN THE FOLLOWING', 
     1        ' CONNECTION ENTRY', /5X,9I10)        
      IT   = 3        
  140 WRITE (OUTT,150) IPNUM(I),(COORD(I,MM),MM=1,3),        
     1                 IPNUM(J),(COORD(J,MM),MM=1,3)        
  150 FORMAT ('0*** IP NUMBER',I10,13H COORDINATES  ,3E16.6,4H AND, /,  
     1        '     IP NUMBER',I10,13H COORDINATES  ,3E16.6,        
     2        ' ARE NOT WITHIN TOLER UNITS.')        
  160 CONTINUE        
  170 CONTINUE        
      GO TO 40        
C        
  180 IF (IERR .EQ. 0) WRITE (OUTT,190) UIM        
  190 FORMAT (A29,' 6516, ALL MANUAL CONNECTIONS SPECIFIED ARE ',       
     1       'ALLOWABLE WITH RESPECT TO TOLERANCE')        
      CALL CLOSE (SCCONN,1)        
      GO TO 250        
C        
  200 IMSG = -1        
      GO TO 230        
  210 IMSG = -2        
      GO TO 230        
  220 IMSG = -8        
  230 CALL MESAGE (IMSG,IFILE,AAA)        
C        
  250 RETURN        
      END        
