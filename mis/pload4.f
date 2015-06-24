      SUBROUTINE PLOAD4 (IBUF5,IDO,JOPEN)        
C        
C     TO GENERATE PLOAD4 PRESSURE LOAD FOR QUAD4 AND TRIA3 ELEMENTS.    
C        
C     BOTH ELEMENT TYPES MAY BE PRESENT, OR ONLY ONE OF THE TWO IS      
C     PRESENT.        
C        
C     THIS ROUTINE IS CALLED ONLY BY EXTERN IN SSG1 MODULE, LINK5       
C        
C     THIS ROUTINE  CALLS PLOD4D OR PLOD4S TO COMPUTE LOAD FOR QUAD4    
C     ELEMENTS, AND CALLS T3PL4D OR T3PL4S TO COMPUTE LOAD FOR TRIA3    
C        
C     IN OVERLAY TREE, THIS ROUTINE SHOULD BE IN PARALLELED WITH FPONT  
C     ROUTINE, AND FOLLOWED BY PLOD4D/S AND T3PL4D/S. I.E.        
C        
C                   ( FPONT        
C            EXTERN (        ( PLOD4D  (/ZZSSA1/        
C                   ( PLOAD4 ( PLOD4S        
C                            ( T3PL4D        
C                            ( T3PL4S        
C        
      LOGICAL         ALLIN,DEBUG        
      INTEGER         IZ(1),NAME(2),FILE,SLT,EST,QUAD4,TRIA3,T3,Q4      
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
CZZ   COMMON /ZZSSA1/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /LOADX / LCARE,SLT,IDUM(5),EST        
      COMMON /SYSTEM/ IBUF,NOUT,JDUM(52),IPREC        
      COMMON /PINDEX/ IEST(45),ISLT(11)        
      COMMON /GPTA1 / NELEM,LAST,INCR,IELEM(1)        
      EQUIVALENCE     (CORE(1),IZ(1))        
      DATA    QUAD4 , TRIA3 , NAME          /        
     1        64    , 83    , 4HPLOA,4HD4   /        
      DATA    DEBUG / .FALSE. /        
C        
C        
C     T3 AND Q4 KEEP TRACK OF THE PRESENCE OF THE CTRIA3 AND CQUAD4     
C     ELEMENTS        
C        
      T3    = 0        
      Q4    = 0        
      LCORE = IBUF5 - IBUF        
      IDO11 = IDO*11        
      ALLIN = .FALSE.        
      IF (IDO11 .GT. LCORE) GO TO 400        
      IF (DEBUG) WRITE (NOUT,300)        
  300 FORMAT (/,' * PLOAD4 IS CALLED FOR ONE LOAD CASE')        
C        
C     OPEN CORE IS BIG ENOUGH TO HOLD ALL PLOAD4 DATA.        
C     READ THEM ALL INTO CORE        
C     (BAD NEWS - OPEN CORE AT THIS TIME IS NOT AVAILABLE)        
C        
      IF (.NOT.ALLIN) GO TO 400        
C        
      ALLIN = .TRUE.        
      FILE  = SLT        
      IMHERE= 350        
      CALL READ (*620,*630,SLT,CORE,IDO11,0,FLAG)        
C        
C     OPEN CORE NOT LARGE ENOUGH TO HOLD ALL PLOAD4 DATA        
C        
  400 IF (JOPEN .EQ. 1) GO TO 415        
      JOPEN = 1        
      FILE  = EST        
      CALL OPEN  (*610,EST,CORE(IBUF5),0)        
      CALL FWDREC (*620,EST)        
      FILE = EST        
  410 CALL READ (*430,*560,EST,IELTYP,1,0,FLAG)        
  415 IF (IELTYP .EQ. QUAD4) GO TO 440        
      IF (IELTYP .EQ. TRIA3) GO TO 445        
  420 CALL FWDREC (*430,EST)        
      GO TO 410        
  430 IF (T3+Q4 .NE. 0) GO TO 560        
      WRITE  (NOUT,435) UFM        
  435 FORMAT (A23,', PLOAD4 PRESSURE LOAD IS USED WITHOUT THE PRESENCE',
     1       ' OF QUAD4 OR TRIA3 ELEMENT')        
      IMHERE = 435        
      GO TO 620        
C        
  440 IF (Q4 .GE. 1) GO TO 420        
      Q4 = 1        
      IF (DEBUG) WRITE (NOUT,441) T3        
  441 FORMAT (/,'   QUAD4 ELEM FOUND. SETTING Q4 TO 1.  T3 =',I3)       
      GO TO 450        
  445 IF (T3 .EQ. 1) GO TO 420        
      T3 = 1        
      IF (DEBUG) WRITE (NOUT,446) Q4        
  446 FORMAT (/,'   TRIA3 ELEM FOUND. SETTING T3 TO 1.  Q4 =',I3)       
  450 J  = INCR*(IELTYP-1)        
      NWORDS = IELEM(J+12)        
      IEST(1)= 0        
C        
      FILE = SLT        
      IB   = 0        
      IMHERE = 550        
      DO 550 J = 1,IDO        
      IF (ALLIN) GO TO 460        
      JSAVE = J        
      IF (J.EQ.1 .AND. T3+Q4.GE.2) GO TO 470        
      CALL READ (*620,*630,SLT,ISLT,11,0,FLAG)        
      GO TO 470        
  460 DO 465 I = 1,11        
  465 ISLT(I) = IZ(I+IB)        
      IB = IB + 11        
  470 IF (ISLT(1)-IEST(1)) 550,490,480        
  480 CALL READ (*560,*560,EST,IEST,NWORDS,0,FLAG)        
      GO TO 470        
C        
  490 IF (IELTYP .EQ. TRIA3) GO TO 520        
C        
C     PLOAD4 FOR QUAD4 ELEMENT        
C        
      IF (DEBUG) WRITE (NOUT,500) IEST(1)        
  500 FORMAT (' ==> PROCESS PLOAD4 FOR QUAD ELEM',I8)        
      GO TO (505,510), IPREC        
  505 CALL PLOD4S        
      GO TO 550        
  510 CALL PLOD4D        
      GO TO 550        
C        
C     PLOAD4 FOR TRIA3 ELEMENT        
C     SET ISLT(1) TO NEGATIVE FOR PLOAD4/TRIA3 COMPUTATION        
C        
  520 IF (DEBUG) WRITE (NOUT,525) IEST(1)        
  525 FORMAT (' ==> PROCESS PLOAD4 FOR TRIA3 ELEM',I8)        
      ISLT(1) = -IABS(ISLT(1))        
      GO TO (530,540), IPREC        
  530 CALL T3PL4S        
      GO TO 550        
  540 CALL T3PL4D        
C        
  550 CONTINUE        
C        
  560 IF (T3+Q4 .GE. 2) GO TO 580        
C        
C     JUST FINISHED EITHER QUAD4 OR TRIA3 ELEMENT. BACKSPACE EST FILE,  
C     AND BACKSPACE SLT FILE IF SLT DATA ARE NOT ALREADY IN CORE.       
C     REPEAT PLOAD4 (LOAD TYPE 25) COMPUTAION FOR THE OTHER ELEMENT     
C     (TRIA3 OR QUAD4) WHICH WE HAVE NOT YET PROCESSED IN THE FIRST     
C     PASS. MUST STEP OVER OTHER LOADS THAT MIGHT BE PRESENT        
C        
      CALL BCKREC (EST)        
      Q4    = Q4 + 1        
      JSAVE = 0        
      IF (ALLIN) GO TO 410        
C        
      CALL BCKREC (SLT)        
      IMHERE = 570        
  570 CALL READ (*620,*630,SLT,I,1,0,FLAG)        
      IF (I .NE. 25) GO TO 570        
      IMHERE = 573        
      CALL READ (*620,*630,SLT,I,1,0,FLAG)        
      IF (I .NE. IDO) GO TO 570        
      IMHERE = 575        
      CALL READ (*620,*630,SLT,ISLT,6,0,FLAG)        
      IF (ISLT(6) .NE. -1) GO TO 570        
      IMHERE = 577        
      CALL READ (*620,*630,SLT,ISLT(7),5,0,FLAG)        
      IF (ISLT(7) .NE. 0) GO TO 570        
      JSAVE = 1        
      GO TO 410        
C        
  580 IF (JOPEN .EQ. 1) CALL CLOSE (EST,1)        
      JOPEN = 0        
      IF (ALLIN .OR. JSAVE.GE.IDO) GO TO 600        
      IMHERE = 590        
      J = (IDO-JSAVE)*11        
      CALL READ (*640,*640,SLT,0,-J,0,FLAG)        
  600 RETURN        
C        
  610 J = -1        
      GO TO 650        
  620 J = -2        
      GO TO 650        
  630 J = -3        
      GO TO 650        
  640 J = 1        
  650 WRITE  (NOUT,660) IMHERE,T3,Q4,IDO,JSAVE        
  660 FORMAT ('   IMHERE =',I5,'   T3,Q4 =',2I3,'   IDO,JSAVE =',2I5)   
      CALL MESAGE (J,FILE,NAME(1))        
      GO TO 600        
      END        
