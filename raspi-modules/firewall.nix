{ ... }: {
  networking.firewall = {
    enable          = true;  # ANSSI R30
    allowPing       = false;
    allowedTCPPorts = [ 22 ];
  };
}
