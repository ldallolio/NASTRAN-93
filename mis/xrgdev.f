      SUBROUTINE XRGDEV        
C        
C     PURPOSE - XRGDEV PROCESSES A FIELD FROM A ****CARD, ****FILE,     
C               ****SBST, OR A ****RFMT CARD FROM THE RIGID FORMAT      
C               DATA BASE        
C        
C     AUTHOR  - RPK CORPORATION; DECEMBER, 1983        
C        
C     INPUT        
C      /SYSTEM/        
C       NOUT    UNIT NUMBER FOR OUTPUT PRINT FILE        
C      /XRGDXX/        
C       ICOL    COLUMN CONTAINING THE FIRST CHARACTER OF THE FIELD      
C       LIMIT   2 WORD ARRAY CONTAINING THE LOWER/UPPER LIMITS FOR      
C               VALUES GIVEN IN THE FIELD        
C       NUMBER  INTEGER VALUE FOR A ALPHA NUMBER WITHIN THE FIELD       
C       RECORD  ARRAY IN 20A4 FORMAT CONTAINING THE CARD IMAGE        
C        
C     OUTPUT        
C      /XRGDXX/        
C       IERROR  ERROR FLAG IS NON-ZERO IF AN ERROR OCCURRED        
C       NUM     2 WORD ARRAY CONTAINING THE VALUE(S) WITHIN THE CURRENT 
C               FIELD        
C        
C     LOCAL VARIABLES        
C       IND     INDEX TO THE ARRAY NUM        
C       ISTATE  NEXT STATE (ROW = IN THE ABOVE DATA STATEMENT) TO BE    
C               USED FOR SYNTAX VALIDATION BASED ON THE TYPE OF THE NEXT
C               CHARACTER IN THE FIELD        
C       ISTR    COLUMN CONTAINING THE FIRST CHARACTER WITHIN THE FIEL   
C       K       DO LOOP INDEX FOR SCANING CHARACTERS WITHIN THE FIELD   
C       STATE   TABLE USED TO VALIDATE THE SYNTAX OF THE FIELD.  THE    
C               NUMBER IN EACH ENTRY INDICATES THE ROW TO BE USED FOR   
C               VALIDATING THE SYNTAX OF THE NEXT CHARACTER.  IF THE    
C               VALUE IS 0 THEN A SYNTAX ERROR OCCURRED.        
C        
C     FUNCTIONS        
C     XRGDEV SCANS THE FIELD FOR SYNTAX ERRORS AND FOR PLACING THE NUMBE
C     INTO THE NUM ARRAY.  VALID FIELDS ARE OF THE FORM 'NNN,' OR       
C     'NNN-NNN,' WITH EMBEDDED BLANKS ALLOWED AND NUMBERS MAY BE OF     
C     ANY VALUE THAT IS WITHIN THE LIMITS OF THE ARRAY LIMIT.        
C        
C     SUBROUTINES CALLED - XRGDTP        
C        
C     CALLING SUBROUTINES - XRGSUB,XRGDCF        
C        
C     ERRORS        
C       ERROR MESSAGES 8021 AND 8022 ARE GIVEN FOR SYNTAX OR VALUE RANGE
C       ERRORS.        
C        
      INTEGER         RECORD, STATE(5,7)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /XRGDXX/ IRESTR, NSUBST, IPHASE, ICOL  , NUMBER, ITYPE ,   
     1                ISTATE, IERROR, NUM(2), IND   , NUMENT        ,   
     2                RECORD(20)    , ICHAR(80)     , LIMIT(2)      ,   
     3                ICOUNT, IDMAP , ISCR  , NAME(2),MEMBER(2)     ,   
     4                IGNORE        
      COMMON /SYSTEM/ ISYSBF, NOUT  , DUM(98)        
C                   NUMBER  ,      -    BLANK    OTHER        
      DATA    STATE / 1,   2,      3,      6,      0,        
     2                1,   0,      0,      2,      0,        
     3                4,   0,      0,      3,      0,        
     4                4,   2,      0,      5,      0,        
     5                0,   2,      0,      5,      0,        
     6                0,   2,      3,      6,      0,        
     7                1,   0,      0,      7,      0 /        
C        
      IF (ICOL .GT. 80) GO TO 110        
      ISTATE = 7        
      IND    = 1        
      NUM(1) = 0        
      ISTR   = ICOL        
      DO 50 K = ISTR,80        
      ICOL = K        
      CALL XRGDTP        
      ISTATE = STATE(ITYPE,ISTATE)        
      IF (ISTATE .NE. 0) GO TO 20        
      IERROR = 1        
      J = 0        
      WRITE  (NOUT,10) UFM,K,RECORD,J,(I,I=1,8),IERROR,(J,I=1,8)        
 10   FORMAT (A23,' 8020, SYNTAX ERROR NEAR COLUMN ',I3,        
     2       ' IN THE FOLLOWING CARD- ',/20X,20A4, /,(20X,I1,I9,7I10))  
      GO TO 110        
 20   GO TO (30,60,40,30,50,50,50), ISTATE        
 30   NUM(IND) = NUM(IND)*10 + NUMBER        
      GO TO 50        
 40   IND    = 2        
      NUM(2) = 0        
 50   CONTINUE        
 60   IF (IND .EQ. 2) GO TO 70        
      NUM(2) = NUM(1)        
      GO TO 90        
 70   IF (NUM(2) .GT. NUM(1)) GO TO 90        
      IERROR = 1        
      WRITE  (NOUT,80) UFM,NUM(1),NUM(2),RECORD        
 80   FORMAT (A23,' 8021, NON-INCREASING RANGE ',I3,1H-,I3,        
     1       ' IN THE FOLLOWING CARD -', /20X,20A4)        
 90   CONTINUE        
      IF (NUM(1).GE.LIMIT(1) .AND. NUM(2).LE.LIMIT(2)) GO TO 110        
      WRITE  (NOUT,100) UFM,LIMIT,RECORD        
 100  FORMAT (A23,' 8022, NUMBERS ARE OUT OF THE RANGE ',I3,1H-,I3,     
     1       ' IN THE FOLLOWING CARD - ', /20X,20A4)        
      IERROR = 1        
 110  CONTINUE        
      RETURN        
      END        
