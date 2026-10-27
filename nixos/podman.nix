{
  pkgs,
  ...
}: {
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  # Rootless only: the rootful socket (podman group / dockerSocket) is root-equivalent.
  systemd.user.sockets.podman.wantedBy = ["sockets.target"];
  environment.variables.DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
  environment.systemPackages = [pkgs.lazydocker pkgs.podman-compose];
}
