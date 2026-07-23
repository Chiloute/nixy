{...}: {
  ExtensionSettings = {
    "*" = {
      blocked_install_message = "The addon you are trying to install is not added in the Nix config";
      installation_mode = "blocked";
    };
  };
  "3rdparty".Extensions = {
    "adnauseam@rednoise.org" = {
      enabled = true;
      firstInstall = false;
      hidingAds = true;
      clickingAds = true;
      blockingMalware = true;
    };
  };
}
