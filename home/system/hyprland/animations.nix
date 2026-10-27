{
  config,
  lib,
  ...
}: let
  animationSpeed = config.theme.animation-speed;

  speed =
    if animationSpeed == "slow"
    then 4
    else if animationSpeed == "medium"
    then 2.5
    else if animationSpeed == "fast"
    then 1.5
    else 0.5;

  # name = [x0 y0 x1 y1]
  beziers = {
    linear = [0 0 1 1];
    md3_standard = [0.2 0 0 1];
    md3_decel = [0.05 0.7 0.1 1];
    md3_accel = [0.3 0 0.8 0.15];
    overshot = [0.05 0.9 0.1 1.1];
    crazyshot = [0.1 1.5 0.76 0.92];
    hyprnostretch = [0.05 0.9 0.1 1.0];
    menu_decel = [0.1 1 0 1];
    menu_accel = [0.38 0.04 1 0.07];
    easeInOutCirc = [0.85 0 0.15 1];
    easeOutCirc = [0 0.55 0.45 1];
    easeOutExpo = [0.16 1 0.3 1];
    softAcDecel = [0.26 0.26 0.15 1];
    md2 = [0.4 0 0.2 1];
  };

  # leaf = [bezier style]; null style keeps Hyprland's default for that leaf.
  animations = {
    windows = ["md3_decel" "popin 60%"];
    windowsIn = ["md3_decel" "popin 60%"];
    windowsOut = ["md3_accel" "popin 60%"];
    border = ["default" null];
    fade = ["md3_decel" null];
    layersIn = ["menu_decel" "slide"];
    layersOut = ["menu_accel" null];
    fadeLayersIn = ["menu_decel" null];
    fadeLayersOut = ["menu_accel" null];
    workspaces = ["menu_decel" "slide"];
    specialWorkspace = ["md3_decel" "slidevert"];
  };
in {
  wayland.windowManager.hyprland.settings = {
    config.animations.enabled = true;

    curve =
      lib.mapAttrsToList (name: p: {
        _args = [
          name
          {
            type = "bezier";
            points = [
              (lib.sublist 0 2 p)
              (lib.sublist 2 2 p)
            ];
          }
        ];
      })
      beziers;

    animation = lib.mapAttrsToList (leaf: a:
      {
        inherit leaf speed;
        enabled = true;
        bezier = builtins.elemAt a 0;
      }
      // lib.optionalAttrs (builtins.elemAt a 1 != null) {style = builtins.elemAt a 1;})
    animations;
  };
}
