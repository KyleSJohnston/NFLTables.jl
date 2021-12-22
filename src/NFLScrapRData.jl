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
    getplaydata(season, part)

Create a dataframe of play-by-play data for `part` of `season`.

# Examples
```jldoctest
julia> df = NFLScrapR.getplaydata(2019, "POST");

julia> first(df[:, [:game_id, :home_team, :away_team, :yardline_100, :half_seconds_remaining]], 5)
5×5 DataFrame
 Row │ game_id     home_team  away_team  yardline_100  half_seconds_remaining
     │ Int64       String3…   String3…   Int64?        Int64
─────┼────────────────────────────────────────────────────────────────────────
   1 │ 2020012600  APR        NPR                  75                    1800
   2 │ 2020012600  APR        NPR                  75                    1776
   3 │ 2020012600  APR        NPR                  80                    1757
   4 │ 2020012600  APR        NPR                  71                    1715
   5 │ 2020012600  APR        NPR                  71                    1709

```
"""
getplaydata(season::Integer, part::SeasonPart) = load_data_from_disk(:play_by_play, part, season)
getplaydata(season::Integer, part::String) = getplaydata(season, parse(SeasonPart, part))

"""
    getgamedata(season, part)

Create a dataframe of game data for `part` of `season`.

# Examples
```jldoctest
julia> df = NFLScrapR.getgamedata(2019, "POST");

julia> first(df[:, [:game_id, :home_team, :away_team, :home_score, :away_score]], 5)
5×5 DataFrame
 Row │ game_id     home_team  away_team  home_score  away_score
     │ Int64       String3…   String3…   Int64?      Int64?
─────┼──────────────────────────────────────────────────────────
   1 │ 2020012600  APR        NPR           missing     missing
   2 │ 2020010400  HOU        BUF                22          19
   3 │ 2020010401  NE         TEN                13          20
   4 │ 2020010500  NO         MIN                20          26
   5 │ 2020010501  PHI        SEA                 9          17

```
"""
getgamedata(season::Integer, part::SeasonPart) = load_data_from_disk(:games, part, season)
getgamedata(season::Integer, part::String) = getgamedata(season, parse(SeasonPart, part))

end  # module NFLScrapR

# to support legacy calls
nflscraprRgame = NFLScrapR.getgamedata
nflscrapRplaybyplay = NFLScrapR.getplaydata
