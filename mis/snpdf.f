      SUBROUTINE SNPDF (SL,CL,TL,SGS,CGS,SGR,CGR,X0,Y0,Z0,EE,DIJ,BETA,  
     1                  CV)        
C        
C     SNPDF CALCULATES THE STEADY PART OF THE INFLUENCE COEFFICIENT     
C     MATRIX ELEMENTS        
C        
      TEST1 = 0.9999        
      TEST2 = 0.0001*EE        
C        
C     ***  TEST1 AND TEST2  SERVE AS A MEASURE OF  'NEARNESS'  WITH     
C     RESPECT TO THE BOUND-  AND TRAILING VORTICES RESPECTIVELY - SEE   
C     TESTS BELOW        
C     NOTE THAT THE MACH NUMBER EFFECT IS ACCOUNTED FOR BY STRETCHING   
C     THE  X-COORDINATES AND THE  SWEEP ANGLE OF THE BOUND VORTEX LINE  
C        
      TLB   = TL/BETA        
      SQTLB = SQRT(1.0+TLB**2)        
      SLB   = TLB/SQTLB        
      CLB   = 1.0/SQTLB        
      CAVE  = CV        
      CLSGS = CLB*SGS        
      CLCGS = CLB*CGS        
      EX    = EE*TLB        
      EY    = EE*CGS        
      EZ    = EE*SGS        
      X0B   = X0/BETA        
      RIX   = X0B+ EX        
      RIY   = Y0 + EY        
      RIZ   = Z0 + EZ        
      RIMAG = SQRT(RIX**2 + RIY**2 + RIZ**2)        
      ROX   = X0B- EX        
      ROY   = Y0 - EY        
      ROZ   = Z0 - EZ        
      ROMAG = SQRT(ROX**2 + ROY**2 + ROZ**2)        
      CAB   = (RIX*SLB+ RIY*CLCGS + RIZ*CLSGS)/RIMAG        
      CBB   = (ROX*SLB+ ROY*CLCGS + ROZ*CLSGS)/ROMAG        
      CBI   =-RIX/RIMAG        
      CAO   = ROX/ROMAG        
      RICAB = RIMAG*CAB        
      DBX   = RIX - RICAB*SLB        
      DBY   = RIY - RICAB*CLCGS        
      DBZ   = RIZ - RICAB*CLSGS        
      DB2   = DBX**2 + DBY**2 + DBZ**2        
      DI2   = RIY**2 + RIZ**2        
      DO2   = ROY**2 + ROZ**2        
      ACAB  = ABS(CAB)        
      ACBB  = ABS(CBB)        
C        
C     ***  THE FOLLOWING IS A TEST TO SEE IF THE RECEIVING POINT LIES ON
C     OR NEAR THE BOUND VORTEX  --  IF SO, THE CONTRIBUTION OF THE BOUND
C     VORTEX IS SET TO ZERO        
C        
      IF (ACAB .GT. TEST1) GO TO 30        
      IF (ACBB .GT. TEST1) GO TO 30        
      CACB = (CAB-CBB)/DB2        
      GO TO  60        
   30 IF (CAB*CBB) 40,50,50        
   40 CACB = 0.        
      GO TO 60        
   50 CACB = 0.5*ABS((1./RIMAG**2)-(1./ROMAG**2))        
   60 CONTINUE        
      VBY = CACB*(DBX*CLSGS - DBZ*SLB)        
      VBZ = CACB*(DBY*SLB - DBX*CLCGS)        
C        
C     ***  TEST TO SEE IF THE RECEIVING POINT LIES ON OR NEAR THE       
C     INBOARD TRAILING VORTEX  --  IF SO, THE CONTRIBUTION OF THE       
C     INBOARD TRAILING VORTEX IS SET TO ZERO        
C        
      IF (DI2 .GT. TEST2) GO TO 62        
      VIY  = 0.0        
      VIZ  = 0.0        
      GO TO  64        
   62 CONTINUE        
      ONECBI = (1.0-CBI)/DI2        
      VIY =  ONECBI*RIZ        
      VIZ = -ONECBI*RIY        
   64 CONTINUE        
C        
C     ***  TEST TO SEE IF THE RECEIVING POINT LIES ON OR NEAR THE       
C     OUTBOARD TRAILING VORTEX  --  IF SO, THE CONTRIBUTION OF THE      
C     OUTBOARD TRAILING VORTEX IS SET TO ZERO        
C        
      IF (DO2 .GT. TEST2) GO TO 66        
      VOY  = 0.0        
      VOZ  = 0.0        
      GO TO  68        
   66 CONTINUE        
      CAOONE = (1.0+CAO)/DO2        
      VOY = -CAOONE*ROZ        
      VOZ =  CAOONE*ROY        
   68 CONTINUE        
      VY  = VBY + VIY + VOY        
      VZ  = VBZ + VIZ + VOZ        
      WW  = VY*SGR - VZ*CGR        
      DIJ = WW*CAVE/25.132741        
      RETURN        
      END        
