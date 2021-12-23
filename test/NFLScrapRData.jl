module TestOfNFLScrapR

using  DataFrames: DataFrame
using  Test

using  NFLTables: SeasonPart
using  NFLTables.NFLScrapR: getgamedata, getplaydata

@testset "nflscrapR-data df tests" begin
    let season = 2019
        for part in instances(SeasonPart)
            df = getplaydata(season, part)
            @test isa(df, DataFrame)
            df = getgamedata(season, part)
            @test isa(df, DataFrame)
        end
    end
end

end  # module TestOfNFLScrapR
