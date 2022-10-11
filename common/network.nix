# Hello everyone,
#
# Here, I choose to define everything that deals with my internet connectivity ;
# meaning, remote services like SSH, firewall, Wi-Fi passwords and Nix custom
# settings (build cache and machines) that help a lot my old and lazy CPU to
# not deal with complex builds itself!

{ lib, ... }: {

  # Q: How to set up Tailscale (a VPN service based on WireGuard)?
  services.tailscale.enable = true;
  # ... and then: % sudo tailscale up
  # c.f. you may want to check out https://tailscale.com/kb/1103/exit-nodes/

  # Q: How to open ports in the firewall?
  # https://nixos.org/manual/nixos/stable/index.html#sec-firewall
  # networking.firewall.allowedUDPPorts = [ ];
  # networking.firewall.allowedTCPPorts = [
  #   ... e.g. add 80 443 here to allow connection to a local HTTP(S) server :)
  # ];

  # Q: How to set up Remote Builders?
  # https://nixos.org/manual/nix/stable/advanced-topics/distributed-builds.html
  # nix.buildMachines = map (x: {
  #   hostName = "builder@x86_64-linux-${toString x}.zw3rk.com";
  #   maxJobs = 16; speedFactor = 16;
  #   systems = [ "x86_64-linux" ];
  #   supportedFeatures = [ "benchmark" "big-parallel" "kvm" "nixos-test" ];
  #   mandatoryFeatures = [ ];
  # }) (lib.range 2 8);

  # Note: so apparently the nix installer from nixos.org doesn't set
  # trusted-users = @admin anymore. Basically no one is trusted.
  # This means in turn that any substituter a flake tries to set, is ignored.
  nix.settings.trusted-users = [ "root" "nix" "yvan" ]; # <- /!\
  # ... this is something you typically want if you use cachix!

  # Q: How to use my machine as a Nix build server?
  #
  # nix.settings.allowed-users = [ "@wheel" "@builders" ];
  # users.groups.builders = { };
  # users.users.nix = {
  #   isNormalUser = true;
  #   extraGroups = [ "builders" ];
  #   openssh.authorizedKeys.keys = [
  #     SSH_PUBLIC_KEY_OF_THE_CLIENT
  #   ];
  # };

  nix.distributedBuilds = true;

  # Q: How to customize your Nix settings? (e.g. to use flakes or cachix)
  nix.settings = {
    allow-import-from-derivation = true;
    bash-prompt-prefix = "(nix:$name)\040";
    build-users-group = "nixbld";
    # You want that if the builder has a faster internet connection than yours!
    builders-use-substitutes = true; # <-- my builder is in a datacenter :)
    experimental-features = [ "nix-command" "flakes" "repl-flake" ];
    extra-nix-path = "nixpkgs=flake:nixpkgs";
    keep-outputs = true;
    keep-derivations = true;
    max-jobs = "auto";
    substituters = [
      "https://cache.zw3rk.com"
      "https://cache.iog.io" "https://cache.ngi0.nixos.org"
      "https://cache.nixos.org" "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.ngi0.nixos.org-1:KqH5CBLNSyX184S9BKZJo1LxrxJ9ltnY2uAs5c/f1MA="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      # Q: How to take advantage of IOHK binary cache? (this is my workplace)
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
      "loony-tools:pr9m4BkM/5/eSTZlkQyRt57Jz7OMBxNSUiMC4FkcNfk="
    ];
  };

  # Q: How to set up daily backups of my home directory using Borg Backup?
  # https://nixos.org/manual/nixos/stable/index.html#module-borgbase
  # services.borgbackup.jobs.home-yvan = {
  #   paths = "/home/yvan";
  #   exclude = [ ".cache" ];
  #   doInit = true;
  #   encryption.mode = "none"; # I don't care, I own this machine
  #   environment.BORG_RSH = "ssh -i /home/yvan/.ssh/id_ed25519";
  #   repo = "ssh://nix@100.102.160.118:/backups/X230";
  #   compression = "auto,zstd";
  #   startAt = "daily";
  # };

  # List services that you want to enable:

  # How to enable SSH agent support in GnuPG agent?
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  # n.b. this will sets `SSH_AUTH_SOCK` environment variable correctly and
  # disable socket-activation and thus always start a GnuPG agent per user
  # session.

}

# Thanks' for reading! /yvan
