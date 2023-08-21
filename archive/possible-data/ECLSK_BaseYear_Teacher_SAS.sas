libname LIB 'C:\ECLSK\';

filename in1 'C:\Teacher.dat';

footnote 'C:\ECLSK\ECLSK_ BaseYear_Teacher_SAS.sas';

proc format; 
   value LOCALE
      1 = "CENTRAL CITY"
      2 = "URBAN FRINGE AND LARGE TOWN"
      3 = "SMALL TOWN AND RURAL"
   ;
   value REGIONS
      1 = "NORTHEAST"
      2 = "MIDWEST"
      3 = "SOUTH"
      4 = "WEST"
      -9 = "NOT ASCERTAINED"
   ;
   value SCTYPES
      1 = "CATHOLIC"
      2 = "OTHER RELIGIOUS"
      3 = "OTHER PRIVATE"
      4 = "PUBLIC/DOD/BIA"
      -9 = "NOT ASCERTAINED"
   ;
   value S2PUBPRI
      1 = "PUBLIC"
      2 = "PRIVATE"
      -9 = "NOT ASCERTAINED"
   ;
   value S2SCTYPE
      1 = "CATHOLIC"
      2 = "OTHER RELIGIOUS"
      3 = "OTHER PRIVATE"
      4 = "PUBLIC"
      -9 = "NOT ASCERTAINED"
   ;
   value S2ENRLS
      1 = "0-149 STUDENTS"
      2 = "150-299 STUDENTS"
      3 = "300-499 STUDENTS"
      4 = "500-749 STUDENTS"
      5 = "750 AND ABOVE"
      -9 = "NOT ASCERTAINED"
   ;
   value S2SCLVL
      1 = "LESS THAN 1ST GRADE"
      2 = "PRIMARY SCHOOL"
      3 = "ELEMENTARY SCHOOL"
      4 = "COMBINED SCHOOL"
      -9 = "NOT ASCERTAINED"
   ;
   value A2CLASS
      1 = "AM ONLY"
      2 = "PM ONLY"
      3 = "AM AND PM"
      4 = "ALL DAY ONLY"
      5 = "AM AND ALL DAY"
      6 = "PM AND ALL DAY"
      7 = "AM, PM, AND ALL DAY"
      -9 = "NOT ASCERTAINED"
   ;
   value A2NEW
      0 - 7 = "0 - 7"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2BEHVR
      1 = "GROUP MISBEHAVES VERY FREQUENTLY"
      2 = "GROUP MISBEHAVES FREQUENTLY"
      3 = "GROUP MISBEHAVES OCCASIONALLY"
      4 = "GROUP BEHAVES WELL"
      5 = "GROUP BEHAVES EXCEPTIONALLY WELL"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2WHOLE
      1 = "NO TIME"
      2 = "HALF HOUR OR LESS"
      3 = "ABOUT ONE HOUR"
      4 = "ABOUT TWO HOURS"
      5 = "THREE HOURS OR MORE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2YN
      1 = "YES"
      2 = "NO"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2YNN
      1 = "YES"
      2 = "NO"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2OFTRD
      1 = "NEVER"
      2 = "LESS THAN ONCE A WEEK"
      3 = "1-2 TIMES A WEEK"
      4 = "3-4 TIMES A WEEK"
      5 = "DAILY"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2TXRD
      1 = "1-30 MINUTES A DAY"
      2 = "31-60 MINUTES A DAY"
      3 = "61-90 MINUTES A DAY"
      4 = "MORE THAN 90 MINUTES A DAY"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2TXSPEN
      1 = "DO NOT PARTICIPATE IN PHYSICAL EDUCATION"
      2 = "1-15 MINUTES PER DAY"
      3 = "16-30 MINUTES PER DAY"
      4 = "31-60 MINUTES PER DAY"
      5 = "MORE THAN 60 MINUTES PER DAY"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DYREC
      0 - 5 = "0 - 5"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2TXREC
      1 = "ONCE"
      2 = "TWICE"
      3 = "THREE OR MORE TIMES"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2LUNCH
      1 = "1-15 MINUTES"
      2 = "16-30 MINUTES"
      3 = "31-45 MINUTES"
      4 = "LONGER THAN 45 MINUTES"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DIVREA
      1 = "NEVER"
      2 = "LESS THAN ONCE A WEEK"
      3 = "ONCE OR TWICE A WEEK"
      4 = "THREE OR FOUR TIMES A WEEK"
      5 = "DAILY"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DIV
      1 = "NEVER"
      2 = "LESS THAN ONCE A WEEK"
      3 = "ONCE OR TWICE A WEEK"
      4 = "THREE OR FOUR TIMES A WEEK"
      5 = "DAILY"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2MINREA
      1 = "1-15 MINUTES/DAY"
      2 = "16-30 MINUTES/DAY"
      3 = "31-60 MINUTES/DAY"
      4 = "LONGER THAN 60 MINUTES/DAY"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2EXASIS
      1 = "NEVER"
      2 = "LESS THAN ONCE A WEEK"
      3 = "ONCE OR TWICE A WEEK"
      4 = "THREE OR FOUR TIMES A WEEK"
      5 = "DAILY"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2GOTO
      0 = "NO LIBRARY OR MEDIA CENTER IN THIS SCHOOL"
      1 = "ONCE A MONTH OR LESS"
      2 = "TWO OR THREE TIMES A MONTH"
      3 = "ONCE OR TWICE A WEEK"
      4 = "THREE OR FOUR TIMES A WEEK"
      5 = "DAILY"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2REGWRK
      0 - 7 = "0 - 7"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2SPEA
      1 = "NOT AT ALL WELL"
      2 = "NOT WELL"
      3 = "WELL"
      4 = "VERY WELL"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2LVLEF
      1 = "HIGH SCHOOL DIPLOMA OR GED"
      2 = "AA IN EARLY CHILDHOOD EDUCATION"
      3 = "BA OR BS IN ELEMENTARY EDUCATION"
      4 = "WORKING ON A BACHELORS DEGREE"
      5 = "DONT KNOW"
      6 = "OTHER (SPECIFY)"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2CERTF
      1 = "ELEMENTARY EDUCATION"
      2 = "EARLY CHILDHOOD EDUCATION"
      3 = "CURRENTLY WORKING ON A TEACHING CREDENT"
      4 = "DON'T KNOW"
      5 = "OTHER (SPECIFY)"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -9 = "NOT ASCERTAINED"
   ;
   value A2TXTBK
      1 = "I DO NOT USE THESE AT THIS GRADE LEVEL"
      2 = "NEVER ADEQUATE"
      3 = "OFTEN NOT ADEQUATE"
      4 = "SOMETIMES NOT ADEQUATE"
      5 = "ALWAYS ADEQUATE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2ARTMAT
      0 = "NOT AVAILABLE"
      1 = "NEVER"
      2 = "ONCE A MONTH OR LESS"
      3 = "TWO OR THREE TIMES A MONTH"
      4 = "ONCE OR TWICE A WEEK"
      5 = "THREE OR FOUR TIMES A WEEK"
      6 = "DAILY"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2LERN
      1 = "NEVER"
      2 = "ONCE A MONTH OR LESS"
      3 = "TWO OR THREE TIMES A MONTH"
      4 = "ONCE OR TWICE A WEEK"
      5 = "THREE OR FOUR TIMES A WEEK"
      6 = "DAILY"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2CONVEN
      1 = "TAUGHT AT A HIGHER GRADE LEVEL"
      2 = "CHILDREN SHOULD ALREADY KNOW"
      3 = "ONE A MONTH OR LESS"
      4 = "2-3 TIMES A MONTH"
      5 = "1-2 TIMES A WEEK"
      6 = "3-4 TIMES A WEEK"
      7 = "DAILY"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2INVSP
      1 = "STRONGLY DISAGREE"
      2 = "DISAGREE"
      3 = "NEITHER AGREE NOR DISAGREE"
      4 = "AGREE"
      5 = "STRONGLY AGREE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2LRNREA
      1 = "NEVER"
      2 = "ONCE A MONTH OR LESS"
      3 = "TWO OR THREE TIMES A MONTH"
      4 = "ONCE OR TWICE A WEEK"
      5 = "THREE OR FOUR TIMES A WEEK"
      6 = "DAILY"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2NUMCON
      1 = "NO CONFERENCES"
      2 = "ONE CONFERENCE"
      3 = "TWO CONFERENCES"
      4 = "THREE OR MORE CONFERENCES"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2TPCONF
      1 = "NONE"
      2 = "1-25 PERCENT"
      3 = "26-50 PERCENT"
      4 = "51-75 PERCENT"
      5 = "76 PERCENT OR MORE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2SENTHO
      1 = "NEVER"
      2 = "ONE TO TWO TIMES"
      3 = "THREE OR FIVE TIMES"
      4 = "SIX TO TEN TIMES"
      5 = "10-14 TIMES"
      6 = "15 OR MORE TIMES"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2MMCOMP
      1 = "JANUARY"
      2 = "FEBRUARY"
      3 = "MARCH"
      4 = "APRIL"
      5 = "MAY"
      6 = "JUNE"
      7 = "JULY"
      8 = "AUGUST"
      9 = "SEPTEMBER"
      10 = "OCTOBER"
      11 = "NOVEMBER"
      12 = "DECEMBER"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DDCOMP
      1 - 31 = "1 - 31"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2YYCOMP
      1999 = "1999"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2YNCOMP
      1 = "TRUE"
      0 = "FALSE"
   ;
   value B1001F
      0 - 15 = "0 - 15"
      -9 = "NOT ASCERTAINED"
   ;
   value B1002F
      0 - 30 = "0 - 30"
      -9 = "NOT ASCERTAINED"
   ;
   value B1003F
      0 - 15 = "0 - 15"
      -9 = "NOT ASCERTAINED"
   ;
   value B1004F
      0 - 15 = "0 - 15"
      -9 = "NOT ASCERTAINED"
   ;
   value B1005F
      0 - 10 = "0 - 10"
      -9 = "NOT ASCERTAINED"
   ;
   value B1006F
      0 - 10 = "0 - 10"
      -9 = "NOT ASCERTAINED"
   ;
   value B1007F
      0 - 10 = "0 - 10"
      -9 = "NOT ASCERTAINED"
   ;
   value B1008F
      0 - 10 = "0 - 10"
      -9 = "NOT ASCERTAINED"
   ;
   value B1009F
      0 - 5 = "0 - 5"
      -9 = "NOT ASCERTAINED"
   ;
   value B1010F
      0 - 5 = "0 - 5"
      -9 = "NOT ASCERTAINED"
   ;
   value B1011F
      0 - 30 = "0 - 30"
      -9 = "NOT ASCERTAINED"
   ;
   value B1012F
      24 - 58 = "24 - 58"
      -9 = "NOT ASCERTAINED"
   ;
   value A1048F
      1 = "YES"
      2 = "NO"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1049F
      1 = "NONE"
      2 = "1 - 25%"
      3 = "26 - 50%"
      4 = "51 - 75%"
      5 = "76% OR MORE"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1050F
      1 = "GROUP MISBEHAVES VERY FREQUENTLY"
      2 = "GROUP MISBEHAVES FREQUENTLY"
      3 = "GROUP MISBEHAVES OCCASIONALLY"
      4 = "GROUP BEHAVES WELL"
      5 = "GROUP BEHAVES EXCEPTIONALLY WELL"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1051F
      1 = "YES"
      2 = "NO"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1068F
      1 = "1 - 15 MINUTES PER DAY"
      2 = "16 - 30 MINUTES PER DAY"
      3 = "31 - 60 MINUTES PER DAY"
      4 = "MORE THAN 60 MINUTES PER DAY"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1069F
      1 = "JANUARY"
      2 = "FEBRUARY"
      3 = "MARCH"
      4 = "APRIL"
      5 = "MAY"
      6 = "JUNE"
      7 = "JULY"
      8 = "AUGUST"
      9 = "SEPTEMBER"
      10 = "OCTOBER"
      11 = "NOVEMBER"
      12 = "DECEMBER"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1070F
      1 - 31 = "1 - 31"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1071F
      1998 = "1998"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1072F
      1 = "ARABIC"
      2 = "FRENCH"
      3 = "GERMAN"
      4 = "GREEK"
      5 = "ITALIAN"
      6 = "POLISH"
      7 = "PORTUGUESE"
      8 = "AFRICAN LANGUAGE"
      9 = "EAST EUROPEAN LANGUAGE"
      10 = "NATIVE AMERICAN LANGUAGE"
      11 = "SIGN LANGUAGE"
      12 = "MIDDLE EASTERN LANGUAGE"
      13 = "WEST EUROPEAN LANGUAGE"
      14 = "INDIAN SUBCONTINENT - LANGUAGE"
      15 = "SOUTHEASTERN ASIAN LANGUAGE"
      16 = "PACIFIC ISLANDS LANGUAGE"
      17 = "OTHER LANGUAGE"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1073F
      1 = "ARABIC"
      2 = "FRENCH"
      3 = "GERMAN"
      4 = "GREEK"
      5 = "ITALIAN"
      6 = "POLISH"
      7 = "PORTUGUESE"
      8 = "AFRICAN LANGUAGE"
      9 = "EAST EUROPEAN LANGUAGE"
      10 = "NATIVE AMERICAN LANGUAGE"
      11 = "SIGN LANGUAGE"
      12 = "MIDDLE EASTERN LANGUAGE"
      13 = "WEST EUROPEAN LANGUAGE"
      14 = "INDIAN SUBCONTINENT - LANGUAGE"
      15 = "SOUTHEASTERN ASIAN LANGUAGE"
      16 = "PACIFIC ISLANDS LANGUAGE"
      17 = "OTHER LANGUAGE"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value B1013F
      1 = "NO TIME"
      2 = "HALF HOUR OR LESS"
      3 = "ABOUT ONE HOUR"
      4 = "ABOUT TWO HOURS"
      5 = "THREE HOURS OR MORE"
      -9 = "NOT ASCERTAINED"
   ;
   value B1014F
      1 = "YES"
      2 = "NO"
      -9 = "NOT ASCERTAINED"
   ;
   value B1015F
      1 = "NOT IMPORTANT"
      2 = "SOMEWHAT IMPORTANT"
      3 = "VERY IMPORTANT"
      4 = "EXTREMELY IMPORTANT"
      5 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value B1016F
      1 = "SAME STANDARDS, EXCEPTIONS FOR NEEDS"
      2 = "DIFFERENT STANDARDS BASED ON TALENTS"
      3 = "EXACTLY THE SAME STANDARDS"
      -9 = "NOT ASCERTAINED"
   ;
   value B1017F
      1 = "2 HOURS OR LESS PER WEEK"
      2 = "MORE THAN 2 HOURS BUT LESS THAN 5 A WEEK"
      3 = "5 TO 9 HOURS PER WEEK"
      4 = "10 TO 14 HOURS PER WEEK"
      5 = "15 OR MORE HOURS PER WEEK"
      -9 = "NOT ASCERTAINED"
   ;
   value B1018F
      1 = "NOT IMPORTANT"
      2 = "NOT VERY IMPORTANT"
      3 = "SOMEWHAT IMPORTANT"
      4 = "VERY IMPORTANT"
      5 = "ESSENTIAL"
      -9 = "NOT ASCERTAINED"
   ;
   value B1019F
      1 = "STRONGLY DISAGREE"
      2 = "DISAGREE"
      3 = "NEITHER AGREE NOR DISAGREE"
      4 = "AGREE"
      5 = "STRONGLY AGREE"
      -9 = "NOT ASCERTAINED"
   ;
   value B1020F
      1 = "NO INFLUENCE"
      2 = "SLIGHT INFLUENCE"
      3 = "SOME INFLUENCE"
      4 = "MODERATE INFLUENCE"
      5 = "A GREAT DEAL OF INFLUENCE"
      -9 = "NOT ASCERTAINED"
   ;
   value B1021F
      1 = "NO CONTROL"
      2 = "SLIGHT CONTROL"
      3 = "SOME CONTROL"
      4 = "MODERATE CONTROL"
      5 = "A GREAT DEAL OF CONTROL"
      -9 = "NOT ASCERTAINED"
   ;
   value B1022F
      1 = "MALE"
      2 = "FEMALE"
      -9 = "NOT ASCERTAINED"
   ;
   value B1023F
      1940 - 1974 = "1940 - 1974"
      -9 = "NOT ASCERTAINED"
   ;
   value B1024F
      1 = "YES"
      2 = "NO"
      -9 = "NOT ASCERTAINED"
   ;
   value B1025F
      1 = "HIGH SCHOOL/ASSOCIATE'S DEGREE/BACHELOR'S DEGREE"
      2 = "AT LEAST ONE YEAR BEYOND BACHELOR'S"
      3 = "MASTER'S DEGREE"
      4 = "EDUCATION SPECIALIST/PROFESSIONAL DIPLOMA"
      5 = "DOCTORATE"
      -9 = "NOT ASCERTAINED"
   ;
   value B1026F
      0 = "0"
      1 = "1"
      2 = "2"
      3 = "3"
      4 = "4"
      5 = "5"
      6 = "6+"
      -9 = "NOT ASCERTAINED"
   ;
   value B1027F
      1 = "NONE"
      2 = "TEMPORARY/PROBATIONAL CERTIFICATION"
      3 = "ALTERNATIVE PROGRAM CERTIFICATION"
      4 = "REGULAR CERTIFICATION, LESS THAN HIGHEST"
      5 = "HIGHEST CERTIFICATION AVAILABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value B1028F
      1 = "YES"
      2 = "NO"
      -9 = "NOT ASCERTAINED"
   ;
   value B1029F
      1998 = "1998"
      1999 = "1999"
      -9 = "NOT ASCERTAINED"
   ;
   value B1030F
      1 = "JANUARY"
      2 = "FEBRUARY"
      3 = "MARCH"
      4 = "APRIL"
      5 = "MAY"
      6 = "JUNE"
      7 = "JULY"
      8 = "AUGUST"
      9 = "SEPTEMBER"
      10 = "OCTOBER"
      11 = "NOVEMBER"
      12 = "DECEMBER"
      -9 = "NOT ASCERTAINED"
   ;
   value B1031F
      1 - 31 = "1 - 31"
      -9 = "NOT ASCERTAINED"
   ;
   value B1TTWSTR
      1 - 89 = "1 - 89"
   ;
   value B1TTWPSU
      1 - 80 = "1 - 80"
   ;
   value B1TW0F
      0 - 504 = "0 - 504"
   ;
   value B1TW1F
      0 - 585 = "0 - 585"
   ;
   value B1TW2F
      0 - 589 = "0 - 589"
   ;
   value B1TW3F
      0 - 500 = "0 - 500"
   ;
   value B1TW4F
      0 - 504 = "0 - 504"
   ;
   value B1TW5F
      0 - 508 = "0 - 508"
   ;
   value B1TW6F
      0 - 504 = "0 - 504"
   ;
   value B1TW7F
      0 - 503 = "0 - 503"
   ;
   value B1TW8F
      0 - 500 = "0 - 500"
   ;
   value B1TW9F
      0 - 500 = "0 - 500"
   ;
   value B1TW10F
      0 - 501 = "0 - 501"
   ;
   value B1TW11F
      0 - 512 = "0 - 512"
   ;
   value B1TW12F
      0 - 508 = "0 - 508"
   ;
   value B1TW13F
      0 - 506 = "0 - 506"
   ;
   value B1TW14F
      0 - 508 = "0 - 508"
   ;
   value B1TW15F
      0 - 510 = "0 - 510"
   ;
   value B1TW16F
      0 - 503 = "0 - 503"
   ;
   value B1TW17F
      0 - 778 = "0 - 778"
   ;
   value B1TW18F
      0 - 508 = "0 - 508"
   ;
   value B1TW19F
      0 - 504 = "0 - 504"
   ;
   value B1TW20F
      0 - 496 = "0 - 496"
   ;
   value B1TW21F
      0 - 500 = "0 - 500"
   ;
   value B1TW22F
      0 - 504 = "0 - 504"
   ;
   value B1TW23F
      0 - 508 = "0 - 508"
   ;
   value B1TW24F
      0 - 508 = "0 - 508"
   ;
   value B1TW25F
      0 - 504 = "0 - 504"
   ;
   value B1TW26F
      0 - 504 = "0 - 504"
   ;
   value B1TW27F
      0 - 504 = "0 - 504"
   ;
   value B1TW28F
      0 - 505 = "0 - 505"
   ;
   value B1TW29F
      0 - 504 = "0 - 504"
   ;
   value B1TW30F
      0 - 500 = "0 - 500"
   ;
   value B1TW31F
      0 - 512 = "0 - 512"
   ;
   value B1TW32F
      0 - 504 = "0 - 504"
   ;
   value B1TW33F
      0 - 504 = "0 - 504"
   ;
   value B1TW34F
      0 - 508 = "0 - 508"
   ;
   value B1TW35F
      0 - 500 = "0 - 500"
   ;
   value B1TW36F
      0 - 504 = "0 - 504"
   ;
   value B1TW37F
      0 - 504 = "0 - 504"
   ;
   value B1TW38F
      0 - 504 = "0 - 504"
   ;
   value B1TW39F
      0 - 504 = "0 - 504"
   ;
   value B1TW40F
      0 - 508 = "0 - 508"
   ;
   value B1TW41F
      0 - 502 = "0 - 502"
   ;
   value B1TW42F
      0 - 501 = "0 - 501"
   ;
   value B1TW43F
      0 - 500 = "0 - 500"
   ;
   value B1TW44F
      0 - 496 = "0 - 496"
   ;
   value B1TW45F
      0 - 502 = "0 - 502"
   ;
   value B1TW46F
      0 - 508 = "0 - 508"
   ;
   value B1TW47F
      0 - 498 = "0 - 498"
   ;
   value B1TW48F
      0 - 508 = "0 - 508"
   ;
   value B1TW49F
      0 - 504 = "0 - 504"
   ;
   value B1TW50F
      0 - 500 = "0 - 500"
   ;
   value B1TW51F
      0 - 509 = "0 - 509"
   ;
   value B1TW52F
      0 - 507 = "0 - 507"
   ;
   value B1TW53F
      0 - 504 = "0 - 504"
   ;
   value B1TW54F
      0 - 503 = "0 - 503"
   ;
   value B1TW55F
      0 - 503 = "0 - 503"
   ;
   value B1TW56F
      0 - 505 = "0 - 505"
   ;
   value B1TW57F
      0 - 500 = "0 - 500"
   ;
   value B1TW58F
      0 - 501 = "0 - 501"
   ;
   value B1TW59F
      0 - 505 = "0 - 505"
   ;
   value B1TW60F
      0 - 606 = "0 - 606"
   ;
   value B1TW61F
      0 - 504 = "0 - 504"
   ;
   value B1TW62F
      0 - 504 = "0 - 504"
   ;
   value B1TW63F
      0 - 504 = "0 - 504"
   ;
   value B1TW64F
      0 - 499 = "0 - 499"
   ;
   value B1TW65F
      0 - 502 = "0 - 502"
   ;
   value B1TW66F
      0 - 503 = "0 - 503"
   ;
   value B1TW67F
      0 - 508 = "0 - 508"
   ;
   value B1TW68F
      0 - 503 = "0 - 503"
   ;
   value B1TW69F
      0 - 500 = "0 - 500"
   ;
   value B1TW70F
      0 - 495 = "0 - 495"
   ;
   value B1TW71F
      0 - 512 = "0 - 512"
   ;
   value B1TW72F
      0 - 504 = "0 - 504"
   ;
   value B1TW73F
      0 - 518 = "0 - 518"
   ;
   value B1TW74F
      0 - 491 = "0 - 491"
   ;
   value B1TW75F
      0 - 405 = "0 - 405"
   ;
   value B1TW76F
      0 - 504 = "0 - 504"
   ;
   value B1TW77F
      0 - 501 = "0 - 501"
   ;
   value B1TW78F
      0 - 665 = "0 - 665"
   ;
   value B1TW79F
      0 - 500 = "0 - 500"
   ;
   value B1TW80F
      0 - 507 = "0 - 507"
   ;
   value B1TW81F
      0 - 499 = "0 - 499"
   ;
   value B1TW82F
      0 - 503 = "0 - 503"
   ;
   value B1TW83F
      0 - 504 = "0 - 504"
   ;
   value B1TW84F
      0 - 513 = "0 - 513"
   ;
   value B1TW85F
      0 - 508 = "0 - 508"
   ;
   value B1TW86F
      0 - 511 = "0 - 511"
   ;
   value B1TW87F
      0 - 548 = "0 - 548"
   ;
   value B1TW88F
      0 - 506 = "0 - 506"
   ;
   value B1TW89F
      0 - 501 = "0 - 501"
   ;
   value B1TW90F
      0 - 511 = "0 - 511"
   ;
   value B2TTWSTR
      1 - 90 = "1 - 90"
   ;
   value B2TTWPSU
      1 - 84 = "1 - 84"
   ;
   value B2TW0F
      0 - 454 = "0 - 454"
   ;
   value B2TW1F
      0 - 523 = "0 - 523"
   ;
   value B2TW2F
      0 - 522 = "0 - 522"
   ;
   value B2TW3F
      0 - 459 = "0 - 459"
   ;
   value B2TW4F
      0 - 454 = "0 - 454"
   ;
   value B2TW5F
      0 - 458 = "0 - 458"
   ;
   value B2TW6F
      0 - 454 = "0 - 454"
   ;
   value B2TW7F
      0 - 447 = "0 - 447"
   ;
   value B2TW8F
      0 - 450 = "0 - 450"
   ;
   value B2TW9F
      0 - 450 = "0 - 450"
   ;
   value B2TW10F
      0 - 452 = "0 - 452"
   ;
   value B2TW11F
      0 - 461 = "0 - 461"
   ;
   value B2TW12F
      0 - 457 = "0 - 457"
   ;
   value B2TW13F
      0 - 456 = "0 - 456"
   ;
   value B2TW14F
      0 - 458 = "0 - 458"
   ;
   value B2TW15F
      0 - 456 = "0 - 456"
   ;
   value B2TW16F
      0 - 453 = "0 - 453"
   ;
   value B2TW17F
      0 - 673 = "0 - 673"
   ;
   value B2TW18F
      0 - 464 = "0 - 464"
   ;
   value B2TW19F
      0 - 455 = "0 - 455"
   ;
   value B2TW20F
      0 - 447 = "0 - 447"
   ;
   value B2TW21F
      0 - 451 = "0 - 451"
   ;
   value B2TW22F
      0 - 454 = "0 - 454"
   ;
   value B2TW23F
      0 - 457 = "0 - 457"
   ;
   value B2TW24F
      0 - 458 = "0 - 458"
   ;
   value B2TW25F
      0 - 454 = "0 - 454"
   ;
   value B2TW26F
      0 - 454 = "0 - 454"
   ;
   value B2TW27F
      0 - 454 = "0 - 454"
   ;
   value B2TW28F
      0 - 451 = "0 - 451"
   ;
   value B2TW29F
      0 - 454 = "0 - 454"
   ;
   value B2TW30F
      0 - 451 = "0 - 451"
   ;
   value B2TW31F
      0 - 460 = "0 - 460"
   ;
   value B2TW32F
      0 - 454 = "0 - 454"
   ;
   value B2TW33F
      0 - 454 = "0 - 454"
   ;
   value B2TW34F
      0 - 456 = "0 - 456"
   ;
   value B2TW35F
      0 - 451 = "0 - 451"
   ;
   value B2TW36F
      0 - 454 = "0 - 454"
   ;
   value B2TW37F
      0 - 454 = "0 - 454"
   ;
   value B2TW38F
      0 - 454 = "0 - 454"
   ;
   value B2TW39F
      0 - 454 = "0 - 454"
   ;
   value B2TW40F
      0 - 452 = "0 - 452"
   ;
   value B2TW41F
      0 - 454 = "0 - 454"
   ;
   value B2TW42F
      0 - 452 = "0 - 452"
   ;
   value B2TW43F
      0 - 451 = "0 - 451"
   ;
   value B2TW44F
      0 - 453 = "0 - 453"
   ;
   value B2TW45F
      0 - 454 = "0 - 454"
   ;
   value B2TW46F
      0 - 456 = "0 - 456"
   ;
   value B2TW47F
      0 - 451 = "0 - 451"
   ;
   value B2TW48F
      0 - 458 = "0 - 458"
   ;
   value B2TW49F
      0 - 454 = "0 - 454"
   ;
   value B2TW50F
      0 - 453 = "0 - 453"
   ;
   value B2TW51F
      0 - 459 = "0 - 459"
   ;
   value B2TW52F
      0 - 457 = "0 - 457"
   ;
   value B2TW53F
      0 - 454 = "0 - 454"
   ;
   value B2TW54F
      0 - 453 = "0 - 453"
   ;
   value B2TW55F
      0 - 452 = "0 - 452"
   ;
   value B2TW56F
      0 - 455 = "0 - 455"
   ;
   value B2TW57F
      0 - 452 = "0 - 452"
   ;
   value B2TW58F
      0 - 454 = "0 - 454"
   ;
   value B2TW59F
      0 - 456 = "0 - 456"
   ;
   value B2TW60F
      0 - 537 = "0 - 537"
   ;
   value B2TW61F
      0 - 454 = "0 - 454"
   ;
   value B2TW62F
      0 - 454 = "0 - 454"
   ;
   value B2TW63F
      0 - 454 = "0 - 454"
   ;
   value B2TW64F
      0 - 451 = "0 - 451"
   ;
   value B2TW65F
      0 - 454 = "0 - 454"
   ;
   value B2TW66F
      0 - 451 = "0 - 451"
   ;
   value B2TW67F
      0 - 457 = "0 - 457"
   ;
   value B2TW68F
      0 - 452 = "0 - 452"
   ;
   value B2TW69F
      0 - 452 = "0 - 452"
   ;
   value B2TW70F
      0 - 449 = "0 - 449"
   ;
   value B2TW71F
      0 - 460 = "0 - 460"
   ;
   value B2TW72F
      0 - 453 = "0 - 453"
   ;
   value B2TW73F
      0 - 464 = "0 - 464"
   ;
   value B2TW74F
      0 - 444 = "0 - 444"
   ;
   value B2TW75F
      0 - 347 = "0 - 347"
   ;
   value B2TW76F
      0 - 448 = "0 - 448"
   ;
   value B2TW77F
      0 - 451 = "0 - 451"
   ;
   value B2TW78F
      0 - 594 = "0 - 594"
   ;
   value B2TW79F
      0 - 452 = "0 - 452"
   ;
   value B2TW80F
      0 - 457 = "0 - 457"
   ;
   value B2TW81F
      0 - 447 = "0 - 447"
   ;
   value B2TW82F
      0 - 451 = "0 - 451"
   ;
   value B2TW83F
      0 - 454 = "0 - 454"
   ;
   value B2TW84F
      0 - 455 = "0 - 455"
   ;
   value B2TW85F
      0 - 458 = "0 - 458"
   ;
   value B2TW86F
      0 - 461 = "0 - 461"
   ;
   value B2TW87F
      0 - 474 = "0 - 474"
   ;
   value B2TW88F
      0 - 457 = "0 - 457"
   ;
   value B2TW89F
      0 - 452 = "0 - 452"
   ;
   value B2TW90F
      0 - 460 = "0 - 460"
   ;
   value S2COMP
      1 = "LESS THAN 10"
      2 = "10 TO LESS THAN 25"
      3 = "25 TO LESS THAN 50"
      4 = "50 TO LESS THAN 75"
      5 = "75 OR MORE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1004P
      2 - 7 = "2 - 7"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1004D
      2 - 8 = "2 - 8"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1004A
      2 - 7 = "2 - 7"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1005P
      2 - 5 = "2 - 5"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1005D
      2 - 6 = "2 - 6"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1005A
      1 - 6 = "1 - 6"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1006D
      0 - 1 = "0 - 1"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1006A
      0 - 1 = "0 - 1"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1006P
      0 - 1 = "0 - 1"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1007D
      0 - 10 = "0 - 10"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1007P
      0 - 7 = "0 - 7"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1007A
      0 - 7 = "0 - 7"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1008P
      0 - 25 = "0 - 25"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1008A
      0 - 25 = "0 - 25"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1008D
      0 - 30 = "0 - 30"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1009A
      0 - 10 = "0 - 10"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1009P
      0 - 10 = "0 - 10"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1009D
      0 - 15 = "0 - 15"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1010P
      0 - 1 = "0 - 1"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1010D
      0 - 1 = "0 - 1"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1010A
      0 - 1 = "0 - 1"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1011D
      0 - 1 = "0 - 1"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1011P
      0 - 1 = "0 - 1"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1011A
      0 - 1 = "0 - 1"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1012P
      0 - 1 = "0 - 1"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1012D
      0 - 1 = "0 - 1"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1012A
      0 - 1 = "0 - 1"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1013D
      10 - 30 = "10 - 30"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1013P
      10 - 30 = "10 - 30"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1013A
      10 - 30 = "10 - 30"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1014A
      0 - 10 = "0 - 10"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1014P
      0 - 10 = "0 - 10"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1014D
      0 - 10 = "0 - 10"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1015P
      0 - 20 = "0 - 20"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1015D
      0 - 20 = "0 - 20"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1015A
      0 - 20 = "0 - 20"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1016P
      0 - 15 = "0 - 15"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1016D
      0 - 25 = "0 - 25"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1016A
      0 - 15 = "0 - 15"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1017P
      0 - 25 = "0 - 25"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1017D
      0 - 25 = "0 - 25"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1017A
      0 - 25 = "0 - 25"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1018A
      0 - 1 = "0 - 1"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1018D
      0 - 1 = "0 - 1"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1018P
      0 - 1 = "0 - 1"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1019D
      0 - 5 = "0 - 5"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1019P
      0 - 3 = "0 - 3"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1019A
      0 - 3 = "0 - 3"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1020D
      9 - 30 = "9 - 30"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1020P
      9 - 30 = "9 - 30"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1020A
      9 - 30 = "9 - 30"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1021A
      0 - 33 = "0 - 33"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1021P
      1 - 23 = "1 - 23"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1021D
      0 - 29 = "0 - 29"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1022D
      0 - 31 = "0 - 31"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1022P
      0 - 24 = "0 - 24"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1022A
      0 - 24 = "0 - 24"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1023A
      0 - 18 = "0 - 18"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1023D
      0 - 10 = "0 - 10"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1023P
      0 - 13 = "0 - 13"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1024A
      0 - 38 = "0 - 38"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1024P
      0 - 30 = "0 - 30"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1024D
      0 - 47 = "0 - 47"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1025D
      0 - 27 = "0 - 27"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1025P
      0 - 20 = "0 - 20"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1025A
      0 - 20 = "0 - 20"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1026D
      0 - 27 = "0 - 27"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1026A
      0 - 41 = "0 - 41"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1026P
      0 - 18 = "0 - 18"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1027P
      0 - 32 = "0 - 32"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1027D
      0 - 31 = "0 - 31"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1027A
      0 - 32 = "0 - 32"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1028D
      0 - 31 = "0 - 31"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1028P
      0 - 28 = "0 - 28"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1028A
      0 - 29 = "0 - 29"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1029P
      0 - 32 = "0 - 32"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1029A
      0 - 33 = "0 - 33"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1029D
      0 - 31 = "0 - 31"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1030P
      0 - 20 = "0 - 20"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1030D
      0 - 20 = "0 - 20"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1030A
      0 - 19 = "0 - 19"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1031D
      0 - 95 = "0 - 95"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1031A
      0 - 95 = "0 - 95"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1031P
      0 - 95 = "0 - 95"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1032P
      0 - 100 = "0 - 100"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1032D
      0 - 100 = "0 - 100"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1032A
      0 - 100 = "0 - 100"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1033D
      0 - 100 = "0 - 100"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1033P
      0 - 100 = "0 - 100"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A1033A
      0 - 100 = "0 - 100"
      -1 = "NOT APPLICABLE"
      -9 = "NOT ASCERTAINED"
   ;
   value A2AOTDIS
      0 - 6 = "0 - 6"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2ASPCIA
      0 - 12 = "0 - 12"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2AIEP
      0 - 12 = "0 - 12"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2AS504F
      0 - 7 = "0 - 7"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2AMORE
      0 - 29 = "0 - 29"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2PLEFT
      0 - 20 = "0 - 20"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2APRTGF
      0 - 1 = "0 - 1"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2PNEW
      0 - 39 = "0 - 39"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2PORTHO
      0 - 2 = "0 - 2"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2PPRTGF
      0 - 1 = "0 - 1"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2MN18C
      0 - 60 = "0 - 60"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2PIMPAI
      0 - 10 = "0 - 10"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2ARDBLO
      0 - 20 = "0 - 20"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DRDBLO
      0 - 26 = "0 - 26"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DPRTGF
      0 - 3 = "0 - 3"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DIMPAI
      0 - 22 = "0 - 22"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DGIFT
      0 - 4 = "0 - 4"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2PRDBLO
      0 - 25 = "0 - 25"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2PGIFT
      0 - 2 = "0 - 2"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2ALEFT
      0 - 26 = "0 - 26"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2ANEW
      0 - 39 = "0 - 39"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DDISAB
      0 - 9 = "0 - 9"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DABSEN
      0 - 18 = "0 - 18"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2PMORE
      0 - 20 = "0 - 20"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DTARDY
      0 - 22 = "0 - 22"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DMTHBL
      0 - 23 = "0 - 23"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2MN18E
      3 - 90 = "3 - 90"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2PMTHBL
      0 - 20 = "0 - 20"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2AGIFT
      0 - 2 = "0 - 2"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2PHEAR
      0 - 2 = "0 - 2"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2PVIS
      0 - 3 = "0 - 3"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2PDELAY
      0 - 20 = "0 - 20"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2PDSTRU
      0 - 2 = "0 - 2"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2PLRNDI
      0 - 30 = "0 - 30"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2PABSEN
      0 - 10 = "0 - 10"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DNEW
      0 - 44 = "0 - 44"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2AIMPAI
      0 - 12 = "0 - 12"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2AORTHO
      0 - 3 = "0 - 3"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2PTRAUM
      0 - 1 = "0 - 1"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DOTHER
      0 - 5 = "0 - 5"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DORTHO
      0 - 4 = "0 - 4"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DHEAR
      0 - 8 = "0 - 8"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DVIS
      0 - 13 = "0 - 13"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DDELAY
      0 - 23 = "0 - 23"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DRETAR
      0 - 1 = "0 - 1"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DIEP
      0 - 17 = "0 - 17"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DTRAUM
      0 - 2 = "0 - 2"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2AOTHER
      0 - 12 = "0 - 12"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2PTARDY
      0 - 12 = "0 - 12"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2AHEAR
      0 - 3 = "0 - 3"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2AVIS
      0 - 5 = "0 - 5"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2ADELAY
      0 - 14 = "0 - 14"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2ADSTRU
      0 - 4 = "0 - 4"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2ALRNDI
      0 - 7 = "0 - 7"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2PDISAB
      0 - 8 = "0 - 8"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2ADISAB
      0 - 7 = "0 - 7"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2ATRAUM
      0 - 1 = "0 - 1"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2ATARDY
      0 - 15 = "0 - 15"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2AABSEN
      0 - 8 = "0 - 8"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2AMHRS
      0 - 40 = "0 - 40"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2PS504F
      0 - 8 = "0 - 8"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2PIEP
      0 - 30 = "0 - 30"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2PSPCIA
      0 - 30 = "0 - 30"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2POTDIS
      0 - 2 = "0 - 2"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DLRNDI
      0 - 15 = "0 - 15"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DLEFT
      0 - 30 = "0 - 30"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2POTHER
      0 - 3 = "0 - 3"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2PMHRS
      0 - 40 = "0 - 40"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2AMTHBL
      0 - 15 = "0 - 15"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2MN18D
      1 - 95 = "1 - 95"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2MN18B
      2 - 90 = "2 - 90"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2MN18A
      0 - 90 = "0 - 90"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2NOMATH
      0 - 10 = "0 - 10"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2NUMRD
      0 - 34 = "0 - 34"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DMORE
      0 - 23 = "0 - 23"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DS504F
      0 - 10 = "0 - 10"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DSPCIA
      0 - 22 = "0 - 22"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DDSTRU
      0 - 12 = "0 - 12"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2DOTDIS
      0 - 9 = "0 - 9"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2FDHRS
      0 - 45 = "0 - 45"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2RECESS
      1 = "1-15 MINUTES"
      2 = "16-30 MINUTES"
      3 = "31-45 MINUTES"
      4 = "LONGER THAN 45 MINUTES"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2REGWRA
      0 - 8 = "0 - 8"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2REGWRB
      0 - 8 = "0 - 8"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2REGWRC
      0 - 6 = "0 - 6"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2REGWRD
      0 - 7 = "0 - 7"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A2REGWRE
      0 - 9 = "0 - 9"
      -1 = "NOT APPLICABLE"
      -7 = "REFUSED"
      -8 = "DON'T KNOW"
      -9 = "NOT ASCERTAINED"
   ;
   value A11074F
      1 = "REGULAR KINDERGARTEN ONLY"
      2 = "HAS OTHER KINDERGARTEN TYPE"
   ;
   value SUPPRESS
      -2 = "DATA SUPPRESSED"
   ;

run;

data lib.ECLSK_ BaseYear_Teacher_SAS;
   infile in1 lrecl=3320;
      input 
   #1
      @1 S_ID $4.
      @5 T_ID $7.
      @12 KURBAN 1.
      @13 CREGION 2.
      @15 CS_TYPE2 2.
      @17 B1TW0 10.5
      @27 B2TW0 10.5
      @37 A1TQUEX 1.
      @38 A1ACLASS 1.
      @39 A1PCLASS 1.
      @40 A1DCLASS 1.
      @41 B1TQUEX 1.
      @42 A2TQUEX 1.
      @43 A2ACLASS 1.
      @44 A2PCLASS 1.
      @45 A2DCLASS 1.
      @46 B2TQUEX 1.
      @47 S2KSCTYP 2.
      @49 S2KPUPRI 2.
      @51 S2KENRLS 2.
      @53 S2KSCLVL 2.
      @55 S2KMINOR 2.
      @57 KGCLASS 2.
      @59 A1APBLK 6.2
      @65 A1APHIS 6.2
      @71 A1APMIN 6.2
      @77 A1PPBLK 6.2
      @83 A1PPHIS 6.2
      @89 A1PPMIN 6.2
      @95 A1DPBLK 6.2
      @101 A1DPHIS 6.2
      @107 A1DPMIN 6.2
      @113 B1AGE 2.
      @115 A1AHRSDA 5.2
      @120 A1ADYSWK 5.2
      @125 A1AREGK 2.
      @127 A1A2YRK1 2.
      @129 A1A2YRK2 2.
      @131 A1ATRNK 2.
      @133 A1APR1ST 2.
      @135 A1AUNGR 2.
      @137 A1AMULGR 2.
      @139 A1ATPREK 2.
      @141 A1ATTRNK 2.
      @143 A1ATREGK 2.
      @145 A1ATPRE1 2.
      @147 A1AT1ST 2.
      @149 A1AT2ND 2.
      @151 A1AT3RD 2.
      @153 A1A3YROL 2.
      @155 A1A4YROL 2.
      @157 A1A5YROL 2.
      @159 A1A6YROL 2.
      @161 A1A7YROL 2.
      @163 A1A8YROL 2.
      @165 A1A9YROL 2.
      @167 A1ATOTAG 2.
      @169 A1AASIAN 2.
      @171 A1AHISP 2.
      @173 A1ABLACK 2.
      @175 A1AWHITE 2.
      @177 A1AAMRIN 2.
      @179 A1ARACEO 2.
      @181 A1ATOTRA 2.
      @183 A1ABOYS 2.
      @185 A1AGIRLS 2.
      @187 A1APRESC 2.
      @189 A1APCPRE 2.
      @191 A1AREPK 2.
      @193 A1ALETT 2.
      @195 A1AWORD 2.
      @197 A1ASNTNC 2.
      @199 A1ABEHVR 2.
      @201 A1AOTLAN 2.
      @203 A1ACSPNH 2.
      @205 A1ACVTNM 2.
      @207 A1ACCHNS 2.
      @209 A1ACJPNS 2.
      @211 A1ACKRN 2.
      @213 A1ACFLPN 2.
      @215 A1AOTASN 2.
      @217 A1AOTLNG 2.
      @219 A1ALANOS 2.
      @221 A1ALEP 2.
      @223 A1ANUMLE 2.
      @225 A1ANOESL 2.
      @227 A1AESLRE 2.
      @229 A1AESLOU 2.
      @231 A1ATNOOT 2.
      @233 A1ATSPNH 2.
      @235 A1ATVTNM 2.
      @237 A1ATCHNS 2.
      @239 A1ATJPNS 2.
      @241 A1ATKRN 2.
      @243 A1ATFLPN 2.
      @245 A1ATOTAS 2.
      @247 A1ATOTLG 2.
      @249 A1ALEPOS 2.
      @251 A1ANONEN 2.
      @253 A1PHRSDA 5.2
      @258 A1PDYSWK 5.2
      @263 A1PREGK 2.
      @265 A1P2YRK1 2.
      @267 A1P2YRK2 2.
      @269 A1PTRNK 2.
      @271 A1PPR1ST 2.
      @273 A1PUNGR 2.
      @275 A1PMULGR 2.
      @277 A1PTPREK 2.
      @279 A1PTTRNK 2.
      @281 A1PTREGK 2.
      @283 A1PTPRE1 2.
      @285 A1PT1ST 2.
      @287 A1PT2ND 2.
      @289 A1PT3RD 2.
      @291 A1P3YROL 2.
      @293 A1P4YROL 2.
      @295 A1P5YROL 2.
      @297 A1P6YROL 2.
      @299 A1P7YROL 2.
      @301 A1P8YROL 2.
      @303 A1P9YROL 2.
      @305 A1PTOTAG 2.
      @307 A1PASIAN 2.
      @309 A1PHISP 2.
      @311 A1PBLACK 2.
      @313 A1PWHITE 2.
      @315 A1PAMRIN 2.
      @317 A1PRACEO 2.
      @319 A1PTOTRA 2.
      @321 A1PBOYS 2.
      @323 A1PGIRLS 2.
      @325 A1PPRESC 2.
      @327 A1PPCPRE 2.
      @329 A1PREPK 2.
      @331 A1PLETT 2.
      @333 A1PWORD 2.
      @335 A1PSNTNC 2.
      @337 A1PBEHVR 2.
      @339 A1POTLAN 2.
      @341 A1PCSPNH 2.
      @343 A1PCVTNM 2.
      @345 A1PCCHNS 2.
      @347 A1PCJPNS 2.
      @349 A1PCKRN 2.
      @351 A1PCFLPN 2.
      @353 A1POTASN 2.
      @355 A1POTLNG 2.
      @357 A1PLANOS 2.
      @359 A1PLEP 2.
      @361 A1PNUMLE 2.
      @363 A1PNOESL 2.
      @365 A1PESLRE 2.
      @367 A1PESLOU 2.
      @369 A1PTNOOT 2.
      @371 A1PTSPNH 2.
      @373 A1PTVTNM 2.
      @375 A1PTCHNS 2.
      @377 A1PTJPNS 2.
      @379 A1PTKRN 2.
      @381 A1PTFLPN 2.
      @383 A1PTOTAS 2.
      @385 A1PTOTLG 2.
      @387 A1PLEPOS 2.
      @389 A1PNONEN 2.
      @391 A1DHRSDA 5.2
      @396 A1DDYSWK 5.2
      @401 A1DREGK 2.
      @403 A1D2YRK1 2.
      @405 A1D2YRK2 2.
      @407 A1DTRNK 2.
      @409 A1DPR1ST 2.
      @411 A1DUNGR 2.
      @413 A1DMULGR 2.
      @415 A1DTPREK 2.
      @417 A1DTTRNK 2.
      @419 A1DTREGK 2.
      @421 A1DTPRE1 2.
      @423 A1DT1ST 2.
      @425 A1DT2ND 2.
      @427 A1DT3RD 2.
      @429 A1D3YROL 2.
      @431 A1D4YROL 2.
      @433 A1D5YROL 2.
      @435 A1D6YROL 2.
      @437 A1D7YROL 2.
      @439 A1D8YROL 2.
      @441 A1D9YROL 2.
      @443 A1DTOTAG 2.
      @445 A1DASIAN 2.
      @447 A1DHISP 2.
      @449 A1DBLACK 2.
      @451 A1DWHITE 2.
      @453 A1DAMRIN 2.
      @455 A1DRACEO 2.
      @457 A1DTOTRA 2.
      @459 A1DBOYS 2.
      @461 A1DGIRLS 2.
      @463 A1DPRESC 2.
      @465 A1DPCPRE 2.
      @467 A1DREPK 2.
      @469 A1DLETT 2.
      @471 A1DWORD 2.
      @473 A1DSNTNC 2.
      @475 A1DBEHVR 2.
      @477 A1DOTLAN 2.
      @479 A1DCSPNH 2.
      @481 A1DCVTNM 2.
      @483 A1DCCHNS 2.
      @485 A1DCJPNS 2.
      @487 A1DCKRN 2.
      @489 A1DCFLPN 2.
      @491 A1DOTASN 2.
      @493 A1DOTLNG 2.
      @495 A1DLANOS 2.
      @497 A1DLEP 2.
      @499 A1DNUMLE 2.
      @501 A1DNOESL 2.
      @503 A1DESLRE 2.
      @505 A1DESLOU 2.
      @507 A1DTNOOT 2.
      @509 A1DTSPNH 2.
      @511 A1DTVTNM 2.
      @513 A1DTCHNS 2.
      @515 A1DTJPNS 2.
      @517 A1DTKRN 2.
      @519 A1DTFLPN 2.
      @521 A1DTOTAS 2.
      @523 A1DTOTLG 2.
      @525 A1DLEPOS 2.
      @527 A1DNONEN 2.
      @529 A1COMPMM 2.
      @531 A1COMPDD 2.
      @533 A1COMPYY 4.
      @537 B1WHLCLS 2.
      @539 B1SMLGRP 2.
      @541 B1INDVDL 2.
      @543 B1CHCLDS 2.
      @545 B1READAR 2.
      @547 B1LISTNC 2.
      @549 B1WRTCNT 2.
      @551 B1PCKTCH 2.
      @553 B1MATHAR 2.
      @555 B1PLAYAR 2.
      @557 B1WATRSA 2.
      @559 B1COMPAR 2.
      @561 B1SCIAR 2.
      @563 B1DRAMAR 2.
      @565 B1ARTARE 2.
      @567 B1TOCLAS 2.
      @569 B1TOSTND 2.
      @571 B1IMPRVM 2.
      @573 B1EFFO 2.
      @575 B1CLASPA 2.
      @577 B1ATTND 2.
      @579 B1BEHVR 2.
      @581 B1COPRTV 2.
      @583 B1FLLWDR 2.
      @585 B1OTMT 2.
      @587 B1EVAL 2.
      @589 B1PAIDPR 2.
      @591 B1NOPAYP 2.
      @593 B1FNSHT 2.
      @595 B1CNT20 2.
      @597 B1SHARE 2.
      @599 B1PRBLMS 2.
      @601 B1PENCIL 2.
      @603 B1NOTDSR 2.
      @605 B1ENGLAN 2.
      @607 B1SENSTI 2.
      @609 B1SITSTI 2.
      @611 B1ALPHBT 2.
      @613 B1FOLWDR 2.
      @615 B1IDCOLO 2.
      @617 B1COMM 2.
      @619 B1INFOHO 2.
      @621 B1INKNDR 2.
      @623 B1SHRTN 2.
      @625 B1VSTK 2.
      @627 B1HMEVST 2.
      @629 B1PRNTOR 2.
      @631 B1OTTRAN 2.
      @633 B1ATNDPR 2.
      @635 B1FRMLIN 2.
      @637 B1ALPHBF 2.
      @639 B1LRNREA 2.
      @641 B1TCHPRN 2.
      @643 B1PRCTWR 2.
      @645 B1HMWRK 2.
      @647 B1READAT 2.
      @649 B1SCHSPR 2.
      @651 B1MISBHV 2.
      @653 B1NOTCAP 2.
      @655 B1ACCPTD 2.
      @657 B1CNTNLR 2.
      @659 B1PAPRWR 2.
      @661 B1PSUPP 2.
      @663 B1SCHPLC 2.
      @665 B1CNTRLC 2.
      @667 B1STNDLO 2.
      @669 B1MISSIO 2.
      @671 B1ALLKNO 2.
      @673 B1PRESSU 2.
      @675 B1PRIORI 2.
      @677 B1ENCOUR 2.
      @679 B1ENJOY 2.
      @681 B1MKDIFF 2.
      @683 B1TEACH 2.
      @685 B1TGEND 2.
      @687 B1YRBORN 4.
      @691 B1HISP 2.
      @693 B1RACE1 2.
      @695 B1RACE2 2.
      @697 B1RACE3 2.
      @699 B1RACE4 2.
      @701 B1RACE5 2.
      @703 B1YRSPRE 5.2
      @708 B1YRSKIN 5.2
      @713 B1YRSFST 5.2
      @718 B1YRS2T5 5.2
      @723 B1YRS6PL 5.2
      @728 B1YRSESL 5.2
      @733 B1YRSBIL 5.2
      @738 B1YRSSPE 5.2
      @743 B1YRSPE 5.2
      @748 B1YRSART 5.2
      @753 B1YRSCH 5.2
      @758 B1HGHSTD 2.
      @760 B1EARLY 2.
      @762 B1ELEM 2.
      @764 B1SPECED 2.
      @766 B1ESL 2.
      @768 B1DEVLP 2.
      @770 B1MTHDRD 2.
      @772 B1MTHDMA 2.
      @774 B1MTHDSC 2.
      @776 B1TYPCER 2.
      @778 B1ELEMCT 2.
      @780 B1ERLYCT 2.
      @782 B1OTHCRT 2.
      @784 B1MMCOMP 2.
      @786 B1DDCOMP 2.
      @788 B1YYCOMP 4.
      @792 A2ANEW 2.
      @794 A2ALEFT 2.
      @796 A2AGIFT 2.
      @798 A2APRTGF 2.
      @800 A2ARDBLO 2.
      @802 A2AMTHBL 2.
      @804 A2ATARDY 2.
      @806 A2AABSEN 2.
      @808 A2ADISAB 2.
      @810 A2AIMPAI 2.
      @812 A2ALRNDI 2.
      @814 A2AEMPRB 2.
      @816 A2ARETAR 2.
      @818 A2ADELAY 2.
      @820 A2AVIS 2.
      @822 A2AHEAR 2.
      @824 A2AORTHO 2.
      @826 A2AOTHER 2.
      @828 A2AMULTI 2.
      @830 A2AAUTSM 2.
      @832 A2ATRAUM 2.
      @834 A2ADEAF 2.
      @836 A2AOTDIS 2.
      @838 A2ASPCIA 2.
      @840 A2AIEP 2.
      @842 A2ASC504 2.
      @844 A2AMORE 2.
      @846 A2ABEHVR 2.
      @848 A2AENGLS 2.
      @850 A2ACSPNH 2.
      @852 A2ACVTNM 2.
      @854 A2ACCHNS 2.
      @856 A2ACJPNS 2.
      @858 A2ACKRN 2.
      @860 A2ACFLPN 2.
      @862 A2AOTASN 2.
      @864 A2AOTLNG 2.
      @866 A2ALNGOS 2.
      @868 A2PNEW 2.
      @870 A2PLEFT 2.
      @872 A2PGIFT 2.
      @874 A2PPRTGF 2.
      @876 A2PRDBLO 2.
      @878 A2PMTHBL 2.
      @880 A2PTARDY 2.
      @882 A2PABSEN 2.
      @884 A2PDISAB 2.
      @886 A2PIMPAI 2.
      @888 A2PLRNDI 2.
      @890 A2PEMPRB 2.
      @892 A2PRETAR 2.
      @894 A2PDELAY 2.
      @896 A2PVIS 2.
      @898 A2PHEAR 2.
      @900 A2PORTHO 2.
      @902 A2POTHER 2.
      @904 A2PMULTI 2.
      @906 A2PAUTSM 2.
      @908 A2PTRAUM 2.
      @910 A2PDEAF 2.
      @912 A2POTDIS 2.
      @914 A2PSPCIA 2.
      @916 A2PIEP 2.
      @918 A2PSC504 2.
      @920 A2PMORE 2.
      @922 A2PBEHVR 2.
      @924 A2PENGLS 2.
      @926 A2PCSPNH 2.
      @928 A2PCVTNM 2.
      @930 A2PCCHNS 2.
      @932 A2PCJPNS 2.
      @934 A2PCKRN 2.
      @936 A2PCFLPN 2.
      @938 A2POTASN 2.
      @940 A2POTLNG 2.
      @942 A2PLNGOS 2.
      @944 A2DNEW 2.
      @946 A2DLEFT 2.
      @948 A2DGIFT 2.
      @950 A2DPRTGF 2.
      @952 A2DRDBLO 2.
      @954 A2DMTHBL 2.
      @956 A2DTARDY 2.
      @958 A2DABSEN 2.
      @960 A2DDISAB 2.
      @962 A2DIMPAI 2.
      @964 A2DLRNDI 2.
      @966 A2DEMPRB 2.
      @968 A2DRETAR 2.
      @970 A2DDELAY 2.
      @972 A2DVIS 2.
      @974 A2DHEAR 2.
      @976 A2DORTHO 2.
      @978 A2DOTHER 2.
      @980 A2DMULTI 2.
      @982 A2DAUTSM 2.
      @984 A2DTRAUM 2.
      @986 A2DDEAF 2.
      @988 A2DOTDIS 2.
      @990 A2DSPCIA 2.
      @992 A2DIEP 2.
      @994 A2DSC504 2.
      @996 A2DMORE 2.
      @998 A2DBEHVR 2.
      @1000 A2DENGLS 2.
      @1002 A2DCSPNH 2.
      @1004 A2DCVTNM 2.
      @1006 A2DCCHNS 2.
      @1008 A2DCJPNS 2.
      @1010 A2DCKRN 2.
      @1012 A2DCFLPN 2.
      @1014 A2DOTASN 2.
      @1016 A2DOTLNG 2.
      @1018 A2DLNGOS 2.
      @1020 A2WHLCLS 2.
      @1022 A2SMLGRP 2.
      @1024 A2INDVDL 2.
      @1026 A2CHCLDS 2.
      @1028 A2COMMTE 2.
      @1030 A2OFTRDL 2.
      @1032 A2TXRDLA 2.
      @1034 A2OFTMTH 2.
      @1036 A2TXMTH 2.
      @1038 A2OFTSOC 2.
      @1040 A2TXSOC 2.
      @1042 A2OFTSCI 2.
      @1044 A2TXSCI 2.
      @1046 A2OFTMUS 2.
      @1048 A2TXMUS 2.
      @1050 A2OFTART 2.
      @1052 A2TXART 2.
      @1054 A2OFTDAN 2.
      @1056 A2TXDAN 2.
      @1058 A2OFTHTR 2.
      @1060 A2TXTHTR 2.
      @1062 A2OFTFOR 2.
      @1064 A2TXFOR 2.
      @1066 A2OFTESL 2.
      @1068 A2TXESL 2.
      @1070 A2TXPE 2.
      @1072 A2TXSPEN 2.
      @1074 A2DYRECS 2.
      @1076 A2TXRCE 2.
      @1078 A2LUNCH 2.
      @1080 A2RECESS 2.
      @1082 A2DIVRD 2.
      @1084 A2DIVMTH 2.
      @1086 A2NUMRD 2.
      @1088 A2MINRD 2.
      @1090 A2NUMTH 2.
      @1092 A2MINMTH 2.
      @1094 A2EXASIS 2.
      @1096 A2MNEXTR 2.
      @1098 A2AIDTUT 2.
      @1100 A2MNAIDE 2.
      @1102 A2SPECTU 2.
      @1104 A2MNSPEC 2.
      @1106 A2PULLOU 2.
      @1108 A2MNPOIN 2.
      @1110 A2OTASSI 2.
      @1112 A2MNOSHP 2.
      @1114 A2GOTOLI 2.
      @1116 A2BORROW 2.
      @1118 A2PDAIDE 2.
      @1120 A2REGWRK 2.
      @1122 A2SPEDWK 2.
      @1124 A2ESLWRK 2.
      @1126 A2REGNON 2.
      @1128 A2SPEDNO 2.
      @1130 A2ESLNON 2.
      @1132 A2ALANG 2.
      @1134 A2ASPK 2.
      @1136 A2ALVLED 2.
      @1138 A2ACERTF 2.
      @1140 A2PLANG 2.
      @1142 A2PSPK 2.
      @1144 A2PLVLED 2.
      @1146 A2PCERTF 2.
      @1148 A2DLANG 2.
      @1150 A2DSPK 2.
      @1152 A2DLVLED 2.
      @1154 A2DCERTF 2.
      @1156 A2TXTBK 2.
      @1158 A2TRADBK 2.
      @1160 A2WORKBK 2.
      @1162 A2MANIPU 2.
      @1164 A2AUDIOV 2.
      @1166 A2VIDEO 2.
      @1168 A2COMPEQ 2.
      @1170 A2SOFTWA 2.
      @1172 A2PAPER 2.
      @1174 A2DITTO 2.
      @1176 A2ART 2.
      @1178 A2INSTRM 2.
      @1180 A2RECRDS 2.
      @1182 A2LEPMAT 2.
      @1184 A2DISMAT 2.
      @1186 A2HEATAC 2.
      @1188 A2CLSSPC 2.
      @1190 A2FURNIT 2.
      @1192 A2ARTMAT 2.
      @1194 A2MUSIC 2.
      @1196 A2COSTUM 2.
      @1198 A2COOK 2.
      @1200 A2BOOKS 2.
      @1202 A2VCR 2.
      @1204 A2TVWTCH 2.
      @1206 A2PLAYER 2.
      @1208 A2EQUIPM 2.
      @1210 A2LERNLT 2.
      @1212 A2PRACLT 2.
      @1214 A2NEWVOC 2.
      @1216 A2DICTAT 2.
      @1218 A2PHONIC 2.
      @1220 A2SEEPRI 2.
      @1222 A2NOPRNT 2.
      @1224 A2RETELL 2.
      @1226 A2READLD 2.
      @1228 A2BASAL 2.
      @1230 A2SILENT 2.
      @1232 A2WRKBK 2.
      @1234 A2WRTWRD 2.
      @1236 A2INVENT 2.
      @1238 A2CHSBK 2.
      @1240 A2COMPOS 2.
      @1242 A2DOPROJ 2.
      @1244 A2PUBLSH 2.
      @1246 A2SKITS 2.
      @1248 A2JRNL 2.
      @1250 A2TELLRS 2.
      @1252 A2MXDGRP 2.
      @1254 A2PRTUTR 2.
      @1256 A2CONVNT 2.
      @1258 A2RCGNZE 2.
      @1260 A2MATCH 2.
      @1262 A2WRTNME 2.
      @1264 A2RHYMNG 2.
      @1266 A2SYLLAB 2.
      @1268 A2PREPOS 2.
      @1270 A2MAINID 2.
      @1272 A2PREDIC 2.
      @1274 A2TEXTCU 2.
      @1276 A2ORALID 2.
      @1278 A2DRCTNS 2.
      @1280 A2PNCTUA 2.
      @1282 A2COMPSE 2.
      @1284 A2WRTSTO 2.
      @1286 A2SPELL 2.
      @1288 A2VOCAB 2.
      @1290 A2ALPBTZ 2.
      @1292 A2RDFLNT 2.
      @1294 A2INVSPE 2.
      @1296 A2OUTLOU 2.
      @1298 A2GEOMET 2.
      @1300 A2MANIPS 2.
      @1302 A2MTHGME 2.
      @1304 A2CALCUL 2.
      @1306 A2MUSMTH 2.
      @1308 A2CRTIVE 2.
      @1310 A2RULERS 2.
      @1312 A2EXPMTH 2.
      @1314 A2CALEND 2.
      @1316 A2MTHSHT 2.
      @1318 A2MTHTXT 2.
      @1320 A2CHLKBD 2.
      @1322 A2PRTNRS 2.
      @1324 A2REALLI 2.
      @1326 A2MXMATH 2.
      @1328 A2PEER 2.
      @1330 A2QUANTI 2.
      @1332 A21TO10 2.
      @1334 A22S5S10 2.
      @1336 A2BYD100 2.
      @1338 A2W12100 2.
      @1340 A2SHAPES 2.
      @1342 A2IDQNTY 2.
      @1344 A2SUBGRP 2.
      @1346 A2SZORDR 2.
      @1348 A2PTTRNS 2.
      @1350 A2REGZCN 2.
      @1352 A2SNGDGT 2.
      @1354 A2SUBSDG 2.
      @1356 A2PLACE 2.
      @1358 A2TWODGT 2.
      @1360 A23DGT 2.
      @1362 A2MIXOP 2.
      @1364 A2GRAPHS 2.
      @1366 A2DATACO 2.
      @1368 A2FRCTNS 2.
      @1370 A2ORDINL 2.
      @1372 A2ACCURA 2.
      @1374 A2TELLTI 2.
      @1376 A2ESTQNT 2.
      @1378 A2ADD2DG 2.
      @1380 A2CARRY 2.
      @1382 A2SUB2DG 2.
      @1384 A2PRBBTY 2.
      @1386 A2EQTN 2.
      @1388 A2LRNRD 2.
      @1390 A2LRNMTH 2.
      @1392 A2LRNSS 2.
      @1394 A2LRNSCN 2.
      @1396 A2LRNKEY 2.
      @1398 A2LRNART 2.
      @1400 A2LRNMSC 2.
      @1402 A2LRNGMS 2.
      @1404 A2LRNLAN 2.
      @1406 A2BODY 2.
      @1408 A2PLANT 2.
      @1410 A2DINOSR 2.
      @1412 A2SOLAR 2.
      @1414 A2WTHER 2.
      @1416 A2TEMP 2.
      @1418 A2WATER 2.
      @1420 A2SOUND 2.
      @1422 A2LIGHT 2.
      @1424 A2MAGNET 2.
      @1426 A2MOTORS 2.
      @1428 A2TOOLS 2.
      @1430 A2HYGIEN 2.
      @1432 A2HISTOR 2.
      @1434 A2CMNITY 2.
      @1436 A2MAPRD 2.
      @1438 A2CULTUR 2.
      @1440 A2LAWS 2.
      @1442 A2ECOLOG 2.
      @1444 A2GEORPH 2.
      @1446 A2SCMTHD 2.
      @1448 A2SOCPRO 2.
      @1450 A2NUMCNF 2.
      @1452 A2TPCONF 2.
      @1454 A2REGHLP 2.
      @1456 A2ATTOPN 2.
      @1458 A2ATTART 2.
      @1460 A2AVHRS 2.
      @1462 A2PVHRS 2.
      @1464 A2DVHRS 2.
      @1466 A2SNTHME 2.
      @1468 A2SHARED 2.
      @1470 A2LESPLN 2.
      @1472 A2CURRDV 2.
      @1474 A2INDCHD 2.
      @1476 A2DISCHD 2.
      @1478 A2INSRVC 2.
      @1480 A2WRKSHP 2.
      @1482 A2CNSLT 2.
      @1484 A2FDBACK 2.
      @1486 A2SUPPOR 2.
      @1488 A2OBSERV 2.
      @1490 A2RELTIM 2.
      @1492 A2COLLEG 2.
      @1494 A2TECH 2.
      @1496 A2STFFTR 2.
      @1498 A2ADTRND 2.
      @1500 A2INCLUS 2.
      @1502 A2MMCOMP 2.
      @1504 A2DDCOMP 2.
      @1506 A2YYCOMP 4.
      @1510 B1TTWSTR 2.
      @1512 B1TTWPSU 2.
      @1514 B1TW1 10.5
      @1524 B1TW2 10.5
      @1534 B1TW3 10.5
      @1544 B1TW4 10.5
      @1554 B1TW5 10.5
      @1564 B1TW6 10.5
      @1574 B1TW7 10.5
      @1584 B1TW8 10.5
      @1594 B1TW9 10.5
      @1604 B1TW10 10.5
      @1614 B1TW11 10.5
      @1624 B1TW12 10.5
      @1634 B1TW13 10.5
      @1644 B1TW14 10.5
      @1654 B1TW15 10.5
      @1664 B1TW16 10.5
      @1674 B1TW17 10.5
      @1684 B1TW18 10.5
      @1694 B1TW19 10.5
      @1704 B1TW20 10.5
      @1714 B1TW21 10.5
      @1724 B1TW22 10.5
      @1734 B1TW23 10.5
      @1744 B1TW24 10.5
      @1754 B1TW25 10.5
      @1764 B1TW26 10.5
      @1774 B1TW27 10.5
      @1784 B1TW28 10.5
      @1794 B1TW29 10.5
      @1804 B1TW30 10.5
      @1814 B1TW31 10.5
      @1824 B1TW32 10.5
      @1834 B1TW33 10.5
      @1844 B1TW34 10.5
      @1854 B1TW35 10.5
      @1864 B1TW36 10.5
      @1874 B1TW37 10.5
      @1884 B1TW38 10.5
      @1894 B1TW39 10.5
      @1904 B1TW40 10.5
      @1914 B1TW41 10.5
      @1924 B1TW42 10.5
      @1934 B1TW43 10.5
      @1944 B1TW44 10.5
      @1954 B1TW45 10.5
      @1964 B1TW46 10.5
      @1974 B1TW47 10.5
      @1984 B1TW48 10.5
      @1994 B1TW49 10.5
      @2004 B1TW50 10.5
      @2014 B1TW51 10.5
      @2024 B1TW52 10.5
      @2034 B1TW53 10.5
      @2044 B1TW54 10.5
      @2054 B1TW55 10.5
      @2064 B1TW56 10.5
      @2074 B1TW57 10.5
      @2084 B1TW58 10.5
      @2094 B1TW59 10.5
      @2104 B1TW60 10.5
      @2114 B1TW61 10.5
      @2124 B1TW62 10.5
      @2134 B1TW63 10.5
      @2144 B1TW64 10.5
      @2154 B1TW65 10.5
      @2164 B1TW66 10.5
      @2174 B1TW67 10.5
      @2184 B1TW68 10.5
      @2194 B1TW69 10.5
      @2204 B1TW70 10.5
      @2214 B1TW71 10.5
      @2224 B1TW72 10.5
      @2234 B1TW73 10.5
      @2244 B1TW74 10.5
      @2254 B1TW75 10.5
      @2264 B1TW76 10.5
      @2274 B1TW77 10.5
      @2284 B1TW78 10.5
      @2294 B1TW79 10.5
      @2304 B1TW80 10.5
      @2314 B1TW81 10.5
      @2324 B1TW82 10.5
      @2334 B1TW83 10.5
      @2344 B1TW84 10.5
      @2354 B1TW85 10.5
      @2364 B1TW86 10.5
      @2374 B1TW87 10.5
      @2384 B1TW88 10.5
      @2394 B1TW89 10.5
      @2404 B1TW90 10.5
      @2414 B2TTWSTR 2.
      @2416 B2TTWPSU 2.
      @2418 B2TW1 10.5
      @2428 B2TW2 10.5
      @2438 B2TW3 10.5
      @2448 B2TW4 10.5
      @2458 B2TW5 10.5
      @2468 B2TW6 10.5
      @2478 B2TW7 10.5
      @2488 B2TW8 10.5
      @2498 B2TW9 10.5
      @2508 B2TW10 10.5
      @2518 B2TW11 10.5
      @2528 B2TW12 10.5
      @2538 B2TW13 10.5
      @2548 B2TW14 10.5
      @2558 B2TW15 10.5
      @2568 B2TW16 10.5
      @2578 B2TW17 10.5
      @2588 B2TW18 10.5
      @2598 B2TW19 10.5
      @2608 B2TW20 10.5
      @2618 B2TW21 10.5
      @2628 B2TW22 10.5
      @2638 B2TW23 10.5
      @2648 B2TW24 10.5
      @2658 B2TW25 10.5
      @2668 B2TW26 10.5
      @2678 B2TW27 10.5
      @2688 B2TW28 10.5
      @2698 B2TW29 10.5
      @2708 B2TW30 10.5
      @2718 B2TW31 10.5
      @2728 B2TW32 10.5
      @2738 B2TW33 10.5
      @2748 B2TW34 10.5
      @2758 B2TW35 10.5
      @2768 B2TW36 10.5
      @2778 B2TW37 10.5
      @2788 B2TW38 10.5
      @2798 B2TW39 10.5
      @2808 B2TW40 10.5
      @2818 B2TW41 10.5
      @2828 B2TW42 10.5
      @2838 B2TW43 10.5
      @2848 B2TW44 10.5
      @2858 B2TW45 10.5
      @2868 B2TW46 10.5
      @2878 B2TW47 10.5
      @2888 B2TW48 10.5
      @2898 B2TW49 10.5
      @2908 B2TW50 10.5
      @2918 B2TW51 10.5
      @2928 B2TW52 10.5
      @2938 B2TW53 10.5
      @2948 B2TW54 10.5
      @2958 B2TW55 10.5
      @2968 B2TW56 10.5
      @2978 B2TW57 10.5
      @2988 B2TW58 10.5
      @2998 B2TW59 10.5
      @3008 B2TW60 10.5
      @3018 B2TW61 10.5
      @3028 B2TW62 10.5
      @3038 B2TW63 10.5
      @3048 B2TW64 10.5
      @3058 B2TW65 10.5
      @3068 B2TW66 10.5
      @3078 B2TW67 10.5
      @3088 B2TW68 10.5
      @3098 B2TW69 10.5
      @3108 B2TW70 10.5
      @3118 B2TW71 10.5
      @3128 B2TW72 10.5
      @3138 B2TW73 10.5
      @3148 B2TW74 10.5
      @3158 B2TW75 10.5
      @3168 B2TW76 10.5
      @3178 B2TW77 10.5
      @3188 B2TW78 10.5
      @3198 B2TW79 10.5
      @3208 B2TW80 10.5
      @3218 B2TW81 10.5
      @3228 B2TW82 10.5
      @3238 B2TW83 10.5
      @3248 B2TW84 10.5
      @3258 B2TW85 10.5
      @3268 B2TW86 10.5
      @3278 B2TW87 10.5
      @3288 B2TW88 10.5
      @3298 B2TW89 10.5
      @3308 B2TW90 10.5
      @3318 A1AKGTYP 1.
      @3319 A1PKGTYP 1.
      @3320 A1DKGTYP 1.
      ;

   IF (S2KPUPRI EQ 1 OR 
       S2KPUPRI EQ 2 OR 
       S2KPUPRI EQ -9) AND 
      (KGCLASS EQ 1 OR 
       KGCLASS EQ 2 OR 
       KGCLASS EQ 3 OR 
       KGCLASS EQ 4 OR 
       KGCLASS EQ 5 OR 
       KGCLASS EQ 6 OR 
       KGCLASS EQ 7 OR 
       KGCLASS EQ -9);

   label
      S_ID = "CROSS ORIG/SUB SCHOOL ID"
      T_ID = "TEACHER IDENTIFICATION NUMBER"
      KURBAN = "LOCATION TYPE IN SAMPLE FRAME"
      CREGION = "CENSUS REGION IN SAMPLE FRAME"
      CS_TYPE2 = "TYPE OF SCHOOL IN SAMPLE FRAME"
      B1TW0 = "B1 TEACHER WEIGHT FULL SAMPLE"
      B2TW0 = "B2 TEACHER WEIGHT FULL SAMPLE"
      A1TQUEX = "A1 PART A QUESTIONNAIRE COMPLETED"
      A1ACLASS = "A1 AM CLASS IN PART A QUESTIONNAIRE"
      A1PCLASS = "A1 PM CLASS IN PART A QUESTIONNAIRE"
      A1DCLASS = "A1 ALL DAY CLASS IN PART A QUESTIONNAIRE"
      B1TQUEX = "B1 PART B QUESTIONNAIRE COMPLETED"
      A2TQUEX = "A2 PART A QUESTIONNAIRE COMPLETED"
      A2ACLASS = "A2 AM CLASS IN PART A QUESTIONNAIRE"
      A2PCLASS = "A2 PM CLASS IN PART A QUESTIONNAIRE"
      A2DCLASS = "A2 ALL DAY CLASS IN PART A QUESTIONNAIRE"
      B2TQUEX = "B2 PART B QUESTIONNAIRE COMPLETED"
      S2KSCTYP = "S2 SCHOOL TYPE FROM THE SCH ADMIN QUEST"
      S2KPUPRI = "S2 PUBLIC OR PRIVATE SCHOOL"
      S2KENRLS = "S2 TOTAL SCHOOL ENROLLMENT"
      S2KSCLVL = "S2 SCH INSTRUCTNL LEVEL FROM ADMIN QUEST"
      S2KMINOR = "S2 PERCENT MINORITY STUDENTS"
      KGCLASS = "KINDERGARTEN TEACHER CLASS COMPOSITE"
      A1APBLK = "A1 PERCENT OF BLACKS IN CLASS-AM"
      A1APHIS = "A1 PERCENT OF HISPANICS IN CLASS-AM"
      A1APMIN = "A1 PERCENT OF MINORITIES IN CLASS-AM"
      A1PPBLK = "A1 PERCENT OF BLACKS IN CLASS-PM"
      A1PPHIS = "A1 PERCENT OF HISPANICS IN CLASS-PM"
      A1PPMIN = "A1 PERCENT OF MINORITIES IN CLASS-PM"
      A1DPBLK = "A1 PERCENT OF BLACKS IN CLASS-AD"
      A1DPHIS = "A1 PERCENT OF HISPANICS IN CLASS-AD"
      A1DPMIN = "A1 PERCENT OF MINORITIES IN CLASS-AD"
      B1AGE = "B1 TEACHER'S AGE"
      A1AHRSDA = "A1 Q1 NUMBER OF CLASS HOURS PER DAY-AM"
      A1ADYSWK = "A1 Q2 NUMBER OF DAYS PER WEEK-AM"
      A1AREGK = "A1 Q3A TCH REGULAR 1-YR KINDERGARTEN-AM"
      A1A2YRK1 = "A1 Q3B TEACHES 1ST YR OF 2-YR K-AM"
      A1A2YRK2 = "A1 Q3C TEACHES 2ND YR OF 2-YR K-AM"
      A1ATRNK = "A1 Q3D TCH TRANSITIONAL KINDERGARTEN-AM"
      A1APR1ST = "A1 Q3E TEACHES PRE-1ST GRADE AFTER K-AM"
      A1AUNGR = "A1 Q3F TEACHES UNGRADED CLASS-AM"
      A1AMULGR = "A1 Q3G TEACHES MULTIGRADE CLASS-AM"
      A1ATPREK = "A1 Q4A TCH PREKINDERGARTEN LEVELS-AM"
      A1ATTRNK = "A1 Q4B TCH TRANSITIONAL KINDERGARTEN-AM"
      A1ATREGK = "A1 Q4C TEACHES REGULAR KINDERGARTEN-AM"
      A1ATPRE1 = "A1 Q4D TCH PRE-1ST GRADE LEVEL-AM"
      A1AT1ST = "A1 Q4E TCH 1ST GRADE LEVEL-AM"
      A1AT2ND = "A1 Q4F TCH 2ND GRADE LEVEL-AM"
      A1AT3RD = "A1 Q4G TCH 3RD GRADE OR HIGHER LEVEL-AM"
      A1A3YROL = "A1 Q5A HOW MANY 3-YEAR-OLDS IN CLASS-AM"
      A1A4YROL = "A1 Q5B HOW MANY 4-YEAR-OLDS IN CLASS-AM"
      A1A5YROL = "A1 Q5C HOW MANY 5-YEAR-OLDS IN CLASS-AM"
      A1A6YROL = "A1 Q5D HOW MANY 6-YEAR-OLDS IN CLASS-AM"
      A1A7YROL = "A1 Q5E HOW MANY 7-YEAR-OLDS IN CLASS-AM"
      A1A8YROL = "A1 Q5F HOW MANY 8-YEAR-OLDS IN CLASS-AM"
      A1A9YROL = "A1 Q5G HOW MANY 9-YEAR-OLDS IN CLASS-AM"
      A1ATOTAG = "A1 Q5H TOTAL CLASS ENROLLMENT (AGE)-AM"
      A1AASIAN = "A1 Q6A # OF ASIAN/PACIFIC ISLANDERS-AM"
      A1AHISP = "A1 Q6B # OF HISPANICS (ALL RACES)-AM"
      A1ABLACK = "A1 Q6C # OF NON-HISPANIC BLACKS-AM"
      A1AWHITE = "A1 Q6D # OF NON-HISPANIC WHITES-AM"
      A1AAMRIN = "A1 Q6E # OF AMERICAN INDIANS-AM"
      A1ARACEO = "A1 Q6F # OF STUDENTS OF OTHER RACES-AM"
      A1ATOTRA = "A1 Q6 TOTAL CLASS ENROLLMENT (RACES)-AM"
      A1ABOYS = "A1 Q7 NUMBER OF BOYS IN CLASS-AM"
      A1AGIRLS = "A1 Q7 NUMBER OF GIRLS IN CLASS-AM"
      A1APRESC = "A1 Q8 K ASSGNMNT BASED ON PRESCH EXP-AM"
      A1APCPRE = "A1 Q9 % CHILDREN W/ PRESCH RECORDS-AM"
      A1AREPK = "A1 Q10 NUMBER OF CHILDREN REPEATING K-AM"
      A1ALETT = "A1 Q11 # READ LETTERS SCH YR START-AM"
      A1AWORD = "A1 Q11 # READ WORDS SCH YR START-AM"
      A1ASNTNC = "A1 Q11 # READ SENTENCES SCH YR START-AM"
      A1ABEHVR = "A1 Q12 TCHR RATING OF CLASS BEHAVIOR-AM"
      A1AOTLAN = "A1 Q13 STUDENT SPEAK NON-ENG LANGUAGE-AM"
      A1ACSPNH = "A1 Q14A STUDENTS SPEAK SPANISH-AM"
      A1ACVTNM = "A1 Q14B STUDENTS SPEAK VIETNAMESE-AM"
      A1ACCHNS = "A1 Q14C STUDENTS SPEAK CHINESE-AM"
      A1ACJPNS = "A1 Q14D STUDENTS SPEAK JAPANESE-AM"
      A1ACKRN = "A1 Q14E STUDENTS SPEAK KOREAN-AM"
      A1ACFLPN = "A1 Q14F STUDENTS SPEAK FILIPINO LNG-AM"
      A1AOTASN = "A1 Q14G STUDENTS SPEAK OTHR ASIAN LNG-AM"
      A1AOTLNG = "A1 Q14H STUDENTS SPEAK ANOTHER LNG-AM"
      A1ALANOS = "A1 Q14H SPECIFY STUDENTS' OTHER LANG-AM"
      A1ALEP = "A1 Q15 LIMITED ENG PROFICIENCY (LEP)-AM"
      A1ANUMLE = "A1 Q16 NUMBER LEP STUDENTS IN CLASS-AM"
      A1ANOESL = "A1 Q17 LEP STUDENTS GET NO ESL-AM"
      A1AESLRE = "A1 Q17 LEP STUDENTS GET IN-CLASS ESL-AM"
      A1AESLOU = "A1 Q17 LEP STUDENTS GET OUTSIDE ESL-AM"
      A1ATNOOT = "A1 Q18A TCHRS SPEAK ONLY ENGLISH-AM"
      A1ATSPNH = "A1 Q18B TCHRS SPEAK SPANISH-AM"
      A1ATVTNM = "A1 Q18C TCHRS SPEAK VIETNAMESE-AM"
      A1ATCHNS = "A1 Q18D TCHRS SPEAK CHINESE-AM"
      A1ATJPNS = "A1 Q18E TCHRS SPEAK JAPANESE-AM"
      A1ATKRN = "A1 Q18F TCHRS SPEAK KOREAN-AM"
      A1ATFLPN = "A1 Q18G TCHRS SPEAK A FILIPINO LNG-AM"
      A1ATOTAS = "A1 Q18H TCHRS SPEAK OTHER ASIAN LNG-AM"
      A1ATOTLG = "A1 Q18I TCHRS SPEAK ANOTHER LANGUAGE-AM"
      A1ALEPOS = "A1 Q18I SPECIFY TCHRS' OTHER LANGUAGE-AM"
      A1ANONEN = "A1 Q19 DAILY TIME TCHRS SPEAK NON-ENG-AM"
      A1PHRSDA = "A1 Q1 NUMBER OF CLASS HOURS PER DAY-PM"
      A1PDYSWK = "A1 Q2 NUMBER OF DAYS PER WEEK-PM"
      A1PREGK = "A1 Q3A TCH REGULAR 1-YR KINDERGARTEN-PM"
      A1P2YRK1 = "A1 Q3B TEACHES 1ST YR OF 2-YR K-PM"
      A1P2YRK2 = "A1 Q3C TEACHES 2ND YR OF 2-YR K-PM"
      A1PTRNK = "A1 Q3D TCH TRANSITIONAL KINDERGARTEN-PM"
      A1PPR1ST = "A1 Q3E TEACHES PRE-1ST GRADE AFTER K-PM"
      A1PUNGR = "A1 Q3F TEACHES UNGRADED CLASS-PM"
      A1PMULGR = "A1 Q3G TEACHES MULTIGRADE CLASS-PM"
      A1PTPREK = "A1 Q4A TCH PREKINDERGARTEN LEVELS-PM"
      A1PTTRNK = "A1 Q4B TCH TRANSITIONAL KINDERGARTEN-PM"
      A1PTREGK = "A1 Q4C TEACHES REGULAR KINDERGARTEN-PM"
      A1PTPRE1 = "A1 Q4D TCH PRE-1ST GRADE LEVEL-PM"
      A1PT1ST = "A1 Q4E TCH 1ST GRADE LEVEL-PM"
      A1PT2ND = "A1 Q4F TCH 2ND GRADE LEVEL-PM"
      A1PT3RD = "A1 Q4G TCH 3RD GRADE OR HIGHER LEVEL-PM"
      A1P3YROL = "A1 Q5A HOW MANY 3-YEAR-OLDS IN CLASS-PM"
      A1P4YROL = "A1 Q5B HOW MANY 4-YEAR-OLDS IN CLASS-PM"
      A1P5YROL = "A1 Q5C HOW MANY 5-YEAR-OLDS IN CLASS-PM"
      A1P6YROL = "A1 Q5D HOW MANY 6-YEAR-OLDS IN CLASS-PM"
      A1P7YROL = "A1 Q5E HOW MANY 7-YEAR-OLDS IN CLASS-PM"
      A1P8YROL = "A1 Q5F HOW MANY 8-YEAR-OLDS IN CLASS-PM"
      A1P9YROL = "A1 Q5G HOW MANY 9-YEAR-OLDS IN CLASS-PM"
      A1PTOTAG = "A1 Q5H TOTAL CLASS ENROLLMENT (AGE)-PM"
      A1PASIAN = "A1 Q6A # OF ASIAN/PACIFIC ISLANDERS-PM"
      A1PHISP = "A1 Q6B # OF HISPANICS (ALL RACES)-PM"
      A1PBLACK = "A1 Q6C # OF NON-HISPANIC BLACKS-PM"
      A1PWHITE = "A1 Q6D # OF NON-HISPANIC WHITES-PM"
      A1PAMRIN = "A1 Q6E # OF AMERICAN INDIANS-PM"
      A1PRACEO = "A1 Q6F # OF STUDENTS OF OTHER RACES-PM"
      A1PTOTRA = "A1 Q6 TOTAL CLASS ENROLLMENT (RACES)-PM"
      A1PBOYS = "A1 Q7 NUMBER OF BOYS IN CLASS-PM"
      A1PGIRLS = "A1 Q7 NUMBER OF GIRLS IN CLASS-PM"
      A1PPRESC = "A1 Q8 K ASSGNMNT BASED ON PRESCH EXP-PM"
      A1PPCPRE = "A1 Q9 % CHILDREN W/ PRESCH RECORDS-PM"
      A1PREPK = "A1 Q10 NUMBER OF CHILDREN REPEATING K-PM"
      A1PLETT = "A1 Q11 # READ LETTERS SCH YR START-PM"
      A1PWORD = "A1 Q11 # READ WORDS SCH YR START-PM"
      A1PSNTNC = "A1 Q11 # READ SENTENCES SCH YR START-PM"
      A1PBEHVR = "A1 Q12 TCHR RATING OF CLASS BEHAVIOR-PM"
      A1POTLAN = "A1 Q13 STUDENT SPEAK NON-ENG LANGUAGE-PM"
      A1PCSPNH = "A1 Q14A STUDENTS SPEAK SPANISH-PM"
      A1PCVTNM = "A1 Q14B STUDENTS SPEAK VIETNAMESE-PM"
      A1PCCHNS = "A1 Q14C STUDENTS SPEAK CHINESE-PM"
      A1PCJPNS = "A1 Q14D STUDENTS SPEAK JAPANESE-PM"
      A1PCKRN = "A1 Q14E STUDENTS SPEAK KOREAN-PM"
      A1PCFLPN = "A1 Q14F STUDENTS SPEAK FILIPINO LNG-PM"
      A1POTASN = "A1 Q14G STUDENTS SPEAK OTHR ASIAN LNG-PM"
      A1POTLNG = "A1 Q14H STUDENTS SPEAK ANOTHER LNG-PM"
      A1PLANOS = "A1 Q14H SPECIFY STUDENTS' OTHER LANG-PM"
      A1PLEP = "A1 Q15 LIMITED ENG PROFICIENCY (LEP)-PM"
      A1PNUMLE = "A1 Q16 NUMBER LEP STUDENTS IN CLASS-PM"
      A1PNOESL = "A1 Q17 LEP STUDENTS GET NO ESL-PM"
      A1PESLRE = "A1 Q17 LEP STUDENTS GET IN-CLASS ESL-PM"
      A1PESLOU = "A1 Q17 LEP STUDENTS GET OUTSIDE ESL-PM"
      A1PTNOOT = "A1 Q18A TCHRS SPEAK ONLY ENGLISH-PM"
      A1PTSPNH = "A1 Q18B TCHRS SPEAK SPANISH-PM"
      A1PTVTNM = "A1 Q18C TCHRS SPEAK VIETNAMESE-PM"
      A1PTCHNS = "A1 Q18D TCHRS SPEAK CHINESE-PM"
      A1PTJPNS = "A1 Q18E TCHRS SPEAK JAPANESE-PM"
      A1PTKRN = "A1 Q18F TCHRS SPEAK KOREAN-PM"
      A1PTFLPN = "A1 Q18G TCHRS SPEAK A FILIPINO LNG-PM"
      A1PTOTAS = "A1 Q18H TCHRS SPEAK OTHER ASIAN LNG-PM"
      A1PTOTLG = "A1 Q18I TCHRS SPEAK ANOTHER LANGUAGE-PM"
      A1PLEPOS = "A1 Q18I SPECIFY TCHRS' OTHER LANGUAGE-PM"
      A1PNONEN = "A1 Q19 DAILY TIME TCHRS SPEAK NON-ENG-PM"
      A1DHRSDA = "A1 Q1 NUMBER OF CLASS HOURS PER DAY-AD"
      A1DDYSWK = "A1 Q2 NUMBER OF DAYS PER WEEK-AD"
      A1DREGK = "A1 Q3A TCH REGULAR 1-YR KINDERGARTEN-AD"
      A1D2YRK1 = "A1 Q3B TEACHES 1ST YR OF 2-YR K-AD"
      A1D2YRK2 = "A1 Q3C TEACHES 2ND YR OF 2-YR K-AD"
      A1DTRNK = "A1 Q3D TCH TRANSITIONAL KINDERGARTEN-AD"
      A1DPR1ST = "A1 Q3E TEACHES PRE-1ST GRADE AFTER K-AD"
      A1DUNGR = "A1 Q3F TEACHES UNGRADED CLASS-AD"
      A1DMULGR = "A1 Q3G TEACHES MULTIGRADE CLASS-AD"
      A1DTPREK = "A1 Q4A TCH PREKINDERGARTEN LEVELS-AD"
      A1DTTRNK = "A1 Q4B TCH TRANSITIONAL KINDERGARTEN-AD"
      A1DTREGK = "A1 Q4C TEACHES REGULAR KINDERGARTEN-AD"
      A1DTPRE1 = "A1 Q4D TCH PRE-1ST GRADE LEVEL-AD"
      A1DT1ST = "A1 Q4E TCH 1ST GRADE LEVEL-AD"
      A1DT2ND = "A1 Q4F TCH 2ND GRADE LEVEL-AD"
      A1DT3RD = "A1 Q4G TCH 3RD GRADE OR HIGHER LEVEL-AD"
      A1D3YROL = "A1 Q5A HOW MANY 3-YEAR-OLDS IN CLASS-AD"
      A1D4YROL = "A1 Q5B HOW MANY 4-YEAR-OLDS IN CLASS-AD"
      A1D5YROL = "A1 Q5C HOW MANY 5-YEAR-OLDS IN CLASS-AD"
      A1D6YROL = "A1 Q5D HOW MANY 6-YEAR-OLDS IN CLASS-AD"
      A1D7YROL = "A1 Q5E HOW MANY 7-YEAR-OLDS IN CLASS-AD"
      A1D8YROL = "A1 Q5F HOW MANY 8-YEAR-OLDS IN CLASS-AD"
      A1D9YROL = "A1 Q5G HOW MANY 9-YEAR-OLDS IN CLASS-AD"
      A1DTOTAG = "A1 Q5H TOTAL CLASS ENROLLMENT (AGE)-AD"
      A1DASIAN = "A1 Q6A # OF ASIAN/PACIFIC ISLANDERS-AD"
      A1DHISP = "A1 Q6B # OF HISPANICS (ALL RACES)-AD"
      A1DBLACK = "A1 Q6C # OF NON-HISPANIC BLACKS-AD"
      A1DWHITE = "A1 Q6D # OF NON-HISPANIC WHITES-AD"
      A1DAMRIN = "A1 Q6E # OF AMERICAN INDIANS-AD"
      A1DRACEO = "A1 Q6F # OF STUDENTS OF OTHER RACES-AD"
      A1DTOTRA = "A1 Q6 TOTAL CLASS ENROLLMENT (RACES)-AD"
      A1DBOYS = "A1 Q7 NUMBER OF BOYS IN CLASS-AD"
      A1DGIRLS = "A1 Q7 NUMBER OF GIRLS IN CLASS-AD"
      A1DPRESC = "A1 Q8 K ASSGNMNT BASED ON PRESCH EXP-AD"
      A1DPCPRE = "A1 Q9 % CHILDREN W/ PRESCH RECORDS-AD"
      A1DREPK = "A1 Q10 NUMBER OF CHILDREN REPEATING K-AD"
      A1DLETT = "A1 Q11 # READ LETTERS SCH YR START-AD"
      A1DWORD = "A1 Q11 # READ WORDS SCH YR START-AD"
      A1DSNTNC = "A1 Q11 # READ SENTENCES SCH YR START-AD"
      A1DBEHVR = "A1 Q12 TCHR RATING OF CLASS BEHAVIOR-AD"
      A1DOTLAN = "A1 Q13 STUDENT SPEAK NON-ENG LANGUAGE-AD"
      A1DCSPNH = "A1 Q14A STUDENTS SPEAK SPANISH-AD"
      A1DCVTNM = "A1 Q14B STUDENTS SPEAK VIETNAMESE-AD"
      A1DCCHNS = "A1 Q14C STUDENTS SPEAK CHINESE-AD"
      A1DCJPNS = "A1 Q14D STUDENTS SPEAK JAPANESE-AD"
      A1DCKRN = "A1 Q14E STUDENTS SPEAK KOREAN-AD"
      A1DCFLPN = "A1 Q14F STUDENTS SPEAK FILIPINO LNG-AD"
      A1DOTASN = "A1 Q14G STUDENTS SPEAK OTHR ASIAN LNG-AD"
      A1DOTLNG = "A1 Q14H STUDENTS SPEAK ANOTHER LNG-AD"
      A1DLANOS = "A1 Q14H SPECIFY STUDENTS' OTHER LANG-AD"
      A1DLEP = "A1 Q15 LIMITED ENG PROFICIENCY (LEP)-AD"
      A1DNUMLE = "A1 Q16 NUMBER LEP STUDENTS IN CLASS-AD"
      A1DNOESL = "A1 Q17 LEP STUDENTS GET NO ESL-AD"
      A1DESLRE = "A1 Q17 LEP STUDENTS GET IN-CLASS ESL-AD"
      A1DESLOU = "A1 Q17 LEP STUDENTS GET OUTSIDE ESL-AD"
      A1DTNOOT = "A1 Q18A TCHRS SPEAK ONLY ENGLISH-AD"
      A1DTSPNH = "A1 Q18B TCHRS SPEAK SPANISH-AD"
      A1DTVTNM = "A1 Q18C TCHRS SPEAK VIETNAMESE-AD"
      A1DTCHNS = "A1 Q18D TCHRS SPEAK CHINESE-AD"
      A1DTJPNS = "A1 Q18E TCHRS SPEAK JAPANESE-AD"
      A1DTKRN = "A1 Q18F TCHRS SPEAK KOREAN-AD"
      A1DTFLPN = "A1 Q18G TCHRS SPEAK A FILIPINO LNG-AD"
      A1DTOTAS = "A1 Q18H TCHRS SPEAK OTHER ASIAN LNG-AD"
      A1DTOTLG = "A1 Q18I TCHRS SPEAK ANOTHER LANGUAGE-AD"
      A1DLEPOS = "A1 Q18I SPECIFY TCHRS' OTHER LANGUAGE-AD"
      A1DNONEN = "A1 Q19 DAILY TIME TCHRS SPEAK NON-ENG-AD"
      A1COMPMM = "A1 Q20 DATE COMPLETED: MONTH"
      A1COMPDD = "A1 Q20 DATE COMPLETED: DAY"
      A1COMPYY = "A1 Q20 DATE COMPLETED: YEAR"
      B1WHLCLS = "B1 Q1A TCHR-DIRECTED WHOLE CLASS ACTIVTS"
      B1SMLGRP = "B1 Q1B TCHR-DIRECTED SMALL GROUP ACTIVTS"
      B1INDVDL = "B1 Q1C TCHR-DIRECTED INDIVIDUAL ACTIVTS"
      B1CHCLDS = "B1 Q1D CHILD-SELECTED ACTIVITIES"
      B1READAR = "B1 Q2A READING AREA WITH BOOKS"
      B1LISTNC = "B1 Q2B LISTENING CENTER"
      B1WRTCNT = "B1 Q2C WRITING CENTER OR AREA"
      B1PCKTCH = "B1 Q2D POCKET CHART OR FLANNEL"
      B1MATHAR = "B1 Q2E MATH AREA WITH MANIPULA"
      B1PLAYAR = "B1 Q2F AREA FOR PUZZLES/BLOCKS"
      B1WATRSA = "B1 Q2G WATER OR SAND TABLE"
      B1COMPAR = "B1 Q2H COMPUTER AREA"
      B1SCIAR = "B1 Q2I SCIENCE OR NATURE AREA"
      B1DRAMAR = "B1 Q2J DRAMATIC PLAY AREA"
      B1ARTARE = "B1 Q2K ART AREA"
      B1TOCLAS = "B1 Q3A EVAL CHILD RELATIVE TO CLASS"
      B1TOSTND = "B1 Q3B EVAL CHILD RELATIVE TO STANDARDS"
      B1IMPRVM = "B1 Q3C EVAL CHILD'S IMPROVEMENT/PROGRESS"
      B1EFFO = "B1 Q3D EVAL CHILD'S EFFORT"
      B1CLASPA = "B1 Q3E EVAL CHILD'S CLASS PARTICIPATION"
      B1ATTND = "B1 Q3F EVAL CHILD'S DAILY ATTENDANCE"
      B1BEHVR = "B1 Q3G EVAL CHILD'S CLASS BEHAVIOR"
      B1COPRTV = "B1 Q3H EVAL CHILD'S COOPERATIVENESS"
      B1FLLWDR = "B1 Q3I EVAL ABILITY TO TAKE DIRECTIONS"
      B1OTMT = "B1 Q3J EVAL USING OTHER METHOD"
      B1EVAL = "B1 Q4 TEACHER’S EVALUATION PRACTICES"
      B1PAIDPR = "B1 Q5 TEACHER'S PAID PREP HOURS PER WEEK"
      B1NOPAYP = "B1 Q6 TEACHER’S UNPAID PREP HOURS A WEEK"
      B1FNSHT = "B1 Q7A K-READINESS: FINISHES TASKS"
      B1CNT20 = "B1 Q7B K-READINESS: COUNTS TO 20 OR MORE"
      B1SHARE = "B1 Q7C K-READINESS: TAKES TURNS / SHARES"
      B1PRBLMS = "B1 Q7D K-READINESS: PRBLM SOLVING SKILLS"
      B1PENCIL = "B1 Q7E K-READINESS: USES PENCIL, BRUSHES"
      B1NOTDSR = "B1 Q7F K-READINESS: IS NOT DISRUPTIVE"
      B1ENGLAN = "B1 Q7G K-READINESS: KNOWS ENGLISH"
      B1SENSTI = "B1 Q7H K-READINESS: SENSITIVE TO OTHERS"
      B1SITSTI = "B1 Q7I K-READINESS: SITS STILL AND ALERT"
      B1ALPHBT = "B1 Q7J K-READINESS: KNOWS MOST ALPHABET"
      B1FOLWDR = "B1 Q7K K-READINESS: FOLLOW DIRECTIONS"
      B1IDCOLO = "B1 Q7L K-READINESS: NAMES COLORS, SHAPES"
      B1COMM = "B1 Q7M K-READINESS: TELLS NEEDS/THOUGHTS"
      B1INFOHO = "B1 Q8A KEEP HOME INFORMED OF PROGRAMS"
      B1INKNDR = "B1 Q8B GET PRESCHOOLERS IN K CLASS"
      B1SHRTN = "B1 Q8C SHORTEN SCHOOLDAYS AT YEAR BEGIN"
      B1VSTK = "B1 Q8D SEE CHILD/PARENT AT K BEFORE"
      B1HMEVST = "B1 Q8E SEE HOMES BEFORE YEAR BEGINNING"
      B1PRNTOR = "B1 Q8F GIVE PARENTS ORIENTATION AT BEGIN"
      B1OTTRAN = "B1 Q8G GIVE OTHER TRANSITION ACTIVITIES"
      B1ATNDPR = "B1 Q9A PRESCHOOL GOOD FOR KINDERGARTEN"
      B1FRMLIN = "B1 Q9B PRESCH RD/MATH GOOD FOR SCHOOL"
      B1ALPHBF = "B1 Q9C HAVE CHILD KNOW ALPHABET BEFORE K"
      B1LRNREA = "B1 Q9D CHILD SHOULD LEARN READING IN K"
      B1TCHPRN = "B1 Q9E HELP PARENT TEACH CHILD TO READ"
      B1PRCTWR = "B1 Q9F PARENT GIVE CHILD HOME SCHOOLWORK"
      B1HMWRK = "B1 Q9G K STUDENTS GET DAILY HOMEWORK"
      B1READAT = "B1 Q9H PARENT MUST READ, PLAY WITH CHILD"
      B1SCHSPR = "B1 Q10A STAFF HAVE SCHOOL SPIRIT"
      B1MISBHV = "B1 Q10B CHILD MISBEHAVIOR AFFECTS TCHNG"
      B1NOTCAP = "B1 Q10C CHILDREN INCAPABLE OF LEARNING"
      B1ACCPTD = "B1 Q10D STAFF ACCEPT ME AS COLLEAGUE"
      B1CNTNLR = "B1 Q10E STAFF LEARN/SEEK NEW IDEAS"
      B1PAPRWR = "B1 Q10F PAPERWORK INTERFERES W/ TEACHING"
      B1PSUPP = "B1 Q10G PARENTS SUPPORT SCHOOL STAFF"
      B1SCHPLC = "B1 Q11 HOW MUCH TEACHERS IMPACT POLICY"
      B1CNTRLC = "B1 Q12 HOW MUCH TCHRS CONTROL CURRICULUM"
      B1STNDLO = "B1 Q13A ACADEMIC STANDARDS TOO LOW"
      B1MISSIO = "B1 Q13B FACULTY ON MISSION"
      B1ALLKNO = "B1 Q13C SCH ADMIN COMMUNICATES VISION"
      B1PRESSU = "B1 Q13D SCH ADMIN HANDLES OUTSD PRESSURE"
      B1PRIORI = "B1 Q13E SCH ADMIN PRIORITIZES WELL"
      B1ENCOUR = "B1 Q13F SCH ADMIN ENCOURAGES STAFF"
      B1ENJOY = "B1 Q14A TEACHER ENJOYS PRESENT TCHNG JOB"
      B1MKDIFF = "B1 Q14B TCHR MAKES DIFF IN CHDN LIVES"
      B1TEACH = "B1 Q14C TEACHER WOULD CHOOSE TCHNG AGAIN"
      B1TGEND = "B1 Q15 TEACHER'S GENDER"
      B1YRBORN = "B1 Q16 TEACHER'S YEAR OF BIRTH"
      B1HISP = "B1 Q17 HISPANIC OR LATINO"
      B1RACE1 = "B1 Q18 NATIVE AMERICAN OR PACIF ISLANDER"
      B1RACE2 = "B1 Q18 ASIAN"
      B1RACE3 = "B1 Q18 BLACK OR AFRICAN AMERICAN"
      B1RACE4 = "B1 Q18 NATIVE HAWAIIAN OR OTHER PAC IS"
      B1RACE5 = "B1 Q18 WHITE"
      B1YRSPRE = "B1 Q19A YRS TEACHER TAUGHT PRESCHOOL"
      B1YRSKIN = "B1 Q19B YRS TEACHER TAUGHT KINDERGARTEN"
      B1YRSFST = "B1 Q19C YRS TEACHER TAUGHT FIRST GRADE"
      B1YRS2T5 = "B1 Q19D YRS TEACHER TAUGHT 2 TO 5 GRADE"
      B1YRS6PL = "B1 Q19E YRS TEACHER TAUGHT 6 GRADE OR UP"
      B1YRSESL = "B1 Q19F YRS TEACHER TAUGHT ESL"
      B1YRSBIL = "B1 Q19G YRS TEACHER TAUGHT BILINGUAL ED"
      B1YRSSPE = "B1 Q19H YRS TEACHER TAUGHT SPECIAL ED"
      B1YRSPE = "B1 Q19I YRS TEACHER TAUGHT PHYSICAL ED"
      B1YRSART = "B1 Q19J YRS TEACHER TAUGHT ART OR MUSIC"
      B1YRSCH = "B1 Q20 YRS TEACHER TAUGHT AT THIS SCHOOL"
      B1HGHSTD = "B1 Q21 HIGHEST ED LEVEL TEACHER ACHIEVED"
      B1EARLY = "B1 Q22A TEACHERS EARLY EDUCATION COURSES"
      B1ELEM = "B1 Q22B TEACHER'S ELEMENTARY ED COURSES"
      B1SPECED = "B1 Q22C TEACHER'S SPECIAL ED COURSES"
      B1ESL = "B1 Q22D TEACHER'S ESL COLLEGE COURSES"
      B1DEVLP = "B1 Q22E TEACHERS CHD DEVELOPMENT COURSES"
      B1MTHDRD = "B1 Q22F TEACHER'S TEACH-READING COURSES"
      B1MTHDMA = "B1 Q22G TEACHER'S TEACH-MATH COURSES"
      B1MTHDSC = "B1 Q22F TEACHER'S TEACH-SCIENCE COURSES"
      B1TYPCER = "B1 Q23 TEACHER'S CERTIFICATION TYPE"
      B1ELEMCT = "B1 Q24A CERTIFICATION: ELEMENTARY ED"
      B1ERLYCT = "B1 Q24B CERTIFICATION: EARLY EDUCATION"
      B1OTHCRT = "B1 Q24C CERTIFICATION: OTHER (SPECIFY)"
      B1MMCOMP = "B1 Q25 DATE QUESTIONNAIRE ENDED: MONTH"
      B1DDCOMP = "B1 Q25 DATE QUESTIONNAIRE ENDED: DAY"
      B1YYCOMP = "B1 Q25 DATE QUESTIONNAIRE ENDED: YEAR"
      A2ANEW = "A2 Q1A NUMBER OF NEW CHILDREN-AM"
      A2ALEFT = "A2 Q1B NUMBER OF CHILDREN WHO LEFT-AM"
      A2AGIFT = "A2 Q2A # CLASSIFIED AS GFTED/TALENTED-AM"
      A2APRTGF = "A2 Q2B # TAKE PART IN GIFTED/TALENTED-AM"
      A2ARDBLO = "A2 Q2C # READING BELOW GRADE LEVEL-AM"
      A2AMTHBL = "A2 Q2D # MATH SKILLS BELOW GRADE LVL-AM"
      A2ATARDY = "A2 Q2E TIMES TARDY ON AVERAGE DAY-AM"
      A2AABSEN = "A2 Q2F TIMES ABSENT ON AVERAGE DAY-AM"
      A2ADISAB = "A2 Q3A NUMBER WITH DISABILITIES-AM"
      A2AIMPAI = "A2 Q4A COMMUNICATION IMPAIRMENTS-AM"
      A2ALRNDI = "A2 Q4B LEARNING DISABILITIES-AM"
      A2AEMPRB = "A2 Q4C SERIOUS EMOTIONAL PROBLEMS-AM"
      A2ARETAR = "A2 Q4D MENTAL RETARDATION-AM"
      A2ADELAY = "A2 Q4E DEVELOPMENTAL DELAY-AM"
      A2AVIS = "A2 Q4F VISION IMPAIRMENTS-AM"
      A2AHEAR = "A2 Q4G HEARING IMPAIRMENTS-AM"
      A2AORTHO = "A2 Q4H ORTHOPEDIC IMPAIRMENTS-AM"
      A2AOTHER = "A2 Q4I OTHER HEALTH IMPAIRMENTS-AM"
      A2AMULTI = "A2 Q4J MULTIPLE DISABILITIES-AM"
      A2AAUTSM = "A2 Q4K AUTISM-AM"
      A2ATRAUM = "A2 Q4L TRAUMATIC BRAIN INJURIES-AM"
      A2ADEAF = "A2 Q4M DEAFNESS AND BLINDNESS-AM"
      A2AOTDIS = "A2 Q4N OTHER SPECIFY DISABILITIES-AM"
      A2ASPCIA = "A2 Q5A SPECIAL DISABILITY SERVICES-AM"
      A2AIEP = "A2 Q5B IEP FOR CHILDREN W/ DISABILITY-AM"
      A2ASC504 = "A2 Q5C CHILDREN W/ SECTION 504 PLAN-AM"
      A2AMORE = "A2 Q5D NOT RECEIVING ENOUGH HELP-AM"
      A2ABEHVR = "A2 Q6 TCHR RATING OF CLASS BEHAVIOR-AM"
      A2AENGLS = "A2 Q7A ENGLISH LANGUAGE ONLY-AM"
      A2ACSPNH = "A2 Q7B STUDENTS SPEAK SPANISH-AM"
      A2ACVTNM = "A2 Q7C STUDENTS SPEAK VIETNAMESE-AM"
      A2ACCHNS = "A2 Q7D STUDENTS SPEAK CHINESE-AM"
      A2ACJPNS = "A2 Q7E STUDENTS SPEAK JAPANESE-AM"
      A2ACKRN = "A2 Q7F STUDENTS SPEAK KOREAN-AM"
      A2ACFLPN = "A2 Q7G STUDENTS SPEAK FILIPINO LNG-AM"
      A2AOTASN = "A2 Q7H STUDENTS SPEAK OTHER ASIAN LNG-AM"
      A2AOTLNG = "A2 Q7I STUDENTS SPEAK ANOTHER LNG-AM"
      A2ALNGOS = "A2 Q7I LANGUAGE OF INSTRUCTION - OTHER-AM"
      A2PNEW = "A2 Q1A NUMBER OF NEW CHILDREN-PM"
      A2PLEFT = "A2 Q1B NUMBER OF CHILDREN WHO LEFT-PM"
      A2PGIFT = "A2 Q2A # CLASSIFIED AS GFTED/TALENTED-PM"
      A2PPRTGF = "A2 Q2B # TAKE PART IN GIFTED/TALENTED-PM"
      A2PRDBLO = "A2 Q2C # READING BELOW GRADE LEVEL-PM"
      A2PMTHBL = "A2 Q2D # MATH SKILLS BELOW GRADE LVL-PM"
      A2PTARDY = "A2 Q2E TIMES TARDY ON AVERAGE DAY-PM"
      A2PABSEN = "A2 Q2F TIMES ABSENT ON AVERAGE DAY-PM"
      A2PDISAB = "A2 Q3A NUMBER WITH DISABILITIES-PM"
      A2PIMPAI = "A2 Q4A COMMUNICATION IMPAIRMENTS-PM"
      A2PLRNDI = "A2 Q4B LEARNING DISABILITIES-PM"
      A2PEMPRB = "A2 Q4C SERIOUS EMOTIONAL PROBLEMS-PM"
      A2PRETAR = "A2 Q4D MENTAL RETARDATION-PM"
      A2PDELAY = "A2 Q4E DEVELOPMENTAL DELAY-PM"
      A2PVIS = "A2 Q4F VISION IMPAIRMENTS-PM"
      A2PHEAR = "A2 Q4G HEARING IMPAIRMENTS-PM"
      A2PORTHO = "A2 Q4H ORTHOPEDIC IMPAIRMENTS-PM"
      A2POTHER = "A2 Q4I OTHER HEALTH IMPAIRMENTS-PM"
      A2PMULTI = "A2 Q4J MULTIPLE DISABILITIES-PM"
      A2PAUTSM = "A2 Q4K AUTISM-PM"
      A2PTRAUM = "A2 Q4L TRAUMATIC BRAIN INJURIES-PM"
      A2PDEAF = "A2 Q4M DEAFNESS AND BLINDNESS-PM"
      A2POTDIS = "A2 Q4N OTHER SPECIFY DISABILITIES-PM"
      A2PSPCIA = "A2 Q5A SPECIAL DISABILITY SERVICES-PM"
      A2PIEP = "A2 Q5B IEP FOR CHILDREN W/ DISABILITY-PM"
      A2PSC504 = "A2 Q5C CHILDREN W/ SECTION 504 PLAN-PM"
      A2PMORE = "A2 Q5D NOT RECEIVING ENOUGH HELP-PM"
      A2PBEHVR = "A2 Q6 TCHR RATING OF CLASS BEHAVIOR-PM"
      A2PENGLS = "A2 Q7A ENGLISH LANGUAGE ONLY-PM"
      A2PCSPNH = "A2 Q7B STUDENTS SPEAK SPANISH-PM"
      A2PCVTNM = "A2 Q7C STUDENTS SPEAK VIETNAMESE-PM"
      A2PCCHNS = "A2 Q7D STUDENTS SPEAK CHINESE-PM"
      A2PCJPNS = "A2 Q7E STUDENTS SPEAK JAPANESE-PM"
      A2PCKRN = "A2 Q7F STUDENTS SPEAK KOREAN-PM"
      A2PCFLPN = "A2 Q7G STUDENTS SPEAK FILIPINO LNG-PM"
      A2POTASN = "A2 Q7H STUDENTS SPEAK OTHER ASIAN LNG-PM"
      A2POTLNG = "A2 Q7I STUDENTS SPEAK ANOTHER LNG-PM"
      A2PLNGOS = "A2 Q7I LANGUAGE OF INSTRUCTION - OTHER-PM"
      A2DNEW = "A2 Q1A NUMBER OF NEW CHILDREN-AD"
      A2DLEFT = "A2 Q1B NUMBER OF CHILDREN WHO LEFT-AD"
      A2DGIFT = "A2 Q2A # CLASSIFIED AS GFTED/TALENTED-AD"
      A2DPRTGF = "A2 Q2B # TAKE PART IN GIFTED/TALENTED-AD"
      A2DRDBLO = "A2 Q2C # READING BELOW GRADE LEVEL-AD"
      A2DMTHBL = "A2 Q2D # MATH SKILLS BELOW GRADE LVL-AD"
      A2DTARDY = "A2 Q2E TIMES TARDY ON AVERAGE DAY-AD"
      A2DABSEN = "A2 Q2F TIMES ABSENT ON AVERAGE DAY-AD"
      A2DDISAB = "A2 Q3A NUMBER WITH DISABILITIES-AD"
      A2DIMPAI = "A2 Q4A COMMUNICATION IMPAIRMENTS-AD"
      A2DLRNDI = "A2 Q4B LEARNING DISABILITIES-AD"
      A2DEMPRB = "A2 Q4C SERIOUS EMOTIONAL PROBLEMS-AD"
      A2DRETAR = "A2 Q4D MENTAL RETARDATION-AD"
      A2DDELAY = "A2 Q4E DEVELOPMENTAL DELAY-AD"
      A2DVIS = "A2 Q4F VISION IMPAIRMENTS-AD"
      A2DHEAR = "A2 Q4G HEARING IMPAIRMENTS-AD"
      A2DORTHO = "A2 Q4H ORTHOPEDIC IMPAIRMENTS-AD"
      A2DOTHER = "A2 Q4I OTHER HEALTH IMPAIRMENTS-AD"
      A2DMULTI = "A2 Q4J MULTIPLE DISABILITIES-AD"
      A2DAUTSM = "A2 Q4K AUTISM-AD"
      A2DTRAUM = "A2 Q4L TRAUMATIC BRAIN INJURIES-AD"
      A2DDEAF = "A2 Q4M DEAFNESS AND BLINDNESS-AD"
      A2DOTDIS = "A2 Q4N OTHER SPECIFY DISABILITIES-AD"
      A2DSPCIA = "A2 Q5A SPECIAL DISABILITY SERVICES-AD"
      A2DIEP = "A2 Q5B IEP FOR CHILDREN W/ DISABILITY-AD"
      A2DSC504 = "A2 Q5C CHILDREN W/ SECTION 504 PLAN-AD"
      A2DMORE = "A2 Q5D NOT RECEIVING ENOUGH HELP-AD"
      A2DBEHVR = "A2 Q6 TCHR RATING OF CLASS BEHAVIOR-AD"
      A2DENGLS = "A2 Q7A ENGLISH LANGUAGE ONLY-AD"
      A2DCSPNH = "A2 Q7B STUDENTS SPEAK SPANISH-AD"
      A2DCVTNM = "A2 Q7C STUDENTS SPEAK VIETNAMESE-AD"
      A2DCCHNS = "A2 Q7D STUDENTS SPEAK CHINESE-AD"
      A2DCJPNS = "A2 Q7E STUDENTS SPEAK JAPANESE-AD"
      A2DCKRN = "A2 Q7F STUDENTS SPEAK KOREAN-AD"
      A2DCFLPN = "A2 Q7G STUDENTS SPEAK FILIPINO LNG-AD"
      A2DOTASN = "A2 Q7H STUDENTS SPEAK OTHER ASIAN LNG-AD"
      A2DOTLNG = "A2 Q7I STUDENTS SPEAK ANOTHER LNG-AD"
      A2DLNGOS = "A2 Q7I LANGUAGE OF INSTRUCTION - OTHER-AD"
      A2WHLCLS = "A2 Q8A TCHR-DIRECTED WHOLE CLASS ACTIVTS"
      A2SMLGRP = "A2 Q8B TCHR-DIRECTED SMALL GROUP ACTIVTS"
      A2INDVDL = "A2 Q8C TCHR-DIRECTED INDIVIDUAL ACTIVTS"
      A2CHCLDS = "A2 Q8D CHILD-SELECTED ACTIVITIES"
      A2COMMTE = "A2 Q9 INTEGRATE TWO CURRICULUM AREAS"
      A2OFTRDL = "A2 Q10A HOW OFTEN READING AND LNG ART"
      A2TXRDLA = "A2 Q10A TIME FOR READING AND LNG ARTS"
      A2OFTMTH = "A2 Q10B HOW OFTEN MATHEMATICS"
      A2TXMTH = "A2 Q10B TIME FOR MATHEMATICS"
      A2OFTSOC = "A2 Q10C HOW OFTEN SOCIAL STUDIES"
      A2TXSOC = "A2 Q10C TIME FOR SOCIAL STUDIES"
      A2OFTSCI = "A2 Q10D HOW OFTEN SCIENCE"
      A2TXSCI = "A2 Q10D TIME FOR SCIENCE"
      A2OFTMUS = "A2 Q10E HOW OFTEN MUSIC"
      A2TXMUS = "A2 Q10E TIME FOR MUSIC"
      A2OFTART = "A2 Q10F HOW OFTEN ART"
      A2TXART = "A2 Q10F TIME FOR ART"
      A2OFTDAN = "A2 Q10G HOW OFTEN DANCE"
      A2TXDAN = "A2 Q10G TIME FOR DANCE"
      A2OFTHTR = "A2 Q10H HOW OFTEN THEATER"
      A2TXTHTR = "A2 Q10H TIME FOR THEATER"
      A2OFTFOR = "A2 Q10I HOW OFTEN FOREIGN LANGUAGE"
      A2TXFOR = "A2 Q10I TIME FOR FOREIGN LANGUAGE"
      A2OFTESL = "A2 Q10J HOW OFTEN ESL"
      A2TXESL = "A2 Q10J TIME FOR ESL"
      A2TXPE = "A2 Q11 TIMES PER WK PHYSICAL EDUCATION"
      A2TXSPEN = "A2 Q12 TIME PER DAY PHYSICAL ED"
      A2DYRECS = "A2 Q13 DAYS PER WEEK HAVE RECESS"
      A2TXRCE = "A2 Q14 TIMES PER DAY HAVE RECESS"
      A2LUNCH = "A2 Q15A TIME FOR LUNCH"
      A2RECESS = "A2 Q15B TIME FOR RECESS"
      A2DIVRD = "A2 Q16A ACHIEVEMENT GROUPS FOR READING"
      A2DIVMTH = "A2 Q16B ACHIEVEMENT GROUPS FOR MATH"
      A2NUMRD = "A2 Q17A NUMBER OF READING GROUPS"
      A2MINRD = "A2 Q17A MINUTES PER DAY FOR RDNG GROUPS"
      A2NUMTH = "A2 Q17B NUMBER OF MATH GROUPS"
      A2MINMTH = "A2 Q17B MINUTES PER DAY FOR MTH GROUPS"
      A2EXASIS = "A2 Q18A FREQUENCY EXTRA ASSISTANCE"
      A2MNEXTR = "A2 Q18A MINUTES EXTRA ASSISTANCE"
      A2AIDTUT = "A2 Q18B FREQUENCY TUTORED BY AIDE"
      A2MNAIDE = "A2 Q18B MINUTES TUTORED BY AIDE"
      A2SPECTU = "A2 Q18C FREQUENCY TUTORED BY SPECIALIST"
      A2MNSPEC = "A2 Q18C MINUTES TUTORED BY SPECIALIST"
      A2PULLOU = "A2 Q18D FREQUENCY PULL-OUT INSTRUCTION"
      A2MNPOIN = "A2 Q18D MINUTES PULL-OUT INSTRUCTION"
      A2OTASSI = "A2 Q18E FREQUENCY OTHER SPECIFY HELP"
      A2MNOSHP = "A2 Q18E MINUTES OTHER SPECIFY HELP"
      A2GOTOLI = "A2 Q19A FREQUENCY AT LIBRARY/MEDIA CTR"
      A2BORROW = "A2 Q19B FREQUENCY BORROW FROM LIBRARY"
      A2PDAIDE = "A2 Q20 NUMBER OF PAID AIDES"
      A2REGWRK = "A2 Q21A1 REGULAR AIDE WORKS W/CHILDREN"
      A2SPEDWK = "A2 Q21A2 SPECIAL AIDE WORKS W/CHILDREN"
      A2ESLWRK = "A2 Q21A3 ESL AIDE WORKS W/CHILDREN"
      A2REGNON = "A2 Q21B1 REGULAR AIDE OTHER TASKS"
      A2SPEDNO = "A2 Q21B2 SPECIAL AIDE OTHER TASKS"
      A2ESLNON = "A2 Q21B3 ESL AIDE OTHER TASKS"
      A2ALANG = "A2 Q22 AIDES FIRST LANGUAGE ENGLISH-AM"
      A2ASPK = "A2 Q23 HOW WELL AIDE SPEAKS ENGLISH-AM"
      A2ALVLED = "A2 Q24 AIDE(S) HIGHEST LEVEL ED-AM"
      A2ACERTF = "A2 Q25 CERTIFICATION OF AIDE-AM"
      A2PLANG = "A2 Q22 AIDES FIRST LANGUAGE ENGLISH-PM"
      A2PSPK = "A2 Q23 HOW WELL AIDE SPEAKS ENGLISH-PM"
      A2PLVLED = "A2 Q24 AIDE(S) HIGHEST LEVEL ED-PM"
      A2PCERTF = "A2 Q25 CERTIFICATION OF AIDE-PM"
      A2DLANG = "A2 Q22 AIDES FIRST LANGUAGE ENGLISH-AD"
      A2DSPK = "A2 Q23 HOW WELL AIDE SPEAKS ENGLISH-AD"
      A2DLVLED = "A2 Q24 AIDE(S) HIGHEST LEVEL ED-AD"
      A2DCERTF = "A2 Q25 CERTIFICATION OF AIDE-AD"
      A2TXTBK = "A2 Q26A ADEQUATE TEXTBOOKS"
      A2TRADBK = "A2 Q26B ADEQUATE TRADEBOOKS"
      A2WORKBK = "A2 Q26C ADEQUATE WORKBKS/PRACTICE SHEETS"
      A2MANIPU = "A2 Q26D ADEQUATE MANIPULATIVES"
      A2AUDIOV = "A2 Q26E ADEQUATE AUDIO-VISUAL EQUIPMENT"
      A2VIDEO = "A2 Q26F ADEQUATE VIDEOTAPES/FILMS"
      A2COMPEQ = "A2 Q26G ADEQUATE COMPUTER EQUIPMENT"
      A2SOFTWA = "A2 Q26H ADEQUATE COMPUTER SOFTWARE"
      A2PAPER = "A2 Q26I ADEQUATE PAPER AND PENCILS"
      A2DITTO = "A2 Q26J ADEQUATE DITTO/PHOTO COPIER"
      A2ART = "A2 Q26K ADEQUATE ART MATERIALS"
      A2INSTRM = "A2 Q26L ADEQUATE MUSICAL INSTRUMENTS"
      A2RECRDS = "A2 Q26M ADEQUATE MUSICAL RECORDINGS"
      A2LEPMAT = "A2 Q26N ADEQUATE MATERIALS FOR LEP"
      A2DISMAT = "A2 Q26O ADEQTE MTH FOR CHDN W/ DISABLTY"
      A2HEATAC = "A2 Q26P ADEQUATE HEAT/AIR-CONDITIONING"
      A2CLSSPC = "A2 Q26Q ADEQUATE CLASSROOM SPACE"
      A2FURNIT = "A2 Q26R ADEQUATE CHILD-SIZE FURNITURE"
      A2ARTMAT = "A2 Q27A FREQUENCY USE ART MATERIALS"
      A2MUSIC = "A2 Q27B FREQUENCY USE MUSIC INSTRUMENTS"
      A2COSTUM = "A2 Q27C FREQUENCY USE COSTUMES"
      A2COOK = "A2 Q27D FREQUENCY USE FOOD RELATED ITEMS"
      A2BOOKS = "A2 Q27E FREQUENCY USE NON-ENGLISH BOOK"
      A2VCR = "A2 Q27F FREQUENCY USE VCR"
      A2TVWTCH = "A2 Q27G FREQUENCY USE TV FOR PROGRAMS"
      A2PLAYER = "A2 Q27H FREQUENCY USE RECORD/TAPE/CD"
      A2EQUIPM = "A2 Q27I FREQUENCY USE SCIENCE EQUIPMENT"
      A2LERNLT = "A2 Q28A FREQUENCY WORK ON LETTER NAMES"
      A2PRACLT = "A2 Q28B FREQUENCY WRITING ALPHABET"
      A2NEWVOC = "A2 Q28C FREQUENCY NEW VOCABULARY"
      A2DICTAT = "A2 Q28D FREQUENCY DICTATE STORIES"
      A2PHONIC = "A2 Q28E FREQUENCY WORK ON PHONICS"
      A2SEEPRI = "A2 Q28F FREQUENCY STORY/SEE PRINT"
      A2NOPRNT = "A2 Q28G FREQUENCY STORY/DON'T SEE PRINT"
      A2RETELL = "A2 Q28H FREQUENCY RETELL STORIES"
      A2READLD = "A2 Q28I FREQUENCY READ ALOUD"
      A2BASAL = "A2 Q28J FREQUENCY BASAL READING TEXTS"
      A2SILENT = "A2 Q28K FREQUENCY READ SILENTLY"
      A2WRKBK = "A2 Q28L FREQUENCY WORK BOOKS/SHEETS"
      A2WRTWRD = "A2 Q28M FREQUENCY WRITE FROM DICTATION"
      A2INVENT = "A2 Q28N FREQ WRITE W/ INVENTED SPELLINGS"
      A2CHSBK = "A2 Q28O FREQUENCY CHOSE BOOKS TO READ"
      A2COMPOS = "A2 Q28P FREQUENCY WRITE STORIES/REPORT"
      A2DOPROJ = "A2 Q28Q FREQUENCY WORK RELATED TO BOOK"
      A2PUBLSH = "A2 Q28R FREQUENCY PUBLISH OWN WRITING"
      A2SKITS = "A2 Q28S FREQUENCY PERFORM PLAYS/SKITS"
      A2JRNL = "A2 Q28T FREQUENCY WRITE IN JOURNAL"
      A2TELLRS = "A2 Q28U FREQUENCY OF STORY TELLERS"
      A2MXDGRP = "A2 Q28V FREQUENCY MIXED LEVEL GROUPS"
      A2PRTUTR = "A2 Q28W FREQUENCY PEER TUTORING"
      A2CONVNT = "A2 Q29A CONVENTION OF PRINT"
      A2RCGNZE = "A2 Q29B ALPHABET AND LETTER RECOGNITION"
      A2MATCH = "A2 Q29C MATCHING LETTERS TO SOUNDS"
      A2WRTNME = "A2 Q29D WRITING OWN NAME"
      A2RHYMNG = "A2 Q29E RHYMING WORDS AND WORD FAMILIES"
      A2SYLLAB = "A2 Q29F READING MULTI-SYLLABLE WORDS"
      A2PREPOS = "A2 Q29G COMMON PREPOSITIONS"
      A2MAINID = "A2 Q29H IDENTIFY MAIN IDEA OF STORY"
      A2PREDIC = "A2 Q29I MAKE PREDICTIONS BASED ON TEXT"
      A2TEXTCU = "A2 Q29J USE CUES FOR COMPREHENSION"
      A2ORALID = "A2 Q29K COMMUNICATE IDEAS ORALLY"
      A2DRCTNS = "A2 Q29L FOLLOW COMPLEX DIRECTIONS"
      A2PNCTUA = "A2 Q29M USE CAPITALIZATION/PUNCTUATION"
      A2COMPSE = "A2 Q29N COMPOSE/WRITE COMPLETE SENTENCES"
      A2WRTSTO = "A2 Q29O STORY HAS BEGINNING/MIDDLE/END"
      A2SPELL = "A2 Q29P CONVENTIONAL SPELLING"
      A2VOCAB = "A2 Q29Q VOCABULARY"
      A2ALPBTZ = "A2 Q29R ALPHABETIZING"
      A2RDFLNT = "A2 Q29S READING ALOUD FLUENTLY"
      A2INVSPE = "A2 Q30 ENCOURAGE USE OF INVENTED SPELL"
      A2OUTLOU = "A2 Q31A FREQUENCY COUNT OUT LOUD"
      A2GEOMET = "A2 Q31B FREQ GEOMETRIC MANIPULATIVES"
      A2MANIPS = "A2 Q31C FREQ COUNTING MANIPULATIVES"
      A2MTHGME = "A2 Q31D FREQUENCY MATH-RELATED GAMES"
      A2CALCUL = "A2 Q31E FREQUENCY USE CALCULATOR"
      A2MUSMTH = "A2 Q31F FREQUENCY MUSIC TO LEARN MATH"
      A2CRTIVE = "A2 Q31G FREQ MOVEMENT TO LEARN MATH"
      A2RULERS = "A2 Q31H FREQ USE MEASURNG INSTRUMNTS"
      A2EXPMTH = "A2 Q31I FREQUENCY EXPLAIN/SOLVE MATH"
      A2CALEND = "A2 Q31J FREQ CALENDAR RELATED ACTIVITIES"
      A2MTHSHT = "A2 Q31K FREQUENCY DO MATH WORKSHEETS"
      A2MTHTXT = "A2 Q31L FREQUENCY USE MATH TEXTBOOKS"
      A2CHLKBD = "A2 Q31M FREQUENCY DO MATH ON CHALKBOARD"
      A2PRTNRS = "A2 Q31N FREQUENCY SOLVE MATH W/PARTNER"
      A2REALLI = "A2 Q31O FREQUENCY SOLVE REAL LIFE MATH"
      A2MXMATH = "A2 Q31P FREQUENCY MIXED GROUP MATH WORK"
      A2PEER = "A2 Q31Q FREQUENCY PEER TUTORING"
      A2QUANTI = "A2 Q32A RELATION BTWN NUMBER & QUANTITY"
      A21TO10 = "A2 Q32B WRITE NUMBERS ONE TO TEN"
      A22S5S10 = "A2 Q32C COUNTING BY 2'S/5'S/10'S"
      A2BYD100 = "A2 Q32D COUNTING BEYOND 100"
      A2W12100 = "A2 Q32E WRITE ALL NUMBERS 1-100"
      A2SHAPES = "A2 Q32F NAME GEOMETRIC SHAPES"
      A2IDQNTY = "A2 Q32G IDENTIFY RELATIVE QUANTITY"
      A2SUBGRP = "A2 Q32H SORT INTO SUBGROUPS USING RULE"
      A2SZORDR = "A2 Q32I ORDERING OBJECTS"
      A2PTTRNS = "A2 Q32J MAKING/COPYING PATTERNS"
      A2REGZCN = "A2 Q32K KNOW VALUE OF COINS AND CASH"
      A2SNGDGT = "A2 Q32L ADD SINGLE-DIGIT NUMBERS"
      A2SUBSDG = "A2 Q32M SUBTRACT SINGLE-DIGIT NUMBERS"
      A2PLACE = "A2 Q32N PLACE VALUE"
      A2TWODGT = "A2 Q32O READING TWO-DIGIT NUMBERS"
      A23DGT = "A2 Q32P READING THREE-DIGIT NUMBERS"
      A2MIXOP = "A2 Q32Q MIXED OPERATIONS"
      A2GRAPHS = "A2 Q32R READING SIMPLE GRAPHS"
      A2DATACO = "A2 Q32S SIMPLE DATA COLLECTION/GRAPHING"
      A2FRCTNS = "A2 Q32T RECOGNIZING FRACTIONS"
      A2ORDINL = "A2 Q32U RECOGNIZING ORDINAL NUMBERS"
      A2ACCURA = "A2 Q32V USE MEASURNG INSTRUMNTS ACCURATE"
      A2TELLTI = "A2 Q32W TELLING TIME"
      A2ESTQNT = "A2 Q32X ESTIMATING QUANTITIES"
      A2ADD2DG = "A2 Q32Y ADDING TWO-DIGIT NUMBERS"
      A2CARRY = "A2 Q32Z CARRYING NUMBERS IN ADDITION"
      A2SUB2DG = "A2 Q32AA SUBTRACTING TWO-DIGIT NUMBERS"
      A2PRBBTY = "A2 Q32BB ESTIMATING PROBABILITY"
      A2EQTN = "A2 Q32CC USE MATH FOR WORD PROBLEMS"
      A2LRNRD = "A2 Q33A COMPUTERS TO READ/WRITE/SPELL"
      A2LRNMTH = "A2 Q33B COMPUTERS TO LEARN MATH"
      A2LRNSS = "A2 Q33C COMPUTERS FOR SOCIAL STUDIES"
      A2LRNSCN = "A2 Q33D COMPUTERS FOR SCIENCE CONCEPTS"
      A2LRNKEY = "A2 Q33E COMPUTERS FOR KEYBOARD SKILLS"
      A2LRNART = "A2 Q33F COMPUTERS TO CREATE ART"
      A2LRNMSC = "A2 Q33G COMPUTERS TO COMPOSE MUSIC"
      A2LRNGMS = "A2 Q33H COMPUTERS FOR FUN (GAMES)"
      A2LRNLAN = "A2 Q33I COMPUTERS FOR INTERNET/LAN"
      A2BODY = "A2 Q34A HUMAN BODY"
      A2PLANT = "A2 Q34B PLANTS AND ANIMALS"
      A2DINOSR = "A2 Q34C DINOSAURS AND FOSSILS"
      A2SOLAR = "A2 Q34D SOLAR SYSTEM AND SPACE"
      A2WTHER = "A2 Q34E WEATHER (RAINY, SUNNY)"
      A2TEMP = "A2 Q34F KNOW AND MEASURE TEMPERATURE"
      A2WATER = "A2 Q34G WATER"
      A2SOUND = "A2 Q34H SOUND"
      A2LIGHT = "A2 Q34I LIGHT"
      A2MAGNET = "A2 Q34J MAGNETISM AND ELECTRICITY"
      A2MOTORS = "A2 Q34K MACHINES AND MOTORS"
      A2TOOLS = "A2 Q34L TOOLS AND THEIR USES"
      A2HYGIEN = "A2 Q34M HEALTH/SAFETY/NUTRITION/HYGIENE"
      A2HISTOR = "A2 Q34N KEY EVENTS IN AMERICAN HISTORY"
      A2CMNITY = "A2 Q34O COMMUNITY RESOURCES"
      A2MAPRD = "A2 Q34P MAP-READING SKILLS"
      A2CULTUR = "A2 Q34Q DIFFERENT CULTURES"
      A2LAWS = "A2 Q34R REASONS FOR RULES/LAWS/GOVT"
      A2ECOLOG = "A2 Q34S ECOLOGY"
      A2GEORPH = "A2 Q34T GEOGRAPHY"
      A2SCMTHD = "A2 Q34U SCIENTIFIC METHOD"
      A2SOCPRO = "A2 Q34V SOCIAL-PROBLEM SOLVING"
      A2NUMCNF = "A2 Q35 NUMBER OF CONFERENCES W/PARENT"
      A2TPCONF = "A2 Q36A % PARENT ATTEND CONFERENCES"
      A2REGHLP = "A2 Q36B % PARENT VOLUNTEERS REGULARLY"
      A2ATTOPN = "A2 Q36C % PARENT ATTEND OPEN HOUSE"
      A2ATTART = "A2 Q36D % PARENT ATTEND ART/MUSIC EVENT"
      A2AVHRS = "A2 Q37 HRS/WK VOLUNTEER-AM"
      A2PVHRS = "A2 Q37 HRS/WK VOLUNTEER-PM"
      A2DVHRS = "A2 Q37 HRS/WK VOLUNTEER-AD"
      A2SNTHME = "A2 Q38A TIMES SENT HOME NEWSLETTERS ETC"
      A2SHARED = "A2 Q38B TIMES PARENTS SEE CHILDS WORK"
      A2LESPLN = "A2 Q39A TIMES MEET FOR LESSON PLANNING"
      A2CURRDV = "A2 Q39B TIMES MEET TO DISCUSS CURRICULUM"
      A2INDCHD = "A2 Q39C TIMES MEET TO DISCUSS A CHILD"
      A2DISCHD = "A2 Q39D TIMES MEET W/ SPECIAL ED TEACHER"
      A2INSRVC = "A2 Q40A ATTENDED THREE INSERVICE DAYS"
      A2WRKSHP = "A2 Q40B ATTENDED PROBLEM SOLVING GROUP"
      A2CNSLT = "A2 Q40C ATTENDED CONSULTANT MEETING"
      A2FDBACK = "A2 Q40D ATTENDED PEER FEEDBACK"
      A2SUPPOR = "A2 Q40E ATTENDED NEW SKILLS SUPPORT"
      A2OBSERV = "A2 Q40F ATTENDED/OBSERVED OTHER SCHOOL"
      A2RELTIM = "A2 Q40G ATTENDED EARLY CHILDHOOD CONF"
      A2COLLEG = "A2 Q40H ATTENDED UNIVERSITY COURSES"
      A2TECH = "A2 Q40I ATTENDED COMPUTER/TECH WORKSHOPS"
      A2STFFTR = "A2 Q40J ATTENDED OTHER STAFF TRAINING"
      A2ADTRND = "A2 Q41A CAN TEACH DISABLED IN MY CLASS"
      A2INCLUS = "A2 Q41A INCLUSION HAS WORKED WELL"
      A2MMCOMP = "A2 MONTH COMPLETED QUESTIONNAIRE"
      A2DDCOMP = "A2 DAY COMPLETED QUESTIONNAIRE"
      A2YYCOMP = "A2 YEAR COMPLETED QUESTIONNAIRE"
      B1TTWSTR = "B1 TCHR WT TAYLOR SERIES SAMPLING STRAT"
      B1TTWPSU = "B1 TCHR WT TAYLOR SERIES PRIM SAMP UNIT"
      B1TW1 = "B1 TEACHER WEIGHT REPLICATE 1"
      B1TW2 = "B1 TEACHER WEIGHT REPLICATE 2"
      B1TW3 = "B1 TEACHER WEIGHT REPLICATE 3"
      B1TW4 = "B1 TEACHER WEIGHT REPLICATE 4"
      B1TW5 = "B1 TEACHER WEIGHT REPLICATE 5"
      B1TW6 = "B1 TEACHER WEIGHT REPLICATE 6"
      B1TW7 = "B1 TEACHER WEIGHT REPLICATE 7"
      B1TW8 = "B1 TEACHER WEIGHT REPLICATE 8"
      B1TW9 = "B1 TEACHER WEIGHT REPLICATE 9"
      B1TW10 = "B1 TEACHER WEIGHT REPLICATE 10"
      B1TW11 = "B1 TEACHER WEIGHT REPLICATE 11"
      B1TW12 = "B1 TEACHER WEIGHT REPLICATE 12"
      B1TW13 = "B1 TEACHER WEIGHT REPLICATE 13"
      B1TW14 = "B1 TEACHER WEIGHT REPLICATE 14"
      B1TW15 = "B1 TEACHER WEIGHT REPLICATE 15"
      B1TW16 = "B1 TEACHER WEIGHT REPLICATE 16"
      B1TW17 = "B1 TEACHER WEIGHT REPLICATE 17"
      B1TW18 = "B1 TEACHER WEIGHT REPLICATE 18"
      B1TW19 = "B1 TEACHER WEIGHT REPLICATE 19"
      B1TW20 = "B1 TEACHER WEIGHT REPLICATE 20"
      B1TW21 = "B1 TEACHER WEIGHT REPLICATE 21"
      B1TW22 = "B1 TEACHER WEIGHT REPLICATE 22"
      B1TW23 = "B1 TEACHER WEIGHT REPLICATE 23"
      B1TW24 = "B1 TEACHER WEIGHT REPLICATE 24"
      B1TW25 = "B1 TEACHER WEIGHT REPLICATE 25"
      B1TW26 = "B1 TEACHER WEIGHT REPLICATE 26"
      B1TW27 = "B1 TEACHER WEIGHT REPLICATE 27"
      B1TW28 = "B1 TEACHER WEIGHT REPLICATE 28"
      B1TW29 = "B1 TEACHER WEIGHT REPLICATE 29"
      B1TW30 = "B1 TEACHER WEIGHT REPLICATE 30"
      B1TW31 = "B1 TEACHER WEIGHT REPLICATE 31"
      B1TW32 = "B1 TEACHER WEIGHT REPLICATE 32"
      B1TW33 = "B1 TEACHER WEIGHT REPLICATE 33"
      B1TW34 = "B1 TEACHER WEIGHT REPLICATE 34"
      B1TW35 = "B1 TEACHER WEIGHT REPLICATE 35"
      B1TW36 = "B1 TEACHER WEIGHT REPLICATE 36"
      B1TW37 = "B1 TEACHER WEIGHT REPLICATE 37"
      B1TW38 = "B1 TEACHER WEIGHT REPLICATE 38"
      B1TW39 = "B1 TEACHER WEIGHT REPLICATE 39"
      B1TW40 = "B1 TEACHER WEIGHT REPLICATE 40"
      B1TW41 = "B1 TEACHER WEIGHT REPLICATE 41"
      B1TW42 = "B1 TEACHER WEIGHT REPLICATE 42"
      B1TW43 = "B1 TEACHER WEIGHT REPLICATE 43"
      B1TW44 = "B1 TEACHER WEIGHT REPLICATE 44"
      B1TW45 = "B1 TEACHER WEIGHT REPLICATE 45"
      B1TW46 = "B1 TEACHER WEIGHT REPLICATE 46"
      B1TW47 = "B1 TEACHER WEIGHT REPLICATE 47"
      B1TW48 = "B1 TEACHER WEIGHT REPLICATE 48"
      B1TW49 = "B1 TEACHER WEIGHT REPLICATE 49"
      B1TW50 = "B1 TEACHER WEIGHT REPLICATE 50"
      B1TW51 = "B1 TEACHER WEIGHT REPLICATE 51"
      B1TW52 = "B1 TEACHER WEIGHT REPLICATE 52"
      B1TW53 = "B1 TEACHER WEIGHT REPLICATE 53"
      B1TW54 = "B1 TEACHER WEIGHT REPLICATE 54"
      B1TW55 = "B1 TEACHER WEIGHT REPLICATE 55"
      B1TW56 = "B1 TEACHER WEIGHT REPLICATE 56"
      B1TW57 = "B1 TEACHER WEIGHT REPLICATE 57"
      B1TW58 = "B1 TEACHER WEIGHT REPLICATE 58"
      B1TW59 = "B1 TEACHER WEIGHT REPLICATE 59"
      B1TW60 = "B1 TEACHER WEIGHT REPLICATE 60"
      B1TW61 = "B1 TEACHER WEIGHT REPLICATE 61"
      B1TW62 = "B1 TEACHER WEIGHT REPLICATE 62"
      B1TW63 = "B1 TEACHER WEIGHT REPLICATE 63"
      B1TW64 = "B1 TEACHER WEIGHT REPLICATE 64"
      B1TW65 = "B1 TEACHER WEIGHT REPLICATE 65"
      B1TW66 = "B1 TEACHER WEIGHT REPLICATE 66"
      B1TW67 = "B1 TEACHER WEIGHT REPLICATE 67"
      B1TW68 = "B1 TEACHER WEIGHT REPLICATE 68"
      B1TW69 = "B1 TEACHER WEIGHT REPLICATE 69"
      B1TW70 = "B1 TEACHER WEIGHT REPLICATE 70"
      B1TW71 = "B1 TEACHER WEIGHT REPLICATE 71"
      B1TW72 = "B1 TEACHER WEIGHT REPLICATE 72"
      B1TW73 = "B1 TEACHER WEIGHT REPLICATE 73"
      B1TW74 = "B1 TEACHER WEIGHT REPLICATE 74"
      B1TW75 = "B1 TEACHER WEIGHT REPLICATE 75"
      B1TW76 = "B1 TEACHER WEIGHT REPLICATE 76"
      B1TW77 = "B1 TEACHER WEIGHT REPLICATE 77"
      B1TW78 = "B1 TEACHER WEIGHT REPLICATE 78"
      B1TW79 = "B1 TEACHER WEIGHT REPLICATE 79"
      B1TW80 = "B1 TEACHER WEIGHT REPLICATE 80"
      B1TW81 = "B1 TEACHER WEIGHT REPLICATE 81"
      B1TW82 = "B1 TEACHER WEIGHT REPLICATE 82"
      B1TW83 = "B1 TEACHER WEIGHT REPLICATE 83"
      B1TW84 = "B1 TEACHER WEIGHT REPLICATE 84"
      B1TW85 = "B1 TEACHER WEIGHT REPLICATE 85"
      B1TW86 = "B1 TEACHER WEIGHT REPLICATE 86"
      B1TW87 = "B1 TEACHER WEIGHT REPLICATE 87"
      B1TW88 = "B1 TEACHER WEIGHT REPLICATE 88"
      B1TW89 = "B1 TEACHER WEIGHT REPLICATE 89"
      B1TW90 = "B1 TEACHER WEIGHT REPLICATE 90"
      B2TTWSTR = "B2 TCHR WT TAYLOR SERIES SAMPLING STRAT"
      B2TTWPSU = "B2 TCHR WT TAYLOR SERIES PRIM SAMP UNIT"
      B2TW1 = "B2 TEACHER WEIGHT REPLICATE 1"
      B2TW2 = "B2 TEACHER WEIGHT REPLICATE 2"
      B2TW3 = "B2 TEACHER WEIGHT REPLICATE 3"
      B2TW4 = "B2 TEACHER WEIGHT REPLICATE 4"
      B2TW5 = "B2 TEACHER WEIGHT REPLICATE 5"
      B2TW6 = "B2 TEACHER WEIGHT REPLICATE 6"
      B2TW7 = "B2 TEACHER WEIGHT REPLICATE 7"
      B2TW8 = "B2 TEACHER WEIGHT REPLICATE 8"
      B2TW9 = "B2 TEACHER WEIGHT REPLICATE 9"
      B2TW10 = "B2 TEACHER WEIGHT REPLICATE 10"
      B2TW11 = "B2 TEACHER WEIGHT REPLICATE 11"
      B2TW12 = "B2 TEACHER WEIGHT REPLICATE 12"
      B2TW13 = "B2 TEACHER WEIGHT REPLICATE 13"
      B2TW14 = "B2 TEACHER WEIGHT REPLICATE 14"
      B2TW15 = "B2 TEACHER WEIGHT REPLICATE 15"
      B2TW16 = "B2 TEACHER WEIGHT REPLICATE 16"
      B2TW17 = "B2 TEACHER WEIGHT REPLICATE 17"
      B2TW18 = "B2 TEACHER WEIGHT REPLICATE 18"
      B2TW19 = "B2 TEACHER WEIGHT REPLICATE 19"
      B2TW20 = "B2 TEACHER WEIGHT REPLICATE 20"
      B2TW21 = "B2 TEACHER WEIGHT REPLICATE 21"
      B2TW22 = "B2 TEACHER WEIGHT REPLICATE 22"
      B2TW23 = "B2 TEACHER WEIGHT REPLICATE 23"
      B2TW24 = "B2 TEACHER WEIGHT REPLICATE 24"
      B2TW25 = "B2 TEACHER WEIGHT REPLICATE 25"
      B2TW26 = "B2 TEACHER WEIGHT REPLICATE 26"
      B2TW27 = "B2 TEACHER WEIGHT REPLICATE 27"
      B2TW28 = "B2 TEACHER WEIGHT REPLICATE 28"
      B2TW29 = "B2 TEACHER WEIGHT REPLICATE 29"
      B2TW30 = "B2 TEACHER WEIGHT REPLICATE 30"
      B2TW31 = "B2 TEACHER WEIGHT REPLICATE 31"
      B2TW32 = "B2 TEACHER WEIGHT REPLICATE 32"
      B2TW33 = "B2 TEACHER WEIGHT REPLICATE 33"
      B2TW34 = "B2 TEACHER WEIGHT REPLICATE 34"
      B2TW35 = "B2 TEACHER WEIGHT REPLICATE 35"
      B2TW36 = "B2 TEACHER WEIGHT REPLICATE 36"
      B2TW37 = "B2 TEACHER WEIGHT REPLICATE 37"
      B2TW38 = "B2 TEACHER WEIGHT REPLICATE 38"
      B2TW39 = "B2 TEACHER WEIGHT REPLICATE 39"
      B2TW40 = "B2 TEACHER WEIGHT REPLICATE 40"
      B2TW41 = "B2 TEACHER WEIGHT REPLICATE 41"
      B2TW42 = "B2 TEACHER WEIGHT REPLICATE 42"
      B2TW43 = "B2 TEACHER WEIGHT REPLICATE 43"
      B2TW44 = "B2 TEACHER WEIGHT REPLICATE 44"
      B2TW45 = "B2 TEACHER WEIGHT REPLICATE 45"
      B2TW46 = "B2 TEACHER WEIGHT REPLICATE 46"
      B2TW47 = "B2 TEACHER WEIGHT REPLICATE 47"
      B2TW48 = "B2 TEACHER WEIGHT REPLICATE 48"
      B2TW49 = "B2 TEACHER WEIGHT REPLICATE 49"
      B2TW50 = "B2 TEACHER WEIGHT REPLICATE 50"
      B2TW51 = "B2 TEACHER WEIGHT REPLICATE 51"
      B2TW52 = "B2 TEACHER WEIGHT REPLICATE 52"
      B2TW53 = "B2 TEACHER WEIGHT REPLICATE 53"
      B2TW54 = "B2 TEACHER WEIGHT REPLICATE 54"
      B2TW55 = "B2 TEACHER WEIGHT REPLICATE 55"
      B2TW56 = "B2 TEACHER WEIGHT REPLICATE 56"
      B2TW57 = "B2 TEACHER WEIGHT REPLICATE 57"
      B2TW58 = "B2 TEACHER WEIGHT REPLICATE 58"
      B2TW59 = "B2 TEACHER WEIGHT REPLICATE 59"
      B2TW60 = "B2 TEACHER WEIGHT REPLICATE 60"
      B2TW61 = "B2 TEACHER WEIGHT REPLICATE 61"
      B2TW62 = "B2 TEACHER WEIGHT REPLICATE 62"
      B2TW63 = "B2 TEACHER WEIGHT REPLICATE 63"
      B2TW64 = "B2 TEACHER WEIGHT REPLICATE 64"
      B2TW65 = "B2 TEACHER WEIGHT REPLICATE 65"
      B2TW66 = "B2 TEACHER WEIGHT REPLICATE 66"
      B2TW67 = "B2 TEACHER WEIGHT REPLICATE 67"
      B2TW68 = "B2 TEACHER WEIGHT REPLICATE 68"
      B2TW69 = "B2 TEACHER WEIGHT REPLICATE 69"
      B2TW70 = "B2 TEACHER WEIGHT REPLICATE 70"
      B2TW71 = "B2 TEACHER WEIGHT REPLICATE 71"
      B2TW72 = "B2 TEACHER WEIGHT REPLICATE 72"
      B2TW73 = "B2 TEACHER WEIGHT REPLICATE 73"
      B2TW74 = "B2 TEACHER WEIGHT REPLICATE 74"
      B2TW75 = "B2 TEACHER WEIGHT REPLICATE 75"
      B2TW76 = "B2 TEACHER WEIGHT REPLICATE 76"
      B2TW77 = "B2 TEACHER WEIGHT REPLICATE 77"
      B2TW78 = "B2 TEACHER WEIGHT REPLICATE 78"
      B2TW79 = "B2 TEACHER WEIGHT REPLICATE 79"
      B2TW80 = "B2 TEACHER WEIGHT REPLICATE 80"
      B2TW81 = "B2 TEACHER WEIGHT REPLICATE 81"
      B2TW82 = "B2 TEACHER WEIGHT REPLICATE 82"
      B2TW83 = "B2 TEACHER WEIGHT REPLICATE 83"
      B2TW84 = "B2 TEACHER WEIGHT REPLICATE 84"
      B2TW85 = "B2 TEACHER WEIGHT REPLICATE 85"
      B2TW86 = "B2 TEACHER WEIGHT REPLICATE 86"
      B2TW87 = "B2 TEACHER WEIGHT REPLICATE 87"
      B2TW88 = "B2 TEACHER WEIGHT REPLICATE 88"
      B2TW89 = "B2 TEACHER WEIGHT REPLICATE 89"
      B2TW90 = "B2 TEACHER WEIGHT REPLICATE 90"
      A1AKGTYP = "A1 Q3 TYPE OF KINDERGARTEN PROG TCH-AM"
      A1PKGTYP = "A1 Q3 TYPE OF KINDERGARTEN PROG TCH-PM"
      A1DKGTYP = "A1 Q3 TYPE OF KINDERGARTEN PROG TCH-AD"
      ;

/* format
      S_ID   $SID.
      T_ID   $TID.
      A1AHRSDA   A1004A.
      A1DHRSDA   A1004D.
      A1PHRSDA   A1004P.
      A1ADYSWK   A1005A.
      A1DDYSWK   A1005D.
      A1PDYSWK   A1005P.
      A1A3YROL   A1006A.
      A1D3YROL   A1006D.
      A1P3YROL   A1006P.
      A1A4YROL   A1007A.
      A1D4YROL   A1007D.
      A1P4YROL   A1007P.
      A1A5YROL   A1008A.
      A1D5YROL   A1008D.
      A1P5YROL   A1008P.
      A1A6YROL   A1009A.
      A1D6YROL   A1009D.
      A1P6YROL   A1009P.
      A1A7YROL   A1010A.
      A1D7YROL   A1010D.
      A1P7YROL   A1010P.
      A1A8YROL   A1011A.
      A1D8YROL   A1011D.
      A1P8YROL   A1011P.
      A1A9YROL   A1012A.
      A1D9YROL   A1012D.
      A1P9YROL   A1012P.
      A1ATOTAG   A1013A.
      A1DTOTAG   A1013D.
      A1PTOTAG   A1013P.
      A1AASIAN   A1014A.
      A1DASIAN   A1014D.
      A1PASIAN   A1014P.
      A1AHISP   A1015A.
      A1DHISP   A1015D.
      A1PHISP   A1015P.
      A1ABLACK   A1016A.
      A1DBLACK   A1016D.
      A1PBLACK   A1016P.
      A1AWHITE   A1017A.
      A1DWHITE   A1017D.
      A1PWHITE   A1017P.
      A1AAMRIN   A1018A.
      A1DAMRIN   A1018D.
      A1PAMRIN   A1018P.
      A1ARACEO   A1019A.
      A1DRACEO   A1019D.
      A1PRACEO   A1019P.
      A1ATOTRA   A1020A.
      A1DTOTRA   A1020D.
      A1PTOTRA   A1020P.
      A1ABOYS   A1021A.
      A1DBOYS   A1021D.
      A1PBOYS   A1021P.
      A1AGIRLS   A1022A.
      A1DGIRLS   A1022D.
      A1PGIRLS   A1022P.
      A1AREPK   A1023A.
      A1DREPK   A1023D.
      A1PREPK   A1023P.
      A1ALETT   A1024A.
      A1DLETT   A1024D.
      A1PLETT   A1024P.
      A1AWORD   A1025A.
      A1DWORD   A1025D.
      A1PWORD   A1025P.
      A1ASNTNC   A1026A.
      A1DSNTNC   A1026D.
      A1PSNTNC   A1026P.
      A1ANUMLE   A1027A.
      A1DNUMLE   A1027D.
      A1PNUMLE   A1027P.
      A1ANOESL   A1028A.
      A1DNOESL   A1028D.
      A1PNOESL   A1028P.
      A1AESLRE   A1029A.
      A1DESLRE   A1029D.
      A1PESLRE   A1029P.
      A1AESLOU   A1030A.
      A1DESLOU   A1030D.
      A1PESLOU   A1030P.
      A1APBLK   A1031A.
      A1DPBLK   A1031D.
      A1PPBLK   A1031P.
      A1APHIS   A1032A.
      A1DPHIS   A1032D.
      A1PPHIS   A1032P.
      A1APMIN   A1033A.
      A1DPMIN   A1033D.
      A1PPMIN   A1033P.
      A1ALEP   A1048F.
      A1AOTLAN   A1048F.
      A1APRESC   A1048F.
      A1DLEP   A1048F.
      A1DOTLAN   A1048F.
      A1DPRESC   A1048F.
      A1PLEP   A1048F.
      A1POTLAN   A1048F.
      A1PPRESC   A1048F.
      A1APCPRE   A1049F.
      A1DPCPRE   A1049F.
      A1PPCPRE   A1049F.
      A1ABEHVR   A1050F.
      A1DBEHVR   A1050F.
      A1PBEHVR   A1050F.
      A1ACCHNS   A1051F.
      A1ACFLPN   A1051F.
      A1ACJPNS   A1051F.
      A1ACKRN   A1051F.
      A1ACSPNH   A1051F.
      A1ACVTNM   A1051F.
      A1AOTASN   A1051F.
      A1AOTLNG   A1051F.
      A1ATNOOT   A1051F.
      A1ATSPNH   A1051F.
      A1DCCHNS   A1051F.
      A1DCFLPN   A1051F.
      A1DCJPNS   A1051F.
      A1DCKRN   A1051F.
      A1DCSPNH   A1051F.
      A1DCVTNM   A1051F.
      A1DOTASN   A1051F.
      A1DOTLNG   A1051F.
      A1DTNOOT   A1051F.
      A1DTSPNH   A1051F.
      A1PCCHNS   A1051F.
      A1PCFLPN   A1051F.
      A1PCJPNS   A1051F.
      A1PCKRN   A1051F.
      A1PCSPNH   A1051F.
      A1PCVTNM   A1051F.
      A1POTASN   A1051F.
      A1POTLNG   A1051F.
      A1PTNOOT   A1051F.
      A1PTSPNH   A1051F.
      A1ANONEN   A1068F.
      A1DNONEN   A1068F.
      A1PNONEN   A1068F.
      A1COMPMM   A1069F.
      A1COMPDD   A1070F.
      A1COMPYY   A1071F.
      A1ALANOS   A1072F.
      A1DLANOS   A1072F.
      A1PLANOS   A1072F.
      A1ALEPOS   A1073F.
      A1DLEPOS   A1073F.
      A1PLEPOS   A1073F.
      A1AKGTYP   A11074F.
      A1DKGTYP   A11074F.
      A1PKGTYP   A11074F.
      A2AABSEN   A2AABSEN.
      A2ADELAY   A2ADELAY.
      A2ADISAB   A2ADISAB.
      A2AEMPRB   A2ADSTRU.
      A2AGIFT   A2AGIFT.
      A2AHEAR   A2AHEAR.
      A2AIEP   A2AIEP.
      A2AIMPAI   A2AIMPAI.
      A2ALEFT   A2ALEFT.
      A2ALRNDI   A2ALRNDI.
      A2AVHRS   A2AMHRS.
      A2AMORE   A2AMORE.
      A2AMTHBL   A2AMTHBL.
      A2ANEW   A2ANEW.
      A2AORTHO   A2AORTHO.
      A2AOTDIS   A2AOTDIS.
      A2AOTHER   A2AOTHER.
      A2APRTGF   A2APRTGF.
      A2ARDBLO   A2ARDBLO.
      A2ARTMAT   A2ARTMAT.
      A2BOOKS   A2ARTMAT.
      A2COOK   A2ARTMAT.
      A2COSTUM   A2ARTMAT.
      A2EQUIPM   A2ARTMAT.
      A2MUSIC   A2ARTMAT.
      A2PLAYER   A2ARTMAT.
      A2TVWTCH   A2ARTMAT.
      A2VCR   A2ARTMAT.
      A2ASC504   A2AS504F.
      A2ASPCIA   A2ASPCIA.
      A2ATARDY   A2ATARDY.
      A2ATRAUM   A2ATRAUM.
      A2AVIS   A2AVIS.
      A2ABEHVR   A2BEHVR.
      A2DBEHVR   A2BEHVR.
      A2PBEHVR   A2BEHVR.
      A2ACERTF   A2CERTF.
      A2DCERTF   A2CERTF.
      A2PCERTF   A2CERTF.
      KGCLASS   A2CLASS.
      A21TO10   A2CONVEN.
      A22S5S10   A2CONVEN.
      A23DGT   A2CONVEN.
      A2ACCURA   A2CONVEN.
      A2ADD2DG   A2CONVEN.
      A2ALPBTZ   A2CONVEN.
      A2BODY   A2CONVEN.
      A2BYD100   A2CONVEN.
      A2CARRY   A2CONVEN.
      A2CMNITY   A2CONVEN.
      A2COMPSE   A2CONVEN.
      A2CONVNT   A2CONVEN.
      A2CULTUR   A2CONVEN.
      A2DATACO   A2CONVEN.
      A2DINOSR   A2CONVEN.
      A2DRCTNS   A2CONVEN.
      A2ECOLOG   A2CONVEN.
      A2EQTN   A2CONVEN.
      A2ESTQNT   A2CONVEN.
      A2FRCTNS   A2CONVEN.
      A2GEORPH   A2CONVEN.
      A2GRAPHS   A2CONVEN.
      A2HISTOR   A2CONVEN.
      A2HYGIEN   A2CONVEN.
      A2IDQNTY   A2CONVEN.
      A2LAWS   A2CONVEN.
      A2LIGHT   A2CONVEN.
      A2MAGNET   A2CONVEN.
      A2MAINID   A2CONVEN.
      A2MAPRD   A2CONVEN.
      A2MATCH   A2CONVEN.
      A2MIXOP   A2CONVEN.
      A2MOTORS   A2CONVEN.
      A2ORALID   A2CONVEN.
      A2ORDINL   A2CONVEN.
      A2PLACE   A2CONVEN.
      A2PLANT   A2CONVEN.
      A2PNCTUA   A2CONVEN.
      A2PRBBTY   A2CONVEN.
      A2PREDIC   A2CONVEN.
      A2PREPOS   A2CONVEN.
      A2PTTRNS   A2CONVEN.
      A2QUANTI   A2CONVEN.
      A2RCGNZE   A2CONVEN.
      A2RDFLNT   A2CONVEN.
      A2REGZCN   A2CONVEN.
      A2RHYMNG   A2CONVEN.
      A2SCMTHD   A2CONVEN.
      A2SHAPES   A2CONVEN.
      A2SNGDGT   A2CONVEN.
      A2SOCPRO   A2CONVEN.
      A2SOLAR   A2CONVEN.
      A2SOUND   A2CONVEN.
      A2SPELL   A2CONVEN.
      A2SUB2DG   A2CONVEN.
      A2SUBGRP   A2CONVEN.
      A2SUBSDG   A2CONVEN.
      A2SYLLAB   A2CONVEN.
      A2SZORDR   A2CONVEN.
      A2TELLTI   A2CONVEN.
      A2TEMP   A2CONVEN.
      A2TEXTCU   A2CONVEN.
      A2TOOLS   A2CONVEN.
      A2TWODGT   A2CONVEN.
      A2VOCAB   A2CONVEN.
      A2W12100   A2CONVEN.
      A2WATER   A2CONVEN.
      A2WRTNME   A2CONVEN.
      A2WRTSTO   A2CONVEN.
      A2WTHER   A2CONVEN.
      A2DABSEN   A2DABSEN.
      A2DDCOMP   A2DDCOMP.
      A2DDELAY   A2DDELAY.
      A2DDISAB   A2DDISAB.
      A2DEMPRB   A2DDSTRU.
      A2DGIFT   A2DGIFT.
      A2DHEAR   A2DHEAR.
      A2DIEP   A2DIEP.
      A2DIMPAI   A2DIMPAI.
      A2DIVMTH   A2DIV.
      A2DIVRD   A2DIV.
      A2OTASSI   A2DIVREA.
      A2DLEFT   A2DLEFT.
      A2DLRNDI   A2DLRNDI.
      A2DMORE   A2DMORE.
      A2DMTHBL   A2DMTHBL.
      A2DNEW   A2DNEW.
      A2DORTHO   A2DORTHO.
      A2DOTDIS   A2DOTDIS.
      A2DOTHER   A2DOTHER.
      A2DPRTGF   A2DPRTGF.
      A2DRDBLO   A2DRDBLO.
      A2ARETAR   A2DRETAR.
      A2DRETAR   A2DRETAR.
      A2PRETAR   A2DRETAR.
      A2DSC504   A2DS504F.
      A2DSPCIA   A2DSPCIA.
      A2DTARDY   A2DTARDY.
      A2DTRAUM   A2DTRAUM.
      A2DVIS   A2DVIS.
      A2DYRECS   A2DYREC.
      A2AIDTUT   A2EXASIS.
      A2EXASIS   A2EXASIS.
      A2PULLOU   A2EXASIS.
      A2SPECTU   A2EXASIS.
      A2DVHRS   A2FDHRS.
      A2BORROW   A2GOTO.
      A2GOTOLI   A2GOTO.
      A2ADTRND   A2INVSP.
      A2INCLUS   A2INVSP.
      A2INVSPE   A2INVSP.
      A2BASAL   A2LERN.
      A2CALCUL   A2LERN.
      A2CALEND   A2LERN.
      A2CHLKBD   A2LERN.
      A2CHSBK   A2LERN.
      A2COMPOS   A2LERN.
      A2CRTIVE   A2LERN.
      A2CURRDV   A2LERN.
      A2DICTAT   A2LERN.
      A2DISCHD   A2LERN.
      A2DOPROJ   A2LERN.
      A2EXPMTH   A2LERN.
      A2GEOMET   A2LERN.
      A2INDCHD   A2LERN.
      A2INVENT   A2LERN.
      A2JRNL   A2LERN.
      A2LERNLT   A2LERN.
      A2LESPLN   A2LERN.
      A2MANIPS   A2LERN.
      A2MTHGME   A2LERN.
      A2MTHSHT   A2LERN.
      A2MTHTXT   A2LERN.
      A2MUSMTH   A2LERN.
      A2MXDGRP   A2LERN.
      A2MXMATH   A2LERN.
      A2NEWVOC   A2LERN.
      A2NOPRNT   A2LERN.
      A2OUTLOU   A2LERN.
      A2PEER   A2LERN.
      A2PHONIC   A2LERN.
      A2PRACLT   A2LERN.
      A2PRTNRS   A2LERN.
      A2PRTUTR   A2LERN.
      A2PUBLSH   A2LERN.
      A2READLD   A2LERN.
      A2REALLI   A2LERN.
      A2RETELL   A2LERN.
      A2RULERS   A2LERN.
      A2SEEPRI   A2LERN.
      A2SILENT   A2LERN.
      A2SKITS   A2LERN.
      A2TELLRS   A2LERN.
      A2WRKBK   A2LERN.
      A2WRTWRD   A2LERN.
      A2LRNART   A2LRNREA.
      A2LRNGMS   A2LRNREA.
      A2LRNKEY   A2LRNREA.
      A2LRNLAN   A2LRNREA.
      A2LRNMSC   A2LRNREA.
      A2LRNMTH   A2LRNREA.
      A2LRNRD   A2LRNREA.
      A2LRNSCN   A2LRNREA.
      A2LRNSS   A2LRNREA.
      A2LUNCH   A2LUNCH.
      A2ALVLED   A2LVLEF.
      A2DLVLED   A2LVLEF.
      A2PLVLED   A2LVLEF.
      A2MINMTH   A2MINREA.
      A2MINRD   A2MINREA.
      A2MMCOMP   A2MMCOMP.
      A2MNEXTR   A2MN18A.
      A2MNAIDE   A2MN18B.
      A2MNSPEC   A2MN18C.
      A2MNPOIN   A2MN18D.
      A2MNOSHP   A2MN18E.
      A2PDAIDE   A2NEW.
      A2NUMTH   A2NOMATH.
      A2NUMCNF   A2NUMCON.
      A2NUMRD   A2NUMRD.
      A2OFTART   A2OFTRD.
      A2OFTDAN   A2OFTRD.
      A2OFTESL   A2OFTRD.
      A2OFTFOR   A2OFTRD.
      A2OFTHTR   A2OFTRD.
      A2OFTMTH   A2OFTRD.
      A2OFTMUS   A2OFTRD.
      A2OFTRDL   A2OFTRD.
      A2OFTSCI   A2OFTRD.
      A2OFTSOC   A2OFTRD.
      A2TXPE   A2OFTRD.
      A2PABSEN   A2PABSEN.
      A2PDELAY   A2PDELAY.
      A2PDISAB   A2PDISAB.
      A2PEMPRB   A2PDSTRU.
      A2PGIFT   A2PGIFT.
      A2PHEAR   A2PHEAR.
      A2PIEP   A2PIEP.
      A2PIMPAI   A2PIMPAI.
      A2PLEFT   A2PLEFT.
      A2PLRNDI   A2PLRNDI.
      A2PVHRS   A2PMHRS.
      A2PMORE   A2PMORE.
      A2PMTHBL   A2PMTHBL.
      A2PNEW   A2PNEW.
      A2PORTHO   A2PORTHO.
      A2POTDIS   A2POTDIS.
      A2POTHER   A2POTHER.
      A2PPRTGF   A2PPRTGF.
      A2PRDBLO   A2PRDBLO.
      A2PSC504   A2PS504F.
      A2PSPCIA   A2PSPCIA.
      A2PTARDY   A2PTARDY.
      A2PTRAUM   A2PTRAUM.
      A2PVIS   A2PVIS.
      A2RECESS   A2RECESS.
      A2REGNON   A2REGWRA.
      A2REGWRK   A2REGWRB.
      A2SPEDNO   A2REGWRC.
      A2ESLWRK   A2REGWRD.
      A2SPEDWK   A2REGWRE.
      A2ESLNON   A2REGWRK.
      A2SHARED   A2SENTHO.
      A2SNTHME   A2SENTHO.
      A2ASPK   A2SPEA.
      A2DSPK   A2SPEA.
      A2PSPK   A2SPEA.
      A2ATTART   A2TPCONF.
      A2ATTOPN   A2TPCONF.
      A2REGHLP   A2TPCONF.
      A2TPCONF   A2TPCONF.
      A2TXART   A2TXRD.
      A2TXDAN   A2TXRD.
      A2TXESL   A2TXRD.
      A2TXFOR   A2TXRD.
      A2TXMTH   A2TXRD.
      A2TXMUS   A2TXRD.
      A2TXRDLA   A2TXRD.
      A2TXSCI   A2TXRD.
      A2TXSOC   A2TXRD.
      A2TXTHTR   A2TXRD.
      A2TXRCE   A2TXREC.
      A2TXSPEN   A2TXSPEN.
      A2ART   A2TXTBK.
      A2AUDIOV   A2TXTBK.
      A2CLSSPC   A2TXTBK.
      A2COMPEQ   A2TXTBK.
      A2DISMAT   A2TXTBK.
      A2DITTO   A2TXTBK.
      A2FURNIT   A2TXTBK.
      A2HEATAC   A2TXTBK.
      A2INSTRM   A2TXTBK.
      A2LEPMAT   A2TXTBK.
      A2MANIPU   A2TXTBK.
      A2PAPER   A2TXTBK.
      A2RECRDS   A2TXTBK.
      A2SOFTWA   A2TXTBK.
      A2TRADBK   A2TXTBK.
      A2TXTBK   A2TXTBK.
      A2VIDEO   A2TXTBK.
      A2WORKBK   A2TXTBK.
      A2CHCLDS   A2WHOLE.
      A2INDVDL   A2WHOLE.
      A2SMLGRP   A2WHOLE.
      A2WHLCLS   A2WHOLE.
      A2ACSPNH   A2YN.
      A2AENGLS   A2YN.
      A2ALANG   A2YN.
      A2DCSPNH   A2YN.
      A2DENGLS   A2YN.
      A2DLANG   A2YN.
      A2PCSPNH   A2YN.
      A2PENGLS   A2YN.
      A2PLANG   A2YN.
      A1ACLASS   A2YNCOMP.
      A1DCLASS   A2YNCOMP.
      A1PCLASS   A2YNCOMP.
      A1TQUEX   A2YNCOMP.
      A2ACLASS   A2YNCOMP.
      A2DCLASS   A2YNCOMP.
      A2PCLASS   A2YNCOMP.
      A2TQUEX   A2YNCOMP.
      B1TQUEX   A2YNCOMP.
      B2TQUEX   A2YNCOMP.
      A2CNSLT   A2YNN.
      A2COLLEG   A2YNN.
      A2COMMTE   A2YNN.
      A2FDBACK   A2YNN.
      A2INSRVC   A2YNN.
      A2OBSERV   A2YNN.
      A2RELTIM   A2YNN.
      A2STFFTR   A2YNN.
      A2SUPPOR   A2YNN.
      A2TECH   A2YNN.
      A2WRKSHP   A2YNN.
      A2YYCOMP   A2YYCOMP.
      B1YRSPRE   B1001F.
      B1YRSKIN   B1002F.
      B1YRSFST   B1003F.
      B1YRS2T5   B1004F.
      B1YRS6PL   B1005F.
      B1YRSESL   B1006F.
      B1YRSBIL   B1007F.
      B1YRSSPE   B1008F.
      B1YRSPE   B1009F.
      B1YRSART   B1010F.
      B1YRSCH   B1011F.
      B1AGE   B1012F.
      B1CHCLDS   B1013F.
      B1INDVDL   B1013F.
      B1SMLGRP   B1013F.
      B1WHLCLS   B1013F.
      B1ARTARE   B1014F.
      B1COMPAR   B1014F.
      B1DRAMAR   B1014F.
      B1HISP   B1014F.
      B1HMEVST   B1014F.
      B1INFOHO   B1014F.
      B1INKNDR   B1014F.
      B1LISTNC   B1014F.
      B1MATHAR   B1014F.
      B1OTTRAN   B1014F.
      B1PCKTCH   B1014F.
      B1PLAYAR   B1014F.
      B1PRNTOR   B1014F.
      B1READAR   B1014F.
      B1SCIAR   B1014F.
      B1SHRTN   B1014F.
      B1VSTK   B1014F.
      B1WATRSA   B1014F.
      B1WRTCNT   B1014F.
      B1ATTND   B1015F.
      B1BEHVR   B1015F.
      B1CLASPA   B1015F.
      B1COPRTV   B1015F.
      B1EFFO   B1015F.
      B1FLLWDR   B1015F.
      B1IMPRVM   B1015F.
      B1OTMT   B1015F.
      B1TOCLAS   B1015F.
      B1TOSTND   B1015F.
      B1EVAL   B1016F.
      B1NOPAYP   B1017F.
      B1PAIDPR   B1017F.
      B1ALPHBT   B1018F.
      B1CNT20   B1018F.
      B1COMM   B1018F.
      B1ENGLAN   B1018F.
      B1FNSHT   B1018F.
      B1FOLWDR   B1018F.
      B1IDCOLO   B1018F.
      B1NOTDSR   B1018F.
      B1PENCIL   B1018F.
      B1PRBLMS   B1018F.
      B1SENSTI   B1018F.
      B1SHARE   B1018F.
      B1SITSTI   B1018F.
      B1ACCPTD   B1019F.
      B1ALLKNO   B1019F.
      B1ALPHBF   B1019F.
      B1ATNDPR   B1019F.
      B1CNTNLR   B1019F.
      B1ENCOUR   B1019F.
      B1ENJOY   B1019F.
      B1FRMLIN   B1019F.
      B1HMWRK   B1019F.
      B1LRNREA   B1019F.
      B1MISBHV   B1019F.
      B1MISSIO   B1019F.
      B1MKDIFF   B1019F.
      B1NOTCAP   B1019F.
      B1PAPRWR   B1019F.
      B1PRCTWR   B1019F.
      B1PRESSU   B1019F.
      B1PRIORI   B1019F.
      B1PSUPP   B1019F.
      B1READAT   B1019F.
      B1SCHSPR   B1019F.
      B1STNDLO   B1019F.
      B1TCHPRN   B1019F.
      B1TEACH   B1019F.
      B1SCHPLC   B1020F.
      B1CNTRLC   B1021F.
      B1TGEND   B1022F.
      B1YRBORN   B1023F.
      B1RACE1   B1024F.
      B1RACE2   B1024F.
      B1RACE3   B1024F.
      B1RACE5   B1024F.
      B1HGHSTD   B1025F.
      B1DEVLP   B1026F.
      B1EARLY   B1026F.
      B1ELEM   B1026F.
      B1ESL   B1026F.
      B1MTHDMA   B1026F.
      B1MTHDRD   B1026F.
      B1MTHDSC   B1026F.
      B1SPECED   B1026F.
      B1TYPCER   B1027F.
      B1ELEMCT   B1028F.
      B1ERLYCT   B1028F.
      B1OTHCRT   B1028F.
      B1YYCOMP   B1029F.
      B1MMCOMP   B1030F.
      B1DDCOMP   B1031F.
      B1TTWPSU   B1TTWPSU.
      B1TTWSTR   B1TTWSTR.
      B1TW0   B1TW0F.
      B1TW10   B1TW10F.
      B1TW11   B1TW11F.
      B1TW12   B1TW12F.
      B1TW13   B1TW13F.
      B1TW14   B1TW14F.
      B1TW15   B1TW15F.
      B1TW16   B1TW16F.
      B1TW17   B1TW17F.
      B1TW18   B1TW18F.
      B1TW19   B1TW19F.
      B1TW1   B1TW1F.
      B1TW20   B1TW20F.
      B1TW21   B1TW21F.
      B1TW22   B1TW22F.
      B1TW23   B1TW23F.
      B1TW24   B1TW24F.
      B1TW25   B1TW25F.
      B1TW26   B1TW26F.
      B1TW27   B1TW27F.
      B1TW28   B1TW28F.
      B1TW29   B1TW29F.
      B1TW2   B1TW2F.
      B1TW30   B1TW30F.
      B1TW31   B1TW31F.
      B1TW32   B1TW32F.
      B1TW33   B1TW33F.
      B1TW34   B1TW34F.
      B1TW35   B1TW35F.
      B1TW36   B1TW36F.
      B1TW37   B1TW37F.
      B1TW38   B1TW38F.
      B1TW39   B1TW39F.
      B1TW3   B1TW3F.
      B1TW40   B1TW40F.
      B1TW41   B1TW41F.
      B1TW42   B1TW42F.
      B1TW43   B1TW43F.
      B1TW44   B1TW44F.
      B1TW45   B1TW45F.
      B1TW46   B1TW46F.
      B1TW47   B1TW47F.
      B1TW48   B1TW48F.
      B1TW49   B1TW49F.
      B1TW4   B1TW4F.
      B1TW50   B1TW50F.
      B1TW51   B1TW51F.
      B1TW52   B1TW52F.
      B1TW53   B1TW53F.
      B1TW54   B1TW54F.
      B1TW55   B1TW55F.
      B1TW56   B1TW56F.
      B1TW57   B1TW57F.
      B1TW58   B1TW58F.
      B1TW59   B1TW59F.
      B1TW5   B1TW5F.
      B1TW60   B1TW60F.
      B1TW61   B1TW61F.
      B1TW62   B1TW62F.
      B1TW63   B1TW63F.
      B1TW64   B1TW64F.
      B1TW65   B1TW65F.
      B1TW66   B1TW66F.
      B1TW67   B1TW67F.
      B1TW68   B1TW68F.
      B1TW69   B1TW69F.
      B1TW6   B1TW6F.
      B1TW70   B1TW70F.
      B1TW71   B1TW71F.
      B1TW72   B1TW72F.
      B1TW73   B1TW73F.
      B1TW74   B1TW74F.
      B1TW75   B1TW75F.
      B1TW76   B1TW76F.
      B1TW77   B1TW77F.
      B1TW78   B1TW78F.
      B1TW79   B1TW79F.
      B1TW7   B1TW7F.
      B1TW80   B1TW80F.
      B1TW81   B1TW81F.
      B1TW82   B1TW82F.
      B1TW83   B1TW83F.
      B1TW84   B1TW84F.
      B1TW85   B1TW85F.
      B1TW86   B1TW86F.
      B1TW87   B1TW87F.
      B1TW88   B1TW88F.
      B1TW89   B1TW89F.
      B1TW8   B1TW8F.
      B1TW90   B1TW90F.
      B1TW9   B1TW9F.
      B2TTWPSU   B2TTWPSU.
      B2TTWSTR   B2TTWSTR.
      B2TW0   B2TW0F.
      B2TW10   B2TW10F.
      B2TW11   B2TW11F.
      B2TW12   B2TW12F.
      B2TW13   B2TW13F.
      B2TW14   B2TW14F.
      B2TW15   B2TW15F.
      B2TW16   B2TW16F.
      B2TW17   B2TW17F.
      B2TW18   B2TW18F.
      B2TW19   B2TW19F.
      B2TW1   B2TW1F.
      B2TW20   B2TW20F.
      B2TW21   B2TW21F.
      B2TW22   B2TW22F.
      B2TW23   B2TW23F.
      B2TW24   B2TW24F.
      B2TW25   B2TW25F.
      B2TW26   B2TW26F.
      B2TW27   B2TW27F.
      B2TW28   B2TW28F.
      B2TW29   B2TW29F.
      B2TW2   B2TW2F.
      B2TW30   B2TW30F.
      B2TW31   B2TW31F.
      B2TW32   B2TW32F.
      B2TW33   B2TW33F.
      B2TW34   B2TW34F.
      B2TW35   B2TW35F.
      B2TW36   B2TW36F.
      B2TW37   B2TW37F.
      B2TW38   B2TW38F.
      B2TW39   B2TW39F.
      B2TW3   B2TW3F.
      B2TW40   B2TW40F.
      B2TW41   B2TW41F.
      B2TW42   B2TW42F.
      B2TW43   B2TW43F.
      B2TW44   B2TW44F.
      B2TW45   B2TW45F.
      B2TW46   B2TW46F.
      B2TW47   B2TW47F.
      B2TW48   B2TW48F.
      B2TW49   B2TW49F.
      B2TW4   B2TW4F.
      B2TW50   B2TW50F.
      B2TW51   B2TW51F.
      B2TW52   B2TW52F.
      B2TW53   B2TW53F.
      B2TW54   B2TW54F.
      B2TW55   B2TW55F.
      B2TW56   B2TW56F.
      B2TW57   B2TW57F.
      B2TW58   B2TW58F.
      B2TW59   B2TW59F.
      B2TW5   B2TW5F.
      B2TW60   B2TW60F.
      B2TW61   B2TW61F.
      B2TW62   B2TW62F.
      B2TW63   B2TW63F.
      B2TW64   B2TW64F.
      B2TW65   B2TW65F.
      B2TW66   B2TW66F.
      B2TW67   B2TW67F.
      B2TW68   B2TW68F.
      B2TW69   B2TW69F.
      B2TW6   B2TW6F.
      B2TW70   B2TW70F.
      B2TW71   B2TW71F.
      B2TW72   B2TW72F.
      B2TW73   B2TW73F.
      B2TW74   B2TW74F.
      B2TW75   B2TW75F.
      B2TW76   B2TW76F.
      B2TW77   B2TW77F.
      B2TW78   B2TW78F.
      B2TW79   B2TW79F.
      B2TW7   B2TW7F.
      B2TW80   B2TW80F.
      B2TW81   B2TW81F.
      B2TW82   B2TW82F.
      B2TW83   B2TW83F.
      B2TW84   B2TW84F.
      B2TW85   B2TW85F.
      B2TW86   B2TW86F.
      B2TW87   B2TW87F.
      B2TW88   B2TW88F.
      B2TW89   B2TW89F.
      B2TW8   B2TW8F.
      B2TW90   B2TW90F.
      B2TW9   B2TW9F.
      KURBAN   LOCALE.
      CREGION   REGIONS.
      S2KMINOR   S2COMP.
      S2KENRLS   S2ENRLS.
      S2KPUPRI   S2PUBPRI.
      S2KSCLVL   S2SCLVL.
      S2KSCTYP   S2SCTYPE.
      CS_TYPE2   SCTYPES.
      A1A2YRK1   SUPPRESS.
      A1A2YRK2   SUPPRESS.
      A1AMULGR   SUPPRESS.
      A1APR1ST   SUPPRESS.
      A1AREGK   SUPPRESS.
      A1AT1ST   SUPPRESS.
      A1AT2ND   SUPPRESS.
      A1AT3RD   SUPPRESS.
      A1ATCHNS   SUPPRESS.
      A1ATFLPN   SUPPRESS.
      A1ATJPNS   SUPPRESS.
      A1ATKRN   SUPPRESS.
      A1ATOTAS   SUPPRESS.
      A1ATOTLG   SUPPRESS.
      A1ATPRE1   SUPPRESS.
      A1ATPREK   SUPPRESS.
      A1ATREGK   SUPPRESS.
      A1ATRNK   SUPPRESS.
      A1ATTRNK   SUPPRESS.
      A1ATVTNM   SUPPRESS.
      A1AUNGR   SUPPRESS.
      A1D2YRK1   SUPPRESS.
      A1D2YRK2   SUPPRESS.
      A1DMULGR   SUPPRESS.
      A1DPR1ST   SUPPRESS.
      A1DREGK   SUPPRESS.
      A1DT1ST   SUPPRESS.
      A1DT2ND   SUPPRESS.
      A1DT3RD   SUPPRESS.
      A1DTCHNS   SUPPRESS.
      A1DTFLPN   SUPPRESS.
      A1DTJPNS   SUPPRESS.
      A1DTKRN   SUPPRESS.
      A1DTOTAS   SUPPRESS.
      A1DTOTLG   SUPPRESS.
      A1DTPRE1   SUPPRESS.
      A1DTPREK   SUPPRESS.
      A1DTREGK   SUPPRESS.
      A1DTRNK   SUPPRESS.
      A1DTTRNK   SUPPRESS.
      A1DTVTNM   SUPPRESS.
      A1DUNGR   SUPPRESS.
      A1P2YRK1   SUPPRESS.
      A1P2YRK2   SUPPRESS.
      A1PMULGR   SUPPRESS.
      A1PPR1ST   SUPPRESS.
      A1PREGK   SUPPRESS.
      A1PT1ST   SUPPRESS.
      A1PT2ND   SUPPRESS.
      A1PT3RD   SUPPRESS.
      A1PTCHNS   SUPPRESS.
      A1PTFLPN   SUPPRESS.
      A1PTJPNS   SUPPRESS.
      A1PTKRN   SUPPRESS.
      A1PTOTAS   SUPPRESS.
      A1PTOTLG   SUPPRESS.
      A1PTPRE1   SUPPRESS.
      A1PTPREK   SUPPRESS.
      A1PTREGK   SUPPRESS.
      A1PTRNK   SUPPRESS.
      A1PTTRNK   SUPPRESS.
      A1PTVTNM   SUPPRESS.
      A1PUNGR   SUPPRESS.
      A2AAUTSM   SUPPRESS.
      A2ACCHNS   SUPPRESS.
      A2ACFLPN   SUPPRESS.
      A2ACJPNS   SUPPRESS.
      A2ACKRN   SUPPRESS.
      A2ACVTNM   SUPPRESS.
      A2ADEAF   SUPPRESS.
      A2ALNGOS   SUPPRESS.
      A2AMULTI   SUPPRESS.
      A2AOTASN   SUPPRESS.
      A2AOTLNG   SUPPRESS.
      A2DAUTSM   SUPPRESS.
      A2DCCHNS   SUPPRESS.
      A2DCFLPN   SUPPRESS.
      A2DCJPNS   SUPPRESS.
      A2DCKRN   SUPPRESS.
      A2DCVTNM   SUPPRESS.
      A2DDEAF   SUPPRESS.
      A2DLNGOS   SUPPRESS.
      A2DMULTI   SUPPRESS.
      A2DOTASN   SUPPRESS.
      A2DOTLNG   SUPPRESS.
      A2PAUTSM   SUPPRESS.
      A2PCCHNS   SUPPRESS.
      A2PCFLPN   SUPPRESS.
      A2PCJPNS   SUPPRESS.
      A2PCKRN   SUPPRESS.
      A2PCVTNM   SUPPRESS.
      A2PDEAF   SUPPRESS.
      A2PLNGOS   SUPPRESS.
      A2PMULTI   SUPPRESS.
      A2POTASN   SUPPRESS.
      A2POTLNG   SUPPRESS.
      B1RACE4   SUPPRESS.
      ;
 */

run;

/*
proc contents;
run;

proc freq;
table 
      KURBAN   
      CREGION   
      CS_TYPE2   
      A1TQUEX   
      A1ACLASS   
      A1PCLASS   
      A1DCLASS   
      B1TQUEX   
      A2TQUEX   
      A2ACLASS   
      A2PCLASS   
      A2DCLASS   
      B2TQUEX   
      S2KSCTYP   
      S2KPUPRI   
      S2KENRLS   
      S2KSCLVL   
      S2KMINOR   
      KGCLASS   
      A1AREGK   
      A1A2YRK1   
      A1A2YRK2   
      A1ATRNK   
      A1APR1ST   
      A1AUNGR   
      A1AMULGR   
      A1ATPREK   
      A1ATTRNK   
      A1ATREGK   
      A1ATPRE1   
      A1AT1ST   
      A1AT2ND   
      A1AT3RD   
      A1APRESC   
      A1APCPRE   
      A1ABEHVR   
      A1AOTLAN   
      A1ACSPNH   
      A1ACVTNM   
      A1ACCHNS   
      A1ACJPNS   
      A1ACKRN   
      A1ACFLPN   
      A1AOTASN   
      A1AOTLNG   
      A1ALANOS   
      A1ALEP   
      A1ATNOOT   
      A1ATSPNH   
      A1ATVTNM   
      A1ATCHNS   
      A1ATJPNS   
      A1ATKRN   
      A1ATFLPN   
      A1ATOTAS   
      A1ATOTLG   
      A1ALEPOS   
      A1ANONEN   
      A1PREGK   
      A1P2YRK1   
      A1P2YRK2   
      A1PTRNK   
      A1PPR1ST   
      A1PUNGR   
      A1PMULGR   
      A1PTPREK   
      A1PTTRNK   
      A1PTREGK   
      A1PTPRE1   
      A1PT1ST   
      A1PT2ND   
      A1PT3RD   
      A1PPRESC   
      A1PPCPRE   
      A1PBEHVR   
      A1POTLAN   
      A1PCSPNH   
      A1PCVTNM   
      A1PCCHNS   
      A1PCJPNS   
      A1PCKRN   
      A1PCFLPN   
      A1POTASN   
      A1POTLNG   
      A1PLANOS   
      A1PLEP   
      A1PTNOOT   
      A1PTSPNH   
      A1PTVTNM   
      A1PTCHNS   
      A1PTJPNS   
      A1PTKRN   
      A1PTFLPN   
      A1PTOTAS   
      A1PTOTLG   
      A1PLEPOS   
      A1PNONEN   
      A1DREGK   
      A1D2YRK1   
      A1D2YRK2   
      A1DTRNK   
      A1DPR1ST   
      A1DUNGR   
      A1DMULGR   
      A1DTPREK   
      A1DTTRNK   
      A1DTREGK   
      A1DTPRE1   
      A1DT1ST   
      A1DT2ND   
      A1DT3RD   
      A1DPRESC   
      A1DPCPRE   
      A1DBEHVR   
      A1DOTLAN   
      A1DCSPNH   
      A1DCVTNM   
      A1DCCHNS   
      A1DCJPNS   
      A1DCKRN   
      A1DCFLPN   
      A1DOTASN   
      A1DOTLNG   
      A1DLANOS   
      A1DLEP   
      A1DTNOOT   
      A1DTSPNH   
      A1DTVTNM   
      A1DTCHNS   
      A1DTJPNS   
      A1DTKRN   
      A1DTFLPN   
      A1DTOTAS   
      A1DTOTLG   
      A1DLEPOS   
      A1DNONEN   
      A1COMPMM   
      A1COMPYY   
      B1WHLCLS   
      B1SMLGRP   
      B1INDVDL   
      B1CHCLDS   
      B1READAR   
      B1LISTNC   
      B1WRTCNT   
      B1PCKTCH   
      B1MATHAR   
      B1PLAYAR   
      B1WATRSA   
      B1COMPAR   
      B1SCIAR   
      B1DRAMAR   
      B1ARTARE   
      B1TOCLAS   
      B1TOSTND   
      B1IMPRVM   
      B1EFFO   
      B1CLASPA   
      B1ATTND   
      B1BEHVR   
      B1COPRTV   
      B1FLLWDR   
      B1OTMT   
      B1EVAL   
      B1PAIDPR   
      B1NOPAYP   
      B1FNSHT   
      B1CNT20   
      B1SHARE   
      B1PRBLMS   
      B1PENCIL   
      B1NOTDSR   
      B1ENGLAN   
      B1SENSTI   
      B1SITSTI   
      B1ALPHBT   
      B1FOLWDR   
      B1IDCOLO   
      B1COMM   
      B1INFOHO   
      B1INKNDR   
      B1SHRTN   
      B1VSTK   
      B1HMEVST   
      B1PRNTOR   
      B1OTTRAN   
      B1ATNDPR   
      B1FRMLIN   
      B1ALPHBF   
      B1LRNREA   
      B1TCHPRN   
      B1PRCTWR   
      B1HMWRK   
      B1READAT   
      B1SCHSPR   
      B1MISBHV   
      B1NOTCAP   
      B1ACCPTD   
      B1CNTNLR   
      B1PAPRWR   
      B1PSUPP   
      B1SCHPLC   
      B1CNTRLC   
      B1STNDLO   
      B1MISSIO   
      B1ALLKNO   
      B1PRESSU   
      B1PRIORI   
      B1ENCOUR   
      B1ENJOY   
      B1MKDIFF   
      B1TEACH   
      B1TGEND   
      B1HISP   
      B1RACE1   
      B1RACE2   
      B1RACE3   
      B1RACE4   
      B1RACE5   
      B1HGHSTD   
      B1EARLY   
      B1ELEM   
      B1SPECED   
      B1ESL   
      B1DEVLP   
      B1MTHDRD   
      B1MTHDMA   
      B1MTHDSC   
      B1TYPCER   
      B1ELEMCT   
      B1ERLYCT   
      B1OTHCRT   
      B1MMCOMP   
      B1YYCOMP   
      A2ARETAR   
      A2AMULTI   
      A2AAUTSM   
      A2ADEAF   
      A2ABEHVR   
      A2AENGLS   
      A2ACSPNH   
      A2ACVTNM   
      A2ACCHNS   
      A2ACJPNS   
      A2ACKRN   
      A2ACFLPN   
      A2AOTASN   
      A2AOTLNG   
      A2ALNGOS   
      A2PRETAR   
      A2PMULTI   
      A2PAUTSM   
      A2PDEAF   
      A2PBEHVR   
      A2PENGLS   
      A2PCSPNH   
      A2PCVTNM   
      A2PCCHNS   
      A2PCJPNS   
      A2PCKRN   
      A2PCFLPN   
      A2POTASN   
      A2POTLNG   
      A2PLNGOS   
      A2DMULTI   
      A2DAUTSM   
      A2DDEAF   
      A2DBEHVR   
      A2DENGLS   
      A2DCSPNH   
      A2DCVTNM   
      A2DCCHNS   
      A2DCJPNS   
      A2DCKRN   
      A2DCFLPN   
      A2DOTASN   
      A2DOTLNG   
      A2DLNGOS   
      A2WHLCLS   
      A2SMLGRP   
      A2INDVDL   
      A2CHCLDS   
      A2COMMTE   
      A2OFTRDL   
      A2TXRDLA   
      A2OFTMTH   
      A2TXMTH   
      A2OFTSOC   
      A2TXSOC   
      A2OFTSCI   
      A2TXSCI   
      A2OFTMUS   
      A2TXMUS   
      A2OFTART   
      A2TXART   
      A2OFTDAN   
      A2TXDAN   
      A2OFTHTR   
      A2TXTHTR   
      A2OFTFOR   
      A2TXFOR   
      A2OFTESL   
      A2TXESL   
      A2TXPE   
      A2TXSPEN   
      A2TXRCE   
      A2LUNCH   
      A2RECESS   
      A2DIVRD   
      A2DIVMTH   
      A2MINRD   
      A2MINMTH   
      A2EXASIS   
      A2AIDTUT   
      A2SPECTU   
      A2PULLOU   
      A2OTASSI   
      A2GOTOLI   
      A2BORROW   
      A2ALANG   
      A2ASPK   
      A2ALVLED   
      A2ACERTF   
      A2PLANG   
      A2PSPK   
      A2PLVLED   
      A2PCERTF   
      A2DLANG   
      A2DSPK   
      A2DLVLED   
      A2DCERTF   
      A2TXTBK   
      A2TRADBK   
      A2WORKBK   
      A2MANIPU   
      A2AUDIOV   
      A2VIDEO   
      A2COMPEQ   
      A2SOFTWA   
      A2PAPER   
      A2DITTO   
      A2ART   
      A2INSTRM   
      A2RECRDS   
      A2LEPMAT   
      A2DISMAT   
      A2HEATAC   
      A2CLSSPC   
      A2FURNIT   
      A2ARTMAT   
      A2MUSIC   
      A2COSTUM   
      A2COOK   
      A2BOOKS   
      A2VCR   
      A2TVWTCH   
      A2PLAYER   
      A2EQUIPM   
      A2LERNLT   
      A2PRACLT   
      A2NEWVOC   
      A2DICTAT   
      A2PHONIC   
      A2SEEPRI   
      A2NOPRNT   
      A2RETELL   
      A2READLD   
      A2BASAL   
      A2SILENT   
      A2WRKBK   
      A2WRTWRD   
      A2INVENT   
      A2CHSBK   
      A2COMPOS   
      A2DOPROJ   
      A2PUBLSH   
      A2SKITS   
      A2JRNL   
      A2TELLRS   
      A2MXDGRP   
      A2PRTUTR   
      A2CONVNT   
      A2RCGNZE   
      A2MATCH   
      A2WRTNME   
      A2RHYMNG   
      A2SYLLAB   
      A2PREPOS   
      A2MAINID   
      A2PREDIC   
      A2TEXTCU   
      A2ORALID   
      A2DRCTNS   
      A2PNCTUA   
      A2COMPSE   
      A2WRTSTO   
      A2SPELL   
      A2VOCAB   
      A2ALPBTZ   
      A2RDFLNT   
      A2INVSPE   
      A2OUTLOU   
      A2GEOMET   
      A2MANIPS   
      A2MTHGME   
      A2CALCUL   
      A2MUSMTH   
      A2CRTIVE   
      A2RULERS   
      A2EXPMTH   
      A2CALEND   
      A2MTHSHT   
      A2MTHTXT   
      A2CHLKBD   
      A2PRTNRS   
      A2REALLI   
      A2MXMATH   
      A2PEER   
      A2QUANTI   
      A21TO10   
      A22S5S10   
      A2BYD100   
      A2W12100   
      A2SHAPES   
      A2IDQNTY   
      A2SUBGRP   
      A2SZORDR   
      A2PTTRNS   
      A2REGZCN   
      A2SNGDGT   
      A2SUBSDG   
      A2PLACE   
      A2TWODGT   
      A23DGT   
      A2MIXOP   
      A2GRAPHS   
      A2DATACO   
      A2FRCTNS   
      A2ORDINL   
      A2ACCURA   
      A2TELLTI   
      A2ESTQNT   
      A2ADD2DG   
      A2CARRY   
      A2SUB2DG   
      A2PRBBTY   
      A2EQTN   
      A2LRNRD   
      A2LRNMTH   
      A2LRNSS   
      A2LRNSCN   
      A2LRNKEY   
      A2LRNART   
      A2LRNMSC   
      A2LRNGMS   
      A2LRNLAN   
      A2BODY   
      A2PLANT   
      A2DINOSR   
      A2SOLAR   
      A2WTHER   
      A2TEMP   
      A2WATER   
      A2SOUND   
      A2LIGHT   
      A2MAGNET   
      A2MOTORS   
      A2TOOLS   
      A2HYGIEN   
      A2HISTOR   
      A2CMNITY   
      A2MAPRD   
      A2CULTUR   
      A2LAWS   
      A2ECOLOG   
      A2GEORPH   
      A2SCMTHD   
      A2SOCPRO   
      A2NUMCNF   
      A2TPCONF   
      A2REGHLP   
      A2ATTOPN   
      A2ATTART   
      A2SNTHME   
      A2SHARED   
      A2LESPLN   
      A2CURRDV   
      A2INDCHD   
      A2DISCHD   
      A2INSRVC   
      A2WRKSHP   
      A2CNSLT   
      A2FDBACK   
      A2SUPPOR   
      A2OBSERV   
      A2RELTIM   
      A2COLLEG   
      A2TECH   
      A2STFFTR   
      A2ADTRND   
      A2INCLUS   
      A2MMCOMP   
      A2YYCOMP   
      A1AKGTYP   
      A1PKGTYP   
      A1DKGTYP   
;
run;

proc means;
var 
      B1TW0   
      B2TW0   
      A1APBLK   
      A1APHIS   
      A1APMIN   
      A1PPBLK   
      A1PPHIS   
      A1PPMIN   
      A1DPBLK   
      A1DPHIS   
      A1DPMIN   
      B1AGE   
      A1AHRSDA   
      A1ADYSWK   
      A1A3YROL   
      A1A4YROL   
      A1A5YROL   
      A1A6YROL   
      A1A7YROL   
      A1A8YROL   
      A1A9YROL   
      A1ATOTAG   
      A1AASIAN   
      A1AHISP   
      A1ABLACK   
      A1AWHITE   
      A1AAMRIN   
      A1ARACEO   
      A1ATOTRA   
      A1ABOYS   
      A1AGIRLS   
      A1AREPK   
      A1ALETT   
      A1AWORD   
      A1ASNTNC   
      A1ANUMLE   
      A1ANOESL   
      A1AESLRE   
      A1AESLOU   
      A1PHRSDA   
      A1PDYSWK   
      A1P3YROL   
      A1P4YROL   
      A1P5YROL   
      A1P6YROL   
      A1P7YROL   
      A1P8YROL   
      A1P9YROL   
      A1PTOTAG   
      A1PASIAN   
      A1PHISP   
      A1PBLACK   
      A1PWHITE   
      A1PAMRIN   
      A1PRACEO   
      A1PTOTRA   
      A1PBOYS   
      A1PGIRLS   
      A1PREPK   
      A1PLETT   
      A1PWORD   
      A1PSNTNC   
      A1PNUMLE   
      A1PNOESL   
      A1PESLRE   
      A1PESLOU   
      A1DHRSDA   
      A1DDYSWK   
      A1D3YROL   
      A1D4YROL   
      A1D5YROL   
      A1D6YROL   
      A1D7YROL   
      A1D8YROL   
      A1D9YROL   
      A1DTOTAG   
      A1DASIAN   
      A1DHISP   
      A1DBLACK   
      A1DWHITE   
      A1DAMRIN   
      A1DRACEO   
      A1DTOTRA   
      A1DBOYS   
      A1DGIRLS   
      A1DREPK   
      A1DLETT   
      A1DWORD   
      A1DSNTNC   
      A1DNUMLE   
      A1DNOESL   
      A1DESLRE   
      A1DESLOU   
      A1COMPDD   
      B1YRBORN   
      B1YRSPRE   
      B1YRSKIN   
      B1YRSFST   
      B1YRS2T5   
      B1YRS6PL   
      B1YRSESL   
      B1YRSBIL   
      B1YRSSPE   
      B1YRSPE   
      B1YRSART   
      B1YRSCH   
      B1DDCOMP   
      A2ANEW   
      A2ALEFT   
      A2AGIFT   
      A2APRTGF   
      A2ARDBLO   
      A2AMTHBL   
      A2ATARDY   
      A2AABSEN   
      A2ADISAB   
      A2AIMPAI   
      A2ALRNDI   
      A2AEMPRB   
      A2ADELAY   
      A2AVIS   
      A2AHEAR   
      A2AORTHO   
      A2AOTHER   
      A2ATRAUM   
      A2AOTDIS   
      A2ASPCIA   
      A2AIEP   
      A2ASC504   
      A2AMORE   
      A2PNEW   
      A2PLEFT   
      A2PGIFT   
      A2PPRTGF   
      A2PRDBLO   
      A2PMTHBL   
      A2PTARDY   
      A2PABSEN   
      A2PDISAB   
      A2PIMPAI   
      A2PLRNDI   
      A2PEMPRB   
      A2PDELAY   
      A2PVIS   
      A2PHEAR   
      A2PORTHO   
      A2POTHER   
      A2PTRAUM   
      A2POTDIS   
      A2PSPCIA   
      A2PIEP   
      A2PSC504   
      A2PMORE   
      A2DNEW   
      A2DLEFT   
      A2DGIFT   
      A2DPRTGF   
      A2DRDBLO   
      A2DMTHBL   
      A2DTARDY   
      A2DABSEN   
      A2DDISAB   
      A2DIMPAI   
      A2DLRNDI   
      A2DEMPRB   
      A2DRETAR   
      A2DDELAY   
      A2DVIS   
      A2DHEAR   
      A2DORTHO   
      A2DOTHER   
      A2DTRAUM   
      A2DOTDIS   
      A2DSPCIA   
      A2DIEP   
      A2DSC504   
      A2DMORE   
      A2DYRECS   
      A2NUMRD   
      A2NUMTH   
      A2MNEXTR   
      A2MNAIDE   
      A2MNSPEC   
      A2MNPOIN   
      A2MNOSHP   
      A2PDAIDE   
      A2REGWRK   
      A2SPEDWK   
      A2ESLWRK   
      A2REGNON   
      A2SPEDNO   
      A2ESLNON   
      A2AVHRS   
      A2PVHRS   
      A2DVHRS   
      A2DDCOMP   
      B1TTWSTR   
      B1TTWPSU   
      B1TW1   
      B1TW2   
      B1TW3   
      B1TW4   
      B1TW5   
      B1TW6   
      B1TW7   
      B1TW8   
      B1TW9   
      B1TW10   
      B1TW11   
      B1TW12   
      B1TW13   
      B1TW14   
      B1TW15   
      B1TW16   
      B1TW17   
      B1TW18   
      B1TW19   
      B1TW20   
      B1TW21   
      B1TW22   
      B1TW23   
      B1TW24   
      B1TW25   
      B1TW26   
      B1TW27   
      B1TW28   
      B1TW29   
      B1TW30   
      B1TW31   
      B1TW32   
      B1TW33   
      B1TW34   
      B1TW35   
      B1TW36   
      B1TW37   
      B1TW38   
      B1TW39   
      B1TW40   
      B1TW41   
      B1TW42   
      B1TW43   
      B1TW44   
      B1TW45   
      B1TW46   
      B1TW47   
      B1TW48   
      B1TW49   
      B1TW50   
      B1TW51   
      B1TW52   
      B1TW53   
      B1TW54   
      B1TW55   
      B1TW56   
      B1TW57   
      B1TW58   
      B1TW59   
      B1TW60   
      B1TW61   
      B1TW62   
      B1TW63   
      B1TW64   
      B1TW65   
      B1TW66   
      B1TW67   
      B1TW68   
      B1TW69   
      B1TW70   
      B1TW71   
      B1TW72   
      B1TW73   
      B1TW74   
      B1TW75   
      B1TW76   
      B1TW77   
      B1TW78   
      B1TW79   
      B1TW80   
      B1TW81   
      B1TW82   
      B1TW83   
      B1TW84   
      B1TW85   
      B1TW86   
      B1TW87   
      B1TW88   
      B1TW89   
      B1TW90   
      B2TTWSTR   
      B2TTWPSU   
      B2TW1   
      B2TW2   
      B2TW3   
      B2TW4   
      B2TW5   
      B2TW6   
      B2TW7   
      B2TW8   
      B2TW9   
      B2TW10   
      B2TW11   
      B2TW12   
      B2TW13   
      B2TW14   
      B2TW15   
      B2TW16   
      B2TW17   
      B2TW18   
      B2TW19   
      B2TW20   
      B2TW21   
      B2TW22   
      B2TW23   
      B2TW24   
      B2TW25   
      B2TW26   
      B2TW27   
      B2TW28   
      B2TW29   
      B2TW30   
      B2TW31   
      B2TW32   
      B2TW33   
      B2TW34   
      B2TW35   
      B2TW36   
      B2TW37   
      B2TW38   
      B2TW39   
      B2TW40   
      B2TW41   
      B2TW42   
      B2TW43   
      B2TW44   
      B2TW45   
      B2TW46   
      B2TW47   
      B2TW48   
      B2TW49   
      B2TW50   
      B2TW51   
      B2TW52   
      B2TW53   
      B2TW54   
      B2TW55   
      B2TW56   
      B2TW57   
      B2TW58   
      B2TW59   
      B2TW60   
      B2TW61   
      B2TW62   
      B2TW63   
      B2TW64   
      B2TW65   
      B2TW66   
      B2TW67   
      B2TW68   
      B2TW69   
      B2TW70   
      B2TW71   
      B2TW72   
      B2TW73   
      B2TW74   
      B2TW75   
      B2TW76   
      B2TW77   
      B2TW78   
      B2TW79   
      B2TW80   
      B2TW81   
      B2TW82   
      B2TW83   
      B2TW84   
      B2TW85   
      B2TW86   
      B2TW87   
      B2TW88   
      B2TW89   
      B2TW90   
;
run;
 */

