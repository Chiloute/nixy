# Fingerprint authentication (ThinkPad X1 Carbon Gen 12 reader).
#
# After the first rebuild, enroll your finger once:
#   fprintd-enroll
#   fprintd-verify   # to test
#
# Once enrolled, login / sudo / screen-unlock accept the fingerprint and
# fall back to the password if it fails.
{...}: {
  services.fprintd.enable = true;

  security.pam.services = {
    hyprlock.fprintAuth = false;

    sudo.rules.auth.fprintd.settings = {
      "max-tries" = 1;
      timeout = 10;
    };
    polkit-1.rules.auth.fprintd.settings = {
      "max-tries" = 1;
      timeout = 10;
    };
  };
}
