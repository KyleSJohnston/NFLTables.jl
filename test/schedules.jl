module TestSchedules

using  Test
import NFLTables
using  NFLTables.Schedules: SEASONS, schedule, validseason

@testset "Valid Seasons" begin
    @test length(SEASONS) == 50
    for season in SEASONS
        @test validseason(season)
    end
end

@testset "Test schedule retrieval" begin
    for season in SEASONS
        df = schedule(season, redownload=false)
        @test size(df, 2) == 13
    end
end

end  # module TestSchedules
