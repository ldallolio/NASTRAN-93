      SUBROUTINE APDR (FILE,Z,CORE,IN,OUT,WR,BUF,TYPE)
C
      INTEGER FILE,OUT,CORE,WR,BUF,FLAG,Z(1),TYPE(3),NAME(2)
      DATA    NAME /4HAPD ,4HR   /     
C                                    
      WR = 0
      IN = 0
      CALL LOCATE (*20,Z(BUF),TYPE,FLAG)
      IN = OUT + 1
      CALL READ (*90,*10,FILE,Z(IN),CORE,0,WR)
      GO TO 80
   10 OUT  = IN + WR - 1
   20 CORE = CORE - WR
      RETURN
C
   80 CALL MESAGE (-3,FILE,NAME)
   90 CALL MESAGE (-2,FILE,NAME)
      GO TO 20
      END
