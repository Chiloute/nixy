# Power management for the Lenovo ThinkPad X1 Carbon Gen 12 (Intel Core Ultra 7 155H, Meteor Lake)
{lib, ...}: {
  # TLP and power-profiles-daemon are mutually exclusive — force PPD off
  services.power-profiles-daemon.enable = lib.mkForce false;

  # Intel thermal daemon: keeps Meteor Lake cool without aggressive throttling.
  services.thermald.enable = true;

  services.tlp = {
    enable = true;
    settings = {
      # --- CPU (intel_pstate active mode: governor stays powersave, EPP differentiates) ---
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 80;
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "balanced";

      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";
      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";

      USB_AUTOSUSPEND = 1;

      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };
}
