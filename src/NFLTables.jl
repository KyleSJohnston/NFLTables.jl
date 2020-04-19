"""
Provides functions to access NFL data in a tabular format.
"""
module NFLTables

using  CSV
using  DataFrames

# include submodules
include("enumerations.jl")
include("artifacts.jl")  # required for schedule and nflscrapR data
include("schedules.jl")
include("NFLScrapRData.jl")

# export the API
export nflscrapRplaybyplay, nflscrapRgame, POST, PRE, REG, nflschedule, SeasonPart, SuperBowl

end # module
