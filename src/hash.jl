abstract type Algorithm end
struct MD5 <: Algorithm end
struct SHA1 <: Algorithm end
struct SHA256 <: Algorithm end
struct SHA512 <: Algorithm end
sri_prefix(::T) where {T<:Algorithm} = lowercase(string(nameof(T)))

abstract type Encoding end
struct Base16 <: Encoding end
struct Base32 <: Encoding end
struct Base32Nix <: Encoding end
struct Base64 <: Encoding end
struct SRI <: Encoding end

struct Hash{E,A}
    value::Vector{UInt8}
    function Hash{E,A}(value) where {E,A}
        @assert E isa Encoding
        @assert A isa Algorithm
        new{E,A}(convert(Vector{UInt8}, value))
    end
end

function Hash(sri::AbstractString) 
    m = match(r"(.*)-(.*)", sri) 
    m === nothing && nixsourcerer_error("Not an SRI hash: $h")

    algorithm, value_enc = m.captures
    A = algorithm == "md5" ? MD5() :
        algorithm == "sha1" ? SHA1() :
        algorithm == "sha256" ? SHA256() :
        algorithm == "sha512" ? SHA512() :
        nixsourcerer_error("Unknown hash type: $algorithm")
    return Hash{SRI(),A}(transcode(Base64Decoder(), String(value_enc)))
end

value(h::Hash) = h.value
algorithm(::Hash{E,A}) where {E,A} = A 
encoding(::Hash{E,A}) where {E,A} = Encoding

function Base.convert(::Type{<:Hash{E}}, h::Hash) where {E}
    return Hash{E,algorithm(h)}(value(h))
end

function Base.show(io::IO, h::Hash)
    Base.show(io, typeof(h))
    write(io, " (", string(h), ")")
    return nothing
end

function Base.string(h::Hash{E}; encoding::Encoding=E) where {E}
    if encoding === Base32Nix()
        sri = convert(Hash{SRI()}, h)
        s = strip(read(`nix hash to-base32 $sri`, String))
    else
        encoder = 
            encoding === Base16() ? Base16Encoder() :
            encoding === Base32() ? Base32Encoder() :
            encoding === Base64() ? Base64Encoder() :
            encoding === SRI() ? Base64Encoder() :
            nixsourcerer_error("Unknown encoding: $(encoding)")
        s = String(transcode(encoder, value(h)))
    end
    return encoding === SRI() ? "$(sri_prefix(algorithm(h)))-$(s)" : s
end

version_string(h::Hash) = git_short_rev(string(h; encoding=Base32Nix()))
