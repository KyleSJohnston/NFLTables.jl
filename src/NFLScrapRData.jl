"""
Module to access nflscrapR-data files

See https://github.com/ryurko/nflscrapR-data/ for additional data documentation.
"""
module NFLScrapRData

using  CSV
using  DataFrames
using  HTTP

export game, playbyplay

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
    playbyplaypath(season::Int, part::AbstractString; root::AbstractString=reporoot)

Create a string representing the path play-by-play data for `part` of `season`.
Supplying a value for `root` will override the default, allowing users to
reference a local clone of the nflscrapR-data repository.
"""
function playbyplaypath(season::Int, part::AbstractString; root::AbstractString=reporoot)
    haskey(partaliases, part) || error("invalid part: $(part)")
    return joinpath(root, "play_by_play_data", "$(partaliases[part])_season", "$(part)_pbp_$(season).csv")
end

"""
    gamepath(season::Int, part::AbstractString; root::AbstractString=reporoot)

Create a string representing the path to game data for `part` of `season`.
Supplying a value for `root` will override the default, allowing users to
reference a local clone of the nflscrapR-data repository.
"""
function gamepath(season::Int, part::AbstractString; root::AbstractString=reporoot)
    haskey(partaliases, part) || error("invalid part: $(part)")
    return joinpath(root, "games_data", "$(partaliases[part])_season", "$(part)_games_$(season).csv")
end

function load(path::AbstractString)
    if occursin(r"^http(s)?://", path)
        source = HTTP.get(path).body
        return CSV.File(source; missingstring="NA") |> DataFrame!
    else
        return CSV.File(path; missingstring="NA") |> DataFrame!
    end
end


"""
    playbyplay(season::Int, part::AbstractString; root::AbstractString=reporoot)

Create a dataframe of play-by-play data for `part` of `season`.
Supplying a value for `root` will override the default, allowing users to
reference a local clone of the nflscrapR-data repository.
"""
function playbyplay(season::Int, part::AbstractString; root::AbstractString=reporoot)
    return load(playbyplaypath(season, part, root=root))
end

"""
    game(season::Int, part::AbstractString; root::AbstractString=reporoot)

Create a dataframe of game data for `part` of `season`.
Supplying a value for `root` will override the default, allowing users to
reference a local clone of the nflscrapR-data repository.
"""
function game(season::Int, part::AbstractString; root::AbstractString=reporoot)
    return load(gamepath(season, part, root=root))
end


end  # module NFLScrapRData
