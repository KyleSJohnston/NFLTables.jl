module TestEnumerations

using  NFLTables: Enumerations
using  NFLTables.Enumerations
using  Test

@testset "enumeration tests" begin
    @test length(instances(Season)) == 50
    @test length(instances(SeasonPart)) == 3
    @test length(instances(SuperBowl)) == 54

    @test Season(Enumerations.SB_LIV) === Enumerations.S2019
    @test SuperBowl(Enumerations.S2019) === Enumerations.SB_LIV
end

end  # module
