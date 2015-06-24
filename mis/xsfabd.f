      BLOCK DATA XSFABD        
C        
CXSFABD        
C        
C     REVISED  8/89 BY G.C./UNISYS        
C          1.  THE ORDER OF COMM AND XF1AT IN /XSFA1/ ARE REVERSED IN   
C              THIS ROUTINE AND IN THE FOLLOWING 7 SUBROUTINES -        
C              XCLEAN, XDPH, XPOLCK, XPUNP, XPURGE, XSFA AND XSOSGN.    
C              ANY INCREASE IN SIZE OF XF1AT CAN THEREFORE BE MADE      
C              EASILY THROUGH OUT THESE GROUP OF ROUTINES BY JUST       
C              CHANGING THE XF1AT DIMENSION HERE.        
C          2.  IN THIS GROUP OF ROUTINES, THE ARRAY XFIAT IN /XSFA1/ IS 
C              RENAMED TO XF1AT, NOT TO BE CONFUSED WITH THE XFIAT ARRAY
C              IN /XFIAT/        
C          3.  ENTN1 MUST EQUAL ICFIAT, THE 24TH WORD OF /SYSTEM/       
C              HOWEVER, XSFA AND XPURGE ROUTINES INITIALIZE ENTN1 AGAIN 
C              TO ICFIAT, JUST TO BE SURE.        
C          4.  THE DIMENSION OF XF1AT SHOULD BE 800 WHEN ENTN1 = 8, OR  
C              1100 WHEN ENTN1 IS 11        
C        
      INTEGER         ALMSK,APNDMK,COMM,CURSNO,ENTN1,ENTN2,ENTN3,       
     1                ENTN4,FLAG,FNX,RMSK,RXMSK,S,SCORNT,SOS,TAPMSK,    
     2                THCRMK,XF1AT,ZAP        
      COMMON /XSFA1 / MF(401),SOS(1501),COMM(20),XF1AT(1100)        
      EQUIVALENCE            (COMM (1),ALMSK ),(COMM (2),APNDMK),       
     1     (COMM (3),CURSNO),(COMM (4),ENTN1 ),(COMM (5),ENTN2 ),       
     2     (COMM (6),ENTN3 ),(COMM (7),ENTN4 ),(COMM (8),FLAG  ),       
     3     (COMM (9),FNX   ),(COMM(10),LMSK  ),(COMM(11),LXMSK ),       
     4     (COMM(12),MACSFT),(COMM(13),RMSK  ),(COMM(14),RXMSK ),       
     5     (COMM(15),S     ),(COMM(16),SCORNT),(COMM(17),TAPMSK),       
     6     (COMM(18),THCRMK),(COMM(19),ZAP   )        
      DATA   ENTN1  , ENTN2 ,ENTN3    ,ENTN4 / 11,3,4,3/, FLAG/ 0 /     
      DATA   XF1AT  / 1100*0     /        
      DATA   TAPMSK / 32768      /        
C            TAPMSK = O 000000100000  = Z 00008000        
      DATA   APNDMK / 1073741824 /        
C            APNDMK = O 010000000000  = Z 40000000        
      DATA   RMSK   / 32767      /        
C            RMSK   = O 000000077777  = Z 00007FFF        
      DATA   RXMSK  / 65535      /        
C            RXMSK  = O 000000177777  = Z 0000FFFF        
      DATA   LMSK   / 1073676288 /        
C            LMSK   = O 007777600000  = Z 3FFF0000        
      DATA   LXMSK  / 2147418112 /        
C            LXMSK  = O 017777600000  = Z 7FFF0000        
      DATA   SCORNT / 1073708992 /        
C            SCORNT = O 007777677700  = Z 3FFF7FC0        
      DATA   ZAP    / 32767      /        
C            ZAP    = O 000000077777  = Z 00007FFF        
      END        
