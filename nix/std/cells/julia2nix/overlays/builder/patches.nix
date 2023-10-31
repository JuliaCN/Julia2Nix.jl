{ path }:
{
  Conda = ''
    mkdir -p $out/conda/3
    cat > $out/${path}/deps/deps.jl <<EOF
    const CONDA_EXE = "$out/conda/3/bin/conda"
    const ROOTENV = "$out/conda/3"
    const USE_MINIFORGE = true
    const MINICONDA_VERSION = "3"
    EOF
  '';
  PyCall = ''
    cat > $out/${path}/deps/deps.jl <<EOF
    const python = "$(julia -e 'println(ENV["PYTHONVERSION"])')"
    const libpython = "$(julia -e 'println(ENV["PYTHONLIB"])')"
    const pyprogramname = "$(julia -e 'println(ENV["PYTHON"])')"
    const pyversion_build = v"$(julia -e 'println(ENV["PYTHONVERSION"])')"
    const PYTHONHOME = "$(julia -e 'println(ENV["PYTHONHOME"])')"
    const conda = false
    EOF
  '';
}
