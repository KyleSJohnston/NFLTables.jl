module TestOfNFLScrapRData

using  DataFrames
using  Test

using  NFLTables.NFLScrapRData
import NFLTables.NFLScrapRData: gamepath, playbyplaypath

seasons = 2009:2018  # 2019 is still in progress, omit from testing
parts = ("pre", "reg", "post")

@testset "nflscrapR-data path tests" begin
    for season in seasons, part in parts
        path = playbyplaypath(season, part)
        @test typeof(path) <: String
        path = gamepath(season, part)
        @test typeof(path) <: String
    end
end

if haskey(ENV, "NFLSCRAPR_DATA")
    # only run full data tests if the data is local
    @testset "nflscrapR-data df tests" begin
        for season in seasons, part in parts
            df = playbyplay(season, part, root=ENV["NFLSCRAPR_DATA"])
            @test typeof(df) == DataFrame
            df = game(season, part, root=ENV["NFLSCRAPR_DATA"])
            @test typeof(df) == DataFrame
        end
    end
end

end  # module TestOfNFLScrapRData
