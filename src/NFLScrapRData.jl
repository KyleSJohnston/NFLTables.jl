"""
Module to access nflscrapR-data files

See https://github.com/ryurko/nflscrapR-data/ for additional data documentation.
"""
module NFLScrapR

using  CSV
using  DataFrames
using  Downloads
using  Logging
using  Scratch: @get_scratch!
using  ..NFLTables: POST, PRE, REG, SeasonPart

export getgamedata, getplaydata


"""
seasons with nflscrapR data
"""
const SEASONS = tuple(2009:2019...)

"""
The root of the nflscrapR-data GitHub repo, after the raw redirect.
"""
const REPOROOT = "https://github.com/ryurko/nflscrapR-data/raw/master/"


function getlocalpath(datatype::Symbol, seasonpart::SeasonPart, season::Integer)::String
    datatype === :games || datatype === :play_by_play || error("Invalid datatype $datatype")
    season in SEASONS || error("Invalid season $season")
    shortdata = datatype === :play_by_play ? "pbp" : string(datatype)
    shortpart = seasonpart |> string |> lowercase
    return "$(shortpart)_$(shortdata)_$season.csv"
end

function getremotepath(datatype::Symbol, seasonpart::SeasonPart, season::Integer)::String
    seasonfolder = seasonpart === REG ? "regular_season" : "$(lowercase(string(seasonpart)))_season"
    return joinpath("$(datatype)_data", seasonfolder, getlocalpath(datatype, seasonpart, season))
end


function load_data_from_disk(datatype::Symbol, seasonpart::SeasonPart, season::Integer; redownload=false, reporoot=REPOROOT)
    dirpath = @get_scratch!("nflscrapR")
    localpath = joinpath(dirpath, getlocalpath(datatype, seasonpart, season))
    if redownload || !isfile(localpath)
        remotepath = joinpath(reporoot, getremotepath(datatype, seasonpart, season))
        @info "downloading..." remotepath localpath
        Downloads.download(remotepath, localpath)
    end
    return DataFrame(CSV.File(localpath, missingstring="NA"))
end

"""
    getplaydata(season::Integer, part::SeasonPart)

Create a dataframe of play-by-play data for `part` of `season`.

# Examples
```jldoctest
julia> df = getplaydata(2018, POST);

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
getplaydata(season::Integer, part::SeasonPart) = load_data_from_disk(:play_by_play, part, season)
getplaydata(season::Integer, part::String) = getplaydata(season, parse(SeasonPart, part))

"""
    getgamedata(season::Integer, part::SeasonPart)

Create a dataframe of game data for `part` of `season`.

# Examples
```jldoctest
julia> df = getgamedata(2018, POST);

julia> df[end, [:game_id, :home_team, :home_score, :away_team, :away_score]]
DataFrameRow
│ Row │ game_id    │ home_team │ home_score │ away_team │ away_score │
│     │ Int64      │ String    │ Int64      │ String    │ Int64      │
├─────┼────────────┼───────────┼────────────┼───────────┼────────────┤
│ 12  │ 2019020300 │ LA        │ 3          │ NE        │ 13         │

```
"""
getgamedata(season::Integer, part::SeasonPart) = load_data_from_disk(:games, part, season)
getgamedata(season::Integer, part::String) = getgamedata(season, parse(SeasonPart, part))

end  # module NFLScrapR

# to support legacy calls
nflscraprRgame = NFLScrapR.getgamedata
nflscrapRplaybyplay = NFLScrapR.getplaydata
