# TODO delete unneeded stuff
# TODO bootstrap nixpkgs
# TODO make manifest read data from project rather than copying over info?

module julia2nix

using Base
using TOML
using JSON
using HTTP
using Git
using Dates
using ArgParse
using Pkg
using Random
using URIs
using Printf
using SHA
using Test
using TranscodingStreams, CodecBase


Base.include(@__MODULE__, joinpath(Sys.BINDIR, "..", "share", "julia", "test", "testhelpers", "FakePTYs.jl"))
using .FakePTYs: open_fake_pty

export update
export update_package
export Nix

const NO_HASH_FETCHERS = (
    "builtins.fetchGit",
)

const UPDATE_SCRIPT_FILENAME = "nix_update.jl"
const FLAKE_FILENAME = "flake.nix"
const JULIA_PROJECT_FILENAME = "Project.toml"
const MANIFEST_FILENAME = "NixManifest.nix"
const PROJECT_FILENAME = "NixProject.toml"
const PAD_WIDTH = 4


include("Nix.jl")
using .Nix

include("types.jl")
include("hash.jl")
include("util.jl")

include("handlers/git.jl")
include("handlers/github.jl")
include("handlers/file.jl")
include("handlers/archive.jl")
include("handlers/crate.jl")
include("handlers/docker.jl")
include("handlers/snap.jl")

include("update.jl")
include("test.jl")
include("main.jl")

include("JuNix/JuNix.jl")

const SCHEMAS = Dict(
    "github" => GITHUB_SCHEMA,
    "file" => FILE_SCHEMA,
    "archive" => ARCHIVE_SCHEMA,
    "crate" => CRATE_SCHEMA,
    "git" => GIT_SCHEMA,
    "docker" => DOCKER_SCHEMA,
    "snap" => SNAP_SCHEMA
)

const HANDLERS = Dict(
    "github" => github_handler,
    "file" => file_handler,
    "archive" => archive_handler,
    "crate" => crate_handler,
    "git" => git_handler,
    "docker" => docker_handler,
    "snap" => snap_handler
)

const DEFAULT_NIX = joinpath(@__DIR__, "../../default.nix")

end # module
