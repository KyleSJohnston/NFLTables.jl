module Enumerations

import Base.parse

"""
Parts of a single season
"""
@enum SeasonPart PRE REG POST

function Base.parse(SeasonPart, str)
    m = Dict([string(e) => e for e in instances(Enumerations.SeasonPart)]...)
    return m[str]
end

"""
An enumeration of the SuperBowls as stylized/marketed (with the season as the value)
"""
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
