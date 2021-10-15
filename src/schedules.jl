module Schedules

using  Cascadia: nodeText, Selector, @sel_str
using  CSV
using  DataFrames
using  Dates: Date, ENGLISH
using  Gumbo: parsehtml
using  HTTP
using  JSON
using  Logging
using  Pkg.Artifacts
using  URIs

using  NFLTables: ARTIFACT_TOML, POST, PRE, REG, SeasonPart

function __init__()
    try
        download_artifact()
    catch e
        @warn "Unable to download artifacts; functionality will be limited until you run Schedules.download_artifact"
    end
end

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
        state = Union{String,Missing}[],
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
                :state => state,
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
requesturi(season::Integer, part::AbstractString, week::Integer) = requesturi(season, parse(SeasonPart, part), week)


function rawdownload(uri::AbstractString)
    r = HTTP.get(uri);
    r.status == 200 || error("Unable to get site (status: $(r.status))")
    return String(r.body)
end
rawdownload(uri::URI) = rawdownload(string(uri))


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
    return "$(season).csv"
end

function download_data(dir::AbstractString; redownload=false)
    for season in SEASONS
        filepath = getfilepath(season)
        localpath = joinpath(dir, filepath)

        if redownload || !isfile(localpath)
            @info "Downloading data and writing to $localpath"
            dataframes = []
            for (part, week) in seasonweeks(season)
                uri = requesturi(season, part, week)
                content = rawdownload(uri)
                df = try
                    extractschedule(content, season, part ,week)
                catch
                    @error "Unable to extract a schedule" season part week
                    rethrow()
                end
                push!(dataframes, df)
            end
            df = vcat(dataframes...)
            sort!(df, [:seasonpart, :week, :date, :home])  # for consistency
            CSV.write(localpath, df)
        else
            @info "$localpath already exists"
        end
    end
end

function download_artifact(; redownload=false)
    hash = artifact_hash("schedule", ARTIFACT_TOML)  # or nothing

    if redownload || isnothing(hash) || !artifact_exists(hash)
        @info "Creating new schedule artifact"
        hash = create_artifact() do artifact_dir
            download_data(artifact_dir)
        end
        @info "Download complete; updating Artifacts.toml"
        bind_artifact!(ARTIFACT_TOML, "schedule", hash, force=true)
    else
        @info "schedule artifact already downloaded"
    end
end


"""
    schedule(season::Integer)

Obtain the NFL schedule for `season`

# Examples
```jldoctest
julia> df = Schedules.schedule(2018);

julia> first(df[:, [:date, :home, :away, :homescore, :awayscore]], 5)
5×5 DataFrame
 Row │ date        home      away      homescore  awayscore
     │ Date…       String3…  String3…  Int64      Int64
─────┼──────────────────────────────────────────────────────
   1 │ 2018-08-02  BAL       CHI              17         16
   2 │ 2018-08-09  BAL       LAR              33          7
   3 │ 2018-08-09  BUF       CAR              23         28
   4 │ 2018-08-09  CIN       CHI              30         27
   5 │ 2018-08-09  GB        TEN              31         17

```
"""
function schedule(season::Integer)
    artifact_dir = try
        artifact"schedule"
    catch e
        if isa(e, LoadError)
            @error "Artifact data has not been downloaded; run Schedules.download_artifact to fix"
        end
        rethrow()
    end
    filepath = joinpath(artifact_dir, getfilepath(season))
    return DataFrame(CSV.File(filepath, missingstring="NA"))
end

end  # module Schedules

nflschedule = Schedules.schedule
