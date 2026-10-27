# Bluetooth configuration for NixOS
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false; # turn on with bluetooth-toggle when needed
  };
}
