{ config, ... }: let
  username = config.var.username;
in {
  services.openssh = {
    enable       = true;
    ports        = [ 22 ];
    openFirewall = true;
    settings = {
      PermitRootLogin        = "no";
      PasswordAuthentication = false;         # ANSSI R53
      AllowUsers             = [ username ];  # ANSSI R54
      MaxAuthTries           = 3;             # ANSSI R50
      LoginGraceTime         = 20;            # ANSSI R50
      X11Forwarding          = false;
      AllowAgentForwarding   = false;
      AllowTcpForwarding     = false;
      ClientAliveInterval    = 300;
      ClientAliveCountMax    = 2;
      KexAlgorithms = [                       # ANSSI R50
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
      ];
      Ciphers = [                             # ANSSI R50
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
      ];
      Macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
      ];
    };
  };

  users.users."${username}".openssh.authorizedKeys.keys = [
    config.var.sshPublicKey
  ];
}
