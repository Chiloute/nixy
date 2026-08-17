# Home-manager configuration for NixOS
{
  inputs,
  pkgs-unstable,
  pkgs-stable,
  ...
}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = {
      inherit inputs pkgs-unstable pkgs-stable;
    };
  };
}
