module TestOfNFLScrapRData

using  Test
using  NFLTables.NFLScrapRData

for season in 2009:2019
    for part in ("pre", "reg", "post")
        path = playbyplaypath(season, part)
        @test typeof(path) == String
        path = gamepath(season, part)
        @test typeof(path) == String
    end
end

end  # module TestOfNFLScrapRData
