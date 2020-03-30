module TestEnumerations

using  NFLTables: Enumerations
using  Test

@testset "enumeration tests" begin
    @test length(instances(Enumerations.SeasonPart)) == 3
    @test length(instances(Enumerations.SuperBowl)) == 54

    @test Int(Enumerations.SB_LIV) == 2019
    @test Enumerations.SuperBowl(2019) === Enumerations.SB_LIV
end

end  # module
