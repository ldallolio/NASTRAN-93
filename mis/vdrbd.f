      BLOCK DATA VDRBD
CVDRBD
C BLOCK DATA FOR THE VECTOR DATA RECOVERY MODULE (VDR).
C*****
      INTEGER USETD,CASECC,EQDYN ,OEIGS ,PP    ,XYCDB ,PNL   ,OUTFLE
     1       ,OPNL1,SCR1  ,SCR2  ,BUF1  ,BUF2  ,BUF3  ,CEI   ,FRQ
     2       ,TRN  ,DIRECT,XSET0 ,BUF
C
      DIMENSION NAM(2)    ,BUF(50)      ,MASKS(6)
     1         ,CEI(2)    ,FRQ( 2)      ,TRN(2)       ,MODAL(2)
     2         ,DIRECT(2)
C
      COMMON/VDRCOM/VDRCOM,IDISP ,IVEL  ,IACC  ,ISPCF ,ILOADS,ISTR
     1             ,IELF  ,IADISP,IAVEL ,IAACC ,IPNL  ,ITTL  ,ILSYM
     2             ,IFROUT,IDLOAD,CASECC,EQDYN ,USETD ,INFILE,OEIGS
     3             ,PP    ,XYCDB ,PNL   ,OUTFLE,OPNL1 ,SCR1  ,SCR2
     4             ,BUF1  ,BUF2  ,BUF3  ,NAM   ,BUF   ,MASKS ,CEI
     5             ,FRQ   ,TRN   ,DIRECT,XSET0 ,VDRREQ,MODAL
C
C DATA DEFINING POSITION OF PARAMETERS IN CASE CONTROL RECORD.
C
      DATA   IDISP  / 20/ ,IVEL   / 32/ ,IACC   / 29/ ,ISPCF  / 35/     
     1      ,ILOADS / 17/ ,ISTR   / 23/ ,IELF   / 26/ ,IADISP /151/     
     2      ,IAVEL  /154/ ,IAACC  /157/ ,IPNL   / 10/ ,ITTL   / 39/     
     3      ,ILSYM  /200/ ,IFROUT /145/ ,IDLOAD / 13/                   
C                                                                       
C DATA DEFINING GINO FILE NAMES                                         
C                                                                       
      DATA   CASECC /101/ ,EQDYN  /102/ ,USETD  /103/ ,INFILE /104/     
     1      ,OEIGS  /105/ ,PP     /105/ ,XYCDB  /106/ ,PNL    /107/     
     2      ,OUTFLE /201/ ,OPNL1  /202/ ,SCR1   /301/ ,SCR2   /302/     
C                                                                       
C MISC DATA                                                             
C                                                                       
      DATA   BUF   /50*0/ ,NAM    /4HVDR ,4H    /                       
     1      ,MASKS /4,8,16,32,64,128/,XSET0/100000000/                  
C                                                                       
C DATA DEFINING RIGID FORMATS AND PROBLEM TYPES                         
C                                                                       
      DATA   CEI    /4HCEIG,4HEN  /,FRQ   /4HFREQ,4HRESP/               
     1      ,TRN    /4HTRAN,4HRESP/,MODAL /4HMODA,4HL   /               
     2      ,DIRECT /4HDIRE,4HCT  /                                     
      END
