module TestCompare

using  DataFrames: join, nrow
using  Test
using  NFLTables

SYMBOL_MAPPING = Dict(
    :home => :home_team,
    :away => :away_team,
    :homescore => :home_score,
    :awayscore => :away_score,
)

@testset "comparing schedules and NFLScrapRData.game" begin
    let season = 2019
        @test NFLTables.NFLScrapRData.hasdata(season)
        @test NFLTables.Schedules.validseason(season)
        schedule_df = nflschedule(season)
        for part in instances(SeasonPart)
            df = schedule_df[
                schedule_df.seasonpart .== uppercase(string(part)),
                [:gameid, :home, :away, :homescore, :awayscore]
            ]
            nflscrapr_df = nflscrapRgame(season, part)[
                :,
                [:game_id, :home_team, :away_team, :home_score, :away_score]
            ]
            @test nrow(df) == nrow(nflscrapr_df)
            joined_df = join(df, nflscrapr_df, on=:gameid=>:game_id, kind=:outer)
            for (k, v) in pairs(SYMBOL_MAPPING)
                @test isequal(joined_df[:, k], joined_df[:, v])
            end
        end
    end
end

end  # module TestSchedules
