# NFLTables.jl
![](https://github.com/KyleSJohnston/NFLTables.jl/workflows/UnitTests/badge.svg)

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://KyleSJohnston.github.io/NFLTables.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://KyleSJohnston.github.io/NFLTables.jl/dev)

Functions to access NFL data. Please create a GitHub issue to request a new
dataset or report a bug.

Documentation: [NFLTables.jl](https://kylesjohnston.github.io/NFLTables.jl/)

## NFL Schedules

```julia
julia> using NFLTables

julia> scheduledf = nflschedule(2019);

julia> size(scheduledf)
(333, 13)

julia> last(scheduledf, 5)
5×13 DataFrames.DataFrame. Omitted printing of 3 columns
│ Row │ date       │ states │ home   │ away   │ site                  │ gameid     │ gc_url                                                                        │ gametime │ homescore │ awayscore │
│     │ Dates.Date │ String │ String │ String │ String                │ Int64      │ String                                                                        │ String⍰  │ Int64⍰    │ Int64⍰    │
├─────┼────────────┼────────┼────────┼────────┼───────────────────────┼────────────┼───────────────────────────────────────────────────────────────────────────────┼──────────┼───────────┼───────────┤
│ 1   │ 2020-01-12 │ POST   │ GB     │ SEA    │ Lambeau Field         │ 2020011201 │ http://www.nfl.com/gamecenter/2020011201/2019/POST19/seahawks@packers         │ FINAL    │ 28        │ 23        │
│ 2   │ 2020-01-19 │ POST   │ KC     │ TEN    │ Arrowhead Stadium     │ 2020011900 │ http://www.nfl.com/gamecenter/2020011900/2019/POST20/titans@chiefs            │ FINAL    │ 35        │ 24        │
│ 3   │ 2020-01-19 │ POST   │ SF     │ GB     │ Levi's� Stadium       │ 2020011901 │ http://www.nfl.com/gamecenter/2020011901/2019/POST20/packers@49ers            │ FINAL    │ 37        │ 20        │
│ 4   │ 2020-01-26 │ PRE    │ APR    │ NPR    │ Camping World Stadium │ 2020012600 │ http://www.nfl.com/gamecenter/2020012600/2019/PRO21/nfc-pro-bowl@afc-pro-bowl │ missing  │ missing   │ missing   │
│ 5   │ 2020-02-02 │ POST   │ KC     │ SF     │ Hard Rock Stadium     │ 2020020200 │ http://www.nfl.com/gamecenter/2020020200/2019/POST22/49ers@chiefs             │ FINAL    │ 31        │ 20        │

```

## NFLScrapRData

The NFLScrapRData module makes it convenient to read nflscrapR-data as a
dataframe.

```julia
julia> using NFLTables

julia> using DataFrames

```

Game information can be obtained using `game`. By default, data is pulled from
GitHub, but a local clone can also be specified with the `root` keyword
argument. In the examples below, the local clone is specified with an
environment variable.

```julia
julia> gamesdf = nflscrapRgame(2018, REG);

julia> size(gamesdf)
(256, 10)

julia> names(gamesdf)
10-element Array{Symbol,1}:
 :type
 :game_id
 :home_team
 :away_team
 :week
 :season
 :state_of_game
 :game_url
 :home_score
 :away_score

julia> first(gamesdf, 5)
5×10 DataFrame
│ Row │ type   │ game_id    │ home_team │ away_team │ week  │ season │ state_of_game │ game_url                                                                 │ home_score │ away_score │
│     │ String │ Int64      │ String    │ String    │ Int64 │ Int64  │ String        │ String                                                                   │ Int64      │ Int64      │
├─────┼────────┼────────────┼───────────┼───────────┼───────┼────────┼───────────────┼──────────────────────────────────────────────────────────────────────────┼────────────┼────────────┤
│ 1   │ reg    │ 2018090600 │ PHI       │ ATL       │ 1     │ 2018   │ POST          │ http://www.nfl.com/liveupdate/game-center/2018090600/2018090600_gtd.json │ 18         │ 12         │
│ 2   │ reg    │ 2018090900 │ BAL       │ BUF       │ 1     │ 2018   │ POST          │ http://www.nfl.com/liveupdate/game-center/2018090900/2018090900_gtd.json │ 47         │ 3          │
│ 3   │ reg    │ 2018090907 │ NYG       │ JAX       │ 1     │ 2018   │ POST          │ http://www.nfl.com/liveupdate/game-center/2018090907/2018090907_gtd.json │ 15         │ 20         │
│ 4   │ reg    │ 2018090906 │ NO        │ TB        │ 1     │ 2018   │ POST          │ http://www.nfl.com/liveupdate/game-center/2018090906/2018090906_gtd.json │ 40         │ 48         │
│ 5   │ reg    │ 2018090905 │ NE        │ HOU       │ 1     │ 2018   │ POST          │ http://www.nfl.com/liveupdate/game-center/2018090905/2018090905_gtd.json │ 27         │ 20         │

```

Play-by-play information is also available; use the `playbyplay` function to
load it into a dataframe.

```julia
julia> pbpdf = nflscrapRplaybyplay(2018, REG);

julia> size(pbpdf)
(45156, 256)

julia> names(pbpdf)[1:10]
10-element Array{Symbol,1}:
 :play_id
 :game_id
 :home_team
 :away_team
 :posteam
 :posteam_type
 :defteam
 :side_of_field
 :yardline_100
 :game_date

julia> pbpdf[1:10, names(pbpdf)[1:5]]
10×5 DataFrame
│ Row │ play_id │ game_id    │ home_team │ away_team │ posteam │
│     │ Int64   │ Int64      │ String    │ String    │ String⍰ │
├─────┼─────────┼────────────┼───────────┼───────────┼─────────┤
│ 1   │ 37      │ 2018090600 │ PHI       │ ATL       │ ATL     │
│ 2   │ 52      │ 2018090600 │ PHI       │ ATL       │ ATL     │
│ 3   │ 75      │ 2018090600 │ PHI       │ ATL       │ ATL     │
│ 4   │ 104     │ 2018090600 │ PHI       │ ATL       │ ATL     │
│ 5   │ 125     │ 2018090600 │ PHI       │ ATL       │ ATL     │
│ 6   │ 146     │ 2018090600 │ PHI       │ ATL       │ ATL     │
│ 7   │ 168     │ 2018090600 │ PHI       │ ATL       │ ATL     │
│ 8   │ 190     │ 2018090600 │ PHI       │ ATL       │ ATL     │
│ 9   │ 214     │ 2018090600 │ PHI       │ ATL       │ ATL     │
│ 10  │ 235     │ 2018090600 │ PHI       │ ATL       │ ATL     │

```
