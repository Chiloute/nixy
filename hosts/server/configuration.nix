{
  config,
  lib,
  ...
}: {
  imports = [
    # NixOS module
    ../../nixos/home-manager.nix
    ../../nixos/nix.nix
    ../../nixos/systemd-boot.nix
    ../../nixos/users.nix
    ../../server-modules/utils.nix
    ../../nixos/amd-graphics.nix

    # NixOS server modules
    ../../server-modules/ssh.nix
    ../../server-modules/firewall.nix
    ../../server-modules/cloudflared.nix
    #../../server-modules/glance
    #../../server-modules/adguardhome.nix
    ../../server-modules/stirling-pdf.nix
    ../../server-modules/mazanoke.nix
    ../../server-modules/kernel-hardening.nix
    ../../server-modules/fail2ban.nix
    ../../server-modules/clamav.nix
    ../../server-modules/performance.nix
    #../../server-modules/umami.nix
    #../../server-modules/gitea.nix
    #../../server-modules/flowsint.nix
    ../../server-modules/cyberchef.nix
    # You should let those lines as is
    ./hardware-configuration.nix
    ./variables.nix

    ./secrets
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  # Don't touch this
  system.stateVersion = "24.05";
}
