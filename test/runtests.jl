module NFLTablesTest

using NFLTables

tests = ["enumerations", "schedules", "NFLScrapRData"]

for test in tests
    include("$(test).jl")
end

end  # module NFLTablesTest
