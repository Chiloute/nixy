# Helpers to emit Hyprland Lua calls through wayland.windowManager.hyprland.settings.
{lib}: let
  inherit (lib.generators) mkLuaInline toLua;
in {
  # Lua equivalent of hyprlang's exec-once: runs `cmd` once, when Hyprland starts.
  # Use as `settings.on = [ (hl.onStart "cmd") ];`
  onStart = cmd: {
    _args = [
      "hyprland.start"
      (mkLuaInline "function() hl.exec_cmd(${toLua {} cmd}) end")
    ];
  };

  # Lua expression of a dispatcher that runs `cmd`, for hl.bind in extraConfig.
  exec = cmd: "hl.dsp.exec_cmd(${toLua {} cmd})";
}
