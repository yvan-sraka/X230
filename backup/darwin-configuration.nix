# /etc/hostname file does not exist on macOS, but conveniently darwin-nix looks
# for a darwin-configuration.nix file rather than a configuration.nix one and I
# have only one macOS machine ...
{ ... }: import ./Butternut/configuration.nix { }
