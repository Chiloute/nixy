# This file is used to sign git commits using an SSH key.
{
  # CHANGEME: change this to your own SSH key.
  home.file.".ssh/allowed_signers".text = "* ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFCStVa0DrQ4qrHapcpP1H+c0qVSrwpp45hrCfGJCTnm";

  # gcr-ssh-agent (gnome-keyring) déverrouille les clés au login mais
  # n'exporte plus SSH_AUTH_SOCK dans le shell depuis gcr 4.x
  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";

  programs.git = {
    signing.format = "openpgp";
    settings = {
      commit.gpgsign = true;
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/github.pub";
    };
    includes = [
      {
        condition = "gitdir:/home/chiloute/dev/gitlab/";
        contents = {
          user = {
            email = "1297-Chiloute@users.noreply.456d073557fa";
            name = "Chiloute";
            # CHANGEME: remplace par la clé de signature GitLab
            signingkey = "~/.ssh/gitlab.pub";
          };
        };
      }
    ];
  };
}
