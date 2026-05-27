{inputs, ...}:
inputs.nixos-raspberrypi.lib.nixosSystem {
  modules = [
    {
      _module.args = {
        inherit inputs;
        pkgs-stable = inputs.nixpkgs-stable.legacyPackages.aarch64-linux; # arm achitecture for raspi
      };
    }
    (with inputs.nixos-raspberrypi.nixosModules; {
      imports = [
        raspberry-pi-4.base
        raspberry-pi-4.display-vc4
      ];
    })
    ./configuration.nix
  ];
}
