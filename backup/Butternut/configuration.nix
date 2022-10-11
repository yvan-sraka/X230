{ home-manager ? null, ... }:

# n.b. on a fresh macOS Sonoma install, to bootstrap this config you should:
#
# xcode-select --install
# curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
# nix-channel --add https://github.com/LnL7/nix-darwin/archive/master.tar.gz darwin
# nix-channel --add http://nixos.org/channels/nixpkgs-unstable nixpkgs
# nix-channel --update
# nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
# ./result/bin/darwin-installer
# rm -r .nixpkgs result
# git clone https://github.com/yvan-sraka/X230 .nixpkgs
# cd .nixpkgs
# nix flake update
# nix build ".#darwinConfigurations.Butternut.system"
# ./result/sw/bin/darwin-rebuild switch --flake .
{
  imports = [
    ../common/configuration.nix
    home-manager.darwinModules.home-manager or <home-manager/nix-darwin>
  ];

  users.users.yvan = {
    name = "yvan";
    home = "/Users/yvan";
  };

  # Q: How to manage your dot files with @rycee home-manager?
  home-manager = {
    # You could find mine here: https://github.com/yvan-sraka/.config
    # n.b. I define in home-manager numerous stuffs (like my graphical session)
    users.yvan = import ./home.nix;
    # https://nix-community.github.io/home-manager/#sec-install-nixos-module
    useUserPackages = true;
    useGlobalPkgs = true;
  };

  # Q: How to use a custom configuration.nix location?
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/config.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/config.nix";

  # Q: How to upgrade nix package and the daemon service?
  services.nix-daemon.enable = true;

  # Q: How to install custom fonts?
  # fonts.fontDir.enable = true;
  # fonts.fonts = with pkgs; [ firacode twemoji-color-font ];

  # Q: How to define your hostname (and macOS computer name)?
  networking.hostName = "Butternut";
  networking.computerName = "Butternut";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
