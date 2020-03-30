module TestOfNFLScrapRData

using  DataFrames
using  Test

using  NFLTables.NFLScrapRData
import NFLTables.NFLScrapRData: SEASONS, seasonparts, season_artifact, validseason

@testset "valid seasons" begin
    for season in SEASONS
        @test validseason(season)
    end
end

@testset "nflscrapR-data artifacts" begin
    for season in SEASONS
        path = season_artifact(season, redownload=false)
        @test isa(path, String)
    end

    @test_throws ErrorException season_artifact(3001)  # invalid season
end

@testset "nflscrapR-data df tests" begin
    for season in SEASONS, part in seasonparts(season)
        df = playbyplay(season, part)
        @test typeof(df) == DataFrame
        df = game(season, part)
        @test typeof(df) == DataFrame
    end
end

end  # module TestOfNFLScrapRData
