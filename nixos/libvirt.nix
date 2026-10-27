{config, ...}: {
  programs.virt-manager.enable = true;
  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };
  users.users."${config.var.username}".extraGroups = ["libvirtd"];
}
