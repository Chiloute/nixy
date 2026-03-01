# This file is used to sign git commits using an SSH key.
{
  # CHANGEME: change this to your own SSH key.
  home.file.".ssh/allowed_signers".text = "* ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP3ur24Y8350g35k/tayyit8I04e2ZOx7pNryZUfItGt";

  programs.git.settings = {
    commit.gpgsign = true;
    gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
    gpg.format = "ssh";
    user.signingkey = "~/.ssh/sign_key.pub";
  };
}
