module TestSchedules

using  Test
using  NFLTables

@testset "Valid Seasons" begin
    @test length(NFLTables.Schedules.SEASONS) == 50
    for season in NFLTables.Schedules.SEASONS
        @test NFLTables.Schedules.validseason(season)
    end
end

@testset "Test schedule retrieval" begin
    for season in NFLTables.Schedules.SEASONS
        df = nflschedule(season, redownload=false)
        @test size(df, 2) == 13
    end
end

end  # module TestSchedules
