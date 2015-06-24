      SUBROUTINE CURV2        
C*****        
C PASSES NEXT SUBCASE OF ELEMENT STRESS OR STRAIN DATA IN OES1        
C AND OUTPUTS OES1M FOR THIS SUBCASE. SETS UP FILES AND TABLES        
C FOR -CURV3- IF OES1G IS TO BE FORMED.        
C        
C     OPEN CORE MAP DURING -CURV2- EXECUTION.        
C     =======================================        
C        
C     FROM-------+------------+        
C     CURV1      I  Z(IELTYP) I  MASTER LIST OF ELEMENT TYPES THAT      
C     EXECUTION  I    THRU    I  EXIST ON ESTX(SCR1)        
C                I  Z(NELTYP) I        
C                +------------+        
C                I  Z(IMCSID) I  MASTER LIST OF MCSIDS ELEMENTS IN      
C                I    THRU    I  PROBLEM REFERENCE, WITH COUNTS OF      
C                I  Z(NMCSID) I  OES1M ELEMENTS FOR CURRENT SUBCASE.    
C                +------------+        
C                I  Z(ICSTM)  I  CSTM FOR EACH -MCSID- IN ABOVE LIST.   
C                I    THRU    I  14 WORD ENTRIES. (USER MAY NOT HAVE    
C                I  Z(NCSTM)  I  SUPPLIED ALL, BUT MAY BE OK.)        
C     FROM-------+------------+        
C     AND DURING I  Z(IESTX)  I  SPACE FOR ONE ENTRY OF ESTX(SCR1)      
C     CURV2      I    THRU    I  ENTRIES.  (SIZE IS ELEMENT DEPENDENT)  
C     EXECUTION  I  Z(NESTX)  I        
C                +------------+        
C                I  Z(IOES1M) I  TABLE OF INCR-WORD .RIES FOR 1 ELEMENT 
C                I    THRU    I  TYPE.  CONTAINS ELEMENT-ID,MCSID,XY-   
C                I  Z(NOES1M) I  COMPONENT-CODE, AND (INCR-3) SIGMAS.   
C                +------------+  INCR =  9 FOR REAL STRESS        
C                I     .      I       = 15 FOR COMPLEX STRESS        
C                I     .      I  AVAILABLE CORE.        
C                I     .      I        
C                I     .      I        
C                I     .      I        
C                I  Z(JCORE)  I        
C                +------------+        
C                I  Z(IBUF4)  I  GINO-BUFFER(OES1M)        
C                I            I        
C                +------------+        
C                I  Z(IBUF3)  I  GINO-BUFFER(SCR2 AND SCR3)        
C                I            I        
C                +------------+        
C                I  Z(IBUF2)  I  GINO-BUFFER(SCR1)        
C                I            I        
C                +------------+        
C                I  Z(IBUF1)  I  GINO-BUFFER(OES1)        
C                I            I        
C                I  Z(LCORE)  I        
C                +------------+        
C        
C        
C*****        
      REAL               Z(1)     ,RBUF(100),U(9)        
C        
      INTEGER            CSTMS    ,SCR1     ,SCR2     ,SCR3     ,MCB(7) 
      INTEGER            SCR4     ,OES1M    ,OES1G    ,OES1     ,SCR5   
      INTEGER            CSTM     ,EST      ,SIL      ,GPL        
      INTEGER            ELTYPE   ,SUBCAS   ,FILE     ,ESTWDS        
      INTEGER            EWORDS   ,OWORDS   ,DEPTS    ,CSTYPE        
      INTEGER            DEVICE   ,OLDID    ,BUF      ,SBUF        
      INTEGER            RD       ,RDREW    ,WRT      ,WRTREW        
      INTEGER            CLS      ,CLSREW   ,EOR      ,SYSBUF        
C        
      LOGICAL            ANY      ,EOFOS1   ,FIRST    ,ANYOUT        
      LOGICAL            FOES1G   ,STRAIN   ,ANY1M    ,ANY1G        
C        
      COMMON/BLANK /     IP1      ,IP2      ,ICMPLX   ,ZDUM(3)        
C        
      COMMON/SYSTEM/     SYSBUF   ,IOUTPT        
C        
      COMMON/NAMES /     RD       ,RDREW    ,WRT      ,WRTREW        
     1                  ,CLSREW   ,CLS        
C        
      COMMON/CONDAS/     VALPI    ,VAL2PI   ,RADDEG   ,DEGRAD        
     1                  ,S4PISQ        
C        
CZZ   COMMON/ZZCURV/     IZ(1)        
      COMMON/ZZZZZZ/     IZ(1)        
C        
      COMMON/CURVC1/     LSBUF    ,SBUF(10)        
C        
      COMMON/CURVC2/     LBUF     ,BUF(100)        
C        
      COMMON/CURVC3/     VEC(3)   ,VMAX(3)  ,VMIN(3)  ,IDREC(146)       
C        
      COMMON/CURVTB/     IMID     ,NMID     ,LMID     ,NMIDS        
     A                  ,IELTYP   ,NELTYP   ,JELTYP   ,ICSTM        
     B                  ,NCSTM    ,CSTMS    ,LCSTM    ,IESTX        
     C                  ,NESTX    ,IMCSID   ,NMCSID   ,LMCSID        
     D                  ,MCSIDS   ,JMCSID   ,KMCSID   ,ISIL        
     E                  ,NSIL     ,LSIL     ,JSIL     ,IOES1M        
     F                  ,NOES1M   ,LOES1M   ,IDEP     ,NDEP        
     G                  ,IINDEP   ,NINDEP   ,JINDEP   ,ISIGMA        
     H                  ,NSIGMA   ,IGMAT    ,NGMAT    ,IEXT        
     I                  ,NEXT     ,LEXT     ,SCR1     ,SCR2        
     J                  ,SCR3     ,SCR4     ,OES1M    ,OES1G        
     K                  ,OES1     ,MPT      ,CSTM     ,EST        
     L                  ,SIL      ,GPL      ,JCORE    ,LCORE        
     M                  ,IBUF1    ,IBUF2    ,IBUF3    ,IBUF4        
     N                  ,I        ,J        ,K        ,L        
     O                  ,K1       ,K2       ,IXYZ1    ,IXYZ2        
     P                  ,LX1      ,LX2      ,ELTYPE   ,MCSID        
     Q                  ,IDSCR1   ,IDOES1   ,NPTS     ,NPTS4        
     R                  ,IWORDS   ,NWORDS   ,SUBCAS   ,KOUNT        
     S                  ,ISIG1    ,ISIG2    ,LOC      ,FILE        
      COMMON/CURVTB/     IMSG     ,NELEMS   ,IMATID   ,ICOMP        
     1                  ,ESTWDS   ,EWORDS   ,JP       ,OWORDS        
     2                  ,MATID    ,DEPTS    ,INDPTS   ,ICTYPE        
     3                  ,IVMAT    ,ITRAN    ,CSTYPE   ,ISING        
     4                  ,DEVICE   ,OLDID    ,ANY      ,EOFOS1        
     5                  ,FIRST    ,ANYOUT   ,FOES1G   ,STRAIN        
     6                  ,LOGERR   ,ANY1M    ,ANY1G    ,SCR5        
C        
      EQUIVALENCE        (Z(1),IZ(1)), (BUF(1),RBUF(1))        
      EQUIVALENCE        (NOEOR,RDREW), (EOR,CLS)        
C        
      DATA MCB/ 7*1 /        
C        
C  OPEN OES1M FOR ANY POSSIBLE OUTPUTS DURING THIS SUBCASE PASS.        
C        
      ISIG1 = 3        
      ISIG2 = 11        
      FILE = OES1M        
      LOC = 60        
      CALL OPEN(*9001,OES1M,IZ(IBUF3),WRT)        
C        
C  OPEN OES1 NOREWIND TO CONTINUE        
C        
      FIRST = .TRUE.        
      ANY = .FALSE.        
      FILE = OES1        
      CALL OPEN(*9001,OES1,IZ(IBUF1),RD)        
      FILE = SCR1        
      CALL OPEN(*9001,SCR1,IZ(IBUF2),RDREW)        
C        
C  ZERO ELEMENT COUNTS FOR EACH -MCSID- THIS SUBCASE MAY REFERENCE.     
C        
      DO 80 I = IMCSID,NMCSID,2        
      IZ(I+1) = 0        
   80 CONTINUE        
C        
C  READ NEXT ID-RECORD        
C        
  100 FILE = OES1        
      LOC = 100        
      CALL READ(*300,*9003,OES1,IDREC(1),146,EOR,NWORDS)        
C        
C  CHECK IF STILL SAME SUBCASE UNLESS THIS IS THE FIRST ID-RECORD OF A  
C  SUBCASE GROUP.        
C        
      IF( .NOT. FIRST ) GO TO 200        
C        
C  YES THIS IS FIRST ID-RECORD OF A SUBCASE GROUP.        
C  SET SUBCASE IDENTIFIERS.        
C        
      SUBCAS = IDREC(4)        
      FIRST = .FALSE.        
      GO TO 500        
C        
C  CHECKING FOR CHANGE IN SUBCASE        
C        
  200 IF( SUBCAS .EQ. IDREC(4) ) GO TO 500        
C        
C  CHANGE IN SUBCASE THUS BACK RECORD OVER THIS ID-RECORD CLOSE        
C  OES1, AND WRAP UP OPERATIONS ON OES1M FOR CURRENT SUBCASE.        
C        
      CALL BCKREC( OES1 )        
      CALL CLOSE( OES1, CLS )        
C        
C  CLOSE ESTX(SCR1) AND ESTXX(SCR2).        
C        
  250 CALL CLOSE( SCR1, CLSREW )        
      CALL CLOSE( SCR2, CLSREW )        
      GO TO 5000        
C        
C  END OF FILE ON OES1. SET EOF FLAG AND WRAP UP CURRENT OPERATIONS     
C  ON OES1M.        
C        
  300 EOFOS1 = .TRUE.        
      CALL CLOSE( OES1, CLSREW )        
      CALL CLOSE(OES1M,CLSREW)        
      GO TO 250        
C        
C  ID RECORD ON OES1 WILL BE FOR SOME KIND OF ELEMENT.        
C  CHECK TO SEE IF ITS TYPE IS IN THE LIST OF TYPES NOW ON SCR1        
C  WHICH IS THE ABBREVIATED EST. IF NOT THEN SKIP THE DATA RECORD       
C  AND GO TO NEXT ID RECORD.        
C        
  500 ELTYPE = IDREC(3)        
      IFORMT = IDREC(9)        
      OWORDS = IDREC(10)        
      DO 520 I = IELTYP,NELTYP        
      IF( ELTYPE .EQ. IZ(I) ) GO TO 600        
  520 CONTINUE        
      CALL FWDREC(*300,OES1)        
      GO TO 100        
C        
C  POSITION TO SCR1 RECORD FOR THIS ELEMENT TYPE. IF IT CAN NOT BE      
C  FOUND BY FORWARD SEARCH THERE IS A LOGIC ERROR, OR OES1 ELEMENT      
C  TYPES ARE NOT IN SAME ORDER AS EST ELEMENT TYPES.        
C        
  600 FILE = SCR1        
      LOC = 600        
      CALL REWIND (SCR1)        
  640 CALL READ(*9002,*9003,SCR1,BUF(1),3,NOEOR,NWORDS)        
      IF( BUF(1) .EQ. ELTYPE ) GO TO 650        
      CALL FWDREC(*9002,SCR1)        
      GO TO 640        
C        
C  NOW POSITIONED TO READ ELEMENT ENTRIES FROM ESTX(SCR1) WHICH        
C  ARE OK FOR INCLUSION IN OES1M AND OES1G PROCESSING.        
C        
C  ALSO POSITIONED TO READ OUTPUT STRESS/STRAIN ENTRIES FROM OES1.      
C  HOWEVER, ONLY THOSE ALSO ON ESTX(SCR1) WILL BE PULLED.        
C        
  650 ANYOUT = .FALSE.        
      EWORDS = BUF(2)        
      NPTS = BUF(3)        
      NPTS4 = 4*NPTS        
      IESTX = NCSTM + 1        
      NESTX = NCSTM + EWORDS        
      IOES1M = NESTX + 1        
      NOES1M = NESTX        
      LOC = 650        
      ICRQ = NOES1M - JCORE        
      IF( NOES1M .GT. JCORE ) GO TO 9008        
      IDSCR1 = 0        
C        
C  READ NEXT OES1 ENTRY AND SET IDOES1  (STRIPPING OFF DEVICE CODE)     
C        
  670 FILE = OES1        
      LOC = 670        
      CALL READ(*9002,*900,OES1,BUF(1),OWORDS,NOEOR,NWORDS)        
      IDOES1 = BUF(1) / 10        
      IF( IDOES1 ) 9000,9000,700        
C        
C  READ NEXT SCR1 ENTRY AND SET IDSCR1        
C        
  680 FILE = SCR1        
      LOC = 680        
      CALL READ(*9002,*950,SCR1,IZ(IESTX),EWORDS,NOEOR,NWORDS)        
      IDSCR1 = IZ(IESTX)        
      IF( IDSCR1 ) 9000,9000,700        
C        
C  CHECK FOR MATCH OF ESTX(SCR1) ENTRY ID WITH OES1 ENTRY ID.        
C        
  700 IF( IDOES1 - IDSCR1 ) 670,710,680        
C        
C  MATCH FOUND THUS BEGIN OES1M ENTRY CALCULATIONS        
C        
  710 MCSID = IZ(IESTX+1)        
      LOC = 710        
      CALL TRANEM( MCSID, NPTS, Z(IESTX+NPTS+2), ICOMP, U(1), VEC(1) )  
C        
C  FORM AND ADD ENTRY TO CORE. INVARIANTS WILL BE COMPUTED LATER.       
C        
      INCR = 9        
      IF (ICMPLX.EQ.1) INCR = 15        
      ICRQ = NOES1M + INCR - JCORE        
      IF( NOES1M+INCR .GT. JCORE ) GO TO 9008        
      IZ(NOES1M+1) = BUF(1)        
      IZ(NOES1M+2) = MCSID        
      IZ(NOES1M+3) = ICOMP        
      IF (ICMPLX.EQ.1) GO TO 730        
C        
C  IF STRAINS DO MODIFICATION OF GAMMA        
C        
      IF( .NOT. STRAIN ) GO TO 720        
      RBUF(ISIG1+2) = RBUF(ISIG1+2) / 2.0        
      RBUF(ISIG2+2) = RBUF(ISIG2+2) / 2.0        
  720 CALL GMMATS( U(1),3,3,0,  RBUF(ISIG1),3,1,0,  Z(NOES1M+4) )       
      CALL GMMATS( U(1),3,3,0,  RBUF(ISIG2),3,1,0,  Z(NOES1M+7) )       
C        
      NOES1M = NOES1M + 9        
      GO TO 740        
C        
  730 IF (IFORMT.NE.3) GO TO 732        
      DO 731 MM1 = 3, 10, 7        
      MM2 = MM1 + 4        
      DO 731 LLL = MM1, MM2, 2        
      ZTEMP   = RBUF(LLL)*COS(RBUF(LLL+1)*DEGRAD)        
      RBUF(LLL+1) = RBUF(LLL)*SIN(RBUF(LLL+1)*DEGRAD)        
      RBUF(LLL) = ZTEMP        
  731 CONTINUE        
  732 ZDUM(1) = RBUF(3)        
      ZDUM(2) = RBUF(5)        
      ZDUM(3) = RBUF(7)        
      CALL GMMATS (U(1),3,3,0,ZDUM,3,1,0,Z(NOES1M+4))        
      ZDUM(1) = RBUF(4)        
      ZDUM(2) = RBUF(6)        
      ZDUM(3) = RBUF(8)        
      CALL GMMATS (U(1),3,3,0,ZDUM,3,1,0,Z(NOES1M+7))        
      ZDUM(1) = RBUF(10)        
      ZDUM(2) = RBUF(12)        
      ZDUM(3) = RBUF(14)        
      CALL GMMATS (U(1),3,3,0,ZDUM,3,1,0,Z(NOES1M+10))        
      ZDUM(1) = RBUF(11)        
      ZDUM(2) = RBUF(13)        
      ZDUM(3) = RBUF(15)        
      CALL GMMATS (U(1),3,3,0,ZDUM,3,1,0,Z(NOES1M+13))        
C        
      IF (IFORMT.NE.3) GO TO 738        
      DO 737 MM1 = 4, 10, 6        
      MM2 = MM1 + 2        
      DO 737 LLL = MM1, MM2        
      LL1 = NOES1M + LLL        
      LL2 = LL1 + 3        
      ZTEMP   = SQRT (Z(LL1)**2 + Z(LL2)**2)        
      IF (ZTEMP.NE.0.0) GO TO 734        
      Z(LL2) = 0.0        
      GO TO 736        
  734 Z(LL2) = ATAN2 (Z(LL2), Z(LL1))*RADDEG        
      IF (Z(LL2).LT.-0.00005E0) Z(LL2) = Z(LL2) + 360.0        
  736 Z(LL1) = ZTEMP        
  737 CONTINUE        
C        
  738 NOES1M = NOES1M + 15        
C        
C        
C  IF THIS IS THE FIRST ELEMENT ENTRY TO BE FOUND        
C  AND OES1G IS TO BE FORMED, THE ID-RECORD IS SAVED FOR USE BY        
C  CURV3 OVERLAY.        
C        
  740 IF( .NOT. FOES1G ) GO TO 790        
      IF( ANY ) GO TO 750        
      FILE = SCR3        
      LOC = 740        
      CALL OPEN(*9001,SCR3,IZ(IBUF4),WRTREW)        
      CALL WRITE( SCR3, IDREC(1), 146, EOR )        
      CALL CLOSE( SCR3, CLSREW )        
C        
      FILE = SCR2        
      CALL OPEN(*9001,SCR2,IZ(IBUF4),WRTREW)        
      DEVICE = MOD( BUF(1), 10 )        
      ANY = .TRUE.        
C        
C  OUTPUT SPECIAL ESTXX (SCR2) ENTRY FOR USE BY CURV3.        
C        
  750 CALL WRITE( SCR2, MCSID, 1, NOEOR )        
      CALL WRITE( SCR2, Z(NOES1M-5), 6, NOEOR )        
      CALL WRITE( SCR2, VEC(1), 3, NOEOR )        
      CALL WRITE( SCR2, NPTS, 1, NOEOR )        
      CALL WRITE( SCR2, IZ(IESTX+2), NPTS4, NOEOR )        
  790 CONTINUE        
      GO TO 670        
C*****        
C  END OF ENTRY DATA POSSIBLE FOR THIS ELEMENT TYPE        
C******        
C        
C  SKIP ANY UNUSED DATA IN ESTX (SCR1) DATA RECORD FOR THIS ELEMENT TYPE
C        
  900 FILE = SCR1        
      LOC = 900        
      CALL FWDREC(*9002,SCR1)        
      GO TO 960        
C        
C  SKIP ANY UNUSED DATA IN OES1 DATA RECORD FOR THIS ELEMENT TYPE.      
C        
  950 FILE = OES1        
      LOC = 950        
      CALL FWDREC(*9002,OES1)        
C        
C  IF ANY ENTRIES WERE FOUND AND COMPLETED AND PLACED IN CORE        
C  THEY ARE SORTED ON -MCSID- AND OUTPUT. AS THEY ARE OUTPUT        
C  THE INVARIANTS ARE COMPUTED.        
C        
  960 IF( NOES1M .LT. IOES1M ) GO TO 100        
C        
C  YES THERE ARE SOME ENTRIES        
C        
      LOES1M = NOES1M - IOES1M + 1        
      CALL SORT( 0, 0, INCR, 2, IZ(IOES1M), LOES1M )        
C        
C  OUTPUT ID-RECORD, REDEFINE MAJOR-ID FOR OFP MODULE        
C        
C  RE-DEFINITION MISSING FOR NOW.        
C        
      IDREC(3) = IDREC(3) + 1000        
      CALL WRITE( OES1M, IDREC(1), 146, EOR )        
      MCB(1) = OES1M        
      CALL WRTTRL( MCB(1) )        
      ANY1M = .TRUE.        
C        
C  MOVE AXIS CODE AND COMPLETE INVARIANTS OF EACH ENTRY.        
C        
      KMCSID = IZ(IOES1M+1)        
      KOUNT = 0        
C        
      DO 970 I = IOES1M, NOES1M, INCR        
      BUF(1) = IZ(I)        
      BUF(2) = IZ(I+1)        
      RBUF(3) = Z(I+3)        
      IF (ICMPLX.EQ.1) GO TO 963        
      RBUF(4) = Z(I+4)        
      RBUF(5) = Z(I+5)        
      CALL CURVPS( RBUF(3), RBUF(6) )        
      IF( .NOT. STRAIN ) GO TO 961        
      RBUF(5) = 2.0 * RBUF(5)        
      RBUF(9) = 2.0 * RBUF(9)        
  961 BUF(10) = IZ(I+2)        
      RBUF(11) = Z(I+6)        
      RBUF(12) = Z(I+7)        
      RBUF(13) = Z(I+8)        
      CALL CURVPS ( RBUF(11), RBUF(14) )        
      IF( .NOT. STRAIN ) GO TO 962        
      RBUF(13) = 2.0 * RBUF(13)        
      RBUF(17) = 2.0 * RBUF(17)        
  962 CALL WRITE( OES1M, BUF(1), 17, NOEOR )        
      GO TO 964        
  963 RBUF( 4) = Z(I+ 6)        
      RBUF( 5) = Z(I+ 4)        
      RBUF( 6) = Z(I+ 7)        
      RBUF( 7) = Z(I+ 5)        
      RBUF( 8) = Z(I+ 8)        
      BUF(  9) = IZ(I+2)        
      RBUF(10) = Z(I+ 9)        
      RBUF(11) = Z(I+12)        
      RBUF(12) = Z(I+10)        
      RBUF(13) = Z(I+13)        
      RBUF(14) = Z(I+11)        
      RBUF(15) = Z(I+14)        
      CALL WRITE (OES1M, BUF(1), 15, NOEOR)        
C        
C  KEEP COUNT OF ELEMENTS IN EACH MCSID GROUP        
C        
  964 IF( IZ(I+1) .NE. KMCSID ) GO TO 965        
      KOUNT = KOUNT + 1        
      IF( I+INCR-1 .LT. NOES1M ) GO TO 970        
C        
C  CHANGE IN -MCSID- OF OUTPUT ENTRIES OR LAST ENTRY.        
C  ADD COUNT OF ELEMENTS OF CURRENT TYPE TO TOTAL COUNT        
C  OF ELEMENTS OF THIS -MCSID-.        
C        
  965 LOC = 965        
      CALL BISLOC(*9000,KMCSID,IZ(IMCSID),2,MCSIDS,JP)        
      IZ(IMCSID+JP) = IZ(IMCSID+JP) + KOUNT        
      KOUNT = 1        
      KMCSID = IZ(I+1)        
  970 CONTINUE        
      CALL WRITE( OES1M, 0, 0, EOR )        
      GO TO 100        
C*****        
C  ALL PROCESSING OF ONE SUBCASE COMPLETE FOR OES1M.        
C*****        
 5000 CALL CLOSE( OES1M, CLS )        
      RETURN        
C*****        
C  ERROR CONDITION ENCOUNTERED        
C*****        
 9000 IMSG = -LOGERR        
      GO TO 5000        
 9001 IMSG = -1        
      GO TO 5000        
 9002 IMSG = -2        
      GO TO 5000        
 9003 IMSG = -3        
      GO TO 5000        
 9008 IMSG = -8        
      LCORE = ICRQ        
      GO TO 5000        
      END        
