# JuNix

```@meta
CurrentModule = Julia2Nix.JuNix
```

### types
```@docs
collect_registries
get_tarball_registry_path
extract_tarball
registry_relpath
```

### fetch
```@docs
is_artifact_required
select_fetcher
```

### util
```@docs
get_archive_url_for_version
get_pkg_url
get_source_path
convert_sha256
fetch_sha256
parse_fetcher
get_os_from_opts
is_git_repo
get_repo_meta
```

### JuNix

```@docs
load_registries!
load_artifacts!
write_julia2nix
generate_depot
```
