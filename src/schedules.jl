module Schedules

using  Cascadia: nodeText, Selector, @sel_str
using  CSV
using  DataFrames
using  Dates: Date, ENGLISH
using  Gumbo: parsehtml
using  HTTP
using  JSON
using  Logging
using  Scratch: @get_scratch!
using  URIs

using  NFLTables: POST, PRE, REG, SeasonPart


const SEASONS = tuple(2010:2021...)


function extractdate(datestring::AbstractString, season::Integer)
    if datestring == "Games not yet scheduled"
        return missing
    end
    monthday = split(datestring, ", ")[2]
    month, day = split(monthday)
    monthnum = findfirst(x -> x == month, ENGLISH.months)
    daynum = parse(Int, match(r"^[0-9]+", day).match)
    if monthnum > 7
        return Date(season, monthnum, daynum)
    else
        return Date(season+oneunit(season), monthnum, daynum)
    end
end


function extractschedule(content::AbstractString, season::Integer, seasonpart::SeasonPart, week::Integer)

    df = DataFrame(
        season = Int[],
        seasonpart = SeasonPart[],
        week = Int[],
        date = Union{Date,Missing}[],
        states = Union{String,Missing}[],
        home = String[],
        away = String[],
        # site = String[],
        # gameid = Int[],
        # gc_url = String[],
        # gametime = Union{String,Missing}[],
        homescore = Union{Int,Missing}[],
        awayscore = Union{Int,Missing}[],
    )

    htmlcontent = parsehtml(content)

    for date_element in eachmatch(sel"section.nfl-o-matchup-group", htmlcontent.root)
        datetext = nodeText(eachmatch(sel"h2.d3-o-section-title", date_element)[1])
        date = try
            extractdate(datetext, season)
        catch e
            @error "Unable to extract date" datetext
            rethrow()
        end

        for game_element in eachmatch(sel"div.nfl-c-matchup-strip", date_element)
            state_elements = eachmatch(sel"p.nfl-c-matchup-strip__period", game_element)
            state = if isempty(state_elements)
                missing
            else
                state = nodeText(state_elements[1])
            end
            away_element, home_element = eachmatch(sel"div.nfl-c-matchup-strip__team", game_element)  # two teams, away@home_score
            away = strip(nodeText(eachmatch(sel"span.nfl-c-matchup-strip__team-abbreviation", away_element)[1]))

            awayscore_elements = eachmatch(sel"div.nfl-c-matchup-strip__team-score", away_element)
            awayscore = if isempty(awayscore_elements)
                missing
            else
                parse(Float64, awayscore_elements[1].attributes["data-score"])
            end

            home = strip(nodeText(eachmatch(sel"span.nfl-c-matchup-strip__team-abbreviation", home_element)[1]))
            homescore_elements = eachmatch(sel"div.nfl-c-matchup-strip__team-score", home_element)
            homescore = if isempty(homescore_elements)
                missing
            else
                parse(Float64, homescore_elements[1].attributes["data-score"])
            end

            push!(df, Dict(
                :season => season,
                :seasonpart => seasonpart,
                :week => week,
                :date => date,
                :states => state,
                :home => home,
                :away => away,
                # :site => d.attributes["data-site"],
                # :gameid => parse(Int, d.attributes["data-gameid"]),
                # :gc_url => d.attributes["data-gc-url"],
                # :gametime => gametime,
                :homescore => homescore,
                :awayscore => awayscore,
            ))
        end
    end
    return df
end


const REQUEST = Dict{String, Any}(
    "Name"   => "Schedules",
    "Module" => Dict{String, Any}(
        "PreSeasonPlacement"=>0,
        "PostSeasonPlacement"=>0,
        "SeasonType"=>"REG1",
        "seasonFromUrl"=>2018,
        "HeaderCountryCode"=>"US",
        "RegularSeasonPlacement"=>0,
        "WeekFromUrl"=>5,
        "TimeZoneID"=>"America/New_York",
    ),
)

function requesturi(season::Integer, part::SeasonPart, week::Integer)
    rd = Dict(REQUEST)
    rd["Module"]["SeasonType"] = "$(string(part))$week"
    rd["Module"]["seasonFromUrl"] = season
    query = JSON.json(rd)
    uri = URI(
        scheme="https",
        host="www.nfl.com",
        path="/api/lazy/load",
        query="json=$(string(query))",
    )
    return uri
end


function rawdownload(uri::URI)
    r = HTTP.get(string(uri));
    r.status == 200 || error("Unable to get site (status: $(r.status))")
    return String(r.body)
end


function seasonweeks(season::Integer)
    season in SEASONS || error("Invalid season: $season")
    rtn = Tuple{SeasonPart,Any}[]
    for i in 0:4
        push!(rtn, (PRE, i))
    end
    for i in 1:17
        push!(rtn, (REG, i))
    end
    if season != 2021
        for i in 1:4
            push!(rtn, (POST, i))
        end
    end
    return rtn
end

function getfilepath(season::Integer)
    season in SEASONS || error("invalid season $season")
    return "$(season).csv"
end


"""
    schedule(season::Integer; redownload::Bool=false)

Obtain the NFL schedule for `season` (optionally force a `redownload`)

# Examples
```jldoctest
julia> df = schedule(2001);

julia> df[end-1, [:home, :homescore, :away, :awayscore]]
DataFrameRow
│ Row │ home   │ homescore │ away   │ awayscore │
│     │ String │ Int64     │ String │ Int64     │
├─────┼────────┼───────────┼────────┼───────────┤
│ 322 │ NE     │ 20        │ STL    │ 17        │

```
"""
function schedule(season::Integer; redownload=false)
    dirpath = @get_scratch!("schedules")
    localpath = joinpath(dirpath, getfilepath(season))
    return if redownload || !isfile(localpath)
        @info "Downloading data for $season and writing to $localpath"
        dataframes = []
        for (part, week) in seasonweeks(season)
            content = rawdownload(requesturi(season, part, week))
            part_df = try
                extractschedule(content, season, part ,week)
            catch
                @error "Unable to extract a schedule" season part week
                rethrow()
            end
            push!(dataframes, part_df)
        end
        df = vcat(dataframes...)
        sort!(df, [:seasonpart, :week, :date, :home])  # for consistency
        CSV.write(localpath, df)
        df
    else
        DataFrame(CSV.File(localpath, missingstring="NA"))
    end
end

end  # module Schedules

nflschedule = Schedules.schedule
