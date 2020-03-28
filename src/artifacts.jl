module Artifacts

using  Pkg.Artifacts:
    artifact_exists, artifact_hash, artifact_path, bind_artifact!, create_artifact

const ARTIFACT_TOML = joinpath(@__DIR__, "..", "Artifacts.toml")

"""
Adapted from https://julialang.github.io/Pkg.jl/v1/artifacts/#Using-Artifacts-1
"""
function get(f::Function, name::AbstractString; redownload::Bool=false)
    hash = artifact_hash(name, ARTIFACT_TOML)
    # If the name was not bound, or the hash it was bound to does not exist, create it!
    if redownload || hash == nothing || !artifact_exists(hash)
        # create_artifact() returns the content-hash of the artifact directory once we're finished creating it
        hash = create_artifact(f)
        bind_artifact!(ARTIFACT_TOML, name, hash, force=true)
    end
    return artifact_path(hash)

end

get(name::AbstractString) = artifact_path(artifact_hash(name, ARTIFACT_TOML))

end  # module Artifacts
