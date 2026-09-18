{lib, ...}: let
  # Reuse the exact same bookmark datasets as Helium (single source of truth).
  categories = [
    (import ../../helium/bookmarks/general.nix)
    (import ../../helium/bookmarks/tools.nix)
    (import ../../helium/bookmarks/entertainment.nix)
    (import ../../helium/bookmarks/infosec.nix)
    (import ../../helium/bookmarks/other.nix)
    (import ../../helium/bookmarks/jack.nix)
  ];

  # Helium bookmarks carry a Chromium-only `icon` field that the home-manager
  # Firefox bookmarks format does not understand, so we strip it.
  toFirefox = item:
    if item ? url
    then {inherit (item) name url;}
    else {
      inherit (item) name;
      bookmarks = map toFirefox item.bookmarks;
    };
in {
  force = true;
  settings = map toFirefox (lib.concatLists categories);
}
