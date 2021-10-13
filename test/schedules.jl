module TestSchedules

using  Test
using  NFLTables: Schedules

@testset "Valid Seasons" begin
    @test length(Schedules.SEASONS) == 12
end

@testset "Test schedule retrieval" begin
    df = Schedules.schedule(2019)
    @test size(df, 2) == 9
end

end  # module TestSchedules
