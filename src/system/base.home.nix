{ pkgs, ... }:

{
  programs.nushell.enable = true;

  programs.git = {
    enable = true;
    settings.user = {
      name = "knyrps";
      email = "knyrps@knyrps.net";
    };
  };

  home.packages = with pkgs; [
    vim
    jq
    pciutils
    hyfetch
    fastfetch
  ];
}
