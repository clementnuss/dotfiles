
fish_vi_key_bindings
function fish_user_key_bindings
    # Execute this once per mode that emacs bindings should be used in
    fish_default_key_bindings -M insert

    # Then execute the vi-bindings so they take precedence when there's a conflict.
    # Without --no-erase fish_vi_key_bindings will default to
    # resetting all bindings.
    # The argument specifies the initial mode (insert, "default" or visual).
    fish_vi_key_bindings --no-erase insert
end

# Homebrew
eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)

# Krew
fish_add_path ~/.krew/bin

# Rust
fish_add_path ~/.cargo/bin 

# LunarVim
fish_add_path ~/.local/bin 

set -gx GOPATH $HOME/go
fish_add_path $GOPATH/bin

starship init fish | source

set -gx EDITOR nvim

