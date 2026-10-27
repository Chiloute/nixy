{
  config,
  inputs,
  lib,
  ...
}: let
  lg = "desc:LG Electronics 27GL850 010NTQD1D164";
  iiyama = "desc:Iiyama North America PL2788H 1149464400239";
in {
  imports = [
    # Programs

    ## GUI
    ../../home/programs/gui/proton
    ../../home/programs/gui/helium
    ../../home/programs/gui/pkgs.nix
    ../../home/programs/gui/sandboxed.nix
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
      # Top center, above the laptop
      {
        output = lg;
        mode = "2560x1440@60";
        position = "0x0";
        scale = 1;
      }
      # Internal screen, centered under the LG
      {
        output = "eDP-1";
        mode = "1920x1200@60";
        position = "320x1440";
        scale = 1;
      }
      # Right of the LG
      {
        output = iiyama;
        mode = "1920x1080@60";
        position = "2560x0";
        scale = 1;
      }
    ];

    workspace_rule = [
      {
        workspace = "1";
        monitor = "eDP-1";
        default = true;
      }
      {
        workspace = "2";
        monitor = lg;
        default = true;
      }
      {
        workspace = "3";
        monitor = iiyama;
        default = true;
      }
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
