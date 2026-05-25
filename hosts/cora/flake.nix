{ inputs, ... }:
inputs.nixpkgs-stable.lib.nixosSystem {
  modules = [
    {
      nixpkgs.hostPlatform = "aarch64-linux";
      _module.args = { inherit inputs; };
    }
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ./configuration.nix
  ];
}
