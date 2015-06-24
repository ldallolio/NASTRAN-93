      SUBROUTINE OPTPR2        
C        
C     THIS ROUTINE IS THE DRIVER FOR PROPERTY OPTIMIZATION, PHASE 2.    
C        
C     CALLING SEQUENCE        
C        
C     OPTPR2  OPTP1,OES1,EST1 / OPTP2,EST2 / V,N,PRINT / V,N,TSTART /   
C                                            V,N,COUNT / V,N,CARDNO $   
C     WHERE   PRINT  = INPUT/OUTPUT - INTEGER, CALL OFP IF 1, SKIP OFP  
C                      IF -1        
C             TSTART = INPUT - INTEGER, END TIME AT OPTPR1.        
C             COUNT  = INPUT/OUTPUT - INTEGER, ITERATION LOOP COUNTER.  
C             CARDNO = INPUT/OUTPUT - INTEGER, PUNCHED CARD COUNT       
C        
C     LOGICAL         DEBUG        
      INTEGER         PRINT,COUNT,YCOR,PARM(8),B1,NAME(2),CREW,FILE,    
     1                SYSBUF,OUTTAP,IY(1),NONE(2),OPTP1,OES1,EST1,OPTP2,
     2                PTRRY,EST2,B2,PTPTY,PTELY,PTPRY,PTPLY,TG,TL,      
     3                TSTART,ZCOR        
      REAL            Y(1)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /BLANK / PRINT,TSTART,COUNT,NCARD,SKP,YCOR,B1,NELOP,NWDSE, 
     1                NWDSP,OPTP1,OES1,EST1,OPTP2,EST2,        
     2                NELW,NPRW,NKLW,NTOTL,CONV        
      COMMON /OPTPW2/ ZCOR,Z(200)        
CZZ   COMMON /ZZOPT2/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /NAMES / NRD,NRREW,NWRT,NWREW,CREW        
      COMMON /SYSTEM/ SYSBUF,OUTTAP        
      COMMON /GPTA1 / NTYPES,LAST,INCR,NE(1)        
      EQUIVALENCE     (Y(1),IY(1),PARM(8)), (CORE(1),MAX,PARM(1)),      
     1                (PARM(4),IPRN ), (PARM(7),IPRNT)        
      DATA    NAME  / 4H OPT,4HPR2  /,   NONE / 4H (NO,4HNE)   /        
      DATA    PTPTY , PTELY,PTPRY,PTPLY,PTRRY / 5*0 /        
C     DATA    DEBUG / .FALSE /        
C        
      OPTP1 = 101        
      OES1  = 102        
      EST1  = 103        
      OPTP2 = 201        
      EST2  = 202        
      ZCOR  = 200        
      NWDSE = 5        
      NWDSP = 6        
C        
C     LOAD /GPTA1/ ON 1108        
C        
      CALL DELSET        
C        
C     STEP 1.  INITIALIZE AND READ POPT DATA        
C        
      B1  = KORSZ(CORE(1)) - SYSBUF + 1        
      B2  = B1 - SYSBUF        
      YCOR= B2 -1        
      IF (B2 .LE. 6) GO TO 10        
      COUNT = COUNT + 1        
      CONV  = 0.0        
      FILE  = OPTP1        
      CALL OPEN  (*105,FILE,PARM(B1),NRREW)        
      CALL FREAD (OPTP1,PARM(1),2,0)        
      CALL FREAD (OPTP1,PARM(1),6,1)        
C        
C     PARM NOW CONTAINS        
C        
C       1 = MAX  - MAX NUMBER OF ITERATIONS (I)        
C       2 = EPS  - CONVERGENCE TEST (R)        
C       3 = GAMA - ITERATION FACTOR (R)        
C       4 = IPRN - PRINT CONTROL (I)        
C     5,6 = KPUN - PUNCH CONTROL (BCD, YES OR NO)        
C        
C     NEW PROPERTIES ARE CALCULATED BY,        
C     PNEW = (PLST*ALPH) / (ALPH + (1-ALPH)GAMA)        
C        
C     STEP 2. CHECK TIME TO GO        
C        
      IF (COUNT .GT. MAX) GO TO 105        
      CALL TMTOGO (TG)        
      IF (TG .GT. 0) GO TO 5        
      CALL MESAGE (45,COUNT,NAME)        
      COUNT = 0        
      GO TO 110        
    5 CALL KLOCK (TL)        
      TL = (TL-TSTART)/COUNT        
      IF (TG .LE. TL) COUNT = MAX        
      IPRNT = 0        
C        
C     STEP 3. READ OPTP1 INTO CORE        
C        
C     RECORD 1 - POINTERS        
C        
      YCOR = YCOR - 7        
      IF (YCOR .LT. NTYPES) GO TO 10        
C        
C     POINTERS TO OPTIMIZING POINTERS        
C        
      CALL FREAD (OPTP1,Y(1),NTYPES,0)        
C        
C     NUMBER OF ELEMENT TYPES THAT MAY BE OPTIMIZED        
C        
      CALL FREAD (OPTP1,NELOP,1,0)        
C        
C     ELEMENT AND PROPERTY POINTERS OF (2,NELOP+1) LENGTH        
C        
      YCOR = YCOR - NTYPES        
      I    = 2*(NELOP+1)        
      PTPTY= NTYPES + 1        
      IF (YCOR .LT. I) GO TO 10        
      CALL FREAD (OPTP1,Y(PTPTY),I,1)        
C        
C     RECORD 2 - ELEMENT DATA        
C        
      YCOR  = YCOR  - I        
      PTELY = PTPTY + I        
      IF (YCOR .LT. NWDSE+NWDSP) GO TO 10        
      CALL READ (*10,*30,OPTP1,Y(PTELY),YCOR,1,NELW)        
C        
C     INSUFFICIENT CORE - PRINT START OF EACH SECTION        
C        
C        
   10 CALL PAGE2 (-3)        
      I = NTYPES + 1        
      WRITE  (OUTTAP,20) UFM,NAME,B1,I,PTPTY,PTELY,PTPRY        
   20 FORMAT (A23,' 2289, ',2A4,'INSUFFICIENT CORE (',I10,2H ), /9X,I9, 
     1       ' = MATERIAL',I9,' = POINTERS',I9,' = ELEMENTS',I9,        
     2       ' = PROPERTIES')        
      CALL CLOSE (FILE,CREW)        
      GO TO 100        
C        
C     RECORD 3 - PROPERTY DATA        
C        
   30 IF (NELW .LT. NWDSE) GO TO 50        
      PTPRY = PTELY + NELW        
      YCOR  = YCOR  - NELW        
      IF (YCOR .LT. NWDSP) GO TO 10        
      CALL READ (*10,*40,OPTP1,Y(PTPRY),YCOR,1,NPRW)        
      GO TO 10        
C        
C     RECORD 4 - PLIMIT DATA        
C        
   40 IF (NPRW .LT. NWDSP) GO TO 50        
      PTPLY = PTPRY + NPRW        
      YCOR  = YCOR  - NPRW        
      IF (YCOR .LT. 0) GO TO 10        
      CALL READ (*10,*70,OPTP1,Y(PTPLY),YCOR,1,NKLW)        
      GO TO 10        
C        
C     INSUFFICIENT DATA        
C        
   50 CALL CLOSE (FILE,CREW)        
      CALL PAGE2 (-2)        
      WRITE  (OUTTAP,60) UFM,NAME        
   60 FORMAT (A23,' 2302, SUBROUTINE ',2A4,' HAS NO PROPERTY OR ',      
     1        'ELEMENT DATA.')        
      GO TO 100        
C        
C     CLOSE OPTP1 FILE.        
C     ALLOCATE AN ARRAY WITH STARTING POINTER PTRRY, OF LENGTH EQUALS TO
C     THE NO. OF PROPERTY CARDS (TO BE USED IN OPT2A, 2B, AND 2C)       
C     SET VARIABLE NTOTL TO THE TOTAL LENGTH OF WORDS USED IN OPEN CORE 
C     RE-ESTABLISH OPEN CORE UPPER LIMIT, YCOR        
C        
   70 CALL CLOSE (FILE,CREW)        
      PTRRY = PTPLY + NKLW        
      NTOTL = PTRRY + NPRW/NWDSP + 1        
      IY(NTOTL-1) = -1234567        
      IF (NTOTL .GT. YCOR) GO TO 10        
      YCOR = B2 - 1        
      DO 80 J = NTOTL,YCOR        
   80 IY(J) = 0        
C        
C     READ STRESS DATA, SET ALPH        
C        
      FILE = OES1        
      CALL GOPEN (FILE,PARM(B1),NRREW)        
      CALL OPT2A (IY(PTPTY),Y(PTELY),IY(PTELY),Y(PTPRY),IY(PTPRY),      
     1            Y(PTRRY))        
      IF (IY(NTOTL-1) .NE. -1234567) GO TO 120        
      CALL CLOSE (FILE,CREW)        
C     IF (DEBUG) CALL BUG (4HPROP,70,Y(PTPRY),NPRW)        
      IF (COUNT .GT. MAX) GO TO 105        
C        
C     SET NEW PROPERTY, CHECK FOR CONVERGENCE        
C        
      CALL OPT2B (IY(PTPRY),Y(PTPRY),Y(PTPLY),Y(PTRRY))        
C     IF (DEBUG) CALL BUG (4HPROP,71,Y(PTPRY),NPRW)        
C        
C     CREATE EST2, PUNCH PROPERTIES IF CONVERGED        
C        
      PRINT = -1        
      IF (COUNT.GE.MAX .OR. COUNT.LE.1 .OR. CONV.EQ. 2.) PRINT = 1      
      IF (IPRN .LT.0  .AND. MOD(COUNT,IABS(IPRN)).EQ. 0) PRINT = 1      
      IF (COUNT.GT.MAX .OR. COUNT.LT.0) GO TO 90        
      IF (COUNT.EQ.1 .OR. COUNT.GE.MAX .OR. MOD(COUNT,IABS(IPRN)).EQ.0  
     1   .OR. CONV.EQ.2.) IPRNT = 1        
      FILE = EST1        
      CALL OPEN  (*95,FILE,PARM(B1),NRREW)        
      CALL FREAD (FILE,NONE(1),2,1)        
      FILE = EST2        
      CALL GOPEN (FILE,PARM(B2),NWREW)        
      CALL OPT2C (Y(PTPTY),IY(PTELY),IY(PTPRY),Y(PTPRY),Y(PTRRY))       
C     IF (DEBUG) CALL BUG (4HFPRO,90,Y(PTPRY),NPRW)        
      CALL CLOSE (FILE,CREW)        
      CALL CLOSE (EST1,CREW)        
C        
C     COPY OPTPR1 TO OPTPR2 - CHANGE RECORD 3        
C        
   90 IF (COUNT .GT. MAX) GO TO 105        
      CALL OPEN (*95,OPTP1,PARM(B1),NRREW)        
      FILE = OPTP2        
      CALL OPEN  (*95,FILE,PARM(B2),NWREW)        
      CALL OPT2D (IY(PTPRY),Y(PTPRY))        
      CALL CLOSE (FILE,CREW)        
      CALL CLOSE (OPTP1,CREW)        
      GO TO 110        
C        
C     FILE NOT PRESENT        
C        
   95 CALL MESAGE (-1 ,FILE,NAME)        
  100 CALL MESAGE (-61,B2,NAME)        
  105 COUNT = -1        
      CALL CLOSE (OPTP1,1)        
  110 IF (CONV .EQ. 2.0) COUNT = MAX        
      IF (COUNT .LE.  0) PRINT = 1        
      IF (COUNT .EQ.  0) COUNT =-1        
      RETURN        
C        
  120 WRITE  (OUTTAP,125) NTOTL,PTRRY        
  125 FORMAT (32H0*** RR DIMENSION ERROR/OPTPR2  ,2I7)        
      GO TO 100        
      END        
