{ config, pkgs, ... }: let
  username = config.var.username;
in {
  programs.zsh.enable    = true;
  users.defaultUserShell = pkgs.zsh;

  users.users."${username}" = {
    isNormalUser    = true;
    description     = "${username} account";
    extraGroups     = [ "networkmanager" "wheel" ];
    initialPassword = "nixos"; # changer apres le premier login : passwd
  };
}
