"""
Module to access nflscrapR-data files

See https://github.com/ryurko/nflscrapR-data/ for additional data documentation.
"""
module NFLScrapRData

using  CSV
using  DataFrames

import ..Artifacts
using  ..Enumerations: POST, PRE, REG, SeasonPart

"""
seasons with nflscrapR data
"""
const SEASONS = tuple(2009:2019...)

"""
returns true if `season` is valid
"""
function validseason(season::Integer)
    return 2009 <= season <= 2019
end

"""
return an array of season parts for a valid season
"""
function seasonparts(season::Integer)
    validseason(season) || error("Invalid season: $season")
    # if season == 2020:
    #     return (PRE,)
    # end
    return instances(SeasonPart)
end

"""
returns true if `part` is valid for `season`
"""
function validpart(season::Integer, part::SeasonPart)
    return part in seasonparts(season)
end

"""
Create a dataframe of play-by-play data for `part` of `season`.
"""
function nflscrapRplaybyplay(season::Integer, part::SeasonPart)
    validpart(season, part) || error("Invalid part ($part) for season $season")
    path = season_artifact(season)
    return CSV.File(joinpath(path, "pbp_$(lowercase(string(part))).csv"), missingstring="NA") |> DataFrame!
end

"""
Create a dataframe of game data for `part` of `season`.
"""
function nflscrapRgame(season::Integer, part::SeasonPart)
    validpart(season, part) || error("Invalid part ($part) for season $season")
    path = season_artifact(season)
    return CSV.File(joinpath(path, "game_$(lowercase(string(part))).csv"), missingstring="NA") |> DataFrame!
end

"""
Aliases for the parts of the season
"""
const partaliases = Dict{SeasonPart,AbstractString}(
    PRE => "pre", REG => "regular", POST => "post"
)

"""
The root of the nflscrapR-data GitHub repo, after the raw redirect.
"""
const REPOROOT = "https://raw.githubusercontent.com/ryurko/nflscrapR-data/master/"

"""
Artifacts are entire directories of data, so we should have one NFLScrapR
directory for each year (tradeoff between amount of data and likelihood of change).
"""
function season_artifact(season::Integer; redownload::Bool=false)
    validseason(season) || error("Invalid season: $season")
    name = "nflscrapR_$(season)"
    path = Artifacts.get(name) do artifact_dir
        for part in seasonparts(season)
            gamepath = joinpath(
                REPOROOT,
                "games_data",
                "$(partaliases[part])_season",
                "$(lowercase(string(part)))_games_$(season).csv"
            )
            download(gamepath, joinpath(artifact_dir, "game_$(lowercase(string(part))).csv"))
            playbyplaypath = joinpath(
                REPOROOT,
                "play_by_play_data",
                "$(partaliases[part])_season",
                "$(lowercase(string(part)))_pbp_$(season).csv"
            )
            download(playbyplaypath, joinpath(artifact_dir, "pbp_$(lowercase(string(part))).csv"))
        end
    end
    return path
end

end  # module NFLScrapRData
