module TestOfNFLScrapRData

using  DataFrames
using  Test

using  NFLTables

@testset "valid seasons" begin
    for season in NFLTables.NFLScrapRData.SEASONS
        @test NFLTables.NFLScrapRData.validseason(season)
    end
end

@testset "nflscrapR-data artifacts" begin
    let season = 2019
        path = NFLTables.NFLScrapRData.season_artifact(season, redownload=false)
        @test isa(path, String)
    end

    @test_throws ErrorException NFLTables.NFLScrapRData.season_artifact(3001)  # invalid season
end

@testset "nflscrapR-data df tests" begin
    let season = 2019
        for part in NFLTables.NFLScrapRData.seasonparts(season)
            df = nflscrapRplaybyplay(season, part)
            @test isa(df, DataFrame)
            df = nflscrapRgame(season, part)
            @test isa(df, DataFrame)
        end
    end
end

end  # module TestOfNFLScrapRData
