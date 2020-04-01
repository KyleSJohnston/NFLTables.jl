module NFLTables

# include submodules
include("artifacts.jl")
include("enumerations.jl")
include("schedules.jl")
include("NFLScrapRData.jl")

# import API components from submodules
using  .NFLScrapRData: nflscrapRgame, nflscrapRplaybyplay
using  .Schedules: nflschedule
using  .Enumerations: POST, PRE, REG, SeasonPart, SuperBowl

# export the relevant API
export nflscrapRplaybyplay, nflscrapRgame, POST, PRE, REG, nflschedule, SeasonPart, SuperBowl

end # module
