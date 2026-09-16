{
  config,
  pkgs,
  ...
}: {
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  users.users."${config.var.username}".extraGroups = ["podman"];
  environment.systemPackages = [pkgs.lazydocker pkgs.podman-compose];
}
