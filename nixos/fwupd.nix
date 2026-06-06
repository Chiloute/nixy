# Firmware updates via LVFS (Linux Vendor Firmware Service).
# Lenovo publishes ThinkPad firmware (BIOS, Thunderbolt, etc.) there.
#
# The daemon is dbus-activated and only refreshes metadata in the background;
# it NEVER applies updates by itself. Update manually when you want:
#   fwupdmgr refresh
#   fwupdmgr get-updates
#   fwupdmgr update
{...}: {
  services.fwupd.enable = true;
}
