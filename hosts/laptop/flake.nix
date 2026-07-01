{
  inputs,
  nixpkgs,
  pkgs-stable,
  ...
}:
nixpkgs.lib.nixosSystem {
  modules = [
    {
      nixpkgs.overlays = [
      ];
      _module.args = {inherit inputs pkgs-stable;};
    }
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-12th-gen # check https://github.com/NixOS/nixos-hardware
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix
    inputs.nix-index-database.nixosModules.default
    inputs.helium-browser.nixosModules.default
    ./configuration.nix
  ];
}
