module Schedules

import CSV
using  Cascadia
using  DataFrames
using  Dates: Date, ENGLISH
using  Gumbo
using  HTTP
# using  Logging

import NFLTables
import NFLTables.Enumerations: PRE, REG, POST

export schedule

const SEASONS = tuple(1970:2019...)

function validseason(season::Integer)
    return 1970 <= season <= 2019
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
        gametime = String[],
        homescore = Int[],
        awayscore = Int[],
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
            try
                d = eachmatch(Selector("div.schedules-list-content"), elem)[1]
                if occursin("type-pro", getattr(d, "class"))
                    continue
                end
                push!(df, Dict(
                    :date => date,
                    :states => d.attributes["data-gamestate"],
                    :home => d.attributes["data-home-abbr"],
                    :away => d.attributes["data-away-abbr"],
                    :site => d.attributes["data-site"],
                    :gameid => parse(Int, d.attributes["data-gameid"]),
                    :gc_url => d.attributes["data-gc-url"],
                    :gametime => nodeText(eachmatch(Selector("span.time"), elem)[1]),
                    :homescore => parse(Int, nodeText(eachmatch(Selector("span.team-score.home"), elem)[1])),
                    :awayscore => parse(Int, nodeText(eachmatch(Selector("span.team-score.away"), elem)[1])),
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

function scheduleurl(season::Integer, part::AbstractString, week::Int)
    validseason(season) || error("Invalid season: $season")
    return "http://www.nfl.com/schedules/$season/$part$week"
end

function scheduleurl(season::Integer, part::AbstractString, week::Type{Nothing})
    validseason(season) || error("Invalid season: $season")
    part == "POST" || error("only POST can be downloaded without a week")
    return "http://www.nfl.com/schedules/$season/$part"
end


function seasonweeks(season::Integer)
    validseason(season) || error("Invalid season: $season")
    rtn = Tuple{String,Any}[]
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

function schedule(season::Integer)
    validseason(season) || error("Invalid season: $season")
    name = "schedule_$(season)"
    path = NFLTables.Artifacts.get(name) do artifact_dir
        df = downloadschedule(season)
        sort!(df, [:gameid])
        CSV.write(joinpath(artifact_dir, "schedule.csv"), df)
    end
    return CSV.File(joinpath(path, "schedule.csv")) |> DataFrame!
end

end  # module Schedules
