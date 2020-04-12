module Schedules

import CSV
using  Cascadia
using  DataFrames
using  Dates: Date, ENGLISH
using  Gumbo
using  HTTP

import ..Artifacts
using  NFLTables: PRE, POST, REG, SeasonPart

const FIRSTSEASON = 1970
const LASTSEASON  = 2019
const SEASONS = tuple(FIRSTSEASON:LASTSEASON...)

function validseason(season::Integer)
    return FIRSTSEASON <= season <= LASTSEASON
end

function extractdate(elem, season::Integer)
    datestring = nodeText(eachmatch(Selector("span > span"), elem)[1])
    dayofweek, monthday = split(datestring, ", ")
    month, day = split(monthday)
    monthnum = findfirst(x -> x == month, ENGLISH.months)
    if monthnum > 7
        return Date(season, monthnum, parse(Int, day))
    else
        return Date(season+oneunit(season), monthnum, parse(Int, day))
    end
end


function extractschedule(schedules_table, season::Integer)

    df = DataFrame(
        date = Date[],
        states = String[],
        home = String[],
        away = String[],
        site = String[],
        gameid = Int[],
        gc_url = String[],
        gametime = Union{String,Missing}[],
        homescore = Union{Int,Missing}[],
        awayscore = Union{Int,Missing}[],
    )

    date = nothing
    for elem in schedules_table
        elemclass = getattr(elem, "class")
        if occursin("schedules-list-date", elemclass)
            if occursin("next-game", elemclass)
                continue
            end
            date = extractdate(elem, season)
        elseif occursin("schedules-list-matchup", elemclass)
            if isnothing(date)
                # A matchup occurs before a date is specified (2019 pro bowl is
                # in the schedule twice) and can be skipped.
                continue
            end
            try
                d = eachmatch(Selector("div.schedules-list-content"), elem)[1]

                if d.attributes["data-gamestate"] == "PRE"
                    gametime = missing
                    homescore = missing
                    awayscore = missing
                else
                    gametime = nodeText(eachmatch(Selector("span.time"), elem)[1])
                    homescore = parse(Int, nodeText(eachmatch(Selector("span.team-score.home"), elem)[1]))
                    awayscore = parse(Int, nodeText(eachmatch(Selector("span.team-score.away"), elem)[1]))
                end

                push!(df, Dict(
                    :date => date,
                    :states => d.attributes["data-gamestate"],
                    :home => d.attributes["data-home-abbr"],
                    :away => d.attributes["data-away-abbr"],
                    :site => d.attributes["data-site"],
                    :gameid => parse(Int, d.attributes["data-gameid"]),
                    :gc_url => d.attributes["data-gc-url"],
                    :gametime => gametime,
                    :homescore => homescore,
                    :awayscore => awayscore,
                ))
            catch e
                @debug elem
                rethrow(e)
            end
        else
            error("Unknown elem: $elem")
        end
    end
    return df
end

function downloadschedule(url::AbstractString, season::Integer)
    validseason(season) || error("Invalid season: $season")
    r = HTTP.get(url);
    r.status == 200 || error("Unable to get site (status: $(r.status))")
    h = parsehtml(String(r.body))
    matches = eachmatch(Selector("ul.schedules-table > li"), h.root)
    df = extractschedule(matches, season)
    return df
end

function scheduleurl(season::Integer, part::SeasonPart, week::Int)
    validseason(season) || error("Invalid season: $season")
    return "http://www.nfl.com/schedules/$season/$(string(part))$week"
end

function scheduleurl(season::Integer, part::SeasonPart, week::Type{Nothing})
    validseason(season) || error("Invalid season: $season")
    part === POST || error("only POST can be downloaded without a week")
    return "http://www.nfl.com/schedules/$season/$(string(part))"
end


function seasonweeks(season::Integer)
    validseason(season) || error("Invalid season: $season")
    rtn = Tuple{SeasonPart,Any}[]
    for i in 0:4
        push!(rtn, (PRE, i))
    end
    for i in 1:17
        push!(rtn, (REG, i))
    end
    push!(rtn, (POST, Nothing))
    return rtn
end


function downloadschedule(season::Integer)
    validseason(season) || error("Invalid season: $season")
    dataframes = DataFrame[]
    for (part, week) in seasonweeks(season)
        url = scheduleurl(season, part, week)
        df = downloadschedule(url, season)
        n = size(df, 1)
        df[!, :season] = fill(season, n)
        df[!, :seasonpart] = fill(part, n)
        df[!, :week] = fill(isnothing(week) ? 0 : week, n)
        push!(dataframes, df)
    end
    return vcat(dataframes...)
end

"""
    nflschedule(season::Integer; redownload::Bool=false)

Obtain the NFL schedule for `season` (optionally force a `redownload`)

# Examples
```jldoctest
julia> df = nflschedule(2001);

julia> df[end-1, [:home, :homescore, :away, :awayscore]]
DataFrameRow
│ Row │ home   │ homescore │ away   │ awayscore │
│     │ String │ Int64     │ String │ Int64     │
├─────┼────────┼───────────┼────────┼───────────┤
│ 322 │ NE     │ 20        │ STL    │ 17        │

```
"""
function nflschedule(season::Integer; redownload::Bool=false)
    validseason(season) || error("Invalid season: $season")
    name = "schedule_$(season)"
    path = Artifacts.get(name, redownload=redownload) do artifact_dir
        df = downloadschedule(season)
        sort!(df, [:gameid])
        CSV.write(joinpath(artifact_dir, "schedule.csv"), df)
    end
    return CSV.File(joinpath(path, "schedule.csv")) |> DataFrame!
end

end  # module Schedules
