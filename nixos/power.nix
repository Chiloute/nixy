# Power management for the ThinkPad X1 Carbon Gen 12 (Core Ultra 7 155H, Meteor Lake).
# power-profiles-daemon (enabled in utils.nix) drives intel_pstate EPP and the firmware platform profile.
# No thermald: it refuses to run on ThinkPads exposing dytc_lapmode (the firmware owns thermals).
{
  # Keep the battery between 75 and 80 % when on AC (the EC can forget it after a full drain).
  systemd.tmpfiles.rules = [
    "w /sys/class/power_supply/BAT0/charge_control_start_threshold - - - - 75"
    "w /sys/class/power_supply/BAT0/charge_control_end_threshold - - - - 80"
  ];
}
