      SUBROUTINE ORDER (GPLST,ID,REST,GRIDS,IDTAB,LCOR,B1,B2,B3)        
C        
      LOGICAL         SPILL        
      INTEGER         GRIDS(1),ID(1),IDTAB(2),TP,GPLST(1),IGRD(2),SCR4, 
     1                ISYM(14),ITYPE(14),HOLD(3),ELID,SILS(34),REST(2), 
     2                EST,SIL,SCR2,ECPT,B1,B2,B3,THREE(3),OFFSET        
      COMMON /BLANK / NGP,SKP(11),EST,SKIP1(3),SIL,SKIP2(5),ECPT,OES1,  
     1                SCR1,SCR2,NEWOES,SCR4        
      EQUIVALENCE     (THREE(1),IFLAG),(THREE(2),NELMT),(THREE(3),IGDPT)
      EQUIVALENCE     (KQ4,ISYM(13)),(KT3,ISYM(14))        
      DATA    ISYM  / 2HSH,2HT1,2HTB,2HTP,2HTM,2HQP,2HQM,2HT2,2HQ2,2HQ1,
     1                2HM1,2HM2,2HQ4,2HT3/    ,KBAR/2HBR/        
      DATA    ITYPE / 4,6,7,8,9,15,16,17,18,19,62,63,64,83/        
      DATA    NTYPE / 14 /        
C        
C     BUILD A TABLE FOR GPECT POINTERS TO ELID AND ITS ORDERED GRID PTS 
C        
      SPILL = .FALSE.        
      J = 1        
      I = 3        
      IDTAB(1) = 0        
      JSPILL = 1        
      LCORX  = LCOR        
      NEWIN  = SCR4        
      NEWOUT = SCR2        
 2    CALL READ (*130,*12,EST,TP,1,0,M)        
      OFFSET = 0        
      IF (TP .EQ. KBAR) OFFSET = 6        
      IF (TP.EQ.KT3 .OR. TP.EQ.KQ4) OFFSET = 1        
 3    CALL FREAD (EST,NGPPE,1,0)        
      IDTAB(I-1) = NGPPE        
C        
C     SKIP PAST THE NON-CONTOUR ELEMENTS        
C        
      DO 4 K = 1,NTYPE        
      IF (TP .EQ. ISYM(K)) GO TO 8        
 4    CONTINUE        
 6    CALL FREAD (EST,ELID,1,0)        
      IF (ELID .EQ. 0) GO TO 2        
      J = 1 + NGPPE + OFFSET        
      CALL FREAD (EST,0,-J,0)        
      GO TO 6        
C        
C     CONSTRUCT IDTAB  1. 0, 2.NGPPE, 3.ELID, 4.ELIDPTR, 5.REPEAT.  3,4 
C     FOR ALL ELEMENTS OF THIS TYPE, 6.REPEAT 1-5 FOR ALL ELEMENTS IN   
C     THE SET. CONSTRUCT GRIDS  1-NGPPE. GRIDS FOR 1ST ELEMENT, NEXT.   
C     REPEAT 1ST FOR ALL ELEMENTS IN THE IDTAB        
C        
 8    CALL READ (*12,*12,EST,IDTAB(I),2,0,M)        
      I = I + 2        
      IF (IDTAB(I-2) .NE. 0) GO TO 10        
C        
C     END OF ELEMENTS OF THIS TYPE        
C        
      TP = IDTAB(I-1)        
      GO TO 3        
C        
 10   CALL FREAD (EST,GRIDS(J),NGPPE,0)        
      IF (OFFSET .NE. 0) CALL FREAD (EST,0,-OFFSET,0)        
      J = J + NGPPE        
      IF (I .GE. LCORX) GO TO 14        
      GO TO 8        
C        
C     TABLE FIT INTO CORE        
C        
 12   CALL BCKREC (EST)        
      GO TO 16        
C        
C     SPILL OCCURS - TABLE DID NOT FIT        
C        
 14   SPILL = .TRUE.        
C        
C     END OF TABLE        
C        
 16   LIDTAB = I - 1        
      IF (LIDTAB .LE. 2) GO TO (130,140), JSPILL        
      LGRIDS = J - 1        
      LASTNG = NGPPE        
      GO TO (18,140), JSPILL        
 18   CALL OPEN (*130,ECPT,GPLST(B2),0)        
      CALL GOPEN (SCR2,GPLST(B1),1)        
      CALL FWDREC (*120,ECPT)        
      IGDPT = 0        
 20   IGDPT = IGDPT + 1        
      IEOR  = 0        
      IF (GPLST(IGDPT) .NE. 0) GO TO 25        
      CALL FWDREC (*120,ECPT)        
      GO TO 20        
 25   NELMT = 0        
      IFLAG =-1        
C        
C      ECPT--1. PIVOT POINT, 2. DEG.FREEDOM, 3. -LENGTH, 4. ELID POINTER
C      5. ELTYPE, 6.SILS (THERE ARE (LENGTH-2) OF THEM), 7. REPEAT ITEMS
C      (3-6) FOR ALL ELEMENTS ATTACHED TO PIVOT, 8. EOR, 9. REPEAT ITEMS
C      (1-8) FOR ALL GRIDS IN THE PROBLEM.        
C        
      CALL READ (*120,*120,ECPT,IGRD,2,0,M)        
 30   CALL READ (*120,*75,ECPT,LENGTH,1,0,M)        
      CALL FREAD (ECPT,SILS,-LENGTH,0)        
      TP = SILS(2)        
      DO 32 I = 1,NTYPE        
      IF (TP .EQ. ITYPE(I)) GO TO 33        
 32   CONTINUE        
      GO TO 30        
C        
C     MATCH ELIDPTR WITH ITS ELID AND GRID POINTS IF POSSIBLE        
C        
 33   J = 1        
      DO 50 I = 1,LIDTAB,2        
      IF (IDTAB(I)) 40,35,40        
 35   NGPPE = IDTAB(I+1)        
      GO TO 50        
 40   IF (IDTAB(I+1) .EQ. SILS(1)) GO TO 55        
      J = J + NGPPE        
 50   CONTINUE        
C        
C     IF NOT IN THE TABLE, IS THERE SPILL(IE IS TABLE NOT COMPLETE).    
C     NO SPILL, SKIP HIM.  YES SPILL, FLAG HIM.        
C        
      IF (.NOT.SPILL) GO TO (30,145), JSPILL        
      ELID  =-SILS(1)        
      NELMT = NELMT + 1        
      GO TO 70        
C        
C     FOUND ELEMENT IN THE TABLE        
C        
 55   ELID = IDTAB(I)        
      DO 60 I = 1,NGPPE        
      K = J + I - 1        
      IF (IGDPT .EQ. GRIDS(K)) GO TO 65        
 60   CONTINUE        
 65   IAFTER = I - (I/NGPPE)*NGPPE + J        
      IBEFOR = J + I - 2        
      IF (I .EQ. 1) IBEFOR = IBEFOR + NGPPE        
      NELMT = NELMT + 1        
      REST(2*NELMT-1) = GRIDS(IAFTER)        
      REST(2*NELMT  ) = GRIDS(IBEFOR)        
 70   ID(NELMT) = ELID        
      IF (NELMT .LT. LCOR/2) GO TO (30,145), JSPILL        
      GO TO 80        
 75   IF (NELMT .EQ. 0) GO TO (20,140), JSPILL        
      IEOR = 1        
C        
C     ORDER ELEMENTS IF WE HAVE REACHED END OF EST FILE        
C        
 80   IF (SPILL) GO TO 112        
      IF (NELMT .LE.2)  GO TO 110        
      INDEX = 3        
      IALL  = 2*NELMT        
      IONE  = REST(1)        
      ITWO  = REST(2)        
 85   IF (IONE .EQ. ITWO) GO TO 105        
      DO 90 I = INDEX,IALL,2        
      IF (ITWO .EQ. REST(I)) GO TO 95        
 90   CONTINUE        
      GO TO 110        
 95   IF (I .EQ. INDEX) GO TO 100        
      J = (INDEX+1)/2        
      K = (I+1)/2        
      HOLD(1) = ID(J)        
      ID(J)   = ID(K)        
      ID(K)   = HOLD(1)        
      HOLD(2) = REST(INDEX  )        
      HOLD(3) = REST(INDEX+1)        
      REST(INDEX  ) = REST(I  )        
      REST(INDEX+1) = REST(I+1)        
      REST(I  ) = HOLD(2)        
      REST(I+1) = HOLD(3)        
 100  INDEX = INDEX + 2        
      ITWO  = REST(INDEX-1)        
      IF (INDEX .LT. IALL) GO TO 85        
      IF (IONE  .NE. ITWO) GO TO 110        
C        
C     INTERIOR ELEMENTS        
C        
 105  CALL WRITE (NEWOUT,THREE,3,0)        
      CALL WRITE (NEWOUT,ID,NELMT,1)        
      IF (IGDPT .LT. NGP) GO TO (20,140), JSPILL        
      GO TO 120        
C        
C     BORDER ELEMENTS        
C        
 110  IFLAG = -2        
 112  CALL WRITE (NEWOUT,THREE,3,0)        
      J = -1        
      DO 115 I = 1,NELMT        
      J = J + 2        
      CALL WRITE (NEWOUT,ID(I),1,0)        
      CALL WRITE (NEWOUT,REST(J),2,0)        
 115  CONTINUE        
      IQ = 2*NELMT        
      CALL WRITE (NEWOUT,0,0,1)        
      GO TO (118,140), JSPILL        
 118  IF (IEOR) 25,25,119        
 119  IF (IGDPT .LT.NGP) GO TO 20        
 120  CALL CLOSE (ECPT,1)        
 125  CALL WRITE (NEWOUT,0,1,1)        
      CALL CLOSE (NEWOUT,1)        
C        
C     IF NO SPILL -  RETURN        
C        
 130  IF (.NOT.SPILL) GO TO 170        
C        
C    COME HERE IF WE HAVE SPILL        
C        
      I = NEWOUT        
      NEWOUT = NEWIN        
      NEWIN  = I        
      CALL GOPEN (NEWIN,GPLST(B1),0)        
      CALL GOPEN (NEWOUT,GPLST(B2),1)        
      JSPILL = 2        
      NGPPE  = LASTNG        
      IDTAB(1) = 0        
      IDTAB(2) = LASTNG        
      I = 3        
      J = 1        
      SPILL = .FALSE.        
      GO TO 8        
C        
C     TABLE CONSTRUCTED SO RETURN HERE        
C        
 140  CALL READ (*160,*160,NEWIN,THREE,3,0,M)        
      NELMT = 0        
 145  CALL READ (*160,*75,NEWIN,SILS(1),3,0,M)        
      IF (SILS(1)) 150,150,155        
 150  SILS(1) = -SILS(1)        
      GO TO 33        
 155  ELID  = SILS(1)        
      NELMT = NELMT + 1        
      REST(2*NELMT-1) = SILS(2)        
      REST(2*NELMT  ) = SILS(3)        
      GO TO 70        
C        
C     END OF FILE        
C        
 160  CALL CLOSE (NEWIN,1)        
      GO TO 125        
C        
C     OUTPUT FILE MUST BE SCRATCH 2        
C        
 170  IF (NEWOUT .EQ. SCR2) RETURN        
      CALL GOPEN  (NEWOUT,GPLST(B1),0)        
      CALL GOPEN  (SCR2,GPLST(B2),1)        
      CALL CPYFIL (NEWOUT,SCR2,REST,LCOR,M)        
      CALL CLOSE  (SCR2,1)        
      CALL CLOSE  (NEWOUT,1)        
      RETURN        
      END        
