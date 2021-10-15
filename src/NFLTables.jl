"""
Provides functions to access NFL data in a tabular format.
"""
module NFLTables

ARTIFACT_TOML = joinpath(splitdir(@__DIR__)[1], "Artifacts.toml")

# include submodules
include("enumerations.jl")
include("schedules.jl")
include("NFLScrapRData.jl")
include("NFLFastR.jl")

# export the API
export POST, PRE, REG, SeasonPart, SuperBowl
# export submodules
export NFLFastR, NFLScrapR, Schedules

end # module
