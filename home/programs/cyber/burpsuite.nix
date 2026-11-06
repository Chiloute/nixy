# Burp Suite Community: proxy listener on 127.0.0.1:8082 (spilltea keeps 8080),
# CA exported to ~/Cyber/certs/burp.der for the LibreWolf "sec" profile
{pkgs, ...}: let
  port = 8082;
  # Burp warns "not fully tested" on nixpkgs OpenJDK (java.vendor = N/A); Temurin passes its check
  burpsuite = pkgs.burpsuite.override {jdk = pkgs.temurin-bin-21;};

  # Project options loaded on every start (Community only has temporary projects)
  projectConfig = pkgs.writeText "burp-project.json" (builtins.toJSON {
    proxy.request_listeners = [
      {
        certificate_mode = "per_host";
        listen_mode = "loopback_only";
        listener_port = port;
        running = true;
      }
    ];
  });

  wrapper = pkgs.writeShellApplication {
    name = "burpsuite";
    runtimeInputs = [pkgs.curl pkgs.coreutils];
    text = ''
      # Java AWT draws blank windows under Hyprland without this
      export _JAVA_AWT_WM_NONREPARENTING=1
      cert="$HOME/Cyber/certs/burp.der"

      # Burp is pinned by Nix: --disable-auto-update stops it fetching a newer jar
      ${burpsuite}/bin/burpsuite --disable-auto-update --config-file=${projectConfig} "$@" &
      pid=$!

      # The CA is generated on first run; export it once the listener is up.
      # LibreWolf imports it on its next start.
      if [ ! -s "$cert" ]; then
        mkdir -p "$(dirname "$cert")"
        for _ in $(seq 120); do
          kill -0 "$pid" 2>/dev/null || break
          if curl -sf --noproxy '*' -o "$cert.tmp" http://127.0.0.1:${toString port}/cert; then
            mv "$cert.tmp" "$cert"
            break
          fi
          sleep 1
        done
        rm -f "$cert.tmp"
      fi

      wait "$pid"
    '';
  };
in {
  # Wrapper first so its bin/burpsuite shadows the upstream one (desktop entry included)
  home.packages = [
    (pkgs.symlinkJoin {
      name = "burpsuite-wrapped";
      paths = [wrapper burpsuite];
    })
  ];
}
