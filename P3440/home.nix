{ pkgs, ... }:

{
  imports = [
    ../common/home.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "yvan";
  home.homeDirectory = "/home/yvan";

  # Q: How to install a user package (add it to my home-manager profile)?
  # To search a new package, run: % nix search wget
  #
  # n.b. Most of my tooling is project-specific, which mean I rather define my
  # developer environment dependencies in a shell.nix than here, what's left is
  # daily routine utilities and GUI software.
  home.packages = with pkgs; [
    # A pretty good TUI-based mail client, with git-email support:
    aerc
    # A simple password manager using gpg and ordinary unix directories:
    pass # thanks @zx2c4 https://www.passwordstore.org/
    # I (still) <3 Mozilla softwares
    (firefox.override { pkcs11Modules = [ eid-mw ]; })
    thunderbird
    # Allows user authentication and digital signatures with Belgian ID cards.
    # Also requires a running pcscd service and compatible card reader.
    # eid-viewer is also installed.
    # This package only installs the libraries. To use eIDs in Firefox or
    # Chromium, the eID Belgium add-on must be installed.
    # This package only installs the libraries. To use eIDs in NSS-compatible
    # browsers like Chrom{e,ium} or Firefox, each user must first execute:
    #   ~$ eid-nssdb add
    # (Running the script once as root with the --system option enables eID
    # support for all users, but will *not* work when using Chrom{e,ium}!)
    # Before uninstalling this package, it is a very good idea to run
    #   ~$ eid-nssdb [--system] remove
    # and remove all ~/.pki and/or /etc/pki directories no longer needed.
    # The above procedure doesn't seem to work in Firefox. You can override the
    # firefox wrapper to add this derivation to the PKCS#11 modules, like so:
    eid-mw
    # Communication
    signal-desktop discord
    # Media (e.g. to record/stream my screen)
    asciinema obs-studio pavucontrol
    # Developer tools (e.g. to target GTK & to hack small games in jams)
    blender glade gnome-builder gnome3.adwaita-icon-theme godot3 meld sysprof
    # Writing LaTeX and reading CS papers ^^'
    evince pandoc pdftk setzer # texlive.combined.scheme-full zotero
    # Learning DVORAK take times ...
    klavaro uhk-agent
    # Since I use a flake-based config, that do not rely on channels, the
    # `--upgrade` flag of `nixos-rebuild switch` command does not upgrade my
    # system! Instead, I use this script:
    (let root = "/etc/nixos"; in (writeShellScriptBin "upgrade-system" ''
      # nix flake update ${root}
      sudo nixos-rebuild switch --upgrade
    ''))
  ];

  # Q: How to have a fully working VSCode on NixOS?
  # programs.vscode = {
  #   enable = true;
  #   # package = pkgs.vscode.fhsWithPackages (ps: with ps;
  #   #   # n.b. needed for rust-analyzer extension:
  #   #   [ rustup zlib openssl.dev pkg-config ] ++
  #   #   # n.b. needed for haskell language server extension:
  #   #   (with haskellPackages; [ ghcup ])
  #   # );
  # };

  # Q: How to define (cross-shell) command aliases?
  home.shellAliases = rec {
    ls = "ls --color=auto --hyperlink=auto -v";
    # Looks how fun it is to self reference with `rec` fix point computation :D
    ll = "${ls} -l";
  };
  # n.b. here, I want `ls` to output terminal hyperlinks by default!

  # Q: How to tweak environment to set GTK theme, icon theme and cursor theme?
  # n.b. It appears that's this wasn't required for me...
  #
  # home.sessionVariables = {
  #   # Q: How to set up GTK theme?
  #   GTK_THEME = "Adwaita-dark";
  #   # Q: How to set up GTK icon theme?
  #   GTK2_RC_FILES = "${pkgs.gtk2}/share/themes/Adwaita/gtk-2.0/gtkrc";
  #   # Q: How to set up GTK cursor theme?
  # };

  # Q: How to set up pointer cursor theme and size?
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.hackneyed;
    name = "Hackneyed";
    size = 64;
  };

  # Q: How to set the default browser in NixOS?
  # https://unix.stackexchange.com/questions/379632
  xdg.mimeApps.defaultApplications =
    let defaultBrowser = "firefox-browser.desktop"; in {
      "x-scheme-handler/file"  = defaultBrowser;
      "x-scheme-handler/http"  = defaultBrowser;
      "x-scheme-handler/https" = defaultBrowser;
    };

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
      action launch --type=overlay    $EDITOR          $FILE_PATH

      # Open in Firefox URLs highlighted it NeoVim comments:
      protocol https
      action launch --type=background $DEFAULT_BROWSER $URL
    '';
    # n.b. more info on kitty `launch` capabilities here:
    # https://sw.kovidgoyal.net/kitty/launch/
  };

}
