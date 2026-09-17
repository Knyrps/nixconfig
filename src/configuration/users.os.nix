{ pkgs, ... }: {
  users.users."knyrps" = {
    isNormalUser = true;
    description = "knyrps";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };
}
