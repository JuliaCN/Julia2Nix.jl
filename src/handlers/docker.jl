# TODO allow ref to be sourceified

const DOCKER_SCHEMA = SchemaSet(
    SimpleSchema("image_name", String, true),
    SimpleSchema("image_tag", String, false),
    SimpleSchema("image_digest", String, false),
    SimpleSchema("os", String, false),
    SimpleSchema("arch", String, false),
)

function docker_handler(name, spec)
    args = [
        "--json",
        "--image-name",
        spec["image_name"],
        "--image-tag",
        get(spec, "image_tag", "latest"),
        "--os",
        get(spec, "os", get_docker_os()),
        "--arch",
        get(spec, "arch", get_docker_arch()),
    ]
    haskey(spec, "image_digest") && append!(args, [ "--image-digest", spec["image_digest"] ])
    info = JSON.parse(strip(run_suppress(`nix-prefetch-docker $args`; out=true)))
    fetcher_name = "pkgs.dockerTools.pullImage"
    fetcher_args = Dict(Symbol(k) => v for (k, v) in info)
    return Source(; pname=name, version=info["finalImageTag"], fetcher_name, fetcher_args)
end

# See: 
# https://github.com/opencontainers/image-spec/blob/main/config.md#properties
# https://golang.org/doc/install/source#environment
function get_docker_arch()
    arch = Base.BinaryPlatforms.HostPlatform().tags["arch"]
    return if arch == "aarch64"
        "arm64"
    elseif (arch == "armv7l" || arch == "armv6l")
        "arm"
    elseif arch == "i686"
        "386"
    else
        "amd64"
    end
end

# TODO
function get_docker_os()
    os = Base.BinaryPlatforms.HostPlatform().tags["os"]
    return os
end
