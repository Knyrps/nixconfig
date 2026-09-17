{ config, lib, ... }:

{
  users.users.knyrps = {
    isNormalUser = true;
    description = "knyrps";
    extraGroups = lib.optional config.features.networkmanager.enable "networkmanager" ++ [ "wheel" ];
  };
}
