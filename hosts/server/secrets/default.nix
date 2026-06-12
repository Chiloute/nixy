{pkgs, ...}: {
  sops = {
    age.keyFile = "/home/chiloute/.config/sops/age/keyssrv.txt";
    defaultSopsFile = ./secrets.yaml;
    secrets = {
    };
  };

  environment.systemPackages = with pkgs; [
    sops
    age
  ];
}
