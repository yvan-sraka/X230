# Hello everyone,
#
# Here belong the configuration of my beloved **Dell P3440**!

{ home-manager ? null, pkgs ? import <nixpkgs> { }, ... }: {

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
    # nixos-hardware.nixosModules.lenovo-thinkpad-x230

    # Q: Where is included the results of the NixOS hardware scan?
    ./hardware-configuration.nix

    # Q: How to get the connect easily to all free hotspots available around?
    # When I'm outside I eventually want connect to public WiFi networks ^^'
    # through WireGuard, indeed I don't trust public networks and you shouldn't
    #
    # ./wifipsk_pub.nix

    ../nixos/devtools.nix
    ../nixos/network.nix
    ../nixos/wayland.nix
  ];

  # Q: How to use the systemd-boot UEFI, rather than legacy bootloader?
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "P3440"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Q: How to clean up /tmp folder during boot?
  boot.tmp.cleanOnBoot = true;

  # Q: How to show other OSes installed (e.g. Windows) in my GRUB menu?
  boot.loader.grub.useOSProber = true;

  # Q: How to fix Visual Studio Code error ENOSPC?
  # "VSCode is unable to watch for file changes in this large workspace"
  # https://code.visualstudio.com/docs/setup/linux
  boot.kernel.sysctl = { "fs.inotify.max_user_watches" = "524288"; };

  # Q: How to set your time zone?
  time.timeZone = "Europe/Brussels";

  # Q: How to set up internationalization properties, e.g. your default locale?
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the GNOME Desktop Environment.
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;

  # You may need to comment out "services.displayManager.gdm.enable = true;"
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma6.enable = true;

  # Q: How to define a user account?
  # n.b. don't forget to set a password with ‘passwd’.
  users.users.yvan = {
    isNormalUser = true;
    description = "Yvan Sraka";
    # Q. How to enable ‘sudo’ for the user?
    extraGroups = [ "networkmanager" "wheel" ];
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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  # #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  # #  wget
  # ];

  services.guix.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

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

  # Q: How to pair an iPhone? e.g. to set up a Personal Hotspot
  # https://support.apple.com/en-us/HT204023
  # % idevicepair pair
  environment.systemPackages = with pkgs; [ libimobiledevice ];
  services.usbmuxd.enable = true;
  services.usbmuxd.user = "yvan";

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

  hardware.keyboard.uhk.enable = true;

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
  system.stateVersion = "23.11";
}

# Thanks' for reading! /yvan
