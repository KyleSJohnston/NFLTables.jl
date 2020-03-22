module TestEnumerations

using  NFLTables.Enumerations
using  Test

@test length(instances(Season)) == 50
@test length(instances(SeasonPart)) == 3
@test length(instances(SuperBowl)) == 54

end  # module
