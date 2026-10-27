# Memory pressure: compressed swap in RAM + systemd-oomd, instead of a hard OOM freeze.
{
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  systemd.oomd.enableUserSlices = true;
}
