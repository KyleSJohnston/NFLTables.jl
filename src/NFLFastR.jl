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
getdata(label; redownload=false, reporoot=REPOROOT) = load_data_from_disk(getfilepath(label); redownload, reporoot)

end  # module NFLFastR
