"""
Provides functions to access NFL data in a tabular format.
"""
module NFLTables

ARTIFACT_TOML = joinpath(splitdir(@__DIR__)[1], "Artifacts.toml")

# include submodules
include("enumerations.jl")
include("artifacts.jl")  # required for schedule and nflscrapR data
include("schedules.jl")
include("NFLScrapRData.jl")
include("NFLFastR.jl")

# export the API
export nflscrapRplaybyplay, nflscrapRgame, POST, PRE, REG, nflschedule, SeasonPart, SuperBowl

end # module
