{...}: {
  # Only extensions declared in extensions.nix are allowed; the user can't
  # install anything else (same idea as zen/policies.nix).
  ExtensionSettings = {
    "*" = {
      install_sources = ["https://addons.mozilla.org/*" "https://*.mozilla.org/*"];
      blocked_install_message = "The addon you are trying to install is not added in the Nix config";
      installation_mode = "blocked";
    };

    # == Helium addons (see extensions.nix) ==
    # private_browsing: keep them usable in private windows.
    # default_area: where the icon lives on the toolbar.
    "gdpr@cavi.au.dk" = {
      # Consent-O-Matic
      installation_mode = "allowed";
      private_browsing = true;
    };
    "foxyproxy@eric.h.jung" = {
      # FoxyProxy Standard
      installation_mode = "allowed";
      private_browsing = true;
      default_area = "navbar";
    };
    "jid1-MnnxcxisBPnSXQ@jetpack" = {
      # Privacy Badger
      installation_mode = "allowed";
      private_browsing = true;
    };
    "78272b6fa58f4a1abaac99321d503a20@proton.me" = {
      # Proton Pass
      installation_mode = "allowed";
      private_browsing = true;
      default_area = "navbar";
    };
    "wappalyzer@crunchlabz.com" = {
      # Wappalyzer
      installation_mode = "allowed";
      private_browsing = true;
      default_area = "navbar";
    };
    "uBlock0@raymondhill.net" = {
      # uBlock Origin (installed by LibreWolf upstream, but explicitly allowed for full control)
      installation_mode = "allowed";
      private_browsing = true;
    };
  };

  DisableAppUpdate = true;
  DisableDefaultBrowserAgent = true;
  DisableFirefoxStudies = true;
  DisableTelemetry = true;
  DontCheckDefaultBrowser = true;

  NewTabURL = "http://127.0.0.1:8888";
}
