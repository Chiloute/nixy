{pkgs}: let
  addons = pkgs.nur.repos.rycee.firefox-addons;
in {
  # Same addons as installed in Helium (helium/system.nix).
  packages = with addons; [
    consent-o-matic # Auto-handles GDPR consent banners
    foxyproxy-standard # Proxy management
    privacy-badger # Tracker/fingerprinter blocking
    proton-pass # Password manager
    ublock-origin # Block ads/trackers (upstream LibreWolf installs it, but we want full control)
    wappalyzer # Technology detection
  ];
}
