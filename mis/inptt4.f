      SUBROUTINE INPTT4        
C        
C     THIS INPTT4 UTILITY MODULE WILL READ USER-SUPPLIED TAPE (OR DISC  
C     FILE), AS GENERATED FROM OUTPUT4 OR FROM MSC/OUTPUTi MODULES (i=1,
C        
C     THIS MODULE HANDLES ONLY MATRICES, AND NOT TABLES        
C        
C     COSMIC/OUTPUT4 AND MSC/OUTPUT4 ARE IDENTICAL (BINARY ONLY)        
C     COSMIC/INPUTT4 AND MSC/INPUTT4 ARE SIMILAR, EXECPT COSMIC/INPUTT4 
C     CAN ALSO PROCESS MSC/OUTPUT1 AND MSC/OUTPUT2 TAPES.        
C        
C     INPUTT4   /O1,O2,O3,O4,O5/V,N,P1/V,N,P2/V,N,P3/V,N,P4 $        
C        
C        Oi     = OUTPUT GINO DATA BLOCKS        
C        
C        P1     = TAPE READ POSITION CONTROL        
C               . SEE P1 OF INPUTT1 MODULE IF P4=-1        
C               . SEE P1 OF INPUTT2 MODULE IF P4=-2        
C               . SEE P1 OF INPUTT4 MODULE IF P4=-4        
C               . IF P4=0,   P1= 0 NO ACTION        
C                            P1=-1 REWIND P2 BEFORE READ        
C                            P1=-2 WRITE E-O-F MARK AND REWIND P2 AT END
C                            P1=-3 BOTH        
C        P2     =+N, INPUT TAPE LOGICAL UNIT, INTEGER, NO DEFAULT       
C                    INPUT TAPE IS IN BINARY (UNFORMATTED).        
C               =-N, INPUT TAPE LOGICAL UNIT +N, INPUT MATRICES WERE    
C                    WRITTEN IN BCD RECORDS (i.e. ASCII, FORMATTED)     
C        P3     = TAPE LABEL, DEFAULT='XXXXXXXX'        
C        P4     = OUTPUT TAPE MODULE, INTEGER (DEFAULT P4=0)        
C               =-4, TAPE WAS ORIGINALLY WRITTEN BY MSC/OUTPUT4 MODULE* 
C                    UNFORMATTED (BINARY) TAPE, OR FORMATTED (BCD) TAPE.
C                    FORMATS FOR BCD TAPE ARE -        
C                    3I8 FOR INTEGERS, 2A4 FOR BCD, AND 5E16.9 FOR REAL.
C               =-2, TAPE WAS ORIGINALLY WRITTEN BY MSC/OUTPUT2 MODULE* 
C               =-1, TAPE WAS ORIGINALLY WRITTEN BY MSC/OUTPUT1 MODULE* 
C               = 0, TAPE WAS ORIGINALLY WRITTEN BY OUTPUT4 MODULE      
C                 .  IN BINARY RECORDS (P2=+N), UNFORMATTED.        
C                 .  IN ASCII FORMATTED RECORDS (P2=-N), FORMATS FOR    
C                    INTEGERS AND REAL DATA ARE MATRIX TYPE DEPENDENT.  
C                    I13 AND 10E13.6 FOR S.P.MATRIX DATA, AND        
C                    I16 AND  8D16.9 FOR D.P.MATRIX DATA.        
C                    I16 AND  8E16.9 FOR S.P.MATRIX DATA, AND LONG WORD 
C             .GE.1, IN ASCII FORMATTED RECORDS (P2=-N), I16 IS USED FOR
C                    INTEGERS, AND 8E16.9 FOR ALL REAL S.P. OR D.P.DATA 
C        
C        * REQUIRE SYNCHRONIZED GINO BUFFER SIZE IN COSMIC NASTRAN AND  
C          MSC/NASTRAN        
C        
C     PARAMETERS EQUIVALENCE FOR COSMIC/INPUTT4 AND MSC/INPUTT4        
C        
C          COSMIC/INPUTT4        MSC/INPUTT4        
C          --------------        ------------------------------        
C               P1               NMAT (NO OF MATRICES ON TAPE)        
C               P2               P2        
C               P3               P1        
C               P4               BCDOPT        
C        
C        
C     NOTE - MIXED OUTPUT FILES FROM MSC/OUTPUT1, OUTPUT2 AND OUTPUT4   
C            ON ONE TAPE ARE NOT ALLOWED IN THIS INPUTT4 MODULE        
C        
C     EXAMPLE 1 - INPUT TAPE INP1 (UNIT 15) CONTAINS 5 MATRICES,        
C     =========   WRITTEN BY OUTPUT4, BINARY.        
C                 WE WANT TO COPY        
C                 FILE 3 TO A,        
C                 FILE 4 TO B        
C        
C     1.  INPUTT4  /,,A,B,/-1/15   $ REWIND, READ & ECHO HEADER RECORD  
C        
C        
C     EXAMPLE 2 - TO COPY THE FIRST 2 FILES OF A FORMATTED TAPE INP2    
C     =========   (UNIT 16), WRITTEN BY OUTPUT4        
C        
C     2.  INPUTT4  /A,B,,,/-1/-16  $        
C        
C        
C     EXAMPLE 3 - TO LIST THE FILES ON INP3 (TAPE CODE 3), THEN REWIND, 
C     =========   AND COPY FILES 2 AND 3 ON INPUT TAPE ORIGINALLY       
C                 WRITTEN BY MSC/OUTPUT1. TAPE CONTAINS A HEADER RECORD 
C                 (FILE 0), AND TAPE ID "MYFILE"        
C        
C     3.  INPUTT4  /A,B,,,/-3/3/*MYFILE*/-1  $        
C        
C     ACTUALLY, INPTT4 MODULE CALLS INPUT2 TO PROCESS ANY TAPE THAT WAS 
C     GENERATED BY MSC/OUTPUT2. SIMILARILY, INPUT1 IS CALLED FOR TAPE   
C     FROM MSC/OUTPUT1        
C        
C     THE FIRT PARAMETER NMAT IN MSC/INPUTT4 IS NOT USED HERE        
C        
      INTEGER         P1,P2,P3,P4,BCDOPT,Y(1),Z(1)        
      COMMON /BLANK / P1,P2,P3(2),P4        
      COMMON /SYSTEM/ IBUFF,NOUT        
CZZ   COMMON /ZZINP4/ X(1)        
      COMMON /ZZZZZZ/ X(1)        
CZZ   COMMON /ZZINP2/ Y        
      EQUIVALENCE     (Y(1),X(1))        
CZZ   COMMON /ZZINP1/ Z        
      EQUIVALENCE     (Z(1),X(1))        
C        
      IF (P4 .GE. 0) GO TO 40        
      NMAT = IABS(P4)        
      GO TO (10,20,30,40,30), NMAT        
C        
   10 CALL INPUT1        
      GO TO 50        
C        
   20 CALL INPUT2        
      GO TO 50        
C        
   30 WRITE  (NOUT,35) P4        
   35 FORMAT ('  ERROR IN INPTT4.  P4 =',I3,' NOT AVAILABLE')        
      CALL MESAGE (-61,0,0)        
C        
   40 NMAT  = 5        
      IUNIT = IABS(P2)        
      ITAPE = P1        
      BCDOPT= 1        
      IF (P2 .LT. 0) BCDOPT = 2        
      IF (P4 .GT. 0) BCDOPT = 3        
C        
C     BCDOPT = 1, BINARAY INPUT TAPE        
C            = 2, ASCII INPUT TAPE, WITH S.P./D.P. STANDARD FORMATS     
C            = 3, ASCII INPUT TAPE, WITH LARGE FILED S.P./D.P. FORMATS  
C        
      CALL INPUT4 (NMAT,IUNIT,ITAPE,BCDOPT)        
   50 RETURN        
      END        
