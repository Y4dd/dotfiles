set -q EDITOR; or set -gx EDITOR nvim
set fish_greeting ""

if status is-login
    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
        exec sway
    end
end

if status is-interactive
    set -g fzf_directory_opts --bind "ctrl-n:execute($EDITOR {} &> /dev/tty)"
end
