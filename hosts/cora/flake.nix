{ inputs, ... }:
inputs.nixos-raspberrypi.lib.nixosSystem {
  modules = [
    {
      _module.args = { inherit inputs; };
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
