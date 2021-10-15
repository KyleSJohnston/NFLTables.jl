module TestCompare

using  DataFrames: nrow, outerjoin
using  Test
using  NFLTables: NFLScrapR, Schedules, PRE, REG

SYMBOL_MAPPING = Dict(
    :away => :away_team,
    :homescore => :home_score,
    :awayscore => :away_score,
)

@testset "comparing schedules and NFLScrapR.game" begin
    let season = 2019
        @test season in NFLScrapR.SEASONS
        @test season in Schedules.SEASONS
        schedule_df = Schedules.schedule(season)
        for part in (PRE, REG)
            df = schedule_df[
                schedule_df.seasonpart .== uppercase(string(part)),
                [:week, :home, :away, :homescore, :awayscore]
            ]

            nflscrapr_df = NFLScrapR.getgamedata(season, part)[
                :,
                [:week, :home_team, :away_team, :home_score, :away_score]
            ]
            la_rename = x -> x == "LA" ? "LAR" : x
            nflscrapr_df[!, :home_team] = la_rename.(nflscrapr_df[:, :home_team])
            nflscrapr_df[!, :away_team] = la_rename.(nflscrapr_df[:, :away_team])

            @test nrow(df) == nrow(nflscrapr_df)
            joined_df = outerjoin(df, nflscrapr_df, on=[:week => :week, :home=>:home_team])
            for (k, v) in pairs(SYMBOL_MAPPING)
                matchmask = isequal.(joined_df[:, k], joined_df[:, v])
                if !all(matchmask)
                    println(joined_df[.!matchmask, :])
                end
                @test all(matchmask)
            end
        end
    end
end

end  # module TestSchedules
