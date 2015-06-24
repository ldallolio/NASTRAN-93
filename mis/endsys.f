      SUBROUTINE ENDSYS (JOBSEG,JOBEND)        
C        
C     ENDSYS SAVES VARIOUS EXEC TABLES ON A SCRATCH FILE        
C        
C     LAST REVISED  5/91 BY G.CHAN/UNISYS  FOR SUPERLINK OPERATION      
C          IF SPERLK = 0, WE ARE IN NASTRAN MULTI-LINK COMPUTATION      
C          IF SPERLK = NON-ZERO, WE ARE IN NASTRAN SUPERLINK        
C          SPERLK IS THE 95TH WORD OF /SYSTEM/        
C        
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF        
      LOGICAL         BITPAS        
      INTEGER         ANDF,FIST,SAVE,SCRN1,SCRN2,THCRMK,POOL,SPERLK,    
     1                NOPREF(2),RSHIFT,BUF,MSGBUF(8),BCDNUM(10),UNITS,  
     2                TENS,ORF,UNITAB(75),FCB(75),DATABF,MSG(2),NAME(2),
     3                FILE,FILEX,LNKNUM(15),COMM,XF1AT,PREFAC        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25,FORTXX*7        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /MACHIN/ MACH        
      COMMON /BLANK / IBLKCM(58),PREFAC(2)        
      COMMON /XPFIST/ NPFIST        
      COMMON /XFIST / FIST(2)        
      COMMON /MSGX  / ITAB1(1)        
      COMMON /STIME / ITAB2(2)        
      COMMON /STAPID/ ITAB3(1)        
      COMMON /XDPL  / ITAB4(3)        
      COMMON /XXFIAT/ ITAB5(1)        
      COMMON /XFIAT / ITAB6(4)        
      COMMON /XVPS  / ITAB7(2)        
      COMMON /XCEITB/ ITAB8(2)        
      COMMON /GINOX / ITAB9(170)        
      COMMON /SYSTEM/ ITAB10(22),LSYSTM,ICFIAT,JTAB10(11),NPRUS,        
     1                KTAB10(35),BITPAS,LTAB10(18),LPCH,LDICT,MTAB10(2),
     2                SPERLK,NTAB10(5)        
      COMMON /OUTPUT/ ITAB11(1)        
      COMMON /NTIME / ITAB13(1)        
      COMMON /XLINK / ITAB14(1)        
      COMMON /SOFCOM/ ITAB15(1)        
      COMMON /BITPOS/ BT(32,2)        
      COMMON /OSCENT/ INOSCR(2)        
CZZ   COMMON /ZZENDS/ DATABF(1)        
      COMMON /ZZZZZZ/ DATABF(1)        
      COMMON /SEM   / MASK,THCRMK,IMASK,LINKS(15)        
      COMMON /L15 L8/ L15,L8,L13        
      COMMON /XSFA1 / DUMMY(1902),COMM(20),XF1AT(1100)        
C                           1902 = 401+1501        
C        
      EQUIVALENCE    (ITAB10( 1),ISYBUF),  (ITAB10(2),NOUT     ),       
     1               (ITAB9 ( 2),FILEX ),  (ITAB9(12),UNITAB(1)),       
     2               (ITAB9(170),FCB(1))        
      DATA MSGBUF(1)/ 4HLINK /        
      DATA MSGBUF(3)/ 4H     /        
      DATA MSGBUF(5)/ 4H---- /        
      DATA MSGBUF(6)/ 4H---- /        
      DATA MSGBUF(7)/ 4H---- /        
      DATA MSGBUF(8)/ 4H---- /        
      DATA SCRN1    , SCRN2  /4HSCRA,4HTCH0/, SAVE/4HSAVE/,        
     1     POOL     / 4HPOOL /,        
     2     NOPREF   / 4HNOT , 4HPREF/        
      DATA MSG      / 4HBEGN, 4HEND /        
      DATA BCDNUM   / 1H0, 1H1, 1H2, 1H3, 1H4, 1H5, 1H6, 1H7, 1H8, 1H9 /
      DATA LNKNUM   / 4H 1  , 4H 2  , 4H 3  , 4H 4  , 4H 5  ,        
     1                4H 6  , 4H 7  , 4H 8  , 4H 9  , 4H10  ,        
     2                4H11  , 4H12  , 4H13  , 4H14  , 4H15  /        
      DATA NAME     / 4HENDS,4HYS   /        
C        
C        
C     PUNCH RESTART DICTIONAY        
C     LDICT MAY NOT BE A SYSTEM PUNCH FILE, PUNCH THE CARDS OUT FIRST   
C     BEFORE THE RESTART DICTIONARY CARDS GET LOST        
C        
      IF (MACH.GE.5 .OR. LDICT.EQ.LPCH) GO TO 8        
      ENDFILE LDICT        
      REWIND  LDICT        
    5 READ   (LDICT,6,ERR=7,END=7) (DATABF(J),J=1,20)        
    6 FORMAT (20A4)        
      WRITE  (LPCH,6) (DATABF(J),J=1,20)        
      GO TO  5        
    7 REWIND LDICT        
C        
    8 MSGBUF(2) = 0        
      J = 0        
      DO 10 I = 1,15        
      IF (JOBEND .EQ. LINKS(I)) MSGBUF(2) = LNKNUM(I)        
      IF (JOBSEG .EQ. LINKS(I)) J = I        
   10 CONTINUE        
      IF (MSGBUF(2) .NE. 0) GO TO 15        
      WRITE  (NOUT,12) SFM,JOBEND        
   12 FORMAT (A25,', ILLEGAL LINK NUMBER ',A4,' ENCOUNTERED BY ENDSYS') 
      CALL MESAGE (-61,0,0)        
   15 MSGBUF(4) = MSG(2)        
C        
      IF (SPERLK .EQ. 0) GO TO 30        
C        
C     SIMPLIFIED OPERATION IF SUPERLINK (USED IN UNIX VERSION)        
C        
      SPERLK = J        
      ITAB10(22) = JOBSEG        
C     PREFAC(1)  = NOPREF(1)        
C     PREFAC(2)  = NOPREF(2)        
      CALL CONMSG (MSGBUF   ,4,0)        
      CALL CONMSG (MSGBUF(5),4,0)        
      DO 20 J = 2,11        
   20 ITAB9(J) = 0        
      DO 25 J = 87,161        
      IF (ITAB9(J) .EQ. 0) GO TO 25        
      I = J - 86        
      WRITE  (NOUT,23) SFM,I,JOBEND        
   23 FORMAT (A25,', LOGICAL UNIT',I5,' WAS NOT CLOSED AT END OF ',A4)  
C     ITAB9(J) = 0        
      CALL MESAGE (-37,0,0)        
   25 CONTINUE        
      GO TO 400        
C        
C     SEARCH FIAT FOR A SAVE FILE -- FILE MUST SATISFY THE FOLLOWING    
C     (1) FILE MUST BE SCRATCHX OR TRAILERS=0 OR EXPIRED*        
C     (2) IF (1) IS TRUE, NO UNEXPIRED SECONDARY ALLOCATIONS WITH       
C     NON-ZERO TRAILERS MAY EXIST. (ALSO FILE MUST NOT BE PURGED)       
C     AN EXPIRED FILE HAS AN LTU LESS THAN THE CURRENT OSCAR POSITION.  
C        
   30 FILE = SAVE        
      LMT  = ITAB6(3)*ICFIAT + 3        
      NEXT = LSHIFT(INOSCR(2),16)        
      IFOUND  = 0        
      FIST(2) = NPFIST + 1        
      FIST(2*NPFIST+3) = SAVE        
C        
      K = ANDF(THCRMK,SCRN2)        
      DO 50 I = 4,LMT,ICFIAT        
      IF (ITAB6(I+1).EQ.SCRN1 .AND. ANDF(THCRMK,ITAB6(I+2)).EQ.K)       
     1    GO TO 35        
      IF (ITAB6(I+3).NE.0 .OR. ITAB6(I+4).NE.0 .OR. ITAB6(I+5).NE.0)    
     1    GO TO 32        
      IF (ICFIAT.EQ.11 .AND.  (ITAB6(I+8).NE.0 .OR. ITAB6(I+9).NE.0 .OR.
     1    ITAB6(I+10).NE.0)) GO TO 32        
      GO TO 35        
   32 LTU = ANDF(ITAB6(I),1073676288)        
C                         1073676288 = 2**30 - 2**16 = 3FFF0000 HEX     
C                                    = 0 SIGN BIT + LEFT 14 BITS OF 1's 
      IF (LTU.GE.NEXT .OR. LTU .EQ. 0) GO TO 50        
   35 IUCB = ANDF(ITAB6(I),32767)        
C                          32767 = 2**15 - 1 = RIGHT 15 BITS OF 1's     
      IF (IUCB .EQ. 32767) GO TO 50        
      DO 40 J = 4,LMT,ICFIAT        
      IF (ANDF(ITAB6(J),32767) .NE. IUCB) GO TO 40        
      IF (I .EQ. J) GO TO 40        
      LTU = ANDF(ITAB6(J),1073676288)        
      IF (LTU.LT.NEXT .AND. LTU.NE.0) GO TO 40        
      IF (ITAB6(J+3).NE.0 .OR. ITAB6(J+4).NE.0 .OR. ITAB6(J+5).NE.0)    
     1    GO TO 50        
      IF (ICFIAT.EQ.11 .AND. (ITAB6(J+8).NE.0 .OR. ITAB6(J+9).NE.0 .OR. 
     1    ITAB6(J+10).NE.0)) GO TO 50        
   40 CONTINUE        
      IF (IFOUND .EQ. 0) IFOUND = I        
C        
C     FLUSH FILE IN CASE DATA EXISTS ON FILE        
C     THIS WILL FREE UP SECONDARIES ON 360 AND DISK ON CDC AND UNIVAC   
C        
      IF (ITAB6(I+3).NE.0 .OR. ITAB6(I+4).NE.0 .OR. ITAB6(I+5).NE.0)    
     1    GO TO 45        
      IF (ICFIAT.EQ.11 .AND. (ITAB6(I+8).NE.0 .OR. ITAB6(I+9).NE.0 .OR. 
     1    ITAB6(I+10).NE.0)) GO TO 45        
      GO TO 50        
   45 FIST(2*NPFIST+4) = I - 1        
      CALL OPEN (*360,SAVE,DATABF,1)        
      CALL CLOSE (SAVE,1)        
   50 CONTINUE        
C        
      IF (IFOUND .EQ. 0) CALL MESAGE (-39,0,0)        
      I = -2
      IF (ITAB11(1)+ITAB11(-I) .EQ. I) ICFIAT = ICFIAT + I
C        
C     GOOD NEWS - WE FOUND A FILE FOR SAVE PURPOSES.        
C     SAVE POINTER TO FILE IN BLANK COMMON.        
C        
      I = IFOUND        
      IBLKCM(1) = ITAB6(I)        
C        
C     SAVE UNIT = 2 FOR ALL MACHINES, IBM INCLUDED        
C     (IBM USED 51 BEFORE)        
C        
      IUNITU = 2        
C        
C     FCB ARREY OF 75 WORDS IS NOT USED BY VAX AND UNIX        
C        
      REWIND IUNITU        
      IF (MACH .LT. 5) WRITE (IUNITU) ITAB6(I),ISYBUF,FCB        
      IF (MACH .GE. 5) WRITE (IUNITU) ITAB6(I),ISYBUF        
      REWIND IUNITU        
      FIST(2*NPFIST+4) = I - 1        
C        
C     SET PREFAC FLAG SO LINK 1 IS RE-ENTRANT        
C        
C     PREFAC(1) = NOPREF(1)        
C     PREFAC(2) = NOPREF(2)        
C        
C     SAVE THE NEXT LINK NO. IN THE 22ND WORD OF /SYSTEM/        
C        
      ITAB10(22) = JOBSEG        
C        
C     WRITE EXEC TABLES ON THE FILE JUST FOUND.        
C        
      CALL OPEN  (*360,SAVE,DATABF,1)        
      LTAB10(7)  = 0        
      CALL WRITE (SAVE,ITAB10,LSYSTM,1)        
      CALL WRITE (SAVE,ITAB1,ITAB1(1)*4+2,1)        
      CALL WRITE (SAVE,ITAB2,1,1)        
      CALL WRITE (SAVE,ITAB3,6,1)        
      CALL WRITE (SAVE,ITAB4,ITAB4(3)*3+3,1)        
      CALL WRITE (SAVE,ITAB5,NPFIST,1)        
      CALL WRITE (SAVE,ITAB6,ITAB6(3)*ICFIAT+3,1)        
      CALL WRITE (SAVE,ITAB7,ITAB7(2),1)        
      CALL WRITE (SAVE,ITAB8,ITAB8(2),1)        
      CALL WRITE (SAVE,ITAB9(12),75,1)        
      CALL WRITE (SAVE,ITAB11,224,1)        
      CALL WRITE (SAVE,ITAB13,ITAB13(1)+1,1)        
      CALL WRITE (SAVE,ITAB14,ITAB14(1)+2,1)        
      CALL WRITE (SAVE,ITAB15,27,1)        
      CALL WRITE (SAVE,BT,64,1)        
      CALL CLOSE (SAVE,1)        
C        
C     FLUSH ANY QUEUED SYSTEM OUTPUT.        
C     LOAD NEXT LINK NO. INTO UNIT 97, AND TERMINATE PRESENT LINK.      
C        
      KK = ITAB10(2)        
      WRITE  (KK,55)        
   55 FORMAT (//)        
      CALL CONMSG (MSGBUF   ,4,0)        
      CALL CONMSG (MSGBUF(5),4,0)        
      IF (MACH .EQ. 4) GO TO 67        
      IF (ITAB10(7) .LT. 0) ENDFILE 52        
C        
C     IF IBM NEW LOGIC OF LINK SWITCHING VIA FILE 97 IS NOT AVAILBLE,   
C     WE STILL NEED THE NEXT 3 LINES FOR DEAR OLD IBM        
C        
      IF (MACH .NE. 2) GO TO 60        
C     CALL SEARCH (JOBSEG,SYSLB2,NOTUSE)        
      CALL SEARCH (JOBSEG)        
      GO TO 400        
C        
   60 I = KHRFN3(MSGBUF(3),JOBSEG,2,1)        
      IF (MACH.EQ.9 .OR. MACH.EQ.12) GO TO 61        
      OPEN (UNIT=97,ACCESS='SEQUENTIAL',STATUS='NEW',ERR=64)        
      GO TO 62        
   61 CALL FLUNAM (97,FORTXX)        
      OPEN (UNIT=97,ACCESS='SEQUENTIAL',STATUS='NEW',ERR=64,FILE=FORTXX)
   62 WRITE  (97,63) I        
   63 FORMAT ('NAST',A2)        
      CLOSE (UNIT=97)        
      CALL EXIT        
CSUN  CALL EXIT (0)        
   64 WRITE  (NOUT,65)        
   65 FORMAT ('0*** SYSTEM ERROR, CAN NOT OPEN FORTRAN UNIT 97 FOR ',   
     1        'LINK SWITCH')        
      CALL MESAGE (-37,0,NAME)        
C        
C     DETERMINE LINK NUMBER FOR 6600        
C        
   67 I = ANDF(4095,RSHIFT(JOBSEG,36))        
      I1 = I/64        
      I2 = I - I1*64        
      I  = 10*I1 + I2 - 297        
      I76= 76        
      CALL LINK (I,ITAB10(I76),0)        
      GO TO 350        
C        
C        
      ENTRY BGNSYS        
C     ============        
C        
      NPRUS      = 0        
      BITPAS     = .TRUE.        
      MSGBUF(4)  = MSG(1)        
C     PREFAC(1)  = 0        
C     PREFAC(2)  = 0        
      IF (SPERLK .EQ. 0) GO TO 70        
C        
C     SIMPLEFIED OPERATION IF SUPERLINK (USED IN UNIX VERSION)        
C        
      IF (SPERLK.LT.1 .OR. SPERLK.GT.15) GO TO 225        
      ITAB10(22) = LINKS(SPERLK)        
      MSGBUF(2)  = LNKNUM(SPERLK)        
      JOBSXX     = ITAB10(22)        
      GO TO 228        
C        
C     BGNSYS RESTORES THE EXEC TABLES SAVED BY ENDSYS        
C     THEN REPOSITIONS THE OSCAR TO THE ENTRY FOR THE MODULE        
C     IN THE CURRENT LINK.        
C        
   70 IUNITU = 2        
      IF (MACH .LT. 5) READ (IUNITU) ITAB6(4),ISYBUF,FCB        
      IF (MACH .GE. 5) READ (IUNITU) ITAB6(4),ISYBUF        
      FIST(2) = NPFIST + 1        
      FIST(2*NPFIST+3) = SAVE        
      FIST(2*NPFIST+4) = 3        
      J = 5000        
      CALL OPEN (*360,SAVE,DATABF(J),0)        
      CALL READ (*340,*80,SAVE,ITAB10,900,1,FLG)        
   80 CALL READ (*340,*90,SAVE,ITAB1,900,1,FLG)        
      GO TO 350        
   90 CALL READ (*340,*100,SAVE,ITAB2,900,1,FLG)        
      GO TO 350        
  100 CALL READ (*340,*110,SAVE,ITAB3,900,1,FLG)        
      GO TO 350        
  110 CALL READ (*340,*120,SAVE,ITAB4,900,1,FLG)        
      GO TO 350        
  120 CALL READ (*340,*130,SAVE,ITAB5,900,1,FLG)        
      GO TO 350        
  130 CALL READ (*340,*140,SAVE,ITAB6,900,1,FLG)        
      GO TO 350        
  140 CALL READ (*340,*150,SAVE,ITAB7,900,1,FLG)        
      GO TO 350        
  150 CALL READ (*340,*160,SAVE,ITAB8,900,1,FLG)        
      GO TO 350        
  160 CALL READ (*340,*170,SAVE,ITAB9(12),900,1,FLG)        
      GO TO 350        
  170 CALL READ (*340,*190,SAVE,ITAB11,900,1,FLG)        
      GO TO 350        
  190 CALL READ (*340,*210,SAVE,ITAB13,900,1,FLG)        
      GO TO 350        
  210 CALL READ (*340,*220,SAVE,ITAB14,900,1,FLG)        
      GO TO 350        
  220 CALL READ (*340,*221,SAVE,ITAB15,900,1,FLG)        
      GO TO 350        
  221 CALL READ (*340,*222,SAVE,BT,900,1,FLG)        
      GO TO 350        
  222 CALL CLOSE (SAVE,1)        
C        
C     RETRIEVE THE CURRENT LINK NO. FROM THE 22ND WORD OF /SYSTEM/      
C        
      JOBSXX = ITAB10(22)        
      DO 224 I = 1,15        
      IF (JOBSXX .NE. LINKS(I)) GO TO 224        
      MSGBUF(2) = LNKNUM(I)        
      GO TO 228        
  224 CONTINUE        
  225 WRITE  (NOUT,226) SFM,JOBSXX,SPERLK        
  226 FORMAT (A25,', ILLEGAL LINK NUMBER ',A4,' ENCOUNTERED BY BGNSYS.',
     1        4X,'SPERLK=',I14)        
      CALL MESAGE (-61,0,0)        
C        
  228 CALL PRESSW (JOBSXX,I)        
      CALL CONMSG (MSGBUF,4,0)        
      CALL SSWTCH (15,L15)        
      CALL SSWTCH ( 8,L 8)        
      CALL SSWTCH (13,L13)        
      IF (MACH .NE. 3) GO TO 320        
C        
      IF (ITAB10(7) .GE. 0) GO TO 238        
  232 READ (52,234,END=236) I        
  234 FORMAT (A1)        
      GO TO 232        
  236 BACKSPACE 52        
  238 CONTINUE        
C        
C     REPOSITION DRUM FILES OFF LOAD POINT (1108 ONLY)        
C        
      CALL DEFCOR        
      CALL CONTIN        
C        
C     TAPE-FLAG IS THE 45TH WORD OF /SYSTEM/        
C     IF THE 7TH BIT (COUNTING FROM RIGHT TO LEFT) OF TAPE-FLAG IS NOT  
C     ON (=1), AND PLT2 HAS NOT BEEN EXTERNALLY ASSIGNED AS A MAGNETIC  
C     TAPE, SET PLT2 IS TO DISK. SIMILARILY,        
C     IF THE 6TH BIT IS NOT SET, AND PLT1 IS NOT TAPE ASSIGNED, SET PLT1
C     TO DISK        
C        
      I45   = 45        
      ISTAT = ANDF(ITAB10(I45),64)        
      JSTAT = ANDF(ITAB10(I45),32)        
C        
      DO 300 I = 1,75        
C        
C     CALL FACIL TO DETERMINE IF UNIT IS TAPE        
C        
      TENS  = I/10        
      UNITS = I - 10*TENS        
      NBCD  = BCDNUM(UNITS+1)        
      IF (TENS .EQ. 0) GO TO 295        
      MASKK = 255        
      MASKK = LSHIFT(MASKK,27)        
      NBCD  = ORF(ANDF(BCDNUM(TENS+1),MASKK),RSHIFT(NBCD,9))        
  295 CALL FACIL (NBCD,J)        
C        
C     DECODE UNITAB ENTRY        
C        
      NBLOCK = ANDF(RSHIFT(UNITAB(I),12),262143)        
      NLR = ANDF(UNITAB(I),4095)        
      IF (J.EQ.7 .OR. J.EQ.9) GO TO 298        
C        
C     POSITION DRUM UNIT NOW OFF LOAD POINT        
C        
      IF (NBLOCK+NLR .EQ. 1) GO TO 300        
      CALL NTRAN (I,10,22)        
      NOSECT = NBLOCK*ITAB9(164)        
      IF (NLR .EQ. 0) NOSECT = NOSECT - ITAB9(164)        
      IF (I.EQ.13 .AND. ISTAT.NE.0) NOSECT = UNITAB(13)        
      IF (I.EQ.12 .AND. JSTAT.NE.0) NOSECT = UNITAB(12)        
      CALL NTRAN (I,6,NOSECT)        
C        
C     RESET FCB ENTRY        
C     COMMENTS FROM G.CHAN/UNISYS   11/90        
C     FCB ARRAY OF 75 WORDS IS USED ONLY BY UNIVAC AND IBM. IT BEGINS   
C     AT THE 170TH WORD OF /GINOX/        
C        
  298 IF (NLR .NE. 0) NBLOCK = NBLOCK + 1        
      FCB(I) = NBLOCK        
  300 CONTINUE        
C        
  320 IF (SPERLK .NE. 0) GO TO 330        
C        
C     DEFINE OPEN CORE FOR VAX AND UNIX        
C        
      IF (MACH .GE. 5) CALL DEFCOR        
C        
C     REPOSITION POOL TO OSCAR ENTRY TO BE EXECUTED.        
C        
  330 BUF  = KORSZ(DATABF) - ITAB10(1)        
      FILE = POOL        
      CALL OPEN (*360,POOL,DATABF(BUF),2)        
      CALL BCKREC (POOL)        
      IF (SPERLK .EQ. 0) GO TO 400        
      DO 333 J = 1,60        
  333 IBLKCM(J)= 0        
C     DO 334 J = 1,1902        
C 334 DUMMY(J) = 0        
C     COMM( 1) = 0        
C     COMM( 3) = 0        
      COMM( 8) = 0        
C     COMM( 9) = 0        
C     COMM(12) = 0        
C     COMM(15) = 0        
C     COMM(18) = 0        
      DO 335 J = 1,1100        
  335 XF1AT(J) = 0        
      GO TO 400        
C        
  340 CONTINUE        
  350 CALL MESAGE (-37,0,NAME)        
  360 CALL MESAGE (-1,FILE,NAME)        
C        
  400 RETURN        
      END        
