      SUBROUTINE GIBSTK (NDSTK,IOLD,RENUM,NDEG,LVL,LVLS1,LVLS2,CCSTOR,  
     1                   JUMP,ICRIT,NHIGH,NLOW,NACUM,SIZE,STPT,UN,IDIM) 
C        
C     THIS ROUTINE IS USED ONLY IN BANDIT MODULE        
C        
C     GIBBSTOCK USES GRAPH THEORETICAL METHODS TO PRODUCE A PERMUTATION 
C     OF AN INPUT ARRAY WHICH REDUCES ITS BANDWITH        
C        
C     THE FOLLOWING INPUT PARAMETERS ARE REQUIRED--NDSTK,N,IDEG,IOLD    
C        
C     THESE INTEGER ARRAYS MUST BE DIMENSIONED IN THE CALLING PROGRAM-- 
C     NDSTK(NR,D1),RENUM(D2+1),NDEG(D2),IOLD(D2),LVL(D2),LVLS1(D2),     
C     LVLS2(D2),CCSTOR(D2)   WHERE D1 .GE. MAX DEGREE OF ANY NODE AND   
C     D2 AND NR ARE .GE. THE TOTAL NUMBER OF NODES IN THE GRAPH.        
C        
C     EXPLANATION OF PARAMETERS--        
C     NDSTK   - ADJACENCY ARRAY REPRESENTING GRAPH TO BE PROCESSED      
C               NDSTK(I,J) = NODE NUMBER OF JTH CONNECTION TO NODE      
C               NUMBER I.  A CONNECTION OF A NODE TO ITSELF IS NOT      
C               LISTED.  EXTRA POSITIONS MUST HAVE ZERO FILL.        
C     NR      - ROW DIMENSION ASSIGNED NDSTK IN CALLING PROGRAM = II1   
C     IOLD(I) - RENUMBERING OF ITH NODE BEFORE GIBBSTOCK PROCESSING     
C               IF NO RENUMBERING EXISTS THEN ILD(1)=1,ILD(2)=2, ETC.   
C     N       - NUMBER OF NODES IN GRAPH BEING PROCESSED        
C     IDEG    - MAX DEGREE OF ANY NODE IN GRAPH BEING PROCESSED        
C     JUMP   IS SET TO 0 IF EITHER CRITERION IS REDUCED.        
C     ICRIT   - RESEQUENCING CRITERION, SET BY BANDIT        
C               1 RMS WAVEFRONT, 2 BANDWIDTH, 3 PROFILE, 4 MAX.WAVEFRONT
C        
C     ON OUTPUT THESE VARIABLES CONTAIN THE FOLLOWING INFORMATION--     
C     RENUM(I)- THE NEW NUMBER FOR THE ITH NODE        
C     NDEG(I) - THE DEGREE OF THE ITH NODE        
C     IDPTH   - NUMBER OF LEVELS IN GIBBSTOCK LEVEL STRUCTURE        
C     IBW2    - THE BANDWITH AFTER RENUMBERING        
C     IPF2    - THE PROFILE AFTER RENUMBERING        
C        
C     THE FOLLOWING ONLY HAVE MEANING IF THE GRAPH WAS ALL ONE COMPONENT
C     LVL(I)  - INDEX INTO LVLS1 TO THE FIRST NODE IN LEVEL I        
C               LVL(I+1)-LVL(I)= NUMBER OF NODES IN ITH LEVEL        
C     LVLS1   - LEVEL STRUCTURE CHOSEN BY GIBBSTOCK        
C     LVLS2(I)- THE LEVEL ASSIGNED TO NODE I BY GIBBSTOCK        
C        
      INTEGER          STNODE,   RVNODE,   RENUM,    XC,       SUMWB,   
     1                 STNUM,    CCSTOR,   SIZE,     STPT,     SBNUM,   
     2                 OBW,      OP,       XCMAX        
      REAL             IM1,      IM2        
      DIMENSION        NHIGH(1), NLOW(1),  NACUM(1), SIZE(1),  STPT(1), 
     1                 CCSTOR(1),IOLD(1),  LVL(1),   LVLS1(1), LVLS2(1),
     2                 RENUM(1), NDEG(1),  NDSTK(1), UN(1)        
      COMMON /BANDA /  DUM5A(5), METHOD        
      COMMON /BANDB /  DUM3B(3), NGRID        
      COMMON /BANDD /  OBW,      NBW,      OP,       NP,       NCM,     
     1                 NZERO        
      COMMON /BANDG /  N,        IDPTH,    IDEG        
      COMMON /BANDW /  MAXW0,    RMS0,     MAXW1,    RMS1,     I77,     
     1                 BRMS0,    BRMS1        
      COMMON /BANDS /  NN,       MM        
      COMMON /SYSTEM/  IBUF,     NOUT,     DUM6S(6), NLPP        
C        
C     OLD AND NEW MAX AND RMS WAVEFRONT FOR ENTIRE PROBLEM,        
C     NOT JUST GIBSTK.        
C     DIMENSIONS OF NHIGH, NLOW, AND NACUM ARE IDIM EACH        
C     SIZE AND STPT HAVE DIMENSION IDIM/2 AND SHOULD BE CONTIGUOUS IN   
C     CORE WITH SIZE FIRST.        
C     XC = NUMBER OF SUB-COMPONENTS RESULTING AFTER REMOVING DIAMETER   
C     FROM ONE COMPONENT OF ORIGINAL GRAPH.        
C        
      XCMAX = IDIM/2        
      NCM   = 0        
      N     = NN        
      IBW2  = 0        
      IPF2  = 0        
C        
C     SET RENUM(I) = 0 FOR ALL I TO INDICATE NODE I IS UNNUMBERED       
C     THEN COMPUTE DEGREE OF EACH NODE AND ORIGINAL B AND P.        
C        
      DO 30 I = 1,N        
   30 RENUM(I) = 0        
      CALL DGREE (NDSTK,NDEG,IOLD,IBW1,IPF1,UN)        
C        
C     ORIGINAL ACTIVE COLUMN DATA IN MAXW1 AND RMS1, COMPUTED BY SCHEME 
C        
      IF (METHOD .NE. 0) GO TO 35        
      MAXWA = MAXW1        
      RMSA  = RMS1        
      BRMSA = BRMS1        
      GO TO 38        
   35 MAXWA = MAXW0        
      RMSA  = RMS0        
      BRMSA = BRMS0        
   38 CONTINUE        
C        
C     NUMBER THE NODES OF DEGREE ZERO        
C     SBNUM = LOW  END OF AVAILABLE NUMBERS FOR RENUMBERING        
C     STNUM = HIGH END OF AVAILABLE NUMBERS FOR RENUMBERING        
C        
      SBNUM = 1        
      STNUM = N        
      DO 40 I = 1,N        
      IF (NDEG(I) .GT. 0) GO TO 40        
      RENUM(I) = STNUM        
      STNUM = STNUM-1        
   40 CONTINUE        
C        
C     NODES OF ZERO DEGREE APPEAR LAST IN NEW SEQUENCE.        
C        
      NZERO = N - STNUM        
      NCM   = NZERO        
C        
C     FIND AN UNNUMBERED NODE OF MIN DEGREE TO START ON        
C        
   50 LOWDG = IDEG + 1        
      NCM   = NCM + 1        
      NFLG  = 1        
      ISDIR = 1        
      DO 70 I = 1,N        
      IF (NDEG(I).GE.LOWDG .OR. RENUM(I).GT.0) GO TO 70        
      LOWDG  = NDEG(I)        
      STNODE = I        
   70 CONTINUE        
C        
C     FIND PSEUDO-DIAMETER AND ASSOCIATED LEVEL STRUCTURES.        
C     STNODE AND RVNODE ARE THE ENDS OF THE DIAM AND LVLS1 AND LVLS2    
C     ARE THE RESPECTIVE LEVEL STRUCTURES.        
C        
      CALL FNDIAM (STNODE,RVNODE,NDSTK,NDEG,LVL,LVLS1,LVLS2,CCSTOR,     
     1             IDFLT,SIZE,UN,IDIM)        
      IF (NGRID .EQ. -3) RETURN        
      IF (NDEG(STNODE) .LE. NDEG(RVNODE)) GO TO 75        
C        
C     NFLG INDICATES THE END TO BEGIN NUMBERING ON        
C        
      NFLG   =-1        
      STNODE = RVNODE        
   75 CALL RSETUP (LVL,LVLS1,LVLS2,           NACUM,IDIM)        
C                                  NHIGH,NLOW,    <===== NEW        
      IF (NGRID .EQ. -3) RETURN        
C        
C     FIND ALL THE CONNECTED COMPONENTS  (XC COUNTS THEM)        
C        
      XC    = 0        
      LROOT = 1        
      LVLN  = 1        
      DO 85 I = 1,N        
      IF (LVL(I) .NE. 0) GO TO 85        
      XC = XC + 1        
      IF (XC .LE. XCMAX) GO TO 80        
C        
C     DIMENSION EXCEEDED.  STOP JOB.        
C        
      NGRID =-3        
      RETURN        
C        
   80 STPT(XC) = LROOT        
      CALL TREE (I,NDSTK,LVL,CCSTOR,NDEG,LVLWTH,LVLBOT,LVLN,MAXLW,N,UN) 
      SIZE(XC) = LVLBOT + LVLWTH - LROOT        
      LROOT = LVLBOT + LVLWTH        
      LVLN  = LROOT        
   85 CONTINUE        
C     IF (SORT2(XC,SIZE,STPT).EQ.0) GO TO 90        
      CALL PIKLVL (*90,LVLS1,LVLS2,CCSTOR,IDFLT,ISDIR,XC,NHIGH,NLOW,    
     1             NACUM,SIZE,STPT)        
C        
C     ON RETURN FROM PIKLVL, ISDIR INDICATES THE DIRECTION THE LARGEST  
C     COMPONENT FELL.  ISDIR IS MODIFIED NOW TO INDICATE THE NUMBERING  
C     DIRECTION.  NUM IS SET TO THE PROPER VALUE FOR THIS DIRECTION.    
C        
   90 ISDIR = ISDIR*NFLG        
      NUM   = SBNUM        
      IF (ISDIR .LT. 0) NUM = STNUM        
C        
      CALL NUMBER (STNODE,NUM,NDSTK,LVLS2,NDEG,RENUM,LVLS1,LVL,NFLG,    
     1             IBW2,IPF2,CCSTOR,ISDIR,NHIGH,NLOW,NACUM,SIZE,UN,IDIM)
      IF (NGRID .EQ. -3) RETURN        
C        
C     UPDATE STNUM OR SBNUM AFTER NUMBERING        
C        
      IF (ISDIR .LT. 0) STNUM = NUM        
      IF (ISDIR .GT. 0) SBNUM = NUM        
      IF (SBNUM .LE. STNUM) GO TO 50        
C        
C     COMPUTE THE NEW BANDWIDTH, PROFILE, AND WAVEFRONT.        
C        
      CALL WAVEY (NDSTK,RENUM,LVL,0,LVLS2,LVLS1,MAXB,MAXWB,AVERWB,      
     1            SUMWB,RMSB,BRMSB,UN)        
C        
      IBW2 = MAXB        
      IPF2 = SUMWB        
      IF (NLPP .GT. 50) WRITE (NOUT,100) MAXB,SUMWB,MAXWB,AVERWB,       
     1                                   RMSB,BRMSB        
  100 FORMAT (/31X,66HAFTER RESEQUENCING BY GIBBS-POOLE-STOCKMEYER (GPS)
     1 ALGORITHM - - -,        
     2        /40X,13HBANDWIDTH    ,I9,  /40X,13HPROFILE      ,I9,      
     3        /40X,13HMAX WAVEFRONT,I9,  /40X,13HAVG WAVEFRONT,F9.3,    
     4        /40X,13HRMS WAVEFRONT,F9.3,/40X,13HRMS BANDWIDTH,F9.3)    
C        
C     CHECK NEW NUMBERING AGAINST OLD NUMBERING.        
C        
      GO TO (110,120,130,140), ICRIT        
  110 IM1   = RMSA        
      IM2   = IPF1        
      CRIT1 = RMSB        
      CRIT2 = IPF2        
      GO TO 150        
  120 IM1   = IBW1        
      IM2   = IPF1        
      CRIT1 = IBW2        
      CRIT2 = IPF2        
      GO TO 150        
  130 IM1   = IPF1        
      IM2   = IBW1        
      CRIT1 = IPF2        
      CRIT2 = IBW2        
      GO TO 150        
  140 IM1   = MAXWA        
      IM2   = RMSA        
      CRIT1 = MAXWB        
      CRIT2 = RMSB        
C        
  150 IF (CRIT1-IM1) 210,160,170        
  160 IF (CRIT2 .LT. IM2) GO TO 210        
C        
C     IF ORIGINAL NUMBERING IS BETTER THAN NEW ONE, SET UP TO RETURN IT 
C        
  170 DO 200 I = 1,N        
  200 RENUM(I) = IOLD(I)        
      IBW2  = IBW1        
      IPF2  = IPF1        
      MAXWB = MAXWA        
      RMSB  = RMSA        
      BRMSB = BRMSA        
      GO TO 220        
C        
C     EQUATE CORRESPONDING GPS AND BANDIT VARIABLES.        
C        
  210 JUMP  = 0        
  220 NBW   = IBW2        
      NP    = IPF2        
      MAXW1 = MAXWB        
      RMS1  = RMSB        
      BRMS1 = BRMSB        
      RETURN        
      END        
