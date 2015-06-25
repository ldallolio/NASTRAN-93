      SUBROUTINE MATWRT (IFILE,XNAME,XITEM,LCORE)
C
      INTEGER         OTPE,SYSBUF
      DOUBLE PRECISION DCOL
      DIMENSION       IA(7),TYPE(10),FORM(18),COL(1),DCOL(1),XNAME(2)
CZZ   COMMON /ZZSOFU/ COL
      COMMON /ZZZZZZ/ COL
      COMMON /UNPAKX/ IT,K,L,INCR
      COMMON /SYSTEM/ SYSBUF,OTPE,INX(6),NLPP,INX1(2),LINE
      COMMON /OUTPUT/ HEAD1(96),HEAD2(96)
      EQUIVALENCE     (COL(1),DCOL(1))
      DATA    TYPE  / 4HREAL,4H    ,4HDB  ,4HPREC,4HCOMP,4HLEX ,4HCMP ,
     1                4HD.P.,4HILL ,4HDEFN/
      DATA    FORM  / 4HSQUA,4HRE  ,4HRECT,4HANG ,4HDIAG,4HONAL,4HLOW ,
     1                4HTRI ,4HUPP ,4HTRI ,4HSYME,4HTRIC,4HVECT,4HOR  ,
     2                4HIDEN,4HITY ,4HILL ,4HDEFN/
      DATA    BLANK , SU    ,BSTR  ,UCTU  ,RE    ,XIT   ,EM    ,CONT  /
     1        4H    , 4H  SU,4HBSTR,4HUCTU,4HRE  ,4H  IT,4HEM  ,4HCONT/
      DATA    XINUE , DX    /
     1        4HINUE, 4HD   /
C
C
C     TRANSFER MATRIX FORM SOF TO GINO
C
      CALL MTRXI (IFILE,XNAME,XITEM,0,ITEST)
      IF (ITEST .NE. 1) RETURN
      IA(1) = IFILE
      CALL RDTRL (IA(1))
C
      DO 10 I = 1,96
   10 HEAD2(I)  = BLANK
      HEAD2( 1) = SU
      HEAD2( 2) = BSTR
      HEAD2( 3) = UCTU
      HEAD2( 4) = RE
      HEAD2( 5) = XNAME(1)
      HEAD2( 6) = XNAME(2)
      HEAD2( 7) = XIT
      HEAD2( 8) = EM
      HEAD2( 9) = XITEM
      HEAD2(11) = CONT
      HEAD2(12) = XINUE
      HEAD2(13) = DX
      NAMEA = IFILE
      LCOL  = LCORE - SYSBUF
      INCR  = 1
      CALL GOPEN (NAMEA,COL(LCOL+1),0)
      IT = IA(5)
      IF (IT.LE.0 .OR. IT.GT.4) IT = 5
      IF = IA(4)
      IF (IF.LE.0 .OR. IF.GT.8) IF = 9
      NCOL = IA(2)
      NROW = IA(3)
      IF (IF .EQ. 7) NCOL = IA(3)
      CALL PAGE1
      WRITE (OTPE,20) XNAME,XITEM,TYPE(2*IT-1),TYPE(2*IT),NCOL,NROW,
     X                FORM(2*IF-1),FORM(2*IF)
   20 FORMAT (1H0,6X,13HSUBSTRUCTURE ,2A4,6H ITEM ,A4,6H IS A ,2A4,
     X        1X,I6,10H COLUMN X ,I6,5H ROW ,2A4,8H MATRIX. )
      IF (IT.EQ.5 .OR. IF.EQ.9 .OR. NCOL.EQ.0 .OR. NROW.EQ.0) GO TO 320
      IF (IF-8) 30,300,320
   30 IF (IF.NE.3 .AND. IF.NE.7) GO TO 40
      NCOL = 1
      NROW = IA(3)
   40 INULL= 0
      IT1  = 5
      IF (IT.EQ.1 .OR. IT.EQ.3) IT1 = 9
      ASSIGN 60 TO IHOP
      JJ = 1
   50 K  = 0
      L  = 0
      CALL UNPACK (*190,NAMEA,COL)
      IF (INULL .EQ. 1) GO TO 330
   60 NROW = L - K + 1
      GO TO (80,80,220,80,80,80,240), IF
   80 WRITE (OTPE,90) JJ,K,L
      LINE = LINE + 3
      IF (LINE .GE. NLPP) CALL PAGE
   90 FORMAT (8H0COLUMN ,I6,5X,6H ROWS ,I6,6H THRU ,I6,5X,50(1H-),/1H )
      IF (IT .GT. 2) NROW = 2*NROW
   91 K = 0
  100 J = K + 1
      IF (J .GT. NROW) GO TO 200
      K = J + IT1
      IF (K .GT. NROW) K = NROW
      GO TO (110,130,150,170), IT
C
C     REAL SINGLE PRECISION
C
  110 WRITE  (OTPE,120) (COL(I),I=J,K)
  120 FORMAT (1X,1P,10E13.5)
  121 LINE = LINE + 1
      IF (LINE .GE. NLPP) CALL PAGE
      GO TO 100
C
C     REAL DOUBLE PRECISION
C
  130 WRITE  (OTPE,140) (DCOL(I),I=J,K)
  140 FORMAT (1P,6D22.14)
      GO TO 121
C
C     COMPLEX SINGLE
C
  150 WRITE  (OTPE,160) (COL(I),I=J,K)
  160 FORMAT (5(1P,E12.4,1H+,1P,E12.4,1HI))
      GO TO 121
C
C     COMPLEX DOUBLE
C
  170 WRITE  (OTPE,180) (DCOL(I),I=J,K)
  180 FORMAT (3(1P,D20.12,1H+,1P,D20.12,2HI ))
      GO TO 121
  190 IF (INULL .EQ. 1) GO TO 200
      IBEGN = JJ
      INULL = 1
  200 JJ =  JJ + 1
      IF (JJ  .LE. NCOL) GO TO 50
      ASSIGN 210 TO IHOP
      IF (INULL .EQ. 1) GO TO 330
  210 CALL CLOSE (NAMEA,1)
      GO TO 270
  220 WRITE (OTPE,230)K,L
      LINE = LINE + 2
  230 FORMAT (30H0DIAGONAL ELEMENTS FOR COLUMNS,I6,3H TO,I7,4H ARE,/1H0)
      GO TO 91
  240 WRITE (OTPE,250) K,L
      LINE = LINE + 2
  250 FORMAT (25H0ROW ELEMENTS FOR COLUMNS,I6,4H TO ,I6,4H ARE ,/1H0 )
      GO TO 91
  270 WRITE  (OTPE,280) IA(6)
  280 FORMAT (53H0THE NUMBER OF NON-ZERO WORDS IN THE LONGEST RECORD =,
     1        I8 )
      IA7A = IA(7)/100
      IA7C = IA(7) - 100*IA7A
      IA7B = IA7C/10
      IA7C = IA7C - 10*IA7B
      WRITE  (OTPE,285) IA7A,IA7B,IA7C
  285 FORMAT (31H0THE DENSITY OF THIS MATRIX IS ,I3,1H.,I1,I1,
     1        9H PERCENT.)
  290 RETURN
C
  300 WRITE  (OTPE,310)
  310 FORMAT (16H0IDENTITY MATRIX)
  320 CALL CLOSE (NAMEA,1)
C
C     FUNNY MATRIX -- TABLE PRINT IT
C
      CALL TABPRT (NAMEA)
      GO TO 290
  330 IFIN = JJ - 1
      WRITE (OTPE,340) IBEGN,IFIN
      INULL = 0
      LINE  = LINE + 2
      IF (LINE .GE. NLPP) CALL PAGE
  340 FORMAT (9H0COLUMNS ,I7,6H THRU ,I7,10H ARE NULL.)
      GO TO IHOP, (60,210)
      END
