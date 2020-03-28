module TestSchedules

using  Test
import NFLTables
using  NFLTables.Enumerations: Season
using  NFLTables.Schedules: schedule

@testset "Test schedule retrieval" begin
    for season in instances(Season)
        if Int(season) < 2018
            continue
        end
        df = schedule(season)
        @test size(df, 2) == 13
        @test size(df, 1) > 300
    end
end

end  # module TestSchedules
