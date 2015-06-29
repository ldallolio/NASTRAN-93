      SUBROUTINE INIT (*,IRDWRT,JBUFF)
C
      INTEGER         IUNITS(300)  ,XYZ   ,UNITAB,BUFADD,PRVOPN,
     1                RSHIFT,ANDF
      COMMON /GINOX / LENGTH,IFILEX,IEOR  ,IOP   ,IENTRY,LSTNAM,
     1                N     ,NAME  ,NTAPE ,XYZ(2),UNITAB(75)   ,
     2                BUFADD(75)   ,NBUFF3,PRVOPN,IUNITS
      COMMON /SYSTEM/ IBUF  ,NOUT
      DATA   ICLOSE / 4            /
      DATA   MASK6F / X'00FFFFFF'  /
C
      NAMEX = NAME
      IF (NAMEX .LT.    400) GO TO 30
      IF (NAMEX .NE. LSTNAM) GO TO 20
      GO TO 40
C
C     IFILEX MUST BE PRESET TO ZERO, SEE P.M. P.3.4-18
C
   20 IFILEX = 0
      CALL GETURN (NAMEX)
      GO TO 40
   30 NAMEX  = NAMEX - 100
      IFILEX = IUNITS(NAMEX)
   40 IF (IFILEX .NE. 0) GO TO 50
      IF (IENTRY .EQ. ICLOSE) RETURN 1
      CALL FNAME (NAME,XYZ)
      WRITE  (NOUT,45) XYZ,NAME
   45 FORMAT ('0*** RD/WRT/FWDREC/REWIND WITHOUT FIRST OPENNING FILE ',
     1        2A4,I6)
      CALL VAXEND
   50 JBUFF = ANDF(BUFADD(IFILEX),MASK6F)
      IF (JBUFF  .NE. 0) GO TO 60
      IF (IENTRY .EQ. ICLOSE) RETURN 1
      CALL VAXEND
   60 IRDWRT = RSHIFT(BUFADD(IFILEX),24)
      RETURN
      END
