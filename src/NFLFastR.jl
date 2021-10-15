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
    getdata(season::Integer)

Create a dataframe of play-by-play data for `season`.

# Examples
```jldoctest
julia> df = NFLFastR.getdata(2010);

julia> first(df[:, [:home_team, :away_team, :yardline_100, :half_seconds_remaining]], 5)
5×4 DataFrame
 Row │ home_team  away_team  yardline_100  half_seconds_remaining
     │ String3…   String3…   Int64?        Int64?
─────┼────────────────────────────────────────────────────────────
   1 │ LA         ARI             missing                    1800
   2 │ LA         ARI                  30                    1800
   3 │ LA         ARI                  78                    1795
   4 │ LA         ARI                  78                    1764
   5 │ LA         ARI                  73                    1723

```
"""
function getdata(season::Integer)
    season in SEASONS || error("Invalid season $season")
    return load_data_from_disk(getfilepath(season))
end
getdata(symbol::Symbol) = load_data_from_disk(getfilepath(symbol))

end  # module NFLFastR
