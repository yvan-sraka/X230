# Hello everyone,
#
# This section focus on tools and settings that I need in my developer journey!
#
# Most of my project-specific environments are defined in custom shell.nix ;
# I advise you to take a look at nixpkgs manual for per-programming language
# instruction -> https://nixos.org/manual/nixpkgs/stable/#chap-language-support
#
# What's left? Mostly utils, I want to be available handily without spawning a
# % nix-shell
#
# About my daily tech habits:
#
# - I spend a lot of time in my terminal emulator (man + zsh + neovim + git)
# - I often hack on Android/iOS mobile and other embedded devices
# - I (again) always prefer working in an `nix-shell --pure` environment ;)

{ pkgs, ... }:

{

  # Q: How to always install all the man pages?
  environment.extraOutputsToInstall = [ "info" "man" "devman" ];

  # Q: How to get completion for system packages (e.g. systemd)?
  environment.pathsToLink = [ "/share/zsh" ];

  # Q: How to enable auto-suggestions/completion into Zsh?
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    promptInit = ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell zsh --info-right | source /dev/stdin
      # Best configuration is https://grml.org/zsh/
      source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
      # Developer envirenments not managed by Nix ...
      export PATH="$PATH:$HOME/.cargo/bin"
      export PATH="$PATH:$HOME/.ghcup/bin"
      # Tweaks to have Helix looks great through tmate or ssh
      export EDITOR="hx"
      if [[ "$TMUX" == *tmate* ]]; then
        export EDITOR="hx -c ~/.config/helix/fallback-config.toml"
        alias hx="$EDITOR"
      fi
      ssh-colorterm() { ssh -t "$@" "export COLORTERM=$COLORTERM; exec \$SHELL" }
    '';
  };

  programs.tmux = {
    enable = true;
    # extraConfig = builtins.readFile (
    #   ./tumx.conf
    # #   builtins.fetchurl {
    # #     url = "https://git.grml.org/f/grml-etc-core/etc/tmux.conf";
    # #     sha256 = "1ysb9jzhhpz160kwcf4iafw7qngs90k3rgblp04qhz5f8gjy6z03";
    # #   }
    # );
  };

  # Q: How to set up your preferred EDITOR and PAGER through ENV variables?
  # environment.variables = {
  #   EDITOR = "hx";
  #   VISUAL = "hx";
  # };

  environment.systemPackages =
    # Q: How to override a system package in NixOS?
    # let neovimOverrided = pkgs.neovim.override {
    #   viAlias = true; vimAlias = true;
    #   configure = {
    #     # Q: How to declare my (Neo)Vim package in NixOS configuration?
    #     packages.myPlugins = with pkgs.vimPlugins; {
    #       # n.b. https://vimawesome.com is a good place to find new plugins ;)
    #       start = [ coc-clangd coc-nvim coc-rust-analyzer editorconfig-vim
    #                 vim-lastplace vim-nix vim-toml ];
    #     };
    #     # Q: How to use a custom `vimrc` (mine is GRML one)?
    #     # https://nixos.org/manual/nix/stable/expressions/builtins.html
    #     customRC = builtins.readFile ./vimrc;
    #   };
    # }; in

  # List packages installed in system profile. To search, run:
  # % nix search wget
  with pkgs; [
    kitty helix
    # Helix/Neovim (https://github.com/neoclide/coc.nvim require `node` in PATH)
    nodejs nodePackages.typescript-language-server marksman
    # C/C++/Rust
    gnumake lldb llvmPackages.clang-unwrapped rustup
    # Haskell
    cabal-install ghc haskell-language-server
    # Nix
    nil nix-prefetch nix-tree nixfmt nixos-option nixpkgs-review shellcheck
    # Misc
    bottom dig fd file jq ripgrep tldr tmate tree unzip wget zellij zip
  ];
}

# Thanks' for reading! /yvan
