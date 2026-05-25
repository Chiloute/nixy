{
  config,
  lib,
  ...
}: {
  config.var = {
    hostname = "cora";
    username = "chiloute";
    timeZone = "Europe/Paris";
    defaultLocale = "en_US.UTF-8";
    autoUpgrade = false;
    autoGarbageCollector = true;
  };

  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };
}
