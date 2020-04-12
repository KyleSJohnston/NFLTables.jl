using Pkg

Pkg.develop(PackageSpec(path=pwd()))
Pkg.instantiate()

using Documenter, NFLTables

makedocs(sitename="NFLTables.jl")
