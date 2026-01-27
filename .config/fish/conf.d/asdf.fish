set -q ASDF_DATA_DIR; and set -l asdf_root "$ASDF_DATA_DIR"; or set -l asdf_root "$HOME/.asdf"
set -l asdf_shims "$asdf_root/shims"

if test -d "$asdf_shims"
    if not contains "$asdf_shims" $PATH
        set -gx --prepend PATH "$asdf_shims"
    end
end
