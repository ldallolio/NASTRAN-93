      SUBROUTINE EMGPRO (IBUF)        
C        
C     THIS ROUTINE OF THE -EMG- MODULE IS THE MAIN PROCESSOR.  IT WILL  
C     PASS THE -EST- DATA BLOCK ONCE, ELEMENT TYPE BY ELEMENT TYPE.     
C        
C     ELEMENT TYPES CONTRIBUTING TO STIFFNESS, MASS, OR DAMPING MATRICES
C     WILL BE PROCESSED.        
C        
      LOGICAL          ANYCON, ERROR, HEAT        
      INTEGER          Z, EST, CSTM, DIT, GEOM2, DICTN, SAVJCR, ELID,   
     1                 OUTPT, EOR, SUBR(2), ELTYPE, PRECIS, ESTBUF,     
     2                 ELEM, ESTWDS, ESTID, SAVNCR, DOSI(2), FLAGS,     
     3                 SIL(32), SYSBUF, SCR3, SCR4, RET        
      DOUBLE PRECISION DUMMY        
      DIMENSION        IZ(1), IPOS(32), IBUF(7), TRIM6(2), TRPL1(2),    
     1                 TRSHL(2), ESTX(12)        
      CHARACTER        UFM*23, UWM*25, UIM*29, SFM*25, SWM*27        
      COMMON /XMSSG /  UFM, UWM, UIM, SFM, SWM        
      COMMON /BLANK /  NOK, NOM, NOB, NOK4GG, NOKDGG, NOCMAS, NCPBAR,   
     1                 NCPROD, NCPQD1, NCPQD2, NCPTR1, NCPTR2, NCPTUB,  
     2                 NCPQDP, NCPTRP, NCPTRB, VOLUME, SURFAC        
      COMMON /SYSTEM/  KSYSTM(65)        
      COMMON /GPTA1 /  NELEM, LAST, INCR, ELEM(1)        
      COMMON /EMGFIL/  EST, CSTM, MPT, DIT, GEOM2, MATS(3), DICTN(3)    
      COMMON /EMGPRM/  ICORE, JCORE, NCORE, ICSTM, NCSTM, IMAT, NMAT,   
     1                 IHMAT, NHMAT, IDIT, NDIT, ICONG, NCONG, LCONG,   
     2                 ANYCON, FLAGS(3), PRECIS, ERROR, HEAT,        
     3                 ICMBAR, LCSTM, LMAT, LHMAT, KFLAGS(3), L38       
      COMMON /EMGEST/  ESTBUF(200)        
      COMMON /EMGDIC/  ELTYPE, LDICT, NLOCS, ELID, ESTID        
CZZ   COMMON /ZZEMGX/  Z(1)        
      COMMON /ZZZZZZ/  Z(1)        
      COMMON /IEMGOT/  NVAL(3)        
      COMMON /MATOUT/  EGNU(6), RHO        
      COMMON /IEMGOD/  DUMMY, KTYPES        
      COMMON /IEMG1B/  ICALL, ILAST        
      COMMON /SMA1CL/  KDUMMY(22), KNOGO        
      COMMON /SMA2CL/  MDUMMY(20), MNOGO        
      EQUIVALENCE      (KSYSTM( 2),OUTPT), (KSYSTM( 1),SYSBUF ),        
     1                 (KSYSTM(55),IPREC), (ESTBUF( 1),ESTX(1)),        
     2                 (IZ    ( 1),Z(1) )        
      DATA    TRIM6,         TRPL1,         TRSHL               /       
     1        4HCTRI,  4HM6  , 4HCTRP,4HLT1 , 4HCTRS,4HHL       /       
      DATA    SCR3  ,  SCR4  / 303, 304 /        
      DATA    EOR   ,  NOEOR / 1, 0     /, SUBR / 4HEMGP,4HRO   /       
      DATA    DOSI  /  4HDOUB, 4HSING   /        
C        
      IQDMM1 = 0        
      IQDMM2 = 0        
      NVAL(1)= 0        
      NVAL(2)= 0        
      NVAL(3)= 0        
      LTYPES = 0        
      KTYPES = 0        
      DUMMY  = 0.0D0        
      ICALL  = 0        
      ILAST  = 0        
C        
C     INITIALIZE /SMA1CL/ AND /SMA2CL/        
C        
      KNOGO = 0        
      MNOGO = 0        
      KDUMMY(10) = 10        
      MDUMMY(10) = 10        
C        
C     FOLLOWING CALL PREPS /GPTA1/ FOR DUMMY ELEMENTS        
C        
      CALL DELSET        
C        
C     DEFINE WORKING CORE BLOCK FOR RESET PURPOSES.        
C        
      IPR = PRECIS        
      IF (IPR .NE. 1) IPR = 0        
      SAVJCR = JCORE        
      SAVNCR = NCORE        
      ESTID  = 0        
      LNUM   = LCONG/2        
C        
C     READ THE ELEMENT TYPE FROM THE EST.        
C        
   10 CALL READ (*1340,*1360,EST,ELTYPE,1,NOEOR,IWORDS)        
      IZERO = INCR*(ELTYPE-1)        
C        
C     CHECK FOR ALLOWABLE ELEMENT TYPES        
C        
      IF (ELTYPE.EQ. 2 .OR. ELTYPE.EQ.32 .OR. ELTYPE.EQ.33 .OR.        
     1    ELTYPE.EQ.68 .OR. ELTYPE.EQ.69 .OR. ELTYPE.EQ.72) GO TO 15    
      IF (ELTYPE.GE.1 .AND. ELTYPE.LE.NELEM) GO TO 40        
   15 WRITE  (OUTPT,20) SFM,ELEM(IZERO+1),ELEM(IZERO+2),ELTYPE        
   20 FORMAT (A25,' 3105, EMGPRO FINDS ',2A4,' ELEMENTS (ELEM. TYPE ',  
     1       I3,') UNDEFINED IN EST DATA BLOCK AND/OR ELEMENT ROUTINE.')
   30 CALL FWDREC (*1350,EST)        
      ERROR = .TRUE.        
      GO TO 10        
C        
C     RESTORE CORE POINTERS        
C        
   40 JCORE = SAVJCR        
      NCORE = SAVNCR        
C        
C     CLEAR ESTBUF        
C        
      DO 50 I = 1,200        
      ESTBUF(I) = 0        
   50 CONTINUE        
C        
C     SET VARIOUS PARAMETERS = FUNCTION OF THIS ELEMENT TYPE        
C        
C     TURN ON COUPLED MASS FLAG IF EITHER OF ALL-COUPLED-MASS-FLAG      
C     OR SPECIFIC-TYPE-COUPLED-MASS-FLAG IS ON.        
C        
      IF (FLAGS(2)) 51,53,51        
   51 IF (NOCMAS  ) 53,52,54        
   52 IF (ELTYPE .EQ. 34) IF (NCPBAR) 53,53,54        
      IF (ELTYPE .EQ.  1) IF (NCPROD) 53,53,54        
      IF (ELTYPE .EQ. 19) IF (NCPQD1) 53,53,54        
      IF (ELTYPE .EQ. 18) IF (NCPQD2) 53,53,54        
      IF (ELTYPE .EQ.  6) IF (NCPTR1) 53,53,54        
      IF (ELTYPE .EQ. 17) IF (NCPTR2) 53,53,54        
      IF (ELTYPE .EQ.  3) IF (NCPTUB) 53,53,54        
      IF (ELTYPE .EQ. 15) IF (NCPQDP) 53,53,54        
      IF (ELTYPE .EQ.  8) IF (NCPTRP) 53,53,54        
      IF (ELTYPE .EQ.  7) IF (NCPTRB) 53,53,54        
   53 ICMBAR = -1        
      GO TO 56        
C        
   54 ICMBAR = 1        
C        
   56 JLTYPE = 2*ELTYPE - IPR        
      ESTWDS = ELEM(IZERO+12)        
      NSILS  = ELEM(IZERO+10)        
      ISIL   = ELEM(IZERO+13)        
      IF (ELEM(IZERO+9) .NE. 0) ISIL = ISIL - 1        
      I1 = ISIL        
      I2 = ISIL + NSILS - 1        
      ISAVE2 = 0        
      IF (ESTWDS. LE. 200) GO TO 70        
      WRITE  (OUTPT,60) SFM,ELTYPE        
   60 FORMAT (A25,' 3106, EMGPRO FINDS THAT ELEMENT TYPE ',I3,        
     1        ' HAS EST ENTRIES TOO LARGE TO HANDLE CURRENTLY.')        
      GO TO 30        
C        
C     CHECK TO SEE IF ILLEGAL ELEMENTS ARE USED IN -HEAT- FORMULATION   
C        
   70 IF (.NOT.HEAT) GO TO 80        
      IF (ELTYPE.EQ. 1 .OR.  ELTYPE.EQ. 3 .OR. ELTYPE.EQ. 6) GO TO 80   
      IF (ELTYPE.GE. 9 .AND. ELTYPE.LE.14) GO TO 80        
      IF (ELTYPE.GE.16 .AND. ELTYPE.LE.24) GO TO 80        
      IF (ELTYPE.EQ.34 .OR.  ELTYPE.EQ.36 .OR. ELTYPE.EQ.37) GO TO 80   
      IF (ELTYPE.GE.39 .AND. ELTYPE.LE.42) GO TO 80        
      IF (ELTYPE.EQ.52 .OR.  ELTYPE.EQ.62 .OR. ELTYPE.EQ.63) GO TO 80   
      IF (ELTYPE.GE.64 .AND. ELTYPE.LE.67) GO TO 80        
      IF (ELTYPE.EQ.80 .OR.  ELTYPE.EQ.81 .OR. ELTYPE.EQ.83) GO TO 80   
C        
      WRITE  (OUTPT,75) UFM,ELEM(IZERO+1),ELEM(IZERO+2),ELTYPE        
   75 FORMAT (A23,' 3115, EMGPRO FINDS ',2A4,' ELEMENTS (ELEMENT TYPE ',
     1        I3,') PRESENT IN A HEAT FORMULATION.')        
      GO TO 30        
C        
C     SET UP VARIABLES TO BE WRITTEN AS DICTIONARY 3-WORD HEADER        
C        
   80 NLOCS = NSILS        
      LDICT = NLOCS + 5        
C        
C     READ AN ELEMENT EST ENTRY        
C        
   90 CALL READ (*1350,*1200,EST,ESTBUF,ESTWDS,NOEOR,IWORDS)        
      ELID  = ESTBUF(1)        
      ESTID = ESTID + 1        
C        
C     CHECK TO SEE IF THIS ELEMENT IS CONGRUENT TO ANOTHER ALREADY      
C     POSSESSING A DICTIONARY IN CORE.        
C        
      IF (.NOT.ANYCON) GO TO 150        
      CALL BISLOC (*150,ELID,Z(ICONG),2,LNUM,J)        
C        
C     MATCH FOUND.  CHECK FOR DICTIONARY-TABLE ON PRIMARY.        
C        
      IPRIME = Z(ICONG+J  )        
      IDPRIM = Z(ICONG+J-1)        
  100 IF (IPRIME) 120,104,110        
C        
C     SET UP ELEMENT MATRIX MAPPING ARRAY FOR LATER USE BY OTHER        
C     ELEMENTS IN THIS CONGRUENT SET        
C        
  104 ICG    = JCORE        
      JJCORE = JCORE  + 2*NSILS + 5        
      ICRQ   = JJCORE - NCORE        
      IF (JJCORE .GE .NCORE) GO TO 1800        
      JCORE   = JJCORE        
      IZ(ICG) = IDPRIM        
      IZ(ICG+1) = NSILS        
      IZ(ICG+2) = 0        
      IZ(ICG+3) = 0        
      IZ(ICG+4) = 0        
      IGOTO = 0        
      GO TO 1380        
C        
C     IPRIME POINTS TO PRIMARY ID        
C        
  110 IDPRIM = Z(IPRIME  )        
      IPRIME = Z(IPRIME+1)        
      GO TO 100        
C        
C     IPRIME IS NEGATIVE TABLE ADDRESS IMPLYING DICTIONARY EXISTS.      
C        
  120 IF (ERROR) GO TO 150        
      IPRIME =-IPRIME        
      IMATCH = 0        
      IBFIND = 1        
C     DO 145 J = 1,3        
      J = 0        
  125 J = J + 1        
      IADD = Z(IPRIME+J)        
      IF (IADD) 140,140,130        
C        
C     COPY DICTIONARY FROM CORE TO DICTIONARY FILE.        
C        
  130 Z(IADD)  = ESTID        
      FLAGS(J) = FLAGS(J) + 1        
      CALL WRITE (DICTN(J),Z(IADD),5,NOEOR)        
      IADDD  = IADD + 5        
      IF (IMATCH .EQ. 1) GO TO 135        
      IF (IMATCH .EQ. 2) GO TO 1600        
      INDCNG = SAVJCR        
      IGOTO  = 1        
  131 IF (IZ(INDCNG) .EQ. IDPRIM) GO TO 1380        
      JJCORE = INDCNG + 2*IZ(INDCNG+1) + 5        
      IF (JJCORE .GE. NCORE) GO TO 1820        
      INDCNG = JJCORE        
      GO TO 131        
  133 DO 134 L = 1,NSILS        
      IF (IPOS(L) .NE. IZ(INDCNG+NSILS+L+4)) GO TO 137        
  134 CONTINUE        
      IMATCH = 1        
  135 CALL WRITE (DICTN(J),Z(IADDD),NSILS,NOEOR)        
      GO TO 140        
  137 IMATCH = 2        
      GO TO 1600        
  140 IBFIND = IBFIND + 2        
      IF (J .LT. 3) GO TO 125        
C 145 CONTINUE        
      GO TO 90        
C        
C     BRANCH ON ELEMENT TYPE.  INDIVIDUAL ROUTINES WILL COMPUTE AND     
C     OUTPUT ALL MATRIX TYPES DESIRED BASED ON FLAGS AVAILABLE TO THEM. 
C        
  150 IF (ELTYPE .EQ. LTYPES) GO TO 152        
      LTYPES = ELTYPE        
      IF (LTYPES .GT. NELEM) GO TO 15        
C     IF (L38 .NE. 1) GO TO 154        
      CALL PAGE2 (3)        
      WRITE  (OUTPT,151) UIM,DOSI(IPR+1),ELEM(IZERO+1),ELEM(IZERO+2),   
     1                   ELTYPE,ELID        
  151 FORMAT (A29,' 3113,', /5X,'EMG MODULE PROCESSING ',A4,        
     1       'LE PRECISION ',2A4,' ELEMENTS (ELEMENT TYPE ',I3,        
     2       ') STARTING WITH ID ',I8)        
      IF (ELTYPE.GE.84 .AND. ELTYPE.LE.86) WRITE (OUTPT,2300)        
  152 IF (L38 .NE. 1) GO TO 154        
      CALL PAGE2 (1)        
      WRITE  (OUTPT,153) ELID        
  153 FORMAT (5X,'ELEMENT ',I8,' IS BEING PROCESSED')        
  154 LOCAL = JLTYPE - 100        
      IF (LOCAL) 155,155,156        
C        
C     PAIRED -GO TO- ENTRIES PER ELEMENT SINGLE/DOUBLE PRECISION        
C        
C             1 CROD      2 C.....    3 CTUBE     4 CSHEAR    5 CTWIST  
  155 GO TO (210,  215,   15,   15,  230,  235,  240,  245,  250,  255, 
C        
C             6 CTRIA1    7 CTRBSC    8 CTRPLT    9 CTRMEM   10 CONROD  
     1       260,  265,  270,  275,  280,  285,  290,  295,  210,  215, 
C        
C            11 ELAS1    12 ELAS2    13 ELAS3    14 ELAS4    15 CQDPLT  
     2       320,  320,  325,  325,  335,  335,  345,  345,  350,  355, 
C        
C            16 CQDMEM   17 CTRIA2   18 CQUAD2   19 CQUAD1   20 CDAMP1  
     3       360,  365,  370,  375,  380,  385,  390,  395,  405,  405, 
C        
C            21 CDAMP2   22 CDAMP3   23 CDAMP4   24 CVISC    25 CMASS1  
     4       415,  415,  425,  425,  435,  435,  440,  445,  455,  455, 
C        
C            26 CMASS2   27 CMASS3   28 CMASS4   29 CONM1    30 CONM2   
     5       465,  465,  475,  475,  485,  485,  490,  495,  500,  505, 
C        
C            31 PLOTEL   32 C.....   33 C.....   34 CBAR     35 CCONEAX 
     6       510,  515,   15,   15,   15,   15,  540,  545,  550,  555, 
C        
C            36 CTRIARG  37 CTRAPRG  38 CTORDRG  39 CTETRA   40 CWEDGE  
     7       560,  565,  570,  575,  580,  585,  590,  595,  600,  605, 
C        
C            41 CHEXA1   42 CHEXA2   43 CFLUID2  44 CFLUID3  45 CFLUID4 
     8       610,  615,  620,  625,  630,  635,  640,  645,  650,  655, 
C        
C            46 CFLMASS  47 CAXIF2   48 CAXIF3   49 CAXIF4   50 CSLOT3  
     9       660,  665,  670,  675,  680,  685,  690,  695,  700,  705  
C        
     *       ), JLTYPE        
C        
C        
C            51 CSLOT4   52 CHBDY    53 CDUM1    54 CDUM2    55 CDUM3   
  156 GO TO (710,  715,  720,  725,  730,  730,  740,  740,  750,  750, 
C        
C            56 CDUM4    57 CDUM5    58 CDUM6    59 CDUM7    60 CDUM8   
     B       760,  760,  770,  770,  780,  780,  790,  790,  800,  800, 
C        
C            61 CDUM9    62 CQDMEM1  63 CQDMEM2  64 CQUAD4   65 CIHEX1  
     C       810,  810,  820,  825,  830,  835,  950,  955,  850,  855, 
C        
C            66 CIHEX2   67 CIHEX3   68 CQUADTS  69 CTRIATS  70 CTRIAAX 
     D       850,  855,  850,  855,   15,   15,   15,   15,  880,  885, 
C        
C            71 CTRAPAX  72 CAERO1   73 CTRIM6   74 CTRPLT1  75 CTRSHL  
     E       890,  895,   15,   15,  900,  905,  910,  915,  920,  925, 
C        
C            76 CFHEX1   77 CFHEX2   78 CFTETRA  79 CFWEDGE  80 CIS2D8  
     F       610,  615,  620,  625,  590,  595,  600,  605,  930,  935, 
C        
C            81 CELBOW   82 FTUBE    83 CTRIA3   84 CPSE2    85 CPSE3   
     G       940,  945,  840,  840,  960,  965,   90,   90,   90,   90, 
C        
C            86 CPSE4        
     H        90,   90        
C        
     *       ), LOCAL        
C        
C     ==================================================================
C     A WALKING TOUR OF EMG TO COMPUTE STIFFNESS (K-) AMD MASS (M-)     
C     MATRICES FOR AN 'OLD' ELEMENT SUCH AS CTRIA2.        
C     SEE HOW EASY IT IS.      G.CHAN/UNISYS, 7/87        
C        
C       EMG SUPPORTING ROUTINES -        
C       EMGTAB,EMGCNG,EMGCOR,EMGFIN,        
C       EMGSOC (WHICH COMPUTES OFFSET BETWWEN /ZZEMGX/ AND /ZZEMII/ AND 
C           /   SETS ICORE,JCORE,NCORE IN /EMGPRM/ FOR OPEN CORE USAGE) 
C          /        
C         /                                --->EMG1B---->EMGOUT        
C        /                                /   OUTPUT PIVOT ROW PARTITION
C     EMG---->EMGPRO---->CTRIA2          /    AFTER KTRIQD IS DONE, AND 
C               /      AN ENTRY POINT   /     ALSO AFTER MTRIQD        
C            /ZZEMGX/     IN           /                             (*)
C                        OLDEL3--->EMGOLD--->KTRIQD--->KTRMEM--->KTRPLT 
C                                    /                              /   
C                                    ------->MTRIQD             /ZZEM14/
C            (*)                                 (&)          UNIT 14 IS
C             KTRPLT---------------->KTRBSC                   ALLOCATED 
C           TO COMPUTE BENDING     TO COMPUTE MEMBRANE        TO CTRIA2 
C           FOR CTRIA2             FOR CTRIA2                 BY TA1ABD 
C                  /                      /        
C                 ------->SMA1B<----------        
C                           \        
C                            ---->EMG1B---->EMGOUT        
C                                          OUTPUT A K-MATRIX        
C           (&)                            PARTITION        
C             MTRIQD BRANCH, FOR M-MATRIX        
C             FOR CTRIA2 ELEMENT, IS SIMILARLY        
C             STRUCTURED AS THAT OF THE KTRIQD BRANCH        
C        
C             REPEAT DAMPING B-MATRIX IF NECESSARY        
C             IF ELEMENT HAS HEAT CAPBABILITY - WHAT DO I DO NOW?       
C        
C     THIS SYMBOL '>' IS RIGHT ARROW HEAD, AND '<' IS LEFT ARROW HEAD   
C     ==================================================================
C        
  210 CALL RODS        
      GO TO 90        
  215 CALL RODD        
      GO TO 90        
  230 CALL TUBES        
      GO TO 90        
  235 CALL TUBED        
      GO TO 90        
  240 CALL SHEARS        
      GO TO 90        
  245 CALL SHEARD        
      GO TO 90        
  250 CALL TWISTS        
      GO TO 90        
  255 CALL TWISTD        
      GO TO 90        
  260 CALL TRIA1S        
      GO TO 300        
  265 CALL TRIA1D        
      GO TO 300        
  270 CALL TRBSCS        
      GO TO 300        
  275 CALL TRBSCD        
      GO TO 300        
  280 CALL TRPLTS        
      GO TO 300        
  285 CALL TRPLTD        
      GO TO 300        
  290 CALL TRMEMS        
      GO TO 300        
  295 CALL TRMEMD        
  300 KHT = 7        
      L   = 9        
      IF (VOLUME.EQ.0 .AND. SURFAC.EQ.0) GO TO 90        
      CALL WRITE (SCR4,ELEM(IZERO+1),2,0)        
      CALL WRITE (SCR4,ESTBUF(1),1,0)        
      ESTX(5)   = ESTX(KHT)        
      ESTX(6)   = RHO        
      ESTBUF(7) = 3        
      CALL WRITE (SCR4,ESTBUF(5), 3,0)        
      CALL WRITE (SCR4,ESTBUF(2), 3,0)        
      CALL WRITE (SCR4,ESTBUF(L),12,1)        
      GO TO 90        
  310 KHT = 8        
      L   = 10        
  315 IF (VOLUME.EQ.0 .AND. SURFAC.EQ.0) GO TO 90        
      CALL WRITE (SCR4,ELEM(IZERO+1),2,0)        
      CALL WRITE (SCR4,ESTBUF(1),1,0)        
      ESTX(5)   = ESTX(KHT)        
      ESTX(6)   = RHO        
      ESTBUF(7) = 4        
      CALL WRITE (SCR4,ESTBUF(5), 3,0)        
      CALL WRITE (SCR4,ESTBUF(2), 4,0)        
      CALL WRITE (SCR4,ESTBUF(L),16,1)        
      GO TO 90        
  320 NSCAL1 = 1        
      GO TO 346        
  325 NSCAL1 = 2        
      GO TO 346        
  335 NSCAL1 = 3        
      GO TO 346        
  345 NSCAL1 = 4        
  346 NSCAL2 = 1        
      GO TO 487        
  350 CALL QDPLTS        
  352 KHT = 10        
      L   = 14        
      GO TO 315        
  355 CALL QDPLTD        
      GO TO 352        
  360 CALL QDMEMS        
      GO TO 310        
  365 CALL QDMEMD        
      GO TO 310        
  370 CALL TRIA2S        
      GO TO 300        
  375 CALL TRIA2D        
      GO TO 300        
  380 CALL QUAD2S        
      GO TO 310        
  385 CALL QUAD2D        
      GO TO 310        
  390 CALL QUAD1S        
  392 IF (ESTX(12) .LE. 0.0) ESTX(12) = ESTX(8)        
      KHT = 12        
      L   = 14        
      GO TO 315        
  395 CALL QUAD1D        
      GO TO 392        
  405 NSCAL1 = 1        
      GO TO 436        
  415 NSCAL1 = 2        
      GO TO 436        
  425 NSCAL1 = 3        
      GO TO 436        
  435 NSCAL1 = 4        
  436 NSCAL2 = 3        
      GO TO 487        
  440 CALL VISCS        
      IF (FLAGS(3) .EQ. 0) WRITE (OUTPT,442) UWM        
  442 FORMAT (A25,' 2422, VISC DATA NOT PROCESSED BY EMGPRO.')        
      GO TO 90        
  445 CALL VISCD        
      IF (FLAGS(3) .EQ. 0) WRITE (OUTPT,442) UWM        
      GO TO 90        
  455 NSCAL1 = 1        
      GO TO 486        
  465 NSCAL1 = 2        
      GO TO 486        
  475 NSCAL1 = 3        
      GO TO 486        
  485 NSCAL1 = 4        
  486 NSCAL2 = 2        
  487 CALL SCALED (NSCAL1,NSCAL2)        
      GO TO 90        
  490 CALL CONM1S        
      GO TO 90        
  495 CALL CONM1D        
      GO TO 90        
  500 CALL CONM2S        
      GO TO 90        
  505 CALL CONM2D        
      GO TO 90        
  510 CALL PLOTLS        
      GO TO 90        
  515 CALL PLOTLD        
      GO TO 90        
  540 CALL BARS        
      GO TO 90        
  545 CALL BARD        
      GO TO 90        
  550 CALL CONES        
      GO TO 90        
  555 CALL CONED        
      GO TO 90        
  560 CALL TRIARS        
      GO TO 90        
  565 CALL TRIARD        
      GO TO 90        
  570 CALL TRAPRS        
      GO TO 90        
  575 CALL TRAPRD        
      GO TO 90        
  580 CALL TORDRS        
      GO TO 90        
  585 CALL TORDRD        
      GO TO 90        
  590 CALL TETRAS        
      GO TO 90        
  595 CALL TETRAD        
      GO TO 90        
  600 CALL WEDGES        
      GO TO 90        
  605 CALL WEDGED        
      GO TO 90        
  610 CALL HEXA1S        
      GO TO 90        
  615 CALL HEXA1D        
      GO TO 90        
  620 CALL HEXA2S        
      GO TO 90        
  625 CALL HEXA2D        
      GO TO 90        
  630 CALL FLUD2S        
      GO TO 90        
  635 CALL FLUD2D        
      GO TO 90        
  640 CALL FLUD3S (IOPT)        
      GO TO 90        
  645 CALL FLUD3D (IOPT)        
      GO TO 90        
  650 CALL FLUD4S (IOPT)        
      GO TO 90        
  655 CALL FLUD4D (IOPT)        
      GO TO 90        
  660 CALL FLMASS        
      GO TO 90        
  665 CALL FLMASD        
      GO TO 90        
  670 CALL AXIF2S        
      GO TO 90        
  675 CALL AXIF2D        
      GO TO 90        
  680 CALL AXIF3S        
      GO TO 90        
  685 CALL AXIF3D        
      GO TO 90        
  690 CALL AXIF4S        
      GO TO 90        
  695 CALL AXIF4D        
      GO TO 90        
  700 CALL SLOT3S        
      GO TO 90        
  705 CALL SLOT3D        
      GO TO 90        
  710 CALL SLOT4S        
      GO TO 90        
  715 CALL SLOT4D        
      GO TO 90        
  720 CALL HBDYS        
      GO TO 90        
  725 CALL HBDYD        
      GO TO 90        
  730 CALL KDUM1        
      GO TO 90        
  740 CALL KDUM2        
      GO TO 90        
  750 CALL KDUM3        
      GO TO 90        
  760 CALL KDUM4        
      GO TO 90        
  770 CALL KDUM5        
      GO TO 90        
  780 CALL KDUM6        
      GO TO 90        
  790 CALL KDUM7        
      GO TO 90        
  800 CALL KDUM8        
      GO TO 90        
  810 CALL KDUM9        
      GO TO 90        
  820 IF (.NOT.HEAT) GO TO 822        
      IF (IQDMM1 .NE. 0) GO TO 360        
      ASSIGN 360 TO RET        
      IQDMM1 = 1        
      GO TO 1000        
  822 CALL QDMM1S        
      GO TO 310        
  825 IF (.NOT.HEAT) GO TO 827        
      IF (IQDMM1 .NE. 0) GO TO 365        
      ASSIGN 365 TO RET        
      IQDMM1 = 1        
      GO TO 1000        
  827 CALL QDMM1D        
      GO TO 310        
  830 IF (.NOT.HEAT) GO TO 832        
      IF (IQDMM2 .NE. 0) GO TO 360        
      ASSIGN 360 TO RET        
      IQDMM2 = 1        
      GO TO 1000        
  832 CALL QDMM2S        
      GO TO 310        
  835 IF (.NOT.HEAT) GO TO 837        
      IF (IQDMM2 .NE. 0) GO TO 365        
      ASSIGN 365 TO RET        
      IQDMM2 = 1        
      GO TO 1000        
  837 CALL QDMM2D        
      GO TO 310        
  840 CALL FTUBE        
      GO TO 90        
  850 CALL IHEXS (ELTYPE-64)        
      GO TO 90        
  855 CALL IHEXD (ELTYPE-64)        
      GO TO 90        
  880 CALL TRIAAX        
      GO TO 90        
  885 CALL TRIAAD        
      GO TO 90        
  890 CALL TRAPAX        
      GO TO 90        
  895 CALL TRAPAD        
      GO TO 90        
  900 CALL KTRM6S        
      L = 14        
      GO TO 927        
  905 CALL KTRM6D        
      L = 14        
      GO TO 927        
  910 CALL KTRPLS        
      L = 24        
      GO TO 927        
  915 CALL KTRPLD        
      L = 24        
      GO TO 927        
  920 CALL KTSHLS        
      L = 28        
      GO TO 927        
  925 CALL KTSHLD        
      L = 28        
  927 IF (VOLUME.EQ.0.0 .AND. SURFAC.EQ.0.0) GO TO 90        
      ESTX(8) = ELEM(IZERO+1)        
      ESTX(9) = ELEM(IZERO+2)        
      IF (ESTX(11) .LE. 0.0) ESTX(11) = ESTX(10)        
      IF (ESTX(12) .LE. 0.0) ESTX(12) = ESTX(10)        
      THK = (ESTX(10) + ESTX(11) + ESTX(12))/3.        
      ESTBUF(10) = ESTBUF(1)        
      ESTX  (11) = THK        
      ESTX  (12) = RHO        
      ESTBUF(13) = 6        
      CALL WRITE (SCR4,ESTBUF(8), 6,0)        
      CALL WRITE (SCR4,ESTBUF(2), 6,0)        
      CALL WRITE (SCR4,ESTBUF(L),24,1)        
      GO  TO  90        
  930 CALL IS2D8S        
      GO TO 90        
  935 CALL IS2D8D        
      GO TO 90        
  940 CALL ELBOWS        
      GO TO 90        
  945 CALL ELBOWD        
      GO TO 90        
  950 CALL QUAD4S        
      GO TO 90        
  955 CALL QUAD4D        
      GO TO 90        
  960 CALL TRIA3S        
      GO TO 90        
  965 CALL TRIA3D        
      GO TO 90        
C        
C     PRINT WARNING MESSAGE TO INDICATE THAT QDMEM1 ELEMENTS        
C     (ELEMENT TYPE 62) AND QDMEM2 ELEMENTS (ELEMENT TYPE 63)        
C     ARE REPLACED BY QDMEM ELEMENTS (ELEMENT TYPE 16) IN        
C     -HEAT- FORMULATION        
C        
 1000 INDEX  = 15*INCR        
      INDEX1 = 16        
      CALL PAGE2 (3)        
      WRITE  (OUTPT,1100) UWM,ELEM(IZERO+1),ELEM(IZERO+2),ELTYPE,       
     1                    ELEM(INDEX+1),ELEM(INDEX+2),INDEX1        
 1100 FORMAT (A25,' 3144, EMGPRO FINDS ',2A4,' ELEMENTS (ELEMENT TYPE ',
     1       I3,') PRESENT IN A HEAT FORMULATION AND IS',/5X,'REPLACING'
     2,      ' THE SAME BY ',2A4,' ELEMENTS (ELEMENT TYPE ',I3,2H).)    
      GO TO RET, (360,365)        
C        
C     ALL ELEMENTS OF THIS ELEMENT TYPE PROCESSED.        
C     COMPLETE DICTIONARY RECORD FOR ELEMENT TYPE.        
C        
 1200 IF (ERROR) GO TO 1310        
      DO 1300 I = 1,3        
      IF (FLAGS(I) .LE. 0) GO TO 1300        
      FLAGS(I) = -FLAGS(I)        
      CALL WRITE (DICTN(I),0,0,EOR)        
 1300 CONTINUE        
C        
C     FOR SAFETY AND IF CONGRUENCY EXISTS CLEAR OFF ANY TABLE POINTERS  
C     ON PRIMARY-IDS IN THE CONGRUENCY LIST        
C        
 1310 IF (.NOT.ANYCON) GO TO 10        
      DO 1330 I = ICONG,NCONG,2        
      IF (Z(I+1) .LT. 0) Z(I+1) = 0        
 1330 CONTINUE        
      GO TO 10        
C        
C     ALL ELEMENT TYPES HAVE BEEN PROCESSED.        
C        
 1340 CONTINUE        
      IF (KNOGO.GT.0 .OR. MNOGO.GT.0) CALL MESAGE (-61,0,0)        
      RETURN        
C        
C     IMPROPER ENCOUNTER OF AN -EOF-        
C        
 1350 JFILE = EST        
 1355 CALL MESAGE (-2,JFILE,SUBR)        
C        
C     IMPROPER ENCOUNTER OF AN -EOR-        
C        
 1360 JFILE = EST        
      CALL MESAGE (-3,JFILE,SUBR)        
C        
C     FILE NOT IN FIST        
C        
 1370 CALL MESAGE (-1,JFILE,SUBR)        
C        
C     COMPUTE MAPPING DATA FOR CONGRUENT ELEMENTS        
C        
 1380 L1 = NSILS        
      DO 1430 L = I1,I2        
      IF (ESTBUF(L) .EQ. 0) GO TO 1420        
      M = 1        
      DO 1410 N = I1,I2        
      IF (ESTBUF(N)-ESTBUF(L)) 1400,1390,1410        
 1390 IF (N.GE.L) GO TO 1410        
 1400 IF (ESTBUF(N) .NE. 0) M = M + 1        
 1410 CONTINUE        
      GO TO 1425        
 1420 M  = L1        
      L1 = L1 - 1        
 1425 IPOS(M) = L - I1 + 1        
      SIL(M) = ESTBUF(L)        
 1430 CONTINUE        
      IF (IGOTO .EQ. 1) GO TO 133        
      DO 1460 L = I1,I2        
      L1 = L - I1 + 1        
      DO 1440 N = 1,NSILS        
      IF (ESTBUF(L) .NE. SIL(N)) GO TO 1440        
      IZ(ICG+L1+4) = N        
      GO TO 1450        
 1440 CONTINUE        
 1450 IZ(ICG+NSILS+L1+4) = IPOS(L1)        
 1460 CONTINUE        
      GO TO 150        
C        
C     CHECK IF THE ELEMENT MATRIX IS DIAGONAL        
C        
 1600 IF (IZ(IADD+1) .NE. 2) GO TO 1604        
C        
C     ELEMENT MATRIX IS DIAGONAL.        
C     RE-WRITE ONLY THE ELEMENT DICTIONARY FOR A CONGRUENT ELEMENT.     
C        
      DO 1602 L = 1,NSILS        
      M = IPOS(L)        
      N = IZ(INDCNG+M+4) - 1        
      CALL WRITE (DICTN(J),Z(IADDD+N),1,NOEOR)        
 1602 CONTINUE        
      GO TO 140        
C        
C     ELEMENT MATRIX IS SQUARE.        
C     PICK UP ELEMENT MATRIX DATA FOR A CONGRUENT ELEMENT THAT HAS      
C     ALREADY BEEN PROCESSED AND STORE IT ON SCR3.        
C        
 1604 IBUF1 = NCORE - SYSBUF - 2        
      ICRQ  = JCORE - IBUF1        
      IF (ICRQ .GT. 0) GO TO 1840        
      IBUF3 = IBUF1 - 1        
      ICRQ  = JCORE - IBUF3 + 36*NSILS*IPREC        
      IF (ICRQ .GT. 0) GO TO 1840        
      IFILE = MATS(J)        
      IF (IZ(INDCNG+J+1) .NE. 0) GO TO 1640        
      CALL SAVPOS (IFILE,ISAVE1)        
      CALL CLOSE  (IFILE,1)        
      IBUF2 = IBUF(IBFIND+1)        
      CALL GOPEN  (IFILE,Z(IBUF2),0)        
      CALL FILPOS (IFILE,Z(IADDD))        
      IF (ISAVE2 .NE. 0) GO TO 1605        
      CALL GOPEN (SCR3,Z(IBUF1),1)        
      GO TO 1607        
 1605 JFILE = SCR3        
      CALL OPEN (*1370,SCR3,Z(IBUF1),3)        
 1607 JFILE = IFILE        
      DO 1620 L1 = 1,NSILS        
      CALL READ  (*1355,*1610,IFILE,Z(JCORE),IBUF3,EOR,N)        
 1610 CALL WRITE (SCR3,Z(JCORE),N,EOR)        
      IF (L1 .EQ. 1) CALL SAVPOS (SCR3,IZ(INDCNG+J+1))        
 1620 CONTINUE        
      CALL FILPOS (IFILE,ISAVE1)        
      CALL SKPREC (IFILE,1)        
      CALL CLOSE  (IFILE,2)        
      CALL OPEN   (*1370,IFILE,Z(IBUF2),3)        
      CALL SAVPOS (SCR3,ISAVE2)        
      CALL CLOSE  (SCR3,1)        
C        
C     ELEMENT MATRIX DATA IS AVAILABLE ON SCR3.  REARRANGE IT IN        
C     THE REQUIRED ORDER AND WRITE IT ON THE OUTPUT DATA BLOCK.        
C        
 1640 CALL GOPEN (SCR3,Z(IBUF1),0)        
      JFILE = SCR3        
      DO 1680 L = 1,NSILS        
      CALL FILPOS (SCR3,IZ(INDCNG+J+1))        
      M = IPOS(L)        
      N = IZ(INDCNG+M+4) - 1        
      CALL SKPREC (SCR3,N)        
      CALL READ (*1355,*1650,SCR3,Z(JCORE),IBUF3,EOR,N)        
 1650 NNWRDS = N/(NSILS*IPREC)        
      NNWRDS = SQRT(NNWRDS+0.5)        
      NWORDS = NNWRDS*IPREC        
      JJCORE = JCORE        
      DO 1670 L2 = 1,NNWRDS        
      DO 1660 L1 = 1,NSILS        
      M = IPOS(L1)        
      N = IZ(INDCNG+M+4) - 1        
      CALL WRITE (IFILE,Z(JJCORE+N*NWORDS),NWORDS,NOEOR)        
 1660 CONTINUE        
      JJCORE = JJCORE + NWORDS*NSILS        
 1670 CONTINUE        
      CALL WRITE  (IFILE,0,0,1)        
      CALL SAVPOS (IFILE,ISAVE1)        
      CALL WRITE  (DICTN(J),ISAVE1,1,NOEOR)        
 1680 CONTINUE        
      CALL FILPOS (SCR3,ISAVE2)        
      CALL SKPREC (SCR3,1)        
      CALL CLOSE  (SCR3,2)        
      GO TO 140        
 1800 WRITE (OUTPT,2000) UIM,IDPRIM        
      WRITE (OUTPT,2400) ICRQ        
      GO TO 1850        
 1820 WRITE (OUTPT,2100) SWM,ESTID        
      GO TO 1850        
 1840 WRITE (OUTPT,2200) UIM,ESTID        
      WRITE (OUTPT,2400) ICRQ        
 1850 CALL PAGE2 (4)        
      GO TO 150        
C        
 2000 FORMAT (A29,' 2382, ELEMENT MATRICES FOR ELEMENTS CONGRUENT TO ', 
     1        'ELEMENT ID =',I10, /5X,'WILL BE RE-COMPUTED AS THERE IS',
     2        ' INSUFFICIENT CORE AT THIS TIME TO HOLD CONGRUENCY ',    
     3        'MAPPING DATA.')        
 2100 FORMAT (A27,' 2383, UNABLE TO LOCATE CONGRUENCY MAPPING DATA FOR',
     1        ' ELEMENT ID =',I10,1H., /5X,'ELEMENT MATRICES FOR THIS ',
     2        'ELEMENT WILL, THEREFORE, BE RE-COMPUTED.')        
 2200 FORMAT (A29,' 2384, CONGRUENCY OF ELEMENT ID =',I10,        
     1        ' WILL BE IGNORED AND ITS ELEMENT MATRICES', /5X,        
     2        'WILL BE RE-COMPUTED AS THERE IS INSUFFICIENT CORE AT ',  
     3        'THIS TIME TO PERFORM CONGRUENCY MAPPING COMPUTATIONS.')  
 2300 FORMAT (5X,'(STEPPING THRU ONLY. NO REAL COMPUTATION HERE FOR ',  
     1        'THIS DIFFERENTIAL STIFFNESS ELEMENT)')        
 2400 FORMAT (5X,'ADDITIONAL CORE NEEDED =',I9,' WORDS.')        
C        
      END        
