      SUBROUTINE CTHMCK (NT,NUM,NOM,IO,IG,IC,IDEG,IDIS,IW,NEW,ICC,ILD,  
     1                   IPP,JUMP,UN,NODESL)        
C        
C     THIS IS THE EXECUTIVE FOR THE CUTHILL-MCKEE GRID POINT RENUMBERING
C     STRATEGY.        
C     91 VERSION, WITH REVERSED NEW SEQUENCE LOGIC        
C        
C     IN SAN ANTONIO, TEXAS, APRIL 27, 1989, THE DOUGLAS MICHEL NASTRAN 
C     ACHIEVEMENT AWARD 1989, AN ANNUAL EVENT SPONSORED BY COSMIC AND   
C     NASA, WAS GIVEN TO ELIZABETH H. CUTHILL, JAMES M. McKEE AND GORDON
C     C. EVERSTINE FOR THEIR TEAMWORK THAT CREATED BANDIT, A COMPUTER   
C     PROGRAM THAT MINIMIZES THE BANDWIDTHS OF NASTRAN MATRICES. THE    
C     WIDOW OF DR. McKEE AND HIS FAMILY RECEIVED THE AWARD FOR HIM.     
C     DRS. CUTHILL AND EVERSTINE RECEIVED THEIR AWARDS PERSONALLY.      
C        
C     THE PRINCIPAL INPUTS ARE THE CONNECTIVITY MATRIX IG AND THE NUMBER
C     OF GRID POINTS (NODES) NN.        
C        
C     INPUT   - NT,NUM,NOM,IO,IP,IG,NN,MAXGRD,ILD        
C     OUTPUT  - NEW,ILD,MM,IH0,IHE,KORIG,KNEW,NCM        
C     SCRATCH - IC,IDEG,IDIS,IW,ICC,IPP        
C        
C     SET FOLLOWING DIMENSIONS IN CALLING PROGRAM -        
C     IG(II1,M),IC(L),IDEG(L),IDIS(L),IW(L),NEW(L),ICC(L),ILD(L),IP(M)  
C        
C     L     = HAS THE DIMENSION OF MAXGRD        
C             (NEW) MAXGRD EXCEEDS NUMBER OF GRID POINTS        
C     II1   = MAXGRD/(PACKING DENSITY IN INTEGERS/WORD)        
C           = ROW DIMENSION OF IG        
C     M     = MAX NODAL DEGREE DIVIDED BY INTEGER PACKING FACTOR        
C             (NEW) EXCEEDS MAX NODAL DEGREE        
C     NT    = MAX NUMBER OF STARTING NODES TO BE CONSIDERED (=80)       
C     NUM AND NOM GIVE THE FRACTION OF THE RANGE FROM MIN DEGREE TO MAX 
C             DEGREE TO CONSIDER FOR STARTING NODES (NUM=1, NOM=2)      
C     IO    = RE-SEQUENCING CRITERION , SET BY BANDIT -        
C           = 1, RMS WAVEFRONT        
C           = 2, BANDWIDTH        
C           = 3, PROFILE. (PROFILE IS BANDWIDTH SUM OF ALL ROWS)        
C           = 4, WAVEFRONT (MAX)        
C     IG(I,J) CONTAINS THE GRID POINT LABEL FOR THE JTH NODE ADJACENT   
C             TO NODE I  (THE CONNECTIVITY MATRIX).        
C             THE CONNECTION OF A NODE TO ITSELF IS NOT LISTED.        
C     NN    = NUMBER OF GRID POINTS (NODES)        
C     MM    = COLUMN DIMENSION OF IG ON INPUT,        
C             MAX NODAL DEGREE ON OUTPUT        
C     MAXGRD= EFFECTIVE IG ROW DIMENSION (NEGLECTING INTEGER PACKING)   
C     NEW(I)= OLD LABEL FOR GRID POINT NOW LABELLED I        
C     ILD(I)= NEW LABEL FOR GRID POINT ORIGINALLY LABELLED I        
C             ILD AND NEW ARE INVERSES        
C     ILD MUST BE INPUT TO CTHMCK TO INDICATE AN INITIAL SEQUENCE.      
C             NORMALLY, ON INPUT, SET ILD(I)=I FOR ALL I.        
C     JUMP  = 1 IF RESEQUENCING ATTEMPTS RESULT IN NO IMPROVEMENT       
C           = 0 OTHERWISE.        
C     IH0   = ORIG PROFILE        
C     IHE   = NEW PROFILE        
C     KORIG = ORIG BANDWIDTH        
C     KNEW  = NEW BW        
C     NCM   = NUMBER OF COMPONENTS        
C     NODESL IS SCRATCH SPACE.        
C        
C     IN CALLING PROGRAM, TRY  CALL CTHMCKL (80,1,2,2,1,...)        
C        
C     THE FOLLOWING SUBROUTINES WERE WRITTEN BY E. CUTHILL AND J. MCKEE 
C     OF NSRDC -        
C     DEGREE,DIAM,IDIST,KOMPNT,MAXBND,MAXDGR,MINDEG,RELABL,CTHMCK       
C     CTHMCK WAS MODIFIED BY G.C. EVERSTINE, DTRC, AND        
C        PUT INTO NASTRAN BY G.C. CHAN/UNISYS        
C        
      INTEGER         SUMW        
      REAL            IM1,     IM2        
      DIMENSION       IG(1),   IC(1),   IDEG(1),  IDIS(1),  IW(1),      
     1                NEW(1),  ICC(1),  ILD(1),   IPP(1),   UN(1),      
     2                NODESL(1)        
      CHARACTER       UFM*23,  UWM*25,  UIM*29        
      COMMON /XMSSG / UFM,     UWM,     UIM        
      COMMON /BANDA / IBUF1,   NOMPC,   NODEP,    NOPCH,    NORUN,      
     1                METHOD,  ICRIT        
      COMMON /BANDB / DUM3B(3),NGRID,   DUMB2(2), KDIM        
      COMMON /BANDD / KORIG,   KNEW,    IH0,      IHE,      NCM        
      COMMON /BANDS / NN,      MM,      IH,       IB,       MAXGRD      
      COMMON /BANDW / MAXW0,   RMS0,    MAXW1,    RMS1,     I77,        
     1                BRMS0,   BRMS1        
      COMMON /SYSTEM/ ISYS,    NOUT,    DUM6Y(6), NLPP        
C        
C     SET UP SCRATCH SPACE NODESL.        
C        
      IDEM  = KDIM        
      K2    = IDEM + 1        
      IAJDIM= 3*IDEM        
C        
C     DETERMINE THE DEGREE OF EACH NODE, THE NUMBER OF COMPONENTS, NCM, 
C     AND THE MAXIMUM DEGREE OF ANY NODE.        
C        
      CALL DEGREE (IG,IDEG,UN)        
      NCM  = KOMPNT(IG,IC,IDEG,IW,ICC,UN)        
      MAXD = MAXDGR(0,IC,IDEG)        
      MMC  = MAXD        
C        
C     INITIALIZE NEW ARRAY FROM THE ILD ARRAY.        
C     ILD MUST BE INPUT TO CUTHILL.        
C        
      DO 10 I = 1,NN        
      K = ILD(I)        
   10 NEW(K) = I        
C        
C     COMPUTE ORIGINAL BANDWIDTH, PROFILE, WAVEFRONT AND ACTIVE COLUMN  
C     IH0 = ORIGINAL PROFILE,  IS = ORIGINAL BW        
C        
      CALL WAVEY (IG,ILD,NEW,0,IC,IW,IS,MAXW,AVERW,SUMW,RMS,BRMS,UN)    
      IH    = SUMW        
      MAXW0 = MAXW        
      RMS0  = RMS        
      BRMS0 = BRMS        
      KORIG = IS        
      IH0   = IH        
      CALL PAGE1        
      I = METHOD + 2        
      WRITE  (NOUT,20) UIM,ICRIT,I,NOMPC,NODEP,NOPCH        
   20 FORMAT (A29,'S FROM RESEQUENCING PROCESSOR - BANDIT     (CRI=',I2,
     1       ',  MTH=',I2,',  MPC=',I2,',  DEP=',I2,',  PCH=',I2,')',/) 
      IF (NLPP .LE. 50) GO TO 50        
      WRITE  (NOUT,30)        
   30 FORMAT (31X,'BEFORE RESEQUENCING - - -')        
      WRITE  (NOUT,40) IS,IH,MAXW,AVERW,RMS,BRMS        
   40 FORMAT (40X,'BANDWIDTH',I13,     /40X,'PROFILE',I15,        
     1       /40X,'MAX WAVEFRONT',I9,  /40X,'AVG WAVEFRONT',F9.3,       
     2       /40X,'RMS WAVEFRONT',F9.3,/40X,'RMS BANDWIDTH',F9.3)       
C        
C     COMPUTE NODAL DEGREE STATISTICS.        
C        
   50 CALL DIST (IDEG,IPP,MEDIAN,MODD)        
      IF (METHOD .EQ. +1) RETURN        
C        
C     INITIALIZE ILD AND NEW ARRAYS.        
C        
      JUMP  = 0        
      DO 70 I = 1,NN        
      NEW(I) = 0        
   70 ILD(I) = 0        
C        
C     GENERATE NUMBERING SCHEME FOR EACH COMPONENT, NC.        
C        
      DO 310 NC = 1,NCM        
C        
C     DETERMINE THE RANGE OF DEGREES (MI TO MAD) OF NODES OF INTEREST.  
C     MAKE SURE MAD DOES NOT EXCEED MEDIAN        
C        
      MI  = MINDEG(NC,IC,IDEG)        
      MAD = MI        
      IF (NOM .EQ. 0) GO TO 80        
      MA  = MAXDGR(NC,IC,IDEG)        
      MAD = MI + ((MA-MI)*NUM)/NOM        
      MAD = MIN0(MAD,MEDIAN-1)        
      MAD = MAX0(MAD,MI)        
C        
C     DETERMINE BANDWIDTH OR SUM CRITERION FOR EACH NODE MEETING        
C     SPECIFIED CONDITION.        
C        
   80 CALL DIAM (NC,MAD,NL,NODESL,IDEM,MAXLEV,IG,IC,IDEG,IDIS,IW,ICC,UN)
      JMAX = MIN0(NT,NL)        
      JMAX = MAX0(JMAX,1)        
      IM1  = 1.E+8        
      IM2  = IM1        
C        
C     CHECK SEQUENCE FOR EACH STARTING NODE SELECTED, AND        
C     COMPUTE NEW BANDWIDTH,PROFILE,WAVEFRONT DATA.        
C     IB = BANDWIDTH, IH = PROFILE.        
C        
      DO 300 J = 1,JMAX        
      CALL RELABL (1,NODESL(J),IG,IC,IDEG,IDIS,IW,NEW,ICC,ILD,        
     1             NODESL(K2),UN,IAJDIM)        
      CALL WAVEY (IG,ILD,NEW,NC,IC,IW,IB,MAXW,AVERW,SUMW,RMS,BRMS,UN)   
      IF (NGRID .EQ. -1) RETURN        
C        
      IH = SUMW        
      GO TO (220,230,240,250), IO        
  220 CRIT1 = RMS        
      CRIT2 = IH        
      GO TO 260        
  230 CRIT1 = IB        
      CRIT2 = IH        
      GO TO 260        
  240 CRIT1 = IH        
      CRIT2 = IB        
      GO TO 260        
  250 CRIT1 = MAXW        
      CRIT2 = RMS        
  260 IF (IM1-CRIT1) 300,280,270        
  270 IM1 = CRIT1        
      IM2 = CRIT2        
      IJ  = J        
      GO TO 300        
  280 IF (IM2 .LE. CRIT2) GO TO 300        
      IM2 = CRIT2        
      IJ  = J        
C        
  300 CONTINUE        
C        
C     RECOMPUTE SEQUENCE FOR STARTING NODE WHICH IS BEST FOR CRITERION  
C     SELECTED.        
C        
      CALL RELABL (1,NODESL(IJ),IG,IC,IDEG,IDIS,IW,NEW,ICC,ILD,        
     1             NODESL(K2),UN,IAJDIM)        
      IF (NGRID .EQ. -1) RETURN        
C        
  310 CONTINUE        
C        
C     DETERMINE NODES OF ZERO DEGREE AND STACK LAST, AND        
C     COMPUTE BANDWIDTH, PROFILE AND WAVEFRONT DATA.        
C        
      CALL STACK (IDEG,NEW,ILD,IW)        
      CALL WAVEY (IG,ILD,NEW,0,IC,IW,IB,MAXW,AVERW,SUMW,RMS,BRMS,UN)    
      IH = SUMW        
C        
      IF (NLPP .LE. 50) GO TO 350        
      WRITE  (NOUT,320)        
  320 FORMAT (/31X,'AFTER RESEQUENCING BY REVERSE CUTHILL-MCKEE (CM)',  
     1        ' ALGORITHM - - -')        
      WRITE (NOUT,40) IB,IH,MAXW,AVERW,RMS,BRMS        
C        
C     CHECK CM LABELING AGAINST ORIGINAL LABELING TO SEE IF BETTER.     
C     IB = BANDWIDTH,  IH = PROFILE.        
C        
  350 GO TO (400,410,420,430), IO        
  400 IM1   = RMS0        
      IM2   = IH0        
      CRIT1 = RMS        
      CRIT2 = IH        
      GO TO 440        
  410 IM1   = IS        
      IM2   = IH0        
      CRIT1 = IB        
      CRIT2 = IH        
      GO TO 440        
  420 IM1   = IH0        
      IM2   = IS        
      CRIT1 = IH        
      CRIT2 = IB        
      GO TO 440        
  430 IM1   = MAXW0        
      IM2   = RMS0        
      CRIT1 = MAXW        
      CRIT2 = RMS        
  440 IF (CRIT1-IM1) 480,450,460        
  450 IF (CRIT2 .LT. IM2) GO TO 480        
C        
C     IF NO IMPROVEMENT RETURN TO ORIGINAL SEQUENCE.        
C        
  460 IB   = IS        
      IH   = IH0        
      MAXW = MAXW0        
      RMS  = RMS0        
      BRMS = BRMS0        
      DO 470 I = 1,NN        
      ILD(I) = I        
  470 NEW(I) = I        
      JUMP = 1        
C        
C     SET FINAL VALUES OF B, P, RMS, W.        
C        
  480 KNEW = IB        
      IHE  = IH        
      MAXW1= MAXW        
      RMS1 = RMS        
      BRMS1= BRMS        
      RETURN        
      END        
