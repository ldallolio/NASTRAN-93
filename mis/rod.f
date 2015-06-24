      SUBROUTINE ROD        
C        
C     ELEMENT TEMPERATURE AND DEFORMATION LOADING FOR THE ROD, CONROD,  
C     TUBE        
C        
      INTEGER         ELTYPE,EID,GPIDA,GPIDB        
      REAL            ARRY(3),GPIDA1(1),GPIDB1(1)        
      COMMON /CONDAS/ PI,TWOPI,RADEG,DEGRA,S4PISQ        
CZZ   COMMON /ZZSSB1/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /TRIMEX/ EID, GPIDA, GPIDB, IARRY(97)        
      COMMON /MATIN / MATID,INFLAG,TEMP,STRESS,SINTH,COSTH        
      COMMON /MATOUT/ E1,G,NU,RHO,ALPHA,TO1,GE,SIGMAT,SIGMAC,SIGMAS,    
     1                SPACE(10)        
      COMMON /SSGWRK/ TI(16),VECT(3),FORCE(3),BGPDT(9),VMAG,IN,L,TBAR,  
     1                DELTA,XL        
      COMMON /SSGETT/ ELTYPE,OLDEL,EORFLG,ENDID,BUFFLG,ITEMP,IDEFT,IDEFM
      EQUIVALENCE     (IARRY(1),ARRY(1)),        
     1                (ICSTMA,BGPDT(1)),(ICSTMB,BGPDT(5)),        
     2                (GPIDA1(1),BGPDT(2)),(GPIDB1(1),BGPDT(6))        
C        
      NEPT = 5        
      IF (ELTYPE .EQ. 3) NEPT = 4        
      A = ARRY(2)        
C        
C     RECOMPUTE AREA IF ELEMENT IS TUBE        
C        
      IF (NEPT .EQ. 4) A = PI*(A-ARRY(3))*ARRY(3)        
C        
      DO 100 I = 1,9        
      NEPT = NEPT + 1        
  100 BGPDT(I) = ARRY(NEPT)        
C        
C     OBTAIN THE MATERIAL DATA        
C        
      INFLAG = 1        
      MATID  = IARRY(1)        
      TEMP   = BGPDT(9)        
      CALL MAT (EID)        
      IF (ITEMP) 240,250,240        
  240 CALL SSGETD (EID,TI,0)        
      TBAR = TI(1) - TO1        
      GO TO 260        
  250 TBAR = 0.0        
  260 IF (IDEFT) 270,280,270        
  270 CALL FEDT (EID,DELTA,IDEFM)        
      GO TO 290        
  280 DELTA = 0.0        
  290 DO 310 I = 1,3        
  310 VECT(I) = GPIDA1(I) - GPIDB1(I)        
      CALL NORM (VECT(1),XL)        
      VMAG = E1*A*(DELTA + ALPHA*XL*TBAR)/XL        
      DO 320 I = 1,3        
      VECT(I) = -VECT(I)*VMAG        
  320 FORCE (I) = -VECT(I)        
      IF (ICSTMB) 330,340,330        
  330 CALL BASGLB (VECT(1),VECT(1),GPIDB1,ICSTMB)        
  340 IN = GPIDB - 1        
      DO 350 I = 1,3        
      L  = IN + I        
  350 CORE(L) = CORE(L) + VECT(I)        
      IF (ICSTMA) 370,380,370        
  370 CALL BASGLB (FORCE(1),FORCE(1),GPIDA1,ICSTMA)        
  380 IN = GPIDA - 1        
      DO 390 I = 1,3        
      L  = IN + I        
  390 CORE(L) = CORE(L) + FORCE(I)        
      RETURN        
      END        
