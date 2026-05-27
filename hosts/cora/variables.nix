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
    sshPublicKey = "ssh-ed2551";
  };

  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };
}
