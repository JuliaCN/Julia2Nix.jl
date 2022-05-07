using Documenter
using Org

orgfiles = filter(f -> endswith(f, ".org"), readdir(joinpath(@__DIR__, "src"), join = true))

for orgfile in orgfiles
    mdfile = replace(orgfile, r"\.org$" => ".md")
    read(orgfile, String) |>
    c ->
        Org.parse(OrgDoc, c) |>
        o ->
            sprint(markdown, o) |>
            s -> replace(s, r"\.org]" => ".md]") |> m -> write(mdfile, m)
end

makedocs(;
    format = Documenter.HTML(),
    pages = ["Introduction" => "index.md", "Usage" => "usage.md"],
    repo = "https://github.com/JuliaCN/julia2nix/blob/{commit}{path}#L{line}",
    sitename = "julia2nix",
    authors = "JuliaCN and contributors: https://github.com/JuliaCN/julia2nix/graphs/contributors",
)

deploydocs(; repo = "github.com/JuliaCN/julia2nix", devbranch = "main")
