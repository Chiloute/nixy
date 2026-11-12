{
  config,
  inputs,
  lib,
  pkgs-unstable,
  ...
}: let
  inherit (import ./mk-container.nix {inherit lib config pkgs-unstable;}) mkContainer;
  domain = config.var.domain;
  # Flake input `blog` (github:Chiloute/cyber-blog): `packages.<system>.default` is the
  # built static site (Astro `dist/`), built offline from package-lock.json.
  # Headers follow docs/security.md in that repo. The CSP for scripts and styles is a
  # per-page <meta> emitted by Astro, so the header must not carry default-src/script-src/style-src.
  securityHeaders = pkgs-unstable.writeText "blog-security-headers.conf" ''
    add_header Content-Security-Policy "connect-src 'self'; img-src 'self' data:; font-src 'self'; media-src 'self'; object-src 'none'; frame-src 'none'; worker-src 'self'; manifest-src 'self'; base-uri 'self'; form-action 'self'; frame-ancestors 'none'; upgrade-insecure-requests" always;
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Permissions-Policy "accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), usb=(), browsing-topics=()" always;
    add_header Cross-Origin-Opener-Policy "same-origin" always;
    add_header Cross-Origin-Resource-Policy "same-origin" always;
    add_header X-Frame-Options "DENY" always;
  '';
  cache = value: ''
    include ${securityHeaders};
    add_header Cache-Control "${value}" always;
  '';
  # Every file in the Nix store has mtime 1, so nginx's Last-Modified/ETag would not change
  # across rebuilds (ETag is mtime-size): validators are disabled below and every unhashed
  # file is revalidated on each request, so a rebuild is visible immediately.
  feed = cache "public, max-age=0, must-revalidate";
in {
  imports = [
    (mkContainer {
      name = "blog";
      hostIp = "10.233.3.1";
      containerIp = "10.233.3.2";
      nixosConfig = {pkgs-unstable, ...}: {
        services.nginx = {
          enable = true;
          virtualHosts = {
            "blog" = {
              root = "${inputs.blog.packages.${pkgs-unstable.stdenv.hostPlatform.system}.default}";
              listen = [
                {
                  addr = "0.0.0.0";
                  port = 8080;
                }
              ];
              locations = {
                "/".tryFiles = "$uri $uri/ =404";
                # Static site: nothing hidden is ever served.
                "~ /\\.(?!well-known/)".extraConfig = "return 404;";
                "= /sitemap.xml".return = "301 /sitemap-index.xml";
                "/_astro/".extraConfig = cache "public, max-age=31536000, immutable";
                "/pagefind/".extraConfig = feed;
                # Content-hashed file names: safe to cache forever.
                "/pagefind/fragment/".extraConfig = cache "public, max-age=31536000, immutable";
                "/pagefind/index/".extraConfig = cache "public, max-age=31536000, immutable";
                "= /shiki.css".extraConfig = feed;
                "= /sitemap-index.xml".extraConfig = feed;
                "= /sitemap-0.xml".extraConfig = feed;
                "= /rss.xml".extraConfig = feed + "types { application/rss+xml xml; }\n";
                "= /writeups/rss.xml".extraConfig = feed + "types { application/rss+xml xml; }\n";
                "= /notes/rss.xml".extraConfig = feed + "types { application/rss+xml xml; }\n";
                "= /site.webmanifest".extraConfig =
                  cache "public, max-age=0, must-revalidate" + "types { application/manifest+json webmanifest; }\n";
              };
              extraConfig = ''
                charset utf-8;
                charset_types text/html text/xml text/plain text/css application/javascript application/json application/rss+xml application/manifest+json;
                etag off;
                if_modified_since off;
                port_in_redirect off;
                absolute_redirect off;
                error_page 404 /404.html;
                if ($request_method !~ ^(GET|HEAD)$) { return 405; }
                ${cache "public, max-age=0, must-revalidate"}
              '';
            };
            "www-redirect" = {
              listen = [
                {
                  addr = "0.0.0.0";
                  port = 8081;
                }
              ];
              extraConfig = "return 301 https://${domain}$request_uri;";
            };
          };
        };
        networking.firewall.allowedTCPPorts = [
          8080
          8081
        ];
        system.stateVersion = "24.05";
      };
    })
  ];

  services.cloudflared.tunnels."${config.var.tunnelId}".ingress = {
    "${config.var.domain}" = "http://10.233.3.2:8080";
    "www.${config.var.domain}" = "http://10.233.3.2:8081";
  };
}
