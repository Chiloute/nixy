{
  config,
  lib,
  pkgs-stable,
  ...
}: {
  imports = [
    ../../nixos/nix.nix
    ../../raspi-modules/ssh.nix
    ../../raspi-modules/users.nix
    ../../raspi-modules/network.nix
    ../../raspi-modules/fail2ban.nix
    ../../raspi-modules/kernel-hardening.nix
    ../../raspi-modules/firewall.nix
    ../../raspi-modules/os-hardening.nix
    ../../raspi-modules/performance.nix
    ./hardware-configuration.nix
    ./variables.nix
  ];

  time.timeZone = config.var.timeZone;
  i18n.defaultLocale = config.var.defaultLocale;

  # Cache Cachix nixos-raspberrypi (binaires kernel vendor)
  nix.settings = {
    extra-substituters = ["https://nixos-raspberrypi.cachix.org"];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
    substituters = lib.mkForce [
      "https://cache.nixos.org?priority=10"
    ];
    trusted-public-keys = lib.mkForce [];
  };

  environment.systemPackages = with pkgs-stable; [git vim neovim curl wget];

  system.stateVersion = "25.05";
}
