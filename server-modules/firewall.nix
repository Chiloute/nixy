# Firewall configuration for NixOS
{
  networking.firewall = {
    enable = true;
    allowPing = false;
    # Drop forwarding by default: containers only get what mk-container.nix allows
    # (NAT'd internet for `internet = true`), never each other or the LAN.
    extraCommands = "iptables -P FORWARD DROP";
    extraStopCommands = "iptables -P FORWARD ACCEPT";
  };
}
