"""
Module to access nflscrapR-data files

See https://github.com/ryurko/nflscrapR-data/ for additional data documentation.
"""
module NFLScrapRData

using  CSV
using  DataFrames
import NFLTables
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
const REPOROOT = "https://raw.githubusercontent.com/ryurko/nflscrapR-data/master/"

"""
Artifacts are entire directories of data, so we should have one NFLScrapR
directory for each year (tradeoff between amount of data and likelihood of change).
"""
function season_artifact(season::Season; redownload::Bool=false)
    validseason(season) || error("Invalid season: $season")
    name = "nflscrapR_$(Int(season))"
    path = NFLTables.Artifacts.get(name) do artifact_dir
        for part in seasonparts(season)
            gamepath = joinpath(
                REPOROOT,
                "games_data",
                "$(partaliases[part])_season",
                "$(part)_games_$(Int(season)).csv"
            )
            download(gamepath, joinpath(artifact_dir, "game_$(part).csv"))
            playbyplaypath = joinpath(
                REPOROOT,
                "play_by_play_data",
                "$(partaliases[part])_season",
                "$(part)_pbp_$(Int(season)).csv"
            )
            download(playbyplaypath, joinpath(artifact_dir, "pbp_$(part).csv"))
        end
    end
    return path
end

season_artifact(season::Int; redownload::Bool=false) = season_artifact(Season(season), redownload=redownload)

end  # module NFLScrapRData
