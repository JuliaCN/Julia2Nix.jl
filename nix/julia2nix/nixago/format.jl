using JuliaFormatter
using ArgParse

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "file"
        help = "format with your jl"
        required = true
        default = "."
    end

    return parse_args(s)
end

command = parse_commandline()

format_file(".")
