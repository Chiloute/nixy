# ClamAV antivirus.
# Keeps virus signatures up to date (freshclam) and runs a full machine scan
# twice a day. We use an on-demand `clamscan` (no resident `clamd` daemon) so
# nothing eats RAM between scans: the signature database is only loaded while a
# scan is running.
{
  pkgs,
  lib,
  ...
}: let
  # Directories left out of the "full machine" scan:
  #  - /proc, /sys, /dev, /run: kernel/virtual filesystems, not real files
  #  - /nix/store: immutable, read-only, rebuilt from trusted sources
  excludeDirs = [
    "^/proc"
    "^/sys"
    "^/dev"
    "^/run"
    "^/nix/store"
  ];
  excludeArgs = lib.concatMapStringsSep " " (dir: "--exclude-dir=${dir}") excludeDirs;
in {
  services.clamav.updater = {
    enable = true; # freshclam: keep the virus database fresh
    frequency = 12; # database checks per day
    interval = "hourly";
  };

  # Full-machine virus scan, triggered by the timer below.
  systemd.services.clamav-fullscan = {
    description = "ClamAV full machine scan";
    # Use a fresh database if both happen to start together (e.g. at boot).
    after = ["clamav-freshclam.service"];
    onFailure = ["clamav-alert.service"];
    serviceConfig = {
      Type = "oneshot";
      # Runs as root so every file is readable. Lowest CPU/IO priority so the
      # scan doesn't disrupt the other services running on the box.
      Nice = 19;
      IOSchedulingClass = "idle";
      ExecStart = lib.concatStringsSep " " [
        "${pkgs.clamav}/bin/clamscan"
        "--database=/var/lib/clamav" # database maintained by freshclam
        "--recursive"
        "--infected" # only log infected files
        "--max-filesize=2000M" # scan large files too (thorough, but slower)
        "--max-scansize=2000M"
        excludeArgs
        "/"
      ];
    };
  };

  systemd.services.clamav-alert = {
    description = "Alert when the ClamAV scan fails or finds infected files";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/logger -t clamav -p user.crit 'ClamAV full scan failed or found infected files (check: journalctl -u clamav-fullscan)'";
    };
  };

  systemd.timers.clamav-fullscan = {
    description = "Run a full ClamAV scan twice a day";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 03,15:00:00"; # 03:00 and 15:00
      Persistent = true; # catch up on boot if a scan was missed (machine off)
      RandomizedDelaySec = "15m";
    };
  };
}
