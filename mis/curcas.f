      SUBROUTINE CURCAS(*,NSKIP,TRL,MCB,ZZ,IBUF)
C   THIS SUBROUTINE COPIES MATRIX FILE TRL(1) TO FILE MCB(1)
C SKIPPING NSKIP-1 MATRIX COLUMNS.  PRIMARY USE IS TO CREATE A MATRIX
C THAT INCLUDES ONLY SUBCASES IN THE CURRENT DMAP LOOP.
C   ALL FILES ARE OPENED, CLOSED AND TRIALERS WRITTEN.
C   IF NSKIP WOULD RESULT IN NO-COPY, MCB(1) IS SET TO TRL(1).
C     TRL - INPUT TRAILER FOR FILE BEING CONVERTED.
C     MCB - OUTPUT TRAILER - WORD 1 HAS GINO FILE NAME.
C     ZZ  - OPEN CORE.
C     IBUF- LOCATION OF TWO GINO BUFFERS.
C     NSKIP - ONE MORE THAN THE SUBCASES TO SKIP.
C       * - NONSTANDARD RETURN IF UNABLE TO PROCESS.
C-----
      INTEGER PARM(4)  ,MCB(7)   ,TRL(7)   ,ZZ(1)    ,COUNT
C
      COMMON /NAMES / IRD,IRDRW,IWT,IWTRW, KREW,KNRW,KNERW
      COMMON /SYSTEM/ ISBZ
      EQUIVALENCE (ICNT,RCNT)
      DATA PARM(3),PARM(4) / 4HCURC,2HAS  /                             
C                                                                       
      PARM(2) = TRL(1)
      IF (NSKIP.LE.1) GO TO 55
C  . FOR STATICS THE NUMBER OF SUBCASES SKIPPED = NO. COLUMNS SKIPPED.
C  .  OTHER ANALYSIS TYPES NEED TO SUPPLY PROPER VALUE FOR NSKIP...
      I = NSKIP - 1
      IBF2 = IBUF+ISBZ
      IF (IBUF.LE.0) GO TO 100
C
      CALL RDTRL(TRL)
      IF (TRL(1).LE.0) GO TO 90
      IF (TRL(2).LE.I) GO TO 110
      CALL OPEN(*90,TRL(1),ZZ(IBF2),IRDRW)
      PARM(2) = MCB(1)
      CALL OPEN(*90,MCB(1),ZZ(IBUF),IWTRW)
      CALL WRITE(MCB(1),MCB(1),2,1)
      PARM(2) = TRL(1)
      CALL FWDREC(*120,TRL(1))
C
      MCB(2) = TRL(2) - I
      MCB(3) = TRL(3)
      MCB(4) = TRL(4)
      MCB(5) = TRL(5)
      MCB(6) = TRL(6)
      DO 20 J = 1,I
      CALL FWDREC(*120,TRL(1))
   20 CONTINUE
      CALL CPYFIL (TRL,MCB,ZZ,IBUF-1,COUNT)
      RCNT = COUNT
      MCB(7) = ICNT
      CALL EOF (MCB)
C
      CALL CLOSE (TRL(1),KRW)
      CALL CLOSE (MCB(1),KRW)
      CALL WRTTRL (MCB(1))
       GO TO 60
   55 MCB(1) = TRL(1)
   60 RETURN
C
C  . ERROR MESSAGES...
C
   90 PARM(1) = +1
       GO TO 130
  100 PARM(1) = +8
       GO TO 130
  110 PARM(1) = +7
       GO TO 130
  120 PARM(1) = +2
C
  130 CALL MESAGE (PARM(1),PARM(2),PARM(3))
      RETURN 1
      END
