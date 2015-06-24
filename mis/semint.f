      SUBROUTINE SEMINT (DEBUG1)        
C        
C     SEMINT IS THE EXECUTION MONITOR FOR THE PREFACE.        
C     UMF IS NO LONGER SUPPORTED.        
C        
C     FOR DEBUG PURPOSE, PRINT OUT GOES TO UNIT 6, NOT OUTTAP        
C        
      INTEGER         AXIC,AXIF,OUTTAP,PLOTF,HICORE,DEBUG1        
      CHARACTER       UFM*23,UWM*25,UIM*29,SUBR(13)*6        
      COMMON /XMSSG / UFM,UWM,UIM        
      COMMON /IFPX1 / NCDS,T1(2,370)        
      COMMON /MACHIN/ MACH,DUMMY4(4)        
      COMMON /SYSTEM/ SYSTEM,OUTTAP,NOGO,INTAP,DUMM15(15),PLOTF,        
     1                DUMM6(6),AXIC,DUMMY3(3),HICORE,DUMMY6(6),        
     2                AXIF,DUMM30(30),ISUBS,ISY70(7),ISY77        
      COMMON /XECHOX/ ECHO(4)        
      COMMON /XXREAD/ INFLAG,INSAVE        
      DATA     BCD1 , BCD2,  BCD3,  BCD4  ,BCD5  ,BCD6,  BCD7   /       
     1         4HXCSA,4HIFP1,4HXSOR,4HXGPI,4HGNFI,4HTTIO,4HTTLP /       
      DATA     BCD8 , BCD9,  BCD10 ,BCD11                       /       
     1         4HTTOT,4HSOLI,4HFLUI,1HD                         /       
      DATA     SUBR / 'NASCAR','GNFIAT','TMTSIO','TMTSLP','XCSA  ',     
     1                'TMTSOT','ASDMAP','IFP1  ','XSORT2','IFP   ',     
     2                'IFP3  ','XGPI  ','BANDIT'/        
C        
C        
      INSAVE = INTAP        
C        
C     READ AND PROCESS THE NASTRAN CARD (IF PRESENT).        
C        
      IF (DEBUG1 .GT. 0) WRITE (6,10) SUBR(1)        
   10 FORMAT (/,' -LINK1 DEBUG- SEMINT CALLING ',A6,' NEXT',/)        
      CALL NASCAR        
C        
C     DEFINE OPEN CORE FOR UNIVAC, VAX, AND UNIX        
C        
      IF (MACH.EQ.3 .OR. MACH.GE.5) CALL DEFCOR        
C        
C     GENERATE INITIAL FILE TABLES.        
C     COMPUTE NASTRAN TIMING CONSTANTS.        
C     READ EXECUTIVE CONTROL DECK AND SAVE NOGO FLAG.        
C     READ CASE CONTROL DECK, SORT BULK DATA AND EXECUTE        
C     INPUT FILE PROCESSOR UNLESS BULK DATA IS MISSING.        
C     IF CONICAL SHELL PROBLEM, EXECUTE IFP3.        
C        
      CALL CONMSG (BCD5,1,1)        
      IF (DEBUG1 .GT. 0) WRITE (6,10) SUBR(2)        
      CALL GNFIAT        
C        
C     CALL THE TIME TEST ROUTINES TO COMPUTE THE NASTRAN        
C     TIMING CONSTANTS AND INITIALIZE COMMON /NTIME/        
C        
C     GENERATE THE I/O TIMES AND        
C     CPU TIMES FOR VARIOUS TYPES OF LOOPS        
C        
      CALL CONMSG (BCD6,1,0)        
      IF (DEBUG1 .GT. 0) WRITE (6,10) SUBR(3)        
      CALL TMTSIO (*2000,DEBUG1)        
      CALL CONMSG (BCD7,1,0)        
      IF (DEBUG1 .GT. 0) WRITE (6,10) SUBR(4)        
      CALL TMTSLP        
C        
C     PROCESS EXECUTIVE CONTROL CARDS        
C        
 2000 CALL CONMSG (BCD1,1,1)        
      IF (DEBUG1 .GT. 0) WRITE (6,10) SUBR(5)        
      CALL XCSA        
C        
C     OUTPUT THE COMMON /NTIME/ ENTRIES IF DIAG 35 IS TURNED ON        
C        
      CALL SSWTCH (35,L35)        
      IF (L35 .EQ. 0) GO TO 3000        
      CALL CONMSG (BCD8,1,0)        
      IF (DEBUG1 .GT. 0) WRITE (6,10) SUBR(6)        
      CALL TMTSOT        
C        
C     PROCESS SUBSTRUCTURING DMAP        
C        
 3000 NOGOX = NOGO        
      NOGO  = 0        
      IF (DEBUG1.GT.0 .AND. ISUBS.NE.0) WRITE (6,10) SUBR(7)        
      IF (ISUBS .NE. 0) CALL ASDMAP        
C        
C     PROCESS CASE CONTROL CARDS        
C        
      CALL CONMSG (BCD2,1,1)        
      IF (DEBUG1 .GT. 0) WRITE (6,10) SUBR(8)        
      CALL IFP1        
      NOGO1 = NOGO        
      IF (NOGO .EQ. -9) NOGO = 1        
      IF (NOGO .LT.  0) NOGO = 0        
      KAXIF = 0        
C        
C     REVERT TO OLD XSORT TO PROCESS BULKDATA CARDS IF DIAG 42 IS       
C     TURNED ON,  OTHERWISE, USE XSORT2 FOR SPEED AND EFFICIENCY        
C        
      CALL CONMSG (BCD3,1,0)        
      CALL SSWTCH (42,L42)        
      IF (DEBUG1 .GT. 0) WRITE (6,10) SUBR(9)        
      IF (L42  .EQ.  1) CALL XSORT        
      IF (L42  .EQ.  0) CALL XSORT2        
      IF (NOGO .EQ. -2) GO TO 4000        
C        
C     INPUT FILE PROCESSOR(S) TO CHECK EACH BULKDATA CARD        
C        
      IF (DEBUG1 .GT. 0) WRITE (6,10) SUBR(10)        
      CALL IFP        
      IF (DEBUG1.GT.0 .AND. AXIC.NE.0) WRITE (6,10) SUBR(11)        
      IF (AXIC .NE. 0) CALL IFP3        
C        
C     SET KAXIF AS IFP4 WILL MODIFY AXIF        
C        
      KAXIF = AXIF        
      IF (KAXIF.EQ.1 .OR. KAXIF.EQ.3) CALL IFP4        
      IF (KAXIF.EQ.2 .OR. KAXIF.EQ.3) CALL IFP5        
C        
C     SUPPRESS NOGO FLAG IF USER REQUESTS UNDEFORMED STRUCTURE PLOT VIA 
C     NASTRAN PLOTOPT CARD        
C        
 4000 IF (NOGO .EQ. -2) NOGO = 0        
      IF (NOGO.EQ.0 .AND. NOGO1.LT.0) NOGO = NOGO1        
      IF (NOGO.GE.1 .AND. NOGO1.LT.0) NOGO = -9        
      IF (NOGO1 .EQ. 0) NOGO1 = NOGO        
C        
C     NOGO FLAG CONDITIONS        
C     NOGOX.NE. 0, FATAL ERROR IN EXECUTIVE CONTROL        
C     NOGO .EQ.-9, FATAL ERROR IN BULKDATA AND IN PLOT COMMANDS        
C     NOGO .EQ. 0, NO FATAL ERROR DETECTED IN ENTIRE INPOUT DECK        
C     NOGO .GT. 0, FATAL ERROR IN BULKDATA, NO ERROR IN PLOT COMMANDS   
C     NOGO .LT. 0, NO ERROR IN BULKDATA, FATAL ERROR IN PLOT COMMANDS   
C        
      IF (NOGOX .NE. 0) GO TO 5500        
      IF (NOGO) 4100,4300,4200        
 4100 IF (NOGO.EQ.-9 .AND. PLOTF.NE.3) GO TO 5500        
      IF (PLOTF .LE. 1) GO TO 4200        
      NOGO = 0        
      GO TO 4300        
 4200 NOGO = 1        
C        
C     EXECUTE GENERAL PROBLEM INITIALIZATION IF DATA PERMITS.        
C        
 4300 IF (NOGO .NE. 0) CALL MESAGE (-61,0,0)        
      CALL CONMSG (BCD4,1,0)        
      IF (DEBUG1 .GT. 0) WRITE (6,10) SUBR(12)        
      CALL XGPI        
C        
C     CALL BANDIT TO GENERATE GRID-POINT RE-SEQUENCE CARDS IF DATA      
C     PERMITS        
C        
      IF (NOGO.NE.0 .AND. NOGO1.LT.0) NOGO = -9        
      IF (NOGO.EQ.0 .AND. NOGO1.NE.0) NOGO = NOGO1        
      IF (ISY77.LT.0 .OR. NOGO .NE.0) GO TO 5100        
      IF (AXIC.NE.0  .OR. KAXIF.EQ.1 .OR. KAXIF.EQ.3) GO TO 5000        
      IF (DEBUG1 .GT.  0) WRITE (6,10) SUBR(13)        
      CALL BANDIT        
      GO TO 5100        
 5000 WRITE (OUTTAP,6100) UIM        
      BCDX = BCD10        
      IF (AXIC .NE. 0) BCDX = BCD9        
      WRITE (OUTTAP,6200) BCDX,BCD11        
      WRITE (OUTTAP,6300)        
C        
C     TERMINATE NASTRAN IF LINK 1 ONLY IS REQUESTED BY USER        
C        
 5100 IF (ISY77 .EQ. -2) CALL PEXIT        
C        
C     EXIT ACCORDING TO PLOT OPTION REQUEST        
C     SET PLOTF TO NEGATIVE ONLY IF JOB IS TO BE TERMINATED AFTER PLOTS 
C     IN LINK2        
C        
      J = PLOTF + 1        
      IF (NOGO .EQ. 0) GO TO (5800,5800,5700,5700,5800,5800), J        
      IF (NOGO .GT. 0) GO TO (5300,5300,5600,5600,5600,5600), J        
      IF (NOGO .LT. 0) GO TO (5500,5500,5500,5600,5600,5200), J        
C                      PLOTF =   0,   1,   2,   3,   4,   5        
C        
 5200 IF (NOGO+9) 5800,5500,5800        
 5300 IF (PLOTF .GT. 1) WRITE (OUTTAP,5400)        
 5400 FORMAT ('0*** ATTEMPT TO PLOT UNDEFORMED MODEL IS ABANDONED DUE', 
     1        ' TO FATAL ERROR IN BULK DATA')        
 5500 CALL MESAGE (-61,0,0)        
 5600 WRITE  (OUTTAP,5650) UWM        
 5650 FORMAT (A25,' - FATAL ERRORS ENCOUNTERED IN USER INPUT DECK,',    
     1       /5X,'HOWEVER, NASTRAN WILL ATTEMPT TO PLOT THE UNDEFORMED',
     2       ' STRUCTURE AS REQUESTED BY USER')        
 5700 PLOTF = -PLOTF        
 5800 RETURN        
C        
 6100 FORMAT (A29,' - GRID-POINT RESEQUENCING PROCESSOR BANDIT IS NOT', 
     1       ' USED DUE TO')        
 6200 FORMAT (5X,'THE PRESENCE OF AXISYMMETRIC ',A4,A1,' DATA')        
 6300 FORMAT (1H0,10X,'**NO ERRORS FOUND - EXECUTE NASTRAN PROGRAM**')  
C        
      END        
