# Server

`hosts/server` builds the `cora` configuration: a NixOS machine that runs its services in NixOS containers and is reachable only through a Cloudflare Tunnel.

Build it with `sudo nixos-rebuild switch --flake ~/.config/nixos#cora`.

## Variables

Set in `hosts/server/variables.nix`:

| Variable | Used for |
|---|---|
| `domain` | Public hostnames: `<service>.<domain>` |
| `tunnelId` | ID of the Cloudflare tunnel in `server-modules/cloudflared.nix` |
| `networkInterface` | WAN interface for container NAT (`eno1`) |

The tunnel credentials come from the sops secret `cloudflared-token`.

## Request path

### How a request reaches a service

```mermaid
flowchart LR
    user["Browser"] -->|HTTPS| cf["Cloudflare"]
    cf --> cfd["cloudflared<br/>(host)"]
    cfd -->|10.233.11.2:3002| gitea["container gitea"]
    cfd -->|10.233.12.2:5678| n8n["container n8n"]
    cfd -->|10.233.3.2:8080| blog["container blog"]
    cfd -->|10.233.5.2:8080| cyber["container cyberchef"]
    cfd -->|10.233.9.2:8080| pdf["container bentopdf"]
    cfd -->|10.233.7.2:8080| mazanoke["container mazanoke"]
    cfd -->|localhost:22| ssh["sshd (host)"]
```

Each module adds its own `ingress` entry to `services.cloudflared.tunnels.<tunnelId>`. Any hostname without an entry gets `http_status:404`.

## Modules

Imported by `hosts/server/configuration.nix`:

| Module | Hostname | Runs as | Notes |
|---|---|---|---|
| `gitea.nix` | `git.<domain>` | container `gitea`, port 3002 | PostgreSQL inside the container, `/var/lib/gitea` bind-mounted, outbound internet allowed |
| `n8n.nix` | `n8n.<domain>` | container `n8n`, port 5678 | PostgreSQL over Unix socket inside the container, task runners in external mode, outbound internet allowed. Hardening below |
| `blog.nix` | `<domain>`, `www.<domain>` | container `blog`, ports 8080 (site) and 8081 (`www` redirect) | Static site from the flake input `blog` ([cyber-blog](https://github.com/Chiloute/cyber-blog)), built offline by Nix; security headers from its `docs/security.md`. Update with `nix flake update blog` |
| `cyberchef.nix` | `cyberchef.<domain>` | container, port 8080 | |
| `bentopdf.nix` | `pdf.<domain>` | container, port 8080 | |
| `mazanoke.nix` | `mazanoke.<domain>` | container, port 8080 | |
| `ssh.nix` | `ssh.<domain>` | host, port 22 | See [SECURITY](SECURITY.md#server) |
| `cloudflared.nix` | none | host | Tunnel service, restarts every 5 s, 10 starts per 300 s |
| `firewall.nix`, `fail2ban.nix`, `kernel-hardening.nix`, `clamav.nix` | none | host | See [SECURITY](SECURITY.md#server) |
| `performance.nix` | none | host | zram swap (zstd, 50% of RAM), journald capped at 500 MB and one month |

Present in `server-modules/` but not imported:

| Module | Content |
|---|---|
| `adguardhome.nix` | AdGuard Home on port 3000, DNS on port 53, `adguard.<domain>` |
| `arr.nix` | Media stack (`media`, `demandemedia`, `bazarr`, `prowlarr`, `radarr`, `sonarr`, `transmission` hostnames) |
| `umami.nix` | Umami analytics, container port 8080, `umami.<domain>` |

Import one in `hosts/server/configuration.nix` to enable it.

## Containers

`mk-container.nix` exports `mkContainer`, which every container module uses.

| Argument | Default | Effect |
|---|---|---|
| `name` | required | Container name. The host interface is `ve-<name>`, limited to 15 characters (checked by an assertion) |
| `hostIp`, `containerIp` | required | Private network. Convention: `10.233.N.1` and `10.233.N.2` |
| `internet` | `false` | NAT outbound traffic through `externalInterface` |
| `externalInterface` | `config.var.networkInterface` | WAN interface for NAT |
| `bindMounts` | `{}` | Host paths mounted in the container |
| `nixosConfig` | required | NixOS module of the container |

Every container gets `privateNetwork = true`, `autoStart = true` and hardening for `services.nginx` (no server tokens, restricted namespaces and address families).

`firewall.nix` sets the `FORWARD` policy to `DROP`. With `internet = true`, `mkContainer` inserts rules that accept new outbound connections from the container, drop traffic to `192.168.0.0/16`, `172.16.0.0/12` and `10.0.0.0/8`, and accept return traffic. Containers without `internet` cannot reach the LAN, the internet or each other.

Subnets in use: `10.233.3` (blog), `10.233.5` (cyberchef), `10.233.7` (mazanoke), `10.233.9` (bentopdf), `10.233.10` (umami), `10.233.11` (gitea), `10.233.12` (n8n).

## n8n

`n8n.nix` uses the NixOS module `services.n8n` (no Docker image) and follows the [n8n security docs](https://docs.n8n.io/hosting/securing/overview/):

- Secrets from sops, bind-mounted read-only and loaded through systemd `LoadCredential`: `n8n-encryption-key` (`N8N_ENCRYPTION_KEY_FILE`) and `n8n-runners-token` (`N8N_RUNNERS_AUTH_TOKEN_FILE`).
- Behind cloudflared: `N8N_PROXY_HOPS=1`, `N8N_WEBHOOK_URL` and `N8N_EDITOR_BASE_URL` set to `https://n8n.<domain>/`, secure cookies.
- Public API and Swagger UI disabled, SSRF protection on, environment access from nodes blocked, Execute Command, Local File Trigger and Read/Write Files nodes excluded.
- Code node runs in the external task runners (JavaScript and Python), connected to the broker on `127.0.0.1:5679`.
- Execution data pruned after 14 days, telemetry, personalization and version notifications off.
- Unfree license (`sustainableUse`) allowed only for `n8n` and `n8n-task-runner-launcher`, inside the container.
- systemd sandbox on top of the upstream module (`DynamicUser`, `ProtectSystem=strict`): no capabilities, `@system-service` syscall filter without `@privileged`, `ProtectProc=invisible`, `UMask=0077`. `PrivateUsers` stays off because it breaks `LoadCredential` in nspawn.

Create the secrets before the first rebuild, otherwise sops-nix fails the build:

```sh
sops hosts/server/secrets/secrets.yaml
# n8n-encryption-key: <openssl rand -hex 32>
# n8n-runners-token: <openssl rand -hex 32>
```

Keep a copy of the encryption key: without it, stored credentials cannot be decrypted.

## Add a service

1. Copy `server-modules/cyberchef.nix`.
2. Change `name`, pick an unused `10.233.N.x` pair, and set the container's listening port in `networking.firewall.allowedTCPPorts`.
3. Change the `ingress."<name>.${config.var.domain}"` line to the container IP and port.
4. Add the file to `imports` in `hosts/server/configuration.nix`, then `git add` it and rebuild.

## Set up the tunnel

The commands come from the comments in `server-modules/cloudflared.nix`:

```sh
cloudflared tunnel login
cloudflared tunnel create YourTunnelName
```

Put the tunnel ID in `tunnelId` and the credentials file content in the sops secret `cloudflared-token`.

TODO: document how DNS records and Cloudflare Access are configured; they live in the Cloudflare dashboard, not in this repository.
