using TOML
using Downloads: download
using Tar
using GitCommand
using p7zip_jll
using Test

using julia2nix
using julia2nix: run_suppress, sanitize_name, git_short_rev, url_name
using julia2nix: Base32Nix, SRI, Hash

noall(cmd::Cmd) = pipeline(cmd; stdout = devnull, stderr = devnull)

function nix_file_sha256(path)
    return Hash(strip(run_suppress(`nix hash file $path`, out = true)))
end

function nix_dir_sha256(path)
    return Hash(strip(run_suppress(`nix hash path $path`, out = true)))
end

function nix_eval_source_attr(dir, attr)
    expr = "(import $(dir)/NixManifest.nix {}).$(attr)"
    return strip(run_suppress(`nix eval --impure --raw --expr $expr`, out = true))
end

function compare_source_attr(dir, truth, attr::AbstractString)
    value = nix_eval_source_attr(dir, attr)
    expected = truth[attr]
    res = value == expected
    !res && @error "value: $value != expected: $expected"
    return value == expected
end

function compare_source_attrs(dir, truth)
    @testset "attr: $(attr)" for attr in sort(collect(keys(truth)))
        @test compare_source_attr(dir, truth, attr)
    end
end

function with_unpack(fn::Function, archive_path::AbstractString; strip::Bool = false)
    mktempdir() do dst
        if endswith(archive_path, ".zip")
            run_suppress(`$(p7zip_jll.p7zip()) x $archive_path -o$(dst)`)
        else
            Tar.extract(`$(p7zip_jll.p7zip()) x $archive_path -so`, dst)
        end

        if strip
            paths = readdir(dst)
            if length(paths) > 1
                error("Archive must contain a single file or directory if strip==true")
            else
                onlydir = joinpath(dst, only(paths))
                if isdir(onlydir)
                    mktempdir() do stripdst
                        for (root, _, files) in walkdir(onlydir)
                            for file in files
                                srcfile = joinpath(root, file)
                                dstfile = joinpath(
                                    stripdst,
                                    relpath(joinpath(dst, root, srcfile), onlydir),
                                )
                                mkpath(dirname(dstfile))
                                cp(srcfile, dstfile)
                            end
                        end
                        fn(stripdst)
                    end
                end
            end
        else
            fn(dst)
        end
    end
end

function with_clone_and_checkout(fn, url, ref_or_rev; leave_git = false)
    mktempdir() do dir
        out = joinpath(dir, "out")
        run_suppress(`$(git()) clone $(url) $(out)`)
        run_suppress(`$(git()) -C $(out) checkout $(ref_or_rev)`)
        if !leave_git
            rm(joinpath(out, ".git"); recursive = true, force = true)
        end
        fn(out)
    end
end

function with_update(fn::Function, toml::AbstractDict)
    mktempdir() do dir
        open("$(dir)/NixProject.toml", "w") do io
            TOML.print(io, toml)
        end
        update(dir)
        fn(dir)
    end
end

function runtest(toml::AbstractDict, truth::AbstractDict)
    with_update(toml) do dir
        compare_source_attrs(dir, truth)
    end
end

# TODO
# function nested_dict(entries::Pair...)
#     x = Dict()
#     for (ks, v) in entries
#         x_cur = x
#         while length(ks) > 1
#             k, ks = Base.first(ks), Base.tail(ks)
#             x_cur = x_cur[k] = Dict()
#         end
#         x_cur[only(ks)] = v
#     end
#     x
# end
