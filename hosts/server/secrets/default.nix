{pkgs, ...}: {
  sops = {
    age.keyFile = "/home/chiloute/.config/sops/age/keysrv.txt";
    defaultSopsFile = ./secrets.yaml;
    secrets = {
    };
  };

  environment.systemPackages = with pkgs; [
    sops
    age
  ];
}
