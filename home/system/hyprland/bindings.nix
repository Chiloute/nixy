{
  pkgs,
  lib,
  config,
  scripts,
  ...
}: let
  colors = config.lib.stylix.colors;
  border-size = config.theme.border-size;
  inherit (import ./lua.nix {inherit lib;}) exec;
  ipc = cmd: exec "noctalia msg ${cmd}";

  mkMenu = menu: let
    configFile = pkgs.writeText "config.yaml" (
      lib.generators.toYAML {} {
        anchor = "top";
        border = "#${colors.base0D}EE";
        border_width = border-size;
        background = "#${colors.base01}FF";
        color = "#${colors.base05}";
        margin_top = 0;
        rows_per_column = 5;

        inherit menu;
      }
    );
  in
    pkgs.writeShellScriptBin "menu" ''
      # Toggle: if wlr-which-key is already open, closing it is all this run should do.
      if ${pkgs.procps}/bin/pkill -x wlr-which-key; then
        exit 0
      fi
      exec ${lib.getExe pkgs.wlr-which-key} ${configFile}
    '';

  appsMenu = lib.getExe (mkMenu [
    {
      key = "p";
      desc = "Proton Pass";
      cmd = "${pkgs.proton-pass}/bin/proton-pass";
    }
    {
      key = "v";
      desc = "Proton VPN";
      cmd = "${pkgs.proton-vpn}/bin/protonvpn-app";
    }
    {
      key = "m";
      desc = "Proton Mail";
      cmd = "${config.programs.helium.package}/bin/helium 'https://mail.proton.me/'";
    }
    {
      key = "o";
      desc = "Obsidian";
      cmd = "obsidian"; # sandboxed wrapper from PATH (gui/sandboxed.nix)
    }
    {
      key = "s";
      desc = "Signal";
      cmd = "signal-desktop"; # sandboxed wrapper from PATH
    }

    {
      key = "b";
      desc = "Helium";
      cmd = "${config.programs.helium.package}/bin/helium";
    }
    {
      key = "d";
      desc = "Discord";
      cmd = "discord"; # sandboxed wrapper from PATH (gui/sandboxed.nix)
    }
  ]);

  powerMenu = lib.getExe (mkMenu [
    {
      key = "l";
      desc = "Lock";
      cmd = "noctalia msg session lock";
    }
    {
      key = "s";
      desc = "Suspend";
      cmd = "systemctl suspend";
    }
    {
      key = "r";
      desc = "Reboot";
      cmd = "systemctl reboot";
    }
    {
      key = "p";
      desc = "Power Off";
      cmd = "systemctl poweroff";
    }
  ]);
in {
  wayland.windowManager.hyprland.extraConfig = ''
    local mod = "SUPER"

    -- Applications
    hl.bind(mod .. " + SHIFT + A", ${exec appsMenu})

    -- Web links
    hl.bind(mod .. " + B", ${exec "uwsm app -- ${config.programs.helium.package}/bin/helium"})

    -- Power
    hl.bind(mod .. " + X", ${ipc "panel-toggle session"}) -- Powermenu
    hl.bind(mod .. " + SHIFT + X", ${exec powerMenu})

    -- Quick launch
    hl.bind(mod .. " + RETURN", ${exec "${pkgs.ghostty}/bin/ghostty +new-window"}) -- Ghostty (terminal, via daemon D-Bus)
    hl.bind(mod .. " + E", ${exec "${pkgs.ghostty}/bin/ghostty +new-window -e elio"}) -- Elio
    hl.bind(mod .. " + SPACE", ${ipc "panel-toggle launcher"}) -- Launcher (toggle)
    hl.bind(mod .. " + N", ${ipc "panel-toggle control-center notifications"}) -- Notification center
    hl.bind(mod .. " + comma", ${ipc "settings-toggle"}) -- Noctalia settings

    -- Windows
    hl.bind(mod .. " + Q", hl.dsp.window.close())
    hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
    hl.bind(mod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
    hl.bind(mod .. " + SHIFT + SPACE", ${exec "${scripts.focus-toggle}/bin/focus-toggle"}) -- Toggle focus mode

    -- Focus
    hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
    hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))
    hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
    hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))
    hl.bind(mod .. " + SHIFT + H", hl.dsp.focus({ monitor = "-1" }))
    hl.bind(mod .. " + SHIFT + J", hl.dsp.layout("removemaster"))
    hl.bind(mod .. " + SHIFT + K", hl.dsp.layout("addmaster"))
    hl.bind(mod .. " + SHIFT + L", hl.dsp.focus({ monitor = "+1" }))

    -- Special workspaces
    hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special("scratch"))
    hl.bind(mod .. " + CTRL + S", hl.dsp.window.move({ workspace = "special:scratch" }))

    -- Utilities
    -- Screenshots (Noctalia: frozen screen, clipboard + ~/Pictures)
    hl.bind(mod .. " + SHIFT + S", ${ipc "screenshot-region --annotate"}) -- Region + annotate
    hl.bind("Print", ${ipc "screenshot-region --annotate"})
    hl.bind("SHIFT + Print", ${ipc "screenshot-region"}) -- Region, no editor
    hl.bind(mod .. " + Print", ${ipc "screenshot-window"})
    hl.bind(mod .. " + SHIFT + Print", ${ipc "screenshot-fullscreen pick"})

    -- Workspaces 1-9 on the number row by keycode (code:10..18), layout-independent
    for i = 1, 9 do
      hl.bind(mod .. " + code:" .. (9 + i), hl.dsp.focus({ workspace = i }))
      hl.bind(mod .. " + SHIFT + code:" .. (9 + i), hl.dsp.window.move({ workspace = i }))
    end

    -- Mouse
    hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
    hl.bind(mod .. " + R", hl.dsp.window.resize(), { mouse = true })

    -- Brightness, media and sound keys keep working on the lock screen
    local locked = { locked = true }
    hl.bind("XF86MonBrightnessUp", ${ipc "brightness-up"}, locked)
    hl.bind("XF86MonBrightnessDown", ${ipc "brightness-down"}, locked)
    hl.bind("XF86AudioPlay", ${exec "${pkgs.playerctl}/bin/playerctl play-pause"}, locked)
    hl.bind("XF86AudioPause", ${exec "${pkgs.playerctl}/bin/playerctl play-pause"}, locked)
    hl.bind("XF86AudioNext", ${exec "${pkgs.playerctl}/bin/playerctl next"}, locked)
    hl.bind("XF86AudioPrev", ${exec "${pkgs.playerctl}/bin/playerctl previous"}, locked)
    hl.bind("XF86AudioStop", ${exec "${pkgs.playerctl}/bin/playerctl stop"}, locked)
    hl.bind("XF86AudioMute", ${ipc "volume-mute"}, locked)
    hl.bind("XF86AudioRaiseVolume", ${ipc "volume-up"}, locked)
    hl.bind("XF86AudioLowerVolume", ${ipc "volume-down"}, locked)
    hl.bind("XF86AudioMicMute", ${ipc "mic-mute"}, locked)
  '';
}
