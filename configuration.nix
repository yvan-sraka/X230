{ ... }@all:
  (import
    ./${
      builtins.head (builtins.split "\n" (builtins.readFile "/etc/hostname"))
    }/configuration.nix) all
