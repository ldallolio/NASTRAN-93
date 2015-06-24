      SUBROUTINE DPLOT        
C        
      IMPLICIT INTEGER (A-Z)        
      INTEGER         TIT(32),NAME(2)        
      CHARACTER       UFM*23,UWM*25        
      COMMON /XMSSG / UFM,UWM        
      COMMON /PLOTHD/ IUSED        
      COMMON /SYSTEM/ BUFSIZ ,NOUT        
CZZ   COMMON /ZZPLOT/ X(1)        
      COMMON /ZZZZZZ/ X(1)        
      COMMON /BLANK / NGP    ,LSIL   ,NSETS  ,PLTFLG ,PLTNUM ,NGPSET  , 
     1                NODEF  ,SKP1(3),PLTPAR ,GPSETS ,ELSETS ,CASECC  , 
     2                BGPDT  ,EQEXIN ,SIL    ,PDEF1  ,PDEF2  ,S2      , 
     3                PLOTX  ,SETD   ,ECPT   ,OES1   ,SCR1   ,SCR2    , 
     4                SCR3   ,SCR4        
C        
C     NOTE THAT NSETS IS DMAP PARAMETER JUMPPLOT        
C     IUSED IS USED IN PLOT AND HDPLOT        
C        
      DATA    INPREW, REW / 0,1   /,        
     1        TIT   / 12*1H ,4HMESS,4HAGES,4H FRO,4HM TH,4HE PL,4HOT M, 
     2                4HODUL,1HE   ,12*1H    /        
      DATA    NAME  / 4HDPLO,4HT   /        
C        
C     FILE NAMES FOR UNDEFORMED PLOTS MAY BE        
C     108  = USET (GPTLBL - SPC DEGREES OF FREEDOM)        
C     109  = ECT  (ELELBL - PROPERTY IDS)        
C     110  = ECPT        
C          = EPT (UNDEFORMED PLOT ONLY, DMAP NUMBER 25 OR LESS)        
C            EPT IS NEEDED FOR PSHELL CARDS IN ORDER TO PICK UP ANY     
C            OFFSET FOR CTRIA3 AND CQUAD4 (IN COMECT)        
C        
      PLTPAR = 101        
      GPSETS = 102        
      ELSETS = 103        
      CASECC = 104        
      BGPDT  = 105        
      EQEXIN = 106        
      SIL    = 107        
      PDEF1  = 108        
      PDEF2  = 109        
      ECPT   = 110        
      OES1   = 111        
      OES1L  = 112        
      ONRGY1 = 113        
      PLOTX  = 201        
      SCR1   = 301        
      SCR2   = 302        
      SCR3   = 303        
      SCR4   = 304        
      NODEF  = 0        
      IF (NGP.LE.0 .OR. LSIL.LE.0) GO TO 80        
      CALL TOTAPE (2,X(1))        
C        
C     OUTPUT THE TITLE FOR MESSAGE FILE        
C     THE LAST BUFFER IS BUFSIZ+1 FOR SUBROUTINE ELELBL        
C        
      BUF = KORSZ(X) - 4*BUFSIZ        
      IF (BUF-4*BUFSIZ .LT. 10) GO TO 85        
      IF (NSETS .LE. 0) GO TO 60        
      CALL GOPEN (PLOTX,X(BUF),REW)        
C        
C     COMMENTS FROM G.CHAN/UNISYS       11/90        
C     NEXT 2 LINES ADD TIT HEADING TO THE 4TH LINE OF NASTRAN HEADERS   
C     WHEN THE PLOTX FILE IS READ AND PRINTED BY PRTMSG MODULE.        
C     THIS SHORTCUT TECHNIQUE IS NO WHERE DISCUSSED IN THE USER'S NOR   
C     PROGRAMMER'S MAUNALS        
C        
      CALL WRITE (PLOTX,-4,1,0)        
      CALL WRITE (PLOTX,TIT,32,0)        
C        
C     READ THE SETID-S FROM -GPSETS- FILE.  SET NEGATIVE SETID-S THAT   
C     HAVE NO ASSOCIATED GRIDS.  FIND FIRST DEFINED SET OR EXIT IF NONE 
C        
      BUF = BUF - BUFSIZ        
      CALL GOPEN (GPSETS,X(BUF),INPREW)        
      CALL FREAD (GPSETS,X,NSETS,1)        
      SETD = 0        
      X(NSETS+1) = 1        
C        
      DO 50 I = 1,NSETS        
      CALL READ (*30,*60,GPSETS,X(NSETS+2),1,1,I1)        
      IF (X(NSETS+2) .GT. 0) GO TO 40        
   30 WRITE  (NOUT,31) UWM,X(NSETS+1)        
   31 FORMAT (A25,' 697, SET',I9,        
     1       ' NOT DEFINED.  FIRST SET DEFINED WILL BE USED.')        
      X(I) = -X(I)        
      GO TO 50        
   40 IF (SETD .EQ. 0) SETD = I        
   50 CONTINUE        
      CALL CLOSE (GPSETS,REW)        
      IF (SETD .NE. 0) GO TO 70        
   60 WRITE  (NOUT,61) UFM        
   61 FORMAT (A23,' 698, NO SETS DEFINED FOR PLOTS')        
      CALL MESAGE (-61,0,0)        
C        
C     PROCESS PLOT REQUESTS        
C        
   70 CALL GOPEN (PLTPAR,X(BUF),INPREW)        
      I1 = 1        
      I2 = I1  + NSETS        
      BUF= BUF - BUFSIZ        
      CALL PARAM (X(I1),X(I2),BUF-NSETS)        
      CALL CLOSE (PLTPAR,REW)        
C        
C     SET JUMPPLOT NEGATIVE IF NO FUTHER REQUESTS        
C        
      IF (PLTFLG.GE.0 .AND. NODEF.EQ.0) NSETS = -1        
      CALL CLSTAB (PLOTX,REW)        
      CALL CLOSE  (GPSETS,REW)        
      PLTFLG = -1        
   80 RETURN        
C        
C     INSUFFICIENT CORE        
C        
   85 CALL MESAGE (-8,BUF,NAME)        
      NSETS = -1        
      PLTFLG= -1        
      GO TO 80        
      END        
