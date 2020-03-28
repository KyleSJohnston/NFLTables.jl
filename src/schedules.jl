module Schedules

import CSV
using  Cascadia
using  DataFrames
using  Dates: Date, ENGLISH
using  Gumbo
using  HTTP
# using  Logging

import NFLTables
using  NFLTables.Enumerations: Season

export schedule

function extractdate(elem, season::Season)
    @debug elem
    datestring = nodeText(eachmatch(Selector("span > span"), elem)[1])
    dayofweek, monthday = split(datestring, ", ")
    month, day = split(monthday)
    monthnum = findfirst(x -> x == month, ENGLISH.months)
    if monthnum > 7
        return Date(Int(season), monthnum, parse(Int, day))
    else
        return Date(Int(season)+1, monthnum, parse(Int, day))
    end
end


function extractschedule(schedules_table, season::Season)

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
            d = eachmatch(Selector("div.schedules-list-content"), elem)[1]
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
        else
            error("Unknown elem: $elem")
        end
    end
    return df
end

function downloadschedule(url::AbstractString, season::Season)
    r = HTTP.get(url);
    r.status == 200 || error("Unable to get site (status: $(r.status))")
    h = parsehtml(String(r.body))
    matches = eachmatch(Selector("ul.schedules-table > li"), h.root)
    df = extractschedule(matches, season)
    return df
end

function scheduleurl(season::Season, part::AbstractString, week::Int)
    return "http://www.nfl.com/schedules/$(Int(season))/$(part)$(week)"
end

function scheduleurl(season::Season, part::AbstractString, week::Type{Nothing})
    part == "POST" || error("only POST can be downloaded without a week")
    return "http://www.nfl.com/schedules/$(Int(season))/$(part)"
end


function seasonweeks(season::Season)
    rtn = Tuple{String,Any}[]
    for i in 0:4
        push!(rtn, ("PRE", i))
    end
    for i in 1:17
        push!(rtn, ("REG", i))
    end
    push!(rtn, ("POST", Nothing))
    return rtn
end


function downloadschedule(season::Season)
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

function schedule(season::Season)
    name = "schedule_$(Int(season))"
    path = NFLTables.Artifacts.get(name) do artifact_dir
        df = downloadschedule(season)
        sort!(df, [:gameid])
        CSV.write(joinpath(artifact_dir, "schedule.csv"), df)
    end
    return CSV.File(joinpath(path, "schedule.csv")) |> DataFrame!
end

schedule(season::Int) = schedule(Season(season))

end  # module Schedules
