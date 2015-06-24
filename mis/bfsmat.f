      SUBROUTINE BFSMAT (ND,NE,NB,NP,NTP,LENGTH,NTOTAL,SCR1,JF,JL,NAS,  
     1                   FMACH,YB,ZB,YS,ZS,X,DELX,EE,XIC,SG,CG,AR,RIA,  
     2                   NBEA1,NBEA2,NASB,NSARAY,NCARAY,BFS,AVR,CBAR,   
     3                   A0,XIS1,XIS2,KR,NSBEA,NT0)        
C        
C     NOTE:        
C     A JUMP (VIA AN ASSIGN STATEMENT) TO 200 AND A JUMP TO 1100 (ALSO  
C     VIA AN ASSIGN STATEMENT), INTO THE MIDDLES OF SOME DO LOOPS, ARE  
C     ACCEPTABLE ANSI 77 FORTRAN. HOWEVER, IBM COMPILER MAY COMPLAIN.   
C     THIS PROBLEM IS NOW ELIMINATED (BY G.C. 9/89)        
C        
C        
C        ND         SYMMETRY FLAG        
C        NE         GROUND EFFECTS FLAG        
C        NB         NUMBER OF BODIES        
C        NP         NUMBER OF PANELS        
C        NTP        NUMBER OF LIFTING SURFACE BOXES        
C        NTOTAL     NTP + TOTAL NO. OF Y AND Z ORIENTED BODY ELEMENTS   
C        LENGTH     NTOTAL + THE TOTAL NUMBER OF Z- AND Y-ORIENTED      
C                   SLENDER BODY ELEMENTS        
C        SCR1       FILE FOR OUTPUT        
C        JF         ROW FOR FIRST ZY BODY        
C        JL         ROW FOR LAST  ZY BODY        
C        NAS        ARRAY CONTAINING THE NUMBER OF ASSOCIATED BODIES    
C                   FOR EACH PANEL        
C        FMACH      MACH NUMBER        
C        YB         ARRAY OF -Y- COORDINATES OF THE BODIES        
C        ZB         ARRAY OF -Z- COORDINATES OF THE BODIES        
C        YS         ARRAY OF -Y- COORDINATES OF STRIPS AND BODIES       
C        ZS         ARRAY OF -Z- COORDINATES OF STRIPS AND BODIES       
C        X          ARRAY OF 3/4 CHORD LOCATIONS OF BOXES AND        
C                            1/2 CHORD FOR BODY ELEMENTS        
C        DELX       ARRAY OF LENGTHS OF BOXES AND BODY ELEMENTS        
C        EE         ARRAY OF THE SEMI-WITH OF STRIPS        
C        XIC        ARRAY OF 1/4 CHORD COORDINATES OF BOXES        
C        SG         ARRAY OF SINE   OF STRIP DIHEDRAL ANGLE        
C        CG         ARRAY OF COSINE OF STRIP DIHEDRAL ANGLE        
C        AR         ARRAY OF RATIO OF MAJOR AXES OF BODIES        
C        RIA        ARRAY OF RADII OF BODY ELEMENTS        
C        NBEA1      ARRAY OF NUMBER OF BODY ELEMENTS PER BODY        
C        NBEA2      ARRAY OF THE BODY ORIENTATION FLAGS PER BODY        
C        NASB       ARRAY OF THE BODIES ASSOCIATED WITH PANELS        
C        NSARAY     ARRAY OF THE NUMBER OF STRIPS PER PANEL        
C        NCARAY     ARRAY OF THE NUMBER OF CHORDWISE DIV. PER PANEL     
C        BFS        WORK ARRAY FOR TEMPORARY STORAGE OF THE BFS COLS.   
C        AVR        ARRAY OF RADII OF BODIES        
C        CBAR       REFERENCE CHORD        
C        A0         ARRAY OF SLENDER BODY ELEMENT RADII        
C        XIS1       ARRAY OF SLENDER BODY ELEMENT LEADING  EDGE COORD.S 
C        XIS2       ARRAY OF SLENDER BODY ELEMENT TRAILING EDGE COORD.S 
C        KR         REDUCED FREQUENCY        
C        NSBEA      ARRAY OF THE NUMBER OF ELEMENTS PER SLENDER BODY    
C        
      LOGICAL    LAST        
      INTEGER    SCR1        
      REAL       KR        
      COMPLEX    BFS(LENGTH,2) , FWZ, FWY, EIKJ1 , EIKJ2        
      DIMENSION  YB(1), ZB(1), YS(1), ZS(1), X(1), DELX(1), EE(1),      
     1           XIC(1), SG(1), CG(1), AR(1), RIA(1), AVR(1), XIS1(1),  
     2           XIS2(1), A0(1), NAS(1), NASB(1), NBEA1(1), NBEA2(1) ,  
     3           NSBEA(1), NCARAY(1), NSARAY(1)        
C        
C        
      BETA2 = 1.0 - FMACH**2        
      ICOL  = 0        
      KSP   = 1        
      GO TO 3000        
C        
   50 CONTINUE        
C        
C     -Y- ORIENTED BODIES AS SENDING ELEMENTS        
C        
      SGS   =-1.0        
      CGS   = 0.0        
      NASD  = 0        
      IZYFLG= 3        
      ASSIGN 4010 TO IBODY        
C     ASSIGN 1100 TO ICOLMN        
      GO TO 1000        
  100 CONTINUE        
C        
C     - LIFTING SURF. BOXES AS SENDING ELEMENTS        
C        
      IF (NTP .LE. 0) GO TO 800        
C     ASSIGN 200 TO ICOLMN        
      J     = 1        
      JP1   = J        
      IBOX  = 0        
      ISTRIP= 0        
      ISN   = 0        
      KSP   = 1        
C        
C     LOOP FOR -PANEL-        
C        
      DO 700 ISP = 1,NP        
      NS  = NSARAY(ISP)        
      NC  = NCARAY(ISP)        
      NS  = (NS-ISN) / NC        
      ISN = NSARAY(ISP)        
      NASD= NAS(ISP)        
C        
C     LOOP FOR -STRIP-        
C        
      DO 600 IS = 1,NS        
      ISTRIP= ISTRIP + 1        
      DYS   = YS(ISTRIP)        
      DZS   = ZS(ISTRIP)        
      SGS   = SG(ISTRIP)        
      CGS   = CG(ISTRIP)        
      WIDTH = 2.0 * EE(ISTRIP)        
C        
C     LOOP FOR -BOX-        
C        
      DO 500 IB = 1,NC        
      IBOX = IBOX + 1        
      DXS  = XIC(IBOX)        
C        
      ICOL = ICOL + 1        
C        
C     GO TO  4000        
C4000 CONTINUE        
      CALL FWMW (ND,NE,SGS,CGS,IRB,DRIA,AR,DXLE,DXTE,YB,ZB,DXS,DYS,     
     1           DZS,NASD,NASB(KSP),KR,BETA2,CBAR,AVR,FWZ,FWY)        
      BFS(ICOL,1) = FWZ * (DXTE - DXLE)        
      BFS(ICOL,2) = FWY * (DXTE - DXLE)        
      BFS(ICOL,1) = BFS(ICOL,1) * SCALE        
      BFS(ICOL,2) = BFS(ICOL,2) * SCALE        
C     GO TO ICOLMN, (1100,200)        
C 200 CONTINUE        
C        
      AREA = WIDTH * DELX(IBOX)        
      BFS(ICOL,1) = BFS(ICOL,1) * AREA        
      BFS(ICOL,2) = BFS(ICOL,2) * AREA        
  500 CONTINUE        
  600 CONTINUE        
      KSP = KSP + NASD        
  700 CONTINUE        
C        
C     -Z-  ORIENTED BODIES AS SENDING ELEMENTS        
C        
  800 CONTINUE        
      SGS   = 0.0        
      CGS   = 1.0        
      NASD  = 0        
      IZYFLG= 1        
      ASSIGN   50 TO IBODY        
C     ASSIGN 1100 TO ICOLMN        
      GO TO  1000        
C        
C        
C     *** LOOP FOR EACH INTERFERENCE BODY SENDING ELEMENT        
C        
 1000 CONTINUE        
      INDEX = NTP        
C        
C     --ISB-- IS THE SENDING BODY        
C        
      DO 1900 ISB  = 1,NB        
      IF (NBEA2(ISB) .EQ.     2 ) GO TO 1070        
      IF (NBEA2(ISB) .NE. IZYFLG) GO TO 1850        
 1070 DYS   = YB(ISB)        
      NSBE  = NBEA1(ISB)        
      JP1   = 1        
      LAST  = .FALSE.        
      DZS   = ZB(ISB)        
      EARG2 = 1.0        
C        
C     --ISBE-- IS THE ELEMENT OF THE SEND BODY        
C        
      DO 1800 ISBE = 1,NSBE        
      EARG1 = EARG2        
      INDEX = INDEX + 1        
      DXS   = X (INDEX) - DELX(INDEX) /4.0        
      EARG2 = KR * DELX(INDEX) / CBAR        
C        
C     CALCULATE THIS COLUMN        
C        
      ICOL  = ICOL + 1        
      EIKJ1 = CMPLX(COS(EARG1),-SIN(EARG1))        
      EIKJ2 = CMPLX(COS(EARG2), SIN(EARG2))        
C        
C     GO TO 4000        
C4000 CONTINUE        
      CALL FWMW (ND,NE,SGS,CGS,IRB,DRIA,AR,DXLE,DXTE,YB,ZB,DXS,DYS,     
     1           DZS,NASD,NASB(KSP),KR,BETA2,CBAR,AVR,FWZ,FWY)        
      BFS(ICOL,1) = FWZ * (DXTE - DXLE)        
      BFS(ICOL,2) = FWY * (DXTE - DXLE)        
      BFS(ICOL,1) = BFS(ICOL,1) * SCALE        
      BFS(ICOL,2) = BFS(ICOL,2) * SCALE        
C     GO TO ICOLMN, (1100,200)        
C1100 CONTINUE        
C        
C        
C     IS THIS THE FIRST COLUMN, YES  BRANCH        
C        
      IF (ISBE .EQ. 1) GO TO 1800        
      BFS(ICOL-1,1) = BFS(ICOL-1,1)*EIKJ1 - BFS(ICOL,1)*EIKJ2        
      BFS(ICOL-1,2) = BFS(ICOL-1,2)*EIKJ1 - BFS(ICOL,2)*EIKJ2        
 1800 CONTINUE        
      GO TO 1900        
 1850 INDEX = INDEX + NBEA1(ISB)        
 1900 CONTINUE        
C        
C     RETURN TO CALLING POINT - EITHER Y OR Z SENDING BODY ELEM        
C        
C     *** GO  EITHER TO THE  Y-ORIENTED INTERFERENCE BODY ELEMENT LOOP  
C         OR  TO THE LOOP FOR SLENDER BODY SENDING ELEMENTS        
C        
      GO TO IBODY, (50,4010)        
C        
C        
C     CALCULATE EACH ROW OF THE SENDING COLUMN        
C        
 3000 CONTINUE        
      IY   = 0        
      JF   = 0        
      NW   = LENGTH*2        
      IROW = 0        
C        
C     --IRB-- IS THE RECEIVING BODY        
C        
C     DO 3900 IRB = 1,NB        
      IRB  = 0        
 3050 IRB  = IRB + 1        
      IF (IRB .GT. NB) GO TO 3900        
      NRBE = NSBEA(IRB)        
      ITSB = NBEA2(IRB)        
C        
      XYB  = YB(IRB)        
      XZB  = ZB(IRB)        
      SCALE= 1.0        
      IF (ND.NE.0 .AND. XYB.EQ.0.0) SCALE = .5        
      IF (NE.NE.0 .AND. XZB.EQ.0.0) SCALE = SCALE*.5        
C        
C     --IRBE-- IS THE ELEM. OF THE REC. BODY        
C        
C     DO 3800 IRBE = 1,NRBE        
      IRBE = 0        
 3060 IRBE = IRBE + 1        
      IF (IRBE .GT. NRBE) GO TO 3800        
      IY   = IY   + 1        
      IROW = IROW + 1        
      DRIA = A0  (IY)        
      DXLE = XIS1(IY)        
      DXTE = XIS2(IY)        
      XX1  = DXLE        
      XX2  = DXTE        
      XAA  = DRIA        
      ICOL = 0        
      GO  TO  100        
C        
 3100 CONTINUE        
      GO TO (3110,3120,3130), ITSB        
 3110 CALL WRITE (SCR1,BFS(1,1),NW,0)        
      GO TO 3140        
 3120 CALL WRITE (SCR1,BFS(1,2),NW,0)        
      CALL WRITE (SCR1,BFS(1,1),NW,0)        
      IF (JF .EQ. 0) JF = IROW        
      IROW = IROW + 1        
      GO TO 3140        
 3130 CALL WRITE (SCR1,BFS(1,2),NW,0)        
      IROW = IROW - 1        
 3140 CONTINUE        
      GO TO 3060        
 3800 CONTINUE        
      GO TO 3050        
 3900 CONTINUE        
      JL = IROW        
      RETURN        
C        
C        
 4010 CONTINUE        
C        
C        
C     *** LOOP FOR EACH SLENDER BODY SENDING ELEMENT        
C        
      IZYFLG= 1        
      SGS   = 0.0        
      CGS   = 1.0        
 4050 CONTINUE        
      LSBE  =  0        
      DO 5000 LSB = 1,NB        
C        
C     --LSB-- IS THE INDEX OF THE SLENDER SENDING BODY        
C        
      IF (NSBEA(LSB) .EQ.      0) GO TO 5000        
      IF (NBEA2(LSB) .EQ.      2) GO TO 4070        
      IF (NBEA2(LSB) .NE. IZYFLG) GO TO 4097        
 4070 CONTINUE        
      XETA  =  YB(LSB)        
      XZETA =  ZB(LSB)        
      SCALE2=  SCALE        
      MSBE  =  NSBEA(LSB)        
      DO 4080 LSBS = 1,MSBE        
      LSBE  =  LSBE + 1        
      ICOL  =  ICOL + 1        
      XXIJ  = .50 * XIS1(LSBE) + .50 * XIS2(LSBE)        
      CALL FWMW (ND,NE,SGS,CGS,IRB,DRIA,AR,DXLE,DXTE,YB,ZB,XXIJ,XETA,   
     1           XZETA,NASD,NASB,KR,BETA2,CBAR,AVR,FWZ,FWY)        
      BFS(ICOL,1) =  FWZ * (DXTE - DXLE)        
      BFS(ICOL,2) =  FWY * (DXTE - DXLE)        
      BFS(ICOL,1) =  BFS(ICOL,1) * SCALE2        
      BFS(ICOL,2) =  BFS(ICOL,2) * SCALE2        
 4080 CONTINUE        
      GO TO 5000        
 4097 LSBE = LSBE + NSBEA(LSB)        
 5000 CONTINUE        
      IF (IZYFLG .EQ. 3) GO TO  5010        
      IZYFLG = 3        
      SGS =-1.0        
      CGS = 0.0        
      GO TO 4050        
 5010 CONTINUE        
C        
      GO TO 3100        
C        
      END        
