"""
Module to access nflscrapR-data files

See https://github.com/ryurko/nflscrapR-data/ for additional data documentation.
"""
module NFLScrapR

using  CSV
using  DataFrames
using  Logging
using  Pkg.Artifacts
using  Downloads
using  ..NFLTables: ARTIFACT_TOML, POST, PRE, REG, SeasonPart

export getgamedata, getplaydata

function __init__()
    try
        download_artifact()
    catch e
        @warn "Unable to download artifacts; functionality will be limited until you run NFLScrapR.download_artifact"
    end
end

"""
seasons with nflscrapR data
"""
const SEASONS = tuple(2009:2019...)

"""
The root of the nflscrapR-data GitHub repo, after the raw redirect.
"""
const REPOROOT = "https://github.com/ryurko/nflscrapR-data/raw/master/"


function getfilepath(datatype::String, seasonpart::SeasonPart, season::Integer)::String
    datatype in ("games", "play_by_play") || error("Invalid datatype $datatype")
    shortdata = datatype == "play_by_play" ? "pbp" : datatype
    shortpart = seasonpart |> string |> lowercase
    return "$(shortpart)_$(shortdata)_$season.csv"
end
function getfilepath(datatype::String, seasonpart::String, season::Integer)::String
    sp = parse(SeasonPart, seasonpart == "regular" ? "reg" : seasonpart)
    return getfilepath(datatype, sp, season)
end

getseasonfolder(seasonpart::SeasonPart) = seasonpart === REG ? "regular_season" : "$(lowercase(string(seasonpart)))_season"

"""
    download_data(dir; redownload=false, reporoot=REPOROOT)

Download nflscrapR data to `dir` (overwrite existing if `redownload` is true)
"""
function download_data(dir; redownload=false, reporoot=REPOROOT)
    for datatype in ("games", "play_by_play")
        for seasonpart in (PRE, REG, POST)
            for season in SEASONS
                filepath = getfilepath(datatype, seasonpart, season)
                remotepath = joinpath(reporoot, "$(datatype)_data", getseasonfolder(seasonpart), filepath)
                localpath = joinpath(dir, filepath)
                if redownload || !isfile(localpath)
                    @info "downloading..." remotepath localpath
                    Downloads.download(remotepath, localpath)
                end
            end
        end
    end
end

"""
    download_artifact(; redownload=false, reporoot=REPOROOT)

Download all nflscrapR data and store as an artifact (overwrite existing with `redownload=true`)
"""
function download_artifact(; redownload=false, reporoot=REPOROOT)
    hash = artifact_hash("nflscrapR", ARTIFACT_TOML)  # or nothing

    if redownload || isnothing(hash) || !artifact_exists(hash)
        @info "Creating new nflscrapR artifact"
        hash = create_artifact() do artifact_dir
            download_data(artifact_dir; reporoot)
        end
        @info "Download complete; updating Artifacts.toml"
        bind_artifact!(ARTIFACT_TOML, "nflscrapR", hash, force=true)
    else
        @info "nflscrapR artifact already downloaded"
    end
end



function load_data_from_disk(path)
    artifact_dir = try
        artifact"nflscrapR"
    catch e
        if isa(e, LoadError)
            @error "Artifact data has not been downloaded; run NFLScrapR.download_artifact to fix"
        end
        rethrow()
    end
    filepath = joinpath(artifact_dir, path)
    return DataFrame(CSV.File(filepath, missingstring="NA"))
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
function getplaydata(season::Integer, part::SeasonPart)
    season in SEASONS || error("Invalid season $season")
    return load_data_from_disk(getfilepath("play_by_play", part, season))
end
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
function getgamedata(season::Integer, part::SeasonPart)
    season in SEASONS || error("Invalid season $season")
    return load_data_from_disk(getfilepath("games", part, season))
end
getgamedata(season::Integer, part::String) = getgamedata(season, parse(SeasonPart, part))

end  # module NFLScrapR

# to support legacy calls
nflscraprRgame = NFLScrapR.getgamedata
nflscrapRplaybyplay = NFLScrapR.getplaydata
