# n8n workflow automation, hardened following https://docs.n8n.io/hosting/securing/
{
  config,
  lib,
  pkgs-unstable,
  ...
}: let
  inherit (import ./mk-container.nix {inherit lib config pkgs-unstable;}) mkContainer;
  url = "https://n8n.${config.var.domain}/";

  # Extra systemd sandboxing on top of the upstream module (DynamicUser, ProtectSystem=strict, ...).
  # No PrivateUsers: it breaks LoadCredential inside nspawn containers (see umami.nix).
  hardening = {
    CapabilityBoundingSet = "";
    AmbientCapabilities = "";
    SystemCallArchitectures = "native";
    SystemCallFilter = ["@system-service" "~@privileged"];
    ProtectProc = "invisible";
    ProtectClock = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    UMask = "0077";
  };
in {
  sops.secrets.n8n-encryption-key.mode = "0400";
  sops.secrets.n8n-runners-token.mode = "0400";

  imports = [
    (mkContainer {
      name = "n8n";
      hostIp = "10.233.12.1";
      containerIp = "10.233.12.2";
      # Workflows call external APIs. LAN and other containers stay blocked by mkContainer.
      internet = true;
      bindMounts = {
        "/run/secrets/n8n-encryption-key" = {
          hostPath = config.sops.secrets.n8n-encryption-key.path;
          isReadOnly = true;
        };
        "/run/secrets/n8n-runners-token" = {
          hostPath = config.sops.secrets.n8n-runners-token.path;
          isReadOnly = true;
        };
      };
      nixosConfig = {lib, ...}: {
        # n8n is under the Sustainable Use License; allow only what this container needs.
        nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) ["n8n" "n8n-task-runner-launcher"];

        # Unix socket only (enableTCPIP = false by default), peer auth for the n8n user.
        services.postgresql = {
          enable = true;
          ensureDatabases = ["n8n"];
          ensureUsers = [
            {
              name = "n8n";
              ensureDBOwnership = true;
            }
          ];
        };

        services.n8n = {
          enable = true;
          # Code node runs in separate sandboxed runner processes (external mode).
          taskRunners.enable = true;
          environment = {
            DB_TYPE = "postgresdb";
            DB_POSTGRESDB_HOST = "/run/postgresql";
            DB_POSTGRESDB_DATABASE = "n8n";
            DB_POSTGRESDB_USER = "n8n";

            # Behind cloudflared: one proxy hop, public HTTPS URL.
            N8N_LISTEN_ADDRESS = "0.0.0.0";
            N8N_HOST = "n8n.${config.var.domain}";
            N8N_PROTOCOL = "https";
            N8N_PROXY_HOPS = 1;
            N8N_EDITOR_BASE_URL = url;
            N8N_WEBHOOK_URL = url;
            N8N_SECURE_COOKIE = true;

            N8N_ENCRYPTION_KEY_FILE = "/run/secrets/n8n-encryption-key";
            N8N_RUNNERS_AUTH_TOKEN_FILE = "/run/secrets/n8n-runners-token";

            N8N_PUBLIC_API_DISABLED = true;
            N8N_PUBLIC_API_SWAGGERUI_DISABLED = true;
            N8N_SSRF_PROTECTION_ENABLED = true;
            N8N_BLOCK_ENV_ACCESS_IN_NODE = true;
            N8N_BLOCK_FILE_ACCESS_TO_N8N_FILES = true;
            N8N_GIT_NODE_DISABLE_BARE_REPOS = true;
            NODES_EXCLUDE = builtins.toJSON [
              "n8n-nodes-base.executeCommand"
              "n8n-nodes-base.localFileTrigger"
              "n8n-nodes-base.readWriteFile"
            ];

            EXECUTIONS_DATA_PRUNE = true;
            EXECUTIONS_DATA_MAX_AGE = 336; # hours (14 days)
            N8N_PERSONALIZATION_ENABLED = false;
            N8N_HIRING_BANNER_ENABLED = false;
          };
        };

        systemd.services.n8n = {
          after = ["postgresql.target"];
          requires = ["postgresql.target"];
          serviceConfig = hardening;
        };
        systemd.services.n8n-task-runner.serviceConfig = hardening;

        networking.firewall.allowedTCPPorts = [5678];
        system.stateVersion = "26.05";
      };
    })
  ];

  services.cloudflared.tunnels."${config.var.tunnelId}".ingress."n8n.${config.var.domain}" = "http://10.233.12.2:5678";
}
