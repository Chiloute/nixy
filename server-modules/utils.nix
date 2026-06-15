# Misc — headless server (no desktop/GUI stack)
{
  pkgs,
  config,
  ...
}: let
  hostname = config.var.hostname;
  keyboardLayout = config.var.keyboardLayout;
  configDir = config.var.configDirectory;
  timeZone = config.var.timeZone;
  defaultLocale = config.var.defaultLocale;
  extraLocale = config.var.extraLocale;
  autoUpgrade = config.var.autoUpgrade;
in {
  networking.hostName = hostname;

  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  system.autoUpgrade = {
    enable = autoUpgrade;
    dates = "04:00";
    flake = "${configDir}";
    flags = [
      "--update-input"
      "nixpkgs"
      "--commit-lock-file"
    ];
    allowReboot = false;
  };

  time.timeZone = timeZone;
  i18n.defaultLocale = defaultLocale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = extraLocale;
    LC_IDENTIFICATION = extraLocale;
    LC_MEASUREMENT = extraLocale;
    LC_MONETARY = extraLocale;
    LC_NAME = extraLocale;
    LC_NUMERIC = extraLocale;
    LC_PAPER = extraLocale;
    LC_TELEPHONE = extraLocale;
    LC_TIME = extraLocale;
  };
  console.keyMap = keyboardLayout;

  environment.variables = {
    EDITOR = "nvim";
  };

  services.dbus = {
    enable = true;
    implementation = "broker";
  };

  environment.pathsToLink = ["/share/zsh"];

  documentation = {
    enable = true;
    doc.enable = false;
    man.enable = true;
    dev.enable = false;
    info.enable = false;
    nixos.enable = false;
  };

  environment.systemPackages = with pkgs; [
    fd
    bc
    file
    git-ignore
    xdg-utils
    wget
    curl
    gnupg
    openssl
    vim
    zip
    unzip
    pfetch
    btop
    p7zip
  ];
}
