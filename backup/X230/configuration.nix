# Hello everyone,
#
# Here belong the configuration of my beloved **Thinkpad X230**!

{ home-manager ? null, nixos-hardware ? null, pkgs ? import <nixpkgs> { }, ... }: {

  imports = [
    ../common/configuration.nix

    # Q: How to use Home Manager (check out below) as a NixOS module?
    home-manager.nixosModule or <home-manager/nixos>
    # n.b. <brackets> reference a Nix channel, so you have to:
    # % sudo nix-channel --add \
    #   https://github.com/nix-community/home-manager/archive/master.tar.gz \
    #   home-manager
    # % sudo nix-channel --update

    # Q: How to get custom profiles to optimize settings for my hardware?
    # https://github.com/NixOS/nixos-hardware
    nixos-hardware.nixosModules.lenovo-thinkpad-x230 or <nixos-hardware/lenovo/thinkpad/x230>

    # Q: Where is included the results of the NixOS hardware scan?
    ./hardware-configuration.nix

    # Q: How to get the connect easily to all free hotspots available around?
    # When I'm outside I eventually want connect to public WiFi networks ^^'
    # through WireGuard, indeed I don't trust public networks and you shouldn't
    #
    # ./nixos/wifipsk_pub.nix

    ../nixos/devtools.nix
    ../nixos/network.nix
    ../nixos/wayland.nix
  ];

  # Q: How to use the systemd-boot UEFI, rather than legacy bootloader?
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # n.b. I give my install commands in ./hardware-configuration.nix

  # Q: How to show other OSes installed (e.g. Windows) in my GRUB menu?
  boot.loader.grub.useOSProber = true;

  # Q: How to clean up /tmp folder during boot?
  boot.tmp.cleanOnBoot = true;

  # Q: How to fix Visual Studio Code error ENOSPC?
  # "VSCode is unable to watch for file changes in this large workspace"
  # https://code.visualstudio.com/docs/setup/linux
  boot.kernel.sysctl = { "fs.inotify.max_user_watches" = "524288"; };

  # Q: How to set your time zone?
  time.timeZone = "Europe/Brussels";

  # Q: How to set up internationalization properties, e.g. your default locale?
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # services.xserver = {
  #   windowManager.windowmaker.enable = true;
  #   windowManager.ratpoison.enable = true;
  #   displayManager.startx.enable = true;
  # };

  # Q: How to define a user account?
  # n.b. don't forget to set a password with ‘passwd’.
  users.users.yvan = {
    isNormalUser = true;
    # Q. How to enable ‘sudo’ for the user?
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # Q: How to manage your dot files with @rycee home-manager?
  home-manager = {
    # You could find mine here: https://github.com/yvan-sraka/.config
    # n.b. I define in home-manager numerous stuffs (like my graphical session)
    users.yvan = import ../nixos/home.nix;
    # https://nix-community.github.io/home-manager/#sec-install-nixos-module
    useUserPackages = true;
    useGlobalPkgs = true;
  };

  # Q: How to enable network interfaces?
  # Interfaces name may change depending on your hardware.
  # DHCP is used to assign a local IP address to each interface.
  # You can inspect your interface status with `ip a` command.
  #
  # networking.interfaces.enp0s25.useDHCP = true; # Ethernet
  # networking.interfaces.wlp3s0.useDHCP = true; # WiFi
  #
  # n.b. `nixos-generate-config` now puts the dhcp configuration in
  # `hardware-configuration.nix` instead of `configuration.nix`

  # Q: How to enable NetworkManager?
  # (I do not want to deal with `wpa_supplicant`)
  networking.networkmanager.enable = true;
  # n.b. I prefer to manage my WiFi PSK directly into my NixOS configuration!
  # https://nixos.org/manual/nixos/stable/index.html#sec-wireless
  #
  # networking.wireless = {
  #   enable = true;
  #   networks = import ./wifipsk.nix;
  # };
  #
  # /!\ `import` and `imports` does not behave the same, look behind ;)

  # Q. What does looks like ./wifipsk.nix`?
  # {
  #   "WiFi name".pskRaw = "pskRaw generated";
  #   ...
  # }

  # Q. How to generate pskRaw knowing SSID and plain password of a WiFi?
  # % wpa_passphrase SSID plain_password
  # network={
  #   ssid="SSID"
  #   #psk="plain_password"
  #   psk=The value you want to copy past in your `./wifipsk.nix` :)
  # }

  networking.hostName = "X230"; # Define your hostname.

  # Q: How to pair an iPhone? e.g. to set up a Personal Hotspot
  # https://support.apple.com/en-us/HT204023
  # % idevicepair pair
  environment.systemPackages = with pkgs; [ libimobiledevice ];
  services.usbmuxd.enable = true;
  services.usbmuxd.user = "yvan";

  # Q: How to improve a lot of my laptop power consumption?
  powerManagement.enable = true;
  services.upower.enable = true;
  services.thermald.enable = true;
  services.tlp.enable = true;
  # e.g. on my 2012's Thinkpad, I achieve more than 10-hours battery life!
  # n.b. I cheated a bit using https://github.com/hamishcoleman/thinkpad-ec and
  # a 11.1 V, 5000 mAh, 6 cell battery (easy to find on the internet for ~$50).

  # Q: How to upgrade my ThinkPad X230 hardware?
  #
  # If you already buy more DDR3L-1600 SODIMM RAM, a good 2.5" SATA 3D NAND SSD
  # and a brand-new battery (see previous), I could advise you to check out:
  # * USB Type C to ThinkPad charging cable adapter (really handy and only ~$4)
  # * Express Card expansions (I choose to add 3x USB3.0 ports for ~$15)
  # * 12.5" IPS screen (simple to replace and the ~$30 clearly worth it)
  #
  # n.b. I also needed to change the CMOS battery (~$5), that prevent BIOS
  # settings reset at each reboot ... And some broken parts like rubber feet
  # (4x for ~$1) and palmrest (~$10 without fingerprint reader), and maybe soon
  # the charging cable connector (~$2) ...
  #
  # For more advanced needs, check out the cool mods of https://www.xyte.ch/ :)

  # Q: How to login (using PAM) with an YubiKey?
  # n.b. that the method which works with my "Security Key" cheapest model!
  security.pam.u2f.enable = true;
  security.pam.services.login.u2fAuth = true;
  # You have to save your FIDO U2F hardware public key with:
  # % nix-shell -p yubico-pam
  # $ pamu2fcfg >> ~/.config/Yubico/u2f_keys

  # Q: How to install NixOS upgrades automatically?
  # https://nixos.org/manual/nixos/stable/#sec-upgrading-automatic
  system.autoUpgrade = { enable = true; allowReboot = false; };

  # Q: How to set up bluetooth?
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  #
  # system.copySystemConfiguration = true;
  #
  # n.b. this option appear to be not out-of-the-bok compatible with flake-based
  # NixOS configurations because it rely on $NIX_PATH value <nixos-config> that
  # should be manually tweaked ...

  # Q: Should I edit this line? No. Never ever.
  system.stateVersion = "22.11";
}

# Thanks' for reading! /yvan
