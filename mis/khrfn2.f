      INTEGER FUNCTION KHRFN2 (WORD,J,IZB)        
C        
C     CHARACTER FUNCTION KHRFN2 RECIEVES THE J-TH BYTE OF WORD        
C     LEFT ADJUSTED IF J IS .GE. ZERO, OR RIGHT ADJUSTED IF J .LT. ZERO 
C     ZERO FILL IF IZB IS ZERO, OTHERWISE, BLANK FILL        
C        
      INTEGER         WORD(1), BLANK        
      COMMON /SYSTEM/ DUMMY(40), NCPW        
      DATA    BLANK / 4H      /        
C        
      I  = 1        
      KHRFN2 = BLANK        
      IF (IZB .EQ. 0) KHRFN2 = 0        
      IF (J   .LT. 0) I = NCPW        
      IJ = IABS(J)        
      KHRFN2 = KHRFN1(KHRFN2,I,WORD(1),IJ)        
      RETURN        
      END        
