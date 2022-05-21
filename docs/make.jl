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
    pages = ["Introduction" => "intro.md", "Usage" => "usage.md"],
    repo = "https://github.com/JuliaCN/Julia2Nix/blob/{commit}{path}#L{line}",
    sitename = "Julia2Nix",
    authors = "JuliaCN and contributors: https://github.com/JuliaCN/Julia2Nix/graphs/contributors",
)

deploydocs(; repo = "github.com/JuliaCN/Julia2Nix", devbranch = "main")
