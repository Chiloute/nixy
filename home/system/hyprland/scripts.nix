# Desktop actions Noctalia has no built-in for. Feedback goes through its OSD.
{pkgs, ...}: let
  osd = icon: text: "noctalia msg osd-show ${icon} \"${text}\" || true";

  focus-toggle = pkgs.writeShellScriptBin "focus-toggle" ''
    if test -f "$XDG_RUNTIME_DIR/hypr-focus-mode"; then
      rm "$XDG_RUNTIME_DIR/hypr-focus-mode"
      ${pkgs.hyprland}/bin/hyprctl reload
      noctalia msg bar-show
      ${osd "eye" "Focus Off"}
    else
      touch "$XDG_RUNTIME_DIR/hypr-focus-mode"
      noctalia msg bar-hide
      ${pkgs.hyprland}/bin/hyprctl eval 'hl.config({
        animations = { enabled = false },
        general = { gaps_in = 0, gaps_out = 0 },
        decoration = { active_opacity = 1, inactive_opacity = 1, rounding = 0 },
      })'
      ${osd "eye" "Focus On"}
    fi
  '';

  color-pick = pkgs.writeShellScriptBin "color-pick" ''
    # hyprpicker -a already copies the color to the clipboard.
    color=$(${pkgs.hyprpicker}/bin/hyprpicker -a 2>/dev/null)
    ${osd "color-picker" "\${color:-Cancelled}"}
  '';

  record-toggle = pkgs.writeShellScriptBin "record-toggle" ''
    if ${pkgs.procps}/bin/pgrep -x wf-recorder >/dev/null; then
      # -INT lets wf-recorder finalize the file cleanly.
      ${pkgs.procps}/bin/pkill -INT -x wf-recorder
      ${osd "player-stop" "Recording saved"}
    else
      dir="$HOME/Videos"
      mkdir -p "$dir"
      file="$dir/rec-$(date +%Y%m%d-%H%M%S).mp4"
      ${pkgs.wf-recorder}/bin/wf-recorder -f "$file" >/dev/null 2>&1 &
      ${osd "player-record" "Recording…"}
    fi
  '';

  entry = name: pkg: icon: comment: {
    inherit name icon comment;
    exec = "${pkg}/bin/${pkg.name}";
    categories = ["System"];
    terminal = false;
  };
in {
  _module.args.scripts = {inherit focus-toggle;};

  # Shown in the Noctalia launcher, like the old tofi actions.
  xdg.desktopEntries = {
    focus-toggle = entry "Focus Mode" focus-toggle "do-not-disturb-symbolic" "Toggle focus mode";
    color-pick = entry "Color Picker" color-pick "color-select-symbolic" "Pick a color to the clipboard";
    record-toggle = entry "Screen Record" record-toggle "media-record-symbolic" "Start or stop screen recording";
  };
}
