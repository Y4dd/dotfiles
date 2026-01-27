set -gx TERMINAL kitty
set -q EDITOR; or set -gx EDITOR nvim
set fish_greeting ""

if status is-login
    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
        exec sway
    end
end

if status is-interactive
  fish_vi_key_bindings
  zoxide init --cmd cd fish | source
  direnv hook fish | source

  # This assumes FZF exists
  set fzf_directory_opts --bind "ctrl-n:execute($EDITOR {} &> /dev/tty)"
end

