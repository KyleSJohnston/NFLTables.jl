"""
Module to access nflfastR-data files

See https://github.com/nflverse/nflfastR-data for additional data documentation.
"""
module NFLFastR

using  CSV: CSV
using  DataFrames: DataFrame
using  Downloads: Downloads
using  Logging
using  Scratch: @get_scratch!

export getdata

"""
seasons with nflfastR data
"""
const SEASONS = tuple(1999:2021...)

"""
The download root of the nflfastR-data GitHub repo.
"""
const REPOROOT = "https://github.com/nflverse/nflfastR-data/raw/master/"


function getfilepath(season::Integer)::String
    season in SEASONS || error("Invalid season $season")
    return "play_by_play_$(season).csv.gz"
end
function getfilepath(symbol::Symbol)::String
    symbol === :player_stats || symbol === :player_stats_kicking || error("invalid symbol: $symbol")
    return "$(symbol).csv.gz"
end


function load_data_from_disk(filepath; redownload=false, reporoot=REPOROOT)
    dirpath = @get_scratch!("nflfastR")
    localpath = joinpath(dirpath, filepath)
    if redownload || !isfile(localpath)
        remotepath = joinpath(reporoot, "data", filepath)
        @info "downloading..." remotepath localpath
        Downloads.download(remotepath, localpath)
    end
    return DataFrame(CSV.File(localpath, missingstring="NA"))
end

"""
    getdata(season::Integer)
    getdata(label::Symbol)

Create a dataframe of play-by-play data for `season` or `label` data for all seasons`.

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
getdata(label; redownload=false, reporoot=REPOROOT) = load_data_from_disk(getfilepath(label); redownload, reporoot)

end  # module NFLFastR
