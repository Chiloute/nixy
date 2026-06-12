# Those are my secrets, encrypted with sops
# You shouldn't import this file, unless you edit it
{
  inputs,
  pkgs,
  config,
  ...
}: let
  home = config.home.homeDirectory;
in {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  sops = {
    age.keyFile = "/home/chiloute/.config/sops/age/keyssrv.txt";
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      sshconfig = {path = "/home/chiloute/.ssh/config";};
      key = {path = "/home/chiloute/.ssh/key";};
      keypub = {path = "/home/chiloute/.ssh/key.pub";};
    };
  };

  home.file.".config/nixos/.sops.yaml".text = ''
    keys:
      - &primary age1l3a3pht8g9vjh3whduwjzxt58e4m83w4aswdppwmjuf8rpw2xgfsffttk3
    creation_rules:
      - path_regex: hosts/server/secrets/secrets.yaml$
        key_groups:
          - age:
            - *primary
  '';

  systemd.user.services.mbsync.Unit.After = ["sops-nix.service"];
  home.packages = with pkgs; [
    sops
    age
  ];

  wayland.windowManager.hyprland.settings.exec-once = ["systemctl --user start sops-nix"];
}
