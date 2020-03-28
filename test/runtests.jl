module NFLTablesTest

using  Logging
using  NFLTables

# Configure logging
logger = Logging.ConsoleLogger(stderr, Logging.Debug)

with_logger(logger) do

    tests = ["enumerations", "schedules", "NFLScrapRData"]

    for test in tests
        include("$(test).jl")
    end

end
end  # module NFLTablesTest
