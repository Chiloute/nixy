{ ... }: {
  # Masquer les processus des autres utilisateurs — ANSSI R67
  security.hideProcessInformation = true;

  # Désactiver les core dumps — ANSSI R68
  systemd.coredump.enable = false;
  security.pam.loginLimits = [
    { domain = "*"; item = "core"; type = "hard"; value = "0"; }
  ];

  # Root non-loginnable par mot de passe
  users.users.root.hashedPassword = "!";

  # umask restrictif — ANSSI R24
  environment.variables.UMASK = "027";
}
