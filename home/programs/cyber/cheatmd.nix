# cheatmd: interactive cheatsheets from my Markdown notes (~/Cyber/notes)
# (from anotherhadi/nixy, modules/programs/cyber/cheatmd.nix)
{
  config,
  lib,
  pkgs,
  ...
}: let
  cheatmd = pkgs.nur.repos.sectui.cheatmd;
in {
  home.packages = [cheatmd];

  xdg.configFile."cheatmd/cheatmd.yaml".text = ''
    path: ${config.home.homeDirectory}/Cyber/notes
  '';

  programs.zsh.initContent = lib.mkOrder 1100 ''
    if [[ $options[zle] = on ]]; then
      eval "$(${cheatmd}/bin/cheatmd widget zsh)"
    fi
  '';
}
