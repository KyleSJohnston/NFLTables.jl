module TestEnumerations

using  NFLTables
using  Test

@testset "enumeration tests" begin
    @test parse(SeasonPart, "PRE")  === PRE
    @test parse(SeasonPart, "REG")  === REG
    @test parse(SeasonPart, "POST") === POST

    @test length(instances(SeasonPart)) == 3
    @test length(instances(SuperBowl)) == 56

    @test Int(NFLTables.SB_LIV) == 2019
    @test SuperBowl(2019) === NFLTables.SB_LIV
end

end  # module
