{
  inputs,
  nixpkgs,
  pkgs-stable,
  ...
}:
nixpkgs.lib.nixosSystem {
  modules = [
    {_module.args = {inherit inputs pkgs-stable;};}
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix
    inputs.sops-nix.nixosModules.sops
    inputs.nixarr.nixosModules.default
    inputs.nix-index-database.nixosModules.default
    inputs.default-creds.nixosModules.default
    ./configuration.nix
  ];
}
