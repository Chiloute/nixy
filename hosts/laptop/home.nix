{
  config,
  inputs,
  lib,
  ...
}: {
  imports = [
    # Programs

    ## GUI
    ../../home/programs/gui/proton
    ../../home/programs/gui/helium
    ../../home/programs/gui/pkgs.nix
    ../../home/programs/gui/zen
    ../../home/programs/gui/spicetify

    ## TUI
    inputs.nvf-config.homeManagerModules.default
    ../../home/programs/tui/ghostty
    ../../home/programs/tui/ilovetui
    ../../home/programs/tui/shell
    ../../home/programs/tui/git
    ../../home/programs/tui/git/lazygit.nix
    ../../home/programs/tui/git/signing.nix # CHANGEME: Change the key or remove this file
    ../../home/programs/tui/nixy
    ../../home/programs/tui/nix-utils
    ../../home/programs/tui/elio
    ../../home/programs/tui/wikiman
    ../../home/programs/tui/pkgs.nix

    ## GROUPS
    ../../home/programs/group/cybersecurity.nix
    ../../home/programs/group/dev.nix

    # System (Desktop environment like stuff)
    ../../home/system/hyprlock
    ../../home/system/hyprland
    ../../home/system/waybar
    ../../home/system/swaync
    ../../home/system/tofi
    ../../home/system/mime
    ../../home/system/udiskie
    ../../home/system/termfilechooser
    ../../home/system/clipboard
    ../../home/system/hypridle

    ./variables.nix # Mostly user-specific configuration

    ./secrets # Home-manager module: sops-managed secrets (ssh keys, etc.)
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;

    sessionVariables = {
      AQ_DRM_DEVICES = "/dev/dri/card1";
    };

    # Don't touch this
    stateVersion = "26.05";
  };

  # Layout:
  #   +----------------------+----------+
  #   |      LG 27GL850      |  Iiyama  |
  #   |      2560x1440       | 1920x1080|
  #   +---+--------------+---+----------+
  #       |    eDP-1     |
  #       |  1920x1200   |
  #       +--------------+
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "desc:LG Electronics 27GL850 010NTQD1D164,2560x1440@60,0x0,1" # Top center, above the laptop
      "eDP-1,1920x1200@60,320x1440,1" # Internal screen, centered under the LG
      "desc:Iiyama North America PL2788H 1149464400239,1920x1080@60,2560x0,1" # Right of the LG
    ];

    workspace = [
      "1, monitor:eDP-1, default:true"
      "2, monitor:desc:LG Electronics 27GL850 010NTQD1D164, default:true"
      "3, monitor:desc:Iiyama North America PL2788H 1149464400239, default:true"
    ];
  };

  programs = {
    home-manager.enable = true;
    nixy = {
      enable = true;
      configDirectory = config.var.configDirectory;
    };
  };
}
