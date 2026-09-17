{ lib, ... }:

{
  imports = lib.filter
    (path: lib.hasSuffix ".os.nix" (toString path))
    (lib.filesystem.listFilesRecursive ./src);
}
