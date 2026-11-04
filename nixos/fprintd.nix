# Fingerprint authentication (ThinkPad X1 Carbon Gen 12 reader).
#
# After the first rebuild, enroll your finger once:
#   fprintd-enroll
#   fprintd-verify   # to test
#
# Once enrolled, sudo / polkit accept the fingerprint and
# fall back to the password if it fails.
{...}: {
  services.fprintd.enable = true;

  security.pam.services = {
    # Off: Noctalia's lock screen authenticates on "login" (password only for now).
    login.fprintAuth = false;

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
