# NFLTables.jl

NFLTables.jl is deprecated. Please use NFLData.jl instead.

![](https://github.com/KyleSJohnston/NFLTables.jl/workflows/UnitTests/badge.svg)

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://KyleSJohnston.github.io/NFLTables.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://KyleSJohnston.github.io/NFLTables.jl/dev)

`NFLTables` provides enumerations.

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
