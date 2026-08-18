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
    age.keyFile = "${home}/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      sshconfig = {
        mode = "0600";
        path = "${home}/.ssh/config";
      };
      key = {
        mode = "0600";
        path = "${home}/.ssh/key";
      };
      srv_key = {
        mode = "0600";
        path = "${home}/.ssh/srv_key";
      };
      ec_key = {
        mode = "0600";
        path = "${home}/.ssh/ec_key";
      };
      ec_key_pub = {
        mode = "0600";
        path = "${home}/.ssh/ec_key.pub";
      };
      signing_key_pub = {
        mode = "0600";
        path = "${home}/.ssh/sign_key.pub";
      };
      signing_key_prv = {
        mode = "0600";
        path = "${home}/.ssh/sign_key";
      };
    };
  };

  home.file.".config/nixos/.sops.yaml".text = ''
    keys:
      - &primary age1n467vk6xtjl0rthlua4y5e2fwhcmnnj7sw7p8fw3sxsxsz3y4uhq0z8qcg
      - &server age1l3a3pht8g9vjh3whduwjzxt58e4m83w4aswdppwmjuf8rpw2xgfsffttk3
    creation_rules:
      - path_regex: hosts/laptop/secrets/secrets.yaml$
        key_groups:
          - age:
            - *primary
      - path_regex: hosts/server/secrets/secrets.yaml$
        key_groups:
          - age:
            - *server
  '';

  systemd.user.services.mbsync.Unit.After = ["sops-nix.service"];
  home.packages = with pkgs; [
    sops
    age
  ];

  wayland.windowManager.hyprland.settings.exec-once = ["systemctl --user start sops-nix"];
}
