{ config, pkgs, lib, ... }:

let name = "Reylee";
    user = "reylee";
    email = "reynard_lee_from.tp@mom.gov.sg"; in
{
  # Shared shell configuration
  zsh.enable = true;
  zsh.autocd = false;
  zsh.plugins = [
    {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    }
    {
        name = "powerlevel10k-config";
        src = lib.cleanSource ./config;
        file = "p10k.zsh";
    }
  ];
  zsh.initExtraFirst = ''
    if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
      . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
    fi

    # Define variables for directories
    export PATH="$HOME/.pnpm-packages/bin:$HOME/.pnpm-packages:$HOME/.npm-packages/bin:$HOME/bin:$HOME/.local/share/bin:$HOME/.cargo/bin:$PATH"
    export PNPM_HOME="$HOME/.pnpm-packages"


    # Remove history data we don't want to see
    export HISTIGNORE="pwd:ls:cd"

    # nix shortcuts
    shell() {
        nix-shell '<nixpkgs>' -A "$1"
    }

    # Use difftastic, syntax-aware diffing
    alias diff=difft

    # Always color ls and group directories
    alias ls='ls --color=auto'

    # my own stuff
    eval "$(fnm env --use-on-cd)"

    export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-8.jdk/contents/home
    export PATH="/opt/local/libexec/gnubin:/opt/local/bin:$PATH"
    export PATH="/Users/reylee/Library/Python/3.9/bin:$PATH"

    if command -v pyenv 1>/dev/null 2>&1; then
      eval "$(pyenv init -)"
    fi
    eval "$(atuin init zsh)"
    eval "$(zoxide init zsh)"

    # bun completions
    [ -s "/Users/reylee/.bun/_bun" ] && source "/Users/reylee/.bun/_bun"

    # bun
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"

    alias lg=lazygit
  '';

}
