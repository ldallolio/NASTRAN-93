      SUBROUTINE TSPL1S (TS1,TS2,TS6,TS6S,TS7,KTR3,KTR31)
C
C    TRANSVERSE SHEAR ROUTINE1 FOR CTRPLT1 - SINGLE PRECISION VERSION
C
      REAL KTR3,KTR31
      REAL J11,J12,J22
      DIMENSION KTR3(400),KTR31(400),TS1(60),TS2(60),TS6(40),TS6S(40)
     1,    TS7(60),GS1(4),GE1(9),BE(7),GA(7),WT(7),CONS(2)
      COMMON /SMA1IO/ X,Y,Z,DISTA,DISTB,DISTC,A1,A2,A3
      COMMON /MATOUT/ EM(6),DUM6(9),RJ11,RJ12,RJ22
C
      DATA  BE          /0.33333333333333E0,0.47014206E0,               
     1   0.05971588E0,0.47014206E0,0.101286505E0,0.79742699E0,          
     2   0.101286505E0/, GA          /0.33333333333333E0,               
     3   2*0.47014206E0,0.05971588E0,2*0.101286505E0,0.79742699E0/,     
     4    WT          /0.1125E0,3*0.066197075E0,3*0.06296959E0/         
      CONS(1)=DISTA*DISTC
      CONS(2)=DISTB*DISTC
      DO 104 I=1,60
      TS1(I)=0.0E0
  104 CONTINUE
      DO 150 K=1,7
      DO 145 KASE=1,2
      IF (KASE.EQ.1)  X=BE(K)*DISTA
      IF (KASE.EQ.2) X=-BE(K)*DISTB
      Y=GA(K)*DISTC
      CALL TSPL3S (TS6)
      CONS1=WT(K)*CONS(KASE)
      THK=A1+A2*X+A3*Y
      CONS14=CONS1*THK
      GS1(1)=RJ11*CONS14
      GS1(2)=RJ12*CONS14
      GS1(3)=GS1(2)
      GS1(4)=RJ22*CONS14
      THK1=THK**3/12.0E0
      CONS11=CONS1*THK1
      D11=EM(1)*THK1
      D12=EM(2)*THK1
      D13=EM(3)*THK1
      D22=EM(4)*THK1
      D23=EM(5)*THK1
      D33=EM(6)*THK1
      D21=D12
      D31=D13
      D32=D23
      J11=1.0/(EM(6)*THK)
      J22=J11
      J12=0.0
      A11=-(J11*D11+J12*D13)
      A12=-(J11*D12+J12*D23)
      A13=-(J11*D13+J12*D33)
      A14=-(J11*D31+J12*D21)
      A15=-(J11*D32+J12*D22)
      A16=-(J11*D33+J12*D23)
      A21=-(J12*D11+J22*D13)
      A22=-(J12*D12+J22*D23)
      A23=-(J12*D13+J22*D33)
      A24=-(J12*D13+J22*D12)
      A25=-(J12*D23+J22*D22)
      A26=-(J12*D33+J22*D32)
      A31=A14+2.0*A13
      A32=A12+2.0*A16
      A33=A24+2.0*A23
      A34=A22+2.0*A26
      A35=A33+A11
      A36=A34+A31
      A37=A25+A32
      GE1(1)=EM(1)*CONS11
      GE1(2)=EM(2)*CONS11
      GE1(3)=EM(3)*CONS11
      GE1(4)=GE1(2)
      GE1(5)=EM(4)*CONS11
      GE1(6)=EM(5)*CONS11
      GE1(7)=GE1(3)
      GE1(8)=GE1(6)
      GE1(9)=EM(6)*CONS11
C
C        (B1) REFERS TO BENDING STRAIN DUE TO SECOND DERIVATIVES OF W
C        (B2) REFERS TO BENDING STRAINS DUE TO TRANSVERSE SHEAR STRAIN
C        (GAMMA) TRANSPOSE (GS) * (GAMMA) IS CONTRIBUTION OF STIFFNESS
C        MATRIX DUE TO WORK DONE BY SHEARING FORCES UNDERGOING SHEAR DEF
C
C
C  GAMMA TRANSPOSE GS GAMMA
C
      CALL GMMATS (TS6,2,20,+1,GS1,2,2,0,TS6S)
      CALL GMMATS (TS6S,20,2,-2,TS6,2,20,0,KTR3)
      TS1(31)  =-24.0*A11
      TS1(33)  =-24.0*A21
      TS1(34)  =-6.0*A31
      TS1(35)  =-6.0*A21
      TS1(36)  =-6.0*A35
      TS1(37)  =-4.0*A32
      TS1(38)  =-4.0*A33
      TS1(39)  =-4.0*A36
      TS1(40)  =-6.0*A15
      TS1(41)  =-6.0*A34
      TS1(42)  =-6.0*A37
      TS1(44)  =-24.0*A25
      TS1(45)  =-24.0*A15
      TS1(46)  =-120.0*A11*X
      TS1(48)  =-120.0*A21*X
      TS1(49)  =-12.0*(A32*X+A31*Y)
      TS1(50)  =-12.0*(A33*X+A21*Y)
      TS1(51)  =-12.0*(A36*X+A35*Y)
      TS1(52)  =-12.0*(A15*X+A32*Y)
      TS1(53)  =-12.0*(A34*X+A33*Y)
      TS1(54)  =-12.0*(A37*X+A36*Y)
      TS1(55)  =-24.0*A15*Y
      TS1(56)  =-24.0*(A25*X+A34*Y)
      TS1(57)  =-24.0*(A15*X+A37*Y)
      TS1(59)  =-120.0*A25*Y
      TS1(60)  =-120.0*A15*Y
C
C  B2 TRANSPOSE D B2
C
      CALL GMMATS (TS1,20,3,0,GE1,3,3,0,TS2)
      CALL GMMATS (TS2,20,3,-2,TS1,20,3,+1,KTR3)
C
C  B2 TRANSPOSE D B1
C
      CALL TSPL2S (TS7)
      CALL GMMATS (TS2,20,3, 0,TS7,3,20, 0,KTR31)
C
C  B1 TRANSPOSE D B2
C
      DO 120 I=1,20
      DO 120 J=1,20
      IJ=(I-1)*20+J
      JI=(J-1)*20+I
      KTR3(IJ)=KTR3(IJ)+KTR31(IJ)+KTR31(JI)
  120 CONTINUE
  145 CONTINUE
  150 CONTINUE
      RETURN
      END
