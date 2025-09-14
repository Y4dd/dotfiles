# =========================================
# ---------- File initialization ----------
# =========================================
if test -f ~/.config/fish/env.fish
  source ~/.config/fish/env.fish
end

if test -f ~/.config/fish/paths.fish
  source ~/.config/fish/paths.fish
end

if test -f ~/.config/fish/binds.fish
  source ~/.config/fish/binds.fish
end

# ================================
# ---------- Basic fish ----------
# ================================
fish_vi_key_bindings
if not set -q __theme_set
    fish_config theme choose "jellybeans"
    set -g __theme_set 1
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fish_greeting ""
set -gx TERMINAL kitty
zoxide init --cmd cd fish | source
direnv hook fish | source

# This assumes fzf is installed
set -q EDITOR; or set -gx EDITOR nvim
set fzf_directory_opts --bind "ctrl-n:execute($EDITOR {} &> /dev/tty)"


# =========================================
# ---------- ASDF Configuration -----------
# =========================================
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims


# ===================================
# ---------- Theme config -----------
# ===================================
set _sun_dark 36342a
set _sun_yellow f9de74

set -g tide_pwd_bg_color $_sun_yellow
set -g tide_pwd_color_anchors $_sun_dark
set -g tide_pwd_color_dirs $_sun_dark

set -g tide_left_prompt_items pwd git newline character
set -g tide_character_color $_sun_yellow

