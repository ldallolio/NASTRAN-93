      SUBROUTINE DS1A        
C        
C     THIS ROUTINE GENERATES THE MATRIX KGGD WHICH IS THE SECOND ORDER  
C     APPROXIMATION TO THE STIFFNESS MATRIX KGG.        
C        
      INTEGER          EOR,CLSRW,OUTRW,FROWIC,CSTM,DIT,ECPTDS,GPCT,     
     1                 BUFFR1,BUFFR2,BUFFR3,FILE,BAR,BEAM,ITYPI(20)     
      DOUBLE PRECISION DZ(1),DPWORD,DDDDDD        
      DIMENSION        NDUM(9),IZ(1),INPVT(2),NAME(2),MCBKGG(7)        
      CHARACTER        UFM*23        
      COMMON /XMSSG /  UFM        
      COMMON /BLANK /  ICOM        
      COMMON /SYSTEM/  KSYSTM(100)        
CZZ   COMMON /ZZDS1A/  Z(1)        
      COMMON /ZZZZZZ/  Z(1)        
      COMMON /DS1ADP/  DDDDDD(300)        
      COMMON /DS1AET/  ECPT(112)        
      COMMON /DS1AAA/  NPVT,ICSTM,NCSTM,IGPCT,NGPCT,IPOINT,NPOINT,      
     1                 I6X6K,N6X6K,CSTM,MPT,DIT,ECPTDS,GPCT,KGGD,       
     2                 INRW,OUTRW,EOR,NEOR,CLSRW,JMAX,FROWIC,LROWIC,    
     3                 NROWSC,NLINKS,LINK(10),NOGO        
      COMMON /GPTA1 /  NELEMS,LAST,INCR,NE(1)        
      COMMON /ZBLPKX/  DPWORD,DUM(2),INDEX        
      COMMON /CONDAS/  PI,TWOPI,RADEG,DEGRA,S4PISQ        
      EQUIVALENCE      (KSYSTM( 1),   ISYS), (KSYSTM( 2),IOUTPT),       
     1                 (KSYSTM(46),NDUM(1)), (KSYSTM(55), IPREC)        
      EQUIVALENCE      (Z(1),IZ(1),DZ(1))        
      DATA    NAME  /  4HDS1A,4H    /, BAR,BEAM / 4HBAR ,4HBEAM /       
C        
C     DEFINE VARIABLES IN COMMON /DS1AAA/        
C        
      CSTM  = 106        
      MPT   = 107        
      DIT   = 110        
      ECPTDS= 301        
      GPCT  = 109        
      KGGD  = 201        
      INRW  = 0        
      OUTRW = 1        
      EOR   = 1        
      NEOR  = 0        
      CLSRW = 1        
      NLINKS= 10        
      NOGO  = 0        
      IITYP = 0        
      J     = 26        
      NE(J) = BAR        
      CALL SSWTCH (38,L38)        
C        
C     DETERMINE SIZE OF VARIABLE CORE, AND SET UP BUFFERS        
C        
      IPR = IPREC        
      CALL DELSET        
      IZMAX  = KORSZ(Z)        
      BUFFR1 = IZMAX  - ISYS        
      BUFFR2 = BUFFR1 - ISYS        
      BUFFR3 = BUFFR2 - ISYS        
      LEFTT  = BUFFR3 - 1        
C        
C     READ THE CSTM INTO CORE        
C        
      IFILE = CSTM        
      NCSTM = 0        
      ICSTM = 0        
      CALL OPEN (*2,CSTM,Z(BUFFR1),INRW)        
      CALL FWDREC (*9020,CSTM)        
      CALL READ (*9030,*1,CSTM,Z(ICSTM+1),LEFTT,EOR,NCSTM)        
      CALL MESAGE (-8,0,NAME)        
    1 LEFTT = LEFTT - NCSTM        
C        
C     PRETRD SETS UP SUBSEQUENT CALLS TO TRANSD.        
C        
      CALL PRETRS (Z(ICSTM+1),NCSTM)        
      CALL PRETRD (Z(ICSTM+1),NCSTM)        
      CALL CLOSE  (CSTM,CLSRW)        
    2 IMAT1 = NCSTM        
C        
C     CALL PREMAT TO READ MPT AND DIT INTO CORE.        
C        
      CALL PREMAT (Z(IMAT1+1),Z(IMAT1+1),Z(BUFFR1),LEFTT,MATCR,MPT,DIT) 
      LEFTT = LEFTT - MATCR        
      IGPCT = NCSTM + MATCR        
C        
C     OPEN KGGD, ECPTDS AND GPCT        
C        
      CALL GOPEN  (KGGD,Z(BUFFR1),OUTRW)        
      CALL MAKMCB (MCBKGG,KGGD,0,6,IPR)        
      CALL GOPEN  (ECPTDS,Z(BUFFR2),INRW)        
      CALL GOPEN  (GPCT,Z(BUFFR3),INRW)        
C        
C     READ THE FIRST TWO WORDS OF NEXT GPCT RECORD INTO INPVT(1).       
C     INPVT(1) IS THE PIVOT POINT.  INPVT(1) .GT. 0 IMPLIES THE PIVOT   
C     POINT IS A GRID POINT.  INPVT(1) .LT. 0 IMPLIES THE PIVOT POINT IS
C     A SCALAR POINT.  INPVT(2) IS THE NUMBER OF WORDS IN THE REMAINDER 
C     OF THIS RECORD OF THE GPCT.        
C        
   10 FILE = GPCT        
      CALL READ (*1000,*700,GPCT,INPVT(1),2,NEOR,IFLAG)        
      NGPCT = INPVT(2)        
      CALL FREAD (GPCT,IZ(IGPCT+1),NGPCT,EOR)        
      IF (INPVT(1) .LT. 0) GO TO 700        
C        
C     FROWIC IS THE FIRST ROW IN CORE. (1 .LE. FROWIC .LE. 6)        
C        
      FROWIC = 1        
C        
C     DECREMENT THE AMOUNT OF CORE REMAINING.        
C        
      LEFT   = LEFTT - 2*NGPCT        
      IF (LEFT .LE. 0) CALL MESAGE (-8,0,NAME)        
      IPOINT = IGPCT + NGPCT        
      NPOINT = NGPCT        
      I6X6K  = IPOINT + NPOINT        
      I6X6K  = (I6X6K - 1)/2 + 2        
C        
C     CONSTRUCT THE POINTER TABLE, WHICH WILL ENABLE SUBROUTINE DS1B TO 
C     INSERT THE 6 X 6 MATRICES INTO KGGD.        
C        
      IZ(IPOINT+1) = 1        
      I1 = 1        
      I  = IGPCT        
      J  = IPOINT + 1        
   30 I1 = I1 + 1        
      IF (I1 .GT. NGPCT) GO TO 40        
      I  = I + 1        
      J  = J + 1        
      INC= 6        
      IF (IZ(I) .LT. 0) INC = 1        
      IZ(J) = IZ(J-1) + INC        
      GO TO 30        
C        
C     JMAX = NO. OF COLUMNS OF KGGD THAT WILL BE GENERATED WITH THE     
C     CURRENT GRID POINT.        
C        
   40 INC   = 5        
      ILAST = IGPCT  + NGPCT        
      JLAST = IPOINT + NPOINT        
      IF (IZ(ILAST) .LT. 0) INC = 0        
      JMAX  = IZ(JLAST) + INC        
C        
C     IF 2*6*JMAX .LT. LEFT THERE ARE NO SPILL LOGIC PROBLEMS FOR       
C     KGGD SINCE THE WHOLE DOUBLE PRECISION SUBMATRIX OF ORDER 6 X JMAX 
C     CAN FIT IN CORE.        
C        
      ITEMP = 6*JMAX        
      IF (2*ITEMP .LT. LEFT) GO TO 80        
      NAME(2) = INPVT(1)        
      CALL MESAGE (30,85,NAME)        
      NROWSC = 3        
   70 IF (2*NROWSC*JMAX .LT. LEFT) GO TO 90        
      NROWSC = NROWSC - 1        
      IF (NROWSC .EQ. 0) CALL MESAGE (-8,0,NAME)        
      GO TO 70        
   80 NROWSC = 6        
C        
C     LROWIC IS THE LAST ROW IN CORE. (1 .LE. LROWIC .LE. 6)        
C        
   90 LROWIC = FROWIC + NROWSC - 1        
C        
C     ZERO OUT THE KGGD SUBMATRIX IN CORE.        
C        
  100 LOW = I6X6K + 1        
      LIM = I6X6K + JMAX*NROWSC        
      DO 115 I = LOW,LIM        
  115 DZ(I) = 0.0D0        
C        
C     INITIALIZE THE LINK VECTOR TO -1.        
C        
      DO 140 I = 1,NLINKS        
  140 LINK(I) = -1        
C        
C     TURN FIRST PASS INDICATOR ON.        
C        
  150 IFIRST = 1        
C        
C     READ THE 1ST WORD OF THE ECPT RECORD, THE PIVOT POINT, INTO NPVT. 
C     IF NPVT .LT. 0, THE REMAINDER OF THE ECPT RECORD IS NULL SO THAT  
C     1 OR 6 NULL COLUMNS MUST BE GENERATED        
C        
      FILE = ECPTDS        
      CALL FREAD (ECPTDS,NPVT,1,NEOR)        
      IF (NPVT .LT. 0) GO TO 700        
C        
C     READ THE NEXT ELEMENT TYPE INTO THE CELL ITYPE.        
C        
  160 CALL READ (*9020,*500,ECPTDS,ITYPE,1,NEOR,IFLAG)        
C        
C     READ THE ECPT ENTRY FOR THE CURRENT TYPE INTO THE ECPT ARRAY. THE 
C     NUMBER OF WORDS TO BE READ WILL BE NWORDS(ITYPE).        
C        
      IP = IPREC        
      IF (IP .NE. 1) IP = 0        
      JTYP  = 2*ITYPE - IP        
      NFREE = 3        
      IF (ITYPE.EQ.2 .OR. ITYPE.EQ.35. OR. ITYPE.EQ.75) NFREE = 6       
C               BEAM             CONEAX           TRSHL        
      IF (ITYPE.GE.53 .AND. ITYPE.LE.61) NFREE = MOD(NDUM(ITYPE-52),10) 
C                DUM1              DUM9        
      IDX = (ITYPE-1)*INCR        
      NWORDS = NE(IDX+12) + 2 + NFREE*NE(IDX+10)        
      IF (ITYPE.GE.65 .AND. ITYPE.LE.67) NWORDS = NWORDS + NE(IDX+10) -1
C               IHEX1             IHEX3        
      IF (ITYPE .EQ. 80) NWORDS = NWORDS + NE(IDX+10)        
C                 IS2D8        
      IF (ITYPE .EQ. 35) NWORDS = NWORDS + 1        
C                CONEAX        
      IF (NE(IDX+12) .LE. 0) CALL MESAGE (-61,0,NAME)        
      CALL FREAD (ECPTDS,ECPT,NWORDS,NEOR)        
      ITEMP = NE(IDX+24)        
C        
C     IF THIS IS THE 1ST ELEMENT READ ON THE CURRENT PASS OF THE ECPT   
C     CHECK TO SEE IF THIS ELEMENT IS IN A LINK THAT HAS ALREADY BEEN   
C     PROCESSED.        
C        
      IF (IFIRST .EQ. 1) GO TO 170        
C        
C     THIS IS NOT THE FIRST PASS.  IF ITYPE(TH) ELEMENT ROUTINE IS IN   
C     CORE, PROCESS IT.        
C        
      IF (ITEMP .EQ. LINCOR) GO TO 171        
C        
C     THE ITYPE(TH) ELEMENT ROUTINE IS NOT IN CORE.  IF THIS ELEMENT    
C     ROUTINE IS IN A LINK THAT ALREADY HAS BEEN PROCESSED READ THE NEXT
C     ELEMENT.        
C        
      IF (LINK(ITEMP) .EQ. 1) GO TO 160        
C        
C     SET A TO BE PROCESSED LATER FLAG FOR THE LINK IN WHICH THE ELEMENT
C     RESIDES        
C        
      LINK(ITEMP) = 0        
      GO TO 160        
C        
C     SINCE THIS IS THE FIRST ELEMENT TYPE TO BE PROCESSED ON THIS PASS 
C     OF THE ECPT RECORD, A CHECK MUST BE MADE TO SEE IF THIS ELEMENT   
C     IS IN A LINK THAT HAS ALREADY BEEN PROCESSED.  IF IT IS SUCH AN   
C     ELEMENT, WE KEEP IFIRST = 1 AND READ THE NEXT ELEMENT.        
C        
  170 IF (LINK(ITEMP) .EQ. 1) GO TO 160        
C        
C     SET THE CURRENT LINK IN CORE = ITEMP AND IFIRST = 0        
C        
      LINCOR = ITEMP        
      IFIRST = 0        
C        
C     CALL THE PROPER ELEMENT ROUTINE.        
C        
  171 IF (ITYPE.LE.0 .OR. ITYPE.GT.NELEMS) CALL MESAGE (-7,0,NAME)      
C        
C     IF DIAG 38 IS ON, ECHO TYPE OF ELEMENT BEING PROCESSED        
C        
      IF (L38   .EQ. 0) GO TO 180        
      IF (IITYP .EQ. 0) GO TO 175        
      DO 173 II = 1,IITYP        
      IF (ITYPE .EQ. ITYPI(II)) GO TO 180        
  173 CONTINUE        
      IF (IITYP .GE. 20) GO TO 180        
  175 IITYP = IITYP + 1        
      ITYPI(IITYP) = ITYPE        
      WRITE  (IOUTPT,177) NE(IDX+1),NE(IDX+2),ITYPE        
  177 FORMAT ('0*** DS1 MODULE PROCESSING ',2A4,' ELEMENTS (ELEM.TYPE', 
     1        I4,1H))        
C        
  180 LOCAL = JTYP - 100        
      IF (LOCAL) 181,181,182        
  181 GO TO (        
C        
C        1-CROD       2-CBEAM      3-CTUBE      4-CSHEAR     5-CTWIST   
     O   210,  210,   220,  220,   230,  230,   240,  240,  9040, 9040, 
C        
C        6-CTRIA1     7-CTRBSC     8-CTRPLT     9-CTRMEM     10-CONROD  
     1   260,  260,  9040, 9040,  9040, 9040,   250,  250,   210,  210, 
C        
C        11-CELAS1    12-CELAS2    13-CELAS3    14-CELAS4    15-CQDPLT  
     2  9040, 9040,  9040, 9040,  9040, 9040,  9040, 9040,  9040, 9040, 
C        
C        16-CQDMEM    17-CTRIA2    18-CQUAD2    19-CQUAD1    20-CDAMP1  
     3   280,  280,   270,  270,   300,  300,   290,  290,  9040, 9040, 
C        
C        21-CDAMP2    22-CDAMP3    23-CDAMP4    24-CVISC     25-CMASS1  
     4  9040, 9040,  9040, 9040,  9040, 9040,  9040, 9040,  9040, 9040, 
C        
C        26-CMASS2    27-CMASS3    28-CMASS4    29-CONM1     30-CONM2   
     5  9040, 9040,  9040, 9040,  9040, 9040,  9040, 9040,  9040, 9040, 
C        
C        31-PLOTEL    32-X         33-X         34-CBAR      35-CCONEAX 
     6  9040, 9040,  9040, 9040,  9040, 9040,  9040, 9040,   370,  370, 
C        
C        36-CTRIARG   37-CTRAPRG   38-CTORDRG   39-CTETRA    40-CWEDGE  
     7  9040, 9040,  9040, 9040,  9040, 9040,  9040, 9040,  9040, 9040, 
C        
C        41-CHEXA1    42-CHEXA2    43-CFLUID2   44-CFLUID3   45-CFLUID4 
     8  9040, 9040,  9040, 9040,  9040, 9040,  9040, 9040,  9040, 9040, 
C        
C        46-CFLMASS   47-CAXIF2    48-CAXIF3    49-CAXIF4    50-CSLOT3  
     9  9040, 9040,  9040, 9040,  9040, 9040,  9040, 9040,  9040, 9040  
C        
     X   ), JTYP        
C        
  182 GO TO (        
C        
C        51-CSLOT4    52-CHBDY     53-CDUM1     54-CDUM2     55-CDUM3   
     X  9040, 9040,  9040, 9040,   321,  321,   322,  322,   323,  323, 
C        
C        56-CDUM4     57-CDUM5     58-CDUM6     59-CDUM7     60-CDUM8   
     A   324,  324,   325,  325,   326,  326,   327,  327,   328,  328, 
C        
C        61-CDUM9     62-CQDMEM1   63-CQDMEM2   64-CQUAD4    65-CIHEX1  
     B   329,  329,  9040, 9040,  9040, 9040,   305,  305,   310,  310, 
C        
C        66-CIHEX2    67-CIHEX3    68-CQUADTS   69-CTRIATS   70-CTRIAAX 
     C   310,  310,   310,  310,   311,  311,   312,  312,  9040, 9040, 
C        
C        71-CTRAPAX   72-CAERO1    73-CTRIM6    74-CTRPLT1   75-CTRSHL  
     D  9040, 9040,  9040, 9040,  9040, 9040,  9040, 9040,   313,  314, 
C        
C        76-CFHEX1    77-CFHEX2    78-CFTETRA   79-CFWEDGE   80-CIS2D8  
     E  9040, 9040,  9040, 9040,  9040, 9040,  9040, 9040,   315,  315, 
C        
C        81-CELBOW    82-FTUBE     83-CTRIA3    84-CPSE2     85-CPSE3   
     F  9040, 9040,  9040, 9040,   275,  275,   380,  380,   385,  385, 
C        
C        86-CPSE4        
     G   390,  390        
C        
     X   ), LOCAL        
C        
C     ROD        
C        
  210 CALL DROD        
      GO TO 160        
C        
C     BAR        
C        
  220 CALL DBAR        
      GO TO 160        
C        
C     TUBE        
C        
  230 TEMP = ECPT(5) - ECPT(6)        
      A  = TEMP*ECPT(6)*PI        
      FJ = .25*A*(TEMP**2 + ECPT(6)**2)        
      C  = .5*ECPT(5)        
      M  = 26        
      DO 235 I = 1,18        
      M = M - 1        
  235 ECPT(M) = ECPT(M-1)        
      GO TO 210        
C        
C     SHEAR        
C        
  240 CALL DSHEAR        
      GO TO 160        
C        
C     TRMEM        
C        
  250 CALL DTRMEM (0)        
      GO TO 160        
C        
C     TRIA1        
C        
  260 CALL DTRIA (1)        
      GO TO 160        
C        
C     TRIA2        
C        
  270 CALL DTRIA (2)        
      GO TO 160        
C        
C     TRIA3        
C        
  275 CALL DTRIA (3)        
      GO TO 160        
C        
C     QDMEM        
C        
  280 CALL DQDMEM        
      GO TO 160        
C        
C     QUAD1        
C        
  290 CALL DQUAD (1)        
      GO TO 160        
C        
C     QUAD2        
C        
  300 CALL DQUAD (2)        
      GO TO 160        
C        
C     QUAD4        
C        
  305 CALL DQUAD (4)        
      GO TO 160        
C        
C     IHEX1,IHEX2,IHEX3        
C        
  310 CALL DIHEX (ITYPE-64)        
      GO TO 160        
C        
C     QUADTS        
C        
  311 CONTINUE        
      GO TO 160        
C        
C    TRIATS        
C        
  312 CONTINUE        
      GO TO 160        
  313 CALL DTSHLS        
      GO TO 160        
  314 CALL DTSHLD        
      GO TO 160        
  315 CALL DIS2D8        
      GO TO 160        
C        
C     DUMMY ELEMENTS        
C        
  321 CALL DDUM1        
      GO TO 160        
  322 CALL DDUM2        
      GO TO 160        
  323 CALL DDUM3        
      GO TO 160        
  324 CALL DDUM4        
      GO TO 160        
  325 CALL DDUM5        
      GO TO 160        
  326 CALL DDUM6        
      GO TO 160        
  327 CALL DDUM7        
      GO TO 160        
  328 CALL DDUM8        
      GO TO 160        
  329 CALL DDUM9        
      GO TO 160        
C        
C     CONE        
C        
  370 CALL DCONE        
      GO TO 160        
C        
C     PRESSURE STIFFNESS ELEMENTS        
C        
  380 CALL DPSE2        
      GO TO 160        
  385 CALL DPSE3        
      GO TO 160        
  390 CALL DPSE4        
      GO TO 160        
C        
C     AT STATEMENT NO. 500 WE HAVE HIT AN EOR ON THE ECPT FILE.  SEARCH 
C     THE LINK VECTOR TO DETERMINE IF THERE ARE LINKS TO BE PROCESSED.  
C        
  500 LINK(LINCOR) = 1        
      DO  510 I = 1,NLINKS        
      IF (LINK(I) .EQ. 0) GO TO 520        
  510 CONTINUE        
      GO TO 525        
C        
C     SINCE AT LEAST ONE LINK HAS NOT BEEN PROCESSED THE ECPT FILE MUST 
C     BE BACKSPACED.        
C        
  520 CALL BCKREC (ECPTDS)        
      GO TO 150        
C        
C     CHECK NOGO FLAG. IF NOGO=1, SKIP BLDPK AND PROCESS ANOTHER RECORD 
C     FROM THE GPCT TABLE        
C        
  525 IF (NOGO .EQ. 1) GO TO 10        
C        
C     AT THIS POINT BLDPK THE NUMBER OF ROWS IN CORE UNTO THE KGG FILE. 
C        
      IFILE = KGGD        
      I1 = 0        
  540 I2 = 0        
      IBEG = I6X6K + I1*JMAX        
      CALL BLDPK (2,IPR,IFILE,0,0)        
  550 I2 = I2 + 1        
      IF (I2 .GT. NGPCT) GO TO 570        
      JJ = IGPCT + I2        
      INDEX = IABS(IZ(JJ)) - 1        
      LIM = 6        
      IF (IZ(JJ) .LT. 0) LIM = 1        
      JJJ = IPOINT + I2        
      KKK = IBEG + IZ(JJJ) - 1        
      I3  = 0        
  560 I3  = I3 + 1        
      IF (I3 .GT. LIM) GO TO 550        
      INDEX = INDEX + 1        
      KKK = KKK + 1        
      DPWORD = DZ(KKK)        
      IF (DPWORD .NE. 0.0D0) CALL ZBLPKI        
      GO TO 560        
  570 CALL BLDPKN (IFILE,0,MCBKGG)        
      I1 = I1 + 1        
      IF (I1 .LT. NROWSC) GO TO 540        
C        
C     TEST TO SEE IF THE LAST ROW IN CORE, LROWIC, = THE TOTAL NO. OF   
C     ROWS TO BE COMPUTED = 6.  IF IT IS, WE ARE DONE.  IF NOT, THE     
C     ECPTDS MUST BE BACKSPACED.        
C        
      IF (LROWIC .EQ. 6) GO TO 10        
      CALL BCKREC (ECPTDS)        
      FROWIC = FROWIC + NROWSC        
      LROWIC = LROWIC + NROWSC        
      GO TO 100        
  700 IF (NOGO .EQ. 1) GO TO 10        
C        
C     HERE WE HAVE A PIVOT POINT WITH NO ELEMENTS CONNECTED, SO THAT    
C     NULL COLUMNS MUST BE OUTPUT ON THE KGGD FILE.        
C        
      FILE = ECPTDS        
      LIM  = 6        
      IF (INPVT(1) .LT. 0) LIM = 1        
      DO 710 I = 1,LIM        
      CALL BLDPK  (2,IPR,KGGD,0,0)        
  710 CALL BLDPKN (KGGD,0,MCBKGG)        
      CALL FWDREC (*9020,ECPTDS)        
      GO TO 10        
C        
C     CHECK NOGO FLAG. IF NOGO=1, TERMINATE EXECUTION        
C        
 1000 IF (NOGO .EQ. 1) CALL MESAGE (-61,0,0)        
C        
C     WRAP UP BEFORE RETURN        
C        
      CALL CLOSE (ECPTDS,CLSRW)        
      CALL CLOSE (GPCT,CLSRW)        
      CALL CLOSE (KGGD,CLSRW)        
      MCBKGG(3) = MCBKGG(2)        
      IF (MCBKGG(6) .EQ. 0) GO TO 9050        
      CALL WRTTRL (MCBKGG)        
      J = 26        
      NE(J) = BEAM        
      RETURN        
C        
C     ERROR RETURNS        
C        
 9020 CALL MESAGE (-2,FILE,NAME)        
 9030 CALL MESAGE (-3,FILE,NAME)        
 9040 CALL MESAGE (-7,FILE,NAME)        
 9050 WRITE  (IOUTPT,9060) UFM        
 9060 FORMAT (A23,' 2402, NULL DIFFERENTIAL STIFFNESS MATRIX ',        
     1        'GENERATED IN SUBROUTINE DS1A.')        
      CALL MESAGE (-61,0,0)        
      RETURN        
      END        
