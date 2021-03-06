      SUBROUTINE TRPLMS (GMAT,DMAT,BMAT,BMAT1,BMAT2,MATTYP,JCOR,WTK)    
C        
C     ROUTINE TO PERFORM THE TRIPLE MULTIPLY AT EACH INTEGRATION        
C     POINT FOR THE QUAD4 ELEMENT.        
C     DIFFERENT PATHS ARE TAKEN BASED ON THE FOLLOWING CRITERIA -       
C      1- ELEMENT BEING A MEMBRANE ONLY, OR BENDING ONLY, OR BOTH       
C         MEMBRANE AND BENDING ELEMENT.        
C      2- THE MATERIAL PROPERTIES BEING ISOTROPIC OR NOT.        
C      3- THE MACHINE THIS CODE IS RUNNING ON. (TENTATIVE)        
C        
      REAL    WTK,AKGG,GMAT(10,10),DMAT(7,7)        
      REAL    BMAT(240),BMAT1(1),BMAT2(1)        
      REAL    DBM(240),DMAT1(3,3),DMAT2(4,4)        
C        
      LOGICAL MEMBRN,BENDNG,SHRFLX,MBCOUP,NORPTH        
C        
      COMMON /TERMS / MEMBRN,BENDNG,SHRFLX,MBCOUP,NORPTH        
CZZ   COMMON /ZZEMGX/ AKGG(1)        
      COMMON /ZZZZZZ/ AKGG(1)        
      COMMON /TRPLM / NDOF,IBOT,IPTX1,IPTX2,IPTY1,IPTY2        
C        
C*****        
C     INITIALIZE        
C*****        
      ND1 = NDOF        
      ND2 = ND1 * 2        
      ND3 = ND1 * 3        
      ND4 = ND1 * 4        
      ND5 = ND1 * 5        
      ND6 = ND1 * 6        
      ND7 = ND1 * 7        
      ND8 = ND1 * 8        
      ND9 = ND1 * 9        
      NDA = ND1 * 10        
      IF (.NOT.NORPTH) GO TO 500        
C*****        
C ALL MIDS ARE THE SAME AND THERE IS NO COUPLING.        
C IF THE MATERIAL IS ISOTROPIC, PERFORM THE 1ST MUTIPLY EXPLICITLY.     
C IF NOT, USE GMMATS. IN EITHER CASE, THE 2ND MULTIPLY USES GMMATS.     
C*****        
      DO 100 I=1,ND1        
      BMAT(I+ND2) = BMAT2(I+IBOT     )        
      BMAT(I+ND3) = BMAT1(I+IPTY1    )        
      BMAT(I+ND4) = BMAT1(I+IPTY2    )        
      BMAT(I+ND5) = BMAT1(I+IPTX1+ND1)        
  100 BMAT(I+ND6) = BMAT1(I+IPTX2+ND1)        
C        
      IF (MATTYP .NE. 1) GO TO 300        
      DO 200 I=1,ND1        
      DBM (I    ) = DMAT(1,1)*BMAT(I    ) + DMAT(1,2)*BMAT(I+ND1)       
      DBM (I+ND1) = DMAT(2,1)*BMAT(I    ) + DMAT(2,2)*BMAT(I+ND1)       
      DBM (I+ND2) = DMAT(3,3)*BMAT(I+ND2)        
      DBM (I+ND3) = DMAT(4,4)*BMAT(I+ND3) + DMAT(4,5)*BMAT(I+ND4)       
      DBM (I+ND4) = DMAT(5,4)*BMAT(I+ND3) + DMAT(5,5)*BMAT(I+ND4)       
      DBM (I+ND5) = DMAT(6,6)*BMAT(I+ND5) + DMAT(6,7)*BMAT(I+ND6)       
  200 DBM (I+ND6) = DMAT(7,6)*BMAT(I+ND5) + DMAT(7,7)*BMAT(I+ND6)       
      GO TO 400        
C        
  300 CALL GMMATS (DMAT,7,7,0,BMAT,7,ND1,0,DBM)        
C        
  400 DO 420 I=1,ND7        
  420 BMAT(I) = BMAT(I)*WTK        
      CALL GMMATS (BMAT,7,ND1,-1,DBM,7,ND1,0,AKGG(JCOR))        
      RETURN        
C*****        
C     MIDS ARE NOT THE SAME. CHECK FOR MEMBRANE ONLY AND BENDING ONLY   
C     CASES AND BRANCH APPROPRIATELY. IF BOTH ARE THERE, CONTINUE.      
C*****        
  500 IF (.NOT.BENDNG) GO TO 800        
      IF (.NOT.MEMBRN) GO TO 1200        
      DO 600 I=1,ND1        
      BMAT(I+ND2) = BMAT2(I+IBOT     )        
      BMAT(I+ND5) = BMAT2(I+IBOT+ND1 )        
      BMAT(I+ND6) = BMAT1(I+IPTY1    )        
      BMAT(I+ND7) = BMAT1(I+IPTY2    )        
      BMAT(I+ND8) = BMAT1(I+IPTX1+ND1)        
  600 BMAT(I+ND9) = BMAT1(I+IPTX2+ND1)        
      CALL GMMATS (GMAT,10,10,0,BMAT,10,ND1,0,DBM)        
C        
      DO 750 I=1,NDA        
  750 BMAT(I) = BMAT(I)*WTK        
      CALL GMMATS (BMAT,10,ND1,-1,DBM,10,ND1,0,AKGG(JCOR))        
      RETURN        
C*****        
C     MEMBRANE ONLY ELEMENT. ONLY THE FIRST 3X3 OF GMAT AND THE FIRST   
C     3 ROWS OF BMAT ARE MULTIPLIED.        
C*****        
  800 DO 900 I=1,ND1        
  900 BMAT(I+ND2) = BMAT2(I+IBOT)        
C        
      IF (MATTYP .NE. 1) GO TO 950        
      DO 920 I=1,ND1        
      DBM (I    ) = GMAT(1,1)*BMAT(I    ) + GMAT(1,2)*BMAT(I+ND1)       
      DBM (I+ND1) = GMAT(2,1)*BMAT(I    ) + GMAT(2,2)*BMAT(I+ND1)       
  920 DBM (I+ND2) = GMAT(3,3)*BMAT(I+ND2)        
      GO TO 1050        
C        
  950 DO 1000 I=1,3        
      DO 1000 J=1,3        
 1000 DMAT1(I,J) = GMAT(I,J)        
      CALL GMMATS (DMAT1,3,3,0,BMAT(1),3,ND1,0,DBM(1))        
C        
 1050 DO 1100 I=1,ND3        
 1100 BMAT(I) = BMAT(I)*WTK        
      CALL GMMATS (BMAT,3,ND1,-1,DBM,3,ND1,0,AKGG(JCOR))        
      RETURN        
C*****        
C     BENDING ONLY ELEMENT. THE FIRST 3 ROWS AND COLUMNS OF GMAT AND    
C     THE FIRST 3 ROWS OF BMAT WILL BE EXCLUDED FROM MULTIPLICATIONS.   
C*****        
 1200 DO 1300 I=1,ND1        
      BMAT(I+ND6) = BMAT1(I+IPTY1    )        
      BMAT(I+ND7) = BMAT1(I+IPTY2    )        
      BMAT(I+ND8) = BMAT1(I+IPTX1+ND1)        
 1300 BMAT(I+ND9) = BMAT1(I+IPTX2+ND1)        
C        
      DO 1400 I=1,3        
      DO 1400 J=1,3        
 1400 DMAT1(I,J) = GMAT(I+3,J+3)        
      DO 1500 I=1,4        
      DO 1500 J=1,4        
 1500 DMAT2(I,J) = GMAT(I+6,J+6)        
C        
      CALL GMMATS (DMAT1,3,3,0,BMAT(ND3+1),3,ND1,0,DBM(1    ))        
      CALL GMMATS (DMAT2,4,4,0,BMAT(ND6+1),4,ND1,0,DBM(ND3+1))        
C        
      DO 1600 I=ND3+1,NDA        
 1600 BMAT(I) = BMAT(I)*WTK        
      CALL GMMATS (BMAT(ND3+1),7,ND1,-1,DBM,7,ND1,0,AKGG(JCOR))        
      RETURN        
C        
      END        
