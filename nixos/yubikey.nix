# YubiKey: FIDO2/U2F for PAM, smartcard (CCID) for OATH/PIV, Yubico Authenticator.
#
# Register the key once (touch it when it blinks):
#   mkdir -p ~/.config/Yubico && pamu2fcfg > ~/.config/Yubico/u2f_keys
# Until that file exists, PAM skips the key and asks for the password / fingerprint as before.
{pkgs, ...}: {
  services.pcscd.enable = true;
  services.udev.packages = [pkgs.yubikey-personalization];
  hardware.gpgSmartcards.enable = true;

  environment.systemPackages = with pkgs; [
    yubioath-flutter
    yubikey-manager
    pam_u2f # pamu2fcfg
  ];

  # "sufficient": key touch OR the usual password/fingerprint, never key alone being required.
  security.pam.u2f = {
    enable = true;
    control = "sufficient";
    settings.cue = true;
  };
  security.pam.services = {
    sudo.u2fAuth = true;
    login.u2fAuth = true;
    polkit-1.u2fAuth = true;
    # u2fAuth defaults to true everywhere once pam.u2f is enabled; hyprlock would wait for a touch after the password.
    hyprlock.u2fAuth = false;
  };
}
