# Hello everyone,
#
# Here is my home-manager configuration, I try to keep consistency by putting
# in this file (rather than in /etc/nixos/):
#
# - everything that is related to my user configuration (e.g. what that needs
#   to access my GPG keys, like git commit signing feature or password manager)
#
# - my graphical environment and applications running on top of it, since there
#   are no other users on my computer that I want to launch it (e.g. running it
#   as root or nix is indeed a bad idea ...)
#
# I use an Q/A code comments style to ~~improve SEO~~, organize all the Nix
# stuffs in a "literate programming"-like format, I hope that you, the unknown
# reader that found a way to this page, will like it!
#
# This file location should be $XDG_CONFIG_HOME/nixpkgs/home.nix where usually
# XDG_CONFIG_HOME="$HOME/.config"
#
# Also note that nothing in this file should be hardware-specific :)
#
# A manual page of all home-manager options could be find here:
# https://nix-community.github.io/home-manager/options.html

{ pkgs, ... }:

rec {

  # Q: How to let Home Manager install and manage itself?
  # https://github.com/nix-community/home-manager
  programs.home-manager.enable = true;

  # Q: How to determines whether to check for release version mismatch between
  # Home Manager and Nixpkgs.
  home.enableNixpkgsReleaseCheck = true;
  home.stateVersion = "22.05";

  # Q: How to display changes between two generations of my home-manager config?
  #
  # home.activation.report-changes = config.lib.dag.entryAnywhere ''
  #   ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin \
  #     diff $oldGenPath $newGenPath
  # '';
  #
  # n.b. I disabled it since I manage my home-manager config with nixos-rebuild!

  # Q: How to enable programs (and their integrate them to your shell)?
  programs.fzf.enable = true;
  programs.gh = { enable = true; settings.git_protocol = "ssh"; };
  # programs.keychain.enable = true;
  # programs.lesspipe.enable = true;

  # Q: How to set my ENV session variables in home-manager?
  home.sessionVariables = {
    # n.b. Electron based desktop applications (to open links) seems use:
    DEFAULT_BROWSER = "firefox";
  };

  # Q: How to have a cool GPU-based terminal emulator?
  # Try out https://sw.kovidgoyal.net/kitty/
  programs.kitty = {
    enable = true;
    # n.b. Kitty (and not Alacritty as I'm writing these lines...) support
    # fonts with code ligatures like https://github.com/tonsky/FiraCode <3
    font = { package = pkgs.jetbrains-mono; name = "JetBrains Mono"; };
    settings = {
      font_size = 14; # Teacher mode: ON
      background = "#ffffff";
      foreground = "#000000";
    };
  };
  # c.f. https://sw.kovidgoyal.net/kitty/integrations/ for more integrations

  # Q: How to fix wrong terminal colors in tmux?
  # n.b. this also apply to tmate that use the same configuration file.
  programs.tmux = { enable = true; terminal = "xterm-kitty"; escapeTime = 0; };

  # Q: How to install Git with all features enabled?
  # e.g. https://git-send-email.io/ <3
  programs.git = {
    enable = true;

    package = pkgs.gitFull;
    lfs.enable = true;

    userName = "Yvan Sraka";
    userEmail = "yvan@sraka.xyz";

    # Q: How to sign all my git commits with my GPG key?
    signing = { key = " 370B823A2A0C7478"; signByDefault = true; };

    # Q: How to have Git company-specific settings applied in a work subfolder?
    includes = [{
      condition = "gitdir:/home/yvan/IOHK/"; # guess my workplace ;)
      contents.user = {
        email = "yvan.sraka@iohk.io";
        signingKey = "7863B37932A7BA70";
      };
    }];

    # Q: How to have have syntax-based more consistent git diff?
    # Try out https://github.com/Wilfred/difftastic
    # difftastic.enable = true;
  };

  # Q: Why my fancy CLI tool does not seems to work without manual tweaking?
  # Well, very program that comes with `.enableZshIntegration = true` by
  # default needs Zsh configuration to be managed by home-manager:
  programs.zsh.enable = true;
  # The same for Bash (`nix-shell` default) and `.enableBashIntegration = true`
  programs.bash.enable = true;

  # Q: How to have a faster, persistent implementation of direnv's `use_nix`?
  # https://github.com/nix-community/nix-direnv
  programs.direnv = { enable = true; nix-direnv.enable = true; };

  # Q: How to have native messaging host of browser extension for zx2c4's pass?
  # https://github.com/browserpass/browserpass-extension
  programs.browserpass = { enable = true; browsers = [ "firefox" ]; };

  programs.zellij = {
    enable = true;
    settings = {
      pane_frames = false;
      simplified_ui = true;
      theme = "ansi-colors";
      themes."ansi-colors" = {
        black = 0; red = 1; green = 2; yellow = 3; blue = 4; magenta = 5; cyan = 6; white = 7;
        fg = 7; bg = 0; orange = 1;
      };
    };
  };

  programs.helix = {
    enable = true;
    # defaultEditor = true;
    settings = {
      editor = {
        color-modes = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        idle-timeout = 0;
        lsp.display-messages = true;
        line-number = "relative";
        rulers = [80];
      };
      theme = "emacs_italic";
    };
    themes.emacs_italic = {
      inherits = "emacs";
      comment = { fg = "firebrick"; modifiers = ["italic"]; };
      keyword = { fg = "purple";    modifiers = ["italic"]; };
      type = { fg = "forest_green"; modifiers = ["italic"]; };
    };
    themes.emacs_no_italic = {
      inherits = "emacs";
      "markup.italic" = { modifiers = []; };
    };
  };

  # tmux doesn't seems to like italic modifiers ...
  xdg.configFile."helix/fallback-config.toml".source = (pkgs.formats.toml {}).generate "helix-fallback-config" (
    programs.helix.settings // {
      theme = "emacs_no_italic";
    }
  );

  # I want to have my toy programming language highlighted in Helix!
  xdg.configFile."helix/languages.toml".source = (pkgs.formats.toml {}).generate "helix-languages" {
    language = [{
      name = "bee";
      scope = "source.bee";
      injection-regex = "bee";
      file-types = ["bee"];
      roots = ["main.bee"];
      comment-token = "//";
      indent = {
        tab-width = 4;
        unit = "    ";
      };
    } {
      name = "typescript";
      language-servers = [ "ts" "gpt" ];
    }];
    grammar = [{
      name = "bee";
      source = {
        path = "~/bee-lang/tree-sitter-bee-lang";
      };
    }];
    language-server = {
      gpt = { command = "helix-gpt"; };
    };
  };
}

# Thanks' for reading! /yvan
