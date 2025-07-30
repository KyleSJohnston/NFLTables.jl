"""
Provides functions to access NFL data in a tabular format.
"""
module NFLTables

using Logging

# include submodules
include("enumerations.jl")

# export the API
export POST, PRE, REG, SeasonPart, SuperBowl

function __init__()
    @warn "NFLTables.jl is deprecated. Please use NFLData.jl instead."
end

end # module
