module TestCompare

using  DataFrames: join, nrow
using  Test
using  NFLTables
using  NFLTables.Schedules: schedule

SYMBOL_MAPPING = Dict(
    :home => :home_team,
    :away => :away_team,
    :homescore => :home_score,
    :awayscore => :away_score,
)

@testset "comparing schedules and NFLScrapRData.game" begin
    for season in instances(Enumerations.Season)
        if Int(season) < 2018
            continue
        end
        schedule_df = schedule(season)
        for part in instances(Enumerations.SeasonPart)
            println(part)
            df = schedule_df[
                schedule_df.seasonpart .== uppercase(string(part)),
                [:gameid, :home, :away, :homescore, :awayscore]
            ]
            nflscrapr_df = NFLTables.NFLScrapRData.game(season, part)[
                :,
                [:game_id, :home_team, :away_team, :home_score, :away_score]
            ]
            @test nrow(df) == nrow(nflscrapr_df)
            joined_df = join(df, nflscrapr_df, on=:gameid=>:game_id, kind=:outer)
            for (k, v) in pairs(SYMBOL_MAPPING)
                @test all(joined_df[:, k] .== joined_df[:, v])
            end
        end
    end
end

end  # module TestSchedules
