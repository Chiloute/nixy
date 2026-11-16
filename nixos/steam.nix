{ pkgs, ... }: {
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # requis par Steam / Proton
    extraPackages = with pkgs; [
      intel-media-driver # VA-API (iHD)
      vpl-gpu-rt # QSV pour Meteor Lake
    ];
  };

  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  programs.gamemode.enable = true;

  environment.systemPackages = [ pkgs.mangohud ];
}
