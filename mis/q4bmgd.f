      SUBROUTINE Q4BMGD (DSHP,GPTH,BGPDT,GPNORM,PHI,BMATRX)        
C        
C     THIS ROUTINE ASSEMBLES PORTIONS OF B-MATRIX FOR QUAD4        
C        
      LOGICAL          MEMBRN,BENDNG,SHRFLX,MBCOUP,NORPTH,BADJ        
      INTEGER          ROWFLG        
      REAL             GPNORM(4,1),BGPDT(4,1)        
      DOUBLE PRECISION BMATRX(1),PSITRN(9),BBAR(120),ATRANS(6),PHI(9),  
     1                 DSHP(1),GPTH(1),DERIV,THICK,HZTA,TERM,DETJ,      
     2                 UEV,UNV,ANGLEI,EDGEL,EDGSHR,BB1,BB2,BB3,        
     3                 BSBAR1(6),BSBAR(48),TEE(9)        
      COMMON /Q4DT  /  DETJ,HZTA,PSITRN,NNODE,BADJ,N1        
      COMMON /TERMS /  MEMBRN,BENDNG,SHRFLX,MBCOUP,NORPTH        
      COMMON /Q4COMD/  ANGLEI(4),EDGSHR(3,4),EDGEL(4),UNV(3,4),        
     1                 UEV(3,4),ROWFLG,IORDER(4)        
C*****        
C     INITIALIZE        
C*****        
      NDOF =NNODE*6        
      NDOF3=NNODE*3        
      ND2=NDOF*2        
      ND3=NDOF*3        
      ND4=NDOF*4        
      ND5=NDOF*5        
      ND6=NDOF*6        
C        
C     SET THE SIZE OF B-MATRIX BASED ON THE ROW FLAG.        
C     ROWFLG = 1      OUT OF PLANE SHEAR (LAST 2 ROWS)   ND2        
C     ROWFLG = 2      IN-PLANE SHEAR (THIRD  ROW)        NDOF        
C     ROWFLG = 3      THE FIRST SIX (THREE) ROWS         ND6 (ND3)      
C        
      NN = ND6        
      IF (NORPTH) NN = ND3        
      IF (ROWFLG .EQ. 1) NN = ND2        
      IF (ROWFLG .EQ. 2) NN = ND2        
C*****        
C     SET UP TERMS TO BE FILLED IN B-MATRIX        
C*****        
      DO 50 K=1,NNODE        
      KPOINT=6*(K-1)        
      THICK =GPTH(K)        
C        
C     COMPUTE THE TERMS WHICH GO IN THE FIRST 6(3) ROWS.        
C        
      IF (ROWFLG .EQ. 1) GO TO 20        
      ATRANS(1)=-PSITRN(2)*GPNORM(4,K)+PSITRN(3)*GPNORM(3,K)        
      ATRANS(2)= PSITRN(1)*GPNORM(4,K)-PSITRN(3)*GPNORM(2,K)        
      ATRANS(3)=-PSITRN(1)*GPNORM(3,K)+PSITRN(2)*GPNORM(2,K)        
      ATRANS(4)=-PSITRN(5)*GPNORM(4,K)+PSITRN(6)*GPNORM(3,K)        
      ATRANS(5)= PSITRN(4)*GPNORM(4,K)-PSITRN(6)*GPNORM(2,K)        
      ATRANS(6)=-PSITRN(4)*GPNORM(3,K)+PSITRN(5)*GPNORM(2,K)        
C        
      DO 10 I=1,2        
      IPOINT=ND3*(I-1)        
      ITOT =IPOINT+KPOINT        
      DERIV=DSHP(N1*(I-1)+K)        
      BBAR(     1+ITOT)=DERIV*PSITRN(1)        
      BBAR(     2+ITOT)=DERIV*PSITRN(2)        
      BBAR(     3+ITOT)=DERIV*PSITRN(3)        
      BBAR(NDOF+1+ITOT)=DERIV*PSITRN(4)        
      BBAR(NDOF+2+ITOT)=DERIV*PSITRN(5)        
      BBAR(NDOF+3+ITOT)=DERIV*PSITRN(6)        
      TERM=HZTA*THICK*DERIV        
      BBAR(     4+ITOT)=TERM*ATRANS(1)        
      BBAR(     5+ITOT)=TERM*ATRANS(2)        
      BBAR(     6+ITOT)=TERM*ATRANS(3)        
      BBAR(NDOF+4+ITOT)=TERM*ATRANS(4)        
      BBAR(NDOF+5+ITOT)=TERM*ATRANS(5)        
      BBAR(NDOF+6+ITOT)=TERM*ATRANS(6)        
   10 CONTINUE        
      GO TO 50        
C        
C     COMPUTE THE TERMS WHICH GO IN THE LAST 2 ROWS.        
C        
   20 IF (.NOT.BENDNG) RETURN        
      TEE(1)= 0.0D0        
      TEE(2)=-GPNORM(4,K)        
      TEE(3)= GPNORM(3,K)        
      TEE(4)=-TEE(2)        
      TEE(5)= 0.0D0        
      TEE(6)=-GPNORM(2,K)        
      TEE(7)=-TEE(3)        
      TEE(8)=-TEE(6)        
      TEE(9)= 0.0D0        
C        
      KP1=KPOINT*2        
      KP2=KP1+7        
      J=IORDER(K)        
      I=J-1        
      IF (I .EQ. 0) I=4        
C        
      IB=0        
   30 IB=IB+1        
      BB1=-UNV(IB,J)*EDGSHR(1,J)/EDGEL(J)        
     1    +UNV(IB,I)*EDGSHR(1,I)/EDGEL(I)        
      BB2=-UNV(IB,J)*EDGSHR(2,J)/EDGEL(J)        
     1    +UNV(IB,I)*EDGSHR(2,I)/EDGEL(I)        
      BB3=-UNV(IB,J)*EDGSHR(3,J)/EDGEL(J)        
     1    +UNV(IB,I)*EDGSHR(3,I)/EDGEL(I)        
      BSBAR(KP1+IB  )=PSITRN(1)*BB1+PSITRN(2)*BB2+PSITRN(3)*BB3        
      BSBAR(KP1+IB+3)=PSITRN(4)*BB1+PSITRN(5)*BB2+PSITRN(6)*BB3        
      IF (IB .LT. 3) GO TO 30        
C        
      IB=0        
   40 IB=IB+1        
      BB1=-(UEV(IB,J)*EDGSHR(1,J)+UEV(IB,I)*EDGSHR(1,I))*0.5D0        
      BB2=-(UEV(IB,J)*EDGSHR(2,J)+UEV(IB,I)*EDGSHR(2,I))*0.5D0        
      BB3=-(UEV(IB,J)*EDGSHR(3,J)+UEV(IB,I)*EDGSHR(3,I))*0.5D0        
      BSBAR1(IB  )=PSITRN(1)*BB1+PSITRN(2)*BB2+PSITRN(3)*BB3        
      BSBAR1(IB+3)=PSITRN(4)*BB1+PSITRN(5)*BB2+PSITRN(6)*BB3        
      IF (IB .LT. 3) GO TO 40        
      CALL GMMATD (BSBAR1,2,3,0,TEE,3,3,0,BSBAR(KP2))        
C        
C*****        
C     FILL IN B-MATRIX FOR THE NORMAL PATH        
C*****        
C        
   50 CONTINUE        
      IF (.NOT.NORPTH) GO TO 200        
      GO TO (140,120,100), ROWFLG        
C        
C     ROWFLG = 3       FIRST THREE ROWS        
C        
  100 DO 110 KBAR=1,NDOF        
      BMATRX(KBAR     )=PHI(1)*BBAR(KBAR     )+PHI(2)*BBAR(KBAR+ND3 )   
      BMATRX(KBAR+NDOF)=PHI(4)*BBAR(KBAR+NDOF)+PHI(5)*BBAR(KBAR+ND4 )   
      BMATRX(KBAR+ND2 )=PHI(4)*BBAR(KBAR     )+PHI(1)*BBAR(KBAR+NDOF)   
     1                 +PHI(5)*BBAR(KBAR+ND3 )+PHI(2)*BBAR(KBAR+ND4 )   
  110 CONTINUE        
      GO TO 300        
C        
C     ROWFLG = 2       IN-PLANE SHEAR (3RD ROW)        
C        
  120 DO 130 KBAR=1,NDOF        
      BMATRX(KBAR)=PHI(4)*BBAR(KBAR    )+PHI(1)*BBAR(KBAR+NDOF)        
     1            +PHI(5)*BBAR(KBAR+ND3)+PHI(2)*BBAR(KBAR+ND4 )        
  130 CONTINUE        
      GO TO 300        
C        
C     ROWFLG = 1       OUT-OF-PLANE SHEAR (LAST 2 ROWS)        
C        
  140 DO 150 KBAR=1,NDOF        
      IBAR=((KBAR-1)/3)*3+KBAR        
      BMATRX(KBAR+NDOF)=BSBAR(IBAR  )        
      BMATRX(KBAR     )=BSBAR(IBAR+3)        
  150 CONTINUE        
      GO TO 300        
C        
C*****        
C     FILL IN B-MATRIX FOR THE MIDI PATH        
C*****        
C        
  200 DO 210 IJI=1,NN        
  210 BMATRX(IJI)=0.0D0        
      GO TO (280,260,220), ROWFLG        
C        
C     ROWFLG = 3       FIRST SIX ROWS        
C        
  220 IF (.NOT.MEMBRN) GO TO 240        
      DO 230 KA=1,NNODE        
      KK=(KA-1)*6        
      DO 230 M=1,3        
      BMATRX(M+KK     )=PHI(1)*BBAR(M+KK     )+PHI(2)*BBAR(M+KK+ND3)    
      BMATRX(M+KK+NDOF)=PHI(4)*BBAR(M+KK+NDOF)+PHI(5)*BBAR(M+KK+ND4)    
  230 CONTINUE        
C        
  240 IF (.NOT.BENDNG) GO TO 300        
      DO 250 KA=1,NNODE        
      KK=(KA-1)*6        
      DO 250 N=4,6        
      BMATRX(N+KK+ND3)=PHI(1)*BBAR(N+KK     )+PHI(2)*BBAR(N+KK+ND3)     
      BMATRX(N+KK+ND4)=PHI(4)*BBAR(N+KK+NDOF)+PHI(5)*BBAR(N+KK+ND4)     
  250 CONTINUE        
      GO TO 300        
C        
C     ROWFLG = 2       IN-PLANE SHEAR (3RD AND 6TH ROWS)        
C        
  260 DO 270 KA=1,NNODE        
      KK=(KA-1)*6        
      DO 270 M=1,3        
      N=3+M        
      BMATRX(M+KK     )=PHI(4)*BBAR(M+KK    )+PHI(1)*BBAR(M+KK+NDOF)    
     1                 +PHI(5)*BBAR(M+KK+ND3)+PHI(2)*BBAR(M+KK+ND4)     
      BMATRX(N+KK+NDOF)=PHI(4)*BBAR(N+KK    )+PHI(1)*BBAR(N+KK+NDOF)    
     1                 +PHI(5)*BBAR(N+KK+ND3)+PHI(2)*BBAR(N+KK+ND4)     
  270 CONTINUE        
      GO TO 300        
C        
C     ROWFLG = 1       OUT-OF-PLANE SHEAR (LAST 2 ROWS)        
C        
  280 DO 290 KA=1,NNODE        
      KK=(KA-1)*6        
      DO 290 M=1,3        
      N=3+M        
      KKK=KK*2        
      BMATRX(M+KK+NDOF)=BSBAR(M+KKK  )        
      BMATRX(N+KK+NDOF)=BSBAR(M+KKK+6)        
      BMATRX(M+KK     )=BSBAR(N+KKK  )        
      BMATRX(N+KK     )=BSBAR(N+KKK+6)        
  290 CONTINUE        
C        
  300 CONTINUE        
      RETURN        
      END        
