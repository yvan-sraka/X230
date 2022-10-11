# Hello everyone,
#
# This is the NixOS configuration of my beloved <3 ThinkPad X230.
#
# Below you will find my personal effort to keep my setup "minimal", and to
# answer in an FAQ-style structured way common questions I encounter as a NixOS
# power user.
#
# This file should (indeed) be located in `/etc/nixos/` folder :)

{ pkgs, lib, ... }: {

  imports = [

    # Q: How to split my configuration into several Nix files?
    ./devtools.nix
    ./network.nix
    # n.b. this is the really subjective configuration organization that
    # survive a lot of my edits... I strongly invite anyone reading this to
    # check out these files ;)

  ];

  # Q: How to enable nix flakes feature (before it became upstream)?
  nix.package = pkgs.nixFlakes;

  # Q: How to do automatic garbage collection?
  # https://nixos.org/manual/nixos/stable/index.html#sec-nix-gc
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  # Q: How to configure network proxy if necessary?
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Q: How to display, when doing `nix-rebuild`, the packages differences
  # between the current system and the new generation?

  # system.activationScripts.diff = ''
  #   ${pkgs.nixUnstable}/bin/nix store \
  #       --experimental-features 'nix-command' \
  #       diff-closures /run/current-system "$systemConfig"
  # '';

  system.activationScripts.postUserActivation = {
    text = ''
      if [[ -e /run/current-system ]]; then
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin \
        diff /run/current-system "$systemConfig"
      fi
    '';
  } // lib.optionalAttrs pkgs.stdenv.isLinux {
    supportsDryActivation = true;
  };

  # Q: How to disable channels (since I use flakes)?
  # nix.channel.enable = false;
}

# Thanks' for reading! /yvan
