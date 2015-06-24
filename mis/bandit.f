      SUBROUTINE BANDIT        
C        
C     BANDIT - A COMPUTER PROGRAM TO RE-SEQUENCE MATRIX BY BANDWIDTH,   
C              PROFILE, AND WAVEFRONT METHODS FOR NASTRAN.        
C        
C     THIS PROGRAM GENERATES THE RE-SEQUENCE CARDS, SEQGP (AFTER GEOM1, 
C     GEOM2, AND GEOM4 DATA BLOCKS ARE ASSEMBLED), AND ADD THESE CARDS  
C     TO THE END OF GEOM1 FILE.        
C        
C     HOWEVER, IF THE ORIGINAL NASTRAN INPUT DECK CONTAINS ONE OR MORE  
C     SEQGP CARD, BANDIT WILL BE AUTOMATICALLY SKIPPED.        
C        
C     ******************************************************************
C        
C     ACKNOWLEDGEMENT:        
C        
C     THE ORIGINAL BANDIT PROGRAM (VERSION 9, DEC. 1978, DISTRIBUTED BY 
C     COSMIC  NO. DOD-0034) WAS WRITTEN BY G. C. EVERTINE OF NAVAL SHIP 
C     RESEARCH AND DEVELOPMENT CENTER (NSRDC), BETHESDA, MD.        
C        
C     THE FOLLOWING SUBROUTINES WERE WRITTEN BY E. CUTHILL AND J. MCKEE 
C     OF NSRDC        
C     - CTHMCK,DEGREE,DIAM,IDIST,KOMPNT,MAXDGR,MINDEG,RELABL        
C        
C     THE FOLLOWING SUBROUTINES WERE WRITTEN BY N. GIBBS, W. POOLE,     
C     P. STOCKMEYER, AND H. CRANE OF THE COLLEGE OF WILLIAM AND MARY    
C     - DGREE,FNDIAM,GIBSTK,NUMBER,PIKLVL,RSETUP,SORTDG,SORT2,TREE.     
C     (THESE ROUTINES AND CTHMCK WERE MODIFIED BY G. C. EVERSTINE.)     
C        
C     ******************************************************************
C        
C     ONLY HALF OF THE ORIGINAL BANDIT PROGRAM WAS ADOPTED IN THIS      
C     NASTRAN VERSION BY G. C. CHAN OF SPERRY, HUNTSVILLE, AL., 1982    
C        
C     THE ORIGINAL BANDIT ROUTINES WERE UPDATED TO MEET NASTRAN        
C     PROGRAMMING STYLE AND STANDARD.        
C     NASTRAN GINO FILES AND GINO I/O ARE USED INSTEAD OF FORTRAN FILES 
C     AND FORTRAN READ/WRITE        
C     THE INTEGER PACK AND UNPACK ROUTINES, BPACK AND BUNPK, WERE RE-   
C     WRITTEN TO ALLOW COMMON USAGE FOR IBM, CDC, UNIVAC AND VAX MACH.  
C        
C     ROUTINES BANDIT, SCHEME, BREAD, BGRID, BSEQGP, AND TIGER WERE     
C     COMPLETELY RE-WRITTEN.        
C     (SCHEME WAS FORMALLY CALLED NASNUM, AND CTHMCK WAS SCHEME)        
C        
C     ******************************************************************
C        
C     THIS NASTRAN VERSION DOES NOT USE $-OPTION CARDS AS IN THE CASE OF
C     ORIGINAL BANDIT PROGRAM.        
C        
C     THE FOLLOWING 'OPTIONS' ARE PRE-SELECTED -        
C        
C        $ADD        (NOT USE)            $INSERT     (NOT USE)        
C        $APPEND     (NOT USE)            $METHOD     (GPS    )        
C        $CONFIG     (NOT USE)            $MPC        (NO     )        
C        $CRITERION  (RMS    )            $NASTRAN    (NOT USE)        
C        $DEGREE     (NOT USE)            $PLUS       (NOT USE)        
C        $DIMENSION  (NOT USE)            $PRINT      (MIN    )        
C        $ELEMENTS   (NOT USE)            $PUNCH      (NONE   )        
C        $FRONTAL    (NOT USE)            $SEQUENCE   (YES    )        
C        $GRID       (NOT USE)            $SPRING     (NO     )        
C        $HICORE     (NOT USE)            $TABLE      (NO     )        
C        $IGNORE     (NOT USE)            $START      (NOT USE)        
C        
C     ******************************************************************
C        
      INTEGER          HICORE,   GEOM1,    GEOM2,    GEOM4,    SCR1,    
     1                 Z,        SUB(3),   END,        
     2                 RD,       RDREW,    WRT,      WRTREW,   REW      
C        
      COMMON /MACHIN/  MACHIN        
      COMMON /BANDA /  IBUF1,    NOMPC,    NODEP,    NOPCH,    NORUN,   
     1                 METHOD,   ICRIT,    NGPTS(2)        
      COMMON /BANDB /  NBITIN,   KORE,     IFL,      NGRID,    IPASS,   
     1                 NW,       KDIM,     NBPW,     IREPT        
      COMMON /BANDD /  KORIG,    KNEW,     IOP,      INP,      NCM,     
     1                 NZERO,    NEL,      NEQ,      NEQR        
      COMMON /BANDG /  DUM3G(3)        
      COMMON /BANDS /  NN,       MM,       IH,       IB,       MAXGRD,  
     1                 MAXDEG,   KMOD,     MACH,     MINDEG,   NEDGE,   
     2                 MASK        
      COMMON /BANDW /  DUM4W(4), I77,      DUM2W(2)        
      COMMON /SYSTEM/  IBUF,     NOUT,     NOGO,     IS(97)        
      COMMON /GEOMX /  GEOM1,    GEOM2,    GEOM4,    SCR1        
      COMMON /NAMES /  RD,       RDREW,    WRT,      WRTREW,   REW      
CZZ   COMMON /ZZBAND/  Z(1)        
      COMMON /ZZZZZZ/  Z(1)        
C        
      EQUIVALENCE      (HICORE,IS(28))        
C     DATA             GEOM1,    GEOM2,    GEOM4,    SCR1    /        
C                      201,      208,      210,      301     /        
C                      K65,      KDIM,     NZERO,    I77     /        
C                      65535,    1,        0,        77      /        
C                      NEL,      NEQ,      NEQR /    3*0     /        
      DATA             SUB  /    4HBAND,   4HIT  ,   4HBEGN  /        
      DATA             END,      IQUIT /   4HEND ,   4HQUIT  /        
C        
C     INITIALIZE PROGRAM PARAMETERS        
C        
C     NOMPC =  0, MPC'S AND RIGID ELEM. ARE NOT USED IN BANDIT COMPUTATI
C           = +1, ONLY RIGID ELEMENTS ARE USED IN BANDIT RESEQUENCING   
C           = +2, BOTH MPC'S  AND RIGID ELEM. ARE USED IN BANDIT        
C           = +3, ONLY MPC'S, NOT RIGID ELEM. ARE USED IN BANDIT        
C     NODEP = +1, MPC DEPENDENT PTS. ARE TO BE REMOVED FROM COMPUTATION 
C           = -1, MPC DEPENDENT PTS. ARE NOT TO BE REMOVED.        
C                 (NOTE - NODEP DICTATES ALSO THE DEPENDENT GRIDS OF    
C                         THE RIGID ELEMENTS)        
C     NOPCH = +1, PUNCH OUT SEQGP CARDS        
C           = -1, NO SEQGP CARDS PUNCHED        
C     NORUN = +1, BANDIT WILL RUN EVEN SEQGP CARDS ARE PRESENT        
C           = -1, BANDIT IS SKIPPED IF ONE OR MORE SEQGP CARD IS        
C                 PRESENT IN  THE INPUT DECK        
C     METHOD= -1, CM METHOD ONLY        
C           =  0, BOTHE CM AND GPS METHODS ARE USED        
C           = +1, USE GPS METHOD ONLY        
C     ICRIT =     RE-SEQUENCING CRITERION        
C           =  1, RMS WAVEFRONT        
C           =  2, BANDWIDTH        
C           =  3, PROFILE        
C           =  4, MAX WAVEFRONT        
C        
      NZERO = 0        
      I77   = 77        
C     K65   = 65535        
      NOMPC = 0        
      NODEP =-1        
      NOPCH =-1        
      NORUN =-1        
      METHOD=+1        
      KDIM  = 1        
      ICRIT = 1        
      IREPT = 0        
C        
C     THE ABOVE DEFAULT VALUES CAN BE RESET BY THE NASTRAN CARD.        
C     (SEE SUBROUTINE NASCAR BANDIT FLAG FOR MORE DETAILS)        
C     ******************************************************************
C        
      CALL CONMSG (SUB,3,0)        
      NBPW = IS(37)        
      MACH = MACHIN        
C     IF (MACH.EQ.3 .AND. HICORE.GT.K65) CALL XCORSZ (Z(1),HICORE)      
      KORE = KORSZ(Z(1))        
C     IFL  = KORE        
      IBUF1= KORE - IBUF - 2        
      KORE = IBUF1 - 1        
C        
C     CALL BGRID TO GET THE NO. OF GRID POINTS IN THE PROBLEM, SET      
C     THE INTEGER PACKING CONSTANT, NW, AND COMPUTE MAXGRD AND MAXDEG.  
C     BANDIT QUITS IF PROBLEM IS TOO SMALL TO BE WORTHWHILE.        
C        
    5 IREPT = IREPT + 1        
      CALL BGRID        
      IF (NGRID .LT. 15) GO TO 30        
      KDIM4 = KDIM*4        
      II3   = 2*MAXGRD        
C        
C     PARTITION OPEN CORE FOR SCHEME COMPUTATION.        
C        
      K2 =  1 + KDIM4        
      K3 = K2 + 2*II3  + 2        
      IF (METHOD.LE.0 .AND. MAXDEG.GT.MAXGRD) K3 = K3 + MAXDEG - MAXGRD 
      K4 = K3 + MAXGRD + 1        
      K5 = K4 + MAXGRD        
      K6 = K5 + MAXGRD + 1        
      K7 = K6 + MAXGRD        
      K8 = K7 + MAXDEG        
      K1 = K8 + MAXDEG + NW        
      K9 = K1 + MAXGRD*MAXDEG/NW        
      IF (K9 .GT. KORE) CALL MESAGE (-8,K9-KORE,SUB)        
C        
C     READ BULK DATA, SET UP CONNECTION TABLE, AND RESEQUENCE NODES.    
C        
      CALL SCHEME(Z(K1),Z(K2),II3,Z(K3),Z(K4),Z(K5),Z(K6),Z(K7),Z(K8),Z)
      IF (NGRID .EQ. -1) CALL SPTCHK        
      IF (IREPT .EQ.  2) GO TO 5        
      IF (NGRID) 20,30,10        
C        
C     JOB DONE.        
C        
   10 SUB(3) = END        
      GO TO 40        
C        
C     NO BANDIT RUN.        
C        
   20 NOGO = 1        
   30 SUB(3) = IQUIT        
   40 CALL CONMSG (SUB,3,0)        
      RETURN        
      END        
