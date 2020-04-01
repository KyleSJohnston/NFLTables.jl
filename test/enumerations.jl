module TestEnumerations

using  Test

using  NFLTables

@testset "enumeration tests" begin
    @test parse(SeasonPart, "PRE")  === PRE
    @test parse(SeasonPart, "REG")  === REG
    @test parse(SeasonPart, "POST") === POST

    @test length(instances(SeasonPart)) == 3
    @test length(instances(SuperBowl)) == 54

    @test Int(NFLTables.Enumerations.SB_LIV) == 2019
    @test SuperBowl(2019) === NFLTables.Enumerations.SB_LIV
end

end  # module
