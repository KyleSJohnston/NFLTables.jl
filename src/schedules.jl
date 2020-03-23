module Schedules

import Dates: Date, ENGLISH
using  Cascadia, Gumbo, HTTP
using  DataFrames
using  ..Enumerations

export getschedule

function extractdate(elem, season::Season)
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

function getschedule(season::Season, part::AbstractString, week::Int)
    r = HTTP.get("http://www.nfl.com/schedules/$(Int(season))/$(part)$(week)");
    r.status == 200 || error("Unable to get site")
    h = parsehtml(String(r.body))
    matches = eachmatch(Selector("ul.schedules-table > li"), h.root)
    df = extractschedule(matches, season)
    n = size(df, 1)
    df[!, :season] = fill(season, n)
    df[!, :seasonpart] = fill(part, n)
    df[!, :week] = fill(week, n)
    return df
end

end  # module Schedules
