      SUBROUTINE ERRMKN (N,IERR)        
C        
C     SENDS ERROR MESSAGES.  N IS THE INDEX OF THE SUBROUTINE CALLING   
C     ERROR, AND IERR IS AN ERROR CODE.        
C        
      DIMENSION       ISUBR(26)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /SYSTEM/ NBUFF,NOUT        
      DATA    ISUBR / 4HCRSU,4HB   ,4HDSTR,4HOY  ,4HFDIT,4H    ,        
     1                4HFMDI,4H    ,4HFNXT,4H    ,4HGETB,4HLK  ,        
     2                4HRETB,4HLK  ,4HSETE,4HQ   ,4HSJUM,4HP   ,        
     3                4HSURE,4HAD  ,4HRENA,4HME  ,4HEXO2,4H    ,        
     4                4HEXIO,4H1   /        
C        
      WRITE (NOUT,1000) SFM,ISUBR(N),ISUBR(N+1)        
      CALL SOFCLS        
      GO TO (10,20,30,40,50,60,70,80,90,100), IERR        
   10 WRITE (NOUT,1010)        
      GO TO 900        
   20 WRITE (NOUT,1020)        
      GO TO 900        
   30 WRITE (NOUT,1030)        
      GO TO 900        
   40 WRITE (NOUT,1040)        
      GO TO 900        
   50 WRITE (NOUT,1050)        
      GO TO 900        
   60 WRITE (NOUT,1060)        
      GO TO 900        
   70 WRITE (NOUT,1070)        
      GO TO 900        
   80 WRITE (NOUT,1080)        
      GO TO 900        
   90 WRITE (NOUT,1090)        
      GO TO 900        
  100 WRITE (NOUT,1100)        
      GO TO 900        
  900 CALL MESAGE (-61,0,0)        
      RETURN        
C        
 1000 FORMAT (A25,' 6224, SOF UTILITY SUBROUTINE ',2A4)        
 1010 FORMAT (5X,'I IS TOO LARGE OR NXTTSZ HAS NOT BEEN PROPERLY ',     
     1        'UPDATED')        
 1020 FORMAT (5X,'ILLEGAL BLOCK NUMBER')        
 1030 FORMAT (5X,'ERROR IN SETTING UP THE LIST IMORE')        
 1040 FORMAT (5X,'NXTCUR IS TOO LARGE')        
 1050 FORMAT (5X,'ERROR IN UPDATING DIT')        
 1060 FORMAT (5X,'ERROR IN UPDATING MDI')        
 1070 FORMAT (5X,'ERROR IN LINKING BLOCKS OF DIT')        
 1080 FORMAT (5X,'LINK THROUGH COMBINED SUBSTRUCTURES IS NOT CIRCULAR') 
 1090 FORMAT (5X,'ERROR IN LINKING SOF BLOCKS')        
 1100 FORMAT (5X,'INTERNAL ARRAY DIMENSION EXCEEDED')        
      END        
