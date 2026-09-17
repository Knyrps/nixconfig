{ lib, ... }:

{
  imports = lib.filter
    (path: lib.hasSuffix ".os.nix" (toString path))
    (lib.filesystem.listFilesRecursive ./src);

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "knyrps" ];
  };
}
