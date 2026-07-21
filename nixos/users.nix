# Users configuration for NixOS
{
  config,
  pkgs-stable,
  ...
}: let
  username = config.var.username;
in {
  programs.zsh.enable = true;
  users = {
    defaultUserShell = pkgs-stable.zsh;

    users.${username} = {
      isNormalUser = true;
      description = "${username} account";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };
  };
}
