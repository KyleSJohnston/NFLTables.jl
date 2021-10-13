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

"""
seasons with nflscrapR data
"""
const SEASONS = tuple(2009:2019...)

"""
The root of the nflscrapR-data GitHub repo, after the raw redirect.
"""
const REPOROOT = "https://raw.githubusercontent.com/ryurko/nflscrapR-data/master/"


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

"""
    download_data(dir; redownload=false, reporoot=REPOROOT)

Download nflscrapR data to `dir` (overwrite existing if `redownload` is true)
"""
function download_data(dir; redownload=false, reporoot=REPOROOT)
    for datatype in ("games", "play_by_play")
        for seasonpart in ("pre", "regular", "post")
            for season in SEASONS
                filepath = getfilepath(datatype, seasonpart, season)
                remotepath = joinpath(reporoot, "$(datatype)_data", "$(seasonpart)_season", filepath)
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
function getplaydata(season::Integer, part::SeasonPart)
    season in SEASONS || error("Invalid season $season")
    return load_data_from_disk(getfilepath("play_by_play", part, season))
end
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
function getgamedata(season::Integer, part::SeasonPart)
    season in SEASONS || error("Invalid season $season")
    return load_data_from_disk(getfilepath("games", part, season))
end
getgamedata(season::Integer, part::String) = getgamedata(season, parse(SeasonPart, part))

end  # module NFLScrapR

# to support legacy calls
nflscraprRgame = NFLScrapR.getgamedata
nflscrapRplaybyplay = NFLScrapR.getplaydata
