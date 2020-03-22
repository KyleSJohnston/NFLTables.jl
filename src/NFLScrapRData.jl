"""
Module to access nflscrapR-data files

See https://github.com/ryurko/nflscrapR-data/ for additional data documentation.
"""
module NFLScrapRData

using  CSV
using  DataFrames
using  Pkg.Artifacts
using  ..Enumerations

export game, playbyplay, seasons, seasonparts, validseason, validpart

"""
seasons with nflscrapR data
"""
const SEASONS = tuple([Season(yr) for yr in 2009:2019]...)

"""
returns true if `season` is valid
"""
function validseason(season::Season)
    return season in SEASONS
end

"""
return an array of season parts for a valid season
"""
function seasonparts(season::Season)
    validseason(season) || error("Invalid season: $season")
    # if season == 2020:
    #     return (pre,)
    # end
    return instances(SeasonPart)
end

"""
returns true if `part` is valid for `season`
"""
function validpart(season::Season, part::SeasonPart)
    return part in seasonparts(season)
end

"""
    playbyplay(season::Int, part::SeasonPart)

Create a dataframe of play-by-play data for `part` of `season`.
Supplying a value for `root` will override the default, allowing users to
reference a local clone of the nflscrapR-data repository.
"""
function playbyplay(season::Season, part::SeasonPart)
    validpart(season, part) || error("Invalid part ($part) for season $season")
    path = season_artifact(season)
    return CSV.File(joinpath(path, "pbp_$part.csv"), missingstring="NA") |> DataFrame!
end

"""
    game(season::Season, part::SeasonPart)

Create a dataframe of game data for `part` of `season`.
Supplying a value for `root` will override the default, allowing users to
reference a local clone of the nflscrapR-data repository.
"""
function game(season::Season, part::SeasonPart)
    validpart(season, part) || error("Invalid part ($part) for season $season")
    path = season_artifact(season)
    return CSV.File(joinpath(path, "game_$part.csv"), missingstring="NA") |> DataFrame!
end

const artifact_toml = joinpath(@__DIR__, "..", "Artifacts.toml")

"""
Aliases for the parts of the season
"""
const partaliases = Dict{SeasonPart,AbstractString}(
    Enumerations.pre => "pre",
    Enumerations.reg => "regular",
    Enumerations.post => "post"
)

"""
The root of the nflscrapR-data GitHub repo, after the raw redirect.
"""
const reporoot = "https://raw.githubusercontent.com/ryurko/nflscrapR-data/master/"

"""
    playbyplaypath(season::Season, part::SeasonPart; root::AbstractString=reporoot)

Create a string representing the path play-by-play data for `part` of `season`.
Supplying a value for `root` will override the default, allowing users to
reference a local clone of the nflscrapR-data repository.
"""
function playbyplaypath(season::Season, part::SeasonPart; root::AbstractString=reporoot)
    haskey(partaliases, part) || error("invalid part: $(part)")
    return joinpath(root, "play_by_play_data", "$(partaliases[part])_season", "$(part)_pbp_$(Int(season)).csv")
end

"""
    gamepath(season::Season, part::SeasonPart; root::AbstractString=reporoot)

Create a string representing the path to game data for `part` of `season`.
Supplying a value for `root` will override the default, allowing users to
reference a local clone of the nflscrapR-data repository.
"""
function gamepath(season::Season, part::SeasonPart; root::AbstractString=reporoot)
    haskey(partaliases, part) || error("invalid part: $(part)")
    return joinpath(root, "games_data", "$(partaliases[part])_season", "$(part)_games_$(Int(season)).csv")
end

"""
Adapted from https://julialang.github.io/Pkg.jl/v1/artifacts/#Using-Artifacts-1

Artifacts are entire directories of data, so we should have one NFLScrapR
directory for each year (tradeoff between amount of data and likelihood of change).
"""
function season_artifact(season::Season; redownload::Bool=false, root::AbstractString=reporoot)
    validseason(season) || error("Invalid season: $season")
    an = "nflscrapR_$(Int(season))"
    ah = artifact_hash(an, artifact_toml)
    # If the name was not bound, or the hash it was bound to does not exist, create it!
    if redownload || ah == nothing || !artifact_exists(ah)
        # create_artifact() returns the content-hash of the artifact directory once we're finished creating it
        ah = create_artifact() do artifact_dir
            # We create the artifact by simply downloading a few files into the new artifact directory
            for part in seasonparts(season)
                download(gamepath(season, part, root=root), joinpath(artifact_dir, "game_$(part).csv"))
                download(playbyplaypath(season, part, root=root), joinpath(artifact_dir, "pbp_$(part).csv"))
            end
        end

        bind_artifact!(artifact_toml, an, ah, force=true)
    end
    return artifact_path(ah)
end

season_artifact(season::Int; redownload::Bool=false, root::AbstractString=reporoot) = season_artifact(Season(season), redownload=redownload, root=root)

end  # module NFLScrapRData
