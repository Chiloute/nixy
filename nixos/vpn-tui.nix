{ config, ... }:
{
  # Package and module come from NUR (repos.Chiloute); the module defaults `package` itself.
  services.vpn-tui.enable = true;
  # The module creates the vpn-tui group; membership grants access to the daemon socket.
  users.users."${config.var.username}".extraGroups = [ "vpn-tui" ];
}
