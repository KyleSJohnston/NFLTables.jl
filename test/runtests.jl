module NFLTablesTest

using  DataFrames
using  Documenter: DocMeta, doctest
using  Logging

using  NFLTables

# Configure logging
Logging.disable_logging(Logging.Info)
logger = Logging.ConsoleLogger(stderr, Logging.Warn)

with_logger(logger) do

    tests = ["enumerations"]

    for test in tests
        include("$(test).jl")
    end

    DocMeta.setdocmeta!(
        NFLTables,
        :DocTestSetup,
        :(using DataFrames, NFLTables),
        recursive=true,
    )
    doctest(NFLTables; manual=false)

end

end  # module NFLTablesTest
