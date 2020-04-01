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
    df = nflschedule(2019, redownload=false)
    @test size(df, 2) == 13
end

end  # module TestSchedules
