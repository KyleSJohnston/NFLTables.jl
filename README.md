# NFLTables.jl
![](https://github.com/KyleSJohnston/NFLTables.jl/workflows/UnitTests/badge.svg)

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://KyleSJohnston.github.io/NFLTables.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://KyleSJohnston.github.io/NFLTables.jl/dev)

Functions to access NFL data. Please create a GitHub issue to request a new
dataset or report a bug.


`NFLTables` provides enumerations and functions to make it _convenient_ to access existing NFL data.
Where relevant, variable, module, and function names follow the conventions for the julia language.

```julia
julia> using NFLTables

julia> varinfo(NFLTables)
  name              size summary
  –––––––––– ––––––––––– ––––––––––
  NFLFastR    23.407 KiB Module
  NFLScrapR   26.434 KiB Module
  NFLTables  273.709 KiB Module
  POST           4 bytes SeasonPart
  PRE            4 bytes SeasonPart
  REG            4 bytes SeasonPart
  Schedules   35.631 KiB Module
  SeasonPart   128 bytes DataType
  SuperBowl    128 bytes DataType

julia> SuperBowl(2021)
SB_LVI::SuperBowl = 2021

julia> instances(SeasonPart)
(PRE, REG, POST)

```

Data retrieved in the submodules is cached locally with `Scratch`. By convention, data can be downloaded again with `redownload=true` in the appropriate function.

## NFL Schedules

Schedules are obtained by parsing data from www.nfl.com.

```julia
julia> scheduledf = Schedules.schedule(2019);

julia> size(scheduledf)
(332, 9)

julia> last(scheduledf, 5)
5×9 DataFrame
 Row │ season  seasonpart  week   date        states     home      away      homescore  awayscore
     │ Int64   String7…    Int64  Date…       String15…  String3…  String3…  Int64      Int64
─────┼────────────────────────────────────────────────────────────────────────────────────────────
   1 │   2019  POST            2  2020-01-12  FINAL      GB        SEA              28         23
   2 │   2019  POST            2  2020-01-12  FINAL      KC        HOU              51         31
   3 │   2019  POST            3  2020-01-19  FINAL      KC        TEN              35         24
   4 │   2019  POST            3  2020-01-19  FINAL      SF        GB               37         20
   5 │   2019  POST            4  2020-02-02  FINAL      KC        SF               31         20

```

## nflscrapR Data

The data is available at https://github.com/ryurko/nflscrapR-data for the 2009-2019 seasons.
Use `NFLScrapR.getgamedata` to retrieve game information as a dataframe.

```julia
julia> gamesdf = NFLScrapR.getgamedata(2018, REG);

julia> size(gamesdf)
(256, 10)

julia> names(gamesdf)
10-element Vector{String}:
 "type"
 "game_id"
 "home_team"
 "away_team"
 "week"
 "season"
 "state_of_game"
 "game_url"
 "home_score"
 "away_score"

julia> first(gamesdf, 5)
5×10 DataFrame
 Row │ type      game_id     home_team  away_team  week   season  state_of_game  game_url                           home_score  away_score
     │ String3…  Int64       String3…   String3…   Int64  Int64   String7…       String                             Int64       Int64
─────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ reg       2018090600  PHI        ATL            1    2018  POST           http://www.nfl.com/liveupdate/ga…          18          12
   2 │ reg       2018090900  BAL        BUF            1    2018  POST           http://www.nfl.com/liveupdate/ga…          47           3
   3 │ reg       2018090907  NYG        JAX            1    2018  POST           http://www.nfl.com/liveupdate/ga…          15          20
   4 │ reg       2018090906  NO         TB             1    2018  POST           http://www.nfl.com/liveupdate/ga…          40          48
   5 │ reg       2018090905  NE         HOU            1    2018  POST           http://www.nfl.com/liveupdate/ga…          27          20

```

Play-by-play information is also available; use the `getplaydata` function.

```julia
julia> pbpdf = NFLScrapR.getplaydata(2018, REG);

julia> size(pbpdf)
(45156, 256)

julia> names(pbpdf)[1:10]
10-element Vector{String}:
 "play_id"
 "game_id"
 "home_team"
 "away_team"
 "posteam"
 "posteam_type"
 "defteam"
 "side_of_field"
 "yardline_100"
 "game_date"

```

## nflfastR Data

For data more recent than nflscrapR, use `NFLFastR`.
The data is hosted at https://github.com/nflverse/nflfastR, and the README describes the improvements over nflscrapR.
This is the recommended data for new analysis.

```julia
julia> fastdf = NFLFastR.getdata(2018);

julia> size(fastdf)
(47874, 372)

julia> fastdf[1:10, 1:6]
10×6 DataFrame
 Row │ play_id  game_id          old_game_id  home_team  away_team  season_type
     │ Int64    String15…        Int64        String3…   String3…   String7…
─────┼──────────────────────────────────────────────────────────────────────────
   1 │       1  2018_01_ATL_PHI   2018090600  PHI        ATL        REG
   2 │      37  2018_01_ATL_PHI   2018090600  PHI        ATL        REG
   3 │      52  2018_01_ATL_PHI   2018090600  PHI        ATL        REG
   4 │      75  2018_01_ATL_PHI   2018090600  PHI        ATL        REG
   5 │     104  2018_01_ATL_PHI   2018090600  PHI        ATL        REG
   6 │     125  2018_01_ATL_PHI   2018090600  PHI        ATL        REG
   7 │     146  2018_01_ATL_PHI   2018090600  PHI        ATL        REG
   8 │     168  2018_01_ATL_PHI   2018090600  PHI        ATL        REG
   9 │     190  2018_01_ATL_PHI   2018090600  PHI        ATL        REG
  10 │     214  2018_01_ATL_PHI   2018090600  PHI        ATL        REG

```
