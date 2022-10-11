# Hello everyone,
#
# Most of my graphical environment is declared into my home-manager config ;)

{ pkgs, ... }: {

  # Q: How to use the Ozone Wayland support in Chrome and Electron apps?
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Q: How to automatically start Sway on tty1 without display manager?
  # environment.loginShellInit = ''
  #   if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
  #     export XDG_CURRENT_DESKTOP=sway
  #     export XDG_SESSION_TYPE=wayland
  #     exec sway
  #   fi
  # '';
  # n.b NixOS’s default display manager (the program that provides a graphical
  # login prompt and manages the X server) is LightDM.

  # Q: How to make Qt apps look like Gtk ones? (to get some look consistency)
  # https://nixos.org/manual/nixos/stable/index.html#sec-x11-gtk-and-qt-themes
  qt = { enable = true; platformTheme = "gtk2"; style = "gtk2"; };

  # TODO Q: How to make "Keyboard Layout Customization"? (e.g. Dvorak)
  # https://nixos.wiki/wiki/Keyboard_Layout_Customization
  # https://nixos.org/manual/nixos/stable/index.html#custom-xkb-layouts

  # Q: How to enable wlroots XDG portal support?
  # https://nixos.org/manual/nixos/stable/index.html#sec-wayland
  xdg.portal = {
    wlr.enable = true;
    configPackages = [ pkgs.gnome.gnome-session ];
  };

  # environment.variables = {
  #   # Q: How to tell GTK apps that there is no XDG portal?
  #   GTK_USE_PORTAL = "0";
  #   # Q: How to set up keymap of my X server?
  #   XKB_DEFAULT_LAYOUT = "dvorak";
  # };

  # Q: How to configure default fonts?
  fonts = {
    packages = with pkgs; [ twitter-color-emoji ];
    fontconfig = {
      enable = true;
      defaultFonts.emoji = [ "Twitter Color Emoji" ];
    };
  };

  # Q. How to set up your console (used in TTY, not in X) key map?
  console = {
    enable = true;
    useXkbConfig = true;
    earlySetup = true;
    colors = [
      "000000" # color0: black
      "cc0403" # color1: red
      "19cb00" # color2: green
      "cecb00" # color3: yellow
      "0d73cc" # color4: blue
      "cb1ed1" # color5: magenta
      "0dcdcd" # color6: cyan
      "dddddd" # color7: white (dull)
      "767676" # color8: black (bright)
      "f2201f" # color9: red (bright)
      "23fd00" # color10: green (bright)
      "fffd00" # color11: yellow (bright)
      "1a8fff" # color12: blue (bright)
      "fd28ff" # color13: magenta (bright)
      "14ffff" # color14: cyan (bright)
      "ffffff" # color15: white (bright)
    ];
  };

  # Q: How to fix error "GLW not found" (e.g. throw by Kitty)
  # n.b. also fix a weird issue where there is no cursor render in wlroots
  # (without WLR_NO_HARDWARE_CURSORS=1 enabled) ...
  # ... so, you have to enable OpenGL:
  hardware.opengl.enable = true;
  # ... you may also want "Accelerated Video Playback":
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver # LIBVA_DRIVER_NAME=iHD
    vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
    vaapiVdpau
    libvdpau-va-gl
  ];
  # n.b. on 64-bit systems, if you want OpenGL for 32-bit programs (such as in
  # Wine), you should also set the following:
  hardware.opengl.driSupport32Bit = true;
  # c.f. https://nixos.wiki/wiki/Accelerated_Video_Playback
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ vaapiIntel ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # Q: How to run Gnome programs outside of GNOME? (and set GNOME themes)
  programs.dconf.enable = true;

  # Q: How to run ancient (Gnome 2) applications?
  services.dbus = {
    enable = true;
    packages = with pkgs; [ gnome2.GConf ];
  };

  # Q: How to enable PC/SC Smart Card Daemon?
  services.pcscd.enable = true;

  # Q: How to allow installation of non-FOSS Nix packages? :')
  # nixpkgs.config.allowUnfree = true;
  # n.b. this could also be defined user-wide
  # echo "{ allowUnfree = true; }" > $XDG_CONFIG_PATH/.nixpkgs/config.nix

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "dvorak";
  };

  # Q: How to fix the VSCode error "Writing login information to the keychain
  # failed with error 'The name org.freedesktop.secret was not provided by any
  # .service files'."?
  services.gnome.gnome-keyring.enable = true;

  services.flatpak.enable = true;
  services.udisks2.enable = true;
  services.power-profiles-daemon.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Q: How to control LCD screen backlight?
  programs.light.enable = true;
}

# Thanks' for reading! /yvan
