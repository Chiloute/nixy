{
  inputs,
  nixpkgs,
  pkgs-unstable,
  pkgs-stable,
  ...
}:
nixpkgs.lib.nixosSystem {
  modules = [
    {
      nixpkgs.overlays = [
        inputs.nur.overlays.default
      ];
      _module.args = {inherit inputs pkgs-unstable pkgs-stable;};
    }
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-12th-gen # check https://github.com/NixOS/nixos-hardware
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix
    inputs.sops-nix.nixosModules.sops
    inputs.nix-index-database.nixosModules.default
    inputs.helium-browser.nixosModules.default
    inputs.impermanence.nixosModules.impermanence
    inputs.disko.nixosModules.disko
    ./configuration.nix
  ];
}
