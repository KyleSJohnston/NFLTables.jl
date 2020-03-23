module TestSchedules

using  Test
import NFLTables
import NFLTables.Enumerations: S2018
using  NFLTables.Schedules

@testset "Test schedule retrieval" begin
    df = getschedule(S2018, "REG", 4)
    @test size(df) == (15, 13)
end


end  # module TestSchedules
