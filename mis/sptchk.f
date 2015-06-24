      SUBROUTINE SPTCHK        
C        
C     THIS ROUTINE IS CALLED ONLY BY BANDIT TO CHECK THE PRESENCE OF ANY
C     UNDEFINED SPOINT. RESET NGRID AND RETURN FOR ONE MORE COMPUTATION 
C     IF THAT IS THE CASE        
C        
      INTEGER         GEOM1,    GEOM2,    RD,       RDREW,    REW,      
     1                Z,        SPOINT(2),NAME(2),  KG(200)        
      COMMON /SYSTEM/ IBUF,     NOUT        
      COMMON /BANDA / IBUF1,    DUM6(6),  NPT(2)        
      COMMON /BANDB / DUM3(3),  NGRID,    DUM4(4),  IREPT        
      COMMON /BANDD / NDD(9)        
      COMMON /BANDS / SKIP(4),  MAXGRD        
      COMMON /GEOMX / GEOM1,    GEOM2        
      COMMON /NAMES / RD,       RDREW,    DUM2(2),  REW        
      COMMON /GPTA1 / NE,       LAST,     INCR,     KE(1)        
CZZ   COMMON /ZZBAND/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      DATA            SPOINT,   NAME /    5551,49,  4HBMIS, 4HS      /  
C        
C     LIST ALL SPOINTS IN Z(1) THRU Z(NS)        
C        
      IF (IREPT .EQ. 3) GO TO 160        
      NS=1        
      CALL PRELOC (*160,Z(IBUF1),GEOM2)        
      CALL LOCATE (*40,Z(IBUF1),SPOINT,K)        
 30   CALL READ (*180,*40,GEOM2,Z(NS),1,0,K)        
      NS=NS+1        
      GO TO 30        
 40   NS=NS-1        
      CALL REWIND (GEOM2)        
C        
C     CHECK THE PRESENCE OF ELAST, DAMP AND MASS CARDS (ELEMENT TYPES   
C     201 THRU 1301).  THEY MAY SPECIFY SCALAR POINTS WITHOUT USING     
C     SPOINT CARDS.        
C        
      NSS=NS        
      DO 100 IELEM=26,350,INCR        
      CALL LOCATE (*100,Z(IBUF1),KE(IELEM+3),J)        
      NWDS =KE(IELEM+5)        
      NGPT1=KE(IELEM+12)        
      NGPTS=KE(IELEM+9)+NGPT1-1        
 50   CALL READ (*180,*100,GEOM2,KG(1),NWDS,0,J)        
      DO 90 I=NGPT1,NGPTS        
      IF (NS .EQ. 0) GO TO 70        
      CALL BISLOC (*70,KG(I),Z(1),1,NS,K)        
      GO TO 90        
 70   NSS=NSS+1        
      IF (NSS .GE. IBUF1) GO TO 110        
      Z(NSS)=KG(I)        
 90   CONTINUE        
      GO TO 50        
 100  CONTINUE        
 110  CALL CLOSE (GEOM2,REW)        
      K=NSS-NS-1        
      IF (K) 160,140,120        
C        
C     SOME SCALAR POINTS ARE USED, BUT NOT SPECIFIED BY SPOINT CARDS.   
C     SORT THEM, AND THROW OUT DUPLICATES        
C        
 120  NS1=NS+1        
      CALL SORT (0,0,1,1,Z(NS1),NSS-NS)        
      K  =NSS        
      NSS=NS1        
      J  =NS+2        
      DO 130 I=J,K        
      IF (Z(I) .EQ. Z(I-1)) GO TO 130        
      NSS=NSS+1        
      Z(NSS)=Z(I)        
 130  CONTINUE        
C        
C     RE-COMPUTE THE TOTAL NO. OF GRID POINTS, NGRID, AND RETURN FOR    
C     ONE MORE BANDIT COMPUTATION        
C        
 140  NPT(2)=NSS-NS        
      NGRID =NPT(1)+NPT(2)        
      DO 150 I=1,9        
 150  NDD(I)=0        
      IREPT =2        
      RETURN        
C        
 160  WRITE (NOUT,170) MAXGRD        
 170  FORMAT (120H1*** USER FATAL ERROR 2007,  THIS STRUCTURE MODEL USES
     1 MORE GRID POINTS THAN THE TOTAL NO. OF GRID CARDS IN BULK DATA (=
     2,I6,1H),/)        
      NGRID=0        
      GO TO 190        
C        
 180  CALL MESAGE (-3,GEOM2,NAME)        
 190  RETURN        
      END        
