"""
Provides functions to access NFL data in a tabular format.
"""
module NFLTables

# include submodules
include("artifacts.jl")
include("enumerations.jl")
include("schedules.jl")
include("NFLScrapRData.jl")

# import API components from submodules
using  .NFLScrapRData: nflscrapRgame, nflscrapRplaybyplay
using  .Schedules: nflschedule

# export the relevant API
export nflscrapRplaybyplay, nflscrapRgame, POST, PRE, REG, nflschedule, SeasonPart, SuperBowl


"""
Obtain the NFL schedule for `season` (optionally force a `redownload`)
"""
const nflsked = nflschedule

end # module
