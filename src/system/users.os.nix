{ config, lib, ... }:

{
  users.users.knyrps = {
    isNormalUser = true;
    description = "knyrps";
    extraGroups = [ "wheel" ] ++ lib.optional config.features.networkmanager.enable "networkmanager";
  };
}
