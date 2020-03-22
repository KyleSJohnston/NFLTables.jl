module NFLTablesTest

using NFLTables

tests = ["enumerations", "NFLScrapRData"]

for test in tests
    include("$(test).jl")
end

end  # module NFLTablesTest
