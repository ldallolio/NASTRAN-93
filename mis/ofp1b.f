      SUBROUTINE OFP1B (LINE)        
C        
C     THIS SUBROUTINE WAS FORMED ONLY TO REDUCE THE SIZE OF OFP1 FOR    
C     COMPILATION PURPOSES.  IT IS CALLED ONLY BY OFP1.        
C     PREVIOUSLY THIS ROUTINE WAS NAMED OPF1A.        
C        
      DIMENSION       FD(50),ID(50),OF(6)        
      COMMON /SYSTEM/ IBUF,L,NOGO        
CZZ   COMMON /ZZOFPX/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      EQUIVALENCE     (CORE(1),OF(1)),(ID(1),FD(1),OF(6))        
      DATA            IDUM1, IDUM2, IDUM3, IDUM4, IDUM5, IDUM6 /        
     1                4HDUM1,4HDUM2,4HDUM3,4HDUM4,4HDUM5,4HDUM6/,       
     2                IDUM7, IDUM8, IDUM9 /        
     3                4HDUM7,4HDUM8,4HDUM9/        
C        
      IF (LINE .GT. 294) GO TO 10        
      LOCAL = LINE - 174        
      GO TO (175,176,177,178,179,180,181,182,183,184,185,186,187,188,189
     1      ,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204
     2      ,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219
     3      ,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234
     4      ,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249
     5      ,250,251,252,253,254,255,256,257,258,259,260,261,262,263,264
     6      ,265,266,267,268,269,270,271,272,273,274,275,276,277,278,279
     7      ,280,281,282,283,284,285,286,287,288,289,290,291,292,293,294
     8      ), LOCAL        
   10 IF (LINE .GT. 380) RETURN        
      LOCAL = LINE - 294        
      GO TO (295,296,297,298,299,300,301,302,303,304,305,306,307,308,309
     9      ,310,311,312,313,314,315,316,317,318,319,320,321,322,323,324
     X      ,325,326,327,328,329,330,331,332,333,334,335,336,337,338,339
     B      ,340,341,342,343,344,345,346,347,348,349,350,351,352,353,354
     C      ,355,356,357,358,359,360,361,362,363,364,365,366,367,368,369
     D      ,370,371,372,373,374,375,376,377,378,379,380) LOCAL        
  175 CONTINUE        
      GO TO 1000        
  176 WRITE (L,676)        
      GO TO 1000        
  177 WRITE (L,677)        
      GO TO 1000        
  178 WRITE (L,678)        
      GO TO 1000        
  179 WRITE (L,679)        
      GO TO 1000        
  180 WRITE (L,680)        
      GO TO 1000        
  181 WRITE (L,681)        
      GO TO 1000        
  182 WRITE (L,682)        
      GO TO 1000        
  183 WRITE (L,683)        
      GO TO 1000        
  184 WRITE (L,684)        
      GO TO 1000        
  185 WRITE (L,685)        
      GO TO 1000        
  186 WRITE (L,686)        
      GO TO 1000        
  187 WRITE (L,687)        
      GO TO 1000        
  188 WRITE (L,688)        
      GO TO 1000        
  189 WRITE (L,689)        
      GO TO 1000        
  190 WRITE (L,690)        
      GO TO 1000        
  191 WRITE (L,691)        
      GO TO 1000        
  192 WRITE (L,692)        
      GO TO 1000        
  193 WRITE (L,693)        
      GO TO 1000        
  194 WRITE (L,694)        
      GO TO 1000        
  195 WRITE (L,695)        
      GO TO 1000        
  196 WRITE (L,696)        
      GO TO 1000        
  197 WRITE (L,697)        
      GO TO 1000        
  198 WRITE (L,698)        
      GO TO 1000        
  199 WRITE (L,699)        
      GO TO 1000        
  200 WRITE (L,700)        
      GO TO 1000        
  201 WRITE (L,701)        
      GO TO 1000        
  202 WRITE (L,702) ID(3)        
      GO TO 1000        
  203 WRITE (L,703)        
      GO TO 1000        
  204 WRITE (L,704)        
      GO TO 1000        
  205 WRITE (L,705)        
      GO TO 1000        
  206 WRITE (L,706)        
      GO TO 1000        
  207 WRITE (L,707)        
      GO TO 1000        
  208 WRITE (L,708)        
      GO TO 1000        
  209 WRITE (L,709)        
      GO TO 1000        
  210 WRITE (L,710)        
      GO TO 1000        
  211 WRITE (L,711)        
      GO TO 1000        
  212 WRITE (L,712)        
      GO TO 1000        
  213 WRITE (L,713)        
      GO TO 1000        
  214 WRITE (L,714) ID(5)        
      GO TO 1000        
  215 WRITE (L,715)        
      GO TO 1000        
  216 WRITE (L,716) (ID(K),K=11,14),ID(17),FD(18),(ID(K),K=19,21)       
      IF (ID(17) .EQ. 1) WRITE (L,7161)        
      IF (ID(17) .NE. 1) WRITE (L,7162)        
      IF (ID(17) .NE. 1) NOGO = 14        
      GO TO 1000        
  217 WRITE (L,717)        
      GO TO 1000        
  218 WRITE (L,718)        
      GO TO 1000        
  219 WRITE (L,719)        
      GO TO 1000        
  220 WRITE (L,720)        
      GO TO 1000        
  221 WRITE (L,721)        
      GO TO 1000        
  222 WRITE (L,722)        
      GO TO 1000        
  223 WRITE (L,723)        
      GO TO 1000        
  224 WRITE (L,724)        
      GO TO 1000        
  225 WRITE (L,725)        
      GO TO 1000        
  226 WRITE (L,726)        
      GO TO 1000        
  227 WRITE (L,727)        
      GO TO 1000        
  228 WRITE (L,728)        
      GO TO 1000        
  229 IDD   = MOD(ID(5),500000)        
      JHARM = (ID(5)-IDD)/500000        
      IHARM = (JHARM-1)/2        
      IF (MOD(JHARM,2) .EQ. 1) GO TO 1229        
      WRITE (L,729) IDD,IHARM        
      GO TO 1000        
 1229 WRITE (L,1729) IDD,IHARM        
      GO TO 1000        
  230 WRITE (L,730)        
      GO TO 1000        
  231 WRITE (L,731)        
      GO TO 1000        
  232 WRITE (L,732)        
      GO TO 1000        
  233 WRITE (L,733)        
      GO TO 1000        
  234 WRITE (L,734)        
      GO TO 1000        
  235 WRITE (L,735)        
      GO TO 1000        
  236 WRITE (L,736)        
      GO TO 1000        
  237 WRITE (L,737)        
      GO TO 1000        
  238 WRITE (L,738)        
      GO TO 1000        
  239 WRITE (L,739)        
      GO TO 1000        
  240 WRITE (L,740)        
      GO TO 1000        
  241 WRITE (L,741)        
      GO TO 1000        
  242 WRITE (L,742)        
      GO TO 1000        
  243 WRITE (L,743)        
      GO TO 1000        
  244 WRITE (L,744)        
      GO TO 1000        
  245 WRITE (L,745)        
      GO TO 1000        
  246 WRITE (L,746)        
      GO TO 1000        
  247 WRITE (L,747)        
      GO TO 1000        
  248 WRITE (L,748)        
      GO TO 1000        
  249 WRITE (L,749)        
      GO TO 1000        
  250 WRITE (L,750)        
      GO TO 1000        
  251 WRITE (L,751)        
      GO TO 1000        
  252 WRITE (L,752)        
      GO TO 1000        
  253 WRITE (L,753)        
      GO TO 1000        
  254 IDX = IDUM1        
      GO TO 1754        
  255 IDX = IDUM2        
      GO TO 1754        
  256 IDX = IDUM3        
      GO TO 1754        
  257 IDX = IDUM4        
      GO TO 1754        
  258 IDX = IDUM5        
      GO TO 1754        
  259 IDX = IDUM1        
      GO TO 1759        
  260 IDX = IDUM2        
      GO TO 1759        
  261 IDX = IDUM3        
      GO TO 1759        
  262 IDX = IDUM4        
      GO TO 1759        
  263 IDX = IDUM5        
      GO TO 1759        
  264 WRITE (L,764)        
      GO TO 1000        
  265 WRITE (L,765)        
      GO TO 1000        
  266 IDX = IDUM1        
      GO TO 1766        
  267 IDX = IDUM2        
      GO TO 1766        
  268 IDX = IDUM3        
      GO TO 1766        
  269 IDX = IDUM4        
      GO TO 1766        
  270 IDX = IDUM5        
      GO TO 1766        
  271 IDX = IDUM1        
      GO TO 1771        
  272 IDX = IDUM2        
      GO TO 1771        
  273 IDX = IDUM3        
      GO TO 1771        
  274 IDX = IDUM4        
      GO TO 1771        
  275 IDX = IDUM5        
      GO TO 1771        
  276 WRITE (L,776)        
      GO TO 1000        
  277 WRITE (L,777)        
      GO TO 1000        
  278 WRITE (L,778)        
      GO TO 1000        
  279 WRITE (L,779)        
      GO TO 1000        
  280 IDX = IDUM6        
      GO TO 1754        
  281 IDX = IDUM7        
      GO TO 1754        
  282 IDX = IDUM8        
      GO TO 1754        
  283 IDX = IDUM9        
      GO TO 1754        
  284 IDX = IDUM6        
      GO TO 1759        
  285 IDX = IDUM7        
      GO TO 1759        
  286 IDX = IDUM8        
      GO TO 1759        
  287 IDX = IDUM9        
      GO TO 1759        
  288 IDX = IDUM6        
      GO TO 1766        
  289 IDX = IDUM7        
      GO TO 1766        
  290 IDX = IDUM8        
      GO TO 1766        
  291 IDX = IDUM9        
      GO TO 1766        
  292 IDX = IDUM6        
      GO TO 1771        
  293 IDX = IDUM7        
      GO TO 1771        
  294 IDX = IDUM8        
      GO TO 1771        
  295 IDX = IDUM9        
      GO TO 1771        
  296 WRITE (L,796)        
      GO TO 1000        
  297 WRITE (L,797)        
      GO TO 1000        
  298 WRITE (L,798)        
      GO TO 1000        
  299 WRITE (L,799)        
      GO TO 1000        
  300 WRITE (L,800)        
      GO TO 1000        
  301 WRITE (L,801)        
      GO TO 1000        
  302 WRITE (L,802)        
      GO TO 1000        
  303 WRITE (L,803)        
      GO TO 1000        
  304 WRITE (L,804)        
      GO TO 1000        
  305 WRITE (L,805)        
      GO TO 1000        
  306 WRITE (L,806)        
      GO TO 1000        
  307 WRITE (L,807)        
      GO TO 1000        
  308 WRITE (L,808)        
      GO TO 1000        
  309 WRITE (L,809)        
      GO TO 1000        
  310 WRITE (L,810)        
      GO TO 1000        
  311 WRITE (L,811)        
      GO TO 1000        
  312 WRITE (L,812)        
      GO TO 1000        
  313 WRITE (L,813)        
      GO TO 1000        
  314 WRITE (L,814)        
      GO TO 1000        
  315 WRITE (L,815)        
      GO TO 1000        
  316 WRITE (L,816)        
      GO TO 1000        
  317 WRITE (L,817)        
      GO TO 1000        
  318 WRITE (L,818)        
      GO TO 1000        
  319 WRITE (L,819)        
      GO TO 1000        
  320 WRITE (L,820)        
      GO TO 1000        
  321 WRITE (L,821)        
      GO TO 1000        
  322 WRITE (L,822)        
      GO TO 1000        
  323 WRITE (L,823)        
      GO TO 1000        
  324 WRITE (L,824)        
      GO TO 1000        
  325 WRITE (L,825)        
      GO TO 1000        
  326 WRITE (L,826)        
      GO TO 1000        
  327 WRITE (L,827)        
      GO TO 1000        
  328 IDD = ID(3) - 64        
      WRITE (L,828) IDD        
      GO TO 1000        
  329 WRITE (L,829)        
      GO TO 1000        
  330 WRITE (L,830)        
      GO TO 1000        
  331 IDD = ID(3) - 64        
      WRITE (L,831) IDD        
      GO TO 1000        
  332 WRITE (L,832)        
      GO TO 1000        
  333 WRITE (L,833)        
      GO TO 1000        
  334 WRITE (L,834)        
      GO TO 1000        
  335 WRITE (L,835)        
      GO TO 1000        
  336 WRITE (L,836)        
      GO TO 1000        
  337 WRITE (L,837)        
      GO TO 1000        
  338 WRITE (L,838)        
      GO TO 1000        
  339 WRITE (L,839)        
      GO TO 1000        
  340 WRITE (L,840)        
      GO TO 1000        
  341 WRITE (L,841)        
      GO TO 1000        
  342 WRITE (L,842)        
      GO TO 1000        
  343 WRITE (L,843)        
      GO TO 1000        
  344 WRITE (L,844)        
      GO TO 1000        
  345 WRITE (L,845)        
      GO TO 1000        
  346 WRITE (L,846)        
      GO TO 1000        
  347 WRITE (L,847)        
      GO TO 1000        
  348 WRITE (L,848)        
      GO TO 1000        
  349 WRITE (L,849)        
      GO TO 1000        
  350 WRITE (L,850)        
      GO TO 1000        
  351 WRITE (L,851)        
      GO TO 1000        
  352 WRITE (L,852)        
      GO TO 1000        
  353 WRITE (L,853)        
      GO TO 1000        
  354 WRITE (L,854) ID(6),ID(7),FD(3)        
      GO TO 1000        
  355 WRITE (L,855)        
      GO TO 1000        
  356 WRITE (L,856)        
      GO TO 1000        
  357 WRITE (L,857)        
      GO TO 1000        
  358 WRITE (L,858)        
      GO TO 1000        
  359 WRITE (L,859)        
      GO TO 1000        
  360 WRITE (L,860)        
      GO TO 1000        
  361 WRITE (L,861)        
      GO TO 1000        
  362 WRITE (L,862)        
      GO TO 1000        
  363 WRITE (L,863)        
      GO TO 1000        
  364 WRITE (L,864)        
      GO TO 1000        
  365 WRITE (L,865)        
      GO TO 1000        
  366 WRITE (L,866)        
      GO TO 1000        
  367 WRITE (L,867)        
      GO TO 1000        
  368 WRITE (L,868)        
      GO TO 1000        
  369 WRITE (L,869)        
      GO TO 1000        
  370 WRITE (L,870)        
      GO TO 1000        
  371 WRITE (L,871)        
      GO TO 1000        
  372 WRITE (L,872)        
      GO TO 1000        
  373 WRITE (L,873)        
      GO TO 1000        
  374 WRITE (L,874)        
      GO TO 1000        
  375 WRITE (L,875)        
      GO TO 990        
  376 WRITE (L,876)        
      GO TO 1000        
  377 WRITE (L,877)        
      GO TO 1000        
  378 WRITE (L,878)        
      GO TO 1000        
  379 WRITE (L,879)        
      GO TO 1000        
  380 WRITE (L,880)        
      GO TO 1000        
  990 WRITE  (L,995)        
  995 FORMAT (1H )        
 1000 RETURN        
C        
C     ******************************************************************
C        
  676 FORMAT (2(25X,5HAXIAL,30X), /2(7X,4HTIME,14X,5HFORCE,9X,6HTORQUE, 
     1       15X))        
  677 FORMAT (21X,17HBEND-MOMENT-END-A,12X,17HBEND-MOMENT-END-B,18X,    
     1       5HSHEAR,17X, /7X,4HTIME,3(8X,7HPLANE 1,7X,7HPLANE 2),9X,   
     2       5HFORCE,10X,6HTORQUE)        
  678 FORMAT (2(25X,5HFORCE,10X,5HFORCE,15X), /2(7X,4HTIME,13X,        
     1       7HPTS 1,3,8X,7HPTS 2,4,14X))        
  679 FORMAT (2(24X,6HMOMENT,9X,6HMOMENT,15X), /2(7X,4HTIME,13X,        
     1       7HPTS 1,3,8X,7HPTS 2,4,14X))        
  680 FORMAT (8X,4HTIME,3X,2(11X,11HBEND-MOMENT),11X,12HTWIST-MOMENT,   
     1       13X,5HSHEAR,17X,5HSHEAR, /31X,1HX,21X,1HY,43X,1HX,21X,1HY) 
  681 FORMAT (4(8X,4HTIME,10X,5HFORCE,6X))        
  682 FORMAT (2(21X,5HAXIAL,7X,6HSAFETY,6X,9HTORSIONAL,5X,6HSAFETY), /  
     1       2(7X,4HTIME,9X,6HSTRESS,7X,6HMARGIN,8X,6HSTRESS,6X,        
     2       6HMARGIN))        
  683 FORMAT (7X,4HTIME,12X,3HSA1,12X,3HSA2,12X,3HSA3,10X,        
     1       12HAXIAL-STRESS,8X,6HSA-MAX,9X,6HSA-MIN,11X,6HM.S.-T, /23X,
     2       3HSB1,12X,3HSB2,12X,3HSB3,30X,6HSB-MAX,9X,6HSB-MIN,11X,    
     3       6HM.S.-C)        
  684 FORMAT (2(26X,7HMAXIMUM,8X,7HAVERAGE,6X,6HSAFETY), /2(8X,4HTIME,  
     1       15X,5HSHEAR,10X,5HSHEAR,7X,6HMARGIN))        
  685 FORMAT (2(54X,6HSAFETY), /2(7X,4HTIME,15X,7HMAXIMUM,8X,7HAVERAGE, 
     1       6X,6HMARGIN))        
  686 FORMAT (19X,5HFIBRE,11X,32HSTRESSES IN ELEMENT COORD SYSTEM,13X,  
     1       31HPRINCIPAL STRESSES (ZERO SHEAR),10X,7HMAXIMUM, /7X,     
     2       4HTIME,7X,8HDISTANCE,7X,8HNORMAL-X,7X,8HNORMAL-Y,6X,       
     3       8HSHEAR-XY,7X,5HANGLE,9X,5HMAJOR,11X,5HMINOR,10X,5HSHEAR)  
  687 FORMAT (20X,32HSTRESSES IN ELEMENT COORD SYSTEM,12X,9HPRINCIPAL,  
     1       11X,18HPRINCIPAL STRESSES,10X,7HMAXIMUM, /7X,4HTIME,8X,    
     2       8HNORMAL-X,6X,8HNORMAL-Y,7X,8HSHEAR-XY,6X,12HSTRESS ANGLE, 
     3       9X,5HMAJOR,10X,5HMINOR,10X,5HSHEAR)        
  688 FORMAT (4(8X,4HTIME, 9X,6HSTRESS,6X))        
  689 FORMAT (5X,4HTIME,15X,3HSA1,12X,3HSA2,12X,3HSA3,12X,3HSA4,8X,     
     1       12HAXIAL-STRESS,6X,6HSA-MAX,9X,6HSA-MIN,5X,6HM.S.-T, /24X, 
     2       3HSB1,12X,3HSB2,12X,3HSB3,12X,3HSB4,26X,6HSB-MAX,9X,       
     3       6HSB-MIN,5X,6HM.S.-C)        
  690 FORMAT (53X,5HAXIAL, /13X,9HFREQUENCY,31X,5HFORCE,41X,6HTORQUE)   
  691 FORMAT (11X,2(42X,5HFORCE), /13X,9HFREQUENCY,30X,7HPTS 1,3,40X,   
     1       7HPTS 2,4)        
  692 FORMAT (11X,2(41X,6HMOMENT), /13X,9HFREQUENCY,30X,7HPTS 1,3,40X,  
     1       7HPTS 2,4)        
  693 FORMAT (5X,9HFREQUENCY,2X,2(11X,11HBEND-MOMENT),10X,        
     1       12HTWIST-MOMENT,2(13X,5HSHEAR,4X), /2(31X,1HX,21X,1HY,12X))
  694 FORMAT (2(12X,9HFREQUENCY,20X,5HFORCE,12X))        
  695 FORMAT (53X,5HAXIAL,39X,9HTORSIONAL, /13X,9HFREQUENCY,        
     1       2(30X,6HSTRESS,11X))        
  696 FORMAT (52X,7HMAXIMUM,39X,7HAVERAGE, /13X,9HFREQUENCY,        
     1       2(31X,5HSHEAR,10X))        
  697 FORMAT (20X,5HFIBRE,37X,'- STRESSES IN ELEMENT COORDINATE SYSTEM',
     1       2H -, /4X,'FREQUENCY,6X,8HDISTANCE',18X,8HNORMAL-X,26X,    
     2       8HNORMAL-Y,25X,8HSHEAR-XY)        
  698 FORMAT (53X,41H- STRESSES IN ELEMENT COORDINATE SYSTEM -, /9X,    
     1       9HFREQUENCY,18X,8HNORMAL-X,26X,8HNORMAL-Y,26X,8HSHEAR-XY)  
  699 FORMAT (2(12X,9HFREQUENCY,19X,6HSTRESS,12X))        
  700 FORMAT (39X,4(8HLOCATION,7X),6X,7HAVERAGE, /8X,9HFREQUENCY,26X,   
     1       1H1,14X,1H2,14X,1H3,14X,1H4,13X,12HAXIAL STRESS)        
  701 FORMAT (21X,17HBEND-MOMENT-END-A,12X,17HBEND-MOMENT-END-B,18X,    
     1       5HSHEAR,17X, /4X,9HFREQUENCY,3(6X,7HPLANE 1,7X,        
     2       9HPLANE 2  ),6X,5HFORCE,10X,6HTORQUE)        
  702 FORMAT (27X,'O U T P U T   F R O M   G R I D   P O I N T   W E I',
     1       ' G H T   G E N E R A T O R', /1H0,53X,        
     2       17HREFERENCE POINT =,I9)        
  703 FORMAT (5X,9HSECTOR-ID,/6X,8HPOINT-ID,/7X,7HRING-ID,2X,8HHARMONIC,
     1       8X,2HT1,13X,2HT2,13X,2HT3,13X,2HR1,13X,2HR2,13X,2HR3)      
  704 FORMAT (11X,'S T R E S S E S   I N   A X I S - S Y M M E T R I C',
     1       '   C O N I C A L   S H E L L   E L E M E N T S   ',       
     2       '(CCONEAX)')        
  705 FORMAT (13X,'F O R C E S   I N   A X I S - S Y M M E T R I C   ', 
     1       'C O N I C A L   S H E L L   E L E M E N T S   (CCONEAX)') 
  706 FORMAT (8H ELEMENT,10X,5HPOINT,5X,5HFIBRE,11X,'STRESSES IN ELEM', 
     1       'ENT COORD SYSTEM',8X,'PRINCIPAL STRESSES (ZERO SHEAR)',   
     2       8X,7HMAXIMUM, /3X,'ID.  HARMONIC  ANGLE    DISTANCE',7X,   
     3       8HNORMAL-V,6X,8HNORMAL-U,6X,8HSHEAR-UV,6X,5HANGLE,7X,      
     4       5HMAJOR,9X,5HMINOR,9X,5HSHEAR)        
  707 FORMAT (9H  ELEMENT,5X,8HHARMONIC,4X,5HPOINT,4X,2(7X,5HBEND-,     
     1       6HMOMENT),6X,12HTWIST-MOMENT,2(11X,5HSHEAR,1X), /3X,3HID., 
     2       9X,6HNUMBER,5X,5HANGLE,15X,1HV,17X,1HU,37X,1HV,16X,1HU)    
  708 FORMAT (31X,'C O M P L E X   D I S P L A C E M E N T   ',        
     1       'V E C T O R  (SOLUTION SET)')        
  709 FORMAT (35X,'C O M P L E X   V E L O C I T Y   V E C T O R  ',    
     1       '(SOLUTION SET)')        
  710 FORMAT (31X,'C O M P L E X   A C C E L E R A T I O N   ',        
     1       'V E C T O R   (SOLUTION SET)')        
  711 FORMAT (43X,46HV E L O C I T Y   V E C T O R   (SOLUTION SET))    
  712 FORMAT (39X,'D I S P L A C E M E N T   V E C T O R   ',        
     1       '(SOLUTION SET)')        
  713 FORMAT (39X,'A C C E L E R A T I O N   V E C T O R   ',        
     1       '(SOLUTION SET)')        
  714 FORMAT (29X,'C O M P L E X   E I G E N V E C T O R   N O .',I11,  
     1       3X,14H(SOLUTION SET))        
  715 FORMAT (30X,'E I G E N V A L U E   A N A L Y S I S   ',        
     1       'S U M M A R Y   (GIVENS METHOD)')        
  716 FORMAT (///,36X,45HNUMBER OF EIGENVALUES EXTRACTED . . . . . . ., 
     1       I10,//36X,45HNUMBER OF EIGENVECTORS COMPUTED . . . . . . .,
     2       I10,//36X,45HNUMBER OF EIGENVALUE CONVERGENCE FAILURES . .,
     3       I10,//36X,45HNUMBER OF EIGENVECTOR CONVERGENCE FAILURES. .,
     4      I10,///36X,45HREASON FOR TERMINATION. . . . . . . . . . . .,
     5  I10,1H*,///36X,45HLARGEST OFF-DIAGONAL MODAL MASS TERM. . . . .,
     6 1P,E10.2,//76X,5H. . .,I10,/46X,'MODE PAIR. . . . . . . . . . .',
     7     /76X,5H. . .,I10,//36X,33HNUMBER OF OFF-DIAG0NAL MODAL MASS ,
     8     /41X,40HTERMS FAILING CRITERION. . . . . . . . .,I10)        
 7161 FORMAT (//36X,22H(* NORMAL TERMINATION))        
 7162 FORMAT (//36X,31H(* INSUFFICIENT TIME REMAINING))        
  717 FORMAT (107X,22HOCTAHEDRAL    PRESSURE, /6X,10HELEMENT-ID,8X,     
     1       8HSIGMA-XX,6X,8HSIGMA-YY,6X,8HSIGMA-ZZ,7X,6HTAU-YZ,8X,     
     2       6HTAU-XZ,8X,6HTAU-XY,8X,5HTAU-0,10X,1HP)        
  718 FORMAT (107X,22HOCTAHEDRAL    PRESSURE, /6X,10H TIME     ,8X,     
     1       8HSIGMA-XX,6X,8HSIGMA-YY,6X,8HSIGMA-ZZ,7X,6HTAU-YZ,8X,     
     2       6HTAU-XZ,8X,6HTAU-XY,8X,5HTAU-0,10X,1HP)        
  719 FORMAT (18X,10HELEMENT-ID,8X,8HSIGMA-XX,6X,8HSIGMA-YY,6X,        
     1       8HSIGMA-ZZ,7X,6HTAU-YZ,8X,6HTAU-XZ,8X,6HTAU-XY)        
  720 FORMAT (18X,10HFREQUENCY ,8X,8HSIGMA-XX,6X,8HSIGMA-YY,6X,        
     1       8HSIGMA-ZZ,7X,6HTAU-YZ,8X,6HTAU-XZ,8X,6HTAU-XY)        
  721 FORMAT (19X,'S T R E S S E S   I N   S O L I D   T E T R A H E D',
     1       ' R O N   E L E M E N T S   ( C T E T R A )')        
  722 FORMAT (11X,'C O M P L E X   S T R E S S E S   I N   S O L I D  ',
     1     ' T E T R A H E D R O N   E L E M E N T S   ( C T E T R A )')
  723 FORMAT (25X,'S T R E S S E S   I N   S O L I D   W E D G E   ',   
     1       'E L E M E N T S   ( C W E D G E )')        
  724 FORMAT (17X,'C O M P L E X   S T R E S S E S   I N   S O L I D  ',
     1       ' W E D G E   E L E M E N T S   ( C W E D G E )')        
  725 FORMAT (20X,'S T R E S S E S   I N   S O L I D   H E X A H E D R',
     1       ' O N   E L E M E N T S   ( C H E X A 1 )')        
  726 FORMAT (12X,'C O M P L E X   S T R E S S E S   I N   S O L I D  ',
     1       ' H E X A H E D R O N   E L E M E N T S   ( C H E X A 1 )')
  727 FORMAT (20X,'S T R E S S E S   I N   S O L I D   H E X A H E D R',
     1       ' O N   E L E M E N T S   ( C H E X A 2 )')        
  728 FORMAT (12X,'C O M P L E X   S T R E S S E S   I N   S O L I D  ',
     1       ' H E X A H E D R O N   E L E M E N T S   ( C H E X A 2 )')
  729 FORMAT (6X,10HPOINT-ID =,I7,4X,10HHARMONIC =,I4)        
 1729 FORMAT (6X,10HPOINT-ID =,I7,4X,10HHARMONIC =,I4,1H*)        
  730 FORMAT (5X,8HHARMONIC,5(3X,8HPOINT-ID,5X,2HT1,5X))        
  731 FORMAT (10X,'V E L O C I T I E S   I N   A X I S Y M M E T R I C',
     1       '   F L U I D   E L E M E N T S   ( C A X I F 2 - ',       
     2       'S T R E S S )')        
  732 FORMAT (10X,'V E L O C I T I E S   I N   A X I S Y M M E T R I C',
     1       '   F L U I D   E L E M E N T S   ( C A X I F 3 - ',       
     2       'S T R E S S )')        
  733 FORMAT (10X,'V E L O C I T I E S   I N   A X I S Y M M E T R I C',
     1       '   F L U I D   E L E M E N T S   ( C A X I F 4 - ',       
     2       'S T R E S S )')        
  734 FORMAT (24X,'V E L O C I T I E S   I N   S L O T   E L E M E N T',
     1       ' S   ( C S L O T 3 - S T R E S S )')        
  735 FORMAT (24X,'V E L O C I T I E S   I N   S L O T   E L E M E N T',
     1       ' S   ( C S L O T 4 - S T R E S S )')        
  736 FORMAT (2X,'C O M P L E X   V E L O C I T I E S   I N   A X I S ',
     1       'Y M M E T R I C   F L U I D   E L E M E N T S   ',        
     2       '( C A X I F 2 - S T R E S S )')        
  737 FORMAT (2X,'C O M P L E X   V E L O C I T I E S   I N   A X I S ',
     1       'Y M M E T R I C   F L U I D   E L E M E N T S   ',        
     2       '( C A X I F 3 - S T R E S S )')        
  738 FORMAT (2X,'C O M P L E X   V E L O C I T I E S   I N   A X I S ',
     1       'Y M M E T R I C   F L U I D   E L E M E N T S   ',        
     2       '( C A X I F 4 - S T R E S S )')        
  739 FORMAT (15X,'C O M P L E X   V E L O C I T I E S   I N   S L O T',
     1       '  E L E M E N T S   ( C S L O T 3 - S T R E S S )')       
  740 FORMAT (15X,'C O M P L E X   V E L O C I T I E S   I N   S L O T',
     1       '  E L E M E N T S   ( C S L O T 4 - S T R E S S )')       
  741 FORMAT (8X,7HELEMENT,17X,6HCENTER,25X,7HEDGE  1,19X,7HEDGE  2,19X,
     1       7HEDGE  3,/10X,3HID., 8X,27HR --------- PHI --------- Z,   
     2       12X,15HS --------- PHI,11X,15HS --------- PHI,11X,        
     3       15HS --------- PHI)        
  742 FORMAT (31X,6HCENTER,25X,7HEDGE  1,19X,7HEDGE  2,19X,7HEDGE  3,   
     1       /2X,8H   TIME ,10X,27HR --------- PHI --------- Z,12X,     
     2       15HS --------- PHI,11X,15HS --------- PHI,11X,        
     3       15HS --------- PHI)        
  743 FORMAT (32X,6HCENTER,25X,7HEDGE  1,19X,7HEDGE  2,19X,7HEDGE  3,   
     1       /4X,9HFREQUENCY,8X,27HR --------- PHI --------- Z,12X,     
     2       15HS --------- PHI,11X,15HS --------- PHI,11X,        
     3       15HS --------- PHI)        
  744 FORMAT (13X,7HELEMENT,18X,6HCENTER,20X,7HEDGE  1,11X,7HEDGE  2,   
     1       11X,7HEDGE  3,11X,7HEDGE  4,/15X,3HID.,13X,        
     2       19HR --------------- Z,17X,1HS,17X,1HS,17X,1HS,17X,1HS)    
  745 FORMAT (38X,6HCENTER,20X,7HEDGE  1,11X,7HEDGE  2,11X,7HEDGE  3,   
     1       11X,7HEDGE  4, /11X,4HTIME,16X,19HR --------------- Z,17X, 
     2       1HS,17X,1HS,17X,1HS,17X,1HS)        
  746 FORMAT (38X,6HCENTER,20X,7HEDGE  1,11X,7HEDGE  2,11X,7HEDGE  3,   
     1       11X,7HEDGE  4,/9X,9HFREQUENCY,13X,19HR --------------- Z,  
     2       17X,1HS,17X,1HS,17X,1HS,17X,1HS)        
  747 FORMAT (9X,7HELEMENT,24X,6HCENTER,26X,7HEDGE  1,15X,7HEDGE  2,    
     1       15X,7HEDGE  3,/11X,3HID.,17X,23HR ------------------- Z,   
     2       21X,1HS,21X,1HS,21X,1HS)        
  748 FORMAT (40X,6HCENTER,26X,7HEDGE  1,15X,7HEDGE  2,15X,7HEDGE  3,   
     1       /7X,4HTIME,20X,23HR ------------------- Z,21X,1HS,21X,1HS, 
     2       21X,1HS)        
  749 FORMAT (40X,6HCENTER,26X,7HEDGE  1,15X,7HEDGE  2,15X,7HEDGE  3,   
     1       /5X,9HFREQUENCY,17X,23HR ------------------- Z,21X,1HS,21X,
     2       1HS,21X,1HS)        
  750 FORMAT (14X,7HELEMENT,30X,6HCENTER,47X,4HEDGE,/16X,3HID.,21X,     
     1       27HR ----------------------- Z,25X,        
     2       28HS ---------------------- PHI)        
  751 FORMAT (51X,6HCENTER,47X,4HEDGE, /12X,4HTIME,24X,        
     1       27HR ----------------------- Z,25X,        
     2       28HS ---------------------- PHI)        
  752 FORMAT (51X,6HCENTER,47X,4HEDGE, /10X,9HFREQUENCY,21X,        
     1       27HR ----------------------- Z,25X,        
     2       28HS ---------------------- PHI)        
  753 FORMAT (46X,35HT E M P E R A T U R E   V E C T O R)        
 1754 WRITE  (L,754) IDX        
      GO TO  1000        
  754 FORMAT (36X,'S T R E S S E S   I N   U S E R   E L E M E N T S',  
     1       '  (C',A4,1H))        
 1759 WRITE  (L,759) IDX        
      GO TO  1000        
  759 FORMAT (38X,'F O R C E S   I N   U S E R   E L E M E N T S   (C', 
     1       A4,1H) )        
  764 FORMAT (5X,9H    EL-ID,6X,2HS1,11X,2HS2,11X,2HS3,11X,2HS4,11X,    
     1       2HS5,11X,2HS6,11X,2HS7,11X,2HS8,11X,2HS9)        
  765 FORMAT (5X,9H    EL-ID,6X,2HF1,11X,2HF2,11X,2HF3,11X,2HF4,11X,    
     1       2HF5,11X,2HF6,11X,2HF7,11X,2HF8,11X,2HF9)        
 1766 WRITE  (L,766) IDX        
      GO TO  1000        
  766 FORMAT (28X,'C O M P L E X   S T R E S S E S   I N   U S E R   ', 
     1       'E L E M E N T S   (C',A4,1H))        
 1771 WRITE  (L,771) IDX        
      GO TO  1000        
  771 FORMAT (30X,'C O M P L E X   F O R C E S   I N   U S E R   E L E',
     1       ' M E N T S   (C',A4,1H))        
  776 FORMAT (5X,9H     TIME,6X,2HS1,11X,2HS2,11X,2HS3,11X,2HS4,11X,    
     1       2HS5,11X,2HS6,11X,2HS7,11X,2HS8,11X,2HS9)        
  777 FORMAT (5X,9H     TIME,6X,2HF1,11X,2HF2,11X,2HF3,11X,2HF4,11X,    
     1       2HF5,11X,2HF6,11X,2HF7,11X,2HF8,11X,2HF9)        
  778 FORMAT (5X,9HFREQUENCY,6X,2HS1,11X,2HS2,11X,2HS3,11X,2HS4,11X,    
     1       2HS5,11X,2HS6,11X,2HS7,11X,2HS8,11X,2HS9)        
  779 FORMAT (5X,9HFREQUENCY,6X,2HF1,11X,2HF2,11X,2HF3,11X,2HF4,11X,    
     1       2HF5,11X,2HF6,11X,2HF7,11X,2HF8,11X,2HF9)        
  796 FORMAT (6X,'POINT ID.   TYPE',6X,'ID   VALUE     ID+1 VALUE    ', 
     1       'ID+2 VALUE     ID+3 VALUE     ID+4 VALUE     ID+5 VALUE') 
  797 FORMAT (19X,'F I N I T E   E L E M E N T   T E M P E R A T U R E',
     1       '   G R A D I E N T S   A N D   F L U X E S')        
  798 FORMAT (4X,'ELEMENT-ID   EL-TYPE        X-GRADIENT       Y-',     
     1       'GRADIENT       Z-GRADIENT        X-FLUX           Y-FLUX',
     2       '           Z-FLUX')        
  799 FORMAT (4X,'TIME         EL-TYPE        X-GRADIENT       Y-',     
     1       'GRADIENT       Z-GRADIENT        X-FLUX           Y-FLUX',
     2       '           Z-FLUX')        
  800 FORMAT (26X,'ELEMENT-ID      APPLIED-LOAD       CONVECTION      ',
     1       ' RADIATION           TOTAL')        
  801 FORMAT (26X,'TIME            APPLIED-LOAD       CONVECTION      ',
     1       ' RADIATION           TOTAL')        
  802 FORMAT (33X,'H E A T   F L O W   I N T O   H B D Y   E L E M E N',
     1       ' T S   (CHBDY)')        
  803 FORMAT (6X,16HTIME        TYPE  ,6X,7H  VALUE)        
  804 FORMAT (21X,'S T R E S S E S   I N   Q U A D R I L A T E R A L',  
     1       '   M E M B R A N E S      ( C Q D M E M 1 )')        
  805 FORMAT (14X,'C O M P L E X   S T R E S S E S   I N   Q U A D R I',
     1       ' L A T E R A L   M E M B R A N E S   ( C Q D M E M 1 )')  
  806 FORMAT (26X,'S T R E S S E S   A C T I N G   I N   Q D M E M 2  ',
     1       ' E L E M E N T S   (CQDMEM2)')        
  807 FORMAT (19X,'C O M P L E X   S T R E S S E S   A C T I N G   I N',
     1       '   Q D M E M 2   E L E M E N T S   (CQDMEM2)')        
  808 FORMAT (18X,'S T R E S S E S   I N   G E N E R A L   Q U A D R I',
     1       ' L A T E R A L   E L E M E N T S', 6X,15H( C Q U A D 4 )) 
  809 FORMAT ('0*** THIS FORMAT 809/OFP1B NOT USED ***')        
C                   ==============================        
  810 FORMAT (28X,'F O R C E S   A C T I N G   O N   Q D M E M 2   E L',
     1       ' E M E N T S   (CQDMEM2)')        
  811 FORMAT (20X,'C O M P L E X   F O R C E S   A C T I N G   O N   ', 
     1       'Q D M E M 2   E L E M E N T S   (CQDMEM2)')        
  812 FORMAT (18X,106H====== POINT  1 ======      ====== POINT  2 ======
     1      ====== POINT  3 ======      ====== POINT  4 ====== , /7X,   
     2       7HELEMENT,4X,8HF-FROM-4,6X,8HF-FROM-2,6X,8HF-FROM-1,6X,    
     3       8HF-FROM-3,6X,8HF-FROM-2,6X,8HF-FROM-4,6X,8HF-FROM-3,6X,   
     4       8HF-FROM-1, /9X,2HID,15X,6HKICK-1,7X,8HSHEAR-12,7X,        
     5       6HKICK-2,7X,8HSHEAR-23,7X,6HKICK-3,7X,8HSHEAR-34,7X,       
     6       6HKICK-4,7X,8HSHEAR-41 )        
  813 FORMAT (18X,106H====== POINT  1 ======      ====== POINT  2 ======
     1      ====== POINT  3 ======      ====== POINT  4 ====== , /14X,  
     2       4X,8HF-FROM-4,6X,8HF-FROM-2,6X,8HF-FROM-1,6X,8HF-FROM-3,6X,
     3       8HF-FROM-2,6X,8HF-FROM-4,6X,8HF-FROM-3,6X,8HF-FROM-1, /5X, 
     4       9HFREQUENCY,12X,6HKICK-1,7X,8HSHEAR-12,7X,6HKICK-2,7X,     
     5       8HSHEAR-23,7X,6HKICK-3,7X,8HSHEAR-34,7X,6HKICK-4,7X,       
     6       8HSHEAR-41)        
  814 FORMAT (18X,106H====== POINT  1 ======      ====== POINT  2 ======
     1      ====== POINT  3 ======      ====== POINT  4 ====== , /14X,  
     2       4X,8HF-FROM-4,6X,8HF-FROM-2,6X,8HF-FROM-1,6X,8HF-FROM-3,6X,
     3       8HF-FROM-2,6X,8HF-FROM-4,6X,8HF-FROM-3,6X,8HF-FROM-1, /10X,
     4       4HTIME,12X,6HKICK-1,7X,8HSHEAR-12,7X,6HKICK-2,7X,8HSHEAR-23
     5,      7X,6HKICK-3,7X,8HSHEAR-34,7X,6HKICK-4,7X,8HSHEAR-41)       
  815 FORMAT (6X,16HSUBCASE     TYPE,10X,2HT1,13X,2HT2,13X,2HT3,13X,    
     1       2HR1,13X,2HR2,13X,2HR3)        
  816 FORMAT (2(26X,7HMAXIMUM,8X,7HAVERAGE,6X,6HSAFETY),/2(6X,7HSUBCASE,
     1       14X,5HSHEAR,10X,5HSHEAR,7X,6HMARGIN))        
  817 FORMAT (20X,32HSTRESSES IN ELEMENT COORD SYSTEM,12X,9HPRINCIPAL,  
     1       11X,18HPRINCIPAL STRESSES,10X,7HMAXIMUM, /6X,7HSUBCASE,6X, 
     2       8HNORMAL-X,6X,8HNORMAL-Y,7X,8HSHEAR-XY,6X,12HSTRESS ANGLE, 
     3       9X,5HMAJOR,10X,5HMINOR,10X,5HSHEAR)        
  818 FORMAT (6X,7HSUBCASE,11X,3HSA1,12X,3HSA2,12X,3HSA3,12X,3HSA4,8X,  
     1       12HAXIAL-STRESS,6X,6HSA-MAX,9X,6HSA-MIN,5X,6HM.S.-T, /24X, 
     2       3HSB1,12X,3HSB2,12X,3HSB3,12X,3HSB4,26X,6HSB-MAX,9X,       
     3       6HSB-MIN,5X,6HM.S.-C)        
  819 FORMAT (18X,106H====== POINT  1 ======      ====== POINT  2 ======
     1      ====== POINT  3 ======      ====== POINT  4 ====== , /14X,  
     2       4X,8HF-FROM-4,6X,8HF-FROM-2,6X,8HF-FROM-1,6X,8HF-FROM-3,6X,
     3       8HF-FROM-2,6X,8HF-FROM-4,6X,8HF-FROM-3,6X,8HF-FROM-1, /5X, 
     4       7HSUBCASE,14X,6HKICK-1,7X,8HSHEAR-12,7X,6HKICK-2,7X,       
     5       8HSHEAR-23,7X,6HKICK-3,7X,8HSHEAR-34,7X,6HKICK-4,7X,       
     6       8HSHEAR-41 )        
  820 FORMAT (21X,17HBEND-MOMENT-END-A,12X,17HBEND-MOMENT-END-B,18X,    
     1       5HSHEAR, /6X,7HSUBCASE,6X,3(7HPLANE 1,7X,7HPLANE 2,8X),    
     2       6H FORCE,10X,6HTORQUE)        
  821 FORMAT (2(21X,5HAXIAL,7X,6HSAFETY,6X,9HTORSIONAL,5X,6HSAFETY), /  
     1       2(6X,7HSUBCASE,7X,6HSTRESS,7X,6HMARGIN,8X,6HSTRESS,6X,     
     2       6HMARGIN))        
  822 FORMAT (2(25X,5HAXIAL,30X) , /2(6X,7HSUBCASE,12X,5HFORCE, 9X,     
     1       6HTORQUE,15X))        
  823 FORMAT (5X,7HELEMENT,8X,33HSTRESSES IN MATERIAL COORD SYSTEM,12X, 
     1       9HPRINCIPAL,11X,18HPRINCIPAL STRESSES,12X,3HMAX)        
  824 FORMAT (13X,7HELEMENT,33X,'- STRESSES IN MATERIAL COORDINATE ',   
     1       'SYSTEM -', /15X,3HID.,18X,8HNORMAL-X,26X,8HNORMAL-Y,26X,  
     2       8HSHEAR-XY)        
  825 FORMAT (20X,33HSTRESSES IN MATERIAL COORD SYSTEM,11X,9HPRINCIPAL, 
     1       11X,18HPRINCIPAL STRESSES,10X,7HMAXIMUM, /7X,4HTIME,8X,    
     2       8HNORMAL-X,6X,8HNORMAL-Y,7X,8HSHEAR-XY,6X,12HSTRESS ANGLE, 
     3       9X,5HMAJOR,10X,5HMINOR,10X,5HSHEAR)        
  826 FORMAT (53X,42H- STRESSES IN MATERIAL COORDINATE SYSTEM -, /9X,   
     1       9HFREQUENCY,18X,8HNORMAL-X,26X,8HNORMAL-Y,26X,8HSHEAR-XY)  
  827 FORMAT (20X,33HSTRESSES IN MATERIAL COORD SYSTEM,11X,9HPRINCIPAL, 
     1       11X,18HPRINCIPAL STRESSES,10X,7HMAXIMUM, /6X,7HSUBCASE,6X, 
     2       8HNORMAL-X,6X,8HNORMAL-Y,7X,8HSHEAR-XY,6X,12HSTRESS ANGLE, 
     3       9X,5HMAJOR,10X,5HMINOR,10X,5HSHEAR)        
  828 FORMAT (21X,'S T R E S S E S   I N   I S O P A R A M E T R I C  ',
     1       ' S O L I D   ( C I H E X',I2,2H ))        
  829 FORMAT (2X,7HELEMENT,5X,4HGRID,11X,'STRESSES IN BASIC COORDINATE',
     1       'SYSTEM',13X,12HDIR. COSINES)        
  830 FORMAT (7X,2HID,4X,5HPOINT,8X,6HNORMAL,12X,5HSHEAR,10X,9HPRINCIPAL
     1,      10X,1HA,4X,1HB,4X,1HC,4X,11HMEAN STRESS,5X,9HMAX SHEAR)    
  831 FORMAT (13X,'C O M P L E X   S T R E S S E S   I N   I S O P A R',
     1       ' A M E T R I C   S O L I D   ( C I H E X',I2,2H ))        
  832 FORMAT (7X,2HID,3X,6HPOINTS,5X,8HNORMAL-X,9X,8HNORMAL-Y,9X,       
     1       8HNORMAL-Z,9X,8HSHEAR-XY,9X,8HSHEAR-YZ,9X,8HSHEAR-ZX)      
  833 FORMAT (25X,'F O R C E   D I S T R I B U T I O N   I N   B A R',  
     1       '   E L E M E N T S,10X,11H( C B A R )')        
  834 FORMAT (21H0    ELEMENT  STATION,9X,11HBEND-MOMENT,22X,        
     1       11HSHEAR FORCE,21X,5HAXIAL)        
  835 FORMAT (7X,3HID.,5X,5H(PCT),5X,7HPLANE 1,8X,7HPLANE 2,11X,        
     1       7HPLANE 1,8X,7HPLANE 2,15X,5HFORCE,14X,6HTORQUE)        
  836 FORMAT (25X,'S T R E S S   D I S T R I B U T I O N   I N   B A R',
     1       '  E L E M E N T S,7X,11H( C B A R )')        
  837 FORMAT (21H0    ELEMENT  STATION,4X,3HSXC,11X,3HSXD,11X,3HSXF,11X,
     1        3HSXG,12X,5HAXIAL,10X,5HS-MAX, 9X,5HS-MIN,9X,4HM.S.)      
  838 FORMAT (7X,3HID.,5X,5H(PCT))        
  839 FORMAT (21X,'F O R C E S  F O R  T H E  Q U A D R I L A T E R A L'
     1,      '  T H I N  S H E L L     ( C Q U A D T S )')        
  840 FORMAT (6X,2HEL,            36X,6HFORCES,51X,7HMOMENTS )        
  841 FORMAT (6X,2HID,5X,5HPOINT,9X,2HFX,17X,2HFY,17X,2HFZ,17X,2HMX,17X,
     1       2HMY,17X,2HMZ )        
  842 FORMAT (17X,'F O R C E S   I N   T R I A N G U L A R   T H I N  ',
     1       'S H E L L   E L E M E N T S   ( C T R S H L )')        
  843 FORMAT (19X,'S T R E S S E S  F O R  T H E  Q U A D R I L A T E ',
     1      'R A L  T H I N  S H E L L     ( C Q U A D T S )')        
  844 FORMAT (3X,9HEL STRESS,8X,28HMEMBRANE  STRESS  RESULTANTS,24X,    
     1       17HFLEXURAL  MOMENTS,27X,5HSHEAR )        
  845 FORMAT (3X,'ID  POINT   NORMAL(NX)     NORMAL(NY)     SHEAR(NXY)',
     1       '     NORMAL(MX)     NORMAL(MY)     TORQUE(MXY)     ',     
     2       'NORMAL(QX)     NORMAL(QY)')        
  846 FORMAT (18X,'S T R E S S E S   I N   T R I A N G U L A R   T H I',
     1       ' N   S H E L L   E L E M E N T S   ( C T R S H L )')      
  847 FORMAT (5X,'S T R E S S E S  I N  A X I S - S Y M M E T R I C  ', 
     1       'T R I A N G U L A R  R I N G  E L E M E N T S  (CTRIAAX)')
  848 FORMAT (' ELEMENT   HARMONIC    POINT    RADIAL      AXIAL',6X,   
     1       'CIRCUM.     SHEAR      SHEAR      SHEAR      F L U X   ', 
     2       'D E N S I T I E S', /,' ID.       NUMBER      ANGLE     ',
     3       '(R)         (Z)     (THETA-T)    (ZR)       (RT)       ', 
     4       '(ZT)        (R)        (Z)        (T)')        
  849 FORMAT (11X,'F O R C E S  I N  A X I S - S Y M M E T R I C  T R ',
     1       'I A N G U L A R  R I N G  E L E M E N T S  (CTRIAAX)')    
  850 FORMAT (1X,113H  ELEMENT   HARMONIC    POINT            RADIAL    
     1        CIRCUMFERENTIAL            AXIAL                CHARGE,   
     1        /1X,'    ID.      NUMBER     ANGLE             (R)',17X,  
     3        '(THETA-T)                (Z)')        
  851 FORMAT (5X,'S T R E S S E S  I N  A X I S - S Y M M E T R I C  T',
     1      ' R A P E Z O I D A L  R I N G  E L E M E N T S  (CTRAPAX)')
  852 FORMAT (11X,'F O R C E S  I N  A X I S - S Y M M E T R I C  T R ',
     1       'A P E Z O I D A L  R I N G  E L E M E N T S  (CTRAPAX)')  
  853 FORMAT (43X,45HE L E M E N T   S T R A I N   E N E R G I E S )    
  854 FORMAT (30X,15HELEMENT-TYPE = ,2A4,9X,23H* TOTAL FOR ALL TYPES = ,
     1       1P,E16.7, /1H0,95X,1H*, /36X,10HELEMENT-ID,10X,        
     2       13HSTRAIN-ENERGY,11X,16HPERCENT OF TOTAL )        
  855 FORMAT (42X,47HG R I D   P O I N T   F O R C E   B A L A N C E )  
  856 FORMAT (11H   POINT-ID,4X,10HELEMENT-ID,5X,6HSOURCE,13X,2HT1,13X, 
     1       2HT2,13X,2HT3,13X,2HR1,13X,2HR2,13X,2HR3)        
  857 FORMAT (22X,'F O R C E S   I N   T R I A N G U L A R   P L A T E',
     1       '  E L E M E N T S   ( C T R P L T 1 )')        
  858 FORMAT (20X,'S T R E S S E S   I N   T R I A N G U L A R   ',     
     1       'P L A T E   E L E M E N T S   ( C T R P L T 1 )')        
  859 FORMAT (1H0,9X,7HELEMENT,4X,5HPOINT,7X,2(11HBEND-MOMENT, 9X),     
     1       12HTWIST-MOMENT,2(11X,5HSHEAR,4X))        
  860 FORMAT (12X,3HID.,7X,3HNO.,13X,1HX,19X,1HY,39X,1HX,19X,1HY)       
  861 FORMAT (1H0, 8H ELEMENT, 2X, 5HPOINT, 5X, 5HFIBER, 11X,        
     1       32HSTRESSES IN ELEMENT COORD SYSTEM, 12X,        
     2       31HPRINCIPAL STRESSES (ZERO SHEAR), 11X, 3HMAX)        
  862 FORMAT (3X,3HID.,6X,3HNO.,5X,8HDISTANCE, 7X,8HNORMAL-X,6X,        
     1       8HNORMAL-Y,6X,8HSHEAR-XY,8X,5HANGLE,9X,5HMAJOR,9X,5HMINOR, 
     2       10X,5HSHEAR)        
  863 FORMAT (18X,'S T R E S S E S   I N   T R I A N G U L A R   ',     
     1       'M E M B R A N E   E L E M E N T S   ( C T R I M 6 )')     
  864 FORMAT (1H0, 8H ELEMENT, 5X, 5HPOINT, 7X,        
     1       32HSTRESSES IN ELEMENT COORD SYSTEM, 13X,        
     2       31HPRINCIPAL STRESSES (ZERO SHEAR), 13X, 3HMAX)        
  865 FORMAT (4X,3HID.,8X,3HNO., 5X,8HNORMAL-X,7X,8HNORMAL-Y,7X,        
     1       8HSHEAR-XY,8X,5HANGLE,10X,5HMAJOR,10X,5HMINOR,10X,5HSHEAR) 
  866 FORMAT (2(24X, 6HMOMENT, 9X, 6HMOMENT, 15X), /2(6X, 7HSUBCASE,11X,
     1       7HPTS 1,3, 8X, 7HPTS 2,4, 14X))        
  867 FORMAT (6X, 7HSUBCASE, 2X, 2(11X, 11HBEND-MOMENT), 11X,        
     1       12HTWIST-MOMENT, 13X, 5HSHEAR, 17X, 5HSHEAR,        
     2       /31X, 1HX, 21X, 1HY, 43X, 1HX, 21X, 1HY)        
  868 FORMAT (4(6X, 7HSUBCASE, 9X, 5HFORCE, 6X))        
  869 FORMAT (5X, 7HSUBCASE, 11X, 3HSA1, 12X, 3HSA2, 12X, 3HSA3, 10X,   
     1       12HAXIAL-STRESS, 8X, 6HSA-MAX, 9X, 6HSA-MIN, 11X,6HM.S.-T, 
     2       /23X, 3HSB1, 12X, 3HSB2, 12X, 3HSB3, 30X, 6HSB-MAX, 9X,    
     3       6HSB-MIN, 11X, 6HM.S.-C)        
  870 FORMAT (2(54X, 6HSAFETY), /2(5X, 7HSUBCASE, 14X, 7HMAXIMUM, 8X,   
     1       7HAVERAGE, 6X, 6HMARGIN))        
  871 FORMAT (19X, 5HFIBRE, 11X, 32HSTRESSES IN ELEMENT COORD SYSTEM,   
     1       13X, 31HPRINCIPAL STRESSES (ZERO SHEAR), 10X, 7HMAXIMUM,/  
     2       5X, 7HSUBCASE, 6X, 8HDISTANCE, 7X, 8HNORMAL-X, 7X,        
     3       8HNORMAL-Y, 6X, 8HSHEAR-XY, 7X, 5HANGLE, 9X, 5HMAJOR,      
     4       11X, 5HMINOR, 10X, 5HSHEAR)        
  872 FORMAT (4(6X, 7HSUBCASE, 8X, 6HSTRESS, 6X))        
  873 FORMAT (107X, 22HOCTAHEDRAL    PRESSURE,/5X, 10HSUBCASE   , 8X,   
     1       8HSIGMA-XX, 6X, 8HSIGMA-YY, 6X, 8HSIGMA-ZZ, 7X, 6HTAU-YZ,  
     2       8X, 6HTAU-XZ, 8X, 6HTAU-XY, 8X, 5HTAU-0, 10X, 1HP)        
  874 FORMAT (107X, 22HOCTAHEDRAL    PRESSURE,/5X, 11HSUBCASE    , 8X,  
     1       8HSIGMA-XX, 6X, 8HSIGMA-YY, 6X, 8HSIGMA-ZZ, 7X, 6HTAU-YZ,  
     2       8X, 6HTAU-XZ, 8X, 6HTAU-XY, 8X, 5HTAU-0, 10X, 1HP)        
  875 FORMAT (32X,'F O R C E S   O F   M U L T I - P O I N T   C O N S',
     1       ' T R A I N T')        
  876 FORMAT (2X,7HELEMENT,4X,16HMAT. COORD. SYS.,6X,        
     1       33HSTRESSES IN MATERIAL COORD SYSTEM,12X,        
     2       31HPRINCIPAL STRESSES (ZERO SHEAR),12X,3HMAX)        
  877 FORMAT (4X, 3HID., 6X, 15HID./OUTPUT CODE,        
     1       5X, 8HNORMAL-X, 7X, 8HNORMAL-Y, 6X, 8HSHEAR-XY,        
     2       7X, 5HANGLE, 9X, 5HMAJOR, 11X, 5HMINOR, 10X, 5HSHEAR)      
  878 FORMAT (43X,'S T R E S S E S   A T   G R I D   P O I N T S')      
  879 FORMAT (7X,'S T R A I N S / C U R V A T U R E S   I N   G E N E ',
     1       'R A L   T R I A N G U L A R   E L E M E N T S',6X,        
     2       '( C T R I A 1 )')        
  880 FORMAT (7X,'S T R A I N S / C U R V A T U R E S   I N   G E N E ',
     1       'R A L   T R I A N G U L A R   E L E M E N T S',6X,        
     2       '( C T R I A 2 )')        
C        
      END        
