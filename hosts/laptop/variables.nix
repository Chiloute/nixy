{
  config,
  lib,
  ...
}: {
  imports = [
    # Choose your theme here:
    ../../themes/rose-pine.nix
  ];

  config.var = {
    hostname = "corava";
    username = "chiloute";
    configDirectory =
      "/home/"
      + config.var.username
      + "/.config/nixos"; # The path of the nixos configuration directory

    keyboardLayout = "fr";

    location = "Paris";
    timeZone = "Europe/Paris";
    defaultLocale = "en_US.UTF-8";
    extraLocale = "fr_FR.UTF-8";

    git = {
      username = "Chiloute";
      email = "35150997+Chiloute@users.noreply.github.com";
    };

    autoUpgrade = false;
    autoGarbageCollector = true;
  };

  # DON'T TOUCH THIS
  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };
}
