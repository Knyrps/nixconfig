{ pkgs, ... }:

{
  programs.nushell.enable = true;

  home.packages = with pkgs; [
    git
    vim
    jq
    pciutils
    hyfetch
    fastfetch
  ];
}
