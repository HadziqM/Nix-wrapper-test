{ pkgs, ... }:
let
  zshrc = pkgs.writeText "zshrc" ''
    typeset -U path cdpath fpath manpath

    # for profile in $${(z) NIX_PROFILES}; do
    #   fpath+=($profile/share/zsh/site-functions $profile/share/zsh/$ZSH_VERSION/functions $profile/share/zsh/vendor-completions)
    # done

    HELPDIR="${pkgs.zsh}/share/zsh/$ZSH_VERSION/help"

    autoload -U compinit && compinit
    source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_STRATEGY=(history)


    # History options should be set in .zshrc and after oh-my-zsh sourcing.
    # See https://github.com/nix-community/home-manager/issues/177.
    HISTSIZE="10000"
    SAVEHIST="10000"

    HISTFILE="$HOME/.zsh_history"
    mkdir -p "$(dirname "$HISTFILE")"

    setopt HIST_FCNTL_LOCK
    unsetopt APPEND_HISTORY
    setopt HIST_IGNORE_DUPS
    unsetopt HIST_IGNORE_ALL_DUPS
    unsetopt HIST_SAVE_NO_DUPS
    unsetopt HIST_FIND_NO_DUPS
    setopt HIST_IGNORE_SPACE
    unsetopt HIST_EXPIRE_DUPS_FIRST
    setopt SHARE_HISTORY
    unsetopt EXTENDED_HISTORY


    nix-cleanup() {
      sudo rm /nix/var/nix/gcroots/auto/*
      sudo nix-collect-garbage -d
      sudo nix-store --optimise
    }

    if [[ $TERM != "dumb" ]]; then
      eval "$(${pkgs.atuin}/bin/atuin init zsh)"
      eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
      eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
      eval "$(${pkgs.callPackage ./starship { }} init zsh)"
    fi



    alias -- ..='cd ..'
    alias -- ...='cd ../..'
    alias -- ....='cd ../../..'
    alias -- c=clear
    alias -- cat='bat --style=auto'
    alias -- cd=z
    alias -- e=exit
    alias -- grep=rg
    alias -- h=history
    alias -- la='eza -la'
    alias -- ll='eza -la'
    alias -- ls='eza -l'
    alias -- lt='eza --tree'
    alias -- tree='eza -T'

    source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    ZSH_HIGHLIGHT_HIGHLIGHTERS+=()


  '';
in
pkgs.symlinkJoin {
  name = "zsh";
  buildInputs = [ pkgs.makeWrapper ];
  paths = [ pkgs.zsh ];
  postBuild = ''
    mkdir -p $out/etc/zsh
    cp ${zshrc} $out/etc/zsh/.zshrc

    wrapProgram $out/bin/zsh \
    --set ZDOTDIR $out/etc/zsh
  '';
}
