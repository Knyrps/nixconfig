{ config, lib, ... }:

{
  options.host = {
    roles = lib.mkOption {
      type = lib.types.listOf (lib.types.enum [
        "ui" "laptop" "ssh" "bluetooth" "networkmanager" "personal" "work" "coding" "gaming" "multimedia"
      ]);
      default = [ ];
    };
    has = lib.mkOption {
      type = lib.types.functionTo lib.types.bool;
      readOnly = true;
      default = role: lib.elem role config.host.roles;
    };
  };
}
