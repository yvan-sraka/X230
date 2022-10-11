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

  documentation.dev.enable = true;

  users.defaultUserShell = pkgs.zsh;

  # Q: How to install Git with all features enabled?
  # e.g. https://git-send-email.io/ <3
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    lfs.enable = true;
    config = {
      # Q: How do I use ~~Neovim~~ Helix as prefered editor?
      # core.editor = "hx";
      # diff.tool = "hx";
      # difftool.nvimdiff.cmd = ''nvim -d "$LOCAL" "$REMOTE"'';
      # Q: How to have good Git defaults?
      init.defaultBranch = "main";
      pull.ff = "only";
      push.autoSetupRemote = true;
      url."ssh://git@github.com/".insteadOf = [ "gh:" "github:" ];
    };
  };

  # Q: How to get ADB (Android Debug Bridge) working?
  programs.adb.enable = true;
  services.udev.packages = [ pkgs.android-udev-rules ];
  users.users.yvan.extraGroups = [ "adbusers"  "docker"  ];

  # Q: How to set up a Docker environment?
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # virtualisation.virtualbox.host = {
  #   enable = true;
  #   enableExtensionPack = true;
  # };
  # users.extraGroups.vboxusers.members = [ "yvan" ];

  virtualisation.waydroid.enable = true;

  # Q: How to get a macOS copy running in a Virtual Machine?
  # https://github.com/kholia/OSX-KVM
  # n.b. this is needed to get a bridge with DHCP enabled:
  virtualisation.libvirtd.enable = true;
  # The libvirtd module currently requires Polkit to be enabled
  security.polkit.enable = true;
  users.extraUsers.yvan.extraGroups = [ "libvirtd" ];
  # n.b. reboot your computer after adding those lines:
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_intel emulate_invalid_guest_state=0
    options kvm ignore_msrs=1
  '';
  # I start considering https://github.com/banhbaoxamlan/X230-Hackintosh as a
  # reliable solution to not need an Apple hardware :)

}

# Thanks' for reading! /yvan
