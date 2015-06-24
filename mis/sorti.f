      SUBROUTINE SORTI (INPFL,OUTFL,NWDS,KEYWRD,L,NX)        
C        
C     WITH ENTRY POINT SORTI2 TO SORT TABLE BY 2 KEY WORDS        
C        
C     THIS SORTING ROUTINE WAS CALLED SORT BEFORE, AND IS NOW RENAMED   
C     SORTI. IT IS CAPABLE FOR IN-CORE SORTING AND FILE SORT.        
C        
C     THE NEW SUBROUTINE SORT IS A TRUNCATED VERSION OF THIS ROUTINE    
C     ONLY FOR IN-CORE SORTING. IT CAN HANDLE INTEGER, REAL, BCD(A4),   
C     BCD(A8), BCD(A7), AND 2-KEY SORTINGS.        
C        
C     (95 PERCENT OF NASTRAN ROUTINES ACTUALLY CALL SORT. THE REMAINING 
C       5 PERCENT CALL SORTI)        
C        
C     IF INPFL AND OUTFL ARE ZERO, CALLING ROUTINE SHOULD CALL SORT     
C     FOR EFFICIENCY        
C        
C     THE OLD SHUTTLE EXCHANGE, WHICH WAS VERY SLOW, IS NOW REPLACED BY 
C     A SUPER FAST SORTER, A MODIFIED SHELL SORT.        
C        
C     THIS MODIFIED VERSION ALSO SORTS TABLE OF ANY LENGTH (PREVIOUSLY N
C     OF WORDS PER ENTRY, NWDS, WAS LIMITED TO 20)        
C        
      INTEGER         OUTFL,SCRA,SCRB,SCRC,DIST1,DIST2,DUMMY,TOTAL,OUT, 
     1                SUBR(2),L(NWDS,2),TEMP,FILE,R,BUFA,BUFB,BUFC,     
     2                SYSBUF,BUFIN,TWO,TWO31        
      COMMON /SETUP / NFILE(6),BUFIN        
      COMMON /SYSTEM/ SYSBUF,DUM38(38),NBPW        
      COMMON /TWO   / TWO(16)        
      EQUIVALENCE     (NFILE(1),SCRB),(NFILE(2),SCRC),(NFILE(3),SCRA)   
      DATA    SUBR  / 4HSORT, 4HI    /        
C        
      KEY2 = 1        
      GO TO 10        
C        
C        
      ENTRY SORTI2 (INPFL,OUTFL,NWDS,KEYWRD,L,NX)        
C     ==========================================        
C        
      KEY2 = 2        
C        
C     IF INPFL EQ 0, CORE BLOCK L OF LENGTH NX IS TO BE SORTED        
C     IF INPFL NE 0, INPFL IS TO BE SORTED USING BLOCK L        
C        
   10 KEYWD = IABS(KEYWRD)        
      NNN   = NX        
      IF (NNN .LT. NWDS) GO TO 350        
      J = 30        
      IF (NBPW .GE. 60) J = 47        
      TWO31 = 2**J        
      IF (INPFL .EQ. 0) GO TO 30        
      BUFA  = NX - SYSBUF + 1        
C        
C     MINIMUM CORE REQUIREMENT = 2 X NUMBER OF WORDS PER ENTRY        
C        
      NZ  = BUFA - 1        
      IF (NZ .LT. NWDS+NWDS) GO TO 360        
      CALL OPEN (*370,SCRA,L(BUFA,1),1)        
      NN  = (NZ/NWDS)*NWDS        
      NNN = NN        
      OUT = SCRA        
      NREC= 0        
   20 CALL READ (*430,*170,INPFL,L,NN,0,NNN)        
C        
C     SORT PHASE --        
C        
   30 LEN = NNN/NWDS        
      IF (LEN*NWDS .NE. NNN) GO TO 365        
      M = LEN        
      IF (KEYWRD .GE. 0) GO TO 40        
C        
C                     - INTEGER SORT ONLY -        
C     IF ORIGINAL ORDER IS TO BE MAINTAINED WHERE DUPLICATE KEYWORDS MAY
C     OCCUR, ADD INDICES TO THE KEYWORDS (GOOD FOR BOTH POSITIVE AND    
C     NEGATIVE RANGES, AND BE SURE THAT KEYWORDS ARE NOT OVERFLOWED),   
C     SORT THE DATA, AND REMOVE THE INDICES LATER        
C        
C     IF ANY KEYWORD OVERFLOWS, SWITCH TO SHUTTLE EXCHANGE METHOD       
C     LIMIT IS THE MAX VALUE BEFORE INTEGER OVERFLOW        
C        
      IF (LEN.GE.TWO(16) .AND. NBPW.LE.32) GO TO 130        
      LIMIT = (TWO31-LEN)/LEN        
      DO 35 I = 1,LEN        
      J = L(KEYWD,I)        
      IF (IABS(J) .GT. LIMIT) GO TO 124        
      J = J*LEN + I        
      K = -1        
      IF (J .LT. 0) K = -LEN        
   35 L(KEYWD,I) = J + K        
      IF (KEY2 .EQ. 1) GO TO 40        
      DO 37 I = 1,LEN        
      J = L(KEYWD+1,I)        
      IF (IABS(J) .GT. LIMIT) GO TO 120        
      J = J*LEN + I        
      K = -1        
      IF (J .LT. 0) K = -LEN        
   37 L(KEYWD+1,I) = J + K        
C        
C     SORT BY        
C     MODIFIED SHELL METHOD, A SUPER FAST SORTER        
C        
   40 M = M/2        
      IF (M .EQ. 0) GO TO 110        
      J = 1        
      K = LEN - M        
   45 I = J        
   50 N = I + M        
C     IF (L(KEYWD,I)-L(KEYWD,N)) 105,105,95        
      IF (L(KEYWD,I)-L(KEYWD,N)) 105, 60,95        
   60 IF (KEY2 .EQ. 1) GO TO 105        
      IF (L(KEYWD+1,I)-L(KEYWD+1,N)) 105,105,95        
   95 DO 100 R = 1,NWDS        
      TEMP   = L(R,I)        
      L(R,I) = L(R,N)        
  100 L(R,N) = TEMP        
      I = I - M        
      IF (I .GE. 1) GO TO 50        
  105 J = J + 1        
      IF (J-K) 45,45,40        
  110 IF (KEYWRD .GE. 0) GO TO 160        
      DO 115 I = 1,LEN        
      L(KEYWD,I) = L(KEYWD,I)/LEN        
      IF (KEY2 .EQ. 2) L(KEYWD+1,I) = L(KEYWD+1,I)/LEN        
  115 CONTINUE        
      GO TO 160        
C        
C     SORT BY        
C     SHUTTLE EXCHANGE METHOD, A SLOW SORTER        
C     (THIS WAS NASTRAN ORIGINAL SORTER, MODIFIED FOR 2-D ARRAY        
C     OPERATION WITH 20-COLUMN LIMITATION REMOVED)        
C        
  120 IF (I .LE. 1) GO TO 123        
      J = I - 1        
      DO 121 I = 1,J        
  121 L(KEYWD+1,I) = L(KEYWD+1,I)/LEN        
  123 I = LEN        
  124 IF (I .LE. 1) GO TO 130        
      J = I - 1        
      DO 125 I = 1,J        
  125 L(KEYWD,I) = L(KEYWD,I)/LEN        
C        
  130 DO 155 II = 2,LEN        
      JJ = II - 1        
C     IF (L(KEYWD,II) .GE. L(KEYWD,JJ)) GO TO 155        
      IF (L(KEYWD,II)-L(KEYWD,JJ)) 135,133,155        
  133 IF (KEY2 .EQ. 1) GO TO 155        
      IF (L(KEYWD+1,II) .GE. L(KEYWD+1,JJ)) GO TO 155        
  135 JJ = JJ - 1        
C     IF (JJ .GT. 0) IF (L(KEYWD,II)-L(KEYWD,JJ)) 135,140,140        
      IF (JJ .LE. 0) GO TO 140        
      IF (L(KEYWD,II)-L(KEYWD,JJ)) 135,137,140        
  137 IF (KEY2 .EQ. 2) IF (L(KEYWD+1,II)-L(KEYWD+1,JJ)) 135,140,140     
  140 JJ = JJ + 2        
      DO 150 I = 1,NWDS        
      TEMP = L(I,II)        
      M = II        
      DO 145 J = JJ,II        
      L(I,M) = L(I,M-1)        
  145 M = M - 1        
  150 L(I,JJ-1) = TEMP        
  155 CONTINUE        
C        
C     IF CORE SORT, SORT IS COMPLETED. IF FILE SORT, WRITE BLOCK ON     
C     SCRATCH FILE TO BE MERGED LATER.        
C        
  160 IF (INPFL .EQ. 0) GO TO 350        
  165 CALL WRITE (SCRA,L,NNN,1)        
      NREC = NREC + 1        
      IF (NNN-NN) 180,20,180        
  170 IF (NNN) 180,180,175        
  175 IF (NNN-NWDS-NWDS) 165,30,30        
  180 CALL CLOSE (SCRA,1)        
C        
C     IF ONLY ONE RECORD, BYPASS MERGE        
C        
      IF (NREC .EQ. 1) GO TO 320        
C        
C     COMPUTE OPTIMUM DISTRIBUTION OF SORTED RECORDS ON TWO SCRATCH     
C     FILES FOR MERGE PHASE USING FIBONACCI SEQUENCE        
C        
      LEVEL = 0        
      DIST1 = 1        
      DIST2 = 0        
      TOTAL = 1        
  190 DUMMY = TOTAL - NREC        
      IF (DUMMY .GE. 0) GO TO 195        
      DIST1 = DIST1 + DIST2        
      DIST2 = DIST1 - DIST2        
      TOTAL = DIST1 + DIST2        
      LEVEL = LEVEL + 1        
      GO TO 190        
  195 BUFB  = BUFA - SYSBUF        
      BUFC  = BUFB - SYSBUF        
      IF (BUFC .LT. 1) GO TO 360        
      NN = BUFB - 1        
C        
C     COPY N SORTED RECORDS ONTO SECOND SCRATCH FILE        
C        
      CALL OPEN (*370,SCRA,L(BUFA,1),0)        
      CALL OPEN (*380,SCRB,L(BUFB,1),1)        
      N = DIST2 - DUMMY        
      DO 205 I = 1,N        
  200 CALL READ  (*440,*205,SCRA,L,NN,0,NFLAG)        
      CALL WRITE (SCRB,L,NN,0)        
      GO TO 200        
  205 CALL WRITE (SCRB,L,NFLAG,1)        
      CALL CLOSE (SCRB,1)        
      CALL CLOSE (SCRA,2)        
      NFILE(4) = SCRB        
      NFILE(5) = SCRC        
      K = 4        
C        
C     MERGE PHASE ---        
C     INPUT FILE WITH GREATER NUMBER IF RECORDS = IN1        
C     INPUT FILE WITH LESSER  NUMBER OF RECORDS = IN2        
C     EACH PASS MERGES ALL RECORDS FROM IN2 WITH LIKE NUMBER OF RECORDS 
C     (INCLUDING DUMMY RECORDS) FROM IN1 ONTO OUT. FOR NEXT PASS IN1    
C     BECOMES IN2, IN2 BECOMES OUT, AND OUT BECOMES IN1.        
C        
      DO 310 I = 1,LEVEL        
      K = K - 1        
      IF (K .EQ. 0) K = 3        
      IN1 = NFILE(K)        
      IN2 = NFILE(K+1)        
      OUT = NFILE(K+2)        
      LAST= 2        
      CALL OPEN (*390,IN1,L(BUFA,1),2)        
      CALL OPEN (*400,IN2,L(BUFB,1),2)        
      CALL OPEN (*410,OUT,L(BUFC,1),1)        
      DO 300 J = 1,DIST2        
      IF1 = NWDS        
      IF2 = NWDS        
      CALL READ (*450,*275,IN1,L,NWDS,0,IF1)        
      IF (DUMMY) 210,210,280        
  210 CALL READ (*460,*290,IN2,L(1,2),NWDS,0,IF2)        
C 220 IF (L(KEYWD,1)-L(KEYWD,2)) 260,260,270        
  220 IF (L(KEYWD,1)-L(KEYWD,2)) 260,230,270        
  230 IF (KEY2 .EQ. 2) IF (L(KEYWD+1,1)-L(KEYWD+1,2)) 260,260,270       
  260 CALL WRITE (OUT,L,NWDS,0)        
      CALL READ  (*450,*275,IN1,L,NWDS,0,IF1)        
      IF (IF2) 260,260,220        
  270 CALL WRITE (OUT,L(1,2),NWDS,0)        
      CALL READ  (*460,*290,IN2,L(1,2),NWDS,0,IF2)        
      IF (IF1) 270,270,220        
  275 IF (IF2) 300,300,270        
  280 DUMMY = DUMMY - 1        
      IF2 = 0        
  290 IF (IF1) 300,300,260        
  300 CALL WRITE (OUT,0,0,1)        
      DIST2 = DIST1 - DIST2        
      DIST1 = DIST1 - DIST2        
      IF (DIST2 .EQ. 0) LAST = 1        
      CALL CLOSE (IN1,LAST)        
      CALL CLOSE (IN2,1)        
  310 CALL CLOSE (OUT,1)        
C        
C     COPY PHASE ---        
C     IF OUTPUT FILE IS NOT SPECIFIED, NFILE(6) WILL CONTAIN NAME OF    
C     SCRATCH FILE CONTAINING OUTPUT        
C        
  320 NFILE(6) = OUT        
      IF (OUTFL .EQ. 0) GO TO 350        
      CALL OPEN (*410,OUT,L(BUFA,1),0)        
      IF (INPFL .NE. OUTFL) GO TO 330        
      CALL CLOSE (INPFL,1)        
      CALL OPEN  (*420,INPFL,L(BUFIN,1),1)        
  330 CALL READ  (*470,*340,OUT,L,NZ,0,NFLAG)        
      CALL WRITE (OUTFL,L,NZ,0)        
      GO TO 330        
  340 CALL WRITE (OUTFL,L,NFLAG,1)        
      CALL CLOSE (OUT,1)        
  350 RETURN        
C        
C     ERRORS        
C        
  360 J = -8        
      FILE = 0        
      GO TO  500        
  365 J = -37        
      GO TO  500        
  370 FILE = SCRA        
      GO TO  480        
  380 FILE = SCRB        
      GO TO  480        
  390 FILE = IN1        
      GO TO  480        
  400 FILE = IN2        
      GO TO  480        
  410 FILE = OUT        
      GO TO  480        
  420 FILE = INPFL        
      GO TO  480        
  430 FILE = INPFL        
      GO TO  490        
  440 FILE = SCRA        
      GO TO  490        
  450 FILE = IN1        
      GO TO  490        
  460 FILE = IN2        
      GO TO  490        
  470 FILE = OUT        
      GO TO  490        
  480 J = -1        
      GO TO  500        
  490 J = -2        
  500 CALL MESAGE (J,FILE,SUBR)        
      RETURN        
      END        
