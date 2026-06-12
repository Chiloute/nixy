{
  config,
  lib,
  ...
}: {
  imports = [
    # Choose your theme here:
    ../../themes/darkviolet.nix
  ];

  config.var = {
    hostname = "cora";
    username = "chiloute";
    configDirectory = "/home/" + config.var.username + "/.config/nixos"; # The path of the nixos configuration directory

    keyboardLayout = "fr";

    timeZone = "Europe/Paris";
    defaultLocale = "en_US.UTF-8";
    extraLocale = "fr_FR.UTF-8";

    git = {
      username = "Chiloute";
      email = "35150997+Chiloute@users.noreply.github.com";
    };

    autoUpgrade = false;
    autoGarbageCollector = true;

    domain = "chiloute.fr";
    tunnelId = "7a6da639-9222-4e7f-8c1e-2ec4d75ce4fb";
    networkInterface = "enp3s0";
  };

  # Let this here
  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };
}
