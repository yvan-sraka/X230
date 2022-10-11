{ lib, pkgs, ... }:

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
    uhk-agent
    # A pretty good TUI-based mail client, with git-email support:
    aerc
    # A simple password manager using gpg and ordinary unix directories:
    pass # thanks @zx2c4 https://www.passwordstore.org/
    # Wayland utils
    qt5.qtwayland wdisplays wl-clipboard xwayland # mako
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
    discord signal-desktop
    # Media (e.g. to record/stream my screen)
    asciinema obs-studio pavucontrol
    # Developer tools (e.g. to target GTK & to hack small games in jams)
    blender glade gnome-builder gnome3.adwaita-icon-theme godot3 meld sysprof
    # Writing LaTeX and reading CS papers ^^'
    evince pandoc pdftk setzer # texlive.combined.scheme-full zotero
    # Learning DVORAK take times ...
    klavaro
    # Since I use a flake-based config, that do not rely on channels, the
    # `--upgrade` flag of `nixos-rebuild switch` command does not upgrade my
    # system! Instead, I use this script:
    (let root = "/etc/nixos"; in (writeShellScriptBin "upgrade-system" ''
      # nix flake update ${root}
      sudo nixos-rebuild switch --upgrade
    '')) openmw-tes3mp
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
  # home.pointerCursor = {
  #   gtk.enable = true;
  #   x11.enable = true;
  #   package = pkgs.hackneyed;
  #   name = "Hackneyed";
  #   size = 64;
  # };

  # Q: How to auto-mount external drives?
  services.udiskie = { enable = true; tray = "never"; };

  # Q: How to set up Sway as WM in NixOS home-manager?
  # n.b. Sway relies on Wayland which is set up here /etc/nixos/wayland.nix
  # You may want to check out https://github.com/yvan-sraka/X230
  wayland.windowManager.sway = {
    enable = true;

    # Q: How to execute Sway with required environment variables for GTK apps?
    # https://nixos.org/manual/nixpkgs/stable/#ssec-gnome-hooks
    wrapperFeatures.gtk = true;

    # This will generate the sway config into ~/.config/sway/config
    config = rec {

      # Keyboard layout
      input = {
        "type:keyboard" = {
          xkb_layout = "us,be";
          xkb_variant = "dvorak,";
          # Alt+Space to switch layouts
          # xkb_options = "grp:alt_space_toggle";
        };
      };

      # Q: How to set i3/Sway modifier key?
      modifier = "Mod4"; # Logo (windows) key

      # Q: How to set i3/Sway preferred terminal emulator?
      terminal = "kitty"; # -1 -> only a single instance of kitty will run

      # Q: How to set i3/Sway preferred application launcher?
      # menu =
      #   let cmdArgs = ''-r 0 -f "Fira Code"''; # (see `man fuzzel`)
      #       appLauncher = "${pkgs.fuzzel}/bin/fuzzel ${cmdArgs}"; in
      #   # Note: it's recommended that you pass the final command to sway
      #   "${appLauncher} | xargs swaymsg exec --";

      # Q: How to set i3/Sway wallpaper?
      # output."*".bg = "~/wallpaper.png stretch";
      # ... or if (like me) you prefer solid colors:
      output."*".bg = "#ffffff solid_color";

      # Q: How to set i3/Sway screen resolution, position and/or orientation?
      # n.b. use `swaymsg -t get_outputs` to get available display options
      output."LVDS-1" =
        { mode = "1366x768" ; pos = "1440 2560"; };

      # Q. How to set an i3/Sway status bar? (n.b. you can have several)
      bars = [];
      # bars = [{
      #   position = "top";
      #   fonts = { names = [ "JetBrains Mono" ]; size = 10.0; };
      #   # When the statusCommand prints a new line to stdout, status bar
      #   # updates. The default just shows the current date and time:
      #   # statusCommand while date +'%Y-%m-%d %l:%M:%S %p'; do sleep 1; done
      #   #statusCommand = # It's a bit hacky ...
      #   #  let cfgPath = "~/.config/i3status-rust/config-default.toml"; in
      #   #  # ... but this is where home-manager generate the configuration.
      #   #  "${pkgs.i3status-rust}/bin/i3status-rs ${cfgPath}";
      #   colors =
      #     # I (again) like simple RGB theme:
      #     let m = "#ff0000"; c = "#0000ff"; w = "#ffffff"; b = "#000000"; in {
      #       statusline = b; # Text color of status bar
      #       background = w; # Background of status bar
      #       separator  = w; # ... I don't like the separator look
      #       focusedWorkspace  = { background = c; border = c; text = w; };
      #       urgentWorkspace   = { background = m; border = m; text = w; };
      #       activeWorkspace   = { background = b; border = b; text = w; };
      #       inactiveWorkspace = { background = w; border = w; text = b; };
      #     };
      # }];

      keybindings = let fn = "XF86WakeUp"; in lib.mkOptionDefault ({
        # Basic UHK-like layer for navigation (using Mod)
        "${modifier}+h" = ''exec swaymsg -- "key Left"'';
        "${modifier}+t" = ''exec swaymsg -- "key Down"'';
        "${modifier}+c" = ''exec swaymsg -- "key Up"'';
        "${modifier}+n" = ''exec swaymsg -- "key Right"'';

        # Mouse control (using Fn)
        "${fn}+h" = ''exec swaymsg -- "pointer move -10 0'';
        "${fn}+t" = ''exec swaymsg -- "pointer move 0 10'';
        "${fn}+c" = ''exec swaymsg -- "pointer move 0 -10'';
        "${fn}+n" = ''exec swaymsg -- "pointer move 10 0'';

        # Brightness
        # "XF86MonBrightnessDown" = "exec light -U 10";
        # "XF86MonBrightnessUp" = "exec light -A 10";
        "${fn}+F8" = "exec light -U 10";
        "${fn}+F9" = "exec light -A 10";

        # Volume
        "XF86AudioRaiseVolume exec" = "'pactl set-sink-volume @DEFAULT_SINK@ +1%'";
        "XF86AudioLowerVolume exec" = "'pactl set-sink-volume @DEFAULT_SINK@ -1%'";
        "XF86AudioMute exec" = "'pactl set-sink-mute @DEFAULT_SINK@ toggle'";
        # TODO: XF86AudioMicMute, XF86Launch1
      });
    };

    # Q: How to remove i3/Sway windows borders? (I don't like it ...)
    extraConfig = ''
      default_border none
      seat seat0 xcursor_theme Hackneyed 64

      # Define workspace names
      set $ws1 1: Terminal
      set $ws2 2: Web
      
      # Application assignments to workspaces
      assign [app_id="kitty"] $ws1
      assign [class="Firefox"] $ws2
      
      # Autostart applications
      exec --no-startup-id swaymsg 'workspace $ws1; exec kitty'
      exec --no-startup-id swaymsg 'workspace $ws2; exec firefox'
    '';

    # Q: How to run programs natively under wayland?
    extraSessionCommands = ''
      # Experimental Wayland support in Firefox:
      export MOZ_ENABLE_WAYLAND=1
      # Qt Apps needs qt5.qtwayland in systemPackages:
      export QT_QPA_PLATFORM=wayland-egl
      export QT_WAYLAND_FORCE_DPI=physical
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      # Fix for some Java AWT applications (e.g. Guidra):
      export _JAVA_AWT_WM_NONREPARENTING=1
      # I like to have a BIG cursor on my 4K screens:
      export XCURSOR_THEME="Hackneyed"
      export XCURSOR_SIZE=64
    '';
  };

  # Q: How to use set up kanshi (an autorandr-like for Wayland)?
  # services.kanshi = {
  #   enable = true;
  #   profiles = {
  #     undocked = {
  #       outputs = [
  #         { criteria = "LVDS-1"; }
  #       ];
  #     };
  #     docked = {
  #       outputs = [
  #         { criteria = "HDMI-A-1"; transform = "90"; mode = "2048x1152"; }
  #         { criteria = "DP-2"; transform = "270"; mode = "2048x1152"; }
  #       ];
  #     };
  #   };
  # };

  # Q: How to set up a software blue light filter (and protect your eyes)?
  services.gammastep = {
    enable = true;
    temperature = { day = 3000; night = 2000; }; # warmer than defaults
    settings.general.adjustment-method = "wayland";
    # I'm based in Brussels :)
    latitude = "50.83";
    longitude = "4.35";
  };

  # Q: How to customize i3status-rust?
  # I use it as status bar in Sway, rather than default waybar.
  # programs.i3status-rust = {
  #   enable = true;
  #   bars.default = {
  #     blocks = [
  #       { block = "disk_space"; interval = 1; }
  #       { block = "memory";     interval = 1; }
  #       { block = "cpu";        interval = 1; }
  #       { block = "battery";    interval = 1; }
  #       { block = "time";       interval = 1;
  #         format = {
  #           full = " $icon $timestamp.datetime(f:'%a %Y-%m-%d %r', l:fr_BE) ";
  #           short = " $icon $timestamp.datetime(f:%R) ";
  #         }; }
  #     ];
  #     settings.theme = {
  #       theme = "native";
  #       overrides.separator = "|";
  #     };
  #     # Q: How to disable i3status-rust colors?
  #     theme = "native";
  #     icons = "awesome6";
  #   };
  # };

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

  # xsession.enable = true;
}
