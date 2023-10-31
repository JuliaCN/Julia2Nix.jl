set -e
for link; do
  test -h "$link" || continue

  dir=$(dirname "$link")
  reltarget=$(readlink "$link")
  case $reltarget in
  /*) abstarget=$reltarget ;;
  *) abstarget=$dir/$reltarget ;;
  esac

  rm -fv "$link"
  cp -afv "$abstarget" "$link" || {
    # on failure, restore the symlink
    rm -rfv "$link"
    ln -sfv "$reltarget" "$link"
  }
done
