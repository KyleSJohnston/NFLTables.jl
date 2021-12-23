# $ julia --project=docs/ --color=yes docs/make.jl
using Documenter, NFLTables

makedocs(sitename="NFLTables.jl"; strict=true)

deploydocs(repo="github.com/KyleSJohnston/NFLTables.jl.git")
