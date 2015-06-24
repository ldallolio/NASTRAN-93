      SUBROUTINE MACHCK (*)        
C        
C     NEW MACHINE COMPATIBILITY CHECK        
C     THIS ROUTINE IS CALLED ONCE ONLY BY XSEM01 IF DEBUG FLAG IS ON    
C        
C     FOR LINK1 DEBUG PURPOSE, PRINT OUT GOES TO UNIT 6, NOT NOUT       
C        
C     WRITTEN BY G.CHAN/UNISYS  5/1991        
C        
C     NEXT LINE IS NEEDED FOR HP WORKSTATION. THE $ STARTS ON COLUMN 1  
C        
C  $MIXED_FORMATS        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        LSHIFT,RSHIFT        
      INTEGER         AR(5)        
      REAL            XX        
      COMPLEX         E,D,F        
      CHARACTER       L21(5)*1,L2*8,RV*8        
      CHARACTER       UFM*23,UWM*25,UIM*29,UIMX*29        
      COMMON /XMSSG / UFM,UWM,UIM        
      COMMON /SEM   / MASK        
      COMMON /SYSTEM/ SYSBUF,NOUT,NOGO,DUMM1(11),DATE(3),DUMM2(13),     
     1                HICORE,TIMEW,DUMM3(62),SPERLK        
      COMMON /MACHIN/ MACHX,IJHALF(2),LQRO,MCHNAM        
      COMMON /LHPWX / LOWPW,HIGHPW        
CZZ   COMMON /ZZXSEM/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
CZZ   COMMON /SOFPTR/ S        
      EQUIVALENCE     (S,Z(1))        
      EQUIVALENCE     (L21(1),L2),(XX,IX)        
      DATA    I,J,K / 4HABCD, 4H1234, 4HA3CD  /,        
     1        D,E   / (1.0,-2.0), (-3.0,4.0)  /,        
     2        L1,BT / 4HWORD, 4HBYTE          /,        
     3        IA,IR / 4HA   , 4HR             /,        
     4        L2,RV / 'NATURAL ', 'REVERSED'  /,        
     5        AS,DS / 3H AS,  3HDES           /        
      DATA    UIMX  / '0*** USER INFORMATION MESSAGE' /        
C        
      NOGO = 0        
      IF (UIMX .EQ. UIM) GO TO 20        
      NOGO = 1        
      WRITE  (6,10)        
   10 FORMAT (/,' -LINK1 DEBUG- SEMDBD DATA BLOCK NOT LOADED CORRECTLY')
C        
C     CALL BTSTRP TO INITIALIZE MACHINE CONSTANTS        
C        
   20 WRITE  (6,30)        
   30 FORMAT (/,' -LINK1 DEBUG- MACHCK CALLING BTSTRP NEXT')        
      CALL BTSTRP        
C        
      WRITE  (6,40)        
   40 FORMAT ( ' -LINK1 DEBUG-  CHARACTER, SHIFT AND COMPLEX CHECKS')   
      L  = KHRFN1(I,2,J,3)        
      IF (L .EQ. K) GO TO 60        
      NOGO = 2        
      WRITE  (6,50) I,J,K,L        
   50 FORMAT (' * KHRFN1 ERROR   I,J,K,L =',4(1X,A4))        
   60 I  = 128        
      J  = LSHIFT(I,2)        
      K  = RSHIFT(I,2)        
      IF (J.EQ.512 .AND. K.EQ.32) GO TO 80        
      NOGO = 3        
      WRITE  (6,70)        
   70 FORMAT (' * LSHIFT AND/OR RSHIFT ERROR')        
C        
C     JUMP TO 100 IF MACHINE DOES NOT HAVE ISHFT FUNCTION        
C        
   80 J  = ISHFT(I,+2)        
      K  = ISHFT(I,-2)        
      IF (J.EQ.512 .AND. K.EQ.32) GO TO 110        
      NOGO = 4        
      IF (J .NE. 512) WRITE (6,90)        
      IF (K .NE.  32) WRITE (6,100)        
   90 FORMAT (' * ISHFT(+) NOT SAME AS LSHIFT')        
  100 FORMAT (' * ISHFT(-) NOT SAME AS RSHIFT')        
C        
C     CHECK ISHFT IS ZERO-FILL        
C        
  110 I  = -1        
      J  = ISHFT(I,-1)        
      K  = ISHFT(I,+1)        
      IF (J.GT.0 .AND. MOD(K,2).EQ.0) GO TO 130        
      NOGO = 5        
      WRITE  (6,120)        
  120 FORMAT (' * SYSTEM ISHFT IS NOT ZERO-FILL')        
C        
C     CHECK K2B SUBROUTINE        
C        
  130 CALL K2B (L21,AR,5)        
      IF (AR(2).EQ.IA .AND. AR(5).EQ.IR) GO TO 150        
      NOGO = 6        
      WRITE  (6,140) AR(2),AR(5)        
  140 FORMAT (' * K2B ERROR   A,R ==',2A4)        
C        
C     COMPLEX NUMBER CHECK        
C        
  150 F  = D*E        
      DR = REAL (D)        
      DI = AIMAG(D)        
      ER = REAL (E)        
      EI = AIMAG(E)        
      A  = DR*ER - DI*EI        
      B  = DR*EI + DI*ER        
      IF (ABS(A-REAL(F)).LE..01 .AND. ABS(B-AIMAG(F)).LE..01) GO TO 170 
      NOGO = 7        
      WRITE  (6,160)        
  160 FORMAT (' * COMPLEX ERROR')        
  170 IF (MASK .EQ. 65535) GO TO 190        
      NOGO = 8        
      WRITE  (6,180)        
  180 FORMAT (' * LABEL COMMON /SEM/ ERROR')        
  190 IF (SPERLK.EQ.1 .OR. SPERLK.EQ.0) GO TO 210        
      NOGO = 9        
      WRITE  (6,200)        
  200 FORMAT (' * LABEL COMMON /SYSTEM/ ERROR')        
  210 IF (NOGO .EQ. 0) WRITE (6,220)        
  220 FORMAT ('  OK')        
C        
C     LOGICAL 'AND' AND 'OR' CHECK.        
C     SYSTEM MAY NAME THESE FUNCTIONS - 'IAND', 'IOR', OR 'AND', 'OR'   
C     IF UNSATISFIED EXTERNALS OCCUR, FIX THEM HERE AND IN MAPFNS.MDS   
C        
      WRITE  (6,230)        
  230 FORMAT ('  LOGICAL "AND" AND "OR" CHECK.  IF ERROR OCCURS, ',     
     1        'SEE MACHCK')        
      K  = IAND(I,J)        
      K  =  IOR(I,J)        
C     K  =  AND(I,J)        
C     K  =   OR(I,J)        
      WRITE (6,220)        
C        
C     CHECK DATE AND TIME, ALREADY SAVED IN /SYSTEM/ BY NASTRN OR NAST01
C        
C     TIME IS SYSTEM CPU TIME, COMMONLY IN 1/60 SECONDS ACCURCY        
C     IF UNSATISFIED EXTERNALS OCCUR, FIX THEM IN TDATE, KLOCK, WALTIM, 
C     CPUTIM, AND/OR SECNDS(IN MAPFNS) SUBROUTINES        
C        
      WRITE  (6,240)        
  240 FORMAT ('  DATE AND TIME CHECKS.  IF ERROR OCCURS, SEE MACHCK')   
      I  = TIMEW/3600        
      J  = (TIMEW-I*3600)/60        
      K  = TIMEW - I*3600 - J*60        
      WRITE  (6,250) DATE,I,J,K        
  250 FORMAT (' -MONTH/DAY/YEAR = ',I2,1H/,I2,1H/,I2, 3X,        
     1        ' -HOUR:MIN:SEC = ',I2,':',I2,':',I2)        
      IF (DATE(1).GT.12 .OR. DATE(3).GT.1000) WRITE (6,260)        
  260 FORMAT (' * SYSTEM DATE SHOULD BE IN mm,dd,yy',        
     1       ' ORDER  <===')        
C        
      R  = MOD(LQRO,100)/10        
      IF (R .GT. 1) L1 = BT        
      IF (MOD(LQRO,10) .EQ. 1) L2 = RV        
      WRITE  (6,270) MACHX,MCHNAM,L1,L2,SYSBUF,LQRO        
  270 FORMAT (/,' -MACHINE =',I3,2H, ,A4,', RECL BY ',A4,        
     1       'S, BCD WORD IN ',A8,' ORDER,', /3X,'SYSBUF =',I7,        
     2       ' WORDS,  LQRO =',I7)        
C        
C     OPEN A DIRECT FILE, FORTRAN UNIT 41, AND TEST FOR RECORD LENGTH   
C        
      I  = SYSBUF - 3        
      IF (MACHX.EQ.3 .OR. MACHX.GE.5) I = SYSBUF - 4        
      I  = I*R        
      OPEN  (UNIT=41,ACCESS='DIRECT',RECL=I,STATUS='SCRATCH',ERR=310)   
      WRITE (41,REC=1,ERR=280) (Z(J),J=1,I)        
      GO TO 300        
  280 IF (R .GT. 1) GO TO 300        
      NOGO = 10        
      WRITE  (6,290) R        
  290 FORMAT (' * FORTRAN I/O RECORD LENGTH IN BTSTRP MAY BE IN ERROR.',
     1       5X,'R =',I4)        
  300 CLOSE  (UNIT=41)        
C        
C     CHECK OPEN CORE IN MEMORY                          ** NEW, NEXT 28
C        
  310 J  = 11        
      I  = LOCFX(Z(J))        
      J  = LOCFX(Z(1))        
      K  = AS        
      IF (I .LT. J) K = DS        
      WRITE  (6,320) K,J,I        
  320 FORMAT (' * SYSTEM MEMORY IN ',A3,'CENDING ORDER',I15,'==>',I12)  
C        
C     CHECK WHETHER NUMTYP.MIS IS SET UP FOR THIS CURRENT MACHINE       
C        
      K  = 123        
      IF (NUMTYP(K) .NE. 1) NOGO = 11        
C        
C     CHECK /SOFPTR/ LOCATION WITH RESPECT TO /ZZZZZZ/ LOCATION HERE IF 
C     AND ONLY IF CURRENT NASTRAN VERSION STILL USES /SOFPTR/, AND      
C     SET K = 1        
C                  K J          I           I          J K        
C               ---+-+----------+   OR   ---+----------+-+        
C                    ASCENDING                 DECENDING        
C        
      K  = 0        
      IF (K .NE. 1) GO TO 340        
C        
      K  = LOCFX(S)        
      IF (I.GT.J .AND. K.GT.J) WRITE (6,330)        
      IF (I.LT.J .AND. K.LT.J) WRITE (6,330)        
  330 FORMAT (' * COMMONS /SOFPTR/ AND /ZZZZZZ/ POSITIONS SHOULD BE ',  
     1        'REVERSED IN OPNCOR.MDS')        
C        
C     CHECK S.P. NUMERIC RANGE        
C        
  340 IF (10.0**(LOWPW+1).GE.0.0 .AND. 10.0**(HIGHPW-1).GT.10.0**36)    
     1    GO TO 360        
      NOGO = 12        
      WRITE  (6,350) LOWPW,HIGHPW        
  350 FORMAT (' * MACHINE NUMERIC RANGE, 10.**',I3,' THRU 10.**',I2,    
     1        ' SET BY BTSTRP, EXCEEDS MACHINE LIMIT.')        
C        
C     CHECK FORTRAN MIXED FORMAT WRITE USED IN SUBOURINTE OFPPNT OF THE 
C     OFP MODULE.        
C     DEC/ULTRIX FORTRAN 3.0 (1992) FAILS ON THIS TEST.        
C        
  360 IX = 123456        
      WRITE  (6,370,ERR=380) XX        
  370 FORMAT (/,I10)        
  380 WRITE  (6,390)        
  390 FORMAT (' IF 123456 IS NOT PRINTED ON ABOVE LINE, MIXED FORMAT ', 
     1        'PRINT OUT IS NOT', /1X,        
     2        'ALLOWED, AND NASTRAN OFP MODULE MAY NOT WORK PROPERLY')  
C        
C     CHECK OPEN CORE        
C        
      J  = 5000        
      Z(J) = 1        
      Z(HICORE) = 2        
C        
      IF (NOGO .NE. 0) GO TO 410        
      WRITE  (6,400) UIM        
  400 FORMAT (A29,', MACHINE COMPATIBILITY CHECK ROUTINE FINDS NO ',    
     1        /5X,'SIGNIFICANT SYSTEM ERROR')        
      RETURN 1        
C        
  410 WRITE  (6,420) UIM,NOGO        
  420 FORMAT (A29,' * ERROR IN MACHCK.  NOGO =',I3)        
      CALL MESAGE (-61,0,0)        
      RETURN        
      END        
