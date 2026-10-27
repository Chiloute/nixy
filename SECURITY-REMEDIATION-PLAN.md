# Plan de remédiation sécurité

Audit réalisé le 2026-10-19 sur le commit `0801c344` (worktree avec modifications non commitées : `nixos/yubikey.nix`, `hosts/laptop/usbguard.nix`, `nixos/utils.nix`, `home/programs/tui/pkgs.nix`).

Portée : lecture du code source uniquement, rien n'a été exécuté. Aucun finding critique ou haut. Aucun secret en clair trouvé dans les fichiers suivis par git.

## Ordre conseillé

| # | Priorité | Sujet | Fichier | Effort |
|---|----------|-------|---------|--------|
| 1 | Moyenne (avant import) | PAM YubiKey cassé / mono-facteur | `nixos/yubikey.nix` | 30 min |
| 2 | Basse | USBGuard : règles VID:PID sans contrainte d'interface | `hosts/laptop/usbguard.nix` | 20 min |
| 3 | Basse | USBGuard : `IPCAllowedUsers` inclut l'utilisateur | `nixos/usbguard.nix` | 5 min |
| 4 | Basse | Pas de politique FORWARD par défaut entre conteneurs | `server-modules/mk-container.nix` | 30 min |
| 5 | Basse (dormant) | Secret recyclarr en mode `0777` | `server-modules/arr.nix` | 2 min |
| 6 | Basse | Gitea `ALLOWED_DOMAINS` trop large | `server-modules/gitea.nix` | 2 min |
| 7 | Info | fail2ban aveugle sur le SSH via tunnel Cloudflare | `server-modules/{ssh,fail2ban}.nix` | variable |
| 8 | Basse | CI : module Go non épinglé, hook `shell=True` | `.github/` | 20 min |
| 9 | Basse/Info | Divers (permissions, sandbox ClamAV) | voir ci-dessous | 30 min |

---

## 1. `nixos/yubikey.nix` : à corriger AVANT de l'importer

Le module n'est importé nulle part pour l'instant, donc aucun impact actuel.

**Problèmes**
- `security.pam.services.{sudo,login}.text` remplace toute la pile PAM par une seule ligne `auth sufficient pam_yubico.so`. Pas de `account`/`session`, pas de repli mot de passe ni empreinte. Si l'OTP échoue, `sudo` et le login console échouent.
- Cela écrase aussi la règle fprintd de `nixos/fprintd.nix`.
- La YubiKey seule remplace le mot de passe : quiconque a la clé devient root. Pas de PIN.
- `id=1` est l'ID client de test public, sans `key=` : validation en ligne via YubiCloud.
- Le script d'activation réécrit `/etc/nixos/yubikey_mappings` avec `chiloute:changeme` à chaque rebuild, ce qui écrase le vrai ID et verrouille l'accès.
- `debug` affiche des détails OTP/token dans le terminal.

**Correctif**
1. Supprimer les blocs `text = ''...''` et le `system.activationScripts.setupYubikeyMapping`.
2. Utiliser FIDO2/U2F plutôt que l'OTP :
   ```nix
   security.pam.u2f = {
     enable = true;
     control = "sufficient"; # ou "required" pour avoir clé + mot de passe
     settings.cue = true;
   };
   security.pam.services.sudo.u2fAuth = true;
   security.pam.services.login.u2fAuth = true;
   ```
3. Enregistrer la clé : `pamu2fcfg > ~/.config/Yubico/u2f_keys` (ou `authFile` géré par sops).
4. Retirer `yubico-pam` des `systemPackages` si inutilisé.
5. Garder une session root ouverte pendant le premier `nixos-rebuild test` pour éviter un lockout.

**Vérification** : `sudo -k; sudo true` avec la clé, sans la clé (repli mot de passe/empreinte), et une connexion TTY.

---

## 2. USBGuard : règles trop permissives

`hosts/laptop/usbguard.nix` : les règles pour Crucial X8, SanDisk, YubiKey (`1050:0407`) et la dock (`17ef:*`) ne vérifient que VID:PID. Un appareil qui usurpe ces IDs avec une interface clavier serait accepté (nécessite un accès physique).

**Correctif**
- Ajouter des contraintes d'interface :
  ```
  allow id 0634:5602 name "Crucial X8 SSD"        with-interface one-of { 08:*:* }
  allow id 0781:5591 name "SanDisk 3.2Gen1"       with-interface one-of { 08:*:* }
  allow id 1050:0407 name "YubiKey OTP+FIDO+CCID" with-interface one-of { 03:*:* 0b:*:* }
  ```
- Pour la dock : `with-interface` adapté (hubs `09:*:*`, Ethernet `02:*:*` / `0a:*:*`, audio `01:*:*`) ou, mieux, épingler avec `hash` via `usbguard generate-policy` dock branchée.
- Corriger le nom `" SanDisk 3.2Gen1"` (espace en trop).

---

## 3. USBGuard : `IPCAllowedUsers`

`nixos/usbguard.nix` ajoute `config.var.username` ; `hosts/laptop/usbguard.nix` veut root uniquement. Les listes fusionnent, donc le résultat est `root` + `chiloute` : tout processus de ta session peut autoriser un périphérique bloqué.

**Correctif** : retirer `config.var.username` du module partagé, ou dans l'hôte :
```nix
services.usbguard.IPCAllowedUsers = lib.mkForce ["root"];
```
(ajouter `lib` aux arguments du module).

---

## 4. Conteneurs serveur : politique FORWARD

`mk-container.nix` suppose qu'une chaîne `CONTAINER-FWD` bloque le forwarding par défaut. Elle n'est définie nulle part. Gitea active `ip_forward`, donc les conteneurs peuvent se joindre entre eux (ex. cyberchef vers gitea:3002). Impact faible (services déjà publics) mais le commentaire est faux.

**Correctif**
- Définir une vraie politique par défaut dans un module serveur (ex. `firewall.nix`), par exemple via `networking.firewall.extraCommands` : `iptables -P FORWARD DROP` puis autoriser explicitement :
  - retour (`RELATED,ESTABLISHED`),
  - sortie des conteneurs `internet = true` (règles déjà dans `mk-container.nix`).
- Ou plus simple : règle `iptables -I FORWARD 1 -i ve-+ -o ve-+ -j DROP`.
- Corriger le commentaire de `mk-container.nix`.
- Vérifier ensuite que cloudflared (host vers conteneurs) fonctionne toujours : c'est de l'OUTPUT/INPUT local, pas du FORWARD.

**Test** : depuis un conteneur, `curl http://10.233.11.2:3002` doit échouer ; `https://git.chiloute.fr` doit continuer de marcher.

---

## 5. `arr.nix` : secret recyclarr en `0777`

```nix
recyclarr = {
  owner = "recyclarr";
  mode = "0400";
};
```
Module non importé aujourd'hui ; à corriger avant de le réactiver.

---

## 6. Gitea : `ALLOWED_DOMAINS`

`"github.com, *.github.com, *gitlab.com"` : `*gitlab.com` matche aussi `evilgitlab.com`.
```nix
migrations.ALLOWED_DOMAINS = "github.com, *.github.com, gitlab.com, *.gitlab.com";
```

---

## 7. SSH via Cloudflare Tunnel et fail2ban

Les connexions via le tunnel arrivent de `127.0.0.1` (dans `ignoreIP`) : jamais bannies. Le mot de passe est désactivé, donc le risque est faible.

**Options** (à choisir)
- Mettre Cloudflare Access (ou un service token) devant `ssh.chiloute.fr` : à faire dans le dashboard Cloudflare.
- Ou retirer `ssh.<domain>` de l'ingress si tu n'en as pas besoin hors LAN.
- Optionnel : `openFirewall = false` + `networking.firewall.interfaces.<lan>.allowedTCPPorts = [22]` pour limiter à ton LAN.

---

## 8. CI et hooks

- `.github/workflows/update-readme.yml` :
  - épingler `go install ...@<version ou commit>` au lieu de `@latest`,
  - épingler `actions/checkout` et `actions/setup-go` sur un SHA,
  - remplacer `git add .` par `git add README.md`.
- `.github/scripts/inject-exec.py` : exécute `shell=True` les commandes des commentaires `<!-- exec: -->` du README. Ne committe pas un README qui contient des commentaires venant d'ailleurs ; ou restreindre à une liste de commandes autorisées.

---

## 9. Divers

- `hosts/server/secrets/default.nix` : `config` (`~/.ssh/config`) en `0644` → `0600`. Le bloc définit aussi `owner`/`mode` en double ; fusionner en un seul bloc par secret.
- `server-modules/clamav.nix` : ajouter un durcissement systemd au service `clamav-fullscan` (`ProtectSystem=strict`, `ProtectHome=read-only`, `PrivateTmp`, `NoNewPrivileges`, `CapabilityBoundingSet` réduit). Le scan tourne en root sur `/`.
- `nixos/sddm.nix` : `sha256 = ""` pour le fond « cat-watching-the-star » ; mettre le vrai hash si tu utilises ce fond (le module n'est pas importé actuellement).
- Groupes à privilèges (`podman`, `wireshark`, `libvirtd`, `wheel`) : compromis accepté, rien à faire sauf si tu veux réduire la surface.

---

## À vérifier hors dépôt

- **Cloudflare Access** devant les hostnames exposés par le tunnel (surtout `transmission`, `radarr`, `sonarr`, `prowlarr`, `adguard` si tu réactives `arr.nix` / `adguardhome.nix`). Transmission a ses whitelists RPC désactivées dans `arr.nix`.
- Rotation des PAT `github_pat`, `gitlab_pat`, `gitea_token` du serveur si tu as le moindre doute sur la clé age `~/.config/sops/age/keys.txt` (lisible par tout processus de ta session).

## Checklist

- [ ] 1. YubiKey : passer à `pam_u2f`, retirer `text =` et le script d'activation
- [ ] 2. USBGuard : contraintes `with-interface` / hash
- [ ] 3. USBGuard : `IPCAllowedUsers = ["root"]`
- [ ] 4. FORWARD : politique par défaut + commentaire corrigé
- [ ] 5. recyclarr : mode `0400`
- [ ] 6. Gitea : `ALLOWED_DOMAINS`
- [ ] 7. SSH tunnel : Access ou suppression de l'ingress
- [ ] 8. CI : épingler versions, `git add README.md`
- [ ] 9. Divers : `~/.ssh/config` en `0600`, sandbox ClamAV
