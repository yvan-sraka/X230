# Hello everyone,
#
# Here, I choose to define everything that deals with my internet connectivity ;
# meaning, remote services like SSH, firewall, Wi-Fi passwords and Nix custom
# settings (build cache and machines) that help a lot my old and lazy CPU to
# not deal with complex builds itself!

{ ... }: {

  # Tailscale might need this?
  # networking.firewall.checkReversePath = "loose";

  # Q: How to enable the OpenSSH secure shell daemon?
  services.sshd.enable = true;
  # n.b this is an alias of `services.openssh.enable`

  # Q: How to use SSH on fuzzy internet connection (e.g working in a train)?
  # Try https://mosh.org/
  programs.mosh.enable = true;

  # List services that you want to enable:

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;

}

# Thanks' for reading! /yvan
