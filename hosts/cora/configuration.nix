{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../nixos/nix.nix
    ../../raspi-modules/ssh.nix
    ../../raspi-modules/users.nix
    ../../raspi-modules/network.nix
    ./hardware-configuration.nix
    ./variables.nix
  ];

  time.timeZone = config.var.timeZone;
  i18n.defaultLocale = config.var.defaultLocale;

  environment.systemPackages = with pkgs; [git vim neovim curl wget];

  system.stateVersion = "25.05";
}
