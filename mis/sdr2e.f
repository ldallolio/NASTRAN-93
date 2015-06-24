      SUBROUTINE SDR2E (*,IEQEX,NEQEX)        
C        
C     THIS ROUTINE WHICH IS CALLED ONLY FROM SDR2D WILL PROCESS THE ESTA
C     FILE ONCE AND OUTPUT FORCE AND OR STRESS RESULTS ON OEF1 AND OR   
C     OES1 WHICH ARE OPENED IN SDR2D.        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        ANDF        
      LOGICAL         EORFLG,ENDID ,RECORD,ACSTIC,AXIC  ,AGAIN ,IDSTRS, 
     1                IDFORC,EOFCC ,IDLYST,IDLYFR,OK2WRT,HEAT  ,DDRMM , 
     2                STRAIN,ILOGIC(4)        
      INTEGER         BUF(50)      ,PLATIT(12)   ,COMPLX(478)  ,        
     1                ISAVEF(75)   ,ISAVES(75)        
      REAL            ZZ(1) ,BUFR(1)      ,TGRID(33)    ,DIFF1 ,DIFF  , 
     1                DEFORM,FRTMEI,TEMP  ,TWOTOP,FNCHK        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM   ,UWM   ,UIM   ,SFM        
      COMMON /LHPWX / LH(6) ,MTISA        
      COMMON /BLANK / APP(2),SORT2 ,ISTRN ,IDUM1 ,COMPS ,IDUM4(4)     , 
     1                STRAIN        
      COMMON /SDR2C1/ IPCMP ,NPCMP ,IPCMP1,NPCMP1,IPCMP2,NPCMP2,NSTROP  
      COMMON /SDR2X1/ IEIGEN,IELDEF,ITLOAD,ISYMFL,ILOADS,IDISPL,ISTR  , 
     1                IELF  ,IACC  ,IVEL  ,ISPCF ,ITTL  ,ILSYM ,IFROUT, 
     2                ISLOAD,IDLOAD,ISORC        
      COMMON /SDR2X2/ CASECC,CSTM  ,MPT   ,DIT   ,EQEXIN,SIL   ,GPTT  , 
     1                EDT   ,BGPDT ,PG    ,QG    ,UGV   ,EST   ,PHIG  , 
     2                EIGR  ,OPG1  ,OQG1  ,OUGV1 ,OES1  ,OEF1  ,PUGV1 , 
     3                OEIGR ,OPHIG ,PPHIG ,ESTA  ,GPTTA ,HARMS ,IDUM3(3)
     4,               OES1L ,OEF1L        
      COMMON /GPTA1 / NELEM ,LAST  ,INCR  ,ELEM(1)        
      COMMON /SDR2X4/ NAM(2),END   ,MSET  ,ICB(7),OCB(7),MCB(7),DTYPE(8)
     1,               ICSTM ,NCSTM ,IVEC  ,IVECN ,TEMP  ,DEFORM,FILE  , 
     2                BUF1  ,BUF2  ,BUF3  ,BUF4  ,BUF5  ,ANY   ,ALL   , 
     3                TLOADS,ELDEF ,SYMFLG,BRANCH,KTYPE ,LOADS ,SPCF  , 
     4                DISPL ,VEL   ,ACC   ,STRESS,FORCE ,KWDEST,KWDEDT, 
     5                KWDGPT,KWDCC ,NRIGDS,STA(2),REI(2),DS0(2),DS1(2), 
     6                FRQ(2),TRN(2),BK0(2),BK1(2),CEI(2),PLA(22)      , 
     7                NRINGS,NHARMS,AXIC  ,KNSET ,ISOPL ,STRSPT,DDRMM   
      COMMON /SDR2X7/ ELESTA(100)  ,BUFA(100)    ,BUFB(4076)        
      COMMON /SDR2X8/ ELWORK(300)        
      COMMON /SDR2X9/ NCHK  ,ISUB  ,ILD   ,FRTMEI(2)    ,TWOTOP,FNCHK   
CZZ   COMMON /ZZSDR2/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /ISAVE / ISAVEF,ISAVES        
      COMMON /NAMES / RD    ,RDREW ,WRT   ,WRTREW,CLSREW        
      COMMON /CLSTRS/ COMPLX        
      COMMON /SYSTEM /KSYSTM(100)        
      COMMON /SDR2DE/ BUF6  ,COEF  ,DEFTMP,DIFF  ,DIFF1 ,DEVICE,ESTAWD, 
     1                ELEMID,ELTYPE,EOF   ,EOFCC ,IREQX ,FLAG  ,FN    , 
     2                FORCEX,FSETNO,FORMT ,ICC   ,I     ,IEDT  ,ISETNO, 
     3                ISETF ,ISETS ,IDEF  ,ISYMN ,SDEST ,IX    ,ISETNF, 
     4                ISEQ  ,IRETRN,IRECX ,ISAVE ,FDEST ,IPART ,ILIST , 
     5                IGPTTA,ICORE ,IELEM ,IESTA ,BUF8  ,JFORC ,JSTRS , 
     6                JANY  ,JLIST ,J     ,KTYPE1,KHI   ,KX    ,K     , 
     7                KLO   ,KN    ,KTYPEX,KFRQ  ,KCOUNT,LSYM  ,M     , 
     8                MIDVEC,NWDSA ,NWDSTR,NLOGIC,NWDS  ,NDEF  ,N     , 
     9                N1    ,N2    ,NOTSET,NSETS ,NSETF ,NWORDS,NX    , 
     O                TDUMM(4)     ,NWDFOR,NGPTT ,NESTA ,NVECTS,NLIST , 
     A                OFILE ,OUTFL ,RETX  ,SETNO ,STRESX,SAVE  ,TLOAD , 
     B                UGVVEC,IXSETS,NXSETS,IXSETF,NXSETF,XSETNS,XSETNF, 
     C                SORC  ,TMPREC,BUF7  ,TGRID        
      COMMON /SDRETT/ IELTYP,OLDEL ,EORFLG,ENDID ,BUFFLG,ITEMP ,XX2(2), 
     1                RECORD,OLDEID        
      EQUIVALENCE     (KSYSTM( 2),OPTE  ) ,(KSYSTM(55),IPREC  ),        
     1                (KSYSTM(56),ITHERM)        
      EQUIVALENCE     (BUF(1),BUFR(1)   ) ,(Z(1)  ,ZZ(1)      ),        
     1                (IDSTRS,ILOGIC(1) ) ,(IDFORC,ILOGIC(2)  ),        
     2                (IDLYST,ILOGIC(3) ) ,(IDLYFR,ILOGIC(4)  ),        
     3                (TEMP  ,JTEMP     ) ,(NELHAR,ELWORK(155))        
      DATA PLATIT / 4HLOAD,4H FAC,4HTOR , 9*0    /        
      DATA BUF    / 50*0 /, IELOLD / 0 /, IELCHK / 0 /        
C        
C     INITIALIZE ESTA POINTERS.        
C        
      IF (STRESX.EQ.0 .AND. FORCEX.EQ.0) RETURN        
      HEAT   = .FALSE.        
      IF (ITHERM .NE. 0) HEAT = .TRUE.        
      ESTAWD = IESTA        
      ISTORE = 0        
      IX     = ICC + HARMS        
      AGAIN  =.FALSE.        
      OHARMS = Z(IX)        
      IF (OHARMS .LT. 0) OHARMS = NHARMS        
      ISAVE  = IVEC        
      ISVSRC = SORC        
      ELTYPE = Z(ESTAWD)        
      FILE   = ESTA        
      IX     = ICC + ISTR + 2        
      SPHASE = IABS(Z(IX))        
      IX     = ICC + IELF + 2        
      FPHASE = IABS(Z(IX))        
C     TWOTOP = 5.0        
C     I      = 2*MACHX - 1        
C     IF (I.GE.3 .AND. I.LE.38) TWO TO P = ALOG10(2.0**NMANT(I))        
      TWO TO P = ALOG10(2.0**MTISA)        
C        
C     POSITION TO THE PROPER THERMAL RECORD IF NECESSARY.        
C        
      RECORD = .FALSE.        
      IF (TLOADS .EQ. 0) GO TO 18        
      IF (TMPREC .EQ. 0) GO TO 18        
      CALL REWIND (GPTT)        
      FILE = GPTT        
      DO 15 I = 1,TMPREC        
      CALL FWDREC (*980,GPTT)        
   15 CONTINUE        
C        
C     READ AND VERIFY SET-ID  (FAILSAFE)        
C        
      CALL READ (*980,*990,GPTT,ISETID,1,0,FLAG)        
      IF (TLOADS .EQ. ISETID) GO TO 17        
      WRITE  (OPTE,16) SFM,TLOADS,ISETID        
   16 FORMAT (A25,' 4019, SDR2E DETECTS INVALID TEMPERATURE DATA FOR ', 
     1       'TEMPERATURE LOAD SET',2I10)        
      CALL MESAGE (-61,0,0)        
   17 RECORD = .TRUE.        
C        
C     INITIALIZE /SDRETT/ VARIABLES        
C        
      OLDEID = 0        
      OLDEL  = 0        
      EORFLG = .FALSE.        
      ENDID  = .TRUE.        
   18 ITEMP  = TLOADS        
      IF (NESTA .NE. 0) GO TO 25        
      CALL REWIND (ESTA)        
   20 CALL READ (*950,*990,ESTA,ELTYPE,1,0,FLAG)        
C        
C     ELEMENT PARAMETERS FOR NEW ELEMENT TYPE        
C        
   25 IELEM  = (ELTYPE-1)*INCR        
      IELTYP = ELTYPE        
      IPR    = IPREC        
      IF (IPR .NE. 1) IPR = 0        
      JLTYPE = 2*ELTYPE - IPR        
      JCORE  = ICORE        
      IF (HEAT .AND. ELTYPE.NE.82) GO TO 27        
C                            FTUBE        
      NWDSA  = ELEM(IELEM+17)        
      NPTSTR = ELEM(IELEM+20)        
      NPTFOR = ELEM(IELEM+21)        
      NWDSTR = ELEM(IELEM+18)        
      NWDFOR = ELEM(IELEM+19)        
      GO TO 28        
C        
   27 NWDFOR = 9        
      NWDSTR = 0        
      NPTFOR = 0        
      NPTSTR = 0        
      NWDSA  = 142        
C        
C     CHOP OFF 483 WORDS FROM OPEN CORE SPACE FOR CIHEX ELEMENTS        
C        
      IF (ELTYPE.LT.65 .OR. ELTYPE.GT.67) GO TO 28        
      ICORE  = ICORE - 483        
C        
   28 CONTINUE        
C        
C     SETUP STRESS PRECISION CHECK.        
C        
      NCHK  = Z(ICC+146)        
      FNCHK = NCHK        
C        
C     SUBCASE ID        
C        
      ISUB  = Z(ICC+1)        
C        
C     DETERMINE LOAD/MODE, EIGENVALUE/FREQ/TIME HEADER        
C        
      FRTMEI(1) = 0.        
      FRTMEI(2) = 0.        
      IF (BRANCH.EQ.5 .OR. BRANCH.EQ.6)  GO TO 31        
      IF (BRANCH.EQ.2 .OR. BRANCH.EQ.8 .OR. BRANCH.EQ.9) GO TO 32       
C        
C     STATICS        
C        
      I   = ICC + ISLOAD        
      ILD = Z(I)        
      GO TO 35        
C        
C     FREQUENCY/TRANSIENT        
C        
   31 I   = ICC + IDLOAD        
      ILD = Z(I)        
      FRTMEI(1) = ZZ(JLIST)        
      GO TO 35        
C        
C     EIGENVALUES        
C        
   32 ILD       =  Z(JLIST  )        
      FRTMEI(1) = ZZ(JLIST+1)        
      FRTMEI(2) = ZZ(JLIST+2)        
      IF (BRANCH .NE. 2) GO TO 35        
      IF (ZZ(JLIST+1) .GT. 0.) FRTMEI(1) = SQRT(ZZ(JLIST+1))/6.2831852  
   35 CONTINUE        
      LSTRES = NWDSTR        
      LFORCE = NWDFOR        
      IDSTRS = .FALSE.        
      IDFORC = .FALSE.        
      IDLYST = .FALSE.        
      IDLYFR = .FALSE.        
      OK2WRT = .TRUE.        
      IF (KTYPE.NE.1 .AND. NPTSTR.EQ.0 .AND. NPTFOR.EQ.0) GO TO 40      
      IF (NWDSTR+NWDFOR .GT. 0) GO TO 70        
C        
C     NO STRESS OR FORCE WORDS POSSIBLE FOR THIS ELEMENT TYPE IF FALL   
C     HERE        
C        
   40 IF (NESTA) 60,50,60        
C        
C     FORWARD REC ON FILE TO NEXT ELEMENT TYPE        
C        
   50 CALL FWDREC (*980,ESTA)        
      GO TO 20        
C        
C     FIND END OF CURRENT ELEMEMT TYPE LIST IN CORE        
C        
   60 ESTAWD = ESTAWD + NWDSA        
      IF (Z(ESTAWD+1)) 60,940,60        
C        
C     OK SOME STRESS AND OR FORCE REQUESTS EXIST FOR THIS ELEMENT TYPE. 
C     PROCESS INDIVIDUAL ELEMENTS REQUESTED        
C        
   70 IF (NESTA .NE.     0) GO TO 90        
      IF (NWDSA .LE. ICORE) GO TO 80        
      CALL MESAGE (8,0,NAM(1))        
C        
C        
C     INSUFFICIENT CORE TO HOLD ESTA FOR 1 ELEMENT OF CURRENT ELEMENT   
C     TYPE TRY PROCESSING THE OTHER ELEMENT TYPES IN AVAILABLE CORE.    
C        
      GO TO 50        
C        
   80 CALL READ (*980,*910,ESTA,Z(IESTA),NWDSA,0,FLAG)        
      ESTAWD = IESTA - 1        
C        
C     DETERMINE IF THIS PARTICULAR ELEMENT OF THE CURRENT ELEMENT TYPE  
C     HAS A STRESS OR FORCE REQUEST IN THE CURRENT CASE CONTROL RECORD. 
C        
   90 ELEMID = Z(ESTAWD+1)        
C        
C     THE FOLLOWING CODE (THRU 93) IS FOR THE COMPLEX ANALYSIS OF IHEX  
C     ELEMENTS ONLY (ELEM. TYPES 65,66,67)        
C        
      IF (KTYPE.NE.2 .OR. ELTYPE.LT.65 .OR. ELTYPE.GT.67) GO TO 93      
      IF (IPART.NE.2 .OR. ISTRPT.NE.(NIP3+NGP1+1)) GO TO 91        
C        
C     DONE FOR THIS IHEX ELEMENT, RESET CHECKING VARIABLES        
C        
      IPART  = 0        
      IELOLD = 0        
      IELCHK = 0        
      GO TO 93        
C        
C     FIRST INTEGRATION POINT FOR IMAGINARY RETULS FOR THIS IHEX ELEMENT
C     SAVE ELEMENT ID AND CURRENT ESTAWD        
C        
   91 IF (IPART.NE.1 .OR. ISTRPT.NE.1) GO TO 92        
      IELOLD = ELEMID        
      OLDAWD = ESTAWD - NWDSA        
      GO TO 93        
C        
C     FIRST INTEGRATION POINT FOR REAL RESULTS FOR THIS IHEX ELEMENT,   
C     SAVE ELEMENT ID TO CHECK WITH EARLIER ELEMENT ID SAVED ABOVE      
C        
   92 IF (IPART.EQ.2 .AND. ISTRPT.EQ.1) IELCHK = ELEMID        
C        
C     END OF SPECIAL TREATMENT FOR IHEX ELEMENT        
C        
   93 IDELEM = ELEMID        
C        
C     DECODE ELEMID TO FIND IT IN SET        
C        
      IF (.NOT. AXIC) GO TO 95        
      NELHAR = ELEMID - (ELEMID/1000)*1000        
      ELEMID = ELEMID/1000        
   95 JSTRS  = 0        
      JFORC  = 0        
      I      = ISETS        
      IF (NWDSTR .EQ. 0) GO TO 140        
      IF (STRESX) 110,140,100        
  100 IF (I .EQ. NSETS) GO TO 120        
      IF (Z(I+1) .GT.0) GO TO 120        
      I = I + 1        
      IF (ELEMID.LT.Z(I-1) .OR. ELEMID.GT.-Z(I)) GO TO 130        
  110 JSTRS = 1        
      GO TO 140        
  120 IF (ELEMID .EQ. Z(I)) GO TO 110        
  130 I = I + 1        
      IF (I .LE. NSETS) GO TO 100        
  140 I = ISETF        
      IF (NWDFOR .EQ. 0) GO TO 190        
      IF (FORCEX) 160,190,150        
  150 IF (I .EQ. NSETF) GO TO 170        
      IF (Z(I+1) .GT.0) GO TO 170        
      I = I + 1        
      IF (ELEMID.LT.Z(I-1) .OR. ELEMID.GT.-Z(I)) GO TO 180        
  160 JFORC = 1        
      GO TO 190        
  170 IF (ELEMID .EQ. Z(I)) GO TO 160        
  180 I = I + 1        
      IF (I .LE. NSETF) GO TO 150        
  190 JANY= JSTRS + JFORC        
      IF (JANY .EQ. 0) IF (NESTA) 890,80,890        
C        
C     OK FALL HERE AND A STRESS OR FORCE REQUEST EXISTS        
C     IF THERMAL LOADING, GET THE ELEMENT THERMAL DATA.        
C     IF ELEMENT DEFORMATIONS, LOOK UP THE DEFORMATION        
C        
C        
C     ELEMENT TEMPERATURE        
C        
      IF (TLOADS .EQ. 0) GO TO 330        
      N = ELEM(IELEM+10)        
C        
C     IF NEW ELEMENTS ARE ADDED THAT HAVE SPECIAL BENDING THERMAL DATA  
C     POSSIBLE THEN THE FOLLOWING TEST SHOULD BE EXPANDED TO INCLUDE    
C     THEIR ELEMENT TYPE SO AS TO RECEIVE ZEROS AND ONLY THE AVERAGE    
C     TEMPERATURE RATHER THAN SIMULATED GRID POINT TEMPERATURES IN THE  
C     ABSENCE OF ANY USER SPECIFIED DATA.        
C        
      IF (IELTYP.EQ.34 .OR. IELTYP.EQ. 6 .OR. IELTYP.EQ.7  .OR.        
     1    IELTYP.EQ. 8 .OR. IELTYP.EQ.15 .OR. IELTYP.EQ.17 .OR.        
     2    IELTYP.EQ.18 .OR. IELTYP.EQ.19) N = 0        
      IF (IELTYP.EQ.74 .OR. IELTYP.EQ.75) N = 0        
      IF (IELTYP.EQ.64 .OR. IELTYP.EQ.83) N = 0        
C        
C     IF (IELTYP.NE.64 .AND. IELTYP.NE.83) GO TO 195        
C     N = 4        
C     DO 193 ITG = 1,7        
C     TGRID(ITG) = 0.0        
C 193 CONTINUE        
C 195 CONTINUE        
C        
      CALL SDRETD (IDELEM,TGRID,N)        
C        
C     SET THE AVERAGE ELEMENT TEMPERATURE CELL.        
C        
      TEMP = TGRID(1)        
      GO TO 340        
C        
C     NORMALLY TGRID(1) WILL CONTAIN THE AVERAGE ELEMENT TEMPERATUE     
C     AND IF GRID POINT TEMPERATURES ARE RETURNED THEY WILL BEGIN       
C     IN TGRID(2).        
C        
  330 JTEMP = -1        
C        
C     ELEMENT DEFORMATION        
C        
  340 DEFORM = 0.0        
      IF (ELDEF .EQ. 0) GO TO 360        
      DO 350 I = IDEF,NDEF,2        
      IF (Z(I) .EQ. ELEMID) GO TO 355        
  350 CONTINUE        
      GO TO 360        
  355 DEFORM = ZZ(I+1)        
C        
C     WRITE ID FOR STRESSES IF NOT YET WRITTEN FOR THIS ELEMENT TYPE.   
C        
  360 IF (STRESS.EQ.0 .OR.  NWDSTR.EQ.0 .OR. JSTRS.EQ.0) GO TO 365      
      IF (COMPS.EQ.-1 .AND. NSTROP.GT.1) GO TO 362        
      IF (IDSTRS) GO TO 365        
      NLOGIC = 1        
      OFILE  = OES1        
      DEVICE = SDEST        
      ISEQ   = 4        
      IFLTYP = DTYPE(ISEQ)        
      IRECX  = ICC + ISTR        
      NWDS   = NWDSTR        
      JCMPLX = NPTSTR        
      ASSIGN 365 TO IRETRN        
      GO TO 630        
C        
  362 IF (IDLYST) GO TO 365        
      NLOGIC = 3        
      OFILE  = OES1L        
      DEVICE = SDEST        
      IFLTYP = 22        
      IRECX  = ICC + ISTR        
      NWDS   = 10        
      JCMPLX = 0        
      OK2WRT = .FALSE.        
      ASSIGN 365 TO IRETRN        
      GO TO 630        
C        
C     WRITE ID FOR FORCES IF NOT YET WRITTEN FOR THIS ELEMENT TYPE.     
C        
  365 IF (FORCE.EQ. 0 .OR.  NWDFOR.EQ.0 .OR.  JFORC .EQ.0) GO TO 375    
      IF (COMPS.EQ.-1 .AND. NSTROP.GT.1 .AND. STRESS.NE.0) GO TO 367    
      IF (IDFORC) GO TO 375        
      NLOGIC = 2        
      OFILE  = OEF1        
      DEVICE = FDEST        
      ISEQ   = 5        
      IFLTYP = DTYPE(ISEQ)        
      IRECX  = ICC + IELF        
      NWDS   = NWDFOR        
      JCMPLX = NPTFOR        
      ASSIGN 375 TO IRETRN        
      GO TO 630        
C        
  367 IF (IDLYFR) GO TO 375        
      NLOGIC = 4        
      OFILE  = OEF1L        
      DEVICE = FDEST        
      IFLTYP = 23        
      IRECX  = ICC + IELF        
      NWDS   = 9        
      JCMPLX = 0        
      OK2WRT = .FALSE.        
      ASSIGN 375 TO IRETRN        
      GO TO 630        
C        
C     MOVE ESTA DATA INTO /SDR2X7/        
C        
  375 NSESTA = ESTAWD        
      IF (IELCHK.EQ.0 .OR. IPART.LT.2 .OR. IELCHK.NE.IELOLD) GO TO 377  
      IPART  = 1        
      GO TO 380        
  377 IPART  = 0        
  380 IPART  = IPART + 1        
      DO 390 I = 1,NWDSA        
      ESTAWD = ESTAWD + 1        
  390 ELESTA(I) = Z(ESTAWD)        
      ACSTIC = .FALSE.        
C        
C     CALL APPROPRIATE ELEMENT ROUTINE FOR STRESS AND FORCE COMPUTATIONS
C        
      IF (HEAT) GO TO 1680        
      LOCAL = JLTYPE - 100        
      IF (LOCAL) 394,394,395        
C        
C     PAIRED -GO TO- ENTRIES PER ELEMENT SINGLE/DOUBLE PRECISION        
C        
C             1 CROD      2 C.....    3 CTUBE     4 CSHEAR    5 CTWIST  
  394 GO TO( 400,  400,  610,  610,  400,  400,  420,  420,  430,  430  
C        
C             6 CTRIA1    7 CTRBSC    8 CTRPLT    9 CTRMEM   10 CONROD  
     1,      450,  450,  460,  460,  470,  470,  480,  480,  400,  400  
C        
C            11 ELAS1    12 ELAS2    13 ELAS3    14 ELAS4    15 CQDPLT  
     2,      490,  490,  490,  490,  490,  490,  490,  490,  500,  500  
C        
C            16 CQDMEM   17 CTRIA2   18 CQUAD2   19 CQUAD1   20 CDAMP1  
     3,      520,  520,  450,  450,  540,  540,  540,  540,  610,  610  
C        
C            21 CDAMP2   22 CDAMP3   23 CDAMP4   24 CVISC    25 CMASS1  
     4,      610,  610,  610,  610,  610,  610,  610,  610,  610,  610  
C        
C            26 CMASS2   27 CMASS3   28 CMASS4   29 CONM1    30 CONM2   
     5,      610,  610,  610,  610,  610,  610,  610,  610,  610,  610  
C        
C            31 PLOTEL   32 C.....   33 C.....   34 CBAR     35 CCONE   
     6,      610,  610,  610,  610,  610,  610,  560,  560,  570,  570  
C        
C            36 CTRIARG  37 CTRAPRG  38 CTORDRG  39 CTETRA   40 CWEDGE  
     7,      580,  580,  590,  590,  600,  600,  601,  601,  602,  602  
C        
C            41 CHEXA1   42 CHEXA2   43 CFLUID2  44 CFLUID3  45 CFLUID4 
     8,      603,  603,  604,  604,  610,  610,  610,  610,  610,  610  
C        
C            46 CFLMASS  47 CAXIF2   48 CAXIF3   49 CAXIF4   50 CSLOT3  
     9,      610,  610,  605,  605,  606,  606,  607,  607,  608,  608  
C        
     *), JLTYPE        
C        
C            51 CSLOT4   52 CHBDY    53 CDUM1    54 CDUM2    55 CDUM3   
  395 GO TO( 609,  609,  610,  610, 1614, 1614, 1615, 1615, 1616, 1616  
C        
C            56 CDUM4    57 CDUM5    58 CDUM6    59 CDUM7    60 CDUM8   
     B,     1617, 1617, 1618, 1618, 1619, 1619, 1620, 1620, 1621, 1621  
C        
C            61 CDUM9    62 CQDMEM1  63 CQDMEM2  64 CQUAD4   65 CIHEX1  
     C,     1622, 1622, 1623, 1623, 1624, 1624, 1625, 1625, 1626, 1626  
C        
C            66 CIHEX2   67 CIHEX3   68 CQUADTS  69 CTRIATS  70 CTRIAAX 
     D,     1626, 1626, 1626, 1626, 1632, 1632, 1633, 1633, 1634, 1634  
C        
C            71 CTRAPAX  72 CAERO1   73 CTRIM6   74 CTRPLT1  75 CTRSHL  
     E,     1635, 1635,  610,  610, 1640, 1640, 1645, 1645, 1650, 1650  
C        
C            76 CFHEX1   77 CFHEX2   78 CFTETRA  79 CFWEDGE  80 CIS2D8  
     F,      610,  610,  610,  610,  610,  610,  610,  610, 1660, 1660  
C        
C            81 CELBOW   82 CFTUBE   83 CTRIA3        
     G,      1670, 1670, 610,  610, 1630, 1630        
C        
     *), LOCAL        
C        
  400 CALL SROD2        
      GO TO 620        
  420 K = 4        
      GO TO 440        
  430 K = 5        
  440 CALL SPANL2 (K)        
      GO TO 620        
  450 K = 3        
      GO TO 550        
  460 K = 0        
      GO TO 510        
  470 K = 3        
      GO TO 510        
  480 K = 1        
      GO TO 530        
  490 CALL SELAS2        
      GO TO 620        
  500 K = 4        
  510 CALL SBSPL2 (K,TGRID(1))        
      GO TO 620        
  520 K = 2        
  530 CALL STQME2 (K)        
      GO TO 620        
  540 K = 4        
  550 CALL STRQD2 (K,TGRID(1))        
      GO TO 620        
  560 CALL SBAR2 (TGRID(1))        
      GO TO 620        
  570 AGAIN = .FALSE.        
      CALL SCONE2 (SORC)        
      GO TO 620        
  580 CALL STRIR2 (TGRID(2))        
      GO TO 620        
  590 CALL STRAP2 (TGRID(2))        
      GO TO 620        
  600 CALL STORD2 (TGRID(2))        
      GO TO 620        
  601 CALL SSOLD2 (1,TGRID(2))        
      GO TO 620        
  602 CALL SSOLD2 (2,TGRID(2))        
      GO TO 620        
  603 CALL SSOLD2 (3,TGRID(2))        
      GO TO 620        
  604 CALL SSOLD2 (4,TGRID(2))        
      GO TO 620        
  605 KK = 0        
      GO TO 611        
  606 KK = 1        
      GO TO 611        
  607 KK = 2        
  611 CALL SAXIF2 (KK,IPART,BRANCH,Z(JLIST))        
      ACSTIC = .TRUE.        
      GO TO 620        
  608 KK = 0        
      GO TO 612        
  609 KK = 1        
  612 CALL SSLOT2 (KK,IPART,BRANCH,Z(JLIST))        
      ACSTIC = .TRUE.        
      GO TO 620        
 1614 CALL SDUM12        
      GO TO 620        
 1615 CALL SDUM22        
      GO TO 620        
 1616 CALL SDUM32        
      GO TO 620        
 1617 CALL SDUM42        
      GO TO 620        
 1618 CALL SDUM52        
      GO TO  620        
 1619 CALL SDUM62        
      GO TO 620        
 1620 CALL SDUM72        
      GO TO 620        
 1621 CALL SDUM82        
      GO TO 620        
 1622 CALL SDUM92        
      GO TO 620        
 1623 CALL SQDM12        
      GO TO 620        
 1624 CALL SQDM22        
      GO TO 620        
 1625 CALL SQUD42        
      GO TO 620        
 1626 CALL SIHEX2 (ELTYPE-64,TGRID(1),NIP,ISTRPT,ISTORE)        
      NGP  = 12*(ELTYPE-64) - 4        
      NGP1 = NGP + 1        
      IF (ELTYPE .EQ. 67) NGP1 = 21        
      NIP3 = NIP**3        
      IF (ISTRPT .LT. NIP3+1) GO TO 905        
      IF (ISTRPT .EQ. NIP3+1) GO TO 1626        
      IF (ISTRPT .EQ. NIP3+1+NGP1) ISTORE = 0        
      IF (KTYPE .EQ. 1) GO TO 620        
      NGPX = ISTRPT - (NIP3+1)        
      NW   = 22        
      IF (ELTYPE .EQ. 67) NW = 23        
      IST = NW*(NGPX-1)        
      IF (IPART .GE. KTYPE) GO TO 1628        
C        
C     STORE IMARINARY PARTS FOR THIS GRID (IHEX ELEMENTS)        
C        
      IJK = IST + ICORE        
      DO 1627 J = 1,NW        
 1627 Z(J+IJK) = BUFA(J)        
      IF (ISTORE .NE. 0) GO TO 1626        
      IVEC   = MIDVEC        
      ESTAWD = OLDAWD        
      GO TO 380        
C        
C     RETRIEVE IMAGINARY PARTS FOR THIS GRID (IHEX ELEMENTS)        
C        
 1628 IJK = IST + ICORE        
      DO 1629 J = 1,NW        
 1629 ISAVES(J) = Z(J+IJK)        
      GO TO 620        
C        
 1630 CALL STRI32        
      GO TO 620        
 1632 CONTINUE        
      GO TO 620        
 1633 CONTINUE        
      GO TO 620        
 1634 AGAIN = .FALSE.        
      CALL STRAX2 (SORC,TGRID(2))        
      GO TO 620        
 1635 AGAIN = .FALSE.        
      CALL STPAX2 (SORC,TGRID(2))        
      GO TO 620        
 1640 CALL STRM62 (TGRID(1))        
      GO TO 620        
 1645 CALL STRP12 (TGRID(1))        
      GO TO 620        
 1650 CALL  STRSL2 (TGRID(1))        
      GO TO 620        
 1660 CALL SS2D82 (IEQEX,NEQEX,TGRID(1))        
      GO TO 620        
 1670 CALL SELBO2 (TGRID(1))        
      GO TO 620        
C        
C     PHASE TWO HEAT ONLY (ALL ELEMENTS)        
C        
 1680 CALL SDHTF2 (IEQEX,NEQEX)        
      GO TO 620        
  610 GO TO 900        
C        
C     CALL ELEMENT TWO TIMES FOR COMPLEX VECTOR.  IMAGINARY FIRST, REAL 
C     SECOND.  CALL ELEMENT ROUTINE TWICE IF AXIC PROBLEM        
C     ONCE FOR EACH OF THE 2 VECTORS IN CORE        
C        
  620 IF (AXIC .AND. MIDVEC.NE.0 .AND. IPART.EQ.1) GO TO 625        
      IF (IPART .GE. KTYPE) GO TO 615        
  625 IVEC = MIDVEC        
C        
C     FOR CONICAL SHELL ONLY        
C        
      IF (AXIC .AND. KTYPE.NE.1) GO TO 626        
      ITEMP = 1        
      IF (SORC .EQ. 1) ITEMP = 2        
      SORC  = ITEMP        
  626 CONTINUE        
      ESTAWD = NSESTA        
      IF (AXIC .AND. KTYPE.EQ.1) GO TO 380        
C        
C     SAVE IMAGINARY OUTPUTS  (NOT MORE THAN 75 STRESS OR FORCE WORDS)  
C        
      DO 622 I = 1,75        
      ISAVES(I) = BUFA(I)        
  622 ISAVEF(I) = BUFB(I)        
      GO TO 380        
C        
C     SPLIT OUTPUT FROM SECOND CALL FOR ACOUSTIC ELEMENTS        
C     AXIF2, AXIF3, AXIF4, SLOT3, OR SLOT4.        
C        
  615 IF (.NOT. ACSTIC) GO TO 617        
      IF (IPART .LT. 2) GO TO 617        
      DO 613 I = 1,12        
      ISAVES(I) = BUFA(I   )        
      BUFA(I)   = BUFA(I+12)        
  613 CONTINUE        
C        
C        
C     OUTPUT ONLY FIRST N HARMONICS REQUESTED        
C        
  617 IF (.NOT. AXIC) GO TO 616        
      IF (NELHAR.LT.0 .OR. NELHAR.GT.OHARMS) GO TO 880        
      IF (IPART.EQ.2 .AND. KTYPE.EQ.1) GO TO 880        
C        
C     OUTPUT STRESS RESULTS ON OES1 (IF REQUESTED)        
C        
  616 IF (JSTRS.EQ.0 .OR. NWDSTR.EQ.0) GO TO 860        
      IF (KTYPE .EQ. 1) GO TO 850        
C        
C     COMBINE COMPLEX OUTPUT DESIRED PER FORMAT IN COMPLX ARRAY.        
C          REAL PARTS ARE IN BUFA   BUFB        
C          IMAG PARTS ARE IN ISAVES ISAVEF        
C        
C        
C     COMPLEX STRESSES        
C        
      IOUT = 0        
      I    = NPTSTR        
  651 NPT  = COMPLX(I)        
      IF (NPT) 652,653,654        
  652 NPT  = -NPT        
      IF (SPHASE .NE. 3) GO TO 654        
C        
C     COMPUTE MAGNITUDE/PHASE        
C        
      CALL MAGPHA (BUFA(NPT),ISAVES(NPT))        
  655 IOUT = IOUT + 1        
      ELWORK(IOUT) = BUFA(NPT)        
      I    = I + 1        
      GO TO 651        
  654 IF (NPT .LE. LSTRES) GO TO 655        
      NPT  = NPT - LSTRES        
      IOUT = IOUT + 1        
      ELWORK(IOUT) = ISAVES(NPT)        
      I    = I + 1        
      GO TO 651        
C        
C     TRANSFER RESULTS TO BUFA        
C        
  653 DO 659 I = 1,IOUT        
  659 BUFA(I) = ELWORK(I)        
      NWDSTR  = IOUT        
C        
C     WRITE STRESSES        
C        
C        
C     DETERMINE DESTINATION FOR STRESS ENTRY        
C        
  850 IF (STRESS .EQ. 0) GO TO 860        
      IF (.NOT.  OK2WRT) GO TO 860        
      ID = BUFA(1)        
      BUFA(1) = 10*ID + SDEST        
      IF (XSETNS) 858,851,852        
  851 BUFA(1) = 10*ID        
      GO TO 858        
  852 IX = IXSETS        
  853 IF (IX .EQ. NXSETS) GO TO 854        
      IF (Z(IX+1) .GT. 0) GO TO 854        
      IF (ID.GE.Z(IX) .AND. ID.LE.(-Z(IX+1))) GO TO 858        
      IX = IX + 2        
      GO TO 855        
  854 IF (ID .EQ. Z(IX)) GO TO 858        
      IX = IX + 1        
  855 IF (IX .LE. NXSETS) GO TO 853        
      GO TO 851        
C        
C     NOW WRITE STRESS ENTRY        
C        
  858 CALL WRITE (OES1,BUFA(1),NWDSTR,0)        
      BUFA(1) = ID        
C        
C     OUTPUT FORCE RESULTS ON OEF1 (IF REQUESTED)        
C        
  860 IF (JFORC .EQ. 0  .OR. NWDFOR .EQ. 0) GO TO 880        
      IF (KTYPE .EQ. 1) GO TO 870        
C        
C     COMPLEX FORCES        
C        
      IOUT = 0        
      I    = NPTFOR        
  951 NPT  = COMPLX(I)        
      IF (NPT) 952,953,954        
  952 NPT  = -NPT        
      IF (FPHASE .NE. 3) GO TO 954        
C        
C     COMPUTE MAGNITUDE/PHASE FOR FORCES        
C        
      CALL MAGPHA (BUFB(NPT),ISAVEF(NPT))        
  955 IOUT = IOUT + 1        
      ELWORK(IOUT) = BUFB(NPT)        
      I    = I + 1        
      GO TO 951        
  954 IF (NPT .LE. LFORCE) GO TO 955        
      NPT  = NPT - LFORCE        
      IOUT = IOUT + 1        
      ELWORK(IOUT) = ISAVEF(NPT)        
      I    = I + 1        
      GO TO 951        
C        
C     TRANSFER RESULTS TO BUFB        
C        
  953 DO 959 I = 1,IOUT        
  959 BUFB(I) = ELWORK(I)        
      NWDFOR  = IOUT        
C        
C     WRITE FORCES        
C        
C        
C     DETERMINE DESTINATION FOR FORCE ENTRY        
C        
  870 IF (FORCE .EQ. 0) GO TO 880        
      IF (.NOT. OK2WRT) GO TO 880        
      ID = BUFB(1)        
      BUFB(1) = 10*ID + FDEST        
      IF (XSETNF) 878,871,872        
  871 BUFB(1) = 10*ID        
      GO TO 878        
  872 IX = IXSETF        
  873 IF (IX .EQ. NXSETF) GO TO 874        
      IF (Z(IX+1) .GT. 0) GO TO 874        
      IF (ID.GE.Z(IX) .AND. ID.LE.(-Z(IX+1))) GO TO 878        
      IX = IX + 2        
      GO TO 875        
  874 IF (ID .EQ. Z(IX)) GO TO 878        
      IX = IX + 1        
  875 IF (IX .LE. NXSETF) GO TO 873        
      GO TO 871        
C        
C     NOW WRITE FORCE ENTRY        
C        
  878 CALL WRITE (OEF1,BUFB(1),NWDFOR,0)        
      BUFB(1) = ID        
  880 GO TO 900        
  890 ESTAWD = ESTAWD + NWDSA        
  900 IF (AGAIN) GO TO 903        
      IF (ISTORE .EQ. 1) GO TO 1626        
      IF (KTYPE.NE.1 .OR. (AXIC .AND. MIDVEC.NE.0)) IVEC = ISAVE        
      IF (AXIC .AND. MIDVEC.NE.0) SORC = ISVSRC        
      IF (.NOT. AXIC) GO TO 905        
      IF (NELHAR .NE. NHARMS) GO TO 905        
  903 IF (ELTYPE .EQ. 35) CALL SCONE3 (AGAIN)        
      IF (ELTYPE .EQ. 70) CALL STRAX3 (AGAIN)        
      IF (ELTYPE .EQ. 71) CALL STPAX3 (AGAIN)        
      NELHAR = -1        
      GO TO 616        
  905 IF (NESTA .EQ. 0) GO TO 80        
      IF (Z(ESTAWD+1) .NE. 0) GO TO 90        
C        
C     END OF ESTA FOR CURRENT ELEMENT TYPE        
C        
  910 IF (.NOT. IDSTRS) GO TO 915        
      CALL WRITE (OES1,0,0,1)        
  915 IF (.NOT. IDFORC) GO TO 920        
      CALL WRITE (OEF1,0,0,1)        
  920 IF (.NOT. IDLYST) GO TO 925        
      CALL WRITE (OES1L,0,0,1)        
  925 IF (.NOT. IDLYFR) GO TO 930        
      CALL WRITE (OEF1L,0,0,1)        
  930 IF (NESTA .EQ. 0) GO TO 20        
  940 ESTAWD = ESTAWD + 2        
      IF (ESTAWD .GE. NESTA) GO TO 950        
      ELTYPE = Z(ESTAWD)        
      GO TO 25        
C        
C     END OF ESTA FILE HIT        
C        
  950 CONTINUE        
  960 CONTINUE        
      IVEC  = ISAVE        
      ICORE = JCORE        
      RETURN        
C        
C     INTERNAL SUBROUTINE FOR WRITING ID RECORDS TO OUTPUT FILES        
C        
  630 DO 635 I = 1,50        
  635 BUF(I) = 0        
C        
C     IF THE ID IS BEING WRITTEN TO A FILE WITH COMPLEX DATA,        
C     CHANGE THE NUMBER OF WORDS TO REFLECT THE ACTUAL COUNT        
C     OF WORDS BEING PUT TOGETHER USING THE STRING OF NUMBERS        
C     IN THE 'COMPLX' ARRAY.  (SEE FORTRAN LABELS 651 THRU 654        
C     AND 951 THRU 954)        
C        
      IF (KTYPE  .EQ. 1) GO TO 645        
      IF (JCMPLX .EQ. 0) RETURN 1        
      JOUT = 0        
      I    = JCMPLX        
  638 NCMPLX = COMPLX(I)        
      IF (NCMPLX) 640,642,640        
  640 JOUT = JOUT + 1        
      I    = I + 1        
      GO TO 638        
  642 NWDS = JOUT        
C        
C     CHECK FOR VON MISES STRESS REQUEST.  SET WORD 11 IF        
C     REQUEST IS FOUND.        
C        
  645 IF (ANDF(NSTROP,1) .NE. 0) BUF(11) = 1        
C        
      GO TO (650,660,650,650,670,790,650,660,660,650), BRANCH        
C        
C     NORMAL STATICS OR DIFF.STIFF. PHASE 0 OR 1 OR BUCKLING PHASE 0.   
C        
  650 BUF(2) = IFLTYP        
      IX     = ICC + ISLOAD        
      BUF(5) = Z(ICC+1)        
      BUF(6) = 0        
      BUF(7) = 0        
      BUF(8) = Z(IX)        
      IF (BRANCH .NE. 10) GO TO 840        
      IX     = ICC + ITTL + 84        
      Z(IX)  = PLATIT(1)        
      Z(IX+1)= PLATIT(2)        
      Z(IX+2)= PLATIT(3)        
      CALL INT2AL (UGVVEC-1,Z(IX+3),PLATIT(4))        
      GO TO 840        
C        
C     EIGENVALUES OR BUCKLING PHASE 1.        
C        
  660 BUF(2) = IFLTYP + KTYPEX        
      BUF(5) = Z(JLIST)        
      BUF(6) = Z(JLIST+1)        
      BUF(7) = Z(JLIST+2)        
      BUF(8) = 0        
      GO TO 840        
C        
C     FREQUENCY RESPONSE.        
C        
  670 IX     = ICC + IDLOAD        
      BUF(8) = Z(IX)        
      BUF(6) = 0        
      BUF(7) = 0        
      BUF(2) = IFLTYP + KTYPEX        
  671 CONTINUE        
C        
C     FIRST TIME FOR THIS LOAD VECTOR ONLY - MATCH LIST OF        
C        
      IF (KFRQ .NE. 0) GO TO 740        
C        
C     USER REQUESTED FREQS WITH ACTUAL FREQS. MARK FOR        
C     OUTPUT EACH ACTUAL FREQ WHICH IS CLOSEST TO USER REQUEST.        
C        
      KFRQ   = 1        
      IX     = ICC + IFROUT        
      FSETNO = Z(IX)        
      IF (FSETNO .LE. 0) GO TO 690        
      IX     = ICC + ILSYM        
      ISETNF = IX+Z(IX) + 1        
  680 ISETFR = ISETNF + 2        
      NSETFR = Z(ISETNF+1) + ISETFR - 1        
      IF (Z(ISETNF) .EQ. FSETNO) GO TO 710        
      ISETNF = NSETFR + 1        
      IF (ISETNF .LT. IVEC) GO TO 680        
      FSETNO = -1        
  690 DO 700 J = ILIST,NLIST,2        
  700 Z(J+1) = 1        
      GO TO 740        
  710 DO 730 I = ISETFR,NSETFR        
      K      = 0        
      DIFF   = 1.E25        
      BUFR(1)= ZZ(I)        
      DO 720 J = ILIST,NLIST,2        
      IF (Z(J+1) .NE. 0) GO TO 720        
      DIFF1  = ABS(ZZ(J) - BUFR(1))        
      IF (DIFF1 .GE. DIFF) GO TO 720        
      DIFF = DIFF1        
      K    = J        
  720 CONTINUE        
      IF (K .NE. 0) Z(K+1) = 1        
  730 CONTINUE        
C        
C     DETERMINE IF CURRENT FREQ IS MARKED FOR OUTPUT.        
C        
  740 IF (Z(JLIST+1) .EQ. 0) GO TO 960        
      BUF(5) = Z(JLIST)        
      GO TO 840        
C        
C     TRANSIENT RESPONSE.        
C        
  790 BUF(5) = Z(JLIST)        
      BUF(2) = IFLTYP        
      IX     = ICC + IDLOAD        
      BUF(8) = Z(IX)        
      BUF(6) = 0        
      BUF(7) = 0        
      GO TO 671        
C        
C     WRITE ID RECORD ON OUTPUT FILE.        
C     (FOR MORE DETAIL, SEE OES1 FILE IN PROGRAMMER MANUAL P.2.3-130)   
C        
  840 BUF(1) = DEVICE + 10*BRANCH        
      BUF(3) = ELTYPE        
C        
C     CHECK FOR TRIA1, TRIA2, TRIA3, QUAD1, QUAD2, QUAD4  ELEMENTS      
C        
      IF (ELTYPE.NE. 6 .AND. ELTYPE.NE.17 .AND. ELTYPE.NE.18 .AND.      
     1    ELTYPE.NE.19 .AND. ELTYPE.NE.64 .AND. ELTYPE.NE.83)        
     2    GO TO 845        
C        
C     CHECK FOR STRAIN OPTION        
C        
      IF (BUF(2).EQ.5 .AND. STRAIN) BUF(2) = 21        
  845 BUF(4) = Z(ICC+1)        
      IF (DDRMM) BUF(4) = 9999        
      BUF(9) = IABS(Z(IRECX+2))        
      IF (BUF(9).EQ.1 .AND. KTYPE.EQ.2) BUF(9) = 2        
      BUF(10) = NWDS        
      CALL WRITE (OFILE,BUF(1),50,0)        
      IX = ICC + ITTL        
      CALL WRITE (OFILE,Z(IX),96,1)        
      ILOGIC(NLOGIC) = .TRUE.        
      GO TO IRETRN, (365,375)        
C        
C     ERRORS        
C        
  980 N = 2        
      GO TO 1000        
  990 N = 3        
      GO TO 1000        
 1000 CALL MESAGE (N,FILE,NAM)        
      RETURN 1        
C        
      END        
