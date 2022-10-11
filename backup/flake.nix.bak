{
  inputs = {
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";
    };
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { darwin, flake-utils, home-manager, nixpkgs, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [ "imagemagick-6.9.12-68" ];
          };
        });
        cfg = x: machines:
          builtins.listToAttrs (builtins.map (hostname: {
            name = hostname;
            value = x (machine hostname);
          }) machines);
        machine = hostname: {
          inherit system;
          specialArgs = inputs // { inherit pkgs; };
          modules = [ ./${hostname}/configuration.nix ];
        };
      in {
        devShell = import ./shell.nix { inherit pkgs; };
        packages = {
          # Linux machines ...
          nixosConfigurations =
            cfg nixpkgs.lib.nixosSystem [ "X230" "P3440" ];
          # macOS machines ...
          darwinConfigurations = cfg darwin.lib.darwinSystem [ "Butternut" ];
        };
      });
}
