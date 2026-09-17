{ lib, ... }:

{
  imports = lib.filter
    (path: lib.hasSuffix ".home.nix" (toString path))
    (lib.filesystem.listFilesRecursive ./src);

  home.stateVersion = "26.05";
}
