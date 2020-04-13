"""
Module to access nflscrapR-data files

See https://github.com/ryurko/nflscrapR-data/ for additional data documentation.
"""
module NFLScrapRData

using  NFLTables: getartifact, POST, PRE, REG, SeasonPart

"""
seasons with nflscrapR data
"""
const SEASONS = tuple(2009:2019...)

"""
    hasdata(season::Integer)

return true if `season` has data
"""
function hasdata(season::Integer)
    return 2009 <= season <= 2019
end

"""
return an array of season parts for a valid season
"""
function seasonparts(season::Integer)
    hasdata(season) || error("Invalid season: $season")
    # if season == 2020:
    #     return (PRE,)
    # end
    return instances(SeasonPart)
end

"""
    hasdata(season::Integer, part::SeasonPart)

returns true if `part` is valid for `season`
"""
function hasdata(season::Integer, part::SeasonPart)
    return part in seasonparts(season)
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
    hasdata(season) || error("Invalid season: $season")
    name = "nflscrapR_$(season)"
    path = getartifact(name) do artifact_dir
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


"""
    nflscrapRplaybyplay(season::Integer, part::SeasonPart)

Create a dataframe of play-by-play data for `part` of `season`.

# Examples
```jldoctest
julia> df = nflscrapRplaybyplay(2018, POST);

julia> first(df, 5)
5×256 DataFrames.DataFrame. Omitted printing of 244 columns
│ Row │ play_id │ game_id    │ home_team │ away_team │ posteam │ posteam_type │ defteam │ side_of_field │ yardline_100 │ game_date  │ quarter_seconds_remaining │ half_seconds_remaining │
│     │ Int64   │ Int64      │ String    │ String    │ String⍰ │ String⍰      │ String⍰ │ String        │ Int64⍰       │ Dates.Date │ Int64                     │ Int64                  │
├─────┼─────────┼────────────┼───────────┼───────────┼─────────┼──────────────┼─────────┼───────────────┼──────────────┼────────────┼───────────────────────────┼────────────────────────┤
│ 1   │ 36      │ 2019010500 │ HOU       │ IND       │ IND     │ away         │ HOU     │ HOU           │ 35           │ 2019-01-05 │ 900                       │ 1800                   │
│ 2   │ 51      │ 2019010500 │ HOU       │ IND       │ IND     │ away         │ HOU     │ IND           │ 75           │ 2019-01-05 │ 900                       │ 1800                   │
│ 3   │ 76      │ 2019010500 │ HOU       │ IND       │ IND     │ away         │ HOU     │ IND           │ 75           │ 2019-01-05 │ 860                       │ 1760                   │
│ 4   │ 98      │ 2019010500 │ HOU       │ IND       │ IND     │ away         │ HOU     │ IND           │ 77           │ 2019-01-05 │ 814                       │ 1714                   │
│ 5   │ 123     │ 2019010500 │ HOU       │ IND       │ IND     │ away         │ HOU     │ IND           │ 65           │ 2019-01-05 │ 774                       │ 1674                   │

```
"""
function nflscrapRplaybyplay(season::Integer, part::SeasonPart)
    NFLScrapRData.hasdata(season, part) || error("Invalid part ($part) for season $season")
    path = NFLScrapRData.season_artifact(season)
    return CSV.File(joinpath(path, "pbp_$(lowercase(string(part))).csv"), missingstring="NA") |> DataFrame!
end

"""
    nflscrapRgame(season::Integer, part::SeasonPart)

Create a dataframe of game data for `part` of `season`.

# Examples
```jldoctest
julia> df = nflscrapRgame(2018, POST);

julia> df[end, [:game_id, :home_team, :home_score, :away_team, :away_score]]
DataFrameRow
│ Row │ game_id    │ home_team │ home_score │ away_team │ away_score │
│     │ Int64      │ String    │ Int64      │ String    │ Int64      │
├─────┼────────────┼───────────┼────────────┼───────────┼────────────┤
│ 12  │ 2019020300 │ LA        │ 3          │ NE        │ 13         │

```
"""
function nflscrapRgame(season::Integer, part::SeasonPart)
    NFLScrapRData.hasdata(season, part) || error("Invalid part ($part) for season $season")
    path = NFLScrapRData.season_artifact(season)
    return CSV.File(joinpath(path, "game_$(lowercase(string(part))).csv"), missingstring="NA") |> DataFrame!
end
