      SUBROUTINE AMG        
C        
C     THIS IS THE MAIN DRIVER FOR AEROELASTIC MATRIX GENERATION        
C        
C     NOTES ON NEW METHOD IMPLIMENTATION        
C     1. ACPT FILE WILL BE POSITIONED READY TO READ AN INPUT RECORD     
C        LEAVE FILE READY TO READ NEXT RECORD.        
C        
C     2. ALWAYS PACK OUT A COLUMN (REALY A ROW) OF NJ LENGTH        
C        OUTPUT FILE, PACKX, AND TRAILER(MCB) WILL BE SET UP        
C        
C     3. YOUR ROW POSITION WILL START AT NROW + 1        
C        
C     4. ALWAYS BUMP NROW BY THE NUMBER OF ROWS WHICH EXIST IN        
C        YOUR INPUT RECORD        
C        
C     5. COMPUTATIONS FOR AJJK MATRIX WILL HAVE 3 BUFFERS OF CORE USED  
C        COMPUTATIONS FOR OTHER MATRICES WILL HAVE 4 BUFFERS USED       
C        
      LOGICAL         DEBUG        
      INTEGER         SYSBUF,BUF1,BUF2,BUF3,AERO,ACPT,AJJL,SKJ,W1JK,    
     1                W2JK,TSKJ,TW1JK,TW2JK        
      DIMENSION       FMACH(1),ND(1),NAME(2)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /BLANK / NK,NJ        
      COMMON /AMGMN / MCB(7),NROW,ND,NE,REFC,FMACH,RFK,TSKJ(7),ISK,NSK  
      COMMON /AMGP2 / TW1JK(7),TW2JK(7)        
      COMMON /SYSTEM/ SYSBUF,IOUT        
      COMMON /PACKX / ITI,ITO,II,NN,INCR        
      COMMON /AMGBUG/ DEBUG        
CZZ   COMMON /ZZAMGX/ IZ(1)        
      COMMON /ZZZZZZ/ IZ(1)        
      DATA    NAME  / 4HAMG ,4H      /        
      DATA    AERO  / 101/, ACPT /102/, AJJL /201/,        
     1        SKJ   / 202/, W1JK /203/, W2JK /204/        
C        
      DEBUG =.FALSE.        
      CALL SSWTCH (20,J)        
      IF (J .EQ. 1) DEBUG =.TRUE.        
C        
C     USE IZ TO COMPUTE BUFFERS        
C        
      ICORE = KORSZ(IZ)        
      IFILE = 4*SYSBUF + 3*NJ        
      IF (ICORE .LE. IFILE) GO TO 460        
C        
C     OPEN INPUT STRUCTURAL DATA        
C        
      ICORE = ICORE - SYSBUF        
      CALL GOPEN (ACPT,IZ(ICORE+1),0)        
C        
C     OPEN AND SKIP HEADER ON AERO        
C        
      IFILE = AERO        
      BUF1  = ICORE - SYSBUF        
      CALL GOPEN (AERO,IZ(BUF1+1),0)        
C        
C     READ 3 INPUT WORDS INTO COMMON        
C        
      CALL READ (*450,*450,AERO,ND,3,1,N)        
C        
C     OPEN OUTPUT FILE FOR AJJL MATRIX, SET UP TRAILER AND WRITE HEADER 
C        
      BUF2  = BUF1 - SYSBUF        
      IFILE = AJJL        
      CALL OPEN  (*440,AJJL,IZ(BUF2+1),1)        
      CALL FNAME (AJJL,MCB)        
      CALL WRITE (AJJL,MCB,2,0)        
      CALL WRITE (AJJL,NJ,1,0)        
      CALL WRITE (AJJL,NK,1,0)        
      BUF3  = BUF2 - SYSBUF        
      CALL GOPEN (SKJ,IZ(BUF3+1),1)        
      IFILE = AERO        
      CALL READ (*440,*10,AERO,IZ,BUF3,0,N)        
      GO TO 460        
   10 NMK   = N/2        
      CALL REWIND (AERO)        
      CALL FWDREC (*450,AERO)        
      CALL FWDREC (*450,AERO)        
      CALL WRITE  (AJJL,NMK,1,0)        
      CALL WRITE  (AJJL,IZ,N,0)        
      IFILE = ACPT        
      IZ(1) = 0        
      N1    = 2        
   20 CALL READ (*90,*90,ACPT,METHOD,1,0,N)        
      IZ( 1) = IZ(1) + 1        
      IZ(N1) = METHOD        
      GO TO (30,40,50,50,50,60,70), METHOD        
C        
C     DOUBLET LATTICE METHOD        
C        
   30 CONTINUE        
      CALL READ (*440,*450,ACPT,MCB,3,1,N)        
C        
C     NUMBER OF COLUMNS ADDED EQUAL NUMBER OF BOXES        
C        
      IZ(N1+1) = MCB(3)        
      IZ(N1+2) = MCB(3)        
      GO TO 80        
C        
C     DOUBLET LATTICE WITH BODIES        
C        
   40 CALL READ (*440,*450,ACPT,MCB,2,1,N)        
      IZ(N1+1) = MCB(1)        
      IZ(N1+2) = MCB(2)        
      GO TO 80        
C        
C     MACH BOX  STRIP THEORY  PISTON THEORY        
C        
   50 CALL READ (*440,*450,ACPT,MCB,1,1,N)        
      IZ(N1+1) = MCB(1)        
      IZ(N1+2) = MCB(1)        
      GO TO 80        
C        
C     COMPRESSOR BLADE METHOD        
C        
   60 CALL READ (*440,*450,ACPT,MCB,5,1,N)        
C        
C     NUMBER OF COLUMNS ADDED IS NJ = NK = (NSTNS*NLINES) FOR THE BLADE 
C        
      IZ(N1+1) = MCB(4)*MCB(5)        
      IZ(N1+2) = IZ(N1+1)        
      GO TO 80        
C        
C     SWEPT TURBOPROP BLADE METHOD        
C        
   70 CALL READ (*440,*450,ACPT,MCB,5,1,N)        
C        
C     NUMBER OF COLUMNS ADDED IS NJ = NK = (2*NSTNS*NLINES) FOR THE PROP
C        
      IZ(N1+1) = 2*MCB(4)*MCB(5)        
      IZ(N1+2) = IZ(N1+1)        
   80 N1 = N1 + 3        
      GO TO 20        
   90 CALL REWIND (ACPT)        
      CALL WRITE  (AJJL,IZ,N1-1,1)        
      MCB(1)  = AJJL        
      MCB(2)  = 0        
      MCB(3)  = NJ        
      MCB(4)  = 2        
      MCB(5)  = 3        
      MCB(6)  = 0        
      MCB(7)  = 0        
      INCR    = 1        
      TSKJ(1) = SKJ        
      TSKJ(2) = 0        
      TSKJ(3) = NK        
      TSKJ(4) = 2        
      TSKJ(5) = 3        
      TSKJ(6) = 0        
      TSKJ(7) = 0        
      IFILE   = ACPT        
C        
C     READ MACH NUMBER AND REDUCED FREQUENCY AND LOOP UNTIL COMPLETED   
C        
  100 CALL READ (*210,*210,AERO,FMACH,2,0,N)        
C        
C     NUMBER OF ROWS ADDED BY EACH RECORD ON ACPT        
C        
      NROW = 0        
      ISK  = 1        
      NSK  = 0        
C        
C     SKIP HEADER        
C        
      CALL FWDREC (*450,ACPT)        
C        
C     READ A RECORD AND LOOP BY METHOD UNTIL EOF        
C     NSK IS BUMPED BY DRIVERS = COLUMNS BUILT  ISK = NEXT COLUMN       
C        
  110 CALL READ (*200,*200,ACPT,METHOD,1,0,N)        
      GO TO (120,130,140,150,160,170,180), METHOD        
C        
C     DOUBLET LATTICE METHOD        
C        
  120 CALL DLAMG (ACPT,AJJL,SKJ)        
      GO TO 190        
C        
C     DOUBLET LATTICE WITH BODIES        
C        
  130 CALL DLAMBY (ACPT,AJJL,SKJ)        
      GO TO 190        
C        
C     MACH BOX        
C        
  140 CALL MBAMG (ACPT,AJJL,SKJ)        
      GO TO 190        
C        
C     STRIP THEORY        
C        
  150 CALL STPDA (ACPT,AJJL,SKJ)        
      GO TO 190        
C        
C     PISTON THEORY        
C        
  160 CALL PSTAMG (ACPT,AJJL,SKJ)        
      GO TO 190        
C        
C     COMPRESSOR BLADE METHOD        
C        
  170 CALL AMGB1 (ACPT,AJJL,SKJ)        
      GO TO 190        
C        
C     SWEPT TURBOPROP BLADE METHOD        
C        
  180 CALL AMGT1 (ACPT,AJJL,SKJ)        
  190 IF (NSK .GT. NK) GO TO 400        
      IF (NROW.GT. NJ) GO TO 420        
      GO TO 110        
  200 CALL REWIND (ACPT)        
      GO TO 100        
  210 CALL CLOSE  (AERO,1)        
      CALL CLOSE  (AJJL,1)        
      CALL CLOSE  (SKJ,1)        
      CALL WRTTRL (TSKJ)        
      CALL WRTTRL (MCB)        
C        
C     COMPUTE W1JK - W2JK        
C        
C        
C     OPEN OUTPUT FILES        
C        
      CALL FWDREC (*450,ACPT)        
      IFILE = W1JK        
      CALL GOPEN (W1JK,IZ(BUF1+1),1)        
      IFILE = W2JK        
      CALL GOPEN (W2JK,IZ(BUF2+1),1)        
      IFILE = ACPT        
C        
C     SET UP PACKX AND TRAILERS        
C        
      INCR = 1        
      ITI  = 1        
      ITO  = 1        
C        
C     II AND NN ARE BUMPED BY METHOD DRIVERS        
C        
      II   = 1        
      DO 220 I = 2,7        
      TW1JK(I) = 0        
      TW2JK(I) = 0        
  220 CONTINUE        
      TW1JK(1) = W1JK        
      TW2JK(1) = W2JK        
      TW1JK(3) = NK        
      TW1JK(4) = 2        
      TW1JK(5) = 1        
      TW2JK(3) = NK        
      TW2JK(4) = 2        
      TW2JK(5) = 1        
C        
C     READ A RECORD AND LOOP ON METHOD UNTIL EOR        
C        
  230 CALL READ (*300,*300,ACPT,METHOD,1,0,N)        
      GO TO (240,250,260,260,260,270,280), METHOD        
C        
C     DOUBLET LATTICE METHOD        
C        
  240 CALL DLPT2 (ACPT,W1JK,W2JK)        
      GO TO 290        
C        
C     DOUBLET LATTICE WITH BODIES        
C        
  250 CALL DLBPT2 (ACPT,W1JK,W2JK)        
      GO TO 290        
C        
C     STRIP THEORY     PISTON THEORY        
C     MACH BOX        
C        
  260 CALL STPPT2 (ACPT,W1JK,W2JK)        
      GO TO 290        
C        
C     COMPRESSOR BLADE METHOD        
C        
  270 CALL AMGB2 (ACPT,W1JK,W2JK)        
      GO TO 290        
C        
C     SWEPT TURBOPROP BLADE METHOD        
C        
  280 CALL AMGT2 (ACPT,W1JK,W2JK)        
  290 IF (NN .GT. NK) GO TO 410        
      GO TO 230        
C        
C     DONE        
C        
  300 CALL CLOSE  (ACPT,1)        
      CALL CLOSE  (W1JK,1)        
      CALL CLOSE  (W2JK,1)        
      CALL WRTTRL (TW1JK)        
      CALL WRTTRL (TW2JK)        
      RETURN        
C        
C     ERROR MESSAGES        
C        
C     NROW IN RECORDS DID NOT MATCH NJ PARAMETER        
C        
  400 NROW = NSK        
      NJ   = NK        
      GO TO 420        
  410 NROW = NN        
      NJ   = NK        
  420 WRITE  (IOUT,430) SFM,NROW,NJ        
  430 FORMAT (A25,' 2264, NUMBER OF ROWS COMPUTED (',I4,') WAS GREATER',
     1       ' THAN SIZE REQUESTED FOR OUTPUT MATRIX (',I4,2H).)        
      CALL MESAGE (-61,N,NAME)        
  440 NMS = -1        
      GO TO 470        
  450 NMS = -2        
      GO TO 470        
  460 NMS = -8        
  470 CALL MESAGE (NMS,IFILE,NAME)        
      RETURN        
      END        
