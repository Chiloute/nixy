{ config, ... }: {
  networking.hostName              = config.var.hostname;
  networking.networkmanager.enable = true;

  services.avahi = {
    enable   = true;
    nssmdns4 = true;
    publish  = {
      enable      = true;
      addresses   = true;
      domain      = true;
      workstation = true;
    };
  };
}
