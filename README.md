# NFLTables.jl
Functions to access NFL data

## NFLScrapRData
Activating environment at `~/vcs/NFLTables.jl/Project.toml`

```julia
julia> using NFLTables.NFLScrapRData

julia> using DataFrames

julia> gamesdf = game(2018, "reg", root=ENV["NFLSCRAPR_DATA"]);

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

julia> pbpdf = playbyplay(2018, "reg", root=ENV["NFLSCRAPR_DATA"]);

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
