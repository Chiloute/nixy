{
  config,
  pkgs-stable,
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

  nix.settings = {
    extra-substituters = ["https://nixos-raspberrypi.cachix.org"];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  environment.systemPackages = with pkgs-stable; [git vim neovim curl wget];

  system.stateVersion = "25.05";
}
