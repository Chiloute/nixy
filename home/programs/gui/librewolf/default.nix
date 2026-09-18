{
  config,
  lib,
  pkgs,
  ...
}: let
  extensions = import ./extensions.nix {inherit pkgs;};
  policies = import ./policies.nix {};
in {
  stylix.targets.librewolf.profileNames = ["default"];

  programs.librewolf = {
    enable = true;
    nativeMessagingHosts = [];
    languagePacks = ["en-US" "fr"];

    policies = policies;

    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;

        bookmarks = import ./bookmarks/default.nix {inherit lib;};

        search = {
          force = true;
          default = "Startpage";
          privateDefault = "Startpage";
          engines = {
            Startpage = {
              urls = [
                {
                  template = "https://www.startpage.com/do/search?q={searchTerms}";
                  params = [
                    {
                      name = "abp";
                      value = "-1";
                    }
                  ];
                }
              ];
              iconMapObj."16" = "https://www.startpage.com/favicon.ico";
              definedAliases = ["@sp"];
            };
          };
        };

        extensions = {
          inherit (extensions) packages;
          # Acknowledged: we manage the extension configuration (policies.nix).
          force = true;
        };

        settings = {
          # ------------------------------------------------------------------
          # Startup: use local bookmarks page (same as Helium)
          "browser.startup.homepage" = "http://127.0.0.1:8888";
          "browser.startup.page" = 1;

          # ------------------------------------------------------------------
          # Anti-fingerprinting: FPP instead of RFP.
          # RFP (resistFingerprinting) is Tor-level: it also forces the timezone
          # to UTC, a spoofed UA/platform, light theme and keyboard handling,
          # which is what breaks sites. FPP covers the same vectors in a less
          # invasive way and keeps letterboxing.
          #   - RFP off (LibreWolf enables it by default via defaultPref, a
          #     profile user.js user_pref wins here).
          #   - FPP on, ALL targets protected... except the JS timezone, which
          #     is by far the #1 breakage. Remove `,-JSDateTimeUTC` for the
          #     absolute maximum.
          "privacy.resistFingerprinting" = false;
          "privacy.fingerprintingProtection" = true;
          "privacy.fingerprintingProtection.overrides" = "+AllTargets,-JSDateTimeUTC";
          "privacy.resistFingerprinting.letterboxing" = false;

          # ------------------------------------------------------------------
          # DNS over HTTPS (mirror Helium: Quad9, mode 2 = fallback to system).
          "network.trr.mode" = 2;
          "network.trr.uri" = "https://dns.quad9.net/dns-query";

          # ------------------------------------------------------------------
          # Disable speculative/prefetch connections (data leakage + tracking).
          "network.dns.disablePrefetch" = true;
          "network.predictor.enabled" = false;
          "network.prefetch-next" = false;
          "network.http.speculative-parallel-limit" = 0;
          "browser.urlbar.speculativeConnect.enabled" = false;

          # Referrer privacy: same-origin only, trimmed to scheme+host+port.
          "network.http.referer.XOriginPolicy" = 1;
          "network.http.referer.XOriginTrimmingPolicy" = 2;
          "browser.send_pings" = false;

          # Punycode everywhere (anti-phishing, no homograph domains).
          "network.IDN_show_punycode" = true;

          # ------------------------------------------------------------------
          # Telemetry / Mozilla services (LibreWolf defaults, re-enforced).
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "browser.ping-centre.telemetry" = false;
          "app.shield.optoutstudies.enabled" = false;
          "identity.fxaccounts.enabled" = false;

          # Password manager / autofill: Proton Pass handles this.
          "signon.rememberSignons" = false;
          "extensions.formautofill.addresses.enabled" = false;
          "extensions.formautofill.creditCards.enabled" = false;

          # ------------------------------------------------------------------
          # Declarative extensions (installed via home-manager) must be
          # auto-enabled instead of asking for permission on every rebuild.
          "extensions.autoDisableScopes" = 0;
        };
      };
    };
  };

  # Keep the profile over rebuilds (mirror Helium, only when impermanence is on).
  home.persistence."/persist" = lib.mkIf (config.var.impermanenceEnabled or false) {
    directories = [".librewolf"];
  };
}
