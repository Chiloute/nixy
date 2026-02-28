# Those are my secrets, encrypted with sops
# You shouldn't import this file, unless you edit it
{
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  sops = {
    age.keyFile = "/home/chiloute/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      sshconfig = {path = "/home/chiloute/.ssh/config";};
      key = {path = "/home/chiloute/.ssh/key";};
      srv_key = {path = "/home/chiloute/.ssh/srv_key";};
    };
  };

  home.file.".config/nixos/.sops.yaml".text = ''
    keys:
      - &primary age1n467vk6xtjl0rthlua4y5e2fwhcmnnj7sw7p8fw3sxsxsz3y4uhq0z8qcg
    creation_rules:
      - path_regex: hosts/laptop/secrets/secrets.yaml$
        key_groups:
          - age:
            - *primary
  '';

  systemd.user.services.mbsync.Unit.After = ["sops-nix.service"];
  home.packages = with pkgs; [sops age];

  wayland.windowManager.hyprland.settings.exec-once = ["systemctl --user start sops-nix"];
}
