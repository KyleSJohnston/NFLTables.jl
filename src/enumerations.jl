module Enumerations

export Season, SeasonPart, SuperBowl

"""
parts of a single season
"""
@enum SeasonPart pre reg post

@enum Season begin
    S1970 = 1970
    S1971 = 1971
    S1972 = 1972
    S1973 = 1973
    S1974 = 1974
    S1975 = 1975
    S1976 = 1976
    S1977 = 1977
    S1978 = 1978
    S1979 = 1979
    S1980 = 1980
    S1981 = 1981
    S1982 = 1982
    S1983 = 1983
    S1984 = 1984
    S1985 = 1985
    S1986 = 1986
    S1987 = 1987
    S1988 = 1988
    S1989 = 1989
    S1990 = 1990
    S1991 = 1991
    S1992 = 1992
    S1993 = 1993
    S1994 = 1994
    S1995 = 1995
    S1996 = 1996
    S1997 = 1997
    S1998 = 1998
    S1999 = 1999
    S2000 = 2000
    S2001 = 2001
    S2002 = 2002
    S2003 = 2003
    S2004 = 2004
    S2005 = 2005
    S2006 = 2006
    S2007 = 2007
    S2008 = 2008
    S2009 = 2009
    S2010 = 2010
    S2011 = 2011
    S2012 = 2012
    S2013 = 2013
    S2014 = 2014
    S2015 = 2015
    S2016 = 2016
    S2017 = 2017
    S2018 = 2018
    S2019 = 2019
end

@enum SuperBowl begin
    SB_I       = 1966
    SB_II      = 1967
    SB_III     = 1968
    SB_IV      = 1969
    SB_V       = 1970
    SB_VI      = 1971
    SB_VII     = 1972
    SB_VIII    = 1973
    SB_IX      = 1974
    SB_X       = 1975
    SB_XI      = 1976
    SB_XII     = 1977
    SB_XIII    = 1978
    SB_XIV     = 1979
    SB_XV      = 1980
    SB_XVI     = 1981
    SB_XVII    = 1982
    SB_XVIII   = 1983
    SB_XIX     = 1984
    SB_XX      = 1985
    SB_XXI     = 1986
    SB_XXII    = 1987
    SB_XXIII   = 1988
    SB_XXIV    = 1989
    SB_XXV     = 1990
    SB_XXVI    = 1991
    SB_XXVII   = 1992
    SB_XXVIII  = 1993
    SB_XXIX    = 1994
    SB_XXX     = 1995
    SB_XXXI    = 1996
    SB_XXXII   = 1997
    SB_XXXIII  = 1998
    SB_XXXIV   = 1999
    SB_XXXV    = 2000
    SB_XXXVI   = 2001
    SB_XXXVII  = 2002
    SB_XXXVIII = 2003
    SB_XXXIX   = 2004
    SB_XL      = 2005
    SB_XLI     = 2006
    SB_XLII    = 2007
    SB_XLIII   = 2008
    SB_XLIV    = 2009
    SB_XLV     = 2010
    SB_XLVI    = 2011
    SB_XLVII   = 2012
    SB_XLVIII  = 2013
    SB_XLIX    = 2014
    SB_50      = 2015
    SB_LI      = 2016
    SB_LII     = 2017
    SB_LIII    = 2018
    SB_LIV     = 2019
    # SB_LV      = 2020
    # SB_LVI     = 2021
    # SB_LVII    = 2022
    # SB_LVIII   = 2023
end

end  # module Enumerations
