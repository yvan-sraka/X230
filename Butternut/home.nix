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

{
    imports = [
    ../common/home.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "yvan";
  home.homeDirectory = "/Users/yvan";

  # Q: How to install a user package (add it to my home-manager profile)?
  # To search a new package, run: % nix search wget
  #
  # n.b. Most of my tooling is project-specific, which mean I rather define my
  # developer environment dependencies in a shell.nix than here, what's left is
  # daily routine utilities and GUI software.
  home.packages = with pkgs; [ aerc asciinema pandoc mosh pass gnupg (
    let root = "/Users/yvan/.nixpkgs";
        flake = "${root}\#darwinConfigurations.Butternut.system"; in (
      writeShellScriptBin "upgrade-system" ''
        # nix flake update ${root}
        # ${nix-output-monitor}/bin/nom build ${flake}
        # ./result/sw/bin/darwin-rebuild switch --flake ${root}
        nix-channel --update
        darwin-rebuild switch
      '')
    )];

  # Q: How to script the mouse click on hyperlinks in Kitty?
  # https://sw.kovidgoyal.net/kitty/open_actions/
  #
  # home-manager doesn't have configuration options to generate:
  # $XDG_CONFIG_HOME/kitty/open-actions.conf
  # But we can manage to create a symlink explicitly:
  xdg.configFile = {
    "kitty/open-actions.conf".text = ''
      # Open file and folders listed by `ls --hyperlink=auto` in NeoVim:
      protocol file
      action launch --type=overlay $EDITOR $FILE_PATH

      # Open in Browser URLs highlighted it NeoVim comments:
      protocol https
      action launch --type=background open $URL
    '';
    # n.b. more info on kitty `launch` capabilities here:
    # https://sw.kovidgoyal.net/kitty/launch/
  };

}
