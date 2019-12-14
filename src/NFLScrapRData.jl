"""
Module to access nflscrapR-data files

See https://github.com/ryurko/nflscrapR-data/ for additional data documentation.
"""
module NFLScrapRData

export gamepath, playbyplaypath

"""
The root of the nflscrapR-data GitHub repo, after the raw redirect.
"""
const reporoot = "https://raw.githubusercontent.com/ryurko/nflscrapR-data/master/"

"""
Aliases for the parts of the season
"""
const partaliases = Dict(
    "pre" => "pre", "reg" => "regular", "post" => "post"
)

"""
    playbyplaypath(season::Int, part::AbstractString; reporoot::AbstractString=reporoot)

Create a string representing the path play-by-play data for `part` of `season`.
Supplying a value for `reporoot` will override the default, allowing users to
reference a local checkout.
"""
function playbyplaypath(season::Int, part::AbstractString; reporoot::AbstractString=reporoot)
    haskey(partaliases, part) || error("invalid part: $(part)")
    return joinpath(reporoot, "play_by_play_data", "$(partaliases[part])_season", "$(part)_pbp_$(season).csv")
end

"""
    gamepath(season::Int, part::AbstractString; reporoot::AbstractString=reporoot)

Create a string representing the path to game data for `part` of `season`.
Supplying a value for `reporoot` will override the default, allowing users to
reference a local checkout.
"""
function gamepath(season::Int, part::AbstractString; reporoot::AbstractString=reporoot)
    haskey(partaliases, part) || error("invalid part: $(part)")
    return joinpath(reporoot, "games_data", "$(partaliases[part])_season", "$(part)_games_$(season).csv")
end

end  # module NFLScrapRData
