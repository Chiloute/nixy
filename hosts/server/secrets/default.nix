{pkgs,config, ...}: let
  home = "/home/" + config.var.username;
in {
  sops = {
    age.keyFile = "/home/chiloute/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      srv_key = {
        mode = "0600";
        path = "${home}/.ssh/srv_key";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    sops
    age
  ];
}
