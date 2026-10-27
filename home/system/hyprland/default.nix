# Hyprland is a dynamic tiling Wayland compositor that is highly customizable and performant.
{
  pkgs-unstable,
  pkgs,
  config,
  lib,
  ...
}: let
  border-size = config.theme.border-size;
  gaps-in = config.theme.gaps-in;
  gaps-out = config.theme.gaps-out;
  active-opacity = config.theme.active-opacity;
  inactive-opacity = config.theme.inactive-opacity;
  rounding = config.theme.rounding;
  blur = config.theme.blur;
  keyboardLayout = config.var.keyboardLayout;
  background = "rgba(" + config.lib.stylix.colors.base00 + "EE)";
  hl = import ./lua.nix {inherit lib;};
in {
  imports = [
    ./animations.nix
    ./bindings.nix
    ./polkitagent.nix
    ./hyprpaper.nix
  ];

  home.packages =
    (with pkgs-unstable; [
      qt5.qtwayland
      qt6.qtwayland
      hyprland-qtutils
    ])
    ++ (with pkgs; [
      libsForQt5.qt5ct
      qt6Packages.qt6ct
      xcb-util-cursor
      papirus-icon-theme
      material-icons
      material-design-icons
      material-symbols
      libxcb
      adw-gtk3
      hyprshot
      hyprpicker
      satty
      imv
      wf-recorder
      brightnessctl
      gnome-themes-extra
      dconf
      wayland-utils
      wayland-protocols
    ]);

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = false;
    package = null;
    portalPackage = null;

    # Settings are emitted alphabetically: env must run first and curves must
    # exist before the animations that reference them.
    importantPrefixes = ["env" "curve"];

    settings = {
      env = map (e: {_args = e;}) [
        ["XDG_CURRENT_DESKTOP" "Hyprland"]
        ["XDG_SESSION_TYPE" "wayland"]
        ["XDG_SESSION_DESKTOP" "Hyprland"]
        ["ANKI_WAYLAND" "1"]
        ["DISABLE_QT5_COMPAT" "0"]
        ["QT_AUTO_SCREEN_SCALE_FACTOR" "1"]
        ["QT_QPA_PLATFORM" "wayland;xcb"]
        ["QT_QPA_PLATFORMTHEME" "gtk3"]
        ["QT_WAYLAND_DISABLE_WINDOWDECORATION" "1"]
        ["ELECTRON_OZONE_PLATFORM_HINT" "auto"]
        ["DIRENV_LOG_FORMAT" ""]
        ["SDL_VIDEODRIVER" "wayland"]
        ["CLUTTER_BACKEND" "wayland"]
      ];

      # Host-specific monitor / workspace layout lives in hosts/<host>/home.nix.
      # This catch-all is only used for monitors no named rule matches.
      monitor = [
        {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = 1;
        }
      ];

      on = [(hl.onStart "systemctl --user start app-com.mitchellh.ghostty.service")];

      config = {
        cursor.default_monitor = "eDP-1";

        general = {
          resize_on_border = true;
          gaps_in = gaps-in;
          gaps_out = gaps-out;
          border_size = border-size;
          layout = "master";
          # Same key as the stylix target, so the override applies.
          "col.inactive_border" = lib.mkForce background;
        };

        decoration = {
          active_opacity = active-opacity;
          inactive_opacity = inactive-opacity;
          rounding = rounding;
          shadow = {
            enabled = true;
            range = 8;
            render_power = 3;
          };
          blur = {
            enabled = blur;
            size = 6;
            passes = 2;
          };
        };

        master = {
          new_status = "slave";
          allow_small_split = true;
          mfact = 0.5;
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          disable_autoreload = true;
          focus_on_activate = true;
        };

        input = {
          kb_layout = keyboardLayout;
          kb_options = "caps:escape";
          follow_mouse = 1;
          sensitivity = 0.5;
          repeat_delay = 300;
          repeat_rate = 50;
          numlock_by_default = true;

          touchpad = {
            natural_scroll = true;
            clickfinger_behavior = true;
          };
        };

        ecosystem.no_update_news = true;
      };

      gesture = {
        fingers = 3;
        direction = "horizontal";
        action = "workspace";
      };

      layer_rule = [
        {
          match.namespace = "launcher";
          animation = "popin 70%";
        }
        {
          match.namespace = "swaync-control-center";
          animation = "slide right";
        }
      ];

      window_rule =
        [
          {
            match.class = ".*";
            suppress_event = "maximize";
          }
        ]
        ++ map (class: {
          match.class = class;
          suppress_event = "fullscreen";
          sync_fullscreen = false;
        }) ["helium" "^(steam_app_.*)$"]
        ++ map (class: {
          match.class = class;
          float = true;
          center = true;
          size = "500 400";
        }) ["proton-authenticator" "protonvpn-app"]
        ++ [
          {
            match.title = "run-bg";
            float = true;
            center = true;
            size = "700 80";
          }
        ];
    };
  };

  # Fail the build, not the session, when Hyprland rejects the generated Lua.
  xdg.configFile."hypr/hyprland.lua".source = lib.mkForce (pkgs.runCommand "hyprland.lua" {
      text = config.xdg.configFile."hypr/hyprland.lua".text;
      passAsFile = ["text"];
    } ''
      export XDG_RUNTIME_DIR=$TMPDIR HOME=$TMPDIR
      # Hyprland picks the Lua parser from the .lua extension.
      cp "$textPath" hyprland.lua
      ${pkgs.hyprland}/bin/Hyprland --verify-config -c hyprland.lua 2>&1 | tee log
      grep -qx "config ok" log
      cp hyprland.lua "$out"
    '');

  qt.enable = true;

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  home.sessionVariables = {
    XDG_ICON_DIR = "${pkgs.papirus-icon-theme}/share/icons/Papirus";
    QS_ICON_THEME = "Papirus";
    QT_STYLE_OVERRIDE = lib.mkForce "Fusion";
  };
}
