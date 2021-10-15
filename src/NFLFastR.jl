"""
Module to access nflfastR-data files

See https://github.com/nflverse/nflfastR-data for additional data documentation.
"""
module NFLFastR

using  CSV: CSV
using  DataFrames: DataFrame
using  Logging
using  Pkg.Artifacts: artifact_exists, artifact_hash, @artifact_str, bind_artifact!, create_artifact
using  Downloads: Downloads
using  ..NFLTables: ARTIFACT_TOML

export getdata

function __init__()
    try
        download_artifact()
    catch e
        @warn "Unable to download artifacts; functionality will be limited until you run NFLFastR.download_artifact"
    end
end

"""
seasons with nflfastR data
"""
const SEASONS = tuple(1999:2021...)

"""
The download root of the nflfastR-data GitHub repo.
"""
const REPOROOT = "https://github.com/nflverse/nflfastR-data/raw/master/"


function getfilepath(season::Integer)::String
    return "play_by_play_$(season).csv.gz"
end
function getfilepath(symbol::Symbol)::String
    symbol === :player_stats || symbol === :player_stats_kicking || error("invalid symbol: $symbol")
    return "$(symbol).csv.gz"
end


"""
    download_data(dir; redownload=false, reporoot=REPOROOT)

Download nflfastR data to `dir` (overwrite existing if `redownload` is true)
"""
function download_data(dir; redownload=false, reporoot=REPOROOT)
    for season in SEASONS
        filepath = getfilepath(season)
        remotepath = joinpath(reporoot, "data", filepath)
        localpath = joinpath(dir, filepath)
        if redownload || !isfile(localpath)
            @info "downloading..." remotepath localpath
            Downloads.download(remotepath, localpath)
        end
    end
    for symbol in (:player_stats, :player_stats_kicking)
        filepath = getfilepath(symbol)
        remotepath = joinpath(reporoot, "data", filepath)
        localpath = joinpath(dir, filepath)
        if redownload || !isfile(localpath)
            @info "downloading..." remotepath localpath
            Downloads.download(remotepath, localpath)
        end
    end
end

"""
    download_artifact(; redownload=false, reporoot=REPOROOT)

Download all nflfastR data and store as an artifact (overwrite existing with `redownload=true`)
"""
function download_artifact(; redownload=false, reporoot=REPOROOT)
    hash = artifact_hash("nflfastR", ARTIFACT_TOML)  # or nothing

    if redownload || isnothing(hash) || !artifact_exists(hash)
        @info "Creating new nflfastR artifact"
        hash = create_artifact() do artifact_dir
            download_data(artifact_dir; reporoot)
        end
        @info "Download complete; updating Artifacts.toml"
        bind_artifact!(ARTIFACT_TOML, "nflfastR", hash, force=true)
    else
        @info "nflfastR artifact already downloaded"
    end
end


function load_data_from_disk(path)
    artifact_dir = try
        artifact"nflfastR"
    catch e
        if isa(e, LoadError)
            @error "Artifact data has not been downloaded; run NFLFastR.download_artifact to fix"
        end
        rethrow()
    end
    filepath = joinpath(artifact_dir, path)
    return DataFrame(CSV.File(filepath, missingstring="NA"))
end

"""
    getplaydata(season::Integer)

Create a dataframe of play-by-play data for `part` of `season`.

# Examples
```jldoctest
julia> df = getdata(2018);

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
function getdata(season::Integer)
    season in SEASONS || error("Invalid season $season")
    return load_data_from_disk(getfilepath(season))
end
getdata(symbol::Symbol) = load_data_from_disk(getfilepath(symbol))

end  # module NFLFastR
