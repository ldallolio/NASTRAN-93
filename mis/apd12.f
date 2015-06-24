      SUBROUTINE APD12        
C        
      EXTERNAL        ORF        
      LOGICAL         LS,LC,DLB        
      INTEGER         AUSET(6,2),ORF,PSPA,UK,USA,IZ(1),NAM(2),        
     1                EID,PID,CP,CIDBX,ACSID,SILB,SCR1,SCR2,SCR3,SCR4,  
     2                SCR5,ECTA,BGPA,GPLA,USETA,SILA,CSTMA,ACPT,BUF10,  
     3                BUF11,BUF12,IAX(20),        
     4                CA2S,CA2E,CA3S,CA3E,CA4S,CA4E,        
     5                PA2S,PA2E,PA3S,PA3E,PA4S,PA4E        
      COMMON /SYSTEM/ SYSBUF,IUT        
      COMMON /APD1C / EID,PID,CP,NSPAN,NCHORD,LSPAN,LCHORD,IGID,        
     1                X1,Y1,Z1,X12,X4,Y4,Z4,X43,XOP,X1P,ALZO,MCSTM,     
     2                NCST1,NCST2,CIDBX,ACSID,IACS,SILB,NCRD,SCR1,      
     3                SCR2,SCR3,SCR4,SCR5,ECTA,BGPA,GPLA,USETA,SILA,    
     4                CSTMA,ACPT,BUF10,BUF11,BUF12,NEXT,LEFT,ISILN,     
     5                NCAM,NAEF1,NAEF2,NCA1,NCA2,CA2S,CA2E,CA3S,CA3E,   
     6                CA4S,CA4E,NPA1,NPA2,PA2S,PA2E,PA3S,PA3E,PA4S,PA4E 
      COMMON /APD12C/ KEY(5),AUSET,USA,UK,NCAM2,NASB,IPPC        
      COMMON /BITPOS/ IBIT(64)        
      COMMON /TWO   / ITWO(32)        
CZZ   COMMON /ZZAPDX/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE    (Z(1),IZ(1)),(EID,IAX(1))        
      DATA    NAM   /4HAPD1,4H2   /        
C        
      I17 = IBIT(17)        
      I18 = IBIT(18)        
      I19 = IBIT(19)        
      I20 = IBIT(20)        
      PSPA= ORF(ITWO(I17),ITWO(I20))        
      USA = ORF(PSPA,ITWO(I18))        
      UK  = ORF(ITWO(I19),ITWO(I20))        
      DO 10 J = 1,2        
      DO 10 I = 1,6        
   10 AUSET(I,J) = USA        
      AUSET(3,2) = UK        
      AUSET(5,2) = UK        
      NCAM = ((NCA2-NCA1)+1)/16        
      IF (NCA1 .EQ. 0) NCAM = 0        
      NCAM2 = ((CA2E-CA2S)+1)/16        
      IF (CA2S .EQ. 0) NCAM2 = 0        
      LCA = 16        
C        
C     CREATE IGID SEQUENCE ARRAY        
C        
      NIGID1 = NEXT        
      IGID2  = NEXT        
      NIGID  = NEXT        
      NX = NCA1        
      J  = NIGID1        
      IF (NCAM .EQ. 0) GO TO 15        
      DO 240 I = 1,NCAM        
      IZ(J) = IZ(NX+7)        
      J = J + 1        
      IZ(J) = NX        
      NX = NX + LCA        
  240 J = J + 1        
C        
C     SORT IGID ARRAY ON IGID        
C        
      CALL SORT (0,0,2,1,IZ(NIGID1),2*NCAM)        
   15 IF (NCAM2 .EQ. 0) GO TO 30        
      NX = CA2S        
      NIGID2 = J        
      DO 20 I = 1,NCAM2        
      IZ(J) = IZ(NX+7)        
      J = J + 1        
      IZ(J) = NX        
      NX = NX + LCA        
   20 J = J + 1        
      CALL SORT (0,0,2,1,IZ(NIGID2),2*NCAM2)        
      IGID2 = NIGID2        
   30 NEXTC = J        
      IF (NCAM .EQ. 0) GO TO 500        
      NIGID = NIGID1        
C        
C     OUTTER LOOP PROCESSES CAERO1 CARDS        
C        
      DO 410 I = 1,NCAM        
C        
C     SET APD1 INPUT COMMON BLOCK        
C        
      NC = IZ(NIGID+1) - 1        
C        
C     MOVE CAERO TO COMMON        
C        
      DO 250 J = 1,16        
      N1 = J + NC        
  250 IAX(J) = IZ(N1)        
      MCSTM  = MCSTM + 1        
      IZ(NC+2) = MCSTM        
C        
C     FIND PAERO1 CARD        
C        
      IF (NPA1 .EQ. 0) GO TO 890        
      DO 260 J = NPA1,NPA2,8        
      IPPC = J        
      IF (PID .EQ. IZ(J)) GO TO 270        
  260 CONTINUE        
      GO TO 890        
  270 XOP  = .25        
      X1P  = .75        
      ALZO = 0.0        
C        
C     FIND AEFACT ARRAYS IF PRESENT        
C        
      JSPAN  = NSPAN        
      JCHORD = NCHORD        
      IF (LSPAN .EQ. 0) GO TO 280        
      CALL APDOE (LSPAN,IZ,NAEF1,NAEF2,ISPAN,JSPAN)        
      IF (ISPAN .EQ. 0) GO TO 850        
      ISPAN = ISPAN + 1        
      JSPAN = JSPAN - 1        
  280 IF (LCHORD .EQ. 0) GO TO 350        
      CALL APDOE (LCHORD,IZ,NAEF1,NAEF2,ICHORD,JCHORD)        
      IF (ICHORD .EQ. 0) GO TO 860        
      ICHORD = ICHORD + 1        
      JCHORD = JCHORD - 1        
  350 CONTINUE        
C        
C     CHECK IF FIRST OR LAST ENTRY IN IGID SET        
C        
      LS = .FALSE.        
      IF (I .EQ. 1) GO TO 370        
      IF (IZ(NIGID) .EQ. IZ(NIGID-2)) GO TO 380        
  370 LS = .TRUE.        
  380 LC = .FALSE.        
      DLB= .FALSE.        
      IF (I .EQ. NCAM) GO TO 390        
      IF (IZ(NIGID) .EQ. IZ(NIGID+2)) GO TO 400        
  390 LC = .TRUE.        
C        
C     CHECK FOR CAERO2 ELEMENT        
C        
      IF (NCAM2 .EQ. 0) GO TO 400        
      IF (NIGID2 .GT. NEXTC) GO TO 50        
   40 IF (IZ(NIGID2) .GT. IZ(NIGID)) GO TO 50        
      IF (IZ(NIGID) .EQ. IZ(NIGID2)) DLB = .TRUE.        
      IF (DLB) GO TO 50        
      NIGID2 = NIGID2 + 2        
      IF (NIGID2 .GT. NEXTC) GO TO 50        
      GO TO 40        
   50 CONTINUE        
      IF (DLB) LC = .FALSE.        
C        
C     CALL APD1 TO MANUFACTURE BOXES        
C        
  400 CALL APD1 (Z(ISPAN),JSPAN,Z(ICHORD),JCHORD,LS,LC)        
      NCHORD = JCHORD        
      NSPAN  = JSPAN        
      IZ(NC+4) = NSPAN        
      IZ(NC+5) = NCHORD        
      IZ(NC+8) = 1        
      IF (.NOT.DLB) GO TO 410        
C        
C     PROCESS CAERO2 WITH CAERO1        
C        
      CALL APD2 (1,IZ(NEXT),IZ(IGID2 ),NEXTC,IZ(NIGID))        
  410 NIGID = NIGID + 2        
C        
C     PROCESS CAERO2 CARDS NOT PROCESSED YET        
C        
  500 IF (NCAM2 .EQ. 0) GO TO 1000        
      CALL APD2 (0,IZ(NEXT),IZ(IGID2 ),NEXTC,IZ(NIGID))        
 1000 RETURN        
C        
C     ERROR MESSAGES        
C        
  812 CALL MESAGE (-61,0,NAM)        
  850 CALL EMSG (0,2326,1,2,0)        
      WRITE  (IUT,851) EID,LSPAN        
  851 FORMAT (10X,19HCAERO1 ELEMENT NO. ,I8,28H REFERENCES AEFACT CARD N
     1O. ,I8,22H WHICH DOES NOT EXIST.)        
      GO TO 812        
  860 CALL EMSG (0,2327,1,2,0)        
      WRITE (IUT,851) EID,LCHORD        
      GO TO 812        
  890 CALL EMSG (0,2323,1,2,0)        
      WRITE  (IUT,891) PID,EID        
  891 FORMAT (10X,16HPAERO1 CARD NO. , I8,31H REFERENCED BY CAERO1 CARD 
     1NO. ,I8,20H BUT DOES NOT EXIST.)        
      GO TO 812        
      END        
