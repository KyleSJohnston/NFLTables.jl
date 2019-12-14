module NFLTablesTest

using NFLTables

tests = ["NFLScrapRData"]

for test in tests
    include("$(test).jl")
end

end  # module NFLTablesTest
